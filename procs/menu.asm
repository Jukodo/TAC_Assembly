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

		;Cursor
		Car		db	32	; Guarda um caracter do Ecran 
		Cor		db	7	; Guarda os atributos de cor do caracter
		Car2		db	32	; Guarda um caracter do Ecran 
		Cor2		db	7	; Guarda os atributos de cor do caracter
		POSy		db	8	; a linha pode ir de [1 .. 25] (val: posição inicial)
		POSx		db	30	; POSx pode ir [1..80] (val: posição inicial)
		POSya		db	8	; Posição anterior de y
		POSxa		db	30	; Posição anterior de x
		
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
		fname	db	'grelha2.txt',0
		msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
		msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
		
		
		;Grelha
		max_linhas		db  6
		max_colunas 	db  9
		cell			dw  1340
		tab_car			db	' '
		buffer			db 	132 dup(0)
		
		;Configuracao
		str_grelha_0	db	"Pressione ENTER para alterar a cor:$"
		str_grelha_1	db	"Vermelho$"
		str_grelha_2	db	"Rosa$"
		str_grelha_3	db	"Azul claro$"
		str_grelha_4	db	"Verde$"
		str_grelha_5	db	"Laranja$"
		str_grelha_6	db	"Branco$"
		str_grelha_7	db	"Azul escuro$"
		bloco_pos		dw	1340

DSEG    ENDS

CSEG    SEGMENT PARA PUBLIC 'CODE'

ASSUME  CS:CSEG, DS:DSEG, SS:PILHA

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
    	mov		cx, 132				; CX fica com o numero de bytes a escrever
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
		mov byte ptr es:[bx+2], '1'
		
		;call func_makeDelay

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

func_editColor proc

	xor ax, ax
	xor bx, bx
	xor dx, dx
	
	mov bx, bloco_pos
	
	cmp ch, 0
	jne pink
	
	
	
	red:
		mov ah, 00064 
		mov es:[bx+1], ah
		mov es:[bx+3], ah
		jmp fim
	
	pink:
		cmp ch, 1
		jne lblue
		mov ah, 00080 
		mov es:[bx+1], ah
		mov es:[bx+3], ah
		jmp fim
	
	lblue:
		cmp ch, 2
		jne green
		mov ah, 00048 
		mov es:[bx+1], ah
		mov es:[bx+3], ah
		jmp fim
	
	green:
		cmp ch, 3
		jne orange
		mov ah, 00032 
		mov es:[bx+1], ah
		mov es:[bx+3], ah
		jmp fim
	
	orange:
		cmp ch, 4
		jne white
		mov ah, 00096 
		mov es:[bx+1], ah
		mov es:[bx+3], ah
		jmp fim
	
	white:
		cmp ch, 5
		jne blue
		mov ah, 00112 
		mov es:[bx+1], ah
		mov es:[bx+3], ah
		jmp fim
	
	blue:
		mov ah, 00016 
		mov es:[bx+1], ah
		mov es:[bx+3], ah
		jmp fim
		
	
	fim:
		ret
		;call func_moveCursor
	
	
	
	

func_editColor endp


func_moveCursor  proc
	
		xor cx, cx


		;;PROG STARTS HERE
		mov		ax, dseg
		mov		ds,ax
		;;||||||||||||||||
		
		mov		ax,0B800h
		mov		es,ax
		
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
		
LER_SETA:	
		call 		func_leTecla
		cmp		ah, 1
		je		ESTEND
		cmp 		al, 27	; ESCAPE
		je		fim
		
		cmp 		al, 13	; ENTER
		je		swtich_color
		
		push ax
		push bx
		
		swtich_color:
			
			xor ax, ax
			
			mov bx, bloco_pos
			mov al, 00064 
			cmp es:[bx+1], al
			jne pink
			
			red:
				mov ch, 0
				jmp edit_color
				
			pink:
				mov al, es:[bx+1]
				cmp al, 00080
				jne lblue
				mov ch, 1
				jmp edit_color
				
			lblue:
				mov al, es:[bx+1]
				cmp al, 00048
				jne green
				mov ch, 2
				jmp edit_color
			
			green:
				mov al, es:[bx+1]
				cmp al, 00032
				jne orange
				mov ch, 3
				jmp edit_color
			
			orange:
				mov al, es:[bx+1]
				cmp al, 00096
				jne white
				mov ch, 4
				jmp edit_color
			
			white:
				mov al, es:[bx+1]
				cmp al, 00112
				jne blue
				mov ch, 5
				jmp edit_color
				
			blue: ;00016
				mov ch, 6
				jmp edit_color
			
			pop ax
			pop bx
			
			edit_color:
				inc ch
				cmp ch, 6
				jg  reset_counter
				
				reset_counter:
					mov ch, 0
					
				
				jmp func_editColor
				;ret

		
		jmp		LER_SETA
		
ESTEND:		
		cmp 		al,48h
		jne		BAIXO
		;if (POSy <= 9){ break; }
			cmp 	POSy, 8
			jle 		CICLO
		dec		POSy		;cima
		sub bloco_pos, 160
		jmp		CICLO

BAIXO:		cmp		al,50h
		jne		ESQUERDA
		;if (POSy >= 14){ break; }
			cmp 	POSy, 13
			jge 		CICLO
		inc 	POSy		;Baixo
		add bloco_pos, 160
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		;if (POSx <= 31){ break; }
			cmp 	POSx, 30
			jle 		CICLO
		dec		POSx		;Esquerda
		dec		POSx		;Esquerda
		sub bloco_pos, 4
		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		;if (POSx >= 48){ break; }
			cmp 	POSx, 46
			jge 		CICLO
		inc		POSx		;Direita
		inc		POSx		;Direita
		add bloco_pos, 4
		jmp		CICLO
		


fim:

		call func_colorsToBuffer
		call func_makeFile
		mov		ah,4CH
		INT		21H
		
		


		
func_moveCursor	endp


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
					
						;mov dh, 32
						;mov es:[bx], dh
						mov es:[bx+1], ah
						
						;mov es:[bx+2], dh
						mov es:[bx+3], ah
						
						jmp next_cell
					
					next_cell:
						mov bx, cell
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
						cmp cl, 7
						jge close_file; Se já leu o tamanho máximo de linhas que pode ler, termina
						;add bx, 8
						add bx, 160; Muda de linha, mas fica na ultima coluna
						sub bx, 34	; Vai para a 1ª coluna da nova linha
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
		jnc     configuracao

		mov     ah,09h			; o ficheiro pode não fechar correctamente
		lea     dx,msgErrorClose
		Int     21h
		
	
	configuracao:
	
		xor ax, ax
		xor bx, bx
		xor cx, cx
		xor dx, dx
		
		goto_xy 2,1
		MOSTRA str_grelha_0
		
		
		mov ch, 25 
		mov es:[484], ch
		
		goto_xy 4,3
		MOSTRA str_grelha_1
		
		mov es:[644], ch
		
		goto_xy 4,4
		MOSTRA str_grelha_2
		
		mov es:[804], ch
		
		goto_xy 4,5
		MOSTRA str_grelha_3
		
		mov es:[964], ch
		
		goto_xy 4,6
		MOSTRA str_grelha_4
		
		mov es:[1124], ch
		
		goto_xy 4,7
		MOSTRA str_grelha_5
		
		mov es:[1284], ch
		
		goto_xy 4,8
		MOSTRA str_grelha_6
		
		mov es:[1444], ch
		
		goto_xy 4,9
		MOSTRA str_grelha_7
		
		call func_moveCursor
		
		jmp fim
	
	

	fim:
		ret
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