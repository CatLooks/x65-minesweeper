@ fetch byte from pointer
@ y: stream offset
fetchByte:
	ltx ch0_ptr, y
	and #$FF
	ltd x
	inx
	stx ch0_ptr, y
	rts

@ fetch word from pointer
@ y: stream offset
fetchWord:
	ltx ch0_ptr, y
	lta x
	inx
	inx
	stx ch0_ptr, y
	rts

@ start to play music
@ x: music data pointer
musicStart:
	@ reset tempo
	lta #$00
	sta musicTimer
	ltd $09, x
	std musicTempo
	stz musicTempo + 1

	@ copy initial pointers
	lta #$00
	ltd $08, x
	tab
	and #$08
	beq :+
	lty $00, x
	sty ch0_ptr
	stz ch0_timer
	stz ch0_timer + 1
:
	tba
	and #$04
	beq :+
	lty $02, x
	sty ch1_ptr
	stz ch1_timer
	stz ch1_timer + 1
:
	tba
	and #$02
	beq :+
	lty $04, x
	sty ch2_ptr
	stz ch2_timer
	stz ch2_timer + 1
:
	tba
	and #$01
	beq :+
	lty $06, x
	sty ch3_ptr
	stz ch3_timer
	stz ch3_timer + 1
:
	rts

@ process music
musicPlay:
	@ check tempo
	ltb musicTempo
	bne :+
	rts
:

	@ tempo timer
	lta musicTimer
	inc a
	mod b
	sta musicTimer
	bcs :+
	rts
:

	@ advance channels
	lty #$00
:
	@ advance pointer
	jsr musicAdvance
	bcs :-

	@ advance loop
	iny
	iny
	cpy #$08
	bcc :-
	rts

@ advance pointer
musicAdvance:
	@ pointer check
	lta ch0_ptr, y
	bne :+
	clc
	rts
:

	@ update timer
	lta ch0_timer, y
	beq :+
	dec a
	sta ch0_timer, y
	clc
	rts
:
	@ set note
	jsr fetchByte
	cmd #$40
	bcs :+

	@ fetch frequency
	asl
	tax
	lta freqTable, x
	sta $5000, y

	@ fetch pause
	jsr fetchByte
	dec a
	sta ch0_timer, y
	clc
	rts
:

	@ quick silence
	cmd #$C0
	bcc :+
	and #$3F
	dec a
	sta ch0_timer, y

	@ reset frequency
	lta #$00
	sta $5000, y
	clc
	rts
:

	@ set silence
	cmd #SIL
	bne :+

	@ fetch pause
	jsr fetchByte
	dec a
	sta ch0_timer, y

	@ reset frequency
	lta #$00
	sta $5000, y
	clc
	rts
:

	@ set volume
	cmd #VOL
	bne :+

	@ fetch volume
	jsr fetchByte
	ltb #$1111
	and #$0F
	mul b
	sta $5010, y
	sec
	rts
:

	@ set delay
	cmd #DEL
	bne :+

	@ fetch pause
	jsr fetchByte
	dec a
	sta ch0_timer, y
	clc
	rts
:

	@ set waveform
	cmd #WAV
	bne :+

	@ fetch id
	jsr fetchByte
	std $5030, y
	lta #$00
	sta $5020, y
	sec
	rts
:

	@ jump
	cmd #REW
	bne :+

	@ fetch address
	jsr fetchWord
	sta ch0_ptr, y
	sec
	rts
:

	@ end track
	cmd #END
	bne :+

	@ reset pointer
	stz ch0_ptr, y
	stz ch0_ptr + 1, y
	clc
	rts
:
	rts

@ music tracks
trackSelect:
	.byte WAV $01
	.byte VOL $07
	.byte A4  $01 $C0
	.byte END

trackConfirm:
	.byte WAV $01
	.byte VOL $09
	.byte A4  $01
	.byte D5  $03 $C0
	.byte END

trackCancel:
	.byte WAV $00
	.byte VOL $05
	.byte B1  $01 $C1
	.byte B1  $01 $C1
	.byte END

tracksFlagSet:
	.byte WAV $01
	.byte VOL $07
	.byte E3  $02
	.byte A3  $01
	.byte E4  $02 $C0
	.byte END

tracksFlagRemove:
	.byte WAV $01
	.byte VOL $07
	.byte E4  $02
	.byte A3  $01
	.byte E3  $02 $C0
	.byte END

trackWinLead:
	.byte WAV $02
	.byte VOL $03
	.byte C3  $03 $C1
	.byte C3  $03 $C1
	.byte E3  $03 $C1
	.byte E3  $03 $C1
	.byte G3  $07 $C1
	.byte B2  $07 $C1
	.byte C3  $10 $C0
	.byte END

trackWinSupport:
	.byte WAV $01
	.byte VOL $06
	.byte C2  $08
	.byte G2  $08
	.byte E2  $08
	.byte D2  $08
	.byte C2  $08 $C0
	.byte END

@ music headers
sfxSelect:
	.word $00
	.word $00
	.word $00
	.word trackSelect
	.byte %0001
	.byte $03

sfxConfirm:
	.word $00
	.word $00
	.word $00
	.word trackConfirm
	.byte %0001
	.byte $03

sfxCancel:
	.word $00
	.word $00
	.word $00
	.word trackCancel
	.byte %0001
	.byte $03

sfxFlagSet:
	.word $00
	.word $00
	.word $00
	.word tracksFlagSet
	.byte %0001
	.byte $03

sfxFlagRemove:
	.word $00
	.word $00
	.word $00
	.word tracksFlagRemove
	.byte %0001
	.byte $03

bgmWin:
	.word trackWinLead
	.word trackWinSupport
	.word $00
	.word $00
	.byte %1100
	.byte $03

bgmLose:
	.word trackLoseLead
	.word trackLoseSupport
	.word $00
	.word $00
	.byte %1100
	.byte $03

bgmMenu:
	.word trackMenuLead
	.word trackMenuSupport
	.word $00
	.word $00
	.byte %1100
	.byte $03

bgmGame:
	.word trackGameBass
	.word trackGameLead
	.word $00
	.word $00
	.byte %1100
	.byte $03