import React from 'react';

/**
 * Separator Component
 *
 * A visual divider with horizontal or vertical orientation.
 */
const Separator = ({ orientation = 'horizontal', className = '', ...props }) => {
  return (
    <div
      className={`shrink-0 bg-muted ${orientation === 'horizontal' ? 'h-[1px] w-full' : 'h-full w-[1px]'} ${className}`}
      role="none"
      {...props}
    />
  );
};

export default Separator;
