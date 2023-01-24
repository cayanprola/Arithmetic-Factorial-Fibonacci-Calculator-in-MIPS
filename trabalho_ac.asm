.data
	main_menu_str: .asciiz "1. Operações aritméticas.\n2. Factorial de um número.\n3. Série de Fibonacci.\n4. Listagens.\n5. Terminar.\nEscolha >> "
	aritmeticas_menu_str: .asciiz "\n\n1. Adiçâo.\n2. Subtração.\n3. Multiplicação.\n4. Divisão.\n5. Retornar.\nEscolha >> "
	_cls: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n"
	divider_str: .asciiz "\n"
	
	ask_q_numbers: .asciiz "\nQuantos numeros deseja inserir? "
	ask_number: .asciiz "Insira um numero: "
	resultado_soma_str: .asciiz "\nResultado da soma é de: "
	resultado_sub_str: .asciiz "\nResultado da subtração � de: "
	resultado_mul_str: .asciiz "\nResultado da multiplicação é de: "
	resultado_div_str: .asciiz "\nResultado da divisão é de: "
	resultado_str: .asciiz "\nResultado do fatorial do numero é de: "
	ask_fibonacci: .asciiz "\nQuantos termos de fibonacci? "
	
	resultado: .word 0
	
	listagens_index: .word 0
	
	# Ajudas para a listagem 
	soma_str: .asciiz " + "
	subtracao_str: .asciiz " - "
	divisao_str: .asciiz " / "
	multiplicacao_str: .asciiz " * "
	igual_str: .asciiz " = "
.data 0x10000100
	fibonacci_arr: .word 0, 1
.data 0x10001000
	listagens_arr: .word
	# Estrutura - listagens array:
	# Index 0 = Quantidade de numeros inseridos pelo utilizador (n)
	# Index 1 até n = Todos os numeros inseridos pelo utilizador
	# Index n+1 = Operação efetuada
	# Index n+2 = Resultado obtido
.text

# menu()
menu:
	jal reset_arguments_values

	jal divider
	jal divider

	# Main Menu
	la $a0, main_menu_str
	jal print_and_input
	
	move $t0, $v0 # t0 = v0, getting value from input
	bgt $t0, 5, menu # if t0 > 5 - menu
	blt $t0, 1, menu # if t0 < 1 - menu
	
	beq $t0, 1, operacoes_aritmeticas 	# if t0 == 1 - operacoes_aritmeticas
	beq $t0, 2, fatorial 				# if t0 == 2 - fatorial
	beq $t0, 3, fibonacci 				# if t0 == 3 - fibonacci
	beq $t0, 4, listagens 				# if t0 == 4 - listagens
	beq $t0, 5, exit 					# if t0 == 5 - exit

fatorial:
	# fatorial()
	# Pede e valida o numero para ser calculado o seu fatorial
	
	la $a0, ask_number
	jal print_and_input

	# Verifica se o parametro é valido
	ble $v0, 0, fatorial # t0 >= 0

	# Carrega o parametro e chama a função que calcula o fatorial
	move $a0, $v0
	jal calcular_fatorial
	
calcular_fatorial:
	# calcular_fatorial($a0)
	# Calcula o fatorial do numero
	#
	# Arguments:
	# $a0 - int -- Numero
	# $a1 - int -- n + x, default: 1
	#
	# Returns:
	# $v0 - int -- Resultado do fatorial
	
	sub $t0, $a0, $a1 # 3-1
	addi $a1, $a1, 1
	beq $t0, 0, print_fatorial
	move $t1, $v0
	move $v0, $a0
	
	# Para evitar acontecer 0 * t0
	beq $a1, 1, calcular_fatorial
	mul $v0, $t1, $t0
	jal calcular_fatorial

	
print_fatorial:
	# print_fatorial($a0)
	# Imprime o resultado que vem da função calcular_fatorial
	#
	# Arguments:
	# $v0 - int -- Resultado que vem do fatorial

	move $t0, $v0

	la $a0, resultado_str
	jal imprimir

	move $a0, $t0
	jal imprimir_int

	j menu

fibonacci:
	# fibonacci()
	# Pede a quantidade de termos para serem calculados e inicia os argumentos

	lui $s0, 0x1000
	addi $s0, $s0, 0x0100
	
	la $a0, ask_fibonacci
	jal print_and_input
	
	# Verifica se o parametro é válido
	blt $v0, 0, fibonacci 	# $v0 < 0
	
	move $a0 , $v0
	sub $a0, $a0, 1

	lw $a1, 0($s0)
	lw $a2, 4($s0)
	
	addi $s1, $s0, 8
	addi $a3, $zero, 0
	
	jal fibonacci_loop

fibonacci_loop:
	# fibonacci_loop($a0, $a1, $a2, $a3)
	# Calcula todas os termos de fibonacci até $a0
	#
	# Arguments:
	# $a0 - int -- Limite de termos da serie
	# $a1 - int -- Termo n-1
	# $a2 - int -- Termo n-2
	# $a3 - int -- Numero de interação atual
	#
	# Returns:
	# $v0 - int -- Resultado de cada termo (recursivo)	

	slt $t4, $a3, $a0 # if a3 < a0
	beq $t4, $zero, fibonacci_fim # if t4 == 0, print fibonacci
	add $v0, $a1, $a2   #Un = Un-2 + Un-1 
	sw $v0, 0($s1)
	addi $s1, $s1, 4
	add $a1, $zero, $a2 # salvar Un-1
	add $a2, $zero, $v0 # salvar Un-2
	addi $a3, $a3, 1
	j fibonacci_loop

fibonacci_fim:
	# fibonacci_fim()
	# Limpar os valores atuais dos argumentos para imprimir todos os termos calculados

	jal reset_arguments_values
	
	j print_fibonacci

print_fibonacci:
	# print_fibonacci($a0)
	# Imprime todos os elementos calculados do fibonacci, recursiva
	#
	# Arguments:
	# $a1 - int -- Index

	addi $a1, $a1, 4

	add $s1, $s0, $a1
	lw $a0, 0($s1)
	beq $a0, 0, menu
	jal imprimir_int
	jal divider
	
	jal print_fibonacci
	

operacoes_aritmeticas:
	# operacoes_aritmeticas($a0)
	# Pergunta ao utilizador que operação deseja fazer
	
	la $a0, aritmeticas_menu_str
	jal print_and_input

	move $t0, $v0 # t0 = v0, getting value from input
	bgt $t0, 5, operacoes_aritmeticas # if t0 > 5 - menu
	blt $t0, 1, operacoes_aritmeticas # if t0 < 1 - menu

	beq $t0, 5, menu # if t0 == 5 exit
	
	# Asking for quantity of numbers
	la $a0, ask_q_numbers
	jal print_and_input
	
	move $a0, $v0
	jal add_to_listagem

	# Resetando valores de argumentos e valores para não haver conflitos.
	jal reset_arguments_values

	move $a1, $v0
	addi $v1, $0, 0

	beq $t0, 1, somar 		# if t0 == 1 - somar
	beq $t0, 2, subtracao 		# if t0 == 2 - subtracao
	beq $t0, 3, multiplicacao 	# if t0 == 3 - multiplicacao
	beq $t0, 4, divisao 		# if t0 == 3 - divisao


somar: 
	# somar($a1, $a2)
	# Soma todos os numeros inseridos
	#
	# Arguments:
	# $a1 - int -- Quantidade de numeros
	# $a2 - int -- N de numeros atuais
	#
	# Returns:
	# $v1 - int -- Resultado (Recursivo)
	
	addi $a2, $a2, 1

	la $a0, ask_number
	jal print_and_input

	add $v1, $v1, $v0

	# Adicionando numero à array de listagem
	move $a0, $v0
	jal add_to_listagem
	
	# if a2 < a1
	blt $a2, $a1, somar

	# Quando acabar de somar tudo
	
	# Adicionando a operação à array de listagem
	add $a0, $0, 1
	jal add_to_listagem

	la $a0, resultado_soma_str
	jal imprimir
	
	sw $v1, resultado
	lw $a0, resultado
	jal imprimir_int
	
	# Adiciona o resultado à array de listagem
	jal add_to_listagem
	
	j operacoes_aritmeticas

subtracao:
	# subtracao($a1, $a2)
	# Subtrai todos os numeros inseridos
	#
	# Arguments:
	# $a1 - int -- Quantidade de numeros
	# $a2 - int -- N de numeros atuais
	#
	# Returns:
	# $v1 - int -- Resultado (Recursivo)

	addi $a2, $a2, 1
	move $t0, $v1

	la $a0, ask_number
	jal print_and_input
	
	move $v1, $v0
	
	# Adicionando numero à array de listagem
	move $a0, $v0
	jal add_to_listagem

	# Para evitar acontecer 0 - v0
	beq $a2, 1, subtracao

	sub $v1, $t0, $v0
	
	# if a2 < a1
	blt $a2, $a1, subtracao

	# Quando acabar de subtrair tudo
	
	# Adicionando a operação à array de listagem
	add $a0, $0, 2
	jal add_to_listagem

	la $a0, resultado_sub_str
	jal imprimir
	
	sw $v1, resultado
	lw $a0, resultado
	jal imprimir_int
		
	# Adiciona o resultado à array de listagem
	jal add_to_listagem

	j operacoes_aritmeticas

multiplicacao:
	# multiplicacao($a1, $a2)
	# Multiplica todos os numeros inseridos
	#
	# Arguments:
	# $a1 - int -- Quantidade de numeros
	# $a2 - int -- N de numeros atuais
	#
	# Returns:
	# $v1 - int -- Resultado (Recursivo)

	addi $a2, $a2, 1
	move $t0, $v1

	la $a0, ask_number
	jal print_and_input
	
	move $v1, $v0
	
	# Adicionando numero à array de listagem
	move $a0, $v0
	jal add_to_listagem
	
	# Para evitar acontecer 0 * v0
	beq $a2, 1, multiplicacao

	mul $v1, $t0, $v0
	
	# if a2 < a1
	blt $a2, $a1, multiplicacao

	# Quando acabar de multiplicar tudo

	# Adicionando a operaçâo à array de listagem
	add $a0, $0, 3
	jal add_to_listagem
	
	la $a0, resultado_mul_str
	jal imprimir
	
	sw $v1, resultado
	lw $a0, resultado
	jal imprimir_int
			
	# Adiciona o resultado à array de listagem
	jal add_to_listagem

	j operacoes_aritmeticas

divisao:
	# divisao($a1, $a2)
	# Divide todos os numeros inseridos
	#
	# Arguments:
	# $a1 - int -- Quantidade de numeros
	# $a2 - int -- N de numeros atuais
	#
	# Returns:
	# $v1 - int -- Resultado (Recursivo)

	addi $a2, $a2, 1
	move $t0, $v1

	la $a0, ask_number
	jal print_and_input
	
	move $v1, $v0
	
	# Adicionando numero à array de listagem
	move $a0, $v0
	jal add_to_listagem
	
	# Para evitar acontecer 0 / v0
	beq $a2, 1, divisao

	div $t0, $v0
	
	mflo $v1
	
	# if a2 < a1
	blt $a2, $a1, divisao

	# Quando acabar de dividir tudo
	
	# Adicionando a operação à array de listagem
	add $a0, $0, 4
	jal add_to_listagem
	
	la $a0, resultado_div_str
	jal imprimir
	
	sw $v1, resultado
	lw $a0, resultado
	jal imprimir_int
			
	# Adiciona o resultado à array de listagem
	jal add_to_listagem

	j operacoes_aritmeticas

listagens:
	# listagens
	# Entry point para imprimir as listagens
	#
	# Estrutura - listagens array:
	# Index 0 = Quantidade de numeros inseridos pelo utilizador (n)
	# Index 1 até n = Todos os numeros inseridos pelo utilizador
	# Index n+1 = Operação efetuada
	# Index n+2 = Resultado obtido
	
	la $a0, listagens_arr
	jal read_listagens
	
read_listagens:
	# read_listagens ($a0)
	# Le a quantidade de numeros do registro e passa o endereço e o operador para a função de print
	#
	# Arguments
	# $a0 - Endereço onde está a quantidade de numeros inseridos pelo utilizador (Index 0, referente à estrutura)

	lw $t2, 0($a0) # Index 0 (Numero de numeros)
	beq $t2, $0, menu # Index 0 == 0, quer dizer que não há mais registros para a frente, logo volta para o menu
	move $a1, $t2
	addi $a2, $0, 0
	
	addi $t3, $t2, 1
	mul $t3, $t3, 4
	add $t3, $a0, $t3
	
	# (n + 1) * 4 = index do operador
	lw $a3, 0($t3)
		
	jal print_listagem
	
	
print_listagem:
	# print_listagem($a0, $a1, $a2, $a3)
	#
	# Arguments:
	# $a0 - Endereço
	# $a1 - Numero total de numeros
	# $a2 - n (contador)
	# $a3 - operador

	addi $a2, $a2, 1
	
	addi $a0, $a0, 4
	lw $t4, 0($a0) # Numero usado para a conta
	
	move $t5, $a0
	move $a0, $t4
	jal imprimir_int

	# Setar $a0 outra vez caso entre na condição
	move $a0, $t5
	beq $a1, $a2, print_listagem_resultado
	
	move $a0, $a3
	jal imprimir_operador
	
	move $a0, $v0
	jal imprimir

	move $a0, $t5
	blt $a2, $a1, print_listagem # $a2 < $a1

print_listagem_resultado:
	# print_listagem_resultado($a0, $a1, $a2, $a3)
	# Imprime o igual (=) e o resultado da conta
	#
	# Arguments:
	# $a0 - Endereço depois de pegar os numeros
	# $a1 - Numero total de numeros
	# $a2 - n (contador)
	# $a3 - operador

	move $t5, $a0
	
	la $a0, igual_str
	jal imprimir
	
	# Pegar o resultado, que vai ser (Index N + 1) + 8, ver estrutura do array.
	lw $a0, 8($t5)
	jal imprimir_int
	jal divider
	
	# Limpar argumentos desnecessarios
	jal reset_arguments_values
	
	# Setar o endereço para o próximo registro
	move $a0, $t5
	add $a0, $a0, 12
	
	j read_listagens

add_to_listagem:
	# add_to_listagem($a0)
	# Adicionar ao array o conteudo de $a0
	#	
	# Arguments:
	# $a0 - int -- Numeros para serem inseridos no array.

	la $s2, listagens_arr
	lw $t3, listagens_index
	
	add $s2, $s2, $t3
	sw $a0, 0($s2)
	
	addi $t3, $t3, 4
	sw $t3, listagens_index

	jr $ra

# System call functions

imprimir:
	# imprimir($a0)
	# Inprime o conteudo que esta em $a0
	#
	# Arguments:
	# $a0 -- la $a0, string

	li $v0, 4
	syscall
	jr $ra

imprimir_int:
	# imprimir_int($a0)
	# Inprime um inteiro que esta em $a0
	#
	# Arguments:
	# $a0 -- la $a0, int

	li $v0, 1
	syscall
	jr $ra

imprimir_operador:
	# imprimir_operador($a0)
	# Imprime o operador usado (listagens)
	#
	# Arguments:
	# $a0 - int[1, 2, 3, 4]
	#
	# 1 - soma_str
	# 2 - subtracao_str
	# 3 - multiplicacao_str
	# 4 - divisao_str
	
	beq $a0, 1, load_soma_str
	beq $a0, 2, load_subtracao_str
	beq $a0, 3, load_multiplicacao_str
	beq $a0, 4, load_divisao_str

load_soma_str:
	# load_soma_str()
	# Simples função para declarar v0 a string "+"

	la $v0, soma_str
	jr $ra

load_subtracao_str:
	# load_subtracao_str()
	# Simples função para declarar v0 a string "-"

	la $v0, subtracao_str
	jr $ra

load_multiplicacao_str:
	# load_multiplicacao_str()
	# Simples função para declarar v0 a string "*"

	la $v0, multiplicacao_str
	jr $ra

load_divisao_str:
	# load_divisao_str()
	# Simples função para declarar v0 a string "/"

	la $v0, divisao_str
	jr $ra
	
print_and_input:
	# print_and_input($a0)
	# Imprime o conteudo e le o input
	#
	# Arguments:
	# $a0 -- la $a0, string
	#
	# Returns:
	# $v0 - int -- inserted number 

	li $v0, 4
	syscall
	li $v0, 5
	syscall
	jr $ra
	
divider:
	# divider()
	# Simplesmente para melhorar UI

	la $a0, divider_str
	li $v0, 4
	syscall
	jr $ra

int_input:
	# int_input()
	# Le o numero inserido pelo utilizador
	#
	# Returns:
	# $v0 - int -- inserted number 

	li $v0, 5
	syscall
	jr $ra
	
reset_arguments_values:
	# reset_arguments_values($a0, $a1, $a2, $a3)
	# Reseta todos os argumentos para 0

	addi $a0, $0, 0
	addi $a1, $0, 0
	addi $a2, $0, 0
	addi $a3, $0, 0
	
	jr $ra
exit: 
	# exit()
	# Função para sair do programa

	li $v0, 10
	syscall