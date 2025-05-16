import React, { useState, useEffect } from 'react';

const UninstallerDashboard = () => {
  const [uninstallStatus, setUninstallStatus] = useState('idle');
  const [uninstallProgress, setUninstallProgress] = useState(0);
  const [systemInfo, setSystemInfo] = useState({
    osVersion: '',
    cursorVersion: '',
    diskSpace: '',
    hasBackup: false
  });

  useEffect(() => {
    // On component mount, check system info
    fetchSystemInfo();
  }, []);

  const fetchSystemInfo = async () => {
    try {
      // In a real implementation, this would call an API endpoint
      // or use MCP to get actual system information
      setSystemInfo({
        osVersion: 'macOS 14.5',
        cursorVersion: '0.49.6',
        diskSpace: '15.2 GB free',
        hasBackup: true
      });
    } catch (error) {
      console.error('Failed to fetch system info:', error);
    }
  };

  const handleUninstall = async () => {
    if (uninstallStatus === 'running') return;
    
    setUninstallStatus('running');
    setUninstallProgress(0);
    
    // Simulate uninstall progress
    const intervalId = setInterval(() => {
      setUninstallProgress(prev => {
        const newProgress = prev + 5;
        if (newProgress >= 100) {
          clearInterval(intervalId);
          setUninstallStatus('completed');
          return 100;
        }
        return newProgress;
      });
    }, 500);
  };

  const handleOptimize = () => {
    alert('Optimization feature coming soon!');
  };

  const handleBackup = () => {
    alert('Backup feature coming soon!');
  };

  return (
    <div className="uninstaller-dashboard">
      <h1>Cursor AI Editor Uninstaller</h1>
      
      <div className="system-info-panel">
        <h2>System Information</h2>
        <ul>
          <li><strong>OS Version:</strong> {systemInfo.osVersion}</li>
          <li><strong>Cursor Version:</strong> {systemInfo.cursorVersion}</li>
          <li><strong>Available Disk Space:</strong> {systemInfo.diskSpace}</li>
          <li>
            <strong>Backup Status:</strong> 
            <span className={systemInfo.hasBackup ? 'status-ok' : 'status-warning'}>
              {systemInfo.hasBackup ? 'Backup Available' : 'No Backup Found'}
            </span>
          </li>
        </ul>
      </div>

      <div className="action-panel">
        <h2>Actions</h2>
        <div className="button-row">
          <button 
            className="uninstall-button" 
            onClick={handleUninstall}
            disabled={uninstallStatus === 'running'}
          >
            {uninstallStatus === 'completed' ? 'Uninstallation Complete' : 'Uninstall Cursor AI'}
          </button>
          
          <button className="optimize-button" onClick={handleOptimize}>
            Optimize Performance
          </button>
          
          <button className="backup-button" onClick={handleBackup}>
            Create Backup
          </button>
        </div>
      </div>

      {uninstallStatus === 'running' && (
        <div className="progress-container">
          <h3>Uninstallation Progress</h3>
          <div className="progress-bar-container">
            <div 
              className="progress-bar" 
              style={{ width: `${uninstallProgress}%` }}
            ></div>
          </div>
          <p>{uninstallProgress}% Complete</p>
        </div>
      )}

      {uninstallStatus === 'completed' && (
        <div className="success-message">
          <h3>Uninstallation Successful</h3>
          <p>Cursor AI Editor has been successfully removed from your system.</p>
        </div>
      )}
    </div>
  );
};

export default UninstallerDashboard; 