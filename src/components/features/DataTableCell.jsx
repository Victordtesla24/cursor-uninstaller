import React from 'react';

const DataTableCell = ({ 
  children,
  className = '',
  ...props 
}) => {
  return (
    <td 
      className={`p-2 align-middle ${className}`}
      {...props}
    >
      {children}
    </td>
  );
};

export default DataTableCell; 