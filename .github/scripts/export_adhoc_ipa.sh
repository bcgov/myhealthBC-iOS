#!/bin/bash

set -eo pipefail

sudo xcodebuild -archivePath $PWD/build/BCVaccineCard.xcarchive \
			-exportOptionsPlist BCVaccineCard/exportOptions-adhoc.plist \
			-exportPath $PWD/build \
			-allowProvisioningUpdates \
			-exportArchive | xcpretty
