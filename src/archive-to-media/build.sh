#!/bin/bash

swift build -c release
cp -f .build/release/archive-to-media ../../bin/archive-to-media