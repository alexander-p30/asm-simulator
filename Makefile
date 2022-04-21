sh: 
		docker build -t ubuntu32 .
		docker run -it --rm -v $$PWD:/app -w /app/ ubuntu32 zsh

comp32:
		nasm -f elf io_c.asm -o io_c.o && gcc main.c io_c.o -o io.out
