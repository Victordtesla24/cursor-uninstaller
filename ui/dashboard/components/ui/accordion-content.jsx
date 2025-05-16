import React from 'react';
import { useAccordionItem } from './accordion-item';

/**
 * AccordionContent Component
 *
 * Content to be revealed when an accordion item is expanded.
 */
const AccordionContent = ({ children, className = '', ...props }) => {
  const { isOpen } = useAccordionItem();

  if (!isOpen) {
    return null;
  }

  return (
    <div
      className={`${className}`}
      data-state={isOpen ? 'open' : 'closed'}
      {...props}
    >
      {children}
    </div>
  );
};

export default AccordionContent;
