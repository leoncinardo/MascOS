# How to write a program for MascOS

> **NOTE**:
> For now this file is a remainder for me on how to create programs. Many features may be buggy or just plainly not work.


## Program structure
If you're program is a .COM executable file it **must** have the `ORG 0x100` directive. If instead it's a .BIN executable then remove that directive.

The general layout of a program is this:
```x86asm
BITS 16
CPU 8086
ORG 0x100

SECTION .text

; We are here when we jump from the kernel
ProgramEntryPoint:
    ; Code....
    ; Your cool code here


    ; Stop the program
    int 0x20


SECTION .data

; Data here

```

## Load and execute a program in memory
It's surprisingly simple, here's how:<br>
you need to call the `LoadProgram` label, and give it the **pointer to the file name**, it can be outside the root directory too, it just needs to point to an 11 byte valid FAT12 file name. After calling the label the kernel will load the program in memory and directly jumps to it.

> Important note: `LoadProgram` WILL RETURN if the operation failed, setting the carry flag. So keep in mind to handle the case it failed to execute your program.

Here's a code example:
```x86asm
SECTION .text

; Loads a program
lea si, ProgramFileName
call LoadProgram

; if we are here it failed the operation(carry flag is set)
cli
hlt

SECTION .data

ProgramFileName: db "SOMENAMEBIN"
```

The location in memory of the program is decided by the os, but like in MS DOS the **actual file is loaded at offset 0x100**, this is why the `org` directive *must* be set to 0x100. Don't use the memory area before that address.

## Exit program
Just use `int 0x20`, nothing more nothing less. It is a **much** cleaner way than doing it the old way, which involed doing a far jump to a specific location in the kernel. This interrupt doesn't expect any input.

Alternatively you can use MS DOS interrupt 0x21 with ah set to 0x4C.

```x86asm
; Exit and go back to shell
mov ah, byte 0x4C
int 0x21
```

## Interrupts
MS DOS interrupt 0x21(int 0x21) is present but the kernel also adds custom interrupts to the IVT(Interrupt Vector Table), so external programs can utilize, for example VGA functions, disk functions provided by the kernel. To see the complete list of interrupts see the [interrupts documentation](InterruptsDocumentation.md).