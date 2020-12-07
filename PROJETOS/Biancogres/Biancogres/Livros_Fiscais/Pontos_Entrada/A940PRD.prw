#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A940PRD   ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A940PRD()
Private aProd 	:= Paramixb[3]
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

    If SB1->B1_RASTRO == "L"  //produtos novos
			If _RAC->IMPNF == "D"
				aProd	:= Substr(Paramixb[3],1,7)+"3"
			EndIf
  	Else											//produtos antigos
			If _RAC->IMPNF == "D"
				aProd	:= Substr(Paramixb[3],1,5)+"3"
			EndIf  
  	EndIf

	EndIf

EndIf

Return(aProd)