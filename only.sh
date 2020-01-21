#!/usr/bin/env bash

./crypt.py -e
cocos deploy -p android -m release --compile-script 0
./crypt.py -d
#mv publish/android/Gashapon-release-signed.apk kuandian.apk
