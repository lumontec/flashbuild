# Generate initramfs cpio archive



initramfs: fs
	# Generate initramfs as cpio archive
	@cd ./build/fs && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

.PHONY: fs
fs:
	# Build the docker image
	@docker build -t flash_initramfs ./build
	# Create the container if not exists
	@docker start flash_initramfs 2> /dev/null || docker run --name flash_initramfs flash_initramfs
	# Compress docker fs as archive
	@docker export flash_initramfs > ./build/flash_initramfs.tar
	# Extract archive inside fs directory
	@mkdir -p ./build/fs
	@tar -xvf ./build/flash_initramfs.tar -C ./build/fs
	# Remove noisy docker leftover folders
	@rm -rf ./build/fs/dev
	# Install init script
	@cp ./build/init ./build/fs

	
.PHONY: clean
clean:
	# Clean dirty folders
	@rm -rf ./build/fs ./build/flash_initramfs.tar ./build/initramfs.cpio.gz
	# Remove previous container
	@docker container rm flash_initramfs | true
	# Remove previous image
	@docker rmi flash_initramfs | true


