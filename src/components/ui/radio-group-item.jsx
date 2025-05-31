import React from 'react';

const RadioGroupItem = ({ 
  value, 
  id,
  className = '', 
  disabled = false,
  ...props 
}) => {
  return (
    <input
      type="radio"
      id={id}
      value={value}
      disabled={disabled}
      className={`aspect-square h-4 w-4 rounded-full border border-primary text-primary ring-offset-background focus:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 ${className}`}
      {...props}
    />
  );
};

export default RadioGroupItem; 