;Trabalho da disciplina SSC0511 Organização de Computadores Digitais
; Prof Dr. Eduardo Simoes

;Grupo:
;Ellian Carlos 		nUSP 11846324
;Giovanna Fardini 	nUSP 10260671
;Thales Damasceno 	nUSP 11816150
;Vinicius Baca 		nUSP 10788589

; Jogo baseado no Dino Chrome (jogo do Google Chrome quando nao ha conexao de internet)

jmp main																									

;********************************************************
;                Declaracao de variaveis
;********************************************************

Letra: var #1
dino: string "K" ; Para desenhar o personagem 
cacto: string "Y"	; Para desenhar o cacto 
placar : string "SEU RECORDE: " ; String do placar

pontos: var #1

delay1: var #1300	; Variaveis para usar como parametro para o delay(quanto maior forem, mais lenta é cada ciclo)
delay2: var #100

offset: var #0 ; offset do cenário

;--------------------------------------------------------------------------------------------------------------
main:	
	
	loadn r1, #0
	store offset, r1

	call ApagaTela
	loadn r1, #tela0Linha0		; Imprime a tela inicial
	loadn r2, #512              
	call ImprimeTela
	
	loadn r1, #tela2Linha0		
	loadn r2, #256             
	call ImprimeTela2
	
	loadn r1, #tela3Linha0		
	loadn r2, #1792             
	call ImprimeTela2
	
	jmp Loop_Inicio
	
	Loop_Inicio:
		
		call DigLetra 		; Le uma letra
		
		loadn r0, #' '		; Espera que o espaco seja digitada para iniciar o jogo
		load r1, Letra
		cmp r0, r1
		jne Loop_Inicio
	
	set_inicio:
		
		push r2
		loadn r2, #0				; Inicializa os pontos
		store pontos, r2
		pop r2
		
		loadn r0, #1020
		store delay1, r0             ; delay cacto
		
		loadn r0, #80                ; delay pulo
		store delay2, r0			

	GameOn:		; Inicializa variaveis e registradores usados no jogo antes de comecar o loop principal	

		call ApagaTela		

		loadn r1, #tela1Linha0
		call ImprimeTelaJogo  		
		

		loadn r1, #placar		
		loadn r2, #0
		call ImprimeStr
		
		loadn r7, #' '	; Parametro para saber se a tecla certa foi pressionada
		loadn r6, #492	; Posicao do personagem na tela 
		loadn r2, #519	; Posicao do cacto na tela 
		load r4, dino	; Guardando a string do personagem no registrador r4
		load r1, cacto	; Guardando a string do cacto no registrador r1
		loadn r5, #0	; Ciclo do pulo (0 = chao, entre 1 e 3 = sobe, maior que 3 = desce)

		jmp LoopJogo
	
		LoopJogo:		; Loop principal do jogo

			call CenarioAnda ; Move o cenario conforme o cacto avanca

			call ChecaColisao	; Checa se houve uma colisao
			
			call AtPontos 		; Atualiza os pontos

			call ApagaPersonagem 	; Desenha o personagem
			call PrintaPersonagem
			
			call AtPosicaoObstaculo 	; Move o cacto
			outchar r1, r2 				
			
			call DelayChecaPulo		; Atrasa a execucao do programa pra ver se houve colisao
			call AtPosicaoPersonagem	; Se nao houve colisao atualiza a posicao do personagem
			
			push r3 			; Checa se pode pular (caso que o personagem esta no chao)
			loadn r3, #0 
			cmp r5, r3
				ceq ChecaPulo
			pop r3
				
			
		jmp LoopJogo 	; Volta para o loop
	
	
	GameOver:
	
		call ApagaTela				;	Imprime a tela do fim do jogo

		loadn r1, #tela4Linha0
		loadn r2, #1792
		call ImprimeTela

		loadn r1, #tela5Linha0
		loadn r2, #2304
		call ImprimeTela2

		loadn r1, #tela6Linha0
		loadn r2, #512
		call ImprimeTela2
		
		load r5, pontos
		loadn r6, #1060
		call PrintaNumero
		call DigLetra
		
		; Espera que a tecla 's' seja digitada para reiniciar o jogo
		loadn r0, #'n'
		load r1, Letra
		cmp r0, r1
		jeq fim_de_jogo
		
		loadn r0, #'s'
		cmp r0, r1
		jne GameOver
		
		call ApagaTela
	
		pop r2
		pop r1
		pop r0

		pop r0	
		jmp set_inicio	
		
fim_de_jogo:
	call ApagaTela
	halt

;-------------------------------------------------------------------------------------------------------------------------

;********************************************************
;                    PrintaPersonagem
;********************************************************

PrintaPersonagem:
	push r0
	
	outchar r4, r6 ; Printa o corpo do boneco	
	dec r4
	loadn r0, #40
	sub r6, r6, r0
	outchar r4, r6 ; Printa a cabeca  do boneco
	add r6, r6, r0
	inc r4
	
	pop r0			
	rts
	
;********************************************************
;                    ApagaPersonagem
;********************************************************

ApagaPersonagem:
	
	push r4
	push r0

	loadn r4, #' '	; Printa um espaco no lugar do personagem
	outchar r4, r6 	
	
	loadn r0, #40
	sub r6, r6, r0
	outchar r4, r6 
	add r6, r6, r0
	
	pop r0
	pop r4
	rts
	

;********************************************************
;                   AtPosicaoPersonagem
;********************************************************

AtPosicaoPersonagem:

	push r0
	
	;if r5 = 1		; Caso o ciclo do pulo esteja em 1, 2, 3 ou 4, o personagem sobe
	loadn r0, #1
	cmp r5, r0
		ceq Sobe

	;if r5 = 2
	loadn r0, #2
	cmp r5, r0
		ceq Sobe
		
	;if r5 = 3
	loadn r0, #3
	cmp r5, r0
		ceq Sobe
		
	;if r5 = 4
	loadn r0, #4
	cmp r5, r0
		ceq Sobe
	
	;if r5 = 5		; Caso o ciclo do pulo esteja em 5, 6, 7 ou 8, o personagem desce
	loadn r0, #5
	cmp r5, r0
		ceq Desce
		
	;if r5 = 6
	loadn r0, #6
	cmp r5, r0
		ceq Desce
		
	;if r5 = 7
	loadn r0, #7
	cmp r5, r0
		ceq Desce
		
	;if r5 = 8
	loadn r0, #8
	cmp r5, r0
		ceq Desce
		
	;if r5 != 0
	loadn r0, #0		; Caso o personagem esteja no chao nao deve ser alterado aqui
	cmp r5, r0
		cne IncrementaPulo	; Caso esteja no ar, deve continuar sendo incrementado
		
	loadn r0, #9	; Ate que o ciclo chegue em 9, entao se torna 0 novamente (personagem esta no chao novamente)
	cmp r5, r0
		ceq ResetaPulo				
		
	pop r0
	rts
	
;********************************************************
;               ATUALIZA POSICAO DO CACTO
;********************************************************

AtPosicaoObstaculo:
	
	push r0
	loadn r0 , #' '
	
	outchar r0, r2
	
	dec r2

	;if posicao do cacto = 480 (fim da tela para a esquerda)
	loadn r0, #480
	cmp r2, r0
		ceq ResetaObstaculo
		
	loadn r0, #440
	cmp r2, r0
		ceq ResetaObstaculo
		
	loadn r0, #400
	cmp r2, r0
		ceq ResetaObstaculo

	pop r0
	rts

;********************************************************
;                       ResetaCacto
;********************************************************

ResetaObstaculo:
	push r0
	push r1
	push r3
	
	loadn r2, #519		; Posicao (padrao do cacto)
	
	call GeraPosicao	; Gera a nova  posicao para o cacto
	
	loadn r1, #1		;  Caso 1
	cmp r3,r1
	ceq AlteraPos1
	
	loadn r1, #2		; Caso 2
	cmp r3,r1
	ceq AlteraPos2
	
	pop r3
	pop r1
	pop r0
	rts

	
;********************************************************
;                       GeraPosicao
;********************************************************

; Funcao que gera uma posicao aleatoria para o cacto

GeraPosicao :
	push r0
	push r1
						; sorteia nr. randomico entre 0 - 7
	loadn r0, #Rand 	; declara ponteiro para tabela rand na memoria!
	load r1, IncRand	; Pega Incremento da tabela Rand
	add r0, r0, r1		; Soma Incremento ao inicio da tabela Rand
						; R2 = Rand + IncRand
	loadi r3, r0 		; busca nr. randomico da memoria em R3
						; R3 = Rand(IncRand)						
	inc r1			
	loadn r0, #30
	cmp r1, r0			; Compara com o Final da Tabela e re-estarta em 0
	jne ResetaVetor
		loadn r1, #0		; re-estarta a Tabela Rand em 0
  ResetaVetor:
	store IncRand, r1	; Salva incremento ++
	
	
	pop r1
	pop r0
	rts

;********************************************************
;                       ResetaAleatorio
;********************************************************

; Funcao que reseta a semente para a funcao de geracao aleatoria

ResetaAleatorio:	
		
		push r2
		loadn r2,#28
		
		sub r1,r2,r2 
		
		pop r2
		rts

;********************************************************
;     				  AlteraPos1
;********************************************************

; Caso 1 da posicao do cacto

AlteraPos1:
		push r1		
		loadn r1,#40
		sub r2,r2,r1
		pop r1
		rts
	
;********************************************************
;     				  AlteraPos2
;********************************************************

; Caso 2 da posicao do cacto

AlteraPos2:
		push r1
		loadn r1,#80
		sub r2,r2,r1	
		pop r1
		rts


;********************************************************
;                  Move a tela do cenario
;********************************************************

CenarioAnda: 
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	store cacto, r1
	loadn r1, #tela1Linha0
	loadn r2, #1280
	load r3, offset
	loadn r4, #51 ; FLAG: TERIA QUE MUDAR AQUI
	call ImprimeTelaJogo

	inc r3
	mod r3, r3, r4
	store offset, r3
	load r1, cacto
	loadn r2, #519
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts


;********************************************************
;                  	     DigLetra
;********************************************************

DigLetra:	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	push r0
	push r1
	loadn r1, #255	; Se nao digitar nada vem 255

   DigLetra_Loop:
		inchar r0			; Le o teclado, se nada for digitado = 255
		cmp r0, r1			;compara r0 com 255
		jeq DigLetra_Loop	; Fica lendo ate' que digite uma tecla valida

	store Letra, r0			; Salva a tecla na variavel global "Letra"

	pop r1
	pop r0
	rts
	
;********************************************************
;                       ApagaTela
;********************************************************

ApagaTela:
	push r0
	push r1
	
	loadn r0, #1200		; apaga as 1200 posicoes da Tela
	loadn r1, #' '		; com "espaco"
	
	   ApagaTela_Loop:	;label for(r0=1200;r3>0;r3--)
		dec r0
		outchar r1, r0
		jnz ApagaTela_Loop
 
	pop r1
	pop r0
	rts	

;********************************************************
;                       ImprimeTela
;********************************************************	

ImprimeTela: 	;  Rotina de Impresao de Cenario na Tela Inteira
				;  r1 = endereco onde comeca a primeira linha do Cenario
				;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r4 na pilha para ser usado na subrotina

	loadn r0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn r3, #40 	; Incremento da posicao da tela!
	loadn r4, #41  	; incremento do ponteiro das linhas da tela
	loadn r5, #1200 ; Limite da tela!
	
   ImprimeTela_Loop:
		call ImprimeStr
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne ImprimeTela_Loop	; Enquanto r0 < 1200

	pop r5	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;********************************************************
;                   ImprimeTelaJogo
;********************************************************	

ImprimeTelaJogo: 	;  Rotina de Impresao de Cenario na Tela Inteira
				;  r1 = endereco onde comeca a primeira linha do Cenario
				;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r4 na pilha para ser usado na subrotina

	loadn r0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn r3, #40 	; Incremento da posicao da tela!
	loadn r4, #51  	; incremento do ponteiro das linhas da tela ; FLAG: TERIA QUE MUDAR AQUI
	loadn r5, #1200 ; Limite da tela!
	
   ImprimeTelaJogo_Loop:
		call ImprimeStrJogo
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne ImprimeTelaJogo_Loop	; Enquanto r0 < 1200

	pop r5	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

ImprimeStrJogo:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; Criterio de parada
	load r5, offset
	add r1, r1, r5
   ImprimeStrJogo_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq ImprimeStrJogo_Sai
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		jmp ImprimeStrJogo_Loop
	
   ImprimeStrJogo_Sai:
    store offset, r5
	pop r5	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
;********************************************************
;                       IMPRIME TELA2
;********************************************************	

ImprimeTela2: 	;  Rotina de Impresao de Cenario na Tela Inteira
		;  r1 = endereco onde comeca a primeira linha do Cenario
		;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina

	loadn r0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn r3, #40  	; Incremento da posicao da tela!
	loadn r4, #41  	; incremento do ponteiro das linhas da tela
	loadn r5, #1200 ; Limite da tela!
	loadn r6, #tela0Linha0	; Endereco onde comeca a primeira linha do cenario!!
	
   ImprimeTela2_Loop:
		call ImprimeStr2
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		add r6, r6, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne ImprimeTela2_Loop	; Enquanto r0 < 1200

	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;********************************************************
;                   IMPRIME STRING2
;********************************************************
	
ImprimeStr2:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina
	
	
	loadn r3, #'\0'	; Criterio de parada
	loadn r5, #' '	; Espaco em Branco

   ImprimeStr2_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq ImprimeStr2_Sai
		cmp r4, r5		; If (Char == ' ')  vai Pula outchar do espaco para na apagar outros caracteres
		jeq ImprimeStr2_Skip
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
   		storei r6, r4
   ImprimeStr2_Skip:
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		inc r6
		jmp ImprimeStr2_Loop
	
   ImprimeStr2_Sai:	
	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
;********************************************************
;                   ImprimeStr
;********************************************************
	
ImprimeStr:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; Criterio de parada

   ImprimeStr_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq ImprimeStr_Sai
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		jmp ImprimeStr_Loop
	
   ImprimeStr_Sai:	
	pop r4	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;********************************************************
;                ChecaColisao
;********************************************************
ChecaColisao:
	push r0
	 
	;;compara posicao inferior do personagem com a do obstaculo, se igual finaliza o jogo
	cmp r2, r6 
	jeq GameOver
	
	loadn r0,#40
	sub r6,r6,r0
	
	;;compara posicao superior do personagem com a do obstaculo, se igual finaliza o jogo
	cmp r2, r6
	jeq GameOver
	
	add r6,r6,r0
	
	pop r0
	rts
	
;********************************************************
;                     ChecaPulo
;********************************************************	

; Funcao que checa se o jogador pressionou 'space' e, se sim, inicia o pulo

ChecaPulo:

	push r3
	load r3, Letra 			; Caso ' space' tenha sido pressionado	
	cmp r7, r3
		ceq IncrementaPulo		; Inicia a funcao do pulo
	pop r3 		
	rts

;********************************************************
;                 IncrementaPulo
;********************************************************

IncrementaPulo:

	inc r5
	rts
	
;********************************************************
;                       ResetaPulo
;********************************************************

ResetaPulo:

	loadn r5, #0
	rts
	
;********************************************************
;                       SOBE
;********************************************************

; Funcao que sobe o personagem para a linha de cima (-40 em sua posicao)

Sobe:

	push r1
	push r2
	
	call ApagaPersonagem
	
	loadn r1, #40
	sub r6, r6, r1
	
	pop r2
	pop r1
	rts 
	
;********************************************************
;                       DESCE
;********************************************************

; Funcao que desce o personagem para a linha de cima (+40 em sua posicao)
	
Desce:

	push r1
	push r2
	
	call ApagaPersonagem
	
	loadn r1, #40
	add r6, r6, r1
	
	pop r2
	pop r1
	rts


;********************************************************
;                    DelayChecaPulo
;********************************************************
 
; Funcao que da o delay do jogo e tambem le uma tecla do teclado

DelayChecaPulo:
	push r0
	push r1
	push r2
	push r3
	
	load r0, delay1
	loadn r3, #255
	store Letra, r3		; Guarda 255 na Letra pro caso de nao apertar nenhuma tecla
	
	loop_delay_1:
		load r1, delay2

			; le o teclado	
			loop_delay_2:
				inchar r2
				cmp r2, r3 
				jeq loop_skip
				store Letra, r2		; Se apertar uma tecla, guarda na variavel Letra
			
	loop_skip:			
		dec r1
		jnz loop_delay_2
		dec r0
		jnz loop_delay_1
		jmp sai_dalay
	
	sai_dalay:
		pop r3
		pop r2
		pop r1
		pop r0
	rts

;********************************************************
;                       IncrementaPontos
;********************************************************

IncPontos:

	push r1
	push r2
	
	load r2, pontos
	
	inc r2
	
	load r1, delay1
	dec r1

	store delay1, r1
	
	load r1, delay2
	dec r1
	dec r1

	store delay2, r1
	
	store pontos, r2
	
	pop r2
	pop r1
	rts

;********************************************************
;                AtualizaPontos
;********************************************************

AtPontos:

	push r1
	push r5
	push r6
	
	loadn r1, #492	; Caso o cacto tenha passado pela posicao do jogador, incrementa a pontuacao
	cmp r2, r1
		ceq IncPontos
	
	loadn r1, #450		; Caso o cacto tenha passado pela posicao do jogador, para o caso do cacto estar em outra linha
	cmp r2, r1
		ceq IncPontos
		
	loadn r1, #410		; Caso o cacto tenha passado pela posicao do jogador, para o caso do cacto estar em outra linha
	cmp r2, r1
		ceq IncPontos
		
	load r5, pontos
	
	loadn r6, #11
	
	call PrintaNumero	; Imprime a pontuacao na tela
	
	pop r6
	pop r5
	pop r1
	rts	
	
;********************************************************
;                    PrintaNumero
;********************************************************

; Imprime um numero de 2 digitos na tela

PrintaNumero:	; R5 contem um numero de ate' 2 digitos e R6 a posicao onde vai imprimir na tela

	push r0
	push r1
	push r2
	push r3
	
	loadn r0, #10
	loadn r2, #48
	
	div r1, r5, r0	; Divide o numero por 10 para imprimir a dezena
	
	add r3, r1, r2	; Soma 48 ao numero pra dar o Cod.  ASCII do numero
	outchar r3, r6
	
	inc r6			; Incrementa a posicao na tela
	
	mul r1, r1, r0	; Multiplica a dezena por 10
	sub r1, r5, r1	; Pra subtrair do numero e pegar o resto
	
	add r1, r1, r2	; Soma 48 ao numero pra dar o Cod.  ASCII do numero
	outchar r1, r6
	
	pop r3
	pop r2
	pop r1
	pop r0

	rts	

halt

;---------------------------------------------------------------
; 					Tabela de num aleatorios:
;---------------------------------------------------------------
			
Rand : var #30			; Tabela de num. randomicos entre 1-3 (usado para sortear posicoes do cacto)	
	static Rand + #0, #3
	static Rand + #1, #2
	static Rand + #2, #2
	static Rand + #3, #3
	static Rand + #4, #3
	static Rand + #5, #2
	static Rand + #6, #1
	static Rand + #7, #2
	static Rand + #8, #1
	static Rand + #9, #3
	static Rand + #10, #2
	static Rand + #11, #1
	static Rand + #12, #3
	static Rand + #13, #3
	static Rand + #14, #2
	static Rand + #15, #1
	static Rand + #16, #2
	static Rand + #17, #3
	static Rand + #18, #1
	static Rand + #19, #2
	static Rand + #20, #1
	static Rand + #20, #2
	static Rand + #21, #3
	static Rand + #22, #2
	static Rand + #23, #2
	static Rand + #24, #1
	static Rand + #25, #1
	static Rand + #26, #3
	static Rand + #27, #2
	static Rand + #28, #3
	static Rand + #29, #2

	
IncRand: var #1

;---------------------------------------------------------------
; Tela de inicio:
;---------------------------------------------------------------

tela0Linha0  : string "                                        "
tela0Linha1  : string "                                        "
tela0Linha2  : string "                                        "
tela0Linha3  : string "                                        "
tela0Linha4  : string "                                        "
tela0Linha5  : string "    ######  ####### #     # ######      "
tela0Linha6  : string "    #     #    #    # #   # #    #      "
tela0Linha7  : string "    #     #    #    #  #  # #    #      "
tela0Linha8  : string "    #     #    #    #   # # #    #      "
tela0Linha9  : string "    ######  ####### #     # ######      "                   
tela0Linha10 : string "                                        "               
tela0Linha11 : string "                                        "               
tela0Linha12 : string "                                        "            
tela0Linha13 : string "                                        "                   
tela0Linha14 : string "                                        "                  
tela0Linha15 : string "                                        "
tela0Linha16 : string "                                        "
tela0Linha17 : string "                                        "
tela0Linha18 : string "                                        "
tela0Linha19 : string "                                        "
tela0Linha20 : string "           ______                       "
tela0Linha21 : string "          |    o |                      "
tela0Linha22 : string "          |      |                      "
tela0Linha23 : string " |       _|   vvv                       "
tela0Linha24 : string "  |    _|    _|                         "
tela0Linha25 : string "   | _|     _| l                        "
tela0Linha26 : string "    |______|  l                         "
tela0Linha27 : string "     L   L                              "
tela0Linha28 : string "                                        "
tela0Linha29 : string "                                        "


tela2Linha0  : string "                                        "
tela2Linha1  : string "                                        "
tela2Linha2  : string "                                        "
tela2Linha3  : string "                                        "
tela2Linha4  : string "                                        "
tela2Linha5  : string "                                        "
tela2Linha6  : string "                                        "
tela2Linha7  : string "                                        "
tela2Linha8  : string "                                        "
tela2Linha9  : string "                                        "
tela2Linha10 : string "                                        "                   
tela2Linha11 : string "     @@@@@  @@@@@@ @@    @@ @@@@@@      "               
tela2Linha12 : string "    @       @    @ @ @  @ @ @           "               
tela2Linha13 : string "    @   @@@ @@@@@@ @  @@  @ @@@@@@      "            
tela2Linha14 : string "    @     @ @    @ @      @ @           "                   
tela2Linha15 : string "    @@@@@@  @    @ @      @ @@@@@@      "                  
tela2Linha16 : string "                                        "
tela2Linha17 : string "                                        "
tela2Linha18 : string "                                        "
tela2Linha19 : string "                                        "
tela2Linha20 : string "                                        "
tela2Linha21 : string "                                        "
tela2Linha22 : string "                               #        "
tela2Linha23 : string "                            #  #  #     "
tela2Linha24 : string "                            #  #  #     "
tela2Linha25 : string "                             # # #      "
tela2Linha26 : string "                              ###       "
tela2Linha27 : string "                              ###       "
tela2Linha28 : string "                              ###       "
tela2Linha29 : string "                                        "


tela3Linha0  : string "                                        "
tela3Linha1  : string "                                        "
tela3Linha2  : string "                                        "
tela3Linha3  : string "                                        "
tela3Linha4  : string "                                        "
tela3Linha5  : string "                                        "
tela3Linha6  : string "                                        "
tela3Linha7  : string "                                        "
tela3Linha8  : string "                                        "
tela3Linha9  : string "                                        "
tela3Linha10 : string "                                        "
tela3Linha11 : string "                                        "
tela3Linha12 : string "                                        "
tela3Linha13 : string "                                        "
tela3Linha14 : string "                                        "
tela3Linha15 : string "                                        "
tela3Linha16 : string "                                        "
tela3Linha17 : string "                                        "
tela3Linha18 : string "                                        "
tela3Linha19 : string "       pressione espaco para jogar      "
tela3Linha20 : string "                                        "
tela3Linha21 : string "                                        "
tela3Linha22 : string "                                        "
tela3Linha23 : string "                                        "
tela3Linha24 : string "                                        "
tela3Linha25 : string "                                        "
tela3Linha26 : string "                                        "
tela3Linha27 : string "                                        "
tela3Linha28 : string "                                        "
tela3Linha29 : string "                                        "

;---------------------------------------------------------------
; Tela padrao do jogo
;---------------------------------------------------------------

tela1Linha0  : string "                                                  "
tela1Linha1  : string "                                   +      +       "
tela1Linha2  : string "   +     +       +           *           +        "
tela1Linha3  : string "          +         +        *             +      "
tela1Linha4  : string "      +        +           * * *        +         "
tela1Linha5  : string "                        * *  O  * *           +   "
tela1Linha6  : string "                           * * *                  "
tela1Linha7  : string "                             *                    "
tela1Linha8  : string "                             *                    "
tela1Linha9  : string "                                                  "
tela1Linha10 : string "                                                  "
tela1Linha11 : string "                                                  "
tela1Linha12 : string "                                                  "
tela1Linha13 : string "------^^^------^^^^^--------^^^------^^^--------^^"
tela1Linha14 : string "                                                  "
tela1Linha15 : string "                                                  "
tela1Linha16 : string "                                                  "
tela1Linha17 : string "                                                  "
tela1Linha18 : string "                                                  "
tela1Linha19 : string "                                                  "
tela1Linha20 : string "                                                  "
tela1Linha21 : string "                                                  "
tela1Linha22 : string "                                                  "
tela1Linha23 : string "                                                  "
tela1Linha24 : string "                                                  "
tela1Linha25 : string "                                                  "
tela1Linha26 : string "                                                  "
tela1Linha27 : string "                                                  "
tela1Linha28 : string "                                                  "
tela1Linha29 : string "                                                  "

;---------------------------------------------------------------
; Tela de fim de jogo
;---------------------------------------------------------------


tela4Linha0  : string "                                        "
tela4Linha1  : string "                                        "
tela4Linha2  : string "                                        "
tela4Linha3  : string "                                        "
tela4Linha4  : string "                                        "
tela4Linha5  : string "                                        "
tela4Linha6  : string "                                        "
tela4Linha7  : string "                                        "
tela4Linha8  : string "                                        "
tela4Linha9  : string "                                        "
tela4Linha10 : string "                                        "
tela4Linha11 : string "                                        "
tela4Linha12 : string "                                        "
tela4Linha13 : string "                                        "
tela4Linha14 : string "                                        "
tela4Linha15 : string "                                        "
tela4Linha16 : string "                                        "
tela4Linha17 : string "                                        "
tela4Linha18 : string "                                        "
tela4Linha19 : string "                                        "
tela4Linha20 : string "             voce foi extinto           "
tela4Linha21 : string "                                        "
tela4Linha22 : string "                                        "
tela4Linha23 : string " Digite 's' para novo jogo 'n' para sair"
tela4Linha24 : string "                                        "
tela4Linha25 : string "                                        "
tela4Linha26 : string " 		PONTOS                 "
tela4Linha27 : string "                                        "
tela4Linha28 : string "                                        "
tela4Linha29 : string "                                        "

tela5Linha0  : string "                                        "
tela5Linha1  : string "                                        "
tela5Linha2  : string "                                        "
tela5Linha3  : string "                                        "
tela5Linha4  : string "                                        "
tela5Linha5  : string "   ####### ####### ##    ## #######     "
tela5Linha6  : string "   #       #     # # #  # # #           "
tela5Linha7  : string "   #   ### ####### #  ##  # #####       "
tela5Linha8  : string "   #     # #     # #      # #           "
tela5Linha9  : string "   ####### #     # #      # #######     "
tela5Linha10 : string "                                        "
tela5Linha11 : string "   ####### #       # ####### ######     "
tela5Linha12 : string "   #     #  #     #  #       #    #     "
tela5Linha13 : string "   #     #   #   #   #####   #  ###     "
tela5Linha14 : string "   #     #    # #    #       #    #     "
tela5Linha15 : string "   #######     #     ####### #    #     "
tela5Linha16 : string "                                        "
tela5Linha17 : string "                                        "
tela5Linha18 : string "                                        "
tela5Linha19 : string "                                        "
tela5Linha20 : string "                                        "
tela5Linha21 : string "                                        "
tela5Linha22 : string "                                        "
tela5Linha23 : string "                                        "
tela5Linha24 : string "                                        "
tela5Linha25 : string "                                        "
tela5Linha26 : string "                                        "
tela5Linha27 : string "                                        "
tela5Linha28 : string "                                        "
tela5Linha29 : string "                                        "


tela6Linha0  : string "                                        "
tela6Linha1  : string "                                        "
tela6Linha2  : string "                                        "
tela6Linha3  : string "                                        "
tela6Linha4  : string "                                        "
tela6Linha5  : string "                                        "
tela6Linha6  : string "                                        "
tela6Linha7  : string "                                        "
tela6Linha8  : string "                                        "
tela6Linha9  : string "                                        "
tela6Linha10 : string "                                        "
tela6Linha11 : string "                                        "
tela6Linha12 : string "                                        "
tela6Linha13 : string "                                        "
tela6Linha14 : string "                                        "
tela6Linha15 : string "                                        "
tela6Linha16 : string "                                        "
tela6Linha17 : string "    T__T                                "
tela6Linha18 : string "   |   |___                             "
tela6Linha19 : string "    |_    x|                            "
tela6Linha20 : string "      |____|                            "
tela6Linha21 : string "                                        "
tela6Linha22 : string "                                        "
tela6Linha23 : string "                                        "
tela6Linha24 : string "                                        "
tela6Linha25 : string "                                        "
tela6Linha26 : string "                                        "
tela6Linha27 : string "                                        "
tela6Linha28 : string "                                        "
tela6Linha29 : string "                                        "
