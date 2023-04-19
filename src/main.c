/* loop principal */

#define UARTBASE 0x101f1000     //registro base de la UART0
#define UARTTXBUF UARTBASE+0    //registro buffer de transmision

//-------------------------------------------------------------------
// funciones externas
//-------------------------------------------------------------------
void PUT32 ( unsigned int, unsigned int );
//-------------------------------------------------------------------
int main ( void )
{
    unsigned int ra;

    for(ra=0;;ra++)
    {
        ra&=7;
        PUT32(UARTTXBUF,0x30+ra);
    }

    return(0);
}
//-------------------------------------------------------------------
//-------------------------------------------------------------------
