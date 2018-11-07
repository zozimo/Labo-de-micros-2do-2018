.include"m328Pdef.inc"

.cseg 
.org 0x00
	JMP MAIN
;.org ICP1addr
;	JMP INTERRUPT


	MAIN: 
		CBI DDRB, 0
		SBI DDRB, 5
		SBI DDRB, 6

		;LDI R20, (1<<INT0)
		;out EIMSK, R20;set INT0
			
		;LDS R20, EICRA ;rising edge INT0
		;ORI R20, 0x03
		;STS EICRA, R20

		LDS R20, TIMSK1
		ORI R20, 0x20
		STS TIMSK1, R20 
				
		LDS R20, TCCR1A
		ANDI R20, 0x0C
		STS TCCR1A, R20 ; Set timer as normal mode

		LDS R20, TCCR1B
		ORI R20, 0x41
		STS TCCR1B,R20 ; rising edge, no prescaler, no noise canceller
		;SEI
	
	HERE: CALL MEASURE_PERIOD
		   JMP HERE
	
	MEASURE_PERIOD:
		;SBI PORTB, 5
	;	CBI PINB, 0
	;	SEI
	L1:
		IN R21, TIFR1 ;timer interrupt
		;When there's an interruption, ICF1 flag is set.
		SBRS R21, ICF1 ; Skip next if ICF1 flag is set.
		RJMP L1; loop until there's an interruption (?
		LDS R23, ICR1L
		LDS R24, ICR1H
		OUT TIFR1, R21 ; clear ICF1
		SBI PORTB, 5

	L2:
		IN R21, TIFR1
		SBRS R21, ICF1 ; Skip next if ICF1 = 1
		RJMP L2
		SBI PORTB, 6
		OUT TIFR1, R21 ; clear ICF1
		LDS R22, ICR1L
		SUB R22, R23; Period = Second edge - First edge
		;OUT PORTC, R22 ; REVISAR
		LDS R23, ICR1H
		SBC R23, R24; R23 = R23 - R24 - C
		CBI PORTB, 5
		;OUT PORTB, R22 ; REVISAR
	RET
