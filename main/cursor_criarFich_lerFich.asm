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
	POSy		db	9	; a linha pode ir de [1 .. 25] (val: posição inicial)
	POSx		db	31	; POSx pode ir [1..80] (val: posição inicial)
	POSya		db	9	; Posição anterior de y
	POSxa		db	31	; Posição anterior de x
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

apaga_ecran	proc
		xor		bx,bx
		mov		cx,25*80
		
apaga:			
		mov	byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 		bx
		loop		apaga
		ret
apaga_ecran	endp


;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp
;########################################################################

func_moveCursor  proc
		;;PROG STARTS HERE
		mov		ax, dseg
		mov		ds,ax
		;;||||||||||||||||
		
		mov		ax,0B800h
		mov		es,ax
	
		call apaga_ecran
		call func_readFile
		
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
		
LER_SETA:	call 		LE_TECLA
		cmp		ah, 1
		je		ESTEND
		CMP 		AL, 27	; ESCAPE
		JE		FIM
		jmp		LER_SETA
		
ESTEND:		cmp 		al,48h
		jne		BAIXO
		;if (POSy <= 9){ break; }
			cmp 	POSy, 9
			jle 		CICLO
		
		dec		POSy		;cima
		jmp		CICLO

BAIXO:		cmp		al,50h
		jne		ESQUERDA
		;if (POSy >= 14){ break; }
			cmp 	POSy, 14
			jge 		CICLO
		inc 	POSy		;Baixo
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		;if (POSx <= 31){ break; }
			cmp 	POSx, 31
			jle 		CICLO
		dec		POSx		;Esquerda
		dec		POSx		;Esquerda

		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		;if (POSx >= 48){ break; }
			cmp 	POSx, 48
			jge 		CICLO
		inc		POSx		;Direita
		inc		POSx		;Direita
		
		jmp		CICLO

fim:
		call func_makeFile
		call apaga_ecran
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
Imp_fname_ler	PROC

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
Imp_fname_ler	endp


;########################################################################

func_readFile  proc
	call	apaga_ecran
	goto_xy	1,1
	call	Imp_fname_ler

		goto_xy	2,22
		;mov	ah,4CH
		;INT	21H
		ret
func_readFile	endp
;|||||||||||||||||||| (end) LerFich |||||||||||||||||||| 
Cseg	ends
end	func_moveCursor