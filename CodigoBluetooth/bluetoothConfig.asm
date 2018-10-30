;------------------------------------------------------------------------------------
;Titulo: 			Configuración Bluetooth
;Fecha de Creación: 29/10/2018
;Autor: 			Cristian Z. Aranda C.
;Editado por:
;
;
;
;
;------------------------------------------------------------------------------------

.include"m328pdef.inc"


;.device Atmega238p

;.EQU	const1=10
;.EQU	const2=20
.DEF	var1=R16
;.DEF	var2=R17

.cseg 
.org 0x0000
		rjmp 	main
.org INT0addr
		rjmp 	Handler_int_Ext0;va el nombre de la rutina a la que ejecutare en la interrupción
.org INT1addr
		rjmp 	Handler_int_Ext1


.org INT_VECTORS_SIZE
main:
		;Inicilizar el stack
		ldi var1, LOW(RAMEND)
		out SPL,var1
		ldi var1, HIGH(RAMEND)
		out SPH,var1


jmp main










Handler_int_Ext0: jmp Handler_int_Ext0
Handler_int_Ext1: jmp Handler_int_Ext1



