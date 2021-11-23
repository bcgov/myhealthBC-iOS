#!/bin/bash

set -eo pipefail

sudo xcodebuild -workspace BCVaccineCard/BCVaccineCard.xcworkspace \
			-scheme BCVaccineCard \
			-sdk iphonesimulator \
			-archivePath $PWD/build/BCVaccineCard.xcarchive \
			clean build | xcpretty