#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "TopConn.CH"

/*
Desenvolvido por: Marcelo Spilares Secate
SPILSOFT SISTEMAS E SERVIÇOS
*/

Static _oGetD1

Class TWImpNfe From LongClassName
	DAta aSitTrib
	Data aSitSN
	Data aButtons //
	Data aCabec
	Data aCols1
	Data aItens
	Data aHeader1 
	Data aLinha
	Data aTipos //"Nota Normal","Nota Beneficiamento","Nota Devolução"
	Data cAviso
	Data cBuffer
	Data cCamArq //caminho completo mais nome do arquivo
	Data cChave
	Data cDir
	Data cNome
	Data cExt
	Data cDrive
	Data cErro
	Data lAmarraOk
	Data lArqVal
	Data lConfirmImp
	Data lFornOk
	Data lICM
	Data nHandle
	Data nDespUnit
	Data nDespesa
	Data nDiferenca
	Data nItem
	Data nTipo // Posição do aTipos
	Data nTamNome
	Data nTamNReduz
	Data nTamEnd
	Data nTamComple
	Data nTamDoc
	Data nTamSerie
	Data nTamVUnit
	Data nRet
	Data oDlg
	Data oDlg1
	Data oDlgConf
	Data oGetD1
	Data oProdNfe
	Data oProdProt
	Data oXDest
	Data oDest
	Data oXEmit
	Data oEmit
	Data oXEnder
	Data oXIDE
	Data oXICM
	Data oXTotal
	Data oXTransp
	Data oXDet
	Data oXml
	Data oXNF
	Data oNF
	Data nTamCodPro
	Data nTamDscPro
	Data nTamNcmPro
	Data nTamCest
	Data nTamProNfe
	Data nTamDscNfe
	
	Data nBaseICM
	Data nValICM
	Data nPICM
	Data cSitTrib
	Data nValIPI
	Data nPIPI
	Data nBASEIPI
	
	//@cDrive, @cDir, @cNome, @cExt
	
	Method New() Constructor
	Method Executa()
	Method ExibeDlg()
	Method PesqArq() //pesquisar arquivo
	Method Confirma()
	Method ArqVal() //Arquivo Valido?
	Method Reseta()
	Method LeArq() //Lê o arquivo XML
	Method FornOk()
	Method ConfirmImp() //Confirma importacao
	Method PrepDet()
	Method VerAmarra()
	Method PesqAmarra()	
	Method PopCols1()	
	Method AmarraOK()	
	Method PopHead1()	
	Method ExibeDlg1()    
	Method Confirmar1()	
	Method Cancelar1()
	Method Imposto()
	Method PreNota()
	Method Classifica()
End Class
/*
*/
Method New() Class TWImpNfe
Private oXml
Private oXNF
Private oXDest
Private oXEmit 
Private oXEnder
Private oEmit
Private oXDet
Private oXTotal

	::cDrive     := "C:"
	::cDir       := "\"
	
	::nDespUnit  := 0.00
	::nDespesa   := 0.00
	::nDiferenca := 0.00

	::nTamNome   := TamSX3("A2_NOME")[1] 
	::nTamNReduz := TamSX3("A2_NREDUZ")[1] 
	::nTamEnd    := TamSX3("A2_END")[1] 
	::nTamComple := TamSX3("A2_COMPLEM")[1] 
	::nTamDoc    := TamSX3("F1_DOC")[1]
	::nTamSerie  := TamSX3("F1_SERIE")[1]	
	
	::nTamCodPro := TamSx3("B1_COD")[1]
	::nTamDscPro := TamSx3("B1_DESC")[1]
	::nTamNcmPro := TamSx3("B1_POSIPI")[1]
	::nTamCest   := If(FieldPos("B1_CEST") > 0, TamSx3("B1_CEST")[1], 20) 
	::nTamProNfe := TamSx3("A5_CODPRF")[1]
	::nTamDscNfe := TamSx3("A5_NOMPROD")[1]	
	::nTamVUnit :=  TamSx3("D1_VUNIT")[2]		
	
	::aSitTrib   := {}
	::aSitSN     := {}
	
	aadd(::aSitTrib ,"00")
	aadd(::aSitTrib ,"10")
	aadd(::aSitTrib ,"20")
	aadd(::aSitTrib ,"30")
	aadd(::aSitTrib ,"40")
	aadd(::aSitTrib ,"41")
	aadd(::aSitTrib ,"50")
	aadd(::aSitTrib ,"51")
	aadd(::aSitTrib ,"60")
	aadd(::aSitTrib ,"70")
	aadd(::aSitTrib ,"90")

	aadd(::aSitSN ,"101")
	aadd(::aSitSN ,"102")
	aadd(::aSitSN ,"201")
	aadd(::aSitSN ,"202")
	aadd(::aSitSN ,"500")
	aadd(::aSitSN ,"900")		

	::Reseta()
Return Self
/*
*/
Method Reseta() Class TWImpNfe
	::aButtons    := {{"Produtos", {||MATA010()}, "Produtos"}}
	::aCabec      := {}
	::aItens      := {}
	::aCols1      := {}
	::aHeader1    := {}    
	::aLinha      := {}
	::aTipos      := {"Nota Normal"/*, "Nota Beneficiamento", "Nota Devolução"*/}
	::cAviso      := ""
	::cBuffer     := ""
	::cCamArq     := Space(240)
	::cErro       := ""
	::lAmarraOk   := .F.
	::lArqVal     := .F.
	::lConfirmImp := .F.
	::lFornOk     := .F.
	::lICM        := .F.
	::nItem       := 0
	::nHandle     := -1
	::nRet        := 0
	::nTipo       := 1
	::oGetD1      := Nil
	::oXDest      := Nil
	::oXIDE       := Nil
	::oXICM       := Nil
	::oXDet       := Nil
	::oDest       := HashTable():New()
	::oDlg1       := Nil
	::oXEmit      := Nil
	::oEmit       := HashTable():New()
	::oXEnder     := Nil
	::oXTransp    := Nil
	::oXTotal     := Nil
	::oXml        := Nil	
	::oXNF        := Nil
	::oNF         := HashTable():New()
	::oProdNfe    := Nil
	::oProdProt	  := Nil
	
	::nBaseICM    := 0	
	::nValICM     := 0
	::nPICM	      := 0
	::cSitTrib    := ""
	::nValIPI     :=  0
	::nPIPI       :=  0 
	::nBASEIPI    :=  0		
	
	oXml          := Nil
	oXNF          := Nil
	oXDest        := Nil
	oXEmit        := Nil
	oEmit         := Nil
	oXEnder	      := Nil
Return Self
/*
*/
Method Executa() Class TWImpNfe
	::ExibeDlg()
Return Self
/*
*/
Method ExibeDlg() Class TWImpNfe
	::oDlg           := MSDialog():New(000,000,150,545,"Importação XML NF-e",,,,,,,,,.T.)
	::oDlg:bInit     := {|| EnchoiceBar(::oDlg, {|| ::Confirma()}, {||::oDlg:End()},,::aButtons)/*, ::oGetD1:oBrowse:nColPos := 5, ::oGetD1:oBrowse:SetFocus()*/}
	::oDlg:lCentered := .T.

	TGet():New(003,005,{|u|If(PCount()==0,::cCamArq,::cCamArq:= u)},::oDlg,180,010,"@!",{||.T.},,,,,,.T.,,,{||.T.},,,,.T.,.F.,,"::cCamArq",,,,,,,"Arquivo XML:  ")	
	TButton():New(003, 225, "Pesquisar",::oDlg,{||::PesqArq()}, 040,010,,,.F.,.T.,.F.,,.F.,,,.F. )	

	TRadMenu():New(020,005,::aTipos,{|u|If(PCount()==0,::nTipo,::nTipo:= u)}, ::oDlg,,,,,,,, 205,010,,,,.T.,.T.)
	
	::oDlg:Activate()
Return Self
/*
*/
Method PesqArq() Class TWImpNfe
	::cCamArq := cGetFile( "Arquivo NFe (*.xml) | *.xml","Selecione o Arquivo de Nota Fiscal XML",,::cDrive + ::cDir,.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.F.)

	If !Empty(::cCamArq)
		SplitPath(::cCamArq, @::cDrive, @::cDir, @::cNome, @::cExt)	
	EndIf
Return Self
/*
*/
Method Confirma() Class TWImpNfe
	If ::ArqVal()
		::LeArq()
	Else
		Return Self
	EndIf
	
	If !::FornOk()
		Return Self
	EndIf	

	DbSelectArea("SF1")
	DbSetOrder(1)
	
	If SF1->(DbSeek( xFilial("SF1") + ::oNF:GetItem("DOC") + ::oNF:GetItem("SERIE") + ::oEmit:GetItem("COD") + ::oEmit:GetItem("LOJA") ))
		If File(::cCamArq)
			FErase(::cCamArq)
		End If	

		MsgAlert("Nota No.: " + ::oNF:GetItem("DOC") + "/" + ::oNF:GetItem("SERIE") + " do Fornecedor " + ::oEmit:GetItem("COD") + " /" + ::oEmit:GetItem("LOJA") + " ja existe. A Importacao será interrompida.")
		Return Self
	EndIf	
	
	If !::ConfirmImp()
		Return Self
	EndIf
	
	::VerAmarra()
	
	If !::lAmarraOk
		Return Self		
	EndIf
	
	::nItem := 1
	
	If ::PreNota()
	
		If File(::cCamArq)
			FErase(::cCamArq)
		End If	

		::Classifica()
	EndIf
	
	::Reseta()
Return Self
/*
*/
Method ArqVal() Class TWImpNfe
Local cMsg    := ""
local nTamArq := 0, nBtLidos := 0

	::lArqVal := .F.

	Begin Sequence
		//testar nome em branco
		If Empty(::cCamArq)
			cMsg := "O arquivo não foi informado."
			Break
		EndIf
		
		If !File(::cCamArq)
			cMsg := "O arquivo " + ::cCamArq + " não foi encontrado."
			Break
		EndIf	

		::nHandle := FOpen(::cCamArq, 0)
		
		If ::nHandle == -1
			cMsg := "O arquivo de nome " + ::cCamArq + " nao pôde ser aberto, verifique."
			Break
		Endif		
		
		nTamArq  := FSeek(::nHandle,0,2)
		FSeek(::nHandle,0,0)
		cBuffer  := Space(nTamArq)                // Variavel para criacao da linha do registro para leitura
		nBtLidos := FRead(::nHandle, @::cBuffer, nTamArq)  // Leitura  do arquivo XML

		FClose(::nHandle)	
		
		::oXml := XmlParser(::cBuffer, "_", @::cAviso, @::cErro)

		If ValType(::oXml) != "O"
			cMsg := "ERRO IMPORTAÇÃO XML - NOTA FISCAL ELETRÔNICA"
			Break
		EndIf

		::lArqVal := .T.
	End Sequence
	
	If !::lArqVal
		Aviso("Importação XML NF-e", cMsg, { "OK" }, 1)	
	EndIf
Return(::lArqVal)
/*
*/
Method LeArq() Class TWImpNfe
	oXml := ::oXml

	If Type("oXml:_NfeProc") != "U"
		::oNF:SetItem("CHAVE", AllTrim(::oXml:_NFeProc:_protNFe:_infProt:_chNFe:TEXT))
		::oXNF   := ::oXml:_NFeProc:_NFe
	Else
		::oNF:SetItem("CHAVE", "")	
		::oXNF   := ::oXml:_NFe
	EndIf
	
	oXNF := ::oXNF

	::oXEmit   := ::oXNF:_InfNfe:_Emit
	::oXIDE    := ::oXNF:_InfNfe:_IDE
	::oXDest   := ::oXNF:_InfNfe:_Dest
	::oXTotal  := ::oXNF:_InfNfe:_Total
	::oXTransp := ::oXNF:_InfNfe:_Transp
	::oXDet    := ::oXNF:_InfNfe:_Det
	
	::oXDet := If(ValType(::oXDet) == "O", {::oXDet}, ::oXDet)
	
	oXDet   := ::oXDet
	oXDest  := ::oXDest	
	oXEmit  := ::oXEmit
	oXTotal := ::oXTotal
	
	If Type("oXNF:_InfNfe:_ICMS") != "U"
		::oXICM := ::oXNF:_InfNfe:_ICMS
		::lICM  := .T.
	EndIf
	
	If Type("oXDest:_CNPJ") != "U"
		::oDest:SetItem("CGC",AllTrim(::oXDest:_CNPJ:TEXT))
	Else
		::oDest:SetItem("CGC","")		
	EndIf
	
	::oNF:SetItem("VERSAO", ::oXml:_NFEPROC:_VERSAO:Text)
	
	If ::oNF:GetItem("VERSAO") == "3.10"
		::oNF:SetItem("EMISSAO",SubStr(::oXIDE:_dhEmi:Text,1,At("T",::oXIDE:_dhEmi:Text) - 1))
	Else
		::oNF:SetItem("EMISSAO",Alltrim(::oXIDE:_dEmi:TEXT))	
	EndIf
	
	::oNF:SetItem("DOC", PadR(AllTrim(::oXIDE:_nNF:TEXT), ::nTamDoc))
	::oNF:SetItem("SERIE", PadR(AllTrim(::oXIDE:_Serie:TEXT), ::nTamSerie))
Return Self
/*
*/
Method FornOk() Class TWImpNfe
Private cCadastro := "Incuir Fornecedor"
Private lIntLox   := GetMV("MV_QALOGIX") == "1"	
Private Inclui    := .T.
Private Altera    := .F.

	DbSelectArea("SA2")
	DbSetOrder(3) //SA29903	nonclustered located on PRIMARY	A2_FILIAL, A2_CGC, R_E_C_N_O_, D_E_L_E_T_
	
	::lFornOk := .F.
	::oXEnder := ::oXEmit:_ENDEREMIT

	oXEnder := ::oXEnder
	oXEmit  := ::oXEmit
	
	If Type("oXEmit:_CNPJ") <> "U" 
		::oEmit:SetItem("TIPO", "J")
		::oEmit:SetItem("CGC", ::oXEmit:_CNPJ:TEXT)
	EndIf  
	
	If Type("oXEmit:_CPF") <> "U" 
		::oEmit:SetItem("TIPO", "F")
		::oEmit:SetItem("CGC", ::oXEmit:_CPF:TEXT)	
	EndIf
	
	If SA2->(DbSeek(xFilial("SA2") + ::oEmit:GetItem("CGC") ))
		::lFornOk := .T.
		
		::oEmit:SetItem("COD" , SA2->A2_COD)
		::oEmit:SetItem("LOJA", SA2->A2_LOJA)		
		::oEmit:SetItem("NOME", AllTrim(SA2->A2_NOME))				
		
		Return(::lFornOk)
	EndIf
	
	If Type("oXEmit:_EMAIL") <> "U" 
		::oEmit:SetItem("EMAIL", AllTrim(::oXEmit:_EMAIL:TEXT))
	Else
		::oEmit:SetItem("EMAIL", "")
	EndIf  		
	
	If Type("oXEmit:_IE") <> "U" //INSCR
		::oEmit:SetItem("INSCR", AllTrim(::oXEmit:_IE:TEXT))
	Else
		::oEmit:SetItem("INSCR", "")	
	EndIf
	
	If Type("oXEmit:_IM") <> "U" //INSCRM
		::oEmit:SetItem("INSCRM", AllTrim(::oXEmit:_IM:TEXT))
	Else
		::oEmit:SetItem("INSCRM", "")	
	EndIf	

	If Type("oXEmit:_XNOME") <> "U" //INSCRM
		::oEmit:SetItem("NOME", AllTrim(::oXEmit:_XNOME:TEXT))
	Else
		::oEmit:SetItem("NOME", "")	
	EndIf		
	
	If Type("oXEmit:_XFANT") <> "U" //INSCRM
		::oEmit:SetItem("NREDUZ", AllTrim(::oXEmit:_XFANT:TEXT))
	Else
		::oEmit:SetItem("NREDUZ", ::oEmit:GetItem("NOME"))	
	EndIf		
	
	If Type("oXEmit:_XCPL") <> "U" 
		::oEmit:SetItem("COMPLEM", AllTrim(::oXEmit:_XCPL:TEXT))	
	Else
		::oEmit:SetItem("COMPLEM", "")			
	EndIf		
	
	::oEmit:SetItem("END", AllTrim(::oXEnder:_XLGR:TEXT))
	::oEmit:SetItem("NRO", AllTrim(::oXEnder:_NRO:TEXT))
	::oEmit:SetItem("CEP", AllTrim(::oXEnder:_CEP:TEXT))
	::oEmit:SetItem("EST", AllTrim(::oXEnder:_UF:TEXT))
	::oEmit:SetItem("BAIRRO", AllTrim(::oXEnder:_XBAIRRO:TEXT))
	::oEmit:SetItem("MUN", AllTrim(::oXEnder:_XMUN:TEXT))

	If Type("oXEnder:_FONE") != "U"
	    ::oEmit:SetItem("DDD", SubStr(::oXEnder:_FONE:TEXT, 1, 2))	
	    ::oEmit:SetItem("TEL", AllTrim(::oXEnder:_FONE:TEXT))
		
		::oEmit:SetItem("TEL", SubStr(::oEmit:GetItem("TEL"), 3, Len(::oEmit:GetItem("TEL")) - 2))
	Else
	    ::oEmit:SetItem("DDD", "")		
	    ::oEmit:SetItem("TEL", "")	
	EndIf
	     
     If CC2->(DbSeek( xFilial("CC2") + ::oEmit:GetItem("EST") + ::oEmit:GetItem("MUN") ))
    	::oEmit:SetItem("COD_MUN", CC2->CC2_CODMUN)
	Else
    	::oEmit:SetItem("COD_MUN", "")		
    EndIf	

	If Empty(::oEmit:GetItem("NRO"))
	 	If Len(::oEmit:GetItem("END")) > ::nTamEnd
	 		::oEmit:SetItem("END", SubStr(::oEmit:GetItem("END"), 1, ::nTamEnd))
	 	EndIf
	Else
		::oEmit:SetItem("END", SubStr(::oEmit:GetItem("END"), 1, ::nTamEnd - Len(::oEmit:GetItem("NRO")) + 1))
	    ::oEmit:SetItem("END", ::oEmit:GetItem("END") + "," + ::oEmit:GetItem("NRO"))
	EndIf

	oEmit := ::oEmit

	::nRet := AxInclui("SA2",,3,,"U_LoSA2FWI()",,"A020TudoOk()",.T.,,)
	
	If ::nRet == 1
		::oEmit:SetItem("COD" , SA2->A2_COD)
		::oEmit:SetItem("LOJA", SA2->A2_LOJA)

		::lFornOk := .T.
	Else
		::lFornOk := .F.
		Alert("Forneceodor não está cadastrado!")			
	EndIf
Return(::lFornOk)
/*
*/
User Function LoSA2FWI()
	M->A2_NOME    := oEmit:GetItem("NOME")
	M->A2_NREDUZ  := oEmit:GetItem("NREDUZ")	
	M->A2_END     := oEmit:GetItem("END")	
	M->A2_TIPO    := oEmit:GetItem("TIPO")	
	M->A2_EST     := oEmit:GetItem("EST")	
	M->A2_COD_MUN := oEmit:GetItem("COD_MUN")	
	M->A2_MUN     := oEmit:GetItem("MUN")	
	M->A2_BAIRRO  := oEmit:GetItem("BAIRRO")
	M->A2_CEP     := oEmit:GetItem("CEP")
	M->A2_PAIS    := oEmit:GetItem("PAIS")	
	M->A2_CGC     := oEmit:GetItem("CGC")
	M->A2_DDD     := oEmit:GetItem("DDD")
	M->A2_TEL     := oEmit:GetItem("TEL")
	M->A2_INSCR   := oEmit:GetItem("INSCR")	
	M->A2_INSCRM  := oEmit:GetItem("INSCRM")	
	M->A2_EMAIL   := oEmit:GetItem("EMAIL")		
Return(.T.)
/*
*/
Method ConfirmImp() Class TWImpNfe
Local aButtons  := {}
Local oFont     := TFont():New('Courier new',,-18,,.T.)
Local cNomeFor  := ::oEmit:GetItem("NOME")
Local cCNPJFor  := ::oEmit:GetItem("CGC")
Local cNotaFor  := ::oNF:GetItem("DOC")
Local cSerieFor := ::oNF:GetItem("SERIE")
Local cEmissao  := ::oNF:GetItem("EMISSAO")
Local cChave    := ::oNF:GetItem("CHAVE")

	::lConfirmImp := .F.

	//::PopCabec()

	::oDlgConf           := MSDialog():New(000,000,185,450,"Confirma importação do documento ?",,,,,,,,,.T.)
	::oDlgConf:bInit     := {|| EnchoiceBar(::oDlgConf, {|| ::lConfirmImp := .T., ::oDlgConf:End() }, {|| ::lConfirmImp := .F., ::oDlgConf:End() },,aButtons)}
	::oDlgConf:lCentered := .T.

	TGet():New(003,005,{|u|If(PCount()==0,cNomeFor,cNomeFor:= u)},::oDlgConf,090,009,"@!" ,{||.T.},,,,,,.T.,,,{||.T.},,,,.T.,.F.,,"cNomeFor",,,,,,,"Fornecedor: ")
	TGet():New(003,130,{|u|If(PCount()==0,cCNPJFor,cCNPJFor:= u)},::oDlgConf,060,009,"@!" ,{||.T.},,,,,,.T.,,,{||.T.},,,,.T.,.F.,,"cCNPJFor",,,,,,,"CNPJ/CPF: ")

	TGet():New(018,005,{|u|If(PCount()==0,cNotaFor,cNotaFor:= u)},::oDlgConf,035,009,"@!" ,{||.T.},,,,,,.T.,,,{||.T.},,,,.T.,.F.,,"cNotaFor",,,,,,,"Documento.: ")
	TGet():New(018,080,{|u|If(PCount()==0,cSerieFor,cSerieFor:= u)},::oDlgConf,005,009,"@!" ,{||.T.},,,,,,.T.,,,{||.T.},,,,.T.,.F.,,"cSerieFor",,,,,,,"Série: ")
	TGet():New(018,120,{|u|If(PCount()==0,cEmissao,cEmissao:= u)},::oDlgConf,035,009,"@!",{||.T.},,,,,,.T.,,,{||.T.},,,,.T.,.F.,,"cEmissao",,,,,,,"Emissão: ")

	TGet():New(033,005,{|u|If(PCount()==0,cChave,cChave:= u)},::oDlgConf,150,009,"@!",{||.T.},,,,,,.T.,,,{||.T.},,,,.T.,.F.,,"cChave",,,,,,,"Chave........: ")

	TSay():New(055,020,{||"Confirma importação do documento ?"},::oDlgConf,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)

	::oDlgConf:Activate()
Return(::lConfirmImp)
/*
*/
Method VerAmarra() Class TWImpNfe
	::PrepDet()
	::PesqAmarra()
	::PopCols1()
	::AmarraOK()
	
	If !::lAmarraOk
		::ExibeDlg1()
	EndIf
Return Self
/*
*/
Method PrepDet() Class TWImpNfe
Local oProd
Local nX := 0

	oXDet := ::oXDet

	::oProdNfe  := ArrayList():New()	
	::oProdProt := ArrayList():New()	

	For nX := 1 To Len(::oXDet)
		oProd := HashTable():New()
		
		oProd:SetItem("CODPRO", PadR(AllTrim(::oXDet[nX]:_Prod:_cProd:TEXT), ::nTamProNfe))
		oProd:SetItem("DSCPRO", SubStr(::oXDet[nX]:_Prod:_xProd:TEXT, 1, ::nTamDscNfe))
		oProd:SetItem("NCM", If(Type("oXDet[nX]:_Prod:_NCM")=="U",Space(::nTamNcmPro),::oXDet[nX]:_Prod:_NCM:TEXT))
		oProd:SetItem("CEST", If(Type("oXDet[nX]:_PROD:_CEST")=="U",Space(::nTamCest),::oXDet[nX]:_PROD:_CEST:TEXT))
		
		::oProdNfe:Add(oProd)
		::oProdProt:Add("")
	Next nX
Return Self
/*
*/
Method PesqAmarra() Class TWImpNfe
Local aArea    := GetArea()
Local aAreaSA5 := SA5->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local nX       := 0
Local oProd	

	DbSelectArea("SA5")
	DbSetOrder(14)

	DbSelectArea("SB1")
	DbSetOrder(1)

	For nX := 1 To ::oProdNfe:GetCount()
		oProd := HashTable():New()

		If SA5->(DbSeek(xFilial("SA5") + ::oEmit:GetItem("COD") + ::oEmit:GetItem("LOJA") + ::oProdNfe:GetItem(nX):GetItem("CODPRO")))
			SB1->(DbSeek(xFilial("SB1") + SA5->A5_PRODUTO))
				
			If SB1->B1_MSBLQL != "1"
				oProd:SetItem("CODPRO", SA5->A5_PRODUTO)
				oProd:SetItem("DSCPRO", SA5->A5_NOMPROD)
					
				oProd:SetItem("NCM", SB1->B1_POSIPI)
				oProd:SetItem("CEST", If(FieldPos("B1_CEST") > 0, SB1->B1_CEST, Space(10)))				
							
				::oProdProt:SetItem(nX, oProd)									
			Else
				MsgInfo("O produto " + SB1->(AllTrim(B1_COD) + "-" + AllTrim(B1_DESC)) + " está bloqueado e deve ser desbloqueado para ser importado!")
			End If
		End If
	Next nX
	
	RestArea(aAreaSB1)
	RestArea(aAreaSA5)
	RestArea(aArea)	
Return Self
/*
*/
Method PopCols1() Class TWImpNfe
Local aItem
Local nX := 0

	::aCols1 := {}
	
	For nX := 1 To ::oProdNfe:GetCount()
		aItem := {"","","","", Space(::nTamCodPro), Space(::nTamDscPro), Space(::nTamNcmPro),Space(::nTamCest),.F.}
		
		aItem[01] := ::oProdNfe:GetItem(nX):GetItem("CODPRO")
		aItem[02] := ::oProdNfe:GetItem(nX):GetItem("DSCPRO")
		aItem[03] := ::oProdNfe:GetItem(nX):GetItem("NCM")
		aItem[04] := ::oProdNfe:GetItem(nX):GetItem("CEST")
		
		If !Empty(::oProdProt:GetItem(nX))
			aItem[05] := ::oProdProt:GetItem(nX):GetItem("CODPRO")
			aItem[06] := ::oProdProt:GetItem(nX):GetItem("DSCPRO")
			aItem[07] := ::oProdProt:GetItem(nX):GetItem("NCM")
			aItem[08] := ::oProdProt:GetItem(nX):GetItem("CEST")
		EndIf
		
		aAdd(::aCols1, aItem)
	Next nX
Return Self
/*
*/
Method AmarraOK() Class TWImpNfe
Local nX := 0

	::lAmarraOk := .T.
	
	For nX := 1 To Len(::aCols1)
		If Empty(::aCols1[nX,05])
			::lAmarraOk := .F.
			Exit
		EndIf
	Next nX
Return(::lAmarraOk)
/*
*/
Method ExibeDlg1() Class TWImpNfe
Local aAlterGD  := {"CODPRO"}
Local aButtons  := {{"Produtos", {||MATA010()}, "Produtos"}}
Local cDelOk    := "AllwaysTrue()"	
Local cFieldOk  := "AllwaysTrue()"	
Local cIniCpos  := ""
Local cLinOk    := "U_VlLinPrI()"//"AllwaysTrue()"
Local cSuperDel := ""	
Local cTudoOk   := "AllwaysTrue()"
Local nFreeze   := 000	
Local nMax      := 99
LocaL nOpc      := 3 //
Local oFont     := TFont():New('Courier new',,-18,,.T.)

Local nDlgHeight   
Local nDlgWidth
Local nDiffWidth := 0 
Local lMDI := .F.
Local nSizeHeader := 30
Local aCordW := {}

Local cNomeFor  := ::oEmit:GetItem("NOME")
Local cCNPJFor  := ::oEmit:GetItem("CGC")
Local cNotaFor  := ::oNF:GetItem("DOC")
Local cSerieFor := ::oNF:GetItem("SERIE")
Local cEmissao  := ::oNF:GetItem("EMISSAO")
Local cChave    := ::oNF:GetItem("CHAVE")
Local nTotalNf  := Val(StrTran(If(Type("oXTotal:_ICMSTOT:_VNF")=="U","0", AllTrim(oXTotal:_ICMSTOT:_VNF:TEXT)), ",","."))

	If SetMDIChild()
		oMainWnd:ReadClientCoors()
		nDlgHeight 	:= oMainWnd:nHeight
		nDlgWidth	:= oMainWnd:nWidth
		lMdi 		:= .T.
		nDiffWidth 	:= 0
	Else           
		nDlgHeight 	:= 420
		nDlgWidth	:= 632
		nDiffWidth 	:= 1
	EndIf
	
	aCordW := {135, 000, nDlgHeight, nDlgWidth}

	//::PopCabec()
	::PopHead1()
	
	//::oDlg1 := MSDialog():New(000,000,570,1000,"Importacao XML NF-e",,,,,,,,,.T.)
	::oDlg1 := MSDialog():New(aCordW[1],aCordW[2],aCordW[3],aCordW[4],"Importacao XML NF-e",,,,,,,,oMainWnd,.T.)	
	::oDlg1:bInit     := {|| EnchoiceBar(::oDlg1, {||::Confirmar1()}, {||::Cancelar1()},,aButtons), ::oGetD1:oBrowse:nColPos := 5, ::oGetD1:oBrowse:SetFocus()}
	::oDlg1:lCentered := .T.
	If lMdi
		::oDlg1:lMaximized := .T.
	EndIf	

	TGet():New(003,005,{|u|If(PCount()==0,cNomeFor,cNomeFor:= u)},::oDlg1,130,009    ,"@!" ,{||.T.},        ,        ,     ,        ,        ,.T.   ,        ,        ,{||.T.},        ,        ,       ,.T.      ,.F.      ,        ,"cNomeFor",        ,        ,        ,          ,         ,        ,"Fornecedor: ")
	TGet():New(003,170,{|u|If(PCount()==0,cCNPJFor,cCNPJFor:= u)},::oDlg1,060,009    ,"@!" ,{||.T.},        ,        ,     ,        ,        ,.T.   ,        ,        ,{||.T.},        ,        ,       ,.T.      ,.F.      ,        ,"cCNPJFor",        ,        ,        ,          ,         ,        ,"CNPJ/CPF: ")
	TGet():New(003,260,{|u|If(PCount()==0,cNotaFor,cNotaFor:= u)},::oDlg1,035,009    ,"@!" ,{||.T.},        ,        ,     ,        ,        ,.T.   ,        ,        ,{||.T.},        ,        ,       ,.T.      ,.F.      ,        ,"cNotaFor",        ,        ,        ,          ,         ,        ,"Docto: ")
	TGet():New(003,320,{|u|If(PCount()==0,cSerieFor,cSerieFor:= u)},::oDlg1,005,009    ,"@!" ,{||.T.},        ,        ,     ,        ,        ,.T.   ,        ,        ,{||.T.},        ,        ,       ,.T.      ,.F.      ,        ,"cSerieFor",        ,        ,        ,          ,         ,        ,"Série: ")
	TGet():New(003,360,{|u|If(PCount()==0,cEmissao,cEmissao:= u)},::oDlg1,035,009,"@!",{||.T.},,,,,,.T.,,,{||.T.},,,,.T.,.F.,,"cEmissao",,,,,,,"Emissão: ")

	TGet():New(003,425,{|u|If(PCount()==0,nTotalNf,nTotalNf:= u)},::oDlg1,040,009,"@E 999,999.99",{||.T.},,,,,,.T.,,,{||.T.},,,,.T.,.F.,,"nTotalNf",,,,,,,"Total R$: ")	
	TGet():New(003,490,{|u|If(PCount()==0,cChave,cChave:= u)},::oDlg1,150,009,"@!",{||.T.},,,,,,.T.,,,{||.T.},,,,.T.,.F.,,"cChave",,,,,,,"Chave: ")	

	TSay():New(017,003,{||"Dados da NF-e:"},::oDlg1,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,090,20)	
	TSay():New(017,280,{||"Nosso Cadastro:"},::oDlg1,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,090,20)	
	
	//(nSizeHeader/2)+13+2,1,If(lMdi, (oMainWnd:nHeight/2)-25,__DlgHeight(oDlg)),If(lMdi, (oMainWnd:nWidth/2)-2,__DlgWidth(oDlg)-nDiffWidth)	
	//	::oGetD1 := MsNewGetDados():New(020,005,270,500, GD_UPDATE,;
	::oGetD1 := MsNewGetDados():New(nSizeHeader,1,If(lMdi, (oMainWnd:nHeight/2)-25,__DlgHeight(oDlg)),If(lMdi, (oMainWnd:nWidth/2)-2,__DlgWidth(oDlg)-nDiffWidth),;
	                            GD_UPDATE,;	
                                cLinOk,cTudoOk,cIniCpos,aAlterGD,nFreeze,nMax,cFieldOk, cSuperDel,;
								cDelOk, ::oDlg1, ::aHeader1, ::aCols1)	

	::oGetD1:oBrowse:nColPos := 5
	_oGetD1 := ::oGetD1
	::oDlg1:Activate()								
Return Self
/*
*/
Method PopHead1() Class TWImpNfe
	::aHeader1 := {}

	aAdd(::aHeader1, {"Cod.Prod.NF-e", "CODPRONFE", "@!", ::nTamProNfe, 0, "AllwaysTrue()","","C","","","","","","","","",".T."})
	aAdd(::aHeader1, {"Dsc.Prod.NF-e", "DSCPRONFE", "@!", ::nTamDscNfe, 0, "AllwaysTrue()","","C","","","","","","","","",".T."})
	aAdd(::aHeader1, {"NCM.Prod.NF-e", "NCMPRONFE", "@!", ::nTamNcmPro, 0, "AllwaysTrue()","","C","","","","","","","","",".F."})
	aAdd(::aHeader1, {"CEST.Prod.NF-e", "CESTPRONFE", "@!", ::nTamCest, 0, "AllwaysTrue()","","C","","","","","","","","",".F."})	
	aAdd(::aHeader1, {"Cod.Prod", "CODPRO", "@!", ::nTamCodPro, 0, "U_VldPrImp()","","C","SB1","","","","","A","","",".T."})	
	aAdd(::aHeader1, {"Dsc.Prod", "DSCPRO", "@!", ::nTamDscPro, 0, "AllwaysTrue()","","C","","","","","","","","",".T."})		
	aAdd(::aHeader1, {"NCM.Prod", "NCMPRO", "@!", ::nTamNcmPro, 0, "AllwaysTrue()","","C","","","","","","","","",".F."})				
	aAdd(::aHeader1, {"CEST.Prod", "CESTPRO", "@!", ::nTamCest, 0, "AllwaysTrue()","","C","","","","","","","","",".F."})					
Return Self
/*
*/
User Function VldPrImp()
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea())
	
	Begin Sequence
		If Empty(M->CODPRO)
			lRet := .F.
			Break
		EndIf
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		
		If DbSeek(xFilial("SB1") + M->CODPRO)
			If SB1->B1_MSBLQL != "1"				
				_oGetD1:aCols[_oGetD1:nAt,06] := SB1->B1_DESC
				_oGetD1:aCols[_oGetD1:nAt,07] := SB1->B1_POSIPI
			    If FieldPos("B1_CEST") > 0
					_oGetD1:aCols[_oGetD1:nAt,08] := SB1->B1_CEST
				EndIf
			Else
				MsgInfo("O produto " + SB1->(AllTrim(B1_COD) + "-" + AllTrim(B1_DESC)) + " está bloqueado e deve ser desbloqueado para ser importado!")
				lRet := .F.
				Break				
			End If			
		Else
			lRet := .F.
			Break
		EndIf
	End Sequence
	
	RestArea(aAreaSB1)
	RestArea(aArea)	
Return(lRet)
/*
*/
User Function VlLinPrI()
Local lRet := .T.
Local cMsg := ""
Local cCRLF := Chr(13) + Chr(10)

	If Empty(_oGetD1:aCols[_oGetD1:nAt,07])
		cMsg += If(Empty(cMsg), "", cCRLF + cCRLF) + "O campo NCN não foi informado."
	End If
		
	//If Empty(_oGetD1:aCols[_oGetD1:nAt,08])
	//	cMsg += If(Empty(cMsg), "", cCRLF + cCRLF) + "O campo CEST não foi informado."
	//End If	

	If !Empty(_oGetD1:aCols[_oGetD1:nAt,05]) .And. AllTrim(_oGetD1:aCols[_oGetD1:nAt,03]) != AllTrim(_oGetD1:aCols[_oGetD1:nAt,07])
		cMsg += If(Empty(cMsg), "", cCRLF + cCRLF) + "O NCN do produto da NF-e é diferente do nosso cadastro."
	End If

	//If !Empty(_oGetD1:aCols[_oGetD1:nAt,05]) .And. AllTrim(_oGetD1:aCols[_oGetD1:nAt,04]) != AllTrim(_oGetD1:aCols[_oGetD1:nAt,08])
	//	cMsg += If(Empty(cMsg), "", cCRLF + cCRLF) + "O CEST do produto da NF-e é diferente do nosso cadastro."
	//End If		
	
	If !Empty(cMsg)
		MsgInfo(cMsg)
	End if
Return(lRet)
/*
*/
Method Confirmar1() Class TWImpNfe
    Local nI := 0
	
	::aCols1 := aClone(::oGetD1:aCols)
	
	U_VlLinPrI()
	
	If ::AmarraOK()
		DbSelectArea("SA5")
		DbSetOrder(14)	
		
		For nI := 1 To Len(::aCols1)
			If !DbSeek(xFilial("SA5") + ::oEmit:GetItem("COD") + ::oEmit:GetItem("LOJA") + ::aCols1[nI,01]) 
				RecLock("SA5",.T.)
					SA5->A5_FILIAL  := xFilial("SA5")
					SA5->A5_FORNECE := ::oEmit:GetItem("COD")
					SA5->A5_LOJA 	:= ::oEmit:GetItem("LOJA")
					SA5->A5_NOMEFOR := ::oEmit:GetItem("NOME")
					SA5->A5_PRODUTO := ::aCols1[nI,05]
					SA5->A5_NOMPROD := ::aCols1[nI,02]
					SA5->A5_CODPRF  := ::aCols1[nI,01]
				SA5->(MsUnLock())
			Endif		
		Next nI		
	
		::oDlg1:End()	
	Else
		Aviso("Importação XML NF-e", "Amarração Fornecedor X Produto inconsistente.", { "OK" }, 1)		
	EndIf
Return(::lAmarraOk)
//
Method Cancelar1() Class TWImpNfe
	::oDlg1:End()
	::lAmarraOk := .F.
Return(.T.)
/*
*/
User Function FWImpNFe()
Local oImpNFe := TWImpNfe():New()

	oImpNFe:Executa()
Return(.T.)
/*
*/
Method PreNota() Class TWImpNfe
Local lRet     := .F.
Local nD       := 0
Local aAreaSD1

Private oXTotal     := ::oXTotal
Private oXTransp    := ::oXTransp
Private oXNF        := ::oXNF
Private oXDet       := ::oXDet
Private lMsErroAuto := .F.

	::aCabec := {}
	::aItens := {}

	aAdd(::aCabec, {"F1_TIPO"  , "N"                   , Nil, Nil})
	aAdd(::aCabec, {"F1_FORMUL", "N"                   , Nil, Nil})
	aAdd(::aCabec, {"F1_DOC"   , ::oNF:GetItem("DOC")  , Nil, Nil})
	aAdd(::aCabec, {"F1_SERIE" , ::oNF:GetItem("SERIE"), Nil, Nil})
	
	If Type("oXTotal:_ICMSTOT:_vOutro:TEXT")<>"U"
		aAdd(::aCabec,{"F1_DESPESA"  ,Round(Val(oXTotal:_ICMSTOT:_vOutro:TEXT), 2),Nil,Nil})
	EndIf
		
	If Type("oXNF:_InfNfe:_infAdic:_infCpl"	)!="U"
		aAdd(::aCabec,{"F1_MENNOTA",oXNF:_InfNfe:_infAdic:_infCpl:TEXT ,Nil,Nil})
	EndIf

	aAdd(::aCabec,{"F1_EMISSAO", Stod(StrTran(::oNF:GetItem("EMISSAO"),"-","")), Nil, Nil})
	aAdd(::aCabec,{"F1_FORNECE", ::oEmit:GetItem("COD")        , Nil, Nil})
	aAdd(::aCabec,{"F1_LOJA"   , ::oEmit:GetItem("LOJA")       , Nil, Nil})
	aAdd(::aCabec,{"F1_ESPECIE", "SPED"                        , Nil, Nil})	

	::nDespesa   := Round(Val(::oXTotal:_ICMSTOT:_vOutro:TEXT), 2)  	
	::nDespUnit  := Round(::nDespesa / Len(::oXDet), 2)
	::nDiferenca := ::nDespesa - (::nDespUnit * Len(::oXDet))
	
	::aItens     := {}
	
	For nD := 1 To Len(::oXDet)
		::aLinha := {}
	
		aAdd(::aLinha, {"D1_COD", ::aCols1[nD, 05], Nil, Nil})
	
		If Val(::oXDet[nD]:_Prod:_qTrib:TEXT) != 0
			aAdd(::aLinha,{"D1_QUANT",Val(::oXDet[nD]:_Prod:_qTrib:TEXT),Nil,Nil})
			aAdd(::aLinha,{"D1_VUNIT",Round(Val(::oXDet[nD]:_Prod:_vProd:TEXT) / Val(::oXDet[nD]:_Prod:_qTrib:TEXT), ::nTamVUnit),Nil,Nil})
		Else
			aAdd(::aLinha,{"D1_QUANT",Val(::oXDet[nD]:_Prod:_qCom:TEXT),Nil,Nil})
			aAdd(::aLinha,{"D1_VUNIT",Round(Val(::oXDet[nD]:_Prod:_vProd:TEXT) / Val(::oXDet[nD]:_Prod:_qCom:TEXT), ::nTamVUnit),Nil,Nil})
		Endif
		//Val(::oXDet[nD]:_Prod:_vUnCom:TEXT)
		aAdd(::aLinha,{"D1_TOTAL",Val(::oXDet[nD]:_Prod:_vProd:TEXT),Nil,Nil})				
		
		If Type("oXDet[nD]:_Prod:_vDesc") != "U"
			aAdd(::aLinha,{"D1_VALDESC",Val(::oXDet[nD]:_Prod:_vDesc:TEXT),Nil,Nil})
		Else
			aAdd(::aLinha,{"D1_VALDESC",0,Nil,Nil})
		EndIf		
		
		::nItem := nD
		
		::Imposto()
			
		If nD == Len(::oXDet)
			::nDespUnit += ::nDiferenca
		EndIf
			               
		aAdd(::aLinha,{"D1_BASEICM" ,::nBaseICM	, Nil, Nil})
		aAdd(::aLinha,{"D1_VALICM"  ,::nValICM	, Nil, Nil})
		aAdd(::aLinha,{"D1_PICM"    ,::nPICM    , Nil, Nil})
		aAdd(::aLinha,{"D1_CLASFIS"	,::cSitTrib	, Nil, Nil})
		aAdd(::aLinha,{"D1_VALIPI"	,::nValIPI	, Nil, Nil})
		aAdd(::aLinha,{"D1_IPI"		,::nPIPI	, Nil, Nil})
		aAdd(::aLinha,{"D1_BASEIPI"	,::nBaseIPI	, Nil, Nil})
		aAdd(::aLinha,{"D1_DESPESA"	,::nDespUnit, Nil, Nil})		

		aAdd(::aItens, ::aLinha)
		
	Next nD
	
	nModulo     := 4 //Estoque
	lMsErroAuto := .F.

	BeginTran()
		
	MSExecAuto({|x,y,z|Mata140(x,y,z)},::aCabec,::aItens,3)

	If lMsErroAuto
		RollBackSX8()
		DisarmTran()
		MostraErro()
	Else
		RecLock("SF1",.F.)
			SF1->F1_CHVNFE := ::oNF:GetItem("CHAVE")
		SF1->(MsUnlock())  
		
		aAreaSD1 := SD1->(GetArea())
		
		DbSelectArea("SD1")
		DbSetOrder(1)
		DbGoTop()
		
		For nD := 1 To Len(::oXDet)
			If DbSeek( SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + Padr(::aCols1[nD, 05], TamSX3("D1_COD")[1]) + StrZero(nD, 4)) )  
				RecLock("SD1", .F.)
					If Val(::oXDet[nD]:_Prod:_qTrib:TEXT) != 0
						SD1->D1_VUNIT := Round(Val(::oXDet[nD]:_Prod:_vProd:TEXT) / Val(::oXDet[nD]:_Prod:_qTrib:TEXT), ::nTamVUnit)
					Else
						SD1->D1_VUNIT := Round(Val(::oXDet[nD]:_Prod:_vProd:TEXT) / Val(::oXDet[nD]:_Prod:_qCom:TEXT), ::nTamVUnit)
					Endif
				SD1->(MsUnlock())
			EndIf
		Next nD
		
		ConfirmSX8()   
		RestArea(aAreaSD1)
	EndIf	
	
	EndTran()  
	
	If !lMsErroAuto
		MsgInfo(SF1->(AllTrim(F1_DOC) + "/" + F1_SERIE) + " - Pre nota gerada com sucesso!")	
	EndIf
Return(!lMsErroAuto)
/*
*/
Method Classifica() Class TWImpNfe
Private aRotina := {}

	aAdd(aRotina,{"Pesquisar"  , "AxPesqui"   , 0 , 1, 0, .F.}) 		//"Pesquisar"
	aAdd(aRotina,{"Visualizar" , "A103NFiscal", 0 , 2, 0, nil}) 		//"Visualizar"
	aAdd(aRotina,{"Incluir"    , "A103NFiscal", 0 , 3, 0, nil}) 		//"Incluir"
	aAdd(aRotina,{"Classificar", "A103NFiscal", 0 , 4, 0, nil}) 		//"Classificar"

	IF MsgYesNo("Deseja Efetuar a Classificação da Nota " + SF1->(AllTrim(F1_DOC) + "/" + F1_SERIE) + " Agora ?")
		DbSelectArea("SF1")
		A103NFiscal("SF1",SF1->(Recno()),4,.F.,.F.)
	Endif
Return Self
/*
*/
Method Imposto() Class TWImpNfe
Local nY := 0

Private nItem  := ::nItem
Private oXEmit := ::oXEmit
Private oXDet  := ::oXDet

	::nBaseICM := 0	
	::nValICM  := 0
	::nPICM    := 0
	::cSitTrib := ""
	::nValIPI  := 0
	::nPIPI    := 0 
	::nBASEIPI := 0

	If Type("oXDet[nItem]:_Imposto")<>"U"
		If Type("oXDet[nItem]:_Imposto:_ICMS")<>"U"
			For nY := 1 To Len(::aSitTrib)
				If Type("oXDet[nItem]:_Imposto:_ICMS:_ICMS"+::aSitTrib[nY])<>"U"
					If Type("oXDet[nItem]:_Imposto:_ICMS:_ICMS"+::aSitTrib[nY]+":_VBC:TEXT")<>"U"
						::nBaseICM := Val(&("oXDet[nItem]:_Imposto:_ICMS:_ICMS"+::aSitTrib[nY]+":_VBC:TEXT"))
						::nValICM  := Val(&("oXDet[nItem]:_Imposto:_ICMS:_ICMS"+::aSitTrib[nY]+":_vICMS:TEXT"))
						::nPICM    := Val(&("oXDet[nItem]:_Imposto:_ICMS:_ICMS"+::aSitTrib[nY]+":_PICMS:TEXT"))
					EndIf
					::cSitTrib := &("oXDet[nItem]:_Imposto:_ICMS:_ICMS"+::aSitTrib[nY]+":_ORIG:TEXT")
					::cSitTrib += &("oXDet[nItem]:_Imposto:_ICMS:_ICMS"+::aSitTrib[nY]+":_CST:TEXT")
				EndIf												
			Next nY			
		               
			//Tratamento para o ICMS para optantes pelo Simples Nacional
			If Type("oXEmit:_CRT") <> "U" .And. oXEmit:_CRT:TEXT == "1"
				For nY := 1 To Len(::aSitSN)
					If Type("oXDet[nItem]:_Imposto:_ICMS:_ICMSSN"+::aSitSN[nY])<>"U"
						If Type("oXDet[nItem]:_Imposto:_ICMS:_ICMSSN"+::aSitSN[nY]+":_VBC:TEXT")<>"U"
							::nBaseICM := Val(&("oXDet[nItem]:_Imposto:_ICMS:_ICMSSN"+::aSitSN[nY]+":_VBC:TEXT"))
							::nValICM  := Val(&("oXDet[nItem]:_Imposto:_ICMS:_ICMSSN"+::aSitSN[nY]+":_vICMS:TEXT"))
							::nPICM    := Val(&("oXDet[nItem]:_Imposto:_ICMS:_ICMSSN"+::aSitSN[nY]+":_PICMS:TEXT"))                   
						EndIf
						::cSitTrib := &("oXDet[nItem]:_Imposto:_ICMS:_ICMSSN"+::aSitSN[nY]+":_CSOSN:TEXT")				
					EndIf
				Next nY	
			EndIf
		
		EndIf
		
		If Type("oXDet[nItem]:_Imposto:_IPI")<>"U"
			If Type("oXDet[nItem]:_Imposto:_IPI:_IPITrib:_vIPI:TEXT")<>"U"
				::nValIPI := Val(oXDet[nItem]:_Imposto:_IPI:_IPITrib:_vIPI:TEXT)
			EndIf
			If Type("oXDet[nItem]:_Imposto:_IPI:_IPITrib:_pIPI:TEXT")<>"U"
				::nPIPI   := Val(oXDet[nItem]:_Imposto:_IPI:_IPITrib:_pIPI:TEXT)
			EndIf
			If Type("oXDet[nItem]:_Imposto:_IPI:_IPITrib:_vBC:TEXT")<>"U"
				::nBASEIPI   := Val(oXDet[nItem]:_Imposto:_IPI:_IPITrib:_vBC:TEXT)
			EndIf 
			
		EndIf
	EndIf     
	     
	If ::nValIPI == 0
		::nBASEIPI := 0
	EndIf
Return Self
/*
*/
//Static Function Teste2
//	M->A2_COD := "999"
//Return(.T.)