; -------------------------------------------
; "Spy VS Spy II - The Island Caper" Amiga.
; Disassembled by Franck "hitchhikr" Charlet.
; -------------------------------------------

                    mc68000
                    opt      o+
                    opt      all+

; -------------------------------------------

_LVOAllocMem        equ      -198
_LVOFreeMem         equ      -210
_LVOOpenLibrary     equ      -552

_LVOOpen            equ      -30
_LVOClose           equ      -36
_LVORead            equ      -42
_LVOExit            equ      -144

; -------------------------------------------

                    section  begin,code_c

ProgStart:          bra      INIT

COPPER_LIST:
PLANES:             dc.w     $E2,0,$E0,0
                    dc.w     $E6,0,$E4,0
                    dc.w     $EA,0,$E8,0
                    dc.w     $EE,0,$EC,0
                    dc.w     $FFFF,$FFFE
END_COPPER_LIST:
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
E_SHOOT:            dc.w     1,40,0,40,-1,10,-1
E_EXPLODE:          dc.w     450,0,0,1,34,0,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1,1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,20,0,0,1,-1
                    dc.w     1,-1
E_DIVE:             dc.w     1,64,0,500,0,1,16,-4,0,-1

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
                    move.w   #1,14(a6)
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
                    move.w   #1,14(a6)
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
                    move.w   #1,14(a6)
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
                    move.w   #1,14(a6)
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

SHOOT:              movem.l  d0-d7/a0-a6,-(sp)
                    lea      $DFF0D0,a5
                    lea      MUSINF_3,a6
                    move.w   #8,$DFF096
                    move.w   #$FF,$DFF09E
                    move.l   #RANDOM_AREA,(a5)
                    move.w   #2000,20(a6)
                    move.w   20(a6),6(a5)
                    move.w   #8192/2,4(a5)
                    clr.w    6(a6)
                    clr.w    (a6)
                    clr.w    4(a6)
                    move.l   #E_SHOOT,10(a6)
                    move.w   #$8008,$DFF096
                    movem.l  (sp)+,d0-d7/a0-a6
                    rts

EXPLODE:            lea      $DFF0D0,a5
                    lea      MUSINF_3,a6
                    move.w   #$FF,$DFF09E
                    move.w   #8192/2,4(a5)
                    move.l   #RANDOM_AREA,(a5)
                    move.w   #3000,20(a6)
                    move.w   20(a6),6(a5)
                    clr.w    6(a6)
                    clr.w    (a6)
                    clr.w    4(a6)
                    move.l   #E_EXPLODE,10(a6)
                    rts

DIVE:               lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    move.w   #$FF,$DFF09E
                    move.w   #32/2,4(a5)
                    move.l   #TRIANGLE32,(a5)
                    move.w   #2130,20(a6)
                    move.w   20(a6),6(a5)
                    clr.w    6(a6)
                    clr.w    (a6)
                    clr.w    4(a6)
                    move.l   #E_DIVE,10(a6)
                    rts

MYINT6:             tst.b    $BFDD00
                    tst.w    MASTER_ENABLE
                    beq      MYINT6_RET
                    movem.l  d0-d7/a0-a6,-(sp)
                    tst.w    MUSIC_DELAY
                    beq      .DELAY
                    subq.w   #1,MUSIC_DELAY
                    bra      ENVS
.DELAY:             move.w   #3,MUSIC_DELAY
                    tst.w    MUSIC_SWITCH
                    beq      ENVS
                    bsr      PLAYMUS
                    bsr      X8912
ENVS:               lea      $DFF0A0,a5
                    lea      MUSINF_0,a6
                    tst.w    14(a6)
                    beq      lbC00082A
                    bsr      CHANGE_ENVELOPE
lbC00082A:          lea      $DFF0B0,a5
                    lea      MUSINF_1,a6
                    tst.w    14(a6)
                    beq      lbC000842
                    bsr      CHANGE_ENVELOPE
lbC000842:          lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    tst.w    14(a6)
                    beq      lbC00085A
                    bsr      CHANGE_ENVELOPE
lbC00085A:          lea      $DFF0D0,a5
                    lea      MUSINF_3,a6
                    tst.w    14(a6)
                    beq      lbC000872
                    bsr      CHANGE_ENVELOPE
lbC000872:          movem.l  (sp)+,d0-d7/a0-a6
MYINT6_RET:         move.w   #$2000,$DFF09C
                    rte

CHANGE_ENVELOPE:    tst.w    (a6)
                    bne      SAME_STEP
                    move.l   10(a6),a0
                    move.w   (a0),d0
                    bmi      DO_VOLUME
                    addq.w   #2,a0
                    move.w   d0,(a6)
                    move.w   (a0)+,2(a6)
                    move.w   (a0)+,4(a6)
                    move.l   a0,10(a6)
SAME_STEP:          tst.w    (a6)
                    beq      DO_VOLUME
                    subq.w   #1,(a6)
                    move.w   6(a6),d0
                    add.w    2(a6),d0
                    move.w   d0,6(a6)
                    move.w   20(a6),d0
                    add.w    4(a6),d0
                    move.w   d0,20(a6)
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
                    clr.w    (6,a6)
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
                    bsr      PSGW
                    move.w   #$D,d0
                    move.w   #9,d1
                    bsr      PSGW
                    move.w   #$C,d0
                    move.w   #3,d1
                    bsr      PSGW
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
                    bpl.w    NEXTSEQ1
                    addq.b   #3,d0
                    move.b   d0,14(a0)
                    cmp.b    15(a0),d0
                    beq      NEXTSEQ0
                    bcc      RESETSEQ
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
                    subq.b   #1,12(a0)
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
                    bra      NEXTNOT1

CONTSONG:           move.l   20(a0),d2
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
                    ori.w    #$C8,d0
                    move.b   d0,REG7
                    move.w   d0,d1
                    move.w   #7,d0
                    bsr      PSGW
                    move.b   #$10,13(a0)
                    move.b   1(a1),d0
                    and.b    #$70,d0
                    cmp.b    #$40,d0
                    beq      OUTAGAIN
                    move.b   #$F,13(a0)
                    rts
SNAREA:             moveq    #0,d0
                    move.b   REG7,d0
                    and.w    #$36,d0
                    ori.w    #$C1,d0
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
                    ori.b    #$D0,d0
                    move.b   d0,REG7
                    move.w   d0,d1
                    move.w   #7,d0
                    bsr      PSGW
                    move.b   #$10,13(a0)
                    move.b   1(a1),d0
                    and.b    #$70,d0
                    cmp.b    #$40,d0
                    beq      OUTAGAIN
                    move.b   #$C,13(a0)
OUTAGAIN:           move.w   #$B,d0
                    move.w   #3,d1
                    bsr      PSGW
                    move.w   #$D,d0
                    move.w   #3,d1
                    bra      PSGW

SNAREB:             move.b   REG7,d0
                    and.w    #$2D,d0
                    ori.w    #$C2,d0
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

OUTVC1:             move.l   #8,d4
                    moveq    #0,d5
                    bra      SNDOUT

OUTVC2:             move.l   #9,d4
                    move.l   #2,d5
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
                    addq.b   #1,d0
                    move.b   8(a0),d1
                    bra      PSGW

NOTEMODS:           move.b   d0,SAVE
                    and.w    #$F,d0
                    move.b   d0,IRQA
                    move.w   d0,d5
                    move.w   d4,d0
                    cmp.b    #8,d0
                    bcc.w    XXMOD5
                    and.w    #7,d0
                    add.b    d5,d0
                    cmp.b    #$C,d0
                    bcs      XXMOD1
                    addq.b   #4,d0
                    and.w    #$F,d0
                    move.w   #$FFFF,d7
NOTEMOD1:
                    move.b   d0,IRQA
                    move.w   d0,d5
                    move.b   SAVE,d0
                    tst.w    d7
                    beq      NOTEMOD2
                    add.b    #16,d0
NOTEMOD2:
                    and.b    #$70,d0
                    or.b     d5,d0
                    move.w   d0,d5
                    move.b   d0,IRQA
                    rts
NOTEMOD5:
                    eor.b    #$FF,d0
                    addq.b   #1,d0
                    add.b    d5,d0
                    bcs      NOTEMOD6
                    subq.b   #4,d0
                    and.w    #$F,d0
                    move.b   d0,IRQA
                    move.w   d0,d5
                    move.b   SAVE,d0
                    sub.b    #16,d0
                    bra      NOTEMOD2
NOTEMOD6:
                    and.w    #$F,d0
                    move.b   d0,IRQA
                    move.w   d0,d5
                    move.b   SAVE,d0
                    bra      NOTEMOD2
XXMOD5:
                    and.w    #7,d0
                    bra      NOTEMOD5
XXMOD1:
                    clr.w    d7
                    bra      NOTEMOD1
RESET:
                    move.w   #8,d0
                    clr.w    d1
                    bsr      PSGW
                    move.w   #9,d0
                    clr.w    d1
                    bsr      PSGW
                    move.w   #$A,d0
                    clr.w    d1
                    bra      PSGW

DURALIST:           dc.b     9,$12,$1B,$24,$36,$48,$6C,$90
SSETBASE:           dc.b     $40,2,0,0,$10,$44,$65,$80,$8A,2,0,0,$10,$44,$65,$80,$C9,1,0,0,$10,$44
                    dc.b     $65,$C4,6,0,0,0,$10,5,4,0,0,0,0,0,$80,2,0,$80
SEQDATA1:           dc.b     $F0,$42,$42,$30,$45,$5A,$70,$33,$42,$10,$1E,$30,$10,0,$1B,$40,$5D,$84,0,$42,$42
SEQDATA2:           dc.b     0,0,$24,$A,0,$24,0,0,$24,$A,0,$24,$C,0,$24,$A,0,$24,0,0,$24,$C,$27,$36,$A,$27,$36
MUSDATA1:           dc.b     $5A,$12,0,$D7,$21,5,$57,$30,$70,$DA,$30,0,$D7,$30,0,$60,$30,$78,$D7
                    dc.b     $30,$78,$DA,$32,0,$D7,$21,3,$D7,5,$78,$5A,$13,$80,$DA,$3D,$F8,$DA,$39
                    dc.b     0,$E2,$31,0,$E0,$32,$78,$D9,$22,$38,$F0,5,2,$E0,$40,0,$E0,$40,$79,$E0
                    dc.b     $40,$79,$60,$40,1,$E2,$40,0,0,5,$78,$E3,$30,$3A,$E2,$30,$10,0,4,4,$5A
                    dc.b     $31,$78,$69,$30,$7A,$67,$30,0,$80,4,4,$55,$31,$78,$47,$40,$78,$47,$40
                    dc.b     0,$52,$40,0,$57,$40,$78,$47,$40,$78,$47,$40,0,0,1,0,$47,$40,$78,$47
                    dc.b     $40,$78,$52,$40,0,$57,$40,0,$47,$40,$78,$C7,$40,$78,0,4,$44
MUSDATA2:           dc.b     $37,$41,$28,$CB,$50,0,$42,$40,8,$C7,$40,$78,$D1,$50,$78,$51,0,0,$B7
                    dc.b     $41,0,$B7,$40,$78,$CB,$50,$78,$C2,$40,0,$C7,$41,0,$CB,$50,$78,$D1,$50
                    dc.b     $78,$B7,$41,0,$CB,$50,$40,$C2,$40,$78,$C7,$40,$78,$D1,$50,0,0,1,$78
IRQA:               dc.b     0
SAVE:               dc.b     0
CHAN:               dc.b     0
                    even
VOICE1:             dc.l     0,0,0,$12
                    dc.l     SEQDATA1
                    dc.l     MUSDATA1
VOICE2:             dc.l     0,0,0,$18
                    dc.l     SEQDATA2
                    dc.l     MUSDATA2
MUSIC_SWITCH:       dc.w     0
RND1:               dc.l     $98121233
RND2:               dc.l     $FE651232
RND3:               dc.l     $17263433

INIT:               bsr      ALLOCATE_MEMORY
                    bsr      START_SOUNDS
                    bsr      SETUP_SCREEN
                    move.l   SCREEN1,a0
                    bsr      CLEAR_SCREEN
                    move.l   SCREEN2,d2
                    move.l   #TIT_NAME,d1
                    bsr      DECO_PIC
                    move.l   SCREEN2,a0
                    lea      128(a0),a0
                    move.l   TIT32K,a1
                    bsr      ATARI_COPY
                    move.l   SCREEN2,a0
                    addq.w   #4,a0
                    bsr      COLOUR_COPY
                    move.l   SCREEN2,d2
                    move.l   #JET_NAME,d1
                    bsr      DECO_PIC
                    move.l   SCREEN2,a0
                    lea      128(a0),a0
                    move.l   JET32K,a1
                    bsr      ATARI_COPY
                    move.l   SCREEN2,d2
                    move.l   #CRED_NAME,d1
                    bsr      DECO_PIC
                    move.l   SCREEN2,a0
                    lea      128(a0),a0
                    move.l   CRED32K,a1
                    bsr      ATARI_COPY
FADE:               lea      MASK,a0
                    move.w   #251-1,d0
.COPY_ALL_MASK:     lea      FADE_MASKING_TABLE,a1
                    move.w   #16-1,d1
.COPY_MASK:         move.w   (a1)+,(a0)+
                    dbra     d1,.COPY_MASK
                    dbra     d0,.COPY_ALL_MASK
PIXELFADE:          lea      MASK,a1
                    move.w   #16-1,d1
.COPY_TITLE:        move.l   TIT32K,a0
                    move.l   SCREEN1,a3
                    bsr      BLIT_ME_HONEY
                    addq.w   #2,a1
                    dbra     d1,.COPY_TITLE
                    move.l   CRED32K,a0
                    move.l   SCREEN1,a3
                    move.w   #0,a5
                    move.w   #29-1,d6
                    bsr      PIXEL_PIECE
                    move.w   #(177*40),a5
                    move.w   #23-1,d6
                    bsr      PIXEL_PIECE
                    move.w   #(28*40),a5
                    move.w   #94-1,d6
                    bsr      PIXEL_PIECE
                    move.l   #364544,d0
.WAIT_START:        subq.l   #1,d0
                    bne      .WAIT_START
                    move.l   TIT32K,a0
                    move.w   #0,a5
                    move.w   #29-1,d6
                    bsr      PIXEL_PIECE
                    move.w   #(177*40),a5
                    move.w   #23-1,d6
                    bsr      PIXEL_PIECE
                    bsr      MOVE_THE_JETS
                    move.l   #2097152,d0
.WAIT_END:          subq.l   #1,d0
                    bne      .WAIT_END
                    bsr      RESCIND_MEMORY
                    move.l   SAVEINT6,$78.w
EXIT_THE_PROGRAM:   lea      $DFF180,a0
                    move.w   #32-1,d0
.CLEAR_PALETTE:     clr.w    (a0)+
                    dbra     d0,.CLEAR_PALETTE
                    move.l   #0,d1
                    move.l   DOS_BASE,a6
                    jsr      _LVOExit(a6)
                    moveq    #0,d0
                    rts

BLIT_ME_HONEY:      move.l   a1,-(sp)
                    move.w   #((200*40)/2)-1,d0
.DRAW:              move.w   (a1)+,d3
                    move.w   d3,d2
                    and.w    (a0)+,d2
                    or.w     d2,(a3)+
                    move.w   d3,d2
                    and.w    (200*40-2)(a0),d2
                    or.w     d2,(200*40-2)(a3)
                    move.w   d3,d2
                    and.w    (200*2*40-2)(a0),d2
                    or.w     d2,(200*2*40-2)(a3)
                    move.w   d3,d2
                    and.w    (200*3*40-2)(a0),d2
                    or.w     d2,(200*3*40-2)(a3)
                    dbra     d0,.DRAW
                    move.l   (sp)+,a1
                    rts

PIXEL_PIECE:        movem.l  a0/a3,-(sp)
                    lea      MASK,a1
                    add.w    a5,a0
                    add.w    a5,a3
                    move.w   #16-1,d7
_BLIT_ME_HONEY_PIECE:
                    bsr      BLIT_ME_HONEY_PIECE
                    addq.w   #2,a1
                    dbra     d7,_BLIT_ME_HONEY_PIECE
                    movem.l  (sp)+,a0/a3
                    rts

BLIT_ME_HONEY_PIECE:
                    movem.l  a0/a1/a3,-(sp)
                    move.w   d6,d0
lbC00120E:          move.w   #20-1,d3
lbC001212:          move.w   #4-1,d2
lbC001216:          move.w   (a1),d1
                    not.w    d1
                    and.w    d1,(a3)
                    not.w    d1
                    and.w    (a0),d1
                    or.w     d1,(a3)
                    lea      (200*40)(a3),a3
                    lea      (200*40)(a0),a0
                    dbra     d2,lbC001216
                    lea      -((200*4*40)-2)(a0),a0
                    lea      -((200*4*40)-2)(a3),a3
                    addq.w   #2,a1
                    dbra     d3,lbC001212
                    dbra     d0,lbC00120E
                    movem.l  (sp)+,a0/a1/a3
                    rts

MOVE_THE_JETS:      move.l   SCREEN1,a0
                    move.l   SCREEN2,a2
                    move.w   #(200*40)-1,d0
.COPY:              move.l   (a0)+,(a2)+
                    dbra     d0,.COPY
                    clr.w    HOLEINDEX
                    clr.w    PLANESPOT
                    clr.w    FRAME_JET
                    move.w   #-64,XSPOT
                    clr.w    OLDX1
                    clr.w    OLDX2
.LOOP:              move.w   XSPOT,d0
                    move.w   #25,d1
                    move.w   OLDX2,RESTORE_X
                    suba.l   a5,a5
                    move.l   #$5000,RASTER_VALUE
                    bsr      SHOW_JET
                    move.w   XSPOT,OLDX2
                    addq.w   #4,XSPOT
                    addq.w   #1,PLANESPOT
                    move.w   PLANESPOT,d0
                    and.w    #7,d0
                    bne      .SHOOT
                    move.w   XSPOT,d0
                    move.w   #25,d1
                    bsr      BLOW_A_HOLE
.SHOOT:             cmp.w    #322,XSPOT
                    blt.w    .LOOP

MOVE_OTHERJET:      clr.w    FRAME_JET
                    clr.w    HOLEINDEX
                    clr.w    PLANESPOT
                    move.w   #-64,XSPOT
                    clr.w    OLDX1
                    clr.w    OLDX2
                    move.l   #(112*40),a5
.LOOP:              move.w   XSPOT,d0
                    move.w   #75,d1
                    move.w   OLDX1,RESTORE_X
                    move.l   #$B000,RASTER_VALUE
                    bsr      SHOW_JET
                    move.w   XSPOT,OLDX1
                    addq.w   #4,XSPOT
                    addq.w   #1,PLANESPOT
                    move.w   PLANESPOT,d0
                    and.w    #7,d0
                    bne      .SHOOT
                    move.w   XSPOT,d0
                    move.w   #80,d1
                    bsr      BLOW_A_HOLE
.SHOOT:             cmp.w    #322,XSPOT
                    blt.w    .LOOP
                    bsr      EXPLODE
                    bra      DIVE

DO_RESTORE_OF_JET:  move.w   RESTORE_X,d0
                    asr.w    #3,d0
                    and.w    #$FFFE,d0
                    move.l   SCREEN2,a1
                    move.l   SCREEN1,a2
                    add.w    d0,a1
                    add.w    d0,a2
                    lsl.w    #3,d1
                    add.w    d1,a1
                    add.w    d1,a2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d1,a1
                    add.w    d1,a2
                    move.w   #33-1,d4
.LOOP:              move.l   (a1),(a2)
                    move.l   (200*40)(a1),(200*40)(a2)
                    move.l   (200*2*40)(a1),(200*2*40)(a2)
                    move.l   (200*3*40)(a1),(200*3*40)(a2)
                    move.l   4(a1),4(a2)
                    move.l   (200*40+4)(a1),(200*40+4)(a2)
                    move.l   (200*2*40+4)(a1),(200*2*40+4)(a2)
                    move.l   (200*3*40+4)(a1),(200*3*40+4)(a2)
                    move.l   8(a1),8(a2)
                    move.l   (200*40+8)(a1),(200*40+8)(a2)
                    move.l   (200*2*40+8)(a1),(200*2*40+8)(a2)
                    move.l   (200*3*40+8)(a1),(200*3*40+8)(a2)
                    lea      40(a2),a2
                    lea      40(a1),a1
                    dbra     d4,.LOOP
                    rts

SHOW_JET:           movem.l  d0-d2,-(sp)
                    move.l   RASTER_VALUE,d1
                    bsr      WAIT_FOR_RASTER
                    clr.w    MASTER_ENABLE
                    movem.l  (sp),d0-d2
                    bsr      DO_RESTORE_OF_JET
                    movem.l  (sp)+,d0-d2
                    asr.w    #3,d0
                    and.w    #$FFFE,d0
                    move.w   d0,SAVE_REL_XPOS
                    move.l   SCREEN1,a1
                    move.l   JET32K,a2
                    add.w    a5,a2
                    move.l   SCREEN2,a3
                    ; *40
                    move.w   d1,d3
                    lsl.w    #3,d3
                    lsl.w    #5,d1
                    add.w    d3,d1
                    move.w   FRAME_JET,d4
                    add.w    d4,d4
                    lea      FRAME_OFFSET,a4
                    move.w   (a4,d4.w),d4
                    add.w    d4,a2
                    addq.w   #1,FRAME_JET
                    cmp.w    #4,FRAME_JET
                    bne      lbC001476
                    clr.w    FRAME_JET
lbC001476:          add.w    d1,a1
                    add.w    d0,a1
                    add.w    d1,a3
                    add.w    d0,a3
                    move.w   #33-1,d4
lbC001482:          move.w   #6-1,d5
                    move.w   SAVE_REL_XPOS,d0
lbC00148C:          tst.w    d0
                    bmi      lbC0014E8
                    cmp.w    #40,d0
                    bge      lbC0014E8
                    move.w   (a2),d7
                    or.w     (200*40)(a2),d7
                    or.w     (200*2*40)(a2),d7
                    or.w     (200*3*40)(a2),d7
                    not.w    d7
                    move.w   (a3),(a1)
                    move.w   (200*40)(a3),(200*40)(a1)
                    move.w   (200*2*40)(a3),(200*2*40)(a1)
                    move.w   (200*3*40)(a3),(200*3*40)(a1)
                    and.w    d7,(a1)
                    and.w    d7,(200*40)(a1)
                    and.w    d7,(200*2*40)(a1)
                    and.w    d7,(200*3*40)(a1)
                    move.w   (a2),d7
                    or.w     d7,(a1)
                    move.w   (200*40)(a2),d7
                    or.w     d7,(200*40)(a1)
                    move.w   (200*2*40)(a2),d7
                    or.w     d7,(200*2*40)(a1)
                    move.w   (200*3*40)(a2),d7
                    or.w     d7,(200*3*40)(a1)
lbC0014E8:          addq.w   #2,a1
                    addq.w   #2,a2
                    addq.w   #2,a3
                    addq.w   #2,d0
                    dbra     d5,lbC00148C
                    lea      (40-(6*2))(a1),a1
                    lea      (40-(6*2))(a3),a3
                    lea      (40-(6*2))(a2),a2
                    dbra     d4,lbC001482
                    move.w   #1,MASTER_ENABLE
                    rts

WAIT_FOR_RASTER:    move.l   d1,d2
                    add.w    #$B00,d2
.WAIT:              move.l   $DFF004,d0
                    and.l    #$1FFFF,d0
                    cmp.l    d1,d0
                    bls      .WAIT
                    cmp.l    d2,d0
                    bhi     .WAIT
                    rts

BLOW_A_HOLE:        lea      HOLETABLE,a0
                    move.w   HOLEINDEX,d2
                    add.w    d2,d2
                    addq.w   #1,HOLEINDEX
                    and.w    #7,HOLEINDEX
                    add.w    #96,d0
                    add.w    (a0,d2.w),d1
                    lea      HOLESHAPE,a0
                    cmp.w    #310,d0
                    bge      lbC001594
                    asr.w    #3,d0
                    and.w    #$FFFE,d0
                    ; *40
                    move.w   d1,d3
                    lsl.w    #3,d1
                    lsl.w    #5,d3
                    add.w    d1,d3
                    add.w    d0,d3
                    move.l   SCREEN1,a1
                    move.l   TIT32K,a2
                    add.w    d3,a1
                    add.w    d3,a2
                    bsr      MOVE_A_HOLE
                    move.l   SCREEN2,a1
                    add.w    d3,a1
                    bra      MOVE_A_HOLE
lbC001594:          rts

MOVE_A_HOLE:        movem.l  d0-d6/a0-a2,-(sp)
                    move.w   #5-1,d6
.COPY_LINES:        move.w   #4-1,d5
.COPY_BPS:          move.w   (a0),d7
                    and.w    d7,(a1)
                    not.w    d7
                    and.w    (a2),d7
                    or.w     d7,(a1)
                    lea      (200*40)(a1),a1
                    lea      (200*40)(a2),a2
                    dbra     d5,.COPY_BPS
                    lea      -(200*4*40-40)(a1),a1
                    lea      -(200*4*40-40)(a2),a2
                    addq.w   #2,a0
                    dbra     d6,.COPY_LINES
                    tst.w    SHOOT_FLAG
                    beq      lbC0015DA
                    subq.w   #1,SHOOT_FLAG
                    bra      lbC0015E8
lbC0015DA:          move.w   #1,SHOOT_FLAG
                    bsr      SHOOT
lbC0015E8:          movem.l  (sp)+,d0-d6/a0-a2
                    rts

HOLETABLE:          dc.w     30,16,35,26,32,28,13,20
HOLESHAPE:          dc.w     %1111100001111111
                    dc.w     %1111000000111111
                    dc.w     %1111000000111111
                    dc.w     %1111000000111111
                    dc.w     %1111100001111111

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
                    ori.w    #$111,d1
                    move.w   d1,(a1)+
                    dbra     d0,.COPY
                    rts

LOAD_FILE:          move.l   d2,-(sp)
                    move.l   d1,-(sp)
                    move.l   4.w,a6
                    moveq    #0,d0
                    lea      DOS_NAME,a1
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
                    move.w   #((END_COPPER_LIST-COPPER_LIST)/2)-1,d0
                    lea      COPPER_LIST,a0
                    lea      COPPER_LIST2,a1
.COPY:              move.w   (a0)+,(a1)+
                    dbra     d0,.COPY
                    move.l   SCREEN1,d1
                    bsr      WHICH_PLANES
                    move.l   #PLANES,COPPER1
                    move.l   #COPPER_LIST2,COPPER2
                    move.l   #PLANES,$80(a6)
                    move.l   #$2C81F4C1,$8E(a6)
                    move.l   #$3800D0,$92(a6)
                    clr.w    $108(a6)
                    clr.w    $10A(a6)
                    clr.w    $102(a6)
                    move.w   #$4200,$100(a6)
                    move.w   #4,$104(a6)
                    clr.w    $88(a6)
                    move.w   #$83DF,$96(a6)
                    rts

WHICH_PLANES:       move.w   #4-1,d0
                    lea      PLANES,a0
lbC00173A:          move.w   d1,2(a0)
                    swap     d1
                    move.w   d1,6(a0)
                    swap     d1
                    add.l    #(200*40),d1
                    addq.w   #8,a0
                    dbra     d0,lbC00173A
                    rts

BLIT_A_SPY:         move.l   SCREEN2,a0
                    lea      (11*40)(a0),a0
                    move.l   SCREEN1,a3
                    lea      (50*40+20)(a3),a3
                    move.w   #40-(3*2),d1
                    swap     d1
                    move.w   #40-(3*2),d1
                    move.w   #$9F0,d2
                    swap     d2
                    move.w   #0,d2
                    move.w   #$8440,$DFF096
                    move.w   #(29<<6)+3,d3
                    bsr      BLIT
                    lea      (200*40)(a0),a0
                    lea      (200*40)(a3),a3
                    bsr      BLIT2
                    lea      (200*40)(a0),a0
                    lea      (200*40)(a3),a3
                    bsr      BLIT2
                    lea      (200*40)(a0),a0
                    lea      (200*40)(a3),a3
                    bra      BLIT2

BLIT:               move.l   d0,$DFF060
                    move.l   d1,$DFF064
                    move.l   d2,$DFF040
                    move.l   #-1,$DFF044
BLIT2:              move.l   a0,$DFF050
                    move.l   a1,$DFF04C
                    move.l   a2,$DFF048
                    move.l   a3,$DFF054
                    move.w   d3,$DFF058
WAIT_BLIT:          btst     #6,$DFF002
                    bne      WAIT_BLIT
                    rts

SWAP_SCREEN:        move.l   SCREEN1,d0
                    move.l   SCREEN2,SCREEN1
                    move.l   d0,SCREEN2
                    move.l   COPPER1,d0
                    move.l   COPPER2,COPPER1
                    move.l   d0,COPPER2
                    move.l   COPPER1,$DFF080
                    rts

CLEAR_SCREEN:       move.w   #((200*40)/4)-1,d0
.CLEAR:             clr.l    (a0)+
                    clr.l    (a0)+
                    clr.l    (a0)+
                    clr.l    (a0)+
                    dbra     d0,.CLEAR
                    rts

ALLOCATE_MEMORY:    bsr      FIND32K
                    move.l   d0,LOADSCREEN
                    bsr      FIND32K
                    move.l   d0,ONESCREEN
                    bsr      FIND32K
                    move.l   d0,TWOSCREEN
                    bsr      FIND32K
                    move.l   d0,TIT32K
                    bsr      FIND32K
                    move.l   d0,JET32K
                    bsr      FIND32K
                    move.l   d0,CRED32K
                    rts

RESCIND_MEMORY:     move.l   CRED32K,a1
                    bsr      LOSE32K
                    move.l   JET32K,a1
                    bsr      LOSE32K
                    move.l   TIT32K,a1
                    bsr      LOSE32K
                    move.l   TWOSCREEN,a1
                    bsr      LOSE32K
                    move.l   ONESCREEN,a1
                    bsr      LOSE32K
                    move.l   LOADSCREEN,a1
                    bra      LOSE32K

FIND32K:            move.l   4.w,a6
                    move.l   #32768,d0
                    moveq    #2,d1
                    jsr      _LVOAllocMem(a6)
                    tst.l    d0
                    beq      WHOS_REMOVED_THE_RAM_CHIPS
                    rts

WHOS_REMOVED_THE_RAM_CHIPS:
                    move.w   #$1FF,$DFF180
                    move.w   #$100,$DFF180
                    bra      WHOS_REMOVED_THE_RAM_CHIPS

LOSE32K:            move.l   4.w,a6
                    move.l   #32768,d0
                    jmp      _LVOFreeMem(a6)

DECO_PIC:           move.l   d2,-(sp)
                    move.l   LOADSCREEN,d2
                    bsr      LOAD_FILE
                    move.l   (sp)+,a1
DECO:               move.l   LOADSCREEN,a0
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
                    bne      DECO_ORD
                    move.b   (a0)+,d2
                    bne      NOT_CD_DECO
                    move.b   #$CD,d2
                    bra      DECO_ORD

NOT_CD_DECO:        bra      DECO_REP

DECO_ORD:           move.b   d2,(a1)
                    tst.w    FLAG
                    bne      ADD_LOTS
                    addq.w   #1,FLAG
                    addq.w   #1,a1
                    subq.w   #1,d1
                    beq      DONE_DECO
                    bra      DECO_LOOP

ADD_LOTS:           clr.w    FLAG
                    addq.w   #7,a1
                    subq.w   #1,d1
                    beq      DONE_DECO
                    bra      DECO_LOOP

DECO_REP:           move.w   d2,d3
                    and.w    #$7F,d3
                    tst.b    d2
                    bmi      USE_FF
                    clr.w    d2
                    bra      DECO_LOTS

USE_FF:             move.w   #-1,d2
DECO_LOTS:          move.b   d2,(a1)
                    tst.w    FLAG
                    bne      ADD_LOTS2
                    addq.w   #1,FLAG
                    addq.w   #1,a1
                    subq.w   #1,d1
                    beq      DONE_DECO
                    subq.b   #1,d3
                    bne      DECO_LOTS
                    bra      DECO_LOOP
ADD_LOTS2:          clr.w    FLAG
                    addq.w   #7,a1
                    subq.w   #1,d1
                    beq      DONE_DECO
                    subq.b   #1,d3
                    bne      DECO_LOTS
                    bra      DECO_LOOP
DONE_DECO:          lea      2(a2),a1
                    dbra     d0,DECO_THREE
                    rts

; -------------------------------------------

FLAG:               dc.w     0
XSPOT:              dc.w     0
OLDX1:              dc.w     0
OLDX2:              dc.w     0
RESTORE_X:          dc.w     0
SAVE_REL_XPOS:      dc.w     0
PLANESPOT:          dc.w     0
HOLEINDEX:          dc.w     0
FRAME_JET:          dc.w     0
FRAME_OFFSET:       dc.w     0,12,24,1920
FADE_MASKING_TABLE: dc.w     %1000000000000000
                    dc.w     %0000001000000000
                    dc.w     %0000000000010000
                    dc.w     %0100000000000000
                    dc.w     %0000000010000000
                    dc.w     %0000000000000010
                    dc.w     %0000010000000000
                    dc.w     %0001000000000000
                    dc.w     %0000000000000001
                    dc.w     %0010000000000000
                    dc.w     %0000000000001000
                    dc.w     %0000000100000000
                    dc.w     %0000000001000000
                    dc.w     %0000000000000100
                    dc.w     %0000100000000000
                    dc.w     %0000000000100000
TIT_NAME:           dc.b     'gfx/tit.pi1',0
JET_NAME:           dc.b     'gfx/jet.pi1',0
CRED_NAME:          dc.b     'gfx/obj.pi1',0
DOS_NAME:           dc.b     'dos.library',0
                    even
DOS_BASE:           dc.l     0
DOS_HANDLE:         dc.l     0

; -------------------------------------------

                    section  uninit_dats,bss_c

TEMP_MUSIC:         ds.w     1
REGS:               ds.b     14
REG7:               ds.b     1
                    even
SAVEINT6:           ds.l     1
MUSINF_0:           ds.l     5
                    ds.w     1
MUSINF_1:           ds.l     5
                    ds.w     1
MUSINF_2:           ds.l     5
                    ds.w     1
MUSINF_3:           ds.l     5
                    ds.w     1
RANDOM_AREA:        ds.b     8192
MUSIC_POINTER:      ds.w     1
MUSIC_DELAY:        ds.w     1
FRED:               ds.w     1
MASTER_ENABLE:      ds.w     2
TIT32K:             ds.l     1
JET32K:             ds.l     1
CRED32K:            ds.l     1
ONESCREEN:          ds.l     1
TWOSCREEN:          ds.l     1
LOADSCREEN:         ds.l     1
FREE_FLAG:          ds.w     1
MASK:               ds.w     4016
SHOOT_FLAG:         ds.w     1
RASTER_VALUE:       ds.l     1
SCREEN2:            ds.l     1
SCREEN1:            ds.l     1
COPPER1:            ds.l     1
COPPER2:            ds.l     1
COPPER_LIST2:       ds.b     (END_COPPER_LIST-COPPER_LIST)

                    end
