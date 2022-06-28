#!/bin/bash

set -eo pipefail

xcodebuild -workspace BCVaccineCard/BCVaccineCard.xcworkspace -scheme HealthGateway -sdk iphonesimulator clean build | xcpretty