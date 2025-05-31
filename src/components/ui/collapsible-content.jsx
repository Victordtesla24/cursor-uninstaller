import React from 'react';

const CollapsibleContent = ({ open, children, className, ...props }) => {
  if (!open) return null;
  
  return (
    <div className={`collapsible-content ${className || ''}`} {...props}>
      {children}
    </div>
  );
};

export default CollapsibleContent;
