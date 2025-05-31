import React from 'react';

const DialogTrigger = ({ 
  className = '', 
  children,
  isOpen = false,
  onOpenChange,
  asChild = false,
  ...props 
}) => {
  const handleClick = () => {
    onOpenChange?.(!isOpen);
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

export default DialogTrigger;