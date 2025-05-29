import React, { createContext, useContext } from 'react';
import { useAccordion } from './accordion';

// Create a context to share the item value with trigger and content
const AccordionItemContext = createContext(null);

/**
 * AccordionItem Component
 *
 * An individual item within an accordion.
 */
const AccordionItem = ({ children, value, className = '', ...props }) => {
  const { value: activeValue, type } = useAccordion();

  // Determine if this item is open
  const isOpen = type === 'single'
    ? activeValue === value
    : Array.isArray(activeValue) && activeValue.includes(value);

  return (
    <AccordionItemContext.Provider value={{ value, isOpen }}>
      <div
        className={`${className}`}
        data-state={isOpen ? 'open' : 'closed'}
        {...props}
      >
        {children}
      </div>
    </AccordionItemContext.Provider>
  );
};

export default AccordionItem;

// Make the context available for use in other components
export const useAccordionItem = () => {
  const context = useContext(AccordionItemContext);
  if (!context) {
    throw new Error('useAccordionItem must be used within an AccordionItem component');
  }
  return context;
};
