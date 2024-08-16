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
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

# Final target
.PHONY: all
all: clean workspace docker fs archive copy-host-kernel  ## Build bootable artifacts 



.PHONY: archive
archive:  # Generate cpio archive
	# Generate initramfs as cpio archive
	@cd ./workspace/fs && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

.PHONY: workspace
workspace:
	mkdir -p workspace

.PHONY: fs 
fs: ## Generate filesystem from container
	# Copy from container to fs directory
	@mkdir -p ./workspace/fs
	# Copy container filesystem in fs.tar
	@docker export flash_initramfs > ./workspace/fs.tar
	# Etracting container fs 
	@tar -xvf ./workspace/fs.tar -C ./workspace/fs

.PHONY: copy-host-kernel
copy-host-kernel: ## Copy kernel from host /boot directory
	@kernel_version=$$(uname -r); \
	cp /boot/vmlinuz-$$kernel_version ./workspace/vmlinuz
 
.PHONY: install_kernel
install_kernel: ## Install kernel inside container
	@echo 'Removing previous container'
	@docker rm flash_initramfs $(IGNORE_FAIL);
	@echo 'Automatic install of kernel modules, mounting kernel src as a volume'
	@docker run --name flash_initramfs --mount type=bind,source=${PWD}/kernel,target=/kernel flash_initramfs /bin/bash -c "cd /kernel; \
	ls ./workspace/kernel; \
	make install;  \
	make modules_install;" 

.PHONY: docker
docker: $(CROSS_BUILD)  ## docker depends on cross build
	@echo 'Creating container ..'
	@docker create --name flash_initramfs flash_initramfs $(IGNORE_FAIL);

.PHONY: crossbuild
crossbuild: ## Cross build
	$(info architecture ARCH = '$(ARCH)' was found)
	@echo 'cross build:' $(CROSS_BUILD);
	@echo 'CROSS building image for ARCH (EXPERIMENTAL)' $(ARCH);
	@docker buildx build --platform=$(ARCH) -t flash_initramfs --load .;

 
.PHONY: build
build: ## Build
	$(info ARCH = '$(ARCH)' does not exist in '$(SUPP_ARCH)' will build against HOST architecture)
	@echo 'cross build:' $(CROSS_BUILD);
	echo 'Building image for ARCH' $(HOST_ARCH); 
	docker buildx build -t  flash_initramfs --load .;

 
.PHONY: import_kernel
import_kernel: import_core_$(TARGET) ## Import headers modules
	@echo 'Importing kernel modules from ./kernel'
	$(MAKE) -C ./kernel modules_install INSTALL_MOD_PATH=../kmodules
	@echo 'Importing kernel modules from ./kernel'
	$(MAKE) -C ./kernel headers_install INSTALL_HDR_PATH=../kheaders


import_core_linux/amd64 import_core_linux/x86_64: setarch ## Intel 64 bit targets
	@echo 'importing amd64 binaries' 
	@cp -rn ./kernel/arch/x86/boot/bzImage .
	@cp -rn ./kernel/vmlinux .


import_core_linux/arm64 import_core_linux/arm/v7 import_core_linux/arm/v6: setarch ## Arm 64 bit targets
	@echo 'importing arm64 binaries' 
	@cp -rn ./kernel/arch/arm64/boot/Image .
	@cp -rn ./kernel/vmlinux .


	
.PHONY: clean
clean: # Clean build files
	# Clean dirty folders initramfs
	@rm -rf ./workspace;					
	# Clean dirty folders kernel
	@rm -rf ./kmodules ./kheaders ./Image ./bzImage ./vmlinuz ./vmlinux config version;					
	# Remove previous container								
	@docker container rm flash_initramfs -f $(SIL_STDE) $(IGNORE_FAIL); 
	# Remove previous image									
	@docker rmi flash_initramfs -f $(SIL_STDE) $(IGNORE_FAIL); 
	# Remove eventual leftover dandling images						
	@docker rmi -f $(shell docker images -f "dangling=true" -q) $(SIL_STDE) $(IGNORE_FAIL);


