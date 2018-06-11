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
; COLOCA O CURSOR NA POSIÇÃO POSX,POSY
;	POSX -> COLUNA
;	POSY -> LINHA
; 	REGISTOS USADOS
;		AH, BH, DL,DH (DX)
;------------------------------------------------------------------------
GOTO_XY		MACRO	POSX,POSY
			MOV	AH,02H
			MOV	BH,0
			MOV	DL,POSX
			MOV	DH,POSY
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
		
	
		NUM_SP		db		"                    $" 	; PAra apagar zona de ecran
		DDMMAAAA 		db		"                     "

		Horas			dw		0				; Vai guardar a HORA actual
		Minutos		dw		0				; Vai guardar os minutos actuais
		Segundos		dw		0				; Vai guardar os segundos actuais
		Timer		dw		60
		Old_seg		dw		0				; Guarda os últimos segundos que foram lidos
				

		POSy	db	10	; a linha pode ir de [1 .. 25]
		POSx	db	40	; POSx pode ir [1..80]	
		NUMDIG	db	0	; controla o numero de digitos do numero lido
		MAXDIG	db	4	; Constante que define o numero MAXIMO de digitos a ser aceite


DSEG    ENDS

CSEG    SEGMENT PARA PUBLIC 'CODE'
	ASSUME  CS:CSEG, DS:DSEG, SS:PILHA
	
	
;********************************************************************************
;********************************************************************************
; HORAS  - LE Hora DO SISTEMA E COLOCA em tres variaveis (Horas, Minutos, Segundos)
; CH - Horas, CL - Minutos, DH - Segundos
;********************************************************************************	

Ler_TEMPO PROC	
 
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		; guarda segundos na variavel correspondente

		POPF
		POP DX
 		RET 
Ler_TEMPO   ENDP 




;********************************************************************************
;********************************************************************************
;ROTINA PARA APAGAR ECRAN

APAGA_ECRAN	PROC
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH SI
		XOR	BX,BX
		MOV	CX,24*80
		mov bx,160
		MOV SI,BX
APAGA:	
		MOV	AL,' '
		MOV	BYTE PTR ES:[BX],AL
		MOV	BYTE PTR ES:[BX+1],7
		INC	BX
		INC BX
		INC SI
		LOOP	APAGA
		POP SI
		POP CX
		POP AX
		POP BX
		RET
APAGA_ECRAN	ENDP
;********************************************************************************
;********************************************************************************
; LEITURA DE UMA TECLA DO TECLADO 
; LE UMA TECLA	E DEVOLVE VALOR EM AH E AL
; SE ah=0 É UMA TECLA NORMAL
; SE ah=1 É UMA TECLA EXTENDIDA
; AL DEVOLVE O CÓDIGO DA TECLA PREMIDA
LE_TECLA	PROC
sem_tecla:
		call Trata_Horas
		MOV	AH,0BH
		INT 21h
		cmp AL,0
		je	sem_tecla
		
		goto_xy	POSx,POSy
		
		MOV	AH,08H
		INT	21H
		MOV	AH,0
		CMP	AL,0
		JNE	SAI_TECLA
		MOV	AH, 08H
		INT	21H
		MOV	AH,1
SAI_TECLA:	
		RET
LE_TECLA	ENDP




;********************************************************************************
;********************************************************************************
; Imprime o tempo e a data no monitor

Trata_Horas PROC

		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		

		CALL 	Ler_TEMPO				; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, Segundos
		cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
		je		fim_horas			; Se a hora não mudou desde a última leitura sai.
		mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 
		
		GOTO_XY	20,10
		MOV AX, Timer
		DEC AX
		MOV Timer, AX
		MOV bl, 10
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'s'		
		MOV 	STR12[3],'$'
		
		MOSTRA	STR12 
		
	

				
        
						
fim_horas:
		
		
		
		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
		
		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		RET		
			
Trata_Horas ENDP


;########################################################################

teclanum  proc
		mov	ax, dseg
		mov	ds,ax
		mov	ax,0B800h
		mov	es,ax		; es é ponteiro para mem video

NOVON:	
		mov		NUMDIG, 0			; inícia leitura de novo número
		mov		cx, 20
		XOR		BX,BX
LIMPA_N: 	
		mov		NUMERO[bx], ' '	
		inc		bx
		loop 	LIMPA_N
		
		mov		al, 20
		mov		POSx,al
		mov		al, 10
		mov		POSy,al				; (POSx,POSy) é posição do cursor
		goto_xy	POSx,POSy
		MOSTRA	NUM_SP	

CICLO:	goto_xy	POSx,POSy
	

		call 	LE_TECLA		; lê uma nova tecla
		cmp		ah,1			; verifica se é tecla extendida
		je		ESTEND
		CMP 	AL,27			; caso seja tecla ESCAPE sai do programa
		JE		FIM
		CMP 	AL,13			; Pressionando ENTER vai para OKNUM
		JE		OKNUM		
		CMP 	AL,8			; Teste BACK SPACE <- (apagar digito)
		JNE		NOBACK
		mov		bl,NUMDIG		; Se Pressionou BACK SPACE 
		CMP		bl,0			; Verifica se não tem digitos no numero
		JE		NOBACK			; se não tem digitos continua então não apaga e salta para NOBACK

		dec		NUMDIG			; Retira um digito (BACK SPACE)
		dec		POSx			; Retira um digito	

		xor		bx,bx
		mov		bl, NUMDIG
		mov		NUMERO[bx],' '	; Retira um digito		
		goto_xy	POSx,POSy
		mov		ah,02h			; imprime SPACE na possicão do cursor
		mov		dl,32			; que equivale a colocar SPACE 
		int		21H

NOBACK:	
		CMP		AL,30h			; se for menor que tecla do ZERO
		jb		CICLO
		CMP		AL,39h			; ou se for maior que tecla do NOVE 
		ja		CICLO			; é rejeitado e vai buscar nova tecla 
		
		mov		bl,MAXDIG		; se atigido numero máximo de digitos ?	
		CMP		bl,NUMDIG	
		jbe		CICLO			; não aceita mais digitos
		xor		Bx, Bx			; caso contrario coloca digito na matriz NUMERO
		mov		bl, NUMDIG
		MOV		NUMERO[bx], al		
		mov		ah,02h			; imprime digito 
		mov		dl,al			; na possicão do cursor
		int		21H

		inc		POSx			; avança o cursor e
		inc		NUMDIG			; incrementa o numero de digitos

ESTEND:	jmp	CICLO			; Tecla extendida não é tratada neste programa 

OKNUM:	goto_xy	20,16
		MOSTRA	NUM_SP			
		goto_xy	20,16		
		xor		bx,bx
		mov		bl, NUMDIG
		inc 	bl
		MOV		NUMERO[bx], '$'			
		MOSTRA	NUMERO 
		jmp		NOVON		; Vai ler novo numero

fim:	ret

teclanum ENDP



;#############################################################################
;             MAIN
;#############################################################################
MENU    Proc
	MOV     	AX,DSEG
	MOV     	DS,AX
	MOV		AX,0B800H
	MOV		ES,AX		; ES É PONTEIRO PARA MEM VIDEO

	CALL 		APAGA_ECRAN 
	call 		LE_TECLA
		
	MOV		AH,4Ch
	INT		21h
MENU    endp
cseg	ends
end     MENU