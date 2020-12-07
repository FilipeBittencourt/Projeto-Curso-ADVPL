#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A940DES   ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A940DES()
Private aProd		:= SB1->B1_COD  //Paramixb[3]
Private aDescr	:= Alltrim(SB1->B1_DESC) //Posicione("SB1",1,xFilial("SB1")+aProd,"B1_DESC")
Private cSql		:= ""
Private Enter		:= CHR(13)+CHR(10)    

If cEmpAnt == "05" //Apenas para Incesa

	If Paramixb[1] == "S" //Apenas para NF de Saida

		cSql := "SELECT	MAX(D2_YIMPNF) AS IMPNF, MAX(D2_EMISSAO) AS EMISSAO	" + Enter
		cSql += "FROM	SD2050 																		" + Enter
		cSql += "WHERE	D2_FILIAL		= '"+xFilial("SD2")+"'	AND " + Enter
		cSql += "				D2_DOC			= '"+SF2->F2_DOC+"'			AND " + Enter
		cSql += "				D2_SERIE 		= '"+SF2->F2_SERIE+"'		AND " + Enter
		cSql += "				D2_CLIENTE	= '"+SF2->F2_CLIENTE+"'	AND " + Enter
		cSql += "				D2_LOJA			= '"+SF2->F2_LOJA+"'		AND " + Enter
		cSql += "				D2_COD 			= '"+aProd+"'		 				AND " + Enter
		cSql += "				D_E_L_E_T_	= '' 												" + Enter
		If chkfile("_RAC")
			dbSelectArea("_RAC")
			dbCloseArea()
		EndIf
		TCQUERY cSql NEW ALIAS "_RAC"

		If _RAC->IMPNF == "D"
			aDescr	:= Substr(aDescr,1,LEN(aDescr)-2)
		EndIf  

	EndIf

EndIf

Return(aDescr)