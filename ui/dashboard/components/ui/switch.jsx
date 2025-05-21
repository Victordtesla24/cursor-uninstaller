import React from 'react';

/**
 * Switch Component
 *
 * A toggle switch input component.
 */
const Switch = ({
  checked = false,
  onCheckedChange,
  className = '',
  disabled = false,
  id,
  ...props
}) => {
  const handleClick = () => {
    if (onCheckedChange && !disabled) {
      onCheckedChange(!checked);
    }
  };

  return (
    <input
      type="checkbox"
      role="switch"
      aria-checked={checked ? 'true' : 'false'}
      id={id}
      checked={checked}
      onChange={(e) => onCheckedChange && onCheckedChange(e.target.checked)}
      disabled={disabled}
      className={`peer relative inline-flex h-[24px] w-[44px] shrink-0 cursor-pointer appearance-none items-center rounded-full border-2 border-transparent transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background disabled:cursor-not-allowed disabled:opacity-50 ${checked ? 'bg-primary' : 'bg-input'} ${className}`}
      data-state={checked ? 'checked' : 'unchecked'}
      {...props}
    />
  );
};

export default Switch;
