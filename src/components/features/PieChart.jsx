import React from 'react';

const PieChart = ({ 
  data = [],
  className = '',
  width = 400,
  height = 300,
  ...props 
}) => {
  return (
    <div 
      className={`pie-chart ${className}`}
      style={{ width, height }}
      {...props}
    >
      <svg width={width} height={height}>
        {/* Basic pie chart implementation */}
        <text x={width/2} y={height/2} textAnchor="middle" className="text-muted-foreground">
          Pie Chart Component
        </text>
      </svg>
    </div>
  );
};

export default PieChart; 