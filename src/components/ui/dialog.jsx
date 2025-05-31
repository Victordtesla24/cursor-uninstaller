import React, { useState } from 'react';

const Dialog = ({ 
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
    <div {...props}>
      {React.Children.map(children, child => 
        React.cloneElement(child, { 
          isOpen, 
          onOpenChange: handleOpenChange 
        })
      )}
    </div>
  );
};

export default Dialog;