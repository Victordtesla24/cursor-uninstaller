import React, { useState, createContext, useContext } from 'react';

// Create a context to share state between collapsible components
const CollapsibleContext = createContext(null);

/**
 * Collapsible Component
 *
 * A component that can be expanded or collapsed.
 */
const Collapsible = ({
  children,
  open = false,
  defaultOpen = false,
  onOpenChange,
  className = '',
  ...props
}) => {
  // Use either controlled (open prop) or uncontrolled (internal state) mode
  const [isOpenState, setIsOpenState] = useState(defaultOpen);
  const isOpen = open !== undefined ? open : isOpenState;

  const toggle = () => {
    const newState = !isOpen;
    if (open === undefined) {
      setIsOpenState(newState);
    }
    if (onOpenChange) {
      onOpenChange(newState);
    }
  };

  return (
    <CollapsibleContext.Provider value={{ isOpen, toggle }}>
      <div
        className={`${className}`}
        data-state={isOpen ? 'open' : 'closed'}
        {...props}
      >
        {children}
      </div>
    </CollapsibleContext.Provider>
  );
};

export default Collapsible;

// Make the context available for use in other components
export const useCollapsible = () => {
  const context = useContext(CollapsibleContext);
  if (!context) {
    throw new Error('useCollapsible must be used within a Collapsible component');
  }
  return context;
};
