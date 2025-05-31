import React, { useContext } from 'react';
import { TabsContext } from './tabs.jsx';

const TabsContent = ({ 
  className = '', 
  children,
  value,
  ...props 
}) => {
  const { activeTab } = useContext(TabsContext) || {};

  if (activeTab !== value) {
    return null;
  }

  return (
    <div 
      className={`mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ${className}`}
      role="tabpanel"
      tabIndex={0}
      {...props}
    >
      {children}
    </div>
  );
};

export default TabsContent; 