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


# Final target
.PHONY: all
all: archive


# Generate cpio archive
.PHONY: archive
archive: fs
	# Generate initramfs as cpio archive
	@cd ./fs && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

# Generate filesystem from container
.PHONY: fs
fs: docker
	# Copy from container to fs directory
	@mkdir -p ./fs
	# Copy docker filesystem in fs folder
	@docker cp flash_initramfs:/fs/ .

# docker depends on cross build 
.PHONY: docker
docker: $(CROSS_BUILD) 
	@echo 'Creating container ..'
	@docker create --name flash_initramfs flash_initramfs;

# Cross build 
.PHONY: crossbuild
crossbuild:
	$(info architecture ARCH = '$(ARCH)' was found)
	@echo 'cross build:' $(CROSS_BUILD);
	@echo 'CROSS building image for ARCH (EXPERIMENTAL)' $(ARCH);
	@docker buildx build --platform=$(ARCH) -t flash_initramfs --no-cache .;

# Build 
.PHONY: build
build:
	$(info ARCH = '$(ARCH)' does not exist in '$(SUPP_ARCH)' will build against HOST architecture)
	@echo 'cross build:' $(CROSS_BUILD);
	echo 'Building image for ARCH' $(HOST_ARCH); 
	docker build -t flash_initramfs --no-cache .;


# Clean build files	
.PHONY: clean
clean:
	# Clean dirty folders
	@rm -rf ./fs ./flash_initramfs.tar ./initramfs.cpio.gz;					
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

.PHONY: help
help:
	@echo  'Supported architectures: $(SUPP_ARCH)' 
	@echo  'Cleaning targets:'
	@echo  '  clean		  - Remove most generated files but keep the sources'
	@echo  '  distclean	  - Remove generated and sources'
	@echo  'Partial targets:'
	@echo  '  docker ARCH=	  - Rebuild container image and instance'
	@echo  '  fs		  - Export filesystem to fs folder'
	@echo  'Other generic targets:'
	@echo  '  all ARCH=	  - Build all targets' 
