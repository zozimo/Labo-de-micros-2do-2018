;------------------------------------------------------------------------------------
;Titulo: 			Configuracion de usart asicronico y transmision de la letra 'G'
;Fecha de Creación: 30/10/2018
;Autor: 			Cristian Z. Aranda C.
;Editado por:
;
;
;
;
;------------------------------------------------------------------------------------

.include"m328pdef.inc"
.DEVICE ATMEGA328P




;.EQU	const1=10
;.EQU	const2=20
.DEF	var1=R16
;.DEF	var2=R17

.cseg 
.org 0x0000
		rjmp 	main
;.org INT0addr
;		rjmp 	Handler_int_Ext0;va el nombre de la rutina a la que ejecutare en la interrupción
;.org INT1addr
;		rjmp 	Handler_int_Ext1


.org INT_VECTORS_SIZE


	 
main:

		;Inicilizar el stack
		ldi var1, LOW(RAMEND)
		out SPL,var1
		ldi var1, HIGH(RAMEND)
		out SPH,var1

		call set_usart
;Transmitimos la letra G continuamente validando que el buffer este vacio
again:	
		lds r16,UCSR0A
		sbrs r16,UDRE0		;salta si el buffer de transmision esta vacio UDRE0=1
		rjmp again			;polling
		ldi R17,'G'
		sts UDR0, R17
		sbi ddrb,5
		sbi portb,5
		call delay_500ms
		cbi portb,5
		call delay_500ms
		rjmp again

jmp main






;------------------------------------------------------------------------------------
;							<<CONSIGNA>>
;Vamos a configurar  el usart con los siguientes paramentros
;Habilitar recepción y transmisión	(en UCSR0B-->RXEN0,TXEN0)	
;Modo Asincronico					(en UCSR0C-->UMSEL0,UMSEL1)
;Tamaño de caracter(frame)= 8bits	(en UCSR0C/B-->UCSZ0,UCSZ1/UCSZ2)
;Sin paridad						(en UCSR0C-->UMSEL0,UMSEL1)
;2 bit de stop 
;Establecer un Bauderate de 1200 	(en UBRR0H/UBRR0L )
;con un micro de 16MHZ(Ver formula)
;------------------------------------------------------------------------------------

set_usart:


			; Habilitar receptor y transmisor
			ldi r16, (1<<RXEN0)|(1<<TXEN0)
			STS UCSR0B,r16; No se puede usar OUT pues UCSR0B esta en la memoria extendida.

			;Tamaño de caracter(frame)= 8bits + 2 bit de stop
			ldi r16, (1<<UCSZ00)|(1<<UCSZ01)|(1<<USBS0)
			STS UCSR0C,r16

			;Establecer un Bauderate de 1200 con clock 16MHZ
			ldi r16, 0x40
			STS	UBRR0L,r16
			ldi r16, 0x03
			STS	UBRR0H,r16
			ret


delay_500ms:
			    ldi  r18, 41
    			ldi  r19, 150
   				ldi  r20, 126
				L1: dec  r20
    			brne L1
  				dec  r19
				brne L1
				dec  r18
				brne L1
				rjmp PC+1
				ret

