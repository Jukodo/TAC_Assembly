.8086
.model small
.stack 2048

dseg	segment para public 'data'
	;|||||||||||||||||||| (start) Cursor |||||||||||||||||||| 
	string	db	"Teste pr�tico de T.I",0
	Car		db	32	; Guarda um caracter do Ecran 
	Cor		db	7	; Guarda os atributos de cor do caracter
	Car2		db	32	; Guarda um caracter do Ecran 
	Cor2		db	7	; Guarda os atributos de cor do caracter
	POSy		db	8	; a linha pode ir de [1 .. 25] (val: posi��o inicial)
	POSx		db	30	; POSx pode ir [1..80] (val: posi��o inicial)
	POSya		db	8	; Posi��o anterior de y
	POSxa		db	30	; Posi��o anterior de x
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
	linha		db	0	; Define o n�mero da linha que est� a ser desenhada
	nlinhas		db	0
	tab_cor		db 	0
	tab_car		db	' '	
	;|||||||||||||||||||| (end) Tabuleiro |||||||||||||||||||| 
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg

espera_tecla macro 
		mov ah,07h
		int 21h
endm

;|||||||||||||||||||| (start) Procs |||||||||||||||||||| 
; DEVOLVE AX

func_hasPlays proc
	start:
		xor dx, dx ;Contador de espa�os possiveis
		mov	al, 160;Espa�os por linha
		mov	ah, 8;POSy
		mul	ah ;160 * POSy
		add	ax, 60; (160 * POSy) + POSx
		
		mov bx, ax; BX = AX
		add bx, 1 ;Para obter a cor do primeiro bloco
		mov cl, 6;Quantidade m�xima de linhas a verificar
		mov ch, 9;Quantidade m�xima de colunas a verificar
	get_color_around:
		mov	al, es:[bx] ;Cor na posi��o do cursor
		mov byte ptr es:[bx-1],'X'
		;mov byte ptr es:[bx],7
		
		;espera_tecla
		
		linhas:
			mov ch, 9
			dec cl
			cmp cl, 0
			jl no_plays
			top:
				inc dl ;Quantidade de espa�os com a cor igual � do cursor
				sub bx, 160 ;Mudar para a linha em cima
				mov ah, es:[bx] ;Posi��o em cima do cursor
				
				mov byte ptr es:[bx-1],'Y'
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				mov byte ptr es:[bx-1],' '
				
				mov byte ptr es:[bx-160],al
				mov byte ptr es:[bx-158],ah
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je top ;Se sim, repete
				dec dl ;Se n�o for igual, n�o incrementa a quantidade de espa�os com a cor igual
				mov al, 160
				mov ah, dl 
				mul ah ;AX = AL * AH (AX = 160*Quant)
				add bx, ax ; Volta � posi��o do cursor
				add bx, 160
			bottom:
				inc dl ;Quantidade de espa�os com a cor igual � do cursor
				add bx, 160 ;Mudar para a linha em baixo
				mov ah, es:[bx] ;Posi��o em baixo do cursor
				mov byte ptr es:[bx-320],al
				mov byte ptr es:[bx-322],ah
				mov byte ptr es:[bx-1],'Y'
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				mov byte ptr es:[bx-1],' '
				
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je bottom ;Se sim, repete
				dec dl ;Se n�o for igual, n�o incrementa a quantidade de espa�os com a cor igual
				cmp dl, 1 ;Se DL >= 3, tem jogadas
				jge has_plays
				mov al, 160
				mov ah, dl 
				mul ah ;AX = AL * AH (AX = 160*Quant)
				sub bx, ax ; Volta � posi��o do cursor
				sub bx, 160
		colunas:
			dec ch
			left:
				inc dh ;Quantidade de espa�os com a cor igual � do cursor
				sub bx, 4 ;Mudar para o bloco atr�s
				mov ah, es:[bx] ;Posi��o atr�s do cursor
				mov byte ptr es:[bx-1],'Y'
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				mov byte ptr es:[bx-1],' '
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je left ;Se sim, repete
				dec dh ;Se n�o for igual, n�o incrementa a quantidade de espa�os com a cor igual
				mov al, 4
				mov ah, dl
				mul ah ;AX = AL * AH (AX = 2*Quant)
				add bx, ax ; Volta � posi��o do cursor
				add bx, 4
			right:
				inc dh
				add bx, 4 ;Mudar para o bloco � frente
				mov ah, es:[bx] ;Posi��o � frente do cursor
				mov byte ptr es:[bx-1],'Y'
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				call func_makeDelay
				mov byte ptr es:[bx-1],' '
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je right ;Se sim, repete
				dec dh ;Se n�o for igual, n�o incrementa a quantidade de espa�os com a cor igual
				cmp dh, 1;Se DL >= 3, tem jogadas
				jge has_plays
				cmp ch, 0
				jl linhas
				jmp no_plays
	has_plays:
		ret 
	no_plays:
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_makeDelay
		call func_drawTabuleiro
		jmp start
		ret
func_hasPlays endp
COMMENT @
func_explode proc
	;mov al, posY
	;mov ah, posX
	cursor_at:
		xor dx, dx
		xor cx, cx
		mov	al, 160;Espa�os por linha
		mov	ah, 1;POSy
		mul	ah ;160 * POSy
		add	ax, 60; (160 * POSy) + POSx
		mov bx, ax; BX = AX
		add bx, 1 ;Para obter a cor
	get_color_around:
		mov	al, es:[bx] ;Posi��o do cursor
		cmp cx, 0 ;Verificar se o vertical j� foi analisado
		jg horizontal
		vertical:
			top:
				inc dl ;Quantidade de espa�os com a cor igual � do cursor
				sub bx, 160 ;Mudar para a linha em cima
				mov ah, es:[bx] ;Posi��o em cima do cursor
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je top ;Se sim, repete
				mov al, 160
				mov ah, dl 
				mul ah ;AX = AL * AH (AX = 160*Quant)
				add bx, ax ; Volta � posi��o do cursor
			bottom:
				inc dh ;Quantidade de espa�os com a cor igual � do cursor
				add bx, 160 ;Mudar para a linha em baixo
				mov ah, es:[bx] ;Posi��o em baixo do cursor
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je bottom ;Se sim, repete
				add dl, dh ;DL = DL + DH
				cmp dl, 3 ;Se DL >= 3, rebenta verticalmente 
				jge boom_vertical
				inc cx
				jmp cursor_at ;Volta ao inicio
		horizontal:
			left:
				inc dl ;Quantidade de espa�os com a cor igual � do cursor
				sub bx, 2 ;Mudar para o bloco atr�s
				mov ah, es:[bx] ;Posi��o atr�s do cursor
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
				je left ;Se sim, repete
				mov al, 2
				mov ah, dl
				mul ah ;AX = AL * AH (AX = 2*Quant)
				add bx, ax ; Volta � posi��o do cursor
			right:
				inc dh
				add bx, 2 ;Mudar para o bloco � frente
				mov ah, es:[bx] ;Posi��o � frente do cursor
				cmp ah, al ;Verificar se a cor do bloco atual � igual ao do cursor
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
@
;|||||||||||||||||||| (end) Procs |||||||||||||||||||| 
;|||||||||||||||||||| (start) Cursor |||||||||||||||||||| 
;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
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

func_leTecla	PROC

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
		;;PROG STARTS HERE
		mov		ax, dseg
		mov		ds,ax
		;;||||||||||||||||
		
		mov		ax,0B800h
		mov		es,ax
	
		call func_limpaEcran
		call func_readFile
		call func_drawTabuleiro
		call func_hasPlays
		
		goto_xy		POSx,POSy	; Vai para nova possi��o
		mov 		ah, 08h	; Guarda o Caracter que est� na posi��o do Cursor
		mov		bh,0		; numero da p�gina
		int		10h			
		mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor	
		
		inc		POSx
		goto_xy		POSx,POSy	; Vai para nova possi��o2
		mov 		ah, 08h		; Guarda o Caracter que est� na posi��o do Cursor
		mov		bh,0		; numero da p�gina
		int		10h			
		mov		Car2, al	; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor2, ah	; Guarda a cor que est� na posi��o do Cursor	
		dec		POSx
	

CICLO:		goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
		mov		ah, 02h
		mov		dl, Car	; Repoe Caracter guardado 
		int		21H	

		inc		POSxa
		goto_xy		POSxa,POSya	
		mov		ah, 02h
		mov		dl, Car2	; Repoe Caracter2 guardado 
		int		21H	
		dec 		POSxa
		
		goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 		ah, 08h
		mov		bh,0		; numero da p�gina
		int		10h		
		mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor
		
		inc		POSx
		goto_xy		POSx,POSy	; Vai para nova possi��o
		mov 		ah, 08h
		mov		bh,0		; numero da p�gina
		int		10h		
		mov		Car2, al	; Guarda o Caracter2 que est� na posi��o do Cursor2
		mov		Cor2, ah	; Guarda a cor que est� na posi��o do Cursor2
		dec		POSx
		
		
		goto_xy		77,0		; Mostra o caractr que estava na posi��o do AVATAR
		mov		ah, 02h		; IMPRIME caracter da posi��o no canto
		mov		dl, Car	
		int		21H			
		
		goto_xy		78,0		; Mostra o caractr2 que estava na posi��o do AVATAR
		mov		ah, 02h		; IMPRIME caracter2 da posi��o no canto
		mov		dl, Car2	
		int		21H			
		
	
		goto_xy		POSx,POSy	; Vai para posi��o do cursor
IMPRIME:	mov		ah, 02h
		mov		dl, '('	; Coloca AVATAR1
		int		21H
		
		inc		POSx
		goto_xy		POSx,POSy		
		mov		ah, 02h
		mov		dl, ')'	; Coloca AVATAR2
		int		21H	
		dec		POSx
		
		goto_xy		POSx,POSy	; Vai para posi��o do cursor
		
		mov		al, POSx	; Guarda a posi��o do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posi��o do cursor
		mov 		POSya, al
		
LER_SETA:	call 		func_leTecla
		cmp		ah, 1
		je		ESTEND
		cmp 		al, 27	; ESCAPE
		je		fim
		;cmp 		al, 13	; ENTER
		;je		func_explode
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

fim:
		call func_makeFile
		call func_limpaEcran
		mov		ah,4CH
		INT		21H
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
		jnc		escreve				; Se n�o existir erro escreve no ficheiro
	
		mov		ah, 09h
		lea		dx, msgErrorCreate
		int		21h
	
		jmp		return_MF

escreve:
		mov		bx, ax				; Coloca em BX o Handle
    	mov		ah, 40h				; indica que � para escrever
    	
		lea		dx, buffer			; DX aponta para a infroma��o a escrever
    	mov		cx, 240				; CX fica com o numero de bytes a escrever
		int		21h					; Chama a rotina de escrita
		jnc		close				; Se n�o existir erro na escrita fecha o ficheiro
	
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
	jc	    erro_ler		; se carry � porque aconteceu um erro
	cmp	    ax,0			;EOF?	verifica se j� estamos no fim do ficheiro 
	je	    fecha_ficheiro	; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
	  mov	    dl,car_fich		; este � o caracter a enviar para o ecran
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

        mov     ah,09h			; o ficheiro pode n�o fechar correctamente
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
		call	func_getRandom
		pop	ax 		; vai bustab_car 'a pilha o n�mero aleat�rio

		mov	dl,cl	
		mov	dh,70
		push	dx		; Passagem de par�metros a func_printNum (posi��o do ecran)
		push	ax		; Passagem de par�metros a func_printNum (n�mero a imprimir)
		call	func_printNum		; imprime 10 aleat�rios na parte direita do ecran
		loop	ciclo4		; Ciclo de impress�o dos n�meros aleat�rios
		
		mov   	ax, 0b800h	; Segmento de mem�ria de v�deo onde vai ser desenhado o tabuleiro
		mov   	es, ax	
		mov	linha, 	8	; O Tabuleiro vai come�ar a ser desenhado na linha 8 
		mov	nlinhas, 6	; O Tabuleiro vai ter 6 linhas
		
ciclo2:		mov	al, 160		
		mov	ah, linha
		mul	ah
		add	ax, 60
		mov 	bx, ax		; Determina Endere�o onde come�a a "linha". bx = 160*linha + 60

		mov	cx, 9		; S�o 9 colunas 
ciclo1:  	
		mov 	dh,	tab_car	; vai imprimir o tab_caracter "SAPCE"
		mov	es:[bx],dh	;
	
novatab_cor:	
		call	func_getRandom	; Calcula pr�ximo aleat�rio que � colocado na pinha 
		pop	ax ; 		; Vai bustab_car 'a pilha o n�mero aleat�rio
		and 	al,01110000b	; posi��o do ecran com tab_cor de fundo aleat�rio e tab_caracter a preto
		cmp	al, 0		; Se o fundo de ecran � preto
		je	novatab_cor		; vai bustab_car outra tab_cor 

		mov 	dh,	   tab_car	; Repete mais uma vez porque cada pe�a do tabuleiro ocupa dois tab_carecteres de ecran
		mov	es:[bx],   dh		
		mov	es:[bx+1], al	; Coloca as tab_caracter�sticas de tab_cor da posi��o atual 
		inc	bx		
		inc	bx		; pr�xima posi��o e ecran dois bytes � frente 

		mov 	dh,	   tab_car	; Repete mais uma vez porque cada pe�a do tabuleiro ocupa dois tab_carecteres de ecran
		mov	es:[bx],   dh
		mov	es:[bx+1], al
		inc	bx
		inc	bx
		
		mov	di,1 ;func_makeDelay de 1 centesimo de segundo
		;;call	func_makeDelay
		loop	ciclo1		; continua at� fazer as 9 colunas que tab_correspondem a uma liha completa
		
		inc	linha		; Vai desenhar a pr�xima linha
		dec	nlinhas		; contador de linhas
		mov	al, nlinhas
		cmp	al, 0		; verifica se j� desenhou todas as linhas 
		jne	ciclo2		; se ainda h� linhas a desenhar continua 
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
;n�o tem parametros de entrada
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

	add	dx,ultimo_num_aleat	; vai bustab_car o aleat�rio anterior
	add	cx,dx	
	mov	ax,65521
	push	dx
	mul	cx			
	pop	dx			 
	xchg	dl,dh
	add	dx,32749
	add	dx,ax

	mov	ultimo_num_aleat,dx	; guarda o novo numero aleat�rio  

	mov	[BP+4],dx		; o aleat�rio � passado por pilha

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
;n�o tem parametros de sa�da
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






;recebe em di o n�mero de milisegundos a esperar
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
;|||||||||||||||||||| (end) Tabuleiro |||||||||||||||||||| 
Cseg	ends
end	func_moveCursor