/**
 * IPC Channel - Inter-process communication for shadow workspaces
 * Provides message passing protocol for safe edit application and diagnostics
 * Target: Low-latency communication <10ms, reliable message delivery
 */

const EventEmitter = require('events');
const { Worker, isMainThread, parentPort, workerData } = require('worker_threads');

class IPCChannel extends EventEmitter {
    constructor(channelId, options = {}) {
        super();

        this.channelId = channelId;
        this.config = {
            maxMessageSize: options.maxMessageSize || 1048576, // 1MB
            messageTimeout: options.messageTimeout || 5000, // 5 seconds
            heartbeatInterval: options.heartbeatInterval || 30000, // 30 seconds
            enableEncryption: options.enableEncryption || false,
            enableCompression: options.enableCompression || false,
            bufferSize: options.bufferSize || 100,
            retryAttempts: options.retryAttempts || 3,
            ...options
        };

        this.state = {
            connected: false,
            initialized: false,
            messageId: 0,
            pendingMessages: new Map(),
            messageBuffer: [],
            lastHeartbeat: null,
            connectionAttempts: 0
        };

        this.worker = null;
        this.messageHandlers = new Map();
        this.heartbeatTimer = null;
        this.connectionTimer = null;

        this.stats = {
            messagesSent: 0,
            messagesReceived: 0,
            messagesDropped: 0,
            averageLatency: 0,
            totalLatency: 0,
            errorCount: 0
        };
    }

    /**
     * Initialize IPC channel
     * @returns {Promise<void>}
     */
    async initialize() {
        if (this.state.initialized) return;

        try {
            if (isMainThread) {
                await this.initializeMainThread();
            } else {
                await this.initializeWorkerThread();
            }

            this.state.initialized = true;
            this.emit('initialized', { channelId: this.channelId });

            console.log(`✅ IPC Channel ${this.channelId} initialized`);

        } catch (error) {
            this.emit('error', { phase: 'initialization', error: error.message });
            throw new Error(`IPC Channel initialization failed: ${error.message}`);
        }
    }

    /**
     * Initialize main thread side
     * @private
     */
    async initializeMainThread() {
        // Setup worker if needed
        if (this.config.useWorkerThread) {
            this.worker = new Worker(__filename, {
                workerData: {
                    channelId: this.channelId,
                    config: this.config
                }
            });

            this.setupWorkerEventHandlers();
        }

        this.setupMessageHandlers();
        this.startHeartbeat();
        this.state.connected = true;
    }

    /**
     * Initialize worker thread side
     * @private
     */
    async initializeWorkerThread() {
        if (!parentPort) {
            throw new Error('Worker thread requires parentPort');
        }

        this.setupParentPortHandlers();
        this.setupMessageHandlers();
        this.state.connected = true;
    }

    /**
     * Send message through IPC channel
     * @param {Object} message - Message to send
     * @param {Object} options - Send options
     * @returns {Promise<Object>} Response message
     */
    async sendMessage(message, options = {}) {
        if (!this.state.connected) {
            throw new Error('IPC channel not connected');
        }

        const messageId = ++this.state.messageId;
        const timestamp = Date.now();

        const envelope = {
            id: messageId,
            channelId: this.channelId,
            timestamp,
            type: message.type || 'request',
            payload: message,
            expectsResponse: options.expectsResponse !== false,
            timeout: options.timeout || this.config.messageTimeout
        };

        // Validate message size
        const messageSize = this.estimateMessageSize(envelope);
        if (messageSize > this.config.maxMessageSize) {
            throw new Error(`Message too large: ${messageSize} bytes (max: ${this.config.maxMessageSize})`);
        }

        try {
            // Apply compression if enabled
            if (this.config.enableCompression) {
                envelope.payload = this.compressPayload(envelope.payload);
                envelope.compressed = true;
            }

            // Apply encryption if enabled
            if (this.config.enableEncryption) {
                envelope.payload = this.encryptPayload(envelope.payload);
                envelope.encrypted = true;
            }

            // Send message
            if (envelope.expectsResponse) {
                return await this.sendWithResponse(envelope);
            } else {
                this.sendOneWay(envelope);
                return { success: true, messageId };
            }

        } catch (error) {
            this.stats.errorCount++;
            this.emit('error', { phase: 'sendMessage', messageId, error: error.message });
            throw error;
        }
    }

    /**
     * Send message with expected response
     * @private
     */
    async sendWithResponse(envelope) {
        return new Promise((resolve, reject) => {
            const timeout = setTimeout(() => {
                this.state.pendingMessages.delete(envelope.id);
                this.stats.messagesDropped++;
                reject(new Error(`Message timeout: ${envelope.id}`));
            }, envelope.timeout);

            this.state.pendingMessages.set(envelope.id, {
                resolve,
                reject,
                timeout,
                sentAt: envelope.timestamp
            });

            this.deliverMessage(envelope).catch(error => {
                clearTimeout(timeout);
                this.state.pendingMessages.delete(envelope.id);
                reject(error);
            });
        });
    }

    /**
     * Send one-way message
     * @private
     */
    sendOneWay(envelope) {
        this.deliverMessage(envelope).catch(error => {
            this.stats.messagesDropped++;
            this.emit('error', { phase: 'sendOneWay', error: error.message });
        });
    }

    /**
     * Deliver message through appropriate channel
     * @private
     */
    async deliverMessage(envelope) {
        this.stats.messagesSent++;

        if (this.worker) {
            // Send to worker thread
            this.worker.postMessage(envelope);
        } else if (parentPort) {
            // Send to parent thread
            parentPort.postMessage(envelope);
        } else {
            // Local delivery
            setImmediate(() => {
                this.handleMessage(envelope);
            });
        }
    }

    /**
     * Handle incoming message
     * @private
     */
    async handleMessage(envelope) {
        try {
            this.stats.messagesReceived++;
            const startTime = Date.now();

            // Validate message
            if (!this.validateMessage(envelope)) {
                throw new Error('Invalid message format');
            }

            // Decrypt payload if needed
            if (envelope.encrypted) {
                envelope.payload = this.decryptPayload(envelope.payload);
            }

            // Decompress payload if needed
            if (envelope.compressed) {
                envelope.payload = this.decompressPayload(envelope.payload);
            }

            // Handle response to pending message
            if (envelope.type === 'response' && this.state.pendingMessages.has(envelope.id)) {
                this.handleResponse(envelope, startTime);
                return;
            }

            // Handle new request
            const response = await this.processMessage(envelope);

            // Send response if expected
            if (envelope.expectsResponse && response) {
                const responseEnvelope = {
                    id: envelope.id,
                    channelId: this.channelId,
                    timestamp: Date.now(),
                    type: 'response',
                    payload: response,
                    expectsResponse: false
                };

                await this.deliverMessage(responseEnvelope);
            }

        } catch (error) {
            this.stats.errorCount++;
            this.emit('error', { phase: 'handleMessage', error: error.message, envelope });

            // Send error response if expected
            if (envelope.expectsResponse) {
                const errorResponse = {
                    id: envelope.id,
                    channelId: this.channelId,
                    timestamp: Date.now(),
                    type: 'response',
                    payload: { error: error.message },
                    expectsResponse: false
                };

                await this.deliverMessage(errorResponse).catch(() => {
                    // Ignore delivery errors for error responses
                });
            }
        }
    }

    /**
     * Handle response to pending message
     * @private
     */
    handleResponse(envelope, startTime) {
        const pending = this.state.pendingMessages.get(envelope.id);
        if (!pending) return;

        // Clear timeout and remove from pending
        clearTimeout(pending.timeout);
        this.state.pendingMessages.delete(envelope.id);

        // Calculate latency
        const latency = startTime - pending.sentAt;
        this.updateLatencyStats(latency);

        // Resolve promise
        if (envelope.payload.error) {
            pending.reject(new Error(envelope.payload.error));
        } else {
            pending.resolve(envelope.payload);
        }
    }

    /**
     * Process incoming message
     * @private
     */
    async processMessage(envelope) {
        const { type, payload } = envelope;

        // Handle built-in message types
        switch (type) {
            case 'ping':
                return { type: 'pong', timestamp: Date.now() };

            case 'pong':
                this.state.lastHeartbeat = Date.now();
                return null;

            case 'shutdown':
                await this.shutdown();
                return { success: true };

            default:
                // Handle custom message types
                const handler = this.messageHandlers.get(type);
                if (handler) {
                    return await handler(payload, envelope);
                } else {
                    this.emit('message', { type, payload, envelope });
                    return { received: true };
                }
        }
    }

    /**
     * Register message handler
     * @param {string} messageType - Type of message to handle
     * @param {Function} handler - Handler function
     */
    onMessage(messageType, handler) {
        this.messageHandlers.set(messageType, handler);
    }

    /**
     * Setup worker event handlers
     * @private
     */
    setupWorkerEventHandlers() {
        this.worker.on('message', (envelope) => {
            this.handleMessage(envelope);
        });

        this.worker.on('error', (error) => {
            this.emit('error', { phase: 'worker', error: error.message });
        });

        this.worker.on('exit', (code) => {
            this.state.connected = false;
            this.emit('disconnected', { code });
        });
    }

    /**
     * Setup parent port handlers
     * @private
     */
    setupParentPortHandlers() {
        parentPort.on('message', (envelope) => {
            this.handleMessage(envelope);
        });
    }

    /**
     * Setup default message handlers
     * @private
     */
    setupMessageHandlers() {
        // Shadow workspace message handlers
        this.onMessage('applyEdit', async (payload) => {
            // Mock edit application
            return {
                success: true,
                diagnostics: [],
                timestamp: Date.now()
            };
        });

        this.onMessage('getDiagnostics', async (payload) => {
            // Mock diagnostics retrieval
            return {
                diagnostics: [],
                timestamp: Date.now()
            };
        });

        this.onMessage('runTests', async (payload) => {
            // Mock test execution
            return {
                success: true,
                tests: [],
                passed: 0,
                failed: 0,
                timestamp: Date.now()
            };
        });
    }

    /**
     * Start heartbeat mechanism
     * @private
     */
    startHeartbeat() {
        if (this.config.heartbeatInterval <= 0) return;

        this.heartbeatTimer = setInterval(async () => {
            try {
                await this.sendMessage({ type: 'ping' }, { timeout: 5000 });
            } catch (error) {
                console.warn(`Heartbeat failed for channel ${this.channelId}:`, error.message);
                this.emit('heartbeatFailed', { error: error.message });
            }
        }, this.config.heartbeatInterval);
    }

    /**
     * Validate message format
     * @private
     */
    validateMessage(envelope) {
        return envelope &&
            typeof envelope.id === 'number' &&
            typeof envelope.channelId === 'string' &&
            typeof envelope.timestamp === 'number' &&
            typeof envelope.type === 'string' &&
            envelope.payload !== undefined;
    }

    /**
     * Estimate message size
     * @private
     */
    estimateMessageSize(envelope) {
        try {
            return JSON.stringify(envelope).length * 2; // UTF-16 estimation
        } catch {
            return 0;
        }
    }

    /**
     * Compress payload (mock implementation)
     * @private
     */
    compressPayload(payload) {
        // Mock compression - in production would use actual compression
        return payload;
    }

    /**
     * Decompress payload (mock implementation)
     * @private
     */
    decompressPayload(payload) {
        // Mock decompression
        return payload;
    }

    /**
     * Encrypt payload (mock implementation)
     * @private
     */
    encryptPayload(payload) {
        // Mock encryption - in production would use actual encryption
        return payload;
    }

    /**
     * Decrypt payload (mock implementation)
     * @private
     */
    decryptPayload(payload) {
        // Mock decryption
        return payload;
    }

    /**
     * Update latency statistics
     * @private
     */
    updateLatencyStats(latency) {
        this.stats.totalLatency += latency;
        this.stats.averageLatency = this.stats.totalLatency / this.stats.messagesSent;
    }

    /**
     * Get IPC channel statistics
     * @returns {Object} Channel statistics
     */
    getStats() {
        return {
            ...this.stats,
            channelId: this.channelId,
            connected: this.state.connected,
            pendingMessages: this.state.pendingMessages.size,
            lastHeartbeat: this.state.lastHeartbeat,
            averageLatency: Math.round(this.stats.averageLatency)
        };
    }

    /**
     * Shutdown IPC channel
     * @returns {Promise<void>}
     */
    async shutdown() {
        try {
            this.state.connected = false;

            // Clear timers
            if (this.heartbeatTimer) {
                clearInterval(this.heartbeatTimer);
                this.heartbeatTimer = null;
            }

            if (this.connectionTimer) {
                clearTimeout(this.connectionTimer);
                this.connectionTimer = null;
            }

            // Reject pending messages
            for (const [messageId, pending] of this.state.pendingMessages.entries()) {
                clearTimeout(pending.timeout);
                pending.reject(new Error('IPC channel shutdown'));
            }
            this.state.pendingMessages.clear();

            // Terminate worker
            if (this.worker) {
                await this.worker.terminate();
                this.worker = null;
            }

            this.emit('shutdown', { channelId: this.channelId });

        } catch (error) {
            this.emit('error', { phase: 'shutdown', error: error.message });
            throw error;
        }
    }
}

// Worker thread entry point
if (!isMainThread && workerData) {
    (async () => {
        try {
            const channel = new IPCChannel(workerData.channelId, workerData.config);
            await channel.initialize();

            // Keep worker alive
            process.on('SIGTERM', async () => {
                await channel.shutdown();
                process.exit(0);
            });

        } catch (error) {
            console.error('Worker thread initialization failed:', error.message);
            process.exit(1);
        }
    })();
}

module.exports = IPCChannel; 