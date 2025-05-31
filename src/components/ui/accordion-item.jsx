import React from 'react';

const AccordionItem = ({ value, children, className, ...props }) => {
  return (
    <div 
      className={`accordion-item border-b border-slate-200 dark:border-slate-700 ${className || ''}`} 
      data-value={value}
      {...props}
    >
      {children}
    </div>
  );
};

export default AccordionItem;
