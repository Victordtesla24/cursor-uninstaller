import React from 'react';

const AvatarImage = ({ 
  src,
  alt = '',
  className = '', 
  ...props 
}) => {
  return (
    <img 
      src={src}
      alt={alt}
      className={`aspect-square h-full w-full ${className}`}
      {...props}
    />
  );
};

export default AvatarImage; 