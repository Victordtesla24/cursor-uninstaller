import React from 'react';

/**
 * CardHeader Component
 *
 * The header section of a card component.
 */
const CardHeader = ({ children, className = '', ...props }) => {
  return (
    <div
      className={`flex flex-col space-y-1.5 p-6 ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default CardHeader;
