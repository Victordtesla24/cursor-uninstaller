import React from 'react';

const TableBody = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <tbody 
      className={`[&_tr:last-child]:border-0 ${className}`}
      {...props}
    >
      {children}
    </tbody>
  );
};

export default TableBody; 