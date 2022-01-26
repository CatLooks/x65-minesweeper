@ random number generator
RNG:
	lta seed
	ltb #21
	clc
	adc #$F281
	mul b
	xor #$5AF0
	sec
	sbc #$7D1C
	sta seed
	rts

@ shuffle array
@ x: ptr, y: len
shuffle:
	@ decrement offset
	dey
	cpy #$FFFF
	beq :+
	tya
	tab
	txa
	clc
	adc b
	sta off1

	@ get random offset
	jsr RNG
	tya
	inc a
	tab
	lta seed
	mod b
	tab
	txa
	clc
	adc b
	sta off2

	@ swap elements
	phx
	phy
	ltx off1
	lty off2
	ltd y
	tab
	ltd x
	std y
	tba
	std x
	ply
	plx

	@ loop back
	bra shuffle
:
	rts