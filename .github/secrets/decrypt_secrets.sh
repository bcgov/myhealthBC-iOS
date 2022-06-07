#!/bin/bash

set -eo pipefail

gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEYS" --output ./.github/secrets/prov.mobileprovision ./.github/secrets/prov.mobileprovision.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEYS" --output ./.github/secrets/cert.p12 ./.github/secrets/cert.p12.gpg

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

cp ./.github/secrets/prov.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/prov.mobileprovision

security create-keychain -p "$IOS_KEYS" health.keychain
security unlock-keychain -p "$IOS_KEYS" health.keychain
security default-keychain -s ~/Library/Keychains/health.keychain
security set-keychain-settings -l -u -t 4000

security import ./.github/secrets/cert.p12 -t agg -k ~/Library/Keychains/health.keychain -P "" -A
security import ./.github/secrets/cert.p12 -k ~/Library/Keychains/health.keychain -P "" -T /usr/bin/codesign

security list-keychains -s ~/Library/Keychains/health.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "$IOS_KEYS" ~/Library/Keychains/health.keychain