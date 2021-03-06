;------------------------------------------------------------------------------------
;Titulo: 			Configuracion de usart asicronico y transmision de la palabra YES  
;					'Yes' continuamente.
;Fecha de Creaci�n: 30/10/2018
;Autor: 			Cristian Z. Aranda C.
;Editado por:
;
;
;
;
;------------------------------------------------------------------------------------

.include"m328pdef.inc"
.DEVICE ATMEGA328P



; Las siguientes constantes establecen el UBRR0L y UBRRH para definir el BAUDE RATE
.EQU	constL=0x67
.EQU	constH=0x00

.DEF	var1=R16
;.DEF	var2=R17

.cseg 
.org 0x0000
		rjmp 	main
;.org INT0addr
;		rjmp 	Handler_int_Ext0;va el nombre de la rutina a la que ejecutare en la interrupci�n
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
		
		ldi R17,'Y'
		call TRAMSTR
		ldi R17,'E'
		call TRAMSTR
		ldi R17,'S'
		call TRAMSTR
		ldi R17,' '		;transmito espacio
		call TRAMSTR
		
		sbi ddrb,5
		sbi portb,5
		call delay_500ms
		cbi portb,5
		call delay_500ms
		rjmp again



TRAMSTR:
		lds r16,UCSR0A	;Cargo de I/O extendido el registro completo
		sbrs r16,UDRE0	; siempre primero chequeo que el buffer este vacio mirando el flag UDRE0
		rjmp TRAMSTR
		sts UDR0, R17
		ret




;------------------------------------------------------------------------------------
;							<<CONSIGNA>>
;Vamos a configurar  el usart con los siguientes paramentros:
;
;Habilitar solo transmisi�n			(en UCSR0B-->RXEN0,TXEN0)	
;Modo Asincronico					(en UCSR0C-->UMSEL0,UMSEL1)
;Tama�o de caracter(frame)= 8bits	(en UCSR0C/B-->UCSZ0,UCSZ1/UCSZ2)
;Sin paridad						(en UCSR0C-->UMSEL0,UMSEL1)
;1 bit de stop 						(en UCSR0C-->USBS0)
;Establecer un Bauderate de 1200 	(en UBRR0H/UBRR0L )
;con un micro de 16MHZ(Ver formula)
;------------------------------------------------------------------------------------

set_usart:


			; Habilitar transmisor
			ldi r16, (0<<RXEN0)|(1<<TXEN0)
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

