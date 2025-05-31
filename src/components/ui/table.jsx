import React from 'react';

const Table = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <div className="relative w-full overflow-auto">
      <table 
        className={`w-full caption-bottom text-sm ${className}`}
        {...props}
      >
        {children}
      </table>
    </div>
  );
};

export default Table; 