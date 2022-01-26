@ update menu
updateMenu:
	@ move cursor down
	lta keys
	and #$801 @ select, down
	beq :+

	@ clear previous cursor
	jsr clearMenuCursor

	@ advance cursor
	ltb #$05
	tba
	ltd menuCursor
	inc a
	mod b
	std menuCursor

	@ color current cursor
	jsr colorMenuCursor

	@ play beep
	ltx #sfxSelect
	jsr musicStart
:

	@ move cursor up
	lta keys
	and #$002 @ up
	beq :+

	@ clear previous cursor
	jsr clearMenuCursor

	@ advance cursor
	ltb #$05
	tba
	ltd menuCursor
	clc
	adc #$04
	mod b
	std menuCursor

	@ color current cursor
	jsr colorMenuCursor

	@ play beep
	ltx #sfxSelect
	jsr musicStart
:

	@ proceed
	lta keys
	and #$680 @ start, L, A
	beq :+++

	@ play beep
	ltx #sfxConfirm
	jsr musicStart

	@ start game
	lta #$00
	ltd menuCursor
	cmd #$03
	bcs :+

	@ generate level
	std level
	jsr generateField
	stz gameCursor

	@ show game scursor
	jsr showGameCursor

	@ switch to game
	ltd #%00000000
	std $4003
	ltd #$02
	std phase

	@ play game bgm
	ltx #bgmGame
	jsr musicStart
	rts
:
	@ show record table
	bne :+

	@ set difficulty to easy
	stz page
	stz level
	jsr createLeaderboard

	@ switch to records
	ltd #%00001100
	std $4003
	ltd #$01
	std phase
	rts
:
	@ show help
	stz helpPage
	jsr createHelp

	@ switch to help
	ltd #%00001100
	std $4003
	ltd #$01
	std phase
	ltd #$02
	std page
	rts
:
	rts

@ clear cursor color
clearMenuCursor:
	ltd menuCursor
	and #$07
	asl
	tax
	lta menuItemCycle, x
	sec
	sbc #$4002
	sta $4004
	ltd #" "
	std $4000

	lta menuItemCycle, x
	sta $4004
	ltx #$00
	txa
:
	std $4000
	inx
	cpx #$07
	bcc :-
	rts

@ color cursor
colorMenuCursor:
	ltd menuCursor
	and #$07
	asl
	tax
	lta menuItemCycle, x
	sec
	sbc #$4002
	sta $4004
	ltd #"@"
	std $4000

	lta menuItemCycle, x
	sta $4004
	ltx #$00
	txa
	ltd #$80
:
	std $4000
	inx
	cpx #$07
	bcc :-
	rts