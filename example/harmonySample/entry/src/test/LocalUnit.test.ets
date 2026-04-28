import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type { RNPackageContext, TurboModuleContext } from '@rnoh/react-native-openharmony/ts';
import { SolarEnginePackage } from '../main/ets/solarengine/SolarEnginePackage';
import {
  _SolarEngineLog,
  SolarengineAnalysisReactNative
} from '../main/ets/solarengine/SolarengineAnalysisReactNative';

export default function localUnitTest() {
  describe('SolarEngineHarmonyBridgeLocalUnitTest', () => {
    beforeAll(() => {
    });
    beforeEach(() => {
    });
    afterEach(() => {
    });
    afterAll(() => {
    });

    it('should expose stable log prefix constant', 0, () => {
      hilog.info(0x0000, 'SeSDKRN', '%{public}s', 'LocalUnit: check log prefix');
      expect(_SolarEngineLog).assertEqual('[SeSDKRNBridge]:');
    });

    it('should compute multiply result in bridge module', 0, () => {
      const module = new SolarengineAnalysisReactNative({} as TurboModuleContext);
      hilog.info(0x0000, 'SeSDKRN', '%{public}s', 'LocalUnit: call multiply/getName');
      const result = module.multiply(6, 7);
      expect(result).assertEqual(42);
      expect(module.getName()).assertEqual('SolarengineAnalysisReactNative');
    });

    it('should create turbo module factory and resolve module by name', 0, () => {
      const pkg = new SolarEnginePackage({} as RNPackageContext);
      const factory = pkg.createTurboModulesFactory({} as TurboModuleContext);

      expect(factory.hasTurboModule('SolarengineAnalysisReactNative')).assertEqual(true);
      expect(factory.hasTurboModule('UnknownModule')).assertEqual(false);

      const created = factory.createTurboModule('SolarengineAnalysisReactNative');
      expect(created !== null).assertEqual(true);

      if (created) {
        const typed = created as SolarengineAnalysisReactNative;
        expect(typed.getName()).assertEqual('SolarengineAnalysisReactNative');
      }

      const missing = factory.createTurboModule('UnknownModule');
      expect(missing === null).assertEqual(true);
    });
  });
}
