; -------------------------------------------
; "Spy VS Spy II - The Island Caper" Amiga.
; Disassembled by Franck "hitchhikr" Charlet.
; -------------------------------------------

                    mc68000
                    opt      o+
                    opt      all+

; -------------------------------------------

_LVOAllocMem        equ      -198
_LVOOpenLibrary     equ      -552

_LVOOpen            equ      -30
_LVOClose           equ      -36
_LVORead            equ      -42

; -------------------------------------------

                    section  spyvspy2,code_c

START_CODE:         bra      START

COPPER_LIST:
PLANES:             dc.w     $E2,0,$E0,0
                    dc.w     $E6,0,$E4,0
                    dc.w     $EA,0,$E8,0
                    dc.w     $EE,0,$EC,0
COPPER_SPRITE:      dc.w     $120,0,$122,0,$124,0,$126,0,$128,0,$12A,0,$12C,0,$12E,0
                    dc.w     $130,0,$132,0,$134,0,$136,0,$138,0,$13A,0,$13C,0,$13E,0
                    dc.w     $192
TOP_GREEN:          dc.w     $7B3
                    dc.w     $7D01,$FFFE,$192,$7B3
                    dc.w     $FFFF,$FFFE
END_COPPER_LIST:
DUMMY_SPRITE:       dcb.w    2,0

WAIT_FOR_RASTER:    move.l   d1,d2
                    add.w    #$B00,d2
.WAIT:              move.l   $DFF004,d0
                    and.l    #$1FFFF,d0
                    cmp.l    d1,d0
                    bls.b    .WAIT
                    cmp.l    d2,d0
                    bhi.b    .WAIT
                    rts

ATARI_COPY:         move.w   #((200*40)/2)-1,d0
.COPY:              move.w   (a0)+,(a1)+
                    move.w   (a0)+,(200*40)-2(a1)
                    move.w   (a0)+,(200*2*40)-2(a1)
                    move.w   (a0)+,(200*3*40)-2(a1)
                    dbra     d0,.COPY
                    rts

COLOUR_COPY:        lea      $DFF180,a1
                    move.w   #16-1,d0
.COPY:              move.w   (a0)+,d1
                    add.w    d1,d1
                    move.w   d1,(a1)+
                    dbra     d0,.COPY
                    rts

LOAD_FILE:          move.l   d2,-(sp)
                    move.l   d1,-(sp)
                    move.l   4.w,a6
                    moveq    #0,d0
                    lea      DOSNAME,a1
                    jsr      _LVOOpenLibrary(a6)
                    move.l   d0,DOS_BASE
                    move.l   d0,a6
                    move.l   (sp)+,d1
                    move.l   #$3ED,d2
                    jsr      _LVOOpen(a6)
                    move.l   d0,DOS_HANDLE
                    move.l   d0,d1
                    move.l   (sp)+,d2
                    move.l   #32128,d3
                    jsr      _LVORead(a6)
                    move.l   DOS_HANDLE,d1
                    jmp      _LVOClose(a6)

SETUP_SCREEN:       move.l   ONESCREEN,SCREEN1
                    move.l   TWOSCREEN,SCREEN2
                    lea      $DFF000,a6
                    move.w   #$3FF,$96(a6)
                    move.l   SCREEN2,d1
                    bsr      WHICH_PLANES
                    move.w   #8-1,d0
                    lea      COPPER_SPRITE+2,a0
                    move.l   #DUMMY_SPRITE,d1
.SET_SPRS:          swap     d1
                    move.w   d1,(a0)
                    addq.w   #4,a0
                    swap     d1
                    move.w   d1,(a0)
                    addq.w   #4,a0
                    dbra     d0,.SET_SPRS
                    move.w   #((END_COPPER_LIST-COPPER_LIST)/2)-1,d0
                    lea      COPPER_LIST,a0
                    lea      COPPER_LIST2,a1
.COPY:              move.w   (a0)+,(a1)+
                    dbra     d0,.COPY
                    move.l   SCREEN1,d1
                    bsr      WHICH_PLANES
                    move.l   #COPPER_LIST,COPPER1
                    move.l   #COPPER_LIST2,COPPER2
                    move.l   #COPPER_LIST,$80(a6)
                    move.l   #$2C81F4C1,$8E(a6)
                    move.l   #$3800D0,$92(a6)
                    clr.w    $108(a6)
                    clr.w    $10A(a6)
                    clr.w    $102(a6)
                    clr.w    $106(a6)
                    clr.w    $1FC(a6)
                    move.w   #$4200,$100(a6)
                    move.w   #4,$104(a6)
                    clr.w    $88(a6)
                    move.w   #$83FF,$96(a6)
                    rts

WHICH_PLANES:       move.w   #4-1,d0
                    lea      PLANES,a0
.SET_BPS:           move.w   d1,2(a0)
                    swap     d1
                    move.w   d1,6(a0)
                    swap     d1
                    add.l    #(200*40),d1
                    addq.w   #8,a0
                    dbra     d0,.SET_BPS
                    rts

BLIT:               bsr.b    WAIT_BLIT
                    move.l   d0,$DFF060
                    move.l   d1,$DFF064
                    move.l   d2,$DFF040
                    move.l   #-1,$DFF044
                    move.l   a0,$DFF050
                    move.l   a1,$DFF04C
                    move.l   a2,$DFF048
                    move.l   a3,$DFF054
                    move.w   d3,$DFF058
                    rts

WAIT_BLIT:          btst     #6,$DFF002
                    bne.b    WAIT_BLIT
                    rts

SWAP_SCREEN:        movem.l  d0/d1,-(sp)
                    bsr.b    WAIT_BLIT
                    move.l   SCREEN1,d0
                    move.l   SCREEN2,SCREEN1
                    move.l   d0,SCREEN2
                    move.l   COPPER1,d0
                    move.l   COPPER2,COPPER1
                    move.l   d0,COPPER2
                    move.l   COPPER1,$DFF080
                    move.w   #1,INT_REQ
.WAIT_INT:          tst.w    INT_REQ
                    bne.b    .WAIT_INT
                    movem.l  (sp)+,d0/d1
                    rts

CLEAR_SCREEN:       move.w   #((200*40)/4)-1,d0
.CLEAR:             clr.l    (a0)+
                    clr.l    (a0)+
                    clr.l    (a0)+
                    clr.l    (a0)+
                    dbra     d0,.CLEAR
                    rts

MYINT2:             movem.l  d0-d2/a0,-(sp)
                    bsr.b    ADD_MATRIX
                    bset     #6,$BFEE01
                    move.b   #0,$BFEC01
                    move.w   #81-1,d0
.WAIT:              dbra     d0,.WAIT
                    bclr     #6,$BFEE01
                    tst.b    $BFED01
                    movem.l  (sp)+,d0-d2/a0
                    move.w   #8,$DFF09C
                    rte

ADD_MATRIX:         move.b   $BFEC01,d0
                    ror.b    #1,d0
                    move.b   d0,d1
                    lea      KB_MATRIX,a0
                    and.w    #$7F,d0
                    eor.w    #$7F,d0
                    move.w   d0,d2
                    and.w    #7,d2
                    lsr.w    #3,d0
                    tst.b    d1
                    bmi.b    DOWN_STROKE
UP_STROKE:          bset     d2,0(a0,d0.w)
                    rts

DOWN_STROKE:        bclr     d2,0(a0,d0.w)
                    rts

INIT_KEY:           moveq    #-1,d0
                    lea      KB_MATRIX,a0
                    move.l   d0,(a0)+
                    move.l   d0,(a0)+
                    move.l   d0,(a0)+
                    move.l   d0,(a0)+
                    rts

INKEY:              movem.l  d2/a0,-(sp)
                    move.w   d0,d2
                    and.w    #7,d2
                    lsr.w    #3,d0
                    lea      KB_MATRIX,a0
                    btst     d2,0(a0,d0.w)
                    bne      .NOT_PRESSED
                    moveq    #-1,d0
                    bra      .PRESSED

.NOT_PRESSED:       moveq    #0,d0
.PRESSED:           movem.l  (sp)+,d2/a0
                    rts

SCAN_JOY:           movem.l  d0/d1,-(sp)
                    move.w   $DFF00A,d0
                    move.w   d0,d1
                    and.w    #$202,d0
                    move.w   d0,LEFT0
                    lsr.w    #1,d0
                    eor.w    d0,d1
                    and.w    #$101,d1
                    move.w   d1,UP0
                    move.w   $DFF00C,d0
                    move.w   d0,d1
                    and.w    #$202,d0
                    move.w   d0,LEFT1
                    lsr.w    #1,d0
                    eor.w    d0,d1
                    and.w    #$101,d1
                    move.w   d1,UP1
                    clr.w    FIRE0
                    moveq    #0,d0
                    move.b   $BFE001,d0
                    btst     #6,d0
                    bne      .MOUSE_LBUTTON
                    move.w   #-1,FIRE0
.MOUSE_LBUTTON:     clr.w    FIRE1
                    btst     #7,d0
                    bne      .JOY_BUTTON1
                    move.w   #-1,FIRE1
.JOY_BUTTON1:       move.w   #$4C,d0
                    bsr      INKEY
                    move.b   d0,KUP1
                    move.w   #$4D,d0
                    bsr      INKEY
                    move.b   d0,KDOWN1
                    move.w   #$4F,d0
                    bsr      INKEY
                    move.b   d0,KLEFT1
                    move.w   #$4E,d0
                    bsr      INKEY
                    move.b   d0,KRIGHT1
                    movem.l  (sp)+,d0/d1
                    rts

KB_MATRIX:          dcb.l    4,-1
LEFT0:              dc.b     -1
RIGHT0:             dc.b     -1
UP0:                dc.b     0
DOWN0:              dc.b     1
FIRE0:              dc.w     0
LEFT1:              dc.b     -1
RIGHT1:             dc.b     -1
UP1:                dc.b     -1
DOWN1:              dc.b     -1
FIRE1:              dc.w     0

HANDLE_MOUSE:       movem.l  d0-d2/a0,-(sp)
                    move.w   $DFF00A,d0
                    lea      LAST_MOUSE0,a0
                    bsr.b    DO_MOUSE
                    move.w   $DFF00C,d0
                    lea      LAST_MOUSE1,a0
                    bsr.b    DO_MOUSE
                    clr.w    MFIRE0
                    move.w   $DFF016,d0
                    btst     #10,d0
                    bne.b    .MOUSE_RBUTTON
                    move.w   #-1,MFIRE0
.MOUSE_RBUTTON:     clr.w    MFIRE1
                    btst     #14,d0
                    bne.b    .JOY_BUTTON2
                    move.w   #-1,MFIRE1
.JOY_BUTTON2:       movem.l  (sp)+,d0-d2/a0
                    rts

DO_MOUSE:           move.l   2(a0),d1
                    beq.b    CHECK_MOUSE
                    tst.b    d1
                    beq.b    .NO_VAL1
                    subq.b   #1,d1
.NO_VAL1:           rol.l    #8,d1
                    tst.b    d1
                    beq.b    .NO_VAL2
                    subq.b   #1,d1
.NO_VAL2:           rol.l    #8,d1
                    tst.b    d1
                    beq.b    .NO_VAL3
                    subq.b   #1,d1
.NO_VAL3:           rol.l    #8,d1
                    tst.b    d1
                    beq.b    .NO_VAL4
                    subq.b   #1,d1
.NO_VAL4:           rol.l    #8,d1
                    move.l   d1,2(a0)
CHECK_MOUSE:        move.w   d0,d2
                    sub.b    1(a0),d0
                    beq.b    DOM_UD
                    bpl.b    DOM_RIGHT
                    neg.b    d0
                    cmp.b    #1,d0
                    bls.b    DOM_UD
                    move.b   #20,2(a0)
                    bra.b    DOM_UD

DOM_RIGHT:          cmp.b    #1,d0
                    bls.b    DOM_UD
                    move.b   #20,3(a0)
DOM_UD:             move.w   d2,d0
                    lsr.w    #8,d0
                    sub.b    (a0),d0
                    beq.b    DOM_RET
                    bpl.b    DOM_DOWN
                    neg.b    d0
                    cmp.b    #1,d0
                    bls.b    DOM_RET
                    move.b   #20,4(a0)
                    bra.b    DOM_RET

DOM_DOWN:           cmp.b    #1,d0
                    bls.b    DOM_RET
                    move.b   #20,5(a0)
DOM_RET:            move.w   d2,(a0)
                    rts

LAST_MOUSE0:        dc.w     0
MLEFT0:             dc.b     0
MRIGHT0:            dc.b     0
MUP0:               dc.b     0
MDOWN0:             dc.b     0
MFIRE0:             dc.w     0
LAST_MOUSE1:        dc.w     0
MLEFT1:             dc.b     0
MRIGHT1:            dc.b     0
MUP1:               dc.b     0
MDOWN1:             dc.b     0
MFIRE1:             dc.w     0
KLEFT1:             dc.b     0
KRIGHT1:            dc.b     0
KUP1:               dc.b     0
KDOWN1:             dc.b     0

ALLOCATE_MEMORY:    move.w   #$100,d7
                    move.w   #$700,d6
                    bsr.b    FIND32K
                    bsr.b    CLEARD0
                    move.l   d0,ONESCREEN
                    move.w   #$10,d7
                    move.w   #$70,d6
                    bsr.b    FIND32K
                    bsr.b    CLEARD0
                    move.w   #1,d7
                    move.w   #7,d6
                    move.l   d0,TWOSCREEN
                    bsr.b    FIND32K
                    move.l   d0,BACK
                    rts

CLEARD0:            move.l   d0,a0
                    move.w   #(200*40)-1,d1
                    ; *4 bitplanes
.CLEAR:             clr.l    (a0)+
                    dbra     d1,.CLEAR
                    rts

FIND32K:            move.l   4.w,a6
                    move.l   #32768,d0
                    moveq    #2,d1
                    jsr      _LVOAllocMem(a6)
                    tst.l    d0
                    beq.b    WHOS_REMOVED_THE_RAM_CHIPS
                    rts

WHOS_REMOVED_THE_RAM_CHIPS:
                    move.w   d7,$DFF180
                    move.w   d6,$DFF180
                    bra.b    WHOS_REMOVED_THE_RAM_CHIPS

DECO_PIC:           move.l   d2,-(sp)
                    move.l   BACK,d2
                    bsr.w    LOAD_FILE
                    move.l   (sp)+,a1
DECO:               move.l   BACK,a0
                    addq.w   #2,a0
                    addq.w   #4,a1
                    move.w   #16-1,d0
DECO_PAL:           move.w   (a0)+,(a1)+
                    dbra     d0,DECO_PAL
                    lea      92(a1),a1
                    move.w   #4-1,d0
DECO_THREE:         move.l   a1,a2
                    move.w   #(200*40),d1
                    clr.w    FLAG
DECO_LOOP:          move.b   (a0)+,d2
                    cmp.b    #$CD,d2
                    bne.b    DECO_ORD
                    move.b   (a0)+,d2
                    bne.b    NOT_CD_DECO
                    move.b   #$CD,d2
                    bra.b    DECO_ORD

NOT_CD_DECO:        bra.b    DECO_REP

DECO_ORD:           move.b   d2,(a1)
                    tst.w    FLAG
                    bne      ADD_LOTS
                    addq.w   #1,FLAG
                    addq.w   #1,a1
                    subq.w   #1,d1
                    beq      DONE_DECO
                    bra.b    DECO_LOOP

ADD_LOTS:           clr.w    FLAG
                    addq.w   #7,a1
                    subq.w   #1,d1
                    beq      DONE_DECO
                    bra.b    DECO_LOOP

DECO_REP:           move.w   d2,d3
                    and.w    #$7F,d3
                    tst.b    d2
                    bmi.b    USE_FF
                    clr.w    d2
                    bra      DECO_LOTS

USE_FF:             move.w   #-1,d2
DECO_LOTS:          move.b   d2,(a1)
                    tst.w    FLAG
                    bne.b    ADD_LOTS2
                    addq.w   #1,FLAG
                    addq.w   #1,a1
                    subq.w   #1,d1
                    beq.b    DONE_DECO
                    subq.b   #1,d3
                    bne.b    DECO_LOTS
                    bra.b    DECO_LOOP

ADD_LOTS2:          clr.w    FLAG
                    addq.w   #7,a1
                    subq.w   #1,d1
                    beq.b    DONE_DECO
                    subq.b   #1,d3
                    bne.b    DECO_LOTS
                    bra.w    DECO_LOOP

DONE_DECO:          lea      2(a2),a1
                    dbra     d0,DECO_THREE
                    rts

FLAG:               dc.w     0
DOSNAME:            dc.b     "dos.library",0
                    even
DOS_BASE:           dc.l     0
DOS_HANDLE:         dc.l     0
ONESCREEN:          dc.l     0
TWOSCREEN:          dc.l     0
LOADSCREEN:         dc.l     0
SCREEN2:            dc.l     0
SCREEN1:            dc.l     0
COPPER1:            dc.l     0
COPPER2:            dc.l     0
COPPER_LIST2:       dcb.b    (END_COPPER_LIST-COPPER_LIST),0

FREQS:              dc.w     404,381,359,339,320,302,285,269,254,240,226,213
ENVELOPE1:          dc.w     1,50,0,25,-2,0,-1
ENVELOPE2:          dc.w     1,30,0,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,-1
ENVELOPE3:          dc.w     1,30,0,15,-2,1,-1
DUMMY:              dc.w     -1
TRIANGLE32:         dc.b     -128,-112,-96,80,-64,-48,-32,-16,0,16,32,48,64
                    dc.b     80,96,112,127,112,96,80,64,48,32,16,0,-16
                    dc.b     -32,-48,-64,-80,-96,-112
WAVEFORM128:        dc.b     0,6,13,19,25,31,37,43,49,55,60,66,71
                    dc.b     76,81,86,91,95,99,103,106,110,113,116,118
                    dc.b     121,122,124,126,127,127,127,127,127,127,127,126
                    dc.b     124,122,121,118,116,113,110,106,103,99,95,91
                    dc.b     86,81,76,71,66,60,55,49,43,37,31,25
                    dc.b     19,13,6,0,-6,-13,-19,-25,-31,-37,-43,-49,-55
                    dc.b     -60,-66,-71,-76,-81,-86,-91,-95,-99,-103,-106,-110
                    dc.b     -113,-116,-118,-121,-122,-124,-126,-127,-127,-128,-128,-128
                    dc.b     -127,-127,-126,-124,-122,-121,-118,-116,-113,-110,-106,-103
                    dc.b     -99,-95,-91,-86,-81,-76,-71,-66,-60,-55,-49,-43
                    dc.b     -37,-31,-25,-19,-13,-6
WAVEFORM64:         dc.b     0,13,25,37,49,60,71,81,91,99,106,113,118
                    dc.b     122,126,127,127,127,126,122,118,113,106,99,91
                    dc.b     81,71,60,49,37,25,13,0,-13,-25,-37,-49,-60
                    dc.b     -71,-81,-91,-99,-106,-113,-118,-122,-126,-127,-128,-127
                    dc.b     -126,-122,-118,-113,-106,-99,-91,-81,-71,-60,-49,-37,-25,-13
WAVEFORM32:         dc.b     0,25,49,71,91,106,118,126,127,126,118,106,91
                    dc.b     71,49,25,0,-25,-49,-71,-91,-106,-118,-126,-128,-126,-118,-106,-91,-71,-49,-25
WAVEFORM16:         dc.b     0,49,91,118,127,118,91,49,0,-49,-91,-118,-128,-118,-91,-49
WAVEFORM8:          dc.b     0,91,127,91,0,-91,-128,-91
WAVEFORM4:          dc.b     0,127,0,-128
WAVEFORM2:          dc.b     -64,64
WHICH_WAVE:         dc.l     WAVEFORM128
                    dc.l     WAVEFORM64
                    dc.l     WAVEFORM32
                    dc.l     WAVEFORM16
                    dc.l     WAVEFORM8
                    dc.l     WAVEFORM4
                    dc.l     WAVEFORM2
WAVE_LENGTH:        dc.w     128/2,64/2,32/2,16/2,8/2,4/2,2/2
E_HIGH_PING:        dc.w     1,32,0,5,0,1,32,-1,0,-1
E_MEDIUM_PING:      dc.w     1,32,0,5,0,1,32,-1,0,-1
E_LOW_PING:         dc.w     1,32,0,5,0,1,32,-1,0,-1
E_MEDIUM_BEEP:      dc.w     1,64,0,25,0,0,1,-64,0,-1
E_BANG:             dc.w     1,64,0,32,-2,0,-1
E_BOOM:             dc.w     1,64,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,-1
E_GRAVE:            dc.w     1,64,0,864,0,0,64,-1
                    dc.w     0,-1
E_BURY:             dc.w     64,1,-3,1,-64,0,180,0,0,-1
E_SPLASH:           dc.w     32,2,0,40,0,-4,64,-1
                    dc.w     0,-1
E_SUB:              dc.w     1,24,0,10,0,-2,400,0,0,24,-1
                    dc.w     0,-1
E_FEET:             dc.w     10,1,-5,1,-10,0,-1
E_KISS:             dc.w     1,15,0,20,0,-13,1,-15,0,-1
E_RUMBLE:           dc.w     1,64,0,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,-1

START_SOUNDS:       move.w   #1,MASTER_ENABLE
                    clr.w    MUSIC_POINTER
                    clr.w    MUSIC_DELAY
                    lea      RANDOM_AREA,a0
                    move.w   #8192-1,d0
.GEN_RND:           move.l   RND1,d1
                    add.l    RND2,d1
                    add.w    $DFF006,d1
                    ror.l    #1,d1
                    move.l   d1,RND1
                    sub.l    RND3,d1
                    rol.l    #1,d1
                    add.w    d1,RND2
                    and.w    #$FF,d1
                    move.b   d1,(a0)+
                    dbra     d0,.GEN_RND
                    clr.w    MUSIC_SWITCH
                    move.w   #$F,$DFF096
                    move.w   #$FF,$DFF09E
                    lea      $DFF0A0,a5
                    lea      MUSINF_0,a6
                    clr.w    (a6)
                    clr.w    6(a6)
                    move.w   #64/2,4(a5)
                    move.w   #$8001,8(a6)
                    move.l   #ENVELOPE1,10(a6)
                    move.l   10(a6),16(a6)
                    move.l   #DUMMY,10(a6)
                    clr.w    4(a6)
                    move.w   #-1,14(a6)
                    lea      $DFF0B0,a5
                    lea      MUSINF_1,a6
                    clr.w    (a6)
                    clr.w    6(a6)
                    move.w   #64/2,4(a5)
                    move.w   #$8002,8(a6)
                    move.l   #ENVELOPE2,10(a6)
                    move.l   10(a6),16(a6)
                    move.l   #DUMMY,10(a6)
                    clr.w    4(a6)
                    move.w   #-1,14(a6)
                    lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    clr.w    (a6)
                    clr.w    6(a6)
                    move.w   #64/2,4(a5)
                    move.w   #$8004,8(a6)
                    move.l   #ENVELOPE3,10(a6)
                    move.l   10(a6),16(a6)
                    move.l   #DUMMY,10(a6)
                    clr.w    4(a6)
                    move.w   #-1,14(a6)
                    lea      $DFF0D0,a5
                    lea      MUSINF_3,a6
                    clr.w    (a6)
                    move.w   #64/2,4(a5)
                    clr.w    6(a6)
                    move.w   #$8008,8(a6)
                    move.l   #ENVELOPE1,10(a6)
                    move.l   10(a6),16(a6)
                    move.l   #DUMMY,10(a6)
                    clr.w    4(a6)
                    move.w   #0,14(a6)
                    bsr      INITMUSC
                    move.l   $78.w,SAVEINT6
                    move.l   #MYINT6,$78.w
                    lea      $BFD000,a0
                    move.b   #0,$600(a0)
                    move.b   #$E,$700(a0)
                    move.b   #$11,$F00(a0)
                    move.b   #$82,$D00(a0)
                    move.w   #$A000,$DFF09A
                    clr.b    REGS+13
                    rts

; d0=length
; d1=period
; a1=waveform
GO_SOUND:           move.l   a1,(a5)
                    move.w   #$FF,$DFF09E
                    move.w   d0,4(a5)
                    move.w   d1,20(a6)
                    move.w   d1,6(a5)
                    clr.w    6(a6)
                    clr.w    (a6)
                    clr.w    4(a6)
                    move.w   #1,14(a6)
                    move.l   a0,10(a6)
                    rts

HIGH_PING:          move.w   #16/2,d0
                    move.w   #220,d1
                    lea      E_HIGH_PING,a0
                    lea      WAVEFORM16,a1
                    bra.b    GO_SOUND

MEDIUM_PING:        move.w   #16/2,d0
                    move.w   #400,d1
                    lea      E_MEDIUM_PING,a0
                    lea      WAVEFORM16,a1
                    bra.b    GO_SOUND

LOW_PING:           move.w   #8/2,d0
                    move.w   #1800,d1
                    lea      E_LOW_PING,a0
                    lea      WAVEFORM8,a1
                    bra.b    GO_SOUND

DROP_PING:          move.w   #8/2,d0
                    move.w   #2200,d1
                    lea      E_LOW_PING,a0
                    lea      WAVEFORM8,a1
                    bra      GO_SOUND

TAKE_PING:          move.w   #8/2,d0
                    move.w   #2500,d1
                    lea      E_LOW_PING,a0
                    lea      WAVEFORM8,a1
                    bra      GO_SOUND

MEDIUM_BEEP:        move.w   #8/2,d0
                    move.w   #600,d1
                    lea      E_MEDIUM_BEEP,a0
                    lea      WAVEFORM8,a1
                    bra      GO_SOUND

BANG:               move.w   #8192/2,d0
                    move.w   #700,d1
                    lea      E_BANG,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

OTHER_SMACK:        move.w   #8192/2,d0
                    move.w   #500,d1
                    lea      E_BANG,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

GRAVESOUND:         move.w   #598/2,d0
                    move.w   #5700,d1
                    lea      E_GRAVE,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

BOOM:               move.w   #8192/2,d0
                    move.w   #4500,d1
                    lea      E_BOOM,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

BURY:               move.w   #8192/2,d0
                    move.w   #1500,d1
                    lea      E_BURY,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

SPLASH:             move.w   #8192/2,d0
                    move.w   #1000,d1
                    lea      E_SPLASH,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

RUMBLE:             move.w   #8192/2,d0
                    move.w   #4600,d1
                    lea      E_RUMBLE,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

FEET:               move.w   #8192/2,d0
                    move.w   #1500,d1
                    lea      E_FEET,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

KISS:               move.w   #8192/2,d0
                    move.w   #132,d1
                    lea      E_KISS,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

SUB:                move.w   #8/2,d0
                    move.w   #5000,d1
                    lea      E_SUB,a0
                    lea      WAVEFORM16,a1
                    bra      GO_SOUND

HANDLE_SOUNDS:      lea      $DFF0A0,a5
                    lea      MUSINF_0,a6
                    bsr.b    HANDLE_REQUEST
                    bne.b    .NO_REQ
                    lea      $DFF0B0,a5
                    lea      MUSINF_1,a6
                    bsr.b    HANDLE_REQUEST
                    bne.b    .NO_REQ
                    lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    bsr.b    HANDLE_REQUEST
                    bne.b    .NO_REQ
                    lea      $DFF0D0,a5
                    lea      MUSINF_3,a6
                    bra.b    HANDLE_REQUEST
.NO_REQ:            rts

HANDLE_REQUEST:     lea      REQUESTS,a0
                    tst.w    14(a6)
                    bne.b    lbC00157C
                    tst.w    (a0)+
                    bmi.b    lbC00153E
                    bne.b    lbC00155C
lbC00153E:          tst.w    (a0)+
                    bmi.b    lbC001548
                    bne.b    lbC00155C
lbC001548:          tst.w    (a0)+
                    bmi.b    lbC001552
                    bne.b    lbC00155C
lbC001552:          tst.w    (a0)+
                    bmi.b    lbC001580
                    beq.b    lbC001580
lbC00155C:          move.w   -(a0),d0
                    and.w    #$FF,d0
                    or.w     #$8000,(a0)
                    and.w    #$9FFF,(a0)
                    move.l   a0,22(a6)
                    add.w    d0,d0
                    add.w    d0,d0
                    lea      SOUND_ROUTINES,a0
                    move.l   (a0,d0.w),a0
                    jsr      (a0)
lbC00157C:          moveq    #0,d0
                    rts

lbC001580:          moveq    #-1,d0
                    rts

NEW_SOUND:          cmp.w    #11,d7
                    beq.b    lbC001590
                    or.w     #$4000,d7
lbC001590:          movem.l  d0-d2/a0,-(sp)
                    move.w   d7,d0
                    move.w   d0,d2
                    and.w    #$3FF,d0
                    btst     #13,d2
                    beq.b    lbC0015BA
                    tst.w    BSND_FLAG
                    bne.b    NEW_RET
                    move.w   #1,BSND_FLAG
                    bra.b    NO_MATCH

lbC0015BA:          lea      REQUESTS,a0
                    move.w   (a0)+,d1
                    and.w    #$3FF,d1
                    cmp.w    d1,d0
                    beq.b    MATCH_SOUND
                    move.w   (a0)+,d1
                    and.w    #$3FF,d1
                    cmp.w    d1,d0
                    beq.b    MATCH_SOUND
                    move.w   (a0)+,d1
                    and.w    #$3FF,d1
                    cmp.w    d1,d0
                    beq.b    MATCH_SOUND
                    move.w   (a0)+,d1
                    and.w    #$3FF,d1
                    cmp.w    d1,d0
                    bne.b    NO_MATCH
MATCH_SOUND:        tst.w    d2
                    bmi.b    NEW_RET
                    or.w     #$4000,-(a0)
                    bra.b    NEW_RET

NO_MATCH:           lea      REQUESTS,a0
                    tst.w    (a0)+
                    tst.w    (a0)+
                    tst.w    (a0)+
                    tst.w    (a0)+
                    beq.b    lbC00161C
                    btst     #14,d2
                    bne.b    lbC00161C
                    bra.b    NEW_RET

lbC00161C:          move.w   d0,-(a0)
NEW_RET:            movem.l  (sp)+,d0-d2/a0
                    rts

REQUESTS:           dcb.w    4,0
SOUND_ROUTINES:     dc.l     HIGH_PING
                    dc.l     HIGH_PING
                    dc.l     BANG
                    dc.l     BURY
                    dc.l     BOOM
                    dc.l     SPLASH
                    dc.l     MEDIUM_PING
                    dc.l     LOW_PING
                    dc.l     MEDIUM_BEEP
                    dc.l     RUMBLE
                    dc.l     SUB
                    dc.l     FEET
                    dc.l     GRAVESOUND
                    dc.l     KISS
                    dc.l     TAKE_PING
                    dc.l     DROP_PING
                    dc.l     OTHER_SMACK

MYINT6:             tst.b    $BFDD00
                    bsr.w    HANDLE_MOUSE
                    tst.w    MASTER_ENABLE
                    beq.w    MYINT6_RET
                    movem.l  d0-d7/a0-a6,-(sp)
                    tst.w    MUSIC_DELAY
                    beq.b    .WAIT
                    subq.w   #1,MUSIC_DELAY
                    bra.b    ENVS

.WAIT:              move.w   #3,MUSIC_DELAY
                    tst.w    MUSIC_SWITCH
                    beq      ENVS
                    bsr      PLAYMUS
                    bsr      X8912
ENVS:               lea      $DFF0A0,a5
                    lea      MUSINF_0,a6
                    tst.w    14(a6)
                    beq.b    .CHNG_ENV_1
                    bsr.b    CHANGE_ENVELOPE
.CHNG_ENV_1:        lea      $DFF0B0,a5
                    lea      MUSINF_1,a6
                    tst.w    14(a6)
                    beq.b    .CHNG_ENV_2
                    bsr.b    CHANGE_ENVELOPE
.CHNG_ENV_2:        lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    tst.w    14(a6)
                    beq.b    .CHNG_ENV_3
                    bsr.b    CHANGE_ENVELOPE
.CHNG_ENV_3:        lea      $DFF0D0,a5
                    lea      MUSINF_3,a6
                    tst.w    14(a6)
                    beq.b    .CHNG_ENV_4
                    bsr.b    CHANGE_ENVELOPE
.CHNG_ENV_4:        bsr.w    HANDLE_SOUNDS
                    movem.l  (sp)+,d0-d7/a0-a6
MYINT6_RET:         move.w   #$2000,$DFF09C
                    rte

CHANGE_ENVELOPE:    tst.w    (a6)
                    bne.b    SAME_STEP
                    or.w     #$8000,8(a6)
                    tst.w    14(a6)
                    bmi.b    lbC001742
                    clr.w    14(a6)
lbC001742:          move.l   10(a6),a0
CE_1:               move.w   (a0),d0
                    bmi.b    END_OF_ENVY
                    or.w     #1,14(a6)
                    addq.w   #2,a0
                    move.w   d0,(a6)
                    move.w   (a0)+,2(a6)
                    move.w   (a0)+,4(a6)
                    move.l   a0,10(a6)
SAME_STEP:          tst.w    (a6)
                    beq.b    DO_VOLUME
                    subq.w   #1,(a6)
                    move.w   6(a6),d0
                    add.w    2(a6),d0
                    move.w   d0,6(a6)
                    move.w   20(a6),d0
                    add.w    4(a6),d0
                    move.w   d0,20(a6)
                    bra.b    DO_VOLUME

END_OF_ENVY:        cmp.w    #-2,d0
                    bne.b    lbC0017B4
                    move.l   22(a6),a1
                    move.w   (a1),d0
                    btst     #14,d0
                    beq.b    lbC0017B0
                    bclr     #14,d0
                    move.w   d0,(a1)
                    move.w   2(a0),d0
                    sub.w    d0,a0
                    bra.b    CE_1

lbC0017B0:          addq.w   #4,a0
                    bra.b    CE_1

lbC0017B4:          tst.w    6(a6)
                    bne.b    lbC0017C2
                    and.w    #$7FFF,8(a6)
lbC0017C2:          move.l   22(a6),a0
                    move.w   (a0),d0
                    and.w    #$4000,d0
                    bne.b    ALLOW_AGAIN
                    clr.w    (a0)
                    bra.b    DO_VOLUME

ALLOW_AGAIN:        and.w    #$3FF,(a0)
DO_VOLUME:          move.w   20(a6),6(a5)
                    move.w   6(a6),8(a5)
                    move.w   8(a6),$DFF096
                    rts

X8912:              lea      REGS,a4
                    lea      $DFF0A0,a5
                    lea      MUSINF_0,a6
                    move.b   7(a4),d0
                    move.w   d0,d1
                    and.w    #9,d1
                    cmp.w    #9,d1
                    beq      XDONE1
                    and.w    #8,d1
                    beq      XNOISE1
                    moveq    #0,d2
                    moveq    #0,d3
                    move.b   (a4),d2
                    move.b   1(a4),d3
                    add.w    d2,d2
                    lea      WAVE_LENGTH,a0
                    move.w   (a0,d2.w),4(a5)
                    add.w    d2,d2
                    lea      WHICH_WAVE,a0
                    move.l   (a0,d2.w),(a5)
                    add.w    d3,d3
                    lea      FREQS,a0
ISITENV1:           cmp.b    #16,8(a4)
                    beq      DO_ENVEL1
                    move.w   (a0,d3.w),6(a5)
                    move.w   (a0,d3.w),20(a6)
                    clr.w    4(a6)
                    move.b   8(a4),d0
                    and.w    #$F,d0
                    add.w    d0,d0
                    move.w   d0,6(a6)
                    bra      XDONE1

DO_ENVEL1:          tst.b    13(a4)
                    beq      XDONE1
                    move.w   (a0,d3.w),6(a5)
                    move.w   (a0,d3.w),20(a6)
                    clr.w    4(a6)
                    move.l   16(a6),10(a6)
                    clr.w    6(a6)
                    clr.w    (a6)
                    bra      XDONE1

XNOISE1:            lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    move.l   #RANDOM_AREA,(a5)
                    move.w   #8192/2,4(a5)
                    moveq    #0,d0
                    move.b   6(a4),d0
                    and.w    #$1F,d0
                    lsl.w    #7,d0
                    move.w   d0,TEMP_MUSIC
                    lea      TEMP_MUSIC,a0
                    clr.w    d3
                    bra      ISITENV1

XDONE1:             lea      $DFF0B0,a5
                    lea      MUSINF_1,a6
                    move.b   7(a4),d0
                    move.w   d0,d1
                    and.w    #$12,d1
                    cmp.w    #$12,d1
                    beq      XDONE2
                    and.w    #$A,d1
                    bne      XNOISE2
                    moveq    #0,d2
                    moveq    #0,d3
                    move.b   2(a4),d2
                    move.b   3(a4),d3
                    add.w    d2,d2
                    lea      WAVE_LENGTH,a0
                    move.w   (a0,d2.w),4(a5)
                    add.w    d2,d2
                    lea      WHICH_WAVE,a0
                    move.l   (a0,d2.w),(a5)
                    add.w    d3,d3
                    lea      FREQS,a0
ISITENV2:           cmp.b    #16,9(a4)
                    beq      DO_ENVEL2
                    move.w   (a0,d3.w),6(a5)
                    move.w   (a0,d3.w),20(a6)
                    clr.w    4(a6)
                    move.b   9(a4),d0
                    and.w    #$F,d0
                    add.w    d0,d0
                    move.w   d0,6(a6)
                    bra      XDONE2

DO_ENVEL2:          tst.b    13(a4)
                    beq      XDONE2
                    move.w   (a0,d3.w),6(a5)
                    move.w   (a0,d3.w),20(a6)
                    clr.w    4(a6)
                    move.l   16(a6),10(a6)
                    clr.w    6(a6)
                    clr.w    (a6)
                    bra      XDONE2

XNOISE2:            lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    move.l   #RANDOM_AREA,(a5)
                    move.w   #8192/2,4(a5)
                    moveq    #0,d0
                    move.b   6(a4),d0
                    and.w    #$1F,d0
                    lsl.w    #7,d0
                    move.w   d0,TEMP_MUSIC
                    lea      TEMP_MUSIC,a0
                    clr.w    d3
                    bra      ISITENV2

XDONE2:             clr.b    13(a4)
                    rts

PSGW:               move.l   a0,-(sp)
                    lea      REGS,a0
                    move.b   d1,(a0,d0.w)
                    move.l   (sp)+,a0
                    rts

INITMUSC:           move.b   #$38,REG7
                    move.w   #$F8,d1
                    move.w   #7,d0
                    bsr.b    PSGW
                    move.w   #13,d0
                    move.w   #9,d1
                    bsr.b    PSGW
                    move.w   #12,d0
                    move.w   #3,d1
                    bsr.b    PSGW
                    lea      VOICE1,a0
                    bsr      VOICEISOF
                    lea      VOICE2,a0
                    bra      VOICEISOF

PLAYMUS:            lea      VOICE1,a0
                    clr.b    CHAN
                    bsr      VOICISON
                    bsr      OUTVC1
                    lea      VOICE2,a0
                    move.b   #1,CHAN
                    bsr      VOICISON
                    bra      OUTVC2

VOICEISOF:          bsr      DEGATEIT
                    move.b   #1,(a0)
                    clr.b    12(a0)
RESETSEQ:           clr.b    2(a0)
                    move.b   #$FD,14(a0)
NEXTSEQ:            moveq    #0,d0
                    move.b   14(a0),d0
                    move.l   16(a0),d2
                    add.l    d0,d2
                    move.l   d2,a1
                    subq.b   #1,2(a0)
                    bpl      NEXTSEQ1
                    addq.b   #3,d0
                    move.b   d0,14(a0)
                    cmp.b    15(a0),d0
                    beq      NEXTSEQ0
                    bcc.b    RESETSEQ
NEXTSEQ0:           move.l   16(a0),d2
                    add.l    d0,d2
                    move.l   d2,a1
                    moveq    #0,d0
                    move.b   (a1),d0
                    lsr.w    #4,d0
                    move.b   d0,2(a0)
NEXTSEQ1:           move.b   (a1),d0
                    and.w    #$F,d0
                    move.b   d0,3(a0)
                    move.b   1(a1),d0
                    subq.b   #3,d0
                    move.b   d0,4(a0)
                    move.b   2(a1),d0
                    move.b   d0,5(a0)
                    rts

VOICISON:           subq.b   #1,(a0)
                    beq      NEXTNOTE
                    rts

NEXTNOTE:           move.l   20(a0),d2
                    moveq    #0,d0
                    move.b   4(a0),d0
                    add.l    d0,d2
                    move.l   d2,a1
                    tst.b    12(a0)
                    beq      NEXTNOTO
                    sub.b    #1,12(a0)
                    moveq    #0,d0
                    move.b   2(a1),d0
                    move.l   d0,d4
                    move.b   d0,IRQA
                    tst.b    d0
                    bmi      SETAREST
                    bsr      DEGATEIT
SETAREST:           move.b   IRQA,d0
                    and.w    #7,d0
                    beq      NEXTNOTO
                    lea      DURALIST-1,a2
                    lea      (a2,d0.w),a2
                    move.b   (a2),(a0)
                    rts

NEXTNOTO:           addq.b   #1,12(a0)
NEXTNOT1:           move.b   4(a0),d0
                    addq.b   #3,d0
                    move.b   d0,4(a0)
                    cmp.b    5(a0),d0
                    bcs      CONTSONG
                    beq      CONTSONG
                    bsr      NEXTSEQ
                    bra.b    NEXTNOT1

CONTSONG:           move.l   $14(a0),d2
                    moveq    #0,d0
                    move.b   4(a0),d0
                    add.l    d0,d2
                    move.l   d2,a1
                    moveq    #0,d0
                    move.b   1(a1),d0
                    and.w    #7,d0
                    lea      DURALIST,a2
                    add.l    d0,a2
                    move.b   (a2),(a0)
                    moveq    #0,d0
                    move.b   1(a1),d0
                    and.w    #$F,d0
                    cmp.b    #8,d0
                    bcs      _DEGATEIT
                    rts

_DEGATEIT:          bsr      DEGATEIT
                    moveq    #0,d0
                    move.b   1(a1),d0
                    and.w    #$F0,d0
                    bne      _CHECK2
                    rts

_CHECK2:            bsr      CHECK2
                    moveq    #0,d0
                    move.b   (a1),d0
                    bsr      CALCNOTE
                    move.b   d0,7(a0)
                    move.b   d5,8(a0)
                    rts

DEGATEIT:           moveq    #0,d0
                    move.b   d0,13(a0)
                    rts

CHECK2:             tst.b    CHAN
                    bne      CHANNELB
                    move.b   1(a1),d0
                    and.b    #$70,d0
                    cmp.b    #$50,d0
                    beq      SNAREA
                    move.b   REG7,d0
                    and.w    #$36,d0
                    or.w     #$C8,d0
                    move.b   d0,REG7
                    move.w   d0,d1
                    move.w   #7,d0
                    bsr      PSGW
                    move.b   #$10,13(a0)
                    move.b   1(a1),d0
                    and.b    #$70,d0
                    cmp.b    #$40,d0
                    beq      OUTAGAIN
                    move.b   #15,13(a0)
                    rts

SNAREA:             moveq    #0,d0
                    move.b   REG7,d0
                    and.w    #$36,d0
                    or.w     #$C1,d0
                    move.b   d0,REG7
                    move.w   d0,d1
                    move.w   #7,d0
                    bsr      PSGW
SNARECNT:           move.b   #$10,13(a0)
                    moveq    #0,d1
                    move.b   (a1),d1
                    and.w    #$1F,d1
                    move.w   #6,d0
                    bsr      PSGW
                    bra      OUTAGAIN

CHANNELB:           moveq    #0,d0
                    move.b   1(a1),d0
                    and.b    #$70,d0
                    cmp.b    #$50,d0
                    beq      SNAREB
                    moveq    #0,d0
                    move.b   REG7,d0
                    and.b    #$2D,d0
                    or.b     #$D0,d0
                    move.b   d0,REG7
                    move.w   d0,d1
                    move.w   #7,d0
                    bsr      PSGW
                    move.b   #$10,13(a0)
                    move.b   1(a1),d0
                    and.b    #$70,d0
                    cmp.b    #$40,d0
                    beq      OUTAGAIN
                    move.b   #12,13(a0)
OUTAGAIN:           move.w   #11,d0
                    move.w   #3,d1
                    bsr      PSGW
                    move.w   #13,d0
                    move.w   #3,d1
                    bra      PSGW

SNAREB:             move.b   REG7,d0
                    and.w    #$2D,d0
                    or.w     #$C2,d0
                    move.b   d0,REG7
                    move.w   d0,d1
                    move.w   #7,d0
                    bsr      PSGW
                    bra      SNARECNT

CALCNOTE:           move.l   d0,d3
                    move.b   3(a0),d4
                    bsr      NOTEMODS
                    move.w   d0,-(sp)
                    and.w    #$F,d0
                    move.w   d0,d5
                    move.w   (sp)+,d0
                    lsr.b    #4,d0
                    and.w    #7,d0
                    beq      CALC2
                    subq.w   #1,d0
                    beq      CALC2
                    subq.w   #1,d0
CALC2:              rts

OUTVC1:             moveq    #8,d4
                    moveq    #0,d5
                    bra      SNDOUT

OUTVC2:             moveq    #9,d4
                    moveq    #2,d5
                    ; no rts

SNDOUT:             move.l   d4,d0
                    clr.w    d1
                    move.b   13(a0),d1
                    bsr      PSGW
                    move.w   d5,d0
                    clr.w    d1
                    move.b   7(a0),d1
                    bsr      PSGW
                    move.w   d5,d0
                    add.b    #1,d0
                    move.b   8(a0),d1
                    bsr      PSGW
                    rts

NOTEMODS:           move.b   d0,SAVE
                    and.w    #$F,d0
                    move.b   d0,IRQA
                    move.w   d0,d5
                    move.w   d4,d0
                    cmp.b    #8,d0
                    bcc      XXMOD5
                    and.w    #7,d0
                    add.b    d5,d0
                    cmp.b    #12,d0
                    bcs      XXMOD1
                    addq.b   #4,d0
                    and.w    #$F,d0
                    move.w   #-1,d7
NOTEMOD1:           move.b   d0,IRQA
                    move.w   d0,d5
                    move.b   SAVE,d0
                    tst.w    d7
                    beq      NOTEMOD2
                    add.b    #$10,d0
NOTEMOD2:           and.b    #$70,d0
                    or.b     d5,d0
                    move.w   d0,d5
                    move.b   d0,IRQA
                    rts

NOTEMOD5:           eor.b    #$FF,d0
                    addq.b   #1,d0
                    add.b    d5,d0
                    bcs      NOTEMOD6
                    subq.b   #4,d0
                    and.w    #$F,d0
                    move.b   d0,IRQA
                    move.w   d0,d5
                    move.b   SAVE,d0
                    sub.b    #$10,d0
                    bra.b    NOTEMOD2

NOTEMOD6:           and.w    #$F,d0
                    move.b   d0,IRQA
                    move.w   d0,d5
                    move.b   SAVE,d0
                    bra.b    NOTEMOD2

XXMOD5:             and.w    #7,d0
                    bra.b    NOTEMOD5

XXMOD1:             clr.w    d7
                    bra.b    NOTEMOD1

RESET:              move.w   #8,d0
                    clr.w    d1
                    bsr      PSGW
                    move.w   #9,d0
                    clr.w    d1
                    bsr      PSGW
                    move.w   #10,d0
                    clr.w    d1
                    bra      PSGW

DURALIST:           dc.b     9,$12,$1B,$24,$36,$48,$6C,$90
SSETBASE:           dc.b     $40,2,0,0,$10,$44,$65,$80,$8A,2,0,0,$10,$44,$65
                    dc.b     $80,$C9,1,0,0,$10,$44,$65,$C4,6,0,0,0,$10,5,4,0,0
                    dc.b     0,0,0,$80,2,0,$80
SEQDATA1:           dc.b     $F0,$42,$42,$30,$45,$5A,$70,$33,$42,$10,$1E,$30
                    dc.b     $10,0,$1B,$40,$5D,$84,0,$42,$42
SEQDATA2:           dc.b     0,0,$24,10,0,$24,0,0,$24,10,0,$24,12,0,$24,10,0
                    dc.b     $24,0,0,$24,12,$27,$36,10,$27,$36
MUSDATA1:           dc.b     $5A,$12,0,$D7,$21,5,$57,$30,$70,$DA,$30,0,$D7,$30
                    dc.b     0,$60,$30,$78,$D7,$30,$78,$DA,$32,0,$D7,$21,3,$D7
                    dc.b     5,$78,$5A,$13,$80,$DA,$3D,$F8,$DA,$39,0,$E2,$31,0
                    dc.b     $E0,$32,$78,$D9,$22,$38,$F0,5,2,$E0,$40,0,$E0,$40
                    dc.b     $79,$E0,$40,$79,$60,$40,1,$E2,$40,0,0,5,$78,$E3
                    dc.b     $30,$3A,$E2,$30,$10,0,4,4,$5A,$31,$78,$69,$30,$7A
                    dc.b     $67,$30,0,$80,4,4,$55,$31,$78,$47,$40,$78,$47,$40
                    dc.b     0,$52,$40,0,$57,$40,$78,$47,$40,$78,$47,$40,0,0,1
                    dc.b     0,$47,$40,$78,$47,$40,$78,$52,$40,0,$57,$40,0,$47
                    dc.b     $40,$78,$C7,$40,$78,0,4,$44
MUSDATA2:           dc.b     $37,$41,$28,$CB,$50,0,$42,$40,8,$C7,$40,$78,$D1
                    dc.b     $50,$78,$51,0,0,$B7,$41,0,$B7,$40,$78,$CB,$50,$78
                    dc.b     $C2,$40,0,$C7,$41,0,$CB,$50,$78,$D1,$50,$78,$B7
                    dc.b     $41,0,$CB,$50,$40,$C2,$40,$78,$C7,$40,$78,$D1,$50
                    dc.b     0,0,1,$78
IRQA:               dc.b     0
SAVE:               dc.b     0
CHAN:               dc.b     0
                    even
VOICE1:             dc.l     0,0,0,18
                    dc.l     SEQDATA1
                    dc.l     MUSDATA1
VOICE2:             dc.l     0,0,0,24
                    dc.l     SEQDATA2
                    dc.l     MUSDATA2
MUSIC_SWITCH:       dc.w     0
RND1:               dc.l     $98121233
RND2:               dc.l     $FE651232
RND3:               dc.l     $17263433
SAVE_INT2:          dc.l     0
TEMP_MUSIC:         dc.w     0
REGS:               dcb.b    14,0
REG7:               dc.b     0
                    eveN
SAVEINT6:           dc.l     0
MUSINF_0:           dc.w     0,0,0,0,0,0,0
lbW001F72:          dc.w     0,0,0,0,0,0
MUSINF_1:           dc.w     0,0,0,0,0,0,0
lbW001F8C:          dc.w     0,0,0,0,0,0
MUSINF_2:           dc.w     0,0,0,0,0,0,0
lbW001FA6:          dc.w     0,0,0,0,0,0
MUSINF_3:           dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0
MUSIC_POINTER:      dc.w     0
MUSIC_DELAY:        dc.w     0
FRED:               dc.w     0
MASTER_ENABLE:      dc.w     0
BSND_FLAG:          dc.w     0

START:              move.l   sp,MY_VERY_OWN_STACK
                    bsr      ALLOCATE_MEMORY
                    bsr      INIT_KEY
                    bsr      START_SOUNDS
                    move.l   $68.w,SAVE_INT2
                    move.w   #1,MUSIC_SWITCH
                    bsr      SETUP_SCREEN
                    move.l   TWOSCREEN,SCREEN2
                    move.l   ONESCREEN,SCREEN1
                    bsr      READALL
                    move.l   #1245184,d0
.WAIT:              subq.l   #1,d0
                    bne.b    .WAIT
                    move.l   $6C.w,SAVE_INT3
                    move.l   #MYINT3,$6C.w
                    move.l   #MYINT2,$68.w
                    move.w   #(200*40)-1,d0
                    move.l   SCREEN2,a1
                    move.l   BACK,a0
.COPY_FRONT:        move.l   (a0)+,(a1)+
                    dbra     d0,.COPY_FRONT
                    bsr      SWAPSCREEN
                    move.w   #(200*40)-1,d0
                    move.l   SCREEN2,a1
                    move.l   BACK,a0
.COPY_BACK:         move.l   (a0)+,(a1)+
                    dbra     d0,.COPY_BACK
                    clr.w    S1MODE
                    move.w   #1,S2MODE
DEVICE:             move.l   MY_VERY_OWN_STACK,sp
                    bsr      GETMODE
                    move.w   d1,S1MODE
                    move.w   d2,S2MODE
PLAY:               move.w   #$23,DANGER
                    bsr      PLAYINIT
                    tst.w    ABORT
                    beq      _DO_GAME
                    clr.w    ABORT
                    bra.b    DEVICE

_DO_GAME:           bsr      DO_GAME
                    bra.b    PLAY

READALL:            move.l   SCREEN1,a0
                    move.w   #(200*40)-1,d0
.CLEAR:             clr.l    (a0)+
                    dbra     d0,.CLEAR
                    lea      SPYPIX,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    clr.w    d1
                    move.w   #4,d2
                    lea      BUF11,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #4,d2
                    lea      BUF12,a1
                    bsr      GRAB
                    clr.w    d1
                    move.w   #43,d2
                    lea      BUF13,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #43,d2
                    lea      BUF14,a1
                    bsr      GRAB
                    clr.w    d1
                    move.w   #160,d2
                    lea      BUF1B,a1
                    bsr      GRAB
                    move.w   #16,d1
                    move.w   #82,d2
                    lea      BUF16,a1
                    move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    clr.w    d1
                    move.w   #82,d2
                    lea      BUF21,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #82,d2
                    lea      BUF22,a1
                    bsr      GRAB
                    clr.w    d1
                    move.w   #121,d2
                    lea      BUF23,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #121,d2
                    lea      BUF24,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #160,d2
                    lea      BUF2B,a1
                    bsr      GRAB
                    move.w   #16,d1
                    move.w   #121,d2
                    lea      BUF26,a1
                    move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    lea      BUF31,a1
                    move.w   #16,d1
                    move.w   #4,d2
                    move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    lea      632(a1),a1
                    move.w   #18,d1
                    move.w   #4,d2
                    move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    lea      632(a1),a1
                    move.w   #16,d1
                    move.w   #43,d2
                    move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    lea      632(a1),a1
                    move.w   #18,d1
                    move.w   #43,d2
                    move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    lea      NOSE,a1
                    move.w   #16,d1
                    move.w   #160,d2
                    move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    lea      632(a1),a1
                    move.w   #18,d1
                    move.w   #160,d2
                    move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    lea      SPYPIX2,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    clr.w    d1
                    move.w   #4,d2
                    lea      BUF17,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #4,d2
                    lea      BUF18,a1
                    bsr      GRAB
                    clr.w    d1
                    move.w   #43,d2
                    lea      BUF19,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #43,d2
                    lea      BUF1A,a1
                    bsr      GRAB
                    move.w   #12,d1
                    move.w   #43,d2
                    lea      BUF15,a1
                    bsr      GRAB
                    clr.w    d1
                    move.w   #82,d2
                    lea      BUF27,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #82,d2
                    lea      BUF28,a1
                    bsr      GRAB
                    clr.w    d1
                    move.w   #121,d2
                    lea      BUF29,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #121,d2
                    lea      BUF2A,a1
                    bsr      GRAB
                    move.w   #12,d1
                    move.w   #121,d2
                    lea      BUF25,a1
                    bsr      GRAB
                    move.w   #82,d2
                    move.w   #16,d1
                    move.w   #2,d6
                    move.w   #39,d7
                    lea      BUF1C,a1
                    bsr      RSAVE_BUFF
                    move.w   #121,d2
                    move.w   #16,d1
                    move.w   #2,d6
                    move.w   #39,d7
                    lea      BUF2C,a1
                    bsr      RSAVE_BUFF
                    move.w   #4,d2
                    move.w   #16,d1
                    move.w   #2,d6
                    move.w   #39,d7
                    lea      BUF1D,a1
                    bsr      RSAVE_BUFF
                    move.w   #4,d2
                    move.w   #18,d1
                    move.w   #2,d6
                    move.w   #39,d7
                    lea      lbB01672C,a1
                    bsr      RSAVE_BUFF
                    move.w   #43,d2
                    move.w   #16,d1
                    move.w   #2,d6
                    move.w   #39,d7
                    lea      BUF2D,a1
                    bsr      RSAVE_BUFF
                    move.w   #43,d2
                    move.w   #18,d1
                    move.w   #2,d6
                    move.w   #39,d7
                    lea      lbB01D3CC,a1
                    bsr      RSAVE_BUFF
                    lea      GRAVE,a1
                    move.w   #8,d1
                    move.w   #43,d2
                    move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    lea      632(a1),a1
                    lea      BUBBLES,a1
                    clr.w    d1
                    move.w   #43,d2
                    move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    lea      632(a1),a1
                    clr.w    d1
                    move.w   #160,d2
                    lea      OBJS,a1
                    bsr      GRABOBJ
                    clr.w    d1
                    move.w   #168,d2
                    lea      OBJS2,a1
                    bsr      GRABOBJ
                    move.w   #176,d2
                    clr.w    d1
                    move.w   #1,d6
                    move.w   #8,d7
                    lea      MAPBOX,a1
                    bsr      RSAVE_BUFF
                    move.w   #176,d2
                    move.w   #1,d1
                    move.w   #1,d6
                    move.w   #8,d7
                    lea      MAPSPOT,a1
                    bsr      RSAVE_BUFF
                    move.w   #184,d2
                    clr.w    d1
                    move.w   #2,d6
                    move.w   #12,d7
                    lea      FIN,a1
                    bsr      RSAVE_BUFF
                    move.w   #2,d1
                    lea      632(a1),a1
                    bsr      RSAVE_BUFF
                    lea      LANDPIX,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    clr.w    d1
                    clr.w    d2
                    lea      LAND,a1
                    bsr      GRABLAND
                    clr.w    d1
                    move.w   #65,d2
                    bsr      GRABLAND
                    clr.w    d1
                    move.w   #130,d2
                    bsr      GRABLAND
                    movem.l  a0/a1,-(sp)
                    move.w   #130,d2
                    moveq    #0,d1
                    lea      CLOUD_SUB,a1
                    move.w   #1,d6
                    move.w   #8,d7
                    move.l   BACK,a0
                    bsr      RSAVE_BUFF
                    lea      LANDPIX2,a0
                    bsr      READPIX
                    movem.l  (sp)+,a0/a1
                    move.w   #0,d1
                    move.w   #64,d2
                    bsr      GRABLAND
VOLCANO_CUT:        move.w   #4,d6
                    move.w   #45,d7
                    move.w   #0,d1
                    move.w   #0,d2
                    lea      VOLTOP,a1
                    move.w   #4-1,d3
_RSAVE_BUFF:        bsr      RSAVE_BUFF
                    addq.w   #5,d1
                    lea      1440(a1),a1
                    dbra     d3,_RSAVE_BUFF
                    lea      MAPPIX,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    clr.w    d1
                    clr.w    d2
                    move.w   #4-1,d3
                    lea      MAPS,a1
                    bsr      GRABMAP
                    move.w   #3-1,d3
                    add.w    #7,d1
                    clr.w    d2
                    bsr      GRABMAP
                    move.w   #16,d1
                    move.w   #130,d2
                    move.w   #4,d6
                    move.w   #64,d7
                    lea      ONETREE,a1
                    bsr      RSTUFF_BUFF
                    move.w   #16,d1
                    move.w   #130,d2
                    move.w   #3,d6
                    move.w   #64,d7
                    lea      ONETREEA,a1
                    bsr      RSTUFF_BUFF
                    move.w   #17,d1
                    move.w   #130,d2
                    move.w   #3,d6
                    move.w   #64,d7
                    lea      ONETREEB,a1
                    bsr      RSTUFF_BUFF
                    move.w   #16,d1
                    move.w   #66,d2
                    move.w   #4,d6
                    move.w   #64,d7
                    lea      TWOTREE,a1
                    bsr      RSTUFF_BUFF
                    move.w   #16,d1
                    move.w   #66,d2
                    move.w   #3,d6
                    move.w   #64,d7
                    lea      TWOTREEA,a1
                    bsr      RSTUFF_BUFF
                    move.w   #17,d1
                    move.w   #66,d2
                    move.w   #3,d6
                    move.w   #64,d7
                    lea      TWOTREEB,a1
                    bsr      RSTUFF_BUFF
                    move.w   #16,d1
                    move.w   #3,d2
                    move.w   #4,d6
                    move.w   #64,d7
                    lea      THRTREE,a1
                    bsr      RSTUFF_BUFF
                    move.w   #16,d1
                    move.w   #3,d2
                    move.w   #3,d6
                    move.w   #64,d7
                    lea      THRTREEA,a1
                    bsr      RSTUFF_BUFF
                    move.w   #17,d1
                    move.w   #3,d2
                    move.w   #3,d6
                    move.w   #64,d7
                    lea      THRTREEB,a1
                    bsr      RSTUFF_BUFF
                    clr.w    d2
                    move.w   #14,d1
                    move.w   #1,d6
                    move.w   #16,d7
                    lea      PARABUFF,a1
                    bsr      RSAVE_BUFF
                    move.w   #22,d2
                    move.w   #14,d1
                    move.w   #1,d6
                    move.w   #16,d7
                    lea      lbB03AD7C,a1
                    bsr      RSAVE_BUFF
                    move.w   #13,d1
                    move.w   #130,d2
                    lea      RTCOVER,a1
                    move.w   #64,d7
                    move.w   #2,d6
                    bsr      RSTUFF_BUFF
                    lea      BACKPIX,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    move.w   #4,d1
                    move.w   #11,d2
                    move.w   #12,d6
                    move.w   #64,d7
                    lea      VOLCANOE,a1
                    bsr      RSAVE_BUFF
                    move.w   #6,d1
                    move.w   #115,d2
                    move.w   #7,d6
                    move.w   #55,d7
                    lea      CONTROLS,a1
                    bsr      RSAVE_BUFF
                    move.w   #96,d1
                    move.w   #115,d2
                    move.w   #11,d6
                    move.w   #55,d7
                    bsr      RCLEARBLOCK
                    move.w   #3,d1
                    move.w   #32,d2
                    move.w   #2,d6
                    move.w   #11,d7
                    lea      ITEMON,a1
                    bsr      RSTUFF_BUFF
                    move.w   #3,d1
                    move.w   #54,d2
                    move.w   #2,d6
                    move.w   #11,d7
                    lea      ITEMOFF,a1
                    bsr      RSTUFF_BUFF
                    move.w   #9,d1
                    move.w   #87,d2
                    move.w   #7,d6
                    move.w   #5,d7
                    lea      STREN,a1
                    bsr      RSAVE_BUFF
                    lea      ROCKET,a1
                    move.w   #5,d1
                    move.w   #82,d2
                    move.w   #2,d3
                    bsr      GRABOBJ1
                    move.w   #5,d1
                    move.w   #181,d2
                    move.w   #2,d3
                    bsr      GRABOBJ1
                    lea      SPY2PICA,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    move.w   #12,d1
                    move.w   #1,d2
                    move.w   #4,d6
                    move.w   #31,d7
                    lea      WSUB,a1
                    bsr      RSAVE_BUFF
                    clr.w    d1
                    move.w   #33,d2
                    move.w   #4,d6
                    move.w   #31,d7
                    lea      WSUB2,a1
                    bsr      RSAVE_BUFF
                    move.w   #5,d2
                    move.w   #8,d1
                    move.w   #2,d6
                    move.w   #39,d7
                    lea      WOMAN,a1
                    bsr      RSAVE_BUFF
                    move.w   #5,d2
                    move.w   #10,d1
                    move.w   #2,d6
                    move.w   #39,d7
                    lea      lbB039284,a1
                    bsr      RSAVE_BUFF
                    lea      BACKPIX,a0
                    bsr      READPIX
                    move.w   d7,$DFF180
                    move.l   BACK,a0
                    move.w   #96,d1
                    move.w   #115,d2
                    move.w   #13,d6
                    move.w   #53,d7
                    bra      RCLEARBLOCK

MYINT3:             addq.w   #1,FERDINAND
                    clr.w    INT_REQ
                    move.w   #$70,$DFF09C
                    rte

GRAB:               move.w   #4-1,d3
.LOOP:              move.w   #2,d6
                    move.w   #39,d7
                    bsr      RSAVE_BUFF
                    addq.w   #2,d1
                    lea      632(a1),a1
                    dbra     d3,.LOOP
                    rts

GRABOBJ:            move.w   #20-1,d3
GRABOBJ1:           move.w   #2,d6
                    move.w   #8,d7
                    bsr      RSTUFF_BUFF
                    addq.w   #1,d1
                    lea      168(a1),a1
                    dbra     d3,GRABOBJ1
                    rts

GRABLAND:           move.w   #20-1,d3
.LOOP:              move.w   #64,d7
                    move.w   #1,d6
                    bsr      RSTUFF_BUFF_SHORT
                    addq.w   #1,d1
                    lea      520(a1),a1
                    dbra     d3,.LOOP
                    rts

GRABMAP:            move.w   #6,d6
                    move.w   #44,d7
                    bsr      RSAVE_BUFF
                    add.w    #44,d2
                    lea      2120(a1),a1
                    dbra     d3,GRABMAP
                    rts

PLAYINIT:           move.w   #1,S1MENU
                    move.w   #1,S2MENU
                    clr.w    S1FLASH
                    clr.w    S2FLASH
                    move.w   #2,REFRESH
                    bsr      RNDER
                    and.w    #3,d0
                    add.w    #3,d0
                    move.w   d0,BULLET
                    bsr      CLEANTRAIL
                    bsr      PARMS
                    bsr      CLEANTRAIL
PLAYINIT0:          clr.w    S1AUTO
                    clr.w    S2AUTO
                    cmp.w    #1,PLAYERS
                    bne.b    .ONEPLAY
                    move.w   #1,S2AUTO
.ONEPLAY:           move.w   LEVEL,d1
                    mulu     #(96*20),d1
                    ; copy the map into the map place holder block
                    lea      MAP,a1
                    add.l    a1,d1
                    move.l   d1,a0
                    move.w   #((96*20)/2)-1,d1
PLAYINIT1:          move.w   (a0)+,(a1)+
                    dbra     d1,PLAYINIT1
                    move.w   LEVEL,d1
                    mulu     #480,d1
                    lea      TERRAIN,a1
                    move.l   a1,a0
                    add.w    d1,a0
                    move.w   #(480/4)-1,d1
PLAYINIT2:          move.l   (a0)+,(a1)+
                    dbra     d1,PLAYINIT2
                    move.l   #XROCKET,S1CHOICEX
                    move.l   #YROCKET,S1CHOICEY
                    move.l   #XROCKET,S2CHOICEX
                    move.l   #YROCKET,S2CHOICEY
                    clr.w    XROCKET
                    clr.w    YROCKET
                    clr.w    XMIDNOSE
                    clr.w    YMIDNOSE
                    clr.w    XMIDTAIL
                    clr.w    YMIDTAIL
                    move.l   #BUF11,S1FADDR
                    move.l   #BUF21,S2FADDR
                    move.w   #100,S1ENERGY
                    move.w   #100,S2ENERGY
                    move.w   #100-1,d1
                    lea      TRAPLIST,a4
.CLEAR:             clr.l    (a4)+
                    clr.w    (a4)+
                    dbra     d1,.CLEAR
                    clr.w    S1ALTITUDE
                    clr.w    S2ALTITUDE
                    clr.w    S1SHCT
                    clr.w    S2SHCT
                    clr.w    S1BRAIN
                    clr.w    S2BRAIN
                    clr.w    S1CT
                    clr.w    S2CT
                    clr.w    S1DEAD
                    clr.w    S2DEAD
                    clr.w    S1SWAMP
                    clr.w    S2SWAMP
                    clr.w    S1DEPTH
                    clr.w    S2DEPTH
                    clr.w    IN_TROUBLE1
                    clr.w    IN_TROUBLE2
                    clr.w    BUF1X
                    move.w   #-1,BUF1Y
                    clr.w    BUF2X
                    move.w   #-1,BUF2Y
                    clr.w    TENMINS
                    clr.w    ONEMINS
                    clr.w    TENSECS
                    clr.w    ONESECS
                    move.w   #5,S1NAPA
                    move.w   #5,S2NAPA
                    clr.w    S1GUN
                    clr.w    S2GUN
                    clr.w    S1HAND
                    clr.w    S2HAND
                    move.w   #1,d1
                    move.w   #30,d2
                    bsr      STUFFIT
                    lea      XNOSE,a1
                    lea      YNOSE,a2
                    bsr      SETXY
                    move.w   #1,d1
                    move.w   #22,d2
                    bsr      STUFFIT
                    lea      XMID,a1
                    lea      YMID,a2
                    bsr      SETXY
                    move.w   #1,d1
                    move.w   #14,d2
                    bsr      STUFFIT
                    lea      XTAIL,a1
                    lea      YTAIL,a2
                    bsr      SETXY
                    move.w   #1,d1
                    move.w   #78,d2
                    bsr      STUFFIT
                    lea      XGUN,a1
                    lea      YGUN,a2
                    bsr      SETXY
                    move.w   LEVEL,d2
                    subq.w   #1,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    lea      WHICHTABLE,a4
                    add.w    d2,a4
                    move.l   (a4),a4
                    move.l   (a4)+,a0
                    add.l    #MAP,a0
                    move.b   #105,(a0)
                    bsr      GETA4
                    move.w   d1,XSUB
                    bsr      GETA4
                    move.w   d1,YSUB
                    bsr      GETA4
                    move.w   #169,d2
                    bsr      STUFFIT
                    bsr      GETA4
                    move.w   #171,d2
                    bsr      STUFFIT
                    bsr      GETA4
                    move.w   #173,d2
                    bsr      STUFFIT
                    bsr      GETA4
                    move.w   #70,d2
                    bsr      STUFFIT
                    bsr      GETA4
                    move.w   #94,d2
                    bsr      STUFFIT
                    bsr      GETA4
                    move.w   #62,d2
                    bsr      STUFFIT
                    bsr      GETA4
                    move.w   #86,d2
                    bsr      STUFFIT
                    bsr      GETA4
                    move.w   d1,S1FUEL
                    bsr      GETA4
                    move.w   d1,S2FUEL
                    bsr      GETA4
                    move.w   d1,S1SHOV
                    bsr      GETA4
                    move.w   d1,S2SHOV
                    bsr      GETA4
                    move.w   d1,S1ROPE
                    bsr      GETA4
                    move.w   d1,S2ROPE
                    bsr      GETA4
                    move.w   d1,S1COCO
                    bsr      GETA4
                    move.w   d1,S2COCO
                    bsr      GETA4
                    move.w   d1,ONEMINS
                    bsr      GETA4
                    move.w   d1,TENMINS
                    clr.w    XROCKET
                    clr.w    YROCKET
                    clr.w    XMIDNOSE
                    clr.w    YMIDNOSE
                    clr.w    XMIDTAIL
                    clr.w    YMIDTAIL
                    move.w   #96,MAXMAPX
                    move.w   #20,MAXMAPY
                    bsr      STUFFSPY
                    bsr      XGET_STICK
                    move.l   BACK,a0
                    move.l   SCREEN2,a1
                    move.w   #(200*40)-1,d0
PLAYINIT9_1:        move.l   (a0)+,(a1)+
                    dbra     d0,PLAYINIT9_1
                    move.l   BACK,a0
                    move.l   SCREEN1,a1
                    move.w   #(200*40)-1,d0
PLAYINIT9_2:        move.l   (a0)+,(a1)+
                    dbra     d0,PLAYINIT9_2
                    rts

GETA4:              clr.w    d1
                    move.b   (a4)+,d1
                    rts

XGET_STICK:         move.w   LEVEL,d1
                    subq.w   #1,d1
                    add.w    d1,d1
                    lea      XPLANESX,a0
                    move.w   (a0,d1.w),XSTICK1
                    lea      YPLANESY,a0
                    move.w   (a0,d1.w),YSTICK1
                    rts

XPLANESX:           dc.w     25,67,83,77,66,81,72
YPLANESY:           dc.w     8,8,4,16,12,16,4
WHICHTABLE:         dc.l     WHICH1
                    dc.l     WHICH2
                    dc.l     WHICH3
                    dc.l     WHICH4
                    dc.l     WHICH5
                    dc.l     WHICH6
                    dc.l     WHICH7
WHICH1:             dc.b     0,0,2,$56,$16,6,2,2,2,0,0,6,6,6,6,1,1,10,10,10,10,6,0,0
WHICH2:             dc.b     0,0,2,$56,$16,6,2,2,2,0,0,8,12,5,5,1,1,8,8,10,10,8,0,0
WHICH3:             dc.b     0,0,0,$D6,$16,2,3,3,3,0,8,10,$14,4,4,1,1,6,6,10,10,1,1,0
WHICH4:             dc.b     0,0,0,$C4,4,2,3,3,3,0,12,$1E,$18,3,3,1,1,12,12,8,8,4,1,0
WHICH5:             dc.b     0,0,1,$19,$59,2,8,8,8,2,$10,$14,$14,3,3,0,0,$10,$10,6,6,8,1,0
WHICH6:             dc.b     0,0,1,$19,$59,2,8,8,8,2,$14,14,$14,3,3,0,0,$14,$14,4,4,2,2,0
WHICH7:             dc.b     0,0,1,$19,$59,2,8,8,8,2,$14,14,$14,3,3,0,0,$14,$14,2,2,7,2,0
SPYPIX:             dc.b     "gfx/spy1x.pi1",0
SPYPIX2:            dc.b     "gfx/spy2x.pi1",0
BACKPIX:            dc.b     "gfx/back.pi1",0
LANDPIX:            dc.b     "gfx/land.pi1",0
MAPPIX:             dc.b     "gfx/maps.pi1",0
LANDPIX2:           dc.b     "gfx/land2.pi1",0
SPY2PICA:           dc.b     "gfx/spy2pica.pi1",0
                    even
MY_VERY_OWN_STACK:  dc.l     0
XSTICK1:            dc.w     0
XSTICK2:            dc.w     0
YSTICK1:            dc.w     0
YSTICK2:            dc.w     0

PARMS:              clr.w    DEMO
                    clr.w    S1AUTO
                    clr.w    S2AUTO
                    clr.w    S1DEAD
                    clr.w    S2DEAD
                    move.w   #1,d3
                    move.w   #65536-1,d0
.WAIT:              dbra     d0,.WAIT
PARMS1:             move.l   BACK,a0
                    move.l   SCREEN2,a1
                    move.w   #(200*40)-1,d0
PARMS1_0_0:         move.l   (a0)+,(a1)+
                    dbra     d0,PARMS1_0_0
                    bsr      READ_TRIGS
                    tst.w    JOY1TRIG
                    bne      PARMSRET
                    tst.w    JOY2TRIG
                    bne      PARMSRET
                    move.w   COUNTER,d1
                    and.w    #3,d1
                    beq      PARMS1_0_1
                    cmp.w    #2,d1
                    beq      PARMS1_0_2
                    bra      PARMSEND

PARMS1_0_1:         clr.l    d0
                    move.w   d3,-(sp)
                    bsr      JOYMOVE
                    move.w   (sp)+,d3
                    bra      PARMS1_0_3

PARMS1_0_2:         move.w   #1,d0
                    move.w   d3,-(sp)
                    bsr      JOYMOVE
                    move.w   (sp)+,d3
PARMS1_0_3:         tst.w    d2
                    bge      PARMS1_0
                    moveq    #1,d7
                    bsr      NEW_SOUND
                    sub.w    #1,d3
                    tst.w    d3
                    bne      PARMS1_1
                    moveq    #0,d7
                    bsr      NEW_SOUND
                    move.w   #1,d3
                    bra      PARMS1_1

PARMS1_0:           cmp.w    #1,d2
                    bne      PARMS1_1
                    moveq    #1,d7
                    bsr      NEW_SOUND
                    add.w    #1,d3
                    cmp.w    #5,d3
                    bne      PARMS1_1
                    moveq    #0,d7
                    bsr      NEW_SOUND
                    move.w   #4,d3
                    bra      PARMS1_1

PARMS1_1:           tst.w    d1
                    beq      PARMSEND
                    cmp.w    #1,d3
                    bne      PARMS2
                    tst.w    d1
                    blt      PARMS1_2
                    cmp.w    #2,PLAYERS
                    beq      PARMSEND
                    moveq    #1,d7
                    bsr      NEW_SOUND
                    move.w   #2,PLAYERS
                    bra      PARMSEND

PARMS1_2:           cmp.w    #1,PLAYERS
                    beq      PARMSEND
                    moveq    #1,d7
                    bsr      NEW_SOUND
                    move.w   #1,PLAYERS
                    bra      PARMSEND

PARMS2:             cmp.w    #2,d3
                    bne      PARMS3
                    add.w    LEVEL,d1
                    move.w   d1,LEVEL
                    ble      PARMS2_0
                    moveq    #1,d7
                    bsr      NEW_SOUND
                    cmp.w    #8,d1
                    blt      PARMSEND
                    clr.l    d7
                    bsr      NEW_SOUND
                    move.w   #7,LEVEL
                    bra      PARMSEND

PARMS2_0:           move.w   #1,LEVEL
                    bra      PARMSEND

PARMS3:             cmp.w    #3,d3
                    bne      PARMS4
                    add.w    IQ,d1
                    move.w   d1,IQ
                    ble      PARMS3_0
                    moveq    #1,d7
                    bsr      NEW_SOUND
                    cmp.w    #6,d1
                    blt      PARMSEND
                    moveq    #0,d7
                    bsr      NEW_SOUND
                    move.w   #5,IQ
                    bra      PARMSEND

PARMS3_0:           move.w   #1,IQ
                    bra      PARMSEND

PARMS4:             cmp.w    #4,d3
                    bne      PARMSEND
                    tst.w    d1
                    beq      PARMSEND
                    blt      PARMS4_0
                    cmp.w    #1,DRAWSUB
                    beq      PARMSEND
                    moveq    #1,d7
                    bsr      NEW_SOUND
                    move.w   #1,DRAWSUB
                    bra      PARMSEND

PARMS4_0:           tst.w    DRAWSUB
                    beq      PARMSEND
                    moveq    #1,d7
                    bsr      NEW_SOUND
                    clr.w    DRAWSUB
                    bra      PARMSEND

PARMSEND:           movem.l  d0-d7/a0-a6,-(sp)
                    move.w   #2,SEL_FLAG
                    bsr      DRAWSEL
                    bsr      PARADROP
                    addq.w   #1,DEMO
                    bsr      SWAPSCREEN
                    movem.l  (sp)+,d0-d7/a0-a6
                    addq.w   #1,COUNTER
                    cmp.w    #256,DEMO
                    bne.b    .WAIT
                    bsr      PLAYINIT0
                    move.w   #1,S1AUTO
                    move.w   #1,S2AUTO
                    movem.l  d0-d7/a0-a6,-(sp)
                    bsr      CLEANTRAIL
                    bsr      DO_GAME
                    movem.l  (sp)+,d0-d7/a0-a6
                    move.w   #1,d3
                    clr.w    DEMO
.WAIT:              tst.w    ABORT
                    bne      PARMSRET
                    bra      PARMS1

PARMSRET:           clr.w    DEMO
                    rts

DO_GAME:            bsr      CLEAROUTCRAP
                    clr.w    DIE_ONCE1
                    clr.w    DIE_ONCE2
                    move.w   #4,COUNTER
                    clr.w    B1TIME
                    clr.w    B2TIME
                    move.w   #$700,S1CT
                    move.w   #$700,S2CT
DO_GAME_AGAIN:      tst.w    ABORT
                    beq      NOT_YET
                    clr.w    ABORT
                    rts

NOT_YET:            clr.w    FEET_FLAG
                    clr.w    d0
                    move.w   S1CT,d1
                    bsr      BUSY
DO1_0:              move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    bsr      SETWINDOW
                    move.w   S1CT,OLD_BUSY
                    tst.w    S1CT
                    bne      _CHECKMEET
                    tst.w    JOY1TRIG
                    bne      _CHECKMEET
                    clr.w    S1FLASH
                    bsr      MOVE
_CHECKMEET:         bsr      CHECKMEET
                    move.w   SPYX,S1MAPX
                    move.w   SPYY,S1MAPY
                    move.w   SPYX,d1
                    lsr.w    #2,d1
                    move.w   d1,S1CELLX
                    move.w   SPYY,d1
                    lsr.w    #2,d1
                    move.w   d1,S1CELLY
                    bsr      GETWINDOW
                    tst.w    OLD_BUSY
                    bne      DO2_0
                    tst.w    S1DEAD
                    bne      DO2_0
                    bsr      DIRFIX
                    tst.w    JOY1TRIG
                    beq      DO2_0
                    clr.w    S1F
DO2_0:              move.w   #1,d0
                    move.w   S2CT,d1
                    bsr      BUSY
                    move.w   S2CT,OLD_BUSY
DO2_1:              move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
                    bsr      SETWINDOW
                    tst.w    S2CT
                    bne      _CHECKMEET0
                    tst.w    JOY2TRIG
                    bne      _CHECKMEET0
                    clr.w    S2FLASH
                    bsr      MOVE
_CHECKMEET0:        bsr      CHECKMEET
                    move.w   SPYX,S2MAPX
                    move.w   SPYY,S2MAPY
                    move.w   SPYX,d1
                    lsr.w    #2,d1
                    move.w   d1,S2CELLX
                    move.w   SPYY,d1
                    lsr.w    #2,d1
                    move.w   d1,S2CELLY
                    bsr      GETWINDOW
                    tst.w    OLD_BUSY
                    bne      DO3_0
                    tst.w    S2DEAD
                    bne      DO3_0
                    bsr      DIRFIX
                    tst.w    JOY2TRIG
                    beq      DO3_0
                    clr.w    S2F
DO3_0:              bsr      DRAWMOVE
lbC0031E0:          cmp.w    #3,FERDINAND
                    blt.b    lbC0031E0
                    bsr      SWAPSCREEN
                    clr.w    FERDINAND
WAITFLY:            move.w   #7,d1
                    and.w    COUNTER,d1
                    bne      DO4_0
                    tst.w    TENMINS
                    bne      lbC003220
                    tst.w    ONEMINS
                    bne      lbC003220
                    moveq    #8,d7
                    bsr      NEW_SOUND
lbC003220:          move.w   #1,d1
                    sub.w    d1,ONESECS
                    bge      DO4_0
                    move.w   #9,ONESECS
                    sub.w    d1,TENSECS
                    bge      DO4_0
                    move.w   #5,TENSECS
                    sub.w    d1,ONEMINS
                    bge      DO4_0
                    move.w   #9,ONEMINS
                    sub.w    d1,TENMINS
DO4_0:              move.w   S1CT,d1
                    or.w     S2CT,d1
                    bne      lbC003284
                    move.w   S1DEAD,d1
                    add.w    S2DEAD,d1
                    cmp.w    #2,d1
                    beq      TIMEGONE
lbC003284:          move.w   TENMINS,d1
                    add.w    ONEMINS,d1
                    add.w    TENSECS,d1
                    add.w    ONESECS,d1
                    beq      TIMEGONE
                    addq.w   #1,COUNTER
                    cmp.w    #$30,S1HAND
                    bne      DO5_0
                    move.w   S1MAPX,d0
                    lsr.w    #2,d0
                    sub.w    XSUB,d0
                    bge      lbC0032C6
                    neg.w    d0
lbC0032C6:          cmp.w    #1,d0
                    bgt      DO5_0
                    move.w   S1MAPY,d0
                    lsr.w    #2,d0
                    sub.w    YSUB,d0
                    bge      lbC0032E2
                    neg.w    d0
lbC0032E2:          cmp.w    #1,d0
                    bgt      DO5_0
                    clr.w    d0
                    bra      DO6_0

DO5_0:              cmp.w    #$30,S2HAND
                    bne      DO_GAMEEND
                    move.w   S2MAPX,d0
                    lsr.w    #2,d0
                    sub.w    XSUB,d0
                    bge      lbC003310
                    neg.w    d0
lbC003310:          cmp.w    #1,d0
                    bgt      DO_GAMEEND
                    move.w   S2MAPY,d0
                    lsr.w    #2,d0
                    sub.w    YSUB,d0
                    bge      lbC00332C
                    neg.w    d0
lbC00332C:          cmp.w    #1,d0
                    bgt      DO_GAMEEND
                    move.w   #1,d0
DO6_0:              clr.w    TENMINS
                    clr.w    ONEMINS
                    clr.w    TENSECS
                    clr.w    ONESECS
                    beq      SUBGIRL
DO_GAMEEND:         cmp.w    #40,DEMO
                    bne      lbC003362
                    rts

lbC003362:          clr.w    LOOPTIME
                    bra      DO_GAME_AGAIN

READPIX:            move.l   a0,d1
                    move.l   SCREEN2,d2
                    bsr      DECO_PIC
                    move.l   SCREEN2,a0
                    lea      128(a0),a0
                    move.l   BACK,a1
                    bsr      ATARI_COPY
                    move.l   SCREEN2,a0
                    addq.w   #4,a0
                    move.w   (a0),d7
                    bsr      COLOUR_COPY
                    move.w   #0,$DFF180
                    move.w   #$F22,$DFF18E
                    rts

STUFFIT:            tst.w    d1
                    beq      STUFFITEND
                    bsr      GETRAND
                    lea      TERRAIN,a2
                    move.w   SLABY,d3
                    lsl.w    #5,d3
                    add.w    d3,a2
                    add.w    d3,d3
                    add.w    d3,a2
                    add.w    SLABX,a2
                    moveq    #0,d3
                    move.b   (a2),d3
                    cmp.w    #$20,d3
                    blt      lbC0033E8
                    cmp.w    #$26,d3
                    blt.b    STUFFIT
lbC0033E8:          cmp.w    #$1A,d3
                    blt      lbC0033FA
                    cmp.w    #$1C,d3
                    bgt      lbC0033FA
                    bra.b    STUFFIT

lbC0033FA:          move.l   a0,a3
                    tst.b    -1(a3)
                    bne.b    STUFFIT
                    tst.b    1(a3)
                    bne.b    STUFFIT
                    sub.l    #$60,a3
                    tst.b    -1(a3)
                    bne.b    STUFFIT
                    tst.b    (a3)
                    bne.b    STUFFIT
                    tst.b    1(a3)
                    bne.b    STUFFIT
                    add.l    #$C0,a3
                    tst.b    -1(a3)
                    bne.b    STUFFIT
                    tst.b    (a3)
                    bne.b    STUFFIT
                    tst.b    1(a3)
                    bne      STUFFIT
                    move.b   d2,(a0)
                    subq.w   #1,d1
                    addq.w   #1,COUNTER
                    bra      STUFFIT

STUFFITEND:         rts

STUFFSPY:           movem.l  d0-d5,-(sp)
                    bsr      GETRAND
                    lea      S1MAPX,a1
                    lea      S1MAPY,a2
                    bsr      SETXY
                    move.w   S1MAPX,d5
                    add.w    d5,d5
                    add.w    d5,d5
                    addq.w   #1,d5
                    move.w   d5,S1MAPX
                    move.w   S1MAPY,d0
                    add.w    d0,d0
                    add.w    d0,d0
                    move.w   d0,S1MAPY
                    and.w    #$FFF0,d0
                    move.w   d0,WIN1Y
                    sub.w    #13,d5
                    move.w   d5,WIN1X
STUFFSPY1:          bsr      GETRAND
                    lea      S2MAPX,a1
                    lea      S2MAPY,a2
                    bsr      SETXY
                    move.w   S2MAPX,d5
                    add.w    d5,d5
                    add.w    d5,d5
                    addq.w   #1,d5
                    move.w   d5,S2MAPX
                    move.w   S2MAPY,d0
                    add.w    d0,d0
                    add.w    d0,d0
                    move.w   d0,S2MAPY
                    and.w    #$FFF0,d0
                    move.w   d0,WIN2Y
                    sub.w    #13,d5
                    move.w   d5,WIN2X
                    move.w   S1MAPY,d0
                    move.w   S2MAPY,d1
                    lsr.w    #4,d0
                    lsr.w    #4,d1
                    cmp.w    d0,d1
                    bgt      lbC003510
                    move.w   S1MAPX,d0
                    sub.w    S2MAPX,d0
                    bge      lbC003506
                    neg.w    d0
lbC003506:          cmp.w    #$32,d0
                    bgt      lbC003510
                    bra.b    STUFFSPY1

lbC003510:          movem.l  (sp)+,d0-d5
                    rts

TIMEGONE:           clr.w    DEMO
                    bsr      SETUP_VOLCANO
                    bsr      COPY_COLOURS
                    move.w   #2,SOUNDCT
                    move.l   #$10009,d7
                    bsr      NEW_SOUND
                    move.w   #0,d1
TIME2:              move.w   #11-1,d0
TIMEGONE1:          movem.l  d0/d1,-(sp)
                    move.l   BACK,a0
                    move.l   SCREEN2,a1
                    move.w   #(200*40)-1,d1
lbC003552:          move.l   (a0)+,(a1)+
                    dbra     d1,lbC003552
                    add.w    #1,d0
                    bsr      GET_RANDOM
                    and.w    #3,d0
                    mulu     #40,d0
                    move.w   #4000-1,d1
                    move.l   SCREEN2,a0
                    move.l   a0,a1
                    add.w    d0,a1
                    lsr.w    #1,d0
                    sub.w    d0,d1
lbC00357A:          move.w   (a1)+,(a0)+
                    move.w   (200*40)-2(a1),(200*40)-2(a0)
                    move.w   (200*2*40)-2(a1),(200*2*40)-2(a0)
                    move.w   (200*3*40)-2(a1),(200*3*40)-2(a0)
                    dbra     d1,lbC00357A
                    movem.l  d0-d2/a0-a2,-(sp)
                    bsr      SWAPSCREEN
                    bsr      COPY_COLOURS
                    movem.l  (sp)+,d0-d2/a0-a2
                    movem.l  (sp)+,d0/d1
                    dbra     d0,TIMEGONE1
                    move.l   d1,-(sp)
                    cmp.w    #3,d1
                    bhi      NO_FRAME
                    add.w    d1,d1
                    add.w    d1,d1
                    lea      VOLCS,a1
                    move.l   0(a1,d1.w),a1
                    move.l   BACK,a0
                    move.w   #$7F,d1
                    move.w   #12,d2
                    move.w   #4,d6
                    move.w   #$2D,d7
                    bsr      RSPRITER
                    bra      DONE_FRAME

NO_FRAME:           move.l   (sp)+,d1
                    cmp.w    #5,d1
                    bne      lbC0035FC
                    move.w   #$D00,COL1A
                    move.w   #$D55,COL1B
                    bra      _NEXT_VOL

lbC0035FC:          cmp.w    #7,d1
                    bne      lbC003618
                    move.w   #$900,COL2A
                    move.w   #$B30,COL2B
                    bra      _NEXT_VOL

lbC003618:          cmp.w    #9,d1
                    bne      _NEXT_VOL
                    move.w   #$F00,COL3A
                    move.w   #$F55,COL3B
_NEXT_VOL:          bra      NEXT_VOL

DONE_FRAME:         move.l   (sp)+,d1
NEXT_VOL:           addq.w   #1,d1
                    cmp.w    #15,d1
                    bne      TIME2
                    move.w   #11,d2
                    move.w   #4,d1
                    move.w   #12,d6
                    move.w   #$40,d7
                    move.l   BACK,a0
                    lea      VOLCANOE,a1
                    bsr      RDRAW_BUFF
                    bsr      SETUP_VOLCANO
                    bra      COPY_COLOURS

VOLCS:              dc.l     VOLTOP
                    dc.l     lbB03389C
                    dc.l     lbB033E3C
                    dc.l     lbB0343DC

SETUP_VOLCANO:      move.w   #$7B3,COL1A
                    move.w   #$7B3,COL1B
                    move.w   #$590,COL2A
                    move.w   #$590,COL2B
                    move.w   #$575,COL3A
                    move.w   #$575,COL3B
                    rts

COPY_COLOURS:       btst     #0,d0
                    bne      lbC0036DE
                    move.w   COL1A,TOP_GREEN
                    move.w   COL1A,$DFF192
                    move.w   COL2A,$DFF194
                    move.w   COL3A,$DFF196
                    rts

lbC0036DE:          move.w   COL1B,TOP_GREEN
                    move.w   COL1B,$DFF192
                    move.w   COL2B,$DFF194
                    move.w   COL3B,$DFF196
                    rts

COL1A:              dc.w     0
COL1B:              dc.w     0
COL2A:              dc.w     0
COL2B:              dc.w     0
COL3A:              dc.w     0
COL3B:              dc.w     0

RNDER:              bsr      GET_RANDOM
                    rts

RNDER2:             move.l   d0,-(sp)
                    bsr      GET_RANDOM
                    move.l   d0,d1
                    move.l   (sp)+,d0
                    rts

GETRAND:            move.w   d1,-(sp)
lbC003728:          lea      MAP,a0
                    bsr.b    RNDER
                    and.w    #1,d0
                    move.w   d0,d1
                    bsr.b    RNDER
                    and.w    #3,d0
                    add.w    d1,d0
                    move.w   d0,SLABY
                    mulu     #384,d0
                    add.w    d0,a0
                    bsr.b    RNDER
                    move.w   d2,d3
                    and.w    #$F8,d3
                    cmp.w    #$A8,d3
                    beq      lbC003762
                    and.w    #3,d0
                    bra      lbC003768

lbC003762:          and.w    #1,d0
                    addq.w   #2,d0
lbC003768:          mulu     #96,d0
                    add.w    d0,a0
                    bsr.b    RNDER
                    and.w    #$3E,d0
                    move.w   d0,d1
                    add.w    d0,a0
                    bsr.b    RNDER
                    and.w    #$1E,d0
                    add.w    d0,d1
                    move.w   d1,SLABX
                    add.w    d0,a0
                    tst.b    (a0)
                    bne.b    lbC003728
                    move.l   a0,d0
                    move.w   (sp)+,d1
                    rts

SETXY:              move.l   a0,d0
                    sub.l    #MAP,d0
                    divu     #96,d0
                    move.w   d0,(a2)
                    swap     d0
                    move.w   d0,(a1)
                    rts

CLEAROUTCRAP:       moveq    #-1,d0
                    lea      L_TENMINS,a0
                    move.l   d0,(a0)
                    move.l   d0,4(a0)
                    move.l   d0,8(a0)
                    move.l   d0,12(a0)
                    move.l   d0,16(a0)
                    move.l   d0,20(a0)
                    rts

FERDINAND:          dc.w     0
L_TENMINS:          dc.l     0
L_ONEMINS:          dc.l     0
L_TENSECS:          dc.l     0
L_ONESECS:          dc.l     0
L_S1FUEL:           dc.l     0
L_S2FUEL:           dc.l     0
SLABX:              dc.w     0
SLABY:              dc.w     0
OLD_BUSY:           dc.w     0
INT_REQ:            dc.w     0
SAVE_INT3:          dc.l     0

DRAWSPY:            tst.w    d0
                    bne      DRAWSPY2_0
                    move.w   SPYWIN,d1
                    cmp.w    #2,d1
                    beq      DRAWSPY3_0
                    moveq    #0,d2
                    move.w   S1MAPX,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d4
                    bne      DRAWSPY1_2
                    move.w   S1MAPX,d2
                    sub.w    WIN1X,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    #48,d2
                    move.w   d2,X
                    moveq    #0,d2
                    move.w   S1MAPY,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d5
                    bne      DRAWSPY1_2
                    move.w   S1MAPY,d2
                    sub.w    WIN1Y,d2
                    move.w   d2,Y
                    add.w    d2,d2
                    add.w    Y,d2
                    lsr.w    #1,d2
                    add.w    #16,d2
                    add.w    S1SWAMP,d2
                    add.w    S1DEPTH,d2
                    sub.w    S1ALTITUDE,d2
                    move.w   d2,Y
                    move.l   #632,d2
                    mulu     S1F,d2
                    add.l    S1FADDR,d2
                    move.w   #2,WIDTH
                    move.w   #39,d3
                    sub.w    S1SWAMP,d3
                    sub.w    S1DEPTH,d3
                    sub.w    #2,d3
                    move.w   d3,HEIGHT
                    move.l   d2,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   X,S1PLOTX
                    move.w   Y,S1PLOTY
                    move.w   Y,-(sp)
                    move.w   X,-(sp)
                    movem.l  d0,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0
                    move.w   (sp)+,X
                    move.w   (sp)+,Y
                    bsr      DRAWHANDS
DRAWSPY1_2:         move.w   SPYWIN,d1
                    cmp.w    #1,d1
                    bne      DRAWSPY3_0
                    moveq    #0,d2
                    move.w   S2MAPX,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d4
                    bne      DRAWSPY2_0
                    move.w   S2MAPX,d2
                    sub.w    WIN1X,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    #48,d2
                    move.w   d2,X
                    moveq    #0,d2
                    move.w   S2MAPY,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d5
                    bne      DRAWSPY2_0
                    move.w   S2MAPY,d2
                    sub.w    WIN1Y,d2
                    move.w   d2,Y
                    add.w    d2,d2
                    add.w    Y,d2
                    lsr.w    #1,d2
                    add.w    #16,d2
                    add.w    S2SWAMP,d2
                    add.w    S2DEPTH,d2
                    sub.w    S2ALTITUDE,d2
                    move.w   d2,Y
                    move.l   #632,d2
                    mulu     S2F,d2
                    add.l    S2FADDR,d2
                    move.w   #2,WIDTH
                    move.w   #39,d3
                    sub.w    S2SWAMP,d3
                    sub.w    S2DEPTH,d3
                    subq.w   #2,d3
                    move.w   d3,HEIGHT
                    move.l   d2,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   X,S2PLOTX
                    move.w   Y,S2PLOTY
                    move.w   Y,-(sp)
                    move.w   X,-(sp)
                    movem.l  d0,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0
                    move.w   (sp)+,X
                    move.w   (sp)+,Y
                    moveq    #1,d0
                    bsr      DRAWHANDS
                    moveq    #0,d0
                    bra      DRAWSPY3_0

DRAWSPY2_0:         move.w   SPYWIN,d1
                    cmp.w    #1,d1
                    beq      DRAWSPY3_0
                    moveq    #0,d2
                    move.w   S2MAPX,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d4
                    bne      DRAWSPY2_1
                    move.w   S2MAPX,d2
                    sub.w    WIN2X,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    #48,d2
                    move.w   d2,X
                    moveq    #0,d2
                    move.w   S2MAPY,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d5
                    bne      DRAWSPY2_1
                    move.w   S2MAPY,d2
                    sub.w    WIN2Y,d2
                    move.w   d2,Y
                    add.w    d2,d2
                    add.w    Y,d2
                    lsr.w    #1,d2
                    add.w    #115,d2
                    add.w    S2SWAMP,d2
                    add.w    S2DEPTH,d2
                    sub.w    S2ALTITUDE,d2
                    move.w   d2,Y
                    move.l   #632,d2
                    mulu     S2F,d2
                    add.l    S2FADDR,d2
                    move.w   #2,WIDTH
                    move.w   #39,d3
                    sub.w    S2SWAMP,d3
                    sub.w    S2DEPTH,d3
                    subq.w   #2,d3
                    move.w   d3,HEIGHT
                    move.l   d2,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   X,S2PLOTX
                    move.w   Y,S2PLOTY
                    move.w   Y,-(sp)
                    move.w   X,-(sp)
                    movem.l  d0,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0
                    move.w   (sp)+,X
                    move.w   (sp)+,Y
                    bsr      DRAWHANDS
DRAWSPY2_1:         move.w   SPYWIN,d1
                    cmp.w    #2,d1
                    bne      DRAWSPY3_0
                    moveq    #0,d2
                    move.w   S1MAPX,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d4
                    bne      DRAWSPY3_0
                    move.w   S1MAPX,d2
                    sub.w    WIN2X,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    #48,d2
                    move.w   d2,X
                    moveq    #0,d2
                    move.w   S1MAPY,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d5
                    bne      DRAWSPY3_0
                    move.w   S1MAPY,d2
                    sub.w    WIN2Y,d2
                    move.w   d2,Y
                    add.w    d2,d2
                    add.w    Y,d2
                    lsr.w    #1,d2
                    add.w    #115,d2
                    add.w    S1SWAMP,d2
                    add.w    S1DEPTH,d2
                    sub.w    S1ALTITUDE,d2
                    move.w   d2,Y
                    move.l   #632,d2
                    mulu     S1F,d2
                    add.l    S1FADDR,d2
                    move.w   #2,WIDTH
                    move.w   #39,d3
                    sub.w    S1SWAMP,d3
                    sub.w    S1DEPTH,d3
                    subq.w   #2,d3
                    move.w   d3,HEIGHT
                    move.l   d2,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   X,S1PLOTX
                    move.w   Y,S1PLOTY
                    move.w   Y,-(sp)
                    move.w   X,-(sp)
                    movem.l  d0,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0
                    move.w   (sp)+,X
                    move.w   (sp)+,Y
                    moveq    #0,d0
                    bsr      DRAWHANDS
                    moveq    #1,d0
DRAWSPY3_0:         rts

DRAWHANDS:          movem.l  d0-d3/a0,-(sp)
                    lea      OBJS,a0
                    tst.w    d0
                    bne      DRAWHANDS1
                    tst.w    S1CT
                    bne      DRAWHANDSEND
                    cmp.w    #5,S1DEPTH
                    bge      DRAWHANDSEND
                    cmp.w    #5,S1SWAMP
                    bge      DRAWHANDSEND
                    move.w   S1HAND,d2
                    move.l   S1FADDR,d1
                    cmp.l    #BUF14,d1
                    bne      lbC003C58
                    addq.w   #7,X
                    add.w    #22,Y
                    bra      DRAWHANDS2

lbC003C58:          cmp.l    #BUF13,d1
                    beq      DRAWHANDS3
                    add.w    #17,X
                    add.w    #21,Y
                    cmp.l    #BUF12,d1
                    bne      DRAWHANDS2
                    sub.w    #17,X
                    lea      OBJS2,a0
                    bra      DRAWHANDS2

DRAWHANDS1:         tst.w    S2CT
                    bne      DRAWHANDSEND
                    cmp.w    #5,S2DEPTH
                    bge      DRAWHANDSEND
                    cmp.w    #5,S2SWAMP
                    bge      DRAWHANDSEND
                    move.w   S2HAND,d2
                    move.l   S2FADDR,d1
                    cmp.l    #BUF24,d1
                    bne      lbC003CDA
                    addq.w   #7,X
                    add.w    #22,Y
                    bra      DRAWHANDS2

lbC003CDA:          cmp.l    #BUF23,d1
                    beq      DRAWHANDS3
                    add.w    #17,X
                    add.w    #21,Y
                    cmp.l    #BUF22,d1
                    bne      DRAWHANDS2
                    sub.w    #17,X
                    lea      OBJS2,a0
DRAWHANDS2:         move.w   d2,d1
                    lsr.w    #3,d1
                    beq      DRAWHANDSEND
                    mulu     #168,d1
                    add.l    a0,d1
                    move.l   d1,BUFFER
                    move.w   #2,WIDTH
                    move.w   #8,HEIGHT
                    move.l   SCREEN2,SCREEN
                    bsr      SPRITER_AM
                    bra      DRAWHANDSEND

DRAWHANDS3:         move.w   d2,d1
                    lsr.w    #3,d1
                    cmp.w    #4,d1
                    blt      DRAWHANDSEND
                    cmp.w    #6,d1
                    bgt      DRAWHANDSEND
                    move.w   X,d2
                    addq.w   #8,d2
                    move.w   d2,X
                    move.w   Y,d2
                    add.w    #20,d2
                    move.w   d2,Y
                    move.l   #OBJS2,BUFFER
                    add.l    #3024,BUFFER
                    move.w   #2,WIDTH
                    move.w   #8,HEIGHT
                    move.l   SCREEN2,SCREEN
                    bsr      SPRITER_AM
                    bra      DRAWHANDSEND

DRAWHANDSEND:       movem.l  (sp)+,d0-d3/a0
                    rts

DRAWBUTTONS:        tst.w    d0
                    bne      DRAWBUTTONS1
                    move.w   #10,d1
                    lea      S1SHOV,a0
                    lea      S1GUN,a1
                    lea      S1COCO,a2
                    lea      S1ROPE,a3
                    lea      S1NAPA,a4
                    move.w   S1FLASH,d4
                    beq      DRAWBUTTONS2
                    move.w   S1MENU,d4
                    bra      DRAWBUTTONS2

DRAWBUTTONS1:       move.w   #$6D,d1
                    lea      S2SHOV,a0
                    lea      S2GUN,a1
                    lea      S2COCO,a2
                    lea      S2ROPE,a3
                    lea      S2NAPA,a4
                    move.w   S2FLASH,d4
                    beq      DRAWBUTTONS2
                    move.w   S2MENU,d4
DRAWBUTTONS2:       move.w   COUNTER,d5
                    and.w    #1,d5
                    move.w   #48,d2
                    cmp.w    #1,d4
                    bne      DRAWBUTTONS2_A
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_B

DRAWBUTTONS2_A:     move.w   (a0),d3
DRAWBUTTONS2_B:     bsr      ONEBUTTON
                    add.w    #11,d1
                    cmp.w    #2,d4
                    bne      DRAWBUTTONS2_0
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_1

DRAWBUTTONS2_0:     move.w   (a1),d3
DRAWBUTTONS2_1:     bsr      ONEBUTTON
                    add.w    #11,d1
                    cmp.w    #3,d4
                    bne      DRAWBUTTONS2_2
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_3

DRAWBUTTONS2_2:     move.w   (a2),d3
DRAWBUTTONS2_3:     bsr      ONEBUTTON
                    add.w    #11,d1
                    cmp.w    #4,d4
                    bne      DRAWBUTTONS2_4
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_5

DRAWBUTTONS2_4:     move.w   (a3),d3
DRAWBUTTONS2_5:     bsr      ONEBUTTON
                    add.w    #11,d1
                    cmp.w    #5,d4
                    bne      DRAWBUTTONS2_6
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_7

DRAWBUTTONS2_6:     move.w   (a4),d3
DRAWBUTTONS2_7:     bsr      ONEBUTTON
                    add.w    #11,d1
                    cmp.w    #6,d4
                    bne      DRAWBUTTONS2_8
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_9

DRAWBUTTONS2_8:     move.w   #1,d3
DRAWBUTTONS2_9:     ;bsr      ONEBUTTON
                    ;rts
                    ; no rts

ONEBUTTON:          movem.l  d0-d5/a0-a4,-(sp)
                    move.w   d1,Y
                    move.w   d2,X
                    move.l   SCREEN2,SCREEN
                    move.w   #2,WIDTH
                    move.w   #11,HEIGHT
                    tst.w    d3
                    bne      ONEBUTTON1
                    move.l   #ITEMOFF,BUFFER
                    bra      ONEBUTTON2

ONEBUTTON1:         move.l   #ITEMON,BUFFER
ONEBUTTON2:         move.w   #$9F0,MINTERMS
                    bsr      SPRITER_AM
                    move.w   #$FE2,MINTERMS
                    movem.l  (sp)+,d0-d5/a0-a4
                    rts

SWAPSCREEN:         jmp      SWAP_SCREEN

DRAWTIME:           move.l   SCREEN2,a0
                    add.w    #$8BA,a0
                    move.w   TENMINS,d0
                    lea      L_TENMINS,a6
                    bsr      COMPARETWICE
                    beq      lbC003F4A
                    bsr      NEXTCHAR
lbC003F4A:          addq.w   #1,a0
                    move.w   ONEMINS,d0
                    lea      L_ONEMINS,a6
                    bsr      COMPARETWICE
                    beq      lbC003F66
                    bsr      NEXTCHAR
lbC003F66:          addq.w   #2,a0
                    move.w   TENSECS,d0
                    lea      L_TENSECS,a6
                    bsr      COMPARETWICE
                    beq      lbC003F82
                    bsr      NEXTCHAR
lbC003F82:          addq.w   #1,a0
                    move.w   ONESECS,d0
                    lea      L_ONESECS,a6
                    bsr      COMPARETWICE
                    beq      lbC003F9E
                    bra      NEXTCHAR
lbC003F9E:          rts

HLINE:              movem.l  d0-d7/a0-a6,-(sp)
                    move.w   COLOR,d7
                    move.w   X,a2
                    move.w   a2,a3
                    add.w    COUNT,a3
                    move.l   SCREEN,a0
                    move.w   Y,d2
                    bsr      HORLINE
                    movem.l  (sp)+,d0-d7/a0-a6
                    rts

METER:              move.w   COUNTER,d0
                    and.w    #7,d0
                    bne      METER0_1
                    move.w   S1CT,d3
                    lsr.w    #8,d3
                    cmp.w    #11,d3
                    blt      lbC003FF4
                    cmp.w    #21,d3
                    ble      METER0_1
lbC003FF4:          tst.w    S1ENERGY
                    blt      METER0_1
                    cmp.w    #100,S1ENERGY
                    beq      METER0_1
                    tst.w    S1DEAD
                    bne      METER0_1
                    addq.w   #1,S1ENERGY
                    move.w   #2,REFRESH
METER0_1:           tst.w    REFRESH
                    beq      METER1_0
                    move.w   #9,d1
                    move.w   #87,d2
                    move.l   SCREEN2,a0
                    lea      STREN,a1
                    move.w   #7,d6
                    move.w   #5,d7
                    bsr      RDRAW_BUFF
                    move.w   #5-1,d0
                    move.w   #148,d1
                    add.w    S1ENERGY,d1
                    move.w   d1,X
                    move.w   #100,d1
                    sub.w    S1ENERGY,d1
                    move.w   d1,COUNT
                    move.w   #87,Y
                    move.w   #15,COLOR
METER1:             move.w   X,-(sp)
                    move.w   COUNT,-(sp)
                    bsr      HLINE
                    move.w   (sp)+,COUNT
                    move.w   (sp)+,X
                    move.w   #1,d1
                    add.w    d1,Y
                    dbra     d0,METER1
METER1_0:           move.w   S2CT,d3
                    lsr.w    #8,d3
                    cmp.w    #11,d3
                    blt      lbC0040C2
                    cmp.w    #21,d3
                    ble      METER1_1
lbC0040C2:          move.w   COUNTER,d0
                    and.w    #7,d0
                    bne      METER1_1
                    tst.w    S2ENERGY
                    blt      METER1_1
                    move.w   S2ENERGY,d0
                    cmp.w    #100,d0
                    beq      METER1_1
                    tst.w    S2DEAD
                    bne      METER0_1
                    add.w    #1,d0
                    move.w   d0,S2ENERGY
                    move.w   #2,REFRESH
METER1_1:           tst.w    REFRESH
                    beq      METER2_0
                    move.w   #9,d1
                    move.w   #186,d2
                    move.l   SCREEN2,a0
                    lea      STREN,a1
                    move.w   #7,d6
                    move.w   #5,d7
                    bsr      RDRAW_BUFF
                    move.w   #5-1,d0
                    move.w   #148,d1
                    add.w    S2ENERGY,d1
                    move.w   d1,X
                    move.w   #100,d1
                    sub.w    S2ENERGY,d1
                    move.w   d1,COUNT
                    move.w   #15,COLOR
                    move.w   #186,Y
METER2:             move.w   X,-(sp)
                    move.w   COUNT,-(sp)
                    bsr      HLINE
                    move.w   (sp)+,COUNT
                    move.w   (sp)+,X
                    move.w   #1,d1
                    add.w    d1,Y
                    dbra     d0,METER2
METER2_0:           tst.w    REFRESH
                    beq      METER3
                    move.w   #1,d1
                    sub.w    d1,REFRESH
METER3:             rts

FLASH:              move.w   #2,d6
                    move.w   #8,d7
                    move.w   COUNTER,d3
                    and.w    #1,d3
                    tst.w    d0
                    beq      FLASH0_1
                    move.w   S1HAND,d4
                    move.w   #82,d2
                    bra      FLASH0_2

FLASH0_1:           move.w   S2HAND,d4
                    move.w   #181,d2
FLASH0_2:           lsr.w    #3,d4
                    move.w   #7,d1
                    cmp.w    #3,d4
                    beq      FLASH1_1
                    cmp.w    #4,d4
                    beq      FLASH1_1
                    cmp.w    #6,d4
                    bne      FLASH1_2
FLASH1_1:           tst.w    d3
                    bne      FLASH1_2
                    move.w   #336,a1
                    add.l    #ROCKET,a1
                    bsr      DRAWPIECE
                    bra      FLASH1_3

FLASH1_2:           move.w   #840,a1
                    add.l    #ROCKET,a1
                    bsr      DRAWPIECE
FLASH1_3:           move.w   #6,d1
                    cmp.w    #2,d4
                    beq      FLASH1_4
                    cmp.w    #4,d4
                    beq      FLASH1_4
                    cmp.w    #5,d4
                    beq      FLASH1_4
                    cmp.w    #6,d4
                    beq      FLASH1_4
                    bra      FLASH1_5

FLASH1_4:           tst.w    d3
                    bne      FLASH1_5
                    move.w   #168,a1
                    add.l    #ROCKET,a1
                    bsr      DRAWPIECE
                    bra      FLASH1_6

FLASH1_5:           move.w   #672,a1
                    add.l    #ROCKET,a1
                    bsr      DRAWPIECE
FLASH1_6:           move.w   #5,d1
                    cmp.w    #1,d4
                    beq      FLASH1_7
                    cmp.w    #5,d4
                    beq      FLASH1_7
                    cmp.w    #6,d4
                    beq      FLASH1_7
                    bra      FLASH1_8

FLASH1_7:           tst.w    d3
                    bne      FLASH1_8
                    lea      ROCKET,a1
                    bsr      DRAWPIECE
                    bra      FLASH1_9

FLASH1_8:           move.w   #504,a1
                    add.l    #ROCKET,a1
                    bsr      DRAWPIECE
FLASH1_9:           rts

DRAWPIECE:          move.l   SCREEN2,a0
                    lsl.w    #4,d1
                    move.w   #$9F0,MINTERMS
                    bsr      RSPRITER_AM
                    move.w   #$FE2,MINTERMS
                    rts

DRAWSEL:            tst.w    SEL_FLAG
                    beq      DRAWSEL6
                    movem.l  d0-d3,-(sp)
DRAWSEL1:           move.l   SCREEN2,a0
                    move.w   COUNTER,d0
                    and.w    #2,d0
                    beq      DRAWSEL1_0
                    clr.w    d3
DRAWSEL1_0:         cmp.w    #1,d3
                    beq      DRAWSEL2
                    move.w   #34,d1
                    add.w    PLAYERS,d1
                    move.w   #73,d2
                    move.w   #10,d0
                    bsr      PUTCHAR
DRAWSEL2:           cmp.w    #2,d3
                    beq      DRAWSEL3
                    move.w   #32,d1
                    add.w    LEVEL,d1
                    move.w   #89,d2
                    move.w   #10,d0
                    bsr      PUTCHAR
DRAWSEL3:           cmp.w    #3,d3
                    beq      DRAWSEL4
                    move.w   #33,d1
                    add.w    IQ,d1
                    move.w   #113,d2
                    move.w   #10,d0
                    bsr      PUTCHAR
DRAWSEL4:           cmp.w    #4,d3
                    beq      DRAWSEL5
                    move.w   #35,d1
                    add.w    DRAWSUB,d1
                    move.w   #137,d2
                    move.w   #10,d0
                    bsr      PUTCHAR
DRAWSEL5:           movem.l  (sp)+,d0-d3
DRAWSEL6:           rts

COMPARETWICE:       cmp.w    (a6),d0
                    bne      lbC00437A
                    lea      2(a6),a6
                    cmp.w    (a6),d0
                    bne      lbC00437A
                    rts

lbC00437A:          move.w   d0,(a6)
                    cmp.w    #-2,d0
                    rts

RSPRITER:           movem.l  d0-d7/a0-a2,-(sp)
                    subq.w   #1,d6
                    subq.w   #1,d7
                    move.w   d1,d4
                    and.w    #$F,d4
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    and.w    #$FFF0,d1
                    asr.w    #3,d1
                    add.w    d1,a0
lbC0043A0:          move.l   a0,a2
                    move.w   d6,d0
lbC0043A4:          moveq    #0,d2
                    move.w   (a1),d2
                    or.w     2(a1),d2
                    or.w     4(a1),d2
                    or.w     6(a1),d2
                    ror.l    d4,d2
                    not.l    d2
                    and.w    d2,(a0)
                    and.w    d2,(200*40)(a0)
                    and.w    d2,(200*2*40)(a0)
                    and.w    d2,(200*3*40)(a0)
                    swap     d2
                    and.w    d2,2(a0)
                    and.w    d2,(200*40)+2(a0)
                    and.w    d2,(200*2*40)+2(a0)
                    and.w    d2,(200*3*40)+2(a0)
                    tst.w    d4
                    beq      lbC00441E
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(a0)+
                    swap     d2
                    or.w     d2,(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*40)-2(a0)
                    swap     d2
                    or.w     d2,(200*40)(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*2*40)-2(a0)
                    swap     d2
                    or.w     d2,(200*2*40)(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*3*40)-2(a0)
                    swap     d2
                    or.w     d2,(200*3*40)(a0)
                    bra      lbC004434

lbC00441E:          move.w   (a1)+,d2
                    or.w     d2,(a0)+
                    move.w   (a1)+,d2
                    or.w     d2,(200*40)-2(a0)
                    move.w   (a1)+,d2
                    or.w     d2,(200*2*40)-2(a0)
                    move.w   (a1)+,d2
                    or.w     d2,(200*3*40)-2(a0)
lbC004434:          dbra     d0,lbC0043A4
                    lea      40(a2),a0
                    dbra     d7,lbC0043A0
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RBACKER:            movem.l  d0-d7/a0-a2,-(sp)
                    subq.w   #1,d6
                    subq.w   #1,d7
                    move.w   d1,d4
                    and.w    #$F,d4
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    and.w    #$FFF0,d1
                    asr.w    #3,d1
                    add.w    d1,a0
lbC004464:          move.l   a0,a2
                    move.w   d6,d0
                    clr.w    (a0)
                    clr.w    (200*40)(a0)
                    clr.w    (200*2*40)(a0)
                    clr.w    (200*3*40)(a0)
lbC004476:          tst.w    d4
                    beq      lbC0044BC
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(a0)+
                    swap     d2
                    move.w   d2,(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*40)-2(a0)
                    swap     d2
                    move.w   d2,(200*40)(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*2*40)-2(a0)
                    swap     d2
                    move.w   d2,(200*2*40)(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*3*40)-2(a0)
                    swap     d2
                    move.w   d2,(200*3*40)(a0)
                    bra      lbC0044CA

lbC0044BC:          move.w   (a1)+,(a0)+
                    move.w   (a1)+,(200*40)-2(a0)
                    move.w   (a1)+,(200*2*40)-2(a0)
                    move.w   (a1)+,(200*3*40)-2(a0)
lbC0044CA:          dbra     d0,lbC004476
                    addq.w   #8,a1
                    lea      40(a2),a0
                    dbra     d7,lbC004464
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSAVE_BUFF:         movem.l  d0-d7/a0-a2,-(sp)
                    subq.w   #1,d6
                    subq.w   #1,d7
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    asl.w    #1,d1
                    add.w    d1,a0
lbC0044F2:          move.l   a0,a2
                    move.w   d6,d0
lbC0044F6:          move.w   (a0)+,(a1)+
                    move.w   (200*40)-2(a0),(a1)+
                    move.w   (200*2*40)-2(a0),(a1)+
                    move.w   (200*3*40)-2(a0),(a1)+
                    dbra     d0,lbC0044F6
                    lea      40(a2),a0
                    dbra     d7,lbC0044F2
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RDRAW_BUFF:         movem.l  d0-d7/a0-a2,-(sp)
                    subq.w   #1,d6
                    subq.w   #1,d7
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    asl.w    #1,d1
                    add.w    d1,a0
lbC00452A:          move.l   a0,a2
                    move.w   d6,d0
lbC00452E:          move.w   (a1)+,(a0)+
                    move.w   (a1)+,(200*40)-2(a0)
                    move.w   (a1)+,(200*2*40)-2(a0)
                    move.w   (a1)+,(200*3*40)-2(a0)
                    dbra     d0,lbC00452E
                    lea      40(a2),a0
                    dbra     d7,lbC00452A
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSTUFF_BUFF:        movem.l  d0-d7/a0-a2,-(sp)
                    move.w   d6,d3
                    mulu     d7,d3
                    add.w    d3,d3
                    move.l   d3,(a1)+
                    move.w   d6,(a1)+
                    move.w   d7,(a1)+
                    subq.w   #2,d6
                    subq.w   #1,d7
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    asl.w    #1,d1
                    add.w    d1,a0
lbC00456E:          move.l   a0,a2
                    move.w   d6,d0
lbC004572:          move.w   (a0),d1
                    or.w     (200*40)(a0),d1
                    or.w     (200*2*40)(a0),d1
                    or.w     (200*3*40)(a0),d1
                    move.w   d1,(a1)
                    move.w   d3,d2
                    move.w   (a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*40)(a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*2*40)(a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*3*40)(a0),(a1,d2.w)
                    addq.w   #2,a1
                    addq.w   #2,a0
                    dbra     d0,lbC004572
                    clr.w    (a1)+
                    lea      40(a2),a0
                    dbra     d7,lbC00456E
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSTUFF_BUFF_SHORT:  movem.l  d0-d7/a0-a2,-(sp)
                    move.w   d6,d3
                    mulu     d7,d3
                    add.w    d3,d3
                    move.l   d3,(a1)+
                    move.w   d6,(a1)+
                    move.w   d7,(a1)+
                    subq.w   #1,d6
                    subq.w   #1,d7
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    asl.w    #1,d1
                    add.w    d1,a0
lbC0045D8:          move.l   a0,a2
                    move.w   d6,d0
lbC0045DC:          move.w   d3,d2
                    move.w   (a0),(a1)
                    move.w   (200*40)(a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*2*40)(a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*3*40)(a0),(a1,d2.w)
                    addq.w   #2,a1
                    addq.w   #2,a0
                    dbra     d0,lbC0045DC
                    lea      40(a2),a0
                    dbra     d7,lbC0045D8
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSPRITER_AM:        movem.l  d0-d7/a0-a4,-(sp)
                    move.w   MINTERMS,d5
                    lea      $DFF000,a2
                    move.w   #$8440,$96(a2)
                    move.w   4(a1),d6
                    cmp.w    #$FE2,d5
                    beq      lbC004630
                    subq.w   #1,d6
lbC004630:          lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    move.w   d1,d3
                    and.w    #$F,d3
                    lsr.w    #3,d1
                    and.w    #$FFFE,d1
                    add.w    d1,a0
                    move.l   #-1,$44(a2)
                    ror.w    #4,d3
                    move.w   d3,$42(a2)
                    or.w     d5,d3
                    move.w   d3,$40(a2)
                    move.w   #0,$64(a2)
                    cmp.w    #$FE2,d5
                    beq      lbC004672
                    move.w   #2,$64(a2)
lbC004672:          move.w   #0,$62(a2)
                    move.w   #40,d3
                    sub.w    d6,d3
                    sub.w    d6,d3
                    move.w   d3,$60(a2)
                    move.w   d3,$66(a2)
                    lsl.w    #6,d7
                    or.w     d6,d7
                    move.l   (a1),a3
                    lea      8(a1),a1
                    move.l   a1,a4
                    add.l    a3,a1
                    move.l   a1,$50(a2)
                    move.l   a4,$4C(a2)
                    move.l   a0,$48(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    lea      (200*40)(a0),a0
                    add.l    a3,a1
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a4,$4C(a2)
                    move.l   a0,$48(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    lea      (200*40)(a0),a0
                    add.l    a3,a1
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a4,$4C(a2)
                    move.l   a0,$48(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    lea      (200*40)(a0),a0
                    add.l    a3,a1
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a4,$4C(a2)
                    move.l   a0,$48(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    movem.l  (sp)+,d0-d7/a0-a4
                    rts

SPRITER:            movem.l  d0-d7/a0/a1,-(sp)
                    move.w   WIDTH,d6
                    move.w   HEIGHT,d7
                    move.w   X,d1
                    move.w   Y,d2
                    move.l   SCREEN,a0
                    move.l   BUFFER,a1
                    bsr      RSPRITER
                    movem.l  (sp)+,d0-d7/a0/a1
                    rts

SPRITER_AM:         movem.l  d0-d7/a0/a1,-(sp)
                    move.w   X,d1
                    move.w   Y,d2
                    move.w   HEIGHT,d7
                    move.l   SCREEN,a0
                    move.l   BUFFER,a1
                    bsr      RSPRITER_AM
                    movem.l  (sp)+,d0-d7/a0/a1
                    rts

BACKER:             movem.l  d0-d7/a0/a1,-(sp)
                    move.w   WIDTH,d6
                    move.w   HEIGHT,d7
                    move.w   X,d1
                    move.w   Y,d2
                    move.l   SCREEN,a0
                    move.l   BUFFER,a1
                    bsr      RBACKER
                    movem.l  (sp)+,d0-d7/a0/a1
                    rts

X:                  dc.w     0
Y:                  dc.w     0
WIDTH:              dc.w     0
HEIGHT:             dc.w     0
BUFFER:             dc.l     0
SCREEN:             dc.l     0
MINTERMS:           dc.w     $FE2

PUTCHAR:            movem.l  d2/a0,-(sp)
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    add.w    d1,a0
                    bsr      NEXTCHAR
                    movem.l  (sp)+,d2/a0
                    rts

NEXTCHAR:           movem.l  d1/a0/a1,-(sp)
                    and.w    #$F,d0
                    lsl.w    #5,d0
                    lea      FONT,a1
                    add.w    d0,a1
                    move.w   #8-1,d0
lbC0047DA:          move.b   (a1)+,(a0)
                    move.b   (a1)+,(200*40)(a0)
                    move.b   (a1)+,(200*2*40)(a0)
                    move.b   (a1)+,(200*3*40)(a0)
                    lea      40(a0),a0
                    dbra     d0,lbC0047DA
                    movem.l  (sp)+,d1/a0/a1
                    rts

; plane 1,plane 2,plane 3,plane 4
FONT:               dc.b     %11111101,%00111110,%00111100,%00111100
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11101110,%01110111,%01100110,%01100110
                    dc.b     %11101110,%01110111,%01100110,%01100110
                    dc.b     %11101110,%01110111,%01100110,%01100110
                    dc.b     %11101110,%01110111,%01100110,%01100110
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11111111,%00111100,%00111100,%00111100

                    dc.b     %11111011,%00011100,%00011000,%00011000
                    dc.b     %11111011,%00111100,%00111000,%00111000
                    dc.b     %11111011,%00111100,%00111000,%00111000
                    dc.b     %11111011,%00011100,%00011000,%00011000
                    dc.b     %11111011,%00011100,%00011000,%00011000
                    dc.b     %11111011,%00011100,%00011000,%00011000
                    dc.b     %11111101,%00111110,%00111100,%00111100
                    dc.b     %11111101,%00111110,%00111100,%00111100

                    dc.b     %11111111,%00011100,%00011100,%00011100
                    dc.b     %11111110,%00111111,%00111110,%00111110
                    dc.b     %11101110,%01110111,%01100110,%01100110
                    dc.b     %11111110,%00001111,%00001110,%00001110
                    dc.b     %11111101,%00011110,%00011100,%00011100
                    dc.b     %11111011,%00111100,%00111000,%00111000
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11111110,%01111111,%01111110,%01111110

                    dc.b     %11111101,%00111110,%00111100,%00111100
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11111110,%00000111,%00000110,%00000110
                    dc.b     %11111110,%00011111,%00011110,%00011110
                    dc.b     %11111110,%00011111,%00011110,%00011110
                    dc.b     %11111110,%00000111,%00000110,%00000110
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11111101,%00111110,%00111100,%00111100

                    dc.b     %11111111,%01100000,%01100000,%01100000
                    dc.b     %11101111,%01110000,%01100000,%01100000
                    dc.b     %11101111,%01111100,%01101100,%01101100
                    dc.b     %11101101,%01111110,%01101100,%01101100
                    dc.b     %11101110,%01111111,%01101110,%01101110
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11111101,%00001110,%00001100,%00001100
                    dc.b     %11111101,%00001110,%00001100,%00001100

                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11101111,%01110000,%01100000,%01100000
                    dc.b     %11111111,%01111100,%01111100,%01111100
                    dc.b     %11111110,%00000111,%00000110,%00000110
                    dc.b     %11011110,%01100111,%01000110,%01000110
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11111101,%00111110,%00111100,%00111100

                    dc.b     %11111111,%00011000,%00011000,%00011000
                    dc.b     %11111110,%00111111,%00111110,%00111110
                    dc.b     %11101111,%01110000,%01100000,%01100000
                    dc.b     %11111101,%01111110,%01111100,%01111100
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11101110,%01110111,%01100110,%01100110
                    dc.b     %11111110,%00111111,%00111110,%00111110
                    dc.b     %11111101,%00011110,%00011100,%00011100

                    dc.b     %11111111,%01111110,%01111110,%01111110
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11111110,%00000111,%00000110,%00000110
                    dc.b     %11110110,%00000111,%00000110,%00001110
                    dc.b     %11111100,%00001101,%00001100,%00001110
                    dc.b     %11101101,%00001110,%00001100,%00011100
                    dc.b     %11111101,%00011110,%00011100,%00011100
                    dc.b     %11111011,%00011100,%00011000,%00011000

                    dc.b     %11111101,%00111110,%00111100,%00111100
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11101110,%01110111,%01100110,%01100110
                    dc.b     %11111101,%00111110,%00111100,%00111100
                    dc.b     %11111101,%00111110,%00111100,%00111100
                    dc.b     %11101110,%01110111,%01100110,%01100110
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11111101,%00111110,%00111100,%00111100

                    dc.b     %11111111,%00111110,%00111110,%00111110
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11101110,%01110111,%01100110,%01100110
                    dc.b     %11111110,%01111111,%01111110,%01111110
                    dc.b     %11111110,%00111111,%00111110,%00111110
                    dc.b     %11111110,%00000111,%00000110,%00000110
                    dc.b     %11111110,%00000111,%00000110,%00000110
                    dc.b     %11111110,%00000111,%00000110,%00000110

                    dc.b     %00000000,%11111111,%01111000,%01111000
                    dc.b     %00000000,%11111111,%11111100,%11111100
                    dc.b     %00000000,%11111111,%11111100,%11111100
                    dc.b     %00000000,%11111111,%11111100,%11111100
                    dc.b     %00000000,%11111111,%11111100,%11111100
                    dc.b     %00000000,%11111111,%11111100,%11111100
                    dc.b     %00000000,%11111111,%01111000,%01111000
                    dc.b     %00000000,%11111111,%00000000,%00000000

CALCAD:             movem.l  d1/d2,-(sp)
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    move.w   d1,d6
                    lsr.w    #3,d1
                    and.w    #$FFFE,d1
                    add.w    d1,a0
                    and.w    #$F,d6
                    add.w    d6,d6
                    move.w   BITTAB(pc,d6.w),d6
                    movem.l  (sp)+,d1/d2
                    rts

BITTAB:             dc.w     %1000000000000000
                    dc.w     %0100000000000000
                    dc.w     %0010000000000000
                    dc.w     %0001000000000000
                    dc.w     %0000100000000000
                    dc.w     %0000010000000000
                    dc.w     %0000001000000000
                    dc.w     %0000000100000000
                    dc.w     %0000000010000000
                    dc.w     %0000000001000000
                    dc.w     %0000000000100000
                    dc.w     %0000000000010000
                    dc.w     %0000000000001000
                    dc.w     %0000000000000100
                    dc.w     %0000000000000010
                    dc.w     %0000000000000001

PLOTPOINT:          and.w    d6,(a0)
                    and.w    d6,(200*40)(a0)
                    and.w    d6,(200*2*40)(a0)
                    and.w    d6,(200*3*40)(a0)
                    or.w     d1,(a0)
                    or.w     d2,(200*40)(a0)
                    or.w     d3,(200*2*40)(a0)
                    or.w     d4,(200*3*40)(a0)
                    rts

LEFT_RIGHT:         tst.w    GO_LEFT
                    bne      BACKWARDS
                    ror.w    #1,d1
                    ror.w    #1,d2
                    ror.w    #1,d3
                    ror.w    #1,d4
                    ror.w    #1,d6
                    bcs      LR_RET
                    addq.w   #2,a0
                    rts

BACKWARDS:          rol.w    #1,d1
                    rol.w    #1,d2
                    rol.w    #1,d3
                    rol.w    #1,d4
                    rol.w    #1,d6
                    bcs      LR_RET
                    subq.w   #2,a0
LR_RET:             rts

UP_DOWN:            tst.w    GO_UP
                    bne      UPWARDS
                    lea      40(a0),a0
                    rts

UPWARDS:            lea      -40(a0),a0
                    rts

DRAW_LINE:          movem.l  d0-d7/a0-a2,-(sp)
                    moveq    #0,d5
                    bsr      CALCAD
                    move.w   d3,d0
                    sub.w    d1,d0
                    bpl      lbC004A04
                    neg.w    d0
                    move.w   #-1,GO_LEFT
                    bra      lbC004A0A

lbC004A04:          clr.w    GO_LEFT
lbC004A0A:          move.w   d4,d5
                    sub.w    d2,d5
                    bpl      lbC004A20
                    neg.w    d5
                    move.w   #-1,GO_UP
                    bra      lbC004A26

lbC004A20:          clr.w    GO_UP
lbC004A26:          addq.w   #1,d5
                    addq.w   #1,d0
                    lsl.w    #8,d5
                    divu     d0,d5
                    and.l    #$FFFF,d5
                    lsl.l    #8,d5
SETUPCOLOUR:        clr.w    d1
                    clr.w    d2
                    clr.w    d3
                    clr.w    d4
                    ror.w    #1,d7
                    bcc      lbC004A4E
                    move.w   d6,d1
lbC004A4E:          ror.w    #1,d7
                    bcc      lbC004A56
                    move.w   d6,d2
lbC004A56:          ror.w    #1,d7
                    bcc      lbC004A5E
                    move.w   d6,d3
lbC004A5E:          ror.w    #1,d7
                    bcc      lbC004A66
                    move.w   d6,d4
lbC004A66:          not.w    d6
                    moveq    #0,d7
MORE_POINTS:        bsr      PLOTPOINT
                    add.l    d5,d7
                    swap     d7
                    tst.w    d7
                    beq      DONE_POINT
_UP_DOWN:           bsr      UP_DOWN
                    bsr      PLOTPOINT
                    subq.w   #1,d7
                    bne.b    _UP_DOWN
DONE_POINT:         bsr      LEFT_RIGHT
                    swap     d7
                    subq.w   #1,d0
                    bne.b    MORE_POINTS
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

GO_LEFT:            dc.w     0
GO_UP:              dc.w     0

HORLINE:            movem.l  d0-d5/a0,-(sp)
                    move.w   a3,d4
                    move.w   a2,d0
                    sub.w    d0,d4
                    addq.w   #1,d4
                    move.w   a2,d1
                    bsr      POINT
                    move.w   d1,d5
                    and.w    #$F,d5
                    beq      GOT_BOUNDARY_STRAIGHT
EARLY:              tst.w    d4
                    beq      DONE_LINE
                    move.w   d1,d5
                    and.w    #$F,d5
                    beq      GOT_BOUNDARY
                    move.w   d7,d0
                    ror.w    #1,d0
                    bcc      lbC004AF2
                    or.w     d3,(a0)
                    bra      lbC004AF8

lbC004AF2:          not.w    d3
                    and.w    d3,(a0)
                    not.w    d3
lbC004AF8:          ror.w    #1,d0
                    bcc      lbC004B06
                    or.w     d3,(200*40)(a0)
                    bra      lbC004B0E

lbC004B06:          not.w    d3
                    and.w    d3,(200*40)(a0)
                    not.w    d3
lbC004B0E:          ror.w    #1,d0
                    bcc      lbC004B1C
                    or.w     d3,(200*2*40)(a0)
                    bra      lbC004B24

lbC004B1C:          not.w    d3
                    and.w    d3,(200*2*40)(a0)
                    not.w    d3
lbC004B24:          ror.w    #1,d0
                    bcc      lbC004B32
                    or.w     d3,(200*3*40)(a0)
                    bra      lbC004B3A

lbC004B32:          not.w    d3
                    and.w    d3,(200*3*40)(a0)
                    not.w    d3
lbC004B3A:          lsr.w    #1,d3
                    addq.w   #1,d1
                    subq.w   #1,d4
                    bra.b    EARLY

GOT_BOUNDARY:       addq.w   #2,a0
GOT_BOUNDARY_STRAIGHT:
                    cmp.w    #15,d4
                    ble      LATER
                    move.w   #$FFFF,d3
                    move.w   d7,d0
                    ror.w    #1,d0
                    bcc      lbC004B5E
                    move.w   d3,(a0)
                    bra      lbC004B60

lbC004B5E:          clr.w    (a0)
lbC004B60:          ror.w    #1,d0
                    bcc      lbC004B6E
                    move.w   d3,(200*40)(a0)
                    bra      lbC004B72

lbC004B6E:          clr.w    (200*40)(a0)
lbC004B72:          ror.w    #1,d0
                    bcc      lbC004B80
                    move.w   d3,(200*2*40)(a0)
                    bra      lbC004B84

lbC004B80:          clr.w    (200*2*40)(a0)
lbC004B84:          ror.w    #1,d0
                    bcc      lbC004B92
                    move.w   d3,(200*3*40)(a0)
                    bra      lbC004B96

lbC004B92:          clr.w    (200*3*40)(a0)
lbC004B96:          sub.w    #$10,d4
                    add.w    #$10,d1
                    bra.b    GOT_BOUNDARY

LATER:              tst.w    d4
                    beq      DONE_LINE
                    move.w   #$8000,d3
LATER2:             move.w   d7,d0
                    ror.w    #1,d0
                    bcc      lbC004BB8
                    or.w     d3,(a0)
                    bra      lbC004BBE

lbC004BB8:          not.w    d3
                    and.w    d3,(a0)
                    not.w    d3
lbC004BBE:          ror.w    #1,d0
                    bcc      lbC004BCC
                    or.w     d3,(200*40)(a0)
                    bra      lbC004BD4

lbC004BCC:          not.w    d3
                    and.w    d3,(200*40)(a0)
                    not.w    d3
lbC004BD4:          ror.w    #1,d0
                    bcc      lbC004BE2
                    or.w     d3,(200*2*40)(a0)
                    bra      lbC004BEA

lbC004BE2:          not.w    d3
                    and.w    d3,(200*2*40)(a0)
                    not.w    d3
lbC004BEA:          ror.w    #1,d0
                    bcc      lbC004BF8
                    or.w     d3,(200*3*40)(a0)
                    bra      lbC004C00

lbC004BF8:          not.w    d3
                    and.w    d3,(200*3*40)(a0)
                    not.w    d3
lbC004C00:          ror.w    #1,d3
                    subq.w   #1,d4
                    bne.b    LATER2
DONE_LINE:          movem.l  (sp)+,d0-d5/a0
BYE_BYE_LINE:       rts

POINT:              move.w   d2,d0
                    lsl.w    #3,d0
                    add.w    d0,a0
                    add.w    d0,d0
                    add.w    d0,d0
                    add.w    d0,a0
                    move.w   d1,d0
                    lsr.w    #3,d0
                    and.w    #$FE,d0
                    add.w    d0,a0
                    move.w   d1,d0
                    and.w    #$F,d0
                    move.w   #$8000,d3
                    lsr.w    d0,d3
                    rts

GET_RANDOM:         move.l   d1,-(sp)
                    move.l   RANDOM1,d0
                    add.l    RANDOM2,d0
                    move.l   d0,RANDOM1
                    sub.l    RANDOM3,d0
                    add.l    d0,RANDOM2
                    move.w   d0,d1
                    and.w    #7,d1
                    swap     d0
                    ror.l    d1,d0
                    sub.l    d0,RANDOM3
                    add.l    d0,RANDOM1
                    move.l   (sp)+,d1
                    rts

RANDOM1:            dc.l     $98081FDD
RANDOM2:            dc.l     $FECA1919
RANDOM3:            dc.l     $121212FD

READ_TRIGS:         move.l   d0,-(sp)
                    bsr      SCAN_JOY
                    cmp.w    #2,S1MODE
                    bne      lbC004C96
                    move.w   #$40,d0
                    bsr      INKEY
                    beq      ZER1
                    bra      NZ1

lbC004C96:          tst.w    S1MODE
                    bne      lbC004CAE
                    tst.w    FIRE1
                    bne      NZ1
                    bra      ZER1

lbC004CAE:          tst.w    FIRE0
                    bne      NZ1
ZER1:               clr.w    JOY1TRIG
                    bra      RT2

NZ1:                move.w   #-1,JOY1TRIG
RT2:                cmp.w    #2,S2MODE
                    bne      lbC004CE6
                    move.w   #$40,d0
                    bsr      INKEY
                    beq      ZER2
                    bra      NZ2

lbC004CE6:          bhi      lbC004D10
                    tst.w    S2MODE
                    bne      lbC004D02
                    tst.w    FIRE1
                    bne      NZ2
                    bra      ZER2

lbC004D02:          tst.w    FIRE0
                    bne      NZ2
                    bra      ZER2

lbC004D10:          cmp.w    #3,S2MODE
                    bne      lbC004D2A
                    tst.w    FIRE0
                    bne      NZ2
                    bra      ZER2

lbC004D2A:          tst.w    FIRE1
                    bne      NZ2
ZER2:               clr.w    JOY2TRIG
                    bra      RT_RET

NZ2:                move.w   #-1,JOY2TRIG
RT_RET:             move.l   (sp)+,d0
                    rts

MOVE:               move.l   d0,-(sp)
                    tst.w    DEMO
                    beq      NO_DEMO
                    bsr      SCAN_JOY
                    tst.w    FIRE0
                    bne      OUT_DEMO
                    tst.w    FIRE1
                    bne      OUT_DEMO
                    move.w   #$40,d0
                    bsr      INKEY
                    bne      OUT_DEMO
                    move.w   #$44,d0
                    bsr      INKEY
                    bne      OUT_DEMO
                    move.w   #$45,d0
                    bsr      INKEY
                    beq      NO_DEMO
OUT_DEMO:           cmp.w    #40,DEMO
                    blt      NO_DEMO
                    move.w   #40,DEMO
NO_DEMO:            move.l   (sp)+,d0
                    tst.w    d0
                    bne      lbC004DC2
                    lea      S1BDIR,a4
                    tst.w    S1AUTO
                    beq      lbC004DF2
                    bra      lbC004DD2

lbC004DC2:          lea      S2BDIR,a4
                    tst.w    S2AUTO
                    beq      lbC004DF2
lbC004DD2:          movem.l  a4,-(sp)
                    bsr      BRAINMOVE
                    tst.w    d1
                    bne      _RANDMOVE
                    tst.w    d2
                    beq      lbC004DEA
_RANDMOVE:          bsr      RANDMOVE
lbC004DEA:          movem.l  (sp)+,a4
                    bra      lbC004DFE

lbC004DF2:          movem.l  a4,-(sp)
                    bsr      JOYMOVE
                    movem.l  (sp)+,a4
lbC004DFE:          add.w    d1,d1
                    add.w    d2,d2
MOVE0_0:            tst.w    d2
                    beq      MOVE0_2
                    tst.w    d0
                    bne      lbC004E46
                    move.w   S1MAPY,d3
                    move.w   d3,d5
                    move.w   S1MAPX,d6
                    tst.w    S1CT
                    beq      lbC004E7A
                    move.w   S1CT,d7
                    and.w    #$FF00,d7
                    cmp.w    #$F00,d7
                    beq      lbC004E7A
                    clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
                    bra      lbC004E7A

lbC004E46:          move.w   S2MAPY,d3
                    move.w   d3,d5
                    move.w   S2MAPX,d6
                    tst.w    S2CT
                    beq      lbC004E7A
                    move.w   S2CT,d7
                    and.w    #$FF00,d7
                    cmp.w    #$F00,d7
                    beq      lbC004E7A
                    clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
lbC004E7A:          move.w   d3,d4
                    add.w    d2,d4
                    lsr.w    #4,d3
                    lsr.w    #4,d4
                    cmp.w    d3,d4
                    beq      MOVE0_2
                    lsr.w    #4,d5
                    lsr.w    #2,d6
                    mulu     #96,d5
                    add.w    d6,d5
                    add.l    #TERRAIN,d5
                    move.l   d5,a0
                    moveq    #0,d3
                    move.b   (a0),d3
                    lsr.w    #1,d3
                    cmp.w    #-2,d2
                    bne      lbC004EE0
                    cmp.w    #18,d3
                    beq      MOVE0_2
                    tst.w    d0
                    bne      lbC004EC4
                    tst.w    S1AUTO
                    beq      lbC004F22
                    bra      MOVE0_7

lbC004EC4:          tst.w    S2AUTO
                    beq      lbC004F22
                    bra      MOVE0_7

lbC004EE0:          cmp.w    #2,d2
                    bne      lbC004F22
                    lsr.w    #1,d3
                    cmp.w    #8,d3
                    beq      MOVE0_2
                    tst.w    d0
                    bne      lbC004F06
                    tst.w    S1AUTO
                    beq      lbC004F22
                    bra      MOVE0_7

lbC004F06:          tst.w    S2AUTO
                    beq      lbC004F22
                    bra      MOVE0_7

lbC004F22:          clr.w    SPYDIR
                    clr.w    (a4)
                    rts

MOVE0_2:            move.w   MAXMAPX,d5
                    asl.w    #2,d5
                    move.w   MAXMAPY,d6
                    asl.w    #2,d6
                    moveq    #0,d3
                    move.w   SPYY,d3
                    add.w    d2,d3
                    lsr.w    #2,d3
                    mulu     MAXMAPX,d3
                    move.w   SPYX,d4
                    add.w    d1,d4
                    lsr.w    #2,d4
                    add.w    d4,d3
                    add.l    #MAP,d3
                    move.l   d3,a0
                    cmp.w    #$5B,d4
                    bhi      MOVE0_2_0
                    cmp.w    #2,d4
                    bls      MOVE0_2_0
                    moveq    #0,d4
                    move.b   (a0),d4
                    btst     #0,d4
                    beq      MOVE1_1
                    move.w   SPYY,d5
                    add.w    d2,d5
                    and.w    #$F,d5
                    cmp.w    #14,d5
                    beq      MOVE1_1
MOVE0_2_0:          tst.w    d0
                    bne      lbC004FBE
                    lea      S1HAND,a1
                    lea      S1FUEL,a2
                    lea      S1BUMP,a3
                    lea      S1BDIR,a4
                    move.w   S1MAPY,d5
                    bra      lbC004FDC

lbC004FBE:          lea      S2HAND,a1
                    lea      S2FUEL,a2
                    lea      S2BUMP,a3
                    lea      S2BDIR,a4
                    move.w   S2MAPY,d5
lbC004FDC:          move.b   (a0),d4
                    cmp.b    #$A9,d4
                    beq      lbC004FF6
                    cmp.b    #$AB,d4
                    beq      lbC004FF6
                    cmp.b    #$AD,d4
                    bne      MOVE0_3
lbC004FF6:          moveq    #7,d7
                    bsr      NEW_SOUND
                    cmp.w    #$58,(a1)
                    beq      lbC00500C
                    bra      MOVE0_7

lbC00500C:          and.w    #14,d5
                    beq      MOVE0_7
                    move.w   #2,d1
                    cmp.w    SPYDIR,d1
                    blt      MOVE0_7
                    add.w    #1,(a3)
                    cmp.w    #4,(a3)
                    bge      MOVE0_9
                    move.w   #$F00,d3
                    bsr      SETSTATE
                    bra      MOVE0_8

MOVE0_3:            cmp.b    #$C1,d4
                    bne      MOVE0_7
MOVE0_4:            moveq    #6,d7
                    bsr      NEW_SOUND
                    add.w    #1,(a2)
                    cmp.w    #7,(a2)
                    bgt      lbC005076
                    tst.w    d0
                    bne      lbC00506A
                    move.w   #15,S1NUDGE
                    bra      lbC00508C

lbC00506A:          move.w   #15,S2NUDGE
                    bra      lbC00508C

lbC005076:          tst.w    d0
                    bne      lbC005086
                    clr.w    S1NUDGE
                    bra      lbC00508C

lbC005086:          clr.w    S2NUDGE
lbC00508C:          move.w   #10,d5
                    cmp.w    (a2),d5
                    bge      MOVE0_8
                    move.w   #10,(a2)
MOVE0_7:            tst.w    d0
                    bne      lbC0050B0
                    lea      S1BUMP,a3
                    lea      S1BDIR,a4
                    bra      lbC0050BC

lbC0050B0:          lea      S2BUMP,a3
                    lea      S2BDIR,a4
lbC0050BC:          move.w   (a4),d1
MOVE0_7_5:          and.w    #3,d1
                    bne      lbC0050E6
                    move.w   #1,d4
                    move.w   #3,d2
                    bsr      RNDER2
                    and.w    #1,d1
                    bne      lbC005102
                    move.w   #2,d4
                    move.w   #4,d2
                    bra      lbC005102

lbC0050E6:          move.w   #4,d4
                    move.w   #1,d2
                    bsr      RNDER2
                    and.w    #1,d1
                    bne      lbC005102
                    move.w   #8,d4
                    move.w   #2,d2
lbC005102:          move.w   d4,(a4)
                    move.w   d2,SPYDIR
                    bsr      RNDER2
                    and.w    #7,d1
                    tst.w    d0
                    bne      lbC005122
                    move.w   d1,S1NUDGE
                    bra      _MOVE0_8

lbC005122:          move.w   d1,S2NUDGE
_MOVE0_8:           bra      MOVE0_8

MOVE0_8:            clr.w    (a3)
MOVE0_9:            clr.w    SPYDIR
                    clr.w    d1
                    clr.w    d2
                    rts

MOVE1_1:            tst.w    d0
                    bne      lbC005160
                    lea      S1BDIR,a5
                    tst.w    S1AUTO
                    beq      lbC00522C
                    tst.w    S1SAFE
                    bne      lbC00522C
                    bra      lbC00517A

lbC005160:          lea      S2BDIR,a5
                    tst.w    S2AUTO
                    beq      lbC00522C
                    tst.w    S2SAFE
                    bne      lbC00522C
lbC00517A:          cmp.b    #$A0,d4
                    beq      lbC00522C
                    cmp.b    #$F0,d4
                    beq      lbC00522C
                    cmp.b    #$80,d4
                    beq      lbC00522C
                    cmp.b    #$68,d4
                    blt      lbC00522C
                    movem.l  d0-d3/a0-a3,-(sp)
                    bsr      GET_RANDOM
                    and.w    #$F,d0
                    add.w    #1,d0
                    move.w   d0,d7
                    movem.l  (sp)+,d0-d3/a0-a3
                    move.w   IQ,d3
                    tst.w    d0
                    bne      lbC0051C0
                    bra      lbC0051C0

lbC0051C0:          add.w    d3,d3
                    add.w    #5,d3
                    cmp.w    d3,d7
                    bge      lbC0051D2
lbC0051CC:          clr.w    (a5)
                    bra      MOVE0_2_0

lbC0051D2:          tst.w    d0
                    bne      lbC0051FC
                    tst.w    S1AUTO
                    beq      lbC00522C
                    cmp.w    #$30,S1HAND
                    beq      lbC005220
                    cmp.w    #$46,S1ENERGY
                    bls.b    lbC0051CC
                    bra      lbC00522C

lbC0051FC:          tst.w    S2AUTO
                    beq      lbC00522C
                    cmp.w    #$30,S2HAND
                    beq      lbC005220
                    cmp.w    #$46,S2ENERGY
                    bls.b    lbC0051CC
                    bra      lbC00522C

lbC005220:          movem.l  d0-d7/a0-a6,-(sp)
                    bsr      BUSY4_A
                    movem.l  (sp)+,d0-d7/a0-a6
lbC00522C:          movem.l  d4-d6,-(sp)
                    tst.w    d0
                    bne      MOVE1_1_0
                    lea      S1DEPTH,a1
                    lea      S1ENERGY,a2
                    lea      S1WATERCT,a3
                    lea      S1SWAMP,a4
                    lea      S1DROWN,a5
                    lea      S1RUN,a6
                    move.w   S1OLDX,d5
                    move.w   S1OLDY,d6
                    tst.w    S1DEAD
                    bne      MOVE1_1_1_9
                    bra      MOVE1_1_0_1

MOVE1_1_0:          lea      S2DEPTH,a1
                    lea      S2ENERGY,a2
                    lea      S2WATERCT,a3
                    lea      S2SWAMP,a4
                    lea      S2DROWN,a5
                    lea      S2RUN,a6
                    move.w   S2OLDX,d5
                    move.w   S2OLDY,d6
                    tst.w    S2DEAD
                    bne      MOVE1_1_1_9
MOVE1_1_0_1:        moveq    #0,d4
                    move.b   (a0),d4
                    clr.w    (a5)
                    cmp.w    #$F0,d4
                    beq      lbC0052C4
                    cmp.w    #$A0,d4
                    bne      lbC00537E
lbC0052C4:          move.w   #1,(a5)
                    clr.w    (a6)
                    move.w   #$17,d4
                    cmp.w    (a1),d4
                    bgt      lbC0052DE
                    cmp.w    (a1),d4
                    blt      lbC0052F8
                    bra      lbC0052FE

lbC0052DE:          tst.w    (a1)
                    bne      lbC0052EE
                    moveq    #5,d7
                    bsr      NEW_SOUND
lbC0052EE:          move.w   #4,d4
                    add.w    d4,(a1)
                    bra      lbC0052FE

lbC0052F8:          move.w   #1,d4
                    sub.w    d4,(a1)
lbC0052FE:          move.w   COUNTER,d4
                    and.w    #3,d4
                    bne      lbC00531A
                    move.w   #2,d4
                    sub.w    d4,(a2)
                    move.w   #2,REFRESH
lbC00531A:          move.w   #1,d4
                    add.w    d4,(a3)
                    cmp.w    #$14,(a3)
                    bne      lbC00533C
                    sub.w    #12,(a2)
                    move.w   #2,REFRESH
                    add.w    #7,(a1)
                    bra      lbC0053FA

lbC00533C:          cmp.w    #$28,(a3)
                    bne      lbC005358
                    sub.w    #12,(a2)
                    move.w   #2,REFRESH
                    add.w    #7,(a1)
                    bra      lbC0053FA

lbC005358:          cmp.w    #$3C,(a3)
                    bne      lbC0053FA
                    clr.w    (a3)
                    sub.w    #$16,(a2)
                    move.w   #2,REFRESH
                    move.w   #$1300,d3
                    bsr      SETSTATE
                    clr.w    d1
                    clr.w    d2
                    bra      lbC0053FA

lbC00537E:          tst.w    (a1)
                    beq      lbC0053FA
                    move.w   #$1500,d3
                    bsr      SETSTATE
                    tst.w    d0
                    bne      lbC0053C4
                    move.l   #BUF1D,S1FADDR
                    move.w   #0,S1F
                    cmp.b    #$F0,1(a0)
                    beq      lbC0053B8
                    cmp.b    #$A0,1(a0)
                    bne      lbC0053F2
lbC0053B8:          move.w   #1,S1F
                    bra      lbC0053F2

lbC0053C4:          move.l   #BUF2D,S2FADDR
                    move.w   #0,S2F
                    cmp.b    #$F0,1(a0)
                    beq      lbC0053EA
                    cmp.b    #$A0,1(a0)
                    bne      lbC0053F2
lbC0053EA:          move.w   #1,S2F
lbC0053F2:          clr.w    (a3)
                    movem.l  (sp)+,d4-d6
                    rts

lbC0053FA:          move.w   #$80,d4
                    cmp.b    (a0),d4
                    bne      MOVE1_1_1
                    bra      MOVE1_1_1_0

MOVE1_1_1:          tst.w    (a4)
                    beq      MOVE1_1_1_9
                    tst.w    d0
                    bne      lbC005422
                    tst.w    S1AUTO
                    beq      MOVE1_1_1_0
                    bra      lbC00542C

lbC005422:          tst.w    S2AUTO
                    beq      MOVE1_1_1_0
lbC00542C:          move.w   COUNTER,d4
                    and.w    #1,d4
                    beq      MOVE1_1_1_0
                    move.w   d1,d4
                    move.w   d2,d1
                    move.w   d4,d2
                    tst.w    d1
                    beq      lbC005462
                    bmi      lbC005456
                    move.w   #2,SPYDIR
                    bra      MOVE1_1_1_0

lbC005456:          move.w   #1,SPYDIR
                    bra      MOVE1_1_1_0

lbC005462:          tst.w    d2
                    beq      MOVE1_1_1_0
                    bmi      lbC005478
                    move.w   #4,SPYDIR
                    bra      MOVE1_1_1_0

lbC005478:          move.w   #3,SPYDIR
                    bra      MOVE1_1_1_0

MOVE1_1_1_0:        cmp.w    d1,d5
                    bne      _DIRFIX
                    cmp.w    d2,d6
                    bne      _DIRFIX
                    bra      lbC0054A4

_DIRFIX:            bsr      DIRFIX
                    sub.w    #4,(a4)
                    bge      lbC0054A4
                    move.w   #-2,(a4)
lbC0054A4:          tst.w    d0
                    bne      lbC0054BA
                    move.w   d1,S1OLDX
                    move.w   d2,S1OLDY
                    bra      lbC0054C6

lbC0054BA:          move.w   d1,S2OLDX
                    move.w   d2,S2OLDY
lbC0054C6:          add.w    #2,(a4)
                    move.w   #$19,d4
                    cmp.w    (a4),d4
                    bge      lbC0054D8
                    move.w   #$19,(a4)
lbC0054D8:          move.w   COUNTER,d4
                    and.w    #3,d4
                    bne      lbC005502
                    sub.w    #1,(a2)
                    move.w   #2,REFRESH
                    move.w   #$80,d4
                    cmp.b    (a0),d4
                    beq      MOVE1_1_1_9
                    tst.w    (a4)
                    beq      MOVE1_1_1_9
lbC005502:          clr.w    d1
                    clr.w    d2
MOVE1_1_1_9:        movem.l  (sp)+,d4-d6
                    tst.w    d0
                    bne      MOVE1_1_A_0
                    tst.w    S1SWAMP
                    bne      MOVE1_1_Z
                    tst.w    S1DEPTH
                    bne      MOVE1_1_Z
                    tst.w    S1SAFE
                    bne      MOVE1_1_A_3
                    bra      MOVE1_1_A_5

MOVE1_1_A_0:        tst.w    S2SWAMP
                    bne      MOVE1_1_Z
                    tst.w    S2DEPTH
                    bne      MOVE1_1_Z
                    tst.w    S2SAFE
                    bne      MOVE1_1_A_3
                    bra      MOVE1_1_A_5

MOVE1_1_A_3:        move.w   d1,d3
                    add.w    d2,d3
                    beq      MOVE1_1_Z
                    tst.w    d0
                    bne      MOVE1_1_A_4
                    sub.w    #1,S1SAFE
                    bra      MOVE1_1_Z

MOVE1_1_A_4:        sub.w    #1,S2SAFE
                    bra      MOVE1_1_Z

MOVE1_1_A_5:        moveq    #0,d4
                    move.b   (a0),d4
                    and.w    #$FFF8,d4
                    cmp.w    #$68,d4
                    beq      MOVE1_1_A
                    cmp.w    #$70,d4
                    beq      MOVE1_1_B
                    cmp.w    #$78,d4
                    beq      MOVE1_1_C
                    cmp.w    #$98,d4
                    beq      MOVE1_1_D
                    cmp.w    #$C8,d4
                    beq      MOVE1_1_E
                    bra      MOVE1_1_Z

MOVE1_1_A:          bsr      DELETE_TRAP
                    move.w   #$E00,d3
                    bsr      SETSTATE
                    bra      MOVE1_1_Z

MOVE1_1_B:          bsr      DELETE_TRAP
                    move.w   #$C00,d3
                    bsr      SETSTATE
                    bra      MOVE1_1_Z

MOVE1_1_C:          bsr      DELETE_TRAP
                    move.w   #$D00,d3
                    bsr      SETSTATE
                    bra      MOVE1_1_Z

MOVE1_1_D:          tst.w    d0
                    bne      lbC0055F4
                    cmp.w    #$38,S1HAND
                    beq      lbC005610
                    bra      _DELETE_TRAP

lbC0055F4:          cmp.w    #$38,S2HAND
                    beq      lbC005610
_DELETE_TRAP:       bsr      DELETE_TRAP
                    move.w   #$1100,d3
                    bsr      SETSTATE
                    bra      MOVE1_1_Z

lbC005610:          move.b   #$C8,(a0)
                    tst.w    d0
                    bne      lbC00562C
                    clr.w    S1HAND
                    move.w   #4,S1SAFE
                    bra      MOVE1_1_Z

lbC00562C:          clr.w    S2HAND
                    move.w   #4,S2SAFE
                    bra      MOVE1_1_Z

MOVE1_1_E:          move.b   #0,(a0)
                    move.w   #$1200,d3
                    bsr      SETSTATE
                    bra      MOVE1_1_Z

MOVE1_1_Z:          add.w    d1,SPYX
                    add.w    d2,SPYY
                    bmi      MOVEABORT
                    tst.w    d0
                    bne      MOVE1_1_Z_3
                    movem.l  d0/d1/a0,-(sp)
                    move.w   SPYX,d0
                    lsr.w    #6,d0
                    lsl.w    #8,d0
                    move.w   SPYY,d1
                    lsr.w    #4,d1
                    or.w     d1,d0
                    cmp.w    S1TRAIL,d0
                    beq      lbC0056A6
                    lea      S1TRAIL,a0
                    moveq    #8,d1
                    add.l    d1,a0
lbC005694:          move.w   (a0),2(a0)
                    sub.w    #2,a0
                    sub.w    #2,d1
                    bge.b    lbC005694
                    move.w   d0,2(a0)
lbC0056A6:          movem.l  (sp)+,d0/d1/a0
                    tst.w    S2DEAD
                    bne      MOVE1_1_2
                    move.w   SPYX,d3
                    sub.w    S2MAPX,d3
                    bge      MOVE1_1_Z_1
                    neg.w    d3
MOVE1_1_Z_1:        cmp.w    #4,d3
                    bge      MOVE1_1_2
                    move.w   SPYY,d3
                    move.w   S2MAPY,d4
                    lsr.w    #4,d3
                    lsr.w    #4,d4
                    cmp.w    d3,d4
                    bne      MOVE1_1_2
                    move.w   SPYY,d3
                    sub.w    S2MAPY,d3
                    bge      MOVE1_1_Z_2
                    neg.w    d3
MOVE1_1_Z_2:        cmp.w    #4,d3
                    bmi      MOVEABORT
                    bra      MOVE1_1_2

MOVE1_1_Z_3:        movem.l  d0/d1/a0,-(sp)
                    move.w   SPYX,d0
                    lsr.w    #6,d0
                    lsl.w    #8,d0
                    move.w   SPYY,d1
                    lsr.w    #4,d1
                    or.w     d1,d0
                    cmp.w    S2TRAIL,d0
                    beq      lbC005744
                    lea      S2TRAIL,a0
                    moveq    #8,d1
                    add.l    d1,a0
lbC005732:          move.w   (a0),2(a0)
                    sub.w    #2,a0
                    sub.w    #2,d1
                    bge.b    lbC005732
                    move.w   d0,2(a0)
lbC005744:          movem.l  (sp)+,d0/d1/a0
                    tst.w    S1DEAD
                    bne      MOVE1_1_2
                    move.w   SPYX,d3
                    sub.w    S1MAPX,d3
                    bge      MOVE1_1_Z_4
                    neg.w    d3
MOVE1_1_Z_4:        cmp.w    #4,d3
                    bge      MOVE1_1_2
                    move.w   SPYY,d3
                    move.w   S1MAPY,d4
                    lsr.w    #4,d3
                    lsr.w    #4,d4
                    cmp.w    d3,d4
                    bne      MOVE1_1_2
                    move.w   SPYY,d3
                    sub.w    S1MAPY,d3
                    bge      MOVE1_1_Z_5
                    neg.w    d3
MOVE1_1_Z_5:        cmp.w    #4,d3
                    bmi      MOVEABORT
MOVE1_1_2:          tst.w    d1
                    bne      lbC0057A8
                    tst.w    d2
                    beq      lbC0057D6
lbC0057A8:          tst.w    FEET_FLAG
                    bne      lbC0057D6
                    addq.w   #1,FEET_FLAG
                    addq.w   #1,FEET_COUNT
                    move.w   FEET_COUNT,d7
                    and.w    #1,d7
                    bne      lbC0057D6
                    moveq    #11,d7
                    bsr      NEW_SOUND
lbC0057D6:          tst.w    SPYX
                    bmi      MOVEABORT
                    bsr      CHECKMEET
                    move.w   SPYWIN,d3
                    tst.w    d3
                    beq      MOVE1_1_5
                    sub.w    #1,d3
                    cmp.w    d0,d3
                    bne      MOVEEND
MOVE1_1_5:          tst.w    d1
                    beq      MOVE2_0
                    move.w   SPYX,d3
                    sub.w    #4,d3
                    sub.w    SPYWX,d3
                    bgt      MOVE1_2
                    move.w   SPYX,d3
                    cmp.w    #4,d3
                    ble      MOVEABORT
                    subq.w   #2,SPYWX
                    rts

MOVE1_2:            move.w   SPYX,d3
                    sub.w    SPYWX,d3
                    sub.w    #$28,d3
                    blt      MOVEEND
                    addq.w   #2,SPYWX
MOVEEND:            rts

MOVE2_0:            move.w   SPYY,d3
                    sub.w    SPYWY,d3
                    bge      MOVE2_2
                    move.w   SPYWY,d3
                    ble      MOVEABORT
                    move.w   #$10,d3
                    sub.w    d3,SPYWY
                    rts

MOVE2_2:            move.w   SPYY,d3
                    sub.w    SPYWY,d3
                    sub.w    #$10,d3
                    blt.b    MOVEEND
                    move.w   SPYY,d3
                    sub.w    d6,d3
                    bge      MOVEABORT
                    move.w   #$10,d3
                    add.w    d3,SPYWY
                    rts

MOVEABORT:          tst.w    d0
                    bne      lbC0058B2
                    lea      S1BDIR,a4
                    clr.w    S1BUMP
                    clr.w    S1BDIR
                    bra      lbC0058C4

lbC0058B2:          lea      S2BDIR,a4
                    clr.w    S2BUMP
                    clr.w    S2BDIR
lbC0058C4:          sub.w    d1,SPYX
                    sub.w    d2,SPYY
                    bsr      RNDER2
                    and.w    #1,d1
                    bra      MOVE0_7_5

CHECKMEET:          movem.l  d0-d7/a0-a6,-(sp)
                    move.w   d1,d4
                    move.w   d2,d5
                    move.w   S1MAPY,d1
                    move.w   S2MAPY,d2
                    and.w    #$FFF0,d1
                    and.w    #$FFF0,d2
                    move.w   d1,WIN1Y
                    move.w   d2,WIN2Y
                    cmp.w    d1,d2
                    bne      SEPARATE
                    tst.w    SPYWIN
                    beq      lbC005924
                    move.w   SPYWIN,d1
                    subq.w   #1,d1
                    cmp.w    d0,d1
                    beq      CHECKMEETBYE
lbC005924:          tst.w    d0
                    bne      lbC00596A
                    move.w   WIN2X,d2
                    addq.w   #4,d2
                    move.w   S1MAPX,d1
                    cmp.w    d2,d1
                    blt      SEPARATE
                    add.w    #36,d2
                    cmp.w    d2,d1
                    bge      SEPARATE
                    move.w   WIN2Y,SPYWY
                    move.w   WIN2X,SPYWX
                    move.w   #2,SPYWIN
                    bra      FORCE_DRAW

lbC00596A:          move.w   WIN1X,d2
                    addq.w   #4,d2
                    move.w   S2MAPX,d1
                    cmp.w    d2,d1
                    blt      SEPARATE
                    add.w    #$24,d2
                    cmp.w    d2,d1
                    bge      SEPARATE
                    move.w   WIN1Y,SPYWY
                    move.w   WIN1X,SPYWX
                    move.w   #1,SPYWIN
FORCE_DRAW:         move.w   #-1,BUF1Y
                    move.w   #-1,BUF2Y
                    bra      CHECKMEETBYE

CHECKMEETEND:       cmp.w    #1,d2
                    ble      CHECKMEETBYE
                    move.w   #-1,BUF1Y
                    move.w   #-1,BUF2Y
CHECKMEETBYE:       movem.l  (sp)+,d0-d7/a0-a6
                    rts

SEPARATE:           tst.w    SPYWIN
                    beq.b    CHECKMEETBYE
                    move.w   #-1,BUF1Y
                    move.w   #-1,BUF2Y
                    move.w   SPYWIN,d1
                    clr.w    SPYWIN
                    cmp.w    #2,d1
                    bne      lbC005A24
                    move.w   S1MAPX,d1
                    sub.w    #$15,d1
                    cmp.w    #2,d1
                    bgt      lbC005A1A
                    move.w   #2,d1
lbC005A1A:          move.w   d1,WIN1X
                    bra      _SETTEMPS

lbC005A24:          move.w   S2MAPX,d1
                    sub.w    #$15,d1
                    cmp.w    #2,d1
                    bgt      lbC005A3A
                    move.w   #2,d1
lbC005A3A:          move.w   d1,WIN2X
_SETTEMPS:          bsr      SETTEMPS
                    movem.l  (sp)+,d0-d7/a0-a6
                    rts

SETTEMPS:           tst.w    d0
                    bne      lbC005A7C
                    move.w   WIN1X,SPYWX
                    move.w   WIN1Y,SPYWY
                    move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    bra      lbC005AA4

lbC005A7C:          move.w   WIN2X,SPYWX
                    move.w   WIN2Y,SPYWY
                    move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
lbC005AA4:          rts

DIRFIX:             movem.l  d1/d2,-(sp)
                    move.w   SPYDIR,d2
                    tst.w    d0
                    bne      BODY2_0
                    cmp.w    #2,d2
                    bne      BODY1_1
                    move.l   #BUF11,S1FADDR
                    bra      BODY1_20

BODY1_1:            cmp.w    #1,d2
                    bne      BODY1_2
                    move.l   #BUF12,S1FADDR
                    bra      BODY1_20

BODY1_2:            cmp.w    #3,d2
                    bne      BODY1_3
                    move.l   #BUF13,S1FADDR
                    bra      BODY1_20

BODY1_3:            cmp.w    #4,d2
                    bne      BODY1_80
                    move.l   #BUF14,S1FADDR
BODY1_20:           move.w   S1F,d1
                    add.w    #1,d1
                    cmp.w    #4,d1
                    bne      BODY1_20_1
                    clr.w    d1
BODY1_20_1:         move.w   d1,S1F
                    bra      BODY1_99

BODY1_80:           clr.w    S1F
BODY1_99:           movem.l  (sp)+,d1/d2
                    rts

BODY2_0:            cmp.w    #2,d2
                    bne      BODY2_1
                    move.l   #BUF21,S2FADDR
                    bra      BODY2_20

BODY2_1:            cmp.w    #1,d2
                    bne      BODY2_2
                    move.l   #BUF22,S2FADDR
                    bra      BODY2_20

BODY2_2:            cmp.w    #3,d2
                    bne      BODY2_3
                    move.l   #BUF23,S2FADDR
                    bra      BODY2_20

BODY2_3:            cmp.w    #4,d2
                    bne      BODY2_80
                    move.l   #BUF24,S2FADDR
BODY2_20:           move.w   S2F,d1
                    add.w    #1,d1
                    cmp.w    #4,d1
                    bne      BODY2_20_1
                    clr.w    d1
BODY2_20_1:         move.w   d1,S2F
                    bra      BODY2_99

BODY2_80:           clr.w    S2F
BODY2_99:           movem.l  (sp)+,d1/d2
                    rts

TEST_OPTIONS:       tst.w    SPECIAL_DELAY
                    beq      _TEST_M
                    subq.w   #1,SPECIAL_DELAY
                    bra      lbC005BCA

_TEST_M:            bsr      TEST_M
lbC005BCA:          rts

TEST_M:             move.w   #$37,d0
                    bsr      INKEY
                    beq      lbC005C36
                    move.w   #$14,SPECIAL_DELAY
                    tst.w    MUSIC_SWITCH
                    bne      lbC005C0C
                    move.w   #-1,lbW001F72
                    move.w   #-1,lbW001F8C
                    move.w   #-1,lbW001FA6
                    move.w   #1,MUSIC_SWITCH
                    rts

lbC005C0C:          clr.w    MUSIC_SWITCH
                    clr.w    lbW001F72
                    clr.w    lbW001F8C
                    clr.w    lbW001FA6
                    clr.w    $DFF0A8
                    clr.w    $DFF0B8
                    clr.w    $DFF0C8
lbC005C36:          rts

JOYMOVE:            movem.l  d0/d7/a0,-(sp)
                    move.w   d0,d7
                    bsr      SCAN_JOY
                    bsr      TEST_OPTIONS
                    move.w   #$19,d0
                    bsr      INKEY
                    beq      JM2
_LITTLE_DELAY:      bsr      LITTLE_DELAY
                    move.w   #$19,d0
                    bsr      INKEY
                    bne.b    _LITTLE_DELAY
_TEST_OPTIONS:      bsr      TEST_OPTIONS
                    bsr      LITTLE_DELAY
                    move.w   #$19,d0
                    bsr      INKEY
                    beq.b    _TEST_OPTIONS
_LITTLE_DELAY0:     bsr      LITTLE_DELAY
                    move.w   #$19,d0
                    bsr      INKEY
                    bne.b    _LITTLE_DELAY0
JM2:                move.w   #$45,d0
                    bsr      INKEY
                    beq      JM3
lbC005C8C:          move.w   #$45,d0
                    bsr      INKEY
                    bne.b    lbC005C8C
                    move.w   #1,ABORT
JM3:                move.w   d7,d0
                    tst.w    BRAINON
                    bne      lbC005D42
                    moveq    #0,d1
                    moveq    #0,d2
                    clr.w    SPYDIR
                    tst.w    d0
                    bne      lbC005CCE
                    tst.w    S1DEAD
                    bne      lbC005D42
                    move.w   S1MODE,d7
                    bra      lbC005CDE

lbC005CCE:          tst.w    S2DEAD
                    bne      lbC005D42
                    move.w   S2MODE,d7
lbC005CDE:          
                    add.w    d7,d7
                    add.w    d7,d7
                    move.l   JOY_TABLE(pc,d7.w),a0
                    tst.b    (a0)+
                    beq      lbC005D02
                    move.w   #-1,d1
                    moveq    #0,d2
                    move.w   #1,SPYDIR
                    bra      lbC005D42

lbC005D02:          tst.b    (a0)+
                    beq      lbC005D1A
                    move.w   #1,d1
                    moveq    #0,d2
                    move.w   #2,SPYDIR
                    bra      lbC005D42

lbC005D1A:          tst.b    (a0)+
                    beq      lbC005D30
                    moveq    #0,d1
                    moveq    #-1,d2
                    move.w   #3,SPYDIR
                    bra      lbC005D42

lbC005D30:          tst.b    (a0)+
                    beq      lbC005D42
                    moveq    #0,d1
                    moveq    #1,d2
                    move.w   #4,SPYDIR
lbC005D42:          clr.w    BRAINON
                    movem.l  (sp)+,d0/d7/a0
                    rts

JOY_TABLE:          dc.l     LEFT1
                    dc.l     MLEFT0
                    dc.l     KLEFT1
                    dc.l     LEFT0
                    dc.l     MLEFT1

SETWINDOW:          cmp.w    #1,SPYWIN
                    beq      SETWINDOW1
                    cmp.w    #2,SPYWIN
                    beq      SETWINDOW2
                    tst.w    d0
                    bne      SETWINDOW2
SETWINDOW1:         move.w   WIN1X,SPYWX
                    move.w   WIN1Y,SPYWY
                    rts

SETWINDOW2:         move.w   WIN2X,SPYWX
                    move.w   WIN2Y,SPYWY
                    rts

GETWINDOW:          cmp.w    #1,SPYWIN
                    beq      GETWINDOW1
                    cmp.w    #2,SPYWIN
                    beq      GETWINDOW2
                    tst.w    d0
                    bne      GETWINDOW2
GETWINDOW1:         move.w   SPYWX,WIN1X
                    move.w   SPYWY,WIN1Y
                    rts

GETWINDOW2:         move.w   SPYWX,WIN2X
                    move.w   SPYWY,WIN2Y
                    rts

LITTLE_DELAY:       move.w   d0,-(sp)
                    move.w   #56001-1,d0
.WAIT:              dbra     d0,.WAIT
                    move.w   (sp)+,d0
                    rts

FEET_COUNT:         dc.w     0
FEET_FLAG:          dc.w     0
SPECIAL_DELAY:      dc.w     0

DRAWMOVE:           moveq    #0,d0
                    moveq    #0,d3
                    bsr      DRAWFUEL
                    bsr      FLASH
                    clr.w    d3
                    clr.w    d0
                    bsr      DRAWSEL
                    tst.w    SEL_FLAG
                    beq      lbC005E2E
                    subq.w   #1,SEL_FLAG
lbC005E2E:          move.w   S1CT,d1
                    beq      DRAWMOVE0
                    and.w    #$FF00,d1
                    cmp.w    #$800,d1
                    bge      DRAWMOVE0
                    cmp.w    #$200,d1
                    beq      DRAWMOVE0
DRAWMOVE0:          cmp.w    #2,SPYWIN
                    beq      DRAWMOVE0_1
                    cmp.w    #$500,d1
                    beq      NOLAND
                    bsr      DRAWLAND
                    bsr      DRAWOBJ
NOLAND:             bra      DRAWMOVE1

DRAWMOVE0_1:        move.w   #446,a0
                    bsr      CLEAR_WINDOW
                    bsr      DRAWLAND5_2
DRAWMOVE1:          move.w   #1,d0
                    bsr      DRAWFUEL
                    bsr      FLASH
                    move.w   S2CT,d1
                    beq      DRAWMOVE2
                    and.w    #$FF00,d1
                    cmp.w    #$800,d1
                    bge      DRAWMOVE2
                    cmp.w    #$200,d1
                    beq      DRAWMOVE2
DRAWMOVE2:          cmp.w    #1,SPYWIN
                    beq      DRAWMOVE2_1
                    cmp.w    #$500,d1
                    beq      NOLAND2
                    bsr      DRAWLAND
                    bsr      DRAWOBJ
NOLAND2:            bra      DRAWMOVE3

DRAWMOVE2_1:        move.w   #4406,a0
                    bsr      CLEAR_WINDOW
                    bsr      DRAWLAND5_2
DRAWMOVE3:          bsr      DRAWBUTTONS
                    moveq    #0,d0
                    bsr      DRAWBUTTONS
                    bsr      DRAWTIME
                    tst.w    S1ENERGY
                    bge      DRAWMOVE4
                    move.w   #-1,S1ENERGY
                    tst.w    S1DEAD
                    bne      DRAWMOVE4
                    move.w   #$1400,S1CT
                    tst.w    S1DROWN
                    bne      DRAWMOVE4
                    tst.w    DIE_ONCE1
                    bne      DRAWMOVE4
                    move.w   #1,DIE_ONCE1
                    moveq    #12,d7
                    bsr      NEW_SOUND
DRAWMOVE4:          tst.w    S2ENERGY
                    bge      DRAWMOVE5
                    move.w   #-1,S2ENERGY
                    tst.w    S2DEAD
                    bne      DRAWMOVE5
                    move.w   #$1400,S2CT
                    tst.w    S2DROWN
                    bne      DRAWMOVE5
                    tst.w    DIE_ONCE2
                    bne      DRAWMOVE5
                    move.w   #1,DIE_ONCE2
                    moveq    #12,d7
                    bsr      NEW_SOUND
DRAWMOVE5:          bsr      DRAWROPES
                    bra      METER

DRAWLAND:           tst.w    d0
                    bne      DRAWLAND0_0
                    move.l   S1FADDR,d1
                    sub.l    #BUF11,d1
                    move.l   #S1BACK,WHICHBACK
                    move.w   WIN1X,d2
                    move.w   WIN1Y,d3
                    move.w   BUF1X,d4
                    move.w   BUF1Y,d5
                    move.w   #50,ULX
                    move.w   #11,ULY
                    move.w   d2,BUF1X
                    move.w   d3,BUF1Y
                    bra      DRAWLAND0_1

DRAWLAND0_0:        move.l   S2FADDR,d1
                    sub.l    #BUF21,d1
                    move.l   #S2BACK,WHICHBACK
                    move.w   WIN2X,d2
                    move.w   WIN2Y,d3
                    move.w   BUF2X,d4
                    move.w   BUF2Y,d5
                    move.w   #50,ULX
                    move.w   #110,ULY
                    move.w   d2,BUF2X
                    move.w   d3,BUF2Y
DRAWLAND0_1:        movem.l  d0-d5,-(sp)
                    lsr.w    #4,d3
                    subq.w   #1,d2
                    lsr.w    #2,d2
                    mulu     #96,d3
                    add.w    d2,d3
                    move.l   d3,a0
                    add.l    #TERRAIN,a0
                    movem.l  (sp),d0-d5
                    subq.w   #1,d2
                    subq.w   #1,d4
                    lsr.w    #2,d2
                    lsr.w    #4,d3
                    lsr.w    #2,d4
                    lsr.w    #4,d5
                    cmp.w    d3,d5
                    bne      DRAWLAND1_0
                    cmp.w    d2,d4
                    beq      DRAWLAND5_0
DRAWLAND1_0:        move.w   #13-1,d1
                    moveq    #0,d3
DRAWLAND1_1:        move.b   (a0)+,d4
                    ext.w    d4
                    bsr      DRAWSLAB
                    addq.w   #1,d3
                    dbra     d1,DRAWLAND1_1
                    bra      DRAWLAND5_0

DRAWLAND2_0:        movem.l  d0/d1/a1/a2,-(sp)
                    movem.l  d1-d3/a0/a3,-(sp)
                    move.l   WHICHBACK,a0
                    move.l   a0,a3
                    addq.w   #8,a0
                    move.l   #$80008,d1
                    move.l   #$9F00000,d2
                    move.w   #$8440,$DFF096
                    move.w   #$1030,d3
                    bsr      BLIT
                    bsr      WAIT_BLIT
                    movem.l  (sp)+,d1-d3/a0/a3
                    lea      11(a0),a0
                    move.w   #11,d3
                    moveq    #0,d4
                    move.b   (a0)+,d4
                    bsr      DRAWSLAB
                    movem.l  (sp)+,d0/d1/a1/a2
                    bra      DRAWLAND5_0

DRAWLAND3_0:        movem.l  d0/d1/a1/a2,-(sp)
                    movem.l  d1-d3/a0/a3,-(sp)
                    move.l   WHICHBACK,a0
                    add.w    #$19F0,a0
                    move.l   a0,a3
                    addq.w   #8,a3
                    move.l   #$80008,d1
                    move.l   #$9F00002,d2
                    move.w   #$8440,$DFF096
                    move.w   #$1030,d3
                    bsr      BLIT
                    bsr      WAIT_BLIT
                    movem.l  (sp)+,d1-d3/a0/a3
                    moveq    #0,d4
                    move.b   (a0)+,d4
                    clr.w    d3
                    bsr      DRAWSLAB
                    movem.l  (sp)+,d0/d1/a1/a2
DRAWLAND5_0:        movem.l  (sp)+,d0-d5
                    lea      $DFF000,a2
                    move.l   WHICHBACK,a1
                    move.l   SCREEN2,a0
                    move.w   ULY,d1
                    lsl.w    #3,d1
                    add.w    d1,a0
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d1,a0
                    addq.w   #6,a0
                    clr.w    $42(a2)
                    and.w    #3,d2
                    neg.w    d2
                    addq.w   #4,d2
                    and.w    #3,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    ror.w    #4,d2
                    or.w     #$9F0,d2
                    move.w   d2,$40(a2)
                    clr.w    $64(a2)
                    move.w   #14,$66(a2)
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+13,$58(a2)
                    lea      1664(a1),a1
                    lea      (200*40)(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+13,$58(a2)
                    lea      1664(a1),a1
                    lea      (200*40)(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+13,$58(a2)
                    lea      1664(a1),a1
                    lea      (200*40)(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+13,$58(a2)
                    bra      WAIT_BLIT

ONE_SLAB:           movem.l  d0-d4/a0-a4,-(sp)
                    lea      $DFF000,a2
                    tst.w    d4
                    bpl      lbC0061BE
                    moveq    #0,d4
lbC0061BE:          mulu     #520,d4
                    lea      LAND,a1
                    add.l    d4,a1
                    move.l   (a1),a4
                    addq.w   #8,a1
                    move.l   WHICHBACK,a0
                    add.w    d3,d3
                    add.w    d3,a0
                    move.w   #$8440,$96(a2)
                    move.l   #-1,$44(a2)
                    clr.w    $42(a2)
                    move.w   #$9F0,$40(a2)
                    move.w   #0,$64(a2)
                    move.w   #24,$66(a2)
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    add.w    a4,a1
                    lea      1664(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    add.w    a4,a1
                    lea      1664(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    add.w    a4,a1
                    lea      1664(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    bsr      WAIT_BLIT
                    movem.l  (sp)+,d0-d4/a0-a4
                    rts

DRAWSLAB:           movem.l  d3/d4,-(sp)
                    move.w   #(64<<6)+1,d7
                    bsr      ONE_SLAB
                    tst.w    d4
                    beq      lbC00628E
                    cmp.w    #12,d4
                    blt      lbC0062AC
                    cmp.w    #$21,d4
                    bgt      lbC0062AC
                    cmp.w    #$13,d4
                    ble      lbC00628E
                    cmp.w    #$1D,d4
                    bge      lbC00628E
                    bra      lbC0062AC

lbC00628E:          moveq    #$3E,d4
                    move.l   a0,d7
                    btst     #3,d7
                    beq      lbC00629C
                    moveq    #$40,d4
lbC00629C:          and.w    #7,d7
                    bne      lbC0062AC
                    move.w   #(15<<6)+1,d7
                    bsr      ONE_SLAB
lbC0062AC:          movem.l  (sp)+,d3/d4
                    rts

DRAWBACK:           move.l   WHICHBACK,a0
                    move.w   X,d1
                    asl.w    #3,d1
                    add.w    d1,a0
                    move.w   HEIGHT,d1
                    subq.w   #1,d1
                    move.l   BUFFER,a1
                    move.w   #96,d0
lbC0062D4:          move.l   (a1)+,(a0)+
                    move.l   (a1)+,(a0)+
                    add.w    d0,a0
                    dbra     d1,lbC0062D4
                    rts

DRAWOBJ:            tst.w    d0
                    bne      DRAWOBJ1_0
                    move.w   WIN1X,d1
                    move.w   WIN1Y,d2
                    move.w   #$32,ULX
                    move.w   #3,ULY
                    lea      S1DEPTH,a0
                    bra      DRAWOBJ1_1

DRAWOBJ1_0:         move.w   WIN2X,d1
                    move.w   WIN2Y,d2
                    move.w   #$32,ULX
                    move.w   #$66,ULY
                    lea      S2DEPTH,a0
DRAWOBJ1_1:         move.w   d1,d3
                    lsr.w    #2,d1
                    lsr.w    #2,d2
                    move.w   d1,WINX
                    move.w   d2,WINY
                    and.w    #3,d3
                    add.w    d3,d3
                    add.w    d3,d3
                    neg.w    d3
                    add.w    #14,d3
                    move.w   d3,OFFSET
                    moveq    #0,d5
                    bra      DRAW_7

DRAW_6:             clr.w    LASTSPY
                    moveq    #0,d4
                    bra      DRAW_11

DRAW_10:            move.w   d5,d3
                    add.w    WINY,d3
                    move.w   MAXMAPX,d1
                    mulu     d1,d3
                    move.w   d4,d2
                    add.w    WINX,d2
                    ext.l    d2
                    add.l    d2,d3
                    lea      MAP,a6
                    moveq    #0,d6
                    move.b   (a6,d3.l),d6
                    beq      DRAW_14
                    tst.w    LASTSPY
                    bne      DRAW_14
                    cmp.w    #$69,d6
                    bne      lbC0063D0
                    cmp.w    #$30,S1HAND
                    beq      lbC0063D0
                    cmp.w    #$30,S2HAND
                    beq      lbC0063D0
                    tst.w    DRAWSUB
                    bne      lbC0063D0
                    bra      DRAW_14

lbC0063D0:          move.w   d6,d3
                    cmp.w    #$AD,d3
                    beq      lbC0063E2
                    and.w    #4,d3
                    bne      DRAW_12
lbC0063E2:          move.w   d6,d3
                    move.w   d6,d1
                    lsr.w    #3,d1
DRAW_10_2:          tst.w    d1
                    beq      DRAW_14
                    cmp.w    #$78,d3
                    beq      DRAW_14
                    cmp.w    #$A0,d3
                    beq      DRAW_14
                    cmp.w    #$F0,d3
                    beq      DRAW_14
                    cmp.w    #$C8,d3
                    beq      DRAW_14
                    cmp.w    #$C0,d3
                    bge      DRAW_14
                    lea      TREETAB,a6
                    cmp.w    #$A9,d3
                    beq      lbC00643C
                    lea      12(a6),a6
                    cmp.w    #$AB,d3
                    beq      lbC00643C
                    lea      12(a6),a6
                    cmp.w    #$AD,d3
                    bne      DRAW10_3
lbC00643C:          move.w   d4,d1
                    lsl.w    #4,d1
                    add.w    ULX,d1
                    add.w    OFFSET,d1
                    sub.w    #$10,d1
                    move.w   d1,X
                    move.w   d5,d1
                    add.w    d1,d1
                    move.w   d1,Y
                    add.w    d1,d1
                    add.w    d1,Y
                    move.w   ULY,d1
                    subq.w   #2,d1
                    add.w    d1,Y
                    move.w   #$34,HEIGHT
                    tst.w    d5
                    bne      lbC006496
                    move.w   #8,d1
                    add.w    d1,Y
                    sub.w    d1,HEIGHT
lbC006496:          cmp.w    #1,d5
                    bne      lbC0064AE
                    move.w   #4,d1
                    add.w    d1,Y
                    sub.w    d1,HEIGHT
lbC0064AE:          tst.w    d4
                    bne      DRAW10_2_1
                    move.w   #$10,d1
                    add.w    d1,X
                    move.l   8(a6),BUFFER
                    move.w   #2,WIDTH
                    bra      DRAW10_2_3

DRAW10_2_1:         cmp.w    #11,d4
                    bne      DRAW10_2_2
                    move.l   4(a6),BUFFER
                    move.w   #2,WIDTH
                    bra      DRAW10_2_3

DRAW10_2_2:         move.l   (a6),BUFFER
                    move.w   #3,WIDTH
DRAW10_2_3:         move.l   SCREEN2,SCREEN
                    bsr      SPRITER_AM
                    bra      DRAW_14

DRAW10_3:           mulu     #168,d1
                    add.l    #OBJS,d1
                    move.l   d1,BUFFER
                    bra      DRAW_13

DRAW_12:            move.l   #OBJS,BUFFER
DRAW_13:            move.w   d4,d1
                    lsl.w    #4,d1
                    add.w    ULX,d1
                    add.w    OFFSET,d1
                    move.w   d1,X
                    move.w   d5,d1
                    add.w    d1,d1
                    move.w   d1,Y
                    add.w    d1,d1
                    add.w    d1,Y
                    move.w   ULY,d1
                    add.w    #$2E,d1
                    add.w    d1,Y
                    move.w   #2,WIDTH
                    move.w   #6,HEIGHT
                    move.l   SCREEN2,SCREEN
                    bsr      SPRITER_AM
DRAW_14:            movem.l  d0-d6,-(sp)
                    add.w    d4,d4
                    add.w    d4,d4
                    add.w    d5,d5
                    add.w    d5,d5
                    tst.w    d0
                    bne      DRAW14_1
                    add.w    WIN1Y,d5
                    add.w    WIN1X,d4
                    bra      DRAW14_2

DRAW14_1:           add.w    WIN2Y,d5
                    add.w    WIN2X,d4
DRAW14_2:           tst.w    LASTSPY
                    beq      lbC0065BE
                    lsr.w    #2,d4
                    lsr.w    #2,d5
                    bsr      DRAWSPY
lbC0065BE:          movem.l  (sp)+,d0-d6
                    add.w    #1,d4
DRAW_11:            cmp.w    #11,d4
                    ble      DRAW_10
                    clr.w    d4
                    tst.w    LASTSPY
                    bne      lbC0065E4
                    addq.w   #1,LASTSPY
                    bra      DRAW_10

lbC0065E4:          addq.w   #1,d5
DRAW_7:             move.w   #$10,d1
                    lsr.w    #2,d1
                    cmp.w    d1,d5
                    blt      DRAW_6
DRAWLAND5_2:        tst.w    d0
                    bne      DRAWLAND5_3
                    move.w   #11,Y
                    bra      DRAWLAND5_4

DRAWLAND5_3:        move.w   #$6E,Y
DRAWLAND5_4:        move.w   #$F8,X
                    move.l   #RTCOVER,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   #2,WIDTH
                    move.w   #$40,HEIGHT
                    movem.l  d0,-(sp)
                    bsr      SPRITER_AM
                    movem.l  (sp)+,d0
                    rts

DRAWROPES:          movem.l  d0-d7/a0-a6,-(sp)
                    move.l   SCREEN2,a0
                    tst.w    S1DRLINE
                    beq      lbC006680
                    move.w   S1LINEX1,d1
                    move.w   S1LINEY1,d2
                    move.w   S1LINEX2,d3
                    move.w   S1LINEY2,d4
                    move.w   #14,d7
                    bsr      DRAW_LINE
                    clr.w    S1DRLINE
lbC006680:          tst.w    S2DRLINE
                    beq      lbC0066B0
                    move.w   S2LINEX1,d1
                    move.w   S2LINEY1,d2
                    move.w   S2LINEX2,d3
                    move.w   S2LINEY2,d4
                    move.w   #15,d7
                    bsr      DRAW_LINE
                    clr.w    S2DRLINE
lbC0066B0:          movem.l  (sp)+,d0-d7/a0-a6
                    rts

DRAWFUEL:           move.l   d0,-(sp)
                    tst.w    d0
                    bne      lbC0066E6
                    move.w   S1FUEL,d0
                    lea      L_S1FUEL,a6
                    bsr      COMPARETWICE
                    beq      DRAWFUEL2
                    move.w   S1FUEL,d5
                    move.w   #$21,a2
                    move.w   #$4E,d2
                    clr.w    d0
                    bra      lbC00670C

lbC0066E6:          move.w   S2FUEL,d0
                    lea      L_S2FUEL,a6
                    bsr      COMPARETWICE
                    beq      DRAWFUEL2
                    move.w   #1,d0
                    move.w   S2FUEL,d5
                    move.w   #$21,a2
                    move.w   #$B1,d2
lbC00670C:          move.l   SCREEN2,a0
                    move.w   a2,a3
                    add.w    #10,a3
                    move.w   #10,d6
                    sub.w    d5,d6
                    tst.w    d6
                    beq      DRAWFUEL1
                    move.w   #2,d7
_HORLINE:           bsr      HORLINE
                    addq.w   #1,d2
                    subq.w   #1,d6
                    bne.b    _HORLINE
DRAWFUEL1:          tst.w    d5
                    beq      DRAWFUEL2
                    move.w   #14,d7
_HORLINE0:          bsr      HORLINE
                    addq.w   #1,d2
                    subq.w   #1,d5
                    bne.b    _HORLINE0
DRAWFUEL2:          move.l   (sp)+,d0
                    rts

CLEAR_WINDOW:       movem.l  a0/a2,-(sp)
                    lea      $DFF000,a2
                    add.l    SCREEN2,a0
                    move.w   #$1F0,$40(a2)
                    clr.w    $42(a2)
                    move.w   #14,$66(a2)
                    move.w   #$FFFF,$74(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+13,$58(a2)
                    bsr      WAIT_BLIT
                    lea      (200*40)(a0),a0
                    clr.w    $74(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+13,$58(a2)
                    bsr      WAIT_BLIT
                    lea      (200*40)(a0),a0
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+13,$58(a2)
                    bsr      WAIT_BLIT
                    lea      (200*40)(a0),a0
                    clr.w    $74(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+13,$58(a2)
                    bsr      WAIT_BLIT
                    movem.l  (sp)+,a0/a2
                    rts

WHICHBACK:          dcb.l    4,0
TREETAB:            dc.l     ONETREE
                    dc.l     ONETREEA
                    dc.l     ONETREEB
                    dc.l     TWOTREE
                    dc.l     TWOTREEA
                    dc.l     TWOTREEB
                    dc.l     THRTREE
                    dc.l     THRTREEA
                    dc.l     THRTREEB
SEL_FLAG:           dc.w     0
LASTSPY:            dc.w     0

BUSY:               bsr      READ_TRIGS
                    tst.w    d0
                    bne      lbC006816
                    tst.w    DELAY0
                    beq      lbC006828
                    subq.w   #1,DELAY0
                    rts

lbC006816:          tst.w    DELAY1
                    beq      lbC006828
                    subq.w   #1,DELAY1
                    rts

lbC006828:          move.w   d1,d2
                    move.w   d1,d3
                    lsr.w    #8,d2
                    and.w    #$FF,d1
                    tst.w    d2
                    beq      BUSY1_0
                    cmp.w    #2,d2
                    beq      BUSY2_0
                    cmp.w    #3,d2
                    beq      BUSY3_0
                    cmp.w    #4,d2
                    beq      BUSY4_0
                    cmp.w    #5,d2
                    beq      BUSY5_0
                    cmp.w    #6,d2
                    beq      BUSY6_0
                    cmp.w    #7,d2
                    beq      BUSY7_0
                    cmp.w    #8,d2
                    beq      BUSY8_0
                    cmp.w    #9,d2
                    beq      BUSY9_0
                    cmp.w    #10,d2
                    beq      BUSY10_0
                    cmp.w    #11,d2
                    beq      BUSY11_0
                    cmp.w    #12,d2
                    beq      BUSY12_0
                    cmp.w    #13,d2
                    beq      BUSY13_0
                    cmp.w    #14,d2
                    beq      BUSY14_0
                    cmp.w    #15,d2
                    beq      BUSY15_0
                    cmp.w    #16,d2
                    beq      BUSY16_0
                    cmp.w    #17,d2
                    beq      BUSY17_0
                    cmp.w    #18,d2
                    beq      BUSY18_0
                    cmp.w    #19,d2
                    beq      BUSY19_0
                    cmp.w    #20,d2
                    beq      BUSY20_0
                    cmp.w    #21,d2
                    beq      BUSY21_0
                    cmp.w    #22,d2
                    beq      BUSY22
                    cmp.w    #64,d2
                    beq      BUSY40_0
                    cmp.w    #65,d2
                    beq      BUSY41_0
                    cmp.w    #36,d2
                    beq      BUSY36
                    rts

BUSY1_0:            tst.w    d0
                    bne      lbC006910
                    tst.w    S1AUTO
                    beq      lbC00691E
                    bra      BRAINBUSY

lbC006910:          tst.w    S2AUTO
                    beq      lbC00691E
                    bra      BRAINBUSY

lbC00691E:          tst.w    d0
                    bne      BUSY1_0_1
                    tst.w    S1DEAD
                    beq      lbC006930
                    rts

lbC006930:          move.w   JOY1TRIG,d1
                    bra      BUSY1_0_2

BUSY1_0_1:          tst.w    S2DEAD
                    beq      lbC006946
                    rts

lbC006946:          move.w   JOY2TRIG,d1
BUSY1_0_2:          bne      BUSY1_0_3
                    bsr      GETBTIME
                    addq.w   #1,d1
                    cmp.w    COUNTER,d1
                    beq      BUSY1_1
                    rts

BUSY1_0_3:          bsr      GETBTIME
                    addq.w   #1,d1
                    cmp.w    COUNTER,d1
                    beq      BUSY1_0_4
                    bsr      GETBTIME
                    addq.w   #4,d1
                    cmp.w    COUNTER,d1
                    blt      BUSY1_0_4
                    move.w   #$600,d3
                    bra      SETSTATE

BUSY1_0_4:          move.w   SPYWIN,d3
                    beq      BUSY1_0_5
BUSY1_0_4_3:        tst.w    d0
                    bne      lbC0069D2
                    cmp.w    #$48,S1HAND
                    beq      BUSY1_0_5
                    cmp.b    #8,S2CT
                    beq      lbC006A00
                    cmp.b    #9,S2CT
                    beq      lbC006A00
                    tst.b    S2CT
                    bne      BUSY1_0_5
                    bra      lbC006A00

lbC0069D2:          cmp.w    #$48,S2HAND
                    beq      BUSY1_0_5
                    cmp.b    #8,S1CT
                    beq      lbC006A00
                    cmp.b    #9,S1CT
                    beq      lbC006A00
                    tst.b    S1CT
                    bne      BUSY1_0_5
lbC006A00:          move.w   S1MAPX,d3
                    sub.w    S2MAPX,d3
                    bpl      lbC006A12
                    neg.w    d3
lbC006A12:          cmp.w    #$19,d3
                    bge      BUSY1_0_5
                    move.w   S1MAPY,d3
                    sub.w    S2MAPY,d3
                    bpl      lbC006A2C
                    neg.w    d3
lbC006A2C:          cmp.w    #3,d3
                    bhi      BUSY1_0_5
                    tst.w    d0
                    bne      lbC006A60
                    tst.w    S2DEAD
                    bne      BUSY1_0_5
                    tst.w    S2CT
                    beq      _BUSY4_A
                    move.w   S2CT,d3
                    and.w    #$FF00,d3
                    cmp.w    #$800,d3
                    bra      _BUSY4_A

lbC006A60:          tst.w    S1DEAD
                    bne      BUSY1_0_5
                    tst.w    S1CT
                    beq      _BUSY4_A
                    move.w   S1CT,d3
                    and.w    #$FF00,d3
                    cmp.w    #$800,d3
_BUSY4_A:           bsr      BUSY4_A
                    move.w   d0,-(sp)
                    move.w   #1,d0
                    sub.w    (sp),d0
                    bsr      BUSY4_A
                    move.w   (sp)+,d0
                    move.w   #$800,d3
                    bsr      SETSTATE
                    bra      BUSY8_0

BUSY1_0_5:          tst.w    d0
                    bne      lbC006AB0
                    move.w   S1CT,d3
                    bra      lbC006AB6

lbC006AB0:          move.w   S2CT,d3
lbC006AB6:          and.w    #$FF00,d3
                    cmp.w    #$800,d3
                    bne      lbC006ACA
                    move.w   #0,d3
                    bsr      SETSTATE
lbC006ACA:          tst.w    d0
                    bne      BUSY1_0_6
                    move.w   COUNTER,B1TIME
                    bsr      JOYMOVE
                    or.w     d2,d1
                    bne      BUSY4_0
                    rts

BUSY1_0_6:          move.w   COUNTER,B2TIME
                    bsr      JOYMOVE
                    or.w     d2,d1
                    bne      BUSY4_0
                    rts

BUSY1_1:            tst.w    d0
                    bne      BUSY1_1_0
                    move.w   S1HAND,d2
                    bra      BUSY1_1_1

BUSY1_1_0:          move.w   S2HAND,d2
BUSY1_1_1:          tst.w    d2
                    beq      BUSY1_2
                    bsr      JOYMOVE
                    or.w     d2,d1
                    tst.w    d1
                    bne      BUSY4_0
                    move.w   #3,d3
                    lsl.w    #8,d3
                    bsr      SETSTATE
                    bra      BUSY3_0

BUSY1_2:            tst.w    d0
                    bne      BUSY1_2_1
                    tst.w    S1SAFE
                    bne      BUSY1_3
                    move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    bra      BUSY1_2_2

BUSY1_2_1:          tst.w    S2SAFE
                    bne      BUSY1_3
                    move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
BUSY1_2_2:          move.w   SPYY,d1
                    lsr.w    #2,d1
                    mulu     MAXMAPX,d1
                    move.w   SPYX,d2
                    lsr.w    #2,d2
                    add.w    d2,d1
                    move.w   d1,a0
                    add.l    #MAP,a0
                    moveq    #0,d1
                    move.b   (a0),d1
                    and.w    #2,d1
                    bne      BUSY2_0
BUSY1_3:            rts

BUSY2_0:            tst.w    d1
                    bne      BUSY2_0_5
                    tst.w    d0
                    bne      lbC006BC2
                    move.w   S1MAPX,d1
                    move.w   S1MAPY,d2
                    bra      lbC006BCE

lbC006BC2:          move.w   S2MAPX,d1
                    move.w   S2MAPY,d2
lbC006BCE:          lsr.w    #2,d2
                    mulu     MAXMAPX,d2
                    lsr.w    #2,d1
                    add.w    d2,d1
                    lea      MAP,a0
                    add.w    d1,a0
                    move.w   #2,d1
BUSY2_0_5:          cmp.w    #2,d1
                    bne      BUSY2_4
                    moveq    #0,d4
                    move.b   (a0),d4
                    beq      BUSY6_4
                    cmp.w    #$60,d4
                    blt      lbC006C02
                    bra      BUSY6_4

lbC006C02:          moveq    #14,d7
                    bsr      NEW_SOUND
                    bsr      DELETE_TRAP
                    and.w    #$FFF8,d4
                    bsr      KILLDOUBLE
                    cmp.w    #$37,d4
                    bgt      lbC006CAC
                    cmp.w    #$30,d4
                    bne      lbC006C34
                    clr.w    XROCKET
                    clr.w    YROCKET
                    bra      lbC006CAC

lbC006C34:          cmp.w    #$18,d4
                    bne      lbC006C4C
                    clr.w    XNOSE
                    clr.w    YNOSE
                    bra      lbC006CAC

lbC006C4C:          cmp.w    #$10,d4
                    bne      lbC006C64
                    clr.w    XMID
                    clr.w    YMID
                    bra      lbC006CAC

lbC006C64:          cmp.w    #8,d4
                    bne      lbC006C7C
                    clr.w    XTAIL
                    clr.w    YTAIL
                    bra      lbC006CAC

lbC006C7C:          cmp.w    #$20,d4
                    bne      lbC006C94
                    clr.w    XMIDNOSE
                    clr.w    YMIDNOSE
                    bra      lbC006CAC

lbC006C94:          cmp.w    #$28,d4
                    bne      lbC006CAC
                    clr.w    XMIDTAIL
                    clr.w    YMIDTAIL
                    bra      lbC006CAC

lbC006CAC:          move.w   #1,DELAY_IN
                    tst.w    d0
                    bne      BUSY2_2_1
                    move.w   d4,S1TEMPHAND
                    clr.w    S1F
                    move.l   #BUF16,S1FADDR
                    bra      BUSY2_4

BUSY2_2_1:          move.w   d4,S2TEMPHAND
                    clr.w    S2F
                    move.l   #BUF26,S2FADDR
BUSY2_4:            cmp.w    #4,d1
                    beq      BUSY2_5
                    add.w    #$201,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY2_5:            tst.w    d0
                    bne      BUSY2_6
                    move.l   #BUF14,S1FADDR
                    move.w   S1TEMPHAND,S1HAND
                    bra      BUSY2_7

BUSY2_6:            move.l   #BUF24,S2FADDR
                    move.w   S2TEMPHAND,S2HAND
BUSY2_7:            move.w   #$700,d3
                    bra      SETSTATE

BUSY3_0:            tst.w    d0
                    bne      BUSY3_1
                    move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    move.w   S1HAND,d3
                    clr.w    S1HAND
                    bra      BUSY3_2

BUSY3_1:            move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
                    move.w   S2HAND,d3
                    clr.w    S2HAND
BUSY3_2:            tst.w    d3
                    bne      BUSY3_2_0_1
                    rts

BUSY3_2_0_1:        moveq    #15,d7
                    bsr      NEW_SOUND
                    bsr      KILLDOUBLE
                    cmp.w    #$48,d3
                    bne      BUSY3_2_A
                    tst.w    d0
                    bne      BUSY3_2_0_0
                    move.w   #1,d1
                    add.w    d1,S1GUN
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_0_0:        move.w   #1,d1
                    add.w    d1,S2GUN
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_A:          cmp.w    #$58,d3
                    bne      BUSY3_2_B
                    tst.w    d0
                    bne      BUSY3_2_A_0
                    move.w   #1,d1
                    add.w    d1,S1ROPE
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_A_0:        move.w   #1,d1
                    add.w    d1,S2ROPE
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_B:          cmp.w    #$40,d3
                    bne      BUSY3_2_C
                    tst.w    d0
                    bne      BUSY3_2_B_0
                    move.w   #1,d1
                    add.w    d1,S1SHOV
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_B_0:        move.w   #1,d1
                    add.w    d1,S2SHOV
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_C:          cmp.w    #$50,d3
                    bne      BUSY3_2_D
                    tst.w    d0
                    bne      BUSY3_2_C_0
                    move.w   #1,d1
                    add.w    d1,S1COCO
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_C_0:        move.w   #1,d1
                    add.w    d1,S2COCO
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_D:          cmp.w    #$60,d3
                    bne      BUSY3_2_Z
                    tst.w    d0
                    bne      BUSY3_2_D_0
                    move.w   #1,d1
                    add.w    d1,S1NAPA
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_D_0:        move.w   #1,d1
                    add.w    d1,S2NAPA
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_Z:          move.w   SPYY,d1
                    lsr.w    #2,d1
                    mulu     MAXMAPX,d1
                    move.w   SPYX,d2
                    lsr.w    #2,d2
                    add.w    d2,d1
                    move.w   d1,a0
                    add.l    #MAP,a0
                    bsr      ADD_TRAP
                    cmp.w    #$37,d3
                    bgt      lbC006F7C
                    movem.l  d0-d3/a0-a2,-(sp)
                    cmp.w    #$30,d3
                    bne      lbC006EEC
                    lea      XROCKET,a1
                    lea      YROCKET,a2
                    bsr      SETXY
                    bra      lbC006F78

lbC006EEC:          cmp.w    #$18,d3
                    bne      lbC006F08
                    lea      XNOSE,a1
                    lea      YNOSE,a2
                    bsr      SETXY
                    bra      lbC006F78

lbC006F08:          cmp.w    #$10,d3
                    bne      lbC006F24
                    lea      XMID,a1
                    lea      YMID,a2
                    bsr      SETXY
                    bra      lbC006F78

lbC006F24:          cmp.w    #8,d3
                    bne      lbC006F40
                    lea      XTAIL,a1
                    lea      YTAIL,a2
                    bsr      SETXY
                    bra      lbC006F78

lbC006F40:          cmp.w    #$20,d3
                    bne      lbC006F5C
                    lea      XMIDNOSE,a1
                    lea      YMIDNOSE,a2
                    bsr      SETXY
                    bra      lbC006F78

lbC006F5C:          cmp.w    #$28,d3
                    bne      lbC006F78
                    lea      XMIDTAIL,a1
                    lea      YMIDTAIL,a2
                    bsr      SETXY
                    bra      lbC006F78

lbC006F78:          movem.l  (sp)+,d0-d3/a0-a2
lbC006F7C:          and.w    #$FFF8,d3
                    or.w     #2,d3
                    move.b   d3,(a0)
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY4_0:            bsr      KILLDOUBLE
                    tst.w    d0
                    bne      BUSY4_1
                    tst.w    S1SAFE
                    bne      BUSY6_4
                    move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    move.w   S1HAND,d3
                    cmp.w    #$48,d3
                    beq      BUSY4_2
                    clr.w    S1HAND
                    bra      BUSY4_2

BUSY4_1:            tst.w    S2SAFE
                    bne      BUSY6_4
                    move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
                    move.w   S2HAND,d3
                    cmp.w    #$48,d3
                    beq      BUSY4_2
                    clr.w    S2HAND
BUSY4_2:            tst.w    d3
                    bne      BUSY4_2_0
                    rts

BUSY4_2_0:          bsr      KILLDOUBLE
                    cmp.w    #$48,d3
                    bne      BUSY4_2_1_0
                    tst.w    d0
                    bne      lbC007024
                    tst.w    S2DEAD
                    bne      BUSY4_8
lbC007024:          tst.w    S1DEAD
                    bne      BUSY4_8
                    tst.w    BULLET
                    beq      BUSY4_8
                    subq.w   #1,BULLET
                    moveq    #2,d7
                    bsr      NEW_SOUND
                    tst.w    SPYWIN
                    beq      BUSY4_8
                    bsr      JOYMOVE
                    move.w   S1MAPY,d3
                    sub.w    S2MAPY,d3
                    bpl      lbC007064
                    neg.w    d3
lbC007064:          cmp.w    #5,d3
                    bge      BUSY4_2_0_4
                    tst.w    d1
                    beq      BUSY4_2_0_4
                    tst.w    d0
                    bne      BUSY4_2_0_1
                    move.w   S2MAPX,d3
                    sub.w    S1MAPX,d3
                    muls     d1,d3
                    bmi      BUSY7_0
                    move.w   #$B00,S2CT
                    move.w   #$A00,d3
                    bra      SETSTATE

BUSY4_2_0_1:        move.w   S1MAPX,d3
                    sub.w    S2MAPX,d3
                    muls     d1,d3
                    bmi      BUSY7_0
                    moveq    #2,d7
                    bsr      NEW_SOUND
                    move.w   #$B00,S1CT
                    move.w   #$A00,d3
                    bra      SETSTATE

BUSY4_2_0_4:        move.w   S1MAPX,d3
                    sub.w    S2MAPX,d3
                    add.w    #1,d3
                    bmi      BUSY7_0
                    cmp.w    #3,d3
                    bge      BUSY7_0
                    tst.w    d2
                    beq      BUSY7_0
                    tst.w    d0
                    bne      BUSY4_2_0_5
                    move.w   S2MAPY,d3
                    sub.w    S1MAPY,d3
                    muls     d2,d3
                    bmi      BUSY7_0
                    moveq    #2,d7
                    bsr      NEW_SOUND
                    move.w   #$B00,S2CT
                    move.w   #$A00,d3
                    bra      SETSTATE

BUSY4_2_0_5:        move.w   S1MAPY,d3
                    sub.w    S2MAPY,d3
                    muls     d2,d3
                    bmi      BUSY7_0
                    moveq    #2,d7
                    bsr      NEW_SOUND
                    move.w   #$B00,S1CT
                    move.w   #$A00,d3
                    bra      SETSTATE

BUSY4_2_1_0:        moveq    #3,d7
                    bsr      NEW_SOUND
                    move.w   SPYY,d1
                    lsr.w    #2,d1
                    mulu     MAXMAPX,d1
                    move.w   SPYX,d2
                    lsr.w    #2,d2
                    add.w    d2,d1
                    move.w   d1,a0
                    add.l    #MAP,a0
                    moveq    #0,d1
                    move.b   (a0),d1
                    and.w    #$FFF8,d1
                    cmp.w    #$30,d1
                    bge      BUSY4_2_1
                    cmp.w    #$30,d3
                    bge      BUSY4_2_1
                    cmp.w    #8,d1
                    bne      lbC0071B8
                    cmp.w    #$10,d3
                    bne      lbC00719C
                    move.b   #$2A,(a0)
                    clr.w    XTAIL
                    clr.w    YTAIL
                    bra      _BUSY4_7

lbC00719C:          cmp.w    #$20,d3
                    bne      BUSY4_2_1
                    move.b   #$32,(a0)
                    clr.w    XTAIL
                    clr.w    YTAIL
                    bra      _BUSY4_7

lbC0071B8:          cmp.w    #$10,d1
                    bne      lbC0071F8
                    cmp.w    #8,d3
                    bne      lbC0071DC
                    move.b   #$2A,(a0)
                    clr.w    XMID
                    clr.w    YMID
                    bra      _BUSY4_7

lbC0071DC:          cmp.w    #$18,d3
                    bne      BUSY4_2_1
                    move.b   #$22,(a0)
                    clr.w    XMID
                    clr.w    YMID
                    bra      _BUSY4_7

lbC0071F8:          cmp.w    #$18,d1
                    bne      lbC007238
                    cmp.w    #$10,d3
                    bne      lbC00721C
                    move.b   #$22,(a0)
                    clr.w    XNOSE
                    clr.w    YNOSE
                    bra      _BUSY4_7

lbC00721C:          cmp.w    #$28,d3
                    bne      BUSY4_2_1
                    move.b   #$32,(a0)
                    clr.w    XNOSE
                    clr.w    YNOSE
                    bra      _BUSY4_7

lbC007238:          cmp.w    #$20,d1
                    bne      lbC00725C
                    cmp.w    #8,d3
                    bne      lbC00725C
                    move.b   #$32,(a0)
                    clr.w    XMIDNOSE
                    clr.w    YMIDNOSE
                    bra      _BUSY4_7

lbC00725C:          cmp.w    #$28,d1
                    bne      BUSY4_2_1
                    cmp.w    #$18,d3
                    bne      BUSY4_2_1
                    move.b   #$32,(a0)
                    clr.w    XMIDTAIL
                    clr.w    YMIDTAIL
                    bra      _BUSY4_7

_BUSY4_7:           bra      BUSY4_7

BUSY4_2_1:          move.l   a0,a1
                    bsr      ADD_TRAP
BUSY4_3:            and.w    #$FFF8,d3
                    cmp.w    #$50,d3
                    bne      BUSY4_4
                    tst.w    d0
                    bne      lbC0072A6
                    lea      S1FUEL,a2
                    bra      lbC0072AC

lbC0072A6:          lea      S2FUEL,a2
lbC0072AC:          tst.w    (a2)
                    beq      BUSY4_4
                    move.w   #$68,d3
                    subq.w   #1,(a2)
                    bsr      SETSAFE
                    bra      BUSY4_6

BUSY4_4:            cmp.w    #$60,d3
                    bne      BUSY4_5
                    move.w   #$70,d3
                    bsr      SETSAFE
                    bra      BUSY4_6

BUSY4_5:            cmp.w    #$40,d3
                    bne      BUSY4_6
                    clr.w    d3
                    cmp.l    a0,a1
                    beq      lbC0072E6
                    rts

lbC0072E6:          clr.w    d1
                    bra      B99

BUSY4_6:            or.w     #6,d3
                    move.b   d3,(a0)
BUSY4_7:            cmp.b    #$37,(a0)
                    bgt      BUSY4_8
                    tst.b    (a0)
                    beq      BUSY4_8
                    movem.l  d0-d3/a0-a2,-(sp)
                    moveq    #0,d3
                    move.b   (a0),d3
                    and.w    #$FFF8,d3
                    cmp.w    #$30,d3
                    bne      lbC007328
                    lea      XROCKET,a1
                    lea      YROCKET,a2
                    bsr      SETXY
                    bra      lbC0073B4

lbC007328:          cmp.w    #$18,d3
                    bne      lbC007344
                    lea      XNOSE,a1
                    lea      YNOSE,a2
                    bsr      SETXY
                    bra      lbC0073B4

lbC007344:          cmp.w    #$10,d3
                    bne      lbC007360
                    lea      XMID,a1
                    lea      YMID,a2
                    bsr      SETXY
                    bra      lbC0073B4

lbC007360:          cmp.w    #8,d3
                    bne      lbC00737C
                    lea      XTAIL,a1
                    lea      YTAIL,a2
                    bsr      SETXY
                    bra      lbC0073B4

lbC00737C:          cmp.w    #$20,d3
                    bne      lbC007398
                    lea      XMIDNOSE,a1
                    lea      YMIDNOSE,a2
                    bsr      SETXY
                    bra      lbC0073B4

lbC007398:          cmp.w    #$28,d3
                    bne      lbC0073C0
                    lea      XMIDTAIL,a1
                    lea      YMIDTAIL,a2
                    bsr      SETXY
                    bra      lbC0073B4

lbC0073B4:          movem.l  (sp)+,d0-d3/a0-a2
                    move.w   #$700,d3
                    bra      SETSTATE

lbC0073C0:          movem.l  (sp)+,d0-d3/a0-a2
BUSY4_8:            clr.w    d3
                    bra      SETSTATE

BUSY4_A:            movem.l  d1-d3,-(sp)
                    tst.w    d0
                    bne      BUSY4_B
                    move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    move.w   S1HAND,d3
                    clr.w    S1HAND
                    bra      BUSY4_C

BUSY4_B:            move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
                    move.w   S2HAND,d3
                    clr.w    S2HAND
BUSY4_C:            tst.w    d3
                    bne      BUSY4_D
                    movem.l  (sp)+,d1-d3
                    rts

BUSY4_D:            move.w   SPYY,d1
                    lsr.w    #2,d1
                    mulu     MAXMAPX,d1
                    move.w   SPYX,d2
                    lsr.w    #2,d2
                    add.w    d2,d1
                    move.w   d1,a0
                    add.l    #MAP,a0
BUSY4_E:            cmp.b    #$F0,(a0)
                    beq      lbC007454
                    cmp.b    #$A0,(a0)
                    bne      lbC00750E
lbC007454:          cmp.w    #$30,d3
                    bgt      lbC00750E
                    movem.l  d0-d4/a0-a3,-(sp)
                    movem.l  d0-d3,-(sp)
                    move.w   #1,d1
                    move.w   d3,d2
                    or.w     #6,d2
                    bsr      STUFFIT
                    movem.l  (sp)+,d0-d3
                    cmp.w    #$30,d3
                    bne      lbC00748E
                    lea      XROCKET,a1
                    lea      YROCKET,a2
                    bra      _SETXY

lbC00748E:          cmp.w    #$18,d3
                    bne      lbC0074A6
                    lea      XNOSE,a1
                    lea      YNOSE,a2
                    bra      _SETXY

lbC0074A6:          cmp.w    #$10,d3
                    bne      lbC0074BE
                    lea      XMID,a1
                    lea      YMID,a2
                    bra      _SETXY

lbC0074BE:          cmp.w    #8,d3
                    bne      lbC0074D6
                    lea      XTAIL,a1
                    lea      YTAIL,a2
                    bra      _SETXY

lbC0074D6:          cmp.w    #$20,d3
                    bne      lbC0074EE
                    lea      XMIDNOSE,a1
                    lea      YMIDNOSE,a2
                    bra      _SETXY

lbC0074EE:          cmp.w    #$28,d3
                    bne      _SETXY
                    lea      XMIDTAIL,a1
                    lea      YMIDTAIL,a2
_SETXY:             bsr      SETXY
                    movem.l  (sp)+,d0-d4/a0-a3
                    bra      BUSY4_H

lbC00750E:          tst.b    -(a0)
                    beq      BUSY4_G
                    tst.b    -(a0)
                    beq      BUSY4_G
                    add.w    #2,a0
BUSY4_F:            add.w    #1,a0
                    tst.b    (a0)
                    bne.b    BUSY4_F
BUSY4_G:            and.w    #$FFF8,d3
                    or.w     #6,d3
                    move.b   d3,(a0)
BUSY4_H:            cmp.b    #$37,(a0)
                    bgt      lbC0075F8
                    movem.l  d0-d3/a0-a2,-(sp)
                    moveq    #0,d3
                    move.b   (a0),d3
                    and.w    #$FFF8,d3
                    cmp.w    #$30,d3
                    bne      lbC007560
                    lea      XROCKET,a1
                    lea      YROCKET,a2
                    bsr      SETXY
                    bra      lbC0075EC

lbC007560:          cmp.w    #$18,d3
                    bne      lbC00757C
                    lea      XNOSE,a1
                    lea      YNOSE,a2
                    bsr      SETXY
                    bra      lbC0075EC

lbC00757C:          cmp.w    #$10,d3
                    bne      lbC007598
                    lea      XMID,a1
                    lea      YMID,a2
                    bsr      SETXY
                    bra      lbC0075EC

lbC007598:          cmp.w    #8,d3
                    bne      lbC0075B4
                    lea      XTAIL,a1
                    lea      YTAIL,a2
                    bsr      SETXY
                    bra      lbC0075EC

lbC0075B4:          cmp.w    #$20,d3
                    bne      lbC0075D0
                    lea      XMIDNOSE,a1
                    lea      YMIDNOSE,a2
                    bsr      SETXY
                    bra      lbC0075EC

lbC0075D0:          cmp.w    #$28,d3
                    bne      lbC0075F4
                    lea      XMIDTAIL,a1
                    lea      YMIDTAIL,a2
                    bsr      SETXY
                    bra      lbC0075EC

lbC0075EC:          move.w   #$700,d3
                    bsr      SETSTATE
lbC0075F4:          movem.l  (sp)+,d0-d3/a0-a2
lbC0075F8:          movem.l  (sp)+,d1-d3
                    rts

DELETE_TRAP:        movem.l  d6/d7/a4,-(sp)
                    lea      TRAPLIST,a4
                    move.l   a0,d7
                    move.w   #100-1,d6
lbC00760E:          cmp.l    (a4),d7
                    beq      lbC007620
                    addq.w   #6,a4
                    dbra     d6,lbC00760E
                    clr.b    (a0)
                    bra      lbC00762C

lbC007620:          move.w   4(a4),d6
                    move.b   d6,(a0)
                    clr.l    (a4)
                    clr.w    4(a4)
lbC00762C:          movem.l  (sp)+,d6/d7/a4
                    rts

ADD_TRAP:           movem.l  d3-d7/a2/a4,-(sp)
                    moveq    #0,d5
                    tst.b    (a0)
                    beq      lbC0076AE
                    tst.w    d0
                    bne      lbC007652
                    tst.w    S1AUTO
                    bne      lbC007672
                    bra      lbC00765C

lbC007652:          tst.w    S2AUTO
                    bne      lbC007672
lbC00765C:          move.b   (a0),d4
                    and.w    #$F0,d4
                    cmp.w    #$A0,d4
                    beq      lbC007672
                    cmp.w    #$F0,d4
                    bne      lbC007686
lbC007672:          addq.w   #1,d5
                    addq.w   #1,d3
                    and.w    #1,d3
                    beq      lbC007682
                    sub.w    d5,a0
                    bra.b    lbC00765C

lbC007682:          add.w    d5,a0
                    bra.b    lbC00765C

lbC007686:          tst.b    (a0)
                    beq      lbC0076AE
                    lea      TRAPLIST,a4
                    move.w   #100-1,d6
lbC007696:          tst.l    (a4)
                    beq      lbC0076A6
                    addq.w   #6,a4
                    dbra     d6,lbC007696
                    bra      lbC0076AE

lbC0076A6:          move.l   a0,(a4)+
                    moveq    #0,d3
                    move.b   (a0),d3
                    move.w   d3,(a4)
lbC0076AE:          movem.l  (sp)+,d3-d7/a2/a4
                    rts

COUNTER1:           dc.w     0
COUNTER2:           dc.w     0

BUSY5_0:            tst.w    SPYWIN
                    beq      lbC0076C6
                    bra      BUSY6_4

lbC0076C6:          movem.l  d0-d3,-(sp)
                    bsr      JOYMOVE
                    movem.l  (sp)+,d0-d3
                    move.w   d1,d6
                    tst.w    d0
                    bne      BUSY5_0_1
                    tst.w    S1DEPTH
                    bne      BUSY6_4
                    tst.w    S1SWAMP
                    bne      BUSY6_4
                    move.w   #3,d2
                    move.w   JOY1TRIG,d3
                    bra      BUSY5_0_2

BUSY5_0_1:          tst.w    S2DEPTH
                    bne      BUSY6_4
                    tst.w    S2SWAMP
                    bne      BUSY6_4
                    move.w   #$66,d2
                    move.w   JOY2TRIG,d3
BUSY5_0_2:          cmp.w    #0,d1
                    bne      BUSY5_1
                    tst.w    d3
                    beq      BUSY5_0_3
                    rts

BUSY5_0_3:          move.w   #$501,d3
                    bra      SETSTATE

BUSY5_1:            cmp.w    #1,d1
                    bne      BUSY5_2
                    move.w   #$2C,d3
                    lsr.w    #2,d3
                    move.w   d3,HEIGHT
                    bsr      SHOWMAP
                    move.w   #$502,d3
                    bra      SETSTATE

BUSY5_2:            cmp.w    #2,d1
                    bne      BUSY5_3
                    move.w   #$2C,d3
                    lsr.w    #1,d3
                    move.w   d3,HEIGHT
                    bsr      SHOWMAP
                    move.w   #$503,d3
                    bra      SETSTATE

BUSY5_3:            cmp.w    #3,d1
                    bne      BUSY5_4
                    move.w   #$2C,d3
                    mulu     #3,d3
                    lsr.w    #2,d3
                    move.w   d3,HEIGHT
                    bsr      SHOWMAP
                    move.w   #$504,d3
                    bra      SETSTATE

BUSY5_4:            move.w   d3,-(sp)
                    move.w   d1,d3
                    add.w    #$501,d3
                    cmp.w    #$FF,d1
                    bne      _SETSTATE
                    subq.w   #8,d3
_SETSTATE:          bsr      SETSTATE
                    move.w   #$2C,HEIGHT
                    bsr      SHOWMAP
                    tst.w    d0
                    bne      BUSY5_4_0
                    move.w   S1MAPX,d1
                    move.w   S1MAPY,d2
                    lea      S1TRAIL,a1
                    move.w   #$14,d5
                    bra      BUSY5_4_1

BUSY5_4_0:          move.w   S2MAPX,d1
                    move.w   S2MAPY,d2
                    lea      S2TRAIL,a1
                    move.w   #$77,d5
BUSY5_4_1:          bsr      GETPOS
                    move.w   COUNTER,d2
                    and.w    #1,d2
                    bne      BUSY5_4_2
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPBOX,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
BUSY5_4_2:          tst.w    XROCKET
                    beq      lbC00787E
                    move.w   XROCKET,d1
                    move.w   YROCKET,d2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d2,d2
                    add.w    d2,d2
                    bsr      GETPOS
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPSPOT,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
lbC00787E:          tst.w    XMIDNOSE
                    beq      lbC0078CC
                    move.w   XMIDNOSE,d1
                    move.w   YMIDNOSE,d2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d2,d2
                    add.w    d2,d2
                    bsr      GETPOS
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPSPOT,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
lbC0078CC:          tst.w    XMIDTAIL
                    beq      lbC00791A
                    move.w   XMIDTAIL,d1
                    move.w   YMIDTAIL,d2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d2,d2
                    add.w    d2,d2
                    bsr      GETPOS
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPSPOT,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
lbC00791A:          tst.w    XNOSE
                    beq      lbC007968
                    move.w   XNOSE,d1
                    move.w   YNOSE,d2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d2,d2
                    add.w    d2,d2
                    bsr      GETPOS
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPSPOT,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
lbC007968:          tst.w    XMID
                    beq      lbC0079B6
                    move.w   XMID,d1
                    move.w   YMID,d2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d2,d2
                    add.w    d2,d2
                    bsr      GETPOS
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPSPOT,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
lbC0079B6:          tst.w    XTAIL
                    beq      lbC007A04
                    move.w   XTAIL,d1
                    move.w   YTAIL,d2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d2,d2
                    add.w    d2,d2
                    bsr      GETPOS
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPSPOT,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
lbC007A04:          movem.l  d0-d7/a0-a4,-(sp)
lbC007A08:          cmp.w    #-1,2(a1)
                    beq      lbC007A90
                    move.w   (a1),d2
                    move.w   2(a1),d4
                    move.w   d2,d1
                    move.w   d4,d3
                    lsr.w    #8,d1
                    and.w    #$FF,d2
                    lsr.w    #8,d3
                    and.w    #$FF,d4
                    sub.w    d1,d3
                    sub.w    d2,d4
                    add.w    d3,d3
                    add.w    d4,d4
                    movem.l  d0-d2/a1,-(sp)
                    bsr      GETPOS1
                    movem.l  (sp)+,d0-d2/a1
                    addq.w   #6,X
                    addq.w   #3,Y
                    move.w   #8,d6
                    tst.w    d3
                    bne      lbC007A5A
                    move.w   #4,d6
lbC007A5A:          move.w   #14,COLOR
                    move.w   #1,COUNT
                    movem.l  d0-d5/a1,-(sp)
                    bsr      HLINE
                    movem.l  (sp)+,d0-d5/a1
                    add.w    d3,X
                    add.w    d4,Y
                    subq.w   #1,d6
                    bne.b    lbC007A5A
                    add.l    #2,a1
                    bra      lbC007A08

lbC007A90:          movem.l  (sp)+,d0-d7/a0-a4
BUSY5_5:            move.w   d6,d1
                    move.w   (sp)+,d3
                    tst.w    d0
                    bne      lbC007AAC
                    tst.w    S1AUTO
                    beq      lbC007ACC
                    bra      lbC007AB6

lbC007AAC:          tst.w    S2AUTO
                    beq      lbC007ACC
lbC007AB6:          move.w   IQ,d2
                    lsl.w    #4,d2
                    move.w   #$5A,d3
                    sub.w    d2,d3
                    sub.w    d1,d3
                    blt      BUSY5_6
                    rts

lbC007ACC:          tst.w    d3
                    bne      BUSY5_6
                    rts

BUSY5_6:            clr.w    d3
                    bra      SETSTATE

BUSY6_0:            tst.w    d0
                    bne      BUSY6_0_1
                    move.w   JOY1TRIG,d2
                    move.w   S1MENU,d4
                    move.w   #1,S1FLASH
                    bra      BUSY6_0_2

BUSY6_0_1:          move.w   JOY2TRIG,d2
                    move.w   S2MENU,d4
                    move.w   #1,S2FLASH
BUSY6_0_2:          tst.w    d1
                    bne      BUSY6_1
                    tst.w    d2
                    beq      BUSY6_0_3
                    rts

BUSY6_0_3:          movem.l  d0-d7/a0-a6,-(sp)
                    tst.w    d0
                    bne      lbC007B4E
                    lea      S1BACK,a1
                    move.w   #11,d2
                    move.w   #-1,BUF1Y
                    bra      lbC007B60

lbC007B4E:          lea      S2BACK,a1
                    move.w   #$6E,d2
                    move.w   #-1,BUF2Y
lbC007B60:          move.w   #4,d1
                    move.w   #12,d6
                    move.w   #$40,d7
                    move.l   SCREEN1,a0
                    bsr      RSAVE_BUFF
                    move.w   #4,d1
                    move.w   #12,d6
                    move.w   #$40,d7
                    move.l   SCREEN2,a0
                    bsr      RDRAW_BUFF
                    movem.l  (sp)+,d0-d7/a0-a6
                    move.w   #$601,d3
                    bsr      SETSTATE
BUSY6_1:            tst.w    d2
                    bne      BUSY6_2
                    move.w   COUNTER,d1
                    and.w    #3,d1
                    bne      BUSY6_1_4
                    move.w   d4,-(sp)
                    bsr      JOYMOVE
                    move.w   (sp)+,d4
                    tst.w    d2
                    beq      lbC007BC0
                    moveq    #1,d7
                    bsr      NEW_SOUND
lbC007BC0:          add.w    d2,d4
                    tst.w    d4
                    bgt      BUSY6_1_1
                    move.w   #6,d4
                    bra      BUSY6_1_2

BUSY6_1_1:          cmp.w    #6,d4
                    ble      BUSY6_1_2
                    move.w   #1,d4
BUSY6_1_2:          tst.w    d0
                    bne      BUSY6_1_3
                    move.w   d4,S1MENU
                    rts

BUSY6_1_3:          move.w   d4,S2MENU
BUSY6_1_4:          rts

BUSY6_2:            tst.w    d0
                    bne      BUSY6_2_1
                    clr.w    S1FLASH
                    bra      BUSY6_3

BUSY6_2_1:          clr.w    S2FLASH
BUSY6_3:            tst.w    d0
                    bne      BUSY6_3_0_1
                    move.w   S1HAND,d1
                    bra      BUSY6_3_0_2

BUSY6_3_0_1:        move.w   S2HAND,d1
BUSY6_3_0_2:        tst.w    d1
                    bne      BUSY6_4
                    cmp.w    #1,d4
                    bne      BUSY6_3_1
                    tst.w    d0
                    bne      BUSY6_3_0_3
                    move.w   S1SHOV,d1
                    beq      BUSY6_4
                    move.w   #$40,S1HAND
                    subq.w   #1,S1SHOV
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_0_3:        move.w   S2SHOV,d1
                    beq      BUSY6_4
                    move.w   #$40,S2HAND
                    subq.w   #1,S2SHOV
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_1:          cmp.w    #2,d4
                    bne      BUSY6_3_2
                    tst.w    d0
                    bne      BUSY6_3_1_0
                    move.w   S1GUN,d1
                    beq      BUSY6_4
                    move.w   #$48,S1HAND
                    subq.w   #1,S1GUN
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_1_0:        move.w   S2GUN,d1
                    beq      BUSY6_4
                    move.w   #$48,S2HAND
                    subq.w   #1,S2GUN
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_2:          cmp.w    #3,d4
                    bne      BUSY6_3_3
                    tst.w    d0
                    bne      BUSY6_3_2_0
                    move.w   S1COCO,d1
                    beq      BUSY6_4
                    move.w   #$50,S1HAND
                    subq.w   #1,S1COCO
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_2_0:        move.w   S2COCO,d1
                    beq      BUSY6_4
                    move.w   #$50,S2HAND
                    subq.w   #1,S2COCO
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_3:          cmp.w    #4,d4
                    bne      BUSY6_3_4
                    tst.w    d0
                    bne      BUSY6_3_3_0
                    move.w   S1ROPE,d1
                    beq      BUSY6_4
                    move.w   #$58,S1HAND
                    subq.w   #1,S1ROPE
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_3_0:        move.w   S2ROPE,d1
                    beq      BUSY6_4
                    move.w   #$58,S2HAND
                    subq.w   #1,S2ROPE
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_4:          cmp.w    #5,d4
                    bne      BUSY6_3_5
                    tst.w    d0
                    bne      BUSY6_3_4_0
                    move.w   S1NAPA,d1
                    beq      BUSY6_4
                    move.w   #$60,S1HAND
                    subq.w   #1,S1NAPA
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_4_0:        move.w   S2NAPA,d1
                    beq      BUSY6_4
                    move.w   #$60,S2HAND
                    subq.w   #1,S2NAPA
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_5:          cmp.w    #6,d4
                    bne      BUSY6_4
                    move.w   #$500,d3
                    bra      SETSTATE

BUSY6_4:            clr.w    d3
                    bra      SETSTATE

BUSY7_0:            move.w   #$700,d3
                    bsr      SETSTATE
                    tst.w    d0
                    bne      BUSY7_1
                    move.w   JOY1TRIG,d1
                    bra      BUSY7_2

BUSY7_1:            move.w   JOY2TRIG,d1
BUSY7_2:            beq      BUSY7_3
                    rts

BUSY7_3:            clr.w    d3
                    bra      SETSTATE

BUSY8_0:            move.w   #$10,d4
                    tst.w    d0
                    bne      lbC007E20
                    move.w   #1,S1RUN
                    clr.w    S1RUN
                    move.w   #$19,d4
                    move.w   #4,d5
                    tst.w    S1AUTO
                    beq      lbC007E48
                    move.w   #5,d4
                    move.w   #0,d5
                    bra      lbC007E48

lbC007E20:          move.w   #1,S2RUN
                    clr.w    S2RUN
                    move.w   #$19,d4
                    move.w   #4,d5
                    tst.w    S2AUTO
                    beq      lbC007E48
                    move.w   #5,d4
                    move.w   #0,d5
lbC007E48:          move.w   S1MAPX,d3
                    sub.w    S2MAPX,d3
                    bge      lbC007E5A
                    neg.w    d3
lbC007E5A:          cmp.w    d4,d3
                    bge      BUSY8_0_1
                    move.w   S1MAPY,d1
                    sub.w    S2MAPY,d1
                    bpl      lbC007E72
                    neg.w    d1
lbC007E72:          cmp.w    d5,d1
                    bhi      BUSY8_0_1
                    tst.w    S1DEAD
                    bne      BUSY8_0_1
                    tst.w    S1DEPTH
                    bne      BUSY8_0_1
                    tst.w    S1SWAMP
                    bne      BUSY8_0_1
                    tst.w    S2DEAD
                    bne      BUSY8_0_1
                    tst.w    S2DEPTH
                    bne      BUSY8_0_1
                    tst.w    S2SWAMP
                    bne      BUSY8_0_1
                    tst.w    d0
                    bne      lbC007EEE
                    cmp.w    #$48,S1HAND
                    beq      BUSY8_0_1
                    move.w   S2CT,d3
                    and.w    #$FF00,d3
                    cmp.w    #$800,d3
                    beq      _BUSY8_1
                    cmp.w    #$900,d3
                    beq      _BUSY8_1
                    tst.w    S2CT
                    beq      _BUSY8_1
                    bra      BUSY8_0_1

lbC007EEE:          cmp.w    #$48,S2HAND
                    beq      BUSY8_0_1
                    move.w   S1CT,d3
                    and.w    #$FF00,d3
                    cmp.w    #$800,d3
                    beq      _BUSY8_1
                    cmp.w    #$900,d3
                    beq      _BUSY8_1
                    tst.w    S1CT
                    beq      _BUSY8_1
                    bra      BUSY8_0_1

_BUSY8_1:           bra      BUSY8_1

BUSY8_0_1:          tst.w    d0
                    bne      BUSY8_0_2
                    move.l   S1FADDR,d1
                    cmp.l    #BUF17,d1
                    beq      BUSY8_0_1_0
                    move.l   #BUF12,S1FADDR
                    clr.w    S1F
                    bra      BUSY8_0_3

BUSY8_0_1_0:        move.l   #BUF11,S1FADDR
                    clr.w    S1F
                    bra      BUSY8_0_3

BUSY8_0_2:          move.l   S2FADDR,d1
                    cmp.l    #BUF27,d1
                    beq      BUSY8_0_2_0
                    move.l   #BUF22,S2FADDR
                    clr.w    S2F
                    bra      BUSY8_0_3

BUSY8_0_2_0:        move.l   #BUF21,S2FADDR
                    clr.w    S2F
BUSY8_0_3:          clr.w    d3
                    bra      SETSTATE

BUSY8_1:            tst.w    d0
                    bne      lbC007FB6
                    tst.w    S1HAND
                    beq      lbC007FC4
                    bsr      BUSY4_A
                    bra      lbC007FC4

lbC007FB6:          tst.w    S2HAND
                    beq      lbC007FC4
                    bsr      BUSY4_A
lbC007FC4:          tst.w    d0
                    bne      BUSY8_2
                    move.w   #1,d1
                    tst.w    S1AUTO
                    bne      lbC007FE2
                    move.w   JOY1TRIG,d1
                    bra      lbC008006

lbC007FE2:          tst.w    SPYWIN
                    beq      BUSY8_0_1
                    move.w   #1,S1RUN
                    cmp.w    #15,S1ENERGY
                    ble      BUSY8_0_1
                    clr.w    S1RUN
lbC008006:          tst.w    d1
                    bne      BUSY8_1_0
                    bra      BUSY8_0_1

BUSY8_1_0:          move.w   S2MAPX,d1
                    sub.w    S1MAPX,d1
                    bgt      BUSY8_1_1
                    move.l   #BUF18,S1FADDR
                    bra      BUSY8_1_2

BUSY8_1_1:          move.l   #BUF17,S1FADDR
BUSY8_1_2:          tst.w    S1AUTO
                    beq      _JOYMOVE
                    moveq    #0,d1
                    moveq    #0,d2
                    tst.w    S1BASH
                    beq      _RNDER2
                    bmi      lbC008060
                    moveq    #1,d1
                    clr.w    S1BASH
                    bra      lbC0080DC

lbC008060:          moveq    #1,d2
                    clr.w    S1BASH
                    bra      lbC0080DC

_RNDER2:            bsr      RNDER2
                    and.w    #$3F,d1
                    move.w   IQ,d7
                    add.w    d7,d7
                    lea      RANDIQ,a0
                    cmp.w    0(a0,d7.w),d1
                    bls      lbC008090
                    moveq    #0,d1
                    bra      lbC0080DC

lbC008090:          move.w   #1,DELAY_IN
                    tst.w    S1AUTO
                    bne      lbC0080AA
                    move.w   #3,DELAY_IN
lbC0080AA:          btst     #0,d1
                    bne      lbC0080C0
                    move.w   #1,S1BASH
                    moveq    #-1,d1
                    bra      lbC0080DC

lbC0080C0:          move.w   #-1,S1BASH
                    moveq    #-1,d2
                    moveq    #0,d1
                    bra      lbC0080DC

_JOYMOVE:           bsr      JOYMOVE
                    bra      lbC0080DC

                    move.w   #1,d1
lbC0080DC:          cmp.w    #-1,d2
                    bne      BUSY8_1_3
                    clr.w    S1F
BUSY8_RET:          move.w   #$800,d3
                    bra      SETSTATE

RANDIQ:             dc.w     $23,$28,$2B,$2F,$33,$37

BUSY8_1_3:          cmp.w    #1,d2
                    bne      BUSY8_1_4
                    move.w   S1F,d1
                    cmp.w    #0,d1
                    bne      BUSY8_1_6
                    move.w   #1,S1F
                    move.w   S2MAPX,d1
                    sub.w    S1MAPX,d1
                    add.w    #4,d1
                    blt      BUSY8_1_6
                    cmp.w    #8,d1
                    bgt      BUSY8_1_6
                    move.w   S2MAPY,d1
                    sub.w    S1MAPY,d1
                    add.w    #2,d1
                    blt      BUSY8_1_6
                    cmp.w    #4,d1
                    bgt      BUSY8_1_6
                    move.w   #$900,S2CT
                    bra.b    BUSY8_RET

BUSY8_1_4:          cmp.w    #1,d1
                    bne      BUSY8_1_5
                    move.w   S1F,d1
                    move.w   #2,S1F
                    cmp.w    #3,d1
                    bne      BUSY8_1_6
                    cmp.l    #BUF17,S1FADDR
                    bne      BUSY8_1_6
                    move.w   S2MAPX,d1
                    sub.w    S1MAPX,d1
                    add.w    #4,d1
                    blt      BUSY8_1_6
                    cmp.w    #8,d1
                    bgt      BUSY8_1_6
                    move.w   S2MAPY,d1
                    sub.w    S1MAPY,d1
                    add.w    #2,d1
                    blt      BUSY8_1_6
                    cmp.w    #4,d1
                    bgt      BUSY8_1_6
                    move.w   #$900,S2CT
                    bra      BUSY8_RET

BUSY8_1_5:          cmp.w    #-1,d1
                    bne      BUSY8_1_6
                    move.w   S1F,d1
                    move.w   #3,S1F
                    cmp.w    #2,d1
                    bne      BUSY8_1_6
                    cmp.l    #BUF18,S1FADDR
                    bne      BUSY8_1_6
                    move.w   S2MAPX,d1
                    sub.w    S1MAPX,d1
                    add.w    #4,d1
                    blt      BUSY8_1_6
                    cmp.w    #8,d1
                    bgt      BUSY8_1_6
                    move.w   S2MAPY,d1
                    sub.w    S1MAPY,d1
                    add.w    #2,d1
                    blt      BUSY8_1_6
                    cmp.w    #4,d1
                    bgt      BUSY8_1_6
                    move.w   #$900,S2CT
BUSY8_1_6:          bra      BUSY8_RET

BUSY8_2:            move.w   #1,d1
                    tst.w    S2AUTO
                    bne      lbC008258
                    move.w   JOY2TRIG,d1
                    bra      lbC00827C

lbC008258:          tst.w    SPYWIN
                    beq      BUSY8_0_1
                    move.w   #1,S2RUN
                    cmp.w    #15,S2ENERGY
                    ble      BUSY8_0_1
                    clr.w    S2RUN
lbC00827C:          tst.w    d1
                    bne      BUSY8_2_0
                    bra      BUSY8_0_1

BUSY8_2_0:          move.w   S1MAPX,d1
                    sub.w    S2MAPX,d1
                    bgt      BUSY8_2_1
                    move.l   #BUF28,S2FADDR
                    bra      BUSY8_2_2

BUSY8_2_1:          move.l   #BUF27,S2FADDR
BUSY8_2_2:          tst.w    S2AUTO
                    beq      _JOYMOVE0
                    moveq    #0,d1
                    moveq    #0,d2
                    tst.w    S2BASH
                    beq      _RNDER20
                    bmi      lbC0082D6
                    moveq    #1,d1
                    clr.w    S2BASH
                    bra      lbC008352

lbC0082D6:          moveq    #1,d2
                    clr.w    S2BASH
                    bra      lbC008352

_RNDER20:           bsr      RNDER2
                    and.w    #$3F,d1
                    move.w   IQ,d7
                    add.w    d7,d7
                    lea      RANDIQ,a0
                    cmp.w    0(a0,d7.w),d1
                    bls      lbC008306
                    moveq    #0,d1
                    bra      lbC008352

lbC008306:          move.w   #1,DELAY_IN
                    tst.w    S2AUTO
                    bne      lbC008320
                    move.w   #3,DELAY_IN
lbC008320:          btst     #0,d1
                    bne      lbC008336
                    move.w   #1,S2BASH
                    moveq    #-1,d1
                    bra      lbC008352

lbC008336:          move.w   #-1,S2BASH
                    moveq    #-1,d2
                    moveq    #0,d1
                    bra      lbC008352

_JOYMOVE0:          bsr      JOYMOVE
                    bra      lbC008352

                    move.w   #1,d1
lbC008352:          cmp.w    #-1,d2
                    bne      BUSY8_2_3
                    clr.w    S2F
                    bra      BUSY8_RET

BUSY8_2_3:          cmp.w    #1,d2
                    bne      BUSY8_2_4
                    move.w   S2F,d1
                    cmp.w    #0,d1
                    bne      BUSY8_2_6
                    move.w   #1,S2F
                    move.w   S1MAPX,d1
                    sub.w    S2MAPX,d1
                    add.w    #4,d1
                    blt      BUSY8_2_6
                    cmp.w    #8,d1
                    bgt      BUSY8_2_6
                    move.w   S1MAPY,d1
                    sub.w    S2MAPY,d1
                    add.w    #2,d1
                    blt      BUSY8_2_6
                    cmp.w    #4,d1
                    bgt      BUSY8_2_6
                    move.w   #$900,S1CT
                    bra      BUSY8_RET

BUSY8_2_4:          cmp.w    #1,d1
                    bne      BUSY8_2_5
                    move.w   S2F,d1
                    move.w   #2,S2F
                    cmp.w    #3,d1
                    bne      BUSY8_2_6
                    cmp.l    #BUF27,S2FADDR
                    bne      BUSY8_2_6
                    move.w   S1MAPX,d1
                    sub.w    S2MAPX,d1
                    add.w    #4,d1
                    blt      BUSY8_2_6
                    cmp.w    #8,d1
                    bgt      BUSY8_2_6
                    move.w   S1MAPY,d1
                    sub.w    S2MAPY,d1
                    add.w    #2,d1
                    blt      BUSY8_2_6
                    cmp.w    #4,d1
                    bgt      BUSY8_2_6
                    move.w   #$900,S1CT
                    bra      BUSY8_RET

BUSY8_2_5:          cmp.w    #-1,d1
                    bne      BUSY8_2_6
                    move.w   S2F,d1
                    move.w   #3,S2F
                    cmp.w    #2,d1
                    bne      BUSY8_2_6
                    cmp.l    #BUF28,S2FADDR
                    bne      BUSY8_2_6
                    move.w   S1MAPX,d1
                    sub.w    S2MAPX,d1
                    add.w    #4,d1
                    blt      BUSY8_2_6
                    cmp.w    #8,d1
                    bgt      BUSY8_2_6
                    move.w   S1MAPY,d1
                    sub.w    S2MAPY,d1
                    add.w    #2,d1
                    blt      BUSY8_2_6
                    cmp.w    #4,d1
                    bgt      BUSY8_2_6
                    move.w   #$900,S1CT
BUSY8_2_6:          bra      BUSY8_RET

SETSAFE:            tst.w    d0
                    bne      SETSAFE1
                    move.w   #4,S1SAFE
                    rts

SETSAFE1:           move.w   #4,S2SAFE
                    rts

KILLDOUBLE:         movem.l  d1,-(sp)
                    move.w   COUNTER,d1
                    sub.w    #$14,d1
                    tst.w    d0
                    bne      lbC0084DE
                    move.w   d1,B1TIME
                    bra      lbC0084E4

lbC0084DE:          move.w   d1,B2TIME
lbC0084E4:          movem.l  (sp)+,d1
                    rts

GETPOS:             asr.w    #6,d1
                    asr.w    #4,d2
GETPOS1:            lsl.w    #4,d1
                    lsl.w    #3,d2
                    add.w    #$72,d1
                    add.w    d5,d2
                    move.w   d1,X
                    move.w   d2,Y
                    rts

BUSY9_0:            tst.w    d1
                    bne      BUSY9_4
                    move.l   #$4002,d7
                    tst.w    d0
                    bne      _NEW_SOUND
                    move.l   #$4010,d7
_NEW_SOUND:         bsr      NEW_SOUND
                    move.w   #1,DELAY_IN
                    tst.w    d0
                    bne      BUSY9_2
                    tst.w    S1HAND
                    beq      lbC00853E
                    bsr      BUSY4_A
lbC00853E:          move.w   #3,d2
                    sub.w    d2,S1ENERGY
                    move.w   #2,REFRESH
                    move.w   #1,S1F
                    move.w   S1MAPX,d1
                    sub.w    S2MAPX,d1
                    bgt      BUSY9_1
                    move.l   #BUF19,S1FADDR
                    move.w   #$901,d3
                    bra      SETSTATE

BUSY9_1:            move.l   #BUF1A,S1FADDR
                    move.w   #$901,d3
                    bra      SETSTATE

BUSY9_2:            tst.w    S2HAND
                    beq      lbC00859A
                    bsr      BUSY4_A
lbC00859A:          move.w   #3,d2
                    sub.w    d2,S2ENERGY
                    move.w   #2,REFRESH
                    move.w   #1,S2F
                    move.w   S2MAPX,d1
                    sub.w    S1MAPX,d1
                    bgt      BUSY9_3
                    move.l   #BUF29,S2FADDR
                    move.w   #$901,d3
                    bra      SETSTATE

BUSY9_3:            move.l   #BUF2A,S2FADDR
                    move.w   #$901,d3
                    bra      SETSTATE

BUSY9_4:            tst.w    d0
                    bne      BUSY9_5
                    move.l   S1FADDR,d1
                    cmp.l    #BUF19,d1
                    beq      BUSY9_4_0
                    move.w   #1,SPYDIR
                    move.l   #BUF12,S1FADDR
                    clr.w    S1F
                    bra      BUSY9_6

BUSY9_4_0:          move.w   #2,SPYDIR
                    move.l   #BUF11,S1FADDR
                    clr.w    S1F
                    bra      BUSY9_6

BUSY9_5:            move.l   S2FADDR,d1
                    cmp.l    #BUF29,d1
                    beq      BUSY9_5_0
                    move.w   #1,SPYDIR
                    move.l   #BUF22,S2FADDR
                    clr.w    S2F
                    bra      BUSY9_6

BUSY9_5_0:          move.w   #2,SPYDIR
                    move.l   #BUF21,S2FADDR
                    clr.w    S2F
BUSY9_6:            clr.w    d3
                    bra      SETSTATE

BUSY10_0:           move.w   #3,DELAY_IN
                    tst.w    d0
                    bne      BUSY10_0_0
                    tst.w    S1DEAD
                    bne      BUSY6_4
                    move.l   #BUF19,S1FADDR
                    lea      S1F,a0
                    bra      BUSY10_0_1

BUSY10_0_0:         tst.w    S2DEAD
                    bne      BUSY6_4
                    move.l   #BUF29,S2FADDR
                    lea      S2F,a0
BUSY10_0_1:         cmp.w    #8,d1
                    beq      BUSY10_4
                    btst     #0,d1
                    beq      BUSY10_1
                    move.w   #2,(a0)
                    add.w    #$A01,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY10_1:           move.w   #3,(a0)
                    add.w    #$A01,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY10_4:           tst.w    d0
                    bne      BUSY10_5
                    move.l   #BUF11,S1FADDR
                    bra      BUSY10_6

BUSY10_5:           move.l   #BUF21,S2FADDR
BUSY10_6:           bra      BUSY7_0

BUSY11_0:           tst.w    d0
                    bne      BUSY11_0_0
                    clr.w    S1F
                    lea      BUF11,a0
                    lea      BUF12,a1
                    lea      BUF13,a2
                    lea      BUF14,a3
                    lea      S1FADDR,a4
                    tst.w    d1
                    bne      BUSY11_0_1
                    move.w   #$10,d3
                    sub.w    d3,S1ENERGY
                    move.w   #2,REFRESH
                    bra      BUSY11_0_1

BUSY11_0_0:         clr.w    S2F
                    lea      BUF21,a0
                    lea      BUF22,a1
                    lea      BUF23,a2
                    lea      BUF24,a3
                    lea      S2FADDR,a4
                    tst.w    d1
                    bne      BUSY11_0_1
                    moveq    #$10,d3
                    sub.w    d3,S2ENERGY
                    move.w   #2,REFRESH
BUSY11_0_1:         move.w   #4,DELAY_IN
                    move.w   #$B01,d3
                    add.w    d1,d3
                    cmp.w    #8,d1
                    beq      BUSY11_4
                    and.w    #3,d1
                    bne      BUSY11_1
                    movem.l  d3/a0/a4,-(sp)
                    bsr      BUSY4_A
                    movem.l  (sp)+,d3/a0/a4
                    move.l   a0,(a4)
                    bra      SETSTATE

BUSY11_1:           cmp.w    #1,d1
                    bne      BUSY11_2
                    move.l   a1,(a4)
                    bra      SETSTATE

BUSY11_2:           cmp.w    #2,d1
                    bne      BUSY11_3
                    move.l   a2,(a4)
                    bra      SETSTATE

BUSY11_3:           cmp.w    #3,d1
                    bne      BUSY11_4
                    move.l   a3,(a4)
                    bra      SETSTATE

BUSY11_4:           clr.w    d3
                    bra      SETSTATE

BUSY12_0:           tst.w    d1
                    bne      BUSY12_3
                    bsr      BUSY4_A
                    move.l   #$4004,d7
                    bsr      NEW_SOUND
                    tst.w    d0
                    bne      BUSY12_2
                    sub.w    #$28,S1ENERGY
                    move.w   #2,REFRESH
                    clr.w    S1HAND
                    tst.w    S2CT
                    bne      BUSY12_3
                    move.w   #$A00,S2CT
                    bra      BUSY12_3

BUSY12_2:           sub.w    #$28,S2ENERGY
                    move.w   #2,REFRESH
                    clr.w    S2HAND
                    tst.w    S1CT
                    bne      BUSY12_3
                    move.w   #$A00,S1CT
BUSY12_3:           move.w   #1,DELAY_IN
BUSY12_3_0_0:       tst.w    d0
                    bne      BUSY12_3_0
                    lea      S1FADDR,a0
                    lea      S1F,a1
                    bra      BUSY12_3_1

BUSY12_3_0:         lea      S2FADDR,a0
                    lea      S2F,a1
BUSY12_3_1:         cmp.w    #3,d1
                    bgt      BUSY12_4
                    move.w   d1,(a1)
                    move.l   #BUF31,(a0)
                    add.w    #$C01,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY12_4:           cmp.w    #$3C,d1
                    beq      BUSY12_5
                    move.w   #3,(a1)
                    add.w    #$C01,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY12_5:           tst.w    d0
                    bne      BUSY12_6
                    move.l   #BUF11,S1FADDR
                    bra      BUSY12_7

BUSY12_6:           move.l   #BUF21,S2FADDR
BUSY12_7:           clr.w    d3
                    bra      SETSTATE

BUSY13_0:           move.w   #2,REFRESH
                    tst.w    d1
                    bne      BUSY13_1
                    bsr      BUSY4_A
                    moveq    #3,d7
                    bsr      NEW_SOUND
                    tst.w    d0
                    bne      lbC00891C
                    sub.w    #$18,S1ENERGY
                    tst.w    S2CT
                    bne      BUSY13_1
                    move.w   #$A00,S2CT
                    bra      BUSY13_1

lbC00891C:          sub.w    #$18,S2ENERGY
                    tst.w    S1CT
                    bne      BUSY13_1
                    move.w   #$A00,S1CT
BUSY13_1:           tst.w    d0
                    bne      lbC00895C
                    lea      S1ALTITUDE,a1
                    lea      S1FADDR,a2
                    clr.w    S1F
                    move.l   #BUF1C,S1FADDR
                    bra      lbC008978

lbC00895C:          lea      S2ALTITUDE,a1
                    lea      S2FADDR,a2
                    clr.w    S2F
                    move.l   #BUF2C,S2FADDR
lbC008978:          cmp.w    #3,d1
                    bge      BUSY13_2
                    move.w   d1,d2
                    move.w   d2,(a1)
                    bra      BUSY13_4

BUSY13_2:           cmp.w    #$10,d1
                    bge      BUSY13_3
                    move.w   d1,d2
                    and.w    #1,d2
                    add.w    #3,d2
                    move.w   d2,(a1)
                    bra      BUSY13_4

BUSY13_3:           cmp.w    #$64,d1
                    bge      BUSY13_5
                    move.w   #3,(a1)
BUSY13_4:           add.w    #$D01,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY13_5:           clr.w    (a1)
                    tst.w    d0
                    bne      lbC0089CC
                    move.l   #BUF14,S1FADDR
                    bra      lbC0089D6

lbC0089CC:          move.l   #BUF24,S2FADDR
lbC0089D6:          clr.w    (a3)
                    clr.w    d3
                    bra      SETSTATE

BUSY14_0:           bsr      BUSY4_A
                    move.l   #$4004,d7
                    bsr      NEW_SOUND
                    tst.w    d0
                    bne      BUSY14_2
                    sub.w    #$20,S1ENERGY
                    move.w   #2,REFRESH
                    clr.w    S1HAND
                    tst.w    S2CT
                    bne      BUSY14_3
                    move.w   #$A00,S2CT
                    bra      BUSY14_3

BUSY14_2:           sub.w    #$20,S2ENERGY
                    move.w   #2,REFRESH
                    clr.w    S2HAND
                    tst.w    S1CT
                    bne      BUSY14_3
                    move.w   #$A00,S1CT
BUSY14_3:           bra      BUSY12_3_0_0

BUSY15_0:           move.w   #1,DELAY_IN
                    tst.w    d1
                    bne      BUSY15_1
                    tst.w    d0
                    bne      lbC008A84
                    cmp.w    #$58,S1HAND
                    bne      BUSY6_4
                    tst.w    S1AUTO
                    beq      BUSY15_0_0
                    move.w   S1MAPX,d1
                    move.w   S1MAPY,d2
                    bra      lbC008AA6

lbC008A84:          cmp.w    #$58,S2HAND
                    bne      BUSY6_4
                    tst.w    S2AUTO
                    move.w   S2MAPX,d1
                    move.w   S2MAPY,d2
                    beq      BUSY15_0_0
lbC008AA6:          lsr.w    #2,d1
                    lsr.w    #2,d2
                    mulu     MAXMAPX,d2
                    add.w    d1,d2
                    add.l    #MAP,d2
                    move.l   d2,a0
                    cmp.b    #$A9,1(a0)
                    beq      lbC008AD8
                    cmp.b    #$AB,1(a0)
                    beq      lbC008AD8
                    cmp.b    #$AD,1(a0)
                    bne      lbC008AE0
lbC008AD8:          move.w   #1,d1
                    bra      BUSY15_0_1

lbC008AE0:          move.w   #-1,d1
                    bra      BUSY15_0_1

BUSY15_0_0:         bsr      JOYMOVE
BUSY15_0_1:         tst.w    d1
                    bgt      lbC008AFE
                    beq      lbC008B28
                    move.w   #2,d1
                    bra      lbC008B00

lbC008AFE:          clr.w    d1
lbC008B00:          tst.w    d0
                    bne      lbC008B16
                    move.w   d1,S1BUMP
                    clr.w    S1HAND
                    bra      lbC008B22

lbC008B16:          move.w   d1,S2BUMP
                    clr.w    S2HAND
lbC008B22:          clr.w    d1
                    bra      BUSY15_1

lbC008B28:          clr.w    d3
                    bra      SETSTATE

BUSY15_1:           move.w   d1,d3
                    and.w    #1,d3
                    cmp.w    #8,d1
                    bge      lbC008B42
                    move.w   d1,d2
                    bra      lbC008B54

lbC008B42:          cmp.w    #$10,d1
                    beq      lbC008BA0
                    bgt      lbC008C12
                    move.w   #15,d2
                    sub.w    d1,d2
lbC008B54:          tst.w    d0
                    bne      lbC008B7A
                    move.l   #BUF1B,S1FADDR
                    or.w     S1BUMP,d3
                    move.w   d3,S1F
                    move.w   d2,S1ALTITUDE
                    bra      lbC008B96

lbC008B7A:          move.l   #BUF2B,S2FADDR
                    or.w     S2BUMP,d3
                    move.w   d3,S2F
                    move.w   d2,S2ALTITUDE
lbC008B96:          add.w    #$F01,d1
                    move.w   d1,d3
                    bra      SETSTATE

lbC008BA0:          tst.w    d0
                    bne      lbC008BDE
                    move.l   #BUF14,S1FADDR
                    move.w   S1MAPX,d2
                    tst.w    S1BUMP
                    bne      lbC008BC8
                    addq.w   #3,d2
                    bra      lbC008BCA

lbC008BC8:          subq.w   #3,d2
lbC008BCA:          move.w   d2,S1TREEX
                    move.w   S1MAPY,S1TREEY
                    bra      lbC008C12

lbC008BDE:          move.l   #BUF24,S2FADDR
                    move.w   S2MAPX,d2
                    tst.w    S2BUMP
                    bne      lbC008C00
                    addq.w   #3,d2
                    bra      lbC008C02

lbC008C00:          subq.w   #3,d2
lbC008C02:          move.w   d2,S2TREEX
                    move.w   S2MAPY,S2TREEY
lbC008C12:          clr.w    DELAY_IN
                    cmp.w    #$C8,d1
                    beq      BUSY15_3
                    tst.w    d0
                    bne      lbC008C54
                    lea      S1F,a0
                    lea      S1TREEX,a1
                    lea      S1TREEY,a2
                    lea      S1MAPX,a3
                    lea      S1MAPY,a4
                    lea      JOY1TRIG,a5
                    lea      S1AUTO,a6
                    bra      lbC008C7E

lbC008C54:          lea      S2F,a0
                    lea      S2TREEX,a1
                    lea      S2TREEY,a2
                    lea      S2MAPX,a3
                    lea      S2MAPY,a4
                    lea      JOY2TRIG,a5
                    lea      S2AUTO,a6
lbC008C7E:          tst.w    (a6)
                    bne      BUSY15_3
                    move.w   (a3),-(sp)
                    move.w   (a4),-(sp)
                    move.w   (a3),SPYX
                    move.w   (a4),SPYY
                    movem.l  d0-d5/a0-a5,-(sp)
                    bsr      SETWINDOW
                    bsr      MOVE
                    bsr      GETWINDOW
                    movem.l  (sp)+,d0-d5/a0-a5
                    move.w   SPYX,(a3)
                    move.w   SPYY,(a4)
                    move.w   (a1),d2
                    move.w   (a3),d3
                    lsr.w    #2,d2
                    lsr.w    #2,d3
                    sub.w    d3,d2
                    bsr      ABSD2
                    cmp.w    #1,d2
                    bgt      lbC008CE0
                    move.w   (a2),d2
                    move.w   (a4),d3
                    lsr.w    #2,d2
                    lsr.w    #2,d3
                    sub.w    d3,d2
                    bsr      ABSD2
                    cmp.w    #1,d2
                    ble      _DIRFIX0
lbC008CE0:          move.w   (sp)+,(a4)
                    move.w   (sp)+,(a3)
                    clr.w    SPYDIR
                    clr.w    (a0)
                    bra      BUSY15_2

_DIRFIX0:           bsr      DIRFIX
                    addq.w   #4,sp
BUSY15_2:           bsr      DRAWROPE
                    tst.w    (a5)
                    bne      BUSY15_3
                    add.w    #$F01,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY15_3:           tst.w    d0
                    bne      lbC008D26
                    move.w   S1MAPX,d2
                    move.w   S1MAPY,d3
                    clr.w    S1BUMP
                    bra      lbC008D38

lbC008D26:          move.w   S2MAPX,d2
                    move.w   S2MAPY,d3
                    clr.w    S2BUMP
lbC008D38:          lsr.w    #2,d3
                    mulu     MAXMAPX,d3
                    lsr.w    #2,d2
                    add.w    d2,d3
                    add.l    #MAP,d3
                    move.l   d3,a0
                    bsr      ADD_TRAP
                    move.b   #$78,(a0)
                    bsr      SETSAFE
                    clr.w    d3
                    bra      SETSTATE

BUSY16_0:           move.w   #2,DELAY_IN
                    tst.w    d1
                    bne      B2
                    move.l   a0,a1
                    bsr      ADD_TRAP
                    cmp.l    a0,a1
                    bne      B98
                    bra      B99

B98:                bsr      DELETE_TRAP
                    bra      BUSY6_4

B99:                tst.w    d0
                    bne      B1
                    move.l   a0,S1DIG
                    tst.w    S1DEPTH
                    bne.b    B98
                    tst.w    S1SWAMP
                    bne.b    B98
                    bra      B2

B1:                 move.l   a0,S2DIG
                    tst.w    S2DEPTH
                    bne.b    B98
                    tst.w    S2SWAMP
                    bne.b    B98
B2:                 move.w   COUNTER,d2
                    and.w    #2,d2
                    lsr.w    #1,d2
                    tst.w    d0
                    bne      lbC008DFE
                    move.l   S1DIG,a0
                    move.l   #BUF15,S1FADDR
                    move.w   d2,S1F
                    lea      BUF14,a1
                    lea      S1FADDR,a2
                    lea      S1HAND,a3
                    lea      S1SHCT,a4
                    bra      lbC008E2C

lbC008DFE:          move.l   S2DIG,a0
                    move.l   #BUF25,S2FADDR
                    move.w   d2,S2F
                    lea      BUF24,a1
                    lea      S2FADDR,a2
                    lea      S2HAND,a3
                    lea      S2SHCT,a4
lbC008E2C:          move.w   d1,d2
                    lsr.w    #2,d2
                    bne      lbC008E42
                    moveq    #3,d7
                    bsr      NEW_SOUND
                    move.b   #$88,(a0)
                    bra      lbC008E8E

lbC008E42:          cmp.w    #1,d2
                    bne      lbC008E58
                    moveq    #3,d7
                    bsr      NEW_SOUND
                    move.b   #$90,(a0)
                    bra      lbC008E8E

lbC008E58:          cmp.w    #2,d2
                    bne      lbC008E68
                    move.b   #$98,(a0)
                    bra      lbC008E8E

lbC008E68:          move.l   a1,(a2)
                    bsr      SETSAFE
                    move.w   #0,d3
                    bsr      SETSTATE
                    add.w    #1,(a4)
                    cmp.w    #8,(a4)
                    bne      lbC008E88
                    clr.w    (a3)
                    clr.w    (a4)
                    rts

lbC008E88:          move.w   #$40,(a3)
                    rts

lbC008E8E:          add.w    #$1001,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY17_0:           tst.w    d1
                    bne      BUSY17_1
                    bsr      BUSY4_A
                    move.w   #$14,d2
                    move.w   #2,REFRESH
                    tst.w    d0
                    bne      lbC008ED0
                    sub.w    d2,S1ENERGY
                    tst.w    S2CT
                    bne      BUSY17_1
                    move.w   #$A00,S2CT
                    bra      BUSY17_1

lbC008ED0:          sub.w    d2,S2ENERGY
                    tst.w    S1CT
                    bne      BUSY17_1
                    move.w   #$A00,S1CT
BUSY17_1:           move.w   #2,DELAY_IN
                    cmp.w    #$3C,d1
                    bge      lbC008F4E
                    tst.w    d0
                    bne      lbC008F0A
                    move.w   #$14,S1DEPTH
                    bra      lbC008F12

lbC008F0A:          move.w   #$14,S2DEPTH
lbC008F12:          move.w   d1,d2
                    lsr.w    #3,d2
                    and.w    #1,d2
                    tst.w    d0
                    bne      lbC008F34
                    move.w   d2,S1F
                    move.l   #NOSE,S1FADDR
                    bra      lbC008F44

lbC008F34:          move.w   d2,S2F
                    move.l   #NOSE,S2FADDR
lbC008F44:          add.w    #$1101,d1
                    move.w   d1,d3
                    bra      SETSTATE

lbC008F4E:          tst.w    d0
                    bne      lbC008F68
                    clr.w    S1DEPTH
                    move.l   #BUF14,S1FADDR
                    bra      lbC008F78

lbC008F68:          clr.w    S2DEPTH
                    move.l   #BUF24,S2FADDR
lbC008F78:          clr.w    d3
                    bra      SETSTATE

BUSY18_0:           move.w   #$14,DELAY_IN
                    bsr      BUSY4_A
                    move.w   #$20,d2
                    move.w   #2,REFRESH
                    tst.w    d0
                    bne      lbC008FB8
                    sub.w    d2,S1ENERGY
                    tst.w    S2CT
                    bne      BUSY17_1
                    move.w   #$A00,S2CT
                    bra      BUSY17_1

lbC008FB8:          sub.w    d2,S2ENERGY
                    tst.w    S1CT
                    bne      BUSY17_1
                    move.w   #$A00,S1CT
                    bra      BUSY17_1

BUSY19_0:           move.w   #2,DELAY_IN
                    tst.w    d0
                    bne      lbC00901C
                    move.w   S1MAPX,d2
                    move.w   S1MAPY,d3
                    move.w   WIN1X,d4
                    move.w   S1MAPX,d5
                    lea      S1MAPX,a1
                    lea      S1FADDR,a2
                    lea      S1F,a3
                    lea      BUF14,a4
                    lea      S1DEPTH,a5
                    bra      lbC009052

lbC00901C:          move.w   S2MAPX,d2
                    move.w   S2MAPY,d3
                    move.w   WIN2X,d4
                    move.w   S2MAPX,d5
                    lea      S2MAPX,a1
                    lea      S2FADDR,a2
                    lea      S2F,a3
                    lea      BUF24,a4
                    lea      S2DEPTH,a5
lbC009052:          lsr.w    #2,d3
                    mulu     MAXMAPX,d3
                    lsr.w    #2,d2
                    add.w    d2,d3
                    add.l    #MAP,d3
                    move.l   d3,a0
                    move.w   #$A0,d2
                    cmp.w    #6,d1
                    bge      lbC0090AE
                    move.w   #$24,d3
                    sub.w    d1,d3
                    move.w   d3,(a5)
                    cmp.b    #$F0,1(a0)
                    beq      lbC00908E
                    cmp.b    #$A0,1(a0)
                    bne      lbC00909C
lbC00908E:          sub.w    d4,d5
                    cmp.w    #$1B,d5
                    bgt      lbC00909C
                    add.w    #1,(a1)
lbC00909C:          move.l   #FIN,(a2)
                    clr.w    (a3)
                    add.w    #$1301,d1
                    move.w   d1,d3
                    bra      SETSTATE

lbC0090AE:          cmp.w    #$12,d1
                    bge      lbC0090E8
                    move.w   #$1E,(a5)
                    move.w   #1,d3
                    sub.w    d3,a0
                    cmp.b    (a0),d2
                    bne      lbC0090D4
                    sub.w    d4,d5
                    cmp.w    #5,d5
                    blt      lbC0090D4
                    sub.w    #1,(a1)
lbC0090D4:          move.l   #FIN,(a2)
                    move.w   #1,(a3)
                    add.w    #$1301,d1
                    move.w   d1,d3
                    bra      SETSTATE

lbC0090E8:          cmp.w    #$18,d1
                    bge      lbC009120
                    move.w   #12,d3
                    add.w    d1,d3
                    move.w   d3,(a5)
                    cmp.b    1(a0),d2
                    bne      lbC00910E
                    sub.w    d4,d5
                    cmp.w    #$1B,d5
                    bgt      lbC00910E
                    add.w    #1,(a1)
lbC00910E:          move.l   #FIN,(a2)
                    clr.w    (a3)
                    add.w    #$1301,d1
                    move.w   d1,d3
                    bra      SETSTATE

lbC009120:          tst.w    d0
                    bne      lbC009134
                    tst.w    S1ENERGY
                    blt      lbC009146
                    bra      lbC00913E

lbC009134:          tst.w    S2ENERGY
                    blt      lbC009146
lbC00913E:          clr.w    (a3)
                    move.l   a4,(a2)
                    move.w   #$23,(a5)
lbC009146:          clr.w    d3
                    bra      SETSTATE

BUSY20_0:           move.w   #1,DELAY_IN
                    clr.w    S1RUN
                    clr.w    S2RUN
                    tst.w    d0
                    bne      lbC00919C
                    lea      S1FADDR,a1
                    lea      S1F,a2
                    lea      S1DEPTH,a3
                    move.w   #1,S1DEAD
                    lea      S1DROWN,a4
                    move.w   S1MAPX,d3
                    move.w   S1MAPY,d4
                    clr.w    S1SWAMP
                    bra      lbC0091CE

lbC00919C:          lea      S2FADDR,a1
                    lea      S2F,a2
                    lea      S2DEPTH,a3
                    move.w   #1,S2DEAD
                    lea      S2DROWN,a4
                    move.w   S2MAPX,d3
                    move.w   S2MAPY,d4
                    clr.w    S2SWAMP
lbC0091CE:          tst.w    d1
                    bne      lbC0091D8
                    bsr      BUSY4_A
lbC0091D8:          move.w   #2,DELAY_IN
                    clr.w    (a2)
                    move.l   #GRAVE,(a1)
                    tst.w    (a4)
                    beq      lbC0091F8
                    move.l   #BUBBLES,(a1)
                    bra      lbC0091F8

lbC0091F8:          cmp.w    #$14,d1
                    blt      lbC009210
                    tst.w    (a4)
                    beq      lbC00920A
                    move.w   #$1E,(a3)
lbC00920A:          clr.w    d3
                    bra      SETSTATE

lbC009210:          move.w   #$14,(a3)
                    sub.w    d1,(a3)
                    add.w    #$1401,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY21_0:           move.w   #2,DELAY_IN
                    cmp.w    #2,d1
                    bne      BUSY21_1
                    tst.w    d0
                    bne      lbC00924A
                    move.l   #BUF14,S1FADDR
                    clr.w    S1F
                    bra      _BUSY6_4

lbC00924A:          move.l   #BUF24,S2FADDR
                    clr.w    S2F
_BUSY6_4:           bra      BUSY6_4

BUSY21_1:           tst.w    d0
                    bne      lbC00928A
                    clr.w    S1DEPTH
                    lea      S1F,a0
                    lea      S1MAPX,a1
                    lea      S1MAPY,a2
                    move.l   #BUF1D,S1FADDR
                    bra      lbC0092AC

lbC00928A:          clr.w    S2DEPTH
                    lea      S2F,a0
                    lea      S2MAPX,a1
                    lea      S2MAPY,a2
                    move.l   #BUF2D,S2FADDR
lbC0092AC:          move.w   #1,(a0)
                    moveq    #0,d3
                    move.w   (a2),d3
                    lsr.w    #2,d3
                    mulu     MAXMAPX,d3
                    move.w   (a1),d4
                    sub.w    #4,d4
                    lsr.w    #2,d4
                    add.w    d4,d3
                    add.l    #MAP,d3
                    move.l   d3,a3
                    cmp.b    #$F0,(a3)
                    beq      lbC0092DE
                    cmp.b    #$A0,(a3)
                    bne      lbC0092E2
lbC0092DE:          move.w   #0,(a0)
lbC0092E2:          add.w    #$1501,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY40_0:           tst.w    d0
                    bne      lbC0092FC
                    clr.w    S1F
                    bra      lbC009302

lbC0092FC:          clr.w    S2F
lbC009302:          add.w    #$4100,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY41_0:           lsl.w    #8,d1
                    move.w   d1,d3
                    ; no rts

SETSTATE:           tst.w    d0
                    bne      SETSTATE2
                    tst.w    DELAY_IN
                    beq      lbC009336
                    move.w   DELAY_IN,DELAY0
                    clr.w    DELAY_IN
lbC009336:          move.w   d3,S1CT
                    rts

SETSTATE2:          tst.w    DELAY_IN
                    beq      lbC009358
                    move.w   DELAY_IN,DELAY1
                    clr.w    DELAY_IN
lbC009358:          move.w   d3,S2CT
                    rts

GETBTIME:           tst.w    d0
                    bne      GETBTIME2
                    move.w   B1TIME,d1
                    rts

GETBTIME2:          move.w   B2TIME,d1
                    rts

SHOWMAP:            move.w   #$70,X
                    add.w    #$10,d2
                    move.w   d2,Y
                    move.w   #6,WIDTH
                    move.l   SCREEN2,SCREEN
                    move.w   LEVEL,d4
                    sub.w    #1,d4
                    mulu     #2120,d4
                    add.l    #MAPS,d4
                    move.l   d4,BUFFER
                    movem.l  d0-d3/a0,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d3/a0
                    rts

ABSD2:              tst.w    d2
                    bge      lbC0093CA
                    neg.w    d2
lbC0093CA:          rts

DRAWROPE:           movem.l  d1-d4,-(sp)
                    tst.w    d0
                    bne      lbC0093E6
                    move.w   S1PLOTX,d1
                    move.w   S1PLOTY,d2
                    bra      lbC0093F2

lbC0093E6:          move.w   S2PLOTX,d1
                    move.w   S2PLOTY,d2
lbC0093F2:          add.w    #$10,d1
                    add.w    #$16,d2
                    move.w   (a1),d3
                    sub.w    (a3),d3
                    add.w    d3,d3
                    add.w    d3,d3
                    add.w    d1,d3
                    move.w   (a2),d4
                    sub.w    (a4),d4
                    add.w    d4,d4
                    add.w    d2,d4
                    sub.w    #$14,d4
                    cmp.w    #1,SPYDIR
                    bne      lbC009422
                    subq.w   #8,d1
                    subq.w   #8,d3
                    bra      lbC00945A

lbC009422:          cmp.w    #2,SPYDIR
                    bne      lbC009436
                    addq.w   #8,d1
                    addq.w   #8,d3
                    bra      lbC00945A

lbC009436:          cmp.w    #3,SPYDIR
                    bne      lbC00944A
                    subq.w   #4,d2
                    subq.w   #4,d4
                    bra      lbC00945A

lbC00944A:          cmp.w    #4,SPYDIR
                    bne      lbC00945A
                    addq.w   #4,d2
                    addq.w   #4,d4
lbC00945A:          tst.w    d0
                    bne      lbC009484
                    move.w   d1,S1LINEX1
                    move.w   d2,S1LINEY1
                    move.w   d3,S1LINEX2
                    move.w   d4,S1LINEY2
                    move.w   #1,S1DRLINE
                    bra      lbC0094A4

lbC009484:          move.w   d1,S2LINEX1
                    move.w   d2,S2LINEY1
                    move.w   d3,S2LINEX2
                    move.w   d4,S2LINEY2
                    move.w   #1,S2DRLINE
lbC0094A4:          movem.l  (sp)+,d1-d4
                    rts

CLEANTRAIL:         movem.l  d0/a0/a1,-(sp)
                    lea      S1TRAIL,a0
                    lea      S2TRAIL,a1
                    move.w   #7-1,d0
lbC0094C2:          move.w   #-1,(a0)+
                    move.w   #-1,(a1)+
                    dbra     d0,lbC0094C2
                    movem.l  (sp)+,d0/a0/a1
                    rts

BUSY36:             tst.w    SPYWIN
                    bne      _BUSY6_40
                    tst.w    d0
                    bne      lbC00951E
                    tst.w    S1DROWN
                    bne      _BUSY6_40
                    tst.w    S1SWAMP
                    bne      _BUSY6_40
                    tst.w    S1DEPTH
                    bne      _BUSY6_40
                    move.l   #BUF14,d5
                    lea      S1FADDR,a4
                    lea      S1F,a5
                    move.w   S1ENERGY,d4
                    bra      lbC009554

lbC00951E:          tst.w    S2DROWN
                    bne      _BUSY6_40
                    tst.w    S2DEPTH
                    bne      _BUSY6_40
                    tst.w    S2SWAMP
                    bne      _BUSY6_40
                    move.l   #BUF24,d5
                    lea      S2FADDR,a4
                    lea      S2F,a5
                    move.w   S2ENERGY,d4
lbC009554:          cmp.w    #$28,d4
                    bhi      _BUSY6_40
                    move.l   d5,(a4)
                    clr.w    (a5)
                    move.w   #$2401,d3
                    bra      SETSTATE

_BUSY6_40:          bra      BUSY6_4

BUSY22:             tst.w    d0
                    bne      lbC009594
                    lea      S1MENU,a2
                    lea      S1AIMMENU,a3
                    lea      S1HAND,a4
                    lea      S1SHOV,a5
                    lea      S1FLASH,a6
                    bra      BUSY22A

lbC009594:          lea      S2MENU,a2
                    lea      S2AIMMENU,a3
                    lea      S2HAND,a4
                    lea      S2SHOV,a5
                    lea      S2FLASH,a6
BUSY22A:            tst.w    SPYWIN
                    bne      BUSY6_4
                    move.w   COUNTER,d4
                    and.w    #3,d4
                    bne      lbC0095EA
                    move.w   (a2),d4
                    cmp.w    (a3),d4
                    beq      BUSY22B
                    blt      lbC0095DC
                    subq.w   #1,(a2)
                    bra      lbC0095DE

lbC0095DC:          addq.w   #1,(a2)
lbC0095DE:          moveq    #1,d7
                    bsr      NEW_SOUND
lbC0095EA:          move.w   #$1600,d3
                    bra      SETSTATE

BUSY22B:            clr.w    (a6)
                    cmp.w    #1,d4
                    bne      lbC00960C
                    tst.w    (a5)
                    beq      _BUSY6_41
                    subq.w   #1,(a5)
                    move.w   #$40,(a4)
                    bra      _BUSY6_41

lbC00960C:          cmp.w    #2,d4
                    bne      lbC009628
                    tst.w    2(a5)
                    beq      _BUSY6_41
                    subq.w   #1,2(a5)
                    move.w   #$48,(a4)
                    bra      _BUSY6_41

lbC009628:          cmp.w    #3,d4
                    bne      lbC009644
                    tst.w    4(a5)
                    beq      _BUSY6_41
                    subq.w   #1,4(a5)
                    move.w   #$50,(a4)
                    bra      _BUSY6_41

lbC009644:          cmp.w    #4,d4
                    bne      lbC009660
                    tst.w    6(a5)
                    beq      _BUSY6_41
                    subq.w   #1,6(a5)
                    move.w   #$58,(a4)
                    bra      _BUSY6_41

lbC009660:          cmp.w    #5,d4
                    bne      lbC00967C
                    tst.w    8(a5)
                    beq      _BUSY6_41
                    subq.w   #1,8(a5)
                    move.w   #$60,(a4)
                    bra      _BUSY6_41

lbC00967C:          tst.w    d0
                    bne      lbC00968C
                    clr.w    S1F
                    bra      lbC009692

lbC00968C:          clr.w    S2F
lbC009692:          move.w   #$4005,d3
                    bra      SETSTATE

_BUSY6_41:          bra      BUSY6_4

DELAY0:             dc.w     0
DELAY1:             dc.w     0
DELAY_IN:           dc.w     0

SUBGIRL:            tst.w    DEMO
                    beq      lbC0096B6
                    move.w   #-1,DEMO
lbC0096B6:          move.w   #5,d0
                    move.w   #1,d1
                    cmp.w    #$30,S1HAND
                    bne      lbC0096EA
                    move.w   #$32,d3
                    move.w   #3,d4
                    move.l   #BUF11,d5
                    move.l   #BUF1D,d6
                    move.w   #$32,a4
                    move.w   #$66,a5
                    bra      SUB0_0

lbC0096EA:          move.w   #$32,d3
                    move.w   #$66,d4
                    move.l   #BUF21,d5
                    move.l   #BUF2D,d6
                    move.w   #$32,a4
                    move.w   #3,a5
SUB0_0:             addq.w   #1,d0
                    movem.l  d0/d1,-(sp)
                    bsr      SWAPSCREEN
                    move.w   #$45,d0
                    jsr      INKEY
                    beq      lbC00972A
                    clr.w    SOUNDCT
                    movem.l  (sp)+,d0/d1
                    rts

lbC00972A:          movem.l  (sp)+,d0/d1
                    bsr      COPYBACK
                    move.w   d3,X
                    add.w    #14,X
                    move.w   d4,Y
                    add.w    #8,Y
                    move.l   SCREEN2,SCREEN
                    move.w   #3,COLOR
                    move.w   #$B8,COUNT
lbC009768:          movem.l  d0/d1,-(sp)
                    bsr      HLINE
                    movem.l  (sp)+,d0/d1
                    add.w    #1,Y
                    move.w   d4,d7
                    add.w    #$17,d7
                    cmp.w    Y,d7
                    bne.b    lbC009768
                    move.l   SCREEN2,SCREEN
                    move.w   #1,COLOR
lbC00979C:          movem.l  d0/d1,-(sp)
                    bsr      HLINE
                    movem.l  (sp)+,d0/d1
                    add.w    #1,Y
                    move.w   d4,d7
                    add.w    #$48,d7
                    cmp.w    Y,d7
                    bne.b    lbC00979C
                    move.w   a4,X
                    add.w    #14,X
                    move.w   a5,Y
                    add.w    #8,Y
                    move.l   SCREEN2,SCREEN
                    move.w   #0,COLOR
                    move.w   #$B8,COUNT
lbC0097F4:          movem.l  d0/d1/a4/a5,-(sp)
                    bsr      HLINE
                    movem.l  (sp)+,d0/d1/a4/a5
                    add.w    #1,Y
                    move.w   a5,d7
                    add.w    #$48,d7
                    cmp.w    Y,d7
                    beq      _SUBCLOUDS
                    bra.b    lbC0097F4

_SUBCLOUDS:         bsr      SUBCLOUDS
                    move.w   d3,X
                    add.w    #$32,X
                    cmp.w    #1,d1
                    beq      lbC009896
                    cmp.w    #7,d1
                    beq      lbC009860
                    move.w   d4,Y
                    add.w    #$28,Y
                    move.l   #WSUB,BUFFER
                    move.w   #$1F,HEIGHT
                    bra      lbC0098CC

lbC009860:          move.w   d4,Y
                    add.w    #$28,Y
                    add.w    d0,Y
                    add.w    d0,X
                    move.l   #WSUB2,BUFFER
                    move.w   #$1F,HEIGHT
                    sub.w    d0,HEIGHT
                    bra      lbC0098CC

lbC009896:          cmp.w    #10,d0
                    bne      lbC0098A8
                    move.w   #5,d7
                    bsr      NEW_SOUND
lbC0098A8:          move.w   d4,Y
                    add.w    #$47,Y
                    sub.w    d0,Y
                    move.l   #WSUB2,BUFFER
                    move.w   d0,HEIGHT
lbC0098CC:          move.w   #4,WIDTH
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6
                    cmp.w    #1,d1
                    bne      SUB0_1
                    cmp.w    #$1F,d0
                    bne      SUB0_0
                    move.w   #2,d1
                    move.w   #0,d0
                    bra      SUB0_0

SUB0_1:             cmp.w    #2,d1
                    bne      SUB1
                    move.w   d3,X
                    add.w    #$28,X
                    move.w   d4,Y
                    add.w    #$1B,Y
                    move.w   #$27,HEIGHT
                    move.w   #2,WIDTH
                    move.l   SCREEN2,SCREEN
                    move.l   d6,BUFFER
                    movem.l  d0-d6,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6
                    cmp.w    #10,d0
                    bne      SUB0_0
                    move.w   #3,d1
                    move.w   #0,d0
                    bra      SUB0_0

SUB1:               cmp.w    #3,d1
                    bne      SUB2
                    move.w   d3,X
                    add.w    #$28,X
                    move.w   d4,Y
                    add.w    #$16,Y
                    move.w   #$27,HEIGHT
                    move.w   #2,WIDTH
                    move.l   SCREEN2,SCREEN
                    move.l   d5,BUFFER
                    movem.l  d0-d6,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6
                    move.w   d3,X
                    add.w    #$3C,X
                    move.w   d4,Y
                    add.w    #$31,Y
                    sub.w    d0,Y
                    move.w   d0,HEIGHT
                    move.w   #2,WIDTH
                    move.l   SCREEN2,SCREEN
                    move.l   #WOMAN,BUFFER
                    movem.l  d0-d6,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6
                    cmp.w    #$16,d0
                    bne      SUB0_0
                    move.w   #4,d1
                    move.w   #0,d0
                    bra      SUB0_0

SUB2:               cmp.w    #4,d1
                    bne      SUB3
                    move.w   d0,d7
                    and.w    #3,d7
                    bne      lbC009A3C
                    moveq    #13,d7
                    bsr      NEW_SOUND
lbC009A3C:          move.w   d3,X
                    add.w    #$28,X
                    move.w   d4,Y
                    add.w    #$16,Y
                    move.w   #$27,HEIGHT
                    move.w   #2,WIDTH
                    move.l   SCREEN2,SCREEN
                    move.l   d5,BUFFER
                    movem.l  d0-d6,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6
                    move.w   d3,X
                    add.w    #$37,X
                    move.w   d4,Y
                    add.w    #$18,Y
                    move.w   #$1B,HEIGHT
                    move.w   #2,WIDTH
                    move.l   SCREEN2,SCREEN
                    move.l   #lbB039284,BUFFER
                    movem.l  d0-d6,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6
                    cmp.w    #$14,d0
                    bne      SUB0_0
                    move.w   #5,d1
                    move.w   #9,d0
                    bra      SUB0_0

SUB3:               cmp.w    #5,d1
                    bne      SUB4
                    move.w   d3,X
                    add.w    #$28,X
                    move.w   d4,Y
                    add.w    #$16,Y
                    move.w   #$27,HEIGHT
                    move.w   #2,WIDTH
                    move.l   SCREEN2,SCREEN
                    move.l   d5,BUFFER
                    movem.l  d0-d6,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6
                    move.w   d3,X
                    add.w    #$3C,X
                    move.w   d4,Y
                    add.w    #13,Y
                    add.w    d0,Y
                    move.w   #$27,HEIGHT
                    sub.w    d0,HEIGHT
                    sub.w    #2,HEIGHT
                    move.w   #2,WIDTH
                    move.l   SCREEN2,SCREEN
                    move.l   #WOMAN,BUFFER
                    movem.l  d0-d6,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6
                    cmp.w    #$23,d0
                    bne      SUB0_0
                    move.w   #6,d1
                    move.w   #5,d0
                    bra      SUB0_0

SUB4:               cmp.w    #6,d1
                    bne      SUB5
                    move.w   d3,X
                    add.w    #$3C,X
                    move.w   d4,Y
                    add.w    #10,Y
                    add.w    d0,Y
                    move.w   #$27,HEIGHT
                    sub.w    d0,HEIGHT
                    move.w   #2,WIDTH
                    move.l   SCREEN2,SCREEN
                    move.l   d5,BUFFER
                    movem.l  d0-d6,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6
                    cmp.w    #$23,d0
                    bne      SUB0_0
                    move.w   #7,d1
                    move.w   #0,d0
                    bra      SUB0_0

SUB5:               cmp.w    #1,d0
                    bne      lbC009C34
                    moveq    #10,d7
                    bsr      NEW_SOUND
                    move.w   #2,SOUNDCT
lbC009C34:          cmp.w    #$1E,d0
                    blt      SUB0_0
                    move.w   #0,SOUNDCT
                    rts

SUBCLOUDS:          movem.l  d0-d7/a0-a6,-(sp)
                    cmp.w    #7,d1
                    blt      lbC009C56
                    sub.w    d0,d3
                    sub.w    d0,d3
lbC009C56:          add.w    #$50,d3
                    add.w    #10,d4
                    move.w   d3,X
                    move.w   d4,Y
                    move.l   #CLOUD_SUB,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d7/a0-a6
                    rts

COPYBACK:           movem.l  d0/a0/a1,-(sp)
                    move.l   SCREEN1,a0
                    move.l   SCREEN2,a1
                    move.w   #((200*40)/4)-1,d0
lbC009CAC:          move.l   (a0)+,(a1)+
                    move.l   (a0)+,(a1)+
                    move.l   (a0)+,(a1)+
                    move.l   (a0)+,(a1)+
                    dbra     d0,lbC009CAC
                    movem.l  (sp)+,d0/a0/a1
                    rts

PARADROP:           move.w   DEMO,d7
                    sub.w    #$18,d7
                    neg.w    d7
                    add.w    #$10,d7
                    cmp.w    #$10,d7
                    ble      lbC009CDA
                    move.w   #$10,d7
lbC009CDA:          cmp.w    #1,d7
                    ble      PARADROPEND
                    move.w   #$6E,d1
                    move.w   #11,d2
                    add.w    DEMO,d2
                    move.w   #1,d6
                    lea      PARABUFF,a1
                    move.l   SCREEN2,a0
                    bsr      RSPRITER
                    move.w   #$AA,d1
                    move.w   #11,d2
                    add.w    DEMO,d2
                    lea      lbB03AD7C,a1
                    bsr      RSPRITER
PARADROPEND:        move.w   #32769-1,d0
.WAIT:              dbra     d0,.WAIT
                    rts

GETMODE:            move.l   SCREEN2,a0
                    move.l   SCREEN1,a2
                    move.w   #8000-1,d0
lbC009D36:          move.l   (a2)+,(a0)+
                    dbra     d0,lbC009D36
                    move.w   #$40,d1
                    move.w   #11,d2
                    move.w   #$16,d6
                    move.w   #$3F,d7
                    move.l   SCREEN2,a0
                    bsr      RCLEARBLOCK
                    move.l   SCREEN1,a0
                    bsr      RCLEARBLOCK
                    move.w   #$40,d1
                    move.w   #$6E,d2
                    move.w   #$16,d6
                    move.w   #$3F,d7
                    move.l   SCREEN2,a0
                    bsr      RCLEARBLOCK
                    move.l   SCREEN1,a0
                    bsr      RCLEARBLOCK
                    move.w   #8,d1
                    move.w   #$15,d2
                    move.w   #7,d6
                    move.w   #$27,d7
                    lea      CONTROLS,a1
                    bsr      RDRAW_BOTH
                    move.w   #8,d1
                    move.w   #$74,d2
                    move.w   #7,d6
                    move.w   #$37,d7
                    lea      CONTROLS,a1
                    bsr      RDRAW_BOTH
                    move.w   #$50,d1
                    move.w   #$13,d2
                    move.w   #2,d6
                    move.w   #$22,d7
                    lea      lbB00FF7C,a1
                    bsr      RSPRITERBOTH
                    move.w   #$50,d1
                    move.w   #$76,d2
                    move.w   #2,d6
                    move.w   #$24,d7
                    lea      lbB016C1C,a1
                    bsr      RSPRITERBOTH
                    move.w   S1MODE,d1
                    move.w   S2MODE,d2
                    cmp.w    #3,d2
                    blt      lbC009E0C
                    sub.w    #3,d2
lbC009E0C:          move.w   #6,d3
                    move.w   #$1F4,DEMO_MODE
GETM2:              bsr      TEST_OPTIONS
                    subq.w   #1,DEMO_MODE
                    bne      _DRAWITEMS
                    move.w   #$100,DEMO
                    movem.l  d0-d7/a0-a6,-(sp)
                    bsr      PLAYINIT0
                    move.w   #1,S1AUTO
                    move.w   #1,S2AUTO
                    bsr      CLEANTRAIL
                    bsr      DO_GAME
                    movem.l  (sp)+,d0-d7/a0-a6
                    clr.w    DEMO
                    bra      GETMODE

_DRAWITEMS:         bsr      DRAWITEMS
                    jsr      SWAP_SCREEN
GETM3:              move.w   #$44,d0
                    jsr      INKEY
                    bne      GETM4
                    move.w   #$40,d0
                    jsr      INKEY
                    beq      GETM5
GETM4:              cmp.w    #6,d3
                    bne      lbC009EA2
                    cmp.w    d2,d1
                    bne      lbC009EA0
                    tst.w    d1
                    bne      lbC009E9E
                    moveq    #3,d2
                    bra      lbC009EA0

lbC009E9E:          moveq    #4,d2
lbC009EA0:          rts

lbC009EA2:          cmp.w    #2,d3
                    bhi      lbC009EC0
                    move.w   d3,d1
                    cmp.w    #2,d2
                    bne      _GETM2
                    cmp.w    d2,d1
                    bne      _GETM2
                    moveq    #0,d2
                    bra      _GETM2

lbC009EC0:          move.w   d3,d2
                    sub.w    #3,d2
                    cmp.w    #2,d2
                    bne      _GETM2
                    cmp.w    d2,d1
                    bne      _GETM2
                    moveq    #0,d1
_GETM2:             bra      GETM2

GETM5:              move.w   #$4C,d0
                    jsr      INKEY
                    beq      GETM6
lbC009EE8:          move.w   #$4C,d0
                    jsr      INKEY
                    bne.b    lbC009EE8
                    move.w   #$1F4,DEMO_MODE
                    tst.w    d3
                    beq      GETM2
                    subq.w   #1,d3
                    bra      GETM2

GETM6:              move.w   #$4D,d0
                    jsr      INKEY
                    beq      GETM2
lbC009F16:          move.w   #$4D,d0
                    jsr      INKEY
                    bne.b    lbC009F16
                    move.w   #$1F4,DEMO_MODE
                    cmp.w    #6,d3
                    beq      GETM2
                    addq.w   #1,d3
                    bra      GETM2

DRAWITEMS:          moveq    #0,d4
DRAWITEMS1:         move.w   #$7E,PX1
                    move.w   #$9E,PX2
                    cmp.w    #3,d4
                    bge      lbC009F6C
                    move.w   d4,d6
                    mulu     #15,d6
                    add.w    #$14,d6
                    move.w   d6,PY1
                    move.w   d6,PY2
                    bra      lbC009F86

lbC009F6C:          move.w   d4,d6
                    sub.w    #3,d6
                    mulu     #15,d6
                    add.w    #$73,d6
                    move.w   d6,PY1
                    move.w   d6,PY2
lbC009F86:          move.w   #1,d5
                    cmp.w    d3,d4
                    bne      _DRAWLINE
                    move.w   #4,d5
_DRAWLINE:          bsr      DRAWLINE
                    add.w    #12,PY1
                    add.w    #12,PY2
                    bsr      DRAWLINE
                    sub.w    #$20,PX2
                    sub.w    #11,PY2
                    bsr      DRAWLINE
                    add.w    #$20,PX1
                    add.w    #$20,PX2
                    bsr      DRAWLINE
                    move.w   #1,d5
                    cmp.w    d1,d4
                    bne      lbC009FE2
                    move.w   #15,d5
lbC009FE2:          add.w    #3,d2
                    cmp.w    d2,d4
                    bne      lbC009FF0
                    move.w   #15,d5
lbC009FF0:          sub.w    #3,d2
                    move.w   #$7F,PX1
                    move.w   #$9D,PX2
                    cmp.w    #3,d4
                    bge      DRAWITEMS2
                    move.w   d4,d6
                    mulu     #15,d6
                    add.w    #$15,d6
                    move.w   d6,PY1
                    move.w   d6,PY2
                    bra      DRAWITEMS3

DRAWITEMS2:         move.w   d4,d6
                    sub.w    #3,d6
                    mulu     #15,d6
                    add.w    #$74,d6
                    move.w   d6,PY1
                    move.w   d6,PY2
DRAWITEMS3:         bsr      DRAWLINE
                    add.w    #10,PY1
                    add.w    #10,PY2
                    bsr      DRAWLINE
                    sub.w    #$1E,PX2
                    sub.w    #9,PY2
                    bsr      DRAWLINE
                    add.w    #$1E,PX1
                    add.w    #$1E,PX2
                    bsr      DRAWLINE
                    addq.w   #1,d4
                    cmp.w    #6,d4
                    ble      DRAWITEMS1
                    rts

DRAWLINE:           movem.l  d0-d7/a0-a6,-(sp)
                    move.w   d5,d7
                    move.w   PX1,d1
                    move.w   PY1,d2
                    move.w   PX2,d3
                    move.w   PY2,d4
                    move.l   SCREEN2,a0
                    bsr      DRAW_LINE
                    movem.l  (sp)+,d0-d7/a0-a6
                    rts

RSPRITERBOTH:       move.l   SCREEN2,a0
                    bsr      RSPRITER
                    move.l   SCREEN1,a0
                    bra      RSPRITER

RDRAW_BOTH:         move.l   SCREEN2,a0
                    bsr      RDRAW_BUFF
                    move.l   SCREEN1,a0
                    bra      RDRAW_BUFF

RCLEARBLOCK:        movem.l  d0-d3/d7/a0/a2,-(sp)
                    addq.w   #1,d7
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    and.w    #$FFF8,d1
                    lsr.w    #3,d1
                    add.w    d1,a0
                    moveq    #0,d0
lbC00A0FE:          move.w   d6,d3
                    move.l   a0,a2
lbC00A102:          st.b     (a0)+
                    move.b   d0,(200*40)-1(a0)
                    move.b   d0,(200*2*40)-1(a0)
                    move.b   d0,(200*3*40)-1(a0)
                    dbra     d3,lbC00A102
                    lea      40(a2),a0
                    dbra     d7,lbC00A0FE
                    movem.l  (sp)+,d0-d3/d7/a0/a2
                    rts

DEMO_MODE:          dc.w     0
PX1:                dc.w     0
PY1:                dc.w     0
PX2:                dc.w     0
PY2:                dc.w     0

BRAINMOVE:          clr.w    GOING_TO_KILL_YOU1
                    clr.w    GOING_TO_KILL_YOU2
                    move.w   #-1,BRAINON
                    bsr      JOYMOVE
                    clr.w    SPYDIR
                    clr.w    d1
                    clr.w    d2
                    tst.w    d0
                    bne      lbC00A210
                    tst.w    XROCKET
                    bne      lbC00A172
                    cmp.w    #$3C,S1ENERGY
                    bls      lbC00A178
lbC00A172:          clr.w    IN_TROUBLE1
lbC00A178:          tst.w    S1NUDGE
                    beq      lbC00A188
                    subq.w   #1,S1NUDGE
lbC00A188:          tst.w    SPYWIN
                    bne      lbC00A1CE
                    tst.w    S1DEPTH
                    bne      lbC00A1CE
                    tst.w    S1DROWN
                    bne      lbC00A1CE
                    tst.w    S1SWAMP
                    bne      lbC00A1CE
                    move.w   S1MAPX,d3
                    and.w    #14,d3
                    cmp.w    #6,d3
                    bne      lbC00A1CE
                    cmp.w    #$28,S1ENERGY
                    bls      STAND_STILL
lbC00A1CE:          move.w   S1MAPX,d3
                    move.w   S1MAPY,d4
                    move.w   S1HAND,d5
                    move.w   S1SAFE,d6
                    move.l   S1CHOICEX,a2
                    move.l   S1CHOICEY,a3
                    lea      S1BDIR,a4
                    lea      S1RUN,a6
                    lea      S1CT,a1
                    tst.w    S1DEAD
                    beq      lbC00A2C4
                    rts

lbC00A210:          tst.w    XROCKET
                    bne      lbC00A226
                    cmp.w    #$3C,S2ENERGY
                    bls      lbC00A22C
lbC00A226:          clr.w    IN_TROUBLE2
lbC00A22C:          tst.w    S2NUDGE
                    beq      lbC00A23C
                    subq.w   #1,S2NUDGE
lbC00A23C:          tst.w    SPYWIN
                    bne      lbC00A282
                    tst.w    S2DEPTH
                    bne      lbC00A282
                    tst.w    S2DROWN
                    bne      lbC00A282
                    tst.w    S2SWAMP
                    bne      lbC00A282
                    move.w   S2MAPX,d3
                    and.w    #14,d3
                    cmp.w    #6,d3
                    bne      lbC00A282
                    cmp.w    #$28,S2ENERGY
                    bls      STAND_STILL
lbC00A282:          move.w   S2MAPX,d3
                    move.w   S2MAPY,d4
                    move.w   S2HAND,d5
                    move.w   S2SAFE,d6
                    move.l   S2CHOICEX,a2
                    move.l   S2CHOICEY,a3
                    lea      S2BDIR,a4
                    lea      S2RUN,a6
                    lea      S2CT,a1
                    tst.w    S2DEAD
                    beq      lbC00A2C4
                    rts

lbC00A2C4:          lsr.w    #2,d3
                    lsr.w    #2,d4
                    movem.l  d4,-(sp)
                    mulu     #96,d4
                    add.w    d3,d4
                    add.l    #MAP,d4
                    move.l   d4,a0
                    bra      lbC00A2DE

lbC00A2DE:          movem.l  (sp)+,d4
BRAINMOVE0:         tst.w    d0
                    bne      lbC00A300
                    cmp.w    #$19,S1ENERGY
                    bhi      BMOVE1A
                    move.w   #$3C,IN_TROUBLE1
                    bra      BMOVE1A

lbC00A300:          cmp.w    #$19,S2ENERGY
                    bhi      BMOVE1A
                    move.w   #$3C,IN_TROUBLE2
BMOVE1A:            tst.w    d0
                    bne      lbC00A334
                    tst.w    IN_TROUBLE1
                    beq      lbC00A34E
                    clr.w    S1BASTARD_COUNT
                    subq.w   #1,IN_TROUBLE1
                    bra      lbC00A454

lbC00A334:          tst.w    IN_TROUBLE2
                    beq      lbC00A34E
                    clr.w    S2BASTARD_COUNT
                    subq.w   #1,IN_TROUBLE2
                    bra      lbC00A454

lbC00A34E:          tst.w    d0
                    bne      lbC00A3BE
                    cmp.w    #$32,S2ENERGY
                    bls      lbC00A3A0
                    tst.w    S2DEAD
                    bne      lbC00A3A0
                    tst.w    S2SWAMP
                    bne      lbC00A3A0
                    tst.w    S2DEPTH
                    bne      lbC00A3A0
                    cmp.b    #8,S2CT
                    beq      lbC00A3AA
                    cmp.b    #9,S2CT
                    beq      lbC00A3AA
                    tst.b    S2CT
                    beq      lbC00A3AA
lbC00A3A0:          clr.w    S1BASTARD_COUNT
                    bra      lbC00A454

lbC00A3AA:          tst.w    S1BASTARD_COUNT
                    beq      lbC00A428
                    subq.w   #1,S1BASTARD_COUNT
                    bra      lbC00A5A2

lbC00A3BE:          cmp.w    #$32,S1ENERGY
                    bls      lbC00A40A
                    tst.w    S1DEAD
                    bne      lbC00A40A
                    tst.w    S1DEPTH
                    bne      lbC00A40A
                    tst.w    S1SWAMP
                    bne      lbC00A40A
                    cmp.b    #8,S1CT
                    beq      lbC00A414
                    cmp.b    #9,S1CT
                    beq      lbC00A414
                    tst.b    S1CT
                    beq      lbC00A414
lbC00A40A:          clr.w    S2BASTARD_COUNT
                    bra      lbC00A454

lbC00A414:          tst.w    S2BASTARD_COUNT
                    beq      lbC00A428
                    subq.w   #1,S2BASTARD_COUNT
                    bra      lbC00A5A2

lbC00A428:          tst.w    SPYWIN
                    bne      lbC00A436
                    bra      lbC00A454

lbC00A436:          tst.w    d0
                    bne      lbC00A448
                    move.w   #5,S1BASTARD_COUNT
                    bra      lbC00A5A2

lbC00A448:          move.w   #5,S2BASTARD_COUNT
                    bra      lbC00A5A2

lbC00A454:          tst.w    d0
                    bne      lbC00A49C
                    tst.w    S1STILL
                    bne      BRAINMOVE1
                    tst.w    S1TRAPNEXT
                    bne      BRAINMOVE1
                    tst.w    XROCKET
                    bne      lbC00A4DE
                    tst.w    S1FUEL
                    beq      lbC00A48C
                    tst.w    IN_TROUBLE1
                    beq      lbC00A4DE
lbC00A48C:          lea      XSTICK1,a2
                    lea      YSTICK1,a3
                    bra      lbC00A5F4

lbC00A49C:          tst.w    S2STILL
                    bne      BRAINMOVE1
                    tst.w    S2TRAPNEXT
                    bne      BRAINMOVE1
                    tst.w    XROCKET
                    bne      lbC00A4DE
                    tst.w    S2FUEL
                    beq      lbC00A4CE
                    tst.w    IN_TROUBLE2
                    beq      lbC00A4DE
lbC00A4CE:          lea      XSTICK1,a2
                    lea      YSTICK1,a3
                    bra      lbC00A5F4

lbC00A4DE:          cmp.w    #$30,d5
                    bne      lbC00A4F6
                    lea      XSUB,a2
                    lea      YSUB,a3
                    bra      lbC00A5F4

lbC00A4F6:          tst.w    XROCKET
                    beq      lbC00A510
                    lea      XROCKET,a2
                    lea      YROCKET,a3
                    bra      lbC00A5C0

lbC00A510:          tst.w    XMIDNOSE
                    beq      lbC00A52A
                    lea      XMIDNOSE,a2
                    lea      YMIDNOSE,a3
                    bra      lbC00A5C0

lbC00A52A:          tst.w    XMIDTAIL
                    beq      lbC00A544
                    lea      XMIDTAIL,a2
                    lea      YMIDTAIL,a3
                    bra      lbC00A5C0

lbC00A544:          tst.w    XNOSE
                    beq      lbC00A566
                    cmp.w    #8,d5
                    beq      lbC00A566
                    lea      XNOSE,a2
                    lea      YNOSE,a3
                    bra      lbC00A5C0

lbC00A566:          tst.w    XMID
                    beq      lbC00A580
                    lea      XMID,a2
                    lea      YMID,a3
                    bra      lbC00A5C0

lbC00A580:          tst.w    XTAIL
                    beq      lbC00A5A2
                    cmp.w    #$18,d5
                    beq      lbC00A5A2
                    lea      XTAIL,a2
                    lea      YTAIL,a3
                    bra      lbC00A5C0

lbC00A5A2:          tst.w    d0
                    bne      lbC00A5E0
                    move.w   #-1,GOING_TO_KILL_YOU1
                    lea      S2CELLX,a2
                    lea      S2CELLY,a3
                    bra      lbC00A5F4

lbC00A5C0:          move.w   (a2),XPLACE
                    move.w   (a3),YPLACE
                    lea      XPLACE,a2
                    lea      YPLACE,a3
                    bsr      FIND_A_MOUND
                    bra      lbC00A5F4

lbC00A5E0:          move.w   #-1,GOING_TO_KILL_YOU2
                    lea      S1CELLX,a2
                    lea      S1CELLY,a3
lbC00A5F4:          tst.w    d0
                    bne      lbC00A60A
                    move.l   a2,S1CHOICEX
                    move.l   a3,S1CHOICEY
                    bra      BRAINMOVE1

lbC00A60A:          move.l   a2,S2CHOICEX
                    move.l   a3,S2CHOICEY
BRAINMOVE1:         movem.l  d0-d6/a0-a6,-(sp)
                    tst.w    d0
                    bne      lbC00A652
                    clr.w    S1STILL
                    tst.w    S1NUDGE
                    bne      BRAINMOVE1_1
                    tst.w    S1SWAMP
                    bne      _BUSY6_42
                    tst.w    S1DEPTH
                    bne      _BUSY6_42
                    tst.w    GOING_TO_KILL_YOU1
                    bne      lbC00A680
                    bra      _BUSY6_42

lbC00A652:          clr.w    S2STILL
                    tst.w    S2NUDGE
                    bne      BRAINMOVE1_1
                    tst.w    S2DEPTH
                    bne      _BUSY6_42
                    tst.w    S2SWAMP
                    bne      _BUSY6_42
                    tst.w    GOING_TO_KILL_YOU2
                    beq      _BUSY6_42
lbC00A680:          move.w   S1MAPX,d1
                    sub.w    S2MAPX,d1
                    bge      lbC00A692
                    neg.w    d1
lbC00A692:          cmp.w    #5,d1
                    bgt      _BUSY6_42
                    move.w   S1MAPY,d1
                    sub.w    S2MAPY,d1
                    bge      lbC00A6AC
                    neg.w    d1
lbC00A6AC:          cmp.w    #1,d1
                    bgt      _BUSY6_42
                    tst.w    SPYWIN
                    beq      _BUSY6_42
                    move.w   #$55,DANGER
                    move.w   #$800,d3
                    bsr      SETSTATE
                    movem.l  (sp)+,d0-d6/a0-a6
                    clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
                    rts

_BUSY6_42:          bsr      BUSY6_4
BRAINMOVE1_0:       tst.w    SPYWIN
                    beq      BRAINMOVE1_1
                    movem.l  d0-d7/a0-a6,-(sp)
                    tst.w    d0
                    bne      lbC00A742
                    tst.w    GOING_TO_KILL_YOU1
                    beq      lbC00A806
                    tst.w    S2DEAD
                    bne      lbC00A806
                    move.w   S1MAPX,d1
                    move.w   S1MAPY,d2
                    move.w   S2MAPX,d3
                    move.w   S2MAPY,d4
                    tst.w    S2SWAMP
                    beq      lbC00A78E
                    tst.w    S2DEPTH
                    beq      lbC00A78E
                    move.w   #1,S1RUN
                    bra      lbC00A806

lbC00A742:          tst.w    GOING_TO_KILL_YOU2
                    beq      lbC00A806
                    tst.w    S1DEAD
                    bne      lbC00A806
                    move.w   S2MAPX,d1
                    move.w   S2MAPY,d2
                    move.w   S1MAPX,d3
                    move.w   S1MAPY,d4
                    tst.w    S1SWAMP
                    beq      lbC00A78E
                    tst.w    S1DEPTH
                    beq      lbC00A78E
                    move.w   #1,S2RUN
                    bra      lbC00A806

lbC00A78E:          lsr.w    #2,d1
                    lsr.w    #2,d3
                    move.w   d2,d5
                    move.w   d4,d6
                    lsr.w    #4,d5
                    lsr.w    #4,d6
                    cmp.w    d5,d6
                    bne      lbC00A806
                    move.w   d1,d5
                    sub.w    d3,d5
                    move.w   d2,d6
                    sub.w    d4,d6
                    tst.w    d6
                    beq      lbC00A806
                    tst.w    d5
                    bpl      lbC00A7B6
                    neg.w    d5
lbC00A7B6:          cmp.w    #$40,d5
                    bhi      lbC00A806
                    tst.w    d6
                    bpl      lbC00A7D6
                    clr.w    d1
                    move.w   #1,d2
                    move.w   #4,SPYDIR
                    bra      lbC00A7E4

lbC00A7D6:          clr.w    d1
                    move.w   #-1,d2
                    move.w   #3,SPYDIR
lbC00A7E4:          move.w   d1,TEMP1
                    move.w   d2,TEMP2
                    movem.l  (sp)+,d0-d7/a0-a6
                    movem.l  (sp)+,d0-d6/a0-a6
                    move.w   TEMP1,d1
                    move.w   TEMP2,d2
                    rts

lbC00A806:          movem.l  (sp)+,d0-d7/a0-a6
BRAINMOVE1_1:       movem.l  (sp)+,d0-d6/a0-a6
                    tst.w    d0
                    bne      lbC00A822
                    tst.w    S1NUDGE
                    bne      GO_MOVE
                    bra      lbC00A82C

lbC00A822:          tst.w    S2NUDGE
                    bne      GO_MOVE
lbC00A82C:          move.w   d4,d6
                    move.w   (a3),d5
                    clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
                    lsr.w    #2,d5
                    lsr.w    #2,d6
                    cmp.w    d5,d6
                    beq      BRAINMOVE2
                    cmp.w    #$20,(a4)
                    bne      lbC00A84E
                    clr.w    (a4)
lbC00A84E:          mulu     #96,d6
                    add.w    d3,d6
                    lea      TERRAIN,a5
                    add.w    d6,a5
                    moveq    #0,d6
                    move.b   (a5),d6
                    lsr.w    #1,d6
                    cmp.w    #$12,d6
                    bne      lbC00A878
                    cmp.w    (a3),d4
                    ble      lbC00A890
                    move.w   #1,(a4)
                    bra      lbC00A926

lbC00A878:          lsr.w    #1,d6
                    cmp.w    #8,d6
                    bne      lbC00A890
                    cmp.w    (a3),d4
                    bge      lbC00A890
                    move.w   #2,(a4)
                    bra      lbC00A926

lbC00A890:          tst.w    d0
                    bne      lbC00A8A4
                    tst.w    S1NUDGE
                    beq      _RNDER21
                    bra      lbC00A904

lbC00A8A4:          tst.w    S2NUDGE
                    bne      lbC00A904
_RNDER21:           bsr      RNDER2
                    and.w    #3,d1
                    beq      lbC00A904
                    move.l   a5,-(sp)
lbC00A8BC:          move.b   -(a5),d1
                    ext.w    d1
                    tst.w    d1
                    bmi      lbC00A8FE
                    cmp.w    (a3),d4
                    ble      lbC00A8E4
                    cmp.w    #$24,d1
                    beq      lbC00A8DA
                    cmp.w    #$25,d1
                    bne.b    lbC00A8BC
lbC00A8DA:          move.l   (sp)+,a5
                    move.w   #4,(a4)
                    bra      lbC00A904

lbC00A8E4:          cmp.w    #$20,d1
                    beq.b    lbC00A8DA
                    cmp.w    #$21,d1
                    beq.b    lbC00A8DA
                    cmp.w    #$22,d1
                    beq.b    lbC00A8DA
                    cmp.w    #$23,d1
                    beq.b    lbC00A8DA
                    bra.b    lbC00A8BC

lbC00A8FE:          move.l   (sp)+,a5
                    move.w   #8,(a4)
lbC00A904:          clr.l    d1
                    tst.w    (a4)
                    bne      lbC00A926
                    movem.l  d0-d2,-(sp)
                    bsr      RNDER
                    move.w   d0,d4
                    and.w    #3,d4
                    move.w   #1,d0
                    lsl.w    d4,d0
                    move.w   d0,(a4)
                    movem.l  (sp)+,d0-d2
lbC00A926:          move.w   (a4),d4
                    bsr      GETD0D1
                    rts

BRAINMOVE2:         move.l   d0,-(sp)
                    bsr      RNDER
                    move.w   d0,d7
                    move.l   (sp)+,d0
                    and.w    #3,d7
                    beq      lbC00A9A6
                    cmp.w    (a2),d3
                    beq      lbC00A9A6
lbC00A946:          tst.w    d0
                    bne      lbC00A95A
                    tst.w    S1NUDGE
                    bne      GO_MOVE
                    bra      lbC00A964

lbC00A95A:          tst.w    S2NUDGE
                    bne      GO_MOVE
lbC00A964:          tst.w    d0
                    bne      lbC00A97A
                    cmp.w    #1,S1ENERGY
                    bhi      lbC00A990
                    bra      lbC00A986

lbC00A97A:          cmp.w    #1,S2ENERGY
                    bhi      lbC00A990
lbC00A986:          cmp.w    (a2),d3
                    bge      lbC00A99E
                    bra      lbC00A996

lbC00A990:          cmp.w    (a2),d3
                    blt      lbC00A99E
lbC00A996:          move.w   #4,(a4)
                    bra      GO_MOVE

lbC00A99E:          move.w   #8,(a4)
                    bra      GO_MOVE

lbC00A9A6:          cmp.w    (a3),d4
                    beq      lbC00A9C2
                    cmp.w    (a3),d4
                    blt      lbC00A9BA
                    move.w   #1,(a4)
                    bra      GO_MOVE

lbC00A9BA:          move.w   #2,(a4)
                    bra      GO_MOVE

lbC00A9C2:          cmp.w    (a2),d3
                    bne.b    lbC00A946
                    move.w   S1HAND,d5
                    move.w   S1BADMOVE,d7
                    tst.w    d0
                    beq      lbC00A9E4
                    move.w   S2HAND,d5
                    move.w   S2BADMOVE,d7
lbC00A9E4:          tst.w    d5
                    beq      lbC00AA2A
                    tst.w    d0
                    bne      lbC00A9FC
                    move.w   #1,S1STILL
                    bra      lbC00AA04

lbC00A9FC:          move.w   #1,S2STILL
lbC00AA04:          tst.w    d7
                    bne      lbC00AA1E
                    cmp.w    #$38,d5
                    bge      lbC00AA1E
                    move.w   #$400,d3
                    bsr      SETSTATE
                    bra      lbC00AA68

lbC00AA1E:          move.w   #$300,d3
                    bsr      SETSTATE
                    bra      lbC00AA68

lbC00AA2A:          tst.w    d0
                    bne      lbC00AA4A
                    tst.w    S1TRAPNEXT
                    bne      lbC00AA68
                    clr.w    S1STILL
                    clr.w    S1SAFE
                    bra      lbC00AA60

lbC00AA4A:          tst.w    S2TRAPNEXT
                    bne      lbC00AA68
                    clr.w    S2SAFE
                    clr.w    S2STILL
lbC00AA60:          move.w   #$200,d3
                    bsr      SETSTATE
lbC00AA68:          clr.w    (a4)
                    clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
                    rts

GO_MOVE:            move.w   (a4),d4
                    bsr      GETD0D1
                    rts

STAND_STILL:        move.w   #0,d1
                    move.w   #0,d2
                    move.w   #0,SPYDIR
                    move.w   #$2400,d3
                    bsr      SETSTATE
                    rts

GETD0D1:            lsr.w    #1,d4
                    bcc      lbC00AAAE
                    move.w   #-1,d2
                    clr.w    d1
                    move.w   #3,SPYDIR
                    rts

lbC00AAAE:          lsr.w    #1,d4
                    bcc      lbC00AAC4
                    move.w   #1,d2
                    clr.w    d1
                    move.w   #4,SPYDIR
                    rts

lbC00AAC4:          lsr.w    #1,d4
                    bcc      lbC00AADA
                    move.w   #-1,d1
                    clr.w    d2
                    move.w   #1,SPYDIR
                    rts

lbC00AADA:          lsr.w    #1,d4
                    bcc      lbC00AAF0
                    move.w   #1,d1
                    clr.w    d2
                    move.w   #2,SPYDIR
                    rts

lbC00AAF0:          clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
                    rts

BRAINBUSY:          tst.w    MAP_TIME
                    beq      lbC00AB0C
                    subq.w   #1,MAP_TIME
lbC00AB0C:          tst.w    d0
                    bne      lbC00AB86
                    lea      S1BRAIN,a1
                    lea      S1BDIR,a2
                    lea      S1CT,a3
                    move.w   S1F,d3
                    move.w   S1MAPX,d6
                    move.w   S1MAPY,d7
                    lea      S1HAND,a4
                    lea      S1SHOV,a5
                    lea      S1FUEL,a6
                    tst.w    S1TRAPNEXT
                    bne      BRAINBUSY0_5
                    tst.w    S2DEAD
                    bne      lbC00ABF8
                    tst.w    S1DROWN
                    bne      lbC00ABF8
                    tst.w    S1SWAMP
                    bne      lbC00ABF8
                    tst.w    S1DEPTH
                    bne      lbC00ABF8
                    tst.w    S1DEAD
                    beq      lbC00ABFA
                    rts

lbC00AB86:          lea      S2BRAIN,a1
                    lea      S2BDIR,a2
                    lea      S2CT,a3
                    move.w   S2F,d3
                    move.w   S2MAPX,d6
                    move.w   S2MAPY,d7
                    lea      S2HAND,a4
                    lea      S2SHOV,a5
                    lea      S2FUEL,a6
                    tst.w    S2TRAPNEXT
                    bne      BRAINBUSY0_5
                    tst.w    S1DEAD
                    bne      lbC00ABF8
                    tst.w    S2DROWN
                    bne      lbC00ABF8
                    tst.w    S2SWAMP
                    bne      lbC00ABF8
                    tst.w    S2DEPTH
                    bne      lbC00ABF8
                    tst.w    S2DEAD
                    beq      lbC00ABFA
lbC00ABF8:          rts

lbC00ABFA:          move.l   d0,-(sp)
                    bsr      GET_RANDOM
                    move.w   d0,d4
                    move.l   (sp)+,d0
                    movem.l  d4/d6/d7,-(sp)
                    tst.w    TENMINS
                    bne      lbC00AC1E
                    cmp.w    #1,ONEMINS
                    ble      lbC00AC6E
lbC00AC1E:          and.w    #$FF,d4
                    move.w   #$16,d6
                    sub.w    IQ,d6
                    sub.w    IQ,d6
                    move.w   S1ENERGY,d7
                    tst.w    d0
                    beq      lbC00AC44
                    move.w   S2ENERGY,d7
lbC00AC44:          cmp.w    #$37,d7
                    bgt      lbC00AC5C
                    move.w   #$10,d6
                    sub.w    IQ,d6
                    sub.w    IQ,d6
lbC00AC5C:          cmp.w    d6,d4
                    blt      BRAINBUSY0
                    cmp.w    #10,COUNTER
                    blt      BRAINBUSY0
lbC00AC6E:          cmp.w    #$38,(a4)
                    blt      lbC00AC82
                    and.w    #7,d4
                    cmp.w    #1,d4
                    beq      BRAINBUSY0
lbC00AC82:          movem.l  (sp)+,d4/d6/d7
                    rts

BRAINBUSY0:         movem.l  (sp)+,d4/d6/d7
BRAINBUSY0_5:       tst.w    SPYWIN
                    bne      FULL_HANDS
                    tst.w    (a4)
                    beq      BB_2
                    cmp.w    #$3F,(a4)
                    bgt      FULL_HANDS
                    tst.w    d0
                    bne      lbC00ACB6
                    move.w   #1,S1TRAPNEXT
                    bra      lbC00ACBE

lbC00ACB6:          move.w   #1,S2TRAPNEXT
lbC00ACBE:          move.w   #$300,d3
                    bra      SETSTATE

BB_2:               cmp.w    #10,COUNTER
                    blt      CHOOSE5
                    bsr      RNDER2
                    move.w   d1,d4
                    and.w    #7,d4
                    beq      CHOOSE5
                    cmp.w    #7,d4
                    blt      USED4
                    move.w   #3,d4
                    bra      USED4

CHOOSE5:            move.w   #6,d4
USED4:              movem.l  d4/a0,-(sp)
                    cmp.w    #6,d4
                    beq      ALLOW_D4
                    lea      S1HAND,a0
                    tst.w    d0
                    beq      UD4A
                    lea      S2HAND,a0
UD4A:               add.w    d4,d4
                    add.w    d4,a0
                    tst.w    (a0)
                    bne      ALLOW_D4
                    movem.l  (sp)+,d4/a0
                    addq.w   #1,d4
                    bra.b    USED4

ALLOW_D4:           movem.l  (sp)+,d4/a0
                    cmp.w    #6,d4
                    bne      lbC00AD4E
                    tst.w    MAP_TIME
                    bne      BUSY6_4
                    move.w   IQ,d3
                    lsl.w    #4,d3
                    add.w    #$14,d3
                    move.w   d3,MAP_TIME
lbC00AD4E:          tst.w    d0
                    bne      lbC00AD86
                    clr.w    S1TRAPNEXT
                    tst.w    S1SWAMP
                    bne      FULL_HANDS
                    tst.w    S1DEPTH
                    bne      FULL_HANDS
                    move.w   d4,S1AIMMENU
                    move.w   #1,S1FLASH
                    clr.w    S1F
                    bra      lbC00ADB4

lbC00AD86:          clr.w    S2TRAPNEXT
                    tst.w    S2SWAMP
                    bne      FULL_HANDS
                    tst.w    S2DEPTH
                    bne      FULL_HANDS
                    clr.w    S2F
                    move.w   d4,S2AIMMENU
                    move.w   #1,S2FLASH
lbC00ADB4:          move.w   #$1600,d3
                    bra      SETSTATE

FULL_HANDS:         move.w   (a4),d4
                    cmp.w    #$50,d4
                    beq      lbC00ADCE
                    cmp.w    #$60,d4
                    bne      lbC00ADDA
lbC00ADCE:          move.w   #$400,d3
                    bsr      SETSTATE
                    bra      lbC00AE6C

lbC00ADDA:          cmp.w    #$40,d4
                    bne      lbC00AE46
                    lsr.w    #2,d6
                    lsr.w    #2,d7
                    movem.l  d7,-(sp)
                    mulu     #96,d7
                    add.w    d6,d7
                    add.l    #MAP,d7
                    move.l   d7,a0
                    movem.l  (sp)+,d7
                    cmp.b    #$A0,(a0)
                    beq      lbC00AE6C
                    cmp.b    #$F0,(a0)
                    beq      lbC00AE6C
                    moveq    #0,d1
                    move.b   (a0),d1
                    btst     #1,d1
                    bne      lbC00AE6C
                    move.l   a0,a1
                    bsr      ADD_TRAP
                    cmp.l    a0,a1
                    bne      lbC00AE6C
                    tst.w    d0
                    bne      lbC00AE34
                    move.l   a0,S1DIG
                    bra      lbC00AE3A

lbC00AE34:          move.l   a0,S2DIG
lbC00AE3A:          move.w   #$1001,d3
                    bsr      SETSTATE
                    bra      lbC00AE6C

lbC00AE46:          cmp.w    #$48,d4
                    bne      lbC00AE58
                    add.w    d4,2(a5)
                    clr.w    (a4)
                    bra      lbC00AE6C

lbC00AE58:          cmp.w    #$38,d4
                    bne      lbC00AE6C
                    move.w   #$300,d3
                    bsr      SETSTATE
                    bra      lbC00AE6C

lbC00AE6C:          rts

BRAINBUSY1:         tst.w    (a3)
                    bne      lbC00AE90
                    tst.w    d0
                    bne      lbC00AE84
                    clr.w    S1F
                    bra      lbC00AE8A

lbC00AE84:          clr.w    S2F
lbC00AE8A:          move.w   #$4005,d3
                    move.w   d3,(a3)
lbC00AE90:          rts

RANDMOVE:           move.l   d0,-(sp)
                    bsr      RNDER
                    and.w    #$1F,d0
                    cmp.w    #$18,d0
                    bne      lbC00AF58
                    bsr      RNDER
                    clr.w    d1
                    btst     #6,d0
                    beq      lbC00AEC0
                    move.w   #1,d1
                    btst     #7,d0
                    beq      lbC00AEC0
                    neg.w    d1
lbC00AEC0:          clr.w    d2
                    tst.w    d1
                    bne      lbC00AED6
                    move.w   #1,d2
                    btst     #9,d0
                    beq      lbC00AED6
                    neg.w    d2
lbC00AED6:          cmp.w    #-1,d1
                    bne      lbC00AEEA
                    move.w   #1,SPYDIR
                    bra      lbC00AF2C

lbC00AEEA:          cmp.w    #1,d1
                    bne      lbC00AEFE
                    move.w   #2,SPYDIR
                    bra      lbC00AF2C

lbC00AEFE:          cmp.w    #-1,d2
                    bne      lbC00AF12
                    move.w   #3,SPYDIR
                    bra      lbC00AF2C

lbC00AF12:          cmp.w    #1,d2
                    bne      lbC00AF26
                    move.w   #4,SPYDIR
                    bra      lbC00AF2C

lbC00AF26:          clr.w    SPYDIR
lbC00AF2C:          tst.w    d0
                    bne      _RNDER
                    bsr      RNDER
                    and.w    #7,d0
                    move.w   d0,S1NUDGE
                    clr.w    d0
                    bra      lbC00AF58

_RNDER:             bsr      RNDER
                    and.w    #7,d0
                    move.w   d0,S2NUDGE
                    move.w   #1,d0
lbC00AF58:          move.l   (sp)+,d0
                    rts

FIND_A_MOUND:       movem.l  d1-d7/a0/a1/a4/a5,-(sp)
                    clr.w    d7
                    move.w   (a2),d1
                    move.w   d1,a4
                    move.w   (a3),d2
                    move.w   d2,a5
                    mulu     MAXMAPX,d2
                    lea      MAP,a0
                    add.w    d2,a0
                    add.w    d1,a0
                    move.b   (a0),d5
                    move.w   a4,d1
                    move.w   a5,d2
                    and.w    #$1C,d2
                    and.w    #$70,d1
                    mulu     MAXMAPX,d2
                    lea      MAP,a0
                    add.w    d2,a0
                    add.w    d1,a0
                    move.w   a4,d1
                    move.w   a5,d2
                    and.w    #$1C,d2
                    and.w    #$70,d1
                    move.w   #4-1,d3
lbC00AFA8:          move.l   a0,a1
                    move.w   d1,d6
                    move.w   #16-1,d4
lbC00AFB0:          move.b   (a0)+,d5
                    beq      lbC00AFE2
                    cmp.w    d1,a4
                    bne      lbC00AFC2
                    cmp.w    d2,a5
                    beq      lbC00AFFC
lbC00AFC2:          cmp.b    #$60,d5
                    bge      lbC00AFE2
                    btst     #1,d5
                    beq      lbC00AFE2
                    cmp.b    #$38,d5
                    blt      lbC00AFE2
                    btst     #2,d5
                    bne      lbC00AFF8
lbC00AFE2:          addq.w   #1,d1
                    dbra     d4,lbC00AFB0
                    lea      96(a1),a0
                    move.w   d6,d1
                    addq.w   #1,d2
                    dbra     d3,lbC00AFA8
                    bra      lbC00B000

lbC00AFF8:          move.w   #1,d7
lbC00AFFC:          move.w   d1,(a2)
                    move.w   d2,(a3)
lbC00B000:          tst.w    d0
                    bne      lbC00B010
                    move.w   d7,S1BADMOVE
                    bra      lbC00B016

lbC00B010:          move.w   d7,S2BADMOVE
lbC00B016:          movem.l  (sp)+,d1-d7/a0/a1/a4/a5
                    rts

; -------------------------------------------

XPLACE:             dc.w     0
YPLACE:             dc.w     0
GOING_TO_KILL_YOU1: dc.w     0
GOING_TO_KILL_YOU2: dc.w     0
S1NUDGE:            dc.w     0
S2NUDGE:            dc.w     0
DANGER:             dc.w     $55
S1BASTARD_COUNT:    dc.w     0
S2BASTARD_COUNT:    dc.w     0
STICK_COUNTER:      dc.w     0
IN_TROUBLE1:        dc.w     0
IN_TROUBLE2:        dc.w     0
MAP_TIME:           dc.w     0
BRAINON:            dc.w     0
DIE_ONCE1:          dc.w     0
DIE_ONCE2:          dc.w     0
TEMP1:              dc.w     0
TEMP2:              dc.w     0
ABORT:              dc.w     0
RIGHTSHIFT:         dc.w     0
TEMPKEY:            dc.w     0,0
OLDSTACK:           dc.w     0,0
PRIV:               dc.w     0
VBAT:               dc.w     0,0
PALETTE:            dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
BACK:               dc.w     0,0
DEMOCT:             dc.w     0
DEMO:               dc.w     0
FILEPTR:            dc.w     0
S1TRAIL:            dc.w     -1,-1,-1,-1,-1,-1,-1
S1MODE:             dc.w     0
S1RUN:              dc.w     0
S1AUTO:             dc.w     0
S1BRAIN:            dc.w     0
S1BDIR:             dc.w     0
S1DEAD:             dc.w     0
S1DROWN:            dc.w     0
S1F:                dc.w     0
S1DIR:              dc.w     0
S1FADDR:            dc.l     0
S1MAPX:             dc.w     0
S1MAPY:             dc.w     0
S1CELLX:            dc.w     0
S1CELLY:            dc.w     0
S1OLDX:             dc.w     0
S1OLDY:             dc.w     0
S1CT:               dc.w     0
S1WATERCT:          dc.w     0
S1ENERGY:           dc.w     0
S1FUEL:             dc.w     0
S1BUMP:             dc.w     0
S1SAFE:             dc.w     0
S1TEMPHAND:         dc.w     0
S1HAND:             dc.w     0
S1SHOV:             dc.w     0
S1GUN:              dc.w     0
S1COCO:             dc.w     0
S1ROPE:             dc.w     0
S1NAPA:             dc.w     0
S1DIG:              dc.l     0
S1SWAMP:            dc.w     0
S1DEPTH:            dc.w     0
S1ALTITUDE:         dc.w     0
B1TIME:             dc.w     0
S1SHCT:             dc.w     0
S1FLASH:            dc.w     0
S1MENU:             dc.w     1
BUF1X:              dc.w     0
BUF1Y:              dc.w     -1
S1TREEX:            dc.w     0
S1TREEY:            dc.w     0
S1PLOTX:            dc.w     0
S1PLOTY:            dc.w     0
S1LINEX1:           dc.w     0
S1LINEY1:           dc.w     0
S1LINEX2:           dc.w     0
S1LINEY2:           dc.w     0
S1DRLINE:           dc.w     0
S1CHOICEX:          dc.l     0
S1CHOICEY:          dc.l     0
S1BASH:             dc.w     0
S1AIMMENU:          dc.w     0
S1BADMOVE:          dc.w     0
S1TRAPNEXT:         dc.w     0
S1STILL:            dc.w     0
S2TRAIL:            dc.w     -1,-1,-1,-1,-1,-1,-1
S2RUN:              dc.w     0
S2MODE:             dc.w     0
S2AUTO:             dc.w     0
S2BRAIN:            dc.w     0
S2BDIR:             dc.w     0
S2DEAD:             dc.w     0
S2DROWN:            dc.w     0
S2F:                dc.w     0
S2DIR:              dc.w     0
S2FADDR:            dc.l     0
S2MAPX:             dc.w     0
S2MAPY:             dc.w     0
S2CELLX:            dc.w     0
S2CELLY:            dc.w     0
S2OLDX:             dc.w     0
S2OLDY:             dc.w     0
S2CT:               dc.w     0
S2WATERCT:          dc.w     0
S2ENERGY:           dc.w     0
S2FUEL:             dc.w     0
S2BUMP:             dc.w     0
S2SAFE:             dc.w     0
S2TEMPHAND:         dc.w     0
S2HAND:             dc.w     0
S2SHOV:             dc.w     0
S2GUN:              dc.w     0
S2COCO:             dc.w     0
S2ROPE:             dc.w     0
S2NAPA:             dc.w     0
S2DIG:              dc.l     0
S2SWAMP:            dc.w     0
S2DEPTH:            dc.w     0
S2ALTITUDE:         dc.w     0
B2TIME:             dc.w     0
S2SHCT:             dc.w     0
S2FLASH:            dc.w     0
S2MENU:             dc.w     1
BUF2X:              dc.w     0
BUF2Y:              dc.w     -1
S2TREEX:            dc.w     0
S2TREEY:            dc.w     0
S2PLOTX:            dc.w     0
S2PLOTY:            dc.w     0
S2LINEX1:           dc.w     0
S2LINEY1:           dc.w     0
S2LINEX2:           dc.w     0
S2LINEY2:           dc.w     0
S2DRLINE:           dc.w     0
S2CHOICEX:          dc.l     0
S2CHOICEY:          dc.l     0
S2BASH:             dc.w     0
S2AIMMENU:          dc.w     0
S2BADMOVE:          dc.w     0
S2TRAPNEXT:         dc.w     0
S2STILL:            dc.w     0
SOUNDNUM:           dc.w     0
SOUNDCT:            dc.w     0
SPYX:               dc.w     0
SPYY:               dc.w     0
SPYDIR:             dc.w     0
SPYWIN:             dc.w     0
SPYWX:              dc.w     0
SPYWY:              dc.w     0
WIN1X:              dc.w     0
WIN1Y:              dc.w     0
WIN2X:              dc.w     0
WIN2Y:              dc.w     0
CURMAXX:            dc.w     60
CURMAXY:            dc.w     32
REFRESH:            dc.w     2
BULLET:             dc.w     4
BUSYDIR:            dc.w     0
COUNTER:            dc.w     1
TENMINS:            dc.w     0
ONEMINS:            dc.w     0
TENSECS:            dc.w     0
ONESECS:            dc.w     0
XROCKET:            dc.w     0
YROCKET:            dc.w     0
XMIDNOSE:           dc.w     0
YMIDNOSE:           dc.w     0
XMIDTAIL:           dc.w     0
YMIDTAIL:           dc.w     0
XNOSE:              dc.w     0
YNOSE:              dc.w     0
XMID:               dc.w     0
YMID:               dc.w     0
XTAIL:              dc.w     0
YTAIL:              dc.w     0
XSUB:               dc.w     0
YSUB:               dc.w     0
XGUN:               dc.w     0
YGUN:               dc.w     0
LOOPTIME:           dc.w     0
SCREEN_P:           dc.w     0,0
CHPLACE_P:          dc.w     0,0
CHSRC_P:            dc.w     0,0
FOURBITS:           dc.w     0
L_COLOR:            dc.w     14
COUNT:              dc.w     0
COLOR:              dc.w     0
WINX:               dc.w     0
WINY:               dc.w     0
ULX:                dc.w     0
ULY:                dc.w     0
OFFSET:             dc.w     0
PLAYERS:            dc.w     1
LEVEL:              dc.w     1
IQ:                 dc.w     1
DRAWSUB:            dc.w     1
MAXMAPX:            dc.w     0
MAXMAPY:            dc.w     0
; 96*20 = 1920 bytes per level
MAP:                dcb.b    (96*20),0
MAP1:               dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
                    dc.b     0,0,0,1,1,1,1,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0
                    dc.b     0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,$80,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,0,0,0,0,$C1,$C1,$C1,1,1,1,1,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,$80,0,0,0,0,0,$80,0,0,0,0,0,0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
MAP2:               dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,0,0,0
                    dc.b     0,0,0,0,0,0,$80,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0
                    dc.b     0,0,0,0,1,1,1,1,1,1,0,0,0,0,1,1,0,1,1,1,1,1,1,0,0
                    dc.b     0,0,0,0,0,0,0,0,$80,0,0,$80,0,0,0,0,0,0,0,0,$C1
                    dc.b     $C1,$C1,1,1,1,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,1,1,1,1
                    dc.b     1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     1,1,1,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$80,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
MAP3:               dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,1,1,1,1,1,1
                    dc.b     0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,$80,$80,$80,$80,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,$80
                    dc.b     $80,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     $80,$80,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0
                    dc.b     1,1,1,0,0,0,0,0,0,0,0,0,$80,0,$80,0,1,1,1,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,$C1,$C1
                    dc.b     $C1,1,1,1,0,0,0,0,$A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     $80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,0,0,$A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,$A0,$A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,1,1,1,1,$A0,$A0,0,0,0,0,0,1,1,1,1,1,1
                    dc.b     0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,1,1,1,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,1,1,1,1
                    dc.b     1,1,0,0,0,0,$A0,$A0,1,1,1,1,$A0,$A0,0,0,0,0,0,0
                    dc.b     $80,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,1,1,1,1,$A0,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,$A0,$A0,$A0,1
                    dc.b     1,1,1,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     $80,$80,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1,1,$A0,$A0,0,0,0
                    dc.b     0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
                    dc.b     1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0
                    dc.b     $80,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,1
                    dc.b     1,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,1,1,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,1,1,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1
                    dc.b     1,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,$80,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,$A0,$A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1,1,$A0
                    dc.b     $A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.b     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
MAP4:               dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1
                    dc.b     0,0,0,0,0,0,$80,0,0,0,$80,0,0,0,0,0,0,0,0,$80,$80
                    dc.b     $80,$80,0,0,0,1,1,0,0,0,0,0,1,1,1,1,0,0,1,1,1,1,0
                    dc.b     0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0
                    dc.b     0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,$80,0,0,0,0,0
                    dc.b     0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0
                    dc.b     $80,$80,$80,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,1,1,$A0,$A0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0
                    dc.b     1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0
                    dc.b     1,1,1,1,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0
                    dc.b     1,1,1,1,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,$A0
                    dc.b     $A0,$A0,1,1,1,1,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,1,1,1,1,$A0,$A0,0,0,0,0,0,1,1,1,1,1,1
                    dc.b     0,0,$80,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1
                    dc.b     1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0
                    dc.b     0,0,0,$A0,$A0,1,1,1,1,$A0,$A0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0
                    dc.b     0,0,0,0,$A0,$A0,1,1,1,1,$A0,$A0,$A0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,$A0,$A0,$A0,1,1,1,1,$A0,$A0,$A0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$A0,$A0,$A0,1,1,1,1,$A0,$A0,0,0,0,0,0
                    dc.b     1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0
                    dc.b     0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,1,1,1,1,$A0,$A0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     $80,$80,$80,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0
                    dc.b     0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,1
                    dc.b     1,1,1,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0
                    dc.b     0,0,$A0,$A0,$A0,1,1,1,1,$A0,$A0,$A0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,$A0,$A0,$A0,1,1,1,1,$A0,$A0,0,0,0
                    dc.b     0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0,1,1,0,0,0
                    dc.b     0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,1
                    dc.b     1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,$C1,$C1
                    dc.b     $C1,0,0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,1,1,1,1,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,1,1,1,1
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     $80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0
                    dc.b     $A0,1,1,1,1,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,1,1
MAP5:               dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,$80,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0
                    dc.b     $80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1,1,$A0,$A0,0
                    dc.b     0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0
                    dc.b     0,0,0,1,1,1,1,1,1,0,0,0,0,$F0,$F0,$F0,$F0,$F0,$F0
                    dc.b     $F0,$F0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1
                    dc.b     1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,1,1
                    dc.b     1,1,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F0
                    dc.b     $F0,$F0,$F0,$F0,$F0,$F0,$F0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0
                    dc.b     0,0,0,0,0,$A0,$A0,1,1,1,1,$A0,$A0,$A0,$A0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,$80,0,0,0,0,0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    dc.b     $F0,$F0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,1,1
                    dc.b     1,1,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F0
                    dc.b     $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$A0,$A0,$A0,1,1,1,1,$A0,$A0,0,0,0,0,0
                    dc.b     1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     1,1,1,1,1,1,0,0,0,0,$A0,$A0,1,1,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1,1,$A0,$A0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,1,1,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1,1,$A0,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,$A0,$A0,$A0,1,1
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1
                    dc.b     1,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0
                    dc.b     $A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,1,1,$A0,$A0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0
                    dc.b     0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,$80,0,0,$80,$80,$80
                    dc.b     $80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,$C1,$C1,$C1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1
                    dc.b     1,1,0,0,0,0,$A0,$A0,1,1,1,1,$A0,$A0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,$80,$80,$80,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,$80,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,1,1,1,1,$A0,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,$A0,$A0,$A0
                    dc.b     1,1,1,1,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,0,0,0,0,0,1,1,1,1,1,1,0,0,1,1,1,1
                    dc.b     1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,0,0,0,0
                    dc.b     0,0,0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,1,1,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,$A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,$A0,$A0,$A0,1,1
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$A0,$A0,$A0,1,1
MAP6:               dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,1,1
                    dc.b     1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0
                    dc.b     0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,1,1,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,1,1,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0
                    dc.b     0,$80,0,0,0,0,0,0,$A0,$A0,$A0,1,1,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,$A0,$A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,1,1,1,1,1,1,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
                    dc.b     1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,1,1
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,$80,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,$A0,$A0
                    dc.b     $A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,1,1,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0
                    dc.b     0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0
                    dc.b     $A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,1,1,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,$80,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0
                    dc.b     0,0,$A0,$A0,$A0,1,1,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,1,1,1
                    dc.b     1,$A0,$A0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1
                    dc.b     0,0,0,0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    dc.b     $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    dc.b     $F0,$F0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,$80,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,$C1,$C1,$C1,1,1,1,1,1,0,0,0,0,$A0
                    dc.b     $A0,1,1,1,1,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    dc.b     $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    dc.b     $F0,$F0,$F0,$F0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0
                    dc.b     $A0,1,1,1,1,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,$80,0,0,0,0,0,0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    dc.b     $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    dc.b     $F0,$F0,$F0,$F0,$F0,$F0,$F0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,$80,0
                    dc.b     0,0,0,0,$A0,$A0,$A0,1,1,1,1,$A0,$A0,$A0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F0,$F0,$F0,$F0
                    dc.b     $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    dc.b     $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,$A0,$A0,$A0,1,1
MAP7:               dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,1,1,1,1,0,0,$80,$80,$80,$80,0,0,0,0,1,1,1
                    dc.b     1,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0
                    dc.b     0,$80,0,0,0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,0,0,0,0,0,0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0,$80,$80
                    dc.b     $80,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     $80,$80,$80,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1,1,$A0,$A0,0,0,0
                    dc.b     0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$C1,$C1,$C1,0,0,0,0,0
                    dc.b     0,0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,1,1,1,1,$A0,$A0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,1,1,1,1,$A0,$A0
                    dc.b     $A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$80,0,0,0,0,0,0,$A0,$A0,$A0,1,1,1,1
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,1,1
                    dc.b     1,1,$A0,$A0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,1,1
                    dc.b     1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0,0,1,1,1
                    dc.b     1,1,1,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1,1
                    dc.b     $A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1,1,$A0
                    dc.b     $A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0,0,0,$80,0,0,0
                    dc.b     0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,1,1
                    dc.b     $A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,1,1,1,1,1,1
                    dc.b     0,0,0,0,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,1,1,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80
                    dc.b     0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,1,1,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$80,0,0,0,0,0,0,$A0,$A0,$A0,1,1,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$80,$80,$80,$80,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,1,1,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0
                    dc.b     0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,1,1,1,1,1,1,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$80,0,0
                    dc.b     0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                    dc.b     $A0,$A0,$A0,0,$FF,$FF,$FF,$FF,$FF,$FF
; 96*5 = 480 bytes per level
TERRAIN:            dcb.b    (5*96),0
TERRAIN1:           dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FF,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,12,13,$10,$20,$21,$10,$11,$1D,$1E,$1F,$10
                    dc.b     $11,$14,$15,$10,$11,$16,$17,$4B,$4C,$4D,$4E,$4F
                    dc.b     $12,$13,$16,$17,$10,$11,14,15,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FF
                    dc.b     $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,5,6
                    dc.b     $1A,$1B,$1C,$3A,8,7,$3B,$37,$38,$39,6,$24,$25,$37
                    dc.b     $38,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$39,6,$2A
                    dc.b     $2B,$2C,$2D,$2E,$2F,$30,$31,$32,5,6,$37,5,6,5,6
                    dc.b     $3A,8,7,8,7,$3B,$36,5,3,4,0,0,0,$FF,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0
TERRAIN2:           dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FF,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,12,13,$14,$15,$10,$11,$16,$17,$4B,$4C,$4D
                    dc.b     $4E,$4F,$12,$13,$18,$21,$10,$11,$14,$15,$3C,$3D
                    dc.b     $3E,$3F,$40,$41,$10,$11,14,15,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FF
                    dc.b     $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,5,6
                    dc.b     $36,$3A,8,7,8,7,$3B,$36,$37,$38,$42,$43,$44,$42
                    dc.b     $43,$44,$45,$46,$47,$48,$49,$4A,$37,5,$24,6,$37
                    dc.b     $38,5,6,$33,$34,$35,$22,6,5,6,$37,$38,$39,5,6,$1A
                    dc.b     $1B,$1C,$3A,7,$3B,5,6,3,4,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,$FF,$FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,1,2,5,6,$34,$3A,8,7,8,7,$3B,5,6,$26,5
                    dc.b     $2A,$2B,$2C,$2D,$2E,$2F,$30,$31,$32,5,$38,5,$38,9
                    dc.b     10,10,11,5,6,$3A,8,7,$24,8,$3B,6,$33,$34,$35,5,6
                    dc.b     $3A,8,7,8,7,$3B,5,6,3,4,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,$FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0
TERRAIN3:           dc.b     $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,12,13,$10,$11,$14,$15,$1D,$1E,$1F
                    dc.b     $10,$20,$14,$15,$3C,$3D,$3E,$3F,$40,$41,$18,$19
                    dc.b     $10,$11,$16,$17,$12,$13,$16,$17,$10,$20,$1D,$1E
                    dc.b     $1F,$1D,$1E,$1F,$12,$13,$18,$19,$10,$11,$1D,$1E
                    dc.b     $1F,14,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FF,$FF,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,5,$33,$34
                    dc.b     $3A,8,7,8,7,$3B,5,6,$37,$38,$26,$27,5,6,$3A,8,7
                    dc.b     $24,5,9,10,10,10,11,5,6,5,$22,$35,$36,$3A,8,$3B,5
                    dc.b     6,5,6,$25,$33,$34,$37,5,6,$26,$27,5,6,$3A,$23,5,9
                    dc.b     10,11,$33,$34,5,6,$1A,$1B,$1C,7,8,$3B,5,6,3,4,0,0
                    dc.b     0,$FF,$FF,0,0,0,1,2,$33,$34,5,$3A,8,7,8,7,$3B,5,6
                    dc.b     $37,$38,$26,$27,$37,$38,9,10,11,5,6,5,$33,$34,$35
                    dc.b     $36,6,5,$22,$2A,$2B,$2C,$2D,$2E,$2F,$30,$31,$32
                    dc.b     $37,5,$38,9,10,11,$3A,$24,7,$3B,5,9,10,10,11,$33
                    dc.b     $34,6,5,6,5,$26,$27,$37,$38,5,$22,6,$25,6,$3A,7
                    dc.b     $3B,5,6,$33,5,$3A,8,7,8,7,$3B,5,6,3,4,0,0,0,$FF
                    dc.b     $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,5
                    dc.b     $33,$34,$3A,8,7,8,7,$3B,$37,$38,$39,6,$24,$33,$34
                    dc.b     $35,$36,5,$38,$42,$43,$44,$45,$46,$47,$48,$49,$4A
                    dc.b     $39,5,6,5,6,5,6,5,6,$3A,$3B,6,5,6,7,$3B,$33,$34,5
                    dc.b     $34,$25,$35,5,9,10,10,11,6,5,$33,6,$3A,8,7,8,7
                    dc.b     $3B,5,6,3,4,0,0,0,$FF,$FF,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0
TERRAIN4:           dc.b     $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,13,$10,$11
                    dc.b     $10,$11,$14,$15,$1D,$1E,$1F,$14,$12,$13,$12,$13
                    dc.b     $14,$15,$1D,$1E,$1F,$20,$10,$11,$1D,$1E,$1F,$14
                    dc.b     $15,$10,$11,$14,$15,$10,$11,$1D,$1E,$1F,$10,$11
                    dc.b     $14,$15,$16,$17,$4B,$4C,$4D,$4E,$4F,$12,$13,$16
                    dc.b     $17,$10,$11,$12,$13,$16,$17,$10,$11,14,15,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,$FF,$FF,0,0,0,1,2,5,6,$36
                    dc.b     $3A,8,7,8,7,$3B,$33,$34,$35,5,$26,6,$3A,7,8,8,7,7
                    dc.b     $3B,5,9,10,10,11,$33,$34,$33,$34,$25,$35,$36,9,10
                    dc.b     11,5,6,5,$26,$27,$37,$38,6,$3A,8,7,$3B,5,$33,$34
                    dc.b     $33,6,5,$22,5,9,10,10,10,11,5,$33,$34,$3A,8,7,7
                    dc.b     $3B,5,9,10,10,11,6,$3A,8,7,8,7,$3B,5,6,3,4,0,0,0
                    dc.b     $FF,$FF,0,0,0,1,2,9,10,11,$3A,8,7,8,7,$3B,$33,$34
                    dc.b     $35,$36,5,6,$3A,7,8,8,7,8,$23,$3B,5,5,5,$33,$34
                    dc.b     $35,$22,$2A,$2B,$2C,$2D,$2E,$2F,$30,$31,$32,6,5
                    dc.b     $37,$38,$26,$27,$37,$38,$39,6,5,9,10,11,$33,6,$24
                    dc.b     7,8,7,7,$3B,5,9,10,10,11,$33,$34,6,5,5,5,5,5,$33
                    dc.b     $34,$3A,8,7,7,7,$3B,$35,$36,3,4,0,0,0,$FF,$FF,0,0
                    dc.b     0,1,2,5,6,$33,$3A,8,7,8,7,$3B,5,$33,$34,$33,$34
                    dc.b     $37,$38,6,$37,$38,5,$22,$25,$35,$36,$37,$38,$39,5
                    dc.b     6,$25,$33,$34,5,9,10,10,11,5,$22,$33,$34,$35,$36
                    dc.b     6,6,$26,$27,6,$37,$38,$39,5,6,$22,5,9,10,10,11
                    dc.b     $35,$36,$33,$34,$35,5,$3A,8,8,7,7,$3B,6,$26,$27
                    dc.b     $37,$38,$3A,8,7,8,7,$3B,$34,6,3,4,0,0,0,$FF,$FF,0
                    dc.b     0,0,1,2,5,$33,5,$3A,8,7,8,7,$3B,9,10,11,5,6,5,$33
                    dc.b     6,$3A,8,8,$24,7,$3B,5,$33,$34,$35,$36,5,9,10,10
                    dc.b     11,6,6,$26,$27,5,$25,$35,$36,$33,$34,5,5,$37,$38
                    dc.b     $39,$3A,7,7,8,7,$24,$33,$34,6,5,5,$34,$35,$42,$43
                    dc.b     $44,$45,$46,$47,$48,$49,$4A,$1A,$1B,$1C,5,$33,$34
                    dc.b     $3A,8,7,8,7,$3B,$26,5,3,4,0,0,0,$FF
TERRAIN5:           dc.b     $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     12,13,$1D,$1E,$1F,$10,$11,$1D,$1E,$1F,$14,$15,$12
                    dc.b     $13,$12,$13,$14,$15,$10,$11,$14,$15,$20,$14,$15
                    dc.b     $1D,$1E,$1F,$10,$11,14,15,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,$FF,$FF,0,0,0,1,2,5,$36,5,$3A,8,7,8,8,7,8,7
                    dc.b     8,$23,8,7,8,$3B,5,9,10,11,$33,$34,5,$33,$34,6,$3A
                    dc.b     8,7,8,7,$3B,$35,$36,3,4,0,0,0,0,0,0,0,0,1,2,$35
                    dc.b     $36,$3A,7,8,7,8,7,$3B,5,9,10,11,5,6,5,6,$25,7,8,7
                    dc.b     8,7,8,$3B,$37,$38,6,$3A,8,7,8,7,$3B,$34,6,3,4,0,0
                    dc.b     0,$FF,$FF,0,0,0,1,2,5,$27,5,$3A,8,7,8,7,$3B,$33
                    dc.b     $34,6,$22,$25,5,9,10,10,10,11,6,5,$26,$27,5,6,$37
                    dc.b     $38,$3A,8,7,8,7,$3B,$36,6,3,4,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FF,$FF,0,0,0,1,2
                    dc.b     5,6,$37,$3A,8,7,8,7,$3B,$26,$27,5,$24,6,$35,$36
                    dc.b     $33,$34,$3A,7,8,8,7,$3B,5,6,$26,$27,5,9,10,11,5,5
                    dc.b     $34,$35,$36,$37,$38,$39,5,6,$33,$34,5,$2A,$2B,$2C
                    dc.b     $2D,$2E,$2F,$30,$31,$32,6,6,$33,$34,$22,$1A,$1B
                    dc.b     $1C,9,10,10,11,$35,$36,6,6,$26,$27,5,$37,$38,$39
                    dc.b     $3A,8,7,8,7,$3B,5,$35,3,4,0,0,0,$FF,$FF,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,1,2,5,$33,$34,$3A,8,7,8,7,$3B,$26,$27
                    dc.b     $3A,7,8,7,$3B,5,9,10,11,$33,$34,$37,$38,$39,6,$25
                    dc.b     5,$3A,7,5,8,7,8,8,$3B,5,$33,$34,$35,$36,$37,$38
                    dc.b     $39,$3A,8,7,8,7,$3B,5,6,3,4,0,0,0,$FF
TERRAIN6:           dc.b     $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,12,13,$14,$15,$10,$11,$1D,$1E,$1F
                    dc.b     $10,$11,$14,$12,$13,$16,$17,$10,$11,$1D,$1E,$1F
                    dc.b     $20,$10,$11,$14,$15,$10,$11,$1D,$1E,$1F,$14,$15
                    dc.b     $10,$11,$10,$11,$18,$12,$13,$19,$10,$11,$1D,$1E
                    dc.b     $1F,14,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FF,$FF,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,5,$33,$34
                    dc.b     $3A,8,7,8,7,$3B,5,9,10,10,11,$3A,8,7,8,7,$3B,$26
                    dc.b     $27,6,5,$37,$38,$39,5,$33,$34,6,$25,$35,$36,$33
                    dc.b     $34,6,5,6,$26,$27,5,6,5,$22,6,$33,$34,$35,$36,5
                    dc.b     11,$33,$34,5,$37,$38,$39,$35,$36,$3A,8,7,8,7,$3B
                    dc.b     $35,5,3,4,0,0,0,$FF,$FF,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,5
                    dc.b     $33,$34,$3A,8,7,8,7,$3B,9,10,11,5,$22,$2A,$2B,$2C
                    dc.b     $2D,$2E,$2F,$30,$31,$32,6,5,$37,$38,5,$24,5,$3A,8
                    dc.b     8,7,7,8,$3B,$26,$27,5,5,$35,$36,6,$3A,8,7,8,7,$3B
                    dc.b     $27,6,3,4,0,0,0,$FF,$FF,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,5
                    dc.b     9,10,11,$33,$34,$3A,7,$3B,$33,$34,$35,$36,$25,$35
                    dc.b     $36,$37,$38,$39,5,6,$26,$27,5,$33,$34,$33,$34,5
                    dc.b     $35,$36,$3A,8,7,8,$23,$3B,5,9,10,10,11,$35,$36
                    dc.b     $3A,8,7,8,7,$3B,$33,$34,3,4,0,0,0,$FF,$FF,0,0,0,1
                    dc.b     2,5,$35,$36,$3A,8,7,8,7,$3B,$37,$38,$39,$3A,8,7,8
                    dc.b     7,$3B,5,6,3,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,1,2,5,6,$26,$3A,8,7,8,7,$3B,5,$33,$34
                    dc.b     5,9,10,10,11,$35,$36,$25,6,$37,$38,$39,5,6,$1A
                    dc.b     $1B,$1C,$3A,7,8,7,$3B,$27,6,3,4,0,0,0,$FF
TERRAIN7:           dc.b     $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,12,13,$10,$11,$14,$15,$1D,$1E,$1F
                    dc.b     $14,$15,$10,$12,$13,$16,$17,$1D,$1E,$1F,$10,$11
                    dc.b     $10,$11,$1D,$1E,$1F,$16,$17,$12,$13,$20,$10,$11
                    dc.b     $1D,$1E,$1F,$14,$18,$19,$12,$13,$10,$11,$1D,$1E
                    dc.b     $1F,14,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FF,$FF,0
                    dc.b     0,0,1,2,$33,6,$33,$34,$3A,7,8,7,$3B,5,$33,$34,5
                    dc.b     $35,$36,$3A,8,7,8,8,$3B,6,$37,$38,$39,$33,$34,6
                    dc.b     $22,$35,$36,$33,$34,5,9,10,11,$33,$34,6,5,6,$33
                    dc.b     $34,$22,6,$33,$34,9,10,10,11,$35,$36,5,6,$24,6
                    dc.b     $26,$27,6,5,$37,$38,$39,$1A,$1B,$1C,6,$33,$34,6,5
                    dc.b     $26,$27,6,$3A,8,7,8,7,$3B,6,$33,3,4,0,0,0,$FF,$FF
                    dc.b     0,0,0,1,2,$33,$34,5,$3A,8,7,8,7,$3B,$35,$36,$37
                    dc.b     $38,$39,5,$3A,8,7,8,8,$3B,6,$26,$27,5,5,$35,$36
                    dc.b     $25,$33,$34,$3A,8,7,8,8,$3B,5,9,10,10,11,5,6,$24
                    dc.b     6,$22,$35,5,6,$26,$27,5,$37,$38,$39,5,$33,$34,6
                    dc.b     $3A,8,7,8,7,$3B,$27,6,3,4,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,$FF,$FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,1,2,$37,$38,$39,$3A,8,7,8,7,$3B,5,9,10
                    dc.b     11,$3A,8,7,7,$3B,$33,$34,$35,$36,5,$3A,7,7,7,8
                    dc.b     $23,8,$24,$33,5,6,5,$26,6,$26,$27,5,6,$33,$34,5
                    dc.b     $35,$36,5,5,9,10,10,11,5,6,$33,$34,6,$37,$38,$39
                    dc.b     $3A,8,7,8,7,$3B,$37,5,3,4,0,0,0,$FF,$FF,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,1,2,5,$33,$34,$3A,8,7,8,7,$3B,$26,$27,6
                    dc.b     $25,$35,$36,5,9,10,10,11,$35,$36,$33,$34,$35,$36
                    dc.b     5,$27,$3A,8,7,8,7,$3B,5,$33,3,4,0,0,0,0,0,0,0,0,0
                    dc.b     0,0,0,0,0,0,0,0,0,0,$FF,0,0,0

; -------------------------------------------

                    section  uninit_dats,bss_c

BUF11:              ds.b     632
lbB00FF7C:          ds.b     1896
BUF12:              ds.b     2528
BUF13:              ds.b     2528
BUF14:              ds.b     2528
BUF15:              ds.b     2528
BUF16:              ds.b     632
BUF17:              ds.b     2528
BUF18:              ds.b     2528
BUF19:              ds.b     2528
BUF1A:              ds.b     2528
BUF1B:              ds.b     2528
BUF1C:              ds.b     632
BUF1D:              ds.b     632
lbB01672C:          ds.b     632
BUF21:              ds.b     632
lbB016C1C:          ds.b     1896
BUF22:              ds.b     2528
BUF23:              ds.b     2528
BUF24:              ds.b     2528
BUF25:              ds.b     2528
BUF26:              ds.b     632
BUF27:              ds.b     2528
BUF28:              ds.b     2528
BUF29:              ds.b     2528
BUF2A:              ds.b     2528
BUF2B:              ds.b     2528
BUF2C:              ds.b     632
BUF2D:              ds.b     632
lbB01D3CC:          ds.b     632
BUF31:              ds.b     2528
GRAVE:              ds.b     632
BUBBLES:            ds.b     632
NOSE:               ds.b     1264
OBJS:               ds.b     3360
OBJS2:              ds.b     3360
ONETREE:            ds.b     2568
ONETREEA:           ds.b     1928
ONETREEB:           ds.b     1928
TWOTREE:            ds.b     2568
TWOTREEA:           ds.b     1928
TWOTREEB:           ds.b     1928
THRTREE:            ds.b     2568
THRTREEA:           ds.b     1928
THRTREEB:           ds.b     1928
LAND:               ds.b     20800
CLOUD:              ds.b     20800
MAPS:               ds.b     14840
CLOUD_SUB:          ds.b     64
ITEMON:             ds.b     228
ITEMOFF:            ds.b     228
FIN:                ds.b     1264
VOLTOP:             ds.b     1440
lbB03389C:          ds.b     1440
lbB033E3C:          ds.b     1440
lbB0343DC:          ds.b     1440
RTCOVER:            ds.b     1288
MAPBOX:             ds.b     96
MAPSPOT:            ds.b     96
S1BACK:             ds.b     6656
S2BACK:             ds.b     6656
ROCKET:             ds.b     1008
STREN:              ds.b     280
WSUB:               ds.b     992
WSUB2:              ds.b     992
WOMAN:              ds.b     632
lbB039284:          ds.b     632
VOLCANOE:           ds.b     6144
PARABUFF:           ds.b     128
lbB03AD7C:          ds.b     128
CONTROLS:           ds.b     3080
HANDLE:             ds.b     4
LENGTH:             ds.b     4
BUPHER:             ds.b     512
JOY1TRIG:           ds.w     1
JOY2TRIG:           ds.w     1
TRAPLIST:           ds.b     100*6
RANDOM_AREA:        ds.b     8192

                    end
