#include "SolarengineAnalysisReactNative.h"

namespace rnoh {
using namespace facebook;

SolarengineAnalysisReactNative::SolarengineAnalysisReactNative(const ArkTSTurboModule::Context ctx,
                                                               const std::string name)
    : ArkTSTurboModule(ctx, name) {
    methodMap_ = {
        ARK_METHOD_METADATA(preInit, 1),
        ARK_METHOD_METADATA(initialize, 4),
        ARK_METHOD_METADATA(setReactNativeBridgeVersion, 1),
        ARK_METHOD_METADATA(multiply, 2),

        ARK_METHOD_METADATA(registerAttribution, 1),
        ARK_METHOD_METADATA(registerDeeplink, 1),
        ARK_METHOD_METADATA(registerDeferredDeeplink, 1),
        ARK_METHOD_METADATA(registerInitiateComplete, 1),

        ARK_METHOD_METADATA(fetchDistinctId, 1),
        ARK_METHOD_METADATA(retrieveAttribution, 0),
        ARK_METHOD_METADATA(setVisitorID, 1),
        ARK_METHOD_METADATA(setOaid, 1),
        ARK_METHOD_METADATA(setChannel, 1),
        ARK_METHOD_METADATA(fetchVisitor, 1),
        ARK_METHOD_METADATA(login, 1),
        ARK_METHOD_METADATA(fetchAccount, 0),
        ARK_METHOD_METADATA(logout, 0),
        ARK_METHOD_METADATA(setSuperProperties, 1),
        ARK_METHOD_METADATA(unsetSuperProperty, 1),
        ARK_METHOD_METADATA(clearSuperProperties, 0),
        ARK_METHOD_METADATA(retrievePresetProperties, 1),
        ARK_METHOD_METADATA(setPresetProperties, 1),

        ARK_METHOD_METADATA(userPropertiesInit, 1),
        ARK_METHOD_METADATA(userPropertiesUpdate, 1),
        ARK_METHOD_METADATA(userPropertiesAdd, 1),
        ARK_METHOD_METADATA(userPropertiesUnset, 1),
        ARK_METHOD_METADATA(userPropertiesAppend, 1),
        ARK_METHOD_METADATA(userPropertiesDelete, 1),

        ARK_METHOD_METADATA(trackAdImpressionWithAttributes, 1),
        ARK_METHOD_METADATA(trackAdClickWithAttributes, 1),
        ARK_METHOD_METADATA(trackIAPWithAttributes, 1),
        ARK_METHOD_METADATA(trackOrderWithAttributes, 1),
        ARK_METHOD_METADATA(trackAppAttrWithAttributes, 1),
        ARK_METHOD_METADATA(trackRegisterWithAttributes, 1),
        ARK_METHOD_METADATA(trackLoginWithAttributes, 1),

        ARK_METHOD_METADATA(trackCustomEvent, 3),
        ARK_METHOD_METADATA(eventStart, 1),
        ARK_METHOD_METADATA(eventEnd, 2),
        ARK_METHOD_METADATA(trackFirstEvent, 2),
        ARK_METHOD_METADATA(reportEventimmediately, 0),
        ARK_METHOD_METADATA(trackAppReEngagement, 1),
        ARK_METHOD_METADATA(appDeeplinkOpenURL, 1),

        ARK_METHOD_METADATA(setDefaultConfig, 1),
        ARK_METHOD_METADATA(setRemoteConfigEventProperties, 1),
        ARK_METHOD_METADATA(setRemoteConfigUserProperties, 1),
        ARK_METHOD_METADATA(fastFetchRemoteConfig, 1),
        ARK_METHOD_METADATA(fastFetchRemoteConfigWithKey, 2),
        ARK_METHOD_METADATA(asyncFetchRemoteConfig, 1),
        ARK_METHOD_METADATA(asyncFetchRemoteConfigWithKey, 2),

        ARK_METHOD_METADATA(currentPlatform, 0),
        ARK_METHOD_METADATA(authorizationCompleted, 0),
        ARK_METHOD_METADATA(requestPermissionsFromUser, 0),

    };
}

} // namespace rnoh