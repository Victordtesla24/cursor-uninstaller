import React from 'react';

const DataTableRow = ({ 
  children,
  className = '',
  selected = false,
  onClick,
  ...props 
}) => {
  return (
    <tr 
      className={`border-b transition-colors hover:bg-muted/50 ${selected ? 'bg-muted' : ''} ${onClick ? 'cursor-pointer' : ''} ${className}`}
      onClick={onClick}
      {...props}
    >
      {children}
    </tr>
  );
};

export default DataTableRow; 