#include <stdio.h>
#include <unistd.h>
#include <prussdrv.h>
#include <pruss_intc_mapping.h>
#include "ws2812.h"

#define PRU_NUM 0	// Using PRU0 for these examples

void RunPRU()
{
	// Initialize structure used by prussdrv_pruintc_intc
	// PRUSS_INTC_INITDATA is found in pruss_intcmapping.h
	tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;

	// Allocate and initialize memory
	prussdrv_init ();
	prussdrv_open (PRU_EVTOUT_0);

	// Map PRU's interrupts
	prussdrv_pruintc_init (&pruss_intc_initdata);

	// Load and execute the PRU program on the PRU
	prussdrv_exec_program (PRU_NUM, "./ws2812.bin");
}

void StopPRU()
{
	ClearLed();
	usleep(350);
	LightLed(0, 0xF000000);
	// Wait for event completion from PRU, returns PRU_EVTOUT_0 number
	int n = prussdrv_pru_wait_event (PRU_EVTOUT_0);
	printf ("EBB PRU programa completed, event number %d.\n",n);

	// Disable PRU and close memory mappings
	prussdrv_pru_disable (PRU_NUM);
	prussdrv_exit ();
}

void LightLed(int led, unsigned int color)
{
    prussdrv_pru_write_memory(PRUSS0_PRU0_DATARAM, led, &color, 4);
}

void ClearLed()
{
	int t;
	for (t = 0; t < 12; t++)
	{
		LightLed(t, 0x000000);
	}
}
