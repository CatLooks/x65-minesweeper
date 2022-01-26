trackLoseLead:
	.byte WAV $02
	.byte VOL $01
	.byte G3  $04
	.byte E3  $04
	.byte C3  $04
	.byte E3  $04
	.byte G3  $04
	.byte Ds3 $04
	.byte C3  $04
	.byte Ds3 $04
	.byte D3  $07 $C1
	.byte B2  $07 $C1
	.byte C3  $10 $C0
	.byte END

trackLoseSupport:
	.byte WAV $01
	.byte VOL $05
	.byte G2  $10
	.byte Ds2 $10
	.byte F2  $07 $C1
	.byte D2  $07 $C1
	.byte Ds2 $10 $C0
	.byte END

trackMenuLead:
	.byte WAV $01
	.byte VOL $01
L0:
	.byte C4  $08
	.byte E4  $04
	.byte G4  $08
	.byte E4  $0C

	.byte B3  $08
	.byte E4  $04
	.byte G4  $08
	.byte E4  $0C

	.byte C4  $08
	.byte E4  $08
	.byte G4  $08
	.byte C5  $08

	.byte B4  $08
	.byte A4  $04
	.byte G4  $08
	.byte F4  $04
	.byte E4  $04
	.byte D4  $04

	.byte REW
	.word L0

trackMenuSupport:
	.byte WAV $01
	.byte VOL $04
L3:
	.byte C3 $0F $C1
	.byte E3 $0F $C1
	.byte B2 $0F $C1
	.byte G3 $0F $C1
	.byte C3 $0F $C1
	.byte E3 $0F $C1
	.byte D2 $0F $C1
	.byte G3 $0F $C1

	.byte REW
	.word L3

trackGameBass:
	.byte WAV $01
	.byte VOL $01
L1:
	.byte D2  $04 $C2
	.byte A2  $04 $C2
	.byte F2  $04 $C2
	.byte A2  $04 $C2

	.byte REW
	.word L1

trackGameLead:
	.byte WAV $01
	.byte VOL $01
L2:
	.byte SIL $60

	.byte D4  $0C
	.byte E4  $0C

	.byte F4  $04 $C2
	.byte E4  $04 $C2
	.byte D4  $04 $C2
	.byte Cs4 $04 $C2

	.byte D4  $04 $C2
	.byte A4  $04 $C8
	.byte A4  $06

	.byte As4 $06
	.byte A4  $06
	.byte G4  $06
	.byte F4  $04 $C2

	.byte G4  $06
	.byte A4  $06
	.byte G4  $06
	.byte F4  $06

	.byte E4  $0C
	.byte D4  $0C

	.byte Cs4 $06
	.byte As3 $06
	.byte F4  $04 $C2
	.byte E4  $04 $C2

	.byte D4  $18

	.byte REW
	.word L2