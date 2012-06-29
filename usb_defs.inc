#define	NUM_CONFIGURATIONS	1
#define	NUM_INTERFACES		1
#define NUM_STRINGS			2

; Define the states that the USB interface can be in
#define	POWERED_STATE	0x00
#define	DEFAULT_STATE	0x01
#define	ADDRESS_STATE	0x02
#define	CONFIG_STATE	0x03

; Define the states for Control EndPoints
#define	EP_IDLE_STATE		0x00
#define	EP_SETUP_STATE		0x01
#define	EP_DISABLED_STATE	0xff

#define	ENDPT_DISABLED		0x00
#define ENDPT_IN_ONLY		0x12
#define ENDPT_OUT_ONLY		0x14
#define ENDPT_CONTROL		0x16	; enable for in, out and setup
#define ENDPT_NON_CONTROL	0x1E	; enable for in, and out

#define INT_STAT_MASK_RESET	0x01
#define INT_STAT_MASK_ERROR	0x02
#define INT_STAT_MASK_TOKEN_DONE	0x04
#define INT_STAT_MASK_SLEEP	0x08
#define INT_STAT_MASK_STALL	0x10

#define TOKEN_OUT	(0x01<<2)
#define TOKEN_ACK	(0x02<<2)
#define TOKEN_IN	(0x09<<2)
#define TOKEN_SETUP	(0x0D<<2)

; Define buffer descriptor table register mapping for no ping-pong buffers
#define BD0OST		0x0400
#define BD0OBC		0x0401
#define BD0OAL		0x0402
#define BD0OAH		0x0403
#define BD0IST		0x0404
#define BD0IBC		0x0405
#define BD0IAL		0x0406
#define BD0IAH		0x0407
#define BD1OST		0x0408
#define BD1OBC		0x0409
#define BD1OAL		0x040A
#define BD1OAH		0x040B
#define BD1IST		0x040C
#define BD1IBC		0x040D
#define BD1IAL		0x040E
#define BD1IAH		0x040F
#define BD2OST		0x0410
#define BD2OBC		0x0411
#define BD2OAL		0x0412
#define BD2OAH		0x0413
#define BD2IST		0x0414
#define BD2IBC		0x0415
#define BD2IAL		0x0416
#define BD2IAH		0x0417
#define BD3OST		0x0418
#define BD3OBC		0x0419
#define BD3OAL		0x041A
#define BD3OAH		0x041B
#define BD3IST		0x041C
#define BD3IBC		0x041D
#define BD3IAL		0x041E
#define BD3IAH		0x041F
#define BD4OST		0x0420
#define BD4OBC		0x0421
#define BD4OAL		0x0422
#define BD4OAH		0x0423
#define BD4IST		0x0424
#define BD4IBC		0x0425
#define BD4IAL		0x0426
#define BD4IAH		0x0427
#define BD5OST		0x0428
#define BD5OBC		0x0429
#define BD5OAL		0x042A
#define BD5OAH		0x042B
#define BD5IST		0x042C
#define BD5IBC		0x042D
#define BD5IAL		0x042E
#define BD5IAH		0x042F
#define BD6OST		0x0430
#define BD6OBC		0x0431
#define BD6OAL		0x0432
#define BD6OAH		0x0433
#define BD6IST		0x0434
#define BD6IBC		0x0435
#define BD6IAL		0x0436
#define BD6IAH		0x0437
#define BD7OST		0x0438
#define BD7OBC		0x0439
#define BD7OAL		0x043A
#define BD7OAH		0x043B
#define BD7IST		0x043C
#define BD7IBC		0x043D
#define BD7IAL		0x043E
#define BD7IAH		0x043F
#define BD8OST		0x0440
#define BD8OBC		0x0441
#define BD8OAL		0x0442
#define BD8OAH		0x0443
#define BD8IST		0x0444
#define BD8IBC		0x0445
#define BD8IAL		0x0446
#define BD8IAH		0x0447
#define BD9OST		0x0448
#define BD9OBC		0x0449
#define BD9OAL		0x044A
#define BD9OAH		0x044B
#define BD9IST		0x044C
#define BD9IBC		0x044D
#define BD9IAL		0x044E
#define BD9IAH		0x044F
#define BD10OST		0x0450
#define BD10OBC		0x0451
#define BD10OAL		0x0452
#define BD10OAH		0x0453
#define BD10IST		0x0454
#define BD10IBC		0x0455
#define BD10IAL		0x0456
#define BD10IAH		0x0457
#define BD11OST		0x0458
#define BD11OBC		0x0459
#define BD11OAL		0x045A
#define BD11OAH		0x045B
#define BD11IST		0x045C
#define BD11IBC		0x045D
#define BD11IAL		0x045E
#define BD11IAH		0x045F
#define BD12OST		0x0460
#define BD12OBC		0x0461
#define BD12OAL		0x0462
#define BD12OAH		0x0463
#define BD12IST		0x0464
#define BD12IBC		0x0465
#define BD12IAL		0x0466
#define BD12IAH		0x0467
#define BD13OST		0x0468
#define BD13OBC		0x0469
#define BD13OAL		0x046A
#define BD13OAH		0x046B
#define BD13IST		0x046C
#define BD13IBC		0x046D
#define BD13IAL		0x046E
#define BD13IAH		0x046F
#define BD14OST		0x0470
#define BD14OBC		0x0471
#define BD14OAL		0x0472
#define BD14OAH		0x0473
#define BD14IST		0x0474
#define BD14IBC		0x0475
#define BD14IAL		0x0476
#define BD14IAH		0x0477
#define BD15OST		0x0478
#define BD15OBC		0x0479
#define BD15OAL		0x047A
#define BD15OAH		0x047B
#define BD15IST		0x047C
#define BD15IBC		0x047D
#define BD15IAL		0x047E
#define BD15IAH		0x047F

#define USB_Buffer	0x0480		; Register location after last buffer descriptor register

#define	UOWN		0x07

; offsets from the beginning of the Buffer Descriptor
#define BYTECOUNT	0x01
#define	ADDRESSL	0x02
#define ADDRESSH	0x03

; standard descriptor types
#define	DEVICE		1
#define	CONFIGURATION	2
#define	STRING		3
#define	INTERFACE	4
#define	ENDPOINT	5

; HID class descriptor types
#define HID			0x21
#define REPORT		0x22
#define PHYSICAL	0x23

; offsets from the beginning of the setup data record
#define	bmRequestType	0x00
#define	bRequest	0x01
#define	wValue		0x02
#define	wValueHigh	0x03
#define	wIndex		0x04
#define	wIndexHigh	0x05
#define	wLength		0x06
#define	wLengthHigh	0x07

; Standard USB requests
#define NO_REQUEST		0xFF
#define	GET_STATUS		0x00
#define	CLEAR_FEATURE	0x01
#define	SET_FEATURE		0x03
#define	SET_ADDRESS		0x05
#define	GET_DESCRIPTOR	0x06
#define SET_DESCRIPTOR	0x07
#define	GET_CONFIGURATION	0x08
#define	SET_CONFIGURATION	0x09
#define	GET_INTERFACE	0x0A
#define	SET_INTERFACE	0x0B
#define SYNCH_FRAME		0x0C

; HID Class requests
#define GET_REPORT		0x01
#define GET_IDLE		0x02
#define GET_PROTOCOL	0x03
#define SET_REPORT		0x09
#define SET_IDLE		0x0A
#define SET_PROTOCOL	0x0B

#define	GET_STRING_DESCRIPTOR	0x66
#define	HID_SET_REPORT		0x21
#define	VEND_SET_MEMORY		0x80

#define	SVCUSBINT		0x01 << 2
#define	SVCTOKENDONE		0x02 << 2
#define	SVCRESET		0x03 << 2
#define	SVCSLEEP		0x04 << 2
#define	SVCSTALL		0x05 << 2
#define	SVCERROR		0x06 << 2
#define	SVCACTIVITY		0x07 << 2
#define	TOKENOUT		0x08 << 2
#define	TOKENIN			0x09 << 2
#define	TOKENSETUP		0x0A << 2
#define	CLEARFEATURE		0x0B << 2
#define	GETCONFIG		0x0C << 2
#define	GETDESCRIPTOR		0x0D << 2
#define	GETINTERFACE		0x0E << 2
#define	GETSTATUS		0x0F << 2
#define	SETADDRESS		0x10 << 2
#define	SETCONFIG		0x11 << 2
#define	SETFEATURE		0x12 << 2
#define	SETINTERFACE		0x13 << 2
#define	FINISHSETADDRESS	0x14 << 2
#define	COPYDESC2EP0		0x15 << 2
#define	COPYSTRINGDESC2EP0	0x16 << 2
#define	ZEROLENPACKET		0x17 << 2

#define EP0				0x00 << 3
#define EP1				0x01 << 3
#define EP2				0x02 << 3

#define STANDARD		0x00 << 5
#define CLASS			0x01 << 5
#define VENDOR			0x02 << 5

#define RECIPIENT_DEVICE	0x00
#define RECIPIENT_INTERFACE	0x01
#define RECIPIENT_ENDPOINT	0x02

#define DEVICE_REMOTE_WAKEUP	0x01
#define ENDPOINT_HALT			0x00
