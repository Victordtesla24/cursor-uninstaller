module.exports = {
  extends: ['next', 'next/core-web-vitals'],
  rules: {
    // Configure no-unknown-property to recognize styled-jsx attributes
    'react/no-unknown-property': ['error', {
      ignore: ['jsx', 'global']
    }]
  }
}; 