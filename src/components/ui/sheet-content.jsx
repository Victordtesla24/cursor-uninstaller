import React, { useContext } from 'react';
import { SheetContext } from './sheet.jsx';

const SheetContent = ({ 
  className = '', 
  children,
  side = 'right',
  ...props 
}) => {
  const { isOpen, onOpenChange } = useContext(SheetContext) || {};

  if (!isOpen) return null;

  const sideClasses = {
    top: 'top-0 left-0 right-0 h-auto border-b',
    bottom: 'bottom-0 left-0 right-0 h-auto border-t',
    left: 'top-0 left-0 h-full w-80 border-r',
    right: 'top-0 right-0 h-full w-80 border-l'
  };

  return (
    <>
      {/* Backdrop */}
      <div 
        className="fixed inset-0 z-50 bg-background/80 backdrop-blur-sm"
        onClick={() => onOpenChange?.(false)}
      />
      
      {/* Sheet Content */}
      <div 
        className={`fixed z-50 gap-4 bg-background p-6 shadow-lg transition ease-in-out ${sideClasses[side]} ${className}`}
        {...props}
      >
        {children}
      </div>
    </>
  );
};

export default SheetContent; 