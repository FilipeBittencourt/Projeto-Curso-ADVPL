#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ E1520_9        ºAutor  ³ BRUNO MADALENO     º Data ³  22/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ LANCAMENTO CONTABIL 520 003                                      º±±
±±º          ³ VARIACAO CAMBIAL PASSIVA COMISSAO           						º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function E1520_9()
LOCAL NVALOR := 0
LOCAL VAL_DOL_B
LOCAL VAL_DOL_E

VAL_DOL_B := ROUND(SE1->E1_DECRESC * SE5->E5_TXMOEDA,2)  //ROUND(SE1->E1_VALOR * SE5->E5_TXMOEDA,2) //(XMOEDA(SE1->E1_VALOR,2,1,SE1->E1_BAIXA)   / 100 ) * SE1->E1_COMIS1
VAL_DOL_E := XMOEDA(SE1->E1_DECRESC,2,1,SE1->E1_EMISSAO) //XMOEDA(SE1->E1_DECRESC,2,1,SE1->E1_EMISSAO) //(XMOEDA(SE1->E1_VALOR,2,1,SE1->E1_EMISSAO) / 100 ) * SE1->E1_COMIS1

IF VAL_DOL_B > VAL_DOL_E // BAIXA PASSIVA
	NVALOR := VAL_DOL_B - VAL_DOL_E 
END IF

RETURN(NVALOR)