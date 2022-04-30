run32: 
		docker build -t ubuntu32 .
		docker run -it --rm -v $$PWD:/app -w /app/ ubuntu32 zsh

comp32:
		nasm -f elf main.asm -o build/main.o 
		gcc main.c build/main.o -o main.out

comp_standalone:
		nasm -f elf -o build/standalone.o standalone.asm 
		ld -m elf_i386 -o standalone.out build/standalone.o

clean:
		rm build/main.o build/standalone.o
