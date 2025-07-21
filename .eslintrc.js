module.exports = {
  env: {
    browser: true,
    es2021: true
  },
  extends: [
    'standard'
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  rules: {
    'no-unused-vars': 'warn',
    'no-console': 'warn',
    'prefer-const': 'error',
    'no-var': 'error'
  },
  globals: {
    // Rails/Stimulus globals
    'Stimulus': 'readonly',
    'application': 'readonly',
    // Chart.js
    'Chart': 'readonly',
    'Chartkick': 'readonly'
  }
}