#! /bin/sh

# Patches the template ssdt-rmne.dsl with a random MAC address
NULLETHDIR=./null_eth

MAC=`od -An -N6 -tx1 /dev/urandom | \
sed -e 's/^  */0x/' -e 's/  */, 0x/g' -e 's/, 0x$//'`
sed -e "s/0x11, 0x22, 0x33, 0x44, 0x55, 0x66/$MAC/" \
$NULLETHDIR/ssdt-rmne.dsl > $NULLETHDIR/ssdt-rmne_rand_mac.dsl
