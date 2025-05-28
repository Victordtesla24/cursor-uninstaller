import * as React from "react";

/**
 * Progress Component
 * 
 * A customizable progress bar component
 * 
 * @param {Object} props - Component props
 * @param {string} props.className - Additional CSS classes
 * @param {number} props.value - Progress value (0-100)
 * @param {Object} ref - Forwarded ref
 */
const Progress = React.forwardRef(({ className = '', value = 0, ...props }, ref) => {
  return (
    <div
      ref={ref}
      className={`relative h-4 w-full overflow-hidden rounded-full bg-muted ${className}`}
      {...props}
    >
      <div
        className="h-full w-full flex-1 bg-primary transition-all"
        style={{ transform: `translateX(-${100 - (value || 0)}%)` }}
      />
    </div>
  );
});

Progress.displayName = "Progress";

export default Progress; 