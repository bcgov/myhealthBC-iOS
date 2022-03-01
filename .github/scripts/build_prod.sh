#!/bin/bash

set -eo pipefail

xcodebuild -workspace BCVaccineCard/BCVaccineCard.xcworkspace -scheme BCVaccineCard-Prod -sdk iphonesimulator clean build | xcpretty