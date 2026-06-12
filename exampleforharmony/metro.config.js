const path = require('path');
const { mergeConfig, getDefaultConfig } = require('@react-native/metro-config');
const {
  createHarmonyMetroConfig,
} = require('@react-native-oh/react-native-harmony/metro.config');
const exclusionList = require('metro-config/src/defaults/exclusionList');

const root = path.resolve(__dirname, '..');
const releaseArtifactsPath = path.join(root, 'release-artifacts');
const harmonyConfig = createHarmonyMetroConfig({
  reactNativeHarmonyPackageName: '@react-native-oh/react-native-harmony',
});
const harmonyResolveRequest = harmonyConfig?.resolver?.resolveRequest;

module.exports = mergeConfig(
  getDefaultConfig(__dirname),
  harmonyConfig,
  {
    projectRoot: __dirname,
    watchFolders: [root],
    resolver: {
      blockList: exclusionList([
        new RegExp(
          `^${releaseArtifactsPath.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\/.*$`
        ),
      ]),
      nodeModulesPaths: [
        path.resolve(__dirname, 'node_modules'),
        path.resolve(root, 'node_modules'),
      ],
      extraNodeModules: {
        'solarengine-analysis-react-native': path.resolve(root, 'src'),
        'react-native': path.resolve(
          __dirname,
          'node_modules/@react-native-oh/react-native-harmony'
        ),
      },
      resolveRequest: (context, moduleName, platform) => {
        if (moduleName === 'solarengine-analysis-react-native') {
          return {
            filePath: path.resolve(root, 'src/index.tsx'),
            type: 'sourceFile',
          };
        }

        if (typeof harmonyResolveRequest === 'function') {
          return harmonyResolveRequest(context, moduleName, platform);
        }

        return context.resolveRequest(context, moduleName, platform);
      },
    },
    transformer: {
      getTransformOptions: async () => ({
        transform: {
          experimentalImportSupport: false,
          inlineRequires: true,
        },
      }),
    },
  }
);
