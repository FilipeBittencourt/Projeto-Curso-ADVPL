#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³ATU_PRE_COM³Autor  ³ MADALENO              ³ Data ³ 06/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ GATILHO PARA A VALIDACAO E O PREENCHIMENTO DA AMARRACAO     ³±±
±±³         ³ DO PRODUTO PELO FORNECEDOR                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION ATU_PRE_COM()
LOCAL CSQL := ""
LOCAL sPOS := ""
LOCAL sPRODUTO := ""
LOCAL nPRECO

sPOS := aScan(aHeader,{|x| x[2]=="C7_PRODUTO"})
sPRODUTO := ACOLS[N,sPOS]

sPOS := aScan(aHeader,{|x| x[2]=="C7_PRECO  "})
nPRECO := ACOLS[N,sPOS]

CSQL := "SELECT A5_YPRECO, A5_MOE_US FROM SA5010 "
CSQL += "WHERE 	A5_FORNECE = '"+CA120FORN+"'  AND "
CSQL += "		A5_PRODUTO = '"+sPRODUTO+"' AND "
CSQL += "		D_E_L_E_T_ = '' "
If chkfile("c_PRO_FORN")
	dbSelectArea("c_PRO_FORN")
	dbCloseArea()
EndIf
TCQUERY CSQL ALIAS "c_PRO_FORN" NEW

IF ! c_PRO_FORN->(EOF())
	IF c_PRO_FORN->A5_YPRECO <> 0
		MSGBOX("PRECO COM AMARRAÇÃO","ALERTA", "INFO")
		IF c_PRO_FORN->A5_MOE_US = "US$"
			nPRECO := xMoeda(c_PRO_FORN->A5_YPRECO,2,1,ddatabase)
		ELSE
			nPRECO := c_PRO_FORN->A5_YPRECO
		ENDIF
	ENDIF	
ENDIF

RETURN(nPRECO)