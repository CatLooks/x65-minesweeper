@ update field cell
@ buffer: cell id
updateCell:
	jsr getCellAddress
	txa
	tab

	@ get tile
	ltd buffer
	and #$FF
	tax
	ltd gameField, x
	bne :+
	tba
	tay
	ltd $0A, y
	std BUF
	bra :+++
:
	cmd #$02
	bne :+
	tba
	tay
	ltd $0B, y
	std BUF
	bra :++
:
	ltd mineField, x
	clc
	adc b
	tax
	ltd x
	std BUF
:
	@ draw cell
	jsr drawCell
	rts

@ update menu cell
@ BUF: cell id
updateMenuCell:
	jsr getMenuPosition
	txa
	tab

	@ get tile
	lta #$00
	ltx BUF
	ltd startmenu, x
	clc
	adc b
	tax
	ltd x
	std BUF

	@ draw cell
	jsr drawCell
	rts

@ draw menu cell
@ BUF: tile id
drawCell:
	@ upper row
	lta tileAddr
	sta $4004
	ltd BUF
	std $4000
	phd
	inc a
	std $4000
	phd

	@ lower row
	lta tileAddr
	clc
	adc #40
	sta $4004
	ltd BUF
	clc
	adc #$10
	std $4000
	phd
	inc a
	std $4000
	phd

	@ set palettes
	lta tileAddr
	clc
	adc #$4028
	sta $4004
	pla
	and #$0E0E
	asl
	asl
	asl
	sta $4000
	lta tileAddr
	clc
	adc #$4000
	sta $4004
	pla
	and #$0E0E
	asl
	asl
	asl
	sta $4000
	rts

@ get cell address
getCellAddress:
	ltd buffer
	and #$FF
	ltb fieldW
	div b
	ltb #80
	mul b
	tax
	ltd buffer
	and #$FF
	ltb fieldW
	mod b
	asl
	tab
	txa
	clc
	adc b
	clc
	adc fieldAddr
	sta tileAddr

	@ check cell highlight
	ltd buffer
	and #$FF
	ltb fieldW
	div b
	and #$01
	tax
	ltd buffer
	ltb fieldW
	mod b
	and #$01
	tab
	txa
	xor b
	beq :+
	ltx #tileH
	rts
:
	ltx #tileL
	rts

@ get global cell position
@ BUF: cell id
getMenuPosition:
	lta BUF
	ltb #20
	div b
	ltb #80
	mul b
	tax
	lta BUF
	ltb #20
	mod b
	asl
	tab
	txa
	clc
	adc b
	adc #$8800
	sta tileAddr

	@ check cell highlight
	lta BUF
	ltb #20
	div b
	and #$01
	tax
	lta BUF
	mod b
	and #$01
	tab
	txa
	xor b
	beq :+
	ltx #tileH
	rts
:
	ltx #tileL
	rts

@ update palette of background pattern
updatePatternPalette:
	@ update timer
	lta #$00
	ltb #PATTERN_MOVE_SPEED
	ltd patternTimer
	inc a
	mod b
	std patternTimer
	bcs :+
	rts

:
	@ shift palette colors
	lta patternPalette
	sta BUF
	ltx #$00
:
	lta patternPalette + $02, x
	sta patternPalette, x
	inx
	inx
	cpx #$0E
	bcc :-
	lta BUF
	sta patternPalette + $0E

	@ update palette
	ltx #$0190
	stx $4004
	ltx #$00
:
	lta patternPalette, x
	sta $4000
	inx
	inx
	cpx #$10
	bcc :-
	rts