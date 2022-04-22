sh: 
		docker build -t ubuntu32 .
		docker run -it --rm -v $$PWD:/app -w /app/ ubuntu32 zsh

comp32:
		nasm -f elf main.asm -o main.o && gcc main.c main.o -o io.out
