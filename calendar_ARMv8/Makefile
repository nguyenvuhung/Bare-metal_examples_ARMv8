# Calendar Example Makefile
#
# Copyright (C) ARM Limited, 2009-2016. All rights reserved.
#
# This makefile is intended for use with GNU make
# This example is intended to be built with ARM Compiler 6

TARGET=calendar_ARMv8.axf


CC=armclang
LD=armlink

# Select build rules based on Windows or Unix
ifdef WINDIR
DONE=@if exist $(1) echo Build completed.
RM=if exist $(1) del /q $(1)
SHELL=$(WINDIR)\system32\cmd.exe
else
ifdef windir
DONE=@if exist $(1) echo Build completed.
RM=if exist $(1) del /q $(1)
SHELL=$(windir)\system32\cmd.exe
else
DONE=@if [ -f $(1) ]; then echo Build completed.; fi
RM=rm -f $(1)
endif
endif

all: $(TARGET)
	$(call DONE,$(TARGET))
	
rebuild: clean all

clean:
	$(call RM,*.o)
	$(call RM,$(TARGET))

calendar.o: calendar.c
# Compile for best debug view (lowest optimization)
	$(CC) -c --target=aarch64-arm-none-eabi -mfpu=none -g -O0 $^ -o $@

$(TARGET): calendar.o
# Link with specific base address to suit Foundation Model memory layout
	$(LD) --ro-base=0x80000000 $^ -o $@
