;------------------------------------------------------------------------
;
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2017/2018
;
;
;	Lê uma string e escreve noutra zona do ecrã
;	simultaneamente actualiza a hora e data no ecrã
;
;		press ESC to exit
;------------------------------------------------------------------------
; MACROS
;------------------------------------------------------------------------
;MACRO GOTO_XY
; COLOCA O CURSOR NA POSIÇÃO time_POSx,time_POSy
;	time_POSx -> COLUNA
;	time_POSy -> LINHA
; 	REGISTOS USADOS
;		AH, BH, DL,DH (DX)
;------------------------------------------------------------------------
GOTO_XY		MACRO	time_POSx,time_POSy
			MOV	AH,02H
			MOV	BH,0
			MOV	DL,time_POSx
			MOV	DH,time_POSy
			INT	10H
ENDM

; MOSTRA - Faz o display de uma string terminada em $
;---------------------------------------------------------------------------
MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM
; FIM DAS MACROS

.8086
.model small
.stack 2048h

PILHA	SEGMENT PARA STACK 'STACK'
		db 2048 dup(?)
PILHA	ENDS
	

DSEG    SEGMENT PARA PUBLIC 'DATA'

	
	
		STR12	 		DB 		"            "	; String para 12 digitos	
		NUMERO		DB		"                    $", 	; String destinada a guardar o número lido
		Segundos		dw		0				; Vai guardar os segundos actuais
		Old_seg		dw		0				; Guarda os últimos segundos que foram lidos
				

		time_POSy	db	10	; a linha pode ir de [1 .. 25]
		time_POSx	db	40	; time_POSx pode ir [1..80]	
		NUMDIG	db	0	; controla o numero de digitos do numero lido
		MAXDIG	db	4	; Constante que define o numero MAXIMO de digitos a ser aceite


DSEG    ENDS

CSEG    SEGMENT PARA PUBLIC 'CODE'
	ASSUME  CS:CSEG, DS:DSEG, SS:PILHA
	
	
dec_second PROC

MOV     CX, 0FH
MOV     DX, 4240H
MOV     AH, 86H
INT     15H



endp dec_second


MENU    Proc

endp MENU
cseg	ends
end     MENU