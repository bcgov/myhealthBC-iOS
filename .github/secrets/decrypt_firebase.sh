#!/bin/bash

set -eo pipefail

gpg --quiet --batch --yes --decrypt --passphrase="$FW_KEYS" --output ./.github/secrets/dist.p12 ./.github/secrets/AppleDistribution.p12.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$FW_KEYS" --output ./.github/secrets/ClientVaccineCard-ADHOC.mobileprovision ./.github/secrets/ClientVaccineCardADHOC.mobileprovision.gpg

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

cp ./.github/secrets/ClientVaccineCard-ADHOC.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/ClientVaccineCard-ADHOC.mobileprovision

security create-keychain -p "$FW_KEYS" health.keychain
security unlock-keychain -p "$FW_KEYS" health.keychain
security default-keychain -s ~/Library/Keychains/health.keychain
security set-keychain-settings -l -u -t 4000

security import ./.github/secrets/dist.p12 -t agg -k ~/Library/Keychains/build.keychain -P "" -A
security import ./.github/secrets/dist.p12 -t agg -k ~/Library/Keychains/health.keychain -P "" -A
security import ./.github/secrets/dist.p12 -k ~/Library/Keychains/health.keychain -P "" -T /usr/bin/codesign

security list-keychains -s ~/Library/Keychains/healthkeychain
security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/health.keychain
