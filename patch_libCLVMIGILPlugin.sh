#!/bin/sh

# Patch libCLVMIGILPlugin for HD4400to prevent crashes in Preview/Quick Look..
# Yosemite only
#
# Credits: the-darkvoid
# http://tonymacx86.com/yosemite-laptop-support/145427-fix-intel-hd4600-mobile-yosemite.html
#
# Notes:
#  [intel HD4600 Mobile] [8086:0416]
#  [intel HD4600 Dsktop] [8086:0412]
#  [intel HD4400 Mobile] [8086:0a16]

LIB_PATH=/System/Library/Frameworks/OpenCL.framework/Libraries/libCLVMIGILPlugin.dylib;

# Helper - Exit if not root
check_root() {
  if [[ $(id -u) -ne 0 ]]; then echo "This script must be run as root"; exit 1; fi
}

check_root

# Make a backup if none exists
if [ ! -f $LIB_PATH.orig ]; then cp $LIB_PATH $LIB_PATH.orig ; fi

# HD4400 [8086:0a16] patch
perl -pi -e 's|\x86\x80\x12\x04|\x86\x80\x16\x0A|sg' $LIB_PATH

# Sign OpenCL framework for good measure
codesign -f -s - $LIB_PATH
codesign -f -s - /System/Library/Frameworks/OpenCL.framework/
