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
	
	
_selstackptr ++
_casecount = 0
_select#v(_selstack#v(_selstackptr - 1))
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
