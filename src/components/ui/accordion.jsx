import React from 'react';

const Accordion = ({ children, type = 'single', collapsible = false, className, ...props }) => {
  return (
    <div className={`accordion ${className || ''}`} data-type={type} data-collapsible={collapsible} {...props}>
      {children}
    </div>
  );
};

export default Accordion;
