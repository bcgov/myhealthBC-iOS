#!/bin/bash

set -eo pipefail

xcodebuild -workspace BCVaccineCard/BCVaccineCard.xcworkspace -scheme BCVaccineCard -sdk iphoneos -configuration AppStoreDistribution archive -archivePath $PWD/build/BCVaccineCard.xcarchive clean archive
