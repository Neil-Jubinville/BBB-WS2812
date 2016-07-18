// PRU-ICSS program to control a 12LEDs ws2812B on P9_27 (pru0_pru_r30_5)

.origin 0							// Start of program in PRU memory
.entrypoint START					// Program entry point (for a debugger)

#define T0H 	38						// 400ns
#define T1H 	79                      // 800ns
#define T0L 	83						// 850ns
#define T1L 	44						// 450ns
#define TRESET 	6000					// 60000ns
#define LEDS 	12*4					// Number of LEDs
#define BITS 	24						// Number of bits
#define PRU0_R31_VEC_VALID 32			// Allows notification of program completition
#define PRU_EVTOUT_0 3					// The event number that is sent back

.macro M_HIGH							// Macro high pulse
	LEDON_H:
			SET		r30.t5				// Turn on the output pin
			MOV		r0, T1H				// Store the T1H time

	DELAYON_H:
			SUB		r0, r0, 1			// Decrement REG0 by 1
			QBNE	DELAYON_H, r0, 0	// Loop to DELAYON_H, unless REG0=0

	LEDOFF_H:
			CLR		r30.t5				// Clear the output pin
			MOV		r0, T0H				// Store the T0H time

	DELAYOFF_H:
			SUB		r0, r0, 1			// Decrement REG0 by 1
			QBNE	DELAYOFF_H, r0, 0	// Loop to DELAYOFF_H, unless REG0=0
.endm

.macro M_LOW							// Macro low pulse

	LEDON_L:
    	    SET     r30.t5              // Turn on the output pin
	        MOV     r0, T1L             // Store the T1L time

	DELAYON_L:
	        SUB     r0, r0, 1           // Decrement REG0 by 1
	        QBNE    DELAYON_L, r0, 0    // Loop to DELAYON_L, unless REG0=0

	LEDOFF_L:
	        CLR     r30.t5              // Clear the output pin
	        MOV     r0, T0L             // Store the T0L time

	DELAYOFF_L:
	        SUB     r0, r0, 1           // Decrement REG0 by 1
	        QBNE    DELAYOFF_L, r0, 0   // Loop to DELAYOFF_L, unless REG0=0
.endm

START:
		MOV		r3, 0x00000000			// Memory start position to clear
		MOV		r4, 0x00000000			// Value to load into memory

START_A:
		SBBO	r4, r3, 0, 4			// Load REG4 to memory adress REG3
		ADD		r3, r3, 4				// Add 4 to memory address REG3
		QBGE	START_A, r3, LEDS		// Loop to MEM_B, unless REG0<=MEMORY

START_B:
        MOV     r3, 0x00000000      	// Store the memory location for COLOR on REG3
		MOV		r4, 0x00FFFFFF			// Store the highest value to exit on REG4

LOAD:
        LBBO    r1, r3, 0, 4			// Load the COLOR on REG1
		QBLT	END, r1, r4				// Loop to END if REG1>REG4
		MOV     r2, 0x00000000      	// Inicialize REG2 to 0 (Used for count n. of BITs)

BUCLE:
        QBBS	HIGH, r1, r2			// Loop to HIGH if REG1 bit REG2 is equal to 1
        QBBC    LOW, r1, r2         	// Loop to HIGH if REG1 bit REG2 is equal to 0

HIGH:
		M_HIGH							// Call to macro M_HIGH
		JMP		PROGRAM					// Jump to PROGRAM

LOW:
        M_LOW                       	// Call to macro M_LOW
		JMP		PROGRAM					// Jump to PROGRAM

PROGRAM:
        ADD     r2, r2, 1           	// Increment REG2 by 1 (Number of BITs)
        QBNE    BUCLE, r2, BITS     	// Loop to START, unless REG2!=BITS

		ADD		r3, r3, 4				// Decrement REG1 by 1 (Number of LEDs)
		QBGT	LOAD, r3, LEDS			// Loop to LOAD, unless REG3<12*4

		MOV		r0, TRESET				// Store the TRESET on REG0

RESET:
		SUB		r0, r0, 1				// Decrement REG0 by 1
		QBNE	RESET, r0, 0			// Loop to RESET, unles REG0=0
		JMP		START_B					// Jump to INIT

END:                                	// Notify the calling app that finished
        MOV     r31.b0, PRU0_R31_VEC_VALID | PRU_EVTOUT_0
        HALT
