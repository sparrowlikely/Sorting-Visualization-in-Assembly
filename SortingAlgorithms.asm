# Omar Cecenas
#
# This program sorts a randomized array of the numbers 1-100 using one of
# the following algorithms: insertion, selection, bubble, quick, and heap sort, depending on user choice.
# It displays the sorting using the bitmap display tool in mars. The numbers are represented by scaled rectangles.
# The bitmap display tool must be opened and connected to mips before running the program.

.data
frameBuffer:	.space 0x80000

arr:		.word 96,91,73,54,19,43,87,72,49,58,52,84,93,62,56,98,24,79,21,90,2,83,75,23,7,61,97,85,59,4,33,64,94,8,37,45,86,20,81
		      ,89,27,31,29,99,13,15,28,82,32,9,17,41,6,95,38,14,40,26,35,100,70,60,66,69,76,74,22,88,36,80,11,53,16,12,30,5
		      ,42,92,65,47,44,3,39,51,48,18,55,50,67,68,1,25,10,46,77,63,34,71,78,57
arrLength:	.word 100
    
singleSpace: 	.asciiz " " 
newLine: 	.asciiz "\n"
promptChoice:	.asciiz "Choose sorting method: \n 1 Insertion Sort \n 2 Selection Sort \n 3 Bubble Sort \n 4 Quick Sort \n 5 Heap Sort"
		

.text


li $s2, 250
lw $s3, arrLength
la $s4, arr
li $t1, 1
li $t2, 2
li $t3, 3
li $t4, 4
li $t5, 5


#### getting input from user  ####
li $v0, 51
la $a0, promptChoice
syscall

bne $t1, $a0, second	# checking if this is the user's choice, else go to second option
li $s1, 0xFF0000	# color is red for unsorted array
jal drawArray		# always draw initial array

la $s0, arr
add $s0, $s0, 4  
jal insertionSort
j exit

second: # selection sort
bne $t2, $a0, third
li $s1, 0xFF0000	
jal drawArray	

la $a1, arr
jal selectionSort
j exit

third: # bubble sort
bne $t3, $a0, fourth
li $s1, 0xFF0000
jal drawArray

la $a1, arr
jal bubbleSort
j exit


fourth: # quick sort
bne $t4, $a0, fifth
li $s1, 0xFF0000
jal drawArray

la $a1, arr
li $a2, 0
li $a3, 99
jal quickSort
j exit

fifth: # heap sort
bne $t5, $a0, exit
li $s1, 0xFF0000
jal drawArray

la $a1, arr
li $a2, 100
jal heapSort
j exit


exit:	#done
li $v0,10
syscall


############################### Inserion Sort ######################################
####################################################################################
insertionSort:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	li $t4, 1	# outer for loop i count

loop:	#outer for loop
	bge $t4, $s3, insertionExit # for i < length
	
	subi $t5, $t4, 1	# the inner while loop count j = i - 1
	subi $t1, $s0, 4	# address of element j starts at i address -4 ( element at i - 1)
	lw $t7, ($s0) 		# arr[i] loaded

innerLoop:
	blt $t5, $zero, innerExit # while j >= 0
	lw $t6, ($t1) # arr[j] loaded, it will be changing so we load it each time
		      # arr[i] stays the same as its the one moving through the array
		      
	bge $t7, $t6, else # while arr[i] < arr[j] swap them, else j--
	sw $t7, ($t1)  # arr[j] = arr[j+1] 
	sw $t6, 4($t1) # arr[j+1] = arr[j] 
	
	################### Redrawing swapped elements ########################
	### erasing old elements ##
	li $s1, 1
	mul $a0, $t5, 5 # distance from left, j * 5
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	li $s1, 1 # color of rectangle now black
	mul $a0, $t5, 5 # distance from left(position), j * 5
	add $a0, $a0, 5 # one more 5 since want (j+1) * 5
	add $a0, $a0, 6 # formatting nudge to the right, final value of distance from left(position) argument
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	## drawing elements after swap ##
	li $s1, 0x00FF00 # color of rectangle now green
	mul $a0, $t5, 5 # distance from left, j * 5
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $t7  # height, arr[j+1] (new value)
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	
	li $s1, 0x00FF00 # color of rectangle now green
	mul $a0, $t5, 5 # distance form left, (j+1) * 5 
	add $a0, $a0, 5
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $t6  # height, arr[j] (new value)
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	
	
else:
	subi $t5, $t5, 1 # j--
	subi $t1, $t1, 4 # address of next arr[j]
	
	j innerLoop
	
innerExit:
	addi $t4,$t4, 1	 # i++
	addi $s0, $s0, 4 # address of next arr[i]
	
	j loop
	
insertionExit:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	
	jr $ra	
	
############################# Selection Sort  #######################################
#####################################################################################
selectionSort:
	addi $sp, $sp, -8
	sw $ra, ($sp)

	
	li $t4, 0 # loop count i = 0, acts as array index for smallest value to swap into

selectloop:
	lw $t7, ($a1) # arr[i] loaded, starts at beginning of array, holds position for next smallest

	bge $t4, $s3, 	selectionExit # while i < array length
	move $t6, $t7	 # current smallest = arr[i]

	addi $t5, $t4, 1 # j count = i+1
	addi $t1, $a1, 4 # arr[j] address = address of arr[i+1]

innerloop:
	bge $t5, $s3, innerexit # for j < array length
	lw $t8, ($t1) # arr[j] loaded, searching for smallest value currently in array

	bge $t8, $t6, else2 # if arr[j] < smallest
	move $t6, $t8 # new smallest = arr[j]
	move $t9, $t1 # address of new smallest (to swap at end of inner loop)

else2:
	addi $t5, $t5, 1 # j++
	addi $t1, $t1, 4 # address of next arr[j] 
	j innerloop

innerexit:
	sw $t6, ($a1)	# arr[i] =  arr[new smallest] 
	sw $t7, ($t9)	# arr[new smallest] = arr[i]
	
	sw $a1, 4($sp)
	################### Redrawing swapped elements ########################
	### erasing old elements ##
	li $s1, 1
	mul $a0, $t4, 5 # distance from left, j * 5
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	li $s1, 1 # color of rectangle now black
	mul $a0, $t5, 5 # distance from left(position), j * 5
	add $a0, $a0, 6 # formatting nudge to the right, final value of distance from left(position) argument
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	## drawing elements after swap #
	li $s1, 0x00FF00 # color of rectangle now white
	mul $a0, $t4, 5 # distance from left, j * 5
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $t6  # height
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	
	li $s1, 0x00FF00 # color of rectangle now white
	mul $a0, $t5, 5 # distance form left, (j+1) * 5 
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $t7  # height
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	
	
	lw $a1, 4($sp) # returning old argument value
	addi $t4, $t4, 1 # i++
	addi $a1, $a1, 4 # address of next arr[i]

	j selectloop

selectionExit:
	
	# erasing leftover rectangle
	li $s1, 1
	li $a0, 501 # distance from left, want last space
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	lw $ra, ($sp)
	addi $sp, $sp, 8
	jr $ra
	

################ Now Bubble Sort ###################
bubbleSort:
	addi $sp, $sp, -8
	sw $ra, ($sp)
	sw $a1, 4($sp)

	li $t4, 0 # count i = 0
	move $t1, $s3
	subi $t1, $t1, 1 # array length shortened by one, don't need to loop for every element


bubbleloop:
	bge $t4, $t1, bubbleExit # for i < array length - 1
	li $t5, 0 # count j = 0
	move $t2, $a1 # address of arr[j] loaded, starts from beginning of array each outer loop pass
	addi $t6, $t2, 4 # address of arr[j+1]


bubbleInner:
	bge $t5, $t1 bubbleInnerExit # for j < array length - 1
	lw $t7, ($t2) # arr[j]
	lw $t8, ($t6) # arr[j+1]
	
	ble $t7, $t8, else3 # if arr[j] > arr[j+1], swap
	sw $t8, ($t2) # arr[j] = arr[j+1]  , index is j count
	sw $t7, ($t6) # arr[j+1] = arr[j]  , index is j count + 1
	
	
	################### Redrawing swapped elements ########################
	### erasing old elements #
	li $s1, 1
	mul $a0, $t5, 5 # distance from left, j * 5
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	li $s1, 1 # color of rectangle now black
	mul $a0, $t5, 5 # distance from left(position), (j +1)* 5
	add $a0, $a0, 5 
	add $a0, $a0, 6 # formatting nudge to the right, final value of distance from left(position) argument
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	## drawing elements after swap #
	li $s1, 0x00FF00 # color of rectangle now white
	mul $a0, $t5, 5 # distance from left, j * 5
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $t8  # height
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	
	li $s1, 0x00FF00 # color of rectangle now white
	mul $a0, $t5, 5 # distance form left, (j+1) * 5 
	add $a0, $a0, 5
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $t7  # height
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	
	lw $a1, 4($sp) # returning old argument value

else3:
	addi $t5, $t5, 1 # j++
	addi $t2, $t2, 4 # address of next arr[j]
	addi $t6, $t6, 4 # address of next arr[j+1]

	j bubbleInner

bubbleInnerExit:
	addi $t4, $t4, 1 # i++

	j bubbleloop

bubbleExit:
	lw $ra, ($sp)
	addi $sp, $sp, 8

	jr $ra

############################## Quick Sort #####################################
###############################################################################
quickSort:
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $a3, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	
	
	bge $a2, $a3, quickExit #if low index < high index do below, else stop recursion
	jal partition # returns Partition Index to $v0, ( PI now sorted)
	
	addi $t1, $v1, -1 # new High index for left quicksort
	addi $t2, $v1, 1  # new Low index for right quicksort
        sw $t2, 16($sp) # using this t2 value stops it from going again to the right side somehow,  fixed sp size along with this line and it worked
        
        lw $a1, 8($sp) ######
        lw $a2, 12($sp) #####
	move $a3, $t1	# load new high index argument
	jal quickSort  # left quicksort, new High index only
	
	lw $t2, 16($sp)
	lw $a1, 8($sp) ######
	move $a2, $t2 # new low index
	lw $a3, 4($sp) # need old High index since line 208 changed it for left quicksort
	jal quickSort # right quicksort, new Low index only


quickExit:
	lw $ra, ($sp)
	addi $sp, $sp, 20
	
	jr $ra

################# Partition function for Quick Sort #####################
partition:
	addi $sp, $sp, -40 # these values are changed when calling other function, need to save on stack to restore after call
	sw $ra, ($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $a1, 24($sp)
	sw $a2, 28($sp)
	sw $a3, 32($sp)
	
	mul $t6, $a3, 4
	add $t6, $a1, $t6 	# t6 = high address
	lw $t1, ($t6)		# pivot = high element

	addi $t2, $a2, -1 # i = low - 1 = current smaller index
	move $t3, $a2	# j = low index

partitionLoop:
	bge $t3, $a3, partitionExit	# for j < High do below
	mul $t7, $t3, 4
	add $t7, $a1, $t7  
	lw $t4, ($t7)	# $t4 = arr[j]

	bgt $t4, $t1, else4	# if arr[j] <= pivot do below
	addi $t2, $t2, 1	# i++
	mul $t8, $t2, 4
	add $t8, $a1, $t8	
	lw $t5, ($t8)		# $t5 = current i element
	sw $t4, ($t8)		# arr[i] = arr[j]  , index for t8 is t2
	sw $t5, ($t7)		# arr[j] = arr[i]  , index for t7 is t3
	
	### erasing old elements #
	mul $a0, $t2, 5 # distance from left, j * 5
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	li $s1, 1
	jal rectangle
	
	li $s1, 1 # color of rectangle now black
	lw $a3, 16($sp) ##### loading correct a3 argument
	mul $a0, $t3, 5 # distance from left(position), j * 5
	add $a0, $a0, 6 # formatting nudge to the right, final value of distance from left(position) argument
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	## drawing elements after swap #
	mul $a0, $t2, 5 # distance from left, 
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $t4  # height, 
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	li $s1, 0x00FF00 # color of rectangle now white
	jal rectangle
	
	li $s1, 0x00FF00 # color of rectangle now white
	mul $a0, $t3, 5 # distance form left, 
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $t5  # height, 
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	
	lw $a1, 24($sp) # loading original arguments of partition function
	lw $a2, 28($sp)
	lw $a3, 32($sp)
	
	
	

else4:
	addi $t3, $t3, 1	# j++
	j partitionLoop

partitionExit:	
	addi $s1, $t2, 1 # s1 = i + 1 INDEX ( returned from partition to quick sort in v0)
	move $v1, $s1	# return value i+1 now in v1
		
	mul $t9, $s1, 4
	add $t9, $a1, $t9
	lw $t0, ($t9)	# t0 = arr[i + 1] 


# swapping pivot into correct position in array
	sw $t1, ($t9)	# arr[i+1] = arr[high]  , 
	sw $t0, ($t6)	# arr[high] = arr[i+1]
	
# storing registers that will be changed when setting up arguments for rectangle, cannot save inside rectangle as values already changed	
	sw $s1, 12($sp)
	sw $a3, 16($sp)
	sw $t0, 20($sp)
	sw $t1, 36($sp)
	### erasing old elements ##
	mul $a0, $s1, 5 # distance from left, j * 5
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	li $s1, 1
	jal rectangle
	
	li $s1, 1 # color of rectangle now black
	lw $a3, 16($sp) ##### loading correct a3 argument
	mul $a0, $a3, 5 # distance from left(position), j * 5
	add $a0, $a0, 6 # formatting nudge to the right, final value of distance from left(position) argument
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	## drawing elements after swap ##
	lw $s1, 12($sp) ###### loading correct s1 argument
	mul $a0, $s1, 5 # distance from left, 
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	lw $t1, 36($sp) 
	move $a3, $t1  # height, equal to old arr[i+1]
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	li $s1, 0x00FF00 # color of rectangle now white
	jal rectangle
	
	li $s1, 0x00FF00 # color of rectangle now white
	lw $a3, 16($sp) #### corect a3 argument
	mul $a0, $a3, 5 # distance form left, 
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	lw $t0, 20($sp) ### corect t0 argument  fixed an error, new one at 237
	move $a3, $t0  # height, euqal to old arr[high]
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	

	#lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $ra, ($sp)
	lw $a1, 24($sp)
	lw $a2, 28($sp)
	lw $a3, 32($sp)
	#lw $t1, 36($sp)
	addi $sp, $sp, 40
	jr $ra

	
####################### Heap Sort ##########################################
############################################################################	
heapSort:
	addi $sp, $sp, -32
	sw $ra, ($sp)
	sw $t3, 12($sp)
	sw $a1, 20($sp)
	sw $a3, 24($sp)
	sw $s1, 28($sp)
	
	div $t1, $a2, 2  # count i for first for loop initialized to (length / 2) 
	sub $t1, $t1, 1  # i--
	
loop1:	# builds first heap
	bltz $t1, loop1Exit
	sw $t1, 4($sp)  # this register will be changed in heapify, store on stack now
	move $a3, $t1	# third argument is i count
	jal heapify 
	
	lw $t1, 4($sp)  # recover old register value before heapify
	sub $t1, $t1, 1 # i--
	j loop1
	
loop1Exit:

	sub $t2, $a2, 1 # i count for 2nd for loop initialized to length - 1

loop2:	# extract one element from heap at a time (sorts in descending order from end of array to start)
	mul $t4, $t2, 4
	add $t4, $a1, $t4
	lw $t5, ($t4)	# t5 = arr[i]
	

	bltz $t2, heapSortExit # heapify array while extracting root to sorted end of array
	lw $t3, ($a1)
	sw $t5, ($a1) # arr[0] = arr[i]
	sw $t3, ($t4) # arr[i] = arr[0]
	
	
	##### erasing old elements ########
	li $s1, 1 # color black to erase
	li $a0, 6  # arr[0] positoin on display is always first, formatted 6 pixels to the right
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	li $s1, 1 # color of rectangle now black
	mul $a0, $t2, 4  # distance form left, i * 5
	add $a0, $a0, 6  # formatted 6 pixels to the right
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	#### drawing elements after swap #######
	li $s1, 0x00FF00 # color of rectangle now white
	li $a0, 6  # arr[0] always first on display
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $t5  # height, arr[0] (new value)
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	
	mul $a0, $t2, 5 # distance form left, (j+1) * 5 
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $t3  # height, arr[i] (new value)
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	
	lw $t5, 16($sp) # original value of t5 also needed
	lw $a1, 20($sp) # restoring argument 1 for heapify
	lw $a3, 24($sp) # restoring argument 2 for heapify
	
	lw $s1, 28($sp)
	sw $t2, 8($sp)
	move $a2, $t2 # second argument (array length) is now set to current i count
	li $a3, 0
	jal heapify
	
	lw $t2, 8($sp)
	sub $t2, $t2, 1 # i--
	j loop2
heapSortExit: 
	lw $ra, ($sp)
	lw $t3, 12($sp)
	lw $a1, 20($sp)
	lw $a3, 24($sp)
	addi $sp, $sp, 32
	
	jr $ra
	

#################### Heapify function for Heap Sort #############################
heapify:
	addi $sp, $sp -36 # storing registers that are changed in other functions
	sw $ra, ($sp)
	sw $a3, 4($sp)
	sw $s2, 8($sp) # 
	sw $s3, 12($sp)
	sw $s4, 16($sp) # 
	sw $a1, 20($sp)
	sw $a2, 24($sp)
	sw $t3, 28($sp)
	
	
	move $t5, $a3	# t5 is index of largest, now equal to root by default
	sll $t6, $a3, 1	# t6 is index of left child
	add $t6, $t6, 1 # t6 is index of left child, now 2 * root + 1
	sll $t7, $a3, 1 # t7 is index of right child
	add $t7, $t7, 2 # t7 is index of right child, now 2 * root + 2
	
	
	mul $t9, $t5, 4
	add $t9, $t9, $a1  # t9 is now address of arr[largest]
	mul $s6, $t6, 4
	add $s6, $s6, $a1  # s6 is now address of arr[left child]
	mul $s7, $t7, 4
	add $s7, $s7, $a1  # s7 is now addres of arr[right child]
	mul $t8, $a3, 4
	add $t8, $t8, $a1  # t8 is now address of arr[root]
	
	
	lw $s1, ($t9)	# s1 = arr[largest]
	lw $s2, ($s6)	# s2 = arr[left child]
	bge $t6, $a2, else5	# if l < array length , do below
	ble $s2, $s1, else5	# if arr[left child] > arr[largest] , do below
	move $t5, $t6	# new largest index = left child index
	
	mul $t9, $t5, 4    # calculating address 
	add $t9, $t9, $a1  # t9 is now address of new arr[largest]
	lw $s1, ($t9)	   # s1 = arr[largest]
	
else5:
	lw $s3, ($s7)  # s3 = arr[right child]
	bge $t7, $a2, else6	# if r < array length (within array bounds), do below
	ble $s3, $s1, else6	# if r < array length and arr[right child] > arr[largest] , do below
	move $t5, $t7	# new largest index = right child index
	
	mul $t9, $t5, 4    # calculating address
	add $t9, $t9, $a1  # t9 is now address of new arr[largest]
	lw $s1, ($t9)	   # s1 = arr[largest]
	
	
else6:
	lw $s4, ($t8)  # s4 = arr[root]
	beq $t5, $a3, heapifyExit  # if largestindex != root index , do below
	sw $s1, ($t8) # arr[root] = arr[largest]
	sw $s4, ($t9) # arr[largest] = arr[root]
	
	sw $s1, 32($sp)
	##### erasing old elements ########
	li $s1, 1
	mul $a0, $a3, 5  # arr[root] index positoin on display, distance from left
	add $a0, $a0, 6  # , formatted 6 pixels to the right
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	li $s1, 1
	mul $a0, $t5, 4  # distance form left, i * 5
	add $a0, $a0, 6  # formatted 6 pixels to the right
	li $a1,5   # width, stays same, 100 numbers
	li $a2, 0 # distance from top, want to start at top to erase entire column
	li $a3, 256  # height, entire column
	jal rectangle
	
	lw $a3, 4($sp) # restoring original arr[root] index argument
	#### drawing elements after swap #######
	mul $a0, $a3, 5  # arr[root] index * 5
	add $a0, $a0, 6  # formatted 6 pixels to right
	li $a1,5   # width, stays same, 100 numbers
	lw $s1, 32($sp) # restoring height of new arr[root]
	move $a3, $s1  # height, arr[root] (new value)
	mul $a3, $a3, 2 # height scaled for display
	lw $s2, 8($sp)
	sub $a2, $s2, $a3 # distance from top, 250 - height
	li $s1, 0x00FF00  ## s1 was changed, returning for rectangle color
	jal rectangle
	
	li $s1, 0x00FF00 # color of rectangle now white
	mul $a0, $t5, 5 # distance form left, arr[largest] index * 5 
	add $a0, $a0, 6 # formatting nudge to the right
	li $a1,5   # width, stays same, 100 numbers
	move $a3, $s4  # height, arr[largest] (new value)
	mul $a3, $a3, 2 # height scaled for display
	sub $a2, $s2, $a3 # distance from top, 250 - height
	jal rectangle
	
	lw $a1, 20($sp)
	lw $a2, 24($sp)
	move $a3, $t5 # new third argument is now new largest index
	jal heapify
	

heapifyExit:	
	lw $ra, ($sp)
	lw $a3, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $a1, 20($sp)
	lw $a2, 24($sp)
	lw $t3, 28($sp)
	addi $sp, $sp, 36
	
	jr $ra

####################### Function to draw entire array before sorting begins #####################
#################################################################################################	
drawArray:
addi $sp, $sp, -24
sw $ra, ($sp)
sw $t1, 4($sp)
sw $t4, 8($sp)
sw $t5, 12($sp)
sw $t6, 16($sp)
sw $t7, 20($sp)

# now do this in a loop for the array
li $s5, 0 # count i =0
li $t7, 6 # keeps track of distance from left, add 5 for every new rectangle
drawloop:
bge $s5,$s3, drawExit # for i < arrlength
mul $t5, $s5, 4   # address off set
add $t5, $t5, $s4 # add address off set to base address to get address of arr[i]
lw $t6, ($t5) # arr[i] loaded
mul $t6, $t6, 2 # actual height of rectangle scaled for demonstration

move $a0, $t7  # distance from left, 100 rectangles width 5, add 5 each loop pass
li $a1,5   # width, stays same, 100 numbers
sub $a2, $s2, $t6 # distance from top, want all rectangles to end at 250 ,this argument should change to 250-height ex(for 50, dft = 200)
move $a3, $t6  # height, elments of array
jal rectangle

add $s5, $s5, 1 # i++
add $t7, $t7, 5

j drawloop

drawExit:
lw $ra, ($sp)
lw $t1, 4($sp)
lw $t4, 8($sp)
lw $t5, 12($sp)
lw $t6, 16($sp)
lw $t7, 20($sp)
addi $sp, $sp, 24

jr $ra

######################## Function that draws a single rectangle ##########################
##########################################################################################
rectangle:
# $a0 is xmin (i.e., left edge; must be within the display)
# $a1 is width (must be nonnegative and within the display)
# $a2 is ymin  (i.e., top edge, increasing down; must be within the display)
# $a3 is height (must be nonnegative and within the display)

addi $sp, $sp, -20
sw $ra, ($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)
sw $t3, 12($sp)
sw $t4, 16($sp)



beq $a1,$zero,rectangleReturn # zero width: draw nothing
beq $a3,$zero,rectangleReturn # zero height: draw nothing

move $t0, $s1 # color: green or red, depending on if displaying for the first time(red) or swapping(green)
la $t1,frameBuffer
add $a1,$a1,$a0 # simplify loop tests by switching to first too-far value
add $a3,$a3,$a2
sll $a0,$a0,2 # scale x values to bytes (4 bytes per pixel)
sll $a1,$a1,2
sll $a2,$a2,11 # scale y values to bytes (512*4 bytes per display row)
sll $a3,$a3,11
addu $t2,$a2,$t1 # translate y values to display row starting addresses
addu $a3,$a3,$t1
addu $a2,$t2,$a0 # translate y values to rectangle row starting addresses
addu $a3,$a3,$a0
addu $t2,$t2,$a1 # and compute the ending address for first rectangle row
li $t4,0x800 # bytes per display row

rectangleYloop:
move $t3,$a2 # pointer to current pixel for X loop; start at left edge

rectangleXloop:
sw $t0,($t3)
addiu $t3,$t3,4
bne $t3,$t2,rectangleXloop # keep going if within the right edge of the rectangle

addu $a2,$a2,$t4 # advace one row worth for the left edge
addu $t2,$t2,$t4 # and right edge pointers
bne $a2,$a3,rectangleYloop # keep going if within bottom limit of the rectangle

rectangleReturn:
lw $ra, ($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $t4, 16($sp)
addi $sp, $sp, 20
jr $ra
