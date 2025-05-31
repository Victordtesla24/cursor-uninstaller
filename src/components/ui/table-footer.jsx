import React from 'react';

const TableFooter = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <tfoot 
      className={`border-t bg-muted/50 font-medium [&>tr]:last:border-b-0 ${className}`}
      {...props}
    >
      {children}
    </tfoot>
  );
};

export default TableFooter; 