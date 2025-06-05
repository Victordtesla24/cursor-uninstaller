/**
 * UI Component Mocks for Tests
 */

// Card components
export const Card = ({ children, className, ...props }) => ({
  type: 'div',
  props: { className: `card ${className || ''}`, ...props },
  children: Array.isArray(children) ? children : [children]
});

export const CardHeader = ({ children, className, ...props }) => ({
  type: 'div',
  props: { className: `card-header ${className || ''}`, ...props },
  children: Array.isArray(children) ? children : [children]
});

export const CardContent = ({ children, className, ...props }) => ({
  type: 'div',
  props: { className: `card-content ${className || ''}`, ...props },
  children: Array.isArray(children) ? children : [children]
});

export const CardFooter = ({ children, className, ...props }) => ({
  type: 'div',
  props: { className: `card-footer ${className || ''}`, ...props },
  children: Array.isArray(children) ? children : [children]
});

export const CardTitle = ({ children, className, ...props }) => ({
  type: 'h3',
  props: { className: `card-title ${className || ''}`, ...props },
  children: Array.isArray(children) ? children : [children]
});

export const CardDescription = ({ children, className, ...props }) => ({
  type: 'p',
  props: { className: `card-description ${className || ''}`, ...props },
  children: Array.isArray(children) ? children : [children]
});

// Collapsible components
export const Collapsible = ({ children, open, ...props }) => ({
  type: 'div',
  props: { 'data-testid': 'mock-collapsible', 'data-open': open ? 'true' : 'false', ...props },
  children: Array.isArray(children) ? children : [children]
});

export const CollapsibleTrigger = ({ children, ...props }) => ({
  type: 'button',
  props: { 'data-testid': 'mock-collapsible-trigger', ...props },
  children: Array.isArray(children) ? children : [children]
});

export const CollapsibleContent = ({ children, ...props }) => ({
  type: 'div',
  props: { 'data-testid': 'mock-collapsible-content', ...props },
  children: Array.isArray(children) ? children : [children]
});

// Accordion components
export const Accordion = ({ children, ...props }) => ({
  type: 'div',
  props: { 'data-testid': 'mock-accordion', ...props },
  children: Array.isArray(children) ? children : [children]
});

export const AccordionItem = ({ children, value, ...props }) => ({
  type: 'div',
  props: { 'data-testid': 'mock-accordion-item', 'data-value': value, ...props },
  children: Array.isArray(children) ? children : [children]
});

export const AccordionTrigger = ({ children, ...props }) => ({
  type: 'button',
  props: { 'data-testid': 'mock-accordion-trigger', ...props },
  children: Array.isArray(children) ? children : [children]
});

export const AccordionContent = ({ children, ...props }) => ({
  type: 'div',
  props: { 'data-testid': 'mock-accordion-content', ...props },
  children: Array.isArray(children) ? children : [children]
});

// Form components
export const Button = ({ children, variant = 'default', size = 'default', className, onClick, disabled, ...props }) => ({
  type: 'button',
  props: {
    className: `button ${variant} ${size} ${className || ''}`,
    onClick,
    disabled,
    ...props
  },
  children: Array.isArray(children) ? children : [children]
});

export const Input = ({ value, onChange, className, ...props }) => ({
  type: 'input',
  props: {
    'data-testid': 'mock-input',
    value,
    onChange,
    className,
    ...props
  }
});

export const Label = ({ children, htmlFor, ...props }) => ({
  type: 'label',
  props: { 'data-testid': 'mock-label', htmlFor, ...props },
  children: Array.isArray(children) ? children : [children]
});

export const Select = ({ children, value, onValueChange, ...props }) => ({
  type: 'select',
  props: {
    'data-testid': 'mock-select',
    value,
    onChange: (e) => onValueChange?.(e.target.value),
    ...props
  },
  children: Array.isArray(children) ? children : [children]
});

export const Switch = ({ checked, onCheckedChange, disabled, className, ...props }) => ({
  type: 'button',
  props: {
    type: 'button',
    role: 'switch',
    'aria-checked': checked,
    className: `switch ${checked ? 'checked' : ''} ${className || ''}`,
    onClick: () => onCheckedChange?.(!checked),
    disabled,
    ...props
  },
  children: [{ type: 'span', props: { className: 'switch-thumb' } }]
});

// Tooltip components
export const TooltipProvider = ({ children, ...props }) => ({
  type: 'div',
  props: { className: 'tooltip-provider', ...props },
  children: Array.isArray(children) ? children : [children]
});

export const Tooltip = ({ children, ...props }) => ({
  type: 'div',
  props: { className: 'tooltip', ...props },
  children: Array.isArray(children) ? children : [children]
});

export const TooltipTrigger = ({ children, ...props }) => ({
  type: 'div',
  props: { className: 'tooltip-trigger', ...props },
  children: Array.isArray(children) ? children : [children]
});

export const TooltipContent = ({ children, className, ...props }) => ({
  type: 'div',
  props: { className: `tooltip-content ${className || ''}`, ...props },
  children: Array.isArray(children) ? children : [children]
});

// Miscellaneous components
export const Badge = ({ children, variant = 'default', className, ...props }) => ({
  type: 'span',
  props: { className: `badge ${variant} ${className || ''}`, ...props },
  children: Array.isArray(children) ? children : [children]
});

export const Separator = ({ orientation = 'horizontal', className, ...props }) => ({
  type: 'div',
  props: { className: `separator ${orientation} ${className || ''}`, ...props }
});

export const Progress = ({ value = 0, className, ...props }) => ({
  type: 'div',
  props: { className: `progress ${className || ''}`, ...props },
  children: [{
    type: 'div',
    props: { 
      className: 'progress-bar',
      style: { width: `${value}%` }
    }
  }]
});

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
