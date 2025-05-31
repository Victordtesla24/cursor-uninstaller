import React from 'react';
import { ChevronDown } from 'lucide-react';

const AccordionTrigger = ({ children, onClick, className, isOpen, ...props }) => {
  return (
    <div 
      className={`accordion-trigger flex items-center justify-between py-4 font-medium transition-all hover:underline cursor-pointer ${className || ''}`}
      onClick={onClick}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          onClick?.(e);
        }
      }}
      {...props}
    >
      {children}
      <ChevronDown className={`h-4 w-4 shrink-0 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`} />
    </div>
  );
};

export default AccordionTrigger;
