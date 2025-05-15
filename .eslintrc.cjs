module.exports = {
  root: true,
  extends: ['@react-native', 'prettier'],
  plugins: ['prettier'],
  rules: {
    'react/react-in-jsx-scope': 'off',
    'react-native/no-inline-styles': 'warn',
    'no-array-constructor': 'warn',
    'no-bitwise': 'warn',
    'prettier/prettier': [
      'error',
      {
        quoteProps: 'consistent',
        singleQuote: true,
        tabWidth: 2,
        trailingComma: 'es5',
        useTabs: false,
      },
    ],
  },
  ignorePatterns: [
    'node_modules/',
    'lib/',
    'cli.js',
    'babel.config.js',
    'metro.config.js',
    'react-native.config.js',
    'jest.setup.js',
    'example/node_modules/',
    'example/ios/',
    'example/android/'
  ],
}; 