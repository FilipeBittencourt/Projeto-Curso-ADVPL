#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} VIXA258
CLASSE COM AS REGRAS DE NEGOCIO REFERENTE AS TRAVAS DO PROJETO VALIDACAO DE XML - NF-e/ CT-e
@type function
@author WLYSSES CERQUEIRA / FILIPE VIEIRA (FACILE)
@since 19/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Class VIXA258 From LongClassName

	Data lVldNfe
	Data lVldCte
	Data oXml
	Data aRetValid
	Data aProdutos
	Data cFornece
	Data cLoja
	Data cDoc
	Data cSerie
	Data lEnabled
	Data nTolerVlr
	Data nTolerDat
	Data cDetalhesPgto
	Data aUF
	Data cEmailNFe
	Data cEmailCte
	
	Data lIsCte
	Data lIsNfe
	
	Method New(	cFornece, cLoja, cDoc, cSerie) Constructor
	Method ValidNfe()
	Method ValidCte()
	
	Method ValidRotaFrete()
	Method ValidRota(cPed, cTpFretNfe, cCnpjTransp, cMunIni01, cMunFim01, cMunIni02, cMunFim02,DT_FORNEC, DT_LOJA)
	
	Method ValidCondPagNfe()

	Method WorkFlowNFe()
	Method WorkFlowCTe()
	Method WorkFlowSE4()
	
	Method SetBloqNFe()
	Method SetBloqCte()
	
	Method SetLibNFe(cTpLib, cUsrAux, cMtvAux)
	Method SetLibCTe(cUsrAux,  cMtvAux)
	
	Method Ocorrencias(cMsg, cPed, cProd)
	Method GetPedidoItem(cProduto)
	Method LibNfe()
	Method LibCte()
	Method DescricaoParcelasWF()
	Method XmlValid(oTEMP, aNode, cTag, lREALNAME)
	Method GetCidadeUF(cCodIbge)
	Method NfGarantia()
		
EndClass

Method New(cFornece, cLoja, cDoc, cSerie) Class VIXA258
	

	Default cFornece	:= ""
	Default cLoja		:= ""
	Default cDoc		:= ""
	Default cSerie		:= ""

	
	::lEnabled		:= GetNewPar("MV_YFVLDXM", .T.)
	::lVldNfe		:= .T.
	::lVldCte		:= .T.
	::aRetValid		:= {}
	::aProdutos		:= {}
	::nTolerVlr		:= GetNewPar("MV_YPARACR", 0)
	::nTolerDat		:= GetNewPar("MV_YDTACRE", 0)
	::cEmailNFe		:= GetNewPar("MV_YEMXMNF", "filipe.vieira@facilesistemas.com.br;wlysses@facilesistemas.com.br")
	::cEmailCte		:= GetNewPar("MV_YEMXMCT", "filipe.vieira@facilesistemas.com.br;wlysses@facilesistemas.com.br")
	::cDetalhesPgto:= ""
	
	::cFornece		:= cFornece
	::cLoja			:= cLoja
	::cDoc			:= cDoc
	::cSerie		:= cSerie

	::aUF := {}
	
	aadd(::aUF,{"RO","11"})
	aadd(::aUF,{"AC","12"})
	aadd(::aUF,{"AM","13"})
	aadd(::aUF,{"RR","14"})
	aadd(::aUF,{"PA","15"})
	aadd(::aUF,{"AP","16"})
	aadd(::aUF,{"TO","17"})
	aadd(::aUF,{"MA","21"})
	aadd(::aUF,{"PI","22"})
	aadd(::aUF,{"CE","23"})
	aadd(::aUF,{"RN","24"})
	aadd(::aUF,{"PB","25"})
	aadd(::aUF,{"PE","26"})
	aadd(::aUF,{"AL","27"})
	aadd(::aUF,{"MG","31"})
	aadd(::aUF,{"ES","32"})
	aadd(::aUF,{"RJ","33"})
	aadd(::aUF,{"SP","35"})
	aadd(::aUF,{"PR","41"})
	aadd(::aUF,{"SC","42"})
	aadd(::aUF,{"RS","43"})
	aadd(::aUF,{"MS","50"})
	aadd(::aUF,{"MT","51"})
	aadd(::aUF,{"GO","52"})
	aadd(::aUF,{"DF","53"})
	aadd(::aUF,{"SE","28"})
	aadd(::aUF,{"BA","29"})
	aadd(::aUF,{"EX","99"})
		
	If IsInCallStack("U_A140IGRV")
	
		::oXml := PARAMIXB[5]
	
	ElseIf IsInCallStack("U_A140IIMP")
		
		::oXml := PARAMIXB[1]
		
	ElseIf IsInCallStack("U_GFEA1181") // Chamado depois da gravacao GXG/GXH
	
		::oXml := PARAMIXB[1]

	ElseIf IsInCallStack("U_GFEA1185") // Chamado antes  da gravacao GXG/GXH
	
		::oXml := PARAMIXB[1]
	
	Else
		
		::oXml := Nil
				
	EndIf
	
	If ! Empty(::oXml)
		
		::lIsCte := ValType(XmlChildEx(::oXml, "_INFCTE")) == "O"
	
		::lIsNfe := ValType(XmlChildEx(::oXml, "_INFNFE")) == "O"
	
	EndIf
	
Return(Self)


Method ValidNfe() Class VIXA258
	If ::lEnabled .And. ::lIsNfe
	
		If !::ValidCondPagNfe()
			
			::lVldNfe := .F.
			
		EndIf

	EndIf
	
Return(::lVldNfe)


Method ValidCte() Class VIXA258
	
	If ::lEnabled .And. ::lIsCte
	
		If !::ValidRotaFrete()
			
			::lVldCte := .F.
			
		EndIf

		If ::lVldCte
	
			::SetLibCte()
	
		Else
	
			::SetBloqCte()
	
		EndIf
	
	EndIf
	
Return(::lVldCte)

 
Method SetLibNFe(cTpLib, cUsrAux, cMtvAux) Class VIXA258
	
	Default cTpLib := ""
	Default cUsrAux := ""
	Default cMtvAux := ""
	
	RecLock("SDS", .F.)
		SDS->DS_YVLDXML := cTpLib 
		SDS->DS_YUSERLB := cUsrAux 
		SDS->DS_YMOTIVO := cMtvAux 
	SDS->(MsUnLock())
	
Return()

Method SetLibCTe(cUsrAux, cMtvAux) Class VIXA258
	
	Local cEdiSit	:= ""
	Local oModel	:= FWModelActive()
	//Local oView		:= FWViewActive()
	Default cUsrAux := ""
	Default cMtvAux := ""	
 
	/*RecLock("GXG", .F.)
		GXG->GXG_YVLDXM  := GXG->GXG_EDISIT  //- X3_CBOX =  "1=Importado;2=Importado com erro;3=Rejeitado;4=Processado;5=Erro Impeditivo"
		GXG->GXG_EDISIT  := cEdiSit
		GXG->GXG_YUSERL  := cUsrAux  
		GXG->GXG_YMOTIV  := cMtvAux 
	GXG->(MsUnLock())*/	
	
	IF oModel != Nil
		cEdiSit := GXG->GXG_YVLDXM
		oModel:SetValue("GFEA118_GXG", "GXG_YVLDXM", GXG->GXG_EDISIT)
		oModel:SetValue("GFEA118_GXG", "GXG_EDISIT", cEdiSit)
		oModel:SetValue("GFEA118_GXG", "GXG_YUSERL", cUsrAux)
		oModel:SetValue("GFEA118_GXG", "GXG_YMOTIV", cMtvAux)
		Aviso("Informativo:", "O CT-e foi liberado com sucesso! Para concluir a ação clique em 'OK' depois em 'Confirmar'.", {"Ok"})
	EndIf

Return()

/*
=============================================================
Envia email com os erros 
============================================================
*/
Method SetBloqNFe() Class VIXA258
	
	Local nW	:= 0
	Local cMsg := ""
	
	For nW := 1 To Len(::aRetValid)
	
		cMsg += "Retorno: " + ::aRetValid[nW][1] + " - Pedido: " + ::aRetValid[nW][2] + " - Produto: " + ::aRetValid[nW][3] +;
				" - V. Nota: " + ::aRetValid[nW][3]+ " - V. Pedido: " + ::aRetValid[nW][3]+ CRLF
	
	Next nW
	
	RecLock("SDS", .F.)
	SDS->DS_STATUS	 := "E"
	SDS->DS_YVLDXML := "1"
	SDS->DS_YINFONF  := cMsg
	SDS->(MsUnLock())

	::WorkFlowNFe()

Return(cMsg)


Method SetBloqCte() Class VIXA258
	
	Local nW	:= 0
	Local cMsg := ""
	Local cEdiSit := ""
	
	For nW := 1 To Len(::aRetValid)
	
		cMsg += ::aRetValid[nW][1] + CRLF
	
	Next nW


	cEdiSit := GXG->GXG_EDISIT
	
	RecLock("GXG", .F.)
	GXG->GXG_EDIMSG := GXG->GXG_EDIMSG //If(Empty(GXG->GXG_EDIMSG), cMsg, cMsg + CRLF + GXG->GXG_EDIMSG)
	GXG->GXG_EDISIT := If(Empty(GXG->GXG_YVLDXM), "5", GXG->GXG_EDISIT)
	GXG->GXG_YVLDXM := If(Empty(GXG->GXG_YVLDXM), cEdiSit, GXG->GXG_YVLDXM)
	GXG->GXG_YBLMOT := cMsg
	
	GXG->(MsUnlock())
	
	::WorkFlowCTe(Replace(cMsg, CRLF, " <br />"))

Return(cMsg)


Method Ocorrencias(cMsg, cPed, cProd, cDadosNF, cDadosCalc) Class VIXA258

	Default cMsg := ""
	Default cPed := ""
	Default cProd := ""
	Default cDadosNF := ""
	Default cDadosCalc := ""
	
	Conout(CRLF + cMsg + CRLF + If(Empty(cPed), "", cPed) + CRLF + If(Empty(cProd), "", cProd) + CRLF)
	
	aAdd(::aRetValid, {cMsg, cPed, cProd, cDadosNF, cDadosCalc})
	
Return(::aRetValid)


/*
=============================================================
Varrendo o XML para tratar as tags
============================================================
*/
Method ValidCondPagNfe() Class VIXA258

	Local lRet 			:= .T.
	Local aAreaSDS		:= SDS->(GetArea())
	Local aAreaSDT		:= SDT->(GetArea())
	Local aAreaSC7		:= SC7->(GetArea())
	Local cPed			:= ""
	Local oXml			:= Nil
	Local oDuplicata	:= Nil
	Local oTotal		:= Nil
	Local oIcmsTot		:= Nil
	Local cFormPg		:= ""
	Local nItem			:= 0
	Local nW			:= 0
	Local nX			:= 0
	Local aRetC7		:= {}
	Local nParcC7		:= 0
	Local nParcXml 	:= 0
	Local dDtVencXml	:= Nil
	Local nVlrAux		:= 0
	Local nSaldo		:= 0
	Local cCFOP 		:= ''
		
	Conout(CRLF + SDS->DS_ARQUIVO)
						
	DBSelectArea("SC7")
	SC7->(DBSetOrder(1)) // C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
	
	DBSelectArea("SDS")
	SDS->(dbSetOrder(1)) // DS_FILIAL, DS_DOC, DS_SERIE, DS_FORNEC, DS_LOJA, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SDT")
	SDT->(dbSetOrder(8)) // DT_FILIAL, DT_FORNEC, DT_LOJA, DT_DOC, DT_SERIE, DT_ITEM, R_E_C_N_O_, D_E_L_E_T_
		
	If ValType(XmlChildEx(::oXml, "_INFNFE")) == "O"
		
		oXml		:= XmlChildEx(::oXml, "_INFNFE")
		
		oItens		:= oXml:_Det
		
		oTotal		:= oXml:_Total
		
		oIcmsTot	:= oXml:_Total:_IcmsTot
	
	Else
		
		::Ocorrencias("A tag 'infnfe'(Grupo que contém as informações da NF-e) não foi encontrada." )
		
		lRet := .F.
	
	EndIf
	
	//Caso seja uma nota de garantia, não valida
	If ::NfGarantia()
		Return .T.
	EndIf
	
	If ValType(XmlChildEx(oXml, "_PAG")) == "O"
					
		oDuplicata := XmlChildEx(oXml, "_PAG")
		
		If ValType(XmlChildEx(oDuplicata, "_DETPAG")) $ "A|O"

			oDuplicata := XmlChildEx(oDuplicata, "_DETPAG")
			
			If ValType(oDuplicata) == "A"
				//Só precisamos buscar o primeiro
				If Len(oDuplicata) > 0 .and. ValType(XmlChildEx(oDuplicata[1], "_INDPAG")) == "O"
					//Alguns fornecedores estão enviando a tag como "A vista", porém nas tags de duplicata
					// está vindo como a prazo, neste caso o Protheus irá travar e o comprador deverá 
					//entrar em contato com o fornecedor para a correção da mesma
					cFormPg := oDuplicata[1]:_INDPAG:TEXT // 0 é a vista | 1 é a prazo.
				else		
					//Se não existir a Tag, vamos entender que é a prazo		
					cFormPg := '1'
				EndIf
			
			ElseIf ValType(oDuplicata) == "O"
				
				If ValType(XmlChildEx(oDuplicata, "_INDPAG")) == "O"
				
					cFormPg := oDuplicata:_INDPAG:TEXT
					
				Else
	
					//::Ocorrencias("A tag 'indPag' (Indicador da forma de pagamento onde: 0=Pagamento à vista, 1=Pagamento a prazo, 2=Outros.) não foi encontrada." )
						
					//Se não existir a Tag, vamos entender que é a prazo		
					cFormPg := '1'
		
					//lRet := .F.
				
				EndIf
	
			EndIf
	
			If ValType(XmlChildEx(oXml, "_COBR")) == "O"
									
				oDuplicata := XmlChildEx(oXml, "_COBR")
				
				If ValType(XmlChildEx(oDuplicata, "_DUP")) $ "O|A"
										
					oDuplicata := XmlChildEx(oDuplicata, "_DUP")
					
					If ValType(oDuplicata) <> "A"
											
						oDuplicata := {oDuplicata}
											
					EndIf
	
					If cFormPg == "1"
	
						For nW := 1 To Len(oDuplicata)
	
							If ValType(XmlChildEx(oDuplicata[nW], "_DVENC")) == "U"
	
								::Ocorrencias("A parcela " + cValToChar(nW) + " tag 'dVenc' ( Data de vencimento da(s) parcela(s) ) não foi encontrada." )
								
								lRet := .F.
								
							EndIf
	
							If ValType(XmlChildEx(oDuplicata[nW], "_VDUP")) == "U"
	
								::Ocorrencias("A parcela " + cValToChar(nW) + " tag 'vDup' ( Valor da duplicata/parcela ) não foi encontrada." )
								
								lRet := .F.
								
							EndIf
	
						Next nW
	
					EndIf
				
				Else
	
					::Ocorrencias("A tag 'dup'  ( Número da duplicata/parcela )  não foi encontrada." )
		
					lRet := .F.
	
				EndIf
	
			Else
	
				::Ocorrencias("A tag 'cobr' ( Grupo Cobrança, onde ficam todas as informações sobre o pagamento) não foi encontrada." )
		
				lRet := .F.
	
			EndIf

		Else
	
			::Ocorrencias("A tag 'detPag' ( Grupo de detalhes do pagamento )  não foi encontrada." )
		
			lRet := .F.
	
		EndIf
			
	Else
	
		::Ocorrencias("A tag 'pag' ( Grupo de informações do pagamento )  não foi encontrada." )
		
		lRet := .F.
	
	EndIf

	If lRet

		If SDS->(DBSeek(xFilial("SDS") + ::cDoc + ::cSerie + ::cFornece + ::cLoja ))
		
			//Elimina a verificação de clientes do grupo
			If u_VerifCliEmp(SDS->DS_CNPJ)
				Return .T.
			EndIf
		
			If SDT->(DBSeek(xFilial("SDT") + ::cFornece + ::cLoja + ::cDoc + ::cSerie))

				While SDT->(!EOF()) .And. SDT->(DT_FILIAL + DT_FORNEC + DT_LOJA +DT_DOC + DT_SERIE) == xFilial("SDT") + ::cFornece + ::cLoja + ::cDoc + ::cSerie

					nItem := Val(SDT->DT_ITEM)
			
					aAdd(::aProdutos, {"", SDT->DT_COD, SDT->DT_TOTAL, SDS->DS_EMISSA, Val(oIcmsTot:_vNF:Text), Val(oIcmsTot:_vIPI:Text)})

					// verIfico se existe a Tag pedido xPed no XML	- "DIficilmente entrará qui, pois a tag xPed não é obrigatória e pode vir MUITOS pedidos para uma NF-e"
					cCFOP := ''
					If Type("oItens["+cValToChar(nItem)+"]") == "U"						

						If ValType(XmlChildEx(oItens, "_PROD")) == "O"
							//Obtem o cópdigo do pedido no XML
							If ValType(XmlChildEx(oItens:_Prod, "_XPED")) == "O"						
								
								cPed := oItens:_Prod:_xPed:Text																
								
							EndIf

						EndIf
						
					Else
					
						If ValType(XmlChildEx(oItens[nItem]:_Prod, "_XPED")) == "O"

							cPed := oItens[nItem]:_Prod:_xPed:Text							

						EndIf

					EndIf

					//  TRATANDO O CODIGO DO PEDIDO   VINDO DA NF-e PARA O PADRÃO PROTHEUS
					If Len(cPed) > TamSx3("DT_PEDIDO")[1]

						cPed := RIGHT(cPed, TamSx3("DT_PEDIDO")[1])

					Else

						cPed := PADR(cPed, TamSx3("DT_PEDIDO")[1])

					EndIf
					
				    //  INSERINDO O PEDIDO NO  NO ARRAY DE PRODUTOS NA POSIÇÃO DO CODIGO DO PEDIDO
					If ! Empty(cPed)

						If SC7->(DBSeek(xFilial("SC7") + cPed))

							::aProdutos[Len(::aProdutos)][1] := cPed

						EndIf

					EndIf

					SDT->(DbSkip())

				EndDo

				::GetPedidoItem() //Preenche o array de produtos com os pedidos de acordo com os produtos encortrados.

			EndIf

		EndIf

		For nW := 1 To Len(::aProdutos)
		
			If Empty(::aProdutos[nW][1])
				
				::Ocorrencias("Pedido não encontrado.", "", ::aProdutos[nW][2])
				
				lRet := .F.
			
			Else
				
				If SC7->(DBSeek(xFilial("SC7") + ::aProdutos[nW][1]))
				
					nParcC7 := 0
					
					nParcXml := 0
					
					dDtVencXml := Nil
					
					If cFormPg == "0" .And. SC7->C7_COND <> "001"
					
						::Ocorrencias("Condicao xml a vista | condicao sistema a prazo.", ::aProdutos[nW][1], ::aProdutos[nW][2])
						
						lRet := .F.
					
					Else
						
						aRetC7 := Condicao(::aProdutos[nW][5], SC7->C7_COND, ::aProdutos[nW][6],::aProdutos[nW][4])
						nParcC7 := Len(aRetC7)
						nParcXml := Len(oDuplicata)
						
						// Calcular a quantidade de parcelas do sistema x xml			
						If nParcXml < nParcC7
							
							::Ocorrencias("A qtd de parcelas do XML está MENOR que a do Protheus. ", ::aProdutos[nW][1], ::aProdutos[nW][2])
							
							lRet := .F.
						
						ElseIf nParcXml > nParcC7
						    
							::Ocorrencias("A qtd de parcelas do XML está MAIOR que a do Protheus. ", ::aProdutos[nW][1], ::aProdutos[nW][2])
							
							lRet := .F.
						
						Else
						
							nSaldo := 0
							For nX := 1 To Len(aRetC7)
								dDtVencXml := SToD(Replace(oDuplicata[nX]:_DVenc:Text, "-", ""))
								
								nVlrAux	 := Val(oDuplicata[nX]:_vDup:Text)
								
								If dDtVencXml <> aRetC7[nX][1]
								
									//If (::nTolerDat >= dDtVencXml - aRetC7[nX][1])
									If (dDtVencXml+::nTolerDat >= aRetC7[nX][1]) .or. (dDtVencXml-::nTolerDat <= aRetC7[nX][1])
									
										::Ocorrencias("Data Vencimento da NF-e diferente do Pedido.", ::aProdutos[nW][1], ::aProdutos[nW][2], dtoc(dDtVencXml), dtoc(aRetC7[nX][1]))										
										lRet := .F.

									//Else

									//	lRet := .T.

									EndIf
								
								EndIf
		
								If nVlrAux > aRetC7[nX][2] + nSaldo
									//
									If (::nTolerVlr >= aRetC7[nX][2] - nVlrAux + nSaldo)
										
										::Ocorrencias("Valor da parcela da NF-e maior que valor calculado do Pedido.", ::aProdutos[nW][1], ::aProdutos[nW][2], cValToChar(nVlrAux), cValToChar(aRetC7[nX][2]))										
										lRet := .F.

									//Else
									//	lRet := .T.
									
									EndIf
								
									nSaldo 	+= (aRetC7[nX][2] - nVlrAux)
								
								EndIf
					
							Next nX
						
						EndIf
						
					EndIf
			
				EndIf
			
			EndIf
			
		Next nW

		
		//Detalhes sobre as datas e os pagamentos e parcelas.
		If lRet == .F.

			::cDetalhesPgto := ""

			if(Len(oDuplicata) >= Len(aRetC7))

				For nW := 1 To Len(oDuplicata)

					if(Len(aRetC7) >= nW)
						::cDetalhesPgto += "Parc.: "+cValToChar(nW)+" do <b>XML:</b> "+cValToChar(SToD(Replace(oDuplicata[nW]:_DVenc:Text, "-", ""))) +" , "+ oDuplicata[nW]:_vDup:Text +" | <b>PROTHEUS:</b> "+cValToChar(aRetC7[nW][1])+" , "+cValToChar(aRetC7[nW][2])+" <br />"
					Else
						::cDetalhesPgto += "Parc.: "+cValToChar(nW)+" do <b>XML:</b> "+cValToChar(SToD(Replace(oDuplicata[nW]:_DVenc:Text, "-", ""))) +" , "+ oDuplicata[nW]:_vDup:Text +" <br />"
					EndIf

				Next nW

			Else

				For nW := 1 To Len(aRetC7)

					if(Len(oDuplicata) >= nW)
						::cDetalhesPgto += "Parc.: "+cValToChar(nW)+" do <b>XML:</b> "+cValToChar(SToD(Replace(oDuplicata[nW]:_DVenc:Text, "-", ""))) +" , "+ oDuplicata[nW]:_vDup:Text +" <br />"
					Else
						::cDetalhesPgto += "Parc.: "+cValToChar(nW)+" do <b>XML:</b> "+cValToChar(SToD(Replace(oDuplicata[nW]:_DVenc:Text, "-", ""))) +" , "+ oDuplicata[nW]:_vDup:Text +" | <b>PROTHEUS:</b> "+cValToChar(aRetC7[nW][1])+" , "+cValToChar(aRetC7[nW][2])+" <br />"
					EndIf
				Next nW

			EndIf

		EndIf
		
		//FIM Detalhes sobre as datas e os pagamentos e parcelas.
	
	EndIf
	
	If lRet

		::SetLibNFe("0")

	Else

		::SetBloqNFe()

	EndIf
	
	RestArea(aAreaSDS)
	RestArea(aAreaSDT)
	RestArea(aAreaSC7)
		
Return(lRet)

/*
=============================================================
VerIficando se existe peidido atraves dos Itens do XML 
============================================================
*/
Method GetPedidoItem(cProduto) Class VIXA258

	Local lConsLoja	:= .T.
	Local cFilQuery	:= ""
	Local cAlias		:= GetNextAlias()
	Local nPos			:= 0
	Local nW			:= 0
	
	Default cProduto := ""
	
	If ! Empty(cProduto)
	
		cFilQuery	+= IIf(!Empty(cFilQuery)," AND ","")
		
		cFilQuery	+= " SC7.C7_PRODUTO = '" + cProduto + "'"
	
	EndIf

	If lConsLoja
	
		cFilQuery	+= IIf(!Empty(cFilQuery)," AND ","")
		
		cFilQuery	+= " SC7.C7_FORNECE = '"+::cFornece+"' AND SC7.C7_LOJA = '"+::cLoja+"' "
		
	Else
	
		cFilQuery	+= IIf(!Empty(cFilQuery)," AND ","")
		
		cFilQuery	+= " SC7.C7_FORNECE = '"+::cFornece+"' "
		
	EndIf

	If SuperGetMV("MV_RESTNFE") == "S"
	
		cFilQuery	+= IIf(!Empty(cFilQuery)," AND ","")
		
		cFilQuery	+= " SC7.C7_CONAPRO <> 'B' "
		
	EndIf

	If Empty(cFilQuery)
	
		cFilQuery	+= "% 1 = 1 %"
		
	Else
	
		cFilQuery	:= "% "+cFilQuery+" %"
		
	EndIf

	BeginSql Alias cAlias
	
		SELECT	SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRODUTO, SC7.C7_LOCAL,
		SC7.C7_QUANT, SC7.C7_QUJE, SC7.C7_PRECO, SC7.C7_QTDACLA
		FROM	%Table:SC7% 	SC7
		WHERE	SC7.C7_FILENT	=  %xFilial:SC7%
		AND SC7.C7_TPOP		<> %Exp:'P'%
		AND SC7.C7_ENCER		=  %Exp:''%
		AND SC7.C7_RESIDUO		=  %Exp:''%
		AND SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA > %Exp:0%
		AND SC7.%NotDel%
		AND %Exp:cFilQuery%
		ORDER BY SC7.C7_PRODUTO, SC7.C7_DATPRF, SC7.C7_NUM, SC7.C7_ITEM
	
	EndSql

	(cAlias)->(dbGoTop())
	
	While (cAlias)->(!EOF())
	
		If Empty(cProduto)

			For nW := 1 To Len(::aProdutos)
	
				If Empty(::aProdutos[nW][1]) .And. AllTrim(::aProdutos[nW][2]) == AllTrim((cAlias)->C7_PRODUTO)
					
					::aProdutos[nW][1] := (cAlias)->C7_NUM
	
				EndIf
	
			Next nW
		
		Else
		
			If (cAlias)->C7_PRODUTO == cProduto
			
				Return((cAlias)->C7_NUM)
			
			EndIf
			
		EndIf
			
		(cAlias)->(dbSkip())

	EndDo
	
	(cAlias)->(dbCloseArea())

Return("")


Method ValidRota(cPed, cTpFretNfe, cCnpjTransp, cMunIni01, cMunFim01, cMunIni02, cMunFim02, DT_FORNEC, DT_LOJA) Class VIXA258
	
	Local lRet := .T.
	Local lRota	:= .F.
	Local aZZE	:= {}
	Local aZZ0	:= {}
	Local nW	:= 0
	Local cCodTransp := ""
	Local cMsg	:= ""
	Local lEncontrou := .F. 
	
	DBSelectArea("ZZE")
	ZZE->(DBSetOrder(1)) // ZZE_FILIAL, ZZE_NUM, ZZE_CTRANS, R_E_C_N_O_, D_E_L_E_T_
	ZZE->(DBGoTop())

	DBSelectArea("ZZ0")
	ZZ0->(DBSetOrder(1)) // ZZ0_FILIAL, ZZ0_CODFOR, ZZ0_LOJA, ZZ0_CTRANS, R_E_C_N_O_, D_E_L_E_T_
	ZZ0->(DBGoTop())


	DBSelectArea("SX5")
	SX5->(DBSetOrder(1)) // X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
	SX5->(DBGoTop())

	DBSelectArea("SA4")
	SA4->(DBSetOrder(3)) // A4_FILIAL, A4_CGC, R_E_C_N_O_, D_E_L_E_T_

	If SA4->(DBSeek(xFilial("SA4") + cCnpjTransp))
	
		cCodTransp := SA4->A4_COD
	
	EndIf
		
	
	if !Empty(cPed)
		If ZZE->(DBSeek(xFilial("ZZE") + cPed))
			
			While ZZE->(!EOF()) .And. ZZE->(ZZE_FILIAL + ZZE_NUM) == xFilial("ZZE") + cPed
				
				aAdd(aZZE, {ZZE->ZZE_TRECHO, ZZE->ZZE_CTRANS,;
							ZZE->ZZE_UFORIG, ZZE->ZZE_CIDORI, ZZE->ZZE_DESCIO,;
							ZZE->ZZE_UFDEST, ZZE->ZZE_CIDDES, ZZE->ZZE_DESCID,;
							ZZE->ZZE_MODALI})

				ZZE->(DBSkip())
				
			EndDo
			
			aSort( aZZE,,, { |x,y| x[1] < y[1] } )
			
			For nW := 1 To Len(aZZE)
				lEncontrou := .T.
				nPos := aScan(::aUF, {|x| AllTrim(x[1]) == AllTrim(aZZE[nW][3]) }) // ZZE_UFORIG
				
				aZZE[nW][4] := ::aUF[nPos][2] + aZZE[nW][4]
				
				nPos := aScan(::aUF, {|x| AllTrim(x[1]) == AllTrim(aZZE[nW][6]) }) // ZZE_UFDEST
				
				aZZE[nW][7] := ::aUF[nPos][2] + aZZE[nW][7]
				
				cMsg += "Rota " + aZZE[nW][1] + " pedido " + cPed + " de " + ::GetCidadeUF(aZZE[nW][4]) + " até " + ::GetCidadeUF(aZZE[nW][7]) + CRLF
							
				If AllTrim(cMunIni02) == AllTrim(aZZE[nW][4]) .And. AllTrim(cMunFim02) == AllTrim(aZZE[nW][7])
			
					If AllTrim(cCodTransp) <> AllTrim(aZZE[nW][2])
					
						::Ocorrencias("Rota [" + aZZE[nW][1] + "] no pedido [" + cPed + "] esta com transportadora [" + cCodTransp + "] e CT-e [" + aZZE[nW][2] + "] !")
						
						lRet := .F.
					
					Else
					
						lRota := .T.
						
					EndIf
					
					If AllTrim(aZZE[nW][9]) == "1" // 1=CIF;2=FOB
					
						::Ocorrencias("Rota [" + aZZE[nW][1] + "] no pedido [" + cPed + "] esta como CIF e chegou CT-e!")
						
						lRet := .F.
						
					EndIf
				
				EndIf
			
			Next nW
		EndIf
	EndIf

	//PEGA NO FORNECEDOR
	if !lEncontrou

		If ZZ0->(DBSeek(xFilial("ZZ0") + DT_FORNEC+DT_LOJA))
		
			While ZZ0->(!EOF()) .And. ZZ0->(ZZ0_FILIAL+ZZ0_CODFOR+ZZ0_LOJA) == xFilial("ZZ0")+DT_FORNEC+DT_LOJA
				
				aAdd(aZZ0, {ZZ0->ZZ0_TRECHO, ZZ0->ZZ0_CTRANS,;
							ZZ0->ZZ0_UFORIG, ZZ0->ZZ0_CIDORI, ZZ0->ZZ0_DESCIO,;
							ZZ0->ZZ0_UFDEST, ZZ0->ZZ0_CIDDES, ZZ0->ZZ0_DESCID,;
							ZZ0->ZZ0_MODALI})

				ZZ0->(DBSkip())
				
			EndDo
		
			aSort( aZZ0,,, { |x,y| x[1] < y[1] } )
			
			For nW := 1 To Len(aZZ0)
				lEncontrou := .T.
				nPos := aScan(::aUF, {|x| AllTrim(x[1]) == AllTrim(aZZ0[nW][3]) }) // ZZ0_UFORIG
				
				aZZ0[nW][4] := ::aUF[nPos][2] + aZZ0[nW][4]
				
				nPos := aScan(::aUF, {|x| AllTrim(x[1]) == AllTrim(aZZ0[nW][6]) }) // ZZ0_UFDEST
				
				aZZ0[nW][7] := ::aUF[nPos][2] + aZZ0[nW][7]
				
				cMsg += "Rota " + aZZ0[nW][1] + " Fornecedor " + DT_FORNEC + " de " + ::GetCidadeUF(aZZ0[nW][4]) + " até " + ::GetCidadeUF(aZZ0[nW][7]) + CRLF
							
				If AllTrim(cMunIni02) == AllTrim(aZZ0[nW][4]) .And. AllTrim(cMunFim02) == AllTrim(aZZ0[nW][7])
			
					If AllTrim(cCodTransp) <> AllTrim(aZZ0[nW][2])
					
						::Ocorrencias("Rota [" + aZZ0[nW][1] + "] no Fornecedor [" + DT_FORNEC + "] esta com transportadora [" + cCodTransp + "] e o CT-e [" + aZZ0[nW][2] + "] !")
						
						lRet := .F.
					
					Else
					
						lRota := .T.
						
					EndIf
					
					If AllTrim(aZZ0[nW][9]) == "1" // 1=CIF;2=FOB
					
						::Ocorrencias("Rota [" + aZZ0[nW][1] + "] no Fornecedor [" + DT_FORNEC + "] esta como CIF e chegou CT-e!")
						
						lRet := .F.
						
					EndIf
				
				EndIf
			
			Next nW
		EndIf

		If ! lRota .And. lRet
		
			::Ocorrencias("As rotas do cadastro são diferentes do CT-e: " +;
							CRLF + "Rota sistema: " + CRLF + cMsg +;
							CRLF + "Rota CT-e: " +;
							CRLF + "De " + ::GetCidadeUF(cMunIni01) + " Até " + ::GetCidadeUF(cMunFim01) +;
							CRLF + "De " + ::GetCidadeUF(cMunIni02) + " Até " + ::GetCidadeUF(cMunFim02))
									
			lRet := .F.
		
		EndIf
	
	EndIf
		
Return(lRet)


Method GetCidadeUF(cCodIbge) Class VIXA258
	
	Local cRet := ""
	Local nPos := 0
	
	DBSelectArea("CC2")
	CC2->(DBSetOrder(1)) // CC2_FILIAL, CC2_EST, CC2_CODMUN, R_E_C_N_O_, D_E_L_E_T_
	
	nPos := aScan(::aUF, {|x| x[2] == Substr(cCodIbge, 1,2) })
			
	If nPos > 0
	
		If CC2->(DBSeek(xFilial("CC2") + ::aUF[nPos][1] + Substr(cCodIbge, 3, 100)))
		
			cRet := AllTrim(CC2->CC2_MUN) + "-" + CC2->CC2_EST

		EndIf	
	
	EndIf

Return(cRet)

Method ValidRotaFrete() Class VIXA258
	
	Local lRet 			:= .T.
	Local aAreaSDS		:= SDS->(GetArea())
	Local aAreaSDT		:= SDT->(GetArea())

	Local oNFe			:= Nil
	Local oCTe			:= Nil
	Local oInfNFE		:= Nil
					
	Local aNFe			:= {}
	Local cTipoCte		:= ""
	Local nItem			:= 0
	Local nW			:= 0
	Local nX			:= 0
	Local nPos			:= 0
	Local aPedidos		:= {}
	
	Local cPed			:= ""
	Local cChaveNfe	:= ""
	Local cCnpjTransp		:= ""
	Local cMunIni01	:= ""
	Local cMunFim01	:= ""
	Local cMunIni02	:= ""
	Local cMunFim02	:= ""
	Local aPedRotas := {}
	
	Conout(CRLF + GXG->GXG_EDIARQ)
						
	DBSelectArea("SC7")
	SC7->(DBSetOrder(1)) // C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
	
	If ValType(XmlChildEx(::oXml, "_INFCTE")) == "O"
		
		oCTe := ::oXml
		
		If oCTe:_INFCTE:_VERSAO:TEXT >= "2.00"
		
			cTipoCte := ::XmlValid(oCTE,{"_INFCTE","_IDE"},"_TPCTE")
			
			// Tag _INFCTENORM não existe em arquivos Ct-e de copmlemento de valores e anulação de valores
			If cTipoCte $ "0;3"
			
				If Empty(XmlChildEx(oCTe:_INFCTE:_INFCTENORM, "_INFDOC"))
			
					::Ocorrencias("O arquivo CT-e importado não é válido.")
					::Ocorrencias("A tag _INFDOC ( Grupo de Documentos Transportados)  não foi encontrada.")   
					
					lRet := .F.
			
				Else
			
					oInfNFE := oCTe:_INFCTE:_INFCTENORM:_INFDOC
			
				EndIf
			
			EndIf

		Else
		
			::Ocorrencias("Versão do xml invalida!")
			
			lRet := .F.
			
		EndIf
		
		If Empty(oInfNFE) .And. !(ValType(XmlChildEx(oInfNFE, "_INFNFE")) $ "O/A")
		
			::Ocorrencias("A tag 'infcte' ( Informações do CT-e: Versão do leiaute e Identificador da tag a ser assinada ) não foi encontrada." )
		
			lRet := .F.
		
		Else
		
			//Verifica as informações da nota vinculada
			If ValType(XmlChildEx(oInfNFE, "_INFNFE")) == "O"
			
				XmlNode2Arr( oInfNFE:_INFNFE  , "_INFNFE" )
			
			EndIf
			
			aNFe := oInfNFE:_INFNFE

		EndIf

	Else
		
		::Ocorrencias("A tag 'infcte' ( Informações do CT-e: Versão do leiaute e Identificador da tag a ser assinada ) não foi encontrada." )
		
		lRet := .F.
	
	EndIf

	DBSelectArea("SDS")
	SDS->(dbSetOrder(2)) // DS_FILIAL, DS_CHAVENF, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SDT")
	SDT->(dbSetOrder(8)) // DT_FILIAL, DT_FORNEC, DT_LOJA, DT_DOC, DT_SERIE, DT_ITEM, R_E_C_N_O_, D_E_L_E_T_
	
	DBSelectArea("SD1")
	SD1->(dbSetOrder(1)) // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
							 
	For nW := 1 To Len(aNfe)
		
		cChaveNfe := aNfe[nW]:_Chave:Text
		
		If SDS->(DBSeek(xFilial("SDS") + cChaveNfe))
			
			cMunIni01	:= oCTe:_InfCte:_Rem:_EnderReme:_cMun:Text
			cMunFim01	:= oCTe:_InfCte:_Emit:_EnderEmit:_cMun:Text
			cMunIni02	:= oCTe:_InfCte:_Emit:_EnderEmit:_cMun:Text
			cMunFim02	:= oCTe:_InfCte:_Ide:_cMunFim:Text
			cCnpjTransp	:= oCTe:_InfCte:_Emit:_CNPJ:Text
			
			::cFornece	:= SDS->DS_FORNEC
			::cLoja		:= SDS->DS_LOJA
			
			If SDT->(DBSeek(xFilial("SDT") + SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
			
				While SDT->(!EOF()) .And. SDT->(DT_FILIAL + DT_FORNEC + DT_LOJA + DT_DOC + DT_SERIE) == xFilial("SDT") + SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
					
					If SD1->(DBSeek(xFilial("SD1") + SD1->(D1_FORNECE+D1_LOJA+D1_DOC+D1_SERIE+D1_COD+D1_ITEM)))
							
						If Empty(SD1->D1_PEDIDO)
						
							cPed := ''//::GetPedidoItem(SD1->D1_COD)
							
						Else
						
							cPed := SD1->D1_PEDIDO
						
						EndIf
						
					Else
					
						cPed := ''//::GetPedidoItem(SDT->DT_COD)
						
					EndIf

					If Len(aPedRotas) == 0 .OR. aScan(aPedRotas, cPed) <= 0
						aAdd(aPedRotas, cPed)
						If !::ValidRota(cPed, SDS->DS_TPFRETE, cCnpjTransp, cMunIni01, cMunFim01, cMunIni02, cMunFim02, DT_FORNEC, DT_LOJA)						
			
							lRet := .F.						
								
						EndIf
					EndIf
		
					SDT->(DBSkip())
				
				EndDo
				
			Else
		
				::Ocorrencias("Nao encontrado registro da NF-e o TOTVS Colaboração [SDT] - Chave: " + cChaveNfe)
		
				lRet := .F.
			
			EndIf
		
		Else
		
			::Ocorrencias("Nao encontrado registro da NF-e o TOTVS Colaboração [SDS] - Chave: " + cChaveNfe)
		
			lRet := .F.
		
		EndIf
	
	NExt nW

Return(lRet)


Method XmlValid(oTEMP, aNode, cTag, lREALNAME) Class VIXA258

	Local nCont
	Local oXML := oTEMP
	Local cReturn := ""
	
	Default lREALNAME := .F.

	//Navega dentro do objeto XML usando a variavel aNode como base, retornando o conteudo do TEXT ou o
	For nCont := 1 to Len(aNode)

		If ValType( XmlChildEx( oXML,aNode[nCont]  ) ) == 'O'
			oXML :=  XmlChildEx( oXML,aNode[nCont]  )
		Else
			Return
		Endif

		If nCont == Len(aNode)
			If !lREALNAME
				cReturn := &("oXML:"+cTag+':TEXT')
				Return cReturn
			Else
				cReturn := &("oXML:REALNAME")
				Return cReturn
			Endif
		EndIf

	Next nCont

	FreeObj(oXML)

Return(cReturn)

Method LibNfe() Class VIXA258
	
	Local lRet		:= .F.
	Local cUsrAux	:= ""
	Local cPswAux	:= ""
	Local cMtvAux	:= ""
	
	If ::lEnabled
	
		If IsBlind()
		
			lRet := .T.
			
		Else
	
			If SDS->DS_YVLDXML == "1"
			
				If Aviso("ATENCAO", "O xml esta com bloqueio!" + CRLF + "Seu usuário não tem permissão para continuar." + CRLF, {"Autorização Gestor", "Cancela"}, 3) == 1
	
					If U_VIXA259(@cUsrAux, @cPswAux, .T. , @cMtvAux)
	
						lRet := .T.
	
					EndIf
		
				Else
	
					lRet := .F.
	
				EndIf
			
			Else

				If(FwIsInCallStack('U_VIX259CL'))
					Aviso("ATENCAO", "O xml já está desbloqueado!", {"Ok"}, 3)
				EndIf

				lRet := .T.
				
			EndIf
		
			If lRet .AND. SDS->DS_YVLDXML == "1"
				
				::SetLibNFe("2", @cUsrAux,  @cMtvAux)
		
			EndIf
		
		EndIf
		
	Else
	
		lRet := .T.
	
	EndIf
				
Return(lRet)

Method LibCte() Class VIXA258
	
	Local lRet		:= .F.
	Local cUsrAux	:= ""
	Local cPswAux	:= ""
	Local cMtvAux	:= ""
	
	
	If ::lEnabled
	
		If IsBlind()
		
			lRet := .F.
			
		Else
	
			If GXG->GXG_EDISIT == "5"
			
				If Aviso("ATENCAO", "O xml esta com bloqueio!" + CRLF + "Seu usuário não tem permissão para continuar." + CRLF, {"Autorização Gestor", "Cancela"}, 3) == 1
	
					If U_VIXA259(@cUsrAux, @cPswAux, .T. , @cMtvAux)
	
						lRet := .T.
	
					EndIf
		
				Else
	
					lRet := .F.
	
				EndIf
			
			Else
			
				lRet := .T.
				
			EndIf
		
			If lRet .And. GXG->GXG_EDISIT == "5"
		 
				::SetLibCte(@cUsrAux,  @cMtvAux)

			ElseIf GXG->GXG_EDISIT == "1"

				Aviso("ATENCAO", "Xml ja esta liberado!", {"Ok"}, 3)
		
			EndIf
		
		EndIf
		
	Else
	
		lRet := .T.
	
	EndIf
				
Return(lRet)

Method WorkFlowNFe() Class VIXA258

	Local cScryptHtml 	:= ""
	Local cLinkImg	 	:= "http://www.grupouniaosa.com.br/wp-content/themes/grupouniao/images/logo.png"
	Local cNomeEmp	 	:= AllTrim(SM0->M0_NOME) + "-" + AllTrim(SM0->M0_FILIAL)
	Local cLinkSit 	:= "http://www.grupouniaosa.com.br/"
	Local nW			:= 0
	Local aAreaSA2		:= SA2->(GetArea())
	
	DBSelectArea("SA2")
	SA2->(DBSetOrder(1))
	
	cScryptHtml := '	<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word"'
	cScryptHtml += '	xmlns="http://www.w3.org/TR/REC-html40">'
	cScryptHtml += '	<head>'
	cScryptHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
	cScryptHtml += '		<title>Comunicado Orçamento '+SM0->M0_FILIAL+'</title>'
	cScryptHtml += '      <style type="text/css">'
	cScryptHtml += '<!--'
	cScryptHtml += '.style6 {font-size: 12px; font-weight: bold; }'
	cScryptHtml += '.style7 {font-size: 12px}'
	cScryptHtml += '-->'
	cScryptHtml += '        </style>'
	cScryptHtml += '</head>'
	cScryptHtml += '	<body>'
	cScryptHtml += '<div class="gs">'
	cScryptHtml += '<div class="gE iv gt"></div>'
	cScryptHtml += '<div class="utdU2e"></div><div class="tx78Ic"></div><div class="QqXVeb"></div><div id=":10g" tabindex="-1"></div><div id=":118" class="ii gt adP adO"><div id=":119"><u></u>'
	cScryptHtml += '	<div style="padding:0;margin:0;background:#eaeaea">'
	cScryptHtml += '		<table style="background:#eaeaea;font-family:Lucida grande,Sans-SerIf;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="100%">'
	cScryptHtml += '			<tbody><tr>'
	cScryptHtml += '				<td style="padding:25px 0 55px" align="center">'
	cScryptHtml += '					<table style="padding:0 50px;text-align:left;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="800">'
	cScryptHtml += '		    <tbody><tr>'
	cScryptHtml += '							<td style="padding-bottom:10px">'
	cScryptHtml += '								<img src="'+cLinkImg+'">							</td>'
	cScryptHtml += '						</tr>'
	cScryptHtml += '						<tr>'
	cScryptHtml += '							<td height="400" style="font-size:13px;color:#888;padding:30px 40px;border:1px solid #b8b8b8;background-color:#fff">'
	cScryptHtml += '								<p style="color:black;margin:0">Você acaba de receber um informativo de '+ cEmpAnt + cFilAnt + "-" + cNomeEmp +'.</p>'
	cScryptHtml += '				  <div style="background-color:#e3e3e3;padding:20px;color:black;margin:30px 0">'
	cScryptHtml += '									<span style="font-weight:bold;font-size:14px;margin:0">Validação XML</span>'
	
	If SA2->(DBSeek(xFilial("SA2") + ::cFornece + ::cLoja))
	
		cScryptHtml += '				<span style="font-weight:bold;font-size:14px;margin:0">Fornecedor: ' + ::cFornece + "-" + ::cLoja + "-" + SA2->A2_NOME + '</span>'
		cScryptHtml += '				<span style="font-weight:bold;font-size:14px;margin:0">Nf-e: ' + ::cDoc + "/" + ::cSerie + '</span>'
	
	EndIf
	
	cScryptHtml += '			                        <hr style="margin:15px 0">'
	cScryptHtml += '									<p style="margin:0"></p>'
	
	cScryptHtml += '									<table width="674" border="0">'

	cScryptHtml += '                                      <tr>'
	cScryptHtml += '                                        <td width="117" style="border 1px black"><span class="style6">Retorno</span></td>'
	cScryptHtml += '                                        <td width="117" style="border 1px black"><span class="style6">Pedido</span></td>'
	cScryptHtml += '                                        <td width="117" style="border 1px black"><span class="style6">Produto</span></td>'
	cScryptHtml += '                                        <td width="117" style="border 1px black"><span class="style6">V. Nota</span></td>'
	cScryptHtml += '                                        <td width="117" style="border 1px black"><span class="style6">V. Pedido</span></td>'
	cScryptHtml += '                                      </tr>'

	For nW := 1 To Len(::aRetValid)
		
		cScryptHtml += '                                      <tr>'
		cScryptHtml += '                                       <td width="547" style="border 1px black"><span class="style4 style7">'+::aRetValid[nW][1]+'</span></td>'
		cScryptHtml += '                                       <td width="20"  style="border 1px black"><span class="style4 style7">'+::aRetValid[nW][2]+'</span></td>'
		cScryptHtml += '                                       <td width="20"  style="border 1px black"><span class="style4 style7">'+::aRetValid[nW][3]+'</span></td>'
		cScryptHtml += '                                       <td width="20"  style="border 1px black"><span class="style4 style7">'+::aRetValid[nW][4]+'</span></td>'
		cScryptHtml += '                                       <td width="20"  style="border 1px black"><span class="style4 style7">'+::aRetValid[nW][5]+'</span></td>'
		cScryptHtml += '                                      </tr>'
		
	Next nW

	cScryptHtml += '                                      <tr>'
	cScryptHtml += '                                       		<td colspan="3" width="547" style="border 1px black"><br/><br/><b>Detalhes:</b><br/><br/><span class="style4 style7">'+::cDetalhesPgto+'</span></td>'
	cScryptHtml += '                                      </tr>'
									
	
	cScryptHtml += '                                 </table>'
	cScryptHtml += '                            <br>'
	
	cScryptHtml += '					          </div>'
	cScryptHtml += '						  <p>Esta notificação foi enviada por um email configurado para não receber resposta.<br>'
	cScryptHtml += '									Por favor, não responda esta mensagem.							  </p>'
	cScryptHtml += '						  </td>'
	cScryptHtml += '						</tr>'
	cScryptHtml += '					</tbody></table>'
	
	cScryptHtml += '	    <p align="center" style="width:640px;padding:10px 20px;font-size:10px;color:#888;line-height:14px">'
	cScryptHtml += '						Para acessar o site da '+cNomeEmp+','
	cScryptHtml += '						<a href="'+cLinkSit+'" style="color:#666;text-decoration:underline" target="_blank">clique aqui.</a>					</p>'
	cScryptHtml += '			  </td>'
	cScryptHtml += '			</tr>'
	cScryptHtml += '		</tbody></table><div class="yj6qo"></div><div class="adL">'
	cScryptHtml += '	</div></div><div class="adL">'
	cScryptHtml += '</div></div></div><div id=":104" class="ii gt" style="display:none"><div id=":103"></div></div><div class="hi"></div></div>'
	cScryptHtml += '		</body>'
	cScryptHtml += '	</html>'
	
	u_EnvEmail(::cEmailNFe, "Erro NF-e FACILE", cScryptHtml)
	
	RestArea(aAreaSA2)

Return()


Method WorkFlowCTe(cMsg) Class VIXA258

	Local cScryptHtml 	:= ""
	Local cLinkImg	 	:= "http://www.grupouniaosa.com.br/wp-content/themes/grupouniao/images/logo.png"
	Local cNomeEmp	 	:= AllTrim(SM0->M0_NOME) + "-" + AllTrim(SM0->M0_FILIAL)
	Local cLinkSit 	:= "http://www.grupouniaosa.com.br/"
	Local nW			:= 0
	Local aAreaSA2		:= SA2->(GetArea())
	
	cScryptHtml := '	<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word"'
	cScryptHtml += '	xmlns="http://www.w3.org/TR/REC-html40">'
	cScryptHtml += '	<head>'
	cScryptHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
	cScryptHtml += '		<title>Comunicado Orçamento '+SM0->M0_FILIAL+'</title>'
	cScryptHtml += '      <style type="text/css">'
	cScryptHtml += '<!--'
	cScryptHtml += '.style6 {font-size: 12px; font-weight: bold; }'
	cScryptHtml += '.style7 {font-size: 12px}'
	cScryptHtml += '-->'
	cScryptHtml += '        </style>'
	cScryptHtml += '</head>'
	cScryptHtml += '	<body>'
	cScryptHtml += '<div class="gs">'
	cScryptHtml += '<div class="gE iv gt"></div>'
	cScryptHtml += '<div class="utdU2e"></div><div class="tx78Ic"></div><div class="QqXVeb"></div><div id=":10g" tabindex="-1"></div><div id=":118" class="ii gt adP adO"><div id=":119"><u></u>'
	cScryptHtml += '	<div style="padding:0;margin:0;background:#eaeaea">'
	cScryptHtml += '		<table style="background:#eaeaea;font-family:Lucida grande,Sans-SerIf;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="100%">'
	cScryptHtml += '			<tbody><tr>'
	cScryptHtml += '				<td style="padding:25px 0 55px" align="center">'
	cScryptHtml += '					<table style="padding:0 50px;text-align:left;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="800">'
	cScryptHtml += '		    <tbody><tr>'
	cScryptHtml += '							<td style="padding-bottom:10px">'
	cScryptHtml += '								<img src="'+cLinkImg+'">							</td>'
	cScryptHtml += '						</tr>'
	cScryptHtml += '						<tr>'
	cScryptHtml += '							<td height="400" style="font-size:13px;color:#888;padding:30px 40px;border:1px solid #b8b8b8;background-color:#fff">'
	cScryptHtml += '								<p style="color:black;margin:0">Você acaba de receber um informativo de '+ cEmpAnt + cFilAnt + "-" + cNomeEmp +'.</p>'
	cScryptHtml += '				  <div style="background-color:#e3e3e3;padding:20px;color:black;margin:30px 0">'
	cScryptHtml += '									<span style="font-weight:bold;font-size:14px;margin:0">Validação XML</span>'
	
	
	//cScryptHtml += '			                        <hr style="margin:15px 0">'
	//cScryptHtml += '									<p style="margin:0"></p>'
	
	cScryptHtml += '									<table width="674" border="0">'
	cScryptHtml += '                                      <tr>'
	cScryptHtml += '                                       		<td colspan="3" width="547" style="border 1px black"><br/>Retorno:<br/><span class="style4 style7">' + cMsg + '</span></td>'
	cScryptHtml += '                                      </tr>'
	cScryptHtml += '                                 </table>'
	cScryptHtml += '                            <br>'
	
	cScryptHtml += '					          </div>'
	cScryptHtml += '						  <p>Esta notificação foi enviada por um email configurado para não receber resposta.<br>'
	cScryptHtml += '									Por favor, não responda esta mensagem.							  </p>'
	cScryptHtml += '						  </td>'
	cScryptHtml += '						</tr>'
	cScryptHtml += '					</tbody></table>'
	
	cScryptHtml += '	    <p align="center" style="width:640px;padding:10px 20px;font-size:10px;color:#888;line-height:14px">'
	cScryptHtml += '						Para acessar o site da '+cNomeEmp+','
	cScryptHtml += '						<a href="'+cLinkSit+'" style="color:#666;text-decoration:underline" target="_blank">clique aqui.</a>					</p>'
	cScryptHtml += '			  </td>'
	cScryptHtml += '			</tr>'
	cScryptHtml += '		</tbody></table><div class="yj6qo"></div><div class="adL">'
	cScryptHtml += '	</div></div><div class="adL">'
	cScryptHtml += '</div></div></div><div id=":104" class="ii gt" style="display:none"><div id=":103"></div></div><div class="hi"></div></div>'
	cScryptHtml += '		</body>'
	cScryptHtml += '	</html>'
	
	u_EnvEmail(::cEmailCTe, "Erro CT-e FACILE", cScryptHtml)
	
	RestArea(aAreaSA2)

Return()

Method WorkFlowSE4() Class VIXA258

	Local cAlias := GetNextAlias()
	Local cScryptHtml 	:= ""
	Local cLinkImg	 	:= "http://www.grupouniaosa.com.br/wp-content/themes/grupouniao/images/logo.png"
	Local cNomeEmp	 	:= Alltrim(SM0->M0_NOME) + "-" + Alltrim(SM0->M0_FILIAL)
	Local cLinkSit 	:= "http://www.grupouniaosa.com.br/"
	Local cAssunto 	:= "Condição de pgto. alterada"
	
	BeginSql Alias cAlias
	
		SELECT	COUNT(*) as NUM FROM %Table:SA2% WHERE A2_COND = %Exp:SE4->E4_CODIGO% AND D_E_L_E_T_ = ''
	
	EndSql
	
	IF (cAlias)->NUM > 0 
	
		cScryptHtml := '	<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word"'
		cScryptHtml += '	xmlns="http://www.w3.org/TR/REC-html40">'
		cScryptHtml += '	<head>'
		cScryptHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
		cScryptHtml += '		<title>Comunicado Orçamento '+SM0->M0_FILIAL+'</title>'
		cScryptHtml += '      <style type="text/css">'
		cScryptHtml += '<!--'
		cScryptHtml += '.style6 {font-size: 12px; font-weight: bold; }'
		cScryptHtml += '.style7 {font-size: 12px}'
		cScryptHtml += '-->'
		cScryptHtml += '        </style>'
		cScryptHtml += '</head>'
		cScryptHtml += '	<body>'
		cScryptHtml += '<div class="gs">'
		cScryptHtml += '<div class="gE iv gt"></div>'
		cScryptHtml += '<div class="utdU2e"></div><div class="tx78Ic"></div><div class="QqXVeb"></div><div id=":10g" tabindex="-1"></div><div id=":118" class="ii gt adP adO"><div id=":119"><u></u>'
		cScryptHtml += '	<div style="padding:0;margin:0;background:#eaeaea">'
		cScryptHtml += '		<table style="background:#eaeaea;font-family:Lucida grande,Sans-SerIf;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="100%">'
		cScryptHtml += '			<tbody><tr>'
		cScryptHtml += '				<td style="padding:25px 0 55px" align="center">'
		cScryptHtml += '					<table style="padding:0 50px;text-align:left;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="800">'
		cScryptHtml += '		    <tbody><tr>'
		cScryptHtml += '							<td style="padding-bottom:10px">'
		cScryptHtml += '								<img src="'+cLinkImg+'">							</td>'
		cScryptHtml += '						</tr>'
		cScryptHtml += '						<tr>'
		cScryptHtml += '							<td height="400" style="font-size:13px;color:#888;padding:30px 40px;border:1px solid #b8b8b8;background-color:#fff">'
		cScryptHtml += '								<p style="color:black;margin:0">Você acaba de receber um informativo de '+ cEmpAnt + cFilAnt + "-" + cNomeEmp +'.</p>'
		cScryptHtml += '				  <div style="background-color:#e3e3e3;padding:20px;color:black;margin:30px 0">'
		cScryptHtml += '									<span style="font-weight:bold;font-size:14px;margin:0">Validação condição de pagamento</span>'

		
		cScryptHtml += '			                        <hr style="margin:15px 0">'
		cScryptHtml += '									<p style="margin:0"></p>'
		
		cScryptHtml += '									<table width="674" border="0">'


			cScryptHtml += '                                      <tr>'
			cScryptHtml += '                                       		<td width="547" style="border 1px black">A condição de pagamento ' +SE4->E4_CODIGO+'  foi Alterada.</td>'
			cScryptHtml += '                                      </tr>'		
										
		
		cScryptHtml += '                                 </table>'
		cScryptHtml += '                            <br>'
		
		cScryptHtml += '					          </div>'
		cScryptHtml += '						  <p>Esta notIficação foi enviada por um email configurado para não receber resposta.<br>'
		cScryptHtml += '									Por favor, não responda esta mensagem.							  </p>'
		cScryptHtml += '						  </td>'
		cScryptHtml += '						</tr>'
		cScryptHtml += '					</tbody></table>'
		
		cScryptHtml += '	    <p align="center" style="width:640px;padding:10px 20px;font-size:10px;color:#888;line-height:14px">'
		cScryptHtml += '						Para acessar o site da '+cNomeEmp+','
		cScryptHtml += '						<a href="'+cLinkSit+'" style="color:#666;text-decoration:underline" target="_blank">clique aqui.</a>					</p>'
		cScryptHtml += '			  </td>'
		cScryptHtml += '			</tr>'
		cScryptHtml += '		</tbody></table><div class="yj6qo"></div><div class="adL">'
		cScryptHtml += '	</div></div><div class="adL">'
		cScryptHtml += '</div></div></div><div id=":104" class="ii gt" style="display:none"><div id=":103"></div></div><div class="hi"></div></div>'
		cScryptHtml += '		</body>'
		cScryptHtml += '	</html>'
		
		u_EnvEmail(::cEmailNFe, cAssunto, cScryptHtml)
	
	EndIf 

Return()

/*/{Protheus.doc} NfGarantia
Analisa as CFOPs dos produtos da nota neessitam de validação
Todas as CFOPs contidas no parâmetro MV_YCFOSPC não necessitam de 
pois são nota de Bonificação, garantia ...
@author henrique.reis
@since 28/12/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/Method NfGarantia() Class VIXA258
	Local aAreaSDT 	:= SDT->(GetArea())
	Local cCFOP		:= ''
	Local lRet		:= .F.
	Local cCFOPGara := AllTrim(GetNewPar("MV_YCFOSPC","5916;6916;6910;5910;5949;6949"))
	Local lEntrou 	:= .F.
	
	If SDS->(DBSeek(xFilial("SDS") + ::cDoc + ::cSerie + ::cFornece + ::cLoja ))
		If SDS->DS_TIPO == "T"
			Return .F.
		EndIf
	EndIf
	
	If SDT->(DBSeek(xFilial("SDT") + ::cFornece + ::cLoja + ::cDoc + ::cSerie))
		While SDT->(!EOF()) .And. SDT->(DT_FILIAL + DT_FORNEC + DT_LOJA +DT_DOC + DT_SERIE) == xFilial("SDT") + ::cFornece + ::cLoja + ::cDoc + ::cSerie
			nItem := Val(SDT->DT_ITEM)
	
			cCFOP := ''
			
			//Quando o XML possui apenas um produto, a tag PROD não vem com o tipo Array
			If Type("oItens["+cValToChar(nItem)+"]") == "U"	
				If ValType(XmlChildEx(oItens, "_PROD")) == "O"
					//Obtem a CFOP de cada produto para identificar se é uma nota de garantia ou não
					If ValType(XmlChildEx(oItens:_Prod, "_CFOP")) == "O"								
						cCFOP := oItens:_Prod:_CFOP:Text

						lEntrou := .T.
						//Se uma CFOP não for de garantia, já sai da rotina
						If ! SubStr(cCFOP, 2, 3) $ cCFOPGara 
							RestArea(aAreaSDT)
							Return .F.
						EndIf
					EndIf	
				EndIf				
			Else
				//Obtem a CFOP de cada produto para identificar se é uma nota de garantia ou não
				If ValType(XmlChildEx(oItens[nItem]:_Prod, "_CFOP")) == "O"								
					cCFOP := oItens[nItem]:_Prod:_CFOP:Text
					lEntrou := .T.
					
					//Se uma CFOP não for de garantia, já sai da rotina
					If ! SubStr(cCFOP, 2, 3) $ cCFOPGara 
						RestArea(aAreaSDT)
						Return .F.
					EndIf
				EndIf	
			EndIf	
			
			SDT->(DbSkip())
		EndDo		
	EndIf
	
	//Se entrou no WHILE da tabela SDT e não deu o return é porque 
	//todas as CFOPs dos produtos da nota não precisam de um pedido
	If lEntrou
		lRet := .T.	
	EndIf
	
	RestArea(aAreaSDT)
	
return lRet