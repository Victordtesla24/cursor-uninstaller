import * as React from "react";
import { ChevronDown } from "lucide-react";

const Accordion = ({ children, type = "single", collapsible = false, ...props }) => {
  const [openItems, setOpenItems] = React.useState([]);

  const contextValue = React.useMemo(() => {
    return {
      open: openItems,
      toggle: (value) => {
        if (type === "single") {
          setOpenItems(openItems.includes(value) && collapsible ? [] : [value]);
        } else {
          setOpenItems(
            openItems.includes(value)
              ? openItems.filter((item) => item !== value)
              : [...openItems, value]
          );
        }
      },
    };
  }, [openItems, type, collapsible]);

  return (
    <AccordionContext.Provider value={contextValue}>
      <div {...props}>{children}</div>
    </AccordionContext.Provider>
  );
};

const AccordionContext = React.createContext({
  open: [],
  toggle: () => {},
});

const AccordionItem = React.forwardRef(({ className, value, ...props }, ref) => {
  return (
    <div
      ref={ref}
      data-state={useAccordionContext().open.includes(value) ? "open" : "closed"}
      className={`border-b ${className}`}
      {...props}
    />
  );
});
AccordionItem.displayName = "AccordionItem";

const AccordionTrigger = React.forwardRef(({ className, children, ...props }, ref) => {
  const { open, toggle } = useAccordionContext();
  const itemContext = React.useContext(AccordionItemContext);

  if (!itemContext) {
    throw new Error("AccordionTrigger must be used within an AccordionItem");
  }

  const { value } = itemContext;
  const isOpen = open.includes(value);

  return (
    <div
      ref={ref}
      className={`flex flex-1 items-center justify-between py-4 font-medium transition-all hover:underline [&[data-state=open]>svg]:rotate-180 ${className}`}
      onClick={() => toggle(value)}
      {...props}
    >
      {children}
      <ChevronDown className="h-4 w-4 shrink-0 transition-transform duration-200" />
    </div>
  );
});
AccordionTrigger.displayName = "AccordionTrigger";

const AccordionContent = React.forwardRef(({ className, children, ...props }, ref) => {
  const { open } = useAccordionContext();
  const itemContext = React.useContext(AccordionItemContext);

  if (!itemContext) {
    throw new Error("AccordionContent must be used within an AccordionItem");
  }

  const { value } = itemContext;
  const isOpen = open.includes(value);

  return (
    <div
      ref={ref}
      data-state={isOpen ? "open" : "closed"}
      className={`overflow-hidden text-sm transition-all data-[state=closed]:animate-accordion-up data-[state=open]:animate-accordion-down ${className}`}
      style={{
        height: isOpen ? "auto" : "0",
      }}
      {...props}
    >
      <div className="pb-4 pt-0">{children}</div>
    </div>
  );
});
AccordionContent.displayName = "AccordionContent";

const AccordionItemContext = React.createContext(null);

// Simplified version that doesn't require nesting
const SimpleAccordionItem = ({ value, trigger, content, className, ...props }) => {
  const { open, toggle } = useAccordionContext();
  const isOpen = open.includes(value);

  return (
    <div
      data-state={isOpen ? "open" : "closed"}
      className={`border-b ${className}`}
      {...props}
    >
      <div
        className="flex flex-1 items-center justify-between py-4 font-medium transition-all hover:underline [&[data-state=open]>svg]:rotate-180"
        onClick={() => toggle(value)}
      >
        {trigger}
        <ChevronDown className="h-4 w-4 shrink-0 transition-transform duration-200" />
      </div>
      <div
        data-state={isOpen ? "open" : "closed"}
        className="overflow-hidden text-sm transition-all"
        style={{
          height: isOpen ? "auto" : "0",
        }}
      >
        <div className="pb-4 pt-0">{content}</div>
      </div>
    </div>
  );
};

const useAccordionContext = () => {
  const context = React.useContext(AccordionContext);
  if (!context) {
    throw new Error("useAccordionContext must be used within an Accordion");
  }
  return context;
};

export { Accordion, AccordionItem, AccordionTrigger, AccordionContent, SimpleAccordionItem };
