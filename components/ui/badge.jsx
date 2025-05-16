import * as React from "react";

function Badge({
  className,
  variant = "default",
  ...props
}) {
  const variantStyles = {
    default: "bg-primary text-primary-foreground",
    secondary: "bg-secondary text-secondary-foreground",
    destructive: "bg-destructive text-destructive-foreground",
    outline: "border text-foreground"
  };

  return (
    <div
      className={`inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 ${variantStyles[variant]} ${className}`}
      {...props}
    />
  );
}

export { Badge };
