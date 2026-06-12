//
// Created on 2026/3/25.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "RNOH/PackageProvider.h"
#include "solarengine/SolarEnginePackage.h"

using namespace rnoh;

std::vector<std::shared_ptr<Package>> PackageProvider::getPackages(Package::Context ctx) {
    return {
        std::make_shared<SolarEnginePackage>(ctx)
    };
}