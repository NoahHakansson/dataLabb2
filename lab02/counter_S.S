	.data
counter:	.quad 0
GPIO:		.quad 0
	.text
	.global setup
	.global interrupt

interrupt:
	ret

setup:
	# set gpio mem adress
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

	# set pin 1-4 to output, using second formula
	movq $4, %r8 # GPIO_NR (pin number)
	movq GPIO, %rdi
outputLoop:
	movq %r8, %rcx
	movq $0x2, %rsi
	shlq $6, %rsi # first parenthesis in %rsi
	movq $4, %r11
	subq %rcx, %r11 #(4-GPIO_NR)
	shlq $1, %r11 # multiply by 2, by shifting left once, %r11 has second parenthesis
	mov %r11, %rcx # move into rcx so we can use its sub register cl for left shift
	shlq %cl, %rsi # whole right side is in %rsi
	orq %rsi, (%rdi) # perform bitwose OR into (%rdi)
	decq %r8
	cmpq $0, %r8
	jne outputLoop
endOP:
	# set GPIO_NR 0 to input
	movq $0, %r8
	movq GPIO, %rdi
	movq $0x3, %rsi
	# right side

	# left side
	shrq $3, %r8 # shift right three times to divide by 8
	addq %r8, (%rdi) # %rdi contains left side







	ret
