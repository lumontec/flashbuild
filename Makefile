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
	@echo  '  wipe		  - Wipe current workspace' 
	@echo  '  save DEST=	  - Saves current workspace state of SOURCES in your DEST path'
	@echo  '  load PROJ=	  - Load saved sources inside current workspace' 
	@echo  '  init		  - Initialize a clean workspace' 
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
	@echo 'create project directory under DEST=$(DEST)';
	@mkdir -p $(DEST);
	@echo 'cleaning previous state for DEST=$(DEST)'
	@rm -rf $(DEST)/*;
	# saving sources
	@echo 'saving sources to DEST=$(DEST)';
	@cp -rn ./workspace $(DEST);
	@cp -rn ./workspace/.gitignore $(DEST)/.gitignore;
	@cp -rn ./workspace/.dockerignore $(DEST)/.dockerignore;
	# emulator 
	@echo 'saving emulation scripts under DEST=$(DEST)';
	@cp -rn emulate* $(DEST);

# load 
.PHONY: 
load: test_proj confirm
	# cleaning
	@echo 'cleaning workspace'
	@rm -rf ./workspace
	# loading 
	@echo 'loading project from $(PROJ)'
	@cp -rn $(PROJ) ./workspace
	# inject template 
	@echo 'injecting Makefile $(PROJ)'
	@cp -rn ./flash/template/Makefile ./workspace/Makefile

# init 
.PHONY: 
init: confirm
	# cleaning
	@echo 'cleaning workspace'
	@rm -rf ./workspace;
	# loading 
	@echo 'loading project from ./template'
	@cp -rn ./template ./workspace

# wipe 
.PHONY: 
wipe: confirm
	# cleaning
	@echo 'cleaning workspace'
	@rm -rf ./workspace
