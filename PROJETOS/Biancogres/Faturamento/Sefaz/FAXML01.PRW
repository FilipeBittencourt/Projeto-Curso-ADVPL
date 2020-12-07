#INCLUDE "TOTVS.CH"
#INCLUDE "TOTVSMAIL.CH"
#INCLUDE "DIRECTRY.CH"

//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Fun‡„o    ³ FAXML01    ³ Autor ³Fernando/Facile Sistemas³ Data ³ 11.11.11 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descri‡„o ³ 2.4 Rotina de importação dos dados do XML recebido.	       ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function FAXML01(cEMP, _cFILE, LCAB)

	//cEMP  =>  Passar empresa e filial com 4 digitos
	//cFILE =>  Passar Nome do arquivo com extensão .XML

	local aArq
	Local I
	Local ARET

	//TESTE
	Default cEMP := "0101"////TESTE
	Default _cFILE := "001615-50851955000120.xml"///TESTE

	Default LCAB := .F.  //Definir se quer somente os dados do cabecalho NF neste forma

	//LCAB = .F.
	//ARET[1] = CNPJ DESTINATARIO
	//ARET[2] = CNPJ FORNECEDOR
	//ARET[3] = NF
	//ARET[4] = SERIE
	//ARET[5] = EMISSAO
	//ARET[6] = VALOR TOTAL

	//LCAB = .T.
	//ARET[1] = ACAB
	//ARET[2] = APROD

	//ESTRUTURA DO VETOR ACAB
	//ACAB[1] := NUMERO NF
	//ACAB[2] := SERIE NF
	//ACAB[3] := EMISSAO
	//ACAB[4] := CNPJ FORNECEDOR
	//ACAB[5] := PEDIDO DE COMPRA
	//ACAB[6] := CHAVE DA NFE

	//ESTRUTURA DO VETOR APROD - VETOR BIMENSIONAL - UMA POSICAO PARA CADA ITEM
	//APROD[I][1] := CODIGO DO PRODUTO NO FORNECEDOR
	//APROD[I][2] := CODIGO INTERNO DO PRODUTO
	//APROD[I][3] := DESCRICAO
	//APROD[I][4] := UNIDADE
	//APROD[I][5] := QTDE
	//APROD[I][6] := PRECO UNITARIO
	//APROD[I][7] := PRECO TOTAL
	//APROD[I][8] := DESCONTO
	//APROD[I][9] := PEDIDO DE COMPRA

	Private cPath
	Private cFILE := AllTrim(_cFILE)
	Private oXML  := NIL


	//PATH ROOT DOS ARQUIVOS XML NFE - CAMINHO SERVIDOR
	Private cPath := "\P10\XML_NFE\"

	//DEFINICAO DO PATH DE ACORDO COM EMPRESA
	cPath += cEMP+"\RECEBIDOS\"

	//Verificar se o PATH existe
	IF !ExistDir(cPath)
		MsgAlert("Pasta "+cPath+" de Importação de arquivos XML não existe!","IMPORTAÇÃO XML - NOTA FISCAL ELETRÔNICA")
		Return(Nil)
	ENDIF

	IF !FILE(cPath+cFILE)
		MsgAlert("Arquivo "+cPath+cFILE+" XML não existe!","IMPORTAÇÃO XML - NOTA FISCAL ELETRÔNICA")
		Return(Nil)
	ENDIF

	ARET := XMLNFE(LCAB)

	//MsgAlert(Len(ARET[2]))
	//MsgAlert(ARET[1])
	//MsgAlert(ARET[2])
	//MsgAlert(ARET[3])
	//MsgAlert(ARET[4])
	//MsgAlert(ARET[5])
	//MsgAlert(ARET[6])

Return(ARET)


//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//VALIDACAO E INICIO DA IMPORTACAO DO CML
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function XMLNFe(LCAB)

	Local cError      := ""
	Local cWarning    := ""
	Local aRET

	//Validar estrutura e abrir arquivo XML
	IF !U_FAVALXML(cPath+cFILE,@oXML)
		Return(Nil)
	ENDIF

	IF LCAB
		aRET := XMLNfeCB()
	ELSE
		aRET := XMLNFeCP()
	ENDIF

Return(aRET)

//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//IMPORTACAO RESUMIDA - DADOS DO CABECALHO PARA VALIDACAO
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function XMLNfeCB()

	Local ARET //RETORNAR VETOR COM OS DADOS BASICO DO CABECALHO DA NF

	IF (Type("oXML:_NfeProc:_Nfe:_InfNfe") <> "U" )

		__CNPJ_FIL 		:= oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
		__CNPJ_FOR 		:= oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
		__NUMNF 	  	:= PADL(Alltrim(oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT),6,"0") //Nro da Nota
		__SERNF 		  := PADR(oXML:_NfeProc:_Nfe:_InfNfe:_IDE:_Serie:Text,3," ") //Serie da Nota
		__CEMISSAO 		:= oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dEmi:Text //Emissao
		__DEMISSAO 		:= STOD(Substr(__CEMISSAO,1,4)+Substr(__CEMISSAO,6,2)+Substr(__CEMISSAO,9,2)) //Emissao
		__TOTALMERC 	:= Val(oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text) // Valor Mercadorias

		ARET := {}
		AADD(ARET, __CNPJ_FIL)
		AADD(ARET, __CNPJ_FOR)
		AADD(ARET, __NUMNF)
		AADD(ARET, __SERNF)
		AADD(ARET, __DEMISSAO)
		AADD(ARET, __TOTALMERC)

	ENDIF

Return(ARET)

//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//IMPORTACAO COMPLETA
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function XMLNFeCP()

	Local ARET := {} //RETORNAR VETOR MULTIDIMENSIONAL COM OS DADOS COMPLETOS A NF
	Local ACAB
	LocAL APROD

	Local nNumItens
	Local nTotalMerc
	Local nDescNota
	Local nValor
	Local nIcmsSubs
	Local cCodForn
	Local cDescForn
	Local nQuant
	Local nPrcUnLiq
	Local nPrcTtLiq
	Local nValDesc
	Local cFornec
	Local cLjFornec
	Local cCodigo
	Local cUnidad
	Local cPedItem
	Local nCont

	//PREENCHIMENTO DO VETOR ACAB - DADOS DO CABECALHO DA NOTA FISCAL
	ACAB := {}
	IF (Type("oXML:_NfeProc:_Nfe:_InfNfe") <> "U" )

		__NUMNF 	  	:= PADL(Alltrim(oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT),6,"0") //Nro da Nota
		__SERNF 	  	:= PADR(oXML:_NfeProc:_Nfe:_InfNfe:_IDE:_Serie:Text,3," ") //Serie da Nota
		__CEMISSAO 		:= oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dEmi:Text //Emissao
		__DEMISSAO 		:= STOD(Substr(__CEMISSAO,1,4)+Substr(__CEMISSAO,6,2)+Substr(__CEMISSAO,9,2)) //Emissao
		__CNPJ_FOR 		:= oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT

		If Type("oXML:_NFEPROC:_NFE:_INFNFE:_COMPRA:_XPED") <> "U"
			__XPED		:= AllTrim(oXML:_NFEPROC:_NFE:_INFNFE:_COMPRA:_XPED)
		Else
			__XPED		:= Space(TamSx3("C7_NUM")[1])
		EndIf

		//Procurando a chave da NFe
		If Type("oXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE") <> "U"
			__CHAVENFE := AllTrim(oXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT)
		Else
			__CHAVENFE := ""
		EndIf

		AADD(ACAB, __NUMNF)
		AADD(ACAB, __SERNF)
		AADD(ACAB, __DEMISSAO)
		AADD(ACAB, __CNPJ_FOR)
		AADD(ACAB, __XPED)
		AADD(ACAB, __CHAVENFE)

	ENDIF

	AADD(ARET,ACAB)

	//VALIDACAO DE DADOS DO FORNECEDOR
	__CNPJ_FOR := oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
	SA2->(DbSetOrder(3))
	If SA2->(DbSeek(xFilial("SA2")+__CNPJ_FOR))

		cFornec := SA2->A2_COD
		cLjFornec := SA2->A2_LOJA

	Else
		MsgAlert("FORNECEDOR NÃO ENCONTRADO - CNPJ: "+__CNPJ_FOR,"IMPORTAÇÃO XML - NOTA FISCAL ELETRÔNICA")
	Endif


	//LEITURA/PREENCHIMENTO DOS DADOS DOS ITENS DA NF
	If ValType(oXml:_NfeProc:_Nfe:_InfNfe:_DET) = "O"
		XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_DET, "_DET")
	EndIf

	nNumItens  	:= Len(oXml:_NfeProc:_Nfe:_InfNfe:_DET)
	nTotalMerc 	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text)
	nDescNota  	:= val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:Text)
	nValor	 		:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:Text)
	nIcmsSubs		:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:Text)

	//cVencimento := ""
	//If XmlChildEx ( oXml:_NFEPROC:_NFE:_INFNFE , "_COBR" ) != Nil
	//	   Voltar mas tem que alterar para aceitar varias parcelas.
	//     cVencimento     := oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:Text
	//	   cVencimento := Substr(cVencimento,9,2)+"/"+Substr(cVencimento,6,2)+"/"+Substr(cVencimento,1,4)
	//EndIf

	APROD := {}
	For nCont := 1 to nNumItens

		cCodForn	:= AllTrim(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_CPROD:Text)
		cDescForn	:= AllTrim(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPROD:Text)
		nQuant		:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_QCOM:Text)
		cUnidad		:= Upper(AllTrim(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_UCOM:Text))
		nPrcUnLiq	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VUNCOM:Text)
		nPrcTtLiq	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VPROD:Text)
		xz_Unid   := Alltrim(oXML:_NFEPROC:_NFE:_INFNFE:_DET[1]:_PROD:_UCOM:TEXT)

		If XmlChildEx(oXml:_NfeProc:_Nfe:_InfNfe:_DET[nCont]:_PROD, "_VDESC")!= Nil
			nValDesc	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VDESC:Text)
		Else
			nValDesc	:= 0
		EndIf

		If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPED") <> "U"
			cPedItem	:= Upper(AllTrim(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPED:Text))
		Else
			cPedItem	:= Space(TamSx3("C7_NUM")[1])
		EndIf

		//BUSCA / ASSOCIACAO DO CODIGO INTERNO DO PRODUTO - (FORNECEDOR: SA5)
		__lFindPrd := .F.
		SA5->(DbSetOrder(5))
		If SA5->(dbSeek(xFilial("SA5")+PADR(cCodForn,TamSx3("A5_CODPRF")[1])))
			While AllTrim(SA5->A5_CODPRF) == AllTrim(cCodForn)
				If SA5->(A5_FORNECE+A5_LOJA) == cFornec+cLjFornec
					cCodigo := SA5->A5_PRODUTO
					__lFindPrd := .T.
					Exit
				Endif
				SA5->(DBSkip())
			EndDo
		EndIf

		If !__lFindPrd
			cCodigo := Space(TamSx3("B1_COD")[1])
		EndIf


		AAUX := {}
		AAdd(AAUX, cCodForn)

		// Posiciona no produto encontrado
		IF cCodigo <> Nil .And. !Empty(cCodigo)
			AAdd(AAUX, cCodigo)
		ELSE
			AAdd(AAUX, Space(TamSx3("B1_COD")[1]))
		ENDIF

		AAdd(AAUX, cDescForn)
		AAdd(AAUX, cUnidad)
		AAdd(AAUX, nQuant)
		AAdd(AAUX, nPrcUnLiq)
		AAdd(AAUX, nPrcTtLiq)
		AAdd(AAUX, nValDesc)
		AAdd(AAUX, cPedItem)
		AAdd(AAUX, xz_Unid)

		AAdd(APROD,AAUX)

	Next nCont

	AADD(ARET,APROD)

Return(ARET)


//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//FUNCAO PARA VALIDAR ESTRUTURA DE XML E RETORNAR O OBJETO
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function FAVALXML(_CFILE,_oXML,_lAuto)
	Local cError := ""
	Local cWarning := ""

	Default _oXML 	:= NIL
	Default _lAuto	:= .F.

	//ABERTURA DO ARQUIVO E VALIDAÇÃO DA ESTRUTURA DO XML
	_oXML := XmlParserFile(_CFILE, "_", @cError, @cWarning )
	If ValType(_oXML) != "O"
		If !_lAuto
			MsgAlert(_CFILE+" - "+cError,"ERRO IMPORTAÇÃO XML - NOTA FISCAL ELETRÔNICA")
		EndIf
		Return(.F.)
	Endif

Return(.T.)
