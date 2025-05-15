import React from 'react';

/**
 * Tooltip Component
 *
 * A basic tooltip container component.
 */
const Tooltip = ({ children, className = '', ...props }) => {
  return (
    <div 
      className={`${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default Tooltip; 