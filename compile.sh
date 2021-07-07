#!/usr/bin/env bash

set -eu -o pipefail

# Build for arm64 and x86_64
mkdir build
clang main.m -framework AppKit -arch arm64 -o build/arm64
clang main.m -framework AppKit -arch x86_64 -o build/x86_64

# Build and sign universal binary
mkdir bin
lipo -create -output bin/macos-font-installer build/*
codesign --sign - --force --preserve-metadata=entitlements,requirements,flags,runtime bin/macos-font-installer
