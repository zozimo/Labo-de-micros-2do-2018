; Archivo principal


.include"m328pdef.inc"
.device atmega328p

.def input_reg = R16 ;
.def output_reg = R17 ;

.equ msg_size = 54	; mensaje de 9 símbolos ascii (6 bytes cada uno)

;---------	Reserva de memoria en RAM	------------
.dseg
.org SRAM_START
	msg : .byte msg_size



;---------	Configuración de interrupciones	---------
.cseg
.ORG 0x00 ;Comienzo del código en la posición 0
	jmp main	;




.ORG INT_VECTORS_SIZE

testing_msg: .db "HOLAMUNDO",0x00

DICCIONARIO:
	A_LETTER:	.db 0x7E,0x90,0x90,0x90,0x7E,0 ;
	B_LETTER: 	.db 0xFE,0x92,0x92,0xF2,0x0E,0 ;
	C_LETTER:	.db 0xFE,0x82,0x82,0x82,0x82,0 ;
	D_LETTER: 	.db 0xFE,0x82,0x82,0x82,0x7C,0 ;
	E_LETTER: 	.db 0xFE,0x92,0x92,0x92,0x82,0 ;
	F_LETTER: 	.db 0xFE,0x90,0x90,0x90,0x80,0 ;
	G_LETTER: 	.db 0x7C,0x82,0x92,0x92,0x9C,0 ;
	H_LETTER: 	.db 0xFE,0x10,0x10,0x10,0xFE,0 ;
	I_LETTER: 	.db 0x00,0x00,0xFE,0x00,0x00,0 ;
	J_LETTER: 	.db 0x8E,0x82,0xFE,0x80,0x80,0 ;
	K_LETTER: 	.db 0xFE,0x10,0x28,0x44,0x82,0 ;
	L_LETTER: 	.db 0xFE,0x02,0x02,0x02,0x02,0 ;
	M_LETTER: 	.db 0xFE,0x60,0x30,0x60,0xFE,0 ;
	N_LETTER: 	.db 0xFE,0x06,0x18,0x06,0xFE,0 ;
	O_LETTER: 	.db 0x7C,0x82,0x82,0x82,0x7C,0 ;
	P_LETTER: 	.db 0xFE,0x90,0x90,0x90,0x60,0 ;
	Q_LETTER:	.db 0x7C,0x82,0x8A,0x86,0x7E,0 ;
	R_LETTER: 	.db 0xFE,0x90,0x98,0x94,0x62,0 ;
	S_LETTER:	.db 0x64,0x92,0x92,0x92,0x4C,0 ;
	T_LETTER: 	.db 0x80,0x80,0xFE,0x80,0x80,0 ;
	U_LETTER: 	.db 0xFC,0x02,0x02,0x02,0xFC,0 ;
	V_LETTER: 	.db 0xC0,0x38,0x0E,0x38,0xC0,0 ;
	W_LETTER: 	.db 0xFE,0x06,0x30,0x06,0xFE,0 ;
	X_LETTER: 	.db 0xC6,0x6C,0x10,0x6C,0xC6,0 ;
	Y_LETTER: 	.db 0x80,0x40,0x3E,0x40,0x80,0 ;
	Z_LETTER: 	.db 0x86,0x9A,0x92,0xB2,0xC2,0 ;



main:
	;inicializa el SP
	LDI output_reg, HIGH(RAMEND) ; Carga el SPH
	OUT SPH, output_reg
	LDI output_reg, LOW(RAMEND) ;Carga el SPL
	OUT SPL, output_reg



	SBI DDRC,0 ;Pone como salida el pin 0 del puerto c
	NOP ;Espera un ciclo de reloj
	SBI PORTC, 0 ;Enciende el led 0

	LDI output_reg, 0x0F
	OUT DDRC,output_reg	; C0...C3 como salidas
	SWAP output_reg
	OUT DDRD,output_reg	; D4...D7 como salidas

	CALL ST_MSG_TO_RAM
	CALL PRINT_MSG

	JMP end

;------------------------------------------------
; recibe en Z la posición de la columna a imprimir
; avanza a la siguiente columna
PRINT_COL:
	PUSH R20
	LPM R20,Z+
	PUSH R20	; guardo el valor de r18 en el stack
	ANDI R20,0x0F
	OUT PORTC,R20	;C0 ... C3 con nibble inferior
	POP R20		; recupero el valor de r18 del stack
	ANDI R20, 0xF0
	OUT PORTD, R20	;D4 ... D7 con nibble superior
	POP R20
	RET

;------------------------------------------------
;recibe en el registro de entrada una letra en ascii
;utiliza puntero z como intermedio
;input_reg esta usado como ascii
;posición de la letra = DICCIONARIO + (input_reg -'A')*5
PRINT_LETTER:
	PUSH input_reg
	PUSH R18
	LDI ZH,HIGH(DICCIONARIO<<1)
	LDI ZL,LOW(DICCIONARIO<<1)
	LDI R18,6

	SUBI input_reg,'A' 
	MUL R18,input_reg	;r0 <- low(r18*r16)		r1 <- high(r18*r16)
	ADD ZL, R0
	ADC ZH, R1

	
	CALL PRINT_COL	; 1er columna
	CALL DELAY_DOT_SPACE
	CALL PRINT_COL	; 2da columna
	CALL DELAY_DOT_SPACE
	CALL PRINT_COL	; 3er columna
	CALL DELAY_DOT_SPACE
	CALL PRINT_COL	; 4ta columna
	CALL DELAY_DOT_SPACE
	CALL PRINT_COL	; 5ta columna
	CALL DELAY_DOT_SPACE

	POP R18
	POP input_reg
	RET

;------------------------------------------------
;lee de RAM una frase e imprime letra por letra
;usa input_reg para cada letra individual
PRINT_MSG:
	PUSH R19
	LDI R19, msg_size	; variable de contador en el mensaje
	LDI XH, HIGH(msg)	; variable para desplazarse en el mensaje en RAM
	LDI XL, LOW(msg)
	PRINT_MSG_LOOP:
		CPI R19,0
		BREQ PRINT_MSG_END
		LD input_reg, X+	; leer letra de RAM
		CALL PRINT_LETTER	; imprimir letra
		CALL DELAY_LETTER_SPACE	; esperar letter_space
		SUBI R19,6		; decrementar contador en 6
		JMP PRINT_MSG_LOOP


	PRINT_MSG_END:
		POP R19
		RET

;------------------------------------------------
; guarda un mensaje desde FLASH a RAM
ST_MSG_TO_RAM:
	PUSH R16
	LDI ZH, HIGH(testing_msg<<1)
	LDI ZL, LOW(testing_msg<<1)

	LDI XH,HIGH(msg)
	LDI XL,LOW(msg)	

	ST_MSG_TO_RAM_LOOP:
		LPM R16,Z+
		CPI R16,0
		BREQ ST_MSG_TO_RAM_END
		ST X+,R16
		RJMP ST_MSG_TO_RAM_LOOP

	ST_MSG_TO_RAM_END:
		POP R16
		RET
;------------------------------------------------
;espera el tiempo correspondiente al espacio entre letras
; 2.9ms a 16 MHz
DELAY_LETTER_SPACE:
;	    ldi  r22, 63
;	    ldi  r23, 83
;	LOOP_LETTER_SPACE: 
;		dec  r23
;	    brne LOOP_LETTER_SPACE
;	    dec  r22
;	    brne LOOP_LETTER_SPACE

	RET
;------------------------------------------------
;espera el tiempo correspondiente al espacio entre columnas de una letra
; 599,5 us a 16 MHz
DELAY_DOT_SPACE:
;	    ldi  r22, 13
;	    ldi  r23, 116
;	LOOP_DOT_SPACE:
;		dec  r23
;	    brne LOOP_DOT_SPACE
;	    dec  r22
;	    brne LOOP_DOT_SPACE
;	    nop
	RET
;------------------------------------------------
;
end: jmp end
