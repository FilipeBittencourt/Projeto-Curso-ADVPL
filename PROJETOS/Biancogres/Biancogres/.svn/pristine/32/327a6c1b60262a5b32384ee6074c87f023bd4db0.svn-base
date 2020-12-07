#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF043
@author Tiago Rossini Coradini
@since 15/08/2016
@version 1.0
@description Geração de arquivo com dados de funcionarios para importação do sistema CCURE
@type function
/*/

User Function BIAF043(jkOrig)

	Local fvAreaAtu := GetArea()
	Local xt, xv_Emps

	If Select("SX6") == 0

		jkOrig := fBiaGeraOrg()

	EndIf

	If jkOrig == "0"

		//                                                                     Tratamento Original
		//****************************************************************************************
		If cEmpAnt $ "01/05/12"

			If IsInCallStack("Gpea010Inc")		

				fImport("M")

			ElseIf IsInCallStack("Gpea010Alt") .And. fUpdFun()

				fImport("M")

			ElseIf UPPER(Alltrim(FunName())) == "GPEA180"

				If SRE->RE_EMPD <> SRE->RE_EMPP .and. SRE->RE_MATD <> SRE->RE_MATP

					U_FROPCPRO(SRE->RE_EMPP, SRE->RE_FILIALP, "U_fBiaPosSRA", SRE->RE_MATP)

					RecLock("SRA", .F.)
					SRA->RA_YBLQACE := "S"
					SRA->RA_YMOTBLQ := "D"
					MsUnLock()

					fImport("B")

				EndIf

			EndIf

		EndIf

	Else

		//               Tratamento Específico criado a partir das necessidades de reprocessamento
		//****************************************************************************************
		If Select("SX6") == 0

			xv_Emps    := U_BAGtEmpr("01_05_12")
			For xt := 1 To Len(xv_Emps)

				RPCSetType(3)

				RPCSetEnv(xv_Emps[xt,1], xv_Emps[xt,2], "", "", "PON", "",{"SRA","SR8"})

				ConOut("HORA: " + TIME() + " - Inicio do processamento da rotina BIAF043 - Empr: " + xv_Emps[xt,1])

				LS002 := " SELECT * "
				LS002 += "   FROM (SELECT RA_MAT, "
				LS002 += "                RA_NOME, "
				LS002 += "                CASE "
				LS002 += "                  WHEN RA_YBLQACE = 'S' THEN 1 "
				LS002 += "                  ELSE 0 "
				LS002 += "                END RA_YBLQACE, "
				LS002 += "                RA_YMOTBLQ, "
				LS002 += "                RA_YSERIAL, "
				LS002 += "                RA_DEMISSA, "
				LS002 += "                R_E_C_N_O_ REGSRA, "
				LS002 += "                ISNULL((SELECT COUNT(*) "
				LS002 += "                          FROM " + RetSqlName("SR8")+ " SR8 "
				LS002 += "                         WHERE R8_FILIAL = '" + xFilial("SR8") + "' "
				LS002 += "                               AND R8_MAT = RA_MAT "
				LS002 += "                               AND ( ( R8_DATAINI < '" + dtos(dDataBase) + "' AND R8_DATAFIM = '' ) OR ('" + dtos(dDataBase) + "' >= R8_DATAINI AND '" + dtos(dDataBase) + "' <= R8_DATAFIM AND R8_DATAFIM <> '' ) ) "
				LS002 += "                               AND SR8.D_E_L_E_T_ = ' '), 0) BLOQ, "
				LS002 += "                ISNULL((SELECT CASE "
				LS002 += "                                 WHEN ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' ) THEN 'F' "
				LS002 += "                                 ELSE 'A' "
				LS002 += "                               END "
				LS002 += "                          FROM " + RetSqlName("SR8")+ " SR8 "
				LS002 += "                         WHERE R8_FILIAL = '" + xFilial("SR8") + "' "
				LS002 += "                               AND R8_MAT = RA_MAT "
				LS002 += "                               AND ( ( R8_DATAINI < '" + dtos(dDataBase) + "' AND R8_DATAFIM = '' ) OR ('" + dtos(dDataBase) + "' >= R8_DATAINI AND '" + dtos(dDataBase) + "' <= R8_DATAFIM AND R8_DATAFIM <> '' ) ) "
				LS002 += "                               AND SR8.D_E_L_E_T_ = ' '), 'N') MOTIV "
				LS002 += "           FROM " + RetSqlName("SRA")+ " "
				LS002 += "          WHERE RA_FILIAL = '" + xFilial("SRA") + "' "
				LS002 += "                AND RA_MAT <= '199999' "
				LS002 += "                AND (RA_DEMISSA = '        ' OR (RA_DEMISSA <> '        ' AND RA_YSERIAL <> '')) "
				LS002 += "                AND RA_YMOTBLQ <> 'D' "
				LS002 += "                AND D_E_L_E_T_ = ' ') AS TARFED "
				LS002 += "  WHERE RA_YMOTBLQ <> MOTIV OR RA_YBLQACE <> BLOQ "		
				LSIndex := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,LS002),'LS02',.T.,.T.)
				dbSelectArea("LS02")
				dbGoTop()
				While !Eof()

					dbSelectArea("SRA")
					dbGoTo(LS02->REGSRA)
					RecLock("SRA", .F.)
					SRA->RA_YBLQACE := IIF(LS02->BLOQ == 0, "N", "S")
					SRA->RA_YMOTBLQ := LS02->MOTIV
					MsUnLock()

					fImport("B")

					dbSelectArea("LS02")
					dbSkip()

				End

				LS02->(dbCloseArea())
				Ferase(LSIndex+GetDBExtension())
				Ferase(LSIndex+OrdBagExt())

				ConOut("HORA: " + TIME() + " - Finalizando Processo BIAF043 - Empr:  " + xv_Emps[xt,1] )

				RpcClearEnv()

			Next xt

		Else

			Processa({|| fBiaFPer1(jkOrig) })

		EndIf


	EndIf

	RestArea( fvAreaAtu )

Return

//**************************************************************************************
//*  Considerando a Transferência, posiciona na empresa Origem para atualizar dados    *
//* do funcionário transferido...                                                      *
//**************************************************************************************
User Function fBiaPosSRA(frMatricAt)

	Local gtAreaAtu := GetArea()

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(xFilial("SRA")+frMatricAt)

	fImport("B")

	RestArea(gtAreaAtu)	 

Return

//**************************************************************************************
//*                                                                                    *
//**************************************************************************************
Static Function fBiaGeraOrg()

	Local ttOrig := "1"

Return ( ttOrig )

//**************************************************************************************
//*                                                                                    *
//**************************************************************************************
Static Function fBiaFPer1(jkOrig)

	If jkOrig == "1"

		LS002 := " SELECT * "
		LS002 += "   FROM (SELECT RA_MAT, "
		LS002 += "                RA_NOME, "
		LS002 += "                RA_YBLQACE, "
		LS002 += "                RA_YMOTBLQ, "
		LS002 += "                RA_YSERIAL, "
		LS002 += "                RA_DEMISSA, "
		LS002 += "                R_E_C_N_O_ REGSRA, "
		LS002 += "                ISNULL((SELECT CASE "
		LS002 += "                                 WHEN ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' ) THEN 'F' "
		LS002 += "                                 ELSE 'A' "
		LS002 += "                               END "
		LS002 += "                          FROM " + RetSqlName("SR8")+ " SR8 "
		LS002 += "                         WHERE R8_FILIAL = '" + xFilial("SR8") + "' "
		LS002 += "                               AND R8_MAT = RA_MAT "
		LS002 += "                               AND ( ( R8_DATAINI < '" + dtos(dDataBase) + "' AND R8_DATAFIM = '' ) OR ('" + dtos(dDataBase) + "' >= R8_DATAINI AND '" + dtos(dDataBase) + "' <= R8_DATAFIM AND R8_DATAFIM <> '' ) ) "
		LS002 += "                               AND SR8.D_E_L_E_T_ = ' '), 'N') MOTIV "
		LS002 += "           FROM " + RetSqlName("SRA")+ " "
		LS002 += "          WHERE RA_FILIAL = '" + xFilial("SRA") + "' "
		LS002 += "                AND RA_MAT <= '199999' "
		LS002 += "                AND (RA_DEMISSA = '        ' OR (RA_DEMISSA <> '        ' AND RA_YSERIAL <> '')) "
		LS002 += "                AND EXISTS (SELECT * "
		LS002 += "                              FROM " + RetSqlName("SR8")+ " SR8 "
		LS002 += "                             WHERE R8_FILIAL = '" + xFilial("SR8") + "' "
		LS002 += "                                   AND R8_MAT = RA_MAT "
		LS002 += "                                   AND ( ( R8_DATAINI < '" + dtos(dDataBase) + "' AND R8_DATAFIM = '' ) OR ('" + dtos(dDataBase) + "' >= R8_DATAINI AND '" + dtos(dDataBase) + "' <= R8_DATAFIM AND R8_DATAFIM <> '' ) ) "
		LS002 += "                                   AND SR8.D_E_L_E_T_ = ' ') "
		LS002 += "                AND D_E_L_E_T_ = ' ') AS TARFED "
		LS002 += "  WHERE RA_YMOTBLQ <> MOTIV "		
		LSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,LS002),'LS02',.T.,.T.)
		dbSelectArea("LS02")
		dbGoTop()
		While !Eof()

			dbSelectArea("SRA")
			dbGoTo(LS02->REGSRA)
			RecLock("SRA", .F.)
			SRA->RA_YBLQACE := "S"
			SRA->RA_YMOTBLQ := LS02->MOTIV
			MsUnLock()

			RegToMemory("SRA")

			fImport("M")

			dbSelectArea("LS02")
			dbSkip()

		End

		LS02->(dbCloseArea())
		Ferase(LSIndex+GetDBExtension())
		Ferase(LSIndex+OrdBagExt())

	ElseIf jkOrig == "2"

		PH003 := " SELECT R_E_C_N_O_ REGSRA "
		PH003 += "   FROM " + RetSqlName("SRA") + " SRA "
		PH003 += "  WHERE RA_FILIAL = '" + xFilial("SRA") + "' "
		PH003 += "        AND RA_MAT <= '199999' "
		PH003 += "        AND (RA_DEMISSA = '' "
		PH003 += "             OR (RA_DEMISSA <> '' "
		PH003 += "                 AND RA_YSERIAL <> '')) "
		PH003 += "        AND D_E_L_E_T_ = ' ' "
		PHIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,PH003),'PH03',.T.,.T.)
		dbSelectArea("PH03")
		dbGoTop()
		While !Eof()

			dbSelectArea("SRA")
			dbGoTo(PH03->REGSRA)

			RegToMemory("SRA")

			fImport("M")

			dbSelectArea("PH03")
			dbSkip()

		End

		PH03->(dbCloseArea())
		Ferase(PHIndex+GetDBExtension())
		Ferase(PHIndex+OrdBagExt())

	EndIf

Return

//**************************************************************************************
//*                                                                                    *
//**************************************************************************************
Static Function fUpdFun()

	Local lRet := .F.

	If SRA->RA_NOME <> M->RA_NOME .Or. SRA->RA_CIC <> M->RA_CIC .Or. SRA->RA_NASC <> M->RA_NASC .Or. SRA->RA_CLVL <> M->RA_CLVL .Or.;
	SRA->RA_YSERIAL <> M->RA_YSERIAL .Or. SRA->RA_TELEFON <> M->RA_TELEFON .Or. SRA->RA_ENDEREC <> M->RA_ENDEREC .Or. SRA->RA_COMPLEM <> M->RA_COMPLEM .Or.; 
	SRA->RA_BAIRRO <> M->RA_BAIRRO .Or. SRA->RA_MUNICIP <> M->RA_MUNICIP .Or. SRA->RA_ESTADO <> M->RA_ESTADO .Or. SRA->RA_HABILIT <> M->RA_HABILIT .Or.;
	SRA->RA_YBLQACE <> M->RA_YBLQACE .Or. SRA->RA_YMOTBLQ <> M->RA_YMOTBLQ .Or. SRA->RA_YACFULL <> M->RA_YACFULL //.Or. SRA->RA_YINTJOR <> M->RA_YINTJOR

		lRet := .T.

	EndIf

Return(lRet)

//**************************************************************************************
//*                                                                                    *
//**************************************************************************************
Static Function fImport(kdFlag)

	Local lRet := .T.
	Local cDir := "\P10\CCURE\"
	Local nX, nY
	//Local cArquivo := "FUN" +"-"+ StrTran(dToC(Date()), "/") +"-"+ StrTran(Time(), ":")
	//Local cArquivo := "FUN" +"-"+ cEmpAnt + M->RA_MAT +"-"+ StrTran(Time(), ":")
	Local cArquivo := ""
	Local nHandle := 0
	Local cCRLF := Chr(13) + Chr(10)
	Local aCab := {}
	Local aLinhas := {}

	aAdd(aCab, "CODEMPR")
	aAdd(aCab, "EMPR")
	aAdd(aCab, "CRACHA")
	aAdd(aCab, "MATRIC")
	aAdd(aCab, "NOME")
	aAdd(aCab, "CPF")
	aAdd(aCab, "DTNASC")
	aAdd(aCab, "CLVL")
	aAdd(aCab, "DCLVL")
	aAdd(aCab, "TELEFONE")
	aAdd(aCab, "ENDERECO")
	aAdd(aCab, "COMPLEMENTO")
	aAdd(aCab, "BAIRRO")
	aAdd(aCab, "MUNICIPIO")
	aAdd(aCab, "ESTADO")
	aAdd(aCab, "CNH")
	aAdd(aCab, "DTVCNH")
	aAdd(aCab, "PLACA")
	aAdd(aCab, "CARRETA")
	aAdd(aCab, "MODELO")
	aAdd(aCab, "DNIT")
	aAdd(aCab, "BLOQUEIO_ACESSO")
	aAdd(aCab, "MOTIVO_BLOQUEIO")
	aAdd(aCab, "TIPO")

	If kdFlag == "M"                                                          // Memória
		//******************************************************************************

		cArquivo := "FUN" +"-"+ cEmpAnt + M->RA_MAT +"-"+ StrTran(Time(), ":")
		ggCracha := IIF(cEmpAnt == "01", "00", cEmpAnt) + "0000000" + M->RA_MAT
		ggCT1Des := StrTran(AllTrim(Posicione("CTH", 1, xFilial("CTH") + M->RA_CLVL, "CTH_DESC01")), ",", "/")

		aAdd(aLinhas, {cEmpAnt                                                       ,;
		fGetEmp()                                                                    ,;
		ggCracha                                                                     ,;
		M->RA_MAT                                                                    ,;
		AllTrim(M->RA_NOME)                                                          ,;
		AllTrim(M->RA_CIC)                                                           ,;
		dToC(M->RA_NASC)                                                             ,;
		AllTrim(M->RA_CLVL)                                                          ,;
		ggCT1Des                                                                     ,;
		StrTran(AllTrim(M->RA_TELEFON), "-")                                         ,;
		StrTran(AllTrim(M->RA_ENDEREC), ",")                                         ,;
		StrTran(AllTrim(M->RA_COMPLEM), ",")                                         ,;
		Alltrim(M->RA_BAIRRO)                                                        ,;
		Alltrim(M->RA_MUNICIP)                                                       ,;
		Alltrim(M->RA_ESTADO)                                                        ,;
		Alltrim(M->RA_HABILIT)                                                       ,;
		""                                                                           ,;
		""                                                                           ,;
		""                                                                           ,;
		""                                                                           ,;
		""                                                                           ,;
		If (M->RA_YBLQACE == "S", "True", "False")                                   ,;
		fMotBlq(M->RA_YMOTBLQ)                                                       ,;
		"Funcionario"                                                                })

	ElseIf kdFlag == "B"                                                         // Base
		//******************************************************************************

		cArquivo := "FUN" +"-"+ cEmpAnt + SRA->RA_MAT +"-"+ StrTran(Time(), ":")
		ggCracha := IIF(cEmpAnt == "01", "00", cEmpAnt) + "0000000" + SRA->RA_MAT
		ggCT1Des := StrTran(AllTrim(Posicione("CTH", 1, xFilial("CTH") + SRA->RA_CLVL, "CTH_DESC01")), ",", "/")

		aAdd(aLinhas, {cEmpAnt                                                       ,;
		fGetEmp()                                                                    ,;
		ggCracha                                                                     ,;
		SRA->RA_MAT                                                                  ,;
		AllTrim(SRA->RA_NOME)                                                        ,;
		AllTrim(SRA->RA_CIC)                                                         ,;
		dToC(SRA->RA_NASC)                                                           ,;
		AllTrim(SRA->RA_CLVL)                                                        ,;
		ggCT1Des                                                                     ,;
		StrTran(AllTrim(SRA->RA_TELEFON), "-")                                       ,;
		StrTran(AllTrim(SRA->RA_ENDEREC), ",")                                       ,;
		StrTran(AllTrim(SRA->RA_COMPLEM), ",")                                       ,;
		Alltrim(SRA->RA_BAIRRO)                                                      ,;
		Alltrim(SRA->RA_MUNICIP)                                                     ,;
		Alltrim(SRA->RA_ESTADO)                                                      ,;
		Alltrim(SRA->RA_HABILIT)                                                     ,;
		""                                                                           ,;
		""                                                                           ,;
		""                                                                           ,;
		""                                                                           ,;
		""                                                                           ,;
		If (SRA->RA_YBLQACE == "S", "True", "False")                                 ,;
		fMotBlq(SRA->RA_YMOTBLQ)                                                     ,;
		"Funcionario"                                                                })

	EndIf

	// Verifica se o diretoria ja existe
	If !ExistDir(cDir)

		// Cria diretorio
		lRet := MakeDir(cDir) == 0

	EndIf

	If lRet

		nHandle := MsFCreate(cDir + cArquivo + ".CSV", 0)

		If nHandle > 0

			For nX := 1 To Len(aCab)
				fWrite(nHandle, aCab[nX] + If (nX < Len(aCab), ",", ""))
			Next

			fWrite(nHandle, cCRLF)

			For nX := 1 To Len(aLinhas)

				For nY := 1 To Len(aCab)
					fWrite(nHandle, Transform(aLinhas[nX, nY], "@!" ) + If (nY < Len(aCab), ",", ""))
				Next nY

				fWrite(nHandle, cCRLF)

			Next nX

			fClose(nHandle)			

		EndIf

	EndIf

Return()

//**************************************************************************************
//*                                                                                    *
//**************************************************************************************
Static Function fGetEmp()

	Local cRet := ""

	If cEmpAnt == "01"

		cRet := "BIANCOGRES"

	ElseIf cEmpAnt == "05"

		cRet := "INCESA"

	ElseIf cEmpAnt == "12"

		cRet := "ST GESTAO"

	EndIf

Return(cRet)

//**************************************************************************************
//*                                                                                    *
//**************************************************************************************
Static Function fMotBlq(cMotBlq)

	Local cRet := "" 

	If cMotBlq == "A"

		cRet := "Afastado"

	ElseIf cMotBlq == "D"

		cRet := "Demitido"

	ElseIf cMotBlq == "F"

		cRet := "Ferias"

	EndIf

Return(cRet)
