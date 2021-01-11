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
# Target architecture 
TARGET := none



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


setarch:
# Set target architecture (ARCH if supported otherwise HOST arch)
ifneq ($(filter $(ARCH),$(SUPP_ARCH)),)
TARGET=$(ARCH)
else
TARGET=linux/$(HOST_ARCH)
endif


.PHONY: help
help:
	@echo  'Supported architectures: $(SUPP_ARCH)' 
	@echo  'Cleaning targets:'
	@echo  '  clean		  	- Remove most generated files but keep the sources'
	@echo  '  distclean	  	- Remove generated and sources'
	@echo  'Partial targets:'
	@echo  '  docker ARCH=	  	- Rebuild container image and instance'
	@echo  '  fs		  	- Export filesystem to fs folder'
	@echo  '  install_kernel  	- Install kernel inside the container'
	@echo  '  import_kernel ARCH=  	- Import all kernel modules and header binaries from ./kernel'
	@echo  'Other generic targets:'
	@echo  '  all ARCH=	  	- Build all targets' 

# Final target
.PHONY: all
all: clean_docker docker fs archive


# Generate cpio archive
.PHONY: archive
archive:
	# Generate initramfs as cpio archive
	@cd ./fs && find . -print0 | cpio --null -ov --format=newc > ../initramfs.cpio

# Generate filesystem from container
.PHONY: fs
fs:
	# Copy from container to fs directory
	@mkdir -p ./fs
	# Copy container filesystem in fs.tar
	@docker export flash_initramfs > ./fs.tar
	# Etracting container fs 
	@tar -xvf ./fs.tar -C ./fs

# Install kernel inside container 
.PHONY: install_kernel
install_kernel:
	@echo 'Removing previous container'
	@docker rm flash_initramfs $(IGNORE_FAIL);
	@echo 'Automatic install of kernel modules, mounting kernel src as a volume'
	@docker run --name flash_initramfs --mount type=bind,source=${PWD}/kernel,target=/kernel flash_initramfs /bin/bash -c "cd /kernel; \
	ls /kernel; \
	make install;  \
	make modules_install;" 

# docker depends on cross build 
.PHONY: docker
docker: $(CROSS_BUILD) 
	@echo 'Creating container ..'
	@docker create --name flash_initramfs flash_initramfs $(IGNORE_FAIL);

# Cross build 
.PHONY: crossbuild
crossbuild:
	$(info architecture ARCH = '$(ARCH)' was found)
	@echo 'cross build:' $(CROSS_BUILD);
	@echo 'CROSS building image for ARCH (EXPERIMENTAL)' $(ARCH);
	@docker buildx build --platform=$(ARCH) -t flash_initramfs .;

# Build 
.PHONY: build
build:
	$(info ARCH = '$(ARCH)' does not exist in '$(SUPP_ARCH)' will build against HOST architecture)
	@echo 'cross build:' $(CROSS_BUILD);
	echo 'Building image for ARCH' $(HOST_ARCH); 
	docker buildx build -t  flash_initramfs .;


# Import headers modules 
.PHONY: import_kernel
import_kernel: import_core_$(TARGET)
	@echo 'Importing kernel modules from ./kernel'
	$(MAKE) -C ./kernel modules_install INSTALL_MOD_PATH=../kmodules $(IGNORE_FAIL);
	@echo 'Importing kernel modules from ./kernel'
	$(MAKE) -C ./kernel headers_install INSTALL_HDR_PATH=../kheaders $(IGNORE_FAIL);
	@echo 'Importing kernel_version'
	$(MAKE) -s -C ./kernel kernelrelease > kernel_version; 
	@echo 'Importing kernel_config'
	@cp ./kernel/.config ./kernel_config;

# Intel 64 bit targets
import_core_linux/amd64 import_core_linux/x86_64: setarch
	@echo 'importing amd64 binaries' 
	@cp -rn ./kernel/arch/x86/boot/bzImage .

# Arm 64 bit targets
import_core_linux/arm64 import_core_linux/arm/v7 import_core_linux/arm/v6: setarch
	@echo 'importing arm64 binaries' 
	@cp -rn ./kernel/arch/arm64/boot/Image .

# Clean build files	
.PHONY: clean
clean: clean_docker
	# Clean dirty folders initramfs
	@rm -rf ./fs ./fs.tar ./initramfs.cpio.gz;					
	# Clean dirty folders kernel
	@rm -rf ./kmodules ./kheaders ./Image ./bzImage ./vmlinuz ./vmlinux ./kernel_config ./kernel_version;					

# Clean docker
.PHONY: clean_docker
clean_docker:
	# Remove previous container								
	@docker container rm flash_initramfs -f $(SIL_STDE) $(IGNORE_FAIL); 
	# Remove previous image									
	@docker rmi flash_initramfs -f $(SIL_STDE) $(IGNORE_FAIL); 
	# Remove eventual leftover dandling images						
	@docker rmi -f $(shell docker images -f "dangling=true" -q) $(SIL_STDE) $(IGNORE_FAIL);


# Distclean build files	
.PHONY: distclean
distclean: clean
	# Clean all but these files / folders
	@find . ! -name "readme.md" ! -name "Makefile" ! -name ".gitignore" ! -name "." -exec rm -rf {} + $(SIL_STDO);

# Custom user command
.PHONY: custom
custom:
	# Execute custom.sh 
	@./custom.sh



