import React from 'react';

const Slider = ({ 
  value = [0], 
  onValueChange,
  min = 0,
  max = 100,
  step = 1,
  className = '', 
  disabled = false,
  ...props 
}) => {
  return (
    <div className={`relative flex w-full touch-none select-none items-center ${className}`} {...props}>
      <input
        type="range"
        min={min}
        max={max}
        step={step}
        value={Array.isArray(value) ? value[0] : value}
        onChange={(e) => onValueChange?.([parseInt(e.target.value)])}
        disabled={disabled}
        className="relative h-2 w-full cursor-pointer appearance-none rounded-full bg-secondary focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
      />
    </div>
  );
};

export default Slider; 