.data 
    n: .asciiz "Informe o tamanho n do vetor (10 <= n <= 100): "
    nao_ord: .asciiz "\nVetor nao ordenado:\n"
    ord: .asciiz "\nVetor ordenado:\n"
    espaco: .asciiz " " 
    nova_linha: .asciiz "\n" 
    .align 2 
    A: .space 400 

.text
main:
    # Leitura do n
    li $v0, 4 
    la $a0, n 
    syscall 

    li $v0, 5 
    syscall  
    move $s0, $v0 

    li $t0, 0   # i = 0

ALEATORIO:
    beq $t0, $s0, EXIBE_NAO_ORDENADO  
    li $v0, 42   
    li $a1, 100  # entre 0 e 99
    syscall  

    sll $t1, $t0, 2  
    sw $a0, A($t1)  

    addi $t0, $t0, 1 
    j ALEATORIO 

EXIBE_NAO_ORDENADO:
    li $v0, 4
    la $a0, nao_ord 
    syscall
    jal PRINT_VETOR 

# insertion_sort

    li $t0, 1  # j = 1

FOR_J:
    beq $t0, $s0, EXIBE_ORDENADO  
    sll $t1, $t0, 2  
    lw $t2, A($t1)   # chave = A[j]
    addi $t3, $t0, -1 # i = j - 1
    
    li $t7, -1  # variavel temporaria para verificar a saida do laco

WHILE_I:
    beq $t3, $t7, END_WHILE # se i == -1, sai do laco 
    sll $t4, $t3, 2 
    lw $t5, A($t4)  # $t5 = A[i]
    
    ble $t5, $t2, END_WHILE # se A[i] <= chave, sai do laco

    # A[i+1] = A[i]
    addi $t6, $t4, 4        # $t6 = endereço de A[i+1]
    sw $t5, A($t6)          # guarda o valor de A[i] na posicao A[i+1]
    
    addi $t3, $t3, -1 
    j WHILE_I

END_WHILE:
    addi $t4, $t3, 1  
    sll $t4, $t4, 2 
    sw $t2, A($t4)  # A[i+1] = chave
    
    addi $t0, $t0, 1 
    j FOR_J  

EXIBE_ORDENADO:
    li $v0, 4
    la $a0, ord
    syscall
    jal PRINT_VETOR

    li $v0, 10 # fim do programa
    syscall 

PRINT_VETOR:
    li $t8, 0  
LOOP:
    beq $t8, $s0, FIM  
    sll $t9, $t8, 2   
    lw $a0, A($t9)    

    li $v0, 1 
    syscall

    li $v0, 4 
    la $a0, espaco
    syscall

    addi $t8, $t8, 1 
    j LOOP

FIM:
    li $v0, 4
    la $a0, nova_linha
    syscall
    jr $ra