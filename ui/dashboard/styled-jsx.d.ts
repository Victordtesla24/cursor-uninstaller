import 'react';

// Extend the StyleHTMLAttributes interface in React to include styled-jsx props
declare module 'react' {
  interface StyleHTMLAttributes<T> extends React.HTMLAttributes<T> {
    jsx?: boolean;
    global?: boolean;
  }
}
