#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "XMLXFUN.CH"

USER FUNCTION CHEC_XML()

	/*ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPROGRAMA  ณ CHEC_XML         ณ MADALENO           บ DATA ณ  30/04/10   บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDESC.     ณ CHECA SE EXISTE O ARQUIVO XML DA NOTA FISCAL DIGITADA      บฑฑ
	ฑฑบ          ณ                                                            บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบUSO       ณ AP 10                                                      บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/

	PRIVATE CARQUIVO := ""
	PRIVATE LOG_NF_NAO := {}
	PRIVATE LOG_NFPROBLEMA := 0
	PRIVATE LOG_NFIMPORTADAS := 0
	PRIVATE CSQL := ""
	PRIVATE ENTER := CHR(13) + CHR(10)
	PRIVATE CCC_EMP := ""
	IF CEMPANT = "01"
		CCC_EMP := "BIANCOGRES"
	ELSE
		CCC_EMP := "INCESA"
	END IF

	cHInicio := Time()
	fPerg := "CHEC_XML"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	xFoldArq := Alltrim(MV_PAR01)
	If left(xFoldArq,1) <> "\"
		xFoldArq := xFoldArq+"\"
	EndIf

	U_BIAMsgRun("Consultando arquivos...",, {|| ChqXmlProc()  })

Return

/*___________________________________________________________________________
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆFun็ใo    ฆ ChqXmlProc ฆ Autor ฆ Marcos Alberto S    ฆ Data ฆ 27/04/12 ฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ*/
Static Function ChqXmlProc()
	
	Local I

	// VERIFICANDO SE EXISTE A PASTA.
	ADIRECTORY := DIRECTORY(xFoldArq + "NFE\" + CCC_EMP + "\*.XML")
	//ADIRECTORY := DIRECTORY("T:\Protheus_Data\P10\NFE\"+CCC_EMP+"\*.XML")

	FOR I := 1 TO LEN(ADIRECTORY)

		CARQUIVO := aDirectory[I][1]
		// ABRINDO O ARQUIVO XMNL
		PRIVATE CERROR   := ""
		PRIVATE CWARNING := ""
		PRIVATE OXML := NIL
		PRIVATE CFILE := "\P10\NFE\"+CCC_EMP+"\" + CARQUIVO
		OXML := XMLPARSERFILE( CFILE, "_", @CERROR, @CWARNING )

		IF OXML == NIL
			CpyS2T( "\P10\NFE\"+CCC_EMP+"\"+CARQUIVO , "\P10\NFE_PROBLEMA\"+CCC_EMP+"\"+CARQUIVO)
			FERASE("\P10\NFE\"+CCC_EMP+"\"+CARQUIVO)
			LOG_NFPROBLEMA += 1
		ELSE
			LLRET := XmlChildEx ( oXml , "_NFEPROC" )
			IF LLRET <> NIL
				C_NOTA_FISCAL := PADL(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT,9,"0") 		// NUMERO NOTA FISCAL
				C_SERIE_NOTA	:= OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT		// SERIE
				C_CNPJ_FOR 		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT 	// CNPJ FORNECDOR
				C_NOME_FOR 		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT	// NOME
			ELSE
				LLRET := XmlChildEx ( oXml , "_NFE" )
				IF LLRET <> NIL
					C_NOTA_FISCAL := PADL(oXml:_NFE:_INFNFE:_IDE:_NNF:TEXT,9,"0") 		// NUMERO NOTA FISCAL
					C_SERIE_NOTA	:= oXml:_NFE:_INFNFE:_IDE:_SERIE:TEXT 	// SERIE
					C_CNPJ_FOR 		:= oXml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT 	// CNPJ FORNECDOR
					C_NOME_FOR 		:= oXml:_NFE:_INFNFE:_EMIT:_XNOME:TEXT // NOME
				END IF
			END IF

			IF LLRET = NIL
				CpyS2T( "\P10\NFE\"+CCC_EMP+"\"+CARQUIVO , "\P10\NFE_PROBLEMA\"+CCC_EMP+"\"+CARQUIVO)
				FERASE("\P10\NFE\"+CCC_EMP+"\"+CARQUIVO)
				LOG_NFPROBLEMA += 1
			ELSE

				// VERIFICANDO SE A NOTA JA FOI DIGITADA
				CSQL := "SELECT F1_DOC, SF1.R_E_C_N_O_ AS N_RECNO " + ENTER
				CSQL += "FROM "+RETSQLNAME("SF1")+" SF1, "+RETSQLNAME("SA2")+" SA2 " + ENTER
				CSQL += "WHERE	RTRIM(F1_DOC) = '"+SUBSTRING(C_NOTA_FISCAL,4,6)+"' AND  " + ENTER
				//CSQL += "		F1_SERIE = '"+C_SERIE_NOTA+"' AND " + ENTER
				CSQL += "		F1_FORNECE = A2_COD AND " + ENTER
				CSQL += "		F1_LOJA = A2_LOJA AND " + ENTER
				CSQL += "		F1_ESPECIE = 'SPED' AND " + ENTER
				CSQL += "		A2_CGC = '"+C_CNPJ_FOR+"' AND " + ENTER
				CSQL += "		SF1.D_E_L_E_T_ = '' AND " + ENTER
				CSQL += "		SA2.D_E_L_E_T_ = '' " + ENTER
				If chkfile("_AUX")
					dbSelectArea("_AUX")
					dbCloseArea()
				EndIf
				TCQUERY CSQL ALIAS "_AUX" NEW

				IF ! _AUX->(EOF()) // ACHOU A NOTA FISCAL

					CCQUERY := " UPDATE "+RETSQLNAME("SF1")+" SET F1_YIMPXML = 'S' WHERE R_E_C_N_O_ = '"+ALLTRIM(STR(_AUX->N_RECNO)) +"' "
					TCSQLEXEC(CCQUERY)

					CNOME_DIRETORIO := C_NOME_FOR + " - " + C_CNPJ_FOR
					//VERIFICANDO SE A PASTA EXISTE DO FORNECEDOR
					IF MakeDir("\P10\NFE_IMPORTADA\"+CCC_EMP+"\" + CNOME_DIRETORIO + "\")  <> 5 // VERIFICANDO SE
						MAKEDIR("\P10\NFE_IMPORTADA\"+CCC_EMP+"\" + CNOME_DIRETORIO)
					END IF

					CpyS2T( "\P10\NFE\"+CCC_EMP+"\"+CARQUIVO , "\P10\NFE_IMPORTADA\"+CCC_EMP+"\" + CNOME_DIRETORIO + "\" + SUBSTRING(C_NOTA_FISCAL,4,6) + "-" + C_CNPJ_FOR  + ".XML")
					FERASE("\P10\NFE\"+CCC_EMP+"\"+CARQUIVO)
					LOG_NFIMPORTADAS += 1
				ELSE
					AADD(LOG_NF_NAO , "NF - " + SUBSTRING(C_NOTA_FISCAL,4,6) + " - " + C_SERIE_NOTA + " - FORNECEDOR - " + C_NOME_FOR )
				END IF

			END IF
		END IF
	next

	//**********************************************************************************************************************************************
	//********************************************** Por Marcos Alberto Soprani (26/04/12) *********************************************************
	//**********************************************************************************************************************************************

	// Verificando se existe a Parta.
	aDirectory := Directory(xFoldArq + "XML_NFE\" + cEmpAnt + cFilAnt + "\RECEBIDOS\*.xml")

	For I := 1 TO Len(aDirectory)

		cArquivo := aDirectory[I][1]
		Private cError   := ""
		Private cWarning := ""
		Private oXML     := NIL
		Private cFile    := "\P10\NFE\"+CCC_EMP+"\" + CARQUIVO
		oXML := XMLParserFile( CFILE, "_", @CERROR, @CWARNING )

		If oXML == NIL
			CpyS2T( "\P10\XML_NFE\"+cEmpAnt+cFilAnt+"\RECEBIDOS\"+cArquivo , "\P10\XML_NFE\"+cEmpAnt+cFilAnt+"\PENDENTES\"+cArquivo)
			Ferase( "\P10\XML_NFE\"+cEmpAnt+cFilAnt+"\RECEBIDOS\"+cArquivo )
			Log_NfProblema += 1
		Else
			llRet := XmlChildEx ( oXml , "_NFEPROC" )
			If llRet <> NIL
				C_NOTA_FISCAL := PADL(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT,9,"0") 		// NUMERO NOTA FISCAL
				C_SERIE_NOTA	:= OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT           		// SERIE
				C_CNPJ_FOR 		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT 	            // CNPJ FORNECDOR
				C_NOME_FOR 		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT            	// NOME
			Else
				llRet := XmlChildEx ( oXml , "_NFE" )
				If llRet <> NIL
					C_NOTA_FISCAL := PADL(oXml:_NFE:_INFNFE:_IDE:_NNF:TEXT,9,"0") 		// NUMERO NOTA FISCAL
					C_SERIE_NOTA	:= oXml:_NFE:_INFNFE:_IDE:_SERIE:TEXT 	            // SERIE
					C_CNPJ_FOR 		:= oXml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT 	            // CNPJ FORNECDOR
					C_NOME_FOR 		:= oXml:_NFE:_INFNFE:_EMIT:_XNOME:TEXT              // NOME
				EndIf
			EndIf

			If llRet = NIL
				CpyS2T( "\P10\XML_NFE\"+cEmpAnt+cFilAnt+"\RECEBIDOS\"+cArquivo , "\P10\XML_NFE\"+cEmpAnt+cFilAnt+"\PENDENTES\"+cArquivo)
				Ferase( "\P10\XML_NFE\"+cEmpAnt+cFilAnt+"\RECEBIDOS\"+cArquivo )
				Log_NfProblema += 1
			Else

				// VERIFICANDO SE A NOTA JA FOI DIGITADA
				CSQL := " SELECT F1_DOC, SF1.R_E_C_N_O_ AS N_RECNO "
				CSQL += "   FROM "+RetSqlName("SF1")+" SF1, "+RetSqlName("SA2")+" SA2 "
				CSQL += "  WHERE F1_FILIAL = '"+xFilial("SF1")+"'
				CSQL += "	   AND A2_FILIAL = '"+xFilial("SA2")+"'
				CSQL += "	   AND RTRIM(F1_DOC) = '"+SUBSTRING(C_NOTA_FISCAL,4,6)+"'
				CSQL += "	   AND F1_FORNECE = A2_COD
				CSQL += "		 AND F1_LOJA = A2_LOJA
				CSQL += "		 AND F1_ESPECIE = 'SPED'
				CSQL += "		 AND A2_CGC = '"+C_CNPJ_FOR+"'
				CSQL += "		 AND SF1.D_E_L_E_T_ = ' '
				CSQL += "		 AND SA2.D_E_L_E_T_ = ' '
				If chkfile("_AUX")
					dbSelectArea("_AUX")
					dbCloseArea()
				EndIf
				TCQUERY CSQL ALIAS "_AUX" NEW

				If !_AUX->(Eof())

					ccQUERY := " UPDATE "+RetSqlName("SF1")+" SET F1_YIMPXML = 'S' WHERE R_E_C_N_O_ = '"+Alltrim(Str(_AUX->N_RECNO)) +"' "
					TCSQLEXEC(ccQUERY)

					CpyS2T( "\P10\XML_NFE\"+cEmpAnt+cFilAnt+"\RECEBIDOS\"+cArquivo , "\P10\XML_NFE\"+cEmpAnt+cFilAnt+"\IMPORTADOS\"+cArquivo)
					FERASE("\P10\NFE\"+CCC_EMP+"\"+CARQUIVO)
					Log_NfImportadas += 1

				Else

					AADD(LOG_NF_NAO , "NF - " + SUBSTRING(C_NOTA_FISCAL,4,6) + " - " + C_SERIE_NOTA + " - FORNECEDOR - " + C_NOME_FOR )

				EndIf

			EndIf

		EndIf

	Next

	A	:= 1

	MONTA_LOG()

Return

/*ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ MONTA_LOG        ณ MADALENO           บ DATA ณ  30/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ MONTA A TELA DO LOG                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/
STATIC FUNCTION MONTA_LOG()

	Local I
	PRIVATE A_ITENS := {}

	AADD(A_ITENS , "-------------------------------------------------------------------------------------------------------------------------------------")
	AADD(A_ITENS , "TOTAL XML IMPORTADOS")
	AADD(A_ITENS , ALLTRIM(STR(LOG_NFIMPORTADAS)) )
	AADD(A_ITENS , " ")

	AADD(A_ITENS , "-------------------------------------------------------------------------------------------------------------------------------------")
	AADD(A_ITENS , "NOTAS FISCAIS NรO ENCONTRADAS")
	FOR I := 1 TO LEN(LOG_NF_NAO)
		AADD(A_ITENS , LOG_NF_NAO[I] )
	next
	AADD(A_ITENS , " ")

	AADD(A_ITENS , "-------------------------------------------------------------------------------------------------------------------------------------")
	AADD(A_ITENS , "XML NรO RECONHECIDO")
	AADD(A_ITENS , ALLTRIM(STR(LOG_NFPROBLEMA)) )

	SetPrvt("oFont1","oDlg1","oSay1","oLBox1")
	oFont1     := TFont():New( "MS Sans Serif",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )
	oDlg1      := MSDialog():New( 095,232,720,647,"IMPORTAวรO XML",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 012,028,{||"IMPORTAวรO ARQUIVO XML"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,160,012)
	oLBox1     := TListBox():New( 036,004,,A_ITENS ,196,256,,oDlg1,,CLR_BLACK,CLR_WHITE,.T.,,,,"",,,,,,, )
	oDlg1:Activate(,,,.T.)

RETURN()

/*___________________________________________________________________________
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆFun็ใo    ฆ ValidPergฆ Autor ฆ Marcos Alberto S      ฆ Data ฆ 05/07/11 ฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs := {}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Informe a pasta   ?","","","mv_ch1","C",50,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
