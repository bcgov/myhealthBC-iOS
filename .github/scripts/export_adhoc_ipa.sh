#!/bin/bash

set -eo pipefail

xcodebuild clean -exportArchive -archivePath $PWD/build/BCVaccineCard.xcarchive -exportPath $PWD/build -allowProvisioningUpdates -exportOptionsPlist BCVaccineCard/exportOptions-adhoc.plist xcpretty