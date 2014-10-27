boot.img:boot.elf head.elf
	dd bs=512 if=boot.elf of=boot.img count=1
	dd bs=512 if=head.elf of=boot.img seek=1 count=9
	dd bs=512 if=/dev/zero of=boot.img seek=10 count=2870
boot.elf:boot.bin
	objcopy -R .pdr -R .comment -R .note -S -O binary boot.bin boot.elf
head.elf:head.bin
	objcopy -R .pdr -R .comment -R .note -S -O binary head.bin head.elf
boot.bin:boot.o
	ld -o boot.bin boot.o -Ttext 0
head.bin:head.o
	ld -o head.bin head.o -Ttext 0
boot.o:bt2.s
	as -o boot.o bt2.s
head.o:hd2.s
	as -o head.o hd2.s
clean:
	rm boot.* head.*
install:
	cp boot.img ~/
	
