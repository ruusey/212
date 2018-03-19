# HW2 Driver
# 2018 Daniel Pade
# All of your functions should be placed between the comments below

.text
  j main

  #------------------ PUT YOUR CODE HERE ---------------------------

  ## Prepends a number to a list
  #
  # @param $a0 The list.
  # @param $a1 The element to prepend
  #
  # @return the new list [$a0] + $a1
  #
  ######################################
  prepend:  
    # BUG: should be -4
    ###addi $sp,$sp,4
    addi    $sp,$sp,-4
    # BUGFIX
    sw      $ra,0($sp)

    lw      $t9,0($a0)              # load head of the list for later use
    lw      $t0,0($a0)              # load head of list into $t0

    # BUG: anding a _pointer_ against 0xF0 makes _no_ sense
    # NOTE: better to use hex for bit patterns
    ###andi $t0,$t0,240             # bitwise and with 240 (1111 0000) to extract first 4 bits for pointer to string
    # BUGFIX

    # BUG: this block of code is on the right track, but, wrong
    # storing into a0 (the struct) for strcmp makes _no_ sense
    sw      $t0,0($a0)              # store $t0 into $a0 for strcmp call
    lb      $t6,0($t0)              # get the byte of the first string char in the list
    lw      $t7,0($a1)              # get address of string
    lb      $t1,0($t7)              # get the byte of the first char of the string

    # NOTE: while we can set these here, we're burning two regs across the
    # strcmp call -- cleaner to move this below the call
    addi    $t3,$zero,1             # $t3 gets 1
    addi    $t4,$zero,-1            # $t3 gets -1

# be careful in this function may have a bug with front of the list
alphloop:
    #   slt     $t2, $t1, $t0           #if $t1 < $t0, then $t2 = 1, else $t2 = 0
    #   beq     $t2, $t3, put           #if
    #   beq     $t2, $zero, nextchar

    # BUG: strcmp destroys the values of a0 and a1, so the second time through
    # here they have bogus values
    # BUGBAD: strcmp uses them as pointers to the _strings_ but here, we're using
    # a0 as a _struct_ pointer!!!
    jal     strcmp                  # compare the strings in $a0 and $a1
    move    $t5,$v0                 # move the value returned from strcmp into $t5
    beq     $t5,$t4,put             # if $t5 == -1, then value is less and then put new string at head of list
    beq     $t5,$t3,nextstring      # if $t5 == 1, then the head of the list is larger than the string and go to next string
    beq     $t5,$zero,close         # check if it is zero, if so it is already in the list so step out

nextstring:
    lw      $t2,0($a0)              # store pointer to next node in $t2

    # NOTE: use hex for bit masks (e.g. 0x0F)
    # BUG: this makes no sense
    andi    $t8,$t9,15              # get address of next node string

    beq     $t8,$zero,put           # if it points to null then add node at the end
    sw      $t8,0($a0)              # store into $a0
    j       alphloop                # check against the next string in loop

put:
    # NOTE: what is 8??? obviously, it's the size in bytes of a node, so the
    # comment should say that
    
    #MOVE NODE NUMBER IN a1 into a0 for Node_num CONSTRUCTOR CALL                   # $t5 gets 8
    move    $a0,$a1                 # $t5 moved into $a0
    jal     Node_num                  # allocate size for node
    move    $t5,$v0                 # move address returned by malloc to $t5

    sw      $a1,0($t5)              # store $a1 into address allocated
    beq     $t2,$zero,front         # node is at front of the list, so there is no need to update pointer
    sw      $t2,4($t5)              # store pointer to current node into new node
    addi    $t0,$a0,-8              # subtract from the current node back one
    sw      $t5,0($t0)              # store new pointer into the node
    jr      $ra

front:
    sw      $t5,0($s0)              # make global reference to front of the node the new node if its at the front

close:
    jr      $ra
                          ##


  ## Gives the length of a linked list.
  #
  # @param $a0 The list.
  #
  # @return The length of the list.
  #
  ######################################
.globl length                        #
length:
	#SAVE RETURN ADRRES AND CURRENT ARRAY ON THE STACK                              #
   	addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $a0,4($sp)
    #INITIALIZE COUNTER
	li $t2,0
    beq     $s0,$zero,length_done

length_loop:
	#TRY TO LOAD FIRST ELEMENTS DATA FROM LIST
    li  $t0,0($a0)
    #IF THERE IS NOTHING RETURN
    beqz $t0, length_done
    #TRY TO LOAD POINTER TO NEXT ELE IN LIST
   	la  $t1,4($a0)
   	#IF THERE IS NO POINTER TO THE NEXT ELEMENT
   	beqz $t1, length_done
   	#OTHERWISE ADD 8 TO POINTER OF LIST (4 byte for int element, 4 for next pointer)
   	addi $a0,$a0,8
    j length_loop
length_done:
	#LOAD RA AND LIST BACK FROM STACK
    lw      $a0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8
    or   $v0, $0, $t2
    jr      $ra


  ## Drops the first x elements from the list
  #
  # @param $a0 The list.
  # @param $a1 The number of elements to drop.
  #
  ######################################
  drop:  
  beqz	$s7, start	#if list is empty, go to menu
	
	lw	$t2, -4($a3)	#load address of previous node
	beqz	$t2, delHead	#if no previous node, this is a head node
	
	lw	$t3, 12($a3)	#load address of next node
	beqz	$t3, delTail	#if no previous node, this is a tail node
	
	lw	$t3, 12($a3)	#load address of next node
	sw	$t2, -4($t3)	#store address of previous node in next node's previous field
	
	lw	$t2, 12($a3)	# load address of next node
	lw	$t3, -4($a3)	# load address of previous node 
	sw	$t2, 12($t3)	#store address of next node in previous node's next field
	
	la	$a3, ($t2)	#the new curr is the next node
	
doneDel:			
	jr	$ra

delHead:
	lw	$t2, 12($a3)
	sw	$zero, -4($t2)
	la	$s7, ($t2)
	la	$a3, ($t2)
	j	doneDel
	
delTail:
	lw	$t2, -4($a3)
	sw	$zero, 12($t2)
	la	$a3, ($t2)
	j	doneDel
  jr $ra                              ##


  ## Inserts an element into a given list at a given index (other
  # than the head).
  #
  #   This function cannot replace the head of the list, i.e. it
  # does not consider 0 a valid index.
  #
  # @param ($a0 : Node) The list to insert into.
  # @param ($a1 : Node) The node to insert.
  # @param ($a2 : num+) The index at which to insert.
  #
  ######################################
  .globl insert                        #
  insert:   
  	beqz $a2, invalid_index
  	bltz $a2, invalid_index
  	
                                       #
  jr $ra                              ##
	

  ## Reverses a list (destructively!)
  #
  # @param $a0 The list.
  #
  # @return the pointer to the first (formerly last) element.
  #
  ######################################
  reverse: 

  jr $ra                              ##
#INCREMENTS LINKED LIST BY 8 BYTES (One node)
nextNode:
	la	$t8, 8($a0)
	lw	$a0, ($t8)
	j	start
	
#DECREMENTS LINKED LIST BY 8 BYTES (One node)
prevNode:
	la	$t8, -8($a0)
	lw	$a0, ($t8)
	jr	$ra

  #------------------ DON'T MODIFY BELOW ---------------------------

  ## Entry point.
  #
  ######################################
  .globl main                          #
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
                                       #
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
  ######################################
  .globl print_list                    #
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
