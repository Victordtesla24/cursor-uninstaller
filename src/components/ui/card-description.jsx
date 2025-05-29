import React from 'react';

/**
 * CardDescription Component
 *
 * Description text for a card component.
 */
const CardDescription = ({ children, className = '', ...props }) => {
  return (
    <p
      className={`text-sm text-muted-foreground ${className}`}
      {...props}
    >
      {children}
    </p>
  );
};

export default CardDescription;
