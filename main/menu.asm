goto_xy		MACRO	menu_POSx,menu_POSy
	MOV	AH,02H
	MOV	BH,0
	MOV	DL,menu_POSx
	MOV	DH,menu_POSy
	INT	10H
ENDM

MOSTRA 		MACRO STR 
	MOV AH,09H
	LEA DX,STR 
	INT 21H
ENDM

.8086
.model small
.stack 2048h

PILHA	SEGMENT PARA STACK 'STACK'
		db 2048 dup(?)
PILHA	ENDS
	

DSEG    SEGMENT PARA PUBLIC 'DATA'
		
		menu_POSy		db 	1
		menu_POSx		db 	1
		menu_POSya		db 	0
		menu_POSxa		db 	0
		
		menu_Car		db	32
		menu_Cor		db	7
		menu_Car2		db	32
		menu_Cor2		db 	7
		
		
		str_opt1		db 	"1 $"
		str_opt2		db 	"2 $"
		str_opt3		db 	"3 $"
		str_opt4		db 	"4 $"
		
		str_jogar		db 	" Jogar$"	
		str_pontuacoes 	db 	" Ver pontuacoes$"
		str_grelha 		db 	" Configurar grelha$"
		str_sair		db 	" Sair$"
		
		left_select		db "($"
		right_select	db ")$"
		
		selected_opt	db	1 ;Inicialmente a opção 1 está selecionada

DSEG    ENDS

CSEG    SEGMENT PARA PUBLIC 'CODE'

	ASSUME  CS:CSEG, DS:DSEG, SS:PILHA
	
	func_limpaEcran	proc
	
		xor		bx,bx
		mov		cx,25*80
		
		apaga:			
			mov	byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 		bx
			loop		apaga
			ret
	func_limpaEcran	endp
	
	func_leTecla	PROC

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		fim_leTecla
		mov		ah, 08h
		int		21h
		mov		ah,1
		
		fim_leTecla:	
			ret
			
	func_leTecla	endp
	
	
	func_selectOpt proc
	
		goto_xy		menu_POSx,menu_POSy	; Vai para nova possição
		mov			bh,0		; numero da página
		int			10h			
		inc			menu_POSx
		goto_xy		menu_POSx,menu_POSy	; Vai para nova possição2
		mov			bh,0		; numero da página
		int			10h			
		dec			menu_POSx
	

	menu_Ciclo:		
	
		goto_xy	menu_POSxa,menu_POSya	; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, menu_Car	; Repoe menu_Caracter guardado 
		int		21H	

		inc		menu_POSxa
		goto_xy		menu_POSxa,menu_POSya	
		mov		ah, 02h
		mov		dl, menu_Car2	; Repoe menu_Caracter2 guardado 
		int		21H	
		dec 		menu_POSxa
		
		goto_xy	menu_POSx,menu_POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		menu_Car, al	; Guarda o menu_Caracter que está na posição do Cursor
		mov		menu_Cor, ah	; Guarda a menu_Cor que está na posição do Cursor
		
		inc		menu_POSx
		goto_xy		menu_POSx,menu_POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		menu_Car2, al	; Guarda o menu_Caracter2 que está na posição do Cursor2
		mov		menu_Cor2, ah	; Guarda a menu_Cor que está na posição do Cursor2
		dec		menu_POSx
			
		
	
		goto_xy		menu_POSx,menu_POSy	; Vai para posição do cursor
		
		menu_imprime:	
		
				inc		menu_POSx
				goto_xy		menu_POSx,menu_POSy		
				mov		ah, 02h
				mov		dl, ')'	; Coloca AVATAR2
				int		21H	
				dec		menu_POSx
				
				goto_xy		menu_POSx,menu_POSy	; Vai para posição do cursor
				
				mov		al, menu_POSx	; Guarda a posição do cursor
				mov		menu_POSxa, al
				mov		al, menu_POSy	; Guarda a posição do cursor
				mov 		menu_POSya, al
				
		menu_LerSeta:	
				call 		func_leTecla
				cmp		ah, 1
				je		menu_Estend
				cmp 		al, 27	; ESCAPE
				je		fim_selectedOpt
				jmp		menu_LerSeta
				
		menu_Estend:		
				cmp 		al,48h
				jne		menu_Baixo
				;if (menu_POSy <= 1){ break; }
				cmp 	menu_POSy, 1
				jle 	menu_Ciclo
				dec		menu_POSy		;cima
				jmp		menu_Ciclo

		menu_Baixo:		
				cmp		al,50h
				jne		menu_LerSeta
				;if (menu_POSy >= 4){ break; }
				cmp 	menu_POSy, 4
				jge 	menu_Ciclo
				inc 	menu_POSy		;Baixo
				jmp		menu_Ciclo

				
		fim_selectedOpt:
			mov ah,4CH
			int	21H
	
	func_selectOpt endp
	

	func_menu PROC
	
		goto_xy 1,1
		MOSTRA str_opt1
		goto_xy 2,1
		MOSTRA str_jogar
		
		goto_xy 1,2
		MOSTRA str_opt2
		goto_xy 2,2
		MOSTRA str_pontuacoes
		
		goto_xy 1,3
		MOSTRA str_opt3
		goto_xy 2,3
		MOSTRA str_grelha
		
		goto_xy 1,4
		MOSTRA str_opt4
		goto_xy 2,4
		MOSTRA str_sair

		call func_selectOpt

		fim_menu:
			ret
			
	func_menu ENDP

	Main    Proc
		MOV     	AX,DSEG
		MOV     	DS,AX
		MOV		AX,0B800H
		MOV		ES,AX

		call func_limpaEcran
		call func_menu 
			
		MOV		AH,4Ch
		INT		21h
	Main    endp
	
cseg	ends
end     Main