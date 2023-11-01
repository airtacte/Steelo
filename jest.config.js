module.exports = {
    preset: '@testing-library/react-native',
    setupFiles: ['./node_modules/react-native-gesture-handler/jestSetup.js'],
    transformIgnorePatterns: [
      'node_modules/(?!(jest-)?@?react-native|@react-native-community|@react-navigation)'
    ],
    globals: {
      'ts-jest': {
        babelConfig: true,
      },
    },
  };
  