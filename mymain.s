	PRESERVE8
	AREA MyCode, CODE, READONLY
	EXPORT asmmain
CR EQU 0x0D
LF EQU 0x0A
mask EQU 0x0F
		
asmmain
	IMPORT myfprint
	IMPORT mygetchar
	IMPORT myputchar
	IMPORT myintprint
	IMPORT getElement
	IMPORT myMenuPrint

setup	
	LDR r0, =menuMessage
	BL myfprint
	
	BL mygetchar
	PUSH {r0}
	BL myputchar
	POP {r0}
	
	CMP R0,#0x30
	BEQ printMenu
	B setup
	
gpioSetup
	MOV r0, #0x7000
	MOVT r0, #0x4004
	MOV r2, #0x1038
	MOV r3, #1
	LDR r1, [r0, r2]
	ORR r1, r1, r3, LSL #8
	STR r1, [r0, r2] // enables portA clock
// sets up gpio functionality

	MOV r0, #0x9000 //base address 
	MOVT r0, #0x4004 //portA 
	MOV r2, #0x80  // offset to GPCLR
	MOV r1, #0x0100 //gpio 001
	MOVT r1, #0x0003 //bits 0-1 for input
	MOV r3, #0x0100 
	MOVT r3, #0x00FF //output bits 16-19
	STR r1, [r0, r2]
	STR r3, [r0, r2]

//set pins as input / output
	
	MOV r0, #0xF000
	MOVT r0, #0x400F //base address of portA gpioA
	MOV r2, #0x14 //offset for pddr register
	STRB #0x0, [r0, r2] //sets porta pins 0-3 as inputs
	STRB #0x11, [r0, r2, #2] //pins 16-19 tbd for output
	MOV r2, 0x10 //now read pins of port A pdir  

configLEDs
	MOVT r1, #0x400F //base address of portA set output register
	MOV r0, #0xC10000C1
	STR r0, [r1, #4, LSL #2] 
	
inputFromKeypad
	LDR r1, [r0, r2]
	LDR r3, [r0, r2, LSL #1]
	ADD r1, r1, r3
	CMP r1, #0x30
	BEQ menuEntered
	B inputFromKeypad
	
menuEntered
	LDR r1, [r0, r2]
	LDR r3, [r0, r2, LSL #1]
	ADD r1, r1, r3
	CMP r1, #0x31
	BEQ led1
	CMP r1, #0x32
	BEQ led2start
	CMP r1, #0x32
	BEQ led3start
	B menuEntered

led1
	MOV r1, #0xF004
	MOVT r1, #0x400F //base address of portA set output register
	MOV r0, #0
	BL getElement
	LSL r1, #18
	STR r0, [r1] 
	B menuEntered

led2start
	LDR r2, =dailyValue
	LDR r6, [r2]
	MOV r3, #0
led2loop
	MOV r0, r3 
	BL getElement
	ADD r0, r0, r6
	STR r0, [r2]
	LDR r6, [r2]
	ADD r3, r3, #1
	CMP r3, #23
	BEQ led2div
	B led2loop
led2div
	MOV r3, #24
	UDIV r0,r0,r3
	MOV r1, #0xF004
	MOVT r1, #0x400F //base address of portA set output register
	LSL r1, #18
	STR r0, [r1]
	B menuEntered
	
led3start	
	LDR r2, =weeklyValue
	LDR r6, [r2]
	MOV r3, #0
led3loop
	MOV r0, r3 
	BL getElement
	ADD r0, r0, r6
	STR r0, [r2]
	LDR r6, [r2]
	ADD r3, r3, #1
	CMP r3, #167
	BEQ led3div
	B led3loop
led3div
	MOV r3, #168
	UDIV r0,r0,r3
	MOV r1, #0xF004
	MOVT r1, #0x400F //base address of portA set output register
	LSL r1, #18
	STR r0, [r1]
	B menuEntered
	

	ALIGN
	AREA MyData, DATA, READWRITE

openingmessage DCB "welcome press 0 to enter",0
menuMessage DCB "Welcome press 0 to enter menu", 0
message DCB "Incorrect Value",0
menuMessage1 DCB "Energy Consumption last hour watts(W)", 0
menuMessage2 DCB "Energy Consumption last day watts(W)", 0
menuMessage3 DCB "Energy Consumption last week watts(W)", 0
weeklyValue DCD 0
dailyValue DCD 0
	END

