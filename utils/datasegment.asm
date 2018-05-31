;--------------------------------------------------------------
; Abre ficheio de texto e envia para o ecran 
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'

	;Create file
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
	
	;Read file
	POSy			db	4	; a linha pode ir de [ .. ]			REP
	POSx			db	10	; POSx pode ir [ .. ]				REP
    Erro_Open       db      'Erro ao tentar abrir o ficheiro$'	
    Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
    Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
    Fich         	db      'ABC.TXT',0
    HandleFich      dw      0
    car_fich        db      ?
	
	;Cursor
	string	db	"Teste prático de T.I",0
	Car		db	32	; Guarda um caracter do Ecran				REP
	Cor		db	7	; Guarda os atributos de cor do caracter	REP
	Car2	db	32	; Guarda um caracter do Ecran 
	Cor2	db	7	; Guarda os atributos de cor do caracter
	POSy	db	5	; a linha pode ir de [1 .. 25]				REP
	POSx	db	10	; POSx pode ir [1..80]						REP
	POSya	db	5	; Posição anterior de y
	POSxa	db	10	; Posição anterior de x
	
	;HMS_DMA
	STR12	 	db 		"            "				; String para 12 digitos	
	NUMERO		db		"                    $", 	; String destinada a guardar o número lido
	NUM_SP		db		"                    $" 	; PAra apagar zona de ecran
	DDMMAAAA	db		"                     "
	Horas		dw		0							; Vai guardar a HORA actual
	Minutos		dw		0							; Vai guardar os minutos actuais
	Segundos	dw		0							; Vai guardar os segundos actuais
	Old_seg		dw		0							; Guarda os últimos segundos que foram lidos
	POSy		db		10							; a linha pode ir de [1 .. 25]										REP
	POSx		db		40							; POSx pode ir [1..80]												REP
	NUMDIG		db		0							; controla o numero de digitos do numero lido
	MAXDIG		db		4							; Constante que define o numero MAXIMO de digitos a ser aceite
	
	;Tabul
	ultimo_num_aleat 	dw 0
	str_num 			db 5 dup(?),'$'
    linha				db	0	; Define o número da linha que está a ser desenhada
    nlinhas				db	0
	cor					db 	0																							;REP
	car					db	' '																							;REP
	
	
dseg	ends

cseg	segment para public 'code'
assume	cs:cseg, ds:dseg


