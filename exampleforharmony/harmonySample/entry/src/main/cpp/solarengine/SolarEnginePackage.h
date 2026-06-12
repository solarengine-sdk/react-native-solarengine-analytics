#pragma once
#include "RNOH/Package.h"
#include "SolarengineAnalysisReactNative.h"

namespace rnoh {
class SolarEngineTurboModuleFactoryDelegate : public TurboModuleFactoryDelegate {
  public:
    SharedTurboModule createTurboModule(Context ctx, const std::string &name) const override {
        if (name == "SolarengineAnalysisReactNative") {
            return std::make_shared<SolarengineAnalysisReactNative>(ctx, name);
        }
        return nullptr;
    }
};

class SolarEnginePackage : public Package {
  public:
    SolarEnginePackage(Package::Context ctx) : Package(ctx) {}
    
    std::unique_ptr<TurboModuleFactoryDelegate> createTurboModuleFactoryDelegate() override {
        return std::make_unique<SolarEngineTurboModuleFactoryDelegate>();
    }
};
} // namespace rnoh
