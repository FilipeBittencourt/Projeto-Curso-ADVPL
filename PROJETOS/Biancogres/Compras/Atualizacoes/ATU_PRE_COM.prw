#include "rwmake.ch"
#include "topconn.ch"
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪履哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o   矨TU_PRE_COM矨utor  � MADALENO              � Data � 06/11/06 潮�
北媚哪哪哪哪拍哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o� GATILHO PARA A VALIDACAO E O PREENCHIMENTO DA AMARRACAO     潮�
北�         � DO PRODUTO PELO FORNECEDOR                                  潮�
北媚哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪� 哪哪幢�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
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
		MSGBOX("PRECO COM AMARRA敲O","ALERTA", "INFO")
		IF c_PRO_FORN->A5_MOE_US = "US$"
			nPRECO := xMoeda(c_PRO_FORN->A5_YPRECO,2,1,ddatabase)
		ELSE
			nPRECO := c_PRO_FORN->A5_YPRECO
		ENDIF
	ENDIF	
ENDIF

RETURN(nPRECO)