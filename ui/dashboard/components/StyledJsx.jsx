import React from 'react';

/**
 * StyledJsx component
 * 
 * A wrapper for styled-jsx to prevent React warnings about non-boolean attributes in tests.
 * This component safely handles the jsx and global attributes.
 * 
 * @param {Object} props - Component props
 * @param {React.ReactNode} props.children - CSS content
 * @param {boolean} props.global - Whether styles should be global
 * @returns {JSX.Element} Properly configured style element
 */
export const StyledJsx = ({ children, global = false }) => {
  // Convert jsx/global props to string data attributes that won't trigger warnings
  return (
    <style
      data-styled-jsx={true}
      data-styled-global={global ? true : undefined}
      dangerouslySetInnerHTML={{ __html: children }}
    />
  );
};

export default StyledJsx; 