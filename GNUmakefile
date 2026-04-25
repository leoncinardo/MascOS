
# Clear suffix list
.SUFFIXES:

SHELL = /bin/sh
override OUTPUT := MascOS.flp
override BUILDDIR := Build

BootloaderFlags := -IBootloader/
KernelFlags := -IKernel/

# override NASMFILES := $(shell find -L Bootloader Kernel -type f -name "Bootloader.asm" -o -name "Kernel.asm" 2>/dev/null | sed "s|^\./||" | LC_ALL=C sort -u)
# override OBJ := $(addprefix .o, $(NASMFILES))
override OSFILES := $(shell find -L Files -type f 2>/dev/null | sed "s|^\./||" | LC_ALL=C sort -u)
override PROGRAMS := $(shell find -L Programs -type f -name "*.asm" 2>/dev/null | sed "s|^\./||" | LC_ALL=C sort -u)
override PROGRAMSOBJ := $(patsubst %.asm, %.com, $(subst Programs, $(BUILDDIR), $(PROGRAMS)))


.PHONY: all createBuildDir checkUser run debug clean distclean


# $(BUILDDIR)/%.asm.o: %.asm GNUmakefile 
# 	nasm -f bin $< -o $@

# Rules to compile stuff inside Programs/
$(BUILDDIR)/%.com: Programs/%.asm GNUmakefile
	nasm -f bin $< -o $@


all: checkUser $(PROGRAMSOBJ)
	mkdir -p $(BUILDDIR)
	test -f $(OUTPUT) || mkdosfs -C $(OUTPUT) 1440

	@echo -e "\n\e[0;32m==> Compiling bootloader and kernel...\e[0m"
	nasm -f bin $(BootloaderFlags) Bootloader/Bootloader.asm -o $(BUILDDIR)/Boot.bin
	nasm -f bin $(KernelFlags) Kernel/Kernel.asm -o $(BUILDDIR)/Kernel.bin

	@echo -e "\n\e[0;32m==> Creating image...\e[0m"
	rm -rf $(OUTPUT)
	dd if=/dev/zero of=$(OUTPUT) bs=512 count=2880 status=none
	mkfs.vfat -F 12 -S 512 $(OUTPUT)

	mkdir -p /mnt/floppy
	sudo mount -o loop $(OUTPUT) /mnt/floppy -t msdos -o "fat=12"

	cp $(BUILDDIR)/Kernel.bin /mnt/floppy
	cp $(OSFILES) $(PROGRAMSOBJ) /mnt/floppy

	sudo umount /mnt/floppy

	dd if=$(BUILDDIR)/Boot.bin of=$(OUTPUT) conv=notrunc status=none bs=512 count=1

	sudo chmod -R a=rwx $(BUILDDIR) $(OUTPUT)
	

# Checks if the user has permissions to mount an image
checkUser:
	@if ! [ "$(shell id -u)" = 0 ]; then \
		echo -e "\e[0;31mYou need administrator permissions to mount the image\n\e[0mAdd \"sudo\" before your command\n"; \
		exit 1; \
	fi


run:
	qemu-system-i386 -fda $(OUTPUT) -M smm=off -no-shutdown -no-reboot \
	-cpu 486 -rtc base=localtime,clock=host \
	-audiodev pa,id=snd0,server=/run/user/1000/pulse/native -machine pcspk-audiodev=snd0


debug:
	qemu-system-i386 -fda $(OUTPUT) -M smm=off -no-shutdown -no-reboot -d int -monitor stdio -D ./QemuLog.log \
    -cpu 486 -rtc base=localtime,clock=host \
    -audiodev pa,id=snd0,server=/run/user/1000/pulse/native -machine pcspk-audiodev=snd0


clean:
	rm -rf $(BUILDDIR)/*


distclean: clean
	rm -f $(OUTPUT)