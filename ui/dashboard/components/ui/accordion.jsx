import React, { createContext, useContext, useState } from 'react';

// Create a context to share state between accordion components
const AccordionContext = createContext(null);

/**
 * Accordion Component
 *
 * A vertically stacked set of interactive headings that reveal/hide associated content.
 */
const Accordion = ({
  children,
  type = 'single',
  collapsible = false,
  defaultValue,
  value,
  onValueChange,
  className = '',
  ...props
}) => {
  // Use either controlled (value prop) or uncontrolled (internal state) mode
  const [valueState, setValueState] = useState(defaultValue);
  const activeValue = value !== undefined ? value : valueState;

  const handleValueChange = (itemValue) => {
    let newValue;

    if (type === 'single') {
      // In single mode, clicking the open item closes it if collapsible is true
      if (itemValue === activeValue && collapsible) {
        newValue = null;
      } else {
        newValue = itemValue;
      }
    } else if (type === 'multiple') {
      // For multiple, we need to toggle the clicked value in the array
      if (!activeValue) {
        newValue = [itemValue];
      } else if (Array.isArray(activeValue)) {
        if (activeValue.includes(itemValue)) {
          newValue = activeValue.filter(v => v !== itemValue);
        } else {
          newValue = [...activeValue, itemValue];
        }
      }
    }

    // Update internal state if uncontrolled
    if (value === undefined) {
      setValueState(newValue);
    }

    // Call callback if provided
    if (onValueChange) {
      onValueChange(newValue);
    }
  };

  return (
    <AccordionContext.Provider value={{ value: activeValue, type, onValueChange: handleValueChange }}>
      <div
        className={`${className}`}
        {...props}
      >
        {children}
      </div>
    </AccordionContext.Provider>
  );
};

export default Accordion;

// Make the context available for use in other components
export const useAccordion = () => {
  const context = useContext(AccordionContext);
  if (!context) {
    throw new Error('useAccordion must be used within an Accordion component');
  }
  return context;
};
