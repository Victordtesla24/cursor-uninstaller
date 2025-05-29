import React from 'react';

/**
 * UI Component Mocks for Tests
 */

// Card components
export const Card = ({ children, className, ...props }) => (
  <div className={`card ${className || ''}`} {...props}>
    {children}
  </div>
);

export const CardHeader = ({ children, className, ...props }) => (
  <div className={`card-header ${className || ''}`} {...props}>
    {children}
  </div>
);

export const CardContent = ({ children, className, ...props }) => (
  <div className={`card-content ${className || ''}`} {...props}>
    {children}
  </div>
);

export const CardFooter = ({ children, className, ...props }) => (
  <div className={`card-footer ${className || ''}`} {...props}>
    {children}
  </div>
);

export const CardTitle = ({ children, className, ...props }) => (
  <h3 className={`card-title ${className || ''}`} {...props}>
    {children}
  </h3>
);

export const CardDescription = ({ children, className, ...props }) => (
  <p className={`card-description ${className || ''}`} {...props}>
    {children}
  </p>
);

// Collapsible components
export const Collapsible = ({ children, open, ...props }) => (
  <div data-testid="mock-collapsible" data-open={open ? 'true' : 'false'} {...props}>
    {children}
  </div>
);

export const CollapsibleTrigger = ({ children, ...props }) => (
  <button data-testid="mock-collapsible-trigger" {...props}>
    {children}
  </button>
);

export const CollapsibleContent = ({ children, ...props }) => (
  <div data-testid="mock-collapsible-content" {...props}>
    {children}
  </div>
);

// Accordion components
export const Accordion = ({ children, ...props }) => (
  <div data-testid="mock-accordion" {...props}>
    {children}
  </div>
);

export const AccordionItem = ({ children, value, ...props }) => (
  <div data-testid="mock-accordion-item" data-value={value} {...props}>
    {children}
  </div>
);

export const AccordionTrigger = ({ children, ...props }) => (
  <button data-testid="mock-accordion-trigger" {...props}>
    {children}
  </button>
);

export const AccordionContent = ({ children, ...props }) => (
  <div data-testid="mock-accordion-content" {...props}>
    {children}
  </div>
);

// Form components
export const Button = ({ children, variant = 'default', size = 'default', className, onClick, disabled, ...props }) => (
  <button 
    className={`button ${variant} ${size} ${className || ''}`}
    onClick={onClick}
    disabled={disabled}
    {...props}
  >
    {children}
  </button>
);

export const Input = ({ value, onChange, className, ...props }) => (
  <input 
    data-testid="mock-input" 
    value={value} 
    onChange={onChange} 
    className={className} 
    {...props} 
  />
);

export const Label = ({ children, htmlFor, ...props }) => (
  <label data-testid="mock-label" htmlFor={htmlFor} {...props}>
    {children}
  </label>
);

export const Select = ({ children, value, onValueChange, ...props }) => (
  <select 
    data-testid="mock-select" 
    value={value} 
    onChange={(e) => onValueChange?.(e.target.value)} 
    {...props}
  >
    {children}
  </select>
);

export const Switch = ({ checked, onCheckedChange, disabled, className, ...props }) => (
  <button
    type="button"
    role="switch"
    aria-checked={checked}
    className={`switch ${checked ? 'checked' : ''} ${className || ''}`}
    onClick={() => onCheckedChange?.(!checked)}
    disabled={disabled}
    {...props}
  >
    <span className="switch-thumb" />
  </button>
);

// Tooltip components
export const TooltipProvider = ({ children, ...props }) => (
  <div className="tooltip-provider" {...props}>
    {children}
  </div>
);

export const Tooltip = ({ children, ...props }) => (
  <div className="tooltip" {...props}>
    {children}
  </div>
);

export const TooltipTrigger = ({ children, ...props }) => (
  <div className="tooltip-trigger" {...props}>
    {children}
  </div>
);

export const TooltipContent = ({ children, className, ...props }) => (
  <div className={`tooltip-content ${className || ''}`} {...props}>
    {children}
  </div>
);

// Miscellaneous components
export const Badge = ({ children, variant = 'default', className, ...props }) => (
  <span className={`badge ${variant} ${className || ''}`} {...props}>
    {children}
  </span>
);

export const Separator = ({ orientation = 'horizontal', className, ...props }) => (
  <div 
    className={`separator ${orientation} ${className || ''}`} 
    {...props}
  />
);

export const Progress = ({ value = 0, className, ...props }) => (
  <div className={`progress ${className || ''}`} {...props}>
    <div 
      className="progress-bar" 
      style={{ width: `${value}%` }}
    />
  </div>
);

export default {
  Card,
  CardHeader, 
  CardContent,
  CardFooter,
  CardTitle,
  CardDescription,
  Button,
  Input,
  Select,
  Switch,
  Label,
  Collapsible,
  CollapsibleTrigger,
  CollapsibleContent,
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionContent
};
