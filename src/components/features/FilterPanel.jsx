import React from 'react';

const FilterPanel = ({ 
  filters = [],
  onFilterChange,
  className = '',
  ...props 
}) => {
  return (
    <div 
      className={`filter-panel p-4 border rounded-md ${className}`}
      {...props}
    >
      <h3 className="text-lg font-medium mb-4">Filters</h3>
      {filters.map((filter, index) => (
        <div key={index} className="mb-3">
          <label className="block text-sm font-medium mb-1">
            {filter.label}
          </label>
          <input
            type={filter.type || 'text'}
            value={filter.value || ''}
            onChange={(e) => onFilterChange?.(filter.key, e.target.value)}
            className="w-full p-2 border rounded"
            placeholder={filter.placeholder}
          />
        </div>
      ))}
    </div>
  );
};

export default FilterPanel; 