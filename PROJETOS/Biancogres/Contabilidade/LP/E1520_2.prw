#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SE1_002        ºAutor  ³ BRUNO MADALENO     º Data ³  22/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ LANCAMENTO CONTABIL 520 002                                      º±±
±±º          ³  BAIXAS A RECEBER CLIENTE 										º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function E1520_2()
LOCAL NVALOR := 0
LOCAL VAL_DOL_B
LOCAL VAL_DOL_E

VAL_DOL_B := ROUND(SE1->E1_VALOR * SE5->E5_TXMOEDA,2) //XMOEDA(SE1->E1_VALOR,2,1,SE1->E1_BAIXA)
VAL_DOL_E := XMOEDA(SE1->E1_VALOR,2,1,SE1->E1_EMISSAO)

If SE1->E1_CORREC <> 0 
	NCM := SE1->E1_CORREC
EndIf

IF NCM > 0
	NVALOR := VAL_DOL_B - NCM
ELSE
 	NVALOR := VAL_DOL_B + (NCM* -1)
END IF
XX_B := ROUND(SE1->E1_DECRESC * SE5->E5_TXMOEDA,2) //(XMOEDA(SE1->E1_VALOR,2,1,SE1->E1_BAIXA)   / 100 ) * SE1->E1_COMIS1
XX_E := XMOEDA(SE1->E1_DECRESC,2,1,SE1->E1_EMISSAO) //(XMOEDA(SE1->E1_VALOR,2,1,SE1->E1_EMISSAO) / 100 ) * SE1->E1_COMIS1
                   
VC := XX_B - XX_E // PASSIVA  

IF VC < 0 // ATIVA
	NVALOR := NVALOR + (VC* -1)
ELSE
	NVALOR := NVALOR - VC
END IF

RETURN(NVALOR)