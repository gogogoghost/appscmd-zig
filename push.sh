#!/bin/sh

set -e

zig build

adb push zig-out/bin/appscmd-cli /data/local/tmp/