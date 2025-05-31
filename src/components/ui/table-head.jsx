import React from 'react';

const TableHead = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <th 
      className={`h-12 px-4 text-left align-middle font-medium text-muted-foreground [&:has([role=checkbox])]:pr-0 ${className}`}
      {...props}
    >
      {children}
    </th>
  );
};

export default TableHead; 