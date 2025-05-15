/* eslint-disable no-undef */

jest.mock('react-native', () => {
  const RN = jest.requireActual('react-native');
  return {
    ...RN,
    NativeModules: {
      ...RN.NativeModules,
      SolarengineAnalysis: {
        initialize: jest.fn(),
        trackEvent: jest.fn(),
        trackUserProfile: jest.fn(),
      },
    },
  };
});
