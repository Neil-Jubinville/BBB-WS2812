#include <stdio.h>
#include <unistd.h>
#include "ws2812.h"

void main (void)
{
	int t;

	RunPRU();

	for (t = 0; t < 12; t++)
	{
		usleep(100000);
		LightLed(t, 0x00F000);
	}
	sleep(1);
	StopPRU();
}
