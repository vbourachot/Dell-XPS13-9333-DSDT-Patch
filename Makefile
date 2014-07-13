# makefile

#
# Patches/Installs/Builds DSDT patches for Dell XPS 13 9333
#
# Created by RehabMan 
# Adapted by vbourachot for XPS 13 9333
#

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

IASLFLAGS=-vr -w1
IASL=/usr/local/bin/iasl
PATCHMATIC=/usr/local/bin/patchmatic

.PHONY: all
all: $(PRODUCTS)

$(BUILDDIR)/dsdt.aml: $(PATCHED)/dsdt.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<
	
$(BUILDDIR)/$(GFXSSDT).aml: $(PATCHED)/$(GFXSSDT).dsl
	$(IASL) $(IASLFLAGS) -p $@ $<
	
.PHONY: clean
clean:
	rm $(PRODUCTS)

# Chameleon Install - NOT TESTED
.PHONY: install_extra
install_extra: $(PRODUCTS)
	-rm $(EXTRADIR)/ssdt-*.aml
	cp $(BUILDDIR)/dsdt.aml $(EXTRADIR)/dsdt.aml
	cp $(BUILDDIR)/$(GFXSSDT).aml $(EXTRADIR)/ssdt-1.aml

# Clover Install
.PHONY: install
install: $(PRODUCTS)
	if [ ! -d $(EFIDIR) ]; then mkdir $(EFIDIR) && diskutil mount -mountPoint $(EFIDIR) $(EFIVOL); fi
	cp $(BUILDDIR)/dsdt.aml $(EFIDIR)/EFI/CLOVER/ACPI/patched
	cp $(BUILDDIR)/$(GFXSSDT).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/ssdt-1.aml
	diskutil unmount $(EFIDIR)
	if [ -d $(EFIDIR) ]; then rmdir $(EFIDIR); fi


# Patch with 'patchmatic'
.PHONY: patch
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

	# NOTE: DISABLE
	# $(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/keyboard.txt $(PATCHED)/dsdt.dsl

	# NOTE: Check layout id in patch - (set to 1)
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
	# $(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/usb/usb_7-series.txt $(PATCHED)/dsdt.dsl

	# System patches - run as is?
	# NOTE: 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_WAK2.txt $(PATCHED)/dsdt.dsl
	# NOTE: 1 change
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_OSYS.txt $(PATCHED)/dsdt.dsl
	# DISABLED IN GIT - NOTE: 1 change
	#$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_MCHC.txt $(PATCHED)/dsdt.dsl
	# DISABLED IN GIT - NOTE: 4 changes
	#$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_HPET.txt $(PATCHED)/dsdt.dsl
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

	# Stands to reason to replace with dell xps 13 patch battery_Dell-XPS-13.txt 
	# NOTE: 15 changes
	# $(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/battery/battery_Lenovo-Ux10-Z580.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/battery/battery_Dell-XPS-13.txt $(PATCHED)/dsdt.dsl
	

.PHONY: patch_debug
patch_debug:
	make patch
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(DEBUGGIT)/debug.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/debug.txt $(PATCHED)/dsdt.dsl
	#$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/debug1.txt $(PATCHED)/dsdt.dsl


.PHONY: disassemble
disassemble:
	$(DISASSEMBLE_SCRIPT)


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
