import React, { createContext, useContext, useState } from 'react';

const TabsContext = createContext();

const Tabs = ({ 
  children,
  defaultValue,
  value,
  onValueChange,
  className = '',
  ...props 
}) => {
  const [activeTab, setActiveTab] = useState(value || defaultValue);
  
  const handleValueChange = (newValue) => {
    setActiveTab(newValue);
    onValueChange?.(newValue);
  };

  return (
    <TabsContext.Provider value={{ activeTab, onValueChange: handleValueChange }}>
      <div className={className} {...props}>
        {children}
      </div>
    </TabsContext.Provider>
  );
};

export default Tabs;
export { TabsContext }; 