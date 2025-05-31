import React from 'react';
import { Calendar } from 'lucide-react';

const DateRangePicker = ({ 
  startDate,
  endDate,
  onStartDateChange,
  onEndDateChange,
  className = '',
  ...props 
}) => {
  return (
    <div className={`date-range-picker flex items-center space-x-2 ${className}`} {...props}>
      <div className="relative">
        <Calendar className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
        <input
          type="date"
          value={startDate || ''}
          onChange={(e) => onStartDateChange?.(e.target.value)}
          className="pl-10 pr-4 py-2 border border-input rounded-md bg-background text-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
        />
      </div>
      <span className="text-muted-foreground">to</span>
      <div className="relative">
        <Calendar className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
        <input
          type="date"
          value={endDate || ''}
          onChange={(e) => onEndDateChange?.(e.target.value)}
          className="pl-10 pr-4 py-2 border border-input rounded-md bg-background text-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
        />
      </div>
    </div>
  );
};

export default DateRangePicker; 