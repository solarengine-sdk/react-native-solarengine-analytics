import { RNPackageContext, RNPackage } from '@rnoh/react-native-openharmony/ts';
import { SolarEnginePackage } from './solarengine/SolarEnginePackage';

export function createRNPackages(ctx: RNPackageContext): RNPackage[] {
  return [new SolarEnginePackage(ctx)];
}