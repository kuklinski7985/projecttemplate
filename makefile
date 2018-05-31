#/******************************************************************************
#* Copyright (C) 2018 Andrew Kuklinski
#*
#* Redistribution, modification or use of this software in source or binary
#* forms is permitted as long as the files maintain this copyright. This file
#* was created as a personal project to better understand programming.  
#* Andrew Kuklinski is not liable for any misuse of this material.
#*
#*******************************************************************************/
#/**
# * @file makfile
# * @brief makefile to build a medium sized project with file structure
# * 
# * The following makefile was adapated from a tutorail location at the addr:
# *https://latedev.wordpress.com/2014/11/08/generic-makefiles-with-gcc-and-gnu-make/
# * This file will build a project that has the file structure noted below. Nothing
# * in this file should need to be changed when moved to another project except
# * name of the output file location at the variable "PRODUCT".  Please make sure
# * the file structure is as indicataed or this will not work.  
# *
# * @author Andrew Kuklinski
# * @date May 10th, 2018
# * @version 1.0
# *
# *  file stucture :
# *     root folder
# *		inc(folder)
# *		  *.h files
# *		obj(folder)
# *		  *.d and *.o will be created and placed here
# *		src(folder)
# *		  *.c files
# *		makefile
# */

#Set up for the file structure noted above
PRODUCT := main.elf
INCDIR := inc
SRCDIR := src
OBJDIR := obj

#linker and complier options
CC := gcc
DEBUG := -pthread -g -Wall -Werror -O0 #-lrt
LDFLAGS = -lm -Wl,-Map

#indicates the the complier should look in the inc directory for user .h files
INCDIRS := -I$(INCDIR)

#make builds a list of the files that are needed and stores in the listed vars
#fxns wildcard and patsubst (pattern substitution) are used.
# := is a once and done assignment instead of just = which is recursive
#directories are used to keep things organized

SRCFILES := $(wildcard $(SRCDIR)/*.c)
OBJFILES := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SRCFILES)) 
DEPFILES := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.d,$(SRCFILES))


#all of the above will be executed EVERY time make is called. below will only
#be run if called directly or if any file has changed

#default since it is cronologically first
#PRODUCT is dependant on the files in OBJFILES, $^=all prerequ, $@=target files name

$(PRODUCT): $(OBJFILES)
	$(CC) $(DEBUG) $^ -o $@ -lrt
	size $(PRODUCT) $(OBJFILES)

#file with .o suffix is dependant on a file with the same name, different
#suffix and heres how to make it
$(OBJDIR)/%.o: $(SRCDIR)/%.c 
	$(CC) $(DEBUG) $(LDFLAGS) $(INCDIRS) -c $< -o $@ -lrt

#-MM directive goes into the files and generates the prereqs automatically

$(OBJDIR)/%.d: $(SRCDIR)/%.c
	$(CC) $(INCDIRS) -MM $< | sed -e 's%^%$@ %' -e 's% % $(OBJDIR)/%' > $@ -lrt

#pulls in the .d files, much like a #include
#if .d exists then it is simply included, if not make will look for rule
#to make it,  creates, and rereads the whole make file

-include $(DEPFILES)

#phony variable to clean the executable and other created files from their dirs
.PHONY: clean
clean:
	-rm *.elf $(OBJDIR)/*.o $(OBJDIR)/*.d
