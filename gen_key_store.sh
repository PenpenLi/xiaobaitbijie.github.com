#!/usr/bin/env bash
alias=$1
keytool -genkey -alias ${alias} -keyalg RSA -validity 20000 -keystore android.keystore
keytool -list -v -alias ${alias} -keystore android.keystore
mv android.keystore ./frameworks/runtime-src/proj.android
