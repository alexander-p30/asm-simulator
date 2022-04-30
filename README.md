# Trabalho 2 de Software Básico - 2021/2

## Identificação

Estevan Alexander de Paula - 17/0009611

## Disclaimer

Caso o setup do docker de 32 bits seja utilizado, como sugerem as instruções abaixo, é possível que builds subsequentes falhem na máquina host devido ao esquema permissões entre host-container (o host não consegue sobrescrever arquivos que foram criados pelo container). Caso isso ocorra, basta rodar:

```bash
make clean
```

Dessa forma, os arquivos objeto dentro da pasta build são excluídos, possibilitando novas compilações/montagens.

## Descrição

O trabalho consiste em escrever, em IA-32, um simulador do assembly fictício visto em aula.

Foram implementados um simulador "standalone", ou seja, que roda em qualquer máquina e que não depende de uma chamada de função em C; e também um simulador que depende de uma chamada de função em C, que só funciona em máquinas de 32 bits.

Ao final da execução, será imprimida na tela uma mensagem com o tamanho do arquivo de disassembly parcial gerado. A separação do output da execução do simulador e do output dessa mensagem é dada por uma linha de caracteres `=`. Exemplo de execução abaixo:

```bash
59b658ed9565# ./main.out asm_examples/teste.txt
5
1
0
1
=====================
O arquivo de saida (asm_examples/teste.txt.diss) ocupa 226 B.
```

A pasta `asm_examples` contém vários arquivos de exemplo do assembly inventado usados para o teste deste simulador.

## Como rodar?

### Versão 32 bits (ia32/c)

Para rodar essa versão, incluí o setup de um container rodando ubuntu 32 bits. Para construir e abrir uma sessão no container, basta rodar:

```bash
make run32
```

Pode demorar um pouco da primeira vez para que a imagem seja construída. Finalizado o processo e com a sessão iniciada no container de 32 bits (deve acontecer automaticamente), rode:

```bash
make comp32
```

Assim, o executável cujo ponto de entrada é um arquivo C mas cuja execução bruta ocorre no assembly será compilado e ligado. Para iniciar o programa:

```bash
./main.out {nome_do_arquivo_objeto_do_asm_inventado}
```

Ex: `./main.out asm_examples/add.txt`, `./main.out asm_examples/teste.txt`...

### Versão "standalone" (roda em 32/64 bits)

Para rodar a versão standalone, basta rodar:

```bash
make comp_standalone
./standalone.out
```

Assim que o programa estiver sendo executado, é só digitar o caminho relativo do arquivo para que ele seja simulado e parcialmente desmontado. Ex: `asm_examples/add.txt`, `asm_examples/teste.txt`...

