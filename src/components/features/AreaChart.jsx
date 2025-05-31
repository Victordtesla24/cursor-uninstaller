import React from 'react';

const AreaChart = ({ 
  data = [],
  className = '',
  width = 400,
  height = 300,
  ...props 
}) => {
  return (
    <div 
      className={`area-chart ${className}`}
      style={{ width, height }}
      {...props}
    >
      <svg width={width} height={height}>
        {/* Basic area chart implementation */}
        <text x={width/2} y={height/2} textAnchor="middle" className="text-muted-foreground">
          Area Chart Component
        </text>
      </svg>
    </div>
  );
};

export default AreaChart; 