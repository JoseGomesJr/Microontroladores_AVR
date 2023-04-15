.def unidade = r19  ;definimos o registrador 19 como unidade (variável que vai armazenar o valor numérico a ser exibido no display de unidade)
.def dezena = r20	;definimos o registrador 20 como dezena (variável que vai armazenar o valor numérico a ser exibido no display de dezena)
.def temp = r16
.def saida = r21
.def loopCt=r17
.def tempo_estado = r23

.cseg 				;flash
jmp reset	

.equ estado_s1 = 0b00001111
.equ estado_s2 = 0b00001110
.equ estado_s3 = 0b11001100
.equ estado_s4 = 0b01000100
.equ estado_s5 = 0b00110000
.equ estado_s6 = 0b00010000
.equ estado_s7 = 0b00000000


.equ ClockMHz = 16
.equ DelayMs = 3000
Delay:
	ldi r23, byte3(ClockMHz * 1000 * DelayMs / 5)
	ldi r22, high(ClockMHz * 1000 * DelayMs / 5)
	ldi r21, low(ClockMHz * 1000 * DelayMs / 5)

	subi r21, 1
	sbci r22, 0
	sbci r23, 0

	brcc pc-3
			
	ret

reset:

	ldi unidade, 0b00100000; iniciamos o valor da unidade do contador em 0
	ldi dezena,  0b00010000 ; iniciamos o valor da dezena do contador em 0
	;Definimos toda a PORTD como saída
	ldi temp, 0b11111111
	out DDRD, temp

	;Definimos os 6 primeiros pinos de PORTB como saída
	ldi temp, 0b00111111
	out DDRB, temp	

	ldi	saida, 0b00100001
	out PORTB, saida

	s1:
		ldi tempo_estado, 22
	loop_s1:
		ldi	saida, estado_s1
		out PORTD, saida

		rcall Delay
		rjmp s2
	s2:
		ldi tempo_estado, 4
	loop_s2:
		ldi	saida, estado_s2
		out PORTD, saida
		
		rcall Delay
		rjmp s3
	s3:
		ldi tempo_estado, 51

	loop_s3:
		ldi	saida, estado_s3
		out PORTD, saida
		
		rcall Delay
		rjmp s4
	s4:
		ldi tempo_estado, 4

	loop_s4:
		ldi	saida, estado_s4
		out PORTD, saida
		
		rcall Delay
		rjmp s5
	s5:
		ldi tempo_estado, 25

	loop_s5:
		ldi	saida, estado_s5
		out PORTD, saida
		
		rcall Delay
		rjmp s6
	s6:
		ldi tempo_estado, 4
	loop_s6:
		ldi	saida, estado_s6
		out PORTD, saida
		
		rcall Delay
		rjmp s7

	s7:
		ldi tempo_estado, 31
	loop_s7:
		ldi	saida, estado_s7
		out PORTD, saida
		
		rcall Delay
		rjmp s1