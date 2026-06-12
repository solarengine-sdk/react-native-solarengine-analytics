import { describe, it, expect } from '@ohos/hypium';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type { TurboModuleContext } from '@rnoh/react-native-openharmony/ts';
import {
  _SolarEngineLog,
  SolarengineAnalysisReactNative
} from '../../../main/ets/solarengine/SolarengineAnalysisReactNative';

export default function solarEngineBridgeTest() {
  describe('SolarEngineBridgeTest', () => {
    it('should keep bridge log prefix stable', 0, () => {
      hilog.info(0x0000, 'SeSDKRN', '%{public}s', 'SolarEngineBridgeTest: check log prefix');
      expect(_SolarEngineLog).assertEqual('[SeSDKRNBridge]:');
    });

    it('should support multiply smoke test', 0, () => {
      const module = new SolarengineAnalysisReactNative({} as TurboModuleContext);
      hilog.info(0x0000, 'SeSDKRN', '%{public}s', 'SolarEngineBridgeTest: call multiply/getName');
      expect(module.multiply(3, 9)).assertEqual(27);
      expect(module.getName()).assertEqual('SolarengineAnalysisReactNative');
    });
  });
}
