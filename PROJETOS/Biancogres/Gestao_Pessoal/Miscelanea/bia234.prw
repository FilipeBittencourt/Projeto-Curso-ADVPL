#INCLUDE "PROTHEUS.CH"
#INCLUDE "BIA688.CH"
#INCLUDE "report.ch"
#INCLUDE "FIVEWIN.CH"

/*/{Protheus.doc} BIA688
@author Marcos Alberto Soprani
@since 29/09/16
@version 1.0
@description Atribuição de ACCESS LEVEL para fins de controle de acesso 
@obs ......
@type function
/*/

User Function BIA234()

	Local xt

	Private zp_EpAtu
	Private zpProcManu := .F.

	cv_ViaWf := .F.
	If Select("SX6") == 0

		xv_Emps    := U_BAGtEmpr("01_12")
		For xt := 1 To Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)

			RPCSetEnv(xv_Emps[xt,1], xv_Emps[xt,2], "", "", "PON", "",{"SRA","SRX","SP4","SPC","SP9","SP8"})

			cv_ViaWf := .T.
			zp_EpAtu := xv_Emps[xt,1]
			ConOut("Data: " + dtoc(Date()) + " Hora: " + TIME() + " --> BIA234 - Iniciando Processo " + xv_Emps[xt,1] )

			Processa({||BA234xPROC()})

			ConOut("Data: " + dtoc(Date()) + " Hora: " + TIME() + " --> BIA234 - Finalizando Processo " + xv_Emps[xt,1] )

			RpcClearEnv()

		Next xt

	Else

		zpProcManu := .T.
		zp_EpAtu   := cEmpAnt
		cHInicio   := Time()

		If Aviso('Access Level', 'Deseja prosseguir com o processamento?', {'Sim','Não'}, 3, "Atenção!!!") == 1

			Processa({||BA234xPROC()})

		EndIf

	EndIf

	U_B234RunSrv()

Return

//**********************************************************************************************
//**                                                                                          **
//**********************************************************************************************
Static Function BA234xPROC()

	Local aTabPadrao 	:= {}
	Local aTabCalend	:= {}
	Local dPerIni
	Local dPerFim

	Local lRet     := .T.
	Local cDir     := "\P10\CCURE\"
	Local cArquivo := ""
	Local nHandle  := 0
	Local cCRLF    := Chr(13) + Chr(10)
	Local aCab     := {}
	Local aLinhas  := {}
	Local kd, nX, nY

	aAdd(aCab, "MATRICULA")
	aAdd(aCab, "EMPR")
	aAdd(aCab, "ACCESS_LEVEL")

	nxEnter  := CHR(13) + CHR(10)

	TG007 := Alltrim(" SELECT RA_MAT,                                                                   ") + nxEnter
	TG007 += Alltrim("        RA_YACFULL YACFULL,                                                       ") + nxEnter
	TG007 += Alltrim("        R_E_C_N_O_ REGSRA                                                         ") + nxEnter
	TG007 += Alltrim("   FROM " + RetSqlName("SRA") + "                                                 ") + nxEnter
	TG007 += Alltrim("  WHERE RA_FILIAL = '" + xFilial("SRA")+ "'                                       ") + nxEnter
	TG007 += Alltrim("    AND RA_MAT <= '199999'                                                        ") + nxEnter
	TG007 += Alltrim("    AND RA_SITFOLH <> 'D'                                                         ") + nxEnter
	TG007 += Alltrim("    AND D_E_L_E_T_ = ' '                                                          ") + nxEnter
	TG007 += Alltrim("  ORDER BY RA_MAT                                                                 ") + nxEnter
	TGcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TG007),'TG07',.F.,.T.)
	dbSelectArea("TG07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		dPerIni      := dDataBase
		dPerFim      := dDataBase

		xfTentativas := 1
		While xfTentativas <= 2

			aTabPadrao := {}
			aTabCalend := {}
			xfFlagGrv  := .F.
			dbSelectArea("SRA")
			dbSetOrder(1)
			dbGoTop()
			dbSeek(xFilial("SRA") + TG07->RA_MAT)

			IncProc("Proc.: " + SRA->RA_MAT + " " + SRA->RA_NOME)

			// Exceção à regra para coordenadores, supervisores, gerentes e diretores...
			If TG07->YACFULL == "S"

				xfAccessNvl  := "000 - FULL"
				xfTentativas := 3				
				xfHoraIni    := 0
				xfFlagGrv    := .T.

			Else

				If !CriaCalend(dPerIni, dPerFim, SRA->RA_TNOTRAB, SRA->RA_SEQTURN, @aTabPadrao, @aTabCalend, SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_CC, NIL, NIL, NIL, .F. )
					xfTentativas := 10
					aAdd(aLinhas, {SRA->RA_MAT   ,;
					cEmpAnt                      ,;
					"000 - BLOQ"                 })
					Loop
				EndIf

				// Caso seja um dia de DSR ou Não Trabalhado, o sistema já pula o Funcionários
				If aTabCalend[1][36] $ "D/N"

					dPerIni      := dPerIni - 1
					dPerFim      := dPerFim - 1

					CriaCalend(dPerIni, dPerFim, SRA->RA_TNOTRAB, SRA->RA_SEQTURN, @aTabPadrao, @aTabCalend, SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_CC, NIL, NIL, NIL, .F. )
					If Len(aTabCalend) >= 4

						If aTabCalend[4][1] <= dPerIni

							xfTentativas := 10
							aAdd(aLinhas, {SRA->RA_MAT   ,;
							cEmpAnt                      ,;
							"000 - BLOQ"                 })
							Loop

						Else

							If Substr(aTabCalend[4][4],2,1) == "S"

								xfHoraFim := aTabCalend[4][3]
								If Val(Substr(Time(),1,2)) <= xfHoraFim 
									xfTentativas := 10
									Loop
								Else
									xfTentativas := 10
									aAdd(aLinhas, {SRA->RA_MAT   ,;
									cEmpAnt                      ,;
									"000 - BLOQ"                 })
									Loop								
								EndIf

							EndIf

						EndIf

					Else

						xfTentativas := 10
						aAdd(aLinhas, {SRA->RA_MAT   ,;
						cEmpAnt                      ,;
						"000 - BLOQ"                 })
						Loop

					EndIf

				EndIf

				hkEnt       := .F.
				hkSai       := .F.
				hkDiaSem    := Alltrim(Str(Dow(dPerIni)))
				xfAccessNvl := ""
				xfExceEscal := .F.
				xfHoraIni   := 0
				xfHoraFim   := 0
				For kd := 1 to Len(aTabCalend)

					If aTabCalend[kd][4] $ "1E"

						// Caso esteja trabalhando sob jornada com exceção, específico para uma matricula
						If aTabCalend[kd][10] == "E"

							KT003 := " WITH TURNOPAD AS (SELECT PJ_TURNO, PJ_ENTRA1, PJ_SAIDA2 "
							KT003 += "                     FROM " + REtSqlName("SPJ") + " (NOLOCK) "
							KT003 += "                    WHERE PJ_FILIAL = '" + xFilial("SPJ") + "' "
							KT003 += "                      AND PJ_TURNO = '" + aTabCalend[kd][14] + "' "
							KT003 += "                      AND PJ_SEMANA = '" + aTabCalend[kd][8] + "' "
							KT003 += "                      AND PJ_DIA = '" + hkDiaSem + "' "
							KT003 += "                      AND D_E_L_E_T_ = ' ') "
							KT003 += " ,    EXCECAOC AS (SELECT P2_TURNO, P2_ENTRA1, P2_SAIDA2 "
							KT003 += "                     FROM " + REtSqlName("SP2") + " (NOLOCK) "
							KT003 += "                    WHERE P2_FILIAL = '" + xFilial("SP2") + "' "
							KT003 += "                      AND P2_TURNO = '" + aTabCalend[kd][14] + "' "
							KT003 += "                      AND P2_MAT = '" + TG07->RA_MAT + "' "
							KT003 += "                      AND '" + dtos(dPerIni) + "' BETWEEN P2_DATA AND P2_DATAATE "
							KT003 += "                      AND D_E_L_E_T_ = ' ') "
							KT003 += " SELECT ROUND(P2_ENTRA1 - PJ_ENTRA1, 2) ENTRADA, "
							KT003 += "        ROUND(P2_SAIDA2 - PJ_SAIDA2, 2) SAIDA "
							KT003 += "   FROM EXCECAOC "
							KT003 += "  INNER JOIN TURNOPAD ON P2_TURNO = PJ_TURNO "
							KTcIndex := CriaTrab(Nil,.f.)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,KT003),'KT03',.F.,.T.)
							dbSelectArea("KT03")

							If KT03->ENTRADA < 0
								hkEnt := .T.
							ElseIf KT03->SAIDA > 0
								hkSai := .T.
							EndIf

							KT03->(dbCloseArea())
							Ferase(KTcIndex+GetDBExtension())     //arquivo de trabalho
							Ferase(KTcIndex+OrdBagExt())          //indice gerado

							// Caso esteja trabalhando sob jornada com exceção, regra geral
							If !hkEnt .and. !hkSai

								KT003 := " WITH TURNOPAD AS (SELECT PJ_TURNO, PJ_ENTRA1, PJ_SAIDA2 "
								KT003 += "                     FROM " + REtSqlName("SPJ") + " (NOLOCK) "
								KT003 += "                    WHERE PJ_FILIAL = '" + xFilial("SPJ") + "' "
								KT003 += "                      AND PJ_TURNO = '" + aTabCalend[kd][14] + "' "
								KT003 += "                      AND PJ_SEMANA = '" + aTabCalend[kd][8] + "' "
								KT003 += "                      AND PJ_DIA = '" + hkDiaSem + "' "
								KT003 += "                      AND D_E_L_E_T_ = ' ') "
								KT003 += " ,    EXCECAOC AS (SELECT P2_TURNO, P2_ENTRA1, P2_SAIDA2 "
								KT003 += "                     FROM " + REtSqlName("SP2") + " (NOLOCK) "
								KT003 += "                    WHERE P2_FILIAL = '" + xFilial("SP2") + "' "
								KT003 += "                      AND P2_TURNO = '" + aTabCalend[kd][14] + "' "
								KT003 += "                      AND P2_MAT = '' "
								KT003 += "                      AND '" + dtos(dPerIni) + "' BETWEEN P2_DATA AND P2_DATAATE "
								KT003 += "                      AND D_E_L_E_T_ = ' ') "
								KT003 += " SELECT ROUND(P2_ENTRA1 - PJ_ENTRA1, 2) ENTRADA, "
								KT003 += "        ROUND(P2_SAIDA2 - PJ_SAIDA2, 2) SAIDA "
								KT003 += "   FROM EXCECAOC "
								KT003 += "  INNER JOIN TURNOPAD ON P2_TURNO = PJ_TURNO "
								KTcIndex := CriaTrab(Nil,.f.)
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,KT003),'KT03',.F.,.T.)
								dbSelectArea("KT03")

								If KT03->ENTRADA < 0
									hkEnt := .T.
								ElseIf KT03->SAIDA > 0
									hkSai := .T.
								EndIf

								KT03->(dbCloseArea())
								Ferase(KTcIndex+GetDBExtension())     //arquivo de trabalho
								Ferase(KTcIndex+OrdBagExt())          //indice gerado

							EndIf

						EndIf

					EndIf

					If kd == 1

						xfHoraIni   := aTabCalend[kd][3]
						If hkEnt
							xfHoraIni := SomaHoras(xfHoraIni, 0.30)
						EndIf
						xfAccessNvl := aTabCalend[kd][14] + ' - ' + Alltrim(Str(xfHoraIni)) + ' X '

					ElseIf ( kd == 2 .and. Len(aTabCalend) == 2 ) .or. kd == 4

						xfHoraFim := aTabCalend[kd][3]
						If hkSai
							xfHoraFim := SubHoras(xfHoraFim, 0.30)
						EndIf
						xfAccessNvl += Alltrim(Str(xfHoraFim))

					EndIf

				Next kd

				// Somente é necessário enviar duas horas antes do início da escala
				kdCtrlTmp := Val(Substr(Time(),1,2)) - xfHoraIni
				If ! ( kdCtrlTmp >= ( -2 ) .and. kdCtrlTmp < 0 )
					xfTentativas := 10
					xfFlagGrv    := .F.
					Loop
				EndIf

				If !Empty(xfAccessNvl)

					KS001 := " SELECT COUNT(*) CONTAD "
					KS001 += "   FROM VW_CCURE_ACCESS_LEVEL "
					KS001 += "  WHERE ACCESS_LEVEL = '" + xfAccessNvl + "' "
					KScIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,KS001),'KS01',.F.,.T.)
					dbSelectArea("KS01")
					dbGoTop()
					If KS01->CONTAD == 0

						xfAccessNvl := SRA->RA_TNOTRAB + Substr(xfAccessNvl, 4, Len(Alltrim(xfAccessNvl))-3 )

						KX002 := " SELECT COUNT(*) CONTAD "
						KX002 += "   FROM VW_CCURE_ACCESS_LEVEL "
						KX002 += "  WHERE ACCESS_LEVEL = '" + xfAccessNvl + "' "
						KXcIndex := CriaTrab(Nil,.f.)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,KX002),'KX02',.F.,.T.)
						dbSelectArea("KX02")
						dbGoTop()
						If KX02->CONTAD == 0
							xfAccessNvl := "000 - BLOQ"
						EndIf
						KX02->(dbCloseArea())
						Ferase(KXcIndex+GetDBExtension())     //arquivo de trabalho
						Ferase(KXcIndex+OrdBagExt())          //indice gerado

					EndIf
					KS01->(dbCloseArea())
					Ferase(KScIndex+GetDBExtension())     //arquivo de trabalho
					Ferase(KScIndex+OrdBagExt())          //indice gerado

					If !Empty(xfAccessNvl)

						xfFlagGrv := .T.

					EndIf

				Else

					xfFlagGrv   := .T.
					xfAccessNvl := "000 - BLOQ"

				EndIf

			EndIf

			If xfFlagGrv

				aAdd(aLinhas, {SRA->RA_MAT    ,;
				cEmpAnt                       ,;
				xfAccessNvl                   })
				xfTentativas := 10

			Else

				xfTentativas := 10

			EndIf

		End

		dbSelectArea("TG07")
		dbSkip()

	End

	TG07->(dbCloseArea())
	Ferase(TGcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TGcIndex+OrdBagExt())          //indice gerado

	cArquivo := "ACCESS_LEVEL" +"-"+ cEmpAnt +"-"+ dtos(dDataBase) +"-"+ StrTran(Time(), ":")

	IncProc("Gerando arquivo...")

	If !ExistDir(cDir)
		lRet := MakeDir(cDir) == 0
	EndIf

	If lRet

		If Len(aLinhas) > 0

			nHandle := MsFCreate(cDir + cArquivo + ".CSV", 0)

			If nHandle > 0

				For nX := 1 To Len(aCab)
					fWrite(nHandle, aCab[nX] + If (nX < Len(aCab), ",", ""))
				Next

				fWrite(nHandle, cCRLF)

				For nX := 1 To Len(aLinhas)

					IncProc("Gerando arquivo... " + Alltrim(Str(nX)))

					For nY := 1 To Len(aCab)
						fWrite(nHandle, Transform(aLinhas[nX, nY], "@!" ) + If (nY < Len(aCab), ",", ""))
					Next nY

					fWrite(nHandle, cCRLF)

				Next nX

				fClose(nHandle)			

			EndIf

		EndIf

	EndIf

Return

//***********************************************************************************************
User Function B234RunSrv()

	Local cCommand  := "" 
	Local cPath     := "" 
	Local lWait     := .F. 

	cCommand  := "D:\ccure4_p12.bat" 
	cPath     := "D:\" 

	Qout("B234RunSrv -:>^<:- Ini processamento... Data | Hora: " + dtoc(Date()) + " | " + Time() )
	WaitRunSrv( @cCommand , @lWait , @cPath )
	Qout("B234RunSrv -:>^<:- Fim processamento... Data | Hora: " + dtoc(Date()) + " | " + Time() )

Return

User Function B234JobRS()

	U_B234RunSrv()

Return
