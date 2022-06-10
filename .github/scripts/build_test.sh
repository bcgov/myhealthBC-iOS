#!/bin/bash

set -eo pipefail

xcodebuild  -workspace BCVaccineCard/BCVaccineCard.xcworkspace \
-scheme HealthGatewayTest \
-sdk iphonesimulator \
clean build | xcpretty