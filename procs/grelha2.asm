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
	fname	db	'grelha2.txt',0
	fhandle dw	0
	buffer	db 106 dup(0)
			
	str_cor	db	"     $"
	lala		db	10
	msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
	msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
	msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"
	;|||||||||||||||||||| (end) CriarFich |||||||||||||||||||| 
	;|||||||||||||||||||| (start) LerFich |||||||||||||||||||| 
	msgErrorOpen       db      'Erro ao tentar abrir o ficheiro$'
	msgErrorRead    db      'Erro ao tentar ler do ficheiro$'
	fname_ler         	db      'grelha2.TXT',0
	car_fich        db      ?
	;|||||||||||||||||||| (end) LerFich |||||||||||||||||||| 
	;|||||||||||||||||||| (start) Tabuleiro |||||||||||||||||||| 
	ultimo_num_aleat dw 0
	str_num db 5 dup(?),'$'
	linha		db	0	; Define o número da linha que está a ser desenhada
	nlinhas		db	0
	tab_cor		db 	0
	tab_car		db	' '	
	
	max_linhas		db 6
	max_colunas 	db 9
	
	line_counter		db 0
	column_counter 	db 0
	
	counter db 0
	
	
	;|||||||||||||||||||| (end) Tabuleiro |||||||||||||||||||| 
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg


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


;----------------------------------------(start) func_colorsToBuffer ----------------------------------------
;Params	: 	buffer, max_colunas, max_linhas
;Func	:	Percorre todas as células da grelha e escreve, em formato de grelha(9x6), as cores no buffer para escrever no ficheiro

;AL 	: 	Cor da célula
;AH		: 	Cor da célula convertida ou \n. Argumento para escrever no buffer
;BX 	:	Endereços da mem. video
;CH 	: 	Contador de células percorridas
;CH 	: 	Contador de linhas percorridas

func_colorsToBuffer proc

	xor ax, ax
	xor bx, bx 
	xor cx, cx
	xor si, si
	xor dx, dx

	mov bx, 1340; Vai para a posição absoluta da 1ª celula da grelha (linha 0, coluna 0)
	
	cycle:
	
		mov	al, es:[bx+1]; Guarda a cor da célula
		;mov byte ptr es:[bx+2], '1'
		
		call func_makeDelay
		call func_makeDelay

		;swtich(al):
		;	case 00064: ah = 2 (red)
		;	case 00080: ah = 3 (pink)
		;	case 00048: ah = 4 (lblue)
		;	case 00032: ah = 5 (green)
		;	case 00096: ah = 6 (orange)
		;	case 00112: ah = 7 (white)
		;	default : (00016) ah = 8 (blue)
			
			
		convert_color:
			cmp al, 00064  ; AL é red?
			jne pink
		
			red:
				mov ah, 2
				jmp addTobuffer
				
			pink:
				cmp al, 00080 
				jne lblue
				mov ah, 3
				jmp addTobuffer
				
			lblue:
				cmp al, 00048 
				jne green
				mov ah, 4
				jmp addTobuffer
			
			green:
				cmp al, 00032 
				jne orange
				mov ah, 5
				jmp addTobuffer
			
			orange:
				cmp al, 00096 
				jne white
				mov ah, 6
				jmp addTobuffer
			
			white:
				cmp al, 00112 
				jne blue
				mov ah, 7
				jmp addTobuffer
				
			blue: ;00016
				mov ah, 8
				jmp addTobuffer
			
		
		addTobuffer:;Adiciona uma cor e um espaço nas respetivas posicoes no buffer
	
			add ah, '0';Converte numero para string
			MOV buffer[si], ah
			mov byte ptr es:[bx+2], ah
			
			inc si; Próxima posição para escrever um espaço
			mov ah, 32; space
			mov buffer[si], ah;Entre cada cor escreve um espaço
			
			inc si;Após escrever o espaço vai para próxima posição para escrever a próxima cor
			
			
			jmp next_cell
		
		

		next_cell:;Le a celula seguinte
		
		add bx, 4 ;Anda para a celula da direita
		inc ch; Nº de células percorridas
		cmp ch, max_colunas
		jge next_line; Se já leu o tamanho máximo de celulas que pode ler muda de linha
		jmp cycle; Se não le a próxima celula
		
		next_line:;Salta para a 1ª celula de linha seguinte
		
		;inc si
		;mov ah, 13; carriage return
		;mov buffer[si], ah; carriage return no fim da linha
		
		;inc si
		;mov ah, 10; new line
		;mov buffer[si], ah; entre cada linha vai haver um \n
		
		;inc si
		
		inc cl; Nº de linhas percorridas
		cmp cl, max_linhas
		jge fim; Se já leu o tamanho máximo de linhas que pode ler, termina
		add bx, 160; Muda de linha, mas fica na ultima coluna
		sub bx, 36; Vai para a 1ª coluna da nova linha
		mov ch, 0; Renicia a contagem das células pois estamos numa nova linha
		jmp cycle; Vai ler a próxima célula (1ª celula da linha nova)
		
		fim:
			ret
		
func_colorsToBuffer endp

;----------------------------------------(end) func_colorsToBuffer ----------------------------------------

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
	

CICLO:		goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
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
		call func_colorsToBuffer
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
		jnc		escreve				; Se não existir erro escreve no ficheiro
	
		mov		ah, 09h
		lea		dx, msgErrorCreate
		int		21h
	
		jmp		return_MF

escreve:
		mov		bx, ax				; Coloca em BX o Handle
    	mov		ah, 40h				; indica que é para escrever
    	
		lea		dx, buffer			; DX aponta para a infromação a escrever
    	mov		cx, 107				; CX fica com o numero de bytes a escrever
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


str2num proc
	
	; str_cor[5] = string de armazenamento
	; bl = 10 (denominador)
	; ax = 00112 (numerador)
	; al = quociente
	; ah = resto
	; si = 4, 3, 2, 1, 0
	
	mov bl, 10
	mov ax, 112
	mov si, 4


	ciclo:
	
		div bl
		cmp al, 0
		je fim
		
		add ah, '0'
		mov buffer[si], ah ; str_cor[si] = resto
		
		
		dec si
		
		;mov dl, 20
		;mov dh, 0
		;mov ah, 0
		;mov al, al
		;push	dx		; Passagem de parâmetros a func_printNum (posição do ecran)
		;push	ax		; Passagem de parâmetros a func_printNum (número a imprimir)
		;call	func_printNum		; imprime POSy
		
	fim:
		;xor ax, ax
		;mov ah, 0046
		;xor bx, bx
		;mov bx, 10
		;mov ah, str_cor
		;mov	es:[bx+1],ah
		
		;mov buffer[0], ah
		ret
str2num endp 

print_array proc

	mov si, 0
	mov bx, 50
	mov ah, 0
	

	ciclo:
		mov al, buffer[si]
		inc si
		mov es:[bx], al
	next_column:
		inc column_counter
		mov ah, column_counter
		cmp ah, max_colunas
		je next_line
		add bx, 2
		jmp ciclo
	next_line:
		mov column_counter, 0
		add bx, 160
		sub bx, 16
		inc line_counter
		mov ah, line_counter
		cmp ah, max_linhas
		jne ciclo
	
		ret

print_array endp

write_array proc

	mov si, 0
	mov bx, 50
	mov ah, 0
	
	ciclo:
		xor ax, ax
		call str2num
		xor ax,ax
		mov ah, str_cor
		mov buffer[si], ah
		inc si
	next_column:
		inc column_counter
		mov ah, column_counter
		cmp ah, max_colunas
		je next_line
		add bx, 2
		jmp ciclo
	next_line:
		mov column_counter, 0
		add bx, 160
		sub bx, 16
		inc line_counter
		mov ah, line_counter
		cmp ah, max_linhas
		jne ciclo
	
		ret

write_array endp


func_drawTabuleiro PROC
	;MOV	AX, DADOS
	;MOV	DS, AX
	
	;mov		ax, dseg
	;mov		ds,ax
	
	xor si, si
	mov	cx,10		; Faz o ciclo 10 vezes
ciclo4:
		call	func_getRandom
		pop	ax 		; vai bustab_car 'a pilha o número aleatório

		mov	dl,cl	
		mov	dh,70
		push	dx		; Passagem de parâmetros a func_printNum (posição do ecran)
		push	ax		; Passagem de parâmetros a func_printNum (número a imprimir)
		call	func_printNum		; imprime 10 aleatórios na parte direita do ecran
		loop	ciclo4		; Ciclo de impressão dos números aleatórios
		
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
		call	func_getRandom	; Calcula próximo aleatório que é colocado na pinha 
		pop	ax ; 		; Vai bustab_car 'a pilha o número aleatório
		and 	al,01110000b	; posição do ecran com tab_cor de fundo aleatório e tab_caracter a preto
		cmp	al, 0		; Se o fundo de ecran é preto
		je	novatab_cor		; vai bustab_car outra tab_cor

		mov 	dh,	   tab_car	; Repete mais uma vez porque cada peça do tabuleiro ocupa dois tab_carecteres de ecran
		mov	es:[bx],   dh
		mov	es:[bx+1], al	; Coloca as tab_características de tab_cor da posição atual
		push bx

		pop bx
		
		inc	bx		
		inc	bx		; próxima posição e ecran dois bytes à frente 

		mov 	dh,	   tab_car	; Repete mais uma vez porque cada peça do tabuleiro ocupa dois tab_carecteres de ecran
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

			
	call print_array
	;call write_array
	;call str2num
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
;|||||||||||||||||||| (end) Tabuleiro |||||||||||||||||||| 
Cseg	ends
end	func_moveCursor