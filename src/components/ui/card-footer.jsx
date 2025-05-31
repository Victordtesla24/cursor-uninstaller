import React from 'react';

const CardFooter = ({ className, children, ...props }) => {
  return (
    <div
      className={`card-footer flex items-center p-6 pt-0 ${className || ''}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default CardFooter;
