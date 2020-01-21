#!/usr/bin/env bash

git checkout yunnan
./crypt.py -e
cocos deploy -p android -m release --compile-script 0
./crypt.py -d
mv publish/android/Gashapon-release-signed.apk yunnan.apk

git checkout develop
./crypt.py -e
cocos deploy -p android -m release --compile-script 0
./crypt.py -d
mv publish/android/Gashapon-release-signed.apk xuezhan.apk

git checkout neijiang
./crypt.py -e
cocos deploy -p android -m release --compile-script 0
./crypt.py -d
mv publish/android/Gashapon-release-signed.apk neijiang.apk
