#!/bin/bash

set -eo pipefail

sudo xcodebuild clean -exportArchive -archivePath $PWD/build/BCVaccineCard.xcarchive -exportPath $PWD/build -allowProvisioningUpdates -exportOptionsPlist BCVaccineCard/exportOptions-adhoc.plist