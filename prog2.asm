; First I get an input and echo it out. Next I check to see if it is an equal sign, then if it is any of the operators (+,-,*,/), then I check to see if it 
; is a number and lastly I check to see if it is a space. These are all of the inputs that the calculator for this MP recognizes. If it doesn't pass any of
; theses checks then we print an invalid expression as it is an input the calculator does not recognize
; Next if it is a number I push the number and go back to get the next input, if it is a space I dont push anything and go straight to the next input.       
; If it is a operator I go to the operator subroutine and pop 2 values from the stack and check if they are valid values. Then I preform the operation and
; push back into the stack for further use. I only print the result when the equal sign is called.
; In the subroutines I have R1 be the temp storage of the R7 value and I rsetore it at the end of the subroutine


.ORIG x3000
		
	AND R1,R1,0 ; INIT R1 --- TEMP STORAGE FOR R7 in Subroutines
	AND R4,R4,0 ; INIT R4
	AND R2,R2,0 ; INIT R2

NEXT_INP    
	GETC		; Gets Character  
    OUT			; Prints Character that was typed for user to see


EQUAL_CHECK
	LD R6, EQU      ; Loads "=" Ascii value into R6
	NOT R6,R6       ; 
	ADD R6,R6,1     ; -"=" Ascii value
	ADD R6, R0, R6  ; R6 stores "keyboard character Ascii value" - "Equal Ascii value" 
	BRz PRINT_HEX	; Branch to EQUAL where we will see if we can a pop a value and then checks if stack_top = stack_start


ADD_CHECK
	LD R6, P_SYMBOL 	; Loads "+" Ascii value into R6
	NOT R6,R6       	; 
	ADD R6,R6, 1    	; -"+" Ascii value
	ADD R6, R0, R6  	; R6 stores "keyboard character Ascii value" - "Add Ascii value" 
	BRnp SUBTRACT_CHECK	; Branch to Subtract if not Add
	JSR PLUS        	; Jumps to PLUS subroutine
	BR NEXT_INP			; Go to Next Input

SUBTRACT_CHECK
	LD R6, MINUS 	 	; Loads "-" Ascii value into R6
	NOT R6,R6        	; 
	ADD R6,R6,1     	; -"-" Ascii value
	ADD R6, R0, R6   	; R6 stores "keyboard character Ascii value" - "Subtract Ascii value" 
	BRnp DIVIDE_CHECK	; Branch to Divide if not subtract
	JSR MIN          	; Jumps to MIN subroutine
	BR NEXT_INP			; Go to Next Input

DIVIDE_CHECK
	LD R6, DIVISION 	; Loads "/" Ascii value into R6
	NOT R6,R6       	; 
	ADD R6,R6,1     	; -"/" Ascii value
	ADD R6, R0, R6  	; R6 stores "keyboard character Ascii value" - "Divide Ascii value" 
	BRnp MULTIPLY_CHECK	; Branch to Multiply if not Divide
	JSR DIV         	; Jumps to DIV subroutine
	BR NEXT_INP			; Go to Next Input


MULTIPLY_CHECK
	LD R6, MULTIPLY 	; Loads "*" Ascii value into R6
	NOT R6,R6       	; 
	ADD R6,R6,1     	; -"*" Ascii value
	ADD R6, R0, R6  	; R6 stores "keyboard character Ascii value" - "Multiply Ascii value" 
	BRnp POWER_CHECK	; Branch to Power if not Multiply
	JSR MUL         	; Jumps to MUL subroutine
	BR NEXT_INP			; Go to Next Input

POWER_CHECK
	LD R6, POWER    	; Loads "^" Ascii value into R6
	NOT R6,R6       	; 
	ADD R6,R6,1     	; -"^" Ascii value
	ADD R6, R0, R6  	; R6 stores "keyboard character Ascii value" - "Power Ascii value"
	BRnp NUM_CHECK		; Branch to NUM_CHECK if not Power 
	JSR EXP         	; Jumps to EXP subroutine
	BR NEXT_INP			; Go to Next Input

NUM_CHECK        
	LD R6, NUM_START     ; R6 Init to 0 ascii value
	AND R4, R4, 0		 ; 
	ADD R4, R4, 10		 ; INIT R4 to 10
	AND R3, R3, 0		 ; 
	ADD R3, R3, R0	     ; Modifiable R0 is in R3
	NOT R3, R3			 ; 
	ADD R3, R3, 1		 ; R0 = -R0 now

	NUM_LOOP
		AND R2, R2, 0		 ; R3=0
		ADD R2, R6, R3		 ; R3 = Difference of R4 and input character from R0
		BRz SKIP    		 ; Current input was a number so we need the next input
		ADD R6, R6, 1		 ; Increment R6 to next number		
		ADD R4, R4, -1		 ; Decrement Counter
		BRp NUM_LOOP



SPACE_CHECK
	LD R6, SPACE	  ; Load SPACE ASCII Value to R6
	AND R3, R3, 0	  ; 
	ADD R3, R3, R0	  ; Modifiable R0 is in R3
	NOT R3, R3        ;
	ADD R3, R3, 1     ; R3 = -R3 now
	ADD R3, R6, R3    ; R3 stores difference of input value and SPACE ascii value
	BRz NEXT_INP   	  ; Branch to next input if it is a space
	JSR INVAL		  ; Print invalid statement since the input is not a calculator function


SKIP
	LD R5, NUM_OFFSET ; R5 stores offset of hex ascii value to decimal value
	ADD R0, R0, R5    ; R0 contains decimal value of integer
	JSR PUSH		  ; Push number into stack
	BR NEXT_INP       ; Get the next input


EQU    		  .FILL x003D						; Ascii value of "="
P_SYMBOL      .FILL x002B						; Ascii value of "+"
MINUS         .FILL x002D						; Ascii value of "-"
DIVISION      .FILL x002F						; Ascii value of "/"
MULTIPLY      .FILL x002A					 	; Ascii value of "*"
POWER         .FILL x005E    					; Ascii value of "^"
NUM_START     .FILL x0030						; Ascii value of "0"
SPACE         .FILL x0020					    ; Ascii value of "SPACE"
NUM_OFFSET    .FILL xFFD0					    ; Ascii offset for numbers
ALPHA_START   .FILL x0041						; Character value of A 
INVAL_STATE   .STRINGZ "Invalid Expression"     ; Invalid expression string
ADDRESS_SP	  .FILL x4000						; String space

PRINT_HEX      

	JSR POP
	ADD R5, R5, 0; 
	BRp INVAL
		
	LD R5, STACK_TOP    ; Load stack top
	LD R6, STACK_START  ; Load stack start
	NOT R5, R5			; 
	ADD R5, R5, 1		; Stack top -1 = -(stack_top+1)
	ADD R4, R6, R5		;
	BRnp INVAL			;

; Converting to Hex
		AND R3, R3, 0;		
		ADD R3, R3, R0;		
		AND R2, R2, 0;		R2 holds counter of 4
		AND R4, R4, 0;
		ADD R4, R4, 4;		Counts how many hex values we went through
RESTART	ADD R4, R4, 0;		
		AND R0, R0, 0;
		ADD R2, R2, 4;		R2 = 4 each restart
	
	
B		ADD R3, R3, 0; 		Calls R3
		BRzp SHIFT
		ADD R0, R0, 1;		R0+1
SHIFT	ADD R3, R3, R3;		
		
		ADD R2, R2, -1;		Decrement Counter
		BRp NEXT 

 aa
		ADD R5,R0,-9;
		BRp CHAR_PRINT
		BRnz NUM_PRINT

BACK	ADD R4, R4, -1;
		BRp RESTART
		BRz DONE

CHAR_PRINT
		AND R1, R1, 0;
		LD  R1, ALPHA_START  ; Creates offset to get to hex 41 
		ADD R0, R0, -10;	 Creates offset for which letter to print
		ADD R0, R1, R0; 	
		OUT;				Prints Letter
		BRnzp BACK

NUM_PRINT
		AND R1, R1, 0;
		LD 	R1, NUM_START    ;	Creates offset to get the hex 30 where the numbers start
		ADD R0, R1, R0; 	R0 has the offset of the specific number needed
		OUT;				Prints number
		BRnzp BACK

NEXT	ADD R0, R0, R0;		Shifts R0, holds 4 letter value
		ADD R4, R4, 0;		
		BRz DONE			
		BRnzp B				
DONE 
		HALT;



INVAL						; Code to print Invalid String
	LEA R0, INVAL_STATE     ; Load in Invalid string
	PUTS					; Print Invalid Expression	
	HALT					; Stop program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0

PLUS	
	AND R1, R1, 0  ; INIT R1
	ADD R1, R1, R7 ; TEMP storage of R7
	AND R2, R2, 0  ; 

	JSR POP	       ; Goes to POP
	ADD R5, R5, 0  ;
	BRp INVAL      ; If R5=1 then pop failed ----- Create Failed statement
	ADD R2, R2, R0 ; First pop stored in R2

	JSR POP	       ; Goes to POP
	ADD R5, R5, 0  ;
	BRp INVAL      ; If R5=1 then pop failed ----- Create Failed statement

	PLUS_CONT
		ADD R0, R2, R0 ; R0 stores the sum of the two popped values
		JSR PUSH	   ; Push back into stack

	AND R7,R7,0    ;
	ADD R7, R1, 0  ; Restores R7
RET;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0

MIN	
	AND R1, R1, 0  ; INIT R1
	ADD R1, R1, R7 ; TEMP storage of R7
	AND R2, R2, 0  ;

	JSR POP	       ; Goes to POP
	ADD R5, R5, 0  ;
	BRp INVAL      ; If R5=1 then pop failed ----- Create Failed statement
	ADD R2, R0, 0 ; First pop stored in R2

	JSR POP	       ; Goes to POP
	ADD R5, R5, 0  ;
	BRp INVAL      ; If R5=1 then pop failed and restore first pop ----- Create Failed statement
		

	MIN_CONT
		NOT R2, R2     ; 
		ADD R2, R2, 1  ; R0 = -R0 now
		ADD R0, R2, R0 ; R0 stores the difference of the two popped values

		JSR PUSH	   ; Push back into stack

	AND R7,R7,0    ;
	ADD R7,R1,0  ; Restore R7
RET;

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MUL	
	AND R1, R1, 0  ; INIT R1
	ADD R1, R7, 0  ; TEMP storage of R7
	AND R2, R2, 0  ;
	JSR POP	       ; Goes to POP
	ADD R5, R5, 0  ;
	BRp INVAL    ; If R5=1 then pop failed ----- Create Failed statement
	
	ADD R2, R0, 0  ; First pop stored in R2  (Counter)
	JSR POP	       ; Goes to POP
	ADD R5, R5, 0  ;
	BRp INVAL    ; If R5=1 then pop failed ----- Create Failed statement


	AND R6, R6, 0  ; INIT R6

	M_LOOP
		ADD R6, R6, R0 ; 
		ADD R2, R2, -1 ; Counter --;  
		BRp M_LOOP     ;  

		ADD R0, R6, 0 ; 
		JSR PUSH	   ; Push back into stack

	AND R7,R7,0    ;
	ADD R7, R1, 0  ; Restore R7
RET 		   ;


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
DIV	

	ADD R1, R7, 0 ; TEMP storage of R7
	AND R2, R2, 0 ;
	
	JSR POP	       ; Goes to POP
	ADD R5, R5, 0  ;
	BRp INVAL    ; If R5=1 then pop failed ----- Create Failed statement
	ADD R2, R2, R0 ; First pop stored in R2  (Counter)

	JSR POP	       ; Goes to POP
	ADD R5, R5, 0  ;
	BRp INVAL  ; If R5=1 then pop failed and restore first pop ----- Create Failed statement	


	DIV_CONT
		NOT R2, R2  ;
		ADD R2, R2, 1  ; R0=-R0 now 
		AND R6, R6, 0  ; INIT R6

		D_LOOP		
			ADD R6, R6, 1  ; Counter++;  
			ADD R0, R0, R2 ; Dividend - Divisor until Dividend  < 0;
			BRzp D_LOOP    ;  
		ADD R6, R6, -1 ; Counter adjusted for extra count

		ADD R0, R6, 0 ; 
		JSR PUSH	   ; Push back into stack with R0

	ADD R7, R1, 0  ; Restore R7
RET;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
EXP
	AND R2, R2, 0;
	ADD R1, R1, R7 ; TEMP storage of R7
	JSR POP	       ; Goes to POP
	ADD R5, R5, 0  ;
	BRp INVAL      ; If R5=1 then pop failed ----- Create Failed statement
	ADD R2, R0, -1 ; First pop stored in R4  (Exponent Counter)
	
	AND R5, R5, 0  ; 
	JSR POP	       ; Goes to POP
	ADD R5, R5, 0  ;
	BRp INVAL      ; If R5=1 then pop failed and restore first pop ----- Create Failed statement
	ADD R4, R0, 0  ;

	ADD R2, R2, 0  ;
	BRzp Exp_Loop   ; 
	ADD R5, R5, 1  ;
    BR EXIT        ;	

	Exp_Loop		
		AND R5, R5, 0  ;
		ADD R6, R4, 0  ; (Multiplication Counter)	
		Muexp_LOOP
			ADD R5, R5, R0 ;
			ADD R2, R2, 0  ;
			BRz EXIT	   ;  
			ADD R6, R6, -1 ; Multiplication Counter --  
			BRp Muexp_LOOP ;  
		ADD R0, R5, 0      ;
		ADD R2, R2, -1 ; Exponent Counter --
		BRp Exp_Loop   ;
EXIT
	ADD R0, R5, 0 ; 
	JSR PUSH	   ; Push back into stack

	AND R7,R7,0    ;
	ADD R7, R1, 0  ; Restore R7
RET;

	
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH	
	ST R3, PUSH_SaveR3	;save R3
	ST R4, PUSH_SaveR4	;save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACk_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz OVERFLOW		;stack is full
	STR R0, R4, #0		;no overflow, store value in the stack
	ADD R4, R4, #-1		;move top of the stack
	ST R4, STACK_TOP	;store top of stack pointer
	BRnzp DONE_PUSH		;
OVERFLOW
	ADD R5, R5, #1		;
DONE_PUSH
	LD R3, PUSH_SaveR3	;
	LD R4, PUSH_SaveR4	;
	RET


PUSH_SaveR3	.BLKW #1	;
PUSH_SaveR4	.BLKW #1	;


;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP	
	ST R3, POP_SaveR3	;save R3
	ST R4, POP_SaveR4	;save R3
	AND R5, R5, #0		;clear R5
	LD R3, STACK_START	;
	LD R4, STACK_TOP	;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz UNDERFLOW		;
	ADD R4, R4, #1		;
	LDR R0, R4, #0		;
	ST R4, STACK_TOP	;
	BRnzp DONE_POP		;
UNDERFLOW
	ADD R5, R5, #1		;
DONE_POP
	LD R3, POP_SaveR3	;
	LD R4, POP_SaveR4	;
	RET


POP_SaveR3	.BLKW #1	;
POP_SaveR4	.BLKW #1	;
STACK_END	.FILL x3FF0	;
STACK_START	.FILL x4000	;
STACK_TOP	.FILL x4000	;


.END
