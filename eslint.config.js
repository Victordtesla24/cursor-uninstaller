import globals from 'globals';

export default [
  {
    files: ['**/*.js'],
    languageOptions: {
      ecmaVersion: 12,
      sourceType: 'module',
      globals: {
        ...globals.node,
        ...globals.jest
      }
    },
    rules: {
      // ESLint recommended rules
      'no-unused-vars': ['warn', { 'argsIgnorePattern': '^_', 'varsIgnorePattern': '^_', 'caughtErrorsIgnorePattern': '^_' }],
      'no-undef': 'error',
      'no-console': 'off',
      'semi': ['warn', 'always'],
      'quotes': ['warn', 'single', { 'allowTemplateLiterals': true }]
    }
  },
  {
    files: ['lib/ui/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.browser,
        document: 'readonly',
        window: 'readonly'
      }
    }
  },
  {
    files: ['tests/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.jest,
        describe: 'readonly',
        it: 'readonly',
        expect: 'readonly',
        beforeEach: 'readonly',
        afterEach: 'readonly',
        beforeAll: 'readonly',
        afterAll: 'readonly',
        jest: 'readonly'
      }
    }
  }
];
