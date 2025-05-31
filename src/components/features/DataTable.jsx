import React from 'react';
import Table from '../ui/table.jsx';

const DataTable = ({ 
  data = [],
  columns = [],
  className = '',
  ...props 
}) => {
  return (
    <div className={`data-table ${className}`} {...props}>
      <Table>
        <thead>
          <tr>
            {columns.map((column, index) => (
              <th key={index} className="text-left p-2">
                {column.header || column.key}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, rowIndex) => (
            <tr key={rowIndex}>
              {columns.map((column, colIndex) => (
                <td key={colIndex} className="p-2">
                  {row[column.key] || ''}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </Table>
    </div>
  );
};

export default DataTable; 