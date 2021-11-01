#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/BCVaccineCard-Prod.xcarchive \
            -exportOptionsPlist Calculator-iOS/Calculator\ iOS/exportOptions.plist \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
