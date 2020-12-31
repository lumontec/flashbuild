# Main commands


# Some helpers

# Silence stdout
SIL_STDO = 1>/dev/null
# Silence stderr
SIL_STDE = 2>/dev/null
# Ignore command failure
IGNORE_FAIL = || true


.PHONY: help
help:
	@echo
	@echo  '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' 
	@echo  '!!!!  Welcome to FLASHbuild !!!!' 
	@echo  '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' 
	@echo
	@echo  'Single modules have to be compiled independently, there is NO single make all command here at the top level'
	@echo  'you can find several plug and play examples inside the ./projects directory, have fun !'
	@echo  'Project targets:'
	@echo  '  clean		  - Remove most generated files but keep the sources'
	@echo  '  distclean	  - Remove generated and sources'
	@echo  '  wipe		  - Wipe current workspace' 
	@echo  '  save DEST=	  - Saves current workspace state of SOURCES in your DEST path'
	@echo  '  load PROJ=	  - Load saved sources inside current workspace' 
	@echo  '  init		  - Initialize a clean workspace' 
	@echo  'Modules targets:'
	@echo  '  bootloader	  - Access bootloader make commands'
	@echo  '  kernel	  - Access kernel make commands'
	@echo  '  initramfs	  - Access initramfs commands'
	@echo  '  rootfs	  - Access rootfs commands'
	@echo

.PHONY: test_dest
# Check if DEST is set
test_dest: 
ifeq ($(DEST),)
	$(error 'DEST path is not set')
else
	$(info 'will save to DEST=$(DEST)')
endif


.PHONY: test_proj
# Check if PROJ is set
test_proj: 
	@if [ -d "$(PROJ)" ];						\
	then								\
		echo "Found project $(PROJ), start loading";		\
	else								\
		echo "Error: Project PROJ=$(PROJ) does not exists or has not been passed as an argument.";	\
		exit 1;							\
	fi;

# Ask for confirmation
.PHONY: confirm
confirm:
	@echo -n "This will completely wipe your current workspace are you sure? [y/N] " && read ans && [ $${ans:-N} = y ];


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
	@#cp `git ls-files --cached --others --exclude-standard ./1_bootloader` $(DEST)/1_bootloader;
	# kernel 
	@echo 'create 2_kernel directory under DEST=$(DEST)';
	@mkdir -p $(DEST)/2_kernel;
	@echo 'saving 2_kernel sources to DEST=$(DEST)/2_kernel';
	@#cp `git ls-files --cached --others --exclude-standard ./2_kernel` $(DEST)/2_kernel;
	# initramfs 
	@echo 'create 3_initramfs directory under DEST=$(DEST)';
	@mkdir -p $(DEST)/3_initramfs;
	@echo 'saving 3_initramfs sources to DEST=$(DEST)/3_initramfs';
	@#cp `git ls-files --cached --others --exclude-standard ./3_initramfs` $(DEST)/3_initramfs;
	@cp -rn ./3_initramfs/Dockerfile $(DEST)/3_initramfs;
	@cp -rn ./3_initramfs/src $(DEST)/3_initramfs;
	# rootfs 
	@echo 'create 4_rootfs directory under DEST=$(DEST)';
	@mkdir -p $(DEST)/4_rootfs;
	@echo 'saving 4_rootfs sources to DEST=$(DEST)/4_rootfs';
	@#cp `git ls-files --cached --others --exclude-standard ./4_rootfs` $(DEST)/4_rootfs;
	@cp -rn ./4_rootfs/Dockerfile $(DEST)/4_rootfs;
	@cp -rn ./4_rootfs/src $(DEST)/4_rootfs;
	# emulator 
	@echo 'saving emulation scripts under DEST=$(DEST)';
	@cp -rn emulate* $(DEST);

# load 
.PHONY: 
load: test_proj confirm
	# cleaning
	@echo 'cleaning workspace'
	@rm -rf ./1_bootloader ./2_kernel ./3_initramfs ./4_rootfs emulate*
	# loading 
	@echo 'loading project from $(PROJ)'
	@cp -rn $(PROJ)/* .
	# inject template 
	@echo 'injecting Makefiles $(PROJ)'
	@cp -rn ./projects/TEMPLATE/1_bootloader/* ./1_bootloader/ 
	@cp -rn ./projects/TEMPLATE/2_kernel/* ./2_kernel/ 
	@cp -rn ./projects/TEMPLATE/3_initramfs/* ./3_initramfs/ 
	@cp -rn ./projects/TEMPLATE/4_rootfs/* ./4_rootfs/ 

# init 
.PHONY: 
init: confirm
	# cleaning
	@echo 'cleaning workspace'
	@rm -rf ./1_bootloader ./2_kernel ./3_initramfs ./4_rootfs emulate*
	# loading 
	@echo 'loading project from ./projects/TEMPLATE'
	@cp -rn ./projects/TEMPLATE/* .

# wipe 
.PHONY: 
wipe: confirm
	# cleaning
	@echo 'cleaning workspace'
	@rm -rf ./1_bootloader ./2_kernel ./3_initramfs ./4_rootfs emulate*
