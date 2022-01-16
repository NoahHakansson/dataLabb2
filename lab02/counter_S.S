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
	subq %rcx, %r11 # (4-GPIO_NR)
	shlq $1, %r11 # multiply by 2, by shifting left once, %r11 has second parenthesis
	mov %r11, %rcx # move into rcx so we can use its sub register cl for left shift
	shlq %cl, %rsi # shift left by %cl, whole right side is in %rsi
	# combine everything
	orq %rsi, (%rdi) # perform bitwose OR into (%rdi)
	# decrease GPIO_NR by 1
	decq %r8
	cmpq $0, %r8 # when we have set GPIO 1-4 dont loop anymore
	jne outputLoop
endOP:
	# set GPIO_NR 0 to input + some more registers
	movq $0, %r8
	movq $3, %r9
	movq GPIO, %rdi
	movq $0x3, %rsi
	# right side
	subq %r8, %r9 # (3-GPIO_NR)
	shlq $1, %r9 # multiply by 2, by shifting left once, %r9 has second parenthesis
	andq $7, %r9 # do AND with 7, same as % 8, %r9 has third parenthesis
	addq $8, %r9 # add 8 to %r9, %r9 has fourth parenthesis
	mov %r9, %rcx # move into rcx so we can use its sub register cl for left shift
	shlq %cl, %rsi # shift left by %cl, whole right side is in %rsi
	# left side
	shrq $3, %r8 # shift right three times to divide by 8
	addq %r8, (%rdi) # %rdi contains left side
	# combine everything
	orq %rsi, (%rdi) # perform bitwose OR into (%rdi)
endIP:









	ret
