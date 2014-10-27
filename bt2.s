.code16
.data
.text
	jmp $0x7c0,$go
go:
	mov %cs,%ax
	mov %ax,%ds
	mov %ax,%es
	lss stk,%sp
	mov $0x200,%bx
	mov $0,%dx
	mov $2,%cx
	mov $0x0208,%ax
	int $0x13
	jnc 1f
	jmp .
1:
	call cls
	nop
	call get_flp_param
	cli
	lgdt l_gdt
	smsw %ax
	or $1,%ax
	lmsw %ax
	jmp $8,$0
//{{{get_flp_param	取得软盘驱动器参数
get_flp_param:
	pusha
	push %ds
	push %ds
	pop %es
	lea fparam,%di
	mov $0,%ax
	mov %ax,%ds
	mov $0x78,%si			#int 0x1E
	lodsw
	mov %ax,%bx
	lodsw
	mov %ax,%ds
	mov %bx,%si
	mov $12,%cx
	rep movsb
	pop %ds
	popa
	ret
//}}}	
//{{{cls	清屏
cls:
	pusha
	mov $0xb800,%ax
	mov %ax,%es
	mov $0,%di
	mov $0x7d0,%cx
	mov $0x20,%ax
	rep stosw
	popa
	ret
//}}}
stk:	.word	0x300,0x3000,0
l_gdt:
		.word	71
		.word	0x7c00+gdt,0
/*关于内存划分使用的初步构想
 现在开始考虑对整体内存的使用规划了，初步设想：
 1、1M内存的分配：
 （1）前64k（0-0xffff）地址存放pdt/pt，idt和gdt。
 （2）第二个64k（0x10000-0x1ffff）存放备份的bios数据。
 （3）紧接着的320k（0x20000-0x6ffff）用于dma的读写缓冲区。
 （4）自0x70000-0x9ffff的192k为自定义的系统数据区。
 （5）0x100000至1M的（其中有显示缓冲区）部分保留。
 2、1M-2M之间的内存分配：
 （1）中断处理函数存放位置
 （2）最后8k（0x1e0000-0x1fffff）为内核堆栈区。
 3、2M-4M之间的内存分配：
 （1）前64k（0x200000-0x20ffff）存放ldt/tr,及部分pt。
 （2）剩余部分为内核代码、数据区。
 4、4M之后为用户空间。
 */		
gdt:
		.word	0,0,0,0
		.word	2,0x7e00,0x9a00,0x00c0			#0x8	text
		.word	2,0x7e00,0x9200,0x00c0			#0x10	data
		.word	1,0xe000,0x9210,0x00c0			#0x18	stack
		.word	1,0x7c00,0x9200,0x00c0			#0x20	floppy parameters'sare
		.word	32,0x0000,0x9200,0x00c0			#0x28	gdt/idt,bios's data
		.word	4,0x0000,0x9210,0x00c0			#0x30	interrupt func
		.word	47,0x000,0x9207,0x00c0			#0x38	personal kernel data
		.word	0,0,0,0

.org	490
fparam:	.space 12,0

.org	510
.word	0xaa55

