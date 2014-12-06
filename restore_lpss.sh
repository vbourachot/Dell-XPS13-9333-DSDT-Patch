#!/bin/sh

mv /System/Library/Extensions/AppleIntelLpssDmac.kext.disabled /System/Library/Extensions/AppleIntelLpssDmac.kext && \
mv /System/Library/Extensions/AppleIntelLpssGspi.kext.disabled /System/Library/Extensions/AppleIntelLpssGspi.kext && \
mv /System/Library/Extensions/AppleIntelLpssI2C.kext.disabled /System/Library/Extensions/AppleIntelLpssI2C.kext && \
mv /System/Library/Extensions/AppleIntelLpssI2CController.kext.disabled /System/Library/Extensions/AppleIntelLpssI2CController.kext && \
mv /System/Library/Extensions/AppleIntelLpssSpiController.kext.disabled /System/Library/Extensions/AppleIntelLpssSpiController.kext && \
mv /System/Library/Extensions/AppleIntelLpssUART.kext.disabled /System/Library/Extensions/AppleIntelLpssUART.kext && \
touch /System/Library/Extensions

# Note: should also remove:
#Dec  1 21:29:25 mba.nyc.rr.com com.apple.kextcache[432]: AppleHSSPISupport.kext - no dependency found for com.apple.driver.AppleIntelLpssSpiController.
#Dec  1 21:29:32 mba.nyc.rr.com com.apple.kextcache[432]: Prelink failed for com.apple.driver.AppleHSSPISupport; omitting from prelinked kernel.
#Dec  1 21:29:32 mba.nyc.rr.com com.apple.kextcache[432]: AppleHSSPISupport.kext - no dependency found for com.apple.driver.AppleIntelLpssSpiController.
#Dec  1 21:29:32 mba.nyc.rr.com com.apple.kextcache[432]: Prelink failed for com.apple.driver.AppleHSSPIHIDDriver; omitting from prelinked kernel.

