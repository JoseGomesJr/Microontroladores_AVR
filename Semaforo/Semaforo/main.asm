.def unidade = r19  ;definimos o registrador 19 como unidade (variável que vai armazenar o valor numérico a ser exibido no display de unidade)
.def dezena = r20	;definimos o registrador 20 como dezena (variável que vai armazenar o valor numérico a ser exibido no display de dezena)
.def temp = r16
.def saida = r21
.def loopCt = r17
.def tempo_estado = r23
.def timerTmp = r25

.cseg 				;flash
jmp reset
.org OC1Aaddr
jmp OCI1A_Interrupt


OCI1A_Interrupt:
	push r25
	in r25, SREG
	push r25

	;tarefa da interrupção 
	dec tempo_estado
	; A cada interrupção aumentamos o valor a ser exibido no display de unidade em 1
	inc unidade

	pop r25
	out SREG, r25
	pop r25
	;Caso o valor da unidade seja 10 teremos um desvio para a label overflow
	cpi unidade, 0b00101010
	breq overflow

	reti  ;retornamos para a rotina principal
	overflow:
		;dentro do tratamento de overflow, faremos a unidade voltar a 0 e incrementamos o valor da dezena em 1
		ldi unidade, 0b00100000
		inc dezena	
		reti ;retornamos para a rotina principal


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
	ldi timerTmp, low(RAMEND)
	out SPL, timerTmp
	ldi timerTmp, high(RAMEND)
	out SPH, timerTmp


	;Velociade do clock
	#define CLOCK 16.0e6 
	;Tempo em segundos
	#define DELAY 1 
	;Valor do prescale (256) 
	.equ PRESCALE = 0b100 
	.equ PRESCALE_DIV = 256
	.equ WGM = 0b0100 ;Waveform generation mode: CTC
	;Condição para analisar se o top não ultrapassa o valor máxido de 65535
	.equ TOP = int(0.5 + ((CLOCK/PRESCALE_DIV)*DELAY))
	.if TOP > 65535
	.error "TOP is out of range"
	.endif

	ldi timerTmp, high(TOP) ;initialize compare value (TOP)
	sts OCR1AH, timerTmp
	ldi timerTmp, low(TOP)
	sts OCR1AL, timerTmp
	ldi timerTmp, ((WGM&0b11) << WGM10)
	sts TCCR1A, timerTmp
	ldi timerTmp, ((WGM>> 2) << WGM12)|(PRESCALE << CS10)
	sts TCCR1B, timerTmp ;start counter

	lds timerTmp, TIMSK1
	sbr timerTmp, 1 <<OCIE1A
	sts TIMSK1, timerTmp
	;------FIM SETUP TIMER------

	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0
	;Definimos toda a PORTD como saída
	ldi temp, 0b11111111
	out DDRD, temp

	;Definimos os 6 primeiros pinos de PORTB como saída
	ldi temp, 0b00111111
	out DDRB, temp	
	
	;habilita as interrupçoes globais
	sei
	

s1:
	ldi tempo_estado, 22
	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0


loop_s1:
	ldi	saida, estado_s1
	out PORTD, saida

	;Enviamos os vetores de controle para os 2 displays com delay de 0.001 segundos 
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay
	cpi tempo_estado, 0
	breq s2
	rjmp loop_s1
s2:
	ldi tempo_estado, 4
	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0
loop_s2:
	ldi	saida, estado_s2
	out PORTD, saida
	
	;Enviamos os vetores de controle para os 2 displays com delay de 0.001 segundos 
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq s3
	rjmp loop_s2
s3:
	ldi tempo_estado, 51
	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0

loop_s3:
	ldi	saida, estado_s3
	out PORTD, saida
	
	;Enviamos os vetores de controle para os 2 displays com delay de 0.001 segundos 
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq s4
	rjmp loop_s3
s4:
	ldi tempo_estado, 4
	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0

loop_s4:
	ldi	saida, estado_s4
	out PORTD, saida
	
	;Enviamos os vetores de controle para os 2 displays com delay de 0.001 segundos 
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq s5
	rjmp loop_s4
s5:
	ldi tempo_estado, 25
	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0

loop_s5:
	ldi	saida, estado_s5
	out PORTD, saida
	
	;Enviamos os vetores de controle para os 2 displays com delay de 0.001 segundos 
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq s6
	rjmp loop_s5
s6:
	ldi tempo_estado, 4
	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0
loop_s6:
	ldi	saida, estado_s6
	out PORTD, saida
	
	;Enviamos os vetores de controle para os 2 displays com delay de 0.001 segundos 
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq s7
	rjmp loop_s6
s7:
	ldi tempo_estado, 31
	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0
loop_s7:
	ldi	saida, estado_s7
	out PORTD, saida

	;Enviamos os vetores de controle para os 2 displays com delay de 0.001 segundos 
	out PORTB, unidade
	rcall Delay
	out PORTB, dezena
	rcall Delay

	cpi tempo_estado, 0
	breq reincia
	rjmp loop_s7
reincia:
	rjmp s1
