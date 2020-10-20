#include "TOTVS.CH"
#include "XMLXFUN.CH"


/*/{Protheus.doc} LOJAY050
//TODO Rotina do Barter Póprio.
@author Facile Tecnologia e Soluções em Sistemas
@since 28/04/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function LOJAY050() //User Function BARTER()

//	If AllTrim(M->LQ_YCOND) $ SUPERGETMV('MV_YBARTER',.F.,'251') .AND. AllTrim(SM0->M0_CODFIL) $ SUPERGETMV('MV_YFILBAR',.F.,'01')
	If AllTrim(M->LQ_YCOND) $ SUPERGETMV('MV_YBARTER',.F.,'251') .AND. SUPERGETMV('MV_YFILBAR',.F.,.F.)
		Return  .T.
	else
		M->LQ_YTROCA  := Space(TamSX3('LQ_YTROCA')[01])
		M->LQ_YQTDTRO := 0
		M->LQ_YPRETRO := 0
	EndIf

Return .F.


/*/{Protheus.doc} LOJAY50A
//TODO Rotina do Barter Póprio.
@author Facile Tecnologia e Soluções em Sistemas
@since 28/04/2020
@version 1.0
@return ${return}, ${return_description}
@param lDeleta, logical, descricao
@type function
/*/

User Function __LOJAY50A(lDeleta) //User Function BARTERVA(lDeleta)
	
	Local cCampo 	:= ReadVar()

	Default lDeleta	:= .F.


	If cCampo == "M->LR_PRODUTO"
		Return M->LR_PRODUTO
	ElseIf	cCampo == "M->LR_QUANT"
		Return M->LR_QUANT
	Else
		Return M->LR_VALDESC
	EndIf

Return .T.


User Function LOJAY50A(lDeleta) //User Function BARTERVA(lDeleta)

	//Processo BARTER
	Local nTamHeader  	:= Len(aHeader)
	Local nTotItem    	:= 0
	Local nI          	:= 0
	Local lRet          := .T.
	Local lRefresh      := .F.

	Default lDeleta		:= .F.

//	If AllTrim(M->LQ_YCOND) $ SUPERGETMV('MV_YBARTER',.F.,'251') .AND. AllTrim(SM0->M0_CODFIL) $ SUPERGETMV('MV_YFILBAR',.F.,'01')
	If AllTrim(M->LQ_YCOND) $ SUPERGETMV('MV_YBARTER',.F.,'251') .AND. SUPERGETMV('MV_YFILBAR',.F.,.F.)

		If M->LQ_YPRETRO > 0

			For nI := 1 To Len(aCols)

				//|Tratamento para momento de deletar itens |
				If lDeleta .And. !aCols[nI,nTamHeader+1] .And. nI == oGetVA:oBrowse:nAt
					Loop
				EndIf

				//|Ignora deletados |
				If aCols[nI,nTamHeader+1] .And. !(lDeleta .And. nI == oGetVA:oBrowse:nAt)
					Loop
				EndIf

				//nTotItem  += (aCols[nI, GdFieldPos("LR_QUANT")] * aCols[nI, GdFieldPos("LR_VRUNIT")]) + aCols[nI, GdFieldPos("LR_YVLRACR")]  //(M->LR_QUANT * M->LR_VRUNIT) //aCols[nI, GdFieldPos("LR_VLRITEM")]
				nTotItem  += aCols[nI, GdFieldPos("LR_VLRITEM")]

			Next nI

			M->LQ_YQTDTRO := nTotItem/M->LQ_YPRETRO

			lRefresh := .T.		

		EndIf

	EndIf 
		
 
	For nI := 1 To Len(aCols)

		If valtype(aCols[nI, GdFieldPos("LR_VALDESC")]) == "C"
			aCols[nI, GdFieldPos("LR_VALDESC")] := 0
			lRefresh := .T.
		EndIf

	Next nI 

	If lRefresh		
		oDlgVA:Refresh(.T.)
		eval(oDlgva:bInit)
		oGetVA:oBrowse:SetFocus(GetFocus(oGetVA:oBrowse))
	EndIf


Return lRet


/*/{Protheus.doc} LOJAY50B
//TODO Rotina do Barter Póprio.
@author Facile Tecnologia e Soluções em Sistemas
@since 28/04/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function BARTERVL() //User Function LOJAY50B()

	Local lRet		:= .T.

//	If AllTrim(M->LQ_YCOND) $ SUPERGETMV('MV_YBARTER',.F.,'251') .AND. AllTrim(SM0->M0_CODFIL) $ SUPERGETMV('MV_YFILBAR',.F.,'01')
	If AllTrim(M->LQ_YCOND) $ SUPERGETMV('MV_YBARTER',.F.,'251') .AND. SUPERGETMV('MV_YFILBAR',.F.,.F.)

		If Empty(M->LQ_YTROCA)
			MsgStop("Em processo de Barter é obrigatório informar o produto da troca no cabeçalho","LOJAY50B")
			lRet	:= .F.
		EndIf

	EndIf

Return lRet


 
 
