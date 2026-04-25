
BITS 16
CPU 8086
ORG 0x100

; ! DRUM ROOL.........
; * This is a hello world program for MascOS
; * Take it as an example to learn how to interact with the os interrupts

SECTION .text

; Print "Hello world!"
mov ah, byte 0x9
lea dx, string
int 0x21

; Exit program
int 0x20

SECTION .data

string: db "Hello world!", 0