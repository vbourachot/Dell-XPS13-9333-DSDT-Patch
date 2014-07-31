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

NULLETHDIR=./null_eth
PATCH_RMNE_SCRIPT=./patch_null_eth_mac.sh

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
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/syntax_dsdt.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/syntax/remove_DSM.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/$(GFXSSDT).dsl $(LAPTOPGIT)/syntax/remove_DSM.txt $(PATCHED)/$(GFXSSDT).dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/remove_wmi.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/keyboard.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl patches/audio.txt $(PATCHED)/dsdt.dsl

	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_IRQ.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/graphics/graphics_Rename-GFX0.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/$(GFXSSDT).dsl $(LAPTOPGIT)/graphics/graphics_Rename-GFX0.txt $(PATCHED)/$(GFXSSDT).dsl
	$(PATCHMATIC) $(PATCHED)/$(GFXSSDT).dsl $(LAPTOPGIT)/graphics/graphics_PNLF_haswell.txt $(PATCHED)/$(GFXSSDT).dsl
	$(PATCHMATIC) $(PATCHED)/$(GFXSSDT).dsl patches/hdmi_audio.txt $(PATCHED)/$(GFXSSDT).dsl

	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/usb/usb_7-series.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_WAK2.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_OSYS.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_MCHC.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_HPET.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_RTC.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_SMBUS.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_Mutex.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_PNOT.txt $(PATCHED)/dsdt.dsl
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_IMEI.txt $(PATCHED)/dsdt.dsl
	# NOTE: From Dell 7000 thread
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_Shutdown2.txt $(PATCHED)/dsdt.dsl
	# NOTE: From Dell 7000 thread
	$(PATCHMATIC) $(PATCHED)/dsdt.dsl $(LAPTOPGIT)/system/system_ADP1.txt $(PATCHED)/dsdt.dsl

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
	if [ -d /System/Library/Extensions/AppleHDA_$(HDACODEC).kext ]; \
	then rm -rf /System/Library/Extensions/AppleHDA_$(HDACODEC).kext && cp -r $(BUILDDIR)/AppleHDA_$(HDACODEC).kext /System/Library/Extensions/; \
	else cp -r $(BUILDDIR)/AppleHDA_$(HDACODEC).kext /System/Library/Extensions/; fi
	touch /System/Library/Extensions


# Install Clover config.plist
# Appends smbios info if ./config.plist.smbios exists
install_config: 
	if [ ! -d $(EFIDIR) ]; then mkdir $(EFIDIR) && diskutil mount -mountPoint $(EFIDIR) $(EFIVOL); fi
	if [ -f ./config.plist.smbios ]; then \
		./config_append_smbios.sh && cp ./config.plist.local $(EFIDIR)/EFI/CLOVER/config.plist; \
		diff ./config.plist $(EFIDIR)/EFI/CLOVER/config.plist || exit 0; \
	else cp ./config.plist $(EFIDIR)/EFI/CLOVER/; \
	fi
	diskutil unmount $(EFIDIR)
	if [ -d $(EFIDIR) ]; then rmdir $(EFIDIR); fi

# Install CodecCommander custom Info.plist
install_plist_cc: 
	if [ ! -d $(EFIDIR) ]; then mkdir $(EFIDIR) && diskutil mount -mountPoint $(EFIDIR) $(EFIVOL); fi
	cp ./plists/CodecCommander_Info.plist $(EFIDIR)/EFI/CLOVER/kexts/10.9/CodecCommander.kext/Contents/Info.plist
	touch $(EFIDIR)/EFI/CLOVER/kexts/10.9/CodecCommander.kext
	diskutil unmount $(EFIDIR)
	if [ -d $(EFIDIR) ]; then rmdir $(EFIDIR); fi

# Install FakeSMC custom Info.plist
install_plist_smc: 
	if [ ! -d $(EFIDIR) ]; then mkdir $(EFIDIR) && diskutil mount -mountPoint $(EFIDIR) $(EFIVOL); fi
	cp ./plists/FakeSMC_Info.plist $(EFIDIR)/EFI/CLOVER/kexts/10.9/FakeSMC.kext/Contents/Info.plist
	touch $(EFIDIR)/EFI/CLOVER/kexts/10.9/FakeSMC.kext
	diskutil unmount $(EFIDIR)
	if [ -d $(EFIDIR) ]; then rmdir $(EFIDIR); fi

# Compile ssdt for null ethernet
null_eth:
	$(PATCH_RMNE_SCRIPT)
	$(IASL) $(IASLFLAGS) -p $(BUILDDIR)/ssdt-rmne_rand_mac.aml $(NULLETHDIR)/ssdt-rmne_rand_mac.dsl

# Install null ethernet ssdt
install_null_eth: null_eth
	if [ ! -d $(EFIDIR) ]; then mkdir $(EFIDIR) && diskutil mount -mountPoint $(EFIDIR) $(EFIVOL); fi
	cp $(BUILDDIR)/ssdt-rmne_rand_mac.aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/ssdt-2.aml
	diskutil unmount $(EFIDIR)
	if [ -d $(EFIDIR) ]; then rmdir $(EFIDIR); fi


.PHONY: all clean distclean patch patch_debug install install_extra \
		disassemble patch_hda install_hda install_config \
		install_plist_cc install_plist_smc \
		null_eth install_null_eth

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
