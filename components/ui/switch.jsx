import * as React from "react";

const Switch = React.forwardRef(({ className, checked, onCheckedChange, ...props }, ref) => {
  const id = React.useId();

  const handleClick = () => {
    if (onCheckedChange) {
      onCheckedChange(!checked);
    }
  };

  return (
    <button
      ref={ref}
      role="switch"
      aria-checked={checked}
      data-state={checked ? "checked" : "unchecked"}
      id={id}
      onClick={handleClick}
      className={`inline-flex h-[24px] w-[44px] shrink-0 cursor-pointer items-center rounded-full border-2 border-transparent transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 data-[state=checked]:bg-primary data-[state=unchecked]:bg-muted ${className}`}
      {...props}
    >
      <span
        data-state={checked ? "checked" : "unchecked"}
        className={`pointer-events-none block h-5 w-5 rounded-full bg-background shadow-lg ring-0 transition-transform data-[state=checked]:translate-x-5 data-[state=unchecked]:translate-x-0`}
      />
    </button>
  );
});
Switch.displayName = "Switch";

export { Switch };
