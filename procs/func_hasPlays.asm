func_hasPlays proc
	start:
		xor dx ;Contador de espaços possiveis
		mov	al, 160;Espaços por linha
		mov	ah, 9;POSy
		mul	ah ;160 * POSy
		add	ax, 62; (160 * POSy) + POSx
		mov bx, ax; BX = AX
		add bx, 1 ;Para obter a cor do primeiro bloco
		mov cl, 6;Quantidade máxima de linhas a verificar
		mov ch, 9;Quantidade máxima de colunas a verificar
	get_color_around:
		mov	al, es:[bx] ;Posição do cursor
		linhas:
			mov ch, 9
			dec cl
			cmp cl, 0
			jl no_plays
			top:
				inc dl ;Quantidade de espaços com a cor igual à do cursor
				sub bx, 160 ;Mudar para a linha em cima
				mov ah, es:[bx] ;Posição em cima do cursor
				cmp ah, al ;Verificar se a cor do bloco atual é igual ao do cursor
				je top ;Se sim, repete
				mov al, 160
				mov ah, dl 
				mul ah ;AX = AL * AH (AX = 160*Quant)
				add bx, ax ; Volta à posição do cursor
			bottom:
				inc dh ;Quantidade de espaços com a cor igual à do cursor
				add bx, 160 ;Mudar para a linha em baixo
				mov ah, es:[bx] ;Posição em baixo do cursor
				cmp ah, al ;Verificar se a cor do bloco atual é igual ao do cursor
				je bottom ;Se sim, repete
				add dl, dh ;DL = DL + DH
				cmp dl, 3 ;Se DL >= 3, tem jogadas
				jge has_plays
				mov al, 160
				mov ah, dl 
				mul ah ;AX = AL * AH (AX = 160*Quant)
				add bx, ax ; Volta à posição do cursor
		colunas:
			dec ch
			left:
				inc dl ;Quantidade de espaços com a cor igual à do cursor
				sub bx, 2 ;Mudar para o bloco atrás
				mov ah, es:[bx] ;Posição atrás do cursor
				cmp ah, al ;Verificar se a cor do bloco atual é igual ao do cursor
				je left ;Se sim, repete
				mov al, 2
				mov ah, dl
				mul ah ;AX = AL * AH (AX = 2*Quant)
				add bx, ax ; Volta à posição do cursor
			right:
				inc dh
				add bx, 2 ;Mudar para o bloco à frente
				mov ah, es:[bx] ;Posição à frente do cursor
				cmp ah, al ;Verificar se a cor do bloco atual é igual ao do cursor
				je right ;Se sim, repete
				add dl, dh ;DL = DL + DH
				cmp dl, 3;Se DL >= 3, tem jogadas
				jge has_plays
				cmp ch, 0
				jl linhas
				no_plays
	has_plays:
		ret
	no_plays:
		ret
func_hasPlays endp