#!/bin/bash

set -eo pipefail

xcodebuild -workspace BCVaccineCard.xcworkspace \
            -scheme BCVaccineCard-Prod\ iOS \
            -sdk iphoneos \
            -configuration AppStoreDistribution \
            -archivePath $PWD/build/BCVaccineCard-Prod.xcarchive \
            clean archive | xcpretty
