#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/BCVaccineCard-Prod.xcarchive \
-exportOptionsPlist BCVaccineCard/exportOptions-adhoc.plist \
-exportPath $PWD/build \
-allowProvisioningUpdates \
-exportArchive | xcpretty
