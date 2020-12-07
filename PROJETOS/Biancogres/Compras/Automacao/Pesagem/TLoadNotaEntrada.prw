#Include "TOTVS.CH"
#Include "Protheus.CH"

Class TLoadNotaEntrada from LongClassName
	
	Public Data oNotaResulStruct
	Public Data lLoadPedido
	
	
	Public Method New() Constructor

	Public Method GetSD2()
		
EndClass


Method New(_lLoadPedido) Class TLoadNotaEntrada
	
	Default _lLoadPedido := .F.
	
	::lLoadPedido = _lLoadPedido
Return

Method GetSD2(cChave) Class TLoadNotaEntrada
	
	Local oNotaStruct		:= TNotaStruct():New()
	Local oNotaResulStruct 	:= TNotaResulStruct():New()
	
	Local lOk		:= .T.
	Local cMsgLog	:= ""
	
	DbSelectArea("SF1")
	SF1->(DbSetOrder(8))
	
	If SF1->(DbSeek(xFilial('SF1')+PADR(cChave, TamSx3("F1_CHVNFE")[1])))
		
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		
		oNotaStruct:cDoc			:= ""
		oNotaStruct:cSerie			:= ""
		oNotaStruct:cChave			:= ""
		oNotaStruct:dDataEmissao	:= "" 
		oNotaStruct:cFornece		:= ""
		oNotaStruct:cLoja			:= ""
		
		
		If SD1->(DbSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+ SF1->F1_FORNECE+ SF1->F1_LOJA))
			
			While ;
					!(SD1->(Eof())) .And. ; 
					SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+ SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA  
					
	
						oNotaItemStruct 			:= TNotaItemStruct():New()
					 	oNotaItemStruct:cProduto	:= SD1->D1_COD
					 	oNotaItemStruct:nQuantidade	:= SD1->D1_QUANT
					 	oNotaItemStruct:nValor		:= SD1->D1_VUNIT
					 	oNotaItemStruct:nTotal		:= SD1->D1_TOTAL
					 	oNotaItemStruct:cTes		:= SD1->D1_TES
					 	oNotaItemStruct:cNfOri		:= SD1->D1_DOC
					 	oNotaItemStruct:cSerieOri	:= SD1->D1_SERIE
					 	
					 	DbSelectArea("SA5")
						SA5->(DbSetOrder(2))
						If SA5->(DbSeek(xFilial("SA5")+SD1->D1_COD+SF1->F1_FORNECE+SF1->F1_LOJA))
							oNotaItemStruct:cTes  := SA5->A5_YTESFRE
						EndIf
					 	
					 	
					 	If (::lLoadPedido)
						 	oPCAberto 			:= TPCAberto():New()
							oPCAResultStruct	:= oPCAberto:GetPorForProd(SD1->D1_FORNECE, SD1->D1_LOJA, oNotaItemStruct:cProduto, oNotaItemStruct:nQuantidade)
							
							If (oPCAResultStruct:lOk)
								
								oNotaItemStruct:cPedido		:= oPCAResultStruct:oResult:cNumero
								oNotaItemStruct:cItemPed	:= oPCAResultStruct:oResult:cItem
								oNotaItemStruct:cLocal		:= oPCAResultStruct:oResult:cLocal
								
							Else
								
								cMsgLog	:= oPCAResultStruct:cMensagem + CRLF
								lOk		:= .F.	
				 		
							EndIf
						EndIf
					 	
					 	oNotaStruct:oNotaItens:Add(oNotaItemStruct)
				SD1->(DbSkip())	 	
			EndDo
			
		EndIf
		
	Else
		
		lOk			:= .F.
		cMsgLog 	:= "[NFe: "+cChave+"] => não encontrada."
		
	EndIf
		
	If (lOk)
		oNotaResulStruct:Add(lOk, cMsgLog, oNotaStruct)
	Else
		oNotaResulStruct:Add(lOk, cMsgLog, Nil)
	EndIf
	
	::oNotaResulStruct := oNotaResulStruct

Return(oNotaResulStruct)
