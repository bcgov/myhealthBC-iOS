#!/bin/bash

set -eo pipefail

xcodebuild -workspace BCVaccineCard/BCVaccineCard.xcworkspace -scheme HealthGatewayDev -sdk iphoneos -configuration AppStoreDistribution archive -archivePath $PWD/build/BCVaccineCard.xcarchive clean archive -allowProvisioningUpdates
