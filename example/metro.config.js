const path = require('path');
const { getDefaultConfig } = require('@react-native/metro-config');

const root = path.resolve(__dirname, '..');

/**
 * Metro configuration
 * https://facebook.github.io/metro/docs/configuration
 *
 * @type {import('metro-config').MetroConfig}
 */
module.exports = {
  ...getDefaultConfig(__dirname),
  projectRoot: __dirname,
  watchFolders: [root],
  resolver: {
    nodeModulesPaths: [
      path.resolve(__dirname, 'node_modules'),
      path.resolve(root, 'node_modules'),
    ],
    resolveRequest: (context, moduleName, platform) => {
      if (moduleName === 'solarengine-analysis-react-native') {
        return {
          filePath: path.resolve(root, 'src/index.tsx'),
          type: 'sourceFile',
        };
      }
      return context.resolveRequest(context, moduleName, platform);
    },
  },
};
