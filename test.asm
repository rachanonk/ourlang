Section .text
	global _main
_main:
	push rbp
	mov rbp, rsp
	mov rax, 20
	mov rbx, 10
	add rax, rbx
	mov eax, 40
	mov ebx, 30
	imul ebx
	mov rcx, 40
	mov rdx, 30
	sub rcx, rdx
ret
