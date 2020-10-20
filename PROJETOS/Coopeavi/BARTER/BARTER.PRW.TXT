#include "TOTVS.CH"
#include "XMLXFUN.CH"

User Function BARTER()	

	If AllTrim(M->LQ_YCOND) $ SUPERGETMV('MV_YBARTER',.F.,'251') .AND. AllTrim(SM0->M0_CODFIL) $ SUPERGETMV('MV_YFILBAR',.F.,'01')
		Return  .T.
	else
		M->LQ_YTROCA  := Space(TamSX3('LQ_YTROCA')[01])
		M->LQ_YQTDTRO := 0
		M->LQ_YPRETRO := 0
	EndIf	 


Return .F.


User Function BARTERVA(lDeleta)	

	//Processo BARTER
	Local nTamHeader  	:= Len(aHeader)
	Local nTotItem    	:= 0
	Local nI          	:= 0

	Default lDeleta		:= .F.
	
	If AllTrim(M->LQ_YCOND) $ SUPERGETMV('MV_YBARTER',.F.,'251') .AND. AllTrim(SM0->M0_CODFIL) $ SUPERGETMV('MV_YFILBAR',.F.,'01')
		
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

			oDlgVA:Refresh(.T.)
			eval(oDlgva:bInit)				
			oGetVA:oBrowse:SetFocus(GetFocus(oGetVA:oBrowse))				 						 

		EndIf

	EndIf 


Return .T.


User Function BARTERVL()	

	Local lRet		:= .T.

	If AllTrim(M->LQ_YCOND) $ SUPERGETMV('MV_YBARTER',.F.,'251') .AND. AllTrim(SM0->M0_CODFIL) $ SUPERGETMV('MV_YFILBAR',.F.,'01')

		If Empty(M->LQ_YTROCA)
			MsgStop("Em processo de Barter é obrigatório informar o produto da troca no cabeçalho","BARTERVL")
			lRet	:= .F.
		EndIf

	EndIf

Return lRet