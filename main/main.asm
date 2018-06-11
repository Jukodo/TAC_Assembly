.8086
.model small
.stack 2048

dseg	segment para public 'data'
	;|||||||||||||||||||| (start) Cursor |||||||||||||||||||| 
	string	db	"Teste prático de T.I",0
	Car		db	32	; Guarda um caracter do Ecran 
	Cor		db	7	; Guarda os atributos de cor do caracter
	Car2		db	32	; Guarda um caracter do Ecran 
	Cor2		db	7	; Guarda os atributos de cor do caracter
	POSy		db	8	; a linha pode ir de [1 .. 25] (val: posição inicial)
	POSx		db	30	; POSx pode ir [1..80] (val: posição inicial)
	POSya		db	8	; Posição anterior de y
	POSxa		db	30	; Posição anterior de x
	;|||||||||||||||||||| (end) Cursor |||||||||||||||||||| 
	;|||||||||||||||||||| (start) CriarFich ||||||||||||||||||||
	fname	db	'pergunta.txt',0
	fhandle dw	0
	buffer	db	'1 5 6 7 8 9 1 5 7 8 9 2 3 7 8 15 16 18 19 20 3',13,10
			db 	'+ - / * * + - - + * / * + - - + * / + - - + * ',13,10
			db	'10 12 14 7 9 11 13 5 10 15 7 8 9 10 13 5 10 11',13,10 
			db 	'/ * + - - + * / + - / * * + - - + * * + - - + ',13,10
			db	'3 45 23 11 4 7 14 18 31 27 19 9 6 47 19 9 6 51',13,10
			db	'______________________________________________',13,10
	msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
	msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
	msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"
	;|||||||||||||||||||| (end) CriarFich |||||||||||||||||||| 
	;|||||||||||||||||||| (start) LerFich |||||||||||||||||||| 
	msgErrorOpen       db      'Erro ao tentar abrir o ficheiro$'
	msgErrorRead    db      'Erro ao tentar ler do ficheiro$'
	fname_ler         	db      'ABC.TXT',0
	car_fich        db      ?
	;|||||||||||||||||||| (end) LerFich |||||||||||||||||||| 
	;|||||||||||||||||||| (start) Tabuleiro |||||||||||||||||||| 
	ultimo_num_aleat dw 0
	str_num db 5 dup(?),'$'
	linha		db	0	; Define o número da linha que está a ser desenhada
	nlinhas		db	0
	tab_cor		db 	0
	tab_car		db	' '	
	;|||||||||||||||||||| (end) Tabuleiro |||||||||||||||||||| 
	;|||||||||||||||||||| (start) New Stuff |||||||||||||||||||| 
	posCell_now		dw 0
	corCell_now		db 0
	max_linhas		db 6
	max_colunas 	db 9
	;
	array_exploding db 54 dup (0)
	array_saveY		db 0
	array_saveX		db 0
	;
	specialCount 	db 0
	;
	pontuacao		db 0
	;
	environment		db 0
	;|||||||||||||||||||| (end) New Stuff |||||||||||||||||||| 
	;|||||||||||||||||||| (start) Menu |||||||||||||||||||| 
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
	;|||||||||||||||||||| (end) Menu |||||||||||||||||||| 
	;|||||||||||||||||||| (start) Timer |||||||||||||||||||| 
	STR12	 		DB 		"            "	; String para 12 digitos	
	Segundos		dw		0				; Vai guardar os segundos actuais
	Timer		dw		60
	Old_seg		dw		0				; Guarda os últimos segundos que foram lidos
	;|||||||||||||||||||| (end) Timer |||||||||||||||||||| 
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg

espera_tecla macro 
		mov ah,07h
		int 21h
endm

;Recebe as coordenadas absolutas (consola) e converte estas para coordenadas relativas à tabela
macro_convertPos macro
	mov ax, bx
	mov dl, 160
	div dl
	sub al, 8
	mov array_saveY, al
	add al, 8
	mov ah, 0
	mul dl
	mov dx, ax
	mov ax, bx
	sub ax, dx
	mov dl, 4
	div dl
	sub al, 15
	mov array_saveX, al
endm

;Recebe as coordenadas relativas à tabela e muda o estado do index calculado para 1
func_setEstadoXY macro
	push bx
	xor ax, ax
	mov al, array_saveY
	mov ah, 9
	mul ah
	xor dx, dx
	mov dl, array_saveX
	add ax, dx
	mov bx, ax
	mov array_exploding [bx], 1
	pop bx
endm

;Procura o index a partir das coordenadas relativas à tabela e apanha o estado
macro_getEstadoXY macro
	push bx
	xor ax, ax
	mov al, array_saveY
	mov ah, 9
	mul ah
	xor dx, dx
	mov dl, array_saveX
	add ax, dx
	mov bx, ax
	mov dl, array_exploding [bx]
	pop bx
endm
;|||||||||||||||||||| (start) Procs |||||||||||||||||||| 

macro_puts MACRO STR 
	MOV AH,09H
	LEA DX,STR 
	INT 21H
ENDM
; DEVOLVE AX


func_hasPlays proc
	start:
		xor dx, dx ;Contador de espaços possiveis
		mov ax, 1341
		mov posCell_now, ax
		mov bx, ax;160 * 8 + 60 + 1 (Celulas por linha * linhas + Celulas até a posição em X + Valor para obter a cor (0 - caracter, 1 - cor)
		mov cl, 1;Quantidade máxima de linhas a verificar
		mov ch, 1;Quantidade máxima de colunas a verificar
	get_color_around:
		xor dx, dx ;Contador de espaços possiveis
		mov ax, posCell_now
		mov bx, ax
		mov	al, es:[bx] ;Cor na posição do cursor
		mov corCell_now, al
		;mov byte ptr es:[bx],7
		
		;espera_tecla
		
		linhas:
			top:
				inc dl ;Quantidade de espaços com a cor igual à do cursor
				sub bx, 160 ;Mudar para a linha em cima
				mov ah, es:[bx] ;Posição em cima do cursor
				mov al, corCell_now
				cmp ah, al ;Verificar se a cor do bloco atual é igual ao do cursor
				je top ;Se sim, repete
				dec dl ;Se não for igual, não incrementa a quantidade de espaços com a cor igual
				mov ax, posCell_now
				mov bx, ax
			bottom:
				inc dl ;Quantidade de espaços com a cor igual à do cursor
				add bx, 160 ;Mudar para a linha em baixo
				mov ah, es:[bx] ;Posição em baixo do cursor
				mov al, corCell_now
				cmp ah, al ;Verificar se a cor do bloco atual é igual ao do cursor
				je bottom ;Se sim, repete
				dec dl ;Se não for igual, não incrementa a quantidade de espaços com a cor igual
				cmp dl, 1	 ;Se DL >= 3, tem jogadas
				jge has_plays
				mov ax, posCell_now
				mov bx, ax
		colunas:
			left:
				inc dh ;Quantidade de espaços com a cor igual à do cursor
				sub bx, 4 ;Mudar para o bloco atrás
				mov ah, es:[bx] ;Posição atrás do cursor
				mov al, corCell_now
				cmp ah, al ;Verificar se a cor do bloco atual é igual ao do cursor
				je left ;Se sim, repete
				dec dh ;Se não for igual, não incrementa a quantidade de espaços com a cor igual
				mov ax, posCell_now
				mov bx, ax
			right:
				inc dh
				add bx, 4 ;Mudar para o bloco à frente
				mov ah, es:[bx] ;Posição à frente do cursor
				mov al, corCell_now
				cmp ah, al ;Verificar se a cor do bloco atual é igual ao do cursor
				je right ;Se sim, repete
				dec dh ;Se não for igual, não incrementa a quantidade de espaços com a cor igual
				cmp dh, 1;Se DL >= 3, tem jogadas
				jge has_plays
				mov ax, posCell_now
				mov bx, ax
				cmp ch, max_colunas
				jl next_column
				cmp ch, max_colunas
				jge next_line
	next_line:
		inc cl
		cmp cl, max_linhas
		jg no_plays
		mov ch, 1
		mov ax, posCell_now
		add ax, 160
		sub ax, 32
		mov posCell_now, ax
		jmp get_color_around
	next_column:
		inc ch
		mov ax, posCell_now
		add ax, 4
		mov posCell_now, ax
		jmp get_color_around
	has_plays:
		ret 
	no_plays:
		call func_drawTabuleiro
		jmp start
		ret
func_hasPlays endp

func_explodeByArray proc
	xor cx, cx
	xor dx, dx
	mov bx, 1341
	mov si, 0
	mov dh, 1
	ciclo:
		inc ch
		mov al, array_exploding [si]
		inc si
		cmp al, 1
		je draw_black
		jmp next_column
	draw_black:
		inc dl
		mov byte ptr es:[bx], 0h
		mov byte ptr es:[bx+2], 0h
		mov ah, es:[bx-1]
		cmp ah, 1
		je is_special
		jmp next_column
	is_special:
		mov dh, 2
	next_column:
		cmp ch, max_colunas
		je next_line
		add bx, 4
		jmp ciclo
	next_line:
		mov ch, 0
		inc cl
		cmp cl, max_linhas
		je fim
		add bx, 160
		sub bx, 32
		jmp ciclo
	fim:
		xor ax, ax
		mov al, dl
		mul dh
		add pontuacao, al
		ret
func_explodeByArray endp

func_atualizaTabela proc
	xor cx, cx
	mov cl, max_linhas
	start:
		mov bx, 2173 ;Posição da última célula
		xor ax, ax
		mov al, max_linhas
		sub al, cl
		mov ch, 160
		mul ch ;Para calcular em que linha está
		sub bx, ax
		mov ch, 0
	check_column:
		mov dh, es:[bx] ;Célula a ser vista
		cmp dh, 0 ;Se for preto, vai procurar células em cima até encontrar uma cor sem ser preto
		jne next_column ;Senão passa para a próxima célula
		push cx
		xor cx, cx
		xor ax, ax
		next_color:
			inc cl
			mov al, 160
			mul cl ; CL * AL = Quantas linhas em cima vai procurar
			mov si, bx
			sub si, ax
			mov dl, es:[si] ; Cor da célula em cima da que está a ser vista
			cmp dl, 0 ; Se for preto vai passar para uma célula em cima
			jne found ; Senão a cor é roubada pela célula a ser vista, e esta passa a preto
			jmp next_color
			found:
				mov byte ptr es:[bx], dl
				mov byte ptr es:[bx+2], dl
				mov dl, es:[si-1]
				mov byte ptr es:[bx-1], dl
				mov byte ptr es:[bx+1], dl
				mov byte ptr es:[si-1], ' '
				mov byte ptr es:[si], 00000000b
				mov byte ptr es:[si+1], ' '
				mov byte ptr es:[si+2], 00000000b
				call func_makeDelay
				call func_makeDelay
			skip:
		pop cx
	next_column:
		sub bx, 4
		inc ch
		cmp ch, max_colunas
		jne check_column
	next_line:
		dec cl
		cmp cl, 1
		jg start
	call func_fillBlack ; Preenche os campos que ficaram vazios
	
	mov ah, 08h		; Guarda o Caracter que está na posição do Cursor
	mov		bh,0		; numero da página
	int		10h			
	mov		Car, ah	; Guarda o Caracter que está na posição do Cursor
	mov		Car2, ah	; Guarda a cor que está na posição do Cursor
	
	ret
func_atualizaTabela endp

func_fillBlack proc
	xor cx, cx
	mov bx, 1341
	ciclo:
		inc ch
		mov al, es:[bx]
		and al,01110000b ; Necessário para ignorar a cor foreground, e se AL ficar a 0, a cor é preta
		cmp	al, 0 ;Se for preto vai desenhar uma cor Random
		je draw_color
		jmp next_column ;Senão passa para a próxima célula
	draw_color:
		call func_getRandom
		pop	ax
		and al,01110000b
		cmp	al, 0 ; Enquanto a cor for preto, repete
		je	draw_color
		mov byte ptr es:[bx], al
		mov byte ptr es:[bx+2], al
		call func_makeDelay
		call func_makeDelay
	next_column:
		cmp ch, max_colunas
		je next_line
		add bx, 4
		jmp ciclo
	next_line:
		mov ch, 0
		inc cl
		cmp cl, max_linhas
		je fim
		add bx, 160
		sub bx, 32
		jmp ciclo
	fim:
		ret
func_fillBlack endp

func_restartArray proc
	xor cx, cx
	mov cl, 54
	mov si, 0
	ciclo:
		mov array_exploding[si], 0
		inc si
		dec cl
		cmp cl, 0
		jg ciclo
	mov byte ptr es:[40], 'F'
	ret
func_restartArray endp

func_debugArray proc
	xor cx, cx
	mov si, 0
	mov bx, 10
	ciclo:
		mov al, array_exploding[si]
		inc al
		inc si
		mov es:[bx], al
	next_column:
		inc ch
		cmp ch, max_colunas
		je next_line
		add bx, 2
		jmp ciclo
	next_line:
		mov ch, 0
		add bx, 160
		sub bx, 16
		inc cl
		cmp cl, max_linhas
		jne ciclo
		ret
func_debugArray endp

func_explode proc
	cursor_at:
	
		;Debug
		mov dl, 0
		mov dh, 0
		mov ax, 0
		mov al, POSy
		
		push	dx		; Passagem de parâmetros a func_printNum (posição do ecran)
		push	ax		; Passagem de parâmetros a func_printNum (número a imprimir)
		call	func_printNum		; imprime POSy
		mov dl, 1
		mov dh, 0
		mov ax, 0
		mov al, POSx
		
		push	dx		; Passagem de parâmetros a func_printNum (posição do ecran)
		push	ax		; Passagem de parâmetros a func_printNum (número a imprimir)
		call	func_printNum		; imprime POSx
		
		
		;mov ah, POSy
		;mov al, POSx
		;mov byte ptr es:[0], ah
		;mov byte ptr es:[160], al
		mov	al, 160;Espaços por linha	
		mov	ah, POSy
		mul ah
		mov dx, 0
		add dl, POSx
		add dl, POSx ;(2x porque cada célula ocupa 2 bytes, e POSx apenas indica a posição considerando o numero de células)
		add ax, dx
		mov bx, ax; BX = AX
		add bx, 1 ;Para obter a cor
		mov ah, es:[bx] ;Posição em cima do cursor
		mov corCell_now, ah
		mov posCell_now, bx
	check_hasRegion:
		has_top:
			mov al, es:[bx-160] ;Posição em cima do cursor
			cmp ah, al
			je fill_array
		has_bottom:
			mov al, es:[bx+160] ;Posição em baixo do cursor
			cmp ah, al
			je fill_array
		has_left:
			mov al, es:[bx-4] ;Posição à esquerda do cursor
			cmp ah, al
			je fill_array
		has_right:
			mov al, es:[bx+4] ;Posição à direira do cursor
			cmp ah, al
			jne no_explode
	fill_array:
		macro_convertPos
		macro_getEstadoXY
		cmp dl, 1
		je no_explode
		func_setEstadoXY
		vertical:
			start_top:
				mov bx, posCell_now
			top:
				mov ah, corCell_now ;AH fica com a cor da célula no cursor
				sub bx, 160 ;Subtrai 160 para subir
				mov al, es:[bx] ;AL fica com a cor da célula atual
				cmp ah, al
				jne start_bottom ;Se as cores forem diferentes passa para o próximo passo
				macro_convertPos
				macro_getEstadoXY
				cmp dl, 1
				je start_bottom
				push bx
				func_setEstadoXY
				pop bx
				top_check_left:
					mov ah, corCell_now
					mov al, es:[bx-4]
					cmp ah, al
					jne top_check_right
					push bx
					sub bx, 4
					macro_convertPos
					macro_getEstadoXY
					pop bx
					cmp dl, 1
					je top_check_right
					func_setEstadoXY
					inc specialCount
					sub bx, 4
					push bx
					add bx, 4
				top_check_right:
					mov ah, corCell_now
					mov al, es:[bx+4]
					cmp ah, al
					jne top
					push bx
					add bx, 4
					macro_convertPos
					macro_getEstadoXY
					pop bx
					cmp dl, 1
					je top
					func_setEstadoXY
					inc specialCount
					add bx, 4
					push bx
					sub bx, 4
				jmp top
			start_bottom:
				xor cx, cx
				mov bx, posCell_now
			bottom:
				mov ah, corCell_now
				add bx, 160
				je start_left
				mov al, es:[bx]
				cmp ah, al
				jne start_left ;Se as cores forem diferentes passa para o próximo passo
				macro_convertPos
				macro_getEstadoXY
				cmp dl, 1
				je start_left
				push bx
				func_setEstadoXY
				pop bx
				bottom_check_left:
					mov ah, corCell_now
					mov al, es:[bx-4]
					cmp ah, al
					jne bottom_check_right
					push bx
					sub bx, 4
					macro_convertPos
					macro_getEstadoXY
					pop bx
					cmp dl, 1
					je bottom_check_right
					func_setEstadoXY
					inc specialCount
					sub bx, 4
					push bx
					add bx, 4
				bottom_check_right:
					mov ah, corCell_now
					mov al, es:[bx+4]
					cmp ah, al
					jne bottom
					push bx
					add bx, 4
					macro_convertPos
					macro_getEstadoXY
					pop bx
					cmp dl, 1
					je bottom
					func_setEstadoXY
					inc specialCount
					add bx, 4
					push bx
					sub bx, 4
				jmp bottom
		horizontal:
			start_left:
				xor cx, cx
				mov bx, posCell_now
			left:
				mov ah, corCell_now
				sub bx, 4
				mov al, es:[bx]
				cmp ah, al
				jne start_right ;Se as cores forem diferentes passa para o próximo passo
				macro_convertPos
				macro_getEstadoXY
				cmp dl, 1
				je start_right
				push bx
				func_setEstadoXY
				pop bx
				left_check_top:
					mov ah, corCell_now
					mov al, es:[bx-160]
					cmp ah, al
					jne left_check_bottom
					push bx
					sub bx, 160
					macro_convertPos
					macro_getEstadoXY
					pop bx
					cmp dl, 1
					je left_check_bottom
					func_setEstadoXY
					inc specialCount
					sub bx, 160
					push bx
					add bx, 160
				left_check_bottom:
					mov ah, corCell_now
					mov al, es:[bx+160]
					cmp ah, al
					jne left
					push bx
					add bx, 160
					macro_convertPos
					macro_getEstadoXY
					pop bx
					cmp dl, 1
					je left
					func_setEstadoXY
					inc specialCount
					add bx, 160
					push bx
					sub bx, 160
				jmp left
			start_right:
				xor cx, cx
				mov bx, posCell_now
			right:
				mov ah, corCell_now
				add bx, 4
				mov al, es:[bx]
				cmp ah, al
				jne is_end
				macro_convertPos
				macro_getEstadoXY
				cmp dl, 1
				je is_end
				push bx
				func_setEstadoXY
				pop bx
				right_check_top:
					mov ah, corCell_now
					mov al, es:[bx-160]
					cmp ah, al
					jne right_check_bottom
					push bx
					sub bx, 160
					macro_convertPos
					macro_getEstadoXY
					pop bx
					cmp dl, 1
					je right_check_bottom
					func_setEstadoXY
					inc specialCount
					sub bx, 160
					push bx
					add bx, 160
				right_check_bottom:
					mov ah, corCell_now
					mov al, es:[bx+160]
					cmp ah, al
					jne right
					push bx
					add bx, 160
					macro_convertPos
					macro_getEstadoXY
					pop bx
					cmp dl, 1
					je right
					func_setEstadoXY
					inc specialCount
					add bx, 160
					push bx
					sub bx, 160
				jmp right
	is_end:
		mov al, specialCount
		cmp al, 1
		jl boom
		dec specialCount
		pop bx
		mov posCell_now, bx
		jmp vertical
	boom:
		call func_debugArray
		call func_explodeByArray
		
		mov dl, 10
		mov dh, 0
		mov ax, 0
		mov al, pontuacao
		
		push	dx		; Passagem de parâmetros a func_printNum (posição do ecran)
		push	ax		; Passagem de parâmetros a func_printNum (número a imprimir)
		call	func_printNum		; imprime POSx
		
		call func_atualizaTabela
		call func_restartArray
		call func_debugArray
		call func_hasPlays
	no_explode:
		ret
func_explode endp
;|||||||||||||||||||| (end) Procs |||||||||||||||||||| 
;|||||||||||||||||||| (start) Cursor |||||||||||||||||||| 
;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm
;########################################################################
;ROTINA PARA APAGAR ECRAN

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


;########################################################################
; LE UMA TECLA	

func_leTecla PROC
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
func_leTecla	endp
;########################################################################

func_moveCursor  proc
		call func_limpaEcran
		;call func_readFile
		call func_drawTabuleiro
		call func_hasPlays
		
		goto_xy		POSx,POSy	; Vai para nova possição
		mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah	; Guarda a cor que está na posição do Cursor	
		
		inc		POSx
		goto_xy		POSx,POSy	; Vai para nova possição2
		mov 		ah, 08h		; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		mov		Car2, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor2, ah	; Guarda a cor que está na posição do Cursor	
		dec		POSx
	

CICLO:		
		mov ah, environment
		cmp ah, 1
		jne skip
			call func_drawTimer
		skip:
		goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, Car	; Repoe Caracter guardado 
		int		21H	

		inc		POSxa
		goto_xy		POSxa,POSya	
		mov		ah, 02h
		mov		dl, Car2	; Repoe Caracter2 guardado 
		int		21H	
		dec 		POSxa
		
		goto_xy	POSx,POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah	; Guarda a cor que está na posição do Cursor
		
		inc		POSx
		goto_xy		POSx,POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		Car2, al	; Guarda o Caracter2 que está na posição do Cursor2
		mov		Cor2, ah	; Guarda a cor que está na posição do Cursor2
		dec		POSx
		
		
		goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter da posição no canto
		mov		dl, Car	
		int		21H			
		
		goto_xy		78,0		; Mostra o caractr2 que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter2 da posição no canto
		mov		dl, Car2	
		int		21H			
		
	
		goto_xy		POSx,POSy	; Vai para posição do cursor
IMPRIME:	mov		ah, 02h
		mov		dl, '('	; Coloca AVATAR1
		int		21H
		
		inc		POSx
		goto_xy		POSx,POSy		
		mov		ah, 02h
		mov		dl, ')'	; Coloca AVATAR2
		int		21H	
		dec		POSx
		
		goto_xy		POSx,POSy	; Vai para posição do cursor
		
		mov		al, POSx	; Guarda a posição do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posição do cursor
		mov 		POSya, al
		
LER_SETA:	
		call 		func_leTecla
		cmp		ah, 1
			je		ESTEND
		cmp 		al, 27	; ESCAPE
			je		fim
		cmp 		al, 13	; ENTER
			je		explode
		jmp		LER_SETA
		
ESTEND:		
		cmp 		al,48h
		jne		BAIXO
		;if (POSy <= 9){ break; }
			cmp 	POSy, 8
			jle 		CICLO
		dec		POSy		;cima
		jmp		CICLO

BAIXO:		cmp		al,50h
		jne		ESQUERDA
		;if (POSy >= 14){ break; }
			cmp 	POSy, 13
			jge 		CICLO
		inc 	POSy		;Baixo
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		;if (POSx <= 31){ break; }
			cmp 	POSx, 30
			jle 		CICLO
		dec		POSx		;Esquerda
		dec		POSx		;Esquerda

		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		;if (POSx >= 48){ break; }
			cmp 	POSx, 46
			jge 		CICLO
		inc		POSx		;Direita
		inc		POSx		;Direita
		
		jmp		CICLO
explode:
	call func_explode
	jmp CICLO
fim:
		call func_makeFile
		call func_limpaEcran
		call func_drawMenu
		mov timer, 60
		mov environment, 0
		ret
func_moveCursor	endp
;|||||||||||||||||||| (end) Cursor |||||||||||||||||||| 
;|||||||||||||||||||| (start) CriarFich ||||||||||||||||||||
func_makeFile proc
		;MOV		AX, DADOS
		;MOV		DS, AX
	
		mov		ah, 3ch				; Abrir o ficheiro para escrita
		mov		cx, 00H				; Define o tipo de ficheiro ??
		lea		dx, fname			; DX aponta para o nome do ficheiro 
		int		21h					; Abre efectivamente o ficheiro (AX fica com o Handle do ficheiro)
		jnc		escreve				; Se não existir erro escreve no ficheiro
	
		mov		ah, 09h
		lea		dx, msgErrorCreate
		int		21h
	
		jmp		return_MF

escreve:
		mov		bx, ax				; Coloca em BX o Handle
    	mov		ah, 40h				; indica que é para escrever
    	
		lea		dx, buffer			; DX aponta para a infromação a escrever
    	mov		cx, 240				; CX fica com o numero de bytes a escrever
		int		21h					; Chama a rotina de escrita
		jnc		close				; Se não existir erro na escrita fecha o ficheiro
	
		mov		ah, 09h
		lea		dx, msgErrorWrite
		int		21h
close:
		mov		ah,3eh				; fecha o ficheiro
		int		21h
		jnc		return_MF
	
		mov		ah, 09h
		lea		dx, msgErrorClose
		int		21h
return_MF:
		RET
		;MOV		AH,4CH
		;INT		21H
func_makeFile	endp
;|||||||||||||||||||| (end) CriarFich ||||||||||||||||||||
;|||||||||||||||||||| (start) LerFich |||||||||||||||||||| 
func_printTextFile	PROC

;abre ficheiro

        mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,fname_ler			; nome do ficheiro
        int     21h			; abre para leitura 
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
        mov     fhandle,ax		; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 

erro_abrir:
        mov     ah,09h
        lea     dx,msgErrorOpen
        int     21h
        jmp     sai

ler_ciclo:
        mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,fhandle		; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
	jc	    erro_ler		; se carry é porque aconteceu um erro
	cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
	je	    fecha_ficheiro	; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
	  mov	    dl,car_fich		; este é o caracter a enviar para o ecran
	  int	    21h				; imprime no ecran
	  jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
        mov     ah,09h
        lea     dx,msgErrorRead
        int     21h

fecha_ficheiro:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,fhandle
        int     21h
        jnc     sai

        mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,msgErrorClose
        Int     21h
sai:	  RET
func_printTextFile	endp


;########################################################################

func_readFile  proc
	call	func_limpaEcran
	goto_xy	1,1
	call	func_printTextFile

		goto_xy	2,22
		;mov	ah,4CH
		;INT	21H
		ret
func_readFile	endp
;|||||||||||||||||||| (end) LerFich |||||||||||||||||||| 
;|||||||||||||||||||| (start) Tabuleiro |||||||||||||||||||| 
func_drawTabuleiro PROC
	;MOV	AX, DADOS
	;MOV	DS, AX
	
	;mov		ax, dseg
	;mov		ds,ax
	

	mov	cx,10		; Faz o ciclo 10 vezes
ciclo4:
		mov   	ax, 0b800h	; Segmento de memória de vídeo onde vai ser desenhado o tabuleiro
		mov   	es, ax	
		mov	linha, 	8	; O Tabuleiro vai começar a ser desenhado na linha 8 
		mov	nlinhas, 6	; O Tabuleiro vai ter 6 linhas
		
ciclo2:		mov	al, 160		
		mov	ah, linha
		mul	ah
		add	ax, 60
		mov 	bx, ax		; Determina Endereço onde começa a "linha". bx = 160*linha + 60

		mov	cx, 9		; São 9 colunas 
ciclo1:  	
		mov 	dh,	tab_car	; vai imprimir o tab_caracter "SAPCE"
		mov	es:[bx],dh	;
	
novatab_cor:
		mov 	dh,	tab_car	; vai imprimir o tab_caracter "SAPCE"
		call func_getRandom
		pop	ax
		and al,01010101b
		cmp	al, 01010101b
		jne get_color
		mov dh, 1
		
		get_color:
		call	func_getRandom	; Calcula próximo aleatório que é colocado na pinha 
		pop	ax ; 		; Vai bustab_car 'a pilha o número aleatório
		and 	al,01110000b	; posição do ecran com tab_cor de fundo aleatório e tab_caracter a preto
		cmp	al, 0		; Se o fundo de ecran é preto
		je	novatab_cor		; vai bustab_car outra tab_cor 

		mov	es:[bx],   dh		
		mov	es:[bx+1], al	; Coloca as tab_características de tab_cor da posição atual 
		inc	bx		
		inc	bx		; próxima posição e ecran dois bytes à frente 
		
		mov	es:[bx],   dh
		mov	es:[bx+1], al
		inc	bx
		inc	bx
		
		mov	di,1 ;func_makeDelay de 1 centesimo de segundo
		;;call	func_makeDelay
		loop	ciclo1		; continua até fazer as 9 colunas que tab_correspondem a uma liha completa
		
		inc	linha		; Vai desenhar a próxima linha
		dec	nlinhas		; contador de linhas
		mov	al, nlinhas
		cmp	al, 0		; verifica se já desenhou todas as linhas 
		jne	ciclo2		; se ainda há linhas a desenhar continua 
return_PROC:
	;call func_hasPlays
	;pop dx
	;cmp dl, 0
	;call func_drawTabuleiro
	ret
func_drawTabuleiro ENDP

;------------------------------------------------------
;func_getRandom - calcula um numero aleatorio de 16 bits
;Parametros passados pela pilha
;entrada:
;não tem parametros de entrada
;saida:
;param1 - 16 bits - numero aleatorio calculado
;notas adicionais:
; deve estar definida uma variavel => ultimo_num_aleat dw 0
; assume-se que DS esta a apontar para o segmento onde esta armazenada ultimo_num_aleat
func_getRandom proc near

	sub	sp,2		; 
	push	bp
	mov	bp,sp
	push	ax
	push	cx
	push	dx	
	mov	ax,[bp+4]
	mov	[bp+2],ax

	mov	ah,00h
	int	1ah

	add	dx,ultimo_num_aleat	; vai bustab_car o aleatório anterior
	add	cx,dx	
	mov	ax,65521
	push	dx
	mul	cx			
	pop	dx			 
	xchg	dl,dh
	add	dx,32749
	add	dx,ax

	mov	ultimo_num_aleat,dx	; guarda o novo numero aleatório  

	mov	[BP+4],dx		; o aleatório é passado por pilha

	pop	dx
	pop	cx
	pop	ax
	pop	bp
	ret
func_getRandom endp

;------------------------------------------------------
;func_printNum - imprime um numero de 16 bits na posicao x,y
;Parametros passados pela pilha
;entrada:
;param1 -  8 bits - posicao x
;param2 -  8 bits - posicao y
;param3 - 16 bits - numero a imprimir
;saida:
;não tem parametros de saída
;notas adicionais:
; deve estar definida uma variavel => str_num db 5 dup(?),'$'
; assume-se que DS esta a apontar para o segmento onde esta armazenada str_num
; sao eliminados da pilha os parametros de entrada
func_printNum proc near
	push	bp
	mov	bp,sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	mov	ax,[bp+4] ;param3
	lea	di,[str_num+5]
	mov	cx,5
prox_dig:
	xor	dx,dx
	mov	bx,10
	div	bx
	add	dl,'0' ; dh e' sempre 0
	dec	di
	mov	[di],dl
	loop	prox_dig

	mov	ah,02h
	mov	bh,00h
	mov	dl,[bp+7] ;param1
	mov	dh,[bp+6] ;param2
	int	10h
	mov	dx,di
	mov	ah,09h
	int	21h
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	ret	4 ;limpa parametros (4 bytes) colocados na pilha
func_printNum endp

;recebe em di o número de milisegundos a esperar
func_makeDelay proc
	pushf
	push	ax
	push	cx
	push	dx
	push	si
	
	mov	ah,2Ch
	int	21h
	mov	al,100
	mul	dh
	xor	dh,dh
	add	ax,dx
	mov	si,ax


ciclo99:	mov	ah,2Ch
	int	21h
	mov	al,100
	mul	dh
	xor	dh,dh
	add	ax,dx

	cmp	ax,si 
	jnb	naoajusta
	add	ax,6000 ; 60 segundos
naoajusta:
	sub	ax,si
	cmp	ax,di
	jb	ciclo99

	pop	si
	pop	dx
	pop	cx
	pop	ax
	popf
	ret
func_makeDelay endp

func_getTempo PROC	
 
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
func_getTempo    ENDP 

func_drawTimer PROC

		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		

		CALL 	func_getTempo 				; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, Segundos
		cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
		je		fim_horas			; Se a hora não mudou desde a última leitura sai.
		mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 
		
		MOV AX, Timer
		DEC AX
		MOV Timer, AX
		MOV bl, 10
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		;MOV 	STR12[0],al			; 
		;MOV 	STR12[1],ah
		;MOV 	STR12[2],'s'		
		;MOV 	STR12[3],'$'
		;GOTO_XY	20,10
		;macro_puts	STR12 
		MOV byte ptr es:[40], al
		MOV byte ptr es:[42], ah
		MOV byte ptr es:[44], 's'

				
        
						
fim_horas:
		
		
		
		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
		
		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		RET		
			
func_drawTimer ENDP

menu_switch_opt proc

	mov al, selected_opt
	cmp al, 1
	jne opt2
	
	opt1:
		goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter da posição no canto
		mov		dl, '1'
		int		21H	
		mov environment, 1
		call func_moveCursor
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
		call func_selectOpt
		;call func_configurarGrelha
		
	fim_menu_switch_opt:
		call func_limpaEcran
		mov ah,4CH
		int	21H

menu_switch_opt endp

func_selectOpt proc

	;goto_xy		menu_POSx,menu_POSy	; Vai para nova possição
	;mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
	;mov			bh,0		; numero da página
	;int			10h	
	;mov		menu_Car, al	; Guarda o Caracter que está na posição do Cursor
	;mov		Cor, ah	; Guarda a cor que está na posição do Cursor	

	
	;inc			menu_POSx
	;goto_xy		menu_POSx,menu_POSy	; Vai para nova possição2
	;mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
	;mov			bh,0		; numero da página
	;int			10h
	;mov		menu_Car2, al	; Guarda o Caracter que está na posição do Cursor
	;mov		Cor2, ah	; Guarda a cor que está na posição do Cursor
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
	mov		Cor, ah	; Guarda a cor que está na posição do Cursor		
	
	inc		menu_POSx
	goto_xy		menu_POSx,menu_POSy	; Vai para nova possição
	mov 		ah, 08h
	mov		bh,0		; numero da página
	;int		10h
	mov		menu_Car2, al	; Guarda o Caracter2 que está na posição do Cursor2
	mov		Cor2, ah	; Guarda a cor que está na posição do Cursor2		
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
			;cmp 		al, 27	; ESCAPE
			;je		fim_selectedOpt
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
		ret
		;mov ah,4CH
		;int	21H

func_selectOpt endp

func_drawMenu proc
	goto_xy 1,1
	macro_puts str_opt1
	goto_xy 2,1
	macro_puts str_jogar
	
	goto_xy 1,2
	macro_puts str_opt2
	goto_xy 2,2
	macro_puts str_pontuacoes
	
	goto_xy 1,3
	macro_puts str_opt3
	goto_xy 2,3
	macro_puts str_grelha
	
	goto_xy 1,4
	macro_puts str_opt4
	goto_xy 2,4
	macro_puts str_sair
	ret
func_drawMenu endp

func_main proc
	;;PROG STARTS HERE
	mov		ax, dseg
	mov		ds,ax
	;;||||||||||||||||
	
	mov		ax,0B800h
	mov		es,ax
	call func_limpaEcran
	call func_drawMenu
	call func_selectOpt
	
func_main endp

;|||||||||||||||||||| (end) Tabuleiro |||||||||||||||||||| 
Cseg	ends
end	func_main