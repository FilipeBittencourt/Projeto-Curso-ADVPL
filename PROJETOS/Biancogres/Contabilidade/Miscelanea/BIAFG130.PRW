#include 'protheus.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG130
@author Gabriel Rossi Mafioletti
@since 26/08/20
@version 1.0
@description Rotina para geracao dos expurgos na empresa 90 - Consolidado/Contabilização
@type function
/*/

User Function BIAFG130()

	Local oBrowse := NIL

	PRIVATE cCadastro	:=	"Expurgos para Consolidação"

	Private msrhEnter   := CHR(13) + CHR(10)
	Private msStaExcQy  := 0
	Private mslOk       := .T.
	Private msGravaErr  := ""

	If cEmpAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado.", "BIAFG130", "STOP")
		Return
	EndIf

	If cEmpAnt == "90" .and. cFilAnt <> "01"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado, Filial 01, devido as amarrações com as tabelas origens.", "BIAFG130", "STOP")
		Return
	EndIf

	DbSelectArea('ZN3')

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('ZN3')
	oBrowse:SetDescription('Expurgos para Consolidação')

	oBrowse:Activate()

Return

Static Function Menudef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar'           , 'AxPesqui' , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar'          , 'AxVisual' , 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Monta Consolidação'  , 'U_BFG130B', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Contabiliza Expurgos', 'U_BFG130C', 0, 7, 0, NIL } )

Return aRotina

USER Function BFG130B()

	Processa({|| bRptFG130() }, "Processando...", , .F.)

Return

Static Function bRptFG130()

	fPerg := "BIAFG130"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf	

	If Substr(dtos(MV_PAR01), 1, 6) <> Substr(dtos(MV_PAR02), 1, 6)
		MsgALERT("Não podem ser informados Ano e Mês diferentes para o intervalo de tempo a ser processado.", "Atenção!!!")
		Return
	EndIf

	EX005 := Alltrim(" SELECT COUNT(*) CONTAD                                            ") + msrhEnter
	EX005 += Alltrim(" FROM " + RetSqlName("ZN3") + " ZN3                                ") + msrhEnter
	EX005 += Alltrim(" WHERE ZN3_FILIAL = '" + xFilial("ZN3") + "'                       ") + msrhEnter
	EX005 += Alltrim("       AND ZN3_MESANO = '" +Substr(dtos(MV_PAR01), 1, 6)+ "'       ") + msrhEnter
	EX005 += Alltrim("       AND ZN3.D_E_L_E_T_ = ' '                                    ") + msrhEnter
	EXIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,EX005),'EX05',.F.,.T.)
	dbSelectArea("EX05")
	dbGoTop()
	If EX05->CONTAD > 0

		mslOk := MsgNOYES("Já existem registros na base de dados para o período informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

	EndIf

	EX05->(dbCloseArea())
	Ferase(EXIndex+GetDBExtension())
	Ferase(EXIndex+OrdBagExt())

	If mslOk

		Begin Transaction

			ET005 := Alltrim(" DELETE ZN3                                                        ") + msrhEnter
			ET005 += Alltrim(" FROM " + RetSqlName("ZN3") + " ZN3                                ") + msrhEnter
			ET005 += Alltrim(" WHERE ZN3_FILIAL = '" + xFilial("ZN3") + "'                       ") + msrhEnter
			ET005 += Alltrim("       AND ZN3_MESANO = '" +Substr(dtos(MV_PAR01), 1, 6)+ "'       ") + msrhEnter
			ET005 += Alltrim("       AND ZN3.D_E_L_E_T_ = ' '                                    ") + msrhEnter
			U_BIAMsgRun("Aguarde... Zerando processamentos anteriores... ",,{|| msStaExcQy := TcSQLExec(ET005) })

			If msStaExcQy < 0
				mslOk := .F.
			EndIf

			If !mslOk

				msGravaErr := TCSQLError()
				DisarmTransaction()

			EndIf

		End Transaction

		If !mslOk
			Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )
			Return
		EndIf 	

	Else

		MsgSTOP("Processamento cancelado", "Atenção!!!")
		Return

	EndIf

	nMesAnoD := Substr(Dtos(MV_PAR01),1,6)
	nMesAnoA := Substr(Dtos(MV_PAR02),1,6)

	cSql := " SELECT * "
	cSql += " FROM " + RetSqlName("ZN0") + " ZN0(NOLOCK)"
	cSql += " WHERE D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY ZN0_SEQUEN "
	If chkfile("ROTEIRO")
		dbSelectArea("ROTEIRO")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "ROTEIRO"

	While !ROTEIRO->(EOF())

		If SUBSTR(ROTEIRO->ZN0_TIPO,1,1) <> "6"

			//Grupo de Produtos
			nGrupos := U_MontaSQLIN(ROTEIRO->ZN0_TPPROD,'_',3)

			msEmpRef := ""
			If Alltrim(ROTEIRO->ZN0_TPPROD) == "ARG"
				msEmpRef := "ZN4_EMPORI"
			Else
				msEmpRef := "ZN4_EMPDES"
			EndIf

			//Define empresas para busca das informacoes
			cSql := " SELECT ZN4_MESANO, "
			cSql += "        " + msEmpRef + " EMPREF, "
			cSql += "        ZN4_FIL FIL, "
			cSql += "        ISNULL(ZN4_TPCTB,'') TP_CTB "
			cSql += " FROM " + RetSqlName("ZN4") + " ZN4(NOLOCK) "
			cSql += " WHERE "
			If !Empty(Alltrim(ROTEIRO->ZN0_FIL))
				cSql += "		ZN4_FIL  = '" + Alltrim(ROTEIRO->ZN0_FIL) + "' AND "
			EndIf
			If !Empty(Alltrim(nGrupos))
				cSql += "		ZN4_TPPROD IN (" + Alltrim(nGrupos) + ") AND "
			EndIf
			If !Empty(Alltrim(ROTEIRO->ZN0_EMPDES))
				If SUBSTR(ROTEIRO->ZN0_TIPO,1,1) == "1"
					cSql += "		ZN4_EMPDES = '" + Alltrim(ROTEIRO->ZN0_EMPDES) + "' AND "
				Else
					cSql += "		ZN4_EMPDES <> '" + Alltrim(ROTEIRO->ZN0_EMPDES) + "' AND "
				EndIf
			EndIf
			If Alltrim(ROTEIRO->ZN0_CONTA) == "41301001"
				cSql += "		ISNULL(ZN4_TPCTB,'') IN ('C','') AND "
			ElseIf Alltrim(ROTEIRO->ZN0_CONTA) == "31601003"
				cSql += "		ISNULL(ZN4_TPCTB,'') IN ('D')    AND "
			EndIf
			cSql += "		ZN4_MESANO >= '" + nMesAnoD + "' AND ZN4_MESANO <= '" + nMesAnoA + "' "
			cSql += " GROUP BY ZN4_MESANO, "
			cSql += "          " + msEmpRef + ", "
			cSql += "          ZN4_FIL, "
			cSql += "          ZN4_TPCTB "
			cSql += " ORDER BY ZN4_MESANO, "
			cSql += "          " + msEmpRef + ", "
			cSql += "          ZN4_FIL, "
			cSql += "          ZN4_TPCTB "
			If chkfile("EMP")
				dbSelectArea("EMP")
				dbCloseArea()
			EndIf
			TcQuery cSql New Alias "EMP"

			While !EMP->(EOF())

				//Se estiver vazio, EMPRESA ORIGEM E DESTINO SÃO IGUAIS

				If Alltrim(ROTEIRO->ZN0_TPPROD) == "ARG"
					nEmpDes := "  "
					nEmpOri := EMP->EMPREF

				ElseIf Empty(Alltrim(ROTEIRO->ZN0_EMPDES))
					nEmpDes := EMP->EMPREF
					nEmpOri := EMP->EMPREF

				Else
					nEmpDes := EMP->EMPREF
					nEmpOri := ROTEIRO->ZN0_EMPDES

				EndIf

				If Alltrim(ROTEIRO->ZN0_CONTA) == "31601003"
					nEmpDes := nEmpOri
				EndIf

				//Define a Filial
				If Empty(Alltrim(ROTEIRO->ZN0_FIL))
					nFil := EMP->FIL
				Else
					nFil := ROTEIRO->ZN0_FIL
				EndIf

				//Define Tp Contabil
				If Empty(Alltrim(EMP->TP_CTB))
					nTpCTB := ""
				Else
					nTpCTB := Alltrim(EMP->TP_CTB)
				EndIf

				_aRet	:= {}
				U_BIAMsgRun("Aguarde... Gerando informações para Consolidação: " + ROTEIRO->ZN0_TIPO ,,{|| _aRet := TCSPEXEC("SP_BIAFG130", ROTEIRO->ZN0_CONTA, nEmpOri, nEmpDes, nFil, nTpCTB, EMP->ZN4_MESANO, SUBSTR(ROTEIRO->ZN0_TIPO,1,1), nGrupos) })

				If Len(_aRet) > 0

					Reclock("ZN3",.T.)
					ZN3->ZN3_FILIAL	:=	xFilial("ZN3")
					ZN3->ZN3_CONTA	:=	ROTEIRO->ZN0_CONTA	
					ZN3->ZN3_TIPO	:=	ROTEIRO->ZN0_TIPO
					ZN3->ZN3_TPPROD	:=	ROTEIRO->ZN0_TPPROD	
					ZN3->ZN3_MESANO	:=	EMP->ZN4_MESANO	
					ZN3->ZN3_DTLANC	:=	LastDay(STOD(EMP->ZN4_MESANO+"01"),0)
					ZN3->ZN3_EMP	:=	nEmpDes	
					ZN3->ZN3_TPLANC	:=	ROTEIRO->ZN0_TPLANC	
					ZN3->ZN3_VALOR	:=	_aRet[1]
					ZN3->ZN3_FLAG	:=	"N"
					ZN3->ZN3_EMPORI	:=	nEmpOri  // Verificar como mudar estas regras para os proximos meses. Em 07/02/21, por Marcos A.
					ZN3->ZN3_EMPDES	:=	nEmpDes  // Verificar como mudar estas regras para os proximos meses. Em 07/02/21, por Marcos A.
					ZN3->ZN3_TIPVAL	:=	""       // Verificar como mudar estas regras para os proximos meses. Em 07/02/21, por Marcos A.
					ZN3->(MSUnlock())

				EndIf

				EMP->(dbSkip())
			End

		Else

			//Define empresas para busca das informacoes
			cSql := " SELECT ZN4_MESANO, "
			cSql += "        ZN4_EMPDES "
			cSql += " FROM " + RetSqlName("ZN4") + " ZN4(NOLOCK)"
			cSql += " WHERE	ZN4_MESANO >= '" + nMesAnoD + "' AND ZN4_MESANO <= '" + nMesAnoA + "' "
			cSql += " GROUP BY ZN4_MESANO,
			cSql += "          ZN4_EMPDES "
			cSql += " ORDER BY ZN4_MESANO, "
			cSql += "          ZN4_EMPDES "
			If chkfile("EMP")
				dbSelectArea("EMP")
				dbCloseArea()
			EndIf
			TcQuery cSql New Alias "EMP"

			While !EMP->(EOF())

				_aRet	:= {}
				U_BIAMsgRun("Aguarde... Gerando informações para Consolidação: " + ROTEIRO->ZN0_TIPO ,,{|| _aRet := TCSPEXEC("SP_BIAFG130", ROTEIRO->ZN0_CONTA, EMP->ZN4_EMPDES, EMP->ZN4_EMPDES, "01", "", EMP->ZN4_MESANO, SUBSTR(ROTEIRO->ZN0_TIPO,1,1), "") })

				If Len(_aRet) > 0

					//Grava o Lançamento de Estorno
					Reclock("ZN3",.T.)
					ZN3->ZN3_FILIAL	:=	xFilial("ZN3")
					ZN3->ZN3_CONTA	:=	ROTEIRO->ZN0_CONTA	
					ZN3->ZN3_TIPO	:=	ROTEIRO->ZN0_TIPO
					ZN3->ZN3_TPPROD	:=	ROTEIRO->ZN0_TPPROD	
					ZN3->ZN3_MESANO	:=	EMP->ZN4_MESANO	
					ZN3->ZN3_DTLANC	:=	LastDay(STOD(EMP->ZN4_MESANO+"01"),0)
					ZN3->ZN3_EMP	:=	EMP->ZN4_EMPDES	
					ZN3->ZN3_TPLANC	:=	ROTEIRO->ZN0_TPLANC	
					ZN3->ZN3_VALOR	:=	_aRet[1]
					ZN3->ZN3_FLAG	:=	"N"
					ZN3->ZN3_EMPORI	:=	EMP->ZN4_EMPDES  // Verificar como mudar estas regras para os proximos meses. Em 07/02/21, por Marcos A.
					ZN3->ZN3_EMPDES	:=	EMP->ZN4_EMPDES  // Verificar como mudar estas regras para os proximos meses. Em 07/02/21, por Marcos A.
					ZN3->ZN3_TIPVAL	:=	""               // Verificar como mudar estas regras para os proximos meses. Em 07/02/21, por Marcos A.
					ZN3->(MSUnlock())

					//Estorna o Laçamento de Estono, no mes seguinte
					If ROTEIRO->ZN0_TPLANC == "C"
						nTpLanc := "D"
					Else
						nTpLanc := "C"
					EndIf

					Reclock("ZN3",.T.)
					ZN3->ZN3_FILIAL	:=	xFilial("ZN3")
					ZN3->ZN3_CONTA	:=	ROTEIRO->ZN0_CONTA	
					ZN3->ZN3_TIPO	:=	ROTEIRO->ZN0_TIPO
					ZN3->ZN3_TPPROD	:=	ROTEIRO->ZN0_TPPROD	
					ZN3->ZN3_MESANO	:=	Substr(Dtos(MonthSum(STOD(EMP->ZN4_MESANO+"01"),1)),1,6)	
					ZN3->ZN3_DTLANC	:=	MonthSum(STOD(EMP->ZN4_MESANO+"01"),1)
					ZN3->ZN3_EMP	:=	EMP->ZN4_EMPDES	
					ZN3->ZN3_TPLANC	:=	nTpLanc	
					ZN3->ZN3_VALOR	:=	_aRet[1]
					ZN3->ZN3_FLAG	:=	"N"
					ZN3->ZN3_EMPORI	:=	EMP->ZN4_EMPDES  // Verificar como mudar estas regras para os proximos meses. Em 07/02/21, por Marcos A.
					ZN3->ZN3_EMPDES	:=	EMP->ZN4_EMPDES  // Verificar como mudar estas regras para os proximos meses. Em 07/02/21, por Marcos A.
					ZN3->ZN3_TIPVAL	:=	""               // Verificar como mudar estas regras para os proximos meses. Em 07/02/21, por Marcos A.
					ZN3->(MSUnlock())

				EndIf

				EMP->(dbSkip())

			End

		EndIf

		ROTEIRO->(dbSkip())

	End

	Msgbox("CONSOLIDAÇÃO das planilhas finalizadas com sucesso.", "BIAFG130", "INFO")

Return

USER Function BFG130C()

	Processa({|| cRptFG130() }, "Processando...", , .F.)

Return

Static Function cRptFG130()

	Local nQtdReg  := 0
	Local nEmpresa := ""
	Local msCtrlCT := .F.

	fPerg := "BIAFG130"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf	

	If Substr(dtos(MV_PAR01), 1, 6) <> Substr(dtos(MV_PAR02), 1, 6)
		MsgALERT("Não podem ser informados Ano e Mês diferentes para o intervalo de tempo a ser processado.", "Atenção!!!")
		Return
	EndIf

	nMesAnoD := Substr(Dtos(MV_PAR01),1,6)
	nMesAnoA := Substr(Dtos(MV_PAR02),1,6)

	cSql := " SELECT *, "
	cSql += "        ROW_ID = "
	cSql += " ( "
	cSql += "     SELECT COUNT(*) "
	cSql += "     FROM " + RetSqlName("ZN3") + " ZN3(NOLOCK) "
	cSql += "     WHERE ZN3_FILIAL = '" + xFilial("ZN3") + "' "
	cSql += "           AND ZN3_MESANO = '" + nMesAnoD + "' "
	cSql += "           AND ZN3_VALOR <> 0 "
	cSql += "           AND ZN3_FLAG = 'N' "
	cSql += "           AND ZN3.D_E_L_E_T_ = ' ' "
	cSql += " ) "
	cSql += " FROM " + RetSqlName("ZN3") + " ZN3(NOLOCK) "
	cSql += " WHERE ZN3_FILIAL = '" + xFilial("ZN3") + "' "
	cSql += "       AND ZN3_MESANO = '" + nMesAnoD + "' "
	cSql += "       AND ZN3_VALOR <> 0 "
	cSql += "       AND ZN3_FLAG = 'N' "
	cSql += "       AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY ZN3_EMP, ZN3_DTLANC, ZN3_TIPO "
	If chkfile("CONSOL")
		dbSelectArea("CONSOL")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "CONSOL"

	fgLanPad := "P04"
	fgLotCtb := "002400"
	fgVetCtb := {}

	nFilEmp	 := CONSOL->ZN3_EMP
	DtLanc	 := CONSOL->ZN3_DTLANC
	nQtdReg  := CONSOL->ROW_ID

	ProcRegua(nQtdReg)
	While !CONSOL->(EOF())

		If CONSOL->ZN3_EMP == "01"
			nEmpresa := "BIANCOGRES"
		ElseIf CONSOL->ZN3_EMP == "05"
			nEmpresa := "INCESA"
		ElseIf CONSOL->ZN3_EMP == "06"
			nEmpresa := "JK"
		ElseIf CONSOL->ZN3_EMP == "07"
			nEmpresa := "LM"
		ElseIf CONSOL->ZN3_EMP == "12"
			nEmpresa := "ST GESTÃO"
		ElseIf CONSOL->ZN3_EMP == "13"
			nEmpresa := "MUNDI"
		ElseIf CONSOL->ZN3_EMP == "14"
			nEmpresa := "VITCER"
		EndIf

		IncProc("Contabilizando Expurgos... " + nEmpresa)

		If nFilEmp <> CONSOL->ZN3_EMP .Or. 	DtLanc <> CONSOL->ZN3_DTLANC

			msFilOld := nFilEmp //Em 07/02/21, por Marcos A.
			nFilEmp  := "90"    //Em 07/02/21, por Marcos A.
			StartJob( "U_fCtResul", GetEnvServer(), .T., cEmpAnt, nFilEmp, fgLanPad, fgLotCtb, fgVetCtb, Stod(DtLanc))
			fgVetCtb := {}
			nFilEmp  := msFilOld //Em 07/02/21, por Marcos A.

			msCtrlCT := .T.

		EndIf

		nFilEmp	:= CONSOL->ZN3_EMP
		DtLanc	:= CONSOL->ZN3_DTLANC

		msTIPO   := AllTrim(CONSOL->ZN3_TIPO)   + Space( TamSX3("ZN3_TIPO")[1] - Len(AllTrim(CONSOL->ZN3_TIPO)))
		msTPPROD := AllTrim(CONSOL->ZN3_TPPROD) + Space( TamSX3("ZN3_TPPROD")[1] - Len(AllTrim(CONSOL->ZN3_TPPROD)))
		msEMPORI := AllTrim(CONSOL->ZN3_EMPORI) + Space( TamSX3("ZN3_EMPORI")[1] - Len(AllTrim(CONSOL->ZN3_EMPORI)))
		msEMPDES := AllTrim(CONSOL->ZN3_EMPDES) + Space( TamSX3("ZN3_EMPDES")[1] - Len(AllTrim(CONSOL->ZN3_EMPDES)))
		Aadd(fgVetCtb, {CONSOL->ZN3_TPLANC, CONSOL->ZN3_CONTA, Abs(CONSOL->ZN3_VALOR), "VLR. REF. CONSOLIDACAO EMPRESA", "P04 " + msTIPO + " " + msTPPROD + " " + "EMPORI: " + msEMPORI + " " + "EMPDES: " + msEMPDES })

		CONSOL->(dbSkip())
	End

	If nFilEmp <> CONSOL->ZN3_EMP .Or. 	DtLanc <> CONSOL->ZN3_DTLANC

		msFilOld := nFilEmp //Em 07/02/21, por Marcos A.
		nFilEmp  := "90"    //Em 07/02/21, por Marcos A.
		StartJob( "U_fCtResul", GetEnvServer(), .T., cEmpAnt, nFilEmp, fgLanPad, fgLotCtb, fgVetCtb, Stod(DtLanc))
		fgVetCtb := {}
		nFilEmp  := msFilOld //Em 07/02/21, por Marcos A.

		msCtrlCT := .T.

	EndIf

	If msCtrlCT

		cSql := " UPDATE " + RetSqlName("ZN3") + " SET ZN3_FLAG = 'S' "
		cSql += " WHERE ZN3_FILIAL = '" + xFilial("ZN3") + "' "
		cSql += "       AND ZN3_MESANO = '" + nMesAnoD + "' "
		cSql += "       AND ZN3_FLAG = 'N' "
		cSql += "       AND D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Gravando como processado... ",,{|| TcSQLExec(cSql) })

		Msgbox("Contabilização dos Expurgos finalizada com sucesso.", "BIAFG130", "INFO")

	Else 

		MsgSTOP("Nenhum registros de Contabilização dos Expurgos foi efetuado. Favor verificar as etapas anteriores deste processamento.", "BIAFG130")

	EndIf

Return

User Function fCtResul(cEmp, cFil, fgLanPad, fgLotCtb, fgVetCtb, dData)

	RPCSetType(3)
	RPCSETENV(cEmp,cFil,,,"CTB")

	dDataBase  := dData

	U_FG130tbA(fgLanPad, fgLotCtb, fgVetCtb)

	RpcClearEnv()

Return()

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ FG130tbA     ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 30/01/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Rotina desenvolvida para contabilizações avulsas diversas ¦¦¦
¦¦¦          ¦ Ela recebe um vetor contendo as informações necessárias    ¦¦¦
¦¦¦          ¦ para a montagem do lançamento, como por exemplo conta deb. ¦¦¦
¦¦¦          ¦ conta cred., valor, centro de custo, histórico, etc.       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FG130tbA(fgLanPad, fgLotCtb, fgVetCtb)

	Local  hj

	Private LCABECALHO, CPADRAO, LPADRAO, NTOTAL, CLOTE, LDIGITA
	Private LAGLUT, CARQUIVO, AROTINA, NHDLPRV
	Private cdeb, ccred, chis, nval, cult

	Public msVthj01
	Public msVthj02
	Public msVthj03
	Public msVthj04
	Public msVthj05

	lCabecalho := .F.
	cPadrao    := fgLanPad
	lPadrao    := .F.
	nTotal     := 0
	clote      := fgLotCtb
	lDigita    := .T.
	lAglut     := .F.
	carquivo   := ""
	aRotina    := {}
	aArrayCt   := fgVetCtb

	c_contad := 0
	For hj := 1 to Len(aArrayCt)

		c_contad ++
		lPadrao := VerPadrao( cPadrao )
		If lPadrao

			If !lCabecalho
				a370Cabecalho(@nHdlPrv,@cArquivo)
			Endif

			msVthj01 := aArrayCt[hj][1]
			msVthj02 := aArrayCt[hj][2]
			msVthj03 := aArrayCt[hj][3]
			msVthj04 := aArrayCt[hj][4]
			msVthj05 := aArrayCt[hj][5]

			nTotal  := nTotal + DetProva(nHdlPrv, cPadrao, "FG130tbA", cLote)
			cult := .F.

		EndIf

		If c_contad == 900
			c := 2
			Exit
		EndIf

	Next hj

	If lCabecalho
		RodaProva(nHdlPrv,nTotal)
	Endif

	If lPadrao
		cA100Incl(cArquivo ,nHdlPrv ,3,cLote ,lDigita , lAglut  )
	End

	If cult == .F.
		fbCont()
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fbCont        ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 30/01/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fbCont()

	If lCabecalho
		RodaProva(nHdlPrv,nTotal)
	Endif
	If lPadrao
		cA100Incl(cArquivo ,nHdlPrv ,3,cLote ,lDigita , lAglut  )
	End

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

Static function __Dummy()

	If (.F.)
		Menudef()
		__Dummy()
	Endif

Return(.F.)
