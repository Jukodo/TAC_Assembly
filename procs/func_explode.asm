func_explode proc
	;mov al, posY
	;mov ah, posX
	cursor_at:
		xor dx
		xor cx
		mov	al, 160;Espaços por linha
		mov	ah, 1;POSy
		mul	ah ;160 * POSy
		add	ax, 60; (160 * POSy) + POSx
		mov bx, ax; BX = AX
		add bx, 1 ;Para obter a cor
	get_color_around:
		mov	al, es:[bx] ;Posição do cursor
		cmp cx, 0 ;Verificar se o vertical já foi analisado
		jg horizontal
		vertical:
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
				cmp dl, 3 ;Se DL >= 3, rebenta verticalmente 
				jge boom_vertical
				inc cx
				jmp cursor_at ;Volta ao inicio
		horizontal:
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
				cmp dl, 3;Se DL >= 3, rebenta verticalmente 
				jge boom_horizontal
				jmp no_explode
	boom_vertical:
	
	boom_horizontal:
	
	no_explode:
		ret
func_explode endp