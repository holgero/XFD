; -*-asm-*-
; -------------------------------------------------------------------------------
; ENGR 2210 SECTION 01 PIC ASSEMBLER MACROS
; -------------------------------------------------------------------------------
; Created by Bradley A. Minch 9/2004 to facilitate reasonably structured
; programming in PIC assembler.  These macros were inspired and informed 
; both by Karl Lunt's PIC macros, described in an atricle in the July 1999
; Nuts & Volts magazine, and by Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.  These macros provide facilities for
; for-next loops, repeat-until loops, select satatements, and if statements.

		
; Relational Operator definitions
;  added to work around gpasm macro limitations
;  (gpasm macros can' tbe passed relops like '==' and '>')
#define EQ 0
#define NE 1
#define GE 2
#define GT 3
#define LE 4
#define LT 5
		

	
; Work-around macros
;  - thanks to Bill Freeman for these! -
;  these solve the problem by which gpasm's macro processor can't
;  handle more than one #v(expression) on one line


; target
;  makes a label of the form a#v(b)_#v(c), where a is a string and b and c
;  are expressions
inrtgt	macro	a, b
a#v(b)
	endm

target	macro	a, b, c
	inrtgt	a#v(b)_, c
	endm

; brnch
;  emits a line like:
;  goto	a#v(b)_#v(c)
;   a is a string, b and c are expressions
inrbrn	macro	b, c
	goto	b#v(c)	
	endm

brnch	macro	a, b, c
	inrbrn	a#v(b)_, c
	endm

; vrbl
;  emits a line like:
;	variable	a#v(b) = #v(c)
;   a is a string, b and c are expressions
inrvrbl	macro	a, b
	variable	a = b
	endm
	
vrbl	macro	a, b, c
	inrvrbl	a#v(b), c
	endm
		
; -------------------------------------------------------------------------------
; FOR-NEXT LOOP MACROS
; -------------------------------------------------------------------------------
; Macros:	for, forf, forlf, forfl, next, nextl, nextf, exitfor, escfor
; -------------------------------------------------------------------------------
; The for-next group of macros provides an iterated looping structure in which
; an index variable takes on a succession of values from the specified starting
; value to the specified ending value.  The loop begins with one of the four for
; macros.  These each take three arguments: the register to use as an index
; variable, the initial value of the index, and the final value of the index.
; The only difference between the for macros is whether the initial values and 
; final values are literals (i.e., constants) or contained in registers (i.e.,
; variables).  Before the first loop iteration, the index register is set to the
; specified initial value.  At the top of the loop, the current value of the 
; index is compared to the specified ending value; if the index exceeds the 
; ending value, the loop terminates.  The loop ends with one of the three next
; macros.  They each take the index register as an argument.  Two of them take
; a second argument, which specifies the step size.  The index is incremented
; by the specified step size at the bottom of the loop.  Any one of the for 
; macros can be used with any one of the next macros.  In the present version, 
; the index variable can only count up.  An example of the basic form of the for 
; loop is as follows:
;
;			for i, 1, 10
;           	.
;				.
;				.
;			next i
;
; In this case, the body of the loop would be executed ten times with the index 
; variable, i, taking on each integer value between 1 and 10 on each succesive 
; iteration of the loop.  For loops may be nested to any depth.  The macros 
; exitfor and escfor respectively exit the innermost and outermost for loop in
; a nested for-loop structure.  Both the for and next macros make use of the W
; register.
; -------------------------------------------------------------------------------
			variable	_forcount = 0
			variable	_forstackptr = 0

; -------------------------------------------------------------------------------
; FOR (START OF A FOR-NEXT LOOP)
; -------------------------------------------------------------------------------
; Syntax:		for index, begl, endl
; -------------------------------------------------------------------------------
; Arguments:	index	the register to be used as the loop index variable
;				begl 	a literal value used as the initial value of the index
;				endl	a literal value used as the final value of the index
; -------------------------------------------------------------------------------
; The body of the loop executes until the value of the index exceeds the endl
; literal value, at which point the loop terminates with the statement following
; the next that terminates the loop.  This test is performed at the top of the 
; loop.  This macro destroys the contents of the W register.  You can terminate
; a for loop with next, nextl, or nextf.
; -------------------------------------------------------------------------------
for			macro		index,begl,endl
			movlw		begl
			movwf		index,BANKED
_for#v(_forcount)
			movf		index,W,BANKED
			sublw		endl
			btfss		STATUS,C,ACCESS
			goto		_next#v(_forcount)
			vrbl	_forstack, _forstackptr, _forcount
;;; 		variable	_forstack#v(_forstackptr) = _forcount
_forstackptr ++
_forcount ++
			endm

; -------------------------------------------------------------------------------
; FORF (START OF A FORF-NEXT LOOP)
; -------------------------------------------------------------------------------
; Syntax:		forf index, begf, endf
; -------------------------------------------------------------------------------
; Arguments:	index	the register to be used as the loop index variable
;				begf 	a register whose value is used to initialize the index
;				endf	a register whose value is used as the final index
; -------------------------------------------------------------------------------
; The body of the loop executes until the value of the index exceeds the endl
; literal value, at which point the loop terminates with the statement following
; the next that terminates the loop.  This test is performed at the top of the 
; loop.  This macro destroys the contents of the W register.  You can terminate
; a forf loop with next, nextl, or nextf.
; -------------------------------------------------------------------------------
forf		macro		index,begf,endf
			movf		begf,W,BANKED
			movwf		index,BANKED
_for#v(_forcount)
			movf		index,W,BANKED
			subwf		endf,W,BANKED
			btfss		STATUS,C,ACCESS
			goto		_next#v(_forcount)
			vrbl	_forstack, _forstackptr, _forcount

_forstackptr ++
_forcount ++
			endm

; -------------------------------------------------------------------------------
; FORLF (START OF A FORLF-NEXT LOOP)
; -------------------------------------------------------------------------------
; Syntax:		forlf index, begl, endf
; -------------------------------------------------------------------------------
; Arguments:	index	the register to be used as the loop index variable
;				begl 	a literal value used as the initial value of the index
;				endf	a register whose value is used as the final index
; -------------------------------------------------------------------------------
; The body of the loop executes until the value of the index exceeds the endl
; literal value, at which point the loop terminates with the statement following
; the next that terminates the loop.  This test is performed at the top of the 
; loop.  This macro destroys the contents of the W register.  You can terminate
; a forlf loop with next, nextl, or nextf.
; -------------------------------------------------------------------------------
forlf		macro		index,begl,endf
			movlw		begl
			movwf		index,BANKED
_for#v(_forcount)
			movf		index,W,BANKED
			subwf		endf,W,BANKED
			btfss		STATUS,C,ACCESS
			goto		_next#v(_forcount)
			vrbl	_forstack, _forstackptr, _forcount

_forstackptr ++
_forcount ++
			endm

; -------------------------------------------------------------------------------
; FORFL (START OF A FORFL-NEXT LOOP)
; -------------------------------------------------------------------------------
; Syntax:		forfl index, begf, endl
; -------------------------------------------------------------------------------
; Arguments:	index	the register to be used as the loop index variable
;				begf 	a register whose value is used to initialize the index
;				endl	a literal value used as the final value of the index
; -------------------------------------------------------------------------------
; The body of the loop executes until the value of the index exceeds the endl
; literal value, at which point the loop terminates with the statement following
; the next that terminates the loop.  This test is performed at the top of the 
; loop.  This macro destroys the contents of the W register.  You can terminate
; a forfl loop with next, nextl, or nextf.
; -------------------------------------------------------------------------------
forfl   	macro		index,begf,endl
			movf		begf,W,BANKED
			movwf		index,BANKED
_for#v(_forcount)
			movf		index,W,BANKED
			sublw		endl
			btfss		STATUS,C,ACCESS
			goto		_next#v(_forcount)
			vrbl	_forstack, _forstackptr, _forcount
_forstackptr ++
_forcount ++
			endm

; -------------------------------------------------------------------------------
; NEXT (END OF A FOR-NEXT LOOP)
; -------------------------------------------------------------------------------
; Syntax:		next index
; -------------------------------------------------------------------------------
; Arguments:	index	the register being used as the loop index variable
; -------------------------------------------------------------------------------
; The next macro increments the index and jumps back to the test at the top of 
; the for loop.  This macro can be used with for, forf, forlf, and forfl.
; -------------------------------------------------------------------------------
next		macro		index
_forstackptr --
			incf		index,F,BANKED
			goto		_for#v(_forstack#v(_forstackptr))
_next#v(_forstack#v(_forstackptr))
			endm

; -------------------------------------------------------------------------------
; NEXTL (END OF A FOR-NEXTL LOOP)
; -------------------------------------------------------------------------------
; Syntax:		nextl index, stepl
; -------------------------------------------------------------------------------
; Arguments:	index	the register being used as the loop index variable
;				stepl	a literal value used as the step size
; -------------------------------------------------------------------------------
; The next macro adds stepl to the index and jumps back to the test at the 
; top of the for loop.  This macro alters the contents of the W register. 
; This macro can be used with for, forf, forlf, and forfl.
; -------------------------------------------------------------------------------
nextl   	macro		index,stepl
_forstackptr --
			movf		index,W,BANKED
			addlw		stepl
			movwf		index,BANKED
			goto		_for#v(_forstack#v(_forstackptr))
_next#v(_forstack#v(_forstackptr))
			endm

; -------------------------------------------------------------------------------
; NEXTF (END OF A FOR-NEXTF LOOP)
; -------------------------------------------------------------------------------
; Syntax:		nextf index, stepf
; -------------------------------------------------------------------------------
; Arguments:	index	the register being used as the loop index variable
;				stepf	a register whose value is used as the step size
; -------------------------------------------------------------------------------
; The next macro adds the value contained in stepf to the index and jumps back 
; to the test at the top of the for loop.  This macro alters the contents of 
; the W register.  This macro can be used with for, forf, forlf, and forfl.
; -------------------------------------------------------------------------------
nextf   	macro		index,stepf
_forstackptr --
			movf		index,W,BANKED
			addwf		stepf,W,BANKED
			movwf		index,BANKED
			goto		_for#v(_forstack#v(_forstackptr))
_next#v(_forstack#v(_forstackptr))
			endm

; -------------------------------------------------------------------------------
; EXITFOR (TERMINATE EXECUTION OF THE INNERMOST FOR-NEXT LOOP)
; -------------------------------------------------------------------------------
; Syntax:		exitfor
; -------------------------------------------------------------------------------
; The exitfor macro terminates the execution of the innermost for-next loop in
; a nested for-loop structure.
; -------------------------------------------------------------------------------
exitfor		macro
		goto		_next#v(_forstack#v(_forstackptr - 1))
		endm

; -------------------------------------------------------------------------------
; ESCFOR (TERMINATE EXECUTION OF THE OUTERMOST FOR-NEXT LOOP)
; -------------------------------------------------------------------------------
; Syntax:		escfor
; -------------------------------------------------------------------------------
; The escfor macro terminates the execution of the outermost for-next loop in
; a nested for-loop structure.  In the context of a single for-next loop, this
; macro behaves in the same manner as does exitfor.
; -------------------------------------------------------------------------------
escfor		macro
		goto		_next#v(_forstack0)
		endm

; -------------------------------------------------------------------------------
; REPEAT-UNTIL LOOP MACROS
; -------------------------------------------------------------------------------
; Macros:	repeat, forever, until, untilf, untilset, untilclr,  
;			exitrepeat, escrepeat
; -------------------------------------------------------------------------------
; The repeat-until loop provides a mechanism for repeatedly executing the 
; instructions comprising the body of the loop until a specified condition
; holds.  The condition is tested at the bottom of the loop, so the body
; of the loop is always executed at least once.  An example of the basic
; strucutre of a repeat-until loop is as follows:
;
;			repeat
;				.
;				.
;				.
;			untilset reg, b, a
;
; In this example, the instructions between the repeat and untilset macros
; would be executed until bit b of register reg is set.  Repeat-until loops 
; may be nested to any depth.  The macros exitrepeat and escrepeat respectively 
; exit the innermost and outermost loop in a nested repeat-until loop structure.
; -------------------------------------------------------------------------------
			variable	_rptcount = 0
			variable	_rptstackptr = 0

; -------------------------------------------------------------------------------
; REPEAT (START OF A REPEAT-UNTIL LOOP)
; -------------------------------------------------------------------------------
; Syntax:		repeat
; -------------------------------------------------------------------------------
; The body of the loop executes repeatedly until the condition specified at
; the close of the loop holds.  The test occurs at the bottom of the loop, so
; even if the condition holds before the execution of the loop begins, the 
; body of the loop will be executed.  The repeat macro can be used with any of
; the forever, untilset, untilclr, untileq, untilne, untilcs, and untilcc 
; macros.  It does not alter the contents of the W register.
; -------------------------------------------------------------------------------
repeat		macro
_repeat#v(_rptcount)
		vrbl	_rptstack, _rptstackptr, _rptcount
;;; 			variable	_rptstack#v(_rptstackptr) = _rptcount
_rptstackptr ++
_rptcount ++
			endm

; -------------------------------------------------------------------------------
; FOREVER (END OF A REPEAT-FOREVER LOOP)
; -------------------------------------------------------------------------------
; Syntax:		forever
; -------------------------------------------------------------------------------
; The forever macro creates an infinite loop by unconditionally jumping back
; to the top of the loop.  The body of the loop is executed endlessly until
; an exitrepeat or escrepeat statement is executed.
; -------------------------------------------------------------------------------
forever		macro
_rptstackptr --
			goto		_repeat#v(_rptstack#v(_rptstackptr))
_endrepeat#v(_rptstack#v(_rptstackptr))
			endm

; -------------------------------------------------------------------------------
; UNTIL (END OF A REPEAT-UNTIL LOOP)
; -------------------------------------------------------------------------------
; Syntax:		until var, relop, lit
; -------------------------------------------------------------------------------
; Arguments:	var		the register to be tested against a literal
;				relop	the relational operator to use for the test, which 
;							must be one of ==, !=, <, <=, >, >=
;				lit		the literal to test the contents of register var against
; -------------------------------------------------------------------------------
; This macro performs a comparison between the contents of register var and a
; literal.  If the specified relation holds, the loop terminates.  This macro 
; makes use of the W register.
; -------------------------------------------------------------------------------
; This macro borrows heavily from Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.
; -------------------------------------------------------------------------------
until		macro	var,relop,lit
_rptstackptr --
			if (relop == EQ)
				movf	var,W,BANKED
				sublw	lit
				btfss	STATUS,Z,ACCESS
			else
			if (relop == NE)
				movf	var,W,BANKED
				sublw	lit
				btfsc	STATUS,Z,ACCESS
			else
			if (relop == GE)
				movlw	lit
				subwf	var,W,BANKED
				btfss	STATUS,C,ACCESS
			else
			if (relop == GT)
				movf	var,W,BANKED
				sublw	lit
				btfsc	STATUS,C,ACCESS
			else
			if (relop == LE)
				movf	var,W,BANKED
				sublw	lit
				btfss	STATUS,C,ACCESS
			else
			if (relop == LT)
				movlw	lit
				subwf	var,W,BANKED
				btfsc	STATUS,C,ACCESS
			else
				error "Illegal relational operator in until statement."
			endif
			endif
			endif				; nested else-ifs are not shown nested
			endif				; for neatness-over-clarity purposes
			endif
			endif

			goto	_repeat#v(_rptstack#v(_rptstackptr))
_endrepeat#v(_rptstack#v(_rptstackptr))
			endm

; -------------------------------------------------------------------------------
; UNTILF (END OF A REPEAT-UNTILF LOOP)
; -------------------------------------------------------------------------------
; Syntax:		untilf var1, relop, var2
; -------------------------------------------------------------------------------
; Arguments:	var1	the first register whose contents are to be tested 
;							against those of a second register
;				relop	the relational operator to use for the test, which 
;							must be one of ==, !=, <, <=, >, >=
;				var2	a second register
; -------------------------------------------------------------------------------
; This macro performs a comparison between the contents of register var1 and 
; those of register var2.  If the specified relation holds, the loop terminates.
; This macro makes use of the W register.
; -------------------------------------------------------------------------------
; This macro borrows heavily from Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.
; -------------------------------------------------------------------------------
untilf		macro		var1,relop,var2
_rptstackptr --
			if (relop == EQ)					; See if relop is ==
				movf	var1,W,BANKED
				subwf	var2,W,BANKED
				btfss	STATUS,Z,ACCESS
			else
			if (relop == NE)			
				movf	var1,W,BANKED
				subwf	var2,W,BANKED
				btfsc	STATUS,Z,ACCESS
			else
			if (relop == GE)					
				movf	var2,W,BANKED
				subwf	var1,W,BANKED
				btfss	STATUS,C,ACCESS
			else					
			if (relop == GT)			
				movf	var1,W,BANKED
				subwf	var2,W,BANKED
				btfsc	STATUS,C,ACCESS
			else
			if (relop == LE)
				movf	var1,W,BANKED
				subwf	var2,W,BANKED
				btfss	STATUS,C,ACCESS
			else
			if (relop == LT)
				movf	var2,W,BANKED
				subwf	var1,W,BANKED
				btfsc	STATUS,C,ACCESS
			else
				error "Illegal relational operator in untilf statement."
			endif
			endif
			endif				; these are really nested
			endif
			endif
			endif
			goto		_repeat#v(_rptstack#v(_rptstackptr))
_endrepeat#v(_rptstack#v(_rptstackptr))
			endm

; -------------------------------------------------------------------------------
; UNTILSET (END OF A REPEAT-UNTILSET LOOP)
; -------------------------------------------------------------------------------
; Syntax:		untilset reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
;				a		if a is 0, the access bank is selected.  if a is 1,
;						the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
; The untilset macro tests the specified bit of register reg and terminates
; loop execution if it is set.
; -------------------------------------------------------------------------------
untilset	macro	reg,bit,a
_rptstackptr --
			btfss		reg,bit,a
			goto		_repeat#v(_rptstack#v(_rptstackptr))
_endrepeat#v(_rptstack#v(_rptstackptr))
			endm

; -------------------------------------------------------------------------------
; UNTILCLR (END OF A REPEAT-UNTILCLR LOOP)
; -------------------------------------------------------------------------------
; Syntax:		untilclr reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
;				a		if a is 0, the access bank is selected.  if a is 1,
;						the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
; The untilclr macro tests the specified bit of register reg and terminates
; loop execution if it is clear.
; -------------------------------------------------------------------------------
untilclr	macro	reg,bit,a
_rptstackptr --
			btfsc		reg,bit,a
			goto		_repeat#v(_rptstack#v(_rptstackptr))
_endrepeat#v(_rptstack#v(_rptstackptr))
			endm

; -------------------------------------------------------------------------------
; EXITREPEAT (TERMINATE EXECUTION OF THE INNERMOST REPEAT-UNTIL LOOP)
; -------------------------------------------------------------------------------
; Syntax:		exitrepeat
; -------------------------------------------------------------------------------
; The exitrepeat macro terminates the execution of the innermost loop in a 
; nested repeat-until loop structure.
; -------------------------------------------------------------------------------
exitrepeat	macro
			goto		_endrepeat#v(_rptstack#v(_rptstackptr - 1))
			endm

; -------------------------------------------------------------------------------
; ESCREPEAT (TERMINATE EXECUTION OF THE OUTERMOST REPEAT-UNTIL LOOP)
; -------------------------------------------------------------------------------
; Syntax:		escrepeat
; -------------------------------------------------------------------------------
; The escrepeat macro terminates the execution of the outermost loop in a 
; nested repeat-until loop structure.  In the context of a single repeat-until 
; loop, this macro behaves in the same manner as does exitrepeat.
; -------------------------------------------------------------------------------
escrepeat	macro
			goto		_endrepeat#v(_rptstack0)
			endm

; -------------------------------------------------------------------------------
; SELECT STATEMENT MACROS
; -------------------------------------------------------------------------------
; Macros:	select, selectf, case, casef, caseset, caseclr, default, break, ends
; -------------------------------------------------------------------------------
; This group of macros allows a program to selectively execute sequences of 
; instructions based on the value of a variable and/or based on the bit values 
; in certain registers.  An example of a select statement is as follows:
;
;			select
;				case 1
;					.
;					.
;					.
;					break
;				case 4
;				casef foo
;					.
;					.
;					.
;					break
;				caseset reg, 0, a
;					.
;					.
;					.
;					break
;				default
;					.
;					.
;					.
;			ends
;
; In this case, the first group of instructions is executed if the value 
; of the W register is 1.  The second group of instructions is executed if
; the value of the W register is 4 or if it matches the value of register
; foo.  The third group of instructions is executed if bit 0 of register 
; reg is set.  The fourth group of instructions is executed in the event
; that none of the specified cases held.  The default block is optional.
; The break macro terminates the execution of the select statement; if no
; break macro exists at the end of a block of instructions, execution 
; continues in the next block.  The contents of the W register are preserved
; by the case macros.  Select statements may be nested to any depth.
; -------------------------------------------------------------------------------
			variable	_selcount = 0
			variable	_selstackptr = 0
			variable	_casecount = 0

; -------------------------------------------------------------------------------
; SELECT (START OF A SELECT STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		select
; -------------------------------------------------------------------------------
; This macro begins a select statement.  The W register is used as
; the selection variable.
; -------------------------------------------------------------------------------
select		macro
	
		vrbl	_casestack, _selstackptr, _casecount
		vrbl	_selstack, _selstackptr, _selcount
	
;;; 		variable	_casestack#v(_selstackptr) = _casecount
;;; 		variable	_selstack#v(_selstackptr) = _selcount
	
_selstackptr ++
_casecount = 0
_select#v(_selstack#v(_selstackptr - 1))
;;; 			goto		_case#v(_selstack#v(_selstackptr - 1))_#v(_casecount)
		brnch	_case, _selstack#v(_selstackptr - 1), _casecount
_selcount ++
			endm

	
; -------------------------------------------------------------------------------
; CASE (START OF A CASE IN A SELECT STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		case val
; -------------------------------------------------------------------------------
; Arguments:	val		a literal value to be compared with the contents of
;                       	the W register
; -------------------------------------------------------------------------------
; This macro compares the value containted in the W register with val; if they 
; match, the instructions following the case macro are executed.  Otherwise, 
; the next case is tested.  This macro preserves the value of the W register.
; -------------------------------------------------------------------------------
case		macro	val
		brnch	_casebypass, _selstack#v(_selstackptr - 1), _casecount

	target	_case, _selstack#v(_selstackptr - 1), _casecount
		xorlw	val
		btfsc	STATUS,Z,ACCESS
		brnch	_casematch, _selstack#v(_selstackptr - 1), _casecount
		xorlw	val
		brnch	_case, _selstack#v(_selstackptr - 1), _casecount + 1
	target	_casematch, _selstack#v(_selstackptr - 1), _casecount
		xorlw		val

	target	_casebypass, _selstack#v(_selstackptr - 1), _casecount
_casecount ++
			endm

; -------------------------------------------------------------------------------
; BREAK (TERMINATES EXECUTION OF A SELECT STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		break
; -------------------------------------------------------------------------------
; This macro terminates the execution of a select statement.
; -------------------------------------------------------------------------------
break		macro
		brnch	_endselect, _selstack#v(_selstackptr - 1), 0
		endm

; -------------------------------------------------------------------------------
; ENDS (END OF A SELECT STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		ends
; -------------------------------------------------------------------------------
; This macro marks the end of a select statement.
; -------------------------------------------------------------------------------
ends		macro
_selstackptr --
	target	_case, _selstack#v(_selstackptr), _casecount
_endselect#v(_selstack#v(_selstackptr))_0
_casecount = _casestack#v(_selstackptr)
		endm

; -------------------------------------------------------------------------------
; SELECTF (START OF A SELECT STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		selectf var
; -------------------------------------------------------------------------------
; Arguments:	var		the register whose value will be tested in each case
; -------------------------------------------------------------------------------
; This macro begins a selectf statement.  It begins by moving the contents of 
; var into the W register.
; -------------------------------------------------------------------------------
selectf		macro		var
		vrbl	_casestack, _selstackptr, _casecount
		vrbl	_selstack, _selstackptr, _selcount

;;; 			variable	_casestack#v(_selstackptr) = _casecount
;;; 			variable	_selstack#v(_selstackptr) = _selcount
_selstackptr ++
_casecount = 0
_select#v(_selstack#v(_selstackptr - 1))
		movf	var,W,BANKED
		brnch	_case, _selstack#v(_selstackptr - 1), _casecount
_selcount ++
		endm


; -------------------------------------------------------------------------------
; CASEF (START OF A CASE IN A SELECT STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		casef var
; -------------------------------------------------------------------------------
; Arguments:	var		a register whose value is to be compared with that of
;							the W register
; -------------------------------------------------------------------------------
; This macro compares the value containted in the W register with that in 
; register var; if they match, the instructions following the case macro are 
; executed.  Otherwise, the next case is tested.  This macro preserves the 
; value of the W register.
; -------------------------------------------------------------------------------
casef		macro	var
		brnch	_casebypass, _selstack#v(_selstackptr - 1), _casecount

	target	_case, _selstack#v(_selstackptr - 1), _casecount
		xorwf	var,W,BANKED
		btfsc	STATUS,Z,ACCESS
		brnch	_casematch, _selstack#v(_selstackptr - 1), _casecount
		xorwf	var,W,BANKED
		brnch	_case, _selstack#v(_selstackptr - 1), _casecount + 1
	target	_casematch, _selstack#v(_selstackptr - 1), _casecount
		xorwf		var,W,BANKED
	target	_casebypass, _selstack#v(_selstackptr - 1), _casecount
_casecount ++
		endm

; -------------------------------------------------------------------------------
; CASESET (START OF A CASE IN A SELECT STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		caseset reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
;				a		if a is 0, the access bank is selected.  if a is 1,
;						the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
; This macro tests the specified bit in register reg; if it is set, the 
; instructions following the case macro are executed.  Otherwise, the next
; case is tested.  This macro does not change the value of the W register.
; -------------------------------------------------------------------------------
caseset		macro	reg,bit,a
		brnch	_casebypass, _selstack#v(_selstackptr - 1), _casecount
	target	_case, _selstack#v(_selstackptr - 1), _casecount
		btfss	reg,bit,a
		brnch	_case, _selstack#v(_selstackptr - 1), (_casecount + 1)
	target	_casebypass, _selstack#v(_selstackptr - 1), _casecount
_casecount ++
		endm

; -------------------------------------------------------------------------------
; CASECLR (START OF A CASE IN A SELECT STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		caseclr reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;		bit		a literal value between 0 and 7 specifying the bit
;				position to be tested
;		a		if a is 0, the access bank is selected.  if a is 1,
;				the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
; This macro tests the specified bit in register reg; if it is clear, the 
; instructions following the case macro are executed.  Otherwise, the next
; case is tested.  This macro does not change the value of the W register.
; -------------------------------------------------------------------------------
caseclr		macro	reg,bit,a
		brnch	_casebypass, _selstack#v(_selstackptr - 1), _casecount
	target	_case, _selstack#v(_selstackptr - 1), _casecount
		btfsc	reg,bit,a
		brnch	_case, _selstack#v(_selstackptr - 1), (_casecount + 1) 
	target	_casebypass, _selstack#v(_selstackptr - 1), _casecount
_casecount ++
		endm

; -------------------------------------------------------------------------------
; DEFAULT (START OF A DEFAULT CASE IN A SELECT STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		default
; -------------------------------------------------------------------------------
; This macro begins the sequence of instructions that is executed if none
; of the other cases held.  The default block is optional.
; -------------------------------------------------------------------------------
default		macro
	target	_case, _selstack#v(_selstackptr - 1), _casecount
_casecount ++
		endm


; -------------------------------------------------------------------------------
; IF STATEMENT MACROS
; -------------------------------------------------------------------------------
; Macros:	ifl, iff, ifset, ifclr,
;			andif, andiff, andifset, andifclr,
;			orif, oriff, orifset, orifclr,
;			elsif, elsiff, elsifset, elsifclr,
;			otherwise, endi
; -------------------------------------------------------------------------------
; This set of macros allows the selective exectution of groups of instructions
; based on the values of one or more bits.  An example of an if statement is
; as follows:
;
;			ifset foo, 0, a
;				.
;				.
;				.
;			elsifclr bar, 5, a
;			andifset foo, 1, a
;				.
;				.
;				.
;			elsifset foo, 2, a
;			orifset foo, 3, a
;				.
;				.
;				.
;			otherwise
;				.
;				.
;				.
;			endi
;
; In this example, the first group of instructions is executed if bit 0 of 
; register foo is set.  The second group of instructions is executed if bit
; 5 of register bar is clear and bit 1 of register foo is set.  The third
; group is executed if either of bit 2 or bit 3 of register foo is set.
; Otherwise, the fourth group of instructions is executed.  The elsif and
; otherwise blocks are optional.  If statements can be nested to any depth.
; -------------------------------------------------------------------------------
			variable	_ifcount = 0
			variable	_ifstackptr = 0
			variable	_ifclausecount = 0

; -------------------------------------------------------------------------------
; IFL (START OF AN IF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		ifl var, relop, lit
; -------------------------------------------------------------------------------
; Arguments:	var		the register to be tested against a literal
;				relop	the relational operator to use for the test, which 
;							must be one of ==, !=, <, <=, >, >=
;				lit		the literal to test the contents of register var against
; -------------------------------------------------------------------------------
; This macro performs a comparison between the contents of register var and a
; literal.  If the specified relation holds, the block of statements following
; the ifl are executed.  This macro makes use of the W register.
; -------------------------------------------------------------------------------
; This macro borrows heavily from Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.
; -------------------------------------------------------------------------------
ifl			macro		var,relop,lit

			vrbl	_ifclausestack, _ifstackptr, _ifclausecount
			vrbl	_ifstack, _ifstackptr, _ifcount

;;; 			variable	_ifclausestack#v(_ifstackptr) = _ifclausecount
;;; 			variable	_ifstack#v(_ifstackptr) = _ifcount
_ifstackptr ++
_ifclausecount = 0
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		if (relop == EQ)				
			movf	var,W,BANKED
			sublw	lit
			btfss	STATUS,Z,ACCESS
		else
		if (relop == NE)				
			movf	var,W,BANKED
			sublw	lit
			btfsc	STATUS,Z,ACCESS
		else
		if (relop == GE)			
			movlw	lit
			subwf	var,W,BANKED
			btfss	STATUS,C,ACCESS
		else					
		if (relop == GT)
			movf	var,W,BANKED
			sublw	lit
			btfsc	STATUS,C,ACCESS
		else
		if (relop == LE)			
			movf	var,W,BANKED
			sublw	lit
			btfss	STATUS,C,ACCESS
		else
		if (relop == LT)
			movlw	lit
			subwf	var,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
			error "Illegal relational operator in ifl statement."
		endif
		endif
		endif
		endif
		endif
		endif
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
_ifcount ++
_ifclausecount ++
			endm

; -------------------------------------------------------------------------------
; IFF (START OF AN IF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		iff var1, relop, var2
; -------------------------------------------------------------------------------
; Arguments:	var1	the first register whose contents are to be tested 
;							against those of a second register
;				relop	the relational operator to use for the test, which 
;							must be one of ==, !=, <, <=, >, >=
;				var2	a second register
; -------------------------------------------------------------------------------
; This macro performs a comparison between the contents of register var1 and 
; those of register var2.  If the specified relation holds, the block of 
; statements following the iff are executed.  This macro makes use of the W 
; register.
; -------------------------------------------------------------------------------
; This macro borrows heavily from Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.
; -------------------------------------------------------------------------------
iff			macro	var1,relop,var2
			vrbl	_ifclausestack, _ifstackptr, _ifclausecount
			vrbl	_ifstack, _ifstackptr, _ifcount

;;; 			variable	_ifclausestack#v(_ifstackptr) = _ifclausecount
;;; 			variable	_ifstack#v(_ifstackptr) = _ifcount
_ifstackptr ++
_ifclausecount = 0
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		if (relop == EQ)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfss	STATUS,Z,ACCESS
		else
		if (relop == NE)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfsc	STATUS,Z,ACCESS
		else
		if (relop == GE)
			movf	var2,W,BANKED
			subwf	var1,W,BANKED
			btfss	STATUS,C,ACCESS
		else
		if (relop == GT)	
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
		if (relop == LE)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfss	STATUS,C,ACCESS
		else
		if (relop == LT)	
			movf	var2,W,BANKED
			subwf	var1,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
			error "Illegal relational operator in iff statement."
		endif
		endif
		endif
		endif
		endif
		endif
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
_ifcount ++
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; IFSET (START OF AN IF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		ifset reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
;				a		if a is 0, the access bank is selected.  if a is 1,
;						the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
; This macro tests the specified bit in register reg; if it is set, the 
; instructions following the ifset macro are executed.  Otherwise, the next
; case is tested.
; -------------------------------------------------------------------------------
ifset		macro	reg,bit,a
		vrbl	_ifclausestack, _ifstackptr, _ifclausecount
		vrbl	_ifstack, _ifstackptr, _ifcount
_ifstackptr ++
_ifclausecount = 0
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		btfss	reg,bit,a
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
_ifcount ++
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; IFCLR (START OF AN IF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		ifclr reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
;				a		if a is 0, the access bank is selected.  if a is 1,
;						the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
; This macro tests the specified bit in register reg; if it is clear, the 
; instructions following the ifclr macro are executed.  Otherwise, the next
; case is tested.
; -------------------------------------------------------------------------------
ifclr		macro	reg,bit,a
		vrbl	_ifclausestack, _ifstackptr, _ifclausecount
		vrbl	_ifstack, _ifstackptr, _ifcount
_ifstackptr ++
_ifclausecount = 0
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		btfsc	reg,bit,a
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
_ifcount ++
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; ANDIF (CONTINUATION OF AN IF/ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		andif var, relop, lit
; -------------------------------------------------------------------------------
; Arguments:	var		the register to be tested against a literal
;				relop	the relational operator to use for the test, which 
;							must be one of ==, !=, <, <=, >, >=
;				lit		the literal to test the contents of register var against
; -------------------------------------------------------------------------------
; This macro performs a comparison between the contents of register var and a
; literal.  If the specified relation holds, the block of statements following
; the ifl are executed.  This macro makes use of the W register.
; -------------------------------------------------------------------------------
; This macro borrows heavily from Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.
; -------------------------------------------------------------------------------
andif		macro		var,relop,lit
		if (relop == EQ)
			movf	var,W,BANKED
			sublw	lit
			btfss	STATUS,Z,ACCESS
		else
		if (relop == NE)
			movf	var,W,BANKED
			sublw	lit
			btfsc	STATUS,Z,ACCESS
		else
		if (relop == GE)
			movlw	lit
			subwf	var,W,BANKED
			btfss	STATUS,C,ACCESS
		else
		if (relop == GT)
			movf	var,W,BANKED
			sublw	lit
			btfsc	STATUS,C,ACCESS
		else
		if (relop == LE)
			movf	var,W,BANKED
			sublw	lit
			btfss	STATUS,C,ACCESS
		else
		if (relop == LT)
			movlw	lit
			subwf	var,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
			error "Illegal relational operator in andif statement."
		endif
		endif
		endif
		endif
		endif
		endif
		brnch	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		endm

; -------------------------------------------------------------------------------
; ANDIFF (CONTINUATION OF AN IF/ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		andiff var1, relop, var2
; -------------------------------------------------------------------------------
; Arguments:	var1	the first register whose contents are to be tested 
;							against those of a second register
;				relop	the relational operator to use for the test, which 
;							must be one of ==, !=, <, <=, >, >=
;				var2	a second register
; -------------------------------------------------------------------------------
; This macro performs a comparison between the contents of register var1 and 
; those of register var2.  If the specified relation holds, the block of 
; statements following the iff are executed.  This macro makes use of the W 
; register.
; -------------------------------------------------------------------------------
; This macro borrows heavily from Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.
; -------------------------------------------------------------------------------
andiff		macro		var1,relop,var2
		if (relop == EQ)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfss	STATUS,Z,ACCESS
		else
		if (relop == NE)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfsc	STATUS,Z,ACCESS
		else
		if (relop == GE)
			movf	var2,W,BANKED
			subwf	var1,W,BANKED
			btfss	STATUS,C,ACCESS
		else
		if (relop == GT)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
		if (relop == LE)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfss	STATUS,C,ACCESS
		else
		if (relop == LT)
			movf	var2,W,BANKED
			subwf	var1,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
			error "Illegal relational operator in andiff statement."
		endif
		endif
		endif
		endif
		endif
		endif
		brnch	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		endm

; -------------------------------------------------------------------------------
; ANDIFSET (CONTINUATION OF AN IF/ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		andifset reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
;				a		if a is 0, the access bank is selected.  if a is 1,
;						the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
andifset	macro	reg,bit,a
		btfss	reg,bit,a
		brnch	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		endm

; -------------------------------------------------------------------------------
; ANDIFCLR (CONTINUATION OF AN IF/ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		andifclr reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
;				a		if a is 0, the access bank is selected.  if a is 1,
;						the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
andifclr	macro	reg,bit,a
		btfsc	reg,bit,a
		brnch	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		endm

; -------------------------------------------------------------------------------
; ORIF (CONTINUATION OF AN IF/ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		orif var, relop, lit
; -------------------------------------------------------------------------------
; Arguments:	var		the register to be tested against a literal
;				relop	the relational operator to use for the test, which 
;							must be one of ==, !=, <, <=, >, >=
;				lit		the literal to test the contents of register var against
; -------------------------------------------------------------------------------
; This macro performs a comparison between the contents of register var and a
; literal.  If the specified relation holds, the block of statements following
; the ifl are executed.  This macro makes use of the W register.
; -------------------------------------------------------------------------------
; This macro borrows heavily from Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.
; -------------------------------------------------------------------------------
orif		macro	var,relop,lit
		brnch	_ifbypass, _ifstack#v(_ifstackptr - 1), _ifclausecount
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		if (relop == EQ)
			movf	var,W,BANKED
			sublw	lit
			btfss	STATUS,Z,ACCESS
		else
		if (relop == NE)
			movf	var,W,BANKED
			sublw	lit
			btfsc	STATUS,Z,ACCESS
		else
		if (relop == GE)
			movlw	lit
			subwf	var,W,BANKED
			btfss	STATUS,C,ACCESS
		else
		if (relop == GT)
			movf	var,W,BANKED
			sublw	lit
			btfsc	STATUS,C,ACCESS
		else
		if (relop == LE)
			movf	var,W,BANKED
			sublw	lit
			btfss	STATUS,C,ACCESS
		else
		if (relop == LT)
			movlw	lit
			subwf	var,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
			error "Illegal relational operator in orif statement."
		endif
		endif
		endif
		endif
		endif
		endif
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
	target	_ifbypass, _ifstack#v(_ifstackptr - 1), _ifclausecount
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; ORIFF (CONTINUATION OF AN IF/ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		oriff var1, relop, var2
; -------------------------------------------------------------------------------
; Arguments:	var1	the first register whose contents are to be tested 
;							against those of a second register
;				relop	the relational operator to use for the test, which 
;							must be one of ==, !=, <, <=, >, >=
;				var2	a second register
; -------------------------------------------------------------------------------
; This macro performs a comparison between the contents of register var1 and 
; those of register var2.  If the specified relation holds, the block of 
; statements following the iff are executed.  This macro makes use of the W 
; register.
; -------------------------------------------------------------------------------
; This macro borrows heavily from Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.
; -------------------------------------------------------------------------------
oriff		macro	var1,relop,var2
		brnch	_ifbypass, _ifstack#v(_ifstackptr - 1), _ifclausecount
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		if (relop == EQ)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfss	STATUS,Z,ACCESS
		else
		if (relop == NE)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfsc	STATUS,Z,ACCESS
		else
		if (relop == GE)
			movf	var2,W,BANKED
			subwf	var1,W,BANKED
			btfss	STATUS,C,ACCESS
		else				
		if (relop == GT)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
		if (relop == LE)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfss	STATUS,C,ACCESS
		else
		if (relop == LT)
			movf	var2,W,BANKED
			subwf	var1,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
			error "Illegal relational operator in oriff statement."
		endif
		endif
		endif
		endif
		endif
		endif
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
	target	_ifbypass, _ifstack#v(_ifstackptr - 1), _ifclausecount
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; ORIFSET (CONTINUATION OF AN IF/ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		orifset reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
; -------------------------------------------------------------------------------
orifset		macro	reg,bit,a
		brnch	_ifbypass, _ifstack#v(_ifstackptr - 1), _ifclausecount
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		btfss	reg,bit,a
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
	target	_ifbypass, _ifstack#v(_ifstackptr - 1), _ifclausecount
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; ORIFCLR (CONTINUATION OF AN IF/ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		orifclr reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
;				a		if a is 0, the access bank is selected.  if a is 1,
;						the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
orifclr		macro	reg,bit,a
		brnch	_ifbypass, _ifstack#v(_ifstackptr - 1), _ifclausecount
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		btfsc	reg,bit,a
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
	target	_ifbypass, _ifstack#v(_ifstackptr - 1), _ifclausecount
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; ELSIF (START OF AN ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		elsif var, relop, lit
; -------------------------------------------------------------------------------
; Arguments:	var		the register to be tested against a literal
;				relop	the relational operator to use for the test, which 
;							must be one of ==, !=, <, <=, >, >=
;				lit		the literal to test the contents of register var against
; -------------------------------------------------------------------------------
; This macro performs a comparison between the contents of register var and a
; literal.  If the specified relation holds, the block of statements following
; the ifl are executed.  This macro makes use of the W register.
; -------------------------------------------------------------------------------
; This macro borrows heavily from Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.
; -------------------------------------------------------------------------------
elsif		macro	var,relop,lit
		goto	_endif#v(_ifstack#v(_ifstackptr - 1))
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		if (relop == EQ)
			movf	var,W,BANKED
			sublw	lit
			btfss	STATUS,Z,ACCESS
		else
		if (relop == NE)
			movf	var,W,BANKED
			sublw	lit
			btfsc	STATUS,Z,ACCESS
		else
		if (relop == GE)
			movlw	lit
			subwf	var,W,BANKED
			btfss	STATUS,C,ACCESS
		else
		if (relop == GT)
			movf	var,W,BANKED
			sublw	lit
			btfsc	STATUS,C,ACCESS
		else
		if (relop == LE)
			movf	var,W,BANKED
			sublw	lit
			btfss	STATUS,C,ACCESS
		else
		if (relop = LT)
			movlw	lit
			subwf	var,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
			error "Illegal relational operator in elsif statement."
		endif
		endif
		endif
		endif
		endif
		endif
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; ELSIFF (START OF AN IF/ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		elsiff var1, relop, var2
; -------------------------------------------------------------------------------
; Arguments:	var1	the first register whose contents are to be tested 
;							against those of a second register
;				relop	the relational operator to use for the test, which 
;							must be one of ==, !=, <, <=, >, >=
;				var2	a second register
; -------------------------------------------------------------------------------
; This macro performs a comparison between the contents of register var1 and 
; those of register var2.  If the specified relation holds, the block of 
; statements following the iff are executed.  This macro makes use of the W 
; register.
; -------------------------------------------------------------------------------
; This macro borrows heavily from Myke Predko's structured programming macros,
; which are described on pp. 542-546 of the second edition of Programming and 
; Customizing PICmicro Microcontrollers.
; -------------------------------------------------------------------------------
elsiff		macro	var1,relop,var2
		goto	_endif#v(_ifstack#v(_ifstackptr - 1))
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		if (relop == EQ)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfss	STATUS,Z,ACCESS
		else
		if (relop == NE)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfsc	STATUS,Z,ACCESS
		else
		if (relop == GE)
			movf	var2,W,BANKED
			subwf	var1,W,BANKED
			btfss	STATUS,C,ACCESS
		else
		if (relop == GT)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
		if (relop == LE)
			movf	var1,W,BANKED
			subwf	var2,W,BANKED
			btfss	STATUS,C,ACCESS
		else
		if (relop == LT)
			movf	var2,W,BANKED
			subwf	var1,W,BANKED
			btfsc	STATUS,C,ACCESS
		else
			error "Illegal relational operator in elsiff statement."
		endif
		endif
		endif
		endif
		endif
		endif
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; ELSIFSET (START OF AN ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		elsifset reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
;				a		if a is 0, the access bank is selected.  if a is 1,
;						the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
; This macro tests the specified bit in register reg; if it is set, the 
; instructions following the elsifset macro are executed.  Otherwise, the 
; next case is tested.
; -------------------------------------------------------------------------------
elsifset	macro	reg,bit,a
		goto	_endif#v(_ifstack#v(_ifstackptr - 1))
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		btfss	reg,bit,a
		goto	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; ELSIFCLR (START OF AN ELSIF CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		elsifclr reg, bit, a
; -------------------------------------------------------------------------------
; Arguments:	reg		the register containing the bit to be tested
;				bit		a literal value between 0 and 7 specifying the bit
;						position to be tested
;				a		if a is 0, the access bank is selected.  if a is 1,
;						the BSR specifies the bank used to select reg.
; -------------------------------------------------------------------------------
; This macro tests the specified bit in register reg; if it is clear, the 
; instructions following the elsifset macro are executed.  Otherwise, the 
; next case is tested.
; -------------------------------------------------------------------------------
elsifclr	macro	reg,bit,a
		goto	_endif#v(_ifstack#v(_ifstackptr - 1))
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
		btfsc	reg,bit,a
		brnch	_if, _ifstack#v(_ifstackptr - 1), (_ifclausecount + 1)
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; OTHERWISE (START OF AN OTHERWISE CLAUSE IN AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		OTHERWISE
; -------------------------------------------------------------------------------
; This macro begins the sequence of instructions that is executed if none
; of the other conditions held.  The otherwise block is optional.  Note that
; this would normally be called 'else', but that was taken by MPASM for 
; conditional assembly structures.
; -------------------------------------------------------------------------------
otherwise	macro
		goto	_endif#v(_ifstack#v(_ifstackptr - 1))
	target	_if, _ifstack#v(_ifstackptr - 1), _ifclausecount
_ifclausecount ++
		endm

; -------------------------------------------------------------------------------
; ENDI (END OF AN IF STATEMENT)
; -------------------------------------------------------------------------------
; Syntax:		endi
; -------------------------------------------------------------------------------
; This macro marks the end of an if statement.
; -------------------------------------------------------------------------------
endi		macro
_ifstackptr --
	target	_if, _ifstack#v(_ifstackptr), _ifclausecount
_endif#v(_ifstack#v(_ifstackptr))
_ifclausecount = _ifclausestack#v(_ifstackptr)
		endm
