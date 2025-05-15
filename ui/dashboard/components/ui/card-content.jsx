import React from 'react';

/**
 * CardContent Component
 *
 * Content section of a card component.
 */
const CardContent = ({ children, className = '', ...props }) => {
  return (
    <div 
      className={`p-6 pt-0 ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default CardContent; 