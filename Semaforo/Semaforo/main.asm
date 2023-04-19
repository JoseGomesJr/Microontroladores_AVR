.def unidade = r19  ;definimos o registrador 19 como unidade (variável que vai armazenar o valor numérico a ser exibido no display de unidade)
.def dezena = r20	;definimos o registrador 20 como dezena (variável que vai armazenar o valor numérico a ser exibido no display de dezena)
.def temp = r16 ;registrador temporário
.def saida = r21 ;saída para os leds
.def tempo_estado = r23 ;armazena o tempo de duração de cada estado

.cseg ;flash

;Definição do vetor de interrupção
;Minuto 6:01 do vídeo
jmp reset
.org OC1Aaddr
jmp OCI1A_Interrupt

;Todo match é um overflow, e a partir disso a interrupção é gerada
;tarefa da interrupção (ISR) - Funciona salvando o SREG, restaurando o SREG e retorna para a rotina principal com RETI
OCI1A_Interrupt:
	push temp
	in temp, SREG
	push temp

	;Decremento no tempo do estado atual a cada interrupção de 1s
	dec tempo_estado
	; A cada interrupção aumentamos o valor a ser exibido no display de unidade em 1
	inc unidade

	pop temp
	out SREG, temp
	pop temp
	;Caso o valor da unidade seja 10 teremos um desvio para a label overflow
	cpi unidade, 0b00101010
	breq overflow

	reti  ;retornamos para a rotina principal
	overflow:
		;dentro do tratamento de overflow, faremos a unidade voltar a 0 e incrementamos o valor da dezena em 1
		ldi unidade, 0b00100000
		inc dezena	
		reti ;retornamos para a rotina principal

;Sequência de bits dos leds de cada estado
; O estado dos leds é representado com 2 bits
; O estado pode ser vemelho: 00, amarelo: 10 para o semaforo A, e 01 para os outros, e verde: 11;
; a sequencia de bits de cada semaforo é a sequinte: 
;	D	 C	  B    A
;  00 | 00 | 00 | 00 |
.equ estado_s1 = 0b00001111
.equ estado_s2 = 0b00001110
.equ estado_s3 = 0b11001100
.equ estado_s4 = 0b01000100
.equ estado_s5 = 0b00110000
.equ estado_s6 = 0b00010000
.equ estado_s7 = 0b00000000

.equ ClockMHz = 16
.equ DelayMs = 1

Delay:
	ldi r28, byte3(ClockMHz * 1000 * DelayMs / 5)
	ldi r27, high(ClockMHz * 1000 * DelayMs / 5)
	ldi r26, low(ClockMHz * 1000 * DelayMs / 5)

	subi r26, 1
	sbci r27, 0
	sbci r28, 0

	brcc pc-3
			
	ret

reset:
	;------SETUP TIMER------
	;Stack initialization
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	;Velociade do clock
	#define CLOCK 16.0e6 
	;Tempo em segundos
	#define DELAY 1 
	;Valor do prescale (256) 
	.equ PRESCALE = 0b100 
	.equ PRESCALE_DIV = 256
	;Gerador de forma de onda CTC (Clear time and compare, modo 4)
	.equ WGM = 0b0100 ;
	;Condição para analisar se o top não ultrapassa o valor máxido de 65535
	.equ TOP = int(0.5 + ((CLOCK/PRESCALE_DIV)*DELAY))
	.if TOP > 65535
	.error "TOP is out of range"
	.endif

	;Configuração do TOP - Carrega o valor do TOP em OCR1A 16 bit

	;Alocando os bits mais significativos 
	ldi temp, high(TOP)  
	sts OCR1AH, temp

	;Alocando os bits menos significativos 
	ldi temp, low(TOP)
	sts OCR1AL, temp

	;O WGM é responsável pelo modo de operação do timer (Modo 0, modo 4, etc)
	;Configuração do WGM - Coloca o valor de WGM no TCCR1A e TCCR1B
	ldi temp, ((WGM&0b11) << WGM10) ;Carrega os 2 bits menos significativos
	sts TCCR1A, temp
	ldi temp, ((WGM>> 2) << WGM12)|(PRESCALE << CS10) ;Carrega os 2 bits mais significativos
	;Inicia o counter
	sts TCCR1B, temp

	;Habilita interrupções do comparador no canal A (Interrupção específica)
	;Minuto 4:07 do vídeo
	lds temp, TIMSK1
	;SBR Faz a troca do bit, sem alterar os outros bits
	sbr temp, 1 <<OCIE1A
	sts TIMSK1, temp
	;------FIM SETUP TIMER------

	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0

	;Definimos toda a PORTD como saída - Leds
	ldi temp, 0b11111111
	out DDRD, temp

	;Definimos os 6 primeiros pinos de PORTB como saída - Display
	ldi temp, 0b00111111
	out DDRB, temp	
	
	;habilita as interrupçoes globais
	sei
	
s1:
	ldi tempo_estado, 22 ;Define quanto tempo esse estado dura
	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0

loop_s1:
	ldi	saida, estado_s1 ;Define a sequência dos leds na saída
	out PORTD, saida

	;Enviamos os vetores de controle para os 2 displays com delay de 0.001 segundos 
	out PORTB, unidade ;Número da unidade
	rcall Delay ;Espera 0.001 segundo
	out PORTB, dezena ;Número da dezena
	rcall Delay ;Espera 0.001 segundo
	cpi tempo_estado, 0 ;Compara se a duração do estado terminou
	breq s2 ;Se sim, muda para o próximo estado
	rjmp loop_s1 ;Senão, volta para o início do loop

s2:
	ldi tempo_estado, 4
	ldi unidade, 0b00100000
	ldi dezena,  0b00010000

loop_s2:
	ldi	saida, estado_s2
	out PORTD, saida 
	
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq s3
	rjmp loop_s2

s3:
	ldi tempo_estado, 51
	ldi unidade, 0b00100000
	ldi dezena,  0b00010000

loop_s3:
	ldi	saida, estado_s3
	out PORTD, saida
		
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq s4
	rjmp loop_s3

s4:
	ldi tempo_estado, 4
	ldi unidade, 0b00100000
	ldi dezena,  0b00010000

loop_s4:
	ldi	saida, estado_s4
	out PORTD, saida
		
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq s5
	rjmp loop_s4

s5:
	ldi tempo_estado, 25
	ldi unidade, 0b00100000
	ldi dezena,  0b00010000

loop_s5:
	ldi	saida, estado_s5
	out PORTD, saida
		
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq s6
	rjmp loop_s5

s6:
	ldi tempo_estado, 4
	ldi unidade, 0b00100000
	ldi dezena,  0b00010000
loop_s6:
	ldi	saida, estado_s6
	out PORTD, saida
		
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq s7
	rjmp loop_s6

s7:
	ldi tempo_estado, 31
	ldi unidade, 0b00100000
	ldi dezena,  0b00010000

loop_s7:
	ldi	saida, estado_s7
	out PORTD, saida

	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq reincia
	rjmp loop_s7

reincia:
	rjmp s1 ;Volta para o estado 1