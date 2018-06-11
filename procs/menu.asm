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
		
		;Menu
		menu_POSy		db 	1
		menu_POSx		db 	1
		menu_POSya		db 	1
		menu_POSxa		db 	1
		
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
		
		selected_opt	db	1 ;Inicialmente a opção 1 está selecionada
		
		;Ficheiro
		fhandle 		dw	0
		msgErrorOpen	db  'Erro ao tentar abrir o ficheiro$'
		msgErrorRead    db	'Erro ao tentar ler do ficheiro$'
		msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"
		fname_ler       db  'GRELHA2.TXT',0
		car_fich        db	?
		cell_counter	db	0
		line_counter	db	0
		
		;Grelha
		max_linhas		db  6
		max_colunas 	db  9
		cell			dw  1340
		tab_car			db	' '

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
	



;----------------------------------------(start) func_configurarGrelha----------------------------------------
func_configurarGrelha proc

	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	
	call func_limpaEcran
	goto_xy 0, 5
	
	open_file:
        mov     ah,3dh			; abrir o ficheiro em modo leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,fname_ler	; nome do ficheiro
        int     21h				; abre para leitura 
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
        mov     fhandle,ax		; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclo		; depois de abero vamos ler o ficheiro

	erro_abrir:
        mov     ah,09h
        lea     dx,msgErrorOpen
        int     21h
        jmp     fim

	ler_ciclo:
        mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,fhandle		; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
		jc	    erro_ler		; se carry é porque aconteceu um erro
		cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		je	    close_file		; se EOF fecha o ficheiro
		
		push ax
		push bx
		push cx
		push dx
		
			convert_color:
			
				xor ax, ax
				xor bx, bx
				xor cx, cx
				xor dx, dx
				
				mov bx, cell
				mov ch, cell_counter
				mov cl, line_counter
				
				cycle:
				
					mov al, car_fich

					cmp al, '2'  ; AL é red?
					jne pink
				
					red:
						mov ah, 00064
						jmp write_to_memory
						
					pink:
						cmp al, '3' 
						jne lblue
						mov ah, 00080
						jmp write_to_memory
						
					lblue:
						cmp al, '4' 
						jne green
						mov ah, 00048
						jmp write_to_memory
					
					green:
						cmp al, '5' 
						jne orange
						mov ah, 00032
						jmp write_to_memory
					
					orange:
						cmp al, '6' 
						jne white
						mov ah, 00096
						jmp write_to_memory
					
					white:
						cmp al, '7' 
						jne blue
						mov ah, 00112
						jmp write_to_memory
						
					blue:
						cmp al, '8' 
						jne next_cell
						mov ah, 00016
						jmp write_to_memory
						
					;space:
						;cmp al, 32
						;jne cr
						;jmp next_cell
						
					;cr:
						;cmp al, 13
						;jne next_cell
						;cmp al, 10
						;jne next_cell
						;jmp next_line
						
					write_to_memory:
					
						;mov dh, tab_car
						;mov es:[bx], dh
						mov es:[bx+1], ah
						
						;mov es:[bx+2], dh
						mov es:[bx+3], ah
						
						jmp next_cell
					
					next_cell:
						add bx, 2
						;add bx, 1 ;Anda para a celula da direita
						inc ch; Nº de células percorridas
						cmp ch, 18
						je next_line; Se já leu o tamanho máximo de celulas que pode ler muda de linha
						jmp continue; Continua a ler do ficheiro e vai ler a próxima celula
					
					next_line:
						;mov	byte ptr es:[bx+1],ch
						mov bx, cell
						inc cl; Nº de linhas percorridas
						cmp cl, 6
						jge fim; Se já leu o tamanho máximo de linhas que pode ler, termina
						add bx, 160; Muda de linha, mas fica na ultima coluna
						sub bx, 36; Vai para a 1ª coluna da nova linha
						mov ch, 0; Renicia a contagem das células pois estamos numa nova linha
						jmp continue; Continua a ler do ficheiro e vai ler a próxima célula (1ª celula da linha nova)
				
			
		continue:	
		
			mov cell, bx
			mov cell_counter, ch
			mov line_counter, cl
			pop ax		
			pop bx
			pop cx
			pop dx
			;mov     ah,02h			; coloca o caracter no ecran
			;mov	    dl,car_fich		; este é o caracter a enviar para o ecran
			;int	    21h				; imprime no ecran
			jmp	    ler_ciclo		; continua a ler o ficheiro
		
	erro_ler:
        mov     ah,09h
        lea     dx,msgErrorRead
        int     21h
		
	close_file:
		mov     ah,3eh
		mov     bx,fhandle
		int     21h
		jnc     fim

		mov     ah,09h			; o ficheiro pode não fechar correctamente
		lea     dx,msgErrorClose
		Int     21h
		
	

	fim:
		;ret
		mov ah,4CH
		int	21H

func_configurarGrelha endp
;----------------------------------------(end) func_configurarGrelha----------------------------------------
	
;----------------------------------------(start) menu_switch_opt----------------------------------------
;Params	: 	selected_opt
;swtich(selected_opt)
;	case 1:
;	case 2:
;	case 3:
;	default:

menu_switch_opt proc

	mov al, selected_opt
	cmp al, 1
	jne opt2
	
	opt1:
		goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter da posição no canto
		mov		dl, '1'
		int		21H	
		call func_selectOpt
	
	opt2:
		cmp al, 2
		jne opt3
		goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter da posição no canto
		mov		dl, '2'
		int		21H
		call func_selectOpt
	
	opt3:
		cmp al, 3
		jne fim_menu_switch_opt
		goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter da posição no canto
		mov		dl, '3'
		int		21H	
		call func_configurarGrelha
		
	fim_menu_switch_opt:
		mov ah,4CH
		int	21H

menu_switch_opt endp
	
;----------------------------------------(end) menu_switch_opt ----------------------------------------
	
	
	func_selectOpt proc
	
		;goto_xy		menu_POSx,menu_POSy	; Vai para nova possição
		;mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		;mov			bh,0		; numero da página
		;int			10h	
		;mov		menu_Car, al	; Guarda o Caracter que está na posição do Cursor
		;mov		menu_Cor, ah	; Guarda a cor que está na posição do Cursor	

		
		;inc			menu_POSx
		;goto_xy		menu_POSx,menu_POSy	; Vai para nova possição2
		;mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		;mov			bh,0		; numero da página
		;int			10h
		;mov		menu_Car2, al	; Guarda o Caracter que está na posição do Cursor
		;mov		menu_Cor2, ah	; Guarda a cor que está na posição do Cursor
		;dec			menu_POSx
	

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
				dec selected_opt
				dec		menu_POSy		;cima
				jmp		menu_Ciclo

		menu_Baixo:		
				cmp		al,50h
				jne		menu_LerSeta
				;if (menu_POSy >= 4){ break; }
				cmp 	menu_POSy, 4
				jge 	menu_Ciclo
				inc selected_opt
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