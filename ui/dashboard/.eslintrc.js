module.exports = {
  extends: ['next', 'next/core-web-vitals'],
  rules: {
    // General rules for the project
    'react/react-in-jsx-scope': 'off',
    'react/prop-types': 'off',

    // Disable styled-jsx related rules since we've migrated to Tailwind CSS
    'styled-jsx/jsx-quotes': 'off',
    'styled-jsx/no-unused-expressions': 'off',
    'styled-jsx/no-duplicate-className': 'off'
  }
};
