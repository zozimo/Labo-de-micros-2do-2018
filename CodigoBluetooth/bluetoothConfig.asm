;------------------------------------------------------------------------------------
;Titulo: 			Configuración modulo Bluetooth
;Fecha de Creación: 4/10/2018
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
.EQU	constL=0x19		;baudaje de 38400
.EQU	constH=0x00
;Constantes para la configuracion del modulo bluetooth

.EQU	\r=0x0D					;\r y \n, no modificar!!!!
.EQU	\n=0x0A					;Necesarios al final de cada comando AT
.EQU	role='0'				;constante para definir el rol del bluetooth
								;role=0-->Slave, role=1-->Master, Modificar según necesidad	
.EQU	stop='0'				;stop=0-->1 bit de stop, stop=1-->2 bit de stop
.EQU	parity='0'				;parity=0--> sin paridad, parity=1-->paridad impar, parity=2-->paridad par



.DEF	buffer=R5				;exclusivo para enviar los datos al udreo
.DEF	var1=R16

.cseg 
;----------Comandos AT--------------
.org 0x500


	AT:		.dB	"AT",\r,\n	
	ATPSWD:	.dB	"AT+PSWD=9564",\r,\n	;Modificar <1234> para cambiar el password del modulo
	;AT:		.dB	"AT",\r,\n
	ATROLE:	.dB	"AT+ROLE=",role,\r,\n	;Modificar <role>  en la Parte de EQU=, para cambiar el nombre rol del bluetooth
	;AT:		.dB	"AT",\r,\n
	ATUART:	.dB	"AT+UART=9600",stop,parity,\r,\n	;Modificar stop y parity en EQU, Cambiar <9600> para el baurate									
	ATNAME:	.dB	"AT+NAME=cris",\r,\n,0xFF	;Modificar <prueba> para cambiar el nombre del bluetooth




.org 0x0000

		rjmp 	main

.org UDREaddr		
		rjmp UDRE_INT_HANDLER


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

		ldi ZH,HIGH(AT<<1)
		ldi ZL,LOW(AT<<1)		

		call Set_ports
		call set_usart
		sei							;habilito interrupcion global
		

again:		
		cbi portb,5
		call delay_500ms
		sbi portb,5
		call delay_500ms
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
;Establecer un Bauderate de 38400	(en UBRR0H/UBRR0L )
;con un micro de 16MHZ(Ver formula)


set_usart:


;------------->>> Habilitar  receptor RXEN0 y habilito la interrupcion de recepcion completa RXCIE0
				;ldi r16,(1<<UDRE0)
				;STS UCSR0A,r16
				
				ldi r16, (0<<RXEN0)|(1<<TXEN0)|(1<<UDRIE0)|(0<<TXCIE0); agrego interrupcion de transmision completa
				STS UCSR0B,r16; No se puede usar OUT pues UCSR0B esta en la memoria extendida.

				;Tamaño de caracter(frame)= 8bits + 1 bit de stop
				ldi r16, (1<<UCSZ00)|(1<<UCSZ01)|(0<<USBS0)
				STS UCSR0C,r16

				;Establecer un Bauderate de 38400 con clock 16MHZ
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

;------------------------------------------------------------------------------------

;En vez de hacer polling de RXC0 para ver si esta en alto uso la interrupcion 

UDRE_INT_HANDLER:	
					push r16
					push r17
					push r18
					push r19
					push r20
					;ponemos un delay de 4 seg para entrar en modo comandos
					;sbi portb,5
					
					call delay_1seg
					call delay_1seg
					;cbi portb,5
					;-------------------------------------------------------
					;prender bluetooth ver como prender una sola vez
					call prender_bluetooth
					

					;call delay_1seg
					;call delay_1seg
					;call delay_1seg
					;call delay_1seg
					;--------------------------------------------------------
					ldi r16,0xFF
					
		send_AT:	lpm buffer,Z+		;cargo los comandos AT 
					cp buffer,r16
					brne send
					;desactivo la interrupcion para que que no envie el mjs indefinidamente
					ldi r16, (1<<RXEN0)|(1<<TXEN0)|(0<<UDRIE0)|(0<<TXCIE0); agrego interrupcion de transmision completa
					STS UCSR0B,r16
					pop r20
					pop	r19
					pop	r18
					pop	r17
					pop	r16
					;sbi portb,5
					;call delay_1seg
					;call delay_1seg
					;call delay_1seg
					;call delay_1seg
					;cbi portb,5
					;call delay_1seg
					;call delay_1seg
					;call delay_1seg
					;call delay_1seg
					
					reti
		
		send:		
					sts UDR0,buffer
					
					;sbi portb,5
					;call delay_500ms
					;call delay_1seg
					;cbi portb,5
					pop r20
					pop	r19
					pop	r18
					pop	r17
					pop	r16
					reti

;------------------------------------------------------------------------------------

prender_bluetooth:
				
				in r16,portb
				sbrc r16,0
				ret
				sbi portb,0
				ret

