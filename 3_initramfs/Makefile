# Generate initramfs cpio archive

# Supported architectures
SUPP_ARCH := 	linux/amd64 \
		linux/arm64 \
		linux/riscv64 \
		linux/ppc64le \
		linux/s390x \
		linux/386 \
		linux/arm/v7 \
		linux/arm/v6 

# Final target
.PHONY: all
all: archcheck docker fs archive

# Check if architecture is supported
.PHONY: archcheck
archcheck:
ifneq ($(filter $(ARCH),$(SUPP_ARCH)),)
	$(info architecture ARCH = '$(ARCH)' was found)
else
	$(error ARCH = '$(ARCH)' does not exist in '$(SUPP_ARCH)')
endif

# Generate cpio archive
.PHONY: archive
archive: 
	# Generate initramfs as cpio archive
	@cd ./fs && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

# Generate filesystem from container
.PHONY: fs
fs: docker
	# Copy from container to fs directory
	@mkdir -p ./fs
	# Copy docker filesystem in fs folder
	@docker cp flash_initramfs:/fs/ .

# Build containers
.PHONY: docker
docker: archcheck
	# Build the docker image
	docker buildx build --platform=$(ARCH) -t flash_initramfs .
	# Create the container if not exists
	@docker create --name flash_initramfs flash_initramfs


# Clean build files	
.PHONY: clean
clean:
	# Clean dirty folders
	@rm -rf ./fs ./flash_initramfs.tar ./initramfs.cpio.gz
	# Remove previous container
	@docker container rm flash_initramfs -f | true
	# Remove previous image
	@docker rmi flash_initramfs -f | true


# Distclean build files	
.PHONY: distclean
distclean:
	# Clean all but these files / folders
	@find . ! -name "readme.md" ! -name "Makefile" ! -name ".gitignore" ! -name "." -exec rm -rf {} + > /dev/null
	# Remove previous container
	@docker container rm flash_initramfs -f | true
	# Remove previous image
	@docker rmi flash_initramfs -f | true

.PHONY: help
help:
	@echo  'Cleaning targets:'
	@echo  '  clean		  - Remove most generated files but keep the sources'
	@echo  '  distclean	  - Remove generated and sources'
	@echo  'Partial targets:'
	@echo  '  docker ARCH=	  - Rebuild container image and instance'
	@echo  '  fs		  - Export filesystem to fs folder'
	@echo  'Other generic targets:'
	@echo  '  all ARCH=	  - Build all targets' 
