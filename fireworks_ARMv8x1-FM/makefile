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

APP ?= fireworks_ARMv8x1-FM.axf
QUIET ?= @
OPT_LEVEL ?= 1
PLATFORM ?= AEM
OUTPUTCHAN ?= UART

# Other switches the user should not normally need to change:
TARGET = aarch64-arm-none-eabi
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
SRC_DIR = src
ASM_DIR = asm
OBJ_DIR = obj

INCLUDES = -I$(SRC_DIR)

ifeq ($(OS),Windows_NT)
RM_FILE = if exist $(1) del /q $(1)
RM_DIR = if exist $(1) rmdir /s /q $(1)
MK_DIR = mkdir
else
RM_FILE = /bin/rm -f $(1)
RM_DIR = /bin/rm -rf $(1)
MK_DIR = /bin/mkdir
endif

DEPEND_FLAGS = -MD -MF $@.d
CFLAGS = --target=$(TARGET) $(DEBUG_FLAGS) -O$(OPT_LEVEL) $(DEFINES) $(INCLUDES) $(DEPEND_FLAGS) $(SUPPRESS) ${CFEXTRA}
AFLAGS = --target=$(TARGET) $(DEBUG_FLAGS) -x assembler-with-cpp $(SUPPRESS) ${AFEXTRA}
LFLAGS = --scatter=scatter.scat --entry=start64

APP_C_SRC := $(wildcard $(SRC_DIR)/*.c)
APP_S_SRC := $(wildcard $(ASM_DIR)/*.s)
OBJ_FILES := $(APP_C_SRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o) \
             $(APP_S_SRC:$(ASM_DIR)/%.s=$(OBJ_DIR)/%.o)
VPATH = $(SRC_DIR):$(ASM_DIR)
DEP_FILES := $(OBJ_FILES:%=%.d)

.phony: all rebuild clean

all: $(APP)

rebuild:	clean all

$(APP): $(OBJ_DIR) $(OBJ_FILES) scatter.scat
	@echo Linking $@
	$(QUIET) $(LINK) $(LFLAGS) --output $@ $(OBJ_FILES)
	@echo Done.

clean:
	- $(call RM_DIR,$(OBJ_DIR))
	- $(call RM_FILE,$(APP))

depend:		clean ${OBJ_FILES}

$(OBJ_DIR):
	$(MK_DIR) $@

$(OBJ_DIR)/%.o : %.c
	$(PROGRESS)
	$(QUIET) $(CC) -c $(CFLAGS) -o $@ $<

$(OBJ_DIR)/%.o : %.s
	$(PROGRESS)
	$(QUIET) $(CC) -c $(AFLAGS) -o $@ $<

-include $(DEP_FILES)

help:
	@echo make [OPTIONS]
	@echo 'PLATFORM=   [AEM/CORTEXA]       Choose VE FVP target: AEMv8 or Cortex-A53/A57/A72'
	@echo 'OUTPUTCHAN= [UART/SEMIHOSTED]   Select semihosted or PL011 UART for output'
	@echo ''
	@echo 'NOTE: The first value in the options indicates the default setting.'
