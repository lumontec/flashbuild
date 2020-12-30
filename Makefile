# Generate initramfs cpio archive

# Supported architectures
SUPP_ARCH := 	linux/x86_64 \
		linux/amd64 \
		linux/arm64 \
		linux/riscv64 \
		linux/ppc64le \
		linux/s390x \
		linux/386 \
		linux/arm/v7 \
		linux/arm/v6 

# Host architecture
HOST_ARCH := $(shell uname -m)
# Support for cross build
CROSS_BUILD := none

# Some helpers

# Silence stdout
SIL_STDO = 1>/dev/null
# Silence stderr
SIL_STDE = 2>/dev/null
# Ignore command failure
IGNORE_FAIL = || true


# Check if architecture is supported in case sets CROSS_BUILD
ifneq ($(filter $(ARCH),$(SUPP_ARCH)),)
CROSS_BUILD=crossbuild
else
CROSS_BUILD=build
endif

# Check if DEST is set
test_dest: 
ifeq ($(DEST),)
$(error 'DEST path is not set')
else
$(info 'will save to DEST=$(DEST)')
endif


# save 
.PHONY: 
save: test_dest
	# cleaning
	@echo 'cleaning previous state for DEST=$(DEST)'
	@rm -rf $(DEST)/1_bootloader $(DEST)/2_kernel $(DEST)/3_initramfs $(DEST)/4_rootfs
	# bootloader 
	@echo 'create 1_bootloader directory under DEST=$(DEST)';
	@mkdir -p $(DEST)/1_bootloader;
	@echo 'saving 1_bootloader sources to DEST=$(DEST)/1_bootloader';
	@cp `git ls-files --cached --others --exclude-standard ./1_bootloader` $(DEST)/1_bootloader;
	# kernel 
	@echo 'create 2_kernel directory under DEST=$(DEST)';
	@mkdir -p $(DEST)/2_kernel;
	@echo 'saving 2_kernel sources to DEST=$(DEST)/2_kernel';
	@cp `git ls-files --cached --others --exclude-standard ./2_kernel` $(DEST)/2_kernel;
	# initramfs 
	@echo 'create 3_initramfs directory under DEST=$(DEST)';
	@mkdir -p $(DEST)/3_initramfs;
	@echo 'saving 3_initramfs sources to DEST=$(DEST)/3_initramfs';
	@cp `git ls-files --cached --others --exclude-standard ./3_initramfs` $(DEST)/3_initramfs;
	@cp -rn ./3_initramfs/Dockerfile $(DEST)/3_initramfs;
	@cp -rn ./3_initramfs/src $(DEST)/3_initramfs;
	# rootfs 
	@echo 'create 4_rootfs directory under DEST=$(DEST)';
	@mkdir -p $(DEST)/4_rootfs;
	@echo 'saving 4_rootfs sources to DEST=$(DEST)/4_rootfs';
	@cp `git ls-files --cached --others --exclude-standard ./4_rootfs` $(DEST)/4_rootfs;
	# emulator 
	@echo 'saving emulation scripts under DEST=$(DEST)';
	@cp -rn emulate* $(DEST);


.PHONY: help
help:
	@echo  'Project targets:'
	@echo  '  clean		  - Remove most generated files but keep the sources'
	@echo  '  distclean	  - Remove generated and sources'
	@echo  '  save DEST=	  - Saves current workspace state of SOURCES in your DEST path'
	@echo  '  load LOAD=	  - Load saved sources inside current workspace' 
	@echo  '  init		  - Initialize a clean workspace' 
	@echo  'Modules targets:'
	@echo  '  bootloader	  - Access bootloader make commands'
	@echo  '  kernel	  - Access kernel make commands'
	@echo  '  initramfs	  - Access initramfs commands'
	@echo  '  rootfs	  - Access rootfs commands'



