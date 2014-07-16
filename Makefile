# makefile

#
# Patches/Installs/Builds DSDT patches for Dell XPS 13 9333
#
# Created by RehabMan 
# Adapted by vbourachot for XPS 13 9333
#

# DSDT patch: from compiled acpi tables to installed patched dsdt/ssdt-1
# make distclean disassemble patch && make && make install
#
# AppleHDA patch: Create injector kext and install in SLE
# make patch_hda && sudo make install_hda
#
# Install Clover config
# make install_config

GFXSSDT=ssdt5
EFIDIR=/Volumes/EFI
EFIVOL=/dev/disk0s1
LAPTOPGIT=../Laptop-DSDT-Patch
DEBUGGIT=../debug.git
EXTRADIR=/Extra
BUILDDIR=./build
PATCHED=./patched
UNPATCHED=./unpatched
PRODUCTS=$(BUILDDIR)/dsdt.aml $(BUILDDIR)/$(GFXSSDT).aml
DISASSEMBLE_SCRIPT=./disassemble.sh

PATCH_HDA_SCRIPT=./patch_hda.sh
HDACODEC=ALC668

IASLFLAGS=-vr -w1
IASL=/usr/local/bin/iasl
PATCHMATIC=/usr/local/bin/patchmatic

all: $(PRODUCTS)

$(BUILDDIR)/dsdt.aml: $(PATCHED)/dsdt.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<
	
$(BUILDDIR)/$(GFXSSDT).aml: $(PATCHED)/$(GFXSSDT).dsl
	$(IASL) $(IASLFLAGS) -p $@ $<
	
clean:
	rm -f $(PRODUCTS)
	rm -rf $(BUILDDIR)/AppleHDA_$(HDACODEC).kext
	rm -f $(PATCHED)/*.dsl

distclean: clean
	rm -f $(UNPATCHED)/*.dsl

# Chameleon Install - NOT TESTED
install_extra: $(PRODUCTS)
	-rm $(EXTRADIR)/ssdt-*.aml
	cp $(BUILDDIR)/dsdt.aml $(EXTRADIR)/dsdt.aml
	cp $(BUILDDIR)/$(GFXSSDT).aml $(EXTRADIR)/ssdt-1.aml

# Clover Install
install: $(PRODUCTS)
	if [ ! -d $(EFIDIR) ]; then mkdir $(EFIDIR) && diskutil mount -mountPoint $(EFIDIR) $(EFIVOL); fi
	cp $(BUILDDIR)/dsdt.aml $(EFIDIR)/EFI/CLOVER/ACPI/patched
	cp $(BUILDDIR)/$(GFXSSDT).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/ssdt-1.aml
	diskutil unmount $(EFIDIR)
	if [ -d $(EFIDIR) ]; then rmdir $(EFIDIR); fi

# Patch with 'patchmatic'
patch:
	cp $(UNPATCHED)/dsdt.dsl $(UNPATCHED)/$(GFXSSDT).dsl $(PATCHED)

	# Fixes syntax errors
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/syntax_dsdt.txt $(PATCHED)/dsdt.dsl

	# replace with laptopgit patch: syntax/remove_DSM.txt (exact copy)
	# NOTE: 28 changes
	# $(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/cleanup.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/syntax/remove_DSM.txt $(PATCHED)/dsdt.dsl
	# $(PATCHMATIC) $(PATCHED)/$(GFXSSDT).dsl patches/cleanup.txt $(PATCHED)/$(GFXSSDT).dsl
	$(PATCHMATIC) $(PATCHED)/$(GFXSSDT).dsl $(LAPTOPGIT)/syntax/remove_DSM.txt $(PATCHED)/$(GFXSSDT).dsl

	# NOTE: 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/remove_wmi.txt $(PATCHED)/dsdt.dsl	

	# NOTE: updated
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/keyboard.txt $(PATCHED)/dsdt.dsl

	# NOTE: Check layout id in patch - (20140715: set to 1)
	# NOTE: 2 patches, 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/audio.txt $(PATCHED)/dsdt.dsl

	# TODO: Skip for now
	# $(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/sensors.txt $(PATCHED)/dsdt.dsl

	# NOTE: 4 changes
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_IRQ.txt $(PATCHED)/dsdt.dsl

	# NOTE: 37 changes	
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/graphics/graphics_Rename-GFX0.txt $(PATCHED)/dsdt.dsl

	# NOTE: 5 changes	
	$(PATCHMATIC) $(PATCHED)/$(GFXSSDT).dsl $(LAPTOPGIT)/graphics/graphics_Rename-GFX0.txt $(PATCHED)/$(GFXSSDT).dsl

	# ISSUE?: 12 patches, only 2 changes (same if applies to DSDT??)
	$(PATCHMATIC) $(PATCHED)/$(GFXSSDT).dsl $(LAPTOPGIT)/graphics/graphics_PNLF_haswell.txt $(PATCHED)/$(GFXSSDT).dsl

	# TODO: Skip for now (hdmi audio)
	# $(PATCHMATIC) $(PATCHED)/$(GFXSSDT).dsl patches/hdmi_audio.txt $(PATCHED)/$(GFXSSDT).dsl

	# TODO: Skip for now (for usb)
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/usb/usb_7-series.txt $(PATCHED)/dsdt.dsl

	# System patches - run as is?
	# NOTE: 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_WAK2.txt $(PATCHED)/dsdt.dsl
	# NOTE: 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_OSYS.txt $(PATCHED)/dsdt.dsl
	# DISABLED IN GIT - NOTE: 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_MCHC.txt $(PATCHED)/dsdt.dsl
	# DISABLED IN GIT - NOTE: 4 changes
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_HPET.txt $(PATCHED)/dsdt.dsl
	# NOTE: 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_RTC.txt $(PATCHED)/dsdt.dsl
	# NOTE: 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_SMBUS.txt $(PATCHED)/dsdt.dsl
	# NOTE: 3 changes
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_Mutex.txt $(PATCHED)/dsdt.dsl
	# NOTE: 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_PNOT.txt $(PATCHED)/dsdt.dsl
	# NOTE: 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_IMEI.txt $(PATCHED)/dsdt.dsl

	# NOTE: From Dell 7000 thread
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_Shutdown2.txt $(PATCHED)/dsdt.dsl
	# NOTE: From Dell 7000 thread
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_ADP1.txt $(PATCHED)/dsdt.dsl


	# NOTE: 15 changes
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/battery/battery_Dell-XPS-13.txt $(PATCHED)/dsdt.dsl

patch_debug:
	make patch
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(DEBUGGIT)/debug.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/debug.txt $(PATCHED)/dsdt.dsl


disassemble:
	$(DISASSEMBLE_SCRIPT)


patch_hda: 
	$(PATCH_HDA_SCRIPT)

install_hda:
	cp -r $(BUILDDIR)/AppleHDA_$(HDACODEC).kext /System/Library/Extensions/

# Clover config.plist install
install_config: 
	if [ ! -d $(EFIDIR) ]; then mkdir $(EFIDIR) && diskutil mount -mountPoint $(EFIDIR) $(EFIVOL); fi
	cp ./config.plist $(EFIDIR)/EFI/CLOVER/
	diskutil unmount $(EFIDIR)
	if [ -d $(EFIDIR) ]; then rmdir $(EFIDIR); fi


.PHONY: all clean distclean patch patch_debug install install_extra \
		disassemble patch_hda install_hda install_config 

# native correlations
# ssdt1 - sensrhub
# ssdt2 - PtidDevc
# ssdt3 - Cpu0Ist
# ssdt4 - CpuPm
# ssdt5 - SaSsdt (gfx0)
# ssdt6 - IsctTabl
# ssdt7 - PmRef - Cpu0Cst (dynamic)
# ssdt8 - PmRef - ApIst (dynamic)
# ssdt9 - PmRef - ApCst (dynamic)
