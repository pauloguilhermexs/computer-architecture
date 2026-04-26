.data
    # constantes em dupla precisão (Double) conforme padrão IEEE 754
    tol:    .double 0.0001
    zero:   .double 0.0
    two:    .double 2.0
    four:   .double 4.0
    ten:    .double 10.0
    
    # [1.0, 2.0]
    a: .double 1.0
    b: .double 2.0
    
  
    msg_res: .asciiz "Raiz aproximada encontrada: "
    msg_err: .asciiz "Raiz não encontrada!\n"
    msg_nl:  .asciiz "\n"

.text
.globl main

main:
    # carrega a = 1.0 e b = 2.0 
    l.d $f12, a
    l.d $f14, b 

    # chama bissecao(a, b)
    jal bissecao

    # branch on equal to zero (desvia se igual a zero) 
    beqz $v0, print_erro

print_sucesso:
    # salva o resultado retornado (em $f0) temporariamente em $f12 para imprimir
    mov.d $f12, $f0

    # imprimir mensagem de sucesso
    li $v0, 4
    la $a0, msg_res
    syscall

    # imprimir o valor double em $f12
    li $v0, 3
    syscall

    # imprimir quebra de linha
    li $v0, 4
    la $a0, msg_nl
    syscall
    
    j fim_programa

print_erro:
    # imprimir mensagem de erro 
    li $v0, 4
    la $a0, msg_err
    syscall

fim_programa:
    # encerrar o programa
    li $v0, 10
    syscall


# f(x) = x^3 + 4x^2 - 10
f:
    # $f0 = x * x (x^2)
    mul.d $f0, $f12, $f12
    
    # $f2 = (x^2) * x (x^3)
    mul.d $f2, $f0, $f12
    
    # Carrega 4.0 em $f4 e faz $f0 = 4 * x^2
    l.d $f4, four
    mul.d $f0, $f0, $f4
    
    # $f0 = x^3 + 4x^2
    add.d $f0, $f2, $f0
    
    # Carrega 10.0 em $f4 e faz $f0 = (x^3 + 4x^2) - 10
    l.d $f4, ten
    sub.d $f0, $f0, $f4
    
    jr $ra

#  bissecao(a, b)

bissecao:
    # preparar a pilha (Salvar $ra, $s0, $s1)
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)

    # mapa de registradores de ponto flutuante:
    # $f20 = a
    # $f22 = b
    # $f24 = tol
    # $f26 = 2.0 (divisor)
    # $f28 = 0.0 (comparador)
    # $f30 = fa
    
    mov.d $f20, $f12   # inicializa a
    mov.d $f22, $f14   # inicializa b
    
    l.d $f24, tol      # tol = 0.0001
    l.d $f26, two      # carrega 2.0
    l.d $f28, zero     # carrega 0.0

    # calcula fa = f(a)
    jal f
    mov.d $f30, $f0    # $f30 = fa

    # contadores do while
    li $s0, 1          # i = 1
    li $s1, 30         # maxiter = N = 30

loop_bissecao:
    # enquanto i <= N (Se i > maxiter, sai do loop com erro)
    bgt $s0, $s1, falha_bissecao  

    # calcula (b - a) em $f16 (Registrador seguro)
    sub.d $f16, $f22, $f20
    
    # calcula (b - a) / 2 em $f16
    div.d $f16, $f16, $f26
    
    # calcula p = a + (b - a) / 2 e salva em $f18 (Registrador seguro)
    add.d $f18, $f20, $f16
    
    # calcula fp = f(p)
    mov.d $f12, $f18   # passa 'p' como argumento
    jal f
    mov.d $f8, $f0     # $f8 = fp

    # condição 1: Se FP == 0
    c.eq.d $f8, $f28
    bc1t sucesso_bissecao

    # condição 2: ou (b-a)/2 < TOL
    c.lt.d $f16, $f24
    bc1t sucesso_bissecao

    # i = i + 1
    addi $s0, $s0, 1

    # verifica: Se FA * FP > 0
    mul.d $f10, $f30, $f8   # $f10 = fa * fp
    
    # compara se (fa * fp) <= 0.0  se for, vai para o bloco 'else'
    c.le.d $f10, $f28       
    bc1t else_bissecao

if_bissecao:
    # a = p
    mov.d $f20, $f18
    # FA = FP
    mov.d $f30, $f8
    j loop_bissecao         # volta pro enquanto

else_bissecao:
    # b = p
    mov.d $f22, $f18
    j loop_bissecao         # volta pro Enquanto

sucesso_bissecao:
    # Coloca 'p' como valor de retorno, status 1 (sucesso) e vai pro fim
    mov.d $f0, $f18
    li $v0, 1
    j limpar_pilha

falha_bissecao:
    # alcancou limite maximo de iteracoes
    li $v0, 0

# limpeza da pilha
limpar_pilha:  
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra