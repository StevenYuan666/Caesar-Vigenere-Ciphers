# TODO: Ye Yuan 260921269
# TODO: ADD OTHER COMMENTS YOU HAVE HERE AT THE TOP OF THIS FILE
# TODO: SEE LABELS FOR PROCEDURES YOU MUST IMPLEMENT AT THE BOTTOM OF THIS FILE
# TODO: NOTICE THE TODO IN THE .DATA SEGMENT
# TODO: RENAME THIS FILE AS PER THE SUBMISSION REQUIREMENTS

# Menu options
# r - read text buffer from file 
# p - print text buffer
# e - encrypt text buffer
# d - decrypt text buffer
# w - write text buffer to file
# g - guess the key
# q - quit

.data
MENU:              .asciiz "Commands (read, print, encrypt, decrypt, write, guess, quit):"
REQUEST_FILENAME:  .asciiz "Enter file name:"
REQUEST_KEY: 	 .asciiz "Enter key (upper case letters only):"
REQUEST_KEYLENGTH: .asciiz "Enter a number (the key length) for guessing:"
REQUEST_LETTER: 	 .asciiz "Enter guess of most common letter:"
ERROR:		 .asciiz "There was an error.\n"

FILE_NAME: 	.space 256	# maximum file name length, should not be exceeded
KEY_STRING: 	.space 256 	# maximum key length, should not be exceeded

.align 2		# ensure word alignment in memory for text buffer (not important)
TEXT_BUFFER:  	.space 10000
.align 2		# ensure word alignment in memory for other data (probably important)
# TODO: define any other spaces you need, for instance, an array for letter frequencies
ALPHABET:	.word 0:26 #there are 26 letters in English

##############################################################
.text
		move $s1 $0 	# Keep track of the buffer length (starts at zero)
MainLoop:	li $v0 4		# print string
		la $a0 MENU
		syscall
		li $v0 12	# read char into $v0
		syscall
		move $s0 $v0	# store command in $s0			
		jal PrintNewLine

		beq $s0 'r' read
		beq $s0 'p' print
		beq $s0 'w' write
		beq $s0 'e' encrypt
		beq $s0 'd' decrypt
		beq $s0 'g' guess
		beq $s0 'q' exit
		b MainLoop

read:		jal GetFileName
		li $v0 13	# open file
		la $a0 FILE_NAME 
		li $a1 0		# flags (read)
		li $a2 0		# mode (set to zero)
		syscall
		move $s0 $v0
		bge $s0 0 read2	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
read2:		li $v0 14	# read file
		move $a0 $s0
		la $a1 TEXT_BUFFER
		li $a2 9999
		syscall
		move $s1 $v0	# save the input buffer length
		bge $s0 0 read3	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		move $s1 $0	# set buffer length to zero
		la $t0 TEXT_BUFFER
		sb $0 ($t0) 	# null terminate the buffer 
		b MainLoop
read3:		la $t0 TEXT_BUFFER
		add $t0 $t0 $s1
		sb $0 ($t0) 	# null terminate the buffer that was read
		li $v0 16	# close file
		move $a0 $s0
		syscall
		la $a0 TEXT_BUFFER
		jal ToUpperCase
print:		la $a0 TEXT_BUFFER
		jal PrintBuffer
		b MainLoop	

write:		jal GetFileName
		li $v0 13	# open file
		la $a0 FILE_NAME 
		li $a1 1		# flags (write)
		li $a2 0		# mode (set to zero)
		syscall
		move $s0 $v0
		bge $s0 0 write2	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
write2:		li $v0 15	# write file
		move $a0 $s0
		la $a1 TEXT_BUFFER
		move $a2 $s1	# set number of bytes to write
		syscall
		bge $v0 0 write3	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
		write3:
		li $v0 16	# close file
		move $a0 $s0
		syscall
		b MainLoop

encrypt:		jal GetKey
		la $a0 TEXT_BUFFER
		la $a1 KEY_STRING
		jal EncryptBuffer
		la $a0 TEXT_BUFFER
		jal PrintBuffer
		b MainLoop

decrypt:		jal GetKey
		la $a0 TEXT_BUFFER
		la $a1 KEY_STRING
		jal DecryptBuffer
		la $a0 TEXT_BUFFER
		jal PrintBuffer
		b MainLoop

guess:		li $v0 4		# print string
		la $a0 REQUEST_KEYLENGTH
		syscall
		li $v0 5		# read an integer
		syscall
		move $s2 $v0
		
		li $v0 4		# print string
		la $a0 REQUEST_LETTER
		syscall
		li $v0 12	# read char into $v0
		syscall
		move $s3 $v0	# store command in $s0			
		jal PrintNewLine

		move $a0 $s2
		la $a1 TEXT_BUFFER
		la $a2 KEY_STRING
		move $a3 $s3
		jal GuessKey
		li $v0 4		# print String
		la $a0 KEY_STRING
		syscall
		jal PrintNewLine
		b MainLoop

exit:		li $v0 10 	# exit
		syscall

###########################################################
PrintBuffer:	li $v0 4          # print contents of a0
		syscall
		li $v0 11	# print newline character
		li $a0 '\n'
		syscall
		jr $ra

###########################################################
PrintNewLine:	li $v0 11	# print char
		li $a0 '\n'
		syscall
		jr $ra

###########################################################
PrintSpace:	li $v0 11	# print char
		li $a0 ' '
		syscall
		jr $ra

#######################################################
GetFileName:	addi $sp $sp -4
		sw $ra ($sp)
		li $v0 4		# print string
		la $a0 REQUEST_FILENAME
		syscall
		li $v0 8		# read string
		la $a0 FILE_NAME  # up to 256 characters into this memory
		li $a1 256
		syscall
		la $a0 FILE_NAME 
		jal TrimNewline
		lw $ra ($sp)
		addi $sp $sp 4
		jr $ra

###########################################################
GetKey:		addi $sp $sp -4
		sw $ra ($sp)
		li $v0 4		# print string
		la $a0 REQUEST_KEY
		syscall
		li $v0 8		# read string
		la $a0 KEY_STRING  # up to 256 characters into this memory
		li $a1 256
		syscall
		la $a0 KEY_STRING
		jal TrimNewline
		la $a0 KEY_STRING
		jal ToUpperCase
		lw $ra ($sp)
		addi $sp $sp 4
		jr $ra

###########################################################
# Given a null terminated text string pointer in $a0, if it contains a newline
# then the buffer will instead be terminated at the first newline
TrimNewline:	lb $t0 ($a0)
		beq $t0 '\n' TNLExit
		beq $t0 $0 TNLExit	# also exit if find null termination
		addi $a0 $a0 1
		b TrimNewline
TNLExit:		sb $0 ($a0)
		jr $ra

##################################################
# converts the provided null terminated buffer to upper case
# $a0 buffer pointer
ToUpperCase:	lb $t0 ($a0)
		beq $t0 $zero TUCExit
		blt $t0 'a' TUCSkip
		bgt $t0 'z' TUCSkip
		addi $t0 $t0 -32	# difference between 'A' and 'a' in ASCII
		sb $t0 ($a0)
TUCSkip:		addi $a0 $a0 1
		b ToUpperCase
TUCExit:		jr $ra

###################################################
# END OF PROVIDED CODE... 
# TODO: use this space below to implement required procedures
###################################################









##################################################
# null terminated buffer is in $a0
# null terminated key is in $a1
EncryptBuffer:	# TODO: Implement this function!
		lb $t0 ($a0) #load the current character
		lb $t1 ($a1) #load the current key
 		beq $t0 $zero EnExit #reach the end of the string, jump back to the main function
 		beq $t1 $zero EnReset #reach the end of the key, iterate from the head again, need to reset here
 		j EnBack
EnReset:	la $a1 KEY_STRING
		lb $t1 ($a1)
EnBack: 	blt $t0 'A' EnSkip #when the current character is not Uppercase Letter
 		bgt $t0 'Z' EnSkip #when the current character is not Uppercase Letter
	 	sub $t1 $t1 'A'
		add $t0 $t0 $t1 #shift the current character by given key steps
		bgt $t0 'Z' EnTrue #If after shifting the value is over character bound, shift back by minus 26
		j EnCon
EnTrue:		subi $t0 $t0 26
EnCon:		sb $t0 ($a0) #store the byte
EnSkip:		addi $a1 $a1 1 #move to the next key
		addi $a0 $a0 1 #move to the next character
		b EncryptBuffer	#iterate again
EnExit:		jr $ra

##################################################
# null terminated buffer is in $a0
# null terminated key is in $a1
DecryptBuffer:	# TODO: Implement this function!
		lb $t0 ($a0) #load the current character
		lb $t1 ($a1) #load the current key
 		beq $t0 $zero DeExit #reach the end of the string, jump back to the main function
 		beq $t1 $zero DeReset #reach the end of the key, iterate from the head again, need to reset here
 		j DeBack
DeReset:	la $a1 KEY_STRING
		lb $t1 ($a1)
DeBack: 	blt $t0 'A' DeSkip #when the current character is not Uppercase Letter
 		bgt $t0 'Z' DeSkip #when the current character is not Uppercase Letter
	 	sub $t1 $t1 'A'
		sub $t0 $t0 $t1 #shift the current character by given key steps
		blt $t0 'A' DeTrue #If after shifting the value is less than character bound, shift back by add 26
		j DeCon
DeTrue:		addi $t0 $t0 26
DeCon:		sb $t0 ($a0) #store the byte
DeSkip:		addi $a1 $a1 1 #move to the next key
		addi $a0 $a0 1 #move to the next character #when we meet a non character, we only need to skip the char not the key
		b DecryptBuffer	#iterate again
DeExit:		jr $ra

###########################################################
# a0 keySize - size of key length to guess
# a1 Buffer - pointer to null terminated buffer to work with
# a2 KeyString - on return will contain null terminated string with guess
# a3 common letter guess - for instance 'E' 
GuessKey:	# TODO: Implement this function!
		#The idea here is that since we may read a file with smaller length than the file we have read, so the buffer may
		#contain parts of the last file. As a consequence, we should set at least one multiple length of key to be null after
		#the true terminator. Otherwise, we may count the characters from the last file.
		lb $t1 ($a1) #load the current char
		li $t0 0 #set the counter to be zero
FindNull:	beq $t1 $zero Initialize #when we find the first null, set the remaining part as null as well
		addi $a1 $a1 1 #update counter
		lb $t1 ($a1)
		j FindNull #iterate again
Initialize:	beq $t0 $a0 CountPre #when after the initialization, start the main loop
		addi $a1 $a1 1 #update the counter
		addi $t0 $t0 1 
		sb $zero ($a1) #store it as null
		j Initialize #iterate again
CountPre:	la $a1 TEXT_BUFFER #reset the a1 at the head of the buffer
		li $t0 0 #k in the formula
Count:		lb $t2 ($a1) #load the current character
		la $t3 ALPHABET #load the array we record the frequencies
		beq $t0 $a0 GuessExit #stop the function when k = n, that is the modular equal to divisor(length of key)
		beq $t2 $zero IncreaseMod #when meet the end of text, start again with k = k + 1
		blt $t2 'A' CountSkip #skip the current iteration since the character is not a letter
		bgt $t2 'Z' CountSkip #skip the current iteration since the character is not a letter
		sub $t4 $t2 'A' #the index in array Alphabet we need to increase by one, the index = current char - 'A'
		li $t5 4 #we need to multiply the index by 4,since the array is word, which is 4 bytes
		mult $t5 $t4 #the result can only be in 0 - 25 * 4, i.e 0 - 100, t4 and t5 can be rewrite now. 
		mflo $t4 #since the product is in 0 - 100, we only need the lower half of the product
		add $t3 $t3 $t4 #let $3 point to the address we want to increase one
		lw $t5 ($t3) #load the target word(stored in t3) to the register t5
		addi $t5 $t5 1 #increase the number stored by one
		sw $t5 ($t3) #store the number after increment to the original address
CountSkip:	add $a1 $a1 $a0 #the next character we care should be the current character we care plus the guess key size
		j Count #go back to the loop
IncreaseMod:	addi $t0 $t0 1 #let k = k + 1
		la $a1 TEXT_BUFFER #reset a1 again, since we need to iterate from the head again
		add $a1 $a1 $t0 #set the begin place as k
		li $t6 0 #array counter
		li $t7 0 #record the max number in the array, i.e the most frequent character
		j FindMax #start to find the most frequent letter for current mod k
FindMaxBack:	j Count #start to count frequencies based on the next k
FindMax:	beq $t6 26 FindMaxExit #when we have iterate 26 times, jump out the loop
		la $t3 ALPHABET #load the array to the register
		li $t4 4 #we need to multiply the index by 4,since the array is word, which is 4 bytes
		mult $t6 $t4 #the product of array counter and 4 is the offset
		mflo $t4 #store the offset in t4
		add $t3 $t3 $t4 #add the offset
		lw $t4 ($t3) #load the number stored in t3 to the register t4
		bgt $t4 $t7 UpdateMax
FBack1:		sw $zero ($t3) #reset the current record as zero, since it's not the max number, we don't need it anymore
		addi $t6 $t6 1 #add the counter by one
		j FindMax #iterate again
UpdateMax:	move $t7 $t4 #since the t7 hold the max value, so move t4 to t7
		move $t8 $t6 #use the t8 to remember the index where we have the maximum number
		j FBack1 #jump back to the loop
FindMaxExit:	sub $t9 $a3 'A' #transform the most common letter to 0 - 25
		sub $t9 $t8 $t9 #substract the number represent common letter from the index where we have the max number
		blt $t9 $zero NeedAdd #when the key is lower than the range of letter, should be added back to the range
FBack2:		addi $t9 $t9 'A' #let the key in the range of A - Z in ASCII
		sb $t9 ($a2) #store the key in the return register
		addi $a2 $a2 1
		j FindMaxBack #jump out the FindMax loop
NeedAdd:	addi $t9 $t9 26 #We should add the key by 26 to let it in the range A - Z
		j FBack2 #jump back to the Exit Process
GuessExit:	sb $zero ($a2)
		jr $ra #jump back to main function
