@ update pause
updatePause:
	@ update time
	ltd firstClick
	bne :+
	jsr updateTime
:

	@ show pause menu
	lta #$00
	ltd pauseScroll
	beq :+
	sec
	sbc #PAUSE_SCROLL_SPEED
	std pauseScroll
	sta $400C
:

	@ move cursor down
	lta keys
	and #$801 @ select, down
	beq :+

	@ clear previous cursor
	jsr clearPauseCursor

	@ advance cursor
	ltb #$05
	tba
	ltd pauseCursor
	inc a
	mod b		
	std pauseCursor

	@ color current cursor
	jsr colorPauseCursor

	@ play beep
	ltx #sfxSelect
	jsr musicStart
:
	
	@ move cursor up
	lta keys
	and #$002 @ up
	beq :+

	@ clear previous cursor
	jsr clearPauseCursor

	@ advance cursor
	ltb #$05
	tba
	ltd pauseCursor
	clc
	adc #$04
	mod b
	std pauseCursor

	@ color current cursor
	jsr colorPauseCursor

	@ play beep
	ltx #sfxSelect
	jsr musicStart
:

	@ check escape
	lta keys
	and #$130 @ R, X, Y
	beq :+

	@ switch to game
	ltd #$02
	std phase

	@ play beep
	ltx #sfxFlagRemove
	jsr musicStart
:

	@ proceed
	lta keys
	and #$680 @ start, L, A
	beq :+++++

	@ resume game
	ltd pauseCursor
	cmd #$00
	bne :+

	@ switch to game
	ltd #$02
	std phase

	@ play beep
	ltx #sfxFlagRemove
	jsr musicStart
	bra :+++++
:

	@ load game
	ltd pauseCursor
	cmd #$01
	bne :+

	@ copy data
	jsr loadGame

	@ switch to game
	ltd #$02
	std phase
	bra :++++
:
	@ save game
	ltd pauseCursor
	cmd #$02
	bne :+

	@ play beep
	ltx #sfxConfirm
	jsr musicStart

	jsr saveGame
	bra :+++
:
	@ reset game
	ltd pauseCursor
	cmd #$03
	bne :+

	@ generate new map
	jsr generateField
	stz gameCursor

	@ switch to game
	ltd #$02
	std phase

	@ play beep
	ltx #sfxConfirm
	jsr musicStart
:

	@ quit game
	ltd pauseCursor
	cmd #$04
	bne :+

	@ hide pause
	lta #$78
	sta $400C
	std pauseScroll

	@ hide game cursor
	jsr hideGameCursor

	@ switch to menu
	ltd #%00000100
	std $4003
	ltd #$00
	std phase

	@ play menu bgm
	ltx #bgmMenu
	jsr musicStart

	@ play beep
	ltx #sfxFlagRemove
	jsr musicStart
:
	rts

@ clear cursor color
clearPauseCursor:
	ltd pauseCursor
	and #$07
	asl
	tax
	lta pauseItemCycle, x
	sec
	sbc #$4002
	sta $4004
	ltd #" "
	std $4000

	lta pauseItemCycle, x
	sta $4004
	ltx #$00
	ltd #$90
:
	std $4000
	inx
	cpx #$06
	bcc :-
	rts

@ color cursor
colorPauseCursor:
	ltd pauseCursor
	and #$07
	asl
	tax
	lta pauseItemCycle, x
	sec
	sbc #$4002
	sta $4004
	ltd #"@"
	std $4000

	lta pauseItemCycle, x
	sta $4004
	ltx #$00
	ltd #$A0
:
	std $4000
	inx
	cpx #$06
	bcc :-
	rts

@ default save values
defaultSave:
	@ check validity sign
	ltd $7017
	cmd #$D4
	bne :+
	rts
:
	
	@ copy default data
	lta #$6000
	sta BUF
	lty #$00
:
	ltx #$00
:
	ltd defaultSaveData, x
	phy
	lty BUF
	std y
	iny
	sty BUF
	ply
	inx
	cpx #$10
	bcc :-
	iny
	cpy #$1E
	bcc :--

	@ verify data
	ltd #$D4
	std $7017
	rts

@ load game
loadGame:
	@ verify savesate
	ltd $7016
	cmd #$FE
	beq :+

	@ play beep
	ltx #sfxCancel
	jsr musicStart
	rts
:
	@ play beep
	ltx #sfxConfirm
	jsr musicStart

	@ copy variables
	ltx #$00
:
	ltd $7000, x
	std timer, x
	inx
	cpx #$16
	bcc :-

	@ copy arrays
	ltx #$00
:
	ltd $7060, x
	std mineField, x
	inx
	cpx #$2A0
	bcc :-

	@ copy background
	jsr createBoard

	@ update flag count
	ltx statsAddr
	stx $4004
	lta #$00
	ltd flagsLeft
	jsr outputNumber

	@ update timer
	lta statsAddr
	clc
	adc #$04
	sta $4004
	lta #$00
	ltd timeMin
	jsr outputNumber
	ltd #":"
	std $4000
	lta #$00
	ltd timeSec
	jsr outputNumber

	@ update game cursor
	jsr updateGameCursor

	@ game is loaded
	ltd #$01
	std gameLoaded
	rts

@ save game
saveGame:
	@ copy variables
	ltx #$00
:
	ltd timer, x
	std $7000, x
	inx
	cpx #$16
	bcc :-

	@ store map seed
	lta seed
	sta $701E
	
	@ verification byte
	ltd #$FE
	std $7016

	@ copy arrays
	ltx #$00
:
	ltd mineField, x
	std $7060, x
	inx
	cpx #$2A0
	bcc :-
	rts