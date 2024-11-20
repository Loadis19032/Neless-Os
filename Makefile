compile_yasm:	
	yasm -f bin neless.asm -o neless.bin
	qemu-system-x86_64 neless.bin


compile_nasm:
	nasm -f bin neless.asm -o neless.bin
	qemu-system-x86_64 neless.bin
