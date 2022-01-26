@ update game
updateGame:
	@ update patterns
	jsr updatePatternPalette

	@ game over state
	ltd gameOver
	beq :++++

	@ check revealed tile count
	ltd tileReveal
	cmd fieldSize
	bcs :+

	@ reveal hidden tiles
	lta #$00
	ltd tileReveal
	tax
	ltd #$01
	std gameField, x
	inx
	std gameField, x
	inx
	std gameField, x
	inx
	std gameField, x

	ltd tileReveal
	std buffer

	jsr updateCell
	inc tileReveal
	inc buffer

	jsr updateCell
	inc tileReveal
	inc buffer

	jsr updateCell
	inc tileReveal
	inc buffer

	jsr updateCell
	inc tileReveal
	inc buffer

	@ check for ending
	ltd tileReveal
	cmd fieldSize
	bcc :+++

	@ create game over label
	ltx #labelLose
	jsr launchGameOver
	rts

:
	@ check for any key press
	lta keys
	beq :++

	@ place run on leaderboard
	ltd gameOver
	cmd #$02
	bne :+
	ltd gameLoaded
	bne :+
	jsr placeOnLeaderboard
	bcs :++
:

	@ play game bgm
	ltx #bgmGame
	jsr musicStart

	@ start new game
	stz gameCursor
	jsr generateField
	jsr showGameCursor
:
	rts
:

	@ update time
	ltd firstClick
	bne :+
	jsr updateTime

	@ check for timeup
	lta timeMin
	cmp #$3B3B
	bne :+

	@ trigger timeup
	ltd #$02
	std gameOver
	ltd fieldSize
	std tileReveal

	@ play beep
	ltx #bgmLose
	jsr musicStart

	@ hide game cursor
	jsr hideGameCursor

	@ output text
	ltx #labelTime
	jsr launchGameOver
:

	@ hide pause menu
	lta #$00
	ltd pauseScroll
	cmd #$78
	bcs :+
	clc
	adc #PAUSE_SCROLL_SPEED
	std pauseScroll
	sta $400C
:

	@ move cursor left
	lta keys
	and #$008
	beq :+
	
	ltd gameCursor
	ltb fieldW
	mod b
	clc
	adc fieldW
	dec a
	mod b
	tax
	ltd gameCursor
	div b
	mul b
	tab
	txa
	clc
	adc b
	std gameCursor
:

	@ move cursor right
	lta keys
	and #$004
	beq :+
	
	ltd gameCursor
	ltb fieldW
	mod b
	inc a
	mod b
	tax
	ltd gameCursor
	div b
	mul b
	tab
	txa
	clc
	adc b
	std gameCursor
:

	@ move cursor down
	lta keys
	and #$001
	beq :+
	
	ltd gameCursor
	ltb fieldW
	div b
	inc a
	ltb fieldH
	mod b
	ltb fieldW
	mul b
	tax
	ltd gameCursor
	mod b
	tab
	txa
	clc
	adc b
	std gameCursor
:

	@ move cursor up
	lta keys
	and #$002
	beq :+
	
	ltd gameCursor
	ltb fieldW
	div b
	clc
	adc fieldH
	dec a
	ltb fieldH
	mod b
	ltb fieldW
	mul b
	tax
	ltd gameCursor
	mod b
	tab
	txa
	clc
	adc b
	std gameCursor
:

	@ check pause
	lta keys
	and #$D10 @ start, select, R, Y
	beq :+

	@ clear previous cursor
	jsr clearPauseCursor

	@ reset pause cursor
	stz pauseCursor

	@ color current cursor
	jsr colorPauseCursor

	@ switch to pause
	ltd #$03
	std phase

	@ play beep
	ltx #sfxFlagSet
	jsr musicStart
:

	@ open cell
	lta keys
	and #$280 @ L, A
	beq :+
	jsr openCell
:

	@ flag cell
	lta keys
	and #$040 @ B
	beq :+
	jsr flagCell
:

	@ chain cell
	lta keys
	and #$020 @ X
	beq :+
	jsr chainCell
:

	@ update cursor
	jsr updateGameCursor
	rts

@ show game cursor
showGameCursor:
	lta #$8424
	sta SPR + $200
	inc a
	sta SPR + $202
	inc a
	sta SPR + $204
	inc a
	sta SPR + $206
	rts

@ hide game cursor
hideGameCursor:
	lta #$0000
	sta SPR + $200
	sta SPR + $202
	sta SPR + $204
	sta SPR + $206
	rts

@ update game cursor
updateGameCursor:
	ltd level
	and #$03
	asl
	tax
	ltd gameCursor
	ltb fieldW
	mod b
	asl
	asl
	asl
	asl
	adc boardCursorX, x
	sta SPR + $000
	lta #$00
	ltd gameCursor
	div b
	mod b
	asl
	asl
	asl
	asl
	adc boardCursorY, x
	sta SPR + $100
	lta SPR + $000
	sta SPR + $004
	clc
	adc #$08
	sta SPR + $002
	sta SPR + $006
	lta SPR + $100
	sta SPR + $102
	clc
	adc #$08
	sta SPR + $104
	sta SPR + $106
	rts

@ open cell
openCell:
	@ test first click
	ltd firstClick
	beq :++

	@ check for bomb
	ltd gameCursor
	and #$FF
	tax
	ltd mineField, x
	cmd #$09
	bne :+

	@ switch bomb's cell
	stz mineField, x
	ltd bombCount
	and #$FF
	tax
	ltd cellArray, x
	tax
	ltd #$09
	std mineField, x

:
	@ generate numbers
	jsr generateNumbers
	stz firstClick
:

	@ check flag
	lta #$00
	ltd gameCursor
	std buffer
	tax
	ltd gameField, x
	bne :++

	@ open cell
	dec tilesLeft
	lta #$00
	ltd gameCursor
	std buffer
	tax
	ltd #$01
	std gameField, x
	jsr updateCell

	@ check for bomb
	lta #$00
	ltd gameCursor
	std buffer
	tax
	ltd mineField, x
	cmd #$09
	bne :+

	@ trigger game over
	ltd #$01
	std gameOver

	@ play beep
	ltx #bgmLose
	jsr musicStart

	@ play beep
	ltx #bgmLose
	jsr musicStart

	@ hide game cursor
	jsr hideGameCursor
	bra :++
:
	@ check for empty tile
	cmd #$00
	bne :+

	@ open neighbor tiles
	ltd gameCursor
	std buffer
	jsr openNeighbors

:
	@ check for victory
	ltd tilesLeft
	bne :+

	@ check for game over
	ltd gameOver
	bne :+

	@ trigger victory
	ltd #$02
	std gameOver
	ltd fieldSize
	std tileReveal

	@ play beep
	ltx #bgmWin
	jsr musicStart

	@ hide game cursor
	jsr hideGameCursor

	@ output text
	ltx #labelWin
	jsr launchGameOver
:

	@ play beep
	ltx #sfxSelect
	jsr musicStart
	rts

@ flag cell
flagCell:
	@ check for unknown
	ltd gameCursor
	std buffer
	and #$FF
	tax
	ltd gameField, x
	tab
	bne :+

	@ check if any flags left
	ltd flagsLeft
	beq :+

	@ place flag
	ltd #$02
	std gameField, x
	dec flagsLeft
	jsr updateCell

	@ play beep
	ltx #sfxFlagSet
	jsr musicStart
	bra :++
:

	@ check for flag
	cmd #$02
	bne :+

	@ remove flag
	stz gameField, x
	inc flagsLeft
	jsr updateCell

	@ play beep
	ltx #sfxFlagRemove
	jsr musicStart
:

	@ update flag count
	ltx statsAddr
	stx $4004
	lta #$00
	ltd flagsLeft
	jsr outputNumber
	rts

@ chain cell
chainCell:
	@ check tile state
	lta #$00
	ltd gameCursor
	tax
	ltd gameField, x
	cmd #$01
	beq :+
	rts

:
	@ check tile number
	ltd mineField, x
	std BUF
	ltd gameCursor
	std buffer
	jsr getFlagCount
	cmd BUF
	beq :+
	rts

:
	@ open neighbor tiles
	jsr openNeighbors 

	@ play beep
	ltx #sfxSelect
	jsr musicStart
	rts

@ open all neighbor tiles
openNeighbors:
	ltd level
	and #$FF
	asl
	tax
	ltx neighborListRef, x
	stx ADDR

	lty #$00
:
	@ store buffer
	ltd buffer
	phd

	@ horizontal overflow check
	ltb fieldW
	ltd buffer
	and #$FF
	mod b
	clc
	adc offsetX, y
	cmd fieldW
	bcs :+

	@ general overflow check
	tya
	adc ADDR
	tax
	ltd buffer
	and #$FF
	clc
	adc x
	and #$FF
	cmd fieldSize
	bcs :++

	@ check for unopened cell
	and #$FF
	tax
	ltd gameField, x
	bne :++

	@ open cell
	dec tilesLeft
	ltd #$01
	std gameField, x
	tya
	adc ADDR
	tax
	ltd buffer
	and #$FF
	clc
	adc x
	and #$FF
	std buffer
	phy
	jsr updateCell
	ply

	@ check for bomb
	lta #$00
	ltd buffer
	tax
	ltd mineField, x
	cmd #$09
	bne :+

	@ trigger game over
	ltd #$01
	std gameOver

	@ play beep
	ltx #bgmLose
	jsr musicStart

	jsr hideGameCursor
	bra :++

:
	@ check for empty tile
	cmd #$00
	bne :+

	@ open neighbors
	phy
	jsr openNeighbors
	ply

:
	@ restore buffer
	pld
	std buffer

	@ advance loop
	iny
	cpy #$08
	bne :---

	@ check for victory
	ltd tilesLeft
	bne :+

	@ check for game over
	ltd gameOver
	bne :+

	@ trigger victory
	ltd #$02
	std gameOver
	ltd fieldSize
	std tileReveal

	@ play beep
	ltx #bgmWin
	jsr musicStart

	@ hide game cursor
	jsr hideGameCursor

	@ output text
	ltx #labelWin
	jsr launchGameOver
:
	rts

@ game over
launchGameOver:
	@ show label
	lta #$00
	ltd $00, x
	clc
	adc #GAME_LABEL
	sta BUF
	lta #$00
	ltd $01, x
	tab
	inx
	inx

	lta BUF
	sta $4004
	ltd #$2C
	std $4000
	ltd #$28
	lty #$00
:
	std $4000
	iny
	cpy b
	bcc :-
	ltd #$2D
	std $4000

	lta BUF
	clc
	adc #40
	sta $4004
	ltd #$29
	std $4000
	lty #$00
:
	ltd x
	std $4000
	inx
	iny
	cpy b
	bcc :-
	ltd #$2A
	std $4000

	lta BUF
	clc
	adc #80
	sta $4004
	ltd #$2E
	std $4000
	ltd #$2B
	lty #$00
:
	std $4000
	iny
	cpy b
	bcc :-
	ltd #$2F
	std $4000
	rts