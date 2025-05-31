import React from 'react';

const Collapsible = ({ open, children, className, ...props }) => {
  return (
    <div className={`collapsible ${open ? 'open' : ''} ${className || ''}`} {...props}>
      {children}
    </div>
  );
};

export default Collapsible;
