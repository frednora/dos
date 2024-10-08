/*
 * File: timer.c 
 * Descri��o:
 *     Handler da irq0 para o Boot Loader.
 * Environment:
 *     32bit bootloader.
 * ATEN��O:
 *    O timer no Boot Loader n�o faz task switch.
 *    O timer ser� usado principalmente para timeout de driver.
 *    O timer pode ser usado para contar tempo de inicializa��o.
 * 2015 - Created by Fred Nora.
 */


#include <bootloader.h>

unsigned long timerTicks=0;

// irq handler.
// Increment jiffies.
void timer()
{
    timerTicks++;
    //if ( timerTicks % 100 == 0 )
    //{
        // Nothing ...
    //}
}

// blTimerInit:
// Inicializa o m�dulo timer.
int blTimerInit()
{
    int Status=0;

    timerTicks = 0;
    //...
    return (int) Status;
}

//
// End
//

