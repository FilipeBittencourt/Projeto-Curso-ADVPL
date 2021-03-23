#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF163
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Filtro na consulta padrao de subitem de projeto 
@obs Projeto: D-01 - Custos dos Projetos
@type Function
/*/

User Function BIAF163()
Local cRet := ""
Local cCodRef := ""
Local cClvl := ""
Local cItemCta := ""
Local cField := ReadVar()
Local oObj := TSubitemProjeto():New()

	Do Case
		
		Case cField == "M->D3_YSUBITE"
		
			If ISINCALLSTACK("MATA241") // Movimentos Múltiplos
			
				cClvl	:= aCV[1][2]	
				cItemCta := GdFieldGet("D3_ITEMCTA", n)
				
			Else
			
				cClvl	:= M->D3_CLVL
				cItemCta := M->D3_ITEMCTA 
				 
			EndIf
		
		Case cField == "M->D1_YSUBITE"
			
			cClvl	:= GdFieldGet("D1_CLVL",n)
			cItemCta := GdFieldGet("D1_ITEMCTA", n)

		Case cField == "M->C1_YSUBITE"
			
			cClvl	:= GdFieldGet("C1_CLVL", n)
			cItemCta := GdFieldGet("C1_ITEMCTA", n)
			
		Case cField == "M->C7_YSUBITE"
			
			cClvl	:= GdFieldGet("C7_CLVL", n)
			cItemCta := GdFieldGet("C7_ITEMCTA", n)

		Case cField == "M->E5_YSUBDB"
			
			cClvl	:= M->E5_CLVLDB
			cItemCta := M->E5_ITEMD

		Case cField == "M->E5_YSUBCR"
			
			cClvl	:= M->E5_CLVLCR
			cItemCta := M->E5_ITEMC
		
		Case cField == "M->CT2_YSUBDB"
			
			cClvl	:= TMP->CT2_CLVLDB
			cItemCta := TMP->CT2_ITEMD

		Case cField == "M->CT2_YSUBCR"
			
			cClvl	:= TMP->CT2_CLVLCR
			cItemCta := TMP->CT2_ITEMC

		Case cField == "M->E2_YSUBITE"

			cClvl	:= M->E2_CLVL
			cItemCta := M->E2_ITEMCTA
			
		Case cField == "M->C3_YSUBITE"

			cClvl	:= GdFieldGet("C3_YCLVL", n)
			cItemCta := GdFieldGet("C3_YITEMCT", n)
	
		Case cField == "M->ZMD_SUBITE"

			cClvl	:= M->ZMC_CLVL
			cItemCta := M->ZMC_ITEMCT			

	EndCase

	oObj:cClvl := cClvl
	oObj:cItemCta := cItemCta
	
	cCodRef := oObj:GetCod()
	
	cRet	+= "@#"
	cRet	+= "ZMB->("
	cRet	+= "ZMB_FILIAL =='"+ xFilial("ZMB") +"'"
	cRet	+= ".AND. ZMB_CODREF =='" + cCodRef +"'"
	cRet	+= ")"
	cRet	+= "@#"	
	
Return(cRet)