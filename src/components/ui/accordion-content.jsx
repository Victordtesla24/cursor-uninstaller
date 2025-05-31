import React from 'react';

const AccordionContent = ({ children, isOpen, className, ...props }) => {
  if (!isOpen) return null;
  
  return (
    <div 
      className={`accordion-content px-1 pb-4 pt-0 text-sm ${className || ''}`} 
      {...props}
    >
      {children}
    </div>
  );
};

export default AccordionContent;
