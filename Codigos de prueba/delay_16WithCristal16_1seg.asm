.include"m328pdef.inc"
.def Temp1 = r17
.def Temp2 = r18
.def Temp3 = r19
.def data = r20
.def byte = r21
.equ INPUT = 0x00 ;
.equ OUTPUT = 0xFF ;

.org 0x0000

	SBI DDRB,5	;defino pb5 como salida
PRENDO: SBI PORTB,5 ; Pongo un 1 en pb5
		call delay1s
		CBI PORTB,5
		call delay1s
		RJMP PRENDO
			;Ldi R16, 90
	;here:rjmp here

;--------------------------------------------------------------
;Rutinas de Retardo de 5ms
;--------------------------------------------------------------
; hacer un llamado tarda 5 ciclos
delay5ms:
ldi Temp1, 66 ;para 8mhz ; 1 ciclo
LOOP0:
ldi temp2, 200 ; 1 ciclo
LOOP1:
dec temp2 ; 1 ciclo
brne LOOP1 ; 1 si es falso 2 si es verdadero(verdadero quiere decir que se cumple da condicion)
dec Temp1 ; 1
brne LOOP0 ; 2
ret
;--------------------------------------------------------------


;--------------------------------------------------------------
;Rutinas de Retardo de 1s
;--------------------------------------------------------------
; hacer un llamado tarda 5 ciclos
delay1s:
     ldi  r18, 82
    ldi  r19, 43
    ldi  r20, 255
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    rjmp PC+1

ret
;--------------------------------------------------------------

