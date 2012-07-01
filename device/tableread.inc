; tableread address, offset
; reads via TBLPTR a byte into W

	variable	_tablereadCounter = 0

tableread	macro	address, offset
	movlw		upper address
	movwf		TBLPTRU, ACCESS
	movlw		high address
	movwf		TBLPTRH, ACCESS
	movlw		low address
	banksel		offset
	addwf		offset, W, BANKED
	btfss		STATUS, C, ACCESS
	goto		_tableread_addressCalculated#v(_tablereadCounter)
	incfsz		TBLPTRH, F, ACCESS
	goto		_tableread_addressCalculated#v(_tablereadCounter)
	incf		TBLPTRU, F, ACCESS
_tableread_addressCalculated#v(_tablereadCounter)
	movwf		TBLPTRL, ACCESS
	tblrd*
	movf		TABLAT, W, ACCESS

_tablereadCounter ++
	endm
