@ generate field
generateField:
	@ store seed
	lta seed
	sta $701C

	@ load settings
	ltd level
	and #$FF
	asl
	tax
	lta boardStart, x
	sta fieldAddr
	lta boardStats, x
	sta statsAddr
	lta boardSize, x
	sta fieldSize
	lta boardWidth, x
	sta fieldW
	lta boardHeight, x
	sta fieldH
	lta boardBombs, x
	std bombCount
	std flagsLeft
	lta fieldSize
	sec
	sbc boardBombs, x
	std tilesLeft

	@ empty mine field & game field
	ltx #$00
:
	stz mineField, x
	stz gameField, x
	inx
	cpx fieldSize
	bne :-

	@ create board background
	jsr createBoard

	@ reset variables
	stz tileReveal
	stz gameOver
	stz gameLoaded
	ltd #$01
	std firstClick

	@ reset timer
	lta #$00
	sta timer
	std timeMin
	std timeSec

	@ update flag count
	ltx statsAddr
	stx $4004
	lta #$00
	ltd bombCount
	jsr outputNumber

	@ create reference array
	ltx #$00
:
	txa
	std cellArray, x
	inx
	cpx fieldSize
	bne :-

	@ shuffle reference array
	ltx #cellArray
	lty fieldSize
	jsr shuffle

	@ paste bombs
	ltx #$00
	txa
	ltd bombCount
	tab
:
	ltd cellArray, x
	tay
	ltd #$09
	std mineField, y
	inx
	cpx b
	bne :-
	rts

@ generate numbers
generateNumbers:
	ltx #$00
:
	ltd mineField, x
	cmd #$09
	beq :+
	txa
	std buffer
	phx
	jsr getMineCount
	plx
	std mineField, x
:
	inx
	cpx fieldSize
	bne :--
	rts

@ count surrounding mines
@ buffer: cell ID
getMineCount:
	ltd level
	and #$FF
	asl
	tax
	ltx neighborListRef, x

	lty #$00
	ltb fieldW
	phy
:
	@ horizontal overflow check
	ltd buffer
	and #$FF
	mod b
	clc
	adc offsetX, y
	cmd fieldW
	bcs :+

	@ general overflow check
	ltd buffer
	and #$FF
	clc
	adc x
	cmd fieldSize
	bcs :+

	@ check for mine
	phx
	and #$FF
	tax
	ltd mineField, x
	plx
	cmd #$09
	bne :+
	pla
	inc a
	pha
:
	@ advance loop
	inx
	iny
	cpy #$08
	bne :--
	pla
	rts

@ count surrounding flags
@ buffer: cell ID
getFlagCount:
	ltd level
	and #$FF
	asl
	tax
	ltx neighborListRef, x

	lty #$00
	ltb fieldW
	phy
:
	@ horizontal overflow check
	ltd buffer
	and #$FF
	mod b
	clc
	adc offsetX, y
	cmd fieldW
	bcs :+

	@ general overflow check
	ltd buffer
	and #$FF
	clc
	adc x
	cmd fieldSize
	bcs :+

	@ check for mine
	phx
	and #$FF
	tax
	ltd gameField, x
	plx
	cmd #$02
	bne :+
	pla
	inc a
	pha
:
	@ advance loop
	inx
	iny
	cpy #$08
	bne :--
	pla
	rts