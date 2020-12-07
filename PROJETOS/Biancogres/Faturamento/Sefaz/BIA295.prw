#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "fwcommand.ch"

User Function BIA295()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := Marcos Alberto Soprani
	Programa  := BIA295
	Empresa   := Biancogres Cerâmica S/A
	Data      := 08/05/12
	Uso       := Compras
	Aplicação := Importacao de XML nota fiscal de Entrada.
	.            Esta rotina foi preparada para ser executada a partir do pro-
	.            grama BIA290, por isso esta condição logo no início do programa
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	Local   _nx, _dy, _pf, _dn
	Private kkEmpr    := cEmpAnt
	Private kkFili    := cFilAnt
	If Upper(Alltrim(FunName())) $ "BIA295/BIA296"
		kkEmpr    := cEmpAnt
		kkFili    := cFilAnt
	Else
		kkEmpr    := ParamIXB
		kkFili    := "01"
	EndIf
	Private kkUsrImp  := __cUserID
	Private cPath 	 	:= "\P10\XML_NFE\" + kkEmpr+kkFili + "\RECEBIDOS\"
	Private cPathImp 	:= "\P10\XML_NFE\" + kkEmpr+kkFili + "\IMPORTADOS\"
	Private cPathCTe 	:= "\P10\XML_NFE\" + kkEmpr+kkFili + "\CTE\"
	Private cPathCan 	:= "\P10\XML_NFE\" + kkEmpr+kkFili + "\CANCELADOS\"
	Private cPathCorr	:= "\P10\XML_NFE\" + kkEmpr+kkFili + "\CARTACORRECAO\"
	Private _oXML     := NIL
	Private pMGetXML  := ""

	//(Carlos - 21/10/14) - Totvs Colaboração
	If kkEmpr == '14'
		Return
	EndIf

	ZaArqXML	:= directory(cPath+"\*.xml")
	For _nx := 1 to len(ZaArqXML)

		// ***************** Verifica se o arquivo é um XML **********************
		If U_BIA295A( cPath+ZaArqXML[_nx,1] )

			// ********** Monta um Vetor com os Dados do Arquivo XML ***************
			VtRetXML := U_BIA295B( ZaArqXML[_nx,1] )

			If ValType(VtRetXML) == "A" .and. Len(VtRetXML) > 0

				_xContinua  := .F.
				_cCodFor    := ""
				_cLojFor    := ""
				_cNomeFor   := ""
				_cEstFor    := ""
				_cTpNfisc   := ""

				If cEmpAnt == "14" .and. VtRetXML[1][4] == "02077546000176" .and. Substr(VtRetXML[2][1][12],2,3) == "901" // Incluído tratamento para Integração Biancogres vs Vitcer - Bene-
					//                                                                                                         ficiamento - por Marcos Alberto Soprani. 13/08/13
					****************************************************************************************************************************************************************************

					_cTpNfisc   := "B"
					SA1->(dbSetOrder(3))
					SA1->(dbGoTop())
					If SA1->(dbSeek(xFilial("SA1")+VtRetXML[1][4]))
						_xContinua := .T.
						While !SA1->(Eof()) .and. SA1->A1_FILIAL == xFilial("SA1") .and. SA1->A1_CGC == VtRetXML[1][4]
							If SA1->A1_MSBLQL <> "1" .and. !SA1->A1_COD $ "INVEST/999999"
								If VtRetXML[1][4] == "02077546000176"
									If SA1->A1_EST = "ES"
										_cCodFor	  := SA1->A1_COD
										_cLojFor	  := SA1->A1_LOJA
										_cNomeFor	  := SA1->A1_NOME
										_cEstFor      := SA1->A1_EST
									EndIf
								Else
									_cCodFor	  := SA1->A1_COD
									_cLojFor	  := SA1->A1_LOJA
									_cNomeFor	  := SA1->A1_NOME
									_cEstFor      := SA1->A1_EST
								EndIf
							EndIf
							SA1->(dbSkip())
						End
					EndIf

				Else

					_cTpNfisc   := "N"
					SA2->(dbSetOrder(3))
					SA2->(dbGoTop())
					If SA2->(dbSeek(xFilial("SA2")+VtRetXML[1][4]))
						_xContinua := .T.
						While !SA2->(Eof()) .and. SA2->A2_FILIAL == xFilial("SA2") .and. SA2->A2_CGC == VtRetXML[1][4]
							If SA2->A2_MSBLQL <> "1" .and. SA2->A2_COD <> "INVEST"
								_cCodFor	  := SA2->A2_COD
								_cLojFor	  := SA2->A2_LOJA
								_cNomeFor	  := SA2->A2_NOME
								_cEstFor      := SA2->A2_EST
							EndIf
							SA2->(dbSkip())
						End
					EndIf

				EndIf

				//(Carlos - 21/10/14)
				// Conforme solicitação do Carlos para projeto Totvs Colaboração
				//			If kkEmpr $ "01_05"
				If kkEmpr $ "05"

					cSqlCgc := GetSqlCGC(VtRetXML[1][4])
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlCgc),'_A2CGC',.F.,.T.)
					dbSelectArea('_A2CGC')
					dbGoTop()

					If _A2CGC->QTD > 0
						If Alltrim(VtRetXML[1][7]) <> "CTE" .And. VtRetXML[2][1][7] <> 0
							_xContinua := .F.
						EndIf
					EndIf

					_A2CGC->(dbCloseArea())

					//If VtRetXML[1][4] $ "28416873000107/86981966000172/73912859000140/31731169000145/39813886000128/39827605000196/04488116000172/86981966000253/10819893000155/05989044000100/27146828000109/06166794000225/05493741000175/08310365000124/17780072000100" //00364536000196
					//	If Alltrim(VtRetXML[1][7]) <> "CTE"
					//		If VtRetXML[2][1][7] <> 0
					//			_xContinua := .F.
					//		EndIf
					//	EndIf
					//EndIf
				EndIf

				If _xContinua
					_cNumeroNF  := StrZero(Val(VtRetXML[1][1]),9)
					_cSerieNF   := VtRetXML[1][2]
					_dEmissaoNF := VtRetXML[1][3]

					// Por Marcos Alberto Soprani em 19/04/16 em atendimento a OS effettivo 1585-16
					If Alltrim(UPPER(VtRetXML[1][7])) == "CTE" .or. !kkEmpr $ "01/05"

						// Identificado que às vezes alguns arquivos XML não possuiem a TAG de processamento da nota
						If !Empty(VtRetXML[1][6])
							VT001 := " SELECT COUNT(*) CONTAD
							VT001 += "   FROM " + RetSqlName("SDS")
							VT001 += "  WHERE DS_FILIAL = '"+xFilial("SDS")+"'
							VT001 += "    AND DS_CHAVENF = '"+VtRetXML[1][6]+"'
							VT001 += "    AND D_E_L_E_T_ = ' '
							VT001 := ChangeQuery(VT001)
							cIndex := CriaTrab(Nil,.f.)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,VT001),'VT01',.T.,.T.)
							dbSelectArea("VT01")
							dbGoTop()
							frContad := VT01->CONTAD
							Ferase(cIndex+OrdBagExt())
							VT01->(dbCloseArea())

							dbSelectArea("SDS")
							dbSetOrder(1)
							If !dbSeek( xFilial("SDS") + Padr(_cNumeroNF, TamSx3("DS_DOC")[1]) + Padr(_cSerieNF, TamSx3("DS_SERIE")[1]) + _cCodFor + _cLojFor ) .and. frContad == 0

								dxArqGrv := Padr(_cNumeroNF, TamSx3("DS_DOC")[1]) + Padr(_cSerieNF, TamSx3("DS_SERIE")[1]) + _cCodFor + _cLojFor + VtRetXML[1][4] +".xml"
								RecLock("SDS",.T.)
								SDS->DS_FILIAL  := xFilial("SDS")
								SDS->DS_DOC     := _cNumeroNF
								SDS->DS_SERIE   := _cSerieNF
								SDS->DS_FORNEC  := _cCodFor
								SDS->DS_LOJA    := _cLojFor
								SDS->DS_CNPJ    := VtRetXML[1][4]
								SDS->DS_TIPO    := _cTpNfisc
								SDS->DS_ESPECI  := VtRetXML[1][7]
								SDS->DS_EMISSA  := _dEmissaoNF
								SDS->DS_FORMUL  := "N"
								SDS->DS_EST     := _cEstFor
								SDS->DS_ARQUIVO := dxArqGrv
								SDS->DS_USERIMP := kkUsrImp
								SDS->DS_DATAIMP := dDataBase
								SDS->DS_HORAIMP := Substr(Time(),1,5)
								SDS->DS_CHAVENF := VtRetXML[1][6]
								SDS->DS_YSCHEMA := Alltrim(pMGetXML)
								MsUnLock()

								For _dy := 1 To Len(VtRetXML[2])

									dbSelectArea("SDT")
									dbSetOrder(1)
									RecLock("SDT",.T.)
									SDT->DT_FILIAL  := xFilial("SDS")
									SDT->DT_ITEM    := VtRetXML[2][_dy][11]
									SDT->DT_COD     := VtRetXML[2][_dy][2]
									SDT->DT_PRODFOR := VtRetXML[2][_dy][1]
									SDT->DT_DESCFOR := VtRetXML[2][_dy][3]
									SDT->DT_FORNEC  := _cCodFor
									SDT->DT_LOJA    := _cLojFor
									SDT->DT_DOC     := Padr(_cNumeroNF, TamSx3("DT_DOC")[1])
									SDT->DT_SERIE   := Padr(_cSerieNF, TamSx3("DT_SERIE")[1])
									SDT->DT_CNPJ    := VtRetXML[1][4]
									SDT->DT_QUANT   := VtRetXML[2][_dy][5]
									SDT->DT_VUNIT   := VtRetXML[2][_dy][6]
									SDT->DT_TOTAL   := VtRetXML[2][_dy][7]
									SDT->DT_PEDIDO  := VtRetXML[2][_dy][9]
									SDT->DT_ITEMPC  := ""
									SDT->DT_YUNID   := VtRetXML[2][_dy][10]
									SDT->DT_YCFOP   := VtRetXML[2][_dy][12]
									MsUnLock()

								Next _dy

								dt_cFile := cPath + ZaArqXML[_nx,1]
								xt_cFil1 := cPathImp + dxArqGrv
								fRename(dt_cFile, xt_cFil1)

							Else

								dt_cFile := cPath + ZaArqXML[_nx,1]
								fErase(dt_cFile)

							EndIf

						EndIf

					Else

						dt_cFile := cPath + ZaArqXML[_nx,1]
						fErase(dt_cFile)

					EndIf

				EndIf

			EndIf

		Else

			dt_cFile := cPath + ZaArqXML[_nx,1]
			fErase(dt_cFile)

		EndIf

	Next _nx

	ZaArqPdf	:= directory(cPath+"\*.pdf")
	For _pf := 1 to len(ZaArqPdf)
		dt_cFile := cPath + ZaArqPdf[_pf,1]
		fErase(dt_cFile)
	Next _pf

	ZaArqPdf	:= directory(cPath+"\*.txt")
	For _pf := 1 to len(ZaArqPdf)
		dt_cFile := cPath + ZaArqPdf[_pf,1]
		fErase(dt_cFile)
	Next _pf

	// Retirado em 13/01/14 por Marcos Alberto Soprani porque identificamos que esta extensão está relacionada a nota fiscal eletronica
	//ZaArqPdf	:= directory(cPath+"\*.dnf")
	//For _pf := 1 to len(ZaArqPdf)
	//	dt_cFile := cPath + ZaArqPdf[_pf,1]
	//	fErase(dt_cFile)
	//Next _pf

	ZaArqPdf	:= directory(cPath+"\*.gif")
	For _pf := 1 to len(ZaArqPdf)
		dt_cFile := cPath + ZaArqPdf[_pf,1]
		fErase(dt_cFile)
	Next _pf

	ZaArqPdf	:= directory(cPath+"\*.jpe")
	For _pf := 1 to len(ZaArqPdf)
		dt_cFile := cPath + ZaArqPdf[_pf,1]
		fErase(dt_cFile)
	Next _pf

	ZaArqPdf	:= directory(cPath+"\*.jpg")
	For _pf := 1 to len(ZaArqPdf)
		dt_cFile := cPath + ZaArqPdf[_pf,1]
		fErase(dt_cFile)
	Next _pf

	ZaArqPdf	:= directory(cPath+"\*.png")
	For _pf := 1 to len(ZaArqPdf)
		dt_cFile := cPath + ZaArqPdf[_pf,1]
		fErase(dt_cFile)
	Next _pf

	ZaArqPdf	:= directory(cPath+"\*.vcf")
	For _pf := 1 to len(ZaArqPdf)
		dt_cFile := cPath + ZaArqPdf[_pf,1]
		fErase(dt_cFile)
	Next _pf

	ZaArqPdf	:= directory(cPath+"\*.html")
	For _pf := 1 to len(ZaArqPdf)
		dt_cFile := cPath + ZaArqPdf[_pf,1]
		fErase(dt_cFile)
	Next _pf

	ZaArqPdf	:= directory(cPath+"\*.htm")
	For _pf := 1 to len(ZaArqPdf)
		dt_cFile := cPath + ZaArqPdf[_pf,1]
		fErase(dt_cFile)
	Next _pf

	ZaArqPdf	:= directory(cPath+"\*.xls")
	For _pf := 1 to len(ZaArqPdf)
		dt_cFile := cPath + ZaArqPdf[_pf,1]
		fErase(dt_cFile)
	Next _pf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA295A   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Valida Arquivo XML                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA295A(_cFile)

	Local  cError   := ""
	Local  cWarning := ""
	Local  cvRetOk  := .T.
	Default _oXML   := NIL

	_oXML := XmlParserFile(_cFile, "_", @cError, @cWarning )
	If ValType(_oXML) != "O"
		cvRetOk  := .F.
	Else
		SAVE _oXML XMLSTRING pMGetXML
	Endif

Return( cvRetOk )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA295B   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Retorna Vetor MULTIDIMENSIONAL com os dados completos da NF¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA295B(_cFile)

	Local aRet := {}
	Local aCab
	LocAL aProd

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

	aCab := {}

	If Type("_oXML:_CTeProc:_CTe:_InfCTe") <> "U"           // Copia os arquivos de CTe para uma pasta específica

		// Tramento feito para evitar que o arquivo XML fique perdido entre as pastas das empresas do grupo
		If Type("_oXML:_CTePROC:_CTe:_INFCTe:_REM:_CNPJ:TEXT") <> "U" .or. Type("_oXML:_CTePROC:_CTe:_INFCTe:_DEST:_CNPJ:TEXT") <> "U"

			If _oXML:_CTePROC:_CTe:_INFCTe:_REM:_CNPJ:TEXT == SM0->M0_CGC

				__NUMNF 	  	:= PADL(Alltrim(_oXML:_CTePROC:_CTe:_INFCTe:_IDE:_NCt:TEXT),6,"0")             // Nro da Nota
				__SERNF 	  	:= PADR(_oXML:_CTeProc:_CTe:_InfCTe:_IDE:_Serie:Text,3," ")                    // Serie da Nota
				__CEMISSAO 		:= _oXML:_CTePROC:_CTe:_INFCTe:_IDE:_dhEmi:Text                                // Emissao
				__DEMISSAO 		:= stod(Substr(__CEMISSAO,1,4)+Substr(__CEMISSAO,6,2)+Substr(__CEMISSAO,9,2))  // Emissao
				__CNPJ_FOR 		:= _oXML:_CTePROC:_CTe:_INFCTe:_EMIT:_CNPJ:TEXT
				__XPED	      := Space(TamSx3("C7_NUM")[1])
				__CHAVECTe    := ""
				If Type("_oXML:_CTePROC:_PROTCTe:_INFPROT:_CHCTe") <> "U"
					__CHAVECTe  := AllTrim(_oXML:_CTePROC:_PROTCTe:_INFPROT:_CHCTe:TEXT)
				EndIf

				AADD(aCab, __NUMNF)
				AADD(aCab, __SERNF)
				AADD(aCab, __DEMISSAO)
				AADD(aCab, __CNPJ_FOR)
				AADD(aCab, __XPED)
				AADD(aCab, __CHAVECTe)
				AADD(aCab, "CTE")

				AADD(aRet,aCab)

				aProd := {}
				AADD(aRet,aProd)

			Else

				If Type("_oXML:_CTePROC:_CTe:_INFCTe:_DEST:_CNPJ:TEXT") <> "U"

					If _oXML:_CTePROC:_CTe:_INFCTe:_DEST:_CNPJ:TEXT == SM0->M0_CGC

						__NUMNF 	  	:= PADL(Alltrim(_oXML:_CTePROC:_CTe:_INFCTe:_IDE:_NCt:TEXT),6,"0")             // Nro da Nota
						__SERNF 	  	:= PADR(_oXML:_CTeProc:_CTe:_InfCTe:_IDE:_Serie:Text,3," ")                    // Serie da Nota
						__CEMISSAO 		:= _oXML:_CTePROC:_CTe:_INFCTe:_IDE:_dhEmi:Text                                // Emissao
						__DEMISSAO 		:= stod(Substr(__CEMISSAO,1,4)+Substr(__CEMISSAO,6,2)+Substr(__CEMISSAO,9,2))  // Emissao
						__CNPJ_FOR 		:= _oXML:_CTePROC:_CTe:_INFCTe:_EMIT:_CNPJ:TEXT
						__XPED	      := Space(TamSx3("C7_NUM")[1])
						__CHAVECTe    := ""
						If Type("_oXML:_CTePROC:_PROTCTe:_INFPROT:_CHCTe") <> "U"
							__CHAVECTe  := AllTrim(_oXML:_CTePROC:_PROTCTe:_INFPROT:_CHCTe:TEXT)
						EndIf

						AADD(aCab, __NUMNF)
						AADD(aCab, __SERNF)
						AADD(aCab, __DEMISSAO)
						AADD(aCab, __CNPJ_FOR)
						AADD(aCab, __XPED)
						AADD(aCab, __CHAVECTe)
						AADD(aCab, "CTE")

						AADD(aRet,aCab)

						aProd := {}
						AADD(aRet,aProd)

					Else

						If fBscEmpr( _oXML:_CTePROC:_CTe:_INFCTe:_DEST:_CNPJ:TEXT, _cFile, .F. )
							dt_cFile := cPath + _cFile
							fErase(dt_cFile)
						Else
							fBscEmpr( _oXML:_CTePROC:_CTe:_INFCTe:_REM:_CNPJ:TEXT, _cFile, .T. )
						EndIf

					EndIf

				EndIf

			EndIf

		Else

			dt_cFile := cPath + _cFile
			fErase(dt_cFile)

		EndIf

	ElseIf Type("_oXML:_EnvICte:_CTe:_InfCTe") <> "U"	      // Copia os arquivos de CTe para uma pasta específica

		// Tramento feito para evitar que o arquivo XML fique perdido entre as pastas das empresas do grupo
		If Type("_oXML:_EnvICte:_CTe:_INFCTe:_REM:_CNPJ:TEXT") <> "U" .or. Type("_oXML:_EnvICte:_CTe:_INFCTe:_DEST:_CNPJ:TEXT") <> "U"

			If _oXML:_EnvICte:_CTe:_INFCTe:_REM:_CNPJ:TEXT == SM0->M0_CGC

				__NUMNF 	  	:= PADL(Alltrim(_oXML:_EnvICte:_CTe:_INFCTe:_IDE:_NCt:TEXT),6,"0")             // Nro da Nota
				__SERNF 	  	:= PADR(_oXML:_EnvICte:_CTe:_InfCTe:_IDE:_Serie:Text,3," ")                    // Serie da Nota
				__CEMISSAO 		:= _oXML:_EnvICte:_CTe:_INFCTe:_IDE:_dhEmi:Text                                // Emissao
				__DEMISSAO 		:= stod(Substr(__CEMISSAO,1,4)+Substr(__CEMISSAO,6,2)+Substr(__CEMISSAO,9,2))  // Emissao
				__CNPJ_FOR 		:= _oXML:_EnvICte:_CTe:_INFCTe:_EMIT:_CNPJ:TEXT
				__XPED	      := Space(TamSx3("C7_NUM")[1])
				__CHAVECTe    := ""
				If Type("_oXML:_EnvICte:_PROTCTe:_INFPROT:_CHCTe") <> "U"
					__CHAVECTe  := AllTrim(_oXML:_EnvICte:_PROTCTe:_INFPROT:_CHCTe:TEXT)
				Else
					If Type("_oXML:_EnvICte:_CTe:_INFCTe:_ID:TEXT") <> "U"
						__CHAVECTe  := Substr(_oXML:_EnvICte:_CTe:_INFCTe:_ID:TEXT,4,44)
					EndIf
				EndIf

				AADD(aCab, __NUMNF)
				AADD(aCab, __SERNF)
				AADD(aCab, __DEMISSAO)
				AADD(aCab, __CNPJ_FOR)
				AADD(aCab, __XPED)
				AADD(aCab, __CHAVECTe)
				AADD(aCab, "CTE")

				AADD(aRet,aCab)

				aProd := {}
				AADD(aRet,aProd)

			Else

				If Type("_oXML:_EnvICte:_CTe:_INFCTe:_DEST:_CNPJ:TEXT") <> "U"

					If _oXML:_EnvICte:_CTe:_INFCTe:_DEST:_CNPJ:TEXT == SM0->M0_CGC

						__NUMNF 	  	:= PADL(Alltrim(_oXML:_EnvICte:_CTe:_INFCTe:_IDE:_NCt:TEXT),6,"0")             // Nro da Nota
						__SERNF 	  	:= PADR(_oXML:_EnvICte:_CTe:_InfCTe:_IDE:_Serie:Text,3," ")                    // Serie da Nota
						__CEMISSAO 		:= _oXML:_EnvICte:_CTe:_INFCTe:_IDE:_dhEmi:Text                                // Emissao
						__DEMISSAO 		:= stod(Substr(__CEMISSAO,1,4)+Substr(__CEMISSAO,6,2)+Substr(__CEMISSAO,9,2))  // Emissao
						__CNPJ_FOR 		:= _oXML:_EnvICte:_CTe:_INFCTe:_EMIT:_CNPJ:TEXT
						__XPED	      := Space(TamSx3("C7_NUM")[1])
						__CHAVECTe    := ""
						If Type("_oXML:_EnvICte:_PROTCTe:_INFPROT:_CHCTe") <> "U"
							__CHAVECTe  := AllTrim(_oXML:_EnvICte:_PROTCTe:_INFPROT:_CHCTe:TEXT)
						Else
							If Type("_oXML:_EnvICte:_CTe:_INFCTe:_ID:TEXT") <> "U"
								__CHAVECTe  := Substr(_oXML:_EnvICte:_CTe:_INFCTe:_ID:TEXT,4,44)
							EndIf
						EndIf

						AADD(aCab, __NUMNF)
						AADD(aCab, __SERNF)
						AADD(aCab, __DEMISSAO)
						AADD(aCab, __CNPJ_FOR)
						AADD(aCab, __XPED)
						AADD(aCab, __CHAVECTe)
						AADD(aCab, "CTE")

						AADD(aRet,aCab)

						aProd := {}
						AADD(aRet,aProd)

					Else

						If fBscEmpr( _oXML:_EnvICte:_CTe:_INFCTe:_DEST:_CNPJ:TEXT, _cFile, .F. )
							dt_cFile := cPath + _cFile
							fErase(dt_cFile)
						Else
							fBscEmpr( _oXML:_EnvICte:_CTe:_INFCTe:_REM:_CNPJ:TEXT, _cFile, .T. )
						EndIf

					EndIf

				EndIf

			EndIf

		Else

			dt_cFile := cPath + _cFile
			fErase(dt_cFile)

		EndIf

	ElseIf Type("_oXML:_RETCONSRECINFE") <> "U"             // Deletar porque não identificamos a funcionalidade deste XML

		dt_cFile := cPath + _cFile
		fErase(dt_cFile)

	ElseIf Type("_oXML:_PROTNFE:_INFPROT") <> "U"           // Deletar porque não identificamos a funcionalidade deste XML - Aparentemente VAZIO

		dt_cFile := cPath + _cFile
		fErase(dt_cFile)

	ElseIf Type("_oXML:_RETCANCNFE") <> "U" .or. Type("_oXML:_CANCNFE") <> "U" .or. Type("_oXML:_PROTNFE:_INFCANC") <> "U" .or. Type("_oXML:_PROCCANCNFE:_CANCNFE") <> "U"     // Canceladas

		htChqChave := .F.
		If Type("_oXML:_PROCCANCNFE:_RETCANCNFE:_INFCANC:_CHNFE:TEXT") <> "U"
			dt_ChaveNf := _oXML:_PROCCANCNFE:_RETCANCNFE:_INFCANC:_CHNFE:TEXT
			RY001 := " UPDATE " + RetSqlName("SDS")
			RY001 += "    SET DS_STATUS = 'P'
			RY001 += "  WHERE DS_FILIAL = '"+xFilial("SDS")+"'
			RY001 += "    AND DS_CHAVENF = '"+dt_ChaveNf+"'
			RY001 += "    AND D_E_L_E_T_ = ' '
			TCSQLExec(RY001)
			htChqChave := .T.
		EndIf
		If htChqChave
			dt_cFile := cPath + _cFile
			xt_cFil1 := cPathCan + _cFile
			If File(xt_cFil1)
				fErase(dt_cFile)
			Else
				fRename(dt_cFile, xt_cFil1)
			EndIf
		EndIf

	ElseIf Type("_oXML:_PROCEVENTONFE") <> "U"              // Carta de Correção

		dt_cFile := cPath + _cFile
		xt_cFil1 := cPathCorr + _cFile
		If File(xt_cFil1)
			fErase(dt_cFile)
		Else
			fRename(dt_cFile, xt_cFil1)
		EndIf

	ElseIf Type("_oXML:_NfeProc:_Nfe:_InfNfe") <> "U"   	  // Com Tag - NfeProc

		// Tramento feito para evitar que o arquivo XML fique perdido entre as pastas das empresas do grupo
		If Type("_oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT") <> "U"

			If _oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT == SM0->M0_CGC

				__NUMNF 	  	:= PADL(Alltrim(_oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT),6,"0")             // Nro da Nota
				__SERNF 	  	:= PADR(_oXML:_NfeProc:_Nfe:_InfNfe:_IDE:_Serie:Text,3," ")                    // Serie da Nota
				If Type("_oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dEmi:Text") <> "U"
					__CEMISSAO 		:= _oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dEmi:Text                            // Emissao
				Else
					__CEMISSAO 		:= _oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dhEmi:Text                             // Emissao
				EndIf
				__DEMISSAO 		:= stod(Substr(__CEMISSAO,1,4)+Substr(__CEMISSAO,6,2)+Substr(__CEMISSAO,9,2))  // Emissao
				__CNPJ_FOR 		:= _oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
				__XPED	      := Space(TamSx3("C7_NUM")[1])
				If Type("_oXML:_NFEPROC:_NFE:_INFNFE:_COMPRA:_XPED") <> "U"
					__XPED		  := AllTrim(_oXML:_NFEPROC:_NFE:_INFNFE:_COMPRA:_XPED)
				EndIf
				__CHAVENFE    := ""
				If Type("_oXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE") <> "U"
					__CHAVENFE  := AllTrim(_oXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT)
				EndIf
				// Implementado em 07/03/13 por Marcos Alberto Soprani
				If Type("_oXML:_NFEPROC:_INFPROT:_CHNFE") <> "U"
					__CHAVENFE  := AllTrim(_oXML:_NFEPROC:_INFPROT:_CHNFE:TEXT)
				EndIf

				AADD(aCab, __NUMNF)
				AADD(aCab, __SERNF)
				AADD(aCab, __DEMISSAO)
				AADD(aCab, __CNPJ_FOR)
				AADD(aCab, __XPED)
				AADD(aCab, __CHAVENFE)
				AADD(aCab, "SPED")

				AADD(aRet,aCab)

				// Verifição de Dados do Fornecedor
				If (Type("_oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ") <> "U" )
					__CNPJ_FOR := _oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
				ElseIf (Type("_oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF") <> "U" )
					__CNPJ_FOR := _oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF:TEXT
				EndIf
				cFornec   := ""
				cLjFornec := ""
				SA2->(dbSetOrder(3))
				SA2->(dbSeek(xFilial("SA2")+__CNPJ_FOR))
				While !SA2->(Eof()) .and. SA2->A2_FILIAL == xFilial("SA2") .and. SA2->A2_CGC == __CNPJ_FOR
					If SA2->A2_MSBLQL <> "1" .and. SA2->A2_COD <> "INVEST"
						cFornec   := SA2->A2_COD
						cLjFornec := SA2->A2_LOJA
					EndIf
					SA2->(dbSkip())
				End

				// Leitura/Preebchimento dos dados dos Itens da NF
				If ValType(_oXML:_NfeProc:_Nfe:_InfNfe:_DET) = "O"
					XmlNode2Arr(_oXML:_NfeProc:_Nfe:_InfNfe:_DET, "_DET")
				EndIf
				nNumItens  	:= Len(_oXML:_NfeProc:_Nfe:_InfNfe:_DET)
				nTotalMerc 	:= Val(_oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text)
				nDescNota  	:= val(_oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:Text)
				nValor	 		:= Val(_oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:Text)
				nIcmsSubs		:= Val(_oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:Text)

				aProd := {}
				For nCont := 1 to nNumItens

					cCodForn	:= AllTrim(_oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_CPROD:Text)
					cDescForn	:= AllTrim(_oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPROD:Text)
					nQuant		:= Val(_oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_QCOM:Text)
					cUnidad		:= Upper(AllTrim(_oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_UCOM:Text))
					nPrcUnLiq	:= Val(_oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VUNCOM:Text)
					nPrcTtLiq	:= Val(_oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VPROD:Text)
					xz_Unid     := Alltrim(_oXML:_NFEPROC:_NFE:_INFNFE:_DET[1]:_PROD:_UCOM:TEXT)
					xz_ItXml    := StrZero(Val(_oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_NITEM:TEXT), TamSx3("DT_ITEM")[1])
					xz_CFOP     := _oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_PROD:_CFOP:TEXT

					nValDesc	:= 0
					If XmlChildEx(_oXML:_NfeProc:_Nfe:_InfNfe:_DET[nCont]:_PROD, "_VDESC")!= Nil
						nValDesc	:= Val(_oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VDESC:Text)
					EndIf

					cPedItem	:= Space(TamSx3("C7_NUM")[1])
					If Type("_oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPED") <> "U"
						cPedItem	:= Upper(AllTrim(_oXML:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPED:Text))
					EndIf

					// Amarração Produto Fornecedor
					__lFindPrd := .F.
					SA5->(dbSetOrder(5))
					If SA5->(dbSeek(xFilial("SA5")+Padr(cCodForn,TamSx3("A5_CODPRF")[1])))
						While AllTrim(SA5->A5_CODPRF) == AllTrim(cCodForn)
							If SA5->(A5_FORNECE+A5_LOJA) == cFornec+cLjFornec
								cCodigo := SA5->A5_PRODUTO
								__lFindPrd := .T.
								Exit
							Endif
							SA5->(dBSkip())
						End
					EndIf
					If !__lFindPrd
						cCodigo := Space(TamSx3("B1_COD")[1])
					EndIf

					AAUX := {}
					AAdd(AAUX, cCodForn)

					// Posiciona no produto encontrado
					If cCodigo <> Nil .And. !Empty(cCodigo)
						AAdd(AAUX, cCodigo)
					Else
						AAdd(AAUX, Space(TamSx3("B1_COD")[1]))
					EndIf

					AAdd(AAUX, cDescForn)
					AAdd(AAUX, cUnidad)
					AAdd(AAUX, nQuant)
					AAdd(AAUX, nPrcUnLiq)
					AAdd(AAUX, nPrcTtLiq)
					AAdd(AAUX, nValDesc)
					AAdd(AAUX, cPedItem)
					AAdd(AAUX, xz_Unid)
					AAdd(AAUX, xz_ItXml)
					AAdd(AAUX, xz_CFOP)

					AAdd(aProd,AAUX)

				Next nCont

				AADD(aRet,aProd)

			Else

				fBscEmpr( _oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT, _cFile, .T. )

			EndIf

		Else

			dt_cFile := cPath + _cFile
			fErase(dt_cFile)

		EndIf

	ElseIf Type("_oXML:_NfeProc:_NfeProc:_Nfe:_InfNfe") <> "U"   	  // Com Tag - NfeProc/NFEPROC

		// Tramento feito para evitar que o arquivo XML fique perdido entre as pastas das empresas do grupo
		If Type("_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DEST:_CNPJ:TEXT") <> "U"

			If _oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DEST:_CNPJ:TEXT == SM0->M0_CGC

				__NUMNF 	  	:= PADL(Alltrim(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_IDE:_NNF:TEXT),6,"0")             // Nro da Nota
				__SERNF 	  	:= PADR(_oXML:_NfeProc:_NfeProc:_Nfe:_InfNfe:_IDE:_Serie:Text,3," ")                    // Serie da Nota
				__CEMISSAO 		:= _oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_IDE:_dEmi:Text                                 // Emissao
				__DEMISSAO 		:= stod(Substr(__CEMISSAO,1,4)+Substr(__CEMISSAO,6,2)+Substr(__CEMISSAO,9,2))  // Emissao
				__CNPJ_FOR 		:= _oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
				__XPED	      := Space(TamSx3("C7_NUM")[1])
				If Type("_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_COMPRA:_XPED") <> "U"
					__XPED		  := AllTrim(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_COMPRA:_XPED)
				EndIf
				__CHAVENFE    := ""
				If Type("_oXML:_NfeProc:_NfeProc:_PROTNFE:_INFPROT:_CHNFE") <> "U"
					__CHAVENFE  := AllTrim(_oXML:_NfeProc:_NfeProc:_PROTNFE:_INFPROT:_CHNFE:TEXT)
				EndIf

				AADD(aCab, __NUMNF)
				AADD(aCab, __SERNF)
				AADD(aCab, __DEMISSAO)
				AADD(aCab, __CNPJ_FOR)
				AADD(aCab, __XPED)
				AADD(aCab, __CHAVENFE)
				AADD(aCab, "SPED")

				AADD(aRet,aCab)

				// Verifição de Dados do Fornecedor
				If (Type("_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_EMIT:_CNPJ") <> "U" )
					__CNPJ_FOR := _oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
				ElseIf (Type("_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_EMIT:_CPF") <> "U" )
					__CNPJ_FOR := _oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_EMIT:_CPF:TEXT
				EndIf
				cFornec   := ""
				cLjFornec := ""
				SA2->(dbSetOrder(3))
				SA2->(dbSeek(xFilial("SA2")+__CNPJ_FOR))
				While !SA2->(Eof()) .and. SA2->A2_FILIAL == xFilial("SA2") .and. SA2->A2_CGC == __CNPJ_FOR
					If SA2->A2_MSBLQL <> "1" .and. SA2->A2_COD <> "INVEST"
						cFornec   := SA2->A2_COD
						cLjFornec := SA2->A2_LOJA
					EndIf
					SA2->(dbSkip())
				End

				// Leitura/Preebchimento dos dados dos Itens da NF
				If ValType(_oXML:_NfeProc:_NfeProc:_Nfe:_InfNfe:_DET) = "O"
					XmlNode2Arr(_oXML:_NfeProc:_NfeProc:_Nfe:_InfNfe:_DET, "_DET")
				EndIf
				nNumItens  	:= Len(_oXML:_NfeProc:_NfeProc:_Nfe:_InfNfe:_DET)
				nTotalMerc 	:= Val(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text)
				nDescNota  	:= val(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:Text)
				nValor	 		:= Val(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:Text)
				nIcmsSubs		:= Val(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:Text)

				aProd := {}
				For nCont := 1 to nNumItens

					cCodForn	:= AllTrim(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_Prod:_CPROD:Text)
					cDescForn	:= AllTrim(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPROD:Text)
					nQuant		:= Val(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_Prod:_QCOM:Text)
					cUnidad		:= Upper(AllTrim(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_Prod:_UCOM:Text))
					nPrcUnLiq	:= Val(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_Prod:_VUNCOM:Text)
					nPrcTtLiq	:= Val(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_Prod:_VPROD:Text)
					xz_Unid     := Alltrim(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[1]:_PROD:_UCOM:TEXT)
					xz_ItXml    := StrZero(Val(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_NITEM:TEXT), TamSx3("DT_ITEM")[1])
					xz_CFOP     := _oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_PROD:_CFOP:TEXT

					nValDesc	:= 0
					If XmlChildEx(_oXML:_NfeProc:_NfeProc:_Nfe:_InfNfe:_DET[nCont]:_PROD, "_VDESC")!= Nil
						nValDesc	:= Val(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_Prod:_VDESC:Text)
					EndIf

					cPedItem	:= Space(TamSx3("C7_NUM")[1])
					If Type("_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPED") <> "U"
						cPedItem	:= Upper(AllTrim(_oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPED:Text))
					EndIf

					// Amarração Produto Fornecedor
					__lFindPrd := .F.
					SA5->(dbSetOrder(5))
					If SA5->(dbSeek(xFilial("SA5")+Padr(cCodForn,TamSx3("A5_CODPRF")[1])))
						While AllTrim(SA5->A5_CODPRF) == AllTrim(cCodForn)
							If SA5->(A5_FORNECE+A5_LOJA) == cFornec+cLjFornec
								cCodigo := SA5->A5_PRODUTO
								__lFindPrd := .T.
								Exit
							Endif
							SA5->(dBSkip())
						End
					EndIf
					If !__lFindPrd
						cCodigo := Space(TamSx3("B1_COD")[1])
					EndIf

					AAUX := {}
					AAdd(AAUX, cCodForn)

					// Posiciona no produto encontrado
					If cCodigo <> Nil .And. !Empty(cCodigo)
						AAdd(AAUX, cCodigo)
					Else
						AAdd(AAUX, Space(TamSx3("B1_COD")[1]))
					EndIf

					AAdd(AAUX, cDescForn)
					AAdd(AAUX, cUnidad)
					AAdd(AAUX, nQuant)
					AAdd(AAUX, nPrcUnLiq)
					AAdd(AAUX, nPrcTtLiq)
					AAdd(AAUX, nValDesc)
					AAdd(AAUX, cPedItem)
					AAdd(AAUX, xz_Unid)
					AAdd(AAUX, xz_ItXml)
					AAdd(AAUX, xz_CFOP)

					AAdd(aProd,AAUX)

				Next nCont

				AADD(aRet,aProd)

			Else

				fBscEmpr( _oXML:_NfeProc:_NfeProc:_NFE:_INFNFE:_DEST:_CNPJ:TEXT, _cFile, .T. )

			EndIf

		Else

			dt_cFile := cPath + _cFile
			fErase(dt_cFile)

		EndIf

	ElseIf Type("_oXML:_ENVINFE:_Nfe:_InfNfe") <> "U"   	// Com Tag - _ENVINFE

		// Tramento feito para evitar que o arquivo XML fique perdido entre as pastas das empresas do grupo
		If Type("_oXML:_ENVINFE:_NFE:_INFNFE:_DEST:_CNPJ:TEXT") <> "U"

			If _oXML:_ENVINFE:_NFE:_INFNFE:_DEST:_CNPJ:TEXT == SM0->M0_CGC

				__NUMNF 	  	:= PADL(Alltrim(_oXML:_ENVINFE:_NFE:_INFNFE:_IDE:_NNF:TEXT),6,"0")             // Nro da Nota
				__SERNF 	  	:= PADR(_oXML:_ENVINFE:_Nfe:_InfNfe:_IDE:_Serie:Text,3," ")                    // Serie da Nota
				__CEMISSAO 		:= _oXML:_ENVINFE:_NFE:_INFNFE:_IDE:_dEmi:Text                                 // Emissao
				__DEMISSAO 		:= stod(Substr(__CEMISSAO,1,4)+Substr(__CEMISSAO,6,2)+Substr(__CEMISSAO,9,2))  // Emissao
				__CNPJ_FOR 		:= _oXML:_ENVINFE:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
				__XPED	      := Space(TamSx3("C7_NUM")[1])
				If Type("_oXML:_ENVINFE:_NFE:_INFNFE:_COMPRA:_XPED") <> "U"
					__XPED		  := AllTrim(_oXML:_ENVINFE:_NFE:_INFNFE:_COMPRA:_XPED)
				EndIf
				__CHAVENFE    := ""
				If Type("_oXML:_ENVINFE:_PROTNFE:_INFPROT:_CHNFE") <> "U"
					__CHAVENFE  := AllTrim(_oXML:_ENVINFE:_PROTNFE:_INFPROT:_CHNFE:TEXT)
				Else
					If Type("_oXML:_ENVINFE:_NFE:_INFNFE:_ID:TEXT") <> "U"
						__CHAVENFE  := Substr(_oXML:_ENVINFE:_NFE:_INFNFE:_ID:TEXT,4,44)
					EndIf
				EndIf

				AADD(aCab, __NUMNF)
				AADD(aCab, __SERNF)
				AADD(aCab, __DEMISSAO)
				AADD(aCab, __CNPJ_FOR)
				AADD(aCab, __XPED)
				AADD(aCab, __CHAVENFE)
				AADD(aCab, "SPED")

				AADD(aRet,aCab)

				// Verifição de Dados do Fornecedor
				If (Type("_oXML:_ENVINFE:_NFE:_INFNFE:_EMIT:_CNPJ") <> "U" )
					__CNPJ_FOR := _oXML:_ENVINFE:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
				ElseIf (Type("_oXML:_ENVINFE:_NFE:_INFNFE:_EMIT:_CPF") <> "U" )
					__CNPJ_FOR := _oXML:_ENVINFE:_NFE:_INFNFE:_EMIT:_CPF:TEXT
				EndIf
				cFornec   := ""
				cLjFornec := ""
				SA2->(dbSetOrder(3))
				SA2->(dbSeek(xFilial("SA2")+__CNPJ_FOR))
				While !SA2->(Eof()) .and. SA2->A2_FILIAL == xFilial("SA2") .and. SA2->A2_CGC == __CNPJ_FOR
					If SA2->A2_MSBLQL <> "1" .and. SA2->A2_COD <> "INVEST"
						cFornec   := SA2->A2_COD
						cLjFornec := SA2->A2_LOJA
					EndIf
					SA2->(dbSkip())
				End

				// Leitura/Preebchimento dos dados dos Itens da NF
				If ValType(_oXML:_ENVINFE:_Nfe:_InfNfe:_DET) = "O"
					XmlNode2Arr(_oXML:_ENVINFE:_Nfe:_InfNfe:_DET, "_DET")
				EndIf
				nNumItens  	:= Len(_oXML:_ENVINFE:_Nfe:_InfNfe:_DET)
				nTotalMerc 	:= Val(_oXML:_ENVINFE:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text)
				nDescNota  	:= val(_oXML:_ENVINFE:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:Text)
				nValor	 		:= Val(_oXML:_ENVINFE:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:Text)
				nIcmsSubs		:= Val(_oXML:_ENVINFE:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:Text)

				aProd := {}
				For nCont := 1 to nNumItens

					cCodForn	:= AllTrim(_oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_Prod:_CPROD:Text)
					cDescForn	:= AllTrim(_oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPROD:Text)
					nQuant		:= Val(_oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_Prod:_QCOM:Text)
					cUnidad		:= Upper(AllTrim(_oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_Prod:_UCOM:Text))
					nPrcUnLiq	:= Val(_oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_Prod:_VUNCOM:Text)
					nPrcTtLiq	:= Val(_oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_Prod:_VPROD:Text)
					xz_Unid     := Alltrim(_oXML:_ENVINFE:_NFE:_INFNFE:_DET[1]:_PROD:_UCOM:TEXT)
					xz_ItXml    := StrZero(Val(_oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_NITEM:TEXT), TamSx3("DT_ITEM")[1])
					xz_CFOP     := _oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_PROD:_CFOP:TEXT

					nValDesc	:= 0
					If XmlChildEx(_oXML:_ENVINFE:_Nfe:_InfNfe:_DET[nCont]:_PROD, "_VDESC")!= Nil
						nValDesc	:= Val(_oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_Prod:_VDESC:Text)
					EndIf

					cPedItem	:= Space(TamSx3("C7_NUM")[1])
					If Type("_oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPED") <> "U"
						cPedItem	:= Upper(AllTrim(_oXML:_ENVINFE:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPED:Text))
					EndIf

					// Amarração Produto Fornecedor
					__lFindPrd := .F.
					SA5->(dbSetOrder(5))
					If SA5->(dbSeek(xFilial("SA5")+Padr(cCodForn,TamSx3("A5_CODPRF")[1])))
						While AllTrim(SA5->A5_CODPRF) == AllTrim(cCodForn)
							If SA5->(A5_FORNECE+A5_LOJA) == cFornec+cLjFornec
								cCodigo := SA5->A5_PRODUTO
								__lFindPrd := .T.
								Exit
							Endif
							SA5->(dBSkip())
						End
					EndIf
					If !__lFindPrd
						cCodigo := Space(TamSx3("B1_COD")[1])
					EndIf

					AAUX := {}
					AAdd(AAUX, cCodForn)

					// Posiciona no produto encontrado
					If cCodigo <> Nil .And. !Empty(cCodigo)
						AAdd(AAUX, cCodigo)
					Else
						AAdd(AAUX, Space(TamSx3("B1_COD")[1]))
					EndIf

					AAdd(AAUX, cDescForn)
					AAdd(AAUX, cUnidad)
					AAdd(AAUX, nQuant)
					AAdd(AAUX, nPrcUnLiq)
					AAdd(AAUX, nPrcTtLiq)
					AAdd(AAUX, nValDesc)
					AAdd(AAUX, cPedItem)
					AAdd(AAUX, xz_Unid)
					AAdd(AAUX, xz_ItXml)
					AAdd(AAUX, xz_CFOP)

					AAdd(aProd,AAUX)

				Next nCont

				AADD(aRet,aProd)

			Else

				fBscEmpr( _oXML:_ENVINFE:_NFE:_INFNFE:_DEST:_CNPJ:TEXT, _cFile, .T. )

			EndIf

		Else

			dt_cFile := cPath + _cFile
			fErase(dt_cFile)

		EndIf

	ElseIf Type("_oXML:_Nfe:_InfNfe") <> "U"  	// Sem a Tag - NfeProc

		// Tramento feito para evitar que o arquivo XML fique perdido entre as pastas das empresas do grupo
		If Type("_oXML:_NFE:_INFNFE:_DEST:_CNPJ:TEXT") <> "U"

			If _oXML:_NFE:_INFNFE:_DEST:_CNPJ:TEXT == SM0->M0_CGC

				__NUMNF 	  	:= PADL(Alltrim(_oXML:_NFE:_INFNFE:_IDE:_NNF:TEXT),6,"0")                      // Nro da Nota
				__SERNF 	  	:= PADR(_oXML:_Nfe:_InfNfe:_IDE:_Serie:Text,3," ")                             // Serie da Nota

				If Type("_oXML:_NFE:_INFNFE:_IDE:_dHEmi") <> "U"  	// Sem a _dHEmi
					__CEMISSAO 		:= _oXML:_NFE:_INFNFE:_IDE:_dHEmi:Text                                          // Emissao
				Else
					__CEMISSAO 		:= _oXML:_NFE:_INFNFE:_IDE:_dEmi:Text                                          // Emissao
				EndIf

				__DEMISSAO 		:= stod(Substr(__CEMISSAO,1,4)+Substr(__CEMISSAO,6,2)+Substr(__CEMISSAO,9,2))  // Emissao
				__CNPJ_FOR 		:= _oXML:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
				__XPED	      := Space(TamSx3("C7_NUM")[1])
				If Type("_oXML:_NFE:_INFNFE:_COMPRA:_XPED") <> "U"
					__XPED		  := AllTrim(_oXML:_NFE:_INFNFE:_COMPRA:_XPED)
				EndIf
				__CHAVENFE    := ""
				If Type("_oXML:_PROTNFE:_INFPROT:_CHNFE") <> "U"
					__CHAVENFE  := AllTrim(_oXML:_PROTNFE:_INFPROT:_CHNFE:TEXT)
				Else
					If Type("_oXML:_NFE:_INFNFE:_ID") <> "U"
						__CHAVENFE  := Substr(_oXML:_NFE:_INFNFE:_ID:TEXT,4,44)
					EndIf
				EndIf

				AADD(aCab, __NUMNF)
				AADD(aCab, __SERNF)
				AADD(aCab, __DEMISSAO)
				AADD(aCab, __CNPJ_FOR)
				AADD(aCab, __XPED)
				AADD(aCab, __CHAVENFE)
				AADD(aCab, "SPED")

				AADD(aRet,aCab)

				// Verifição de Dados do Fornecedor
				If (Type("_oXML:_NFE:_INFNFE:_EMIT:_CNPJ") <> "U" )
					__CNPJ_FOR := _oXML:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
				ElseIf (Type("_oXML:_NFE:_INFNFE:_EMIT:_CPF") <> "U" )
					__CNPJ_FOR := _oXML:_NFE:_INFNFE:_EMIT:_CPF:TEXT
				EndIf
				cFornec   := ""
				cLjFornec := ""
				SA2->(dbSetOrder(3))
				SA2->(dbSeek(xFilial("SA2")+__CNPJ_FOR))
				While !SA2->(Eof()) .and. SA2->A2_FILIAL == xFilial("SA2") .and. SA2->A2_CGC == __CNPJ_FOR
					If SA2->A2_MSBLQL <> "1" .and. SA2->A2_COD <> "INVEST"
						cFornec   := SA2->A2_COD
						cLjFornec := SA2->A2_LOJA
					EndIf
					SA2->(dbSkip())
				End

				// Leitura/Preebchimento dos dados dos Itens da NF
				If ValType(_oXML:_Nfe:_InfNfe:_DET) = "O"
					XmlNode2Arr(_oXML:_Nfe:_InfNfe:_DET, "_DET")
				EndIf
				nNumItens  	:= Len(_oXML:_Nfe:_InfNfe:_DET)
				nTotalMerc 	:= Val(_oXML:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text)
				nDescNota  	:= val(_oXML:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:Text)
				nValor	 		:= Val(_oXML:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:Text)
				nIcmsSubs		:= Val(_oXML:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:Text)

				aProd := {}
				For nCont := 1 to nNumItens

					cCodForn	:= AllTrim(_oXML:_NFE:_INFNFE:_DET[nCont]:_Prod:_CPROD:Text)
					cDescForn	:= AllTrim(_oXML:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPROD:Text)
					nQuant		:= Val(_oXML:_NFE:_INFNFE:_DET[nCont]:_Prod:_QCOM:Text)
					cUnidad		:= Upper(AllTrim(_oXML:_NFE:_INFNFE:_DET[nCont]:_Prod:_UCOM:Text))
					nPrcUnLiq	:= Val(_oXML:_NFE:_INFNFE:_DET[nCont]:_Prod:_VUNCOM:Text)
					nPrcTtLiq	:= Val(_oXML:_NFE:_INFNFE:_DET[nCont]:_Prod:_VPROD:Text)
					xz_Unid     := Alltrim(_oXML:_NFE:_INFNFE:_DET[1]:_PROD:_UCOM:TEXT)
					xz_ItXml    := StrZero(Val(_oXML:_NFE:_INFNFE:_DET[nCont]:_NITEM:TEXT), TamSx3("DT_ITEM")[1])
					xz_CFOP     := _oXML:_NFE:_INFNFE:_DET[nCont]:_PROD:_CFOP:TEXT

					nValDesc	:= 0
					If XmlChildEx(_oXML:_Nfe:_InfNfe:_DET[nCont]:_PROD, "_VDESC")!= Nil
						nValDesc	:= Val(_oXML:_NFE:_INFNFE:_DET[nCont]:_Prod:_VDESC:Text)
					EndIf

					cPedItem	:= Space(TamSx3("C7_NUM")[1])
					If Type("_oXML:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPED") <> "U"
						cPedItem	:= Upper(AllTrim(_oXML:_NFE:_INFNFE:_DET[nCont]:_Prod:_XPED:Text))
					EndIf

					// Amarração Produto Fornecedor
					__lFindPrd := .F.
					SA5->(dbSetOrder(5))
					If SA5->(dbSeek(xFilial("SA5")+Padr(cCodForn,TamSx3("A5_CODPRF")[1])))
						While AllTrim(SA5->A5_CODPRF) == AllTrim(cCodForn)
							If SA5->(A5_FORNECE+A5_LOJA) == cFornec+cLjFornec
								cCodigo := SA5->A5_PRODUTO
								__lFindPrd := .T.
								Exit
							Endif
							SA5->(dBSkip())
						End
					EndIf
					If !__lFindPrd
						cCodigo := Space(TamSx3("B1_COD")[1])
					EndIf

					AAUX := {}
					AAdd(AAUX, cCodForn)

					// Posiciona no produto encontrado
					If cCodigo <> Nil .And. !Empty(cCodigo)
						AAdd(AAUX, cCodigo)
					Else
						AAdd(AAUX, Space(TamSx3("B1_COD")[1]))
					EndIf

					AAdd(AAUX, cDescForn)
					AAdd(AAUX, cUnidad)
					AAdd(AAUX, nQuant)
					AAdd(AAUX, nPrcUnLiq)
					AAdd(AAUX, nPrcTtLiq)
					AAdd(AAUX, nValDesc)
					AAdd(AAUX, cPedItem)
					AAdd(AAUX, xz_Unid)
					AAdd(AAUX, xz_ItXml)
					AAdd(AAUX, xz_CFOP)

					AAdd(aProd,AAUX)

				Next nCont

				AADD(aRet,aProd)

			Else

				fBscEmpr( _oXML:_NFE:_INFNFE:_DEST:_CNPJ:TEXT, _cFile, .T. )

			EndIf

		Else

			dt_cFile := cPath + _cFile
			fErase(dt_cFile)

		EndIf

	EndIf

Return(aRet)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fBscEmpr  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/05/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Caso um XML esteja gravado na pasta de empresa errada, faz ¦¦¦
¦¦¦          ¦ a gravação na pasta correta                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fBscEmpr(sxCGC, _cFile, _OkDel)

	Local fcRec
	Local fRefGrp := .F.
	Local _aSm0	:=	{}
	Local _nI
	Local _cEmp

	fcRec := SM0->(Recno())
	_aSm0	:=	FWLoadSM0()

	For _nI	:=	1 to Len(_aSM0)

		_cEmp	:=	Iif(!Empty(_aSM0[_nI,SM0_EMPRESA]),_aSM0[_nI,SM0_EMPRESA],_aSM0[_nI,SM0_GRPEMP])

		If _aSM0[_nI,SM0_CGC] == sxCGC
			dt_cFile := cPath + _cFile
			xt_cFil1 := "\P10\XML_NFE\" + _cEmp + _aSM0[_nI,SM0_FILIAL] + "\RECEBIDOS\" + _cFile
			If !File(xt_cFil1)
				fRename(dt_cFile, xt_cFil1)
			Else
				fErase(dt_cFile)
			EndIf
			fRefGrp := .T.
			Exit
		EndIf
	Next

	If !fRefGrp .and. _OkDel
		dt_cFile := cPath + _cFile
		fErase(dt_cFile)
	EndIf

	SM0->(dbGoTo(fcRec))

Return ( fRefGrp )
//--------------------------------------------------------------------------------------------------------
Static Function GetSqlCGC(pCGC)
	Local cSql := ""

	cSql:= " SELECT COUNT(0) AS QTD
	cSql+= " FROM SA2010
	cSql+= " WHERE A2_FILIAL = ''
	cSql+= " AND A2_MSBLQL <> '1'
	cSql+= " AND A2_CGC IN
	cSql+= " (
	cSql+= " SELECT A2.A2_CGC
	cSql+= " FROM " + RetSqlName("SD1") + " D1 "
	cSql+= " INNER JOIN " + RetSqlName("SA2") + " A2 ON A2.A2_COD = D1_FORNECE AND A2.D_E_L_E_T_ = ''
	cSql+= " WHERE D1_FILIAL = '01'
	cSql+= " 	  AND D1_EMISSAO BETWEEN '20140801' AND '20140930'
	cSql+= " 	  AND D1_FORNECE <> '003721'
	cSql+= " 	  AND D1_COD >= '100000'
	cSql+= " 	  AND D1_COD <= '107999'
	cSql+= " 	  AND D1.D_E_L_E_T_ = ''
	cSql+= " 	  AND A2.A2_CGC <> ''
	cSql+= " )
	cSql+= " AND A2_CGC = '" +pCGC+	"' "
	cSql+= " AND D_E_L_E_T_ = ''

Return cSql
//--------------------------------------------------------------------------------------------------------
