#!/bin/bash

set -eo pipefail

gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEYS" --output ./.github/secrets/healthgateway.mobileprovision ./.github/secrets/healthgateway.mobileprovision.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEYS" --output ./.github/secrets/certDev.p12 ./.github/secrets/certDev.p12.gpg

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

cp ./.github/secrets/prov.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/healthgateway.mobileprovision

security create-keychain -p "$IOS_KEYS" health.keychain
security unlock-keychain -p "$IOS_KEYS" health.keychain
security default-keychain -s ~/Library/Keychains/health.keychain
security set-keychain-settings -l -u -t 4000

security import ./.github/secrets/certDev.p12 -t agg -k ~/Library/Keychains/health.keychain -P "" -A
security import ./.github/secrets/certDev.p12 -k ~/Library/Keychains/health.keychain -P "" -T /usr/bin/codesign

security list-keychains -s ~/Library/Keychains/health.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "$IOS_KEYS" ~/Library/Keychains/health.keychain