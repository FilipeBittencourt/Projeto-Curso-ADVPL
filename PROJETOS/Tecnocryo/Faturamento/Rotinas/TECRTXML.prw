#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "TopConn.ch" 

Static _oXNfe, _oXNf, _oXIdent, _oXEmit, _oXDest, _oXTotal, _oXTransp, _oXDet, _oXFatura, _oXIcms

User Function TecRtXml
Local oTecRtXml := TecRtXml():New()

	oTecRtXml:Show()
Return Nil

Class TecRtXml From LongClassName
	Data aPergs
	Data aRet
	Data cArquivo
	Data cPasta
	Data lImpNfe 
	Data lGerFin
	Data aArqs
	Data lFileOK
	Data oHshNfe
	Data oHshIdent
	Data oHshEmit
	Data oHshTotal
	Data oLstDet

	Method New() Constructor
	Method Load() 
	Method Show() 
	Method ClickOK() 
	Method LoadFiles()
	Method ReadFile()
	Method Import()
	Method GerFin()
End Class
//
Method New() Class TecRtXml
	::Load()
Return Self
//
Method Load() Class TecRtXml
	::cArquivo := Space(100)
	::cPasta   := PadR("D:\TEMP\Tecnocryo\XML", 100, " ")
	::aArqs    := {}
	::lGerFin  := .F.
	::lImpNfe  := .F.
	::aPergs   := {}
	::aRet     := {"", ::cPasta, " ", " "}
	::lFileOK  := .F.
Return Self
//
Method Show() Class TecRtXml
	aAdd(::aPergs, {9, "Rotina para importação de XML.", 180, 30, .T.})
	aAdd(::aPergs, {1, "Pasta XML", ::cPasta, "@!",,, '.T.', 80, .T.})
	aAdd(::aPergs, {2, "Importa NF Manual?", 1, {"S=Sim","N=Não"}, 80, '.T.', .T.})	
	aAdd(::aPergs, {2, "Gera Financeiro?", 1, {"S=Sim","N=Não"}, 80, '.T.', .T.})	
		                      
	ParamBox(::aPergs, "Importação XML", @::aRet, {|| ::ClickOk() })
Return Self
//
Method ClickOK() class TecRtXml
	::lImpNfe := If(::aRet[3] == 1, .T., .F.)
	::lGerFin := If(::aRet[4] == 1, .T., .F.)
	
	Processa({|| ::LoadFiles() },"Aguarde, processando...","Mensagem",.F.)	
Return(.T.)
//
Method LoadFiles() Class TecRtXml
Local nQtd := 0
Local n    := 0

	DbSelectArea("SA1")
	DbSetOrder(3)

	nQtd := aDir(Alltrim(::cPasta) + "\*.xml", @::aArqs) 
	
	ProcRegua(nQtd)
	
	For n := 1 To nQtd
		::cArquivo := ::aArqs[n]
		IncProc(::cArquivo)		
		If ::ReadFile()
			::Import()
		EndIf
	Next 
Return Self
//
Method ReadFile() Class TecRtXml
Local cFile    := AllTrim(::cPasta) + "\" + ::cArquivo
Local nHdl     := -1
Local nTamFile := 0 
Local cBuffer  := "", cAviso := "", cErro := ""
Local nBtLidos := 0
Local x        := 0	
Local oHshDet

	_oXNfe    := Nil
	::lFileOK := .F.
	
	If !File(cFile)
		Return(::lFileOK)
	EndIf
		
	nHdl := fOpen(cFile,0)   

	If nHdl == -1
		Return(::lFileOK)
	Endif	

	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	
	cBuffer  := Space(nTamFile)
	nBtLidos := fRead(nHdl,@cBuffer,nTamFile)
	fClose(nHdl)

	_oXNfe := XmlParser(cBuffer, "_", @cAviso, @cErro)	

	If ValType(_oXNfe) != "O"
		MsgAlert(cArq + " - " + cErro, "ERRO IMPORTAÇÃO XML - NOTA FISCAL ELETRÔNICA")
		Return(::lFileOK)
	EndIf
	//9 99918862 _oXTotal:_ICMSTOT:_VNF:
	::oHshNfe   := HashTable():New()
	::oHshIdent := HashTable():New()
       
	If Type("_oXNfe:_NfeProc")<> "U"
		::oHshNfe:SetItem("Versao", _oXNfe:_NFeProc:_VERSAO:Text)
		::oHshNfe:SetItem("Chave", _oXNfe:_NFeProc:_protNFe:_infProt:_chNFe:TEXT)
		_oXNf := _oXNfe:_NFeProc:_NFe
	ElseIf Type("_oXNfe:_Nfe")<> "U"
		::oHshNfe:SetItem("Versao", "2.00")
		_oXNf := _oXNfe:_NFe		
	Else 
		Return(::lFileOK)
	EndIf
	
	_oXEmit   := _oXNf:_InfNfe:_Emit
	_oXIdent  := _oXNf:_InfNfe:_IDE
	_oXTotal  := _oXNf:_InfNfe:_Total
	_oXTransp := _oXNf:_InfNfe:_Transp
	
	::oHshIdent := HashTable():New()
	::oHshEmit  := HashTable():New()
	::oHshTotal := HashTable():New()
	::oLstDet   := ArrayList():New()
	
	If ::oHshNfe:GetItem("Versao") == "3.10"
		::oHshIdent:SetItem("Emissao", SubStr(_oXIdent:_dhEmi:Text, 1, At("T", _oXIdent:_dhEmi:Text) - 1))
	Else	
		::oHshIdent:SetItem("Emissao", Alltrim(_oXIdent:_dEmi:TEXT))	
	EndIf
	
	::oHshIdent:SetItem("Doc", Alltrim(_oXIdent:_nNF:TEXT))
	::oHshIdent:SetItem("Serie", AllTrim(_oXIdent:_serie:TEXT))
	
	_oXIcms   := If(Type("_oXNf:_INFNFE:_ICMS") != "U", _oXNf:_INFNFE:_ICMS, Nil)	
	_oXFatura := If(Type("_oXNf:_INFNFE:_COBR") != "U", _oXNf:_INFNFE:_COBR, Nil)	
	_oXDest   := If(Type("_oXNf:_INFNFE:_DEST") != "U", _oXNf:_INFNFE:_DEST, Nil)	
	_oXDet    := If(Type("_oXNf:_INFNFE:_DET") != "U", _oXNf:_INFNFE:_DET, Nil)
	
	If Type("_oXNf:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT") != "U"
		::oHshTotal:SetItem("VNF", _oXTotal:_ICMSTOT:_VNF:TEXT)
	Else
		::oHshTotal:SetItem("VNF", 0)	
	EndIf
	
	If Type("_oXNf:_INFNFE:_EMIT:_CPF") != "U"
		::oHshEmit:SetItem("CPF", AllTrim(_oXEmit:_CPF:TEXT))
		::oHshEmit:SetItem("PESSOA", "F")
	Else
		::oHshEmit:SetItem("CNPJ", AllTrim(_oXEmit:_CNPJ:TEXT))
		::oHshEmit:SetItem("PESSOA", "J")	
	EndIf
	
	Do Case
	Case Type("_oXNf:_InfNfe:_Det") == "O"
		oHshDet := HashTable():New()
		oHshDet:SetItem("EAN", _oXDet:_PROD:_CEAN:TEXT)
		oHshDet:SetItem("CFOP", _oXDet:_PROD:_CFOP:TEXT)
		oHshDet:SetItem("CODIGO", AllTrim(_oXDet:_PROD:_CPROD:TEXT))
		oHshDet:SetItem("NCM", _oXDet:_PROD:_NCM:TEXT)
		oHshDet:SetItem("UN", _oXDet:_PROD:_UCOM:TEXT)
		oHshDet:SetItem("DESCRICAO", _oXDet:_PROD:_XPROD:TEXT)	
		oHshDet:SetItem("QUANTIDADE", Val(_oXDet:_PROD:_QCOM:TEXT))
		oHshDet:SetItem("TOTITEM", Val(_oXDet:_PROD:_VPROD:TEXT))
		
		::oLstDet:Add(oHshDet)
	Case Type("_oXNf:_InfNfe:_Det") == "A"
		For x := 1 To Len(_oXDet)
			oHshDet := HashTable():New()
			oHshDet:SetItem("EAN", _oXDet[x]:_PROD:_CEAN:TEXT)
			oHshDet:SetItem("CFOP", _oXDet[x]:_PROD:_CFOP:TEXT)			
			oHshDet:SetItem("CODIGO", AllTrim(_oXDet[x]:_PROD:_CPROD:TEXT)) //5102, 6102 11002
			oHshDet:SetItem("NCM", _oXDet[x]:_PROD:_NCM:TEXT)
			oHshDet:SetItem("UN", _oXDet[x]:_PROD:_UCOM:TEXT)
			oHshDet:SetItem("DESCRICAO", _oXDet[x]:_PROD:_XPROD:TEXT)	
			oHshDet:SetItem("QUANTIDADE", Val(_oXDet[x]:_PROD:_QCOM:TEXT))
			oHshDet:SetItem("TOTITEM", Val(_oXDet[x]:_PROD:_VPROD:TEXT))
			
			::oLstDet:Add(oHshDet)
		Next x
	End Case
	
	::lFileOK := .T.
Return(::lFileOK)
//
Method Import() Class TecRtXml
	If ::lGerFin
		::GerFin()
	EndIf
Return Self
//
Method GerFin() Class TecRtXml
Local aCond    := {}//Condicao(nValor,cCondicao,nValIpi,dDataNew)
Local aTit     := {}
Local dBaseBkp := dDataBase
Local y        := 0

	If SA1->(DbSeek( xFilial("SA1") + If(::oHshEmit:GetItem("PESSOA") == "J", ::oHshEmit:GetItem("CNPJ"), ::oHshEmit:GetItem("CPF")) ))
		If Empty(SA1->A1_COND)
			Return Self
		EndIf

		If !::oLstDet:GetItem(1):GetItem("CFOP") $ "5102_6102"
			Return Self
		EndIf	
		
		dDataBase := Stod(StrTran(::oHshIdent:GetItem("Emissao"), "-", ""))
		
		aCond := Condicao(::oHshTotal:GetItem("VNF"), SA1->A1_COND, 0, dDataBase)		

		For y := 1 To Len(aCond)
			lMsErroAuto	:=	.F.			

			aTit	:=	{{ "E1_PREFIXO", ::oHshIdent:GetItem("Serie")               , NIL },;
			           	 { "E1_NUM"    , ::oHshIdent:GetItem("Doc")                 , NIL },;
         		   		 { "E1_PARCELA", If(Len(aCond) == 1, " ", RetAsc(y, 1, .T.)), NIL },;
         		   		 { "E1_TIPO"   , "NF"                                       , NIL },;
            			 { "E1_NATUREZ", "11002"                                    , NIL },;
			             { "E1_CLIENTE", SA1->A1_COD			                    , NIL },;
           		  		 { "E1_LOJA"   , SA1->A1_LOJA			                    , NIL },;
           				 { "E1_EMISSAO", aCond[y,01]			                    , NIL },;
            			 { "E1_VENCTO" , aCond[y,01]                                , NIL },;
            			 { "E1_VALOR"  , aCond[y,01]                                , NIL }}

				MsExecAuto( { |x, y| FINA040(x, y)}, aTit, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão            				
				
			If lMsErroAuto
   				MostraErro()
			Endif
		Next y

		dDataBase := dBaseBkp
	EndIf
Return Self