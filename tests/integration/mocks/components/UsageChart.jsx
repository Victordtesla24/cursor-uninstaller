import React from 'react';

const UsageChart = ({ usageData, darkMode, ...props }) => (
  <div data-testid="usage-chart" data-dark={darkMode ? 'true' : 'false'} {...props}>
    <h3>Usage Chart Mock</h3>
    {usageData && (
      <div>
        <span>Daily Data Points: {usageData.daily?.length || 0}</span>
        <span>Weekly Data Points: {usageData.weekly?.length || 0}</span>
        <span>Monthly Data Points: {usageData.monthly?.length || 0}</span>
      </div>
    )}
  </div>
);

export default UsageChart; 