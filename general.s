@ output number
@ a: value
outputNumber:
	ltb #10
	tay
	div b
	mod b
	ora #$30
	std $4000
	tya
	mod b
	ora #$30
	std $4000
	rts

@ output text
outputText:
	ltd x
	beq :+
	std $4000
	inx
	bra outputText
:
	rts

@ output name
outputName:
	lty #$00
:
	ltd x
	std $4000
	inx
	iny
	cpy #12
	bcc :-
	rts

@ create background
@ a: addr
createBackground:
	@ copy tiles
	stx $4004
	phx
	ltd #$10
	lty #$00
:
	ltx #$00
:
	std $4000
	xor #$01
	inx
	cpx #40
	bcc :-
	xor #$02
	iny
	cpy #30
	bcc :--

	@ copy palette
	pla
	clc
	adc #$4000
	sta $4004
	ltx #$00
	ltd #$C0
:
	std $4000
	inx
	cpx #$4B0
	bcc :-
	rts

@ create window
@ x: addr, winw: width, winh: height
createWindow:
	@ upper part
	stx $4004
	phx
	phx
	ltd #$2C
	std $4000
	ltx #$00
	ltd #$28
:
	std $4000
	inx
	cpx winw
	bcc :-
	ltd #$2D
	std $4000

	@ middle part
	lty #$00
:
	pla
	clc
	adc #40
	pha
	sta $4004
	ltd #$29
	std $4000
	ltd #$20
	ltx #$00
:
	std $4000
	inx
	cpx winw
	bcc :-
	ltd #$2A
	std $4000
	iny
	cpy winh
	bcc :--

	@ lower part
	pla
	clc
	adc #40
	pha
	sta $4004
	ltd #$2E
	std $4000
	ltx #$00
	ltd #$2B
:
	std $4000
	inx
	cpx winw
	bcc :-
	ltd #$2F
	std $4000

	@ palette
	pla
	pla
	clc
	adc #$4000
	pha
	lta winw
	inc a
	inc a
	sta winw
	lta winh
	inc a
	inc a
	sta winh
	lty #$00
:
	ltx #$00
	pla
	sta $4004
	clc
	adc #40
	pha
	lta #$00
:
	std $4000
	inx
	cpx winw
	bcc :-
	iny
	cpy winh
	bcc :--
	pla
	rts

@ create minefield background
createBoard:
	ltx #$8000
	jsr createBackground

	@ create status window
	lta #10
	sta winw
	lta #1
	sta winh
	lta statsAddr
	sec
	sbc #42
	tax
	jsr createWindow

	@ create status text
	ltx statsAddr
	dex
	stx $4004
	ltx #labelStatus
	jsr outputText

	@ create board window
	lta fieldW
	asl
	sta winw
	lta fieldH
	asl
	sta winh
	lta fieldAddr
	sec
	sbc #41
	tax
	jsr createWindow

	@ create board cells
	ltx #$00
:
	txa
	std buffer
	phx
	jsr updateCell
	plx
	inx
	cpx fieldSize
	bcc :-
	rts