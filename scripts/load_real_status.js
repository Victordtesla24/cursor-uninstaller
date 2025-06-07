// Real Status Data Loader - Production Grade
// Loads actual system status data for dashboard integration

async function loadRealStatusData() {
    try {
        // Try to load the local status file
        const response = await fetch('./scripts/.cursor-status-web.json');
        if (response.ok) {
            const data = await response.json();
            console.log('✅ Loaded real status data:', data.timestamp);
            return data;
        }
    } catch (error) {
        console.warn('⚠️ Real status data not available:', error.message);
    }
    return null;
}

// Export for use in dashboard
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { loadRealStatusData };
}
