Section .text
	global _main
_main:
	push rbp
	mov rbp, rsp
	ldr rax, [rbp + 0]
	mov rbx, 10
	mov rax, rbx
	str rax, [rbp + 0]
ret
