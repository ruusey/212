# HW4a Driver
# 2018 Daniel Pade
# All of your functions should be placed within the comments below.

.data
  # You may use 'test_lst' to test your functions. Once you succeed in
  # implementing 'enum', generate your tests from that function.
  .eqv    data_offset		0
  .eqv    next_offset   4
  .eqv    node_size     8
           
 
  #HELPERS FOR ACCESSING REGISTERS
	.eqv    temp0       		$t0
	.eqv    temp1       		$t1
	.eqv    temp2       		$t2
	.eqv    temp3       		$t3
	.eqv    temp4       		$t4
	.eqv    temp5       		$t5
	.eqv    arg0       		  $a0
	.eqv    arg1       		  $a1
	.eqv    arg2       		  $a2
	.eqv    arg3       		  $a3
	.eqv    rval0       		$v0
	.eqv    rval1       		$v1
	.eqv    stack       		$sp
	.eqv    retaddr       	$ra
	
.text
  j main

  #------------------ PUT YOUR CODE HERE ---------------------------

  ## Creates a list from start to end with given step.
  #
  # E.g enum(1,10,4) = [1,5,9]
  #
  # @param ($a0 : int) The number to start with
  # @param ($a1 : int) The largest allowed number in the list.
  # @param ($a2 : int) The step size
  #
  ########################################
  .globl enum                            #
  enum:   
  
  	addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    jal 	  savestate
    #SAVE OUR START VALUE SO WE CAN USE a0 FOR FUNC CALLS
    move    temp0, arg0
    #STORE RANGE INTO t0 (10-1 = 9)
    sub     temp1, arg1, temp0
    #DIVIDE THE RANGE BY THE STEP AMOUNT (9/4 = 2r1)
    div     temp1, arg2
    #LOAD QUOTIENT FROM LO
    mflo    temp1
    #CREATE A START NODE WITH START VALUE
    move    arg0, temp0
    jal     Node_num
    move    temp4, rval0
    move    temp2, rval0
    
    add     temp0, temp0, arg2
    li      temp3, 1
	enum.next:
		#GET THE NEXT STEP VALUE TO PUT IN NEXT NODE
		move    arg0, temp0
		# CREATE THE NEW NODE
		jal     Node_num
		#SAVE NEW NODES ADRESS IN PREVIOUS NODES NEXT FIELD
		sw      rval0, next_offset(temp2)
		#SET THE NEW NODE TO CURRENT, CONTINUE
		move    temp2, rval0
		
	enum.increment:
		#IF WEVE ADDED ALL THE ELEMENTS
		beq     temp3, temp1, enum.exit
		addi    temp3, temp3, 1
		#ELSE INCREMENT AND CALCULATE NEXT STEP
		add     temp0, temp0, arg2
    j 		 enum.next  
  enum.exit:
    move    rval0, temp4   
    j       returnstate                           
 
  ## Applies a function pointwise to a list.
  #
  # E.g map(plus_one, [1,2,3]) = [2,3,4]
  #
  # @param ($a0 : ptr)  The memory address of the function to use
  #                     This function must take ONE argument
  # @param ($a1 : Node) The list to map over.
  #
  #######################################
  .globl map                            #
  map:
  	addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    jal 	  savestate
    move    temp4, arg1
    j       map.next
  map.next:
  	#SAVE THE ADRESS OF FUNCTION TO MAP
  	move    temp0, arg0
  	move    temp3, arg1
  	#LOAD THE VALUE OF THE FIRST NODE
  	lw 	    arg0, data_offset(arg1)
  	la      $ra, map.save
  	jr      temp0
  
  map.save:
  	#SAVE THE VALUE RETURNED FROM THE NESTED ARITHMETIC
  	sw      rval0, data_offset(arg1)
  	#LOAD THE ADRESS OF THE NEXT NODE
  	lw      temp1, next_offset(arg1)
  	move    arg0, temp0
  	move    arg1, temp1
  	#IF THERE ARE MORE NODES KEEP GOING
  	bnez    arg1, map.next
  
  map.exit:
  	move    rval0, temp4
    j       returnstate                                
  
  ## Folds a list over a given function
  #
  # e.g. foldl(plus, 0, [1,2,3]) = (((0 + 1) + 2) + 3)
  #
  # @param ($a0 : ptr)  The memory address of the function to use.
  #                     This function must take TWO arguments
  # @param ($a1 : int)  The initial value.
  # @param ($a2 : Node) The list to fold.
  #
  #######################################
  .globl foldl                          #
  foldl: 
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    jal 	  savestate
    #SAVE STATIC VALUES (start of list and initial fold value
    or      temp5, $0, arg2 
    or      temp0, $0, arg0
    or      temp1, $0, arg1
    #COUNTER FOR RESULT
    li 		  temp2, 0          
  foldl.next:
  	#SAVE THE ADRESS OF FUNCTION TO MAP
  	lw      arg1, data_offset(arg2)
  	#LOAD THE VALUE OF THE FIRST NODE
  	or      arg0, $0, temp1
  	la 			$ra, foldl.apply
  	jr 			temp0                              ##
	foldl.apply:
		add 		temp2, temp2, rval0
    lw  		arg2, next_offset(arg2)
    bnez  	arg2, foldl.next     
	foldl.exit:
		move 		rval0, temp2
		j 			returnstate
  ## Calculates a summation.
  #
  # Given a start, end, step, and function, calculates the following:
  #
  #     end
  #      Σ  f(i * step)
  #     i=start
  #
  # e.g. sum(1, 10, 2, square) = 165
  #
  # @param ($a0 : int)  start
  # @param ($a1 : int)  stop
  # @param ($a2 : int)  step
  # @param ($a3 : fn)   The inner function
  #
  # @return The value of the above sum
  #
  #######################################
  .globl sum                            #
  sum: 
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    jal 	  savestate
    # CREATE AN ARRAY WITH SPECIFIED LIMITS
    jal 		enum
    or 			arg0, $0, arg3
    or 			arg1, $0, rval0
    #MAP THE LIST WITH GIVEN FUNCTION
    jal 		map
    la  		$a0, plus                       
    or  		$a1, $0, $0                       
    or  		$a2, $0, rval0    
    #FOLD THE LIST USING PLUS (total of the new mapped list of squares)                  
    jal 		foldl                                                        
  sum.exit:
  	j 			returnstate
                                                                               ##
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
 