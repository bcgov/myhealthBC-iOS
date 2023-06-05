#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/BCVaccineCard.xcarchive \
           -exportOptionsPlist BCVaccineCard/exportOptions-dev.plist \
           -exportPath $PWD/build \
           -allowProvisioningUpdates \
           -exportArchive | xcpretty
