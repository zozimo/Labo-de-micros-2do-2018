;------------------------------------------------------------------------------------
;Titulo: 			De bluetooth a memoria ram
;Fecha de Creación: 4/10/2018
;Autor: 			Cristian Z. Aranda 
;Editado por:		Cristian Z. Aranda 20/11/2018
;
;
;
;
;------------------------------------------------------------------------------------

.include"m328pdef.inc"
.DEVICE ATMEGA328P



; Las siguientes constantes establecen el UBRR0L y UBRRH para definir el BAUDE RATE
.EQU	constL=0x67		;baudaje de 9600
.EQU	constH=0x00
.EQU msg_size = 54	; mensaje de 9 símbolos ascii (6 bytes cada uno)
.EQU	\r=0x0D					;\r y \n, no modificar!!!!
.EQU	\n=0x0A					;Necesarios al final de cada comando AT

.DEF	buffer=R5				;exclusivo para enviar los datos al udreo
.DEF	var1=R16


;---------	Reserva de memoria en RAM	------------
.dseg
.org 0x100

msg : .byte msg_size

.cseg
.org 0x0000

		rjmp 	main


.org URXCaddr	
		rjmp URXC_INT_HANDLER


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
		ldi XH,HIGH(msg)
		ldi XL,LOW(msg)

		call Set_ports
		call set_usart
		call prender_bluetooth
		sei							;habilito interrupcion global
		

again:		
		;cbi portb,5
		;call delay_500ms
		;sbi portb,5
		;call delay_500ms
		rjmp again















;------------------------------------RUTINAS-----------------------------------------


;------------------------------------------------------------------------------------
;							<<CONSIGNA>>
;Vamos a configurar  el usart con los siguientes paramentros:
;
;Habilitar transmision y Recepción	(en UCSR0B-->RXEN0,TXEN0)	
;Modo Asincronico					(en UCSR0C-->UMSEL0,UMSEL1)
;Tamaño de caracter(frame)= 8bits	(en UCSR0C/B-->UCSZ0,UCSZ1/UCSZ2)
;Sin paridad						(en UCSR0C-->UMSEL0,UMSEL1)
;1 bit de stop 						(en UCSR0C-->USBS0)
;Establecer un Bauderate de 9600	(en UBRR0H/UBRR0L )
;con un micro de 16MHZ(Ver formula)


set_usart:


;------------->>> Habilitar  receptor RXEN0 y habilito la interrupcion de recepcion completa RXCIE0
				;ldi r16,(1<<UDRE0)
				;STS UCSR0A,r16
				
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
;------------------------------------------------------------------------------------

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

delay_1seg:
			    ldi  r18, 82
			    ldi  r19, 43
    			ldi  r20, 0
			L2: dec  r20
    			brne L2
    			dec  r19
    			brne L2
    			dec  r18
    			brne L2
				ret	

Set_ports:		sbi ddrb,0		;PWR para modulo(digital pin 8)
				;cbi portb,0
				sbi ddrb,5		;para el led de prueba
				;ldi r16,0xFF
				;out ddrc,r16	;puerto C como salida
				;ldi r16,0x00	
				;out ddrc,r16	;Puerto C como entrada
				ret 

prender_bluetooth:
				
				in r16,portb
				sbrc r16,0
				ret
				sbi portb,0
				ret
;------------------------------------------------------------------------------------


;-------------------------------INTERRUCIONES----------------------------------------


URXC_INT_HANDLER:	push r16
					push r17
					push r18
					push r19
					push r20

					;lds r17,UCSR0A 		
					;sbrs r17,7			;salto cuando el flag se borre
					;rjmp salir
					lds r17,UDR0	; cargo el mensaje 
					cpi R17,'\r'	;\r para putty y \n para android
					breq salir					
					st X+,r17; aca lo que falta es una validacion que permita reinciar la 
							; direccion del  ram para poder volver a guardar el msj a 0x100
					
					
				;	brne salir		;salgo si no es 'c'
					;sbi portb,5
					;call delay_500ms
					;call delay_1seg
					;call delay_1seg
					;cbi portb,5
					pop r20
					pop	r19
					pop	r18
					pop	r17
					pop	r16

					reti

		salir:		call reset_RAM
					pop r20
					pop	r19
					pop	r18
					pop	r17
					pop	r16
					reti
;--------------------------------------------------------------------------------------

reset_RAM:
				ldi XH,HIGH(msg)
				ldi XL,LOW(msg)
				sbi portb,5
				call delay_1seg
				call delay_1seg
				call delay_1seg
				call delay_1seg
				cbi portb,5
				ret
				
				
				
				
				
				
				 
