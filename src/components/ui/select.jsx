import React from 'react';

const Select = ({ children, onValueChange, defaultValue, disabled, ...props }) => {
  return (
    <div className="relative" {...props}>
      {children}
    </div>
  );
};

export default Select; 