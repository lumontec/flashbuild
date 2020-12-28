# Generate initramfs cpio archive

initramfs: fs archive

# Generate cpio archive
.PHONY: archive
archive:
	# Generate initramfs as cpio archive
	@cd ./fs && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

# Generate filesystem from container
.PHONY: fs
fs:
	# Build the docker image
	@docker build -t flash_initramfs .
	# Create the container if not exists
	@docker create --name flash_initramfs flash_initramfs
	# Extract archive inside fs directory
	@mkdir -p ./fs
	# Copy docker filesystem in fs folder
	@docker cp flash_initramfs:/fs/ .

# Clean build files	
.PHONY: clean
clean:
	# Clean dirty folders
	@rm -rf ./fs ./flash_initramfs.tar ./initramfs.cpio.gz
	# Remove previous container
	@docker container rm flash_initramfs -f | true
	# Remove previous image
	@docker rmi flash_initramfs -f | true
