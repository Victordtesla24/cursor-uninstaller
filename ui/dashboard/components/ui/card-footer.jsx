import React from 'react';

/**
 * CardFooter Component
 *
 * Footer section of a card component.
 */
const CardFooter = ({ children, className = '', ...props }) => {
  return (
    <div 
      className={`flex items-center p-6 pt-0 ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default CardFooter; 