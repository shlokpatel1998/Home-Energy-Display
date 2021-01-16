// Standard C Included Files
#include <stdio.h>
#include <stdlib.h>
// SDK Included Files
#include "board.h"
#include "gpio_pins.h"
#include "fsl_debug_console.h"
#include <cstddef>


///////////////////////////////////////////////////////////////////////////////
// Variables
///////////////////////////////////////////////////////////////////////////////
int array[720];
extern void asmmain(void);

void myfprint(char *d) {
	PRINTF("%s\r\n",d);
}

void myMenuPrint() {
	printf("PRESS 1: ENERGY CONSUMPTION PER HOUR\r\n");
	printf("PRESS 2: ENERGY CONSUMPTION PER DAY\r\n");
	printf("PRESS 3: ENERGY CONSUMPTION PER WEEK\r\n");
}

void myintprint(int d) {
	PRINTF("%d\r\n", d);
}

void myputchar(char c){
	PUTCHAR(c);
}
void mygetchar(){
	GETCHAR();
}

int getkWh(){
	int r = (rand() % 200) + 950;
	return r;
}

void initArray() {
	for(int i=0; i < 720; i++) {
		array[i] = getkWh();
	}
}

int getElement(int index) {
	return array[index];
}
int main(void)
{
	
    // Init hardware
	initArray();
  hardware_init();
	asmmain();
}

/*******************************************************************************
 * EOF
 ******************************************************************************/