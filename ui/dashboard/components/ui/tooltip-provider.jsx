import React from 'react';

/**
 * TooltipProvider Component
 *
 * Provider component for tooltips.
 */
const TooltipProvider = ({ children, ...props }) => {
  return (
    <div {...props}>
      {children}
    </div>
  );
};

export default TooltipProvider;
