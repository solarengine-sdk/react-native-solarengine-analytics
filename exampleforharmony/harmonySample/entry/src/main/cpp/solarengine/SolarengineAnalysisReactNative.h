#pragma once
#include "RNOH/ArkTSTurboModule.h"

namespace rnoh {
class JSI_EXPORT SolarengineAnalysisReactNative : public ArkTSTurboModule {
  public:
    SolarengineAnalysisReactNative(const ArkTSTurboModule::Context ctx, const std::string name);
};
} // namespace rnoh
