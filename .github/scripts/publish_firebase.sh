#!/bin/bash

set -eo pipefail

firebase appdistribution:distribute $PWD/build/BCVaccineCard.ipa  \
		--app $FIREBASE_APP_ID \
		--token $FIREBASE_TOKEN
		--release-notes "Bug fixes and improvements"
