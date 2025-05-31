import React from 'react';

const BarChart = ({ 
  data = [],
  className = '',
  width = 400,
  height = 300,
  ...props 
}) => {
  return (
    <div 
      className={`bar-chart ${className}`}
      style={{ width, height }}
      {...props}
    >
      <svg width={width} height={height}>
        {/* Basic bar chart implementation */}
        <text x={width/2} y={height/2} textAnchor="middle" className="text-muted-foreground">
          Bar Chart Component
        </text>
      </svg>
    </div>
  );
};

export default BarChart; 