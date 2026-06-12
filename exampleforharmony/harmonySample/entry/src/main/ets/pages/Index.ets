import {
  AnyJSBundleProvider,
  ComponentBuilderContext,
  MetroJSBundleProvider,
  ResourceJSBundleProvider,
  RNApp,
  RNOHCoreContext,
  RNOHErrorDialog,
  RNOHLogger,
  TraceJSBundleProviderDecorator
} from '@rnoh/react-native-openharmony';
import { createRNPackages } from '../RNPackagesFactory';
import { HARMONY_METRO_ENABLED, HARMONY_METRO_HOST, HARMONY_METRO_PORT } from './HarmonyMetroConfig';

@Builder
export function buildCustomRNComponent(ctx: ComponentBuilderContext) {
}

const wrappedCustomRNComponentBuilder = wrapBuilder(buildCustomRNComponent)

@Entry
@Component
struct Index {
  @State shouldShow: boolean = false
  @StorageLink('RNOHCoreContext') private rnohCoreContext: RNOHCoreContext | undefined = undefined
  private logger: RNOHLogger | undefined = undefined

  aboutToAppear() {
    this.logger = this.rnohCoreContext!.logger.clone("Index")
    const stopTracing = this.logger.clone("aboutToAppear").startTracing();

    this.shouldShow = true
    stopTracing();
  }

  onBackPress(): boolean | undefined {
    // NOTE: this is required since `Ability`'s `onBackPressed` function always
    // terminates or puts the app in the background, but we want Ark to ignore it completely
    // when handled by RN
    this.rnohCoreContext!.dispatchBackPress()
    return true
  }

  build() {
    Column() {
      if (this.rnohCoreContext && this.shouldShow) {
        if (this.rnohCoreContext?.isDebugModeEnabled) {
          RNOHErrorDialog({ ctx: this.rnohCoreContext })
        }
        RNApp({
          rnInstanceConfig: {
            createRNPackages,
            enableNDKTextMeasuring: true, // 该项必须为true，用于开启NDK文本测算
            enableBackgroundExecutor: false,
            enableCAPIArchitecture: true, // 该项必须为true，用于开启CAPI
            arkTsComponentNames: []
          },
          initialProps: { "foo": "bar" } as Record<string, string>,
          appKey: "SolarengineAnalysisReactNativeExample",
          wrappedCustomRNComponentBuilder: wrappedCustomRNComponentBuilder,
          onSetUp: (rnInstance) => {
            rnInstance.enableFeatureFlag("ENABLE_RN_INSTANCE_CLEAN_UP")
          },
          jsBundleProvider: this.createJSBundleProvider(),
        })
      }
    }
    .height('100%')
    .width('100%')
  }

  private createJSBundleProvider() {
    const coreContext = this.rnohCoreContext as RNOHCoreContext
    const resourceProvider = new ResourceJSBundleProvider(
      coreContext.uiAbilityContext.resourceManager,
      'bundle.harmony.js'
    )
    const providers = HARMONY_METRO_ENABLED
      ? [
        MetroJSBundleProvider.fromServerIp(
          HARMONY_METRO_HOST,
          HARMONY_METRO_PORT
        ),
        resourceProvider
      ]
      : [resourceProvider]

    return new TraceJSBundleProviderDecorator(
      new AnyJSBundleProvider(providers),
      coreContext.logger
    )
  }
}
