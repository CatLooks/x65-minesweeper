@ ROM header
header:
	.byte "x65", $00
	.word $02
	.byte $03
	.byte $01

@ root bank
PRG:
	.fpos $0010
	.spos $F000
	.vpos $0000

	@ variables
	.def word BUF
	.def word ADDR

	.def byte device

	.def word seed
	.def word off1
	.def word off2
	.def byte buf

	@ ============ SAVE DATA ============
	.def word timer
	.def byte timeMin
	.def byte timeSec

	.def byte gameCursor

	.def byte bombCount
	.def word fieldAddr
	.def word statsAddr

	.def word fieldSize
	.def word fieldW
	.def word fieldH
	.def byte level

	.def byte flagsLeft
	.def byte tilesLeft
	.def byte firstClick
	.def byte gameOver
	.def byte tileReveal
	@ ===================================

	.def byte gameLoaded

	.def word ch0_timer
	.def word ch1_timer
	.def word ch2_timer
	.def word ch3_timer

	.def word ch0_ptr
	.def word ch1_ptr
	.def word ch2_ptr
	.def word ch3_ptr

	.def word musicTimer
	.def word musicTempo

	.def word keys
	.def word keyBuf
	.def byte phase
	.def byte page

	.def byte pauseScroll

	.def byte menuCursor
	.def byte nameCursor
	.def byte pauseCursor

	.def byte buffer
	.def word tileAddr

	.def word patternPalette $08
	.def byte patternTimer

	.def word winw
	.def word winh

	.def byte nameBuffer $0C
	.def byte nameBufPos
	.def byte leadIndex

	.def word helpTimer
	.def word helpPtr
	.def byte helpPage

	.def byte newLine

	.def byte mineField $E0
	.def byte gameField $E0
	.def byte cellArray $E0

	.vpos $2000
	.def byte SPR $300

	@ note macros
	.lib "freqs.s"

	@ macros
	.set TIMER_SPEED 60
	.set PAUSE_SCROLL_SPEED $06
	.set PATTERN_MOVE_SPEED $04

	.set START_TITLE $C94E
	.set START_MODE1 $CA19
	.set START_MODE2 $CA69
	.set START_MODE3 $CAB9
	.set START_TIMES $CB09
	.set START_GUIDE $CB59

	.set NAME_INPUT $9125
	.set NAME_TEXT  $914E
	.set NAME_KEYS  $919A
	.set NAME_NAME  $9129

	.set PAUSE_TITLE $E029
	.set PAUSE_FIELD $E0CB
	.set PAUSE_GLOAD $E11B
	.set PAUSE_GSAVE $E16B
	.set PAUSE_RESET $E1BB
	.set PAUSE_ABORT $E20B

	.set GAME_LABEL   $8200
	.set HELP_PAGE    $988C
	.set HELP_FIELD   $990C

	.set LEAD_DIFF_WIN  $9BCA
	.set LEAD_DIFF_NAME $9BF3
	.set LEAD_TABLE     $9880
	.set LEAD_CAPTION   $9885

@ empty IRQ
irq:
	rti

@ frame subroutines
.lib "menu.s"
.lib "records.s"
.lib "game.s"
.lib "pause.s"

@ music engine
.lib "music.s"

@ starting code
rst:
	@ initialize CPU
	sei
	clf
	ltx #$1000
	ltv x
	ltx #$1FFF
	txs

	@ load banks
	ltd #$01
	std $4016	@ bank 6 = $01
	dec a
	std $4017	@ bank 7 = $00
	std $4018	@ bank s = $00

	@ verify save data
	jsr defaultSave

	@ create name input screen
	jsr createNameInput

	@ load palettes
	ltx #$00
	stx $4004
:
	lta palettes, x
	sta $4000
	inx
	inx
	cpx #$200
	bcc :-

	@ load menu tiles
	ltx #$00
:
	phx
	stx BUF
	jsr updateMenuCell
	plx
	inx
	cpx #$12C
	bcc :-

	@ create start menu
	lta #14
	sta winw
	lta #16
	sta winh
	ltx #$88FC
	jsr createWindow

	@ create separator
	lta #$89C4
	sta $4004
	ltx #$00
:
	lta labelSeparator, x
	sta $4000
	inx
	inx
	cpx #$10
	bcc :-

	@ create menu labels
	lta #START_MODE1 - $4002
	sta $4004
	ltd #"@"
	std $4000
	ltx #$00
:
	phx
	lta startMenuAddrRef, x
	sta $4004
	ltx startMenuDataRef, x
	jsr outputText
	plx
	inx
	inx
	cpx #$1E
	bcc :-

	@ load pause tiles
	ltx #$A000
	stx $4004
	ltx #$00
	stx ADDR

	lty #$00
:
	ltx #$00
:
	phx
	ltx ADDR
	ltd pausemenu, x
	std $4000
	inx
	stx ADDR
	plx
	inx
	cpx #$0F
	bcc :-
	ltx #$00
	txa
:
	std $4000
	inx
	cpx #$19
	bcc :-
	iny
	cpy #$0E
	bcc :---
	ltx #$00
:
	lty #$00
	ltd #$20
:
	std $4000
	iny
	cpy #$0D
	bcc :-
	txa
	and #$01
	beq :+
	lta #$3E20
	bra :++
:
	lta #$3C5B
:
	sta $4000
	lty #$00
:
	stz $4000
	iny
	cpy #$19
	bcc :-
	inx
	cpx #$10
	bcc :-----

	@ load pause palette
	ltx #$E000
	stx $4004
	ltx #$00
	lta #$9090
:
	sta $4000
	inx
	inx
	cpx #$4B0
	bcc :-

	@ initial text highlight
	lty #START_TITLE
	sty $4004
	ltd #$80
	ltx #$00
:
	std $4000
	inx
	cpx #$0C
	bcc :-

	lty #START_MODE1
	sty $4004
	ltx #$00
:
	std $4000
	inx
	cpx #$09
	bcc :-

	lty #PAUSE_TITLE
	sty $4004
	ltd #$A0
	ltx #$00
:
	std $4000
	inx
	cpx #$0C
	bcc :-

	lty #PAUSE_FIELD
	sty $4004
	ltx #$00
:
	std $4000
	inx
	cpx #$06
	bcc :-

	@ cursor highlight
	ltd #%00000010
	std $4002

	lty #START_MODE1 - 2
	sty $4004
	ltd #$80
	ltx #$00
:
	std $4000
	inx
	cpx #$09
	bcc :-

	lty #PAUSE_FIELD - 2
	sty $4004
	ltd #$A0
	ltx #$00
:
	std $4000
	inx
	cpx #$09
	bcc :-

	@ setup background patterns
	ltx #$00
:
	lta palettes + $190, x
	sta patternPalette, x
	inx
	inx
	cpx #$10
	bcc :-
	stz patternTimer

	@ reset variables
	lta #$00
	sta timer
	sta musicTimer
	sta musicTempo

	sta ch0_timer
	sta ch1_timer
	sta ch2_timer
	sta ch3_timer

	sta ch0_ptr
	sta ch1_ptr
	sta ch2_ptr
	sta ch3_ptr

	sta keys
	sta keyBuf

	stz winw
	stz winw + 1
	stz winh
	stz winh + 1

	stz timeMin
	stz timeSec
	stz phase
	stz page
	stz menuCursor
	stz pauseCursor
	ltd #$78
	std pauseScroll

	@ reset sprites
	ltx #$00
:
	stz SPR
	inx
	cpx #$300
	bcc :-

	@ set sprite address
	lta #SPR
	sta $4006

	@ reset layer scrolling
	stz $4008
	stz $400A
	stz $400E
	lta #$78
	sta $400C

	@ enable APU
	ltd #%11110000
	std $5040

	@ start menu bgm
	ltx #bgmMenu
	jsr musicStart

	@ enable GPU
	ltd #%00000100
	std $4003
	ltd #%11110000
	std $4002
	
	@ do nothing
infloop:
	wai
	bra infloop

@ NMI loop
nmi:
	@ disable nmi
	ltd #%01110000
	std $4002

	@ halt for a moment
	ltx #$00
:
	inx
	cpx #$80
	bcc :-

	@ update key presses
	jsr updateInput

	@ enter phase
	ltd phase
	cmd #$00
	bne :+
	jsr updateMenu
	bra :++++
:
	cmd #$01
	bne :+
	jsr updateInfo
	bra :+++
:
	cmd #$02
	bne :+
	jsr updateGame
	bra :++
:
	jsr updatePause
:

	@ update music
	jsr musicPlay

	@ enable nmi
	ltd #%11110000
	std $4002
	rti

@ update joystick
updateInput:
	@ update input device
	lta $5000
	rol
	rol
	and #$01
	std device

	@ update button presses
	lta $5000
	and keyBuf
	sta keys
	lta $5000
	xor #$FFFF
	sta keyBuf
	rts

@ update time
updateTime:
	@ tick timer
	ltb #TIMER_SPEED
	lta timer
	inc a
	mod b
	sta timer
	bcc :+
	@ update in-game time
	ltb #60
	ltd timeSec
	inc a
	mod b
	std timeSec
	php
	tax
	lta statsAddr
	clc
	adc #$07
	sta $4004
	ltb #10
	txa
	div b
	ora #$30
	std $4000
	txa
	mod b
	ora #$30
	std $4000
	plp
	bcc :+
	ltb #60
	tba
	ltd timeMin
	inc a
	mod b
	std timeMin
	tax
	lta statsAddr
	clc
	adc #$04
	sta $4004
	ltb #10
	txa
	div b
	ora #$30
	std $4000
	txa
	mod b
	ora #$30
	std $4000
:
	rts

End1:
	.val End1

@ interrupt vectors
vectors:
	.fpos $100A
	.word irq
	.word rst
	.word nmi

@ bank 1
BNK1:
	@ code
	.fpos $1010
	.spos $E000

@ RNG
.lib "random.s"

@ general subroutines
.lib "general.s"

@ generator subroutines
.lib "generator.s"

@ display subroutines
.lib "display.s"

@ help data
.lib "help.s"

@ background music
.lib "bgm.s"

@ color palettes
palettes:
	.file "data-palettes.dat"

@ frequency table
freqTable:
	.word $001C, $001D, $001F, $0021, $0023, $0025, $0027, $0029
	.word $002C, $002E, $0031, $0034, $0037, $003A, $003E, $0041
	.word $0045, $0049, $004E, $0052, $0057, $005C, $0062, $0068
	.word $006E, $0075, $007B, $0083, $008B, $0093, $009C, $00A5
	.word $00AF, $00B9, $00C4, $00D0, $00DC, $00E9, $00F7, $0106
	.word $0115, $0126, $0137, $014A, $015D, $0172, $0188, $019F
	.word $01B8, $01D2, $01EE, $020B, $022A, $024B, $026E, $0293
	.word $02BA, $02E4, $0310, $033F, $0370, $03A4, $03DC, $0417

@ keyboard buttons
keyboardKeys:
	.byte "A", "B", "C", "D", "E", "F"
	.byte "G", "H", "I", "J", "K", "L"
	.byte "M", "N", "O", "P", "Q", "R"
	.byte "S", "T", "U", "V", "W", "X"
	.byte "Y", "Z", $40, $14, $15, $16
keyboardAddr:
	.word $91EC, $91EF, $91F2, $91F5, $91F8, $91FB
	.word $923C, $923F, $9242, $9245, $9248, $924B
	.word $928C, $928F, $9292, $9295, $9298, $929B
	.word $92DC, $92DF, $92E2, $92E5, $92E8, $92EB
	.word $932C, $932F, $9332, $9335, $9338, $933B

@ default save data
defaultSaveData:
	.byte "@           ", $3B, $3B, $3B, $00

@ text data
labelSeparator:
	.byte $3D, $2B, $2B, $2B, $2B, $5C, $2B, $2B, $2B, $2B, $5C, $2B, $2B, $2B, $2B, $3F
labelTitle:
	.byte "MINE SWEEPER", $00
labelAuthor:
	.byte "BY EAXSI", $00
labelLeaderboard:
	.byte "RECORDS", $00
labelManual:
	.byte "HELP", $00
labelWin:
	.byte $17, $08, "VICTORY", $5D
labelLose:
	.byte $18, $06, "DEFEAT"
labelTime:
	.byte $18, $06, "TIMEUP"
labelStatus:
	.byte "#00 !00:00", $00
labelName:
	.byte $5E, "NAME", $5F, $00
labelRecords:
	.byte $5E, "RECORD TABLE", $5F, $00
labelHelp:
	.byte $5E, "HELP", $5F, $00
labelPage:
	.byte "PAGE: X OF 6", $00
labelDifficulty:
	.byte "DIFFICULTY: ", $00
labelEasy:
	.byte "EASY", $00
labelNormal:
	.byte "NORMAL", $00
labelHard:
	.byte "HARD", $00
labelKeys:
	.byte "KEY BINDINGS", $00
labelA:
	.byte "OPEN CELL", $00
labelB:
	.byte "FLAG CELL", $00
labelX:
	.byte "QUICK OPEN", $00
labelY:
	.byte "PAUSE GAME", $00
labelSep:
	.byte " @ ", $00

@ help keys
keyA:
	.byte "XA"
keyB:
	.byte "ZB"
keyX:
	.byte "SX"
keyY:
	.byte "AY"

@ neighbor indexes
offsetX:
	.byte $01, $FF, $00, $01, $FF, $00, $01, $FF
neighbors1:
	.byte $01, $07, $08, $09, $F7, $F8, $F9, $FF
neighbors2:
	.byte $01, $0B, $0C, $0D, $F3, $F4, $F5, $FF
neighbors3:
	.byte $01, $11, $12, $13, $ED, $EE, $EF, $FF

@ field tiles
tileL:
	.byte $80, $C0, $C2, $C4, $C6, $C8, $CA, $CC, $CE, $8C, $84, $88
tileH:
	.byte $82, $E0, $E2, $E4, $E6, $E8, $EA, $EC, $EE, $8E, $86, $8A

@ boards data
boardStart:
	.word $814C, $80D0, $80A2
boardStats:
	.word $80D8, $8060, $8038
boardCursorX:
	.word $60, $40, $10, $E8
boardCursorY:
	.word $40, $28, $20, $38
boardSize:
	.word $40, $84, $D8
boardWidth:
	.word $08, $0C, $12
boardHeight:
	.word $08, $0B, $0C
boardBombs:
	.word $0A, $1B, $2E

@ start menu label address
startMenuAddrRef:
	.word START_TITLE - $4000
	.word START_TITLE - $4000 + $2A
	.word START_MODE1 - $4000
	.word START_MODE2 - $4000
	.word START_MODE3 - $4000
	.word START_TIMES - $4000
	.word START_GUIDE - $4000

@ start menu label data
startMenuDataRef:
	.word labelTitle
	.word labelAuthor
	.word labelEasy
	.word labelNormal
	.word labelHard
	.word labelLeaderboard
	.word labelManual

@ key binds list
keybindRef:
	.word labelA
	.word labelB
	.word labelX
	.word labelY

@ menu item cycle
menuItemCycle:
	.word START_MODE1
	.word START_MODE2
	.word START_MODE3
	.word START_TIMES
	.word START_GUIDE

@ pause item cycle
pauseItemCycle:
	.word PAUSE_FIELD
	.word PAUSE_GLOAD
	.word PAUSE_GSAVE
	.word PAUSE_RESET
	.word PAUSE_ABORT

@ difficulty labels
difficultyListRef:
	.word labelEasy
	.word labelNormal
	.word labelHard

@ neighbor offsets
neighborListRef:
	.word neighbors1
	.word neighbors2
	.word neighbors3

End2
	.val End2

@ backgrounds
	.fpos $1E12
	.spos $EE02
startmenu:
	.file "data-startmenu.dat"
pausemenu:
	.file "data-pausemenu.dat"

@ DSD ROM
DSD:
	.fpos $2010
	.file "sound-square.dat"
	.file "sound-triangle.dat"
	.file "sound-trumpet.dat"

@ CHR ROM
CHR:
	.file "graphics.chr"