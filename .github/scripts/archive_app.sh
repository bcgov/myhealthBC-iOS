#!/bin/bash

set -eo pipefail

xcodebuild -workspace BCVaccineCard/BCVaccineCard.xcworkspace \
            -scheme BCVaccineCard-Prod \
            -sdk iphoneos \
            -configuration AppStoreDistribution \
            -archivePath $PWD/build/BCVaccineCard-Prod.xcarchive \
            clean archive | xcpretty
