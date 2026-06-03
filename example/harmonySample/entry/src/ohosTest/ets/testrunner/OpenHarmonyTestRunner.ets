import { abilityDelegatorRegistry } from '@kit.TestKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Hypium } from '@ohos/hypium';
import testsuite from '../test/List.test';

export default class OpenHarmonyTestRunner {
  onPrepare() {
    hilog.info(0x0000, 'SeSDKRN', '%{public}s', 'OpenHarmonyTestRunner: onPrepare');
  }

  onRun() {
    hilog.info(0x0000, 'SeSDKRN', '%{public}s', 'OpenHarmonyTestRunner: onRun');
    const delegator = abilityDelegatorRegistry.getAbilityDelegator();
    const args = abilityDelegatorRegistry.getArguments();
    Hypium.hypiumTest(delegator, args, testsuite);
  }

  onFinish() {
    hilog.info(0x0000, 'SeSDKRN', '%{public}s', 'OpenHarmonyTestRunner: onFinish');
  }
}
