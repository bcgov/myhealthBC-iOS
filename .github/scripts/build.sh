#!/bin/bash

set -eo pipefail

xcodebuild  -workspace BCVaccineCard/BCVaccineCard.xcworkspace \
			-scheme BCVaccineCard \
			-sdk iphonesimulator \
			clean build | xcpretty