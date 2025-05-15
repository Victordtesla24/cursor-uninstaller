import React from 'react';
import { useCollapsible } from './collapsible';

/**
 * CollapsibleTrigger Component
 *
 * A trigger button that controls a collapsible component.
 */
const CollapsibleTrigger = ({ children, className = '', asChild, ...props }) => {
  const { toggle } = useCollapsible();

  return (
    <button 
      type="button"
      className={`${className}`}
      onClick={toggle}
      aria-expanded={true}
      {...props}
    >
      {children}
    </button>
  );
};

export default CollapsibleTrigger; 