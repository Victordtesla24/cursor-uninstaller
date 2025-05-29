import React from 'react';

/**
 * Card Component
 *
 * A container component with styling for a card-like appearance.
 */
const Card = ({ children, className = '', ...props }) => {
  return (
    <div
      className={`rounded-lg border bg-card text-card-foreground shadow-sm ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default Card;
