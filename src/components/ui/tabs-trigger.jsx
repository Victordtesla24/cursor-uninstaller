import React, { useContext } from 'react';
import { TabsContext } from './tabs.jsx';

const TabsTrigger = ({ 
  className = '', 
  children,
  value,
  disabled = false,
  ...props 
}) => {
  const { activeTab, onValueChange } = useContext(TabsContext) || {};

  const isActive = activeTab === value;

  const handleClick = () => {
    if (!disabled && value) {
      onValueChange?.(value);
    }
  };

  return (
    <button 
      className={`inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 ${
        isActive 
          ? 'bg-background text-foreground shadow-sm' 
          : 'hover:bg-muted hover:text-foreground'
      } ${className}`}
      role="tab"
      aria-selected={isActive}
      disabled={disabled}
      onClick={handleClick}
      {...props}
    >
      {children}
    </button>
  );
};

export default TabsTrigger; 