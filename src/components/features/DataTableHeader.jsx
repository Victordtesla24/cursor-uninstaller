import React from 'react';

const DataTableHeader = ({ 
  children,
  className = '',
  sortable = false,
  onSort,
  ...props 
}) => {
  return (
    <th 
      className={`text-left p-2 font-medium ${sortable ? 'cursor-pointer hover:bg-muted' : ''} ${className}`}
      onClick={sortable ? onSort : undefined}
      {...props}
    >
      {children}
    </th>
  );
};

export default DataTableHeader; 