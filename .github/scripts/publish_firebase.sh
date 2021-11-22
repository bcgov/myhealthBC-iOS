#!/bin/bash

set -eo pipefail

firebase appdistribution:distribute $PWD/build/BCVaccineCard.ipa  \
--app 1:31314327234:ios:b0a5dd723940d15f852d5b \
--token 1//06MvM85fAZyktCgYIARAAGAYSNwF-L9Iry6Y_D5ifK-uTcpjX-EurrpH_jcA96viTxJxhc3tFQizh7FdeQxfcBP3CsC9IF-olqXw\
--release-notes "Bug fixes and improvements"
