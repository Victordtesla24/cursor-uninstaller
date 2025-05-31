import React from 'react';

const TableRow = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <tr 
      className={`border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted ${className}`}
      {...props}
    >
      {children}
    </tr>
  );
};

export default TableRow; 