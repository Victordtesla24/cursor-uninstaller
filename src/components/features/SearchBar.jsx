import React from 'react';
import { Search } from 'lucide-react';

const SearchBar = ({ 
  value = '',
  onChange,
  placeholder = 'Search...',
  className = '',
  ...props 
}) => {
  return (
    <div className={`relative ${className}`} {...props}>
      <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
      <input
        type="text"
        value={value}
        onChange={(e) => onChange?.(e.target.value)}
        placeholder={placeholder}
        className="w-full pl-10 pr-4 py-2 border border-input rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
      />
    </div>
  );
};

export default SearchBar; 