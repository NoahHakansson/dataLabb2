	.data
counter:	.quad 0
GPIO:		.quad 0
	.text
	.global setup
	.global interrupt

interrupt:
	ret

setup:
	movq $0x60, %rdi
	movq $0xFFFF, %rsi
	movq $0x9E, %rdx

	shlq $16, %rdi
	andq $0x1000, %rsi
	notq %rdx
	andq $0xFF, %rdx

	orq %rsi, %rdi
	orq %rdx, %rdi
	movq %rdi, GPIO

	

	ret
