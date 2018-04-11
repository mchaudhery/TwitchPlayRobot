

START_IMAGE:
.incbin "start.bmp"
STOP_IMAGE:
.incbin "stop.bmp"
RIGHT_IMAGE:
.incbin "right.bmp"
LEFT_IMAGE:
.incbin "left.bmp"




.global _start
_start:

initialization:
#FOR NON INTERRUPTS
#writing the information to the output




#  movia r2,ADDR_JP1PORT_DIR
#  movia r3, 0b111 #enabling the reading of pin 1,2 and 3
#  stwio r3,0(r2)  # Set the first bit to read


DEFAULT_INITIALIZATION:
  movia r15, START_IMAGE
.equ ADDR_JP1PORT, 0xFF200060
.equ ADDR_JP1PORT_DIR, 0xFF200064
.equ ADDR_JP1PORT_IE, 0xFF200068
.equ ADDR_JP1PORT_EDGE, 0xFF20006C
.equ IRQ_JP1PA, 0x00000800

#Keyboard Declarations
.equ PS_2_KEYBOARD, 0xFF200100
#PS2 values table: 
.equ keyUp, 0x75
.equ keyRight, 0x74
.equ keyLeft, 0x6B

.equ ADDR_VGA, 0x08000000
.equ DRAWING_COMPLETE, 0x40000
.equ WHITE, 0xFFFF


movia r2,ADDR_JP1PORT_DIR
movia r3,0b00001111
stwio r3,0(r2)

movia r2,ADDR_JP1PORT
movi  r3, 0b00000000
stwio r3, 0(r2)   # Write value to output pins 

movia r18, 1
movia r20, PS_2_KEYBOARD

  
START_SCREEN:
  movia r16, 320*2
  movia r2, ADDR_VGA
  addi r15, r15, 66
  add r14, r0, r0
  add r16, r16, r2

ClearScreen:
  movia r13, WHITE
  movia r14, DRAWING_COMPLETE
  add r14, r14, r2
ClearScreen_Loop:
  beq r2, r14, DONE_IMAGE
  ldhio r12, 0(r15)
  sthio r12, 0(r2)
  addi r2, r2, 2
  addi r15, r15, 2
  beq r2, r16, NEXT_Y
  br ClearScreen_Loop
NEXT_Y:
  addi r2, r2, 384
  addi r16, r16, 1024
  br ClearScreen_Loop

DONE_IMAGE:

  movia r17, 0
  
#declaring all of the GPIO constants
#taken from reference from the 





# .equ TIMER_ADDRESS, 0xFF202000
# .equ DEFAULT_CLOCK_CYCLES, 300000000
# .equ ENABLE_INTERRUPT_TIMER, 0x7
# .equ TIMER_CTL_ENABLE, 0x1

#Register storage values:
# r2 - default address storage
# r6 - 
#r11 - storage for x pixel 
#r12 - storage for y pixel

#Enabling whether the system in reading or writing
#0 is set to read and 1 is set to write


############################################################################----MAIN-----############################################################################
#  Enable all interrupts 
enable_all_interrupts:
  movia r13, 0b01
  stwio r13,  4(r20)

#  Mask IRQ line bits for processor keyboard bit 7
  movi r13, 0b010000000 #  timer currently disabled
  wrctl ienable, r13

# Enable global interrupts for processor
  movi r13, 0x0000001
  wrctl status, r13

############################################################################----FUNCTIONS-----############################################################################
# enable interrupts on PS2 keyboard device


###############NOT NEEDED
# # disable the interrupt
# #  disablt the interrupts on PS2 keyboard device
# disable_device_interrupts:
#     movia r13, 0b00
#     stwio r13,  4(r12)



#VGA pixel buffer
LOOP_FOREVER:
  beq r17, r18, START_SCREEN
  br LOOP_FOREVER


.section .exceptions, "ax"

myISR:
    beq r17, r18, RETURN
  #PS2 Interrupt
    rdctl r14, ipending
    add r13, r14, r0
    andi r13 ,r13, 0b0010000000
    movi r15, 0b0010000000
    beq r13,r15, PS_2_INTERRUPT

PS_2_INTERRUPT:

  ldwio r23, 0(r20)
  movia r17, 1
  andi r23, r23, 0b11111111


  movia r13, keyUp
  beq r23, r13, FORWARD

  movia r13, keyLeft
  beq r23, r13, LEFT

  movia r13, keyRight
  beq r23, r13, RIGHT
  br RETURN

LEFT:
#  call turnLeftFunction
  movia r2,ADDR_JP1PORT
  movi  r3, 0b00000010
  stwio r3, 0(r2)
  movia r15, LEFT_IMAGE
  br RETURN

FORWARD:
#  call forwardFunction
  movia r2,ADDR_JP1PORT
  movi  r3, 0b00001010
  stwio r3, 0(r2)
  movia r15, START_IMAGE
  br RETURN


RIGHT:
#  call turnLeftFunction
  movia r2,ADDR_JP1PORT
  movi  r3, 0b00001000
  stwio r3, 0(r2)
  movia r15, RIGHT_IMAGE
  br RETURN

RETURN:
#disable_device_interrupts:
  movia r13, 0b00
  stwio r13, 4(r20)

  movi r13, 0b000000000 #  timer currently disabled
  wrctl ienable, r13

# Enable global interrupts for processor
  movi r13, 0x0000000
  wrctl status, r13
  movia ea, START_SCREEN
  eret





# timer_initialization:
#   movia r2, TIMER_ADDRESS  # r2 contains the address for the timer 
#   movi r3, %lo(DEFAULT_CLOCK_CYCLES)
#   stwio r3, 8(r2)                          
#   movi r3, %hi(DEFAULT_CLOCK_CYCLES)
#   stwio r3, 12(r2)
#   stwio r0, 0(r2)
#   movia r3, ENABLE_INTERRUPT_TIMER 
#   stwio r3, 4(r2)    # Start the timer with interrupt

#   #enable the ctl interrupts
#   movi r3, TIMER_CTL_ENABLE
#   wrctl ctl0, r3
#   wrctl ctl3, r3

#Initialization
#VGA Constants
# .equ ADDR_VGA, 0x08000000
# .equ DRAWING_COMPLETE, 245374
# .equ WHITE 0xFF

# movia r2, ADDR_VGA

# ClearScreen:
#   movia r11, 0
#   movia r12, 0
# ClearScreen_Loop:
#   beq DRAWING_COMPLETE, LOOP_FOREVER
#   movia r13, WHITE
#   stw r13, 0,(r2)
#   addi r11, r11, 1
#   br ClearScreen_Loop

# #VGA pixel buffer
# LOOP_FOREVER:
#   br LOOP_FOREVER

# #Interrupt initialization
# #NEED TO FIGURE OUT WHAT THE 
#   movia r2,ADDR_JP1PORT_IE
#   movi  r3,0x40
#   stwio r3,0(r2)  # Enable interrupts on 4 LSB pins 

#   movia r2,IRQ_JP1PA
#   wrctl ctl3,r2   # Enable bit 11 - button interrupts on Nios II 

#   movia r2,1
#   wrctl ctl0,r2   # Enable global Interrupts on Nios II 




#FOR NON INTERRUPTS
#writing the information to the output
#  movia r2,ADDR_JP1PORT
#  movi  r3,0x00000001
#  stwio r3, 0(r2)   # Write value to output pins 





# .section .exceptions, "ax"
# interupt_storage:

#   rdctl r8, ctl1
#   rdctl r9, ctl4
  

#  rdctl et, ctl4          # Check if an external interrupt has occurred 
#  beq et, r0, SKIP_EA_DEC 

#  movia r7,IRQ_JP1PA        # test for bit 7 interrupt 
#  and   r7,et,r7
#  beq   r7,r0,EXIT_IHANDLER # if not, exit handler 

#  movia r2,ADDR_JP1PORT
#  ldwio r3,0(r2)  # Read port A data 


# TimerInterrupt:
#   movia r12, 0x00000001 #r3 = r11
#   movia r10, TIMER_ADDRESS
#   stwio r0, 0(r10)
#   movia r11, ENABLE_INTERRUPT_TIMER
#   wrctl ctl0, r11
#   wrctl ctl1, r8
#   beq r12, r3, moveMotorsOFF

# moveMotorsON:
#   #This is where we move the motors
#   ########
#   movia r2,ADDR_JP1PORT
#   movi  r3,0x00000001
#   stwio r3, 0(r2)
#   eret
#   #########
# moveMotorsOFF:
#   movia r2,ADDR_JP1PORT
#   movi  r3,0x00000000
#   stwio r3, 0(r2)
#   eret

#  movia r7,ADDR_JP1PORT_EDGE
#  stwio r0, 0(r7) # De-assert interrupt - write to edge capture reg


#EXIT_IHANDLER:
#  subi ea,ea,4    # Replay interrupted instruction for hw interrupts 
#SKIP_EA_DEC:
#  eret