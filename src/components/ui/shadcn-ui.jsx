import React from 'react';

// Card Components
export const Card = ({ className, ...props }) => (
  <div className={`bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 shadow-sm overflow-hidden ${className || ''}`} {...props} />
);

export const CardHeader = ({ className, ...props }) => (
  <div className={`p-6 ${className || ''}`} {...props} />
);

export const CardTitle = ({ className, ...props }) => (
  <h3 className={`text-xl font-semibold text-slate-900 dark:text-white ${className || ''}`} {...props} />
);

export const CardDescription = ({ className, ...props }) => (
  <p className={`text-sm text-slate-500 dark:text-slate-400 ${className || ''}`} {...props} />
);

export const CardContent = ({ className, ...props }) => (
  <div className={`p-6 pt-0 ${className || ''}`} {...props} />
);

// Button Component
export const Button = ({ variant = 'default', size = 'default', className, ...props }) => {
  const variants = {
    default: 'bg-slate-900 text-white hover:bg-slate-700 dark:bg-slate-700 dark:hover:bg-slate-600',
    destructive: 'bg-red-500 text-white hover:bg-red-600 dark:bg-red-700 dark:hover:bg-red-600',
    outline: 'border border-slate-200 hover:bg-slate-100 hover:text-slate-900 dark:border-slate-700 dark:hover:bg-slate-800 dark:text-slate-300 dark:hover:text-slate-100',
    secondary: 'bg-slate-100 text-slate-900 hover:bg-slate-200 dark:bg-slate-800 dark:text-slate-100 dark:hover:bg-slate-700',
    ghost: 'hover:bg-slate-100 hover:text-slate-900 dark:hover:bg-slate-800 dark:hover:text-slate-100',
    link: 'text-slate-900 underline-offset-4 hover:underline dark:text-slate-100'
  };

  const sizes = {
    default: 'h-10 px-4 py-2',
    sm: 'h-9 rounded-md px-3',
    lg: 'h-11 rounded-md px-8',
    icon: 'h-10 w-10'
  };

  return (
    <button 
      className={`inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-400 focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none ${variants[variant]} ${sizes[size]} ${className || ''}`} 
      {...props} 
    />
  );
};

// Badge Component
export const Badge = ({ variant = 'default', className, ...props }) => {
  const variants = {
    default: 'bg-slate-900 text-white dark:bg-slate-700',
    secondary: 'bg-slate-100 text-slate-900 dark:bg-slate-800 dark:text-slate-100',
    destructive: 'bg-red-500 text-white dark:bg-red-700',
    outline: 'text-slate-900 border border-slate-200 dark:text-slate-100 dark:border-slate-700'
  };

  return (
    <div className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${variants[variant]} ${className || ''}`} {...props} />
  );
};

// Separator Component
export const Separator = ({ orientation = 'horizontal', className, ...props }) => {
  return orientation === 'horizontal' ? (
    <div className={`h-[1px] w-full bg-slate-200 dark:bg-slate-700 ${className || ''}`} {...props} />
  ) : (
    <div className={`h-full w-[1px] bg-slate-200 dark:bg-slate-700 ${className || ''}`} {...props} />
  );
};

// Progress Component
export const Progress = ({ value, max = 100, className, ...props }) => {
  return (
    <div className={`relative w-full h-4 overflow-hidden rounded-full bg-slate-200 dark:bg-slate-700 ${className || ''}`} {...props}>
      <div 
        className="h-full bg-slate-900 dark:bg-slate-400 transition-all" 
        style={{ width: `${(value / max) * 100}%` }} 
      />
    </div>
  );
};

// Switch Component
export const Switch = ({ checked, onChange, className, ...props }) => {
  return (
    <button
      role="switch"
      aria-checked={checked}
      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-400 focus-visible:ring-offset-2 ${
        checked ? 'bg-slate-900 dark:bg-slate-400' : 'bg-slate-200 dark:bg-slate-700'
      } ${className || ''}`}
      onClick={() => onChange(!checked)}
      {...props}
    >
      <span
        className={`${
          checked ? 'translate-x-5' : 'translate-x-1'
        } inline-block h-4 w-4 transform rounded-full bg-white transition-transform`}
      />
    </button>
  );
};

// Tooltip Components
export const TooltipProvider = ({ children }) => {
  return <>{children}</>;
};

export const Tooltip = ({ children }) => {
  return <>{children}</>;
};

export const TooltipTrigger = ({ className, _asChild, ...props }) => {
  // Handle the asChild prop by ignoring it but not passing it to the DOM element
  // This fixes the React warning about unrecognized prop
  return <div className={className} {...props} />;
};

export const TooltipContent = ({ className, ...props }) => {
  return (
    <div 
      className={`z-50 overflow-hidden rounded-md border border-slate-200 bg-white px-3 py-1.5 text-sm text-slate-950 shadow-md animate-in fade-in-50 data-[side=bottom]:slide-in-from-top-1 data-[side=left]:slide-in-from-right-1 data-[side=right]:slide-in-from-left-1 data-[side=top]:slide-in-from-bottom-1 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-50 ${className || ''}`} 
      {...props} 
    />
  );
};

// Input Component
export const Input = ({ className, ...props }) => {
  return (
    <input
      className={`flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm ring-offset-white file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-slate-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-400 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 dark:border-slate-800 dark:bg-slate-950 dark:ring-offset-slate-950 dark:placeholder:text-slate-400 dark:focus-visible:ring-slate-800 ${className || ''}`}
      {...props}
    />
  );
};

// Label Component
export const Label = ({ className, ...props }) => {
  return (
    <label
      className={`text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 ${className || ''}`}
      {...props}
    />
  );
};

// Export all components
export default {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  Button,
  Badge,
  Separator,
  Progress,
  Switch,
  TooltipProvider,
  Tooltip,
  TooltipTrigger,
  TooltipContent,
  Input,
  Label
};
