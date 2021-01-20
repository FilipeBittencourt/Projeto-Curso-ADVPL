#Include "TOTVS.CH"
#Include "Protheus.CH"
#INCLUDE "XMLXFUN.CH"

Class TLoadXMLNFe from LongClassName

	Public Data cBuffer
	Public Data oNotaResulStruct
	
	Public Method New() Constructor

	Public Method GetNFe()
	
	
EndClass

Method New(_cBuffer) Class TLoadXMLNFe
	
	::cBuffer 			:= _cBuffer
	::oNotaResulStruct	:= Nil
	
Return

Method GetNFe() Class TLoadXMLNFe
	
	Local oNF				:= Nil
	Local oEmitente 		:= Nil
	Local oIdent    		:= Nil
	Local oDestino  		:= Nil
	Local oTotal    		:= Nil
	Local oTransp   		:= Nil
	Local oDet      		:= Nil 
	
	Local cData				:= ""
	Local cProdXML			:= ""
	Local cCgc				:= ""
	
	Local oNotaStruct		:= TNotaStruct():New()
	Local oNotaResulStruct 	:= TNotaResulStruct():New()
	
	Local cLogMsg			:= ""
	Local lRet				:= .T.
	
	Local nI				:= 0
	
	
	cAviso 		:= ""
	cErro  		:= ""
	oNfe   		:= XmlParser(::cBuffer,"_", @cAviso,@cErro)

	If (oNfe <> Nil)
	
		If Type("oNFe:_NfeProc") <> "U"
			oNF := oNFe:_NFeProc:_NFe
		Else
			oNF := oNFe:_NFe
		EndIf
		
		oEmitente  := oNF:_InfNfe:_Emit
		oIdent     := oNF:_InfNfe:_IDE
		oDestino   := oNF:_InfNfe:_Dest
		oTotal     := oNF:_InfNfe:_Total
		oTransp    := oNF:_InfNfe:_Transp
		oDet       := oNF:_InfNfe:_Det 
		
		oDet := IIf(ValType(oDet) == "O", {oDet}, oDet)
		
		cCgc := AllTrim(IIf(Type("oEmitente:_CPF") == "U", oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT))
		
		DbSelectArea('SA2')
		SA2->(DbSetOrder(3))
		
		If SA2->(DbSeek(xFilial("SA2")+PADR(cCgc, TamSx3("A2_CGC")[1])))
			
			
			oNotaStruct:cDoc			:= Right(REPLICATE("0", 9)+Alltrim(oIdent:_nNF:TEXT), 9)
			oNotaStruct:cSerie			:= AllTrim(oIdent:_serie:TEXT)
			oNotaStruct:cChave			:= IIf(Type("oNFe:_NfeProc:_protNFe:_infProt:_chNFe") <> "U", oNFe:_NfeProc:_protNFe:_infProt:_chNFe:TEXT, "")
			
			cData 						:= Alltrim(oIdent:_dhEmi:TEXT)
			oNotaStruct:dDataEmissao	:= stod(Left(cData, 4) + Substr(cData, 6, 2) + Substr(cData, 9, 2)) 
			oNotaStruct:cFornece		:= SA2->A2_COD
			
			oNotaStruct:cLoja			:= SA2->A2_LOJA
			oNotaStruct:cCond 			:= SA2->A2_COND //condicao pagamento padrao
			
			
			For nI := 1 To Len(oDet)
			
				cProdXML := PadR(AllTrim(oDet[nI]:_Prod:_cProd:TEXT), TamSx3("A5_CODPRF")[1])
				
				DbSelectArea("SA5")
				SA5->(DbSetOrder(14)) ////SA5->(DbOrderNickName("FORPROD"))  
				If SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cProdXML))
				
					oNotaItemStruct 			:= TNotaItemStruct():New()
				 	oNotaItemStruct:cProduto	:= SA5->A5_PRODUTO
				 	oNotaItemStruct:cTES		:= SA5->A5_YTES
				 	
				 	oNotaItemStruct:nQuantidade	:= Val(oDet[nI]:_Prod:_qCom:TEXT)
				 	oNotaItemStruct:nValor		:= Val(oDet[nI]:_Prod:_vUnCom:TEXT)
				 	oNotaItemStruct:nTotal		:= Val(oDet[nI]:_Prod:_vProd:TEXT)
				 	
				 	oNotaItemStruct:cPedido	 	:= IIF(XmlChildEx(oDet[nI]:_Prod, "_XPED") <> NIL, oDet[nI]:_Prod:_xPed:TEXT, "")
				 	oNotaItemStruct:cItemPed	:= IIF(XmlChildEx(oDet[nI]:_Prod, "_NITEMPED") <> NIL, cValToChar(oDet[nI]:_Prod:_nItemPed:TEXT), "")
					
					If (!Empty(oNotaItemStruct:cItemPed))
						oNotaItemStruct:cItemPed := Right(REPLICATE("0", 4)+Alltrim(oNotaItemStruct:cItemPed), 4)
					EndIf
					
					If (AllTrim(SA2->A2_SIMPNAC) == '1')//simples nacional
						If (XmlChildEx(oDet[nI]:_imposto:_ICMS, "_ICMSSN101") <> NIL)
							oNotaItemStruct:nAliqICMS 	:= IIF(XmlChildEx(oDet[nI]:_imposto:_ICMS:_ICMSSN101, "_PCREDSN") <> NIL, Val(oDet[nI]:_imposto:_ICMS:_ICMSSN101:_PCREDSN:TEXT), 0)
							oNotaItemStruct:nValICMS 	:= IIF(XmlChildEx(oDet[nI]:_imposto:_ICMS:_ICMSSN101, "_VCREDICMSSN") <> NIL, Val(oDet[nI]:_imposto:_ICMS:_ICMSSN101:_VCREDICMSSN:TEXT), 0)
						Else
							cLogMsg := "Fornecedor "+cvaltochar(SA2->A2_COD)+" cadastrado como 'Simples Nacional': Não encontrado TAG ICMSSN101"+CRLF
							lRet	:= .F.	
						EndIf
					EndIf
					
					
				 	If !Empty(oNotaItemStruct:cPedido) .And. !Empty(oNotaItemStruct:cItemPed)

						DbSelectArea("SC7")
						SC7->(DbSetOrder(1))
						
						If SC7->(DbSeek(xFilial("SC7")+PADR(oNotaItemStruct:cPedido, TamSx3("C7_NUM")[1])+PADR(oNotaItemStruct:cItemPed, TamSx3("C7_ITEM")[1])))
							oNotaItemStruct:cLocal	:= SC7->C7_LOCAL
						Else
							cLogMsg := "Pedido de compra não encontrado: Pedido => "+ oNotaItemStruct:cPedido+ CRLF
							lRet	:= .F.	
						EndIf
						
					Else
						
						oPCAberto 			:= TPCAberto():New()
						oPCAResultStruct	:= oPCAberto:GetPorForProd(oNotaStruct:cFornece, oNotaStruct:cLoja, oNotaItemStruct:cProduto, oNotaItemStruct:nQuantidade)
						
						If (oPCAResultStruct:lOk)
							
							oNotaItemStruct:cPedido		:= oPCAResultStruct:oResult:cNumero
							oNotaItemStruct:cItemPed	:= oPCAResultStruct:oResult:cItem
							oNotaItemStruct:cLocal		:= oPCAResultStruct:oResult:cLocal
							
						Else
							
							cLogMsg := oPCAResultStruct:cMensagem + CRLF
							lRet	:= .F.	
			 		
						EndIf
						
						
					EndIf
				 	
				 	
				 	oNotaStruct:oNotaItens:Add(oNotaItemStruct)
				
			 	Else
			 	
			 		cLogMsg := "Relação produto fornecedor não encontrado: Produto => "+ cProdXML+ CRLF
			 		lRet	:= .F.	
		
		 		EndIf
				
			Next nI
			
		Else
		
			cLogMsg := "Fornecedor não encontrado => "+ cCgc + CRLF
			lRet	:= .F.	
		
		EndIf
	
	Else	
		
		cLogMsg := "Erro ao ler o arquivo XML." + CRLF
		lRet	:= .F.	
		
	EndIf
	
	
		
	If (lRet)
		oNotaResulStruct:Add(lRet, cLogMsg, oNotaStruct)
	Else
		oNotaResulStruct:Add(lRet, cLogMsg, Nil)
	EndIf
	
	::oNotaResulStruct := oNotaResulStruct

Return(oNotaResulStruct)



//classes struct

Class TNotaStruct from LongClassName

	Data cDoc
	Data cSerie
	Data cFornece
	Data cLoja
	Data dDataEmissao
	Data cEspecie
	Data cTipo
	Data cChave
	Data cCond
	
	Data oNotaItens

	Method New() Constructor

EndClass

Method New() Class TNotaStruct

	::cDoc 					:= ""
	::cSerie				:= ""
	::cFornece				:= ""
	::cLoja					:= ""
	::dDataEmissao			:= Date()
	::cEspecie				:= "SPED"
	::cTipo					:= "N"
	::cChave				:= ""
	::cCond					:= ""
	
	::oNotaItens	    	:= ArrayList():New()

Return()

Class TNotaItemStruct From LongClassName

	Data cProduto
	Data nQuantidade
	Data nValor
	Data nTotal
	Data cPedido
	Data cItemPed
	Data cLocal
	Data cTES
	Data nQuantTicket
	Data nAliqICMS
	Data nValICMS
	Data cNfOri
	Data cSerieOri
	Data cNumTicket
	
	
	Method New() Constructor

EndClass

Method New() Class TNotaItemStruct
	
	::cProduto		:= ""
	::nQuantidade	:= 0
	::nValor		:= 0
	::nTotal		:= 0
	::cPedido		:= ""
	::cItemPed		:= ""		
	::cLocal		:= ""
	::cTES			:= ""
	::nQuantTicket	:= 0
	::nAliqICMS		:= 0
	::nValICMS		:= 0
	::cNfOri		:= ""
	::cSerieOri		:= ""
	::cNumTicket	:= ""
	
Return()

Class TNotaResulStruct From LongClassName

	Public Data lOk		as logical
	Public Data cMensagem	as character
	Public Data oResult	

	Public Method New() Constructor
	Public Method Add()

EndClass

Method New() Class TNotaResulStruct

	::lOk		:= .T.
	::cMensagem	:= ""
	::oResult	:= Nil
	
Return()

Method Add(lOk, cMensagem, oResult) Class TNotaResulStruct

	::lOk		:= lOk
	::cMensagem	+= cMensagem
	::oResult	:= oResult

Return()