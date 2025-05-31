import React from 'react';

const AvatarFallback = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <div 
      className={`flex h-full w-full items-center justify-center rounded-full bg-muted ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default AvatarFallback; 