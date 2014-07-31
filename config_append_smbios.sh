#! /bin/sh
LC=`wc -l ./config.plist | awk '{print $1}'`

head -n `expr $LC - 3`  ./config.plist > config.plist.local
cat ./config.plist.smbios >> config.plist.local
