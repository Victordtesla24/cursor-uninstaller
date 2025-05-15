import React from 'react';
import { useAccordion } from './accordion';
import { useAccordionItem } from './accordion-item';

/**
 * AccordionTrigger Component
 *
 * The clickable trigger element that expands/collapses an accordion item.
 */
const AccordionTrigger = ({ children, className = '', ...props }) => {
  const { onValueChange } = useAccordion();
  const { value, isOpen } = useAccordionItem();

  const handleClick = () => {
    onValueChange(value);
  };

  return (
    <button 
      type="button"
      className={`${className}`}
      onClick={handleClick}
      aria-expanded={isOpen}
      data-state={isOpen ? 'open' : 'closed'}
      {...props}
    >
      {children}
    </button>
  );
};

export default AccordionTrigger;