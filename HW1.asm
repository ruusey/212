.text

################################################################################
##BEGIN interface HW1 
##Copyright Robert Usey
##CSCE212 Homework01
##18 February, 2018
################################################################################

################################################################################
##BEGIN function suffix 
##returns a string that is the last n bytes of the string pointed to by a0
################################################################################
.globl suffix
suffix:
	#save return adress and args
	addi $sp $sp -4
    sw $ra 0($sp)
    jal savestate
	#allocate bytes on the heap
	jal suffix.allocatebytes
	#move n into a2 and resultant string into a1
	move $a2,$a1
	move $a1,$v0
	#find the length of a0
	jal length
	jal suffix.getstartindex
	#t0 will hold the total number of bytes counted so we can reset the location of a1 
	li $t0,0
	jal suffix.copy
	j returnstate
suffix.allocatebytes:
	#push a0 onto the stack so we can syscall
    addi $sp $sp -4
    sw $a0 0($sp)
	#syscall allocate bytes
	li $v0,9
	la $a0,($a1)
	syscall
	#pop a0 off stack
	lw $a0 0($sp)
    addi $sp $sp 4
	jr $ra	
suffix.getstartindex:
	#calculate the start index len-a2 where since we just jumped to length will be stored in v0
	sub $v0, $v0, $a2
	#set the start index of a0
	add $a0, $a0, $v0
	jr $ra
suffix.increment:
	#increment string adresses by one byte and total bytes counted by 1
	addi $t0, $t0, 1
    addi $a0, $a0, 1 
    addi $a1, $a1, 1	
suffix.copy:
	#load next byte from a0
    lb $t1, 0($a0)
    #if weve reached the end
    beq $t1, $zero, suffix.done
    #save the byte to the next location in a1
    sb $t1, 0($a1)
    j suffix.increment
   	
suffix.done:
	#reset result string address to where the string starts on the heap.
	sub $a1, $a1, $t0
	#move result string into retun v0
	move $v0, $a1
	jr $ra
################################################################################
##END function suffix
################################################################################	
	
################################################################################
##BEGIN function memchr 
##returns the index of the first occurance of char c within n bytes of the
##string pointed to by a0
################################################################################
.globl memchr
memchr:
 	addi $sp $sp -4
    sw $ra 0($sp)
   	jal savestate
	#store character counter in t0, set its initial value to 0
    li $t0, 0 
    #begin recursive loop to parse string
    j memchr.getchr
memchr.increment:
    addi $a0, $a0, 1 
    addi $t0, $t0, 1
memchr.getchr:
	lb $t1, 0($a0)
    #if the current character is equal to the one we are looking for
    beq $t1,$a1 memchr.found
	 #if we are at the maximum # of bytes defined by parameter a2
 	beq $t0,$a2 memchr.notfound
    #otherwise continue looking
    j memchr.increment 
memchr.notfound:
    #return -1 as instructed
    li $v0,-1
    j returnstate
memchr.found:
	#store result index in v0
    move $v0, $t0
    j returnstate  
################################################################################
##END function memchr
################################################################################


################################################################################
##BEGIN function length 
##returns the number of characters in the string pointed to by a0
################################################################################
.globl length                    
length:
	#store return adress/args so we can call length witout messing other stuff up
	addi $sp $sp -4
    sw $ra 0($sp)
   	jal savestate
	#store character counter in t0, set its initial value to 0
    li $t0, 0 
    #begin recursive loop to parse string
    j length.getchar
length.increment:
    addi $a0, $a0, 1 
    addi $t0, $t0, 1
length.getchar:
    lb $t1, 0($a0)
    #jump to increment character count/advance to next char index if the current character is non-zero
    bnez $t1, length.increment 
  	#move result into v0 return register
    move $v0, $t0
   	#get the return state
  	j returnstate

################################################################################
##END function length
################################################################################

################################################################################
##BEGIN function strncmp 
##compares the first n bytes specified by a2 of the srtings pointed to by a0,a1
################################################################################
.globl strncmp
strncmp:
	#save return adress on stack
	addi $sp $sp -4
    sw $ra 0($sp)
    #save arguments
    jal savestate
    #reset counters
    li $t0, 0
    li $t1, 0 
    li $t2, 0 
    #begin recursive loop to parse strings
    j strncmp.getchr
strncmp.increment:
	#increment both string adress pointers by 1 byte
    addi $a0, $a0, 1 
    addi $a1, $a1, 1
    #increment total byte counter by 1
    addi $t0, $t0, 1
     
strncmp.getchr:
	 #once we have loaded all byte values up to n
 	beq $t0,$a2 strncmp.complete
 	#Load bytes at index from both strings
  	lb $t3, 0($a0)
  	lb $t4, 0($a1)
  	#sum the bytes with current values for each
    add $t1, $t1,$t3
    add $t2, $t2,$t4
    
    j strncmp.increment
strncmp.complete:
	#store the result of the differnces of the sums of ascii caracters to n in t3
	sub $t3,$t2,$t1
	#if equal return 0
	beq $t1,$t2 strncmp.returnequal
	#if greater return -1
	bgtz $t3, strncmp.returngreater
	#if less return 1
	bltz $t3, strncmp.returnless
strncmp.returnequal:
	li $v0,0
	j returnstate
strncmp.returngreater:
	li $v0,-1
	j returnstate
strncmp.returnless:
	li $v0,1
	j returnstate
################################################################################
##END function strncmp
################################################################################

################################################################################
##BEGIN global save/load state functions to simply pushing and poping data from the 
##stack pointer, sorry if this was not permitted.
################################################################################	
.globl savestate
savestate:
	#Saves arguments to stack for later use/nested calls
	#sp expected to be decremented by 4 per necessity to save return adress from caller function
	#ra expected to be saved by user before calling. (cant save it here!)
	addi $sp $sp -4
    sw $a0 0($sp)
    addi $sp $sp -4
    sw $a1 0($sp)
    addi $sp $sp -4
    sw $a2 0($sp)
    jr $ra
################################################################################
.globl returnstate
returnstate:
	
	#loads arguments from stack after nested fn call
	lw $a2 0($sp)
    addi $sp $sp 4
    lw $a1 0($sp)
    addi $sp $sp 4
    lw $a0 0($sp)
    addi $sp $sp 4
    lw $ra 0($sp)
    addi $sp $sp 4
    jr $ra
################################################################################

################################################################################
##END interface HW1
################################################################################
