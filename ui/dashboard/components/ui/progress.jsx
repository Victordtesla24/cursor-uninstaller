import * as React from "react";

const Progress = React.forwardRef(({ className, value, ...props }, ref) => {
  return (
    <div
      ref={ref}
      role="progressbar"
      aria-valuemin={0}
      aria-valuemax={100}
      aria-valuenow={value}
      className={`h-2 w-full overflow-hidden rounded-full bg-muted ${className}`}
      {...props}
    >
      <div
        className="h-full w-0 transform-gpu rounded-full bg-primary transition-all duration-300"
        style={{ width: `${value}%` }}
      />
    </div>
  );
});

Progress.displayName = "Progress";

export { Progress };