#!/bin/sh
set -eo pipefail

gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEYS" --output ./.github/secrets/prov.mobileprovision ./.github/secrets/prov.mobileprovision.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEYS" --output ./.github/secrets/cert.p12 ./.github/secrets/cert.p12.gpg

gpg --quiet --batch --yes --decrypt --passphrase="$FW_KEYS" --output ./.github/secrets/dist.p12 ./.github/secrets/dist.p12.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$FIREBASE_PROVISIONING" --output ./.github/secrets/prov2.mobileprovision ./.github/secrets/ClientVaccineCardADHOC.mobileprovision.gpg


mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

cp ./.github/secrets/prov.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/prov.mobileprovision
cp ./.github/secrets/prov2.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/prov2.mobileprovision

security create-keychain -p "" build.keychain
security import ./.github/secrets/cert.p12 -t agg -k ~/Library/Keychains/build.keychain -P "" -A
security import ./.github/secrets/dist.p12 -t agg -k ~/Library/Keychains/build.keychain -P "" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain

security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain
