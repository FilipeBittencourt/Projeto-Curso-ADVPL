#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} BIA657
@description REALIZA A LEITURA DOS XMLS DE ENTRADA PARA INCLUSÃO NA SDS E SDT
@author LUANA MARIN RIBEIRO
@since 23/01/2019
@version 1.0
@type function
/*/
User Function BIA657(_oXml,lJob,Origem)
	Local lRet

	lRet := LeXml(_oXml,lJob,Origem)

Return (lRet)

Static Function LeXml (cXMLOri,lJob,Origem)
	Local lRet 	   := .T.
	Local cError   := ""
	Local cWarning := ""
	Local oFullXml := NIL

	//Origem == "G" (GT1POSIN)
	//Origem == "M" (GT1POSIN)

	If !Empty(cXMLOri)
		If Origem <> "G"
			oFullXML := XmlParser(cXMLOri,"_",@cError,@cWarning)

			If !Empty(cError) //-- Erro na sintaxe do XML
				If lJob
					Conout("Erro de sintaxe no arquivo XML: Entre em contato com o emissor do documento e comunique a ocorrência.(BIA657)")
				Else
					MsgBox("Erro de sintaxe no arquivo XML: Entre em contato com o emissor do documento e comunique a ocorrência.","BIA657","ALERT") //-- Erro
				EndIf
				lRet := .F.
			EndIf
		Else
			oFullXML := cXMLOri
		EndIf

		If lRet == .T.
			If ValType(oFullXML)=="O"
				Do Case
					Case ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O" //-- Nota normal, devolucao, beneficiamento, bonificacao
					lRet := IXmlNf(lJob,oFullXml:_NFeProc:_NFe,,cXmlOri,Origem)
					Case ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O" //-- Nota Fiscal Complementar
					lRet := IXmlCom(lJob,oFullXml:_Invoic_NFe_Compl,cXMLOri,Origem)
				EndCase
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return (lRet)

Static Function IXmlNf(lJob,oFullXML,lNfeCompl,cXmlOri,Origem)
	Local cXML       := ""
	Local cError     := ""
	Local cWarning   := ""
	Local cCGC	     := ""
	Local cTipoNF    := ""
	Local cTabEmit   := ""
	Local cDoc	     := ""
	Local cSerie     := ""
	Local cCodigo    := ""
	Local cLoja	     := ""
	Local cNomeFor   := ""
	Local cCampo1    := ""
	Local cCampo2    := ""
	Local cCampo3    := ""
	Local cCampo4    := ""
	Local cCampo5    := ""
	Local cLote		 := ""
	Local cPedido	 := Space(TamSx3("DT_PEDIDO")[1])
	Local cItemPed	 := Space(TamSx3("DT_ITEMPC")[1])
	Local cNFECFAP   := SuperGetMV("MV_XMLCFPC",.F.,"")
	Local cNFECFBN   := SuperGetMV("MV_XMLCFBN",.F.,"")
	Local cNFECFDV   := SuperGetMV("MV_XMLCFDV",.F.,"")
	Local cNFECFND   := SuperGetMV("MV_XMLCFND",.F.,"")
	Local cNFECFNO   := SuperGetMV("MV_XMLCFNO",.F.,"")
	Local cCFOP      :='N'
	Local lFound     := .F.
	Local lProces    := .T.
	Local nX		 := 0
	Local nY		 := 0
	Local oAuxXML    := NIL
	Local oXMLBia	 := NIL
	Local aItens     := {}
	Local aCabSDS    := {}
	Local aItSDT   	 := {}
	Local cProduto	 := ""
	Local nQuant	 := 0
	Local nPrecUni	 := 0
	Local cCNPJTran  := ""
	Local cCodTransp := ""
	Local cPlacaTran := ""
	Local nPesoLiq   := 0
	Local nPesoBruto := 0
	Local cTipoFrete := ""
	Local aQtdVol	 := {} 
	Local aEspVol	 := {}
	Local cFciCod	 := ""
	Local nTamFci	 := TamSx3("DT_FCICOD")[1]
	Local dValidLote := StoD("")
	Local cCodCFOP	:= ""
	Local cCodOrig	:= ""
	Local cCodCST	:= ""
	Local cMotivo	:= ""
	Local cChaveNFe	:= ""
	Local ncStat	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³IMPOSTOS dos itens ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Local nIPIItem  := 0
	Local nICMItem  := 0
	Local nISSItem  := 0    
	Local nPISItem  := 0
	Local nCOFItem  := 0
	Local nIMCSTIt := 0

	Local nAlIPIItem  := 0
	Local nAlICMItem  := 0
	Local nAlISSItem  := 0    
	Local nAlPISItem  := 0
	Local nALCOFItem  := 0
	Local nALIMCSTIt  := 0
	Local nBSICMST	  := 0
	Local nBSICM	  := 0

	Local nBCFCPSTRet := 0
	Local nPFCPSTRet  := 0
	Local nVFCPSTRet  := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Variáveis SIGATMS  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Local cCGCDes	 	 := ""
	Local cInsc	 	 	 := ""
	Local cInsDes	 	 := "" 
	Local lAchouForn	:= .F.
	Local nQCNPJ	:= 0
	Local nQINSC	:= 0
	Local cNFOriComp	:= ""
	Local cSerOriComp	:= ""
	Local cItOriComp	:= ""
	Local cChvNFComp	:= ""
	Local lSemCad		:= .F.
	Local lSemIE		:= .F.
	Local cHrEmis		:= ""
	Local lFCPAnt		:= SDT->(ColumnPos("DT_XBFCPAN")) > 0 .And. SDT->(ColumnPos("DT_XAFCPAN")) > 0 .And. SDT->(ColumnPos("DT_XVFCPAN")) > 0 //verifica se estes campos existem para inclusao de valor nos mesmos

	Default lJob := .T.
	Default oFullXML := NIL
	Default lNfeCompl := .F.
	Default cXmlOri := ""

	If lProces
		If Origem <> "G"
			oFullXML := XmlParser(cXMLOri,"_",@cError,@cWarning)

			If !Empty(cError) //-- Erro na sintaxe do XML
				If lJob
					Conout("Erro de sintaxe no arquivo XML: Entre em contato com o emissor do documento e comunique a ocorrência.(BIA657)")
				Else
					MsgBox("Erro de sintaxe no arquivo XML: Entre em contato com o emissor do documento e comunique a ocorrência.","BIA657","ALERT") //-- Erro
				EndIf
				lProces := .F.
			EndIf
		Else
			oFullXML := cXMLOri
		EndIf

		If lProces		
			oXMLBia    := oFullXML
			oAuxXML := oXMLBia			
			//-- Resgata o no inicial da NF-e
			If	lNfeCompl
				oXMLBia := oFullXML:_Invoic_NFe_Compl:_NFe_Sefaz:_NFe
			Else
				While !lFound
					oAuxXML := XmlChildEx(oAuxXML,"_NFE")
					If !(lFound := oAuxXML # NIL)
						For nX := 1 To XmlChildCount(oXMLBia)
							oAuxXML  := XmlChildEx(XmlGetchild(oXMLBia,nX),"_NFE")
							lFound := oAuxXML:_InfNfe# Nil
							If lFound
								oXMLBia := oAuxXML
								Exit
							EndIf
						Next nX
					EndIf				
					If lFound
						oXMLBia := oAuxXML
						Exit
					EndIf
				EndDo			
			EndIf

			//Hora emissão da NF-e
			oXMLProtNFe := XmlChildEx(oFullXML:_NFEPROC:_PROTNFE,"_INFPROT")
			If Valtype(XmlChildEx(oXMLProtNFe,"_DHRECBTO")) <> "U"
				cHrEmis := Substr(oXMLProtNFe:_DhRecbto:Text,12)
			Endif

			oAuxXml := XmlChildEx(oXMLBia,"_INFNFE")

			//Emitente				
			If XmlChildEx(oAuxXml:_EMIT,"_CNPJ") # NIL
				cCGC := oAuxXml:_EMIT:_CNPJ:TEXT
			Elseif XmlChildEx(oAuxXml:_EMIT,"_CPF") # NIL
				cCGC := oAuxXml:_EMIT:_CPF:TEXT
			EndIf	
			If XmlChildEx(oAuxXml:_EMIT,"_IE") # NIL
				cInsc := oAuxXml:_EMIT:_IE:TEXT
			EndIf

			//Destinatario
			If XmlChildEx(oAuxXml:_DEST,"_CNPJ") # NIL
				cCGCDes := oAuxXml:_DEST:_CNPJ:TEXT
			Elseif XmlChildEx(oAuxXml:_DEST,"_CPF") # NIL
				cCGCDes := oAuxXml:_DEST:_CPF:TEXT
			EndIf
			If XmlChildEx(oAuxXml:_DEST,"_IE") # NIL
				cInsDes := oAuxXml:_DEST:_IE:TEXT					
			EndIf
		EndIf
	EndIf

	//Verifica se XML é Cancelado ou Rejeitado.
	If lProces .And. ValType(oXMLprotNFe) <> "U" .And. Valtype(XmlChildEx(oXMLprotNFe,"_CSTAT")) <> "U"

		ncStat := VAL(AllTrim(oXMLprotNFe:_cStat:Text))

		If ncStat == 101 .Or. ncStat == 151 .Or. ncStat > 200
			//Chave NF-e
			cChaveNFe	:= Right(AllTrim(oXMLBia:_InfNfe:_Id:Text),44)
			lProces	:= .F.

			//Motivo 
			If Valtype(XmlChildEx(oXMLprotNFe,"_XMOTIVO")) <> "U"
				cMotivo := ConvASC(oXMLprotNFe:_xMotivo:Text)  
			EndIf

			If ncStat == 101 .Or. ncStat == 151 //Cancelado
				If !lJob
					MsgBox("NF-e cancelada: " + cChaveNFe + " - Motivo: " + cMotivo,"BIA657","ALERT")
				Else
					Conout("NF-e cancelada: " + cChaveNFe + " - Motivo: " + cMotivo+" (BIA657)")
				EndIf				
			Else //Rejeitado
				If !lJob
					MsgBox("NF-e rejeitada: " + cChaveNFe + " - Motivo: " + cMotivo,"BIA657","ALERT")
				Else
					Conout("NF-e rejeitada: " + cChaveNFe + " - Motivo: " + cMotivo+" (BIA657)")
				EndIf
			EndIf	
		EndIf
	EndIf

	If lProces
		//-- Se tag _InfNfe:_Det valida
		//-- Extrai CGC do fornecedor/cliente
		aItens := IIF(ValType(oXMLBia:_InfNfe:_Det) == "O",{oXMLBia:_InfNfe:_Det},oXMLBia:_InfNfe:_Det)			
		If AllTrim(oXMLBia:_InfNfe:_Ide:_finNFe:Text) == "1"
			cTipoNF := "N"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a NF eh compl. de preco ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If Val(oXMLBia:_InfNFe:_TOTAL:_ICMSTOT:_VPROD:Text) == 0  .And.;
			(Val(oXMLBia:_InfNFe:_TOTAL:_ICMSTOT:_VICMS:Text) > 0 .Or.;
			Val(oXMLBia:_InfNFe:_TOTAL:_ICMSTOT:_VIPI:Text)  > 0 .Or.;
			Val(oXMLBia:_InfNFe:_TOTAL:_ICMSTOT:_VST:Text)   > 0)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Move arquivo XML de Compl. de Preco ICMS/IPI  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Conout("Documento complemento de preço icms/ipi não é inserido na SDT e SDS. (BIA657)")
				lProces	:= .F.
			EndIf

			//-- Valida o tipo da nf
			For nX := 1 To Len(aItens)
				If aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFAP
					cTipoNF := "O"
				ElseIf aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFBN
					cTipoNF := "B"
				ElseIf aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFDV
					cTipoNF := "D"
				EndIf
				If cTipoNF <> "N"
					Exit
				EndIf
			Next nX
		ElseIf AllTrim(oXMLBia:_InfNfe:_Ide:_finNFe:Text) == "2"
			cTipoNF := "C"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a NF eh compl. de preco ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If Val(oXMLBia:_InfNFe:_TOTAL:_ICMSTOT:_VPROD:Text) == 0  .And.;
			(Val(oXMLBia:_InfNFe:_TOTAL:_ICMSTOT:_VICMS:Text) > 0 .Or.;
			Val(oXMLBia:_InfNFe:_TOTAL:_ICMSTOT:_VIPI:Text)  > 0 .Or.;
			Val(oXMLBia:_InfNFe:_TOTAL:_ICMSTOT:_VST:Text)   > 0)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Move arquivo XML de Compl. de Preco ICMS/IPI  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Conout("Documento complemento de preço icms/ipi não é inserido na SDT e SDS. (BIA657)")
				lProces	:= .F.
			EndIf
		ElseIf AllTrim(oXMLBia:_InfNfe:_Ide:_finNFe:Text) == "3"
			Conout("Tipo NF-e de ajustes não é inserido na SDT e SDS. (BIA657)")
			lProces	:= .F.
		ElseIf AllTrim(oXMLBia:_InfNfe:_Ide:_finNFe:Text) == "4"
			For nX := 1 To Len(aItens)			
				If aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFNO // Tratamento para modificar o tipo da nota para N = Normal, quando TAG FINNFE = 4.				
					cTipoNF := "N"				
					Exit				
				ElseIf aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFBN				
					cTipoNF := "B"				
					Exit				
				EndIf			
			Next nX		
			If Empty(cTipoNF)
				cTipoNF := "D"
			Endif
		EndIf

		//-- Verifica se este ID ja foi processado	
		DbSelectArea("SDS")
		SDS->(DbSetOrder(2))
		lFound := SDS->(DbSeek(xFilial("SDS")+Right(AllTrim(oXMLBia:_InfNfe:_Id:Text),44)))//Filial + Chave de acesso

		If lFound
			If lJob
				Conout("ID de NF-e já registrado na NF do fornecedor. Exclua o documento registrado na ocorrência. (BIA657)")
			Else
				Conout(SDS->(DS_DOC+"/"+SerieNfId("SDS",2,"DS_SERIE")) + SDS->(DS_FORNEC+"/"+DS_LOJA)+" (BIA657)")
			EndIf
			lProces	:= .F.
		EndIf	

		cDoc     := StrZero(Val(AllTrim(oXMLBia:_InfNfe:_Ide:_nNF:Text)),TamSx3("F1_DOC")[1])
		cSerie   := PadR(oXMLBia:_InfNfe:_Ide:_Serie:Text,SerieNfId("SF1",6,"F1_SERIE"))

		If lProces
			//-- Se tag CGC valida
			//-- Busca fornecedor/cliente na base
			lAchouForn :=.F.
			cTabEmit := If (Empty(cTabEmit),If(cTipoNF $ "DB","SA1","SA2"),cTabEmit)
			(cTabEmit)->(dbSetOrder(3)) 	
			If (cTabEmit)->(dbSeek(xFilial(cTabEmit)+cCGC))
				While !(cTabEmit)->(EOF()) .And. cCGC $ limpCamp((cTabEmit)->&(Substr(cTabEmit,2,2)+"_CGC"))
					If (cTabEmit)->&(Substr(cTabEmit,2,2)+"_MSBLQL") <> "1" .And. (valIE(cInsc,(cTabEmit)->&(Substr(cTabEmit,2,2)+"_INSCR")) .Or. Empty(limpCamp(Alltrim((cTabEmit)->&(Substr(cTabEmit,2,2)+"_INSCR")))) .Or. "ISENT" $ limpCamp(Alltrim((cTabEmit)->&(Substr(cTabEmit,2,2)+"_INSCR"))))
						If valIE(cInsc,(cTabEmit)->&(Substr(cTabEmit,2,2)+"_INSCR"))
							cCodigo 	:= (cTabEmit)->&(Substr(cTabEmit,2,2)+"_COD")
							cLoja   	:= (cTabEmit)->&(Substr(cTabEmit,2,2)+"_LOJA")
							cNomeFor 	:= (cTabEmit)->&(Substr(cTabEmit,2,2)+"_NOME")
							nQCNPJ++
							nQINSC++
							lAchouForn 	:= .T.
							lSemIE 		:= .F.
						ElseIf Empty(limpCamp(Alltrim((cTabEmit)->&(Substr(cTabEmit,2,2)+"_INSCR")))) .And. nQINSC = 0
							cCodigo	:= (cTabEmit)->&(Substr(cTabEmit,2,2)+"_COD")
							cLoja		:= (cTabEmit)->&(Substr(cTabEmit,2,2)+"_LOJA")
							cNomeFor 	:= (cTabEmit)->&(Substr(cTabEmit,2,2)+"_NOME")
							nQCNPJ++
							lAchouForn := .T.
							lSemIE 		:= .F.
						ElseIf 'ISENT' $ limpCamp(Alltrim((cTabEmit)->&(Substr(cTabEmit,2,2)+"_INSCR"))) .And. nQINSC = 0
							cCodigo	:= (cTabEmit)->&(Substr(cTabEmit,2,2)+"_COD")
							cLoja		:= (cTabEmit)->&(Substr(cTabEmit,2,2)+"_LOJA")
							cNomeFor 	:= (cTabEmit)->&(Substr(cTabEmit,2,2)+"_NOME")
							nQCNPJ++
							lAchouForn := .T.
							lSemIE 		:= .F.
						ElseIf Empty(limpCamp(Alltrim((cTabEmit)->&(Substr(cTabEmit,2,2)+"_INSCR")))) .And. nQINSC <> 0 
							nQCNPJ++
							lAchouForn := .T.
						EndIf
						//Achou CNPJ mas IE esta cadastrado errado
					Elseif (cTabEmit)->&(Substr(cTabEmit,2,2)+"_MSBLQL") <> "1" .And. !Empty(limpCamp(Alltrim((cTabEmit)->&(Substr(cTabEmit,2,2)+"_INSCR")))) .And. !valIE(cInsc,(cTabEmit)->&(Substr(cTabEmit,2,2)+"_INSCR"))
						lAchouForn := .T.
						lSemIE := .T.
					EndIf
					(cTabEmit)->(dbSkip())
				EndDo

			Else

				lSemCad := .T.

			EndIf	

			If nQCNPJ > 1 .And. nQINSC <> 1 //CNPJ duplicado
				If lJob
					Conout("CNPJ duplicado:" + Transform(cCGC,"@R 99.999.999/9999-99")+ " (BIA657)")
				Else
					MsgBox("CNPJ duplicado:" + Transform(cCGC,"@R 99.999.999/9999-99"),"BIA657","ALERT")
				EndIf
				lProces := .F.
			Elseif lSemCad .Or. (lAchouForn .And. lSemIE) //CPNJ inexistente ou encontrou CNPJ mas não encontrou com a IE correta.
				If lJob
					Conout("CPNJ inexistente ou encontrou CNPJ mas não encontrou com a IE correta:" + Transform(cCGC,"@R 99.999.999/9999-99")+ " (BIA657)")
				Else
					MsgBox("CPNJ inexistente ou encontrou CNPJ mas não encontrou com a IE correta:" + Transform(cCGC,"@R 99.999.999/9999-99"),"BIA657","ALERT")
				EndIf
				lProces := .F.
			ElseIf !lAchouForn .And. !lSemCad //Fornecedor bloqueado
				If lJob
					Conout("Fornecedor/Cliente bloqueado na base:" + Transform(cCGC,"@R 99.999.999/9999-99")+ " (BIA657)")
				Else
					MsgBox("Fornecedor/Cliente bloqueado na base:" + Transform(cCGC,"@R 99.999.999/9999-99"),"BIA657","ALERT")
				EndIf
				lProces := .F.
			EndIf		
		EndIf

		//SE FOR PARA O EDI TEREMOS QUE AMARRAR COM O CLIENTE
		If cTipoNF $ "DB"
			cCampo1 := "A7_PRODUTO"
			cCampo2 := "A7_FILIAL"
			cCampo3 := "A7_CLIENTE"
			cCampo4 := "A7_LOJA"
			cCampo5 := "A7_CODCLI"				
		Else                                        
			//Processa cabeçalho e itens
			cCampo1 := "A5_PRODUTO"
			cCampo2 := "A5_FILIAL"
			cCampo3 := "A5_FORNECE"
			cCampo4 := "A5_LOJA"
			cCampo5 := "A5_CODPRF"
		EndIf

		//Grava o tipo do frete	
		If lProces
			Do Case 
				Case AllTrim(oXMLBia:_InfNfe:_Transp:_ModFrete:Text) == "0"
				cTipoFrete := "C"
				Case AllTrim(oXMLBia:_InfNfe:_Transp:_ModFrete:Text) == "1"
				cTipoFrete := "F"
				Case AllTrim(oXMLBia:_InfNfe:_Transp:_ModFrete:Text) == "2"
				cTipoFrete := "T"			
				Case AllTrim(oXMLBia:_InfNfe:_Transp:_ModFrete:Text) == "3"
				cTipoFrete := "S"
			End Case

			dbSelectArea("SDS") 
			dbSetorder(1)
			If msSeek(xFilial("SDS")+cDoc+cSerie+cCodigo+cLoja)
				If lJob
					Conout("Documento e serie já cadastrados:" + cDoc + "/" + cSerie + " (BIA657)")
				Else
					MsgBox("Documento e serie já cadastrados:" + cDoc + "/" + cSerie,"BIA657","ALERT")
				EndIf
				lProces := .F.
			EndIf
		EndIf

		If lProces
			//Grava os Dados da DANFE
			cCNPJTran  := ""
			cCodTransp := ""
			cPlacaTran := ""
			nPesoLiq   := 0
			nPesoBruto := 0

			//Prepara o Array aEspVol para gravar os campos Vol/Esp
			aAdd(aEspVol,{"DS_ESPECI1",""})
			aAdd(aEspVol,{"DS_ESPECI2",""})
			aAdd(aEspVol,{"DS_ESPECI3",""})
			aAdd(aEspVol,{"DS_ESPECI4",""})
			aAdd(aEspVol,{"DS_VOLUME1",0})
			aAdd(aEspVol,{"DS_VOLUME2",0})
			aAdd(aEspVol,{"DS_VOLUME3",0})
			aAdd(aEspVol,{"DS_VOLUME4",0})				
			If ValType(XmlChildEx(oXMLBia:_InfNFe,"_TRANSP")) == "O" 			
				If ValType(XmlChildEx(oXMLBia:_InfNFe:_Transp,"_TRANSPORTA")) == "O"
					If ValType(XmlChildEx(oXMLBia:_InfNFe:_Transp:_Transporta,"_CPF")) == "O"
						cCNPJTran := oXMLBia:_InfNfe:_Transp:_Transporta:_CPF:Text	
					ElseIf ValType(XmlChildEx(oXMLBia:_InfNFe:_Transp:_Transporta,"_CNPJ")) == "O"
						cCNPJTran := oXMLBia:_InfNfe:_Transp:_Transporta:_CNPJ:Text
					EndIf
					SA4->(dbSetOrder(3))
					If SA4->(dbSeek(xFilial("SA4")+cCNPJTran))
						cCodTransp := SA4->A4_COD
					EndIf
				EndIf
				If ValType(XmlChildEx(oXMLBia:_InfNFe:_Transp,"_VEICTRANSP")) == "O"
					If ValType(XmlChildEx(oXMLBia:_InfNFe:_Transp:_VeicTransp,"_PLACA")) == "O"
						cPlacaTran := oXMLBia:_InfNFe:_Transp:_VeicTransp:_Placa:Text
					EndIf
				EndIf
				If ValType(XmlChildEx(oXMLBia:_InfNFe:_Transp,"_VOL")) == "O"
					aQtdVol := {oXMLBia:_InfNfe:_Transp:_Vol}
				ElseIf ValType(XmlChildEx(oXMLBia:_InfNFe:_Transp,"_VOL")) == "A"
					aQtdVol := oXMLBia:_InfNfe:_Transp:_Vol
				EndIf
				For nX := 1 To Len(aQtdVol)
					If ValType(XmlChildEx(aQtdVol[nX],"_PESOB")) == "O"
						nPesoBruto += Val(aQtdVol[nX]:_PESOB:TEXT)
					EndIf
					If ValType(XmlChildEx(aQtdVol[nX],"_PESOL")) == "O"
						nPesoLiq += Val(aQtdVol[nX]:_PESOL:TEXT)
					EndIf
					If nX <= 4
						If ValType(XmlChildEx(aQtdVol[nX],"_ESP")) == "O"
							aEspVol[nX][2] := aQtdVol[nX]:_Esp:TEXT
						EndIf
						If ValType(XmlChildEx(aQtdVol[nX],"_QVOL")) == "O"
							aEspVol[nX+4][2] := Val(aQtdVol[nX]:_QVol:TEXT)
						EndIf
					EndIf
				Next nX
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida tag da data de emissao      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType(XmlChildEx(oXMLBia:_InfNfe:_Ide,"_DEMI")) == "O"
				dEmis := StoD(StrTran(AllTrim(oXMLBia:_InfNfe:_Ide:_DEmi:Text),"-",""))
			ElseIf ValType(XmlChildEx(oXMLBia:_InfNfe:_Ide,"_DHEMI")) == "O"
				dEmis := StoD(StrTran(Substr((oXMLBia:_InfNfe:_Ide:_DhEmi:Text),1,10),"-",""))
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os Dados do Cabecalho - SDS  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SDS")
			AADD(aCabSDS,{{"DS_FILIAL"	,xFilial("SDS")																	     		},; //Filial
			{"DS_CNPJ"		,cCGC																				},; //CGC
			{"DS_DOC"		,cDoc 																				},; //Numero do Documento
			{"DS_SERIE"		,cSerie 																			},; //Serie
			{"DS_FORNEC"	,cCodigo																			},; //Fornecedor
			{"DS_LOJA"		,cLoja 																				},; //Loja do Fornecedor
			{"DS_NOMEFOR"	,cNomeFor																			},; //Nome do Fornecedor
			{"DS_EMISSA"	,dEmis																				},; //Data de Emissão
			{"DS_EST"		,oXMLBia:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT												},; //Estado de emissao da NF
			{"DS_TIPO"		,cTipoNF													 						},; //Tipo da Nota
			{"DS_FORMUL"	,"N" 																		 		},; //Formulario proprio
			{"DS_ESPECI"	,"SPED"																		  		},; //Especie
			{"DS_ARQUIVO"	,""																   					},; //Arquivo importado
			{"DS_STATUS"	,If(cTipoNF <> "N",cTipoNF," ")														},; //Status
			{"DS_CHAVENF"	,Right(AllTrim(oXMLBia:_InfNfe:_Id:Text),44)											},; //Chave de Acesso da NF
			{"DS_VERSAO"	,oXMLBia:_InfNfe:_versao:text 															},; //Versão
			{"DS_USERIMP"	,IIf(!lJob,cUserName,"JOB")															},; //Usuario na importacao
			{"DS_DATAIMP"	,dDataBase																			},; //Data importacao do XML
			{"DS_HORAIMP"	,SubStr(Time(),1,5)																	},; //Hora importacao XML
			{"DS_FRETE"		,Val(oXMLBia:_INFNFE:_TOTAL:_ICMSTOT:_vFrete:TEXT)										},; //Valor Frete
			{"DS_SEGURO"	,Val(oXMLBia:_INFNFE:_TOTAL:_ICMSTOT:_vSeg:TEXT)										},; //Valor Seguro
			{"DS_DESPESA"	,Val(oXMLBia:_INFNFE:_TOTAL:_ICMSTOT:_vOutro:TEXT)										},; //Valor Desconto
			{"DS_DESCONTO"	,Val(oXMLBia:_INFNFE:_TOTAL:_ICMSTOT:_vDesc:TEXT)										},; //Valor Desconto
			{"DS_VALMERC"	,Val(oXMLBia:_INFNFE:_TOTAL:_ICMSTOT:_vProd:TEXT)										},; //Valor Mercadoria
			{"DS_TPFRETE"	,cTipoFrete																			},; //Tipo de Frete
			{"DS_TRANSP"	,cCodTransp																			},; //Codigo da Transportadora
			{"DS_PLACA"		,cPlacaTran																			},; //Placa
			{"DS_PLIQUI"	,nPesoLiq																			},; //Peso Liquido
			{"DS_PBRUTO"	,nPesoBruto																			},; //Peso Bruto
			{"DS_ESPECI1"	,cValToChar(aEspVol[1][2])															},; //Especie1
			{"DS_VOLUME1"	,aEspVol[5][2]																		},; //Volume1
			{"DS_ESPECI2"	,cValToChar(aEspVol[2][2])															},; //Especie2
			{"DS_VOLUME2"	,aEspVol[6][2]																		},; //Volume2
			{"DS_ESPECI3"	,cValToChar(aEspVol[3][2])															},; //Especie3
			{"DS_VOLUME3"	,aEspVol[7][2]																		},; //Volume3
			{"DS_ESPECI4"	,cValToChar(aEspVol[4][2])															},; //Especie4
			{"DS_VOLUME4"	,aEspVol[8][2]																		},; //Volume4
			{"DS_HORNFE"  	,cHrEmis																			}}) //Hora NF-e

		EndIf
		If lProces
			IIF(cTipoNF $ "DB",SA7->(DbSetOrder(1)),SA5->(DbSetOrder(1)))
			For nX := 1 To Len(aItens)
				cProduto := ""

				If Empty(cProduto)
					cSql := "SELECT " +cCampo1 + " FROM " +RetSqlName(If(cTipoNF $ "DB","SA7","SA5"))
					cSql += " WHERE D_E_L_E_T_ <> '*' AND "
					cSql += cCampo2 +" = '" +xFilial(If(cTipoNF $ "DB","SA7","SA5")) +"' AND "
					cSql += cCampo3 +" = '" +cCodigo +"' AND "
					cSql += cCampo4 +" = '" +cLoja +"' AND "
					cSql += "Replace("+cCampo5+", ' ','') = '" + StrTran(AllTrim(UPPER(StrTran(aItens[nX]:_Prod:_cProd:Text,"'"))), " ") +"' AND "
					cSql += cCampo1 +" <> ' '"

					If chkfile("QYR")
						dbSelectArea("QYR")
						dbCloseArea()
					EndIf
					TCQUERY cSql ALIAS "QYR" NEW

					If !QYR->(EOF())
						cProduto := QYR->(&cCampo1)
					Else
						If lJob
							Conout("Fornecedor sem cadastro de Produto x Fornecedor: CNPJ-> " + Transform(cCGC,"@R 99.999.999/9999-99") + " /Produto-> " + AllTrim(aItens[nX]:_Prod:_cProd:Text) + AllTrim(aItens[nX]:_Prod:_xProd:Text)+ " (BIA657)")
						Else
							MsgBox("Fornecedor sem cadastro de Produto x Fornecedor: CNPJ-> " + Transform(cCGC,"@R 99.999.999/9999-99") + " /Produto-> " + AllTrim(aItens[nX]:_Prod:_cProd:Text) + AllTrim(aItens[nX]:_Prod:_xProd:Text),"BIA657","ALERT")
						EndIf										
						lProces := .F.
					EndIf

					QYR->(dbCloseArea())
				EndIf
				nQuant := Val(aItens[nX]:_Prod:_qCom:Text)
				If (nPrecUni := Val(aItens[nX]:_Prod:_vUnCom:Text)) == 0  .And. cTipoNF <> "C"
					If lJob
						Conout("Nota fiscal possui itens com valor zerado./Verifique a nota recebida do fornecedor. (BIA657)")
					Else
						MsgBox("Nota fiscal possui itens com valor zerado./Verifique a nota recebida do fornecedor.","BIA657","ALERT")
					EndIf
					lProces := .F.
				EndIf

				If lProces .And. cTipoNF $ "NC"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existe a Tag para pedido de compra                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ValType(XmlChildEx(aItens[nX]:_Prod,"_XPED")) == "O"
						cPedido := aItens[nX]:_Prod:_xPed:Text
						If Len(cPedido) > TamSx3("DT_PEDIDO")[1]
							cPedido := RIGHT(cPedido,TamSx3("DT_PEDIDO")[1])
						Else
							cPedido := PADR(cPedido,TamSx3("DT_PEDIDO")[1])
						EndIf
					EndIf
					If ValType(XmlChildEx(aItens[nX]:_Prod,"_NITEMPED")) == "O"
						cItemPed:= aItens[nX]:_Prod:_nItemPed:Text
						If Len(cItemPed) > TamSx3("DT_ITEMPC")[1]
							cItemPed := RIGHT(cItemPed,TamSx3("DT_ITEMPC")[1])
						Else
							cItemPed := PADL(cItemPed,TamSx3("DT_ITEMPC")[1],"0")
						EndIf
					EndIf

					If !Empty(cPedido) .And. !Empty(cItemPed)
						DbSelectArea("SC7")
						DbSetOrder(1)
						If MsSeek(xFilial("SC7")+cPedido+cItemPed)
							If	SC7->C7_FORNECE == cCodigo .And. SC7->C7_LOJA == cLoja .And. SC7->C7_PRODUTO == cProduto .And. (SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA) > 0 .And. SC7->C7_ENCER != "E" .And. SC7->C7_RESIDUO != "S"
								lProces := .T.
							Else
								cPedido := Space(TamSx3("DT_PEDIDO")[1])
								cItemPed:= Space(TamSx3("DT_ITEMPC")[1])
							EndIf
						Else
							cPedido := Space(TamSx3("DT_PEDIDO")[1])
							cItemPed:= Space(TamSx3("DT_ITEMPC")[1])
						EndIf
					Else
						cPedido := Space(TamSx3("DT_PEDIDO")[1])
						cItemPed:= Space(TamSx3("DT_ITEMPC")[1])
					EndIf

					//Verifica NF Origem - NF de Complemento
					If cTipoNF == "C"
						If ValType(XmlChildEx(oXMLBia:_INFNFE,"_IDE")) == "O"
							If ValType(XmlChildEx(oXMLBia:_INFNFE:_IDE,"_NFREF")) == "O"
								If ValType(XmlChildEx(oXMLBia:_INFNFE:_IDE:_NFREF,"_REFNFE")) == "O"
									cChvNFComp := PadR(oXMLBia:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT,TamSX3("F1_CHVNFE")[1])

									If !Empty(cChvNFComp)
										cNFOriComp		:= Posicione("SF1",8,xFilial("SF1") + cChvNFComp,"F1_DOC")
										cSerOriComp	:= Posicione("SF1",8,xFilial("SF1") + cChvNFComp,"F1_SERIE")
										cItOriComp		:= Posicione("SD1",1,xFilial("SD1") + cNFOriComp + cSerOriComp + cCodigo + cLoja + cProduto,"D1_ITEM")
									Endif
								Endif
							Endif
						Endif		
					Endif
				EndIf

				//Verifica se existe a Tag para códido do FCI
				cFciCod := ""
				If lProces .and. ValType(XmlChildEx(aItens[nX]:_Prod,"_NFCI")) == "O"
					cFciCod := aItens[nX]:_Prod:_nFCI:Text
					If Len(cFciCod) > nTamFCI
						cFciCod := RIGHT(cFciCod,nTamFci)
					Else
						cFciCod := PADR(cFciCod,nTamFci)
					EndIf
				EndIf

				//Informacoes de Lote e Validade do Lote
				If lProces
					If ValType(XmlChildEx(aItens[nX]:_Prod,"_MED")) == "O"
						cLote      := aItens[nX]:_Prod:_Med:_Nlote:Text
						dValidLote := StoD(StrTran(AllTrim(aItens[nX]:_Prod:_Med:_Dval:Text),"-",""))
					EndIf
				EndIf

				//Verifica se Unid. Medida foi preenchida na relacao Prod. x Forn.					
				If lProces
					If cTipoNF == "N"
						If SA5->(DbSeek(xFilial("SA5")+cCodigo+cLoja+cProduto)) .And. SA5->A5_UMNFE == "2"
							nQuant := ConvUM(cProduto,Val(aItens[nX]:_Prod:_qCom:Text),Val(aItens[nX]:_Prod:_qCom:Text),1)
							SB1->(dbSetOrder(1))
							If SB1->(dbSeek(xFilial("SB1")+cProduto))
								nPrecUni := If(SB1->B1_TIPCONV == "M", (nPrecUni*SB1->B1_CONV), (nPrecUni/SB1->B1_CONV))
							EndIf
						EndIf
					ElseIf cTipoNF $ "DB" 
						If SA7->(DbSeek(xFilial("SA7")+cCodigo+cLoja+cProduto)) .And. SA7->A7_UMNFE == "2"
							nQuant := ConvUM(cProduto,Val(aItens[nX]:_Prod:_qCom:Text),Val(aItens[nX]:_Prod:_qCom:Text),1)
							SB1->(dbSetOrder(1))
							If SB1->(dbSeek(xFilial("SB1")+cProduto))
								nPrecUni := If(SB1->B1_TIPCONV == "M", (nPrecUni*SB1->B1_CONV), (nPrecUni/SB1->B1_CONV))
							EndIf
						EndIf	
					EndIf

					//Verifica se existe a Tag para os valores de frete/seguro/despesa
					nFretItem  := 0
					nDespItem  := 0
					nSegItem   := 0    
					nDescItem  := 0
					nUnidMed   := ""

					If ValType(XmlChildEx(aItens[nX]:_Prod,"_VFRETE")) == "O"
						nFretItem := Val(aItens[nX]:_Prod:_vFrete:Text)
					EndIf

					If ValType(XmlChildEx(aItens[nX]:_Prod,"_VOUTRO")) == "O"
						nDespItem := Val(aItens[nX]:_Prod:_vOutro:Text)
					EndIf

					If ValType(XmlChildEx(aItens[nX]:_Prod,"_VSEG")) == "O"
						nSegItem := Val(aItens[nX]:_Prod:_vSeg:Text)
					EndIf

					If ValType(XmlChildEx(aItens[nX]:_Prod,"_VDESC")) == "O"
						nDescItem := Val(aItens[nX]:_Prod:_vDesc:Text)
					EndIf

					If ValType(XmlChildEx(aItens[nX]:_Prod,"_UCOM")) == "O"
						nUnidMed := aItens[nX]:_Prod:_UCom:Text
					EndIf

					cCfop := 'N'
					If aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFND
						cCfop:='S'
					EndIF

					cCodCFOP := ""
					If !Empty(aItens[nX]:_PROD:_CFOP:TEXT)
						cCodCFOP := aItens[nX]:_PROD:_CFOP:TEXT
					EndIF

					//Verifica se existe a Tag para os valores de impostos.
					nIPIItem  := 0
					nICMItem  := 0
					nISSItem  := 0    
					nPISItem  := 0
					nCOFItem  := 0
					nIMCSTIt  := 0

					nAlIPIItem  := 0
					nAlICMItem  := 0
					nAlISSItem  := 0    
					nAlPISItem  := 0
					nALCOFItem  := 0
					nALIMCSTIt  := 0
					nBSICMST	:= 0
					nBSICM	:= 0

					nBCFCPSTRet := 0
					nPFCPSTRet  := 0
					nVFCPSTRet  := 0

					//--IPI
					If ValType(XmlChildEx(aItens[nX]:_Imposto,"_IPI")) == "O"
						If ValType(XmlChildEx(aItens[nX]:_Imposto:_IPI,"_IPITRIB")) == "O"
							// Verifica as TAGS do imposto IPI, pois ha XML que vem somente com 1 das TAGS abaixo.
							If ValType(XmlChildEx(aItens[nX]:_Imposto:_IPI:_IPITrib,"_VIPI")) == "O"

								nIPIItem := Val(aItens[nX]:_Imposto:_IPI:_IPITrib:_vIPI:Text)

							EndIf

							If ValType(XmlChildEx(aItens[nX]:_Imposto:_IPI:_IPITrib,"_PIPI")) == "O"

								nAlIPIItem := Val(aItens[nX]:_Imposto:_IPI:_IPITrib:_pIPI:Text)

							EndIf

						Endif
					EndIf

					//--ICMS
					If ValType(XmlChildEx(aItens[nX]:_Imposto,"_ICMS")) == "O"
						If ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS00")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS00:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS00:_CST:Text, "")
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS00:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS00:_pICMS:Text), 0)
							nBSICM  	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_VBC")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS00:_VBC:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS10")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS10:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS10:_CST:Text, "")
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_pICMS:Text), 0)
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_pICMSST:Text), 0)
							nBSICMST  	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VBCST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_VBCST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS20")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS20:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS20:_CST:Text, "")
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS20:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS20:_pICMS:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS30")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS30:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS30:_CST:Text, "")
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_pICMSST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS40")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS40,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS40:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS40,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS40:_CST:Text, "")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS41")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS41,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS41:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS41,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS41:_CST:Text, "")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS50")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS50,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS50:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS50,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS50:_CST:Text, "")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS51")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS51:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS51:_CST:Text, "")
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS51:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS51:_pICMS:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS60")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS60:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS60:_CST:Text, "")
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vICMSSTRet:Text), 0)
							nBCFCPSTRet := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VBCFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vBCFCPSTRet:Text), 0)
							nPFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_PFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_pFCPSTRet:Text), 0)
							nVFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vFCPSTRet:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS70")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS70:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS70:_CST:Text, "")
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_pICMS:Text), 0)
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_pICMSST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS90")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS90:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS90:_CST:Text, "")
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_pICMS:Text), 0)	
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_pICMSST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSPART")) == "O"
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSPART,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSPART:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSPART,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSPART:_pICMSST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSST")) == "O" 
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSST,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSST:_vICMSSTRet:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN101")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN101,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN101:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN101,"_CSOSN")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN101:_CSOSN:Text, "")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN102")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN102,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN102:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN102,"_CSOSN")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN102:_CSOSN:Text, "")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN103")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN103,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN103:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN103,"_CSOSN")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN103:_CSOSN:Text, "")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN201")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN201,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN201:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN201,"_CSOSN")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN201:_CSOSN:Text, "")	
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN201,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN201:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN201,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN201:_pICMSST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN202")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN202,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN202:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN202,"_CSOSN")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN202:_CSOSN:Text, "")
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN202,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN202:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN202,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN202:_pICMSST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN203")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN203,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN203:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN203,"_CSOSN")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN203:_CSOSN:Text, "")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN300")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN300,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN300:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN300,"_CSOSN")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN300:_CSOSN:Text, "")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN400")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN400,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN400:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN400,"_CSOSN")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN400:_CSOSN:Text, "")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN500")) == "O"
							cCodOrig	 := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_ORIG:Text, "")
							cCodCST		 := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_CSOSN")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_CSOSN:Text, "")	
							nIMCSTIt	 := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vICMSSTRet:Text), 0)
							nBCFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VBCFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vBCFCPSTRet:Text), 0)
							nPFCPSTRet   := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_PFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_pFCPSTRet:Text), 0)
							nVFCPSTRet   := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vFCPSTRet:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN900")) == "O"
							cCodOrig	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_ORIG:Text, "")
							cCodCST		:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_CSOSN")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_CSOSN:Text, "")
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_pICMS:Text), 0)	
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_vICMSSTRet:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_PICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_pICMSSTRet:Text), 0)
						EndIf
					EndIf

					//--PIS
					If ValType(XmlChildEx(aItens[nX]:_Imposto,"_PIS")) == "O"
						If ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS,"_PISALIQ")) == "O"  
							nPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISAliq:_vPIS:Text)
							nAlPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISAliq:_pPIS:Text)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS,"_PISQTDE")) == "O"
							nPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISQtde:_vPIS:Text)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS,"_PISOUTR")) == "O"
							nPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISOutr:_vPIS:Text)
							If ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS:_PISOutr,"_PPIS")) == "O"
								nAlPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISOutr:_pPIS:Text)
							ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS:_PISOutr,"_VALIQPROD")) == "O"
								nAlPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISOutr:_vAliqProd:Text)
							EndIf
						Endif
					EndIf

					//--COFINS
					If ValType(XmlChildEx(aItens[nX]:_Imposto,"_COFINS")) == "O"
						If ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS,"_COFINSALIQ")) == "O"
							nCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSAliq:_vCOFINS:Text)
							nAlCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSAliq:_pCOFINS:Text)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS,"_COFINSQTDE")) == "O"
							nCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSQtde:_vCOFINS:Text)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS,"_COFINSOUTR")) == "O"
							nCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSOutr:_vCOFINS:Text)
							If ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS:_COFINSOutr,"_PCOFINS")) == "O"
								nAlCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSOutr:_pCOFINS:Text)
							ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS:_COFINSOutr,"_VALIQPROD")) == "O"
								nAlCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSOutr:_vAliqProd:Text)
							EndIf
						EndIf
					EndIf

					//Dados dos Itens - SDT
					DbSelectArea("SDT")

					//DADOS DO PRODUTO
					aAdd(aItSDT,{{"DT_FILIAL" 	,xFilial("SDT")																},; //Filial
					{"DT_CNPJ"		,cCGC																		},; //CGC
					{"DT_COD"		,cProduto																	},; //Codigo do produto
					{"DT_PRODFOR"	,aItens[nX]:_PROD:_CPROD:TEXT												},; //Cdgo do pduto do Fornecedor
					{"DT_DESCFOR"	,aItens[nX]:_PROD:_XPROD:TEXT												},; //Dcao do pduto do Fornecedor
					{"DT_ITEM"   	,PadL(Len(aItSDT)+1,TamSX3("D1_ITEM")[1],"0")								},; //Item
					{"DT_QUANT"  	,IIF(cTipoNF == "C",0,nQuant)												},; //Qtde
					{"DT_VUNIT"	,IIF(cTipoNF == "C",Val(aItens[nX]:_Prod:_vProd:Text),nPrecUni)				},; //Vlor Unitário
					{"DT_FORNEC"	,cCodigo																	},; //Forncedor
					{"DT_LOJA"   	,cLoja																		},; //Lja
					{"DT_DOC"    	,cDoc																		},; //DocmTo
					{"DT_SERIE"	,cSerie							   											},; //Serie
					{"DT_VALFRE"	,nFretItem																	},; //Valor Frete
					{"DT_DESPESA"	,nDespItem							   										},; //Valor Despesa
					{"DT_SEGURO"	,nSegItem								  									},; //Valor Seguro
					{"DT_VALDESC"	,nDescItem																	},; //Valor Desconto
					{"DT_YUNID"	,nUnidMed																	},; //Unidade de Medida
					{"DT_TOTAL"	,IIF(cTipoNF == "C",Val(aItens[nX]:_Prod:_vProd:Text),(nQuant * nPrecUni))	},; //Vlor Total
					{"DT_PEDIDO"	,cPedido							   										},; //Pedido
					{"DT_ITEMPC"	,cItemPed								  									},; //Item do pedido
					{"DT_CFOP"		,cCFOP								  										},; // Confirma CFOP de Retorno de Beneficiamento 'S' ou 'N'
					{"DT_LOTE"		,cLote								  										},; // Lote
					{"DT_DTVALID"	,dValidLote								  									},; // Validade do Lote
					{"DT_FCICOD"	,cFciCod																	}})	//Codigo FCI (alteração)

					If cTipoNF == "C" .And. !Empty(cNFOriComp) .And. !Empty(cSerOriComp) .And. !Empty(cItOriComp)
						aAdd(aItSDT[Len(aItSDT)],{"DT_NFORI"	, cNFOriComp}) // NF Origem
						aAdd(aItSDT[Len(aItSDT)],{"DT_SERIORI"	, cSerOriComp}) // Serie Origem
						aAdd(aItSDT[Len(aItSDT)],{"DT_ITEMORI"	, cItOriComp}) // Item Origem
					Endif

					aAdd(aItSDT[nX],{"DT_CODCFOP" , cCodCFOP})
					aAdd(aItSDT[nX],{"DT_YCFOP"   , cCodCFOP})
					aAdd(aItSDT[nX],{"DT_YCSTFOR" , cCodOrig + cCodCST})
					aAdd(aItSDT[nX],{"DT_XMLIPI"  , nIPIItem})
					aAdd(aItSDT[nX],{"DT_XMLICM"  , nICMItem})
					aAdd(aItSDT[nX],{"DT_XMLISS"  , nISSItem})
					aAdd(aItSDT[nX],{"DT_XMLPIS"  , nPISItem})
					aAdd(aItSDT[nX],{"DT_XMLCOF"  , nCOFItem})
					aAdd(aItSDT[nX],{"DT_XMLICST" , nIMCSTIt})

					aAdd(aItSDT[nX],{"DT_XALQIPI"  , nAlIPIItem})
					aAdd(aItSDT[nX],{"DT_XALQICM"  , nAlICMItem})
					aAdd(aItSDT[nX],{"DT_XALQISS"  , nAlISSItem})
					aAdd(aItSDT[nX],{"DT_XALQPIS"  , nAlPISItem})
					aAdd(aItSDT[nX],{"DT_XALQCOF"  , nAlCOFItem})
					aAdd(aItSDT[nX],{"DT_XALICST"  , nALIMCSTIt})
					aAdd(aItSDT[nX],{"DT_YXMLBST"  , nBSICMST})
					aAdd(aItSDT[nX],{"DT_YXMLBIC"  , nBSICM})

					If lFCPAnt
						aAdd(aItSDT[Len(aItSDT)],{"DT_XBFCPAN"  , nBCFCPSTRet})
						aAdd(aItSDT[Len(aItSDT)],{"DT_XAFCPAN"  , nPFCPSTRet})
						aAdd(aItSDT[Len(aItSDT)],{"DT_XVFCPAN"  , nVFCPSTRet})
					Endif
				EndIf    
			Next nX 
			If (TamSx3("DS_PLIQUI")[1] - (TamSx3("DS_PLIQUI")[2]+1) < Len(AllTrim(STR(Int(nPesoLiq)))) .Or. TamSx3("DS_PLIQUI")[2] < Len(AllTrim(Str(nPesoLiq - Int(nPesoLiq))))-2) .And. lProces
				Conout("DS_PLIQUI - O tamanho do campo não suporta o valor fornecido. (BIA657)")
				lProces := .F.
			ElseIf (TamSx3("DS_PBRUTO")[1] - (TamSx3("DS_PBRUTO")[2]+1) < Len(AllTrim(STR(Int(nPesoBruto)))) .Or. TamSx3("DS_PBRUTO")[2] < Len(AllTrim(Str(nPesoBruto - Int(nPesoBruto))))-2) .And. lProces
				Conout("DS_PBRUTO - O tamanho do campo não suporta o valor fornecido. (BIA657)")			
				lProces := .F.			
			EndIf
		EndIf
		//Grava os dados do cabeçalho e itens da nota importada do XML
		If lProces
			Begin Transaction

				aCabSDS:=aCabSDS[1]
				//--Grava cabeçalho
				RecLock("SDS",.T.)
				For nX:=1 To Len(aCabSDS)
					If aCabSDS[nX][1] == "DS_SERIE"
						SerieNfId("SDS",1,"DS_SERIE",dEmis,"SPED",aCabSDS[nX][2])
					Else
						SDS->&(aCabSDS[nX][1]):= aCabSDS[nX][2]
					Endif
				Next
				dbCommit()
				MsUnlock()
				//--Grava Itens
				For nX:=1 To Len(aItSDT)
					RecLock("SDT",.T.)
					For nY:=1 To Len(aItSDT[nX])
						If aItSDT[nX][nY][1] == "DT_SERIE"
							SerieNfId("SDT",1,"DT_SERIE",dEmis,"SPED",aItSDT[nX][nY][2])
						Else
							SDT->&(aItSDT[nX][nY][1]):= aItSDT[nX][nY][2]
						Endif
					Next
					dbCommit()
					MsUnlock()
				Next

				//aAdd(aProc,{cDoc,cSerie,cNomeFor})

			End Transaction
		EndIf
	EndIf

	oXMLBia	:=Nil
	oAuxXml	:=Nil
	oFullXML:=Nil
	DelClassIntf()

Return lProces

//Remove caracteres especiais
Static Function remCarEsp(cStrXML)

	Local aPesq	:= {"Ã",CHR(129),CHR(141),CHR(143),CHR(144),CHR(157)}		// Caracteres especiais nao reconhecidos pela funcao EncodeUTF8
	Local nX := 0
	Default cStrXML := ""

	If !Empty(cStrXML)
		For nX := 1 To Len(aPesq)
			cStrXML := StrTran(cStrXML, aPesq[nX])
		Next nX
	EndIf

Return cStrXML

//Retira caracteres especiais do CNPJ, CPF, telefone, etc
Static Function limpCamp(cCampo)

	Local aCaEspec	:= {".","-","/"}
	Local nI			:= 0

	For nI := 1 To Len(aCaEspec)
		cCampo := StrTran(cCampo,aCaEspec[nI],"")
	Next nI

Return cCampo

//Elimina espaço em branco e caracteres especiais
Static Function valIE(cIeXml,cIeTab)

	Local lRet := .F.

	cIeXml := AllTrim(cIeXml)
	cIeXml := limpCamp(cIeXml)

	cIeTab := AllTrim(cIeTab)
	cIeTab := limpCamp(cIeTab)

	If (cIeXml $ cIeTab) .Or. (cIeTab $ cIeXml)
		lRet := .T.
	Endif

Return lRet


Static Function IXmlCom(lJob,oFullXML,cXMLOri,Origem)
	Local aItens		:= {}
	Local cError     	:= ""
	Local cWarning   	:= ""
	Local cCodigo 		:= ""
	Local cLoja			:= ""
	Local cNomeFor		:= ""
	Local cDoc			:= ""
	Local cSerie		:= ""   
	Local cNumPed		:= ""
	Local cItemPC		:= ""
	Local cNfOri		:= ""
	Local cSerOri		:= ""
	Local cItemOri		:= ""
	Local cPrdFor		:= ""
	Local lNfOri		:= .F.
	Local lNumPed		:= .F.
	Local lProces    	:= .T.
	Local nCntFor		:= 0
	Local nX

	Default lJob   	 	:= .T.
	Default oFullXML	:= NIL

	If lProces

		If lProces		
			oXMLBia    := oFullXML
			oAuxXML := oXMLBia			
			//-- Resgata o no inicial da NF-e
			If	lNfeCompl
				oXMLBia := oFullXML:_Invoic_NFe_Compl:_NFe_Sefaz:_NFe
			Else
				While !lFound
					oAuxXML := XmlChildEx(oAuxXML,"_NFE")
					If !(lFound := oAuxXML # NIL)
						For nX := 1 To XmlChildCount(oXMLBia)
							oAuxXML  := XmlChildEx(XmlGetchild(oXMLBia,nX),"_NFE")
							lFound := oAuxXML:_InfNfe# Nil
							If lFound
								oXMLBia := oAuxXML
								Exit
							EndIf
						Next nX
					EndIf				
					If lFound
						oXMLBia := oAuxXML
						Exit
					EndIf
				EndDo			
			EndIf
		EndIf


		If Origem <> "G"
			oFullXML := XmlParser(cXMLOri,"_",@cError,@cWarning)

			If Empty(oFullXML) .Or. !Empty(cError) //-- Erro na sintaxe do XML
				If lJob
					Conout("Erro de sintaxe no arquivo XML: Entre em contato com o emissor do documento e comunique a ocorrência. (BIA657)")
				Else
					MsgBox("Erro de sintaxe no arquivo XML: Entre em contato com o emissor do documento e comunique a ocorrência.","BIA657","ALERT") //-- Erro
				EndIf
				lProces := .F.
			EndIf
		Else
			oFullXML := cXMLOri
		EndIf	

		If lProces
			cChaveNF := RIGHT(oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_Id:Text,TamSx3("DS_CHAVENF")[1])

			SDS->(DbSetOrder(2))
			If	SDS->(!DbSeek(xFilial("SDS")+cChaveNF))
				lProces := IXmlNf(lJob,.F.,oFullXml:_INVOIC_NFE_COMPL:_NFE_SEFAZ,.T.,cXmlOri,Origem)
			EndIf
		EndIf
		If lProces
			cCodigo := SDS->DS_FORNEC			//-- Codigo do Fornecedor/Cliente
			cLoja	:= SDS->DS_LOJA
			cDoc	:= SDS->DS_DOC
			cSerie	:= SDS->DS_SERIE
			SF2->(DbSetOrder(2))
			SC7->(DbSetOrder(4))
			SDT->(DbSetOrder(2))
			aItens:=Iif(ValType(oFullXML:_INVOIC_NFE_COMPL:_COMPLEMENT_NFE:_NS1_ITENS:_NS1_ITEM) == "O",;
			{oFullXML:_INVOIC_NFE_COMPL:_COMPLEMENT_NFE:_NS1_ITENS:_NS1_ITEM},oFullXML:_INVOIC_NFE_COMPL:_COMPLEMENT_NFE:_NS1_ITENS:_NS1_ITEM)
			Begin Transaction

				For nCntFor := 1 To Len(aItens)
					//-- Pesquisar se o pedido de compra do arquivo XML da nota fiscal complementar esta cadastrado
					cNumPed := ""
					cItemPC	:= ""
					cPrdFor := ""
					cNfOri	:= ""
					cSerOri	:= ""
					cItemOri:= ""
					cNumPed := PadR(aItens[nCntFor]:_NS1_PONUMBER:Text,TamSx3("C7_NUM")[1])
					If	Type("aItens["+Str(nCntFor)+"]:_NS1_NUMITEMREQUEST:Text")<>"U"
						cItemPC := PadR(aItens[nCntFor]:_NS1_NUMITEMREQUEST:Text,TamSx3("C7_ITEM")[1])
					EndIf
					cPrdFor	:= PadR(aItens[nCntFor]:_NS1_PRODCODSUPLLI:Text,TamSx3("DT_PRODFOR")[1])
					//-- Pesquisar se a nota fiscal de origem do arquivo XML da nota fiscal complementar esta cadastrado
					If	Type("aItens["+Str(nCntFor)+"]:_NS1_RETURNINDUSTRIALIZATION:_NS1_INVOICE_REFERENCED:_NS1_INVOICEREFERENCED:_NS1_NUMINVOICEREFERENCED:Text")<>"U"
						cNfOri	:= PadR(aItens[nCntFor]:_NS1_RETURNINDUSTRIALIZATION:_NS1_INVOICE_REFERENCED:_NS1_INVOICEREFERENCED:_NS1_NUMINVOICEREFERENCED:Text,TamSx3("F2_DOC")[1])
					EndIf
					If	Type("aItens["+Str(nCntFor)+"]:_NS1_RETURNINDUSTRIALIZATION:_NS1_INVOICE_REFERENCED:_NS1_INVOICEREFERENCED:_NS1_SERIEINVOICEREFERENCED:Text")<>"U"
						cSerOri	:= PadR(aItens[nCntFor]:_NS1_RETURNINDUSTRIALIZATION:_NS1_INVOICE_REFERENCED:_NS1_INVOICEREFERENCED:_NS1_SERIEINVOICEREFERENCED:Text,SerieNfId("SF2",6,"F2_SERIE"))
					EndIf
					If	Type("aItens["+Str(nCntFor)+"]:_NS1_RETURNINDUSTRIALIZATION:_NS1_INVOICE_REFERENCED:_NS1_INVOICEREFERENCED:_NS1_ITEMINVOICEREFERENCED:Text")<>"U"
						cItemOri:= PadR(aItens[nCntFor]:_NS1_RETURNINDUSTRIALIZATION:_NS1_INVOICE_REFERENCED:_NS1_INVOICEREFERENCED:_NS1_ITEMINVOICEREFERENCED:Text,TamSx3("DT_ITEMORI")[1])
					EndIf
					If	SDT->( DbSeek(xFilial("SDT")+cCodigo+cLoja+cDoc+cSerie+cPrdFor) )
						lNumPed := SC7->(DbSeek(xFilial("SC7")+SDT->DT_COD+cNumPed+cItemPC))
						If	!Empty(cNfOri)
							lNfOri	:= SF2->(DbSeek(xFilial("SF2")+cCodigo+cLoja+cNfOri+cSerOri))
						EndIf	
						RecLock("SDT",.F.)
						If	lNumPed	
							SDT->DT_PEDIDO	:= cNumPed
							SDT->DT_ITEMPC	:= cItemPC
						EndIf
						If	lNfOri	
							SDT->DT_NFORI	:= cNfOri
							SDT->DT_SERIORI	:= cSerOri
							SDT->DT_ITEMORI	:= cItemOri
						EndIf
						MsUnLock()
					EndIf
				Next nCntFor

			End Transaction     
			//aAdd(aProc,{cDoc,cSerie,cNomeFor})
		EndIf
	EndIf
Return lProces