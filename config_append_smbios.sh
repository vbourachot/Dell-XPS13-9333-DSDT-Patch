#! /bin/sh
LC=`wc -l ./config.plist | awk '{print $1}'`
LC_TRIM=`expr $LC - 3`

head -n `expr $LC - 3`  ./config.plist > config.plist.local
cat ./config.plist.smbios >> config.plist.local
