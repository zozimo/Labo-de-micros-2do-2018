.include"m328Pdef.inc"

.cseg 
.org 0x00
	JMP MAIN
.org 0x02
	JMP INTERRUPT


	MAIN: 
		LDS R20, TIMSK1
		ORI R20, 0x20
		STS TIMSK1, R20 
				
		LDS R20, TCCR1A
		ANDI R20, 0x0C
		STS TCCR1A, R20 ; Set timer as normal mode

		LDS R20, TCCR1B
		ORI R20, 0x41
		STS TCCR1B,R20 ; rising edge, no prescaler, no noise canceller
		SEI
	
	
	INTERRUPT:
	L1:
		LDS R21, TIFR1 ;timer interrupt
		;When there's an interruption, ICF1 flag is set.
		SBRS R21, ICF1 ; Skip next if ICF1 flag is set.
		RJMP L1; loop until there's an interruption (?
		LDS R23, ICR1L
		LDS R24, ICR1H
		STS TIFR1, R21 ; clear ICF1

	L2:
		LDS R21, TIFR1
		SBRS R21, ICF1 ; Skip next if ICF1 = 1
		RJMP L2
		STS TIFR1, R21 ; clear ICF1
		LDS R22, ICR1L
		SUB R22, R23; Period = Second edge - First edge
		OUT PORTC, R22 ; REVISAR
		LDS R22, ICR1H
		SBC R22, R24; R22 = R22 - R24 - C
		OUT PORTB, R22 ; REVISAR
	RETI
