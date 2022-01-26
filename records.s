@ create name input table
createNameInput:
	ltx #$9000
	jsr createBackground

	@ create display
	lta #12
	sta winw
	lta #1
	sta winh
	ltx #NAME_INPUT
	jsr createWindow

	@ create keyboard
	lta #18
	sta winw
	lta #11
	sta winh
	ltx #NAME_KEYS
	jsr createWindow

	@ create label
	lta #NAME_NAME
	sta $4004
	ltx #labelName
	jsr outputText

	@ create keys
	stz BUF
	stz BUF + 1
	lty #$00
:
	ltx #$00
:	
	phx
	phy
	lta BUF
	tax
	inc a
	sta BUF
	txa
	asl
	tay
	lta keyboardAddr, y
	sta $4004
	ltd keyboardKeys, x
	std $4000
	ply
	plx
	inx
	cpx #$06
	bcc :-
	iny
	cpy #$05
	bcc :--

	@ reset variables
	stz nameCursor
	rts

@ create leaderboard
createLeaderboard:
	ltx #$9800
	jsr createBackground

	@ create label
	ltd level
	cmd #$01
	bne :+
	lta #18
	sta winw
	ltx #LEAD_DIFF_WIN
	lty #LEAD_DIFF_NAME
	phy
	bra :++
:
	lta #16
	sta winw
	ltx #LEAD_DIFF_WIN + 1
	lty #LEAD_DIFF_NAME + 1
	phy
:
	lta #1
	sta winh
	jsr createWindow
	ply
	sty $4004

	@ label caption
	ltx #labelDifficulty
	jsr outputText

	lta #$00
	ltd level
	asl
	tax
	ltx difficultyListRef, x
	jsr outputText

	@ create table
	lta #22
	sta winw
	lta #19
	sta winh
	ltx #LEAD_TABLE
	jsr createWindow

	@ table caption
	ltx #LEAD_CAPTION
	stx $4004
	ltx #labelRecords
	jsr outputText

	@ show table contents
	lta #$00
	ltd level
	sta BUF
	ltx #LEAD_TABLE + 41
	phx
	ltx #$00
:
	@ change position
	pla
	sta $4004
	clc
	adc #80
	pha

	@ get info address
	ltd level
	and #$03
	ltb #$0A
	mul b
	tab
	txa
	clc
	adc b
	asl
	asl
	asl
	asl
	clc
	adc #$6000
	tay
	phx
	phy

	@ draw rating
	txa
	inc a
	and #$FF
	jsr outputNumber
	ltd #$17
	std $4000
	ltd #$20
	std $4000

	@ draw name
	plx
	phx
	jsr outputName
	ltd #$20
	std $4000

	@ draw time
	pla
	clc
	adc #$0C
	tax
	ltd x
	and #$FF
	jsr outputNumber
	ltd #":"
	std $4000
	inx
	ltd x
	jsr outputNumber
	plx

	@ advance loop
	inx
	cpx #$0A
	bcc :-
	pla

	@ copy palette
	lta #LEAD_TABLE + 45 + $4000
	pha
	lty #$00
:
	pla
	sta $4004
	clc
	adc #80
	pha
	ltx #$00
	lta #$8080
:
	sta $4000
	inx
	cpx #$06
	bcc :-
	iny
	cpy #$0A
	bcc :--
	pla
	rts

@ create help page
createHelp:
	ltx #$9800
	jsr createBackground

	@ create window
	lta #34
	sta winw
	lta #24
	sta winh
	ltx #$9852
	jsr createWindow

	@ create outline
	ltx #$98A2
	stx $4004
	ltd #$3D
	std $4000
	lta #$2B2B
	ltx #$00
:
	sta $4000
	inx
	cpx #$03
	bcc :-
	ltx #$00
:
	ltd #$5C
	std $4000
	lta #$2B2B
	sta $4000
	sta $4000
	sta $4000
	inx
	cpx #$04
	bcc :-
	ltd #$3F
	std $4000

	@ create labels
	lta #$9861
	sta $4004
	ltx #labelHelp
	jsr outputText

	lta #$9886
	sta $4004
	ltx #labelPage
	jsr outputText

	@ fill page id
	ltx #HELP_PAGE
	stx $4004
	ltd helpPage
	clc
	adc #$31
	std $4000

	@ highlight first row
	ltx #$D8F4
	stx $4004
	ltx #$00
	ltd #$80
:
	std $4000
	inx
	cpx #$16
	bcc :-

	@ fill page text
	ltd helpPage
	and #$FF
	asl
	tax
	ltx helpRef, x
	beq :+
	jsr outputPage
:

	@ setup preview
	ltx #HELP_FIELD + 41
	stx fieldAddr
	lta #3
	sta fieldW
	sta fieldH

	@ create preview
	ltd helpPage
	and #$FF
	asl
	tax
	ltx previewRef, x
	beq :+
	phx

	@ create preview field
	lta #6
	sta winw
	sta winh
	ltx #HELP_FIELD
	jsr createWindow

	@ show cursor
	ltd #$03
	std level
	jsr showGameCursor
	plx

	@ load preview
	jsr previewReset
	rts
:
	@ create keybinds page
	lty #$98F5
	sty $4004
	phy
	ltx #labelKeys
	jsr outputText

	@ print keybindings
	lty #$00
:
	pla
	clc
	adc #80
	sta $4004
	pha
	tya
	asl
	pha
	tab
	ltd device
	adc b
	tax
	ltd keyA, x
	std $4000

	ltx #labelSep
	jsr outputText

	plx
	ltx keybindRef, x
	jsr outputText

	iny
	cpy #$04
	bcc :-
	pla

	@ hide cursor
	jsr hideGameCursor
	rts

@ update leaderboard
updateLeaderboard:
	@ switch to next leaderboard
	lta keys
	and #$184 @ R, A, right
	beq :+
	ltb #$03
	tba
	ltd level
	inc a
	mod b
	std level
	jsr createLeaderboard

	@ play beep
	ltx #sfxSelect
	jsr musicStart
	rts
:

	@ switch to prev leaderboard
	lta keys
	and #$248 @ L, B, left
	beq :+
	ltb #$03
	tba
	ltd level
	inc a
	inc a
	mod b
	std level
	jsr createLeaderboard

	@ play beep
	ltx #sfxSelect
	jsr musicStart
	rts
:

	@ exit to menu
	lta keys
	and #$C30
	beq :+
	stz phase
	ltd #%00000100
	std $4003

	@ play beep
	ltx #sfxFlagRemove
	jsr musicStart
	rts
:
	rts

@ update input page
updateInputPage:
	@ press button
	lta keys
	and #$A80
	beq :+
	jsr namePress
:

	@ erase character
	lta keys
	and #$140
	beq :+
	jsr nameErase
:

	@ proceed
	lta keys
	and #$400
	beq :+
	jsr insertRecord
:

	@ move cursor down
	lta keys
	and #$001
	beq :+

	@ clear previous cursor
	jsr clearNameCursor

	@ move cursor
	lta #$00
	ltd nameCursor
	clc
	adc #6
	ltb #30
	mod b
	std nameCursor

	@ color current cursor
	jsr colorNameCursor

	@ play beep
	ltx #sfxSelect
	jsr musicStart
:
	@ move cursor up
	lta keys
	and #$002
	beq :+

	@ clear previous cursor
	jsr clearNameCursor

	@ move cursor
	lta #$00
	ltd nameCursor
	clc
	adc #24
	ltb #30
	mod b
	std nameCursor

	@ color current cursor
	jsr colorNameCursor

	@ play beep
	ltx #sfxSelect
	jsr musicStart
:
	@ move cursor right
	lta keys
	and #$004
	beq :+

	@ clear previous cursor
	jsr clearNameCursor

	@ move cursor
	lta #$00
	ltd nameCursor
	clc
	adc #1
	ltb #30
	mod b
	std nameCursor

	@ color current cursor
	jsr colorNameCursor

	@ play beep
	ltx #sfxSelect
	jsr musicStart
:
	@ move cursor left
	lta keys
	and #$008
	beq :+

	@ clear previous cursor
	jsr clearNameCursor

	@ move cursor
	lta #$00
	ltd nameCursor
	clc
	adc #29
	ltb #30
	mod b
	std nameCursor

	@ color current cursor
	jsr colorNameCursor

	@ play beep
	ltx #sfxSelect
	jsr musicStart
:
	rts

@ update help page
updateHelpPage:
	@ view next page
	lta keys
	and #$184
	beq :+
	lta #$00
	ltb #$06
	ltd helpPage
	inc a
	mod b
	std helpPage
	jsr createHelp

	@ play beep
	ltx #sfxSelect
	jsr musicStart
:

	@ view next page
	lta keys
	and #$248
	beq :+
	lta #$00
	ltb #$06
	ltd helpPage
	clc
	adc #$05
	mod b
	std helpPage
	jsr createHelp

	@ play beep
	ltx #sfxSelect
	jsr musicStart
:

	@ exit to menu
	lta keys
	and #$C30
	beq :+

	@ hide cursor
	jsr hideGameCursor

	@ switch to menu
	ltd #%00000100
	std $4003
	ltd #$00
	std phase

	@ play beep
	ltx #sfxFlagRemove
	jsr musicStart
	rts
:
	
	@ update preview
	jsr previewProcess 

	@ update cursor
	jsr updateGameCursor
	rts

@ update info page
updateInfo:
	@ update pattern palette
	jsr updatePatternPalette

	@ update page
	ltd page
	bne :+
	jsr updateLeaderboard
	rts
:
	cmd #$01
	bne :+
	jsr updateInputPage
	rts
:
	jsr updateHelpPage
	rts

@ place run on leaderboard
placeOnLeaderboard:
	@ calculate leaderboard position
	ltd #$FF
	std leadIndex
	ltx #$00
:
	jsr saveDataAddress
	ltd $0C, y
	tdh
	ltd $0D, y
	tab
	ltd timeMin
	tdh
	ltd timeSec
	cmp b
	bcs :+
	txa
	std leadIndex
	bra :++
:
	inx
	cpx #$0A
	bcc :--
	clc
	rts
:

	@ reset naming buffer
	ltx #$00
	ltd #$20
:
	std nameBuffer, x
	inx
	cpx #$0C
	bcc :-

	@ update display
	lta #NAME_TEXT
	sta $4004
	ltx #nameBuffer
	jsr outputName

	@ highlight first letter
	stz nameCursor
	stz nameBufPos
	jsr colorNameCursor

	@ hide game cursor
	jsr hideGameCursor
	lta #$8000
	sta SPR + $000
	sta SPR + $002
	sta SPR + $004
	sta SPR + $006

	@ switch to name input
	ltd #%00001000
	std $4003
	ltd #$01
	std phase
	std page

	@ play menu bgm
	ltx #bgmMenu
	jsr musicStart
	sec
	rts

@ clear name cursor
clearNameCursor:
	lta #$00
	ltd nameCursor
	asl
	tax
	lta keyboardAddr, x
	ora #$4000
	sta $4004
	stz $4000
	rts

@ color name cursor
colorNameCursor:
	lta #$00
	ltd nameCursor
	asl
	tax
	lta keyboardAddr, x
	ora #$4000
	sta $4004
	ltd #$80
	std $4000
	rts

@ press button
namePress:
	@ check for backspace
	ltd nameCursor
	cmd #$1C
	bne :+
	jsr nameErase
	rts
:
	@ check for return
	cmd #$1D
	bne :+
	jsr insertRecord
	rts
:
	@ check for extra space
	ltd nameBufPos
	cmd #$0C
	bcc :+
	rts
:
	@ push character
	lta #$00
	ltd nameCursor
	tax
	ltd nameBufPos
	tay

	@ check for space
	ltd keyboardKeys, x
	cmd #$14
	bne :+
	ltd #$20
:
	std nameBuffer, y
	inc nameBufPos

	@ update display
	lta #NAME_TEXT
	sta $4004
	ltx #nameBuffer
	jsr outputName

	@ play beep
	ltx #sfxSelect
	jsr musicStart
	rts

@ erase character
nameErase:
	@ check for characters
	ltd nameBufPos
	bne :+
	rts
:
	@ erase character
	lta #$00
	ltd nameBufPos
	dec a
	std nameBufPos
	tay
	ltd #$20
	std nameBuffer, y

	@ update display
	lta #NAME_TEXT
	sta $4004
	ltx #nameBuffer
	jsr outputName

	@ play beep
	ltx #sfxCancel
	jsr musicStart
	rts

@ insert record into leaderboard
insertRecord:
	@ check for name data
	ltd nameBufPos
	bne :+

	@ play beep
	ltx #sfxCancel
	jsr musicStart
	rts
:

	@ reset input color
	jsr clearNameCursor

	@ shift entries in leaderboard
	lta #$00
	ltd leadIndex
	cmd #$09
	beq :++
	tab
	ltx #$09
:
	dex
	phb
	jsr saveDataAddress
	lta $00, y
	sta $10, y
	lta $02, y
	sta $12, y
	lta $04, y
	sta $14, y
	lta $06, y
	sta $16, y
	lta $08, y
	sta $18, y
	lta $0A, y
	sta $1A, y
	lta $0C, y
	sta $1C, y
	lta $0E, y
	sta $1E, y
	plb
	cpx b
	bne :-
:

	@ insert entry into leaderboard
	lta #$00
	ltd leadIndex
	tax
	jsr saveDataAddress
	ltx #$00
:
	lta nameBuffer, x
	sta y
	iny
	iny
	inx
	inx
	cpx #$0C
	bcc :-

	ltd timeMin
	std $00, y
	ltd timeSec
	std $01, y
	lta timer
	sta $02, y

	@ generate leaderboard
	jsr createLeaderboard

	@ switch to records
	ltd #%00001100
	std $4003
	ltd #$01
	std phase
	stz page

	@ play beep
	ltx #sfxConfirm
	jsr musicStart
	rts

@ get save data address
@ x: id
saveDataAddress:
	ltd level
	and #$03
	ltb #$0A
	mul b
	tab
	txa
	clc
	adc b
	asl
	asl
	asl
	asl
	clc
	adc #$6000
	tay
	rts