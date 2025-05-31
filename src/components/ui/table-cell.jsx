import React from 'react';

const TableCell = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <td 
      className={`p-4 align-middle [&:has([role=checkbox])]:pr-0 ${className}`}
      {...props}
    >
      {children}
    </td>
  );
};

export default TableCell; 