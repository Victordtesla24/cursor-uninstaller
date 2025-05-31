import React from 'react';

const CollapsibleTrigger = ({ onClick, children, className, ...props }) => {
  return (
    <div
      role="button"
      tabIndex={0}
      className={`collapsible-trigger cursor-pointer ${className || ''}`}
      onClick={onClick}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          onClick?.(e);
        }
      }}
      {...props}
    >
      {children}
    </div>
  );
};

export default CollapsibleTrigger;
