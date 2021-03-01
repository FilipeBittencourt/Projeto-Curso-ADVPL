#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA501
@author Marcos Alberto Soprani
@since 20/06/14
@version 1.0
@description Cadastro de Parâmetros para Custo
@type function
/*/

/*/{Protheus.doc} BIA501
@author Artur Antunes
@since 19/04/17
@version 1.1
@description Inclusão de controle de processamento via SX6 (MV_YULRAC) 
@obs OS 2304-16
@type function
/*/

User Function BIA501()

	Local oDlg
	Local oRadio
	Local nRadio
	Local nOpca := 1

	While nOpca == 1

		DEFINE MSDIALOG oDlg FROM  94,1 TO 350,293 TITLE "Parâmetros para Custo" PIXEL

		@ 05,17 Say "Cadastro de Parâmetros para Custo:" SIZE 150,7 OF oDlg PIXEL

		@ 17,07 TO 110, 140 OF oDlg  PIXEL

		@ 25,10 Radio 	oRadio VAR nRadio;
		ITEMS "Capacidade Produtiva";
		SIZE 110,10 OF oDlg PIXEL

		DEFINE SBUTTON FROM 115,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
		DEFINE SBUTTON FROM 115,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)

		If nOpca == 1

			If nRadio == 1
				BIA501Brw("Z42", nRadio)					// Capacidade Produtiva

			EndIf

		EndIf

	EndDo

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA501Brw ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 27.07.15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA501Brw(brwTabl, xFunCad)

	private cTab	:= brwTabl
	private bOpcao3 := {|| fOpcoes(cTab,0,3)} 
	private bOpcao4 := {|| fOpcoes(cTab,Recno(),4)} 
	private bOpcao5 := {|| fOpcoes(cTab,Recno(),5)} 
	private bOpcao6 := {|| fOpcoes(cTab,Recno(),6)} 

	dbSelectArea("SX2")
	dbSeek(brwTabl)

	If xFunCad <> 1

		AxCadastro(SX2->X2_CHAVE, Upper(Alltrim(SX2->X2_NOME)))

	Else

		cCadastro := Upper(Alltrim(SX2->X2_NOME))
		aRotina   := { {"Pesquisar"       ,"AxPesqui"	    				,0,1},;
		{               "Visualizar"      ,"AxVisual"	    				,0,2},;
		{               "Incluir"         ,"EVAL(bOpcao3)"					,0,3},;
		{               "Alterar"         ,"EVAL(bOpcao4)"					,0,4},;
		{               "Excluir"         ,"EVAL(bOpcao5)"					,0,5},;
		{               "Orc p/ Ajustado" ,"EVAL(bOpcao6)"					,0,6},;
		{               "Imprimir"        ,'ExecBlock("BIA501CP",.F.,.F.)'  ,0,7},;
		{               "Atualiza Linha"  ,'ExecBlock("BIA501AL",.F.,.F.)'  ,0,8},;
		{               "Importar"        ,'ExecBlock("B501Impt",.F.,.F.)'  ,0,9}}

		dbSelectArea(brwTabl)
		dbSetOrder(1)
		dbGoTop()

		mBrowse(06,01,22,75,brwTabl)

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA501CP  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 27.07.15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA501CP()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	fPerg := "BIA501CP"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	aCampos := {}
	AADD(aCampos,{ "LINHA     ", "C", 03, 0 })
	AADD(aCampos,{ "FORMATO   ", "C", 02, 0 })
	AADD(aCampos,{ "DFORMATO  ", "C", 30, 0 })
	AADD(aCampos,{ "BASE      ", "C", 03, 0 })
	AADD(aCampos,{ "DBASE     ", "C", 30, 0 })
	AADD(aCampos,{ "JAN       ", "N", 15, 2 })
	AADD(aCampos,{ "DJAN      ", "N", 15, 2 })
	AADD(aCampos,{ "PJAN      ", "N", 15, 3 })
	AADD(aCampos,{ "FEV       ", "N", 15, 2 })
	AADD(aCampos,{ "DFEV      ", "N", 15, 2 })
	AADD(aCampos,{ "PFEV      ", "N", 15, 3 })
	AADD(aCampos,{ "MAR       ", "N", 15, 2 })
	AADD(aCampos,{ "DMAR      ", "N", 15, 2 })
	AADD(aCampos,{ "PMAR      ", "N", 15, 3 })
	AADD(aCampos,{ "ABR       ", "N", 15, 2 })
	AADD(aCampos,{ "DABR      ", "N", 15, 2 })
	AADD(aCampos,{ "PABR      ", "N", 15, 3 })
	AADD(aCampos,{ "MAI       ", "N", 15, 2 })
	AADD(aCampos,{ "DMAI      ", "N", 15, 2 })
	AADD(aCampos,{ "PMAI      ", "N", 15, 3 })
	AADD(aCampos,{ "JUN       ", "N", 15, 2 })
	AADD(aCampos,{ "DJUN      ", "N", 15, 2 })
	AADD(aCampos,{ "PJUN      ", "N", 15, 3 })
	AADD(aCampos,{ "JUL       ", "N", 15, 2 })
	AADD(aCampos,{ "DJUL      ", "N", 15, 2 })
	AADD(aCampos,{ "PJUL      ", "N", 15, 3 })
	AADD(aCampos,{ "AGO       ", "N", 15, 2 })
	AADD(aCampos,{ "DAGO      ", "N", 15, 2 })
	AADD(aCampos,{ "PAGO      ", "N", 15, 3 })
	AADD(aCampos,{ "SET       ", "N", 15, 2 })
	AADD(aCampos,{ "DSET      ", "N", 15, 2 })
	AADD(aCampos,{ "PSET      ", "N", 15, 3 })
	AADD(aCampos,{ "OUT       ", "N", 15, 2 })
	AADD(aCampos,{ "DOUT      ", "N", 15, 2 })
	AADD(aCampos,{ "POUT      ", "N", 15, 3 })
	AADD(aCampos,{ "NOV       ", "N", 15, 2 })
	AADD(aCampos,{ "DNOV      ", "N", 15, 2 })
	AADD(aCampos,{ "PNOV      ", "N", 15, 3 })
	AADD(aCampos,{ "DEZ       ", "N", 15, 2 })
	AADD(aCampos,{ "DDEZ      ", "N", 15, 2 })
	AADD(aCampos,{ "PDEZ      ", "N", 15, 3 })
	T001 := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,, T001, "T001")
	DbCreateInd(T001, "LINHA+FORMATO+BASE", {|| LINHA+FORMATO+BASE})

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Capacidade produtiva para custo RAC - ano ref.: " + MV_PAR01

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "LINHA"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORMATO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DFORMATO"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "BASE"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DBASE"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "JAN"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS JAN"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECOJAN"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FEV"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS FEV"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECOFEV"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MAR"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS MAR"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECOMAR"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ABR"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS ABR"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECOABR"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MAI"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS MAI"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECOMAI"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "JUN"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS JUN"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECOJUN"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "JUL"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS JUL"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECOJUL"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "AGO"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS AGO"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECOAGO"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SET"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS SET"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECOSET"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "OUT"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS OUT"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECOOUT"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOV"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS NOV"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECONOV"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DEZ"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS DEZ"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECODEZ"        ,1,1)

	ES004 := " SELECT SUBSTRING(Z42_DTFIM,1,6) DTREF, "
	ES004 += "        Z42_LINHA LINHA, "
	ES004 += "        Z42_FORMAT FORMAT, "
	ES004 += "        ZZ6_DESC DFORMAT, "
	ES004 += "        Z42_BASE BASE, "
	ES004 += "        Z32_DESCR DBASE, "
	ES004 += "        Z42_CAPACI CAPACID, "
	ES004 += "        Z42_DNMES DNMES, "
	ES004 += "        Z42_PSECO PSECO "
	ES004 += "   FROM " + RetSqlName("Z42") + " Z42(NOLOCK) "
	ES004 += "  INNER JOIN " + RetSqlName("ZZ6") + " ZZ6(NOLOCK) ON ZZ6.ZZ6_FILIAL = '" + xFilial("ZZ6") + "' "
	ES004 += "                       AND ZZ6.ZZ6_COD = Z42.Z42_FORMAT "
	ES004 += "                       AND ZZ6.D_E_L_E_T_ = ' ' "
	ES004 += "  INNER JOIN " + RetSqlName("Z32") + " Z32(NOLOCK) ON Z32.Z32_FILIAL = '" + xFilial("Z32") + "' "
	ES004 += "                       AND Z32.Z32_CODIGO = Z42.Z42_BASE "
	ES004 += "                       AND Z32.D_E_L_E_T_ = ' ' "
	ES004 += "  WHERE Z42.Z42_FILIAL = '" + xFilial("Z42") + "' "
	ES004 += "    AND Z42.Z42_DTFIM BETWEEN '" + MV_PAR01 + "0131' AND '" + MV_PAR01 + "1231' "
	ES004 += "    AND Z42.Z42_FINALI IN('" + IIF(MV_PAR02 == 1, "R", "O','I") + "') "
	ES004 += "    AND Z42.Z42_VERSAO = '" + MV_PAR03 + "' "
	ES004 += "    AND Z42.Z42_REVISA = '" + MV_PAR04 + "' "
	ES004 += "    AND Z42.Z42_ANOREF = '" + MV_PAR05 + "' "
	ES004 += "    AND Z42.D_E_L_E_T_ = ' ' "
	ES004 += "  ORDER BY Z42_DTFIM, Z42_LINHA, Z42_FORMAT, Z42_BASE "
	ESIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ES004),'ES04',.T.,.T.)
	dbSelectArea("ES04")
	dbGoTop()
	While !Eof()

		dbSelectArea("T001")
		dbSetOrder(1)
		If !dbSeek(ES04->LINHA + ES04->FORMAT + ES04->BASE)
			RecLock("T001",.T.)
			T001->LINHA    := ES04->LINHA
			T001->FORMATO  := ES04->FORMAT
			T001->DFORMATO := ES04->DFORMAT
			T001->BASE     := ES04->BASE
			T001->DBASE    := ES04->DBASE
		Else
			RecLock("T001",.F.)
		EndIf
		&("T001->"+Substr(UPPER(MesExtenso(Substr(ES04->DTREF,5,2))),1,3))  := ES04->CAPACID
		&("T001->D"+Substr(UPPER(MesExtenso(Substr(ES04->DTREF,5,2))),1,3)) := ES04->DNMES
		&("T001->P"+Substr(UPPER(MesExtenso(Substr(ES04->DTREF,5,2))),1,3)) := ES04->PSECO

		MsUnLock()

		dbSelectArea("ES04")
		dbSkip()
	End

	ES04->(dbCloseArea())
	Ferase(ESIndex+GetDBExtension())
	Ferase(ESIndex+OrdBagExt())

	dbSelectArea("T001")
	dbGoTop()
	While !Eof()

		IncProc("Processando...")

		oExcel:AddRow(nxPlan, nxTabl, { T001->LINHA, T001->FORMATO, T001->DFORMATO, T001->BASE, T001->DBASE, T001->JAN, T001->DJAN, T001->PJAN, T001->FEV, T001->DFEV, T001->PFEV, T001->MAR, T001->DMAR, T001->PMAR, T001->ABR, T001->DABR, T001->PABR, T001->MAI, T001->DMAI, T001->PMAI, T001->JUN, T001->DJUN, T001->PJUN, T001->JUL, T001->DJUL, T001->PJUL, T001->AGO, T001->DAGO, T001->PAGO, T001->SET, T001->DSET, T001->PSET, T001->OUT, T001->DOUT, T001->POUT, T001->NOV, T001->DNOV, T001->PNOV, T001->DEZ, T001->DDEZ, T001->PDEZ  })

		dbSelectArea("T001")
		dbSkip()

	End

	T001->(dbCloseArea())
	Ferase(T001+GetDBExtension())
	Ferase(T001+OrdBagExt())

	xArqTemp := "capacidadeprodutiva - " + cEmpAnt + " - " + MV_PAR01

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA501OP  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 07.08.15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA501OP()

	Processa({|| RptoDetail()})

Return

Static Function RptoDetail()

	Local msStaExcQy  := 0
	Local lOk         := .T.

	fPerg := "BIA501OP"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidxPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	if !U_BiaULRAC(MV_PAR01)
		Return
	endif

	hsIniDt := Substr(dtos(MV_PAR01-1),1,6) + "01"
	hsFimDt := dtos(MV_PAR01-1)
	hsDiaMs := MV_PAR02 - MV_PAR01 + 1

	Begin Transaction

		//                               Zera Valores para que não ocorra erros em caso se reprocessamento
		**************************************************************************************************
		ZP003 := " DELETE " + RetSqlName("Z42") + " "
		ZP003 += "   FROM " + RetSqlName("Z42") + " WITH (NOLOCK) "
		ZP003 += "  WHERE Z42_FILIAL = '" + xFilial("Z42") + "' "
		ZP003 += "    AND Z42_FINALI = 'R' "
		ZP003 += "    AND Z42_DTFIM BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
		ZP003 += "    AND D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Apagando registros ... ",,{|| msStaExcQy := TcSQLExec(ZP003) })
		If msStaExcQy < 0
			lOk := .F.
		EndIf

		If lOk

			QT008 := " INSERT INTO " + RetSqlName("Z42") + " "
			QT008 += " (Z42_FILIAL, "
			QT008 += "  Z42_DTINI, "
			QT008 += "  Z42_DTFIM, "
			QT008 += "  Z42_LINHA, "
			QT008 += "  Z42_FORMAT, "
			QT008 += "  Z42_BASE, "
			QT008 += "  Z42_ACABAM, "
			QT008 += "  Z42_CAPACI, "
			QT008 += "  Z42_TPPROD, "
			QT008 += "  D_E_L_E_T_, "
			QT008 += "  R_E_C_N_O_, "
			QT008 += "  Z42_PSECO, "
			QT008 += "  Z42_DNMES, "
			QT008 += "  Z42_FINALI, "
			QT008 += "  Z42_ESPESS, "
			QT008 += "  Z42_DISTRI, "
			QT008 += "  Z42_VERSAO, "
			QT008 += "  Z42_REVISA, "
			QT008 += "  Z42_ANOREF) "
			QT008 += " SELECT Z42_FILIAL, "
			QT008 += "        '" + dtos(MV_PAR01) + "' Z42_DTINI, "
			QT008 += "        '" + dtos(MV_PAR02) + "' Z42_DTFIM, "
			QT008 += "        Z42_LINHA, "
			QT008 += "        Z42_FORMAT, "
			QT008 += "        Z42_BASE, "
			QT008 += "        Z42_ACABAM, "
			QT008 += "        Z42_CAPACI, "
			QT008 += "        Z42_TPPROD, "
			QT008 += "        D_E_L_E_T_, "
			QT008 += "        (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("Z42") + ") + ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) AS R_E_C_N_O_, "
			QT008 += "        Z42_PSECO, "
			QT008 += "        '" + Alltrim(Str(hsDiaMs)) + "' Z42_DNMES, "
			QT008 += "        'R' Z42_FINALI, "
			QT008 += "        Z42_ESPESS, "
			QT008 += "        1 Z42_DISTRI, "
			QT008 += "        '" + MV_PAR03 + "' Z42_VERSAO, "
			QT008 += "        '" + MV_PAR04 + "' Z42_REVISA, "
			QT008 += "        '" + MV_PAR05 + "' Z42_ANOREF "
			QT008 += "   FROM " + RetSqlName("Z42") + " (NOLOCK) "
			QT008 += "  WHERE Z42_FILIAL = '" + xFilial("Z42") + "' "

			If Substr(dtos(MV_PAR01), 5, 2) == "01"

				QT008 += "    AND Z42_DTFIM BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
				QT008 += "    AND Z42_CAPACI <> 0 "
				QT008 += "    AND Z42_FINALI IN('O') "
				QT008 += "    AND Z42_VERSAO = '" + MV_PAR03 + "' "
				QT008 += "    AND Z42_REVISA = '" + MV_PAR04 + "' "
				QT008 += "    AND Z42_ANOREF = '" + MV_PAR05 + "' "

			Else

				QT008 += "    AND Z42_DTFIM BETWEEN '" + hsIniDt + "' AND '" + hsFimDt + "' "
				QT008 += "    AND Z42_CAPACI <> 0 "
				QT008 += "    AND Z42_FINALI IN('R') "
				QT008 += "    AND Z42_VERSAO + Z42_REVISA + Z42_ANOREF IN "
				QT008 += "    ( "
				QT008 += "        SELECT MAX(Z42_VERSAO + Z42_REVISA + Z42_ANOREF) "
				QT008 += "        FROM " + RetSqlName("Z42") + " "
				QT008 += "        WHERE Z42_FILIAL = '"+xFilial("Z42")+"' "
				QT008 += "              AND Z42_DTFIM BETWEEN '" + hsIniDt + "' AND '" + hsFimDt + "' "
				QT008 += "              AND Z42_CAPACI <> 0 "
				QT008 += "              AND Z42_FINALI IN('R') "
				QT008 += "        AND D_E_L_E_T_ = ' ' "
				QT008 += "    ) "

			EndIf

			QT008 += "   AND D_E_L_E_T_ = ' ' "

			U_BIAMsgRun("Gravando ...",,{|| msStaExcQy := TcSQLExec(QT008)})

			If msStaExcQy < 0
				lOk := .F.
			EndIf

		EndIf

		If !lOk

			msGravaErr := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction 

	If lOk

		Aviso('BIA501OP', 'Rotina realizada!!! Favor verificar se foram gerados registros para o período do processamento.',{'Ok'})

	Else

		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )

	EndIf

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
	aAdd(aRegs,{cPerg,"01","Ano de Referência        ?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Finalidade               ?","","","mv_ch2","N",01,0,0,"C","","mv_par02","Real","","","","","Orçado","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Versão Orçamentária      ?","","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"04","Revisão Ativa            ?","","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Ano de Referência        ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidxPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Versão Orçamentária      ?","","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"04","Revisão Ativa            ?","","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Ano de Referência        ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

static function fOpcoes(cAlias,nReg,nOpc)

	private cAliasX	:= cAlias
	private nRegX	:= nReg
	private nOpcX	:= nOpc
	private bTudoOK := {|| fTuudoOK(cAliasX,nRegX,nOpcX)} 

	do case
		case nOpc == 3
		AxInclui(cAlias,nReg,nOpc,Nil,Nil,Nil,"EVAL(bTudoOK)")
		case nOpc == 4
		if U_BiaULRAC((cAlias)->Z42_DTINI)
			AxAltera(cAlias,nReg,nOpc,Nil,Nil,Nil,Nil,"EVAL(bTudoOK)")
		endif	
		case nOpc == 5 
		if U_BiaULRAC((cAlias)->Z42_DTINI)
			AxDeleta(cAlias,nReg,nOpc)
		endif	
		case nOpc == 6
		ExecBlock("BIA501OP",.F.,.F.)
	endcase

return

static function fTuudoOK(cAlias,nReg,nOpc)

	local lRet	:= .T.

	if lRet
		lRet := U_BiaULRAC(M->Z42_DTINI)
	endif

return lRet

User Function BIA501AL()

	Local _cSql
	Local _cAlias
	Local _cDataFim

	If !VPergLin()
		Return
	EndIf

	_cDataFim	:=	DtoS(MV_PAR01)
	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		SELECT TOP 1 ISNULL(MIN(Z42_DTINI),'') DINI
		FROM %TABLE:Z42%
		WHERE Z42_FILIAL = %XFILIAL:Z42%
		AND Z42_LINHA = %EXP:MV_PAR03%
		AND Z42_DTFIM = %Exp:_cDataFim%
		AND Z42_FINALI = %Exp:MV_PAR02%
		AND %NotDel%
	EndSql

	If !Empty((_cAlias)->DINI) .AND. U_BiaULRAC(StoD((_cAlias)->DINI)) 

		_cSql	:=	"UPDATE " + RetSqlName("Z42")
		_cSql	+=	" SET Z42_DISTRI = " + ValtoSql(MV_PAR04) 
		_cSql	+=	" WHERE Z42_FILIAL = " + ValTosql(xFilial("Z42")) 
		_cSql	+=	" 		AND Z42_DTFIM = " + ValTosql(MV_PAR01) 
		_cSql	+=	" 		AND Z42_FINALI = " + ValtoSql(MV_PAR02)
		_cSql	+=	" 		AND Z42_LINHA = " + ValToSql(MV_PAR03)
		_cSql	+=	" 		AND D_E_L_E_T_ = '' " 

		TcSqlExec(_cSql)

		MsgInfo("Informações Atualizadas com Sucesso")

	EndIf

	(_cAlias)->(DbCloseArea())

Return

Static Function VPergLin()

	local cLoad	    := "BIA501AL" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := STOD('')
	MV_PAR02 := SPACE(1)
	MV_PAR03 := SPACE(TAMSX3("Z42_LINHA")[1])
	MV_PAR04 := 0

	aAdd( aPergs ,{1,"Data Refer." 	   		,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.T.})	
	aAdd( aPergs ,{2,"Finalidade" 	   		,MV_PAR02 ,{'O=Orçamento','R=Realizado','I=Indefinido'} ,50,"",.T.})
	aAdd( aPergs ,{1,"Linha" 	   			,MV_PAR03 ,""  ,"NAOVAZIO()",'UA'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Data Refer." 	   		,MV_PAR04 ,PesqPict( "Z42", "Z42_DISTRI" )  ,"",''  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Alteração de Linha",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)

	EndIf

Return lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ B501Impt  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 23/09/19 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B501Impt()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("Z42") + SPACE(TAMSX3("Z42_VERSAO")[1]) + SPACE(TAMSX3("Z42_REVISA")[1]) + SPACE(TAMSX3("Z42_ANOREF")[1])
	Local bWhile	    := {|| Z42_FILIAL + Z42_VERSAO + Z42_REVISA + Z42_ANOREF }   

	Local aNoFields     := {"Z42_VERSAO", "Z42_REVISA", "Z42_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("Z42_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("Z42_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("Z42_ANOREF")[1])
	Private _oGAnoRef

	Private _msCtrlAlt := .T.  

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B501IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})
	aAdd(_aButtons,{"AUTOM"   ,{|| U_B501RPLC() }, "Replica Registros" , "Replica Registros"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"Z42",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Capacidade Produtiva" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA501A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA501B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA501C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, "U_B501TOK()" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, /*cFieldOK*/, /*[ cSuperDel]*/, /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA501A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA501D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA501B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA501D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA501C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA501D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA501D()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local _msc

	Private msrhEnter := CHR(13) + CHR(10)	

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e menor ou igual a DataBase" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		_msCtrlAlt := .F.
		_oGetDados:lInsert := .F.
		_oGetDados:lUpdate := .F.
		_oGetDados:lDelete := .F.
	Else
		_msCtrlAlt := .T.
		_oGetDados:lInsert := .T.
		_oGetDados:lUpdate := .T.
		_oGetDados:lDelete := .T.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *,
		(SELECT COUNT(*)
		FROM %TABLE:Z42% Z42
		WHERE Z42_FILIAL = %xFilial:Z42%
		AND Z42_VERSAO = %Exp:_cVersao%
		AND Z42_REVISA = %Exp:_cRevisa%
		AND Z42_ANOREF = %Exp:_cAnoRef%
		AND Z42_FINALI = 'O'
		AND Z42.%NotDel%
		) NUMREG
		FROM %TABLE:Z42% Z42
		WHERE Z42_FILIAL = %xFilial:Z42%
		AND Z42_VERSAO = %Exp:_cVersao%
		AND Z42_REVISA = %Exp:_cRevisa%
		AND Z42_ANOREF = %Exp:_cAnoRef%
		AND Z42_FINALI = 'O'
		AND Z42.%NotDel%
		ORDER BY Z42_VERSAO, Z42_REVISA, Z42_ANOREF, Z42_DTINI, Z42_DTFIM, Z42_LINHA, Z42_FORMAT, Z42_BASE, Z42_ACABAM

	EndSql

	xtrTot :=  (_cAlias)->(NUMREG)
	ProcRegua(xtrTot)

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "Z42_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "Z42"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z42_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) $ "Z42_DTINI/Z42_DTFIM"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Stod(&(Alltrim(_oGetDados:aHeader[_msc][2])))

				Else
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

				EndIf			
			Next _msc
			_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := .F.	

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI
	Local _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If !fDelPeriod()
		Return
	EndIF

	dbSelectArea('Z42')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			Z42->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("Z42",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("Z42->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

			Else

				Z42->(DbDelete())

			EndIf

			Z42->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("Z42",.T.)

				Z42->Z42_FILIAL  := xFilial("Z42")
				Z42->Z42_VERSAO  := _cVersao
				Z42->Z42_REVISA  := _cRevisa
				Z42->Z42_ANOREF  := _cAnoRef
				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("Z42->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

				Z42->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao        := SPACE(TAMSX3("Z42_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("Z42_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("Z42_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B501IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B501IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !_msCtrlAlt

		MsgInfo("Não é permitido importar dados porque a Versão orçamentária está bloquada.")
		Return

	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Índices de Variação da Quantidade da Pre-Estr."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Índices...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B501IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'Z42'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb
	Local ny
	Local _msc
	Local nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_REC_WT"})
	Local vtRecGrd := {}

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 to Len(_ImpaColsBkp)
		AADD(vtRecGrd, _ImpaColsBkp[vnb][nPosRec])	
	Next vnb

	If Len(vtRecGrd) == 1
		nPrimeralin := _ImpaColsBkp[Len(_ImpaColsBkp)][nPosRec]
		If nPrimeralin == 0
			_oGetDados:aCols := {}
		EndIf
	EndIf

	_oGetDados:aCols	:=	{}

	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If Len(aArquivo) > 0 

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		For nx := 1 to len(aWorksheet) 

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

			If nx == 1

				aCampos := aWorksheet[nx]
				For ny := 1 to len(aCampos)
					cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
					aCampos[ny] := cTemp
				Next ny

			Else

				aLinha    := aWorksheet[nx]
				aItem     := {}
				cConteudo := ''

				nLinReg   := 0
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "Z42_REC_WT"})

				azDTINI    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_DTINI"})
				azDTFIM    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_DTFIM"})
				azLINHA    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_LINHA"})
				azFORMAT   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_FORMAT"})
				azBASE     := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_BASE"})
				azACABAM   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_ACABAM"})
				azESPESS   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_ESPESS"})
				azTPPROD   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_TPPROD"})
				azRecno	   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_REC_WT"})

				vtDTINI     := aScan(aCampos,{|x| AllTrim(x) == "Z42_DTINI"})
				vtDTFIM     := aScan(aCampos,{|x| AllTrim(x) == "Z42_DTFIM"})
				vtLINHA     := aScan(aCampos,{|x| AllTrim(x) == "Z42_LINHA"})
				vtFORMAT    := aScan(aCampos,{|x| AllTrim(x) == "Z42_FORMAT"})
				vtBASE      := aScan(aCampos,{|x| AllTrim(x) == "Z42_BASE"})
				vtACABAM    := aScan(aCampos,{|x| AllTrim(x) == "Z42_ACABAM"})
				vtESPESS    := aScan(aCampos,{|x| AllTrim(x) == "Z42_ESPESS"})
				vtTPPROD    := aScan(aCampos,{|x| AllTrim(x) == "Z42_TPPROD"})

				If nPosRec <> 0
					//Alterado por Gabriel Rossi Mafioletti para atender à solicitação de Marcos, caso precisem voltar algum dia à alterar registros
					nLinReg := 0//aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})
					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						// São muitos campos para comparar: não aprofundei para identificar onde está o problema que apesar de possuir duplicidade não está alertando. Farei um valid tudo para contornar este problema.
						nLinChave := aScan(_oGetDados:aCols,{|x| Alltrim(x[azDTINI]) + Alltrim(x[azDTFIM]) + Alltrim(x[azLINHA]) + Alltrim(x[azFORMAT]) + Alltrim(x[azBASE]) + Alltrim(x[azACABAM]) + Alltrim(x[azESPESS]) + Alltrim(x[azTPPROD]) == Alltrim(aLinha[vtDTINI]) + Alltrim(aLinha[vtDTFIM]) + Alltrim(aLinha[vtLINHA]) + Alltrim(aLinha[vtFORMAT]) + Alltrim(aLinha[vtBASE]) + Alltrim(aLinha[vtACABAM]) + Alltrim(aLinha[vtESPESS]) + Alltrim(aLinha[vtTPPROD]) })
						If nLinChave <> 0

							MsgINFO("A chave oriundo do excel, já existe na tela. Linha: " + Alltrim(Str(nLinChave)) + ". O registro será desconsiderado. Atenciosamente!!!")

						Else

							AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
							nLinReg := Len(_oGetDados:aCols)

						EndIf

					EndIf				

					For _msc := 1 to Len(aCampos)

						xkPosCampo := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == aCampos[_msc]})
						If xkPosCampo <> 0
							If _oGetDados:aHeader[xkPosCampo][8] == "N"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Val(Alltrim(aLinha[_msc]))

							ElseIf _oGetDados:aHeader[xkPosCampo][8] == "D"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Stod(Replace(substr(aLinha[_msc],1,10),'-',''))

							Else
								_oGetDados:aCols[nLinReg, xkPosCampo] := aLinha[_msc]

							EndIf
						EndIf

					Next _msc
					_oGetDados:aCols[nLinReg,azRecno]	:=	0
					_oGetDados:aCols[nLinReg, Len(_oGetDados:aHeader)+1] := .F.	
					nImport ++

				Else

					MsgALERT("Erro no Layout do Arquivo de Importação!!!")
					nImport := 0
					Exit

				EndIf

			EndIf

		Next nx

	EndIf

	If nImport > 0 
		MsgInfo("Registros importados com sucesso")
	Else

		MsgStop("Falha na importação dos registros")
		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf

	RestArea(aArea)

Return

User Function B501TOK()

	Local _lRet	:=	.T.
	Local _ki
	Local _PosDupl := 0
	Local _VetConf := _oGetDados:aCols
	Local _nPosDel := Len(_oGetDados:aHeader) + 1	

	azDTINI    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_DTINI"})
	azDTFIM    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_DTFIM"})
	azLINHA    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_LINHA"})
	azFORMAT   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_FORMAT"})
	azBASE     := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_BASE"})
	azACABAM   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_ACABAM"})
	azESPESS   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_ESPESS"})
	azTPPROD   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_TPPROD"})

	For _ki	:=	1 to Len(_VetConf)

		If !_VetConf[_ki, _nPosDel]

			_PosDupl := aScan(_VetConf,{|x| Alltrim(dtos(x[azDTINI])) + Alltrim(dtos(x[azDTFIM])) + Alltrim(x[azLINHA]) + Alltrim(x[azFORMAT]) + Alltrim(x[azBASE]) + Alltrim(x[azACABAM]) + Alltrim(x[azESPESS]) + Alltrim(x[azTPPROD]) == Alltrim(dtos(_VetConf[_ki][azDTINI])) + Alltrim(dtos(_VetConf[_ki][azDTFIM])) + Alltrim(_VetConf[_ki][azLINHA]) + Alltrim(_VetConf[_ki][azFORMAT]) + Alltrim(_VetConf[_ki][azBASE]) + Alltrim(_VetConf[_ki][azACABAM]) + Alltrim(_VetConf[_ki][azESPESS]) + Alltrim(_VetConf[_ki][azTPPROD]) })
			If _PosDupl > 0
				If _PosDupl <> _ki
					MsgSTOP("A linha " + Alltrim(Str(_ki)) + " está duplicada se comparada a linha " + Alltrim(Str(_PosDupl)))
					_lRet := .F.
				EndIf
			EndIf

		EndIf

	Next _ki

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B501RPLC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09/09/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Replicando Registros da Versão Anterior para Corrente      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B501RPLC()

	Local M002        := GetNextAlias()
	Local mnDTINI     := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_DTINI"})
	Local mnDTFIM     := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_DTFIM"})
	Local mnDNMES     := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z42_DNMES"})
	Local _msc

	If !_msCtrlAlt

		MsgInfo("Não é permitido importar dados porque a Versão orçamentária está bloquada.")
		Return

	EndIf

	If !Empty(_oGetDados:aCols[1][1])

		MsgInfo("Não é permitido importar dados porque já existem registros contidos nesta revisão.")
		Return

	EndIf

	_oGetDados:aCols	:=	{}

	BeginSql Alias M002

		SELECT *
		FROM %TABLE:Z42% Z42
		WHERE Z42_VERSAO+Z42_REVISA+Z42_ANOREF = (SELECT MAX(Z42_VERSAO+Z42_REVISA+Z42_ANOREF)
		FROM %TABLE:Z42% Z42
		WHERE Z42_FILIAL = %xFilial:Z42%
		AND Z42_ANOREF < %Exp:_cAnoRef%
		AND Z42_FINALI = 'O'
		AND Z42.%NotDel%)
		AND Z42_FINALI = 'O'
		AND Z42.%NotDel%
		ORDER BY Z42_VERSAO, Z42_REVISA, Z42_ANOREF, Z42_DTINI, Z42_DTFIM, Z42_LINHA, Z42_FORMAT, Z42_BASE, Z42_ACABAM

	EndSql

	If (M002)->(!Eof())

		While (M002)->(!Eof())

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "Z42_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "Z42"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z42_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := 0

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) $ "Z42_DTINI"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := (M002)->(Stod( _cAnoRef + Substr(&(Alltrim(_oGetDados:aHeader[_msc][2])),5,4) ) )

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) $ "Z42_DTFIM"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := UltimoDia( (M002)->(Stod( _cAnoRef + Substr(&(Alltrim(_oGetDados:aHeader[_msc][2])),5,2) + "01" ) ) )

				Else
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := (M002)->(&(Alltrim(_oGetDados:aHeader[_msc][2])))

				EndIf			
			Next _msc

			_oGetDados:aCols[Len(_oGetDados:aCols), mnDNMES] := _oGetDados:aCols[Len(_oGetDados:aCols)][mnDTFIM] - _oGetDados:aCols[Len(_oGetDados:aCols)][mnDTINI] + 1
			_oGetDados:aCols[Len(_oGetDados:aCols), _msc]    := .F.	

			(M002)->(dbSkip())

		EndDo

		(M002)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

	MsgINFO("Replica efetuada com sucesso. Para concluir a gravação é necessário clicar em Confirmar.")

Return

Static Function fDelPeriod()

	Local _lRet	:=	.T.
	Local _cQuery

	_cQuery	:=	" UPDATE " + RetSqlName("Z42") + " SET D_E_L_E_T_ = '*' "
	_cQuery +=	" WHERE Z42_FILIAL = " + ValtoSql(xFilial("Z42")) + " "
	_cQuery +=	" 	AND Z42_VERSAO = " + ValtoSql(_cVersao) +" "
	_cQuery +=	" 	AND Z42_REVISA = " + ValtoSql(_cRevisa) +" "
	_cQuery +=	" 	AND Z42_ANOREF = " + ValtoSql(_cAnoRef) +" "
	_cQuery +=	" 	AND D_E_L_E_T_ = ' ' "

	_nError := TcSqlExec(_cQuery)

	If _nError <> 0 .And. !Empty(TcSqlError()) 
		MsgInfo("Ocorreu um Erro ao Apagar registros do orçamento selecionado para importação!")
		_lRet	:=	.F.
	Endif 

Return _lRet
