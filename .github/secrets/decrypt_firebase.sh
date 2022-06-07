#!/bin/bash

set -eo pipefail

gpg --quiet --batch --yes --decrypt --passphrase="$FW_KEYS" --output ./.github/secrets/dist.p12 ./.github/secrets/AppleDistribution.p12.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$FW_KEYS" --output ./.github/secrets/ClientVaccineCard-ADHOC.mobileprovision ./.github/secrets/ClientVaccineCardADHOC.mobileprovision.gpg

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

cp ./.github/secrets/ClientVaccineCard-ADHOC.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/ClientVaccineCard-ADHOC.mobileprovision

# Create keychain with password
security create-keychain -p "$FW_KEYS" healthfirebase.keychain
# Unlock keycbain
security unlock-keychain -p "$FW_KEYS" healthfirebase.keychain
# Set default Keyhcain
security default-keychain -s ~/Library/Keychains/healthfirebase.keychain
# Extend keychain lock timeout
security set-keychain-settings -l -u -t 4000

security import ./.github/secrets/dist.p12 -t agg -k ~/Library/Keychains/healthfirebase.keychain -P "" -A
security import ./.github/secrets/dist.p12 -k ~/Library/Keychains/healthfirebase.keychain -P "" -T /usr/bin/codesign

security list-keychains -s ~/Library/Keychains/healthfirebase.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/healthfirebase.keychain
