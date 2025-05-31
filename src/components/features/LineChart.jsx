import React from 'react';

const LineChart = ({ 
  data = [],
  className = '',
  width = 400,
  height = 300,
  ...props 
}) => {
  return (
    <div 
      className={`line-chart ${className}`}
      style={{ width, height }}
      {...props}
    >
      <svg width={width} height={height}>
        {/* Basic line chart implementation */}
        <text x={width/2} y={height/2} textAnchor="middle" className="text-muted-foreground">
          Line Chart Component
        </text>
      </svg>
    </div>
  );
};

export default LineChart; 