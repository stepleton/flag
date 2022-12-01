; Transputer/occam flag simulation -- PC-side CGA display frontend for MS-DOS
;
; Forfeited into the public domain with NO WARRANTY. Read LICENSE for details.
;
; BUILDING: Assemble into a .COM executable file with e.g. nasm:
;    nasm -w+all flagdos.asm -o flagdos.com
; If your B008 board uses an I/O address different to 0150h, be sure to change
; the kB008Base constant below before building.
;
; USAGE: Use the iserver to start the "flagb8h" or "flagsngh" programs on the
; transputer network on your B008 transputer backplane. When they are running
; (i.e. when the iserver exits), start this program. Use the number keys 0
; through 9 on the main keyboard to change the design and colour of the
; flag; use the ESC key to exit. Exiting the frontend will stop the flag
; simulation program running on the transputers.
;
; CHANGING FLAG COLOURS: See notes at DATA below.
;
; "THEORY" OF OPERATION: When the transputer-side "boss" program starts, it
; configures the network and waits for a byte from the PC to kick things off.
; This program sends that byte, then furiously polls the B008 I/O ports to
; pull in CGA video frames byte-by-byte, which it copies to the screen. This 
; poll-and-display step is aggressively unrolled via macros, so a short
; assembly program will yield a fairly big .com file.
;
; While displaying CGA frames, the program monitors the keyboard for the
; number keys and ESC as described above. For number keys, the program first
; sends a byte selecting a flag design to the transputers, which change the
; colours assigned to flag elements accordingly. This program meanwhile
; changes the CGA colour palette as needed. For the ESC key, the program sends
; an 'x' byte to the transputers (a shutdown signal) and then exits.


; {{{***** PREAMBLE *****
    ; This is a .COM file. 16-bit real mode, origin at $100 hex. Classic...
    USE16
    CPU 8086
    ORG 100h
; }}}


; {{{***** CONSTANTS *****
kCgaEvenSeg     equ   0b800h  ; Standard CGA card memory mapping, odd rows
kCgaOddSeg      equ   0ba00h  ; Standard CGA card memory mapping, even rows
kCgaCcrPort     equ   03d9h   ; CGA card colour control register port
kB008Base       equ   0150h   ; Transputer B008 board base address
; }}}


; {{{***** MACROS *****

    ; ByteToX -- Send a byte to the transputer B008 board
    ; Args:
    ;   bl: The byte to send to the B008
    ; Notes:
    ;   Trashes al,dx
%macro    ByteToX 0
    mov   dx,kB008Base+1  ; Load B008 output data register into dx
    mov   al,bl           ; Copy output byte to al
    out   dx,al           ; Send output byte to: the output
    inc   dx              ; Point dx at the B008 output status register...
    inc   dx              ; ...which is two plus the output data register
%%l in    al,dx           ; Copy in the status register
    test  al,1            ; Is bit 0 set?
    jz    %%l             ; No, poll the status register again
%endmacro


    ; XToMemByte -- Copy one byte from the B008 to memory
    ; Args:
    ;   dx: Transputer B008 I/O base address, e.g. 150h
    ;   es,bx: Destination base address and offset
    ; Notes:
    ;   Increments bx
    ;   Trashes al
%macro    XToMemByte 0
    inc   dx              ; Point dx at the B008 input status register...
    inc   dx              ; ...which is two plus the base address
%%l in    al,dx           ; Copy in the status register
    test  al,1            ; Is bit 0 set?
    jz    %%l             ; No, poll the status register again
    dec   dx              ; Yes, point DX back at the input data register...
    dec   dx              ; ...so subtract two
    in    al,dx           ; Copy the data byte from the input data register
    mov   es:bx,al        ; Copy the byte from the B008
    inc   bx              ; Increment the offset
%endmacro


    ; XToMem -- Copy bytes from the B008 to memory
    ; Args:
    ;   1: Number of bytes to copy (unroll this loop how many times?)
    ;   dx: Transputer B008 I/O base address, e.g. 150h
    ;   es,bx: Destination base address and offset
    ; Notes:
    ;   Increments bx with each byte
    ;   Trashes al
%macro    XToMem 1
%rep      %1
    XToMemByte
%endrep
%endmacro


    ; XTo2CgaRows -- Copy two adjacent 80-pixel rows from B008 to memory
    ; Args:
    ;   dx: Transputer B008 I/O base address, e.g. 150h
    ;   bx: CGA base address offset
    ; Notes:
    ;   After calling, bx will be incremented by 80
    ;   This macro uses a lot of code space: nearly 1700 bytes!
    ;   Trashes ax,es
%macro    XTo2CgaRows 0
    mov   ax,kCgaEvenSeg  ; CGA base address for even scanlines...
    mov   es,ax           ; ...goes into the ES segment register
    XToMem  80d           ; Copy in 80 bytes
    sub   bx,80d          ; Rewind bx by 80
    mov   ax,kCgaOddSeg   ; CGA base address for odd scanlines...
    mov   es,ax           ; ...goes into the ES segment register
    XToMem  80d           ; Copy in 80 bytes
%endmacro


    ; XTo2NCgaRows -- Copy 2*N adjacent 80-pixel rows from B008 to memory
    ; Args:
    ;   1: N, the number of row pairs to copy
    ;   dx: Transputer B008 I/O base address, e.g. 150h
    ;   bx: CGA base address offset
    ; Notes:
    ;   After calling, bx will be incremented by N*80
    ;   This macro uses a lot of code space: nearly N*1700 bytes!
    ;   Trashes ax,es
%macro    XTo2NCgaRows 1
%rep      %1
    XTo2CgaRows
%endrep
%endmacro
; }}}


; {{{***** PROGRAM *****

    ; main -- Program entry point
    ; Args:
    ;   not applicable
    ; Notes:
    ;   not applicable
main:
    xor   bl,bl           ; Select the first flag video mode: "trans" palette
.m0 ByteToX               ; Send palette choice to B008; also synchronise start
    call  FlagVideoMode   ; Enter the selected video mode now

    ; Copy a CGA video frame from the transputer B008 board to the CGA.
    mov   dx,kB008Base    ; Load transputer B008 base address into dx
.m1 xor   bx,bx           ; Zero offset from CGA base address
    mov   cx,04h          ; Loop 4 times
.m2 XTo2NCgaRows 25       ; Copy 50 adjacent rows of pixels from the B008
    dec   cx              ; Can't use loop since body is too far away after...
    jnz   .m2             ; ...all of our unrolling

    ; Check for keyboard input; if none, loop to next frame
    mov   ah,01h          ; Ask BIOS if there's a keystroke waiting
    int   16h
    jz    .m1             ; If not, loop to copy a new frame

    ; Keyboard input: get the key, exit or change flag type if needed
    xor   ah,ah           ; Get the key waiting on us.
    int   16h
    cmp   ah,01h          ; Is it esc?
    jz    .mx             ; If so, jump to exit

    cmp   ah,0bh          ; Is it one of the number keys?
    jg    .m1             ; No, ignore: loop to copy a new frame

    jl    .m3             ; Jump ahead unless it's key 0 (0bh)
    mov   ah,1            ; If it is, change scancode to 1
.m3 dec   ah              ; Subtract one: ah is now a value in 0..9
    mov   bl,ah           ; "Blah?" Move value to palette choice argument
    jmp   .m0

    ; Clean up and exit
.mx mov   bl,'x'          ; Tell the transputers to stop...
    ByteToX               ; ...by sending the byte 'x'
    mov   ax,0003h        ; We'd like video mode 3: 80-col colour text
    int   10h             ; Call INT 10h to make it so
    mov   ah,4ch          ; Then, to exit to DOS...
    int   21h             ; ...call INT 21h function 4ch


    ; FlagVideoMode -- Enter 320x200 CGA colour graphics
    ; Args:
    ;   al: Which of the flag video modes below to use?
    ; Notes:
    ;   Trashes ax, bx, dx, es
FlagVideoMode:
    ; Accessing the flag video mode data structure
    shl   bl,1            ; Multiply bl by four for an offset into the...
    shl   bl,1            ; ...kFlagConfig data structures
    xor   bh,bh           ; Extend offset to 16 bits
    add   bx,kFlagModes   ; Now an absolute address

    ; Setting the CGA video mode
    mov   al,1[bx]        ; Copy 5 vs. 4 byte into al
    test  al,al           ; Is the byte zero? (Do we want mode 5?)
    jz    .f1             ; Yes, skip ahead
    xor   al,al           ; No, turn into a bit, starting with 0...
    inc   al              ; ...then incrementing
.f1 add   al,4            ; Add four to get the value 4 or 5 in al: video mode
    xor   ah,ah           ; Clear ah in preparation for...
    int   10h             ; ...setting the video mode with a call to INT 10h

    ; Setting flags in the CGA colour control register
    xor   al,al           ; Clear al --- no options yet
    mov   ah,2[bx]        ; Copy intense colours choice to ah
    test  ah,ah           ; Is it zero?
    jz    .f2             ; Skip ahead
    or    al,10h          ; Wasn't zero, set bit 4: want intense colours
.f2 mov   ah,3[bx]        ; Copy palette choice to ah
    test  ah,ah           ; Is it zero?
    jz    .f3             ; Skip ahead
    or    al,20h          ; Wasn't zero, set bit 5: want cyan/magenta/white
.f3 mov   dx,kCgaCcrPort  ; Address of the colour control register
    out   dx,al           ; Push config to the colour control register

    ; Copy the flags to the BIOS CGA colour control register value mirror
    mov   bx,0040h        ; Set ES segment base address to $40, home of...
    mov   es,bx           ; ...DOS bios variables
    mov   es:066h,al      ; Copy flags to the colour control register mirror

    ret
; }}}


; {{{***** DATA *****

; This frontend program and the flag simulation code running on the transputers
; work together to display different colours and patterns on the flag. If you
; wish to have different patterns to the ones built into the code now, you will
; have to make simultaneous changes in the following data structure and in
; flagflag.occ/flagflag.inc.
;
; This series of records tells the frontend how to set the VGA video mode and
; colour palette for the various flags. CGA colour options are famously
; limited: see https://en.wikipedia.org/wiki/Color_Graphics_Adapter#320%C3%97200
; for the full selection available.
;
; Each record is four bytes long. The flag identifier byte is the same as the
; record's position in the series and isn't used for anything yet. The other
; three bytes are used as labeled in the first record below, kFlagTrans.

kFlagModes:
kFlagTrans:
    db 0    ; 8-bit int: flag identifier
    db 0    ; Boolean: enter mode 5 instead of mode 4?
    db 1    ; Boolean: intense colours instead of dim ones?
    db 1    ; Boolean: cyan/magenta/white instead of red/yellow/green?
kFlagBotswana:
    db 1
    db 0    ; Mode 4
    db 1    ; Intense colours
    db 1    ; Cyan/magenta/white
kFlagEstonia:
    db 2
    db 0    ; Mode 4
    db 1    ; Intense colours
    db 1    ; Cyan/magenta/white
kFlagLuxembourg:
    db 3
    db 1    ; Mode 5
    db 1    ; Intense colours
    db 0    ; Palette choice is irrelevant in mode 5
kFlagBenin:
    db 4
    db 0    ; Mode 4
    db 1    ; Intense colours
    db 0    ; Red/yellow/green
kFlagMali:
    db 5
    db 0    ; Mode 4
    db 1    ; Intense colours
    db 0    ; Red/yellow/green
kFlagFrance:
    db 6
    db 1    ; Mode 5
    db 1    ; Intense colours
    db 0    ; Palette choice is irrelevant in mode 5
kFlagPeru:
    db 7
    db 1    ; Mode 5
    db 1    ; Intense colours
    db 0    ; Palette choice is irrelevant in mode 5
kFlagUk:
    db 8
    db 1    ; Mode 5
    db 1    ; Intense colours
    db 0    ; Palette choice is irrelevant in mode 5
kFlagChequered:
    db 9
    db 0    ; Mode 4
    db 1    ; Intense colours
    db 1    ; Cyan/magenta/white
; }}}
