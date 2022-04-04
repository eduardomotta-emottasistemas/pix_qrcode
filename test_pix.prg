/*
Para testar a chave use o site:
https://www.gerarpix.com.br/

*/

Function u_Teste()
Local nValor := 1.00 //Valor do PIX
Local cPIX_CHAVE := "+5511999991234"  // chave pix
Local cPIX_NOME := "NOME DA PESSOA"        //Nome do Proprietario do PIX
Local cPIX_cidade := "SAO PAULO"      //Nome da Cidade do proprietario do PIX
Local cMsg := "PAGAMENTO"
Local cBmp_QRCode := "pix.bmp"

cMsg            := '05'+ strzero(len(alltrim(left(alltrim(cMsg),21))),2) + left(alltrim(cMsg),21)  //Reference label até 25 caracteres.
nTamChave       := 22 + len(alltrim(cPIX_CHAVE))  //Tamanho da chave para ser colocado no registro 26

cString   := '000201'  //Inicio do código para gerar o Qr-Code
cString += '26'+strzero(nTamChave,2)+'0014BR.GOV.BCB.PIX01'+ strzero(len(alltrim(cPIX_CHAVE)),2) + alltrim(cPIX_CHAVE)
cString += '52040000'
cString += '5303986'
cString += '54' + strzero(len(alltrim(str(nValor))),2) + alltrim(str(nValor))
cString += '5802BR'
cString += '59' + strzero(len(alltrim(cPIX_NOME)),2) + alltrim(cPIX_NOME) //Merchant Name até 25 caracteres.
cString += '60' + strzero(len(left(alltrim(cPIX_cidade),15)),2) + alltrim(left(cPIX_cidade,15)) //City Name até 15 caracteres.
cString += '62' + strzero(len(cMsg),2) + cMsg
cString += '6304'
cString += EMTCRC_CCITT_FFFF(cString)

QRcode(cString, cBmp_QRCode)

MsgStop(cString)

Return


// TUDO DAQUI PRA BAIXO COLOQUE NA SUA LIB DE FUNCOES GENÉRICAS OU CRIE UMA CHAMADA FUNCOES_PIX.PRG

#include "fivewin.ch"

#Define DC_CALL_STD 0x0020

FUNCTION QRcode(cStr,cFile)
LOCAL qrDLL

Generar_QR(cStr,cFile)

RETURN(NIL)

Function Generar_QR(cStr,cFile)
LOCAL nResp
LOCAL qrDLL
qrDLL:=LoadLibrary("QRCodelib.Dll" )
nResp:=DllCall(qrDLL,DC_CALL_STD,"FastQRCode",cStr,cFile)
FreeLibrary(qrDLL)
RETURN (NIL)


Function EMTCRC_CCITT_FFFF(cTexto)
Local cCrc,nCrc
nCrc := C_EMTCRC_CCITT_FFFF(cTexto)
cCrc := NumToHex(nCrc)
cCrc := PadL(NumToHex(nCrc), 4, "0")
Return cCrc

#pragma BEGINDUMP
#include "windows.h"
#include "hbapi.h"
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

#ifndef DEF_LIBCRC_CHECKSUM_H
#define DEF_LIBCRC_CHECKSUM_H


#define		CRC_POLY_16		0xA001
#define		CRC_POLY_32		0xEDB88320L
#define		CRC_POLY_CCITT		0x1021
#define		CRC_POLY_DNP		0xA6BC
#define		CRC_POLY_KERMIT		0x8408
#define		CRC_POLY_SICK		0x8005

#define		CRC_START_8		0x00
#define		CRC_START_16		0x0000
#define		CRC_START_MODBUS	0xFFFF
#define		CRC_START_XMODEM	0x0000
#define		CRC_START_CCITT_1D0F	0x1D0F
#define		CRC_START_CCITT_FFFF	0xFFFF
#define		CRC_START_KERMIT	0x0000
#define		CRC_START_SICK		0x0000
#define		CRC_START_DNP		0x0000
#define		CRC_START_32		0xFFFFFFFFL

unsigned char *		checksum_NMEA(     const unsigned char *input_str, unsigned char *result  );
uint8_t			crc_8(             const unsigned char *input_str, size_t num_bytes       );
uint16_t		crc_16(            const unsigned char *input_str, size_t num_bytes       );
uint32_t		crc_32(            const unsigned char *input_str, size_t num_bytes       );
uint16_t		crc_ccitt_1d0f(    const unsigned char *input_str, size_t num_bytes       );
uint16_t		crc_ccitt_ffff(    const unsigned char *input_str, size_t num_bytes       );
uint16_t		crc_dnp(           const unsigned char *input_str, size_t num_bytes       );
uint16_t		crc_kermit(        const unsigned char *input_str, size_t num_bytes       );
uint16_t		crc_modbus(        const unsigned char *input_str, size_t num_bytes       );
uint16_t		crc_sick(          const unsigned char *input_str, size_t num_bytes       );
uint16_t		crc_xmodem(        const unsigned char *input_str, size_t num_bytes       );
uint8_t			update_crc_8(      uint8_t  crc, unsigned char c                          );
uint16_t		update_crc_16(     uint16_t crc, unsigned char c                          );
uint32_t		update_crc_32(     uint32_t crc, unsigned char c                          );
uint16_t		update_crc_ccitt(  uint16_t crc, unsigned char c                          );
uint16_t		update_crc_dnp(    uint16_t crc, unsigned char c                          );
uint16_t		update_crc_kermit( uint16_t crc, unsigned char c                          );
uint16_t		update_crc_sick(   uint16_t crc, unsigned char c, unsigned char prev_byte );

#endif  // DEF_LIBCRC_CHECKSUM_H


static uint16_t		crc_ccitt_generic( const unsigned char *input_str, size_t num_bytes, uint16_t start_value );
static void             init_crcccitt_tab( void );

static bool             crc_tabccitt_init       = false;
static uint16_t         crc_tabccitt[256];

static void		init_crc_tab( void );

static bool		crc_tab_init		= false;
static uint16_t		crc_tab[256];

/*
    * uint16_t crc_xmodem( const unsigned char *input_str, size_t num_bytes );
    *
    * The function crc_xmodem() performs a one-pass calculation of an X-Modem CRC
    * for a byte string that has been passed as a parameter.
    */

uint16_t crc_xmodem( const unsigned char *input_str, size_t num_bytes ) {

    return crc_ccitt_generic( input_str, num_bytes, CRC_START_XMODEM );

}  /* crc_xmodem */

/*
    * uint16_t crc_ccitt_1d0f( const unsigned char *input_str, size_t num_bytes );
    *
    * The function crc_ccitt_1d0f() performs a one-pass calculation of the CCITT
    * CRC for a byte string that has been passed as a parameter. The initial value
    * 0x1d0f is used for the CRC.
    */

uint16_t crc_ccitt_1d0f( const unsigned char *input_str, size_t num_bytes ) {

    return crc_ccitt_generic( input_str, num_bytes, CRC_START_CCITT_1D0F );

}  /* crc_ccitt_1d0f */

/*
    * uint16_t crc_ccitt_ffff( const unsigned char *input_str, size_t num_bytes );
    *
    * The function crc_ccitt_ffff() performs a one-pass calculation of the CCITT
    * CRC for a byte string that has been passed as a parameter. The initial value
    * 0xffff is used for the CRC.
    */

uint16_t crc_ccitt_ffff( const unsigned char *input_str, size_t num_bytes ) {

    return crc_ccitt_generic( input_str, num_bytes, CRC_START_CCITT_FFFF );

}  /* crc_ccitt_ffff */

/*
    * static uint16_t crc_ccitt_generic( const unsigned char *input_str, size_t num_bytes, uint16_t start_value );
    *
    * The function crc_ccitt_generic() is a generic implementation of the CCITT
    * algorithm for a one-pass calculation of the CRC for a byte string. The
    * function accepts an initial start value for the crc.
    */

static uint16_t crc_ccitt_generic( const unsigned char *input_str, size_t num_bytes, uint16_t start_value ) {

    uint16_t crc;
    uint16_t tmp;
    uint16_t short_c;
    const unsigned char *ptr;
    size_t a;

    if ( ! crc_tabccitt_init ) init_crcccitt_tab();

    crc = start_value;
    ptr = input_str;

    if ( ptr != NULL ) for (a=0; a<num_bytes; a++) {

        short_c = 0x00ff & (unsigned short) *ptr;
        tmp     = (crc >> 8) ^ short_c;
        crc     = (crc << 8) ^ crc_tabccitt[tmp];

        ptr++;
    }

    return crc;

}  /* crc_ccitt_generic */

/*
    * uint16_t update_crc_ccitt( uint16_t crc, unsigned char c );
    *
    * The function update_crc_ccitt() calculates a new CRC-CCITT value based on
    * the previous value of the CRC and the next byte of the data to be checked.
    */

uint16_t update_crc_ccitt( uint16_t crc, unsigned char c ) {

    int16_t tmp;
    int16_t short_c;

    short_c  = 0x00ff & (uint16_t) c;

    if ( ! crc_tabccitt_init ) init_crcccitt_tab();

    tmp = (crc >> 8) ^ short_c;
    crc = (crc << 8) ^ crc_tabccitt[tmp];

    return crc;

}  /* update_crc_ccitt */

/*
    * static void init_crcccitt_tab( void );
    *
    * For optimal performance, the routine to calculate the CRC-CCITT uses a
    * lookup table with pre-compiled values that can be directly applied in the
    * XOR action. This table is created at the first call of the function by the
    * init_crcccitt_tab() routine.
    */

static void init_crcccitt_tab( void ) {

    uint16_t i;
    uint16_t j;
    uint16_t crc;
    uint16_t c;

    for (i=0; i<256; i++) {

        crc = 0;
        c   = i << 8;

        for (j=0; j<8; j++) {

            if ( (crc ^ c) & 0x8000 ) crc = ( crc << 1 ) ^ CRC_POLY_CCITT;
            else                      crc =   crc << 1;

            c = c << 1;
        }

        crc_tabccitt[i] = crc;
    }

    crc_tabccitt_init = true;

}
// ========================================================================

static void             init_crc16_tab( void );

static bool             crc_tab16_init          = false;
static uint16_t         crc_tab16[256];

/*
    * uint16_t crc_16( const unsigned char *input_str, size_t num_bytes );
    *
    * The function crc_16() calculates the 16 bits CRC16 in one pass for a byte
    * string of which the beginning has been passed to the function. The number of
    * bytes to check is also a parameter. The number of the bytes in the string is
    * limited by the constant SIZE_MAX.
    */

uint16_t crc_16( const unsigned char *input_str, size_t num_bytes ) {

    uint16_t crc;
    uint16_t tmp;
    uint16_t short_c;
    const unsigned char *ptr;
    size_t a;

    if ( ! crc_tab16_init ) init_crc16_tab();

    crc = CRC_START_16;
    ptr = input_str;

    if ( ptr != NULL ) for (a=0; a<num_bytes; a++) {

        short_c = 0x00ff & (uint16_t) *ptr;
        tmp     =  crc       ^ short_c;
        crc     = (crc >> 8) ^ crc_tab16[ tmp & 0xff ];

        ptr++;
    }

    return crc;

}  /* crc_16 */

/*
    * uint16_t crc_modbus( const unsigned char *input_str, size_t num_bytes );
    *
    * The function crc_modbus() calculates the 16 bits Modbus CRC in one pass for
    * a byte string of which the beginning has been passed to the function. The
    * number of bytes to check is also a parameter.
    */

uint16_t crc_modbus( const unsigned char *input_str, size_t num_bytes ) {

    uint16_t crc;
    uint16_t tmp;
    uint16_t short_c;
    const unsigned char *ptr;
    size_t a;

    if ( ! crc_tab16_init ) init_crc16_tab();

    crc = CRC_START_MODBUS;
    ptr = input_str;

    if ( ptr != NULL ) for (a=0; a<num_bytes; a++) {

        short_c = 0x00ff & (uint16_t) *ptr;
        tmp     =  crc       ^ short_c;
        crc     = (crc >> 8) ^ crc_tab16[ tmp & 0xff ];

        ptr++;
    }

    return crc;

}  /* crc_modbus */


/*
    * uint16_t crc_kermit( const unsigned char *input_str, size_t num_bytes );
    *
    * The function crc_kermit() calculates the 16 bits Kermit CRC in one pass for
    * a byte string of which the beginning has been passed to the function. The
    * number of bytes to check is also a parameter.
    */

    uint16_t crc_kermit( const unsigned char *input_str, size_t num_bytes ) {

uint16_t crc;
uint16_t low_byte;
uint16_t high_byte;
const unsigned char *ptr;
size_t a;

if ( ! crc_tab_init ) init_crc_tab();

crc = CRC_START_KERMIT;
ptr = input_str;

if ( ptr != NULL ) for (a=0; a<num_bytes; a++) {

    crc = (crc >> 8) ^ crc_tab[ (crc ^ (uint16_t) *ptr++) & 0x00FF ];
}

low_byte  = (crc & 0xff00) >> 8;
high_byte = (crc & 0x00ff) << 8;
crc       = low_byte | high_byte;

return crc;

}  /* crc_kermit */

/*
* static void init_crc_tab( void );
*
* For optimal performance, the  CRC Kermit routine uses a lookup table with
* values that can be used directly in the XOR arithmetic in the algorithm.
* This lookup table is calculated by the init_crc_tab() routine, the first
* time the CRC function is called.
*/

static void init_crc_tab( void ) {

uint16_t i;
uint16_t j;
uint16_t crc;
uint16_t c;

for (i=0; i<256; i++) {

    crc = 0;
    c   = i;

    for (j=0; j<8; j++) {

        if ( (crc ^ c) & 0x0001 ) crc = ( crc >> 1 ) ^ CRC_POLY_KERMIT;
        else                      crc =   crc >> 1;

        c = c >> 1;
    }

    crc_tab[i] = crc;
}

crc_tab_init = true;

}  /* init_crc_tab */


/*
    * uint16_t update_crc_16( uint16_t crc, unsigned char c );
    *
    * The function update_crc_16() calculates a new CRC-16 value based on the
    * previous value of the CRC and the next byte of data to be checked.
    */

uint16_t update_crc_16( uint16_t crc, unsigned char c ) {

    uint16_t tmp;
    uint16_t short_c;

    short_c = 0x00ff & (uint16_t) c;

    if ( ! crc_tab16_init ) init_crc16_tab();

    tmp =  crc       ^ short_c;
    crc = (crc >> 8) ^ crc_tab16[ tmp & 0xff ];

    return crc;

}  /* update_crc_16 */

/*
    * static void init_crc16_tab( void );
    *
    * For optimal performance uses the CRC16 routine a lookup table with values
    * that can be used directly in the XOR arithmetic in the algorithm. This
    * lookup table is calculated by the init_crc16_tab() routine, the first time
    * the CRC function is called.
    */

static void init_crc16_tab( void ) {

    uint16_t i;
    uint16_t j;
    uint16_t crc;
    uint16_t c;

    for (i=0; i<256; i++) {

        crc = 0;
        c   = i;

        for (j=0; j<8; j++) {

            if ( (crc ^ c) & 0x0001 ) crc = ( crc >> 1 ) ^ CRC_POLY_16;
            else                      crc =   crc >> 1;

            c = c >> 1;
        }

        crc_tab16[i] = crc;
    }

    crc_tab16_init = true;

}  /* init_crc16_tab */


// ========================================================================
HB_FUNC( C_EMTCRC_CCITT_FFFF ) // cText --> nTextCRC
{
    hb_retnl( crc_ccitt_ffff( ( unsigned char *  ) hb_parc( 1 ), hb_parclen( 1 ) ) );

}

#pragma ENDDUMP
    