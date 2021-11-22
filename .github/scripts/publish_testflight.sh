#!/bin/bash

set -eo pipefail

xcrun altool --upload-app -t ios -f build/BCVaccineCard-Prod.ipa -u "$APPLEID_USERNAME" -p "$APPLEID_PASSWORD" --verbose
