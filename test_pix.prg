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

cPIX_CHAVE := "+5519997283044"
cPIX_NOME := "EDUARDO MOTTA"        //Nome do Proprietario do PIX
cPIX_cidade := "NOVA ODESSA"      //Nome da Cidade do proprietario do PIX
cMsg := "PAGAMENTO"


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

#define		CRC_POLY_CCITT		0x1021

#define		CRC_START_CCITT_FFFF	0xFFFF

uint16_t		crc_ccitt_ffff(    const unsigned char *input_str, size_t num_bytes       );

#endif  // DEF_LIBCRC_CHECKSUM_H


static uint16_t		crc_ccitt_generic( const unsigned char *input_str, size_t num_bytes, uint16_t start_value );
static void             init_crcccitt_tab( void );

static bool             crc_tabccitt_init       = false;
static uint16_t         crc_tabccitt[256];

static bool		crc_tab_init		= false;
static uint16_t		crc_tab[256];

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

static bool             crc_tab16_init          = false;
static uint16_t         crc_tab16[256];


// ========================================================================
HB_FUNC( C_EMTCRC_CCITT_FFFF ) // cText --> nTextCRC
{
    hb_retnl( crc_ccitt_ffff( ( unsigned char *  ) hb_parc( 1 ), hb_parclen( 1 ) ) );

}

#pragma ENDDUMP
    