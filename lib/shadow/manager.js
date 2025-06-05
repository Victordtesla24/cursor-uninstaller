/**
 * Shadow Manager - Manages multiple shadow workspaces and resource pooling
 * Handles workspace lifecycle, resource allocation, and concurrency
 * Target: Manage up to 10 concurrent workspaces, efficient resource usage
 */

const EventEmitter = require('events');
const ShadowWorkspace = require('./workspace');

class ShadowManager extends EventEmitter {
    constructor(options = {}) {
        super();

        this.config = {
            maxConcurrentWorkspaces: options.maxConcurrentWorkspaces || 5,
            maxIdleTime: options.maxIdleTime || 300000, // 5 minutes
            memoryThresholdMB: options.memoryThresholdMB || 1000, // 1GB
            enableResourcePooling: options.enableResourcePooling !== false,
            enableAutoCleanup: options.enableAutoCleanup !== false,
            poolWarmupSize: options.poolWarmupSize || 2,
            workspaceDefaults: {
                maxMemoryMB: 200,
                setupTimeoutMs: 2000,
                cleanupOnShutdown: true,
                ...options.workspaceDefaults
            },
            ...options
        };

        this.workspaces = new Map(); // active workspaces
        this.workspacePool = []; // pre-warmed workspaces
        this.workspaceQueue = []; // queued workspace requests
        this.initialized = false;

        this.stats = {
            totalWorkspacesCreated: 0,
            workspacesInUse: 0,
            workspacesPooled: 0,
            totalEditsApplied: 0,
            totalDiagnosticsGenerated: 0,
            memoryUsageMB: 0,
            averageWorkspaceLifetime: 0
        };

        this.cleanupInterval = null;
    }

    /**
     * Initialize shadow manager
     * @param {Array} workspaceConfigs - Initial workspace configurations
     * @returns {Promise<void>}
     */
    async initialize(workspaceConfigs = []) {
        if (this.initialized) return;

        try {
            console.log('🚀 Initializing Shadow Manager...');

            // Pre-warm workspace pool
            if (this.config.enableResourcePooling) {
                await this.warmupPool();
            }

            // Create initial workspaces
            for (const config of workspaceConfigs) {
                await this.createWorkspace(config);
            }

            // Setup automatic cleanup
            if (this.config.enableAutoCleanup) {
                this.startPeriodicCleanup();
            }

            this.initialized = true;
            this.emit('initialized');

            console.log(`✅ Shadow Manager initialized with ${this.workspaces.size} active workspaces`);

        } catch (error) {
            this.emit('error', { phase: 'initialization', error: error.message });
            throw new Error(`Shadow Manager initialization failed: ${error.message}`);
        }
    }

    /**
     * Create a new shadow workspace
     * @param {Object} config - Workspace configuration
     * @returns {Promise<string>} Workspace ID
     */
    async createWorkspace(config = {}) {
        try {
            // Check resource limits
            if (this.workspaces.size >= this.config.maxConcurrentWorkspaces) {
                throw new Error(`Maximum concurrent workspaces (${this.config.maxConcurrentWorkspaces}) reached`);
            }

            // Check memory threshold
            const currentMemory = this.getTotalMemoryUsage();
            if (currentMemory > this.config.memoryThresholdMB) {
                await this.performMemoryCleanup();
            }

            // Try to get workspace from pool first
            let workspace = null;
            if (this.config.enableResourcePooling && this.workspacePool.length > 0) {
                workspace = this.workspacePool.pop();
                await this.reconfigureWorkspace(workspace, config);
                console.log(`♻️  Reused pooled workspace: ${workspace.config.workspaceId}`);
            } else {
                // Create new workspace
                const workspaceConfig = {
                    ...this.config.workspaceDefaults,
                    ...config
                };

                workspace = new ShadowWorkspace(workspaceConfig);
                await workspace.initialize();

                this.stats.totalWorkspacesCreated++;
                console.log(`🆕 Created new workspace: ${workspace.config.workspaceId}`);
            }

            // Setup workspace event handlers
            this.setupWorkspaceEventHandlers(workspace);

            // Add to active workspaces
            this.workspaces.set(workspace.config.workspaceId, {
                workspace,
                createdAt: Date.now(),
                lastUsed: Date.now(),
                editsApplied: 0,
                diagnosticsGenerated: 0
            });

            this.stats.workspacesInUse = this.workspaces.size;
            this.stats.workspacesPooled = this.workspacePool.length;

            this.emit('workspaceCreated', {
                workspaceId: workspace.config.workspaceId,
                totalActive: this.workspaces.size
            });

            return workspace.config.workspaceId;

        } catch (error) {
            this.emit('error', { phase: 'createWorkspace', error: error.message });
            throw error;
        }
    }

    /**
     * Get an existing workspace
     * @param {string} workspaceId - Workspace ID
     * @returns {ShadowWorkspace|null} Workspace instance
     */
    getWorkspace(workspaceId) {
        const workspaceData = this.workspaces.get(workspaceId);
        if (!workspaceData) return null;

        // Update last used time
        workspaceData.lastUsed = Date.now();
        return workspaceData.workspace;
    }

    /**
     * Apply edit to workspace
     * @param {string} workspaceId - Workspace ID
     * @param {Object} edit - Edit operation
     * @returns {Promise<Object>} Edit result
     */
    async applyEdit(workspaceId, edit) {
        const workspace = this.getWorkspace(workspaceId);
        if (!workspace) {
            throw new Error(`Workspace not found: ${workspaceId}`);
        }

        try {
            const result = await workspace.applyEdit(edit);

            // Update statistics
            const workspaceData = this.workspaces.get(workspaceId);
            if (workspaceData) {
                workspaceData.editsApplied++;
                workspaceData.diagnosticsGenerated += result.diagnostics?.length || 0;
            }

            this.stats.totalEditsApplied++;
            this.stats.totalDiagnosticsGenerated += result.diagnostics?.length || 0;

            return result;

        } catch (error) {
            this.emit('error', { phase: 'applyEdit', workspaceId, error: error.message });
            throw error;
        }
    }

    /**
     * Release workspace back to pool or destroy
     * @param {string} workspaceId - Workspace ID
     * @param {boolean} forceDestroy - Force destruction instead of pooling
     * @returns {Promise<void>}
     */
    async releaseWorkspace(workspaceId, forceDestroy = false) {
        const workspaceData = this.workspaces.get(workspaceId);
        if (!workspaceData) return;

        const { workspace, createdAt } = workspaceData;

        try {
            // Remove from active workspaces
            this.workspaces.delete(workspaceId);

            // Update lifetime statistics
            const lifetime = Date.now() - createdAt;
            this.updateAverageLifetime(lifetime);

            if (forceDestroy || !this.config.enableResourcePooling ||
                this.workspacePool.length >= this.config.poolWarmupSize) {
                // Destroy workspace
                await workspace.cleanup();
                console.log(`🗑️  Destroyed workspace: ${workspaceId}`);
                this.emit('workspaceDestroyed', { workspaceId, lifetime });
            } else {
                // Return to pool
                await this.resetWorkspaceForPool(workspace);
                this.workspacePool.push(workspace);
                console.log(`🔄 Returned workspace to pool: ${workspaceId}`);
                this.emit('workspacePooled', { workspaceId });
            }

            this.stats.workspacesInUse = this.workspaces.size;
            this.stats.workspacesPooled = this.workspacePool.length;

        } catch (error) {
            this.emit('error', { phase: 'releaseWorkspace', workspaceId, error: error.message });
            // Force cleanup on error
            try {
                await workspace.cleanup();
            } catch (cleanupError) {
                console.error(`Failed to cleanup workspace ${workspaceId}:`, cleanupError.message);
            }
        }
    }

    /**
     * Get manager statistics
     * @returns {Object} Manager statistics
     */
    getStats() {
        const memoryUsage = this.getTotalMemoryUsage();

        return {
            ...this.stats,
            memoryUsageMB: memoryUsage,
            workspaceDetails: Array.from(this.workspaces.entries()).map(([id, data]) => ({
                workspaceId: id,
                createdAt: data.createdAt,
                lastUsed: data.lastUsed,
                editsApplied: data.editsApplied,
                diagnosticsGenerated: data.diagnosticsGenerated,
                memoryUsage: data.workspace.getMemoryUsage()
            }))
        };
    }

    /**
     * Cleanup idle workspaces
     * @returns {Promise<void>}
     */
    async cleanupIdleWorkspaces() {
        const now = Date.now();
        const idleWorkspaces = [];

        for (const [workspaceId, data] of this.workspaces.entries()) {
            const idleTime = now - data.lastUsed;
            if (idleTime > this.config.maxIdleTime) {
                idleWorkspaces.push(workspaceId);
            }
        }

        for (const workspaceId of idleWorkspaces) {
            console.log(`🧹 Cleaning up idle workspace: ${workspaceId}`);
            await this.releaseWorkspace(workspaceId, true);
        }

        return idleWorkspaces.length;
    }

    /**
     * Shutdown manager and cleanup all resources
     * @returns {Promise<void>}
     */
    async shutdown() {
        try {
            console.log('🛑 Shutting down Shadow Manager...');

            // Stop periodic cleanup
            if (this.cleanupInterval) {
                clearInterval(this.cleanupInterval);
                this.cleanupInterval = null;
            }

            // Shutdown all active workspaces
            const shutdownPromises = [];
            for (const [workspaceId, data] of this.workspaces.entries()) {
                shutdownPromises.push(
                    data.workspace.cleanup().catch(error => {
                        console.error(`Failed to cleanup workspace ${workspaceId}:`, error.message);
                    })
                );
            }

            // Shutdown pooled workspaces
            for (const workspace of this.workspacePool) {
                shutdownPromises.push(
                    workspace.cleanup().catch(error => {
                        console.error(`Failed to cleanup pooled workspace:`, error.message);
                    })
                );
            }

            await Promise.all(shutdownPromises);

            // Clear collections
            this.workspaces.clear();
            this.workspacePool.length = 0;
            this.workspaceQueue.length = 0;

            this.initialized = false;
            this.emit('shutdown');

            console.log('✅ Shadow Manager shutdown complete');

        } catch (error) {
            this.emit('error', { phase: 'shutdown', error: error.message });
            throw error;
        }
    }

    // Private Methods

    /**
     * Warm up workspace pool
     * @private
     */
    async warmupPool() {
        console.log(`🔥 Warming up workspace pool (${this.config.poolWarmupSize} workspaces)...`);

        const warmupPromises = [];
        for (let i = 0; i < this.config.poolWarmupSize; i++) {
            warmupPromises.push(this.createPooledWorkspace());
        }

        await Promise.all(warmupPromises);
        console.log(`✅ Workspace pool warmed up with ${this.workspacePool.length} workspaces`);
    }

    /**
     * Create workspace for pool
     * @private
     */
    async createPooledWorkspace() {
        const workspace = new ShadowWorkspace(this.config.workspaceDefaults);
        await workspace.initialize();
        this.workspacePool.push(workspace);
        this.stats.totalWorkspacesCreated++;
    }

    /**
     * Reconfigure workspace from pool
     * @private
     */
    async reconfigureWorkspace(workspace, config) {
        // Update configuration
        Object.assign(workspace.config, config);

        // Reset state
        workspace.state.filesModified.clear();
        workspace.state.diagnostics.clear();
        workspace.state.lastActivity = Date.now();

        // Could add more reconfiguration logic here
    }

    /**
     * Reset workspace for return to pool
     * @private
     */
    async resetWorkspaceForPool(workspace) {
        // Clear state
        workspace.state.filesModified.clear();
        workspace.state.diagnostics.clear();
        workspace.state.lastActivity = null;

        // Reset statistics
        workspace.stats.editsApplied = 0;
        workspace.stats.lintsGenerated = 0;
        workspace.stats.testsRun = 0;
        workspace.stats.diagnosticsCount = 0;

        // Could add file cleanup logic here
    }

    /**
     * Setup event handlers for workspace
     * @private
     */
    setupWorkspaceEventHandlers(workspace) {
        workspace.on('error', (error) => {
            this.emit('workspaceError', {
                workspaceId: workspace.config.workspaceId,
                error
            });
        });

        workspace.on('editApplied', (result) => {
            this.emit('editApplied', {
                workspaceId: workspace.config.workspaceId,
                result
            });
        });

        workspace.on('diagnosticsReceived', (data) => {
            this.emit('diagnosticsReceived', {
                workspaceId: workspace.config.workspaceId,
                ...data
            });
        });
    }

    /**
     * Start periodic cleanup
     * @private
     */
    startPeriodicCleanup() {
        this.cleanupInterval = setInterval(async () => {
            try {
                const cleanedCount = await this.cleanupIdleWorkspaces();
                if (cleanedCount > 0) {
                    console.log(`🧹 Periodic cleanup removed ${cleanedCount} idle workspaces`);
                }

                // Check memory usage
                const memoryUsage = this.getTotalMemoryUsage();
                if (memoryUsage > this.config.memoryThresholdMB) {
                    await this.performMemoryCleanup();
                }

            } catch (error) {
                console.error('Periodic cleanup error:', error.message);
            }
        }, 60000); // Every minute
    }

    /**
     * Get total memory usage across all workspaces
     * @private
     */
    getTotalMemoryUsage() {
        let totalMemory = 0;

        for (const data of this.workspaces.values()) {
            const memoryUsage = data.workspace.getMemoryUsage();
            totalMemory += memoryUsage.heapUsedMB;
        }

        for (const workspace of this.workspacePool) {
            const memoryUsage = workspace.getMemoryUsage();
            totalMemory += memoryUsage.heapUsedMB;
        }

        return totalMemory;
    }

    /**
     * Perform emergency memory cleanup
     * @private
     */
    async performMemoryCleanup() {
        console.log('⚠️  Memory threshold exceeded, performing cleanup...');

        // Sort workspaces by last used time (oldest first)
        const sortedWorkspaces = Array.from(this.workspaces.entries())
            .sort((a, b) => a[1].lastUsed - b[1].lastUsed);

        // Clean up oldest workspaces until under threshold
        let cleanedCount = 0;
        const maxToClean = Math.ceil(this.workspaces.size * 0.3); // Clean up to 30%

        for (const [workspaceId] of sortedWorkspaces) {
            if (cleanedCount >= maxToClean) break;
            if (this.getTotalMemoryUsage() <= this.config.memoryThresholdMB * 0.8) break;

            await this.releaseWorkspace(workspaceId, true);
            cleanedCount++;
        }

        // Also clean pool if needed
        while (this.workspacePool.length > 0 &&
            this.getTotalMemoryUsage() > this.config.memoryThresholdMB * 0.8) {
            const workspace = this.workspacePool.pop();
            await workspace.cleanup();
        }

        console.log(`🧹 Memory cleanup completed: cleaned ${cleanedCount} workspaces`);
    }

    /**
     * Update average workspace lifetime
     * @private
     */
    updateAverageLifetime(lifetime) {
        if (this.stats.averageWorkspaceLifetime === 0) {
            this.stats.averageWorkspaceLifetime = lifetime;
        } else {
            this.stats.averageWorkspaceLifetime =
                (this.stats.averageWorkspaceLifetime + lifetime) / 2;
        }
    }
}

module.exports = ShadowManager; 