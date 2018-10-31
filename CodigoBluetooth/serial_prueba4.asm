;------------------------------------------------------------------------------------
;Titulo: 			Configuracion de usart asicronico + Transmisión y Recepción 
;
;Resumen:			Este programa envia la palabra YES A la PC, luego obtiene datos 
;					del los switches del puerto C, y transmite eso via el puerto serial 
;					a la pantalla de la PC, por último recibe una pulsacion de teclado
;					enviandolo por hyperterminal y los pone en los led's del puerto D, los 
;					dos ultimos pasos se realizan repetidamente.
;
;Fecha de Creación: 31/10/2018
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
		
		call Set_ports
		call set_usart
;Primero transimito Yes
		
		ldi R17,'Y'
		call TRAMSTR
		ldi R17,'E'
		call TRAMSTR
		ldi R17,'S'
		call TRAMSTR
		

again:	
		call recepAndTrans				
				
		sbi portb,5
		call delay_500ms
		cbi portb,5
		call delay_500ms
		rjmp again















;------------------------------------RUTINAS-----------------------------------------

;------------------------------------------------------------------------------------

recepAndTrans:
				lds r16,UCSR0A
				sbrs r16,RXC0	; hay algun byte en UDR para ser recibido?? osea RXC0=1
				rjmp NO_RECIBO	; me salto esto si  recibi algo
				lds r17,UDR0	; cargo el mensaje 
				out	portd,r17	; saco el msj por el puerto d (LEDS)
				


NO_RECIBO:
				lds r16,UCSR0A		;Cargo de I/O extendido el registro completo
				sbrs r16,UDRE0		; siempre primero chequeo que el buffer este vacio mirando el flag UDRE0 para poder transmitir	
				rjmp NO_TRANSMITO	; me salto esto si tengo algo que transmitir
				in r17,pinc
				sts UDR0, R17
				
NO_TRANSMITO:	ret
;------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------
TRAMSTR:
		lds r16,UCSR0A	;Cargo de I/O extendido el registro completo
		sbrs r16,UDRE0	; siempre primero chequeo que el buffer este vacio mirando el flag UDRE0
						; en general en el micro este el buffer esta vacio entonces este bit esta en alto
		rjmp TRAMSTR
		sts UDR0, R17
		ret
;------------------------------------------------------------------------------------


;------------------------------------------------------------------------------------
;							<<CONSIGNA>>
;Vamos a configurar  el usart con los siguientes paramentros:
;
;Habilitar solo Recepción		(en UCSR0B-->RXEN0,TXEN0)	
;Modo Asincronico					(en UCSR0C-->UMSEL0,UMSEL1)
;Tamaño de caracter(frame)= 8bits	(en UCSR0C/B-->UCSZ0,UCSZ1/UCSZ2)
;Sin paridad						(en UCSR0C-->UMSEL0,UMSEL1)
;1 bit de stop 						(en UCSR0C-->USBS0)
;Establecer un Bauderate de 9600	(en UBRR0H/UBRR0L )
;con un micro de 16MHZ(Ver formula)
;------------------------------------------------------------------------------------

set_usart:


				; Habilitar transmisor y receptor
				ldi r16, (1<<RXEN0)|(1<<TXEN0)
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

Set_ports:		
				sbi ddrb,5		;para el led de prueba
				ldi r16,0xFF
				out ddrd,r16	;puerto D como salida
				ldi r16,0x00	;para sacar los datos
				out ddrc,r16	;Puerto C como entrada
				ret 




