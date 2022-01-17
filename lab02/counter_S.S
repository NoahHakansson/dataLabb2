	.data
counter:	.quad 0
GPIO:		.quad 0
	.text
	.global setup
	.global interrupt

interrupt:
	movq counter, %rsi
	movq GPIO, %rdi
	incq %rdi # increment counter by one 0-15
	andq $15, %rsi # do AND with 15, same as %16 (modulus 16)

pin4:
	# Use AND + right shift to get each leds on or off status
	movq counter, %rsi
	movq $1, %r8 #  0001 /pin 4
	andq %rsi, %r8 # AND to get the 1 bit isolated
	# no shifting needed, already in least significant bit
	movq $4, %rcx # move pin number to rcx to call led on/off procedure
	cmpq $0, %r8 # if 0 turn off led, otherwise turn on led
	je pin4Off
pin4On:
	call ledOn
	jmp pin3
pin4Off:
	call ledOff

pin3:
	movq counter, %rsi
	movq $2, %r8 #  0010 /pin 3
	andq %rsi, %r8 # AND to get the 2 bit isolated
	shrq $1, %r8 # shift right to get bit in least significant bit
	movq $3, %rcx # move pin number to rcx to call led on/off procedure
	cmpq $0, %r8 # if 0 turn off led, otherwise turn on led
	je pin3Off
pin3On:
	call ledOn
	jmp pin2
pin3Off:
	call ledOff

pin2:
	movq counter, %rsi
	movq $4, %r8 # 0100 /pin 2
	andq %rsi, %r8 # AND to get the 4 bit isolated
	shrq $2, %r8 # shift right to get bit in least significant bit
	movq $2, %rcx # move pin number to rcx to call led on/off procedure
	cmpq $0, %r8 # if 0 turn off led, otherwise turn on led
	je pin2Off
pin2On:
	call ledOn
	jmp pin1
pin2Off:
	call ledOff

pin1:
	movq counter, %rsi
	movq $8, %r8 # 1000 /pin 1
	andq %rsi, %r8 # AND to get the 8 bit isolated
	shrq $3, %r8 # shift right to get bit in least significant bit
	movq $1, %rcx # move pin number to rcx to call led on/off procedure
	cmpq $0, %r8 # if 0 turn off led, otherwise turn on led
	je pin1Off
pin1On:
	call ledOn
	jmp endIr
pin1Off:
	call ledOff
endIr:
	ret

# set leds on or off
ledOn:
	# %rcx contains GPIO_NR, %rdi contains GPIO
	movq GPIO, %rdi
	movq $0x3, %r9
	addq $3, (%rdi) # left side done
	shlq $4, %r9
	addq $1, %r9 # left parenthesis done
	subq $1, %rcx
	shlq $3, %rcx # shift left 3 times to multiply by 8, rcx contains right perenthesis
	# both parenthesis done, time to combine them
	shlq %cl, %r9 # shift left by %cl (%rcx subregister), whole right side is in %rsi
	# right side is in %r9
	orq %r9, (%rdi) # perform bitwose OR into (%rdi)
	ret
ledOff:
	# %rcx contains GPIO_NR, %rdi contains GPIO
	movq GPIO, %rdi
	addq $3, (%rdi)
	ret

setup:
	movq $0, counter
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
	andq $7, %r9 # do AND with 7, same as %8 (modulus 8), %r9 has third parenthesis
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
