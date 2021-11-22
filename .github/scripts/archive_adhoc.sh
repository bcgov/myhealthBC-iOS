#!/bin/bash

set -eo pipefail

sudo xcodebuild -workspace BCVaccineCard/BCVaccineCard.xcworkspace \
			-scheme BCVaccineCard \
			-sdk iphoneos \
			-archivePath $PWD/build/BCVaccineCard-Prod.xcarchive \
			clean archive | xcpretty
