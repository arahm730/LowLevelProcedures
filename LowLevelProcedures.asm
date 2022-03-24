TITLE Average of Signed Decimals    (LowLevelProcedures.asm)


; Description: The program requests 10 valid signed integers from the user and then displays the inputs, their sum, and their truncated average.

INCLUDE Irvine32.inc

; ----------------------------------------------------
; Name: mGetString
;
; Displays a prompt and then gets the user's input and number of bytes read
;
; Preconditions: do not use EAX, EBX, ECX, and EDX as arguments
;
; Postconditions: none
;
; Receives: 
;	  prompt	     = prompt to display to user
;	  userInput		 = string that will contain user's input
;	  maxInputLength = maximum length of input allowed
;	  bytesRead		 = used to store number of bytes read
;
; returns: 
;	  userInput		 = string containing user's input
;	  bytesRead		 = number of bytes read
;----------------------------------------------------
mGetString MACRO prompt, userInput, maxInputLength, bytesRead
	; push registers
	PUSH	EAX
    PUSH    EBX
	PUSH	ECX
	PUSH	EDX

	; display prompt
	MOV		EDX, prompt
	CALL	WriteString

	; read user input
	MOV		EDX, userInput
	MOV		ECX, maxInputLength
	CALL	ReadString

	; store integer of bytes read
	MOV		EBX, bytesRead
	MOV		[EBX], EAX	

	; pop registers
	POP		EDX
	POP		ECX
    POP     EBX
	POP		EAX
ENDM

; ----------------------------------------------------
; Name: mDisplayString
;
; Displays a prompt and then gets the user's input and number of bytes read
;
; Preconditions: do not use EDX as argument
;
; Postconditions: none
;
; Receives: 
;	  string	= string to display to user
;
; returns: none
;----------------------------------------------------
mDisplayString MACRO usrString
	PUSH	EDX
	MOV		EDX, usrString
	CALL	WriteString
	POP		EDX
ENDM


	MAX_LENGTH = 12
	COUNT = 10
	MIN_ASCII = 48		; number 0
	MAX_ASCII = 57		; number 9
	NEG_SIGN = 45
	POS_SIGN = 43


.data
	programTitle		BYTE		"Designing low-level I/O procedures",0
	instructionOne		BYTE		"Please provide 10 signed decimal integers.",0
	instructionTwo		BYTE		"Each number needs to be small enough to fit inside a 32 bit register. ",0 
	instructionThree	BYTE		"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",0
	numberPrompt		BYTE		"Please enter a signed number: ",0
	errorMessage		BYTE		"ERROR: You did not enter a signed number or your number was too big.",10
						BYTE		"Please try again: ",0
	allNumsMessage		BYTE		"You entered the following numbers: ",0
	sumMessage			BYTE		"The sum of these numbers is: ",0
	averageMessage		BYTE		"The truncated average is: ",0
	farewelMessage		BYTE		"Thanks for playing!",0
	numArray			SDWORD		COUNT DUP(?)
	userStr				SDWORD		?
	textLength			DWORD		?
	userInt				SDWORD		?
	comma               BYTE		", ",0
	userSum				SDWORD		?
	userAverage			SDWORD		?
	displayedStr        SDWORD		MAX_LENGTH DUP(?)

.code
main PROC

	; introduce user to program
	mDisplayString OFFSET programTitle
	CALL	CrLf
	mDisplayString OFFSET author
	CALL	CrLf
	CALL	CrLf
	mDisplayString OFFSET instructionOne
	CALL	CrLf
	mDisplayString OFFSET instructionTwo
	mDisplayString OFFSET instructionThree
	CALL	CrLf
	CALL	CrLf

	MOV		EDI, OFFSET numArray	; points to beginning of numArray
	MOV		ECX, COUNT				; used to loop for 10 numbers

_LoopForValues:
	; loop to get 10 valid integers from user
	PUSH	EDI
	PUSH	OFFSET numberPrompt
	PUSH	OFFSET userStr
	PUSH	OFFSET textLength
	PUSH	OFFSET errorMessage
	CALL	ReadVal

	MOV		EAX, [EDI]					; EAX holds converted integer
	ADD		EDI, TYPE numArray			; next element is pointed
	ADD		userSum, EAX
	LOOP	_LoopForValues				; loops until 10 valid numbers are inputted
	CALL	CrLf

	; displays message prior to printing the 10 inputted integers
	mDisplayString OFFSET allNumsMessage
	CALL	CrLf

	; setup counter
	MOV		ESI, OFFSET numArray		; points to first entered number in array
	MOV		ECX, COUNT

_printNumbers:
	; prints all of the user's inputted numbers
	PUSH	OFFSET displayedStr
	PUSH	[ESI]
	CALL	WriteVal
	CMP		ECX, 1
	JE		_donePrinting				; no need to print comma if 10 integers are printed
	mDisplayString OFFSET comma			; print comma if less than 10 integers printed
	ADD		ESI, TYPE numArray			; points to next element
	LOOP	_printNumbers

_donePrinting:
	; all the integers have been printed
	CALL	CrLf

	; displays total sum
	mDisplayString OFFSET sumMessage
	PUSH	OFFSET displayedStr
	PUSH	userSum
	CALL	WriteVal
	CALL	CrLf

	; finds the average
	MOV		EAX, userSum
	MOV		EBX, COUNT
	CDQ
	IDIV	EBX
	MOV		userAverage, EAX

	; display average to user
	mDisplayString	OFFSET averageMessage
	PUSH	OFFSET displayedStr
	PUSH	userAverage
	CALL	WriteVal
	CALL	CrLf
	CALL	CrLf

	; display farewell message to user
	mDisplayString	OFFSET farewelMessage

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ----------------------------------------------------
; Name: ReadVal
;
; Invokes mGetstring macro to get user input in the form of a 
;	string of ascii digits, validates input to be a valid number, 
;	and then converts the string to its numerical representation
;
; Preconditions: the array is type SDWORD
;
; Postconditions: changes registers EAX, EBX, ECX, EDX, ESI
;
; Receives: 
;	  [EBP + 24]	= current index in array of numbers
;	  [EBP + 20]	= prompt user to enter a number
;	  [EBP + 16]	= string that user has inputted
;	  [EBP + 12]	= length of user's text input
;	  [EBP + 8]		= error message
;
; returns: array updated with user's signed integer
;----------------------------------------------------
ReadVal PROC
	
	; push registers 
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI

	mGetString [EBP+20], [EBP+16], MAX_LENGTH, [EBP+12]		; prompt user for number

_setupReg:
	; setup registers for looping
	MOV		EBX, [EBP+12]
	MOV		ECX, [EBX]		
	PUSH	ECX
	MOV		EDX, [EBP+24]
	MOV		ESI, [EBP+16]	; points to string that user has inputted
	MOV		EAX, 0
	MOV		[EDX], EAX
	CLD						; used to move forward through array

_checkEachDigit:
	; check if entered value has a sign
	LODSB					; takes value pointed by ESI and copies it into Al
	CMP		ECX, [ESP]
	JNE		_isNextDigit
	MOV		EBX, 0
	CMP		AL, POS_SIGN	; check if Al has '+'
	JE		_hasSign
	JNE		_checkIfNegSign

_checkIfNegSign:
	; checks if there is a '-' entered
	CMP		AL, NEG_SIGN
	JE		_hasSign
	JNE		_wholeNumber

_wholeNumber:
	; input does not have '+' or '-'
	MOV		BL, 0
	JMP		_isNextDigit

_hasSign:
	; input has either a '+' or '-'
	MOV		BL, AL
	JMP		_digitIsValid

_isNextDigit:
	; checks if entered value is from 0-9 (48-57 in ascii)
	CMP		AL, MAX_ASCII
	JA		_tryAgain
	CMP		AL, MIN_ASCII
	JB		_tryAgain

_convertToInt:
	; convert ascii to int using formula: numInt = 10*numInt+(numChar-48)
	SUB		AL, MIN_ASCII	; numChar - 48
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX

	; 10*numInt with result in EAX
	MOV		EBX, 10
	MOV		EAX, [EDX]		; holds numInt
	IMUL	EBX				
	JO		_overFlowOccured
	POP		EDX
	POP		EBX
	MOV		[EDX], EAX
	POP		EAX

	; check if result should be added or subtracted
	CMP		BL, NEG_SIGN
	JE		_negNum
	ADD		[EDX], EAX		; adds result if positive
	JO		_tryAgain
	JMP		_digitIsValid

_negNum:
	; subtract result if negative
	SUB		[EDX], EAX
	JO		_tryAgain

_digitIsValid:
	; loop to check next digit
	LOOP	_checkEachDigit
	JMP		_done

_overflowOccured:
	; pop registers
	POP		EDX
	POP		EBX
	POP		EAX

_tryagain:
	; reprompt user for input
	POP		ECX
	mGetString	[EBP+8], [EBP+16], MAX_LENGTH, [EBP+12]
	JMP		_setupReg

_done:
	; pop registers and return
	POP		ECX
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		20

ReadVal	ENDP


; ----------------------------------------------------
; Name: WriteVal
;
; Converts a numeric SDWORD value to a string of ASCII digits
; and invokes mDisplayString to print the ASCII string
;
; Preconditions: the array is type SDWORD
;
; Postconditions: changes registers EAX, EBX, ECX, EDX, EDI
;
; Receives: 
;	  [EBP + 12]	= printed string that will contain converted ascii
;	  [EBP + 8]		= integer to convert to string
;
; returns: array updated with user's signed integer
;----------------------------------------------------
WriteVal PROC
	
	; push registers
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI

	MOV		EDI, [EBP+12]	; contains output string
	MOV		EAX, [EBP+8]
	ADD		EDI, 11
	STD						; used to move backward through array

	MOV		EBX, 0
	MOV		ECX, MAX_LENGTH
	CMP		EAX, 0			; check if integer is negative
	JGE		_convertNum
	JL		_isNegative

_convertNum:
	; convert int back to ascii string
	PUSH	EBX
	MOV		EDX, 0
	MOV		EBX, 10
	DIV		EBX				; EAX / 10
	POP		EBX
	PUSH	EAX				
	MOV		EAX, EDX
	ADD		EAX, MIN_ASCII  ; integer has been finally converted to ASCII
	STOSB					; copy value in Al into location pointed by EDI
	POP		EAX

	; check if need to break from loop
	CMP		EAX, 0			
	JNZ		_nextNumber
	MOV		ECX, 1			

_nextNumber:
	; keep looping
	LOOP	_convertNum

	; check if '-' is needed
	CMP		BL, NEG_SIGN
	JNE		_completedConversion
	MOV		AL, BL
	STOSB					
	JMP		_completedConversion

_isNegative:
	; need a '-' ascii
	MOV		BL, NEG_SIGN
	NEG		EAX
	JMP		_convertNum

_completedConversion:
	; int has been converted to ascii string
	ADD		EDI, 1
	mDisplayString EDI		; display number as ascii
	
	; pop registers
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		8
WriteVal ENDP

END main
