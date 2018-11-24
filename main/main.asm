; Archivo principal

.include"m328pdef.inc"
.device atmega328p

.def input_reg = R16 ;
.def output_reg = R17 ;

.equ msg_size = 54	; mensaje de 9 símbolos ascii (6 bytes cada uno)

; Las siguientes constantes establecen el UBRR0L y UBRRH para definir el BAUDE RATE
.EQU	constL=0x67		;baudaje de 9600
.EQU	constH=0x00
.EQU	maxSpeed=0x00 ;constantes para validar la velocidad minima y maxima del 
.EQU	minSpeed=0xF0
.DEF	buffer=R5				;exclusivo para enviar los datos al udreo
.DEF	timeForOneGrade=R23
;.DEF	var1=R16

;---------	Reserva de memoria en RAM	------------
.dseg
.org SRAM_START
	msg : .byte msg_size



;---------	Configuración de interrupciones	---------
.cseg
.ORG 0x00 ;Comienzo del código en la posición 0
	jmp main	;

;.org ICP1addr
;	JMP ICP1_INTERRUPT

.org URXCaddr	
	jmp URXC_INT_HANDLER ; interrupcion de recepcion por Bluetooth


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

	;CALL CONFIG_TIMER

	;CALL BLUETOOTH_TO_RAM
	SEI

	CALL ST_MSG_TO_RAM
here:
	CALL PRINT_MSG
	JMP here
;	JMP end

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
	CALL DELAY_1_GRADE
	CALL PRINT_COL	; 2da columna
	CALL DELAY_1_GRADE
	CALL PRINT_COL	; 3er columna
	CALL DELAY_1_GRADE
	CALL PRINT_COL	; 4ta columna
	CALL DELAY_1_GRADE
	CALL PRINT_COL	; 5ta columna
	CALL DELAY_1_GRADE
	CALL PRINT_COL	; 6ta columna (columna vacia)
	CALL DELAY_1_GRADE

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
		;CALL DELAY_3_MS	; esperar letter_space
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
;	DELAYS
;------------------------------------------------
;Delay de 1 grado que va a ser utilizado para generar delays de cierta cantidad de grados
DELAY_1_GRADE:
		PUSH R20

		IN R20, TIFR0
		SBRS R20, TOV0 ; saltar sigueinte instruccion si T0V0 flag está seteado
		RJMP DELAY_1_GRADE
		LDS R20, TCCR0B
		ANDI R20, 0x30 ; stop timer
		STS TCCR1B,R20
		LDI R20, (1<<TOV0)
		OUT TIFR0, R20 ; clear T0V0 flag escribiendo 1 en TIFR

		POP R20
	RET
;--------------------------------------------------
;espera el tiempo correspondiente al espacio entre letras
; 2.9ms a 16 MHz
DELAY_3_MS:
		push r22
		push R24

	    ldi  r22, 63
	    ldi  R24, 83
	LOOP_LETTER_SPACE: 
		dec  R24
	    brne LOOP_LETTER_SPACE
	    dec  r22
	    brne LOOP_LETTER_SPACE
	
		pop R24
		pop r22
		
	RET
;-------------------------------------------------
DELAY_500_MS:
		push r18
		push r19
		push r20

		ldi  r18, 41
	    ldi  r19, 150
	    ldi  r20, 128
	L1: dec  r20
	    brne L1
	    dec  r19
	    brne L1
	    dec  r18
	    brne L1

		pop r20
		pop r19
		pop r18

		

		ret
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
;	RUTINAS DE BLUETOOTH
;------------------------------------------------
BLUETOOTH_TO_RAM:
	ldi XH,HIGH(msg)
	ldi XL,LOW(msg)

	call Set_ports
	call set_usart
	call prender_bluetooth
	ret

;-----------------------------------------------------------
;	CONFIGURACION DE BLUETOOTH
;Habilitar transmision y Recepción	(en UCSR0B-->RXEN0,TXEN0)	
;Modo Asincronico					(en UCSR0C-->UMSEL0,UMSEL1)
;Tamaño de caracter(frame)= 8bits	(en UCSR0C/B-->UCSZ0,UCSZ1/UCSZ2)
;Sin paridad						(en UCSR0C-->UMSEL0,UMSEL1)
;1 bit de stop 						(en UCSR0C-->USBS0)
;Establecer un Bauderate de 9600	(en UBRR0H/UBRR0L )
;con un micro de 16MHZ(Ver formula)
;-----------------------------------------------------------
set_usart:
;--->>> Habilitar  receptor RXEN0 y habilito la interrupcion de recepcion completa RXCIE0
	
	ldi r16, (1<<RXEN0)|(1<<TXEN0)|(0<<UDRIE0)|(0<<TXCIE0)|(1<<RXCIE0); agrego interrupcion de transmision completa
	STS UCSR0B,r16; No se puede usar OUT pues UCSR0B esta en la memoria extendida.

	;Tamaño de caracter(frame)= 8bits + 1 bit de stop
	ldi r16, (1<<UCSZ00)|(1<<UCSZ01)|(0<<USBS0)
	STS UCSR0C,r16

	;Establecer un Bauderate de 9600 con clock 16MHZ
	ldi r16, constL
	STS	UBRR0L,r16
	ldi r16, constH
	STS	UBRR0H,r16
	ret

Set_ports:		
	sbi ddrb,0		;PWR para modulo(digital pin 8)
	sbi ddrb,5		;para el led de prueba
	ret 

prender_bluetooth:
	in r16,portb
	sbrc r16,0
	ret
	sbi portb,0
	ret

;-------------------------------
;	RUTINAS DE TIMER
;-------------------------------
CONFIG_TIMER:
	PUSH R20
	PUSH R24

	CBI DDRB, 0

	LDS R20, TIMSK1
	ORI R20, 0x20
	STS TIMSK1, R20 
			
	LDS R20, TCCR1A
	ANDI R20, 0x0C
	STS TCCR1A, R20 ; Set timer as normal mode

	LDS R20, TCCR1B
	ORI R20, 0x41
	STS TCCR1B,R20 ; rising edge, no prescaler, no noise canceller

	CALL MEASURE_PERIOD
	
	;config timer para el delay de 1 grado
	LDI R24, 0xFF 
	SUB R24, timeForOneGrade ;timeForOneGrade contiene el valor alto del tiempo del periodo. Este representaría el tiempo de un grado. Fue calculado en MEASURE_PERIOD
	OUT TCNT0, R24
	LDI R20, 0x01
		
	LDI R20, 0x00
	OUT TCCR0A, R20

	LDI R20, 0x01
	OUT TCCR0B, R20
	
	POP R24
	POP R20
	
	RET

;-------------------------------
;	Mide el periodo de una señal rectangular dado entre dos flancos ascendentes
;	Usar luego de CONFIG_TIMER
;	Devuelve en R22:R23 el periodo de la señal

MEASURE_PERIOD:
	PUSH R21
	PUSH R22
	PUSH R24

	MEASURE_PERIOD_L1:
		IN R21, TIFR1 ;timer interrupt
		;When there's an interruption, ICF1 flag is set.
		SBRS R21, ICF1 ; Skip next if ICF1 flag is set.
		RJMP MEASURE_PERIOD_L1; loop until there's an interruption (?
		LDS timeForOneGrade, ICR1L
		LDS R24, ICR1H
		OUT TIFR1, R21 ; clear ICF1
		;SBI PORTB, 5  ;Solo para pruebas

	MEASURE_PERIOD_L2:
		IN R21, TIFR1
		SBRS R21, ICF1 ; Skip next if ICF1 = 1
		RJMP MEASURE_PERIOD_L2
		SBI PORTB, 6
		OUT TIFR1, R21 ; clear ICF1
		LDS R22, ICR1L
		SUB R22, timeForOneGrade; Period = Second edge - First edge

		LDS timeForOneGrade, ICR1H
		SBC timeForOneGrade, R24; R23 = R23 - R24 - C
		;CBI PORTB, 5 ;Solo para pruebas
	CALL SET_TIME_PER_GRADE
	
	POP R21
	POP R22
	POP R24
	RET

;---------------------------------------------------
SET_TIME_PER_GRADE:
	CPI timeForOneGrade, maxSpeed ; Comparar con 0, quiere decir que la velocidad es demasiado alta
	BREQ MEASURE_PERIOD
	SBI PORTD, 7

	CPI timeForOneGrade, minSpeed
	BRSH MEASURE_PERIOD
	SBI PORTC, 0


	CALL DELAY_500_MS ; delay para hacer visible los LEDs
	CBI PORTD, 7
	CBI PORTC, 0

	RET
	

;-------------------------------
;	INTERRUPCIONES
;-------------------------------
URXC_INT_HANDLER:	
	push r16
	push r17
	push r18
	push r19
	push r20
	lds r17,UDR0	; cargo el mensaje 
	
	st X+,r17; aca lo que falta es una validacion que permita reinciar la 
			; direccion del  ram para poder volver a guardar el msj a 0x100
	pop r20
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	reti

;------------------------------
;	END
end: jmp end
