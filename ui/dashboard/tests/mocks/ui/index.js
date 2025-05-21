import React from 'react';

/**
 * UI Component Mocks for Tests
 */

// Card components
export const Card = ({ className = '', children, ...props }) => (
  <div className={`mock-card ${className}`} data-testid="mock-card" {...props}>{children}</div>
);

export const CardContent = ({ className = '', children, ...props }) => (
  <div className={`mock-card-content ${className}`} data-testid="mock-card-content" {...props}>{children}</div>
);

export const CardDescription = ({ className = '', children, ...props }) => (
  <p className={`mock-card-description ${className}`} data-testid="mock-card-description" {...props}>{children}</p>
);

export const CardFooter = ({ className = '', children, ...props }) => (
  <div className={`mock-card-footer ${className}`} data-testid="mock-card-footer" {...props}>{children}</div>
);

export const CardHeader = ({ className = '', children, ...props }) => (
  <div className={`mock-card-header ${className}`} data-testid="mock-card-header" {...props}>{children}</div>
);

export const CardTitle = ({ className = '', children, ...props }) => (
  <h3 className={`mock-card-title ${className}`} data-testid="mock-card-title" {...props}>{children}</h3>
);

// Collapsible components
export const Collapsible = ({ className = '', children, open = false, ...props }) => (
  <div
    data-testid="mock-collapsible"
    data-open={open ? 'true' : 'false'}
    className={`mock-collapsible ${className}`.trim()}
    {...props}
  >
    {children}
  </div>
);

export const CollapsibleContent = ({ className = '', children, ...props }) => (
  <div className={`mock-collapsible-content ${className}`} data-testid="mock-collapsible-content" {...props}>{children}</div>
);

export const CollapsibleTrigger = ({ className = '', children, ...props }) => (
  <button className={`mock-collapsible-trigger ${className}`} data-testid="mock-collapsible-trigger" {...props}>{children}</button>
);

// Accordion components
export const Accordion = ({ className = '', children, collapsible, ...props }) => {
  // Convert boolean prop to string to avoid React warning
  const accordionProps = { ...props };
  if (collapsible !== undefined) {
    accordionProps['data-collapsible'] = collapsible.toString();
  }

  return (
    <div className={`mock-accordion ${className}`} data-testid="mock-accordion" {...accordionProps}>
      {children}
    </div>
  );
};

export const AccordionContent = ({ className = '', children, ...props }) => (
  <div className={`mock-accordion-content ${className}`} data-testid="mock-accordion-content" {...props}>{children}</div>
);

export const AccordionItem = ({ className = '', children, ...props }) => (
  <div className={`mock-accordion-item ${className}`} data-testid="mock-accordion-item" {...props}>{children}</div>
);

export const AccordionTrigger = ({ className = '', children, ...props }) => (
  <button className={`mock-accordion-trigger ${className}`} data-testid="mock-accordion-trigger" {...props}>{children}</button>
);

// Form components
export const Button = ({ className = '', children, ...props }) => (
  <button className={`mock-button ${className}`} data-testid="mock-button" {...props}>{children}</button>
);

export const Input = ({ className = '', ...props }) => (
  <input className={`mock-input ${className}`} data-testid="mock-input" {...props} />
);

export const Label = ({ className = '', children, ...props }) => (
  <label className={`mock-label ${className}`} data-testid="mock-label" {...props}>{children}</label>
);

export const Switch = ({ className = '', checked, onCheckedChange, ...props }) => {
  // Handle the onCheckedChange prop properly
  const handleChange = (e) => {
    if (onCheckedChange && typeof onCheckedChange === 'function') {
      onCheckedChange(e.target.checked);
    }
  };

  return (
    <input
      type="checkbox"
      role="switch" // Explicitly add the role
      className={`mock-switch ${className}`}
      data-testid="mock-switch"
      defaultChecked={checked}
      onChange={handleChange}
      {...props}
    />
  );
};

// Tooltip components
export const Tooltip = ({ children }) => children;

export const TooltipContent = ({ className = '', children, ...props }) => (
  <div className={`mock-tooltip-content ${className}`} data-testid="mock-tooltip-content" {...props}>{children}</div>
);

export const TooltipProvider = ({ children }) => children;

export const TooltipTrigger = ({ className = '', children, asChild, ...props }) => {
  // Filter out asChild prop to avoid React DOM attribute warning
  const triggerProps = { ...props };
  if (asChild !== undefined) {
    triggerProps['data-aschild'] = asChild.toString();
  }

  return (
    <div
      className={`mock-tooltip-trigger ${className}`}
      data-testid="mock-tooltip-trigger"
      {...triggerProps}
    >
      {children}
    </div>
  );
};

// Miscellaneous components
export const Badge = ({ className = '', children, ...props }) => (
  <div className={`mock-badge ${className}`} data-testid="mock-badge" {...props}>{children}</div>
);

export const Separator = ({ className = '', ...props }) => (
  <hr className={`mock-separator ${className}`} data-testid="mock-separator" {...props} />
);
