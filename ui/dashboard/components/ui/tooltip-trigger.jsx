import React from 'react';

/**
 * TooltipTrigger Component
 *
 * The trigger element that shows a tooltip on hover/focus.
 */
const TooltipTrigger = ({ children, asChild, className = '', ...props }) => {
  return (
    <div
      className={`${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default TooltipTrigger;
