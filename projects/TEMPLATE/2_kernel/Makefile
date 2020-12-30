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


.PHONY: help
help:
	@echo  'Supported architectures: $(SUPP_ARCH)' 
	@echo  'Cleaning targets:'
	@echo  '  clean		  - Remove most generated files but keep the sources'
	@echo  '  distclean	  - Remove generated and sources'
	@echo  'Partial targets:'
	@echo  '  install ARCH=	  - Install compiled loadable kernel modules and kernel headers inside rootfs'
	@echo  '  import ARCH=	  - Import all kernel modules and header binaries from ./src'
	@echo  'Other generic targets:'
	@echo  '  all ARCH=	  - Build all targets' 


# Final target
.PHONY: all
all: import install


# Generate cpio archive
.PHONY: 
install:
	@echo 'Install kmodule folder inside 3_rootfs/src folder'
	@cp -rn ./kmodules ../3_initramfs/src
	@echo 'Install kheaders folder inside 3_rootfs/src folder'
	@cp -rn ./kheaders ../3_initramfs/src

# Import headers modules 
.PHONY: import 
import: import_core_$(ARCH)
	@echo 'Importing kernel modules from ./src'
	$(MAKE) -C ./src modules_install INSTALL_MOD_PATH=../kmodule
	@echo 'Importing kernel modules from ./src'
	$(MAKE) -C ./src headers_install INSTALL_HDR_PATH=../kheaders

# Intel 64 bit targets
import_core_linux/amd64 import_core_linux/x86_64:
	@echo 'importing amd64 binaries' 
	@cp -rn ./src/arch/x86_64/boot/bzImage .
	@cp -rn ./src/vmlinux .

# Arm 64 bit targets
import_core_linux/arm64 import_core_linux/arm/v7 import_core_linux/arm/v6:
	@echo 'importing arm64 binaries' 
	@cp -rn ./src/arch/arm64/boot/Image .
	@cp -rn ./src/vmlinux .

# Clean build files	
.PHONY: clean
clean:
	# Clean dirty folders
	@rm -rf ./kmodules ./kheaders ./Image ./bzImage ./vmlinuz ./vmlinux config version;					

# Distclean build files	
.PHONY: distclean
distclean: clean
	# Clean all but these files / folders
	@find . ! -name "readme.md" ! -name "Makefile" ! -name ".gitignore" ! -name "." -exec rm -rf {} + $(SIL_STDO);
