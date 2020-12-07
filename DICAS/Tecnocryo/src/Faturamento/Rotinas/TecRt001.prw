#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"

User Function TecRt001()
	Processa({|| Percorre() },"Aguarde, processando...","Mensagem",.F.)
Return()
//
Static Function Percorre()
Local aArea    := GetArea()
Local aAreaCC2 := CC2->(GetArea()) 
Local aAreaDA0 := DA0->(GetArea())
Local aAreaDA1 := DA1->(GetArea())  
Local aAreaSA1 := SA1->(GetArea()) 
Local aAreaSB1 := SB1->(GetArea())

Local cDir      := "D:\TEMP\Tecnocryo\XML\"
Local cEspecArq := cDir + "*.xml"
Local aNomesArq := {}
Local nQtd      := 0
Local n         := 0
Local cArquivo  := "" 

	nQtd := aDir(cEspecArq, @aNomesArq) 
	
	ProcRegua(nQtd)
	
	DbSelectArea("DA0")
	DbSetOrder(1) //DA0_FILIAL, DA0_CODTAB, R_E_C_N_O_, D_E_L_E_T_    
	
	DbSelectArea("DA1")
	DbSetOrder(1) //DA1_FILIAL, DA1_CODTAB, DA1_CODPRO, DA1_INDLOT, DA1_ITEM, R_E_C_N_O_, D_E_L_E_T_
	
	DbSelectArea("CC2")
	DbSetOrder(4)

	DbSelectArea("SA1")
	DbSetOrder(3)	
	
	DbSelectArea("SB1")
	DbSetOrder(1)

	For n := 1 To nQtd
		cArquivo := aNomesArq[n]
		IncProc(cArquivo)		
		Importa(cDir,cArquivo)
	Next n
	
	RestArea(aAreaCC2) 
	RestArea(aAreaDA0)
	RestArea(aAreaDA1)
	RestArea(aAreaSA1)	
	RestArea(aAreaSB1)
	RestArea(aArea)	
Return()
//
Static Function Importa(cDir, cArq)
Local cFile    := cDir + cArq
Local nHdl     := -1
Local nTamFile := 0 
Local cBuffer  := "", cAviso := "", cErro := ""
Local nBtLidos := 0

Local oDest    := HashTable():New()

Private oXNFe, oXDest, oXTransp, oXDet, oXEnder

	If !File(cFile)
		Return
	EndIf
	
	nHdl := fOpen(cFile,0)   

	If nHdl == -1
		Return
	Endif	

	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	cBuffer  := Space(nTamFile)
	nBtLidos := fRead(nHdl,@cBuffer,nTamFile)
	fClose(nHdl)     
	
	oXNFe := XmlParser(cBuffer,"_",@cAviso,@cErro)	

	If ValType(oXNFe) != "O"
		MsgAlert(cArq + " - " + cErro, "ERRO IMPORTAÇÃO XML - NOTA FISCAL ELETRÔNICA")
		Return
	EndIf
    
	If Type("oXNfe:_NFEPROC:_NFE:_INFNFE:_DEST") <> "U"
		oXDest := oXNfe:_NFEPROC:_NFE:_INFNFE:_DEST
		Cliente()
		
		If Type("oXNfe:_NFEPROC:_NFE:_INFNFE:_DET") <> "U"
			oXDet := oXNfe:_NFEPROC:_NFE:_INFNFE:_DET
			Produto()
		EndIf 		
	EndIf	
Return()
//
Static Function Produto()
Local aProds := {}
Local aProd  := {}
Local nDesc  := TamSX3("B1_DESC")[1]
Local cEan   := ""
Local cCod   := ""
Local cNcm   := ""
Local cUn    := ""
Local cDsc   := ""
Local cTab   := SA1->A1_TABELA
Local nVal   := 0.00
Local x      := 0
Local p      := 0

	Do Case
	Case Type("oXDet") == "O"
		cEan := oXDet:_PROD:_CEAN:TEXT
		cCod := AllTrim(oXDet:_PROD:_CPROD:TEXT)
		cNcm := oXDet:_PROD:_NCM:TEXT
		cUn  := oXDet:_PROD:_UCOM:TEXT
		cDsc := oXDet:_PROD:_XPROD:TEXT
		nVal := Val(AllTrim(oXDet:_PROD:_VPROD:TEXT))
		
		aProd := {xFilial("SB1"), cCod, cDsc, "PA", cUn, "01", cNcm, nVal}
		
		aAdd(aProds, aProd)
		
	Case Type("oXDet") == "A"
		For x := 1 To Len(oXDet)
			cEan := oXDet[x]:_PROD:_CEAN:TEXT
			cCod := AllTrim(oXDet[x]:_PROD:_CPROD:TEXT)
			cNcm := oXDet[x]:_PROD:_NCM:TEXT
			cUn  := oXDet[x]:_PROD:_UCOM:TEXT
			cDsc := oXDet[x]:_PROD:_XPROD:TEXT
			nVal := Val(AllTrim(oXDet[x]:_PROD:_VPROD:TEXT))					
			
			aProd := {xFilial("SB1"), cCod, cDsc, "PA", cUn, "01", cNcm, nVal}
			
			aAdd(aProds, aProd)			
		Next x
	End Case
	
	For p := 1 to Len(aProds)
		If !SB1->(DbSeek( aProds[p,01] + aProds[p,02]   ))
			RecLock("SB1", .T.)
				SB1->B1_FILIAL  := aProds[p,01]
				SB1->B1_COD     := aProds[p,02]
				SB1->B1_DESC    := if(Len(aProds[p,03]) > nDesc, SubStr(aProds[p,03], 1, nDesc), aProds[p,03])
				SB1->B1_TIPO    := aProds[p,04]
				SB1->B1_UM      := aProds[p,05]
				SB1->B1_LOCPAD  := aProds[p,06]
				SB1->B1_POSIPI  := aProds[p,07]	
				SB1->B1_GRUPO   := If( Len(aProds[p,02]) == 10, SubStr(aProds[p,02],1, 4), "    " )
				SB1->B1_ORIGEM  := "0"			
				SB1->B1_CLASFIS := "00"
				SB1->B1_GARANT  := "2"
			SB1->(MsUnlock())
		EndIf
		
		If Empty(SA1->A1_TABELA)
			cTab := GetSx8Num("DA0", "DA0_CODTAB")
			
			Reclock("DA0", .T.)
				DA0->DA0_FILIAL := xFilial("DA0")
				DA0->DA0_CODTAB := cTab
				DA0->DA0_DESCRI := SA1->A1_NREDUZ
				DA0->DA0_DATDE  := dDataBase
				DA0->DA0_HORADE := "00:00"
				DA0->DA0_HORATE := "23:59"
				DA0->DA0_TPHORA := "1"
				DA0->DA0_ATIVO  := "1"				
			DA0->(MsUnlock())
			
			ConfirmSX8()
			
			Reclock("SA1", .F.)
				SA1->A1_TABELA := cTab
			SA1->(Msunlock())
			
			Reclock("DA1", .T.) 
				DA1->DA1_FILIAL := xFilial("DA1")
				DA1->DA1_CODTAB := cTab
				DA1_ITEM        := "0001"
				DA1_CODPRO      := aProds[p,02]
				DA1_PRCVEN      := aProds[p,08]
				DA1_ATIVO       := "1"
				DA1_TPOPER      := "4"
				DA1_QTDLOT      := 999999.99
				DA1_MOEDA       := 1
				DA1_DATVIG      := dDataBase				
			DA1->(MsUnlock())			
		Else
			If DA0->(DbSeek(xFilial("DA0") + cTab))
				If !DA1->(DbSeek( xFilial("DA1") + DA0->DA0_CODTAB + aProds[p,02] ))
					Reclock("DA1", .T.) 
						DA1->DA1_FILIAL := xFilial("DA1")
						DA1->DA1_CODTAB := cTab
						DA1->DA1_ITEM   := ProxItem(cTab)
						DA1->DA1_CODPRO := aProds[p,02]
						DA1->DA1_PRCVEN := aProds[p,08]
						DA1->DA1_ATIVO  := "1"
						DA1->DA1_TPOPER := "4"
						DA1->DA1_QTDLOT := 999999.99
						DA1->DA1_MOEDA  := 1
						DA1->DA1_DATVIG := dDataBase				
					DA1->(MsUnlock())					
				EndIf			
			EndIf
		EndIf		
		
		DbCommitAll()
	Next p
Return()
//
Static Function ProxItem(cCodTab)
Local cItem := "0000"
Local Query := GetNextAlias()
Local cSql  := ""
	
	cSql := "SELECT COALESCE(MAX(DA1_ITEM),'0000') DA1_ITEM "
	cSql += "  FROM " + RetSqlname("DA1") + " " 
	cSql += " WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "
	cSql += "  AND DA1_CODTAB = '" + cCodTab + "' "
	cSql += "  AND D_E_L_E_T_ != '*' "
	
	TcQuery cSQL New Alias (Query)

	cItem := Soma1((Query)->DA1_ITEM)

	(Query)->(dbCloseArea())
Return(cItem)
//
Static Function Cliente()
Local nNome     := TamSX3("A1_NOME")[1] 
Local nNReduz   := TamSX3("A1_NREDUZ")[1] 
Local nEnd      := TamSX3("A1_END")[1] 
Local nCompl    := TamSX3("A1_COMPLEM")[1] 
Local cCgc      := ""
Local cPessoa   := ""
Local cCod      := ""
Local cLj       := ""
Local cNome     := ""
Local cFantasia := ""
Local cEmail    := ""
Local cEnder    := ""
Local cNum      := ""
Local cFone     := ""
Local cCep      := ""
Local cUf       := ""
Local cBairro   := ""
Local cMun      := ""
Local cIE       := ""
Local cIM       := ""
Local cCompl    := ""
Local cCodMun   := ""
Local cDdd      := ""

	If Type("oXDest:_CNPJ") <> "U" 
		cPessoa := "J"
		cCgc    := AllTrim(oXDest:_CNPJ:TEXT)
		cCod    := "0" + SubStr(cCgc,1,8)
		cLj     := SubStr(cCgc,9,4)
	EndIf  
	
	If Type("oXDest:_CPF") <> "U" 
		cPessoa := "F"
		cCgc    := AllTrim(oXDest:_CPF:TEXT)
		cCod    := SubStr(cCgc,1,9)
		cLj     := SubStr(cCgc,10,2) + "00"
	EndIf
	
	If SA1->(DbSeek(xFilial("SA1") + cCgc))
		Return
	EndIf

	If Type("oXDest:_IE") <> "U" 
		cIE  := AllTrim(oXDest:_IE:TEXT)
	EndIf

	If Type("oXDest:_IM") <> "U" 
		cIM  := AllTrim(oXDest:_IM:TEXT)
	EndIf

	cNome   := AllTrim(oXDest:_XNOME:TEXT)

	If Type("oXDest:_EMAIL") <> "U" 
		cEmail  := StrTran(AllTrim(oXDest:_EMAIL:TEXT), ";contato@tecnocryo.com.br", "")
	EndIf  
	
	If Type("oXDest:_XCPL") <> "U" 
		cCompl  := AllTrim(oXDest:_XCPL:TEXT)
	EndIf	
	
	oXEnder := oXDest:_ENDERDEST
	
	cEnder  := AllTrim(oXEnder:_XLGR:TEXT)
	cNum    := AllTrim(oXEnder:_NRO:TEXT)
	
	If Empty(cNum)
	 	If Len(cEnder) > nEnd
	 		cEnder := SubStr(cEnder, 1, nEnd)
	 	EndIf
	Else
		cEnder := SubStr(cEnder, 1, nEnd - Len(cNum) + 1  )
	    cEnder += "," + cNum
	EndIf

	If Type("oXEnder:_FONE") != "U"
	    cFone := AllTrim(oXEnder:_FONE:TEXT)	
	     
	    cDdd := SubStr(cFone, 1, 2)
	    cFone := SubStr(cFone, 3, Len(cFone) - 2)
	EndIf
	

    cCep    := oXEnder:_CEP:TEXT
    cUf     := oXEnder:_UF:TEXT
    cBairro := oXEnder:_XBAIRRO:TEXT
    cMun    := oXEnder:_XMUN:TEXT
    
    If (CC2->(DbSeek( xFilial("CC2") + cUf + cMun )))
    	cCodMun := CC2->CC2_CODMUN
    EndIf
    
	RecLock("SA1", .T.)
    	SA1->A1_FILIAL  := xFilial("SA1")
     	SA1->A1_COD     := cCod
     	SA1->A1_LOJA    := cLj  
     	SA1->A1_CGC     := cCgc
     	SA1->A1_NOME    := SubStr(cNome, 1, nNome)
     	SA1->A1_NREDUZ  := SubStr(cNome, 1, nNReduz)
     	SA1->A1_PESSOA  := cPessoa
     	SA1->A1_TIPO    := "F"
     	SA1->A1_END     := cEnder
     	SA1->A1_COMPLEM := If(Len(cCompl) > nCompl, SubStr(cCompl, 1, nCompl), cCompl)   
     	SA1->A1_EST     := cUf
     	//SA1->A1_COD_MUN := ""
     	SA1->A1_MUN     := cMun
     	SA1->A1_COD_MUN := cCodMun
     	SA1->A1_PAIS    := "105"
     	SA1->A1_CODPAIS := "01058"
     	SA1->A1_BAIRRO  := cBairro
     	SA1->A1_CEP     := cCep
     	SA1->A1_TEL     := cFone
     	SA1->A1_INSCR   := cIE
     	SA1->A1_INSCRM  := cIM
     	SA1->A1_EMAIL   := cEmail
     	SA1->A1_DDI     := "55"
     	SA1->A1_DDD     := cDdd  
     	SA1->A1_TPESSOA := "CI" 
     	//SA1->A1_TABELA
	SA1->(MsUnlock())
Return()