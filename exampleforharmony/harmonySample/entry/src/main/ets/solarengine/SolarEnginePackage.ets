import { RNPackage, TurboModulesFactory } from '@rnoh/react-native-openharmony/ts';
import type { TurboModule, TurboModuleContext } from '@rnoh/react-native-openharmony/ts';
import { SolarengineAnalysisReactNative } from './SolarengineAnalysisReactNative';

class SolarEngineTurboModulesFactory extends TurboModulesFactory {
  createTurboModule(name: string): TurboModule | null {
    if (name === 'SolarengineAnalysisReactNative') {
      return new SolarengineAnalysisReactNative(this.ctx);
    }
    return null;
  }

  hasTurboModule(name: string): boolean {
    return name === 'SolarengineAnalysisReactNative';
  }
}

export class SolarEnginePackage extends RNPackage {
  createTurboModulesFactory(ctx: TurboModuleContext): TurboModulesFactory {
    return new SolarEngineTurboModulesFactory(ctx);
  }
}
