import React, { useContext } from 'react';
import { SheetContext } from './sheet.jsx';

const SheetTrigger = ({ 
  className = '', 
  children,
  asChild = false,
  ...props 
}) => {
  const { onOpenChange } = useContext(SheetContext) || {};

  const handleClick = () => {
    onOpenChange?.(true);
  };

  if (asChild && React.isValidElement(children)) {
    return React.cloneElement(children, {
      onClick: handleClick,
      ...props
    });
  }

  return (
    <button 
      className={className}
      onClick={handleClick}
      {...props}
    >
      {children}
    </button>
  );
};

export default SheetTrigger; 