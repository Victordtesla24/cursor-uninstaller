import React from 'react';
import { useCollapsible } from './collapsible';

/**
 * CollapsibleContent Component
 *
 * Content that is shown or hidden based on the collapsible state.
 */
const CollapsibleContent = ({ children, className = '', ...props }) => {
  const { isOpen } = useCollapsible();

  if (!isOpen) {
    return null;
  }

  return (
    <div
      className={`${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default CollapsibleContent;
