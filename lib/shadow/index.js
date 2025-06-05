/**
 * Shadow Workspace System - Main Entry Point
 * Provides isolated environment for AI iteration with lint/test feedback
 * Target: <200MB memory overhead, <2s environment setup
 */

const ShadowWorkspace = require('./workspace');
const ShadowManager = require('./manager');
const IPCChannel = require('./ipc');

module.exports = {
    ShadowWorkspace,
    ShadowManager,
    IPCChannel,

    // Factory functions for easy instantiation
    async createWorkspace(config = {}) {
        const workspace = new ShadowWorkspace(config);
        await workspace.initialize();
        return workspace;
    },

    async createManager(workspaceConfigs = []) {
        const manager = new ShadowManager();
        await manager.initialize(workspaceConfigs);
        return manager;
    },

    async createIPCChannel(channelId, options = {}) {
        const channel = new IPCChannel(channelId, options);
        await channel.initialize();
        return channel;
    }
}; 