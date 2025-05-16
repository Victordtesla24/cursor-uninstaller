import React from 'react';

/**
 * CardTitle Component
 *
 * Title element for a card component.
 */
const CardTitle = ({ children, className = '', ...props }) => {
  return (
    <h3
      className={`text-lg font-semibold leading-none tracking-tight ${className}`}
      {...props}
    >
      {children}
    </h3>
  );
};

export default CardTitle;
