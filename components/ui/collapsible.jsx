import * as React from "react";

const Collapsible = ({ open, children, ...props }) => {
  return <div {...props}>{children}</div>;
};

const CollapsibleTrigger = React.forwardRef(({ className, children, ...props }, ref) => {
  return (
    <button
      ref={ref}
      className={className}
      {...props}
    >
      {children}
    </button>
  );
});
CollapsibleTrigger.displayName = "CollapsibleTrigger";

const CollapsibleContent = React.forwardRef(({ className, open, children, ...props }, ref) => {
  const [height, setHeight] = React.useState(0);
  const ref2 = React.useRef(null);

  React.useEffect(() => {
    if (ref2.current) {
      setHeight(open ? ref2.current.scrollHeight : 0);
    }
  }, [open]);

  return (
    <div
      ref={ref}
      className={className}
      style={{
        overflow: "hidden",
        height: open === undefined ? "auto" : height,
        transition: "height 0.2s ease-in-out"
      }}
      {...props}
    >
      <div ref={ref2}>{children}</div>
    </div>
  );
});
CollapsibleContent.displayName = "CollapsibleContent";

export { Collapsible, CollapsibleTrigger, CollapsibleContent };
