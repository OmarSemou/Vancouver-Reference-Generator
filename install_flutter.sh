#!/bin/bash

# Download and install Flutter SDK
FLUTTER_VERSION="2.10.4"
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Add flutter to the path
export PATH="$PATH:`pwd`/flutter/bin"

# Run flutter doctor to initialize Flutter
flutter doctor
