import React from 'react';

const SelectValue = ({ placeholder, className = '', ...props }) => {
  return (
    <span 
      className={`truncate ${className}`}
      {...props}
    >
      {placeholder}
    </span>
  );
};

export default SelectValue; 