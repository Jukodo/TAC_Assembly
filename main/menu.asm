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
		
		menu_Car		db	0
		menu_Cor		db	0
		menu_Car2		db	0
		menu_Cor2		db 	0
		
		
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
	
	
	;Params: AL
	;swtich(AL)
	;	case 1:
	;	case 2:
	;	case 3:
	;	case 4:
	
	menu_switch_opt proc
	
		pop ax
		cmp al, 1
		jne opt2
		
		opt1:
			;goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
			;mov		ah, 02h		; IMPRIME caracter da posição no canto
			;mov		dl, '1'
			;int		21H	
			call func_selectOpt
		
		opt2:
			cmp al, 2
			jne opt3
			;goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
			;mov		ah, 02h		; IMPRIME caracter da posição no canto
			;mov		dl, '2'
			;int		21H
			call func_selectOpt
		
		opt3:
			cmp al, 3
			jne opt3
			;goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
			;mov		ah, 02h		; IMPRIME caracter da posição no canto
			;mov		dl, '3'
			;int		21H	
			call func_selectOpt
		
		opt4:
			cmp al, 4
			;jne func_selectOpt
			;goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
			;mov		ah, 02h		; IMPRIME caracter da posição no canto
			;mov		dl, '4'
			;int		21H	
			call func_selectOpt
	
		fim_menu_switch_opt:
			ret
	
	menu_switch_opt endp
	
	
	func_selectOpt proc
	
		mov al, 1
		push ax
	
		goto_xy		menu_POSx,menu_POSy	; Vai para nova possição
		;mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		;mov			bh,0		; numero da página
		;int			10h	
		;mov		menu_Car, al	; Guarda o Caracter que está na posição do Cursor
		;mov		menu_Cor, ah	; Guarda a cor que está na posição do Cursor	

		
		inc			menu_POSx
		goto_xy		menu_POSx,menu_POSy	; Vai para nova possição2
		;mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		;mov			bh,0		; numero da página
		;int			10h
		;mov		menu_Car2, al	; Guarda o Caracter que está na posição do Cursor
		;mov		menu_Cor2, ah	; Guarda a cor que está na posição do Cursor
		dec			menu_POSx
	

	menu_Ciclo:		
	
		dec menu_POSxa
		goto_xy	menu_POSxa,menu_POSya	; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, menu_Car	; Repoe menu_Caracter guardado 
		int		21H	
		inc menu_POSxa

		inc		menu_POSxa
		goto_xy		menu_POSxa,menu_POSya	
		mov		ah, 02h
		mov		dl, menu_Car2	; Repoe menu_Caracter2 guardado 
		int		21H	
		dec 		menu_POSxa
		
		goto_xy	menu_POSx,menu_POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		;int		10h
		mov		menu_Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		menu_Cor, ah	; Guarda a cor que está na posição do Cursor		
		
		inc		menu_POSx
		goto_xy		menu_POSx,menu_POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		;int		10h
		mov		menu_Car2, al	; Guarda o Caracter2 que está na posição do Cursor2
		mov		menu_Cor2, ah	; Guarda a cor que está na posição do Cursor2		
		dec		menu_POSx
		
		;goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
		;mov		ah, 02h		; IMPRIME caracter da posição no canto
		;mov		dl, menu_Car	
		;int		21H

		;goto_xy		78,0		; Mostra o caractr2 que estava na posição do AVATAR
		;mov		ah, 02h		; IMPRIME caracter2 da posição no canto
		;mov		dl, menu_Car2	
		;int		21H		
			
		
	
		goto_xy		menu_POSx,menu_POSy	; Vai para posição do cursor
		
		menu_imprime:
				
				dec menu_POSx
				goto_xy		menu_POSx,menu_POSy
				mov		ah, 02h
				mov		dl, '('	; Coloca AVATAR1
				int		21H
				inc menu_POSx
		
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
				cmp 	al, 13	; ENTER
				je		menu_switch_opt
				jmp		menu_LerSeta
				
		menu_Estend:		
				cmp 		al,48h
				jne		menu_Baixo
				;if (menu_POSy <= 1){ break; }
				cmp 	menu_POSy, 1
				jle 	menu_Ciclo
				pop ax
				dec al
				;push ax
				dec		menu_POSy		;cima
				jmp		menu_Ciclo

		menu_Baixo:		
				cmp		al,50h
				jne		menu_LerSeta
				;if (menu_POSy >= 4){ break; }
				cmp 	menu_POSy, 4
				jge 	menu_Ciclo
				pop ax
				inc al
				;push ax
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