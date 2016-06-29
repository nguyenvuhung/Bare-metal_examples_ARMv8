# Copyright (C) ARM Limited, 2014-2016. All rights reserved.
#
# This example is intended to be built with ARM Compiler 6
#
# Environment variables for build options that the user might wish to change
#
# Variable     Example Value
# ----------   -------------
# APP          myapp.axf
# QUIET        @ for terse output, or leave blank for detailed output
# OPT_LEVEL    0, 1, 2 or 3
# DEFINES      -D MYDEFINE
# SUPPRESS     --diag_suppress=1234
# PLATFORM     CORTEXA (adds extra code for initialising Cortex-A53/A57/A72), or AEM
# OUTPUTCHAN   UART (a terminal will open in the model), or SEMIHOSTED

AARCH64_STARTUP ?= AArch64_startup.axf
AARCH32_APP ?= AArch32_app.axf
QUIET ?= @
OPT_LEVEL ?= 1
PLATFORM ?= AEM
OUTPUTCHAN ?= SEMIHOSTED

# Other switches the user should not normally need to change:
DEBUG_FLAGS = -g


ifeq "$(PLATFORM)" "CORTEXA"
	AFEXTRA += -D CORTEXA
endif

ifeq "$(OUTPUTCHAN)" "UART"
	CFEXTRA	+= -D USE_SERIAL_PORT -D STANDALONE
endif


ifeq ($(QUIET),@)
PROGRESS = @echo Compiling $<...
endif


CC = armclang
AS = armclang
LINK = armlink
APP_DIR = app_32_src
STARTUP_DIR = startup_64_src
APP_OBJ_DIR = app_32_obj
STARTUP_OBJ_DIR = startup_64_obj

INCLUDES = -I$(APP_DIR)

ifeq ($(OS),Windows_NT)
RM_FILE = if exist $(1) del /q $(1)
RM_DIR = if exist $(1) rmdir /s /q $(1)
MK_DIR = mkdir
else
RM_FILE = /bin/rm -f $(1)
RM_DIR = /bin/rm -rf $(1)
MK_DIR = /bin/mkdir
endif

CFLAGS = $(DEBUG_FLAGS) -O$(OPT_LEVEL) $(DEFINES) $(INCLUDES) $(SUPPRESS) ${CFEXTRA}
AFLAGS = $(DEBUG_FLAGS) -x assembler-with-cpp $(SUPPRESS) ${AFEXTRA}
LFLAGS =

APP_C_SRC := $(wildcard $(APP_DIR)/*.c)
APP_S_SRC := $(wildcard $(APP_DIR)/*.s)
STARTUP_C_SRC := $(wildcard $(STARTUP_DIR)/*.c)
STARTUP_S_SRC := $(wildcard $(STARTUP_DIR)/*.s)
APP_OBJS := $(APP_C_SRC:$(APP_DIR)/%.c=$(APP_OBJ_DIR)/%.o) \
             $(APP_S_SRC:$(APP_DIR)/%.s=$(APP_OBJ_DIR)/%.o)
STARTUP_OBJS := $(STARTUP_C_SRC:$(STARTUP_DIR)/%.c=$(STARTUP_OBJ_DIR)/%.o) \
             $(STARTUP_S_SRC:$(STARTUP_DIR)/%.s=$(STARTUP_OBJ_DIR)/%.o)


.phony: all rebuild clean

all: $(AARCH32_APP) $(AARCH64_STARTUP)

rebuild:	clean all

$(AARCH64_STARTUP): $(STARTUP_OBJ_DIR) $(STARTUP_OBJS) scatter64.scat
	@echo Linking $@
	$(QUIET) $(LINK) --scatter=scatter64.scat --entry=start64 --output $@ $(STARTUP_OBJS) symdefs.txt
	@echo Done.

$(AARCH32_APP) : $(APP_OBJ_DIR) $(APP_OBJS) scatter32.scat
	@echo Linking $@
	$(QUIET) $(LINK) --scatter=scatter32.scat --output $@ $(APP_OBJS) --symdefs=symdefs.txt
	@echo Done.

clean:
	- $(call RM_DIR,$(STARTUP_OBJ_DIR))
	- $(call RM_DIR,$(APP_OBJ_DIR))
	- $(call RM_FILE,$(AARCH64_STARTUP))
	- $(call RM_FILE,$(AARCH32_APP))
	- $(call RM_FILE,symdefs.txt)

$(APP_OBJ_DIR):
	$(MK_DIR) $@

$(APP_OBJ_DIR)/%.o : $(APP_DIR)/%.c
	$(PROGRESS)
	$(QUIET) $(CC) -c --target=armv8a-arm-none-eabi $(CFLAGS) -o $@ $<

$(APP_OBJ_DIR)/%.o : $(APP_DIR)/%.s
	$(PROGRESS)
	$(QUIET) $(CC) -c --target=armv8a-arm-none-eabi $(AFLAGS) -o $@ $<

$(STARTUP_OBJ_DIR):
	$(MK_DIR) $@

$(STARTUP_OBJ_DIR)/%.o : $(STARTUP_DIR)/%.c
	$(PROGRESS)
	$(QUIET) $(CC) -c --target=aarch64-arm-none-eabi $(CFLAGS) -o $@ $<

$(STARTUP_OBJ_DIR)/%.o : $(STARTUP_DIR)/%.s
	$(PROGRESS)
	$(QUIET) $(CC) -c --target=aarch64-arm-none-eabi $(AFLAGS) -o $@ $<

-include $(DEP_FILES)

help:
	@echo make [OPTIONS]
	@echo 'PLATFORM=   [AEM/CORTEXA]       Choose VE FVP target: AEMv8 or Cortex-A53/A57/A72'
	@echo ''
	@echo 'NOTE: The first value in the options indicates the default setting.'
