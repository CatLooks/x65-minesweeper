@ macros
.set MOV $80
.set SET $81
.set DEL $82
.set RST $83

.set comma $FC
.set dot   $FD
.set endl  $FE
.set endp  $FF

@ fetch help byte
fetchHelpByte:
	ltx helpPtr
	and #$FF
	ltd x
	inx
	stx helpPtr
	rts

@ output page text
@ x: addr
outputPage:
	ltd #$01
	std newLine
	lty #$98F4
	sty $4004
	phy
:
	ltd x
	and #$FF

	@ check paragraph end
	cmd #endp
	bne :+
	ply
	rts
:
	@ check new line
	cmd #endl
	bne :+
	pla
	clc
	adc #40
	sta $4004
	pha
	ltd #$01
	std newLine
	bra :+++++
:
	@ check comma
	stz newLine
	cmd #comma
	bne :+
	ltd #$18
	std $4000
	bra :++++
:
	@ check dot
	cmd #dot
	bne :+
	ltd #$17
	std $4000
	bra :+++
:
	@ get word address
	ltd newLine
	bne :+
	ltd #" "
	std $4000
:
	phx
	ltd x
	asl
	tax
	ltx dictRef, x
	jsr outputText
	plx
:
	@ advance loop
	inx
	bra :-------

@ start preview
@ x: data addr
previewReset:
	@ update cursor
	ltd $09, x
	std gameCursor

	@ copy pointer
	lta $0A, x
	sta helpPtr

	@ reset timer
	lta #30
	sta helpTimer

	@ copy field
	lty #$00
:
	ltd x
	std mineField, y
	ltd #$01
	std gameField, y
	tya
	std buffer
	phx
	phy
	jsr updateCell
	ply
	plx
	inx
	iny
	cpy #$09
	bcc :-
	rts

@ process preview
previewProcess:
	@ pointer check
	lta helpPtr
	bne :+
	rts
:
	@ update timer
	lta helpTimer
	beq :+
	dec a
	sta helpTimer
	rts
:
	jsr previewAdvance
	bcc :-
	rts

@ advance preview
previewAdvance:
	@ load instruction byte
	jsr fetchHelpByte

	@ check cursor move
	cmd #MOV
	bne :+

	@ get new position
	jsr fetchHelpByte
	std gameCursor
	clc
	rts
:

	@ check cell set
	cmd #SET
	bne :+

	@ get cell position
	jsr fetchHelpByte
	std buffer
	tay

	@ change cell
	jsr fetchHelpByte
	std mineField, y
	jsr updateCell
	clc
	rts
:

	@ check timer set
	cmd #DEL
	bne :+

	@ fetch ticks
	jsr fetchHelpByte
	sta helpTimer
	sec
	rts
:

	@ check for reset
	cmd #RST
	bne :+

	@ reset
	ltd helpPage
	and #$FF
	asl
	tax
	ltx previewRef, x
	jsr previewReset
	sec
	rts
:
	sec
	rts

@ help dictionary
dict:
d_at:
	.set w_at $00
	.byte "AT", $00
d_the:
	.set w_the $01
	.byte "THE", $00
d_start:
	.set w_start $02
	.byte "START", $00
d_mines:
	.set w_mines $03
	.byte "MINES", $00
d_will:
	.set w_will $04
	.byte "WILL", $00
d_be:
	.set w_be $05
	.byte "BE", $00
d_spread_across:
	.set w_spread_across $06
	.byte "SPREAD ACROSS", $00
d_field:
	.set w_field $07
	.byte "FIELD", $00
d_if:
	.set w_if $08
	.byte "IF", $00
d_a:
	.set w_a $09
	.byte "A", $00
d_cell:
	.set w_cell $0A
	.byte "CELL", $00
d_does_not:
	.set w_does_not $0B
	.byte "DOES NOT", $00
d_contain:
	.set w_contain $0C
	.byte "CONTAIN", $00
d_mine:
	.set w_mine $0D
	.byte "MINE", $00
d_number:
	.set w_number $0E
	.byte "NUMBER", $00
d_of:
	.set w_of $0F
	.byte "OF", $00
d_in:
	.set w_in $10
	.byte "IN", $00
d_neighbor:
	.set w_neighbor $11
	.byte "NEIGHBOR", $00
d_cells:
	.set w_cells $12
	.byte "CELLS", $00
d_shown:
	.set w_shown $13
	.byte "SHOWN", $00
d_goal:
	.set w_goal $14
	.byte "GOAL", $00
d_game:
	.set w_game $15
	.byte "GAME", $00
d_is:
	.set w_is $16
	.byte "IS", $00
d_to:
	.set w_to $17
	.byte "TO", $00
d_open:
	.set w_open $18
	.byte "OPEN", $00
d_all:
	.set w_all $19
	.byte "ALL", $00
d_without:
	.set w_without $1A
	.byte "WITHOUT", $00
d_flags_are_used_to_mark:
	.set w_flags_are_used_to_mark $1B
	.byte "FLAGS ARE USED TO MARK", $00
d_position:
	.set w_position $1C
	.byte "POSITION", $00
d_uncovered:
	.set w_uncovered $1D
	.byte "UNCOVERED", $00
d_equal:
	.set w_equal $1E
	.byte "EQUAL", $00
d_left:
	.set w_left $1F
	.byte "LEFT", $00
d_should:
	.set w_should $20
	.byte "SHOULD", $00
d_flagged:
	.set w_flagged $21
	.byte "FLAGGED", $00
d_near:
	.set w_near $22
	.byte "NEAR", $00
d_were_found:
	.set w_were_found $23
	.byte "WERE FOUND", $00
d_you:
	.set w_you $24
	.byte "YOU", $00
d_this:
	.set w_this $25
	.byte "THIS", $00
d_can:
	.set w_can $26
	.byte "CAN", $00
d_done:
	.set w_done $27
	.byte "DONE", $00
d_quick:
	.set w_quick $28
	.byte "QUICK", $00
d_sometimes_it:
	.set w_sometimes_it $29
	.byte "SOMETIMES IT", $00
d_harder:
	.set w_harder $2A
	.byte "HARDER", $00
d_predict:
	.set w_predict $2B
	.byte "PREDICT", $00
d_case_try:
	.set w_case_try $2C
	.byte "CASE", $18, " TRY", $00
d_check_every_possible:
	.set w_check_every_possible $2D
	.byte "CHECK EVERY POSSIBLE", $00
d_placement:
	.set w_placement $2E
	.byte "PLACEMENT", $00
d_and:
	.set w_and $2F
	.byte "AND", $00
d_see:
	.set w_see $30
	.byte "SEE", $00
d_conflict_with:
	.set w_conflict_with $31
	.byte "CONFLICT WITH", $00
d_your:
	.set w_your $32
	.byte "YOUR", $00
d_run_was:
	.set w_run_was $33
	.byte "RUN WAS", $00
d_loading:
	.set w_loading $34
	.byte "LOADING", $00
d_have:
	.set w_have $35
	.byte "HAVE", $00
d_placed:
	.set w_placed $36
	.byte "PLACED", $00
d_on:
	.set w_on $37
	.byte "ON", $00
d_leaderboard:
	.set w_leaderboard $38
	.byte "LEADERBOARD", $00
d_time:
	.set w_time $39
	.byte "TIME", $00
d_good_enough:
	.set w_good_enough $3A
	.byte "GOOD ENOUGH", $00
d_asked:
	.set w_asked $3B
	.byte "ASKED", $00
d_input:
	.set w_input $3C
	.byte "INPUT", $00
d_then:
	.set w_then $3D
	.byte "THEN", $00
d_basics:
	.set w_basics $3E
	.byte "BASICS", $00
d_flagging:
	.set w_flagging $3F
	.byte "FLAGGING", $00
d_opening:
	.set w_opening $40
	.byte "OPENING", $00
d_deducting:
	.set w_deducting $41
	.byte "DEDUCTING", $00
d_these:
	.set w_these $42
	.byte "THESE", $00
d_efficiently:
	.set w_efficiently $43
	.byte "EFFICIENTLY", $00
d_by_using:
	.set w_by_using $44
	.byte "BY USING", $00
d_which_variant:
	.set w_which_variant $45
	.byte "WHICH VARIANT", $00
d_name:
	.set w_name $46
	.byte "NAME", $00
d_performed:
	.set w_performed $47
	.byte "PERFORMED", $00
d_chance:
	.set w_chance $48
	.byte "CHANCE", $00

@ word references
dictRef:
	.word d_at
	.word d_the
	.word d_start
	.word d_mines
	.word d_will
	.word d_be
	.word d_spread_across
	.word d_field
	.word d_if
	.word d_a
	.word d_cell
	.word d_does_not
	.word d_contain
	.word d_mine
	.word d_number
	.word d_of
	.word d_in
	.word d_neighbor
	.word d_cells
	.word d_shown
	.word d_goal
	.word d_game
	.word d_is
	.word d_to
	.word d_open
	.word d_all
	.word d_without
	.word d_flags_are_used_to_mark
	.word d_position
	.word d_uncovered
	.word d_equal
	.word d_left
	.word d_should
	.word d_flagged
	.word d_near
	.word d_were_found
	.word d_you
	.word d_this
	.word d_can
	.word d_done
	.word d_quick
	.word d_sometimes_it
	.word d_harder
	.word d_predict
	.word d_case_try
	.word d_check_every_possible
	.word d_placement
	.word d_and
	.word d_see
	.word d_conflict_with
	.word d_your
	.word d_run_was
	.word d_loading
	.word d_have
	.word d_placed
	.word d_on
	.word d_leaderboard
	.word d_time
	.word d_good_enough
	.word d_asked
	.word d_input
	.word d_then
	.word d_basics
	.word d_flagging
	.word d_opening
	.word d_deducting
	.word d_these
	.word d_efficiently
	.word d_by_using
	.word d_which_variant
	.word d_name
	.word d_performed
	.word d_chance

@ help text
helpPage1:
	.byte w_basics endl endl
	.byte w_at w_the w_start comma w_mines endl w_will w_be
	.byte w_spread_across endl w_the w_field dot endl endl
	.byte w_if w_a w_cell w_does_not endl w_contain w_the w_mine
	.byte comma w_the endl w_number w_of w_mines w_in endl
	.byte w_neighbor w_cells w_will w_be w_shown dot endl endl
	.byte w_the w_goal w_of w_the w_game w_is w_to w_open endl
	.byte w_all w_cells w_without w_mines dot
	.byte endp

helpPage2:
	.byte w_flagging endl endl
	.byte w_flags_are_used_to_mark endl w_a w_mine w_position
	.byte dot endl endl
	.byte w_if w_the w_number w_of endl w_uncovered w_neighbor
	.byte endl w_cells w_is w_equal w_to w_the endl w_number w_of
	.byte w_mines w_left comma endl w_these w_cells w_should w_be
	.byte w_flagged dot endp

helpPage3:
	.byte w_quick w_opening endl endl
	.byte w_if w_all w_mines w_near w_a endl w_cell w_were_found comma
	.byte w_you endl w_should w_open w_all endl
	.byte w_neighbor w_cells dot endl endl
	.byte w_this w_can w_be w_done endl w_efficiently w_by_using endl
	.byte w_quick w_opening dot endp

helpPage4:
	.byte w_deducting endl endl
	.byte w_sometimes_it w_is w_harder w_to endl w_predict w_position
	.byte w_of endl w_the w_mines dot endl endl
	.byte w_in w_this w_case_try w_to endl w_check_every_possible
	.byte endl w_mine w_placement w_and w_see endl
	.byte w_which_variant w_does_not endl w_conflict_with
	.byte w_neighbor w_cells dot
	.byte endp

helpPage5:
	.byte w_leaderboard endl endl
	.byte w_if w_your w_run_was endl w_performed w_without endl w_loading
	.byte comma w_you w_will w_have endl w_a w_chance w_to w_be w_placed
	.byte endl w_on w_the w_leaderboard dot endl endl
	.byte w_if w_your w_time w_is w_good_enough comma endl w_you
	.byte w_will w_be w_asked w_to w_input w_your endl w_name w_and w_then
	.byte w_placed w_on endl w_the w_leaderboard dot
	.byte endp

@ preview animations
frames2:
	.byte MOV $01
	.byte DEL $10
	.byte MOV $00
	.byte DEL $40
	.byte SET $00 $0B
	.byte DEL $30
	.byte MOV $03
	.byte DEL $10
	.byte MOV $06
	.byte DEL $10
	.byte MOV $07
	.byte DEL $10
	.byte MOV $08
	.byte DEL $40
	.byte SET $08 $0B
	.byte DEL $20
	.byte RST
frames3:
	.byte MOV $03
	.byte DEL $10
	.byte MOV $04
	.byte DEL $30
	.byte SET $00 $01
	.byte SET $01 $00
	.byte SET $02 $00
	.byte SET $05 $01
	.byte DEL $40
	.byte RST
frames4:
	.byte MOV $04
	.byte DEL $18
	.byte MOV $01
	.byte DEL $18
	.byte SET $01 $0B
	.byte DEL $30
	.byte MOV $00
	.byte DEL $18
	.byte SET $00 $0B
	.byte DEL $44
	.byte SET $00 $0A
	.byte DEL $18
	.byte MOV $01
	.byte DEL $18
	.byte MOV $02
	.byte DEL $18
	.byte SET $02 $0B
	.byte DEL $44
	.byte MOV $01
	.byte DEL $18
	.byte SET $01 $0A
	.byte DEL $18
	.byte MOV $00
	.byte DEL $18
	.byte SET $00 $0B
	.byte DEL $18
	.byte MOV $01
	.byte DEL $18
	.byte SET $01 $02
	.byte DEL $30
	.byte RST

@ preview headers
@ showcase
preview1:
	.byte $00 $02 $09
	.byte $01 $03 $09
	.byte $09 $02 $01
	.byte $00
	.word $0000

@ flagging
preview2:
	.byte $0A $01 $00
	.byte $01 $02 $01
	.byte $00 $01 $0A
	.byte $02
	.word frames2

@ chainning
preview3:
	.byte $0A $0A $0A
	.byte $01 $01 $0A
	.byte $00 $01 $0B
	.byte $06
	.word frames3

@ deduction
preview4:
	.byte $0A $0A $0A
	.byte $01 $02 $01
	.byte $00 $00 $00
	.byte $07
	.word frames4

@ leaderboard
preview5:
	.byte $0B $02 $0B
	.byte $01 $04 $0B
	.byte $0B $02 $01
	.byte $08
	.word $0000

@ help text reference
helpRef:
	.word helpPage1
	.word helpPage2
	.word helpPage3
	.word helpPage4
	.word helpPage5
	.word $0000

@ preview reference
previewRef:
	.word preview1
	.word preview2
	.word preview3
	.word preview4
	.word preview5
	.word $0000