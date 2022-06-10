#!/bin/bash

set -eo pipefail

xcodebuild -workspace BCVaccineCard/BCVaccineCard.xcworkspace \
            -scheme HealthGateway \
            -sdk iphoneos \
            -configuration AppStoreDistribution \
            -archivePath $PWD/build/BCVaccineCard-Prod.xcarchive \
            clean archive | xcpretty
