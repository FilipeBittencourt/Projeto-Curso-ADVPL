#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF169
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Ferramenta para controlar Orçamento Clvl 
@obs Projeto: D-01 - Custos dos Projetos
@type Function
/*/

User Function BIAF169()
Private aRotina := {}
Private cCadastro := "Orçamento Clvl"
Private cAlias := "ZMC"
Private oObj := TWOrcamentoClvl():New()

	aAdd(aRotina, {"Pesquisar" , "PesqBrw", 0, 1})
	aAdd(aRotina, {"Visualizar", "U_BIAF169A", 0, 2})
	aAdd(aRotina, {"Incluir", "U_BIAF169A", 0, 3})
	aAdd(aRotina, {"Alterar", "U_BIAF169A", 0, 4})
	aAdd(aRotina, {"Excluir", "U_BIAF169A", 0, 5})		
	                                               
	DbSelectArea(cAlias)
	DbSetOrder(1)

	mBrowse(,,,,cAlias)

Return()


User Function BIAF169A(cAlias, nRecno, nOpc)
		
	If nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5 

		oObj:cCodigo := ZMC->ZMC_CODIGO
		oObj:cClvl := ZMC->ZMC_CLVL
		oObj:cItemCta := ZMC->ZMC_ITEMCT
			
	EndIf
	
	oObj:nFDOpc := nOpc
	
	oObj:Activate()
		
Return()


User Function BIAF169B()
Local lRet := .T.
Local cMField := ReadVar()
Local cMoeda := GdFieldGet("ZMD_MOEDA", n, .T.)
Local nValor := GdFieldGet("ZMD_VALOR", n, .T.)
Local nQuant := GdFieldGet("ZMD_QUANT", n, .T.)
Local nTotal := 0

	If cMField == "M->ZMD_VALOR" .Or. cMField == "M->ZMD_QUANT" .Or. cMField == "M->ZMD_MOEDA"
				
		If cMoeda == "2"
			
			nValor := nValor * M->ZMC_DOLAR
		
		ElseIf cMoeda == "3"
		
			nValor := nValor * M->ZMC_LIBRA
			
		ElseIf cMoeda == "4"
		
			nValor := nValor * M->ZMC_EURO	
		
		EndIf
		
		If nValor > 0
		
			nTotal := Round(nValor * nQuant, TamSX3("ZMD_TOTAL")[2])
			
			GdFieldPut("ZMD_TOTAL", nTotal, n)
			
		EndIf
		
	ElseIf cMField == "M->ZMD_SUBITE"

		oObjSub := TSubitemProjeto():New()

		oObjSub:cClvl := M->ZMC_CLVL
		oObjSub:cItemCta := M->ZMC_ITEMCT
		oObjSub:cSubItem := GdFieldGet("ZMD_SUBITE", n, .T.)
	
		If oObjSub:Validate()
			
			GdFieldPut("ZMD_DESC", oObjSub:GetDesc(), n)
			
		Else
			
			lRet := .F.
		
		EndIf
		
	EndIf	
			
Return(lRet)