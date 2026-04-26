.data 
    n: .asciiz "Informe o tamanho n do vetor: "
    nao_ord: .asciiz "\nVetor nao ordenado:\n"
    ord: .asciiz "\nVetor ordenado:\n"
    espaco: .asciiz " " 
    nova_linha: .asciiz "\n" 
    .align 2 
    A: .space 400 # reserva espaço para 100 inteiros 

.text
main:
    li $v0, 4
    la $a0, n 
    syscall 

    li $v0, 5 
    syscall  
    add $s0, $v0, $zero 

    li $t0, 0       # i = 0

ALEATORIO:
    beq $t0, $s0, EXIBE_NAO_ORDENADO  
    li $v0, 42      # syscall para gerar numero aleatorio
    li $a1, 1000    # valor maximo
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

# qs(A, 0, n - 1)
    la $a0, A       # endereco base do vetor
    li $a1, 0       # left = 0 
    addi $a2, $s0, -1 # right = n - 1 
    jal QS

EXIBE_ORDENADO:
    li $v0, 4
    la $a0, ord
    syscall
    jal PRINT_VETOR

    li $v0, 10      # fim do programa
    syscall 

QS:
    # gerenciamento da pilha 
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $a1, 12($sp) # guarda left
    sw $a2, 8($sp)  # guarda right

    add $t0, $a1, $zero   # i = left 
    add $t1, $a2, $zero   # j = right 
    
    # x = vetor[(left + right) / 2] 
    add $t2, $a1, $a2
    srl $t2, $t2, 1 # divisao por 2 (deslocamento logico a direita) add $t8, $zero, 2 \n div $t2, $t8  \n mflo $t2
    sll $t2, $t2, 2
    add $t2, $t2, $a0
    lw $t2, 0($t2)  # $t2 = pivo (x)

PARTICAO:
WHILE_I:
    sll $t3, $t0, 2
    add $t3, $t3, $a0
    lw $t4, 0($t3)
    bge $t4, $t2, WHILE_J # vetor[i] < x 
    bge $t0, $a2, WHILE_J # i < right
    addi $t0, $t0, 1
    j WHILE_I

WHILE_J:
    sll $t5, $t1, 2
    add $t5, $t5, $a0
    lw $t6, 0($t5)
    ble $t6, $t2, SWAP_CHECK # x < vetor[j] 
    ble $t1, $a1, SWAP_CHECK # j > left 
    addi $t1, $t1, -1
    j WHILE_J

SWAP_CHECK:
    bgt $t0, $t1, RECURSAO_CHECK # se i > j, não troca 
    # troca (Swap) 
    sw $t6, 0($t3)  # vetor[i] = vetor[j]
    sw $t4, 0($t5)  # vetor[j] = y
    addi $t0, $t0, 1 # i++ 
    addi $t1, $t1, -1 # j-- 

    ble $t0, $t1, PARTICAO # faca enquanto (i <= j) 

RECURSAO_CHECK:
    # salva i e j atuais para nao perder nas chamadas recursivas
    sw $t0, 4($sp)
    sw $t1, 0($sp)

    # se (left < j) qs(vetor, left, j) 
    lw $a1, 12($sp) # recupera left original
    bge $a1, $t1, CHECK_RIGHT
    add $a2, $t1, $zero   # novo right = j
    jal QS

CHECK_RIGHT:
    # se (i < right) qs(vetor, i, right) 
    lw $t0, 4($sp)  # recupera i atualizado
    lw $a2, 8($sp)  # recupera right original
    bge $t0, $a2, FIM_QS
    add $a1, $t0, $zero   # novo left = i
    jal QS

FIM_QS:
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

PRINT_VETOR:
    li $t8, 0  
LOOP_P:
    beq $t8, $s0, FIM_P  
    sll $t9, $t8, 2   
    lw $a0, A($t9)    

    li $v0, 1 
    syscall

    li $v0, 4 
    la $a0, espaco
    syscall

    addi $t8, $t8, 1 
    j LOOP_P

FIM_P:
    li $v0, 4
    la $a0, nova_linha
    syscall
    jr $ra
