#!/bin/bash

set -eo pipefail

xcodebuild  -workspace BCVaccineCard/BCVaccineCard.xcworkspace \
			-scheme HealthGatewayDev \
			-sdk iphonesimulator \
			clean build | xcpretty