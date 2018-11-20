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
	
	HERE:
		 CALL MEASURE_PERIOD
		 CALL DELAY		
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
	GRADOS:
		CLR R2; Registro para el resto
		LDI R24, 0xFF ; Registro con el que se divide
		LDI R25, 0x10
	
	DIV8A:
		LSL R22 ; Shift left 
		ROL R23
		ROL R2 
		BRCS DIV8B
		CP R2, R24
		BRCS DIV8C
	DIV8B:
		SUB R2, R24
		INC R22
	DIV8C:
		DEC R25
		BRNE DIV8A

	RET


	DELAY:
		LDI R24, 0xFF
		SUB R24, R22
		OUT TCNT0, R24
		LDI R20, 0x01
		
		LDI R20, 0x00
		OUT TCCR0A, R20
	;	LDS R20, TCCR0A
	;	ANDI R20, 0x0C
	;	STS TCCR0A, R20 ; Set timer as normal mode

		LDI R20, 0x01
		OUT TCCR0B, R20
		;LDS R20, TCCR0B
		;ORI R20, 0x01 ; int clk, no prescaler
		;STS TCCR0B,R20	

	AGAIN:
		IN R20, TIFR0
		SBRS R20, TOV0 ; skip next instruction if T0V0 flag is set
		RJMP AGAIN
		LDS R20, TCCR0B
		ANDI R20, 0x30 ; stop timer
		STS TCCR1B,R20
		LDI R20, (1<<TOV0)
		OUT TIFR0, R20 ; clear T0V0 flag by writting 1 to TIFR
		RET
