posCell_now		dw 0
corCell_now		db 0
max_linhas		db 6
max_colunas 	db 9

debug_table macro  ;Debug
	mov byte ptr es:[bx-1],'Y'
	call func_makeDelay
	call func_makeDelay
	call func_makeDelay
	call func_makeDelay
	call func_makeDelay
	mov byte ptr es:[bx-1],' '
endm

func_hasPlays proc
	start:
		xor dx, dx ;Contador de espa�os possiveis
		mov ax, 1341
		mov posCell_now, ax
		mov bx, ax;160 * 8 + 60 + 1 (Celulas por linha * linhas + Celulas at� a posi��o em X + Valor para obter a cor (0 - caracter, 1 - cor)
		mov cl, 1;Quantidade m�xima de linhas a verificar
		mov ch, 1;Quantidade m�xima de colunas a verificar
	get_color_around:
		xor dx, dx ;Contador de espa�os possiveis
		mov ax, posCell_now
		mov bx, ax
		mov	al, es:[bx] ;Cor na posi��o do cursor
		mov corCell_now, al
		mov byte ptr es:[bx-1],'X' ;Debug
		;mov byte ptr es:[bx],7
		
		;espera_tecla
		
		linhas:
			top:
				inc dl ;Quantidade de espa�os com a cor igual � do cursor
				sub bx, 160 ;Mudar para a linha em cima
				mov ah, es:[bx] ;Posi��o em cima do cursor
				
				debug_table ;Debug
				
				mov al, corCell_now
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je top ;Se sim, repete
				dec dl ;Se n�o for igual, n�o incrementa a quantidade de espa�os com a cor igual
				mov ax, posCell_now
				mov bx, ax
			bottom:
				inc dl ;Quantidade de espa�os com a cor igual � do cursor
				add bx, 160 ;Mudar para a linha em baixo
				mov ah, es:[bx] ;Posi��o em baixo do cursor
				
				debug_table ;Debug
				
				mov al, corCell_now
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je bottom ;Se sim, repete
				dec dl ;Se n�o for igual, n�o incrementa a quantidade de espa�os com a cor igual
				cmp dl, 3	 ;Se DL >= 3, tem jogadas
				jge has_plays
				mov ax, posCell_now
				mov bx, ax
		colunas:
			left:
				inc dh ;Quantidade de espa�os com a cor igual � do cursor
				sub bx, 4 ;Mudar para o bloco atr�s
				mov ah, es:[bx] ;Posi��o atr�s do cursor
				
				debug_table ;Debug
				
				mov al, corCell_now
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je left ;Se sim, repete
				dec dh ;Se n�o for igual, n�o incrementa a quantidade de espa�os com a cor igual
				mov ax, posCell_now
				mov bx, ax
			right:
				inc dh
				add bx, 4 ;Mudar para o bloco � frente
				mov ah, es:[bx] ;Posi��o � frente do cursor
				
				debug_table ;Debug
				
				mov al, corCell_now
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je right ;Se sim, repete
				dec dh ;Se n�o for igual, n�o incrementa a quantidade de espa�os com a cor igual
				cmp dh, 3;Se DL >= 3, tem jogadas
				jge has_plays
				mov ax, posCell_now
				mov bx, ax
				
				mov ax, posCell_now
				mov bx, ax
				mov byte ptr es:[bx-1],' ' ;Debug
				
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