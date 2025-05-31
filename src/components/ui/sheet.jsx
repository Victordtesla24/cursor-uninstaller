import React, { createContext, useContext, useState } from 'react';

const SheetContext = createContext();

const Sheet = ({ 
  children,
  open,
  onOpenChange,
  ...props 
}) => {
  const [isOpen, setIsOpen] = useState(open || false);
  
  const handleOpenChange = (newOpen) => {
    setIsOpen(newOpen);
    onOpenChange?.(newOpen);
  };

  return (
    <SheetContext.Provider value={{ isOpen, onOpenChange: handleOpenChange }}>
      <div {...props}>
        {children}
      </div>
    </SheetContext.Provider>
  );
};

export default Sheet;
export { SheetContext }; 