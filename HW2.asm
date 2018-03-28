#Author: Robert Usey
#CSCE212, Dan Pade
#HW2
.data
	.eqv    nodeData       		0
    .eqv    nodeNextAddr        4
    .eqv    nodeSize       		8       


.text
  j main

.globl prepend
prepend:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    jal 	savestate
    move 	$a2, $a1
    jal     Node_num
    sw      $a1, 4($v0)
	
    j 		returnstate
    
    ##
    ##for some reason the adress from the start of the original list gets passed to print list after this
    ## verified that it does point all next nodes to the previous but after calling, the adress of the end node is passed forcing a print of only the last element
    ## not sure if my error or driver error or if this isnt the corrent way to recerse things...
    ## got this to work in private testing by explicitly passing the correct adress for the new start of the reversed list
    
 .globl reverse   
reverse:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    jal 	savestate
    beq     $a0, $zero, reverse_exit
    #load adress of next nodes
    lw 		$t0, nodeNextAddr($a0)
    lw 		$t1, nodeNextAddr($t0)
    sw 		$zero, nodeNextAddr($a0)
    j 		reverse_loop
reverse_increment:
	#save adress of current node
	move 	$t0, $t1
	lw 		$t1, nodeNextAddr($t0) 
reverse_loop:
   #if we reach the end of the list
   beqz 	$t1, reverse_exit
   #save adress of current node in following nodes next field
   sw 		$a0, 4($t0)
   #make the current node the next node
   move 	$a0, $t0	
   bnez    	$t0, reverse_increment
reverse_exit:
	#end is now the start
    move 	$v0, $t0
    j 		returnstate 
          
.globl insert   
insert:
    addi    $sp, $sp,-4
    sw      $ra 0($sp)
    jal 	savestate
	li 		$t0, 0
    beq 	$a0, $zero,insert_exit
    move 	$a3, $a0
    j 		insert_loop
insert_increment:
	addi 	$t0, $t0,1
	la 		$a0,($t1)
insert_loop:
    lw      $t1, nodeNextAddr($a0)
    beq 	$t0, $a2, insert_index_found
    bnez    $t1,insert_increment
insert_index_found:
	#DATA FROM NEW NODE
	lw		$t0,nodeData($a1)
	#ADR TO NEXT NODE
	lw 		$t1,nodeNextAddr($a0)
	# REPLACE THE DATA	
	sw 		$t0, nodeData($a0)
	sw 		$t1, nodeNextAddr($a0)
insert_exit:
    move 	$v0, $a3
    j 		returnstate       
                          
.globl drop                       
drop:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    jal 	savestate
	li 		$t0, 0
    beq     $a0, $zero, drop_exit
    li 		$t0, 1
    j 		drop_loop
drop_increment:
	addi 	$t0, $t0, 1
	la 		$a0,($t1)
drop_loop:
   	#CALL "DECONSCTOR" (zero the data)
    lw      $t1,nodeNextAddr($a0)
    #######################################################
    #Should free memory but this causes the driver to fail...
    #######################################################
    #sw    $0  nodeData($a0)                   
    #sw    $0  nodeNextAddr($a0)
    ########
    beq 	$t0, $a1, drop_exit
    bnez    $t1, drop_increment
drop_exit:
    move 	$v0, $t1
    j 		returnstate

.globl length
length:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    jal 	savestate
	li 		$t0, 0
    beq     $a0, $zero, length_exit
    li		$t0, 1
    j 		length_loop
length_increment:
	addi 	$t0, $t0, 1
	la 		$a0, ($t1)
length_loop:
   	lw      $t3, 0($a0)
    lw      $t1, nodeNextAddr($a0)     
    bnez    $t1, length_increment
length_exit:
    move 	$v0, $t0
    j 		returnstate
  #------------------ DON'T MODIFY BELOW ---------------------------

  ## Entry point.
  #
  ######################################
                        #
  main:                                #
                                       #
    # Create 10 nodes in reverse       #
    # reverse order                    #
    ori  $a0  $0  10                   # Build the list [1..10]
    jal  Node_num                      # .
                                       # .
    ori  $a0  $0   9                   # .
    or   $a1  $0 $v0                   # .
    jal  prepend                       # .
                                       # .
    ori  $a0  $0   8                   # .
    or   $a1  $0 $v0                   # .
    jal  prepend                       # .
                                       # .
    ori  $a0  $0   7                   # .
    or   $a1  $0 $v0                   # .
    jal  prepend                       # .
                                       # .
    ori  $a0  $0   6                   # .
    or   $a1  $0 $v0                   # .
    jal  prepend                       # .
                                       # .
    ori  $a0  $0   5                   # .
    or   $a1  $0 $v0                   # .
    jal  prepend                       # .
                                       # .
    ori  $a0  $0   4                   # .
    or   $a1  $0 $v0                   # .
    jal  prepend                       # .
                                       # .
    ori  $a0  $0   3                   # .
    or   $a1  $0 $v0                   # .
    jal  prepend                       # .
                                       # .
    ori  $a0  $0   2                   # .
    or   $a1  $0 $v0                   # .
    jal  prepend                       # .
                                       # .
    ori  $a0  $0   1                   # .
    or   $a1  $0 $v0                   # .
    jal  prepend                       # .
    or   $s0  $0 $v0                   # [list := $s0] = [1..10]
                                       #
    addi $a0  $0  -1                   # [node := $s1] = new Node(-1)
    jal  Node_num                      # .
    or   $s1  $0 $v0                   # .
                                       #
    or   $a0  $0 $s0                   # print(length(list))
    jal  length                        # .
    or   $a0  $0 $v0                   # .
    ori  $v0  $0   1                   # .
    syscall                            # .
    ori  $t9  $0  10                   # .
    jal chr                            # .
                                       #
    or   $a0  $0 $s0                   # insert(list, node, 2)
    or   $a1  $0 $s1                   # .
    ori  $a2  $0   1                   # .
    jal  insert                        # .
                                       #
    or   $a0  $0 $s0                   # print(drop(list.next, 2))
    ori  $a1  $0   2                   # .
    jal  drop                          # .
    or   $a0  $0 $v0                   # .
    jal  print_list                    # .
    ori  $t9  $0 10                    # .
    jal  chr                           # .
                                       
   or   $a0  $0 $s0                   # Print the original list (before drop)
    jal print_list                     # .
    ori  $t9  $0 10                    # .
    jal  chr                           # .
                                       #
    or   $a0  $0 $s0                   # print(reverse(list))
    jal reverse                        # .
    jal print_list                     # .
    or   $a0 $0 $v0                    # .
    ori  $t9  $0 10                    # .
    jal  chr                           # .
                                       #
  ori  $v0 $0  10                      #
  syscall                             ##


  ## Prints a list.
  #
  # @param ($a0 : Node) The list to print.
  #
  ######################################                   #
  print_list:                          #
    addi $sp $sp  -4                   # print_list(list):
    sw   $ra  0($sp)                   #
                                       #
    ori  $t9  $0  91                   # print('[')
    jal  chr                           # .
    jal  print_list_recurse            # print_list_recurse(list)
    ori  $t9  $0  93                   # print(']')
    jal  chr                           # .
    lw   $ra  0($sp)                   #
    addi $sp $sp   4                   #
  jr $ra                              ##


  ## The inner recursive portion of printing a list.
  #
  # @param ($a0 : Node) The list to print.
  #
  ######################################
  .globl print_list_recurse            #
  print_list_recurse:                  #
    addi $sp $sp  -4                   # print_list_recurse(list):
    sw   $ra 0 ($sp)                   #
                                       # [val := $t0, next := $t1]
    lw   $t0  0($a0)                   # val  = list.val
    lw   $t1  4($a0)                   # next = list.next
                                       #
    or   $a0  $0 $t0                   # print(val)
    ori  $v0  $0   1                   # .
    syscall                            # .
                                       #
    bne $t1 $0 print_list__w_tail      # if next is NULL:
      j    print_recurse__end          #   return
    print_list__w_tail:                # else:
      ori  $t9  $0 44                  #   print(", ")
      jal  chr                         #   .
      ori  $t9  $0 32                  #   .
      jal  chr                         #   .
      or   $a0  $0 $t1                 #   print_list(next)
      jal  print_list_recurse          #   .
                                       #
  print_recurse__end:                  #
    lw   $ra 0 ($sp)                   #
    addi $sp $sp   4                   #
  jr $ra                              ##


  ## Constructs a (guaranteed) empty Node object.
  #
  #   A Node contains an int and a ptr, so we ask for 2 words (8
  # bytes) and zero them out.
  #
  # @return A pointer to an empty Node.
  #
  ######################################
  .globl Node                          #
  Node:                                #
    addi $sp $sp  -4                   # Node():
    sw   $a0  0($sp)                   #
                                       #
    ori  $a0  $0   8                   # Get the bytes
    ori  $v0  $0   9                   #
    syscall                            #
                                       #
    sw    $0  0($v0)                   # Zero them
    sw    $0  4($v0)                   #
                                       #
    lw   $a0  0($sp)                   #
    addi $sp $sp   4                   #
  jr $ra                              ##


  ## Constructs a Node with the given value.
  #
  # @param $a0 The value to store
  #
  # @return A pointer to a Node containing the value, and null for
  #         its `next' pointer.
  #
  ######################################
  .globl Node_num                      #
  Node_num:                            #
    addi $sp $sp  -4                   # Node(num : int):
    sw   $ra  0($sp)                   #
                                       #
    jal  Node                          #
    sw   $a0 0($v0)                    #
                                       #
    lw   $ra  0($sp)                   #
    addi $sp $sp   4                   #
  jr $ra                              ##


  ## Print a character
  #
  #   This function takes its argument in $t9 in order to preserve as
  # many `useful' registers for the callee as possible.
  #
  # @param $t9 The ASCII code of the character to print.
  #
  ######################################
  .globl chr                           #
  chr:                                 #
    addi $sp $sp  -4                   # chr($t9=char):
    sw   $a0  0($sp)                   #
    addi $sp $sp  -4                   #
    sw   $v0  0($sp)                   #
                                       #
    or   $a0  $0 $t9                   #
    ori  $v0  $0  11                   #
    syscall                            #
                                       #
    lw   $v0  0($sp)                   #
    addi $sp $sp  4                    #
    lw   $a0  0($sp)                   #
    addi $sp $sp  4                    #
  jr $ra                              ##
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
