import React, { useState } from 'react';

const Popover = ({ 
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
    <div className="relative inline-block" {...props}>
      {React.Children.map(children, child => 
        React.cloneElement(child, { 
          isOpen, 
          onOpenChange: handleOpenChange 
        })
      )}
    </div>
  );
};

export default Popover; 