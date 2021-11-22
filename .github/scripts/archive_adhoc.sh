#!/bin/bash

set -eo pipefail

sudo xcodebuild -workspace BCVaccineCard/BCVaccineCard.xcworkspace \
			-scheme BCVaccineCard \
			-sdk iphonesimulator \
			-archivePath $PWD/build/BCVaccineCard-Prod.xcarchive \
			clean archive | xcpretty
