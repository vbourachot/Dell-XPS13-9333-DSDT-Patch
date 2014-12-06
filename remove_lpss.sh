#!/bin/sh

mv /System/Library/Extensions/AppleIntelLpssDmac.kext /System/Library/Extensions/AppleIntelLpssDmac.kext.disabled && \
mv /System/Library/Extensions/AppleIntelLpssGspi.kext /System/Library/Extensions/AppleIntelLpssGspi.kext.disabled && \
mv /System/Library/Extensions/AppleIntelLpssI2C.kext /System/Library/Extensions/AppleIntelLpssI2C.kext.disabled && \
mv /System/Library/Extensions/AppleIntelLpssI2CController.kext /System/Library/Extensions/AppleIntelLpssI2CController.kext.disabled && \
mv /System/Library/Extensions/AppleIntelLpssSpiController.kext /System/Library/Extensions/AppleIntelLpssSpiController.kext.disabled && \
mv /System/Library/Extensions/AppleIntelLpssUART.kext /System/Library/Extensions/AppleIntelLpssUART.kext.disabled && \
touch /System/Library/Extensions

# Note: should also remove:
#Dec  1 21:29:25 mba.nyc.rr.com com.apple.kextcache[432]: AppleHSSPISupport.kext - no dependency found for com.apple.driver.AppleIntelLpssSpiController.
#Dec  1 21:29:32 mba.nyc.rr.com com.apple.kextcache[432]: Prelink failed for com.apple.driver.AppleHSSPISupport; omitting from prelinked kernel.
#Dec  1 21:29:32 mba.nyc.rr.com com.apple.kextcache[432]: AppleHSSPISupport.kext - no dependency found for com.apple.driver.AppleIntelLpssSpiController.
#Dec  1 21:29:32 mba.nyc.rr.com com.apple.kextcache[432]: Prelink failed for com.apple.driver.AppleHSSPIHIDDriver; omitting from prelinked kernel.

