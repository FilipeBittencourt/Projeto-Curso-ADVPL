#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} MT010INC
@author Ranisses A. Corona
@since 29/09/05
@version 1.0
@description Grava os campos de Grupo de Tributacao e Percentual de ICMS Substituicao Tributaria para produtos PA para MG
@history 29/09/05, Marcos Alberto Soprani, As funções originais já estavam comentadas a tempo: forma retiradas Deixadas apenas as instruções ativas
@type function
/*/

// Fonte Descontinuado - MVC_ITEM

/*
User function MT010INC()

	If Alltrim(SB1->B1_TIPO) $ GetMv("MV_YEXPECO") .And. (Substr(Alltrim(SB1->B1_COD),Len(Alltrim(SB1->B1_COD)),1) $ "1_2_3")

		Processa({|| U_EXPECO(1)})

	EndIf

	//Projeto PDM - Fernando em 14/08/2018 - Gravar dados das caracteristicas do PDM relacionado ao produto. Vem da classe TPDMProduto após tela de seleção
	If !Empty(SB1->B1_YPDM) .And. Type("__MEMPDM_ALST") <> "U"

		oPDMPrd := TPDMProduto():New()		
		oPDMPrd:Tipo := SB1->B1_TIPO

		If ( oPDMPrd:SetPDM(SB1->B1_YGRPPDM, SB1->B1_YSUBPDM, SB1->B1_YFAMPDM) )

			oPDMPrd:aLstValCar := AClone(__MEMPDM_ALST)

			oPDMPrd:IncluiZD7(SB1->B1_COD)

			__MEMPDM_ALST := Nil

		EndIf

	EndIf
	
	If Type("_ObjCrePd_") == "O"
	
		_ObjCrePd_:SalvarMarca()
		
		_ObjCrePd_ := Nil
	
	EndIf



	If SB1->B1_TIPO == "PA" .and. SB1->B1_YCLASSE = "1"

			U_BIA736Prc(SB1->B1_COD, SB1->B1_COD)

	EndIf

Return/*