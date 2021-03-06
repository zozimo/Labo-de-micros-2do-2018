/*
------------------------------------------------
TRABAJO PR�CTICO INTEGRADOR
Laboratorio de microprocesadores (86.07)
Facultad de Ingenier�a - Universidad de Buenos Aires
Proyecto: Display POV
Autores: Aranda Cordero,Cristian Z.- Carrero Riveros, Daniela - Gonz�lez, Pablo Javier.
2do cuatrimestre 2018
------------------------------------------------
*/
; Archivo principal

.include"m328pdef.inc"
.device atmega328p

.DEF input_reg = R16 ;

.EQU msg_size = 36	; mensaje preconfigurado de 6 s�mbolos ascii (6 bytes cada uno)

; Las siguientes constantes establecen el UBRR0L y UBRRH para definir el BAUDE RATE
.EQU	constL=0x67		;baudaje de 9600
.EQU	constH=0x00		;baudaje de 9600
.EQU	\r=0x0D					;\r y \n, no modificar!!!!
.EQU	\n=0x0A					;Necesarios al final de cada comando AT
.DEF	buffer=R5				;exclusivo para enviar los datos al udreo

.DEF	timeForOneGradeReg=R23

.EQU	maxSpeed=0x00 ;constantes para validar la velocidad minima y maxima del 
.EQU	minSpeed=0xF0

.EQU	initial_position=220	; valor del angulo inicial


;---------	Reserva de memoria en RAM	------------
.dseg
.org SRAM_START
	msg : .byte msg_size	; Reserva de RAM para el mensaje preconfigurado

;------------------------------------------------

.cseg
.ORG 0x600

DICCIONARIO:
/*	SPACE_MK:	.db 0x00,0x00,0x00,0x00,0x00,0 
	EXCL_MK:	.db 0x00,0x00,0xFA,0x00,0x00,0 
	DTILE_MK:	.db 0x00,0x00,0xC0,0xC0,0x00,0 
	NUMERAL_MK:	.db 0x00,0x00,0x00,0x00,0x00,0 
	DOLLAR_MK:	.db 0x24,0x52,0xFE,0x52,0x4C,0 
	PERCENT_MK:	.db 0x02,0x4C,0x10,0x64,0x80,0 
	AMPER_MK:	.db 0x6C,0x92,0x92,0x6C,0x12,0 
	TILE_MK:	.db 0x00,0x00,0xC0,0x00,0x00,0 
	LPAR_MK:	.db 0x00,0x7E,0x82,0x00,0x00,0 
	RPAR_MK:	.db 0x00,0x00,0x82,0x7E,0x00,0 
	STAR_MK:	.db 0x14,0x18,0x70,0x18,0x14,0 
	PLUS_MK:	.db 0x00,0x10,0x38,0x10,0x00,0 
	COMA_MK:	.db 0x00,0x00,0x06,0x00,0x00,0 
	DASH_MK:	.db 0x00,0x10,0x10,0x10,0x00,0 
	SDOT_MK:	.db 0x00,0x00,0x02,0x00,0x00,0 
	SLASH_MK:	.db 0x02,0x02,0x10,0x60,0x80,0 
	CERO_NUM:	.db 0x7C,0x86,0x92,0xC2,0x7C,0 
	ONE_NUM:	.db 0x20,0x40,0xFE,0x00,0x00,0 
	TWO_NUM:	.db 0x62,0x86,0x8A,0x92,0x62,0 
	THREE_NUM:	.db 0x44,0x82,0x92,0x92,0x6C,0 
	FOUR_NUM:	.db 0xF0,0x10,0x10,0xFE,0x10,0 
	FIVE_NUM:	.db 0xE4,0xA2,0xA2,0xA2,0x9C,0 
	SIX_NUM:	.db 0x3C,0x52,0x92,0x12,0x0C,0 
	SEVEN_NUM:	.db 0x80,0x90,0x9C,0xB0,0xC0,0 
	EIGHT_NUM:	.db 0x6C,0x92,0x92,0x92,0x6C,0 
	NINE_NUM:	.db 0x60,0x90,0x90,0x90,0x7E,0 
	DDOT_MK:	.db 0x00,0x00,0x12,0x00,0x00,0 
	DOTCOMA_MK:	.db 0x00,0x00,0x16,0x00,0x00,0 
	MINOR_MK:	.db 0x10,0x28,0x44,0x82,0x00,0 
	EQUAL_MK:	.db 0x00,0x12,0x12,0x12,0x00,0 
	GREATER_MK:	.db 0x00,0x82,0x44,0x28,0x10,0 
	ASK_MK:		.db 0x60,0x80,0x9A,0x90,0x60,0 
	AT_MK:		.db 0x3C,0x42,0x5C,0x54,0x3C,0 */
	A_LETTER:	.db 0x7E,0x90,0x90,0x90,0x7E,0 
	B_LETTER: 	.db 0xFE,0x92,0x92,0xF2,0x0E,0 
	C_LETTER:	.db 0xFE,0x82,0x82,0x82,0x82,0 
	D_LETTER: 	.db 0xFE,0x82,0x82,0x82,0x7C,0 
	E_LETTER: 	.db 0xFE,0x92,0x92,0x92,0x82,0 
	F_LETTER: 	.db 0xFE,0x90,0x90,0x90,0x80,0 
	G_LETTER: 	.db 0x7C,0x82,0x92,0x92,0x9C,0 
	H_LETTER: 	.db 0xFE,0x10,0x10,0x10,0xFE,0 
	I_LETTER: 	.db 0x00,0x00,0xFE,0x00,0x00,0 
	J_LETTER: 	.db 0x8E,0x82,0xFE,0x80,0x80,0 
	K_LETTER: 	.db 0xFE,0x10,0x28,0x44,0x82,0 
	L_LETTER: 	.db 0xFE,0x02,0x02,0x02,0x02,0 
	M_LETTER: 	.db 0xFE,0x60,0x30,0x60,0xFE,0 
	N_LETTER: 	.db 0xFE,0x06,0x18,0x06,0xFE,0 
	O_LETTER: 	.db 0x7C,0x82,0x82,0x82,0x7C,0 
	P_LETTER: 	.db 0xFE,0x90,0x90,0x90,0x60,0 
	Q_LETTER:	.db 0x7C,0x82,0x8A,0x86,0x7E,0 
	R_LETTER: 	.db 0xFE,0x90,0x98,0x94,0x62,0 
	S_LETTER:	.db 0x64,0x92,0x92,0x92,0x4C,0 
	T_LETTER: 	.db 0x80,0x80,0xFE,0x80,0x80,0 
	U_LETTER: 	.db 0xFC,0x02,0x02,0x02,0xFC,0 
	V_LETTER: 	.db 0xC0,0x38,0x0E,0x38,0xC0,0 
	W_LETTER: 	.db 0xFE,0x06,0x30,0x06,0xFE,0 
	X_LETTER: 	.db 0xC6,0x6C,0x10,0x6C,0xC6,0 
	Y_LETTER: 	.db 0x80,0x40,0x3E,0x40,0x80,0 
	Z_LETTER: 	.db 0x86,0x9A,0x92,0xB2,0xC2,0 


;---------		Mensaje preconfigurado		---------		

testing_msg: .db "HOLA",\n,0

;---------	Configuraci�n de interrupciones	---------

.ORG 0x00 ;Comienzo del c�digo en la posici�n 0
	jmp main	;

.org ICP1addr
	JMP ICP1_INTERRUPT

.org URXCaddr	
	jmp URXC_INT_HANDLER ; interrupcion de recepcion por Bluetooth


.ORG INT_VECTORS_SIZE


;------------------------------------------------
;	RUTINAS PRINCIPAL
;------------------------------------------------

main:
	;inicializa el SP
	LDI R17, HIGH(RAMEND) ; Carga el SPH
	OUT SPH, R17
	LDI R17, LOW(RAMEND) ;Carga el SPL
	OUT SPL, R17

	; configuraci�n de pines conectados a los LEDs
	LDI R17, 0x0F
	OUT DDRC,R17	; C0...C3 como salidas
	SWAP R17
	OUT DDRD,R17	; D4...D7 como salidas

	CALL ST_MSG_TO_RAM	; carga de mensaje preconfigurado
	CALL BLUETOOTH_TO_RAM	;configuraci�n de uso de Bluetooth
	
	CALL CONFIG_TIMER	; configuraci�n de timers, medici�n y validaci�n de velocidad de giro

	SEI		; habilitaci�n de interrupciones globales

here:	
	JMP here
	

;------------------------------------------------
;	RUTINAS DE MANEJO DE DICCIONARIO
;------------------------------------------------
; recibe en Z la posici�n de la columna a imprimir
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
;posici�n de la letra = DICCIONARIO + (input_reg -'A')*6

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
	;call DELAY_1_GRADE
	CALL DELAY_DOT_SPACE
	CALL PRINT_COL	; 2da columna
	;call DELAY_1_GRADE
	CALL DELAY_DOT_SPACE
	CALL PRINT_COL	; 3er columna
	;call DELAY_1_GRADE
	CALL DELAY_DOT_SPACE
	CALL PRINT_COL	; 4ta columna
	;call DELAY_1_GRADE
	CALL DELAY_DOT_SPACE
	CALL PRINT_COL	; 5ta columna
	;call DELAY_1_GRADE
	CALL DELAY_DOT_SPACE
	CALL PRINT_COL	; 6ta columna (columna vacia)
	;call DELAY_1_GRADE
	CALL DELAY_DOT_SPACE

	POP R18
	POP input_reg
	RET

;------------------------------------------------
;	lee de RAM una frase e imprime letra por letra
;	usa input_reg para cada letra individual

PRINT_MSG:
	
	LDI XH, HIGH(msg)	; variable para desplazarse en el mensaje en RAM
	LDI XL, LOW(msg)
	PRINT_MSG_LOOP:
		LD input_reg, X+	; leer letra de RAM
		CPI input_reg,0x00	; validacion contra fin de cadena
		BREQ PRINT_MSG_END
		CPI input_reg,0xFF	; validacion contra fin de cadena
		BREQ PRINT_MSG_END
		CPI input_reg,\r	; validacion contra fin de cadena
		BREQ PRINT_MSG_END
		CPI input_reg,\n	; validacion contra fin de cadena
		BREQ PRINT_MSG_END
		CALL PRINT_LETTER	; imprimir letra
		JMP PRINT_MSG_LOOP

	PRINT_MSG_END:
		RET

;------------------------------------------------
; guarda un mensaje desde FLASH a RAM
; usado para cargar el mensaje preconfigurado

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
;	Delay de 1 grado que va a ser utilizado para generar delays de cierta cantidad de grados 
;	Es un delay din�mico basado en el periodo medido

DELAY_1_GRADE:
		PUSH R20

		IN R20, TIFR0
		SBRS R20, TOV0 ; saltar sigueinte instruccion si T0V0 flag est� seteado
		RJMP DELAY_1_GRADE
		LDS R20, TCCR0B
		ANDI R20, 0x30 ; stop timer
		STS TCCR1B,R20
		LDI R20, (1<<TOV0)
		OUT TIFR0, R20 ; clear T0V0 flag escribiendo 1 en TIFR

		POP R20
	RET

;-------------------------------------------------
;	Delay usado solo para visualizar validaci�n de velocidad

DELAY_500_MS:
		push r18
		push r19
		push r20

		ldi  r18, 41
	    ldi  r19, 150
	    ldi  r20, 128
	LOOP_DELAY_500_MS:
			dec  r20
		    brne LOOP_DELAY_500_MS
		    dec  r19
		    brne LOOP_DELAY_500_MS
		    dec  r18
		    brne LOOP_DELAY_500_MS

		pop r20
		pop r19
		pop r18	

		ret

;------------------------------------------------
; espera el tiempo correspondiente al espacio entre columnas de una letra
; delay fijo de 599,5 us a 16 MHz

DELAY_DOT_SPACE:
	    ldi  r22, 13
	    ldi  r23, 116
	LOOP_DOT_SPACE:
		dec  r23
	    brne LOOP_DOT_SPACE
	    dec  r22
	    brne LOOP_DOT_SPACE
	    nop
	RET

;------------------------------------------------
; delay usado para desplazar el angulo inicial del display

DELAY_INITIAL_POSITION:
	;ldi R20,(initial_position>>1); divido por 2 la posici�n inicial a pedido de Pablo
	ldi R20, initial_position
	loop:
		DEC R20
		;call DELAY_1_GRADE		; delay din�mico
		call DELAY_DOT_SPACE	; delay fijo
		CPI R20, 0
		BRNE LOOP

	ret


;------------------------------------------------
;	RUTINAS DE BLUETOOTH
;------------------------------------------------
;	Rutina general de configuraci�n de Bluetooth

BLUETOOTH_TO_RAM:
	ldi YH,HIGH(msg)
	ldi YL,LOW(msg)

	call Set_ports
	call set_usart
	call prender_bluetooth
	ret

;-----------------------------------------------------------
;	CONFIGURACION DE BLUETOOTH
;Habilitar transmision y Recepci�n	(en UCSR0B-->RXEN0,TXEN0)	
;Modo Asincronico					(en UCSR0C-->UMSEL0,UMSEL1)
;Tama�o de caracter(frame)= 8bits	(en UCSR0C/B-->UCSZ0,UCSZ1/UCSZ2)
;Sin paridad						(en UCSR0C-->UMSEL0,UMSEL1)
;1 bit de stop 						(en UCSR0C-->USBS0)
;Establecer un Bauderate de 9600	(en UBRR0H/UBRR0L )
;con un micro de 16MHZ(Ver formula)
;-----------------------------------------------------------

set_usart:
;--->>> Habilitar  receptor RXEN0 y habilito la interrupcion de recepcion completa RXCIE0
	
	ldi r16, (1<<RXEN0)|(1<<TXEN0)|(0<<UDRIE0)|(0<<TXCIE0)|(1<<RXCIE0); agrego interrupcion de transmision completa
	STS UCSR0B,r16; No se puede usar OUT pues UCSR0B esta en la memoria extendida.

	;Tama�o de caracter(frame)= 8bits + 1 bit de stop
	ldi r16, (1<<UCSZ00)|(1<<UCSZ01)|(0<<USBS0)
	STS UCSR0C,r16

	;Establecer un Bauderate de 9600 con clock 16MHZ
	ldi r16, constL
	STS	UBRR0L,r16
	ldi r16, constH
	STS	UBRR0H,r16
	ret

;------------------------------------------------

Set_ports:		
	sbi ddrb,2		;PWR para modulo(digital pin 8)
;	sbi ddrb,5		;para el led de prueba
	ret 

;------------------------------------------------

prender_bluetooth:
	in r16,portb
	sbrc r16,2
	ret
	sbi portb,2
	ret

;------------------------------------------------
; Rutina para reiniciar la posicion en RAM y sobreescribir el mensaje

reset_RAM:
	ldi YH,HIGH(msg)
	ldi YL,LOW(msg)
	ret

;-------------------------------
;	RUTINAS DE TIMER
;-------------------------------
; Configuraci�n de los timers utilizados en el proyecto
; Timer 1 para medir periodo
; Timer 0 para establecer delay de un grado basado en el valor del periodo obtenido

CONFIG_TIMER:
	PUSH R20
	PUSH R24
	
	;Configura pin B.O como entrada para la interrupci�n de captura (�CP1)
	CBI DDRB, 0
	
	;-------------------------------------
	;Config timer para medir el periodo
	LDS R20, TIMSK1  ;Activa interrupcion del timer al capturar se�al del pin B.0
	ORI R20, 0x20
	STS TIMSK1, R20 
			
	LDS R20, TCCR1A
	ANDI R20, 0x0C
	STS TCCR1A, R20 ; Setear timer como modo normal

	LDS R20, TCCR1B
	ORI R20, 0x43	; flanco ascendente, prescaler 64, cancelador de ruido
	;ORI R20, 0x41	; flanco ascendente, sin prescaler, cancelador de ruido
	STS TCCR1B,R20 
	;-------------------------------------

	CALL MEASURE_PERIOD
	
	;-------------------------------------
	;config timer para el delay de 1 grado
	LDI R24, 0xFF 
	SUB R24, timeForOneGradeReg ;timeForOneGradeReg contiene el valor alto del tiempo del periodo. Este representar�a el tiempo de un grado. Fue calculado en MEASURE_PERIOD
	OUT TCNT0, R24
		
	LDI R20, 0x00
	OUT TCCR0A, R20

	LDI R20, 0x03	; prescaler 64
	;LDI R20, 0x01	; sin prescaler
	
	OUT TCCR0B, R20
	;-------------------------------------
	
	POP R24
	POP R20
	RET

;-------------------------------
; Mide el periodo de una se�al rectangular dado entre dos flancos ascendentes
; Usar luego de CONFIG_TIMER
; Devuelve en R23:R22 el periodo de la se�al

MEASURE_PERIOD:
	PUSH R21
	PUSH R22
	PUSH R24

	MEASURE_PERIOD_L1:
	;Se espera a obtener el primer flanco ascendente para la se�al del sensor Hall
		IN R21, TIFR1 ;Registro de interrupci�n del timer
		;Cuando hay una interrupci�n en ICP1, el flag ICF1 se activa (dentro del registro TIFR1).
		SBRS R21, ICF1 ; Saltea la siguiente instrucci�n si ICF1 flag est� activado.
		RJMP MEASURE_PERIOD_L1; loop hasta que hay una interrupci�n (Espera al momento en que el sensor hall pasa por el iman) 
		LDS timeForOneGradeReg, ICR1L
		LDS R24, ICR1H
		OUT TIFR1, R21 ; clear ICF1 (para luego detectar una nueva interrupci�n)
		;SBI PORTB, 5  ;Solo para pruebas

	MEASURE_PERIOD_L2:
	;Se espera a obtener el segundo flanco ascendente para la se�al del sensor Hall
		IN R21, TIFR1
		SBRS R21, ICF1 ; Saltea la siguiente instrucci�n si ICF1 = 1
		RJMP MEASURE_PERIOD_L2
		SBI PORTB, 6
		OUT TIFR1, R21 ; clear ICF1
		LDS R22, ICR1L
		SUB R22, timeForOneGradeReg; Periodo = segundo flanco - primer flanco

		LDS timeForOneGradeReg, ICR1H ;Este registro ser� utilizado para validar la velocidad del POV. 
		SBC timeForOneGradeReg, R24; R23 = R23 - R24 - C
		;CBI PORTB, 5 ;Solo para pruebas
	CALL SET_TIME_PER_GRADE
	
	POP R21
	POP R22
	POP R24
	RET

;---------------------------------------------------
; Rutina para validar la velocidad del POV -> a qu� velocidad empieza a imprimir el mensaje.
; Se establecen velocidades m�ximas y m�nimas
; Usar luego de MEASURE_PERIOD

SET_TIME_PER_GRADE:

	SBI PORTC, 0
	LDI R20, minSpeed ;Compara con un valor determinado para establecer una velocidad minima
	CP R20, timeForOneGradeReg
	BRSH MEASURE_PERIOD

	SBI PORTD, 7
	CPI timeForOneGradeReg, maxSpeed ; Comparar con 0, quiere decir que la velocidad es demasiado alta
	BREQ MEASURE_PERIOD

	CALL DELAY_500_MS ; delay para hacer visible los LEDs
	CBI PORTD, 7
	CBI PORTC, 0

	RET
	

;-------------------------------
;	INTERRUPCIONES
;-------------------------------
ICP1_INTERRUPT:
	SEI
	call DELAY_INITIAL_POSITION
	;---Desactiva interrupci�n del sensor hall---
	LDS R20, TIMSK1 
	ANDI R20, 0xD8
	STS TIMSK1, R20 
	;--------------------------------------------
	
	CALL PRINT_MSG
	;---Activa interrupci�n del sensor hall---
	LDS R20, TIMSK1 
	ORI R20, 0x20
	STS TIMSK1, R20 
	;--------------------------------------------
	RETI

;-------------------------------
URXC_INT_HANDLER:	
	push r16
	push r17
	push r18
	push r19
	push r20

	lds r17,UDR0	; cargo el mensaje 
	;st Y+,r17
	cpi R17,\r	;\r para putty
	breq END_BLUETOOTH_MSG	
	cpi R17,\n	;\n para android
	breq END_BLUETOOTH_MSG	
					
	st Y+,r17

	pop r20
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	reti

	END_BLUETOOTH_MSG:	
		st Y+,r17; guardo el \n en la RAM
			
		call reset_RAM
		pop r20
		pop	r19
		pop	r18
		pop	r17
		pop	r16
		reti

;------------------------------
