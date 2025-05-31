import React from 'react';
import { Download } from 'lucide-react';
import Button from '../ui/button.jsx';

const ExportButton = ({ 
  onExport,
  format = 'csv',
  className = '',
  children = 'Export',
  ...props 
}) => {
  const handleExport = () => {
    onExport?.(format);
  };

  return (
    <Button
      onClick={handleExport}
      variant="outline"
      className={`export-button ${className}`}
      {...props}
    >
      <Download className="h-4 w-4 mr-2" />
      {children}
    </Button>
  );
};

export default ExportButton; 