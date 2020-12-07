#Include "TOPCONN.CH"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'

/*/{Protheus.doc} BIA776
@author Marcos Alberto Soprani
@since 11/08/11
@version 1.0
@description Custo Padrão
.            Este Programa tem que estar em perfeita armonia com o BIA269 E BIA776
.            Este programa derivou do BIA776 EM 17/05/17....
@type function
/*/

User Function BIA776()

	Local _cAlias	:=	GetNExtAlias()

	Private lGravaZ46	:=	.T.

	cHInicio := Time()
	fPerg := "BIA776"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	BeginSql Alias _cAlias

		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:MV_PAR15%
		AND ZB5.ZB5_REVISA = %Exp:MV_PAR16%
		AND ZB5.ZB5_ANOREF = %Exp:MV_PAR17%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTCONS <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%

	EndSql

	(_cAlias)->(dbGoTop())
	If (_cAlias)->CONTAD <> 1
		lGravaZ46	:=	.F.
	EndIf

	(_cAlias)->(DbCloseArea())
	Processa({ || RptDetail() })

Return

Static Function RptDetail()

	Local M001        := GetNextAlias()
	Local wgt
	Private lNegEstr  := GETMV("MV_NEGESTR")
	Private aDadoX    := {}
	Private xSomaRet  := .F.
	Private xQtdRetn  := 0
	Private gtVlrRet  := .F.
	Private msrhEnter := CHR(13) + CHR(10)

	//  Usado para Filtro Aleatório
	Private oDlgCpad
	Private Confirmar
	Private oMultiGet1
	Private cMultiGet1 := ""
	Private oSay1
	Private fh_Esc     := .F.
	//*****************************

	Private cNoCfCust := AllTrim(GetNewPar("MV_YCUSCFN","1911,2911,1910,2910")) 

	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private ctplCtZero

	cNoCfCust := StrTran(cNoCfCust,"/",",") 
	cNoCfCust := StrTran(cNoCfCust,"\",",") 
	cNoCfCust := StrTran(cNoCfCust,"|",",") 
	cNoCfCust := StrTran(cNoCfCust,";",",") 

	// Temporário para gravação de custo unitário para C.VARIAVEL Orcto
	ctplCtZero := .F.
	mArry := {}
	AADD(mArry,{ "DATDE"      ,"D",08,0 } )
	AADD(mArry,{ "DATAT"      ,"D",08,0 } )
	AADD(mArry,{ "CODPROD"    ,"C",15,0 } )
	AADD(mArry,{ "COMPONE"    ,"C",15,0 } )
	AADD(mArry,{ "MOTIVO"     ,"C",30,0 } )
	T004 := CriaTrab(mArry)
	dbUseArea( .T.,, T004, "T004", .F., .F. )
	dbCreateInd(T004, "DTOS(DATDE)+DTOS(DATAT)+CODPROD+COMPONE" ,{ || Indices })

	If mv_par14 == 1

		If !U_VALOPER("T01")

			MsgSTOP("Favor verificar o preenchimento do parametro 14, pois você selecionou Sim para este parâmetro e não possui permissão para gravação de custo unitário para orçamento C.VARIAVEL. Caso necessite deste acesso, favor solicitar a TI para inclusão do seu idUser na tabela T01 do ValOper().", "OP T01")
			Return .F.

		Else

			fgContin := MsgYESNO("Você selecionou a opção para gravar os custos unitários para orçamento C.VARIAVEL (parâmetro 14). Deseja realmente prosseguir com a gravação???")
			If !fgContin

				MsgALERT("O processamento de gravação de custos unitários para orçamento C.VARIAVEL foi abortado...")
				Return .F.

			EndIf

		EndIf

	EndIf

	// Controle para gravação de C.VARIAVEL
	If MV_PAR14 == 1

		If Alltrim(FunName()) == "BIA518"

			xfMensCompl := ""
			xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
			xfMensCompl += "Status igual Fechado" + msrhEnter
			xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
			xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
			xfMensCompl += "Data Encerramento diferente de branco e menor ou igual DataBase" + msrhEnter

			BeginSql Alias M001

				SELECT COUNT(*) CONTAD
				FROM %TABLE:ZB5% ZB5
				WHERE ZB5_FILIAL = %xFilial:ZB5%
				AND ZB5.ZB5_VERSAO = %Exp:MV_PAR15%
				AND ZB5.ZB5_REVISA = %Exp:MV_PAR16%
				AND ZB5.ZB5_ANOREF = %Exp:MV_PAR17%
				AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
				AND ZB5.ZB5_STATUS = 'F'
				AND ZB5.ZB5_DTDIGT <> ''
				AND ZB5.ZB5_DTCONS <> ''
				AND ZB5.ZB5_DTENCR <> ''
				AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
				AND ZB5.%NotDel%

			EndSql

			(M001)->(dbGoTop())
			If (M001)->CONTAD <> 1
				MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
				(M001)->(dbCloseArea())
				Return .F.
			EndIf	
			(M001)->(dbCloseArea())

		Else

			xfMensCompl := ""
			xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
			xfMensCompl += "Status igual Aberto" + msrhEnter
			xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
			xfMensCompl += "Data Conciliação diferente de branco e menor ou igual DataBase" + msrhEnter
			xfMensCompl += "Data Encerramento igual branco" + msrhEnter

			BeginSql Alias M001

				SELECT COUNT(*) CONTAD
				FROM %TABLE:ZB5% ZB5
				WHERE ZB5_FILIAL = %xFilial:ZB5%
				AND ZB5.ZB5_VERSAO = %Exp:MV_PAR15%
				AND ZB5.ZB5_REVISA = %Exp:MV_PAR16%
				AND ZB5.ZB5_ANOREF = %Exp:MV_PAR17%
				AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
				AND ZB5.ZB5_STATUS = 'A'
				AND ZB5.ZB5_DTDIGT <> ''
				AND ZB5.ZB5_DTCONS <> ''
				AND ZB5.ZB5_DTCONS <= %Exp:dtos(Date())%
				AND ZB5.ZB5_DTENCR = ''
				AND ZB5.%NotDel%

			EndSql

			(M001)->(dbGoTop())
			If (M001)->CONTAD <> 1
				MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
				(M001)->(dbCloseArea())
				T004->(dbCloseArea())
				Return .F.
			EndIf	
			(M001)->(dbCloseArea())

		EndIf

	EndIf

	// Tramento incluído para atender a OS effettivo 3716-15. Por Marcos Alberto Soprani em 22/12/2015
	agrpPAR04 := ""
	If !Empty(MV_PAR04)

		QR003 := " SELECT BM_GRUPO 
		QR003 += "   FROM " + RetSqlName("SBM")
		QR003 += "  WHERE D_E_L_E_T_ = ' '
		QR003 += "    AND BM_MSBLQL <> '1'
		QR003 += "    AND BM_YAGRPCT IN "+FormatIn(MV_PAR04,",")
		QR003 += "  ORDER BY BM_GRUPO
		QRIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR003),'QR03',.T.,.T.)
		dbSelectArea("QR03")
		dbGoTop()
		While !Eof()
			agrpPAR04 += QR03->BM_GRUPO+","
			dbSelectArea("QR03")
			dbSkip()
		End
		QR03->(dbCloseArea())
		Ferase(QRIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(QRIndex+OrdBagExt())          //indice gerado

	EndIf

	fyFilAleat := ""
	If Alltrim(FunName()) == "BIA518"

		fyFilAleat := w8FilAleat

	Else

		If MV_PAR13 == 1

			DEFINE MSDIALOG oDlgCpad TITLE "Filtro adicional para Custo Padrão" FROM 000, 000  TO 300, 550 COLORS 0, 16777215 PIXEL
			@ 024, 013 GET oMultiGet1 VAR cMultiGet1 OF oDlgCpad MULTILINE SIZE 246, 113 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 223 BUTTON Confirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlgCpad ACTION (fh_Esc := .T., oDlgCpad:End()) PIXEL
			@ 012, 013 SAY oSay1 PROMPT "Informe o código dos produtos que deseja filtrar separados por virgula:" SIZE 180, 007 OF oDlgCpad COLORS 0, 16777215 PIXEL
			ACTIVATE MSDIALOG oDlgCpad VALID fh_Esc

			fyFilAleat := cMultiGet1

		EndIf

	EndIf

	// Forecast = Não e Atualiza Custo p/ Orçamento = Sim
	//    or
	// Programa BIA518 e Atualiza Custo p/ Orçamento = Sim
	If ( MV_PAR18 == 2 .and. MV_PAR14 == 1 .and. MV_PAR19 $ "  /01") .or. ( Alltrim(FunName()) == "BIA518" .and. MV_PAR14 == 1 )

		KS007 := " UPDATE " + RetSqlName("ZBT") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
		KS007 += "   FROM " + RetSqlName("ZBT") + " ZBT "
		KS007 += "  WHERE ZBT.ZBT_FILIAL = '" + xFilial("ZBT") + "' "
		KS007 += "    AND ZBT.ZBT_VERSAO = '" + MV_PAR15 + "' "
		KS007 += "    AND ZBT.ZBT_REVISA = '" + MV_PAR16 + "' "
		KS007 += "    AND ZBT.ZBT_ANOREF = '" + MV_PAR17 + "' "
		KS007 += "    AND ZBT.ZBT_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'
		If !Empty(fyFilAleat)
			KS007 += "    AND ZBT.ZBT_COD IN " + FormatIn(fyFilAleat,",") + " "
		EndIf
		KS007 += "    AND ZBT.D_E_L_E_T_ = ' ' "

		U_BIAMsgRun("Aguarde... Apagando registros ZBT... ",,{|| TcSQLExec(KS007) })

	EndIf

	aBitmap  := "LOGOPRI" + cEmpAnt + ".BMP"
	fCabec   := "CUSTO PADRÃO - ORCAMETÁRIO"
	fCabe02  := ""

	wnPag    := 0
	nRow1    := 0

	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont32  := TFont():New("Lucida Console"    ,9,32,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()
	oPrint:SetPaperSize(09)
	oPrint:Setup()

	IF !Empty(MV_PAR19)

		IF MV_PAR19 == '13'

			MV_PAR10 := stod(MV_PAR17 + "0101")  
			MV_PAR11 := stod(MV_PAR17 + "0101")
			fCabe02  := "de data: " + dtoc(MV_PAR10) + ", até data: " + dtoc(MV_PAR11)
			gB766Loop()

		Else

			MV_PAR10 := LastDay(stod(MV_PAR17 + MV_PAR19 + "01"))  
			MV_PAR11 := LastDay(stod(MV_PAR17 + MV_PAR19 + "01"))
			fCabe02  := "de data: " + dtoc(MV_PAR10) + ", até data: " + dtoc(MV_PAR11)
			gB766Loop()

		EndIf

	Else

		MV_PAR10 := stod(MV_PAR17 + "0101")  
		MV_PAR11 := stod(MV_PAR17 + "0101")
		fCabe02  := "de data: " + dtoc(MV_PAR10) + ", até data: " + dtoc(MV_PAR11)
		gB766Loop()

		For wgt := 1 to 12

			If Alltrim(FunName()) == "BIA518"
				ctplCtZero	:=	.F.
			EndIF
			MV_PAR10 := Ultimodia(stod(MV_PAR17 + StrZero(wgt,2) + "01"))
			MV_PAR11 := Ultimodia(MV_PAR10)
			fCabe02  := "de data: " + dtoc(MV_PAR10) + ", até data: " + dtoc(MV_PAR11)
			If Alltrim(FunName()) == "BIA518"
				If MV_PAR11 >= fyDatRef
					gB766Loop()
				EndIf
			Else
				gB766Loop()
			EndIf

		Next wgt

	EndIf

	// Incluído em 26/04/19 para poder refletir na tabela ZCH registros da tabela Z87
	If Alltrim(FunName()) == "BIA518"
		ksGrvZCH()
	EndIf

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Erros de Custo"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DATDE"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATAT"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CODPROD"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COMPONE"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MOTIVO"          ,1,1)

	dbSelectArea("T004")
	dbGoTop()
	While !Eof()

		oExcel:AddRow(nxPlan, nxTabl, { T004->DATDE           ,;
		T004->DATAT                                           ,;
		T004->CODPROD                                         ,;
		T004->COMPONE                                         ,;
		T004->MOTIVO                                          })

		dbSelectArea("T004")
		dbSkip()

	End
	T004->(dbCloseArea())

	xArqTemp := "custo_orct - " + cEmpAnt + strzero(seconds()%3500,5)

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

	SGG->(DbClearFilter())
	Set Softseek Off

	oPrint:Preview()

Return

Static Function gB766Loop()

	Local i

	msCampoUpdt := ""
	msCampoCtrl := ""

	// Forecast = Sim e Atualiza Custo p/ Orçamento = Sim e !Programa = BIA518
	If MV_PAR18 == 1 .and. MV_PAR14 == 1 .and. !Alltrim(FunName()) == "BIA518"

		msCampoUpdt := ""
		msCampoCtrl := ""
		If DAY(MV_PAR11) == 1
			msCampoUpdt := "ZBT_CTOTAL"
		Else
			msCampoUpdt := "ZBT_M" + StrZero(MONTH(MV_PAR11),2)
			msCampoCtrl := "Z47_QTDM" + StrZero(MONTH(MV_PAR11),2)
		EndIf
		If !Empty(msCampoUpdt)

			KS009 := " UPDATE " + RetSqlName("ZBT") + " SET " + msCampoUpdt + " = 0 "
			KS009 += "   FROM " + RetSqlName("ZBT") + " ZBT "
			KS009 += "  WHERE ZBT.ZBT_FILIAL = '" + xFilial("ZBT") + "' "
			KS009 += "    AND ZBT.ZBT_VERSAO = '" + MV_PAR15 + "' "
			KS009 += "    AND ZBT.ZBT_REVISA = '" + MV_PAR16 + "' "
			KS009 += "    AND ZBT.ZBT_ANOREF = '" + MV_PAR17 + "' "
			KS009 += "    AND ZBT.ZBT_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'
			If !Empty(fyFilAleat)
				KS009 += "    AND ZBT.ZBT_COD IN " + FormatIn(fyFilAleat,",") + " "
			EndIf
			KS009 += "    AND ZBT.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Zerando registros ZBT... ",,{|| TcSQLExec(KS009) })

		EndIf

	EndIf

	aDados2 := {}

	IF MV_PAR05	== 1 .And. lGravaZ46 .And. MV_PAR14 == 1 .and. !Alltrim(FunName()) == "BIA518"

		_cSqlf := " UPDATE " + RetSqlName("Z46") + " SET D_E_L_E_T_ = '*'
		_cSqlf += "  WHERE Z46_FILIAL = '" + xFilial("Z46") + "' "
		_cSqlf += "    AND Z46_VERSAO = '" + MV_PAR15 + "' "
		_cSqlf += "    AND Z46_REVISA = '" + MV_PAR16 + "' "
		_cSqlf += "    AND Z46_ANOREF = '" + MV_PAR17 + "' "
		_cSqlf += "    AND Z46_DATARF = '" + dtos(MV_PAR11) + "' "
		_cSqlf += "    AND Z46_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
		_cSqlf += "    AND D_E_L_E_T_ = ' ' "

		U_BIAMsgRun("Aguarde... Apagando registros Z46... ",,{|| TcSQLExec(_cSqlf) })

	EndIF

	// Temporário para Impressão de resumo final, quando relatório analítico
	xArry := {}
	AADD(xArry,{ "CCONTAB"    ,"C",20,0 } )
	AADD(xArry,{ "CUSTO"      ,"N",18,8 } )
	AADD(xArry,{ "PROJT"      ,"N",18,8 } )
	T001 := CriaTrab(xArry)
	dbUseArea( .T.,, T001, "T001", .F., .F. )
	dbCreateInd(T001, "CCONTAB" ,{ || Indices })

	// Temporário para gravação de custo unitário para C.VARIAVEL Orcto
	xArry := {}
	AADD(xArry,{ "CCONTAB"    ,"C",20,0 } )
	AADD(xArry,{ "CUSTO"      ,"N",18,8 } )
	T003 := CriaTrab(xArry)
	dbUseArea( .T.,, T003, "T003", .F., .F. )
	dbCreateInd(T003, "CCONTAB" ,{ || Indices })

	// Temporário para evitar buscas sucessivas para um mesmo componente
	xAyCt := {}
	AADD(xAyCt,{ "CODCOMP"    ,"C",15,0 } )
	AADD(xAyCt,{ "CUSTO"      ,"N",18,8 } )
	AADD(xAyCt,{ "ULTCOM"     ,"D",08,0 } )
	AADD(xAyCt,{ "EMPR"       ,"C",02,0 } )
	AADD(xAyCt,{ "REFER"      ,"C",02,0 } )
	T002 := CriaTrab(xAyCt)
	dbUseArea( .T.,, T002, "T002", .F., .F. )
	dbCreateInd(T002, "CODCOMP" ,{ || Indices })

	// Monta referência para diluir o retorno da Massa na formulação da massa. Usado apenas para PI MASSA
	AK007 := " SELECT GG_COD, MAX(GG_TRT) GG_TRT, SUM(GG_YMISTUR) PERC
	AK007 += "   FROM "+RetSqlName("SGG")+" SGG
	AK007 += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	AK007 += "                      AND B1_COD = GG_COD
	AK007 += "                      AND B1_GRUPO = 'PI01'
	AK007 += "                      AND SB1.D_E_L_E_T_ = ' '
	AK007 += "  WHERE GG_FILIAL = '"+xFilial("SGG")+"'
	AK007 += "    AND GG_INI <= " + ValtoSql(MV_PAR10)
	AK007 += "    AND GG_FIM >= " + ValtoSql(MV_PAR11)
	AK007 += "    AND SGG.D_E_L_E_T_ = ' '
	AK007 += "  GROUP BY GG_COD
	AK007 := ChangeQuery(AK007)
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,AK007),'AK07',.T.,.T.)
	aStruX := ("AK07")->(dbStruct())
	/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
	gh_IndX := "GG_COD"
	If !chkfile("AK08")
		AK08 := U_BIACrTMP(aStruX)
		dbUseArea( .T.,, AK08, "AK08", .F., .F. )
		dbCreateInd(AK08, gh_IndX,{ || gh_IndX })
	EndIf
	dbSelectArea("AK08")
	APPEND FROM ("AK07")
	If Select("AK07") > 0
		AK07->(dbCloseArea())
	Endif

	// Filtra Produtos para montagem do relatório
	A0003 := " SELECT GG_COD, B1_QB, B1_DESC, MAX(GG_TRT) GG_TRT
	A0003 += "   FROM " + RetSqlName("SGG") + " SGG
	A0003 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "'
	A0003 += "                       AND B1_COD = GG_COD
	A0003 += "                       AND B1_TIPO = '" + MV_PAR07 + "'
	If MV_PAR07 == "PA" .and. MV_PAR12 == 1
		A0003 += "                       AND B1_YCLASSE = '1'
	EndIf
	If MV_PAR07 $ "PA/PP"
		A0003 += "                       AND RIGHT(RTRIM(B1_COD),3) <> '000'
	EndIf
	A0003 += "                       AND SB1.D_E_L_E_T_ = ' '
	A0003 += "  WHERE GG_FILIAL = '" + xFilial("SGG") + "'
	A0003 += "    AND GG_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'
	A0003 += "    AND " + ValtoSql(MV_PAR10) + " >= GG_INI " 
	A0003 += "    AND " + ValtoSql(MV_PAR11) + " <= GG_FIM "
	If !Empty(fyFilAleat)
		A0003 += "    AND GG_COD IN " + FormatIn(fyFilAleat,",")
	EndIf
	If !Empty(msCampoCtrl) .and. !Alltrim(FunName()) == "BIA518"
		A0003 += " AND GG_COD IN ( SELECT Z47_PRODUT
		A0003 += "                   FROM " + RetSqlName("Z47")
		A0003 += "                  WHERE Z47_VERSAO = '" + MV_PAR15 + "'
		A0003 += "                    AND Z47_REVISA = '" + MV_PAR16 + "'
		A0003 += "                    AND Z47_ANOREF = '" + MV_PAR17 + "'
		A0003 += "                    AND " + msCampoCtrl + " <> 0
		A0003 += "                    AND D_E_L_E_T_ = ' '
		A0003 += "                  GROUP BY Z47_PRODUT)
	EndIf
	A0003 += "    AND SGG.D_E_L_E_T_ = ' '
	A0003 += "  GROUP BY GG_COD, B1_QB, B1_DESC
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0003),'A003',.T.,.T.)
	aStru1 := ("A003")->(dbStruct())
	/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
	gh_Ind := "GG_COD"
	If !chkfile("A004")
		A004 := U_BIACrTMP(aStru1)
		dbUseArea( .T.,, A004, "A004", .F., .F. )
		dbCreateInd(A004, gh_Ind,{ || gh_Ind })
	EndIf
	dbSelectArea("A004")
	APPEND FROM ("A003")
	If Select("A003") > 0
		A003->(dbCloseArea())
	Endif
	dbGotop()
	wk_RefVl := ""
	wQtdReg := LastRec()
	ProcRegua(wQtdReg)
	While !Eof()

		gtVlrRet  := .F.

		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc(Alltrim(Str(wQtdReg)) + " Dt: " + dtoc(MV_PAR11) + " Prod: " + Alltrim(A004->GG_COD) + " Tempo: " + cTempo)

		wQtdReg := wQtdReg -1

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+A004->GG_COD)

		nEstru     := 0
		wProduto   := A004->GG_COD
		wQtd       := IIF(A004->B1_QB == 0, 1, A004->B1_QB)
		wpRevAtu   := A004->GG_TRT
		wpNiv      := 1
		cArqTmp    := ""
		cAliasTRB  := cArqTRB := "Estrut"

		xQtdRetn   := 0

		cNome      := StrutBia(wProduto, wQtd, cAliasTRB, cArqTRB, .F., wpRevAtu, wpNiv)
		cArqTRB    := cArqTmp
		ESTRUT->(dbGoTop())
		While ESTRUT->(!Eof())

			xk_Custo  := 0
			xk_UltCom := ctod("  /  /  ")
			wk_RefVl  := ""
			xk_EmpOri := Space(2)
			xk_Umidad := 0

			dbSelectArea("Z87")
			dbSetOrder(1)
			If dbSeek(xFilial("Z87") + dtos(MV_PAR11) + ESTRUT->COMP)
				xk_Umidad := Z87->Z87_UMIDAD
			EndIf

			If xk_Custo == 0

				xk_Custo  := 0
				xk_UltCom := ctod("  /  /  ")
				wk_RefVl  := ""

				DbSelectArea("ZCH")
				ZCH->(DbSetOrder(2))
				If ZCH->(DbSeek(xFilial("ZCH")+MV_PAR15+MV_PAR16+MV_PAR17 + ESTRUT->COMP))

					If Month(MV_PAR11) == 1 .And. Day(MV_PAR11) = 1
						xk_Custo	:=	ZCH->ZCH_VULENT
						If xk_Custo == 0
							xk_Custo := ZCH->ZCH_VMES01
						EndIf
					Else
						xk_Custo	:=	&("ZCH->ZCH_VMES"+PADL(Alltrim(Str(MONTH(MV_PAR10))),2,"0"))
					EndIf

					dbSelectArea("Z87")
					dbSetOrder(1)
					If !dbSeek(xFilial("Z87") + dtos(MV_PAR11) + ESTRUT->COMP)
						RecLock("Z87",.T.)
						Z87->Z87_FILIAL  := xFilial("Z87")
						Z87->Z87_DATARF  := MV_PAR11
						Z87->Z87_PRODUT  := ESTRUT->COMP
					Else
						RecLock("Z87",.F.)
					EndIf
					Z87->Z87_CUSTO1  := xk_Custo
					Z87->Z87_DTCUST  := dDataBase
					Z87->Z87_ORICST  := "ZCH"
					Z87->Z87_UMIDAD  := xk_Umidad
					MsUnLock()					

				EndIf

			EndIf		

			// Controle de Projeção de Custo
			xf_Projetd := xk_Custo

			Aadd(aDados2, { ESTRUT->PRODPAI    ,;
			ESTRUT->ORDEM                      ,;
			ESTRUT->CODIGO                     ,;
			ESTRUT->COMP                       ,;
			ESTRUT->TRT                        ,;
			ESTRUT->QUANT                      ,;
			ESTRUT->QTDORI                     ,;
			ESTRUT->NIVEL                      ,;
			xk_Custo                           ,;
			xk_UltCom                          ,;
			xk_EmpOri                          ,;
			xf_Projetd                         ,;
			wk_RefVl                           ,;
			xk_Umidad                          })

			ESTRUT->(dbSkip())
		End
		U_BIAFimStru(cAliasTRB,cArqTRB)

		dbSelectArea("A004")
		dbSkip()
	End
	A004->(dbCloseArea())
	T002->(dbCloseArea())

	// ----------------------- Impressão --------------------------------------
	aDadoX	:=	{}
	If MV_PAR05 == 1

		// Relatório Analítico
		xCamp := {}

		AADD(xCamp,{ "DATREF"     ,"D",8,0 } )
		AADD(xCamp,{ "PROPAI"     ,"C",15,0 } )
		AADD(xCamp,{ "NIVEL"      ,"C",03,0 } )
		AADD(xCamp,{ "SGGCOD"     ,"C",15,0 } )
		AADD(xCamp,{ "COMP"       ,"C",15,0 } )
		AADD(xCamp,{ "DESCR"      ,"C",70,0 } )
		AADD(xCamp,{ "REVISA"     ,"C",03,0 } )
		AADD(xCamp,{ "UM"         ,"C",02,0 } )
		AADD(xCamp,{ "SEQUEN"     ,"C",03,0 } )
		AADD(xCamp,{ "QUANT"      ,"N",18,8 } )
		AADD(xCamp,{ "CUNIT"      ,"N",14,4 } )
		AADD(xCamp,{ "CTOTAL"     ,"N",14,4 } )
		AADD(xCamp,{ "RF"         ,"C",02,0 } )
		AADD(xCamp,{ "DTCTO"      ,"C",08,0 } )
		AADD(xCamp,{ "EMPR"       ,"C",02,0 } )
		AADD(xCamp,{ "PROJET"     ,"N",14,4 } )
		AADD(xCamp,{ "PERCT"      ,"N",08,2 } )
		AADD(xCamp,{ "UMIDAD"     ,"N",08,2 } )
		AADD(xCamp,{ "KEY"        ,"C",20,0 } )
		AADD(xCamp,{ "DESCRC"     ,"C",50,0 } )
		AADD(xCamp,{ "ITCUS"      ,"C",03,0 } )

		ql_ProdPai := Space(15)
		ql_PrdRefR := Space(15)
		msNivPAMin := 9999
		msPANivCrt := 0
		msTipoNiv  := ""
		ql_TotCPai := 0
		ql_ToPrPai := 0
		ql_SeqGrv  := 0
		aDados2 := Asort(aDados2,,, { |x, y| x[1]+x[2] < y[1]+y[2] })
		For i := 1 to Len(aDados2)

			cTempo := Alltrim(ElapTime(cHInicio, Time()))
			IncProc("Imprimindo....   Tempo: "+cTempo)

			// Salto de Pagina e Totalizadores de um produto para outro
			If ql_ProdPai <> aDados2[i][1]
				If !Empty(ql_ProdPai)
					fImpTotais()
					ql_TotCPai := 0
					ql_ToPrPai := 0
					ql_SeqGrv  := 0
				EndIf
				ql_ProdPai := aDados2[i][1]
				ql_PrdRefR := Space(15)
				fImpCabec()
			EndIf
			// Reinializa páginas
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + ql_ProdPai))
			msYtpProd := SB1->B1_YTPPROD

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+aDados2[i][3]))
			ql_GrpCod := Alltrim(SB1->B1_GRUPO)
			msTipoNiv := SB1->B1_TIPO

			If SB1->B1_TIPO == "PA" .and. Empty(ql_PrdRefR) .and. Alltrim(aDados2[i][3]) <> Alltrim(wProduto)
				ql_PrdRefR := aDados2[i][3]
			EndIf
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+aDados2[i][4]))

			If ql_GrpCod $ Alltrim(agrpPAR04) .or. Alltrim(SB1->B1_GRUPO) $ Alltrim(agrpPAR04) .or. Empty(agrpPAR04)

				// Calcula percetual da Projeção
				ql_Quant := aDados2[i][6]
				ql_Perct := 0

				// Novo tratamento para adicional de umidade
				If aDados2[i][14] <> 0
					ql_Quant := ql_Quant/(-(((aDados2[i][14]/100)/1)-1))
				EndIf

				If (ql_Quant*aDados2[i][12]) - (ql_Quant*aDados2[i][9]) <> 0
					If aDados2[i][9] == 0
						ql_Perct := 100
					Else
						ql_Perct := ((ql_Quant*aDados2[i][12]) - (ql_Quant*aDados2[i][9])) / (ql_Quant*aDados2[i][9]) * 100
					EndIf
				EndIf

				If !SB1->B1_TIPO $ "PI/PP/PA" .and. aDados2[i][9] == 0 .and. !Alltrim(aDados2[i][4]) $ "1020700/1010170/1010173/1010235/1010268/1010334/1024245"

					dbSelectArea("T004")
					If !dbSeek(dtos(MV_PAR10) + dtos(MV_PAR11) + Alltrim(aDados2[i][1]) + Alltrim(aDados2[i][4]) )
						RecLock("T004",.T.)
						T004->DATDE   := MV_PAR10
						T004->DATAT   := MV_PAR11
						T004->CODPROD := Alltrim(aDados2[i][1])
						T004->COMPONE := Alltrim(aDados2[i][4])
						T004->MOTIVO  := "CUSTO ZERO"
						MsUnLock()
						ctplCtZero := .T.
					EndIf

				EndIf

				// Incluída tratativa para atender OS effettivo 3428-16
				If SB1->B1_MSBLQL == "1"

					dbSelectArea("T004")
					If !dbSeek(dtos(MV_PAR10) + dtos(MV_PAR11) + Alltrim(aDados2[i][1]) + Alltrim(aDados2[i][4]) )
						RecLock("T004",.T.)
						T004->DATDE   := MV_PAR10
						T004->DATAT   := MV_PAR11
						T004->CODPROD := Alltrim(aDados2[i][1])
						T004->COMPONE := Alltrim(aDados2[i][4])
						T004->MOTIVO  := "PRODUTO BLOQUEADO: verificar."
						MsUnLock()
						ctplCtZero := .T.
					EndIf

				EndIf

				CT1->( dbSetOrder(1) )
				CT1->( dbSeek(xFilial("CT1") + SB1->B1_YCTRIND ) )
				Z29->( dbSetOrder(1) )
				Z29->( dbSeek(xFilial("Z29") + CT1->CT1_YITCUS ) )

				If Alltrim(ql_ProdPai) <> Alltrim(aDados2[i][3])

					If msTipoNiv == "PA" .and. msNivPAMin == 9999 .and. msPANivCrt == 0
						msNivPAMin := aDados2[I][8]
						msPANivCrt := aDados2[I][8]
					EndIf

					If msTipoNiv <> "PA" .and. msPANivCrt = aDados2[I][8]
						msNivPAMin := 9999
						msPANivCrt := 0
					EndIf

				EndIf

				msIprGer := .T.

				If msIprGer

					//--------------------- Reservado para Impressão ----------------------
					xf_RefCt := aDados2[i][13]
					xf_Item := +;
					Padr(Space(aDados2[i][8]*5) + aDados2[i][4] + Alltrim(SB1->B1_DESC)             ,075)+" "+;
					Padc(IIF(SB1->B1_TIPO == "PI", fRetTRT(SB1->B1_COD), "   ")		                ,006)+" "+;
					Padr(SB1->B1_UM                                                                 ,002)+" "+;
					Padc(aDados2[i][5]                                                              ,003)+" "+;
					Padl(Transform(ql_Quant, "@E 999,999.99999999")                                 ,017)+" "+;
					Padl(Transform(aDados2[i][9], "@E 9,999,999.9999")                              ,014)+" "+;
					Padl(Transform(ql_Quant * aDados2[i][9], "@E 9,999,999.9999")                   ,014)+" "+;
					Padl(xf_RefCt                                                                   ,002)+" "+;
					Padl(dtoc(aDados2[i][10])                                                       ,008)+" "+;
					Padl(aDados2[i][11]                                                             ,002)+" "+;
					Padl(Transform(ql_Quant * aDados2[i][12] , "@E 99999.9999")                     ,010)+" "+;
					Padl(Transform(ql_Perct                , "@E 99999.99")                         ,008)+" "+;
					Padl(Transform(aDados2[i][14]          , "@E 99999.99")                         ,008)
					oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont8)
					If aDados2[i][3] == ql_ProdPai
						oPrint:Line (nRow1-15, 100, nRow1-15, 3350)
					EndIf
					nRow1 += 050

					//--------- KEY para amarração entre o padrão e o realizado -------
					xdContaC := ""
					xdDescrC := ""
					xdItCus  := ""

					CT1->(dbSetOrder(1))
					If CT1->(dbSeek(xFilial("CT1")+SB1->B1_YCTRIND))
						xdContaC := SB1->B1_YCTRIND
						xdItCus  := CT1->CT1_YITCUS
						xdDescrC := CT1->CT1_DESC01
					Else
						If SB1->B1_TIPO == "PA"
							xdContaC := "61111003"
							xdItCus  := "063"
							xdDescrC := "PLACAS CONSUMIDAS NO CORTE"
						EndIf
					EndIf

					//------------------- Reservado para Exportação -------------------
					Aadd(aDadoX, {MV_PAR11	,; 
					aDados2[i][1]                                     ,;
					Alltrim(Str(aDados2[i][8]))                                      ,;
					aDados2[i][3]                                                    ,;
					aDados2[i][4]                                                    ,;
					Alltrim(SB1->B1_DESC)                                            ,;
					IIF(SB1->B1_TIPO == "PI", fRetTRT(SB1->B1_COD), "   ")           ,;
					SB1->B1_UM                                                       ,;
					aDados2[i][5]                                                    ,;
					Transform(ql_Quant,                     "@E 999,999.99999999")   ,;
					Transform(aDados2[i][9],                "@E 9,999,999.9999")     ,;
					Transform(ql_Quant * aDados2[i][9],     "@E 9,999,999.9999")     ,;
					xf_RefCt                                                         ,;
					dtoc(aDados2[i][10])                                             ,;
					aDados2[i][11]                                                   ,;
					Transform(ql_Quant * aDados2[i][12],   "@E 9,999,999.9999")      ,;
					Transform(ql_Perct,                    "@E 99999.99")            ,;
					Transform(aDados2[i][14],              "@E 99999.99")            ,;
					xdContaC                                                         ,;
					xdDescrC                                                         ,;
					xdItCus                                                          })

					/*
					Grava Z46					
					*/
					If lGravaZ46 .And. MV_PAR14 == 1
						ql_SeqGrv  ++
						RecLock("Z46",.T.)
						Z46->Z46_FILIAL := xFilial("Z46")
						Z46->Z46_VERSAO	:= MV_PAR15
						Z46->Z46_REVISA	:= MV_PAR16
						Z46->Z46_ANOREF	:= MV_PAR17
						Z46->Z46_DATARF := MV_PAR11
						Z46->Z46_SEQGRV := StrZero(ql_SeqGrv,4)
						Z46->Z46_COD    := aDados2[i][1]
						Z46->Z46_SG1COD := aDados2[i][3]
						Z46->Z46_COMP   := aDados2[i][4]
						Z46->Z46_NIVEL  := Alltrim(Str(aDados2[i][8]))
						Z46->Z46_REVATU := IIF(SB1->B1_TIPO == "PI", SB1->B1_REVATU, "   ")
						Z46->Z46_TRT    := aDados2[i][5]
						Z46->Z46_QUANT  := ql_Quant
						Z46->Z46_CUNIT  := aDados2[i][9]
						Z46->Z46_CTOTAL := ql_Quant * aDados2[i][9]
						Z46->Z46_RF     := xf_RefCt
						Z46->Z46_DTCSTO := aDados2[i][10]
						Z46->Z46_EMPR   := aDados2[i][11]
						Z46->Z46_PROJET := ql_Quant * aDados2[i][12]
						Z46->Z46_PERCT  := ql_Perct
						Z46->Z46_UMIDAD := aDados2[i][14]
						Z46->Z46_CONTA  := IIF(SB1->B1_TIPO == "PA", "61111003", SB1->B1_YCTRIND)
						Z46->Z46_ITCUS  := IIF(SB1->B1_TIPO == "PA", "063", xdItCus)
						Z46->(MsUnLock())
					EndIf

					//--------------------- Reservado para Resumo ---------------------
					If SB1->B1_TIPO <> "PI" .or. aDados2[i][9] <> 0
						dbSelectArea("T001")
						If !dbSeek(SB1->B1_YCTRIND)
							RecLock("T001",.T.)
							T001->CCONTAB := SB1->B1_YCTRIND
						Else
							RecLock("T001",.F.)
						EndIf
						T001->CUSTO += ql_Quant * aDados2[i][9]
						T001->PROJT += ql_Quant * aDados2[i][12]
						MsUnLock()
						ql_TotCPai += ql_Quant * aDados2[i][9]
						ql_ToPrPai += ql_Quant * aDados2[i][12]
					EndIf

				EndIf

				//------------------- Reservado para C.VARIAVEL -------------------
				If aDados2[I][8] < msNivPAMin

					If SB1->B1_TIPO <> "PI" .or. aDados2[i][9] <> 0
						dbSelectArea("T003")
						If !dbSeek(SB1->B1_YCTRIND)
							RecLock("T003",.T.)
							T003->CCONTAB := SB1->B1_YCTRIND
						Else
							RecLock("T003",.F.)
						EndIf
						T003->CUSTO += ql_Quant * aDados2[i][9]
						MsUnLock()
					EndIf

				EndIf
				//-----------------------------------------------------------------

			EndIf

		Next i

		fImpTotais()

	Else

		// Relatório Sintético
		xCamp := {}
		AADD(xCamp,{ "PROPAI"     ,"C",15,0 } )
		AADD(xCamp,{ "DESCR"      ,"C",70,0 } )
		AADD(xCamp,{ "REVISA"     ,"C",03,0 } )
		AADD(xCamp,{ "UM"         ,"C",02,0 } )
		AADD(xCamp,{ "ULTCOM"     ,"N",14,4 } )
		AADD(xCamp,{ "PROJET"     ,"N",14,4 } )
		AADD(xCamp,{ "PERCT"      ,"N",08,2 } )
		AADD(xCamp,{ "CUSTFX"     ,"N",14,4 } )
		AADD(xCamp,{ "CTOTULC"    ,"N",14,4 } )
		AADD(xCamp,{ "CTOTPRJ"    ,"N",14,4 } )

		fImpCab01()
		ql_ProdPai := Space(15)
		ql_PrdRefR := Space(15)
		ql_TotCPai := 0
		ql_ToPrPai := 0
		aDados2 := Asort(aDados2,,, { |x, y| x[1]+x[2] < y[1]+y[2] })
		For i := 1 to Len(aDados2)

			// Salto de Pagina e Totalizadores de um produto para outro
			If ql_ProdPai <> aDados2[i][1]
				If !Empty(ql_ProdPai)
					fImpTotPrd()
					ql_TotCPai := 0
					ql_ToPrPai := 0
				EndIf
				ql_ProdPai := aDados2[i][1]
				ql_PrdRefR := Space(15)
			EndIf
			// Reinializa páginas
			If nRow1 > 2250
				fImpRoda()
				fImpCab01()
			EndIf

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+aDados2[i][3]))
			ql_GrpCod := Alltrim(SB1->B1_GRUPO)
			If SB1->B1_TIPO == "PA" .and. Alltrim(aDados2[i][3]) <> Alltrim(ql_ProdPai) // .and. Substr(SB1->B1_COD,1,2) == "C1"
				ql_PrdRefR := aDados2[i][3]
			EndIf
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+aDados2[i][4]))
			If ql_GrpCod $ Alltrim(agrpPAR04) .or. Alltrim(SB1->B1_GRUPO) $ Alltrim(agrpPAR04) .or. Empty(agrpPAR04)

				// Calcula percetual da Projeção
				ql_Quant := aDados2[i][6]
				ql_Perct := 0

				// Novo tratamento para adicional de umidade
				If aDados2[i][14] <> 0
					ql_Quant := ql_Quant/(-(((aDados2[i][14]/100)/1)-1))
				EndIf

				If (ql_Quant*aDados2[i][12]) - (ql_Quant*aDados2[i][9]) <> 0
					If aDados2[i][9] == 0
						ql_Perct := 100
					Else
						ql_Perct := ((ql_Quant*aDados2[i][12]) - (ql_Quant*aDados2[i][9])) / (ql_Quant*aDados2[i][9]) * 100
					EndIf
				EndIf

				ql_TotCPai += ql_Quant * aDados2[i][9]
				ql_ToPrPai += ql_Quant * aDados2[i][12]

			EndIf

		Next i

		fImpTotPrd()

	EndIf

	T001->(dbCloseArea())
	T003->(dbCloseArea())

	If MV_PAR06 == 1
		//U_BIAxExcel(aDadoX, xCamp, "BIA776"+strzero(seconds()%3500,5) + '-'+ DtoS(MV_PAR11) )
		MsgInfo("A função de extrair dados para Excel foi descontinuada. Favor recuperar os dados através da função Rel. Custo Unit. Orca!","BIA776")
	EndIf

	AK08->(dbCloseArea())

	oPrint:EndPage()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 11/08/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Ação     ¦ Navega Estrutura de Produto para Acumular quantidades que  ¦¦¦
¦¦¦          ¦ servirão de base para custo variável                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function StrutBia(cProduto, nQuant, cAliasEstru, cArqTrab, lAsShow, cRevisao, xNivel)

	LOCAL nRegi   := 0, nQuantItem := 0
	LOCAL aCampos := {}, aTamSX3:={}, lAdd :=.F.
	LOCAL nRecno
	cAliasEstru   := IIF(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
	nQuant        := IIF(nQuant == NIL,1,nQuant)
	lAsShow       := IIF(lAsShow==NIL,.F.,lAsShow)
	xNivel        := IIF(xNivel == NIL, 1, xNivel)
	nEstru++
	If nEstru == 1
		xk_Ordem := 0
		aTamSX3:=TamSX3("GG_COD")
		AADD(aCampos,{"PRODPAI","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("GG_TRT")
		AADD(aCampos,{"ORDEM","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("GG_COD")
		AADD(aCampos,{"CODIGO","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("GG_COMP")
		AADD(aCampos,{"COMP","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("GG_TRT")
		AADD(aCampos,{"TRT","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("GG_QUANT")
		AADD(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
		aTamSX3:=TamSX3("GG_QUANT")
		AADD(aCampos,{"QTDORI","N",Max(aTamSX3[1],18),aTamSX3[2]})
		aTamSX3:=TamSX3("GG_NIV")
		AADD(aCampos,{"NIVEL","N",Max(aTamSX3[1],18),aTamSX3[2]})
		cArqTrab := CriaTrab(aCampos)
		If Select(cAliasEstru) > 0
			dbSelectArea(cAliasEstru)
			dbCloseArea()
		EndIf
		Use &cArqTrab NEW Exclusive Alias &(cAliasEstru)
		IndRegua(cAliasEstru,cArqTrab,"CODIGO+COMP+TRT",,,"Selecionando Registros...")
		dbSetIndex(cArqtrab+OrdBagExt())

		/*--------*/
		cFiltro := " dtos(GG_INI) >= '" + dtos(MV_PAR10) + "' .and. dtos(GG_FIM) <= '" + dtos(MV_PAR11) + "' "
		dbSelectArea("SGG")
		Set Softseek On
		dbSetOrder(1)
		DbSetFilter({|| &cFiltro},cFiltro)
		dbSetOrder(1)
		dbGoTop()

	EndIf

	dbSelectArea("SGG")
	dbSetOrder(1)
	dbSeek(xFilial("SGG")+cProduto)

	While !Eof() .and. SGG->GG_FILIAL+SGG->GG_COD == xFilial("SGG")+cProduto

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SGG->GG_COD ))
		kdCodTipo  := SB1->B1_TIPO
		kdCodFormt := SB1->B1_YFORMAT
		kdCodTpPrd := SB1->B1_YTPPROD
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SGG->GG_COMP ))
		kdCmpTipo  := SB1->B1_TIPO
		kdCmpFormt := SB1->B1_YFORMATMARCO
		kdCmpTpPrd := SB1->B1_YTPPROD

		dbSelectArea("SGG")
		nRegi:=Recno()
		If SGG->GG_COD != SGG->GG_COMP .and. kdCmpTipo <> "PA"

			lAdd:=.F.
			If SGG->GG_INI >= MV_PAR10 .and. SGG->GG_FIM <= MV_PAR11

				// Retorno somado à Massa. Incluido em 30/09/11 para equiparação do programa ao que o Jecimar faz no excel
				sm_Perc := 0
				sm_QtdPlus := 0
				sm_QtdBkp := nQuant
				If AK08->(dbSeek(SGG->GG_COD)) .and. AK08->PERC < 100
					sm_Perc := (SGG->GG_YMISTUR / AK08->PERC) * 100
					sm_QtdPlus := sm_Perc * nQuant / SGG->GG_YMISTUR
					nQuant := sm_QtdPlus
					xSomaRet := .T.
					xQtdRetn := AK08->PERC
				EndIf

				nQuantItem := xBia776E(nQuant, MV_PAR10, MV_PAR11)
				nQuant := sm_QtdBkp

				If (lNegEstr .Or. (!lNegEstr .And. QtdComp(nQuantItem,.T.) > QtdComp(0) )) .And. (QtdComp(nQuantItem,.T.) # QtdComp(0,.T.))

					dbSelectArea(cAliasEstru)
					xk_Ordem ++
					RecLock(cAliasEstru,.T.)
					ESTRUT->ORDEM  := StrZero(xk_Ordem,3)
					ESTRUT->PRODPAI:= wProduto
					ESTRUT->CODIGO := SGG->GG_COD
					ESTRUT->COMP   := SGG->GG_COMP
					ESTRUT->TRT    := fRetTRT(SGG->GG_COD)
					If MV_PAR03 == 1
						ESTRUT->QUANT  := ( nQuantItem * (100 - SGG->GG_PERDA) ) / 100
					ElseIf MV_PAR03 == 2
						ESTRUT->QUANT  := nQuantItem
					EndIf
					ESTRUT->QTDORI := SGG->GG_QUANT
					ESTRUT->NIVEL  := xNivel
					MsUnlock()
					lAdd:=.T.
				EndIf
				dbSelectArea("SGG")

				// Verifica se existe sub-estrutura
				nRecno:=Recno()
				IF fSeekTpC() <> "PA" .And. dbSeek(xFilial("SGG")+SGG->GG_COMP)
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+SGG->GG_COD))
					StrutBia(SGG->GG_COD, nQuantItem, cAliasEstru, cArqTrab, lAsShow, fRetTRT(SB1->B1_COD), xNivel+1)
					nEstru --
				Endif

			EndIf

		EndIf

		dbGoto(nRegi)
		dbSkip()

	End

	cArqTmp := cArqTrab

Return cArqTrab

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpTotais ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 29/08/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpTotais()

	If xSomaRet
		oPrint:Say  (nRow1+20 ,0050 ,"Retorno: " + Transform(100-xQtdRetn, "@E 999,999,999.9999")                               ,oFont8)
	EndIf

	//-------------------------------------------------------------------------
	// Bloco do programa para impressão dos valores totais dos custos variáries
	nRow1 += 075

	oPrint:Line (nRow1-15, 050, nRow1-15, 3350)
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	xf_Total := +;
	Padr("TOTAL DO CUSTO VARIÁVEL  ---->>>>>"                                       ,080)+" "+;
	Padc(""                                                                         ,006)+" "+;
	Padr(""                                                                         ,002)+" "+;
	Padc(""                                                                         ,003)+" "+;
	Padl(""                                                                         ,017)+" "+;
	Padl(""                                                                         ,014)+" "+;
	Padl(Transform(ql_TotCPai, "@E 9,999,999.9999")                                 ,014)+"  "+;
	Padl(""                                                                         ,002)+" "+;
	Padl(""                                                                         ,008)+" "+;
	Padl(""                                                                         ,002)+" "+;
	Padl(Transform(ql_ToPrPai, "@E 9,999,999.9999")                                 ,014)
	oPrint:Say  (nRow1 ,0050 ,xf_Total                               ,oFont8)
	ql_TotCPai := 0
	ql_ToPrPai := 0

	//-----------------------------------------------------------
	// Bloco do programa destinado ao tratamento dos custos fixos
	If MV_PAR09 <> 1
		nRow1 += 150
		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf
		oPrint:Line (nRow1-15, 050, nRow1-15, 3350)
		A0007 := " SELECT TOP 1 "+IIF(MV_PAR09 == 2, "Z13_CUSTFX", "Z13_DESPFX")+" Z13_CUSTFX
		A0007 += "   FROM "+RetSqlName("Z13")+" Z13
		A0007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
		A0007 += "                       AND B1_COD = '"+IIF(Empty(ql_PrdRefR), ql_ProdPai, ql_PrdRefR)+"'
		A0007 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0007 += "  WHERE Z13_FILIAL = '"+xFilial("Z13")+"'
		A0007 += "    AND '"+dtos(dDataBase)+"' >= Z13_DATADE
		A0007 += "    AND '"+dtos(dDataBase)+"' <= Z13_DATAAT
		A0007 += "    AND Z13_TIPO = '03'
		A0007 += "    AND Z13_FORMAT = B1_YFORMAT
		A0007 += "    AND Z13.D_E_L_E_T_ = ' '
		A0007 += "  ORDER BY Z13_PLANO DESC
		TcQuery A0007 ALIAS "A007" NEW
		dbSelectArea("A007")
		dbGoTop()
		xf_TCtFx := +;
		Padr("TOTAL DO CUSTO FIXO "+IIF(MV_PAR09 == 2, "TOTAL ", "INDUSTRIAL ")+"---->>>>>"   ,080)+" "+;
		Padc(""                                                                               ,006)+" "+;
		Padr(""                                                                               ,002)+" "+;
		Padc(""                                                                               ,003)+" "+;
		Padl(""                                                                               ,017)+" "+;
		Padl(""                                                                               ,014)+" "+;
		Padl(Transform(A007->Z13_CUSTFX, "@E 9,999,999.9999")                                 ,014)+"  "+;
		Padl(""                                                                               ,002)+" "+;
		Padl(""                                                                               ,008)+" "+;
		Padl(""                                                                               ,002)+" "+;
		Padl(Transform(A007->Z13_CUSTFX, "@E 9,999,999.9999")                                 ,014)
		oPrint:Say  (nRow1 ,0050 ,xf_TCtFx                               ,oFont8)

		dbSelectArea("T001")
		RecLock("T001",.T.)
		T001->CCONTAB := "CUSTO FIXO"
		T001->CUSTO   := A007->Z13_CUSTFX
		T001->PROJT   := A007->Z13_CUSTFX
		MsUnLock()
		ql_TotCPai += A007->Z13_CUSTFX
		ql_ToPrPai += A007->Z13_CUSTFX

		//----------- Reservado para Exportação para Excel -------------------
		Aadd(aDadoX, { IIF(Empty(ql_PrdRefR), ql_ProdPai, ql_PrdRefR)                                 ,;
		""                                                                                            ,;
		""                                                                                            ,;
		"TOTAL DO CUSTO FIXO "+IIF(MV_PAR09 == 2, "TOTAL ", "INDUSTRIAL ")                            ,;
		""                                                                                            ,;
		""                                                                                            ,;
		""                                                                                            ,;
		""                                                                                            ,;
		""                                                                                            ,;
		Transform(A007->Z13_CUSTFX,     "@E 9,999,999.9999")                                          ,;
		""                                                                                            ,;
		""                                                                                            ,;
		""                                                                                            ,;
		""                                                                                            ,;
		""                                                                                            ,;
		""                                                                                            ,;
		"CF"                                                                                          ,;
		IIF(MV_PAR09 == 2, "TOTAL ", "INDUSTRIAL ")                                                   ,;
		"   "                                                                                         })
		//--------------------------------------------------------------------

		A007->(dbCloseArea())
	EndIf

	//-----------------------------------------------
	// Impressão do resumo de custo por ContaContábil
	kv_TTVlr := 0
	kv_TTPrj := 0
	nRow1 += 125
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	rr_Total := +;
	Padr(""                                                                         ,015)+" "+;
	Padr("C.Contabil"                                                               ,020)+" "+;
	Padr("Descrição"                                                                ,035)+" "+;
	Padl("Custo"                                                                    ,014)+" "+;
	Padl("Projetado"                                                                ,014)
	oPrint:Say  (nRow1 ,0050 ,rr_Total                               ,oFont8)
	oPrint:Line (nRow1+35, 050, nRow1+35, 3350)
	nRow1 += 075

	dbSelectArea("T001")
	dbGotop()
	While !Eof()
		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf
		ss_Total := +;
		Padr(""                                                                         ,015)+" "+;
		Padr(T001->CCONTAB                                                              ,020)+" "+;
		Padr(Posicione("CT1",1,xFilial("CT1")+T001->CCONTAB,"CT1_DESC01")               ,035)+" "+;
		Padl(Transform(T001->CUSTO, "@E 9,999,999.9999")                                ,014)+" "+;
		Padl(Transform(T001->PROJT, "@E 9,999,999.9999")                                ,014)
		oPrint:Say  (nRow1 ,0050 ,ss_Total                               ,oFont8)
		nRow1 += 050
		kv_TTVlr += T001->CUSTO
		kv_TTPrj += T001->PROJT
		RecLock("T001",.F.)
		Delete
		MsUnLock()
		dbSelectArea("T001")
		dbSkip()
	End

	dbSelectArea("T003")
	dbGotop()
	While !Eof()

		If !Empty(T003->CCONTAB)
			If !ctplCtZero
				fIncRegCVar()
			Else
				ctplCtZero := .F.
			EndIf
		EndIf

		RecLock("T003",.F.)
		Delete
		MsUnLock()

		dbSelectArea("T003")
		dbSkip()

	End

	nRow1 += 050
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	ss_Total := +;
	Padr(""                                                                         ,015)+" "+;
	Padr("Total p/ Conta"                                                           ,020)+" "+;
	Padr(""                                                                         ,035)+" "+;
	Padl(Transform(kv_TTVlr, "@E 9,999,999.9999")                                   ,014)+" "+;
	Padl(Transform(kv_TTPrj, "@E 9,999,999.9999")                                   ,014)
	oPrint:Say  (nRow1 ,0050 ,ss_Total                               ,oFont8)

	fImpRoda()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpTotPrd ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 29/08/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpTotPrd()

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+ql_ProdPai))
	ql_DescPai := Substr(SB1->B1_DESC,1,50)
	ql_UmPai   := SB1->B1_UM
	ql_QtRfPai := Transform(IIF(SB1->B1_QB == 0, 1, SB1->B1_QB), "@E 999,999.999")
	ql_RAtuPai := fRetTRT(SB1->B1_COD)

	// Calcula percetual da Projeção
	ql_Perct := 0
	If ql_ToPrPai - ql_TotCPai <> 0
		If ql_TotCPai == 0
			ql_Perct := 100
		Else
			ql_Perct := (ql_ToPrPai - ql_TotCPai) / ql_TotCPai * 100
		EndIf
	EndIf

	//------------------------------------------------
	xf_CtoFix := 0
	If MV_PAR09 <> 1
		A0007 := " SELECT TOP 1 "+IIF(MV_PAR09 == 2, "Z13_CUSTFX", "Z13_DESPFX")+" Z13_CUSTFX
		A0007 += "   FROM "+RetSqlName("Z13")+" Z13
		A0007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
		A0007 += "                       AND B1_COD = '"+IIF(Empty(ql_PrdRefR), ql_ProdPai, ql_PrdRefR)+"'
		A0007 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0007 += "  WHERE Z13_FILIAL = '01'
		A0007 += "    AND '"+dtos(dDataBase)+"' >= Z13_DATADE
		A0007 += "    AND '"+dtos(dDataBase)+"' <= Z13_DATAAT
		A0007 += "    AND Z13_TIPO = '03'
		A0007 += "    AND Z13_FORMAT = B1_YFORMAT
		A0007 += "    AND Z13.D_E_L_E_T_ = ' '
		A0007 += "  ORDER BY Z13_PLANO DESC
		TcQuery A0007 ALIAS "A007" NEW
		dbSelectArea("A007")
		dbGoTop()
		xf_CtoFix := A007->Z13_CUSTFX
		A007->(dbCloseArea())
	EndIf

	ss_Total := +;
	Padr(ql_ProdPai + ql_DescPai                                                    ,080)+" "+;
	Padc(ql_RAtuPai                                                                 ,006)+" "+;
	Padr(ql_UmPai                                                                   ,002)+" "+;
	Padl(Transform(ql_TotCPai, "@E 9,999,999.9999")                                 ,014)+"  "+;
	Padl(Transform(ql_ToPrPai, "@E 9,999,999.9999")                                 ,014)+" "+;
	Padl(Transform(ql_Perct, "@E 99999.99")                                         ,008)+"  "+;
	Padl(Transform(xf_CtoFix, "@E 9,999,999.9999")                                  ,014)+"  "+;
	Padl(Transform(ql_TotCPai + xf_CtoFix, "@E 9,999,999.9999")                     ,014)+"  "+;
	Padl(Transform(ql_ToPrPai + xf_CtoFix, "@E 9,999,999.9999")                     ,014)
	oPrint:Say  (nRow1 ,0050 ,ss_Total                               ,oFont8)
	nRow1 += 050

	//------------------- Reservado para Exportação -----------------------
	Aadd(aDadoX, { ql_ProdPai                                      ,;
	ql_DescPai                                                     ,;
	ql_RAtuPai                                                     ,;
	ql_UmPai                                                       ,;
	Transform(ql_TotCPai, "@E 9,999,999.9999")                     ,;
	Transform(ql_ToPrPai, "@E 9,999,999.9999")                     ,;
	Transform(ql_Perct, "@E 99999.99")                             ,;
	Transform(xf_CtoFix, "@E 9,999,999.9999")                      ,;
	Transform(ql_TotCPai + xf_CtoFix, "@E 9,999,999.9999")         ,;
	Transform(ql_ToPrPai + xf_CtoFix, "@E 9,999,999.9999")         })
	//--------------------------------------------------------------------

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
	EndIf
	nRow1 += 025

	oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,110)                                           ,oFont14)
	oPrint:Say  (nRow1+75 ,0050 ,Padc(fCabe02,110)                                          ,oFont14)
	oPrint:Say  (nRow1+10 ,3000 ,"Página:"                                                  ,oFont7)
	oPrint:Say  (nRow1+05 ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
	oPrint:Say  (nRow1+60 ,3000 ,"Emissão:"                                                 ,oFont7)
	oPrint:Say  (nRow1+65 ,3150 ,dtoc(dDataBase)                                            ,oFont8)

	nRow1 += 175
	oPrint:Line (nRow1-40, 050, nRow1-40, 3350)

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+ql_ProdPai))
	ql_DescPai := Substr(SB1->B1_DESC,1,50)
	ql_UmPai   := SB1->B1_UM
	ql_QtRfPai := Transform(IIF(SB1->B1_QB == 0, 1, SB1->B1_QB), "@E 999,999.999")
	ql_RAtuPai := fRetTRT(SB1->B1_COD)

	ql_RefPai  := ql_ProdPai + " - " + ql_DescPai + " Unid.Medida: " + ql_UmPai + "            Qtd.Base: " + ql_QtRfPai + "      RevAtu: " + ql_RAtuPai
	oPrint:Say  (nRow1    ,0050 , ql_RefPai          ,oFont10)
	nRow1 += 075

	xf_Cabec := +;
	Padr("Produto - Descrição"                                                      ,075)+" "+;
	Padc("RevAtu"                                                                   ,006)+" "+;
	Padr("UM"                                                                       ,002)+" "+;
	Padc("TRT"                                                                      ,003)+" "+;
	Padl(IIF(MV_PAR03 == 1, "Quant. Orig", "Quant. c/Perda")                        ,017)+" "+;
	Padl("C.Unit"                                                                   ,014)+" "+;
	Padl("CustoUltCom"                                                              ,014)+" "+;
	Padc("Rf"                                                                       ,002)+" "+;
	Padc("UltCom"                                                                   ,008)+" "+;
	Padc("EP"                                                                       ,002)+" "+;
	Padl("Projetado"                                                                ,010)+" "+;
	Padl("%"                                                                        ,008)+" "+;
	Padl("Umidade"                                                                  ,008)
	oPrint:Say  (nRow1 ,0050 ,xf_Cabec                              ,oFont8)
	oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
	nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpCab01 ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 29/08/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCab01()

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
	EndIf
	nRow1 += 025

	oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,110)                                           ,oFont14)
	oPrint:Say  (nRow1+75 ,0050 ,Padc(fCabe02,110)                                          ,oFont14)
	oPrint:Say  (nRow1+10 ,3000 ,"Página:"                                                  ,oFont7)
	oPrint:Say  (nRow1+05 ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
	oPrint:Say  (nRow1+60 ,3000 ,"Emissão:"                                                 ,oFont7)
	oPrint:Say  (nRow1+65 ,3150 ,dtoc(dDataBase)                                            ,oFont8)

	nRow1 += 175
	oPrint:Line (nRow1-40, 050, nRow1-40, 3350)

	xf_Cabec := +;
	Padr("Produto - Descrição"                                                      ,080)+" "+;
	Padc("RevAtu"                                                                   ,006)+" "+;
	Padr("UM"                                                                       ,002)+" "+;
	Padl("CustoUltCom"                                                              ,014)+"  "+;
	Padl("Projetado"                                                                ,014)+" "+;
	Padl("%"                                                                        ,008)+"  "+;
	Padl("CustoFixo"                                                                ,014)+"  "+;
	Padl("TotUltCom"                                                                ,014)+"  "+;
	Padl("TotProjet"                                                                ,014)
	oPrint:Say  (nRow1 ,0050 ,xf_Cabec                              ,oFont8)
	oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
	nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (2300, 050, 2300, 3350)
	oPrint:Say  (2300+30 , 050,"Prog.: " + fPerg                                                    ,oFont7)
	oPrint:Say  (2300+30 ,0850,"Legenda: Rf -->> I=Informado; Nf=Nota Fiscal; R=Retificado "        ,oFont7)
	oPrint:Say  (2300+30 ,2850,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()                         ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ xBia776E  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 17.05.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Explode Estrutura de Produto para obter a quantidade       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xBia776E(nQuant, deDataStru, atDataStru)

	LOCAL nQuantItem:=0, cUnidMod, nG1Quant:=0, nQBase:=0, nDecimal:=0, nBack:=0
	LOCAL aTamSX3:={}
	LOCAL lOk:=.T.
	LOCAL nDecOrig:=Set(3,8)

	aTamSX3:=TamSX3("GG_QUANT")
	nDecimal:=aTamSX3[2]

	// Verifica a data de validade
	deDataStru := If((deDataStru == NIL), dDataBase, deDataStru)
	atDataStru := If((atDataStru == NIL), dDataBase, atDataStru)

	If SGG->GG_INI >= deDataStru .and. SGG->GG_FIM <= atDataStru .And. lOk

		cUnidMod := GetMv("MV_UNIDMOD")
		dbSelectArea("SB1")
		dbSeek(xFilial()+SGG->GG_COD)
		nQBase := B1_QB
		dbSeek(xFilial()+SGG->GG_COMP)
		dbSelectArea("SGG")
		nG1Quant := GG_QUANT
		If IsProdMod(GG_COMP)
			cTpHr := GetMv("MV_TPHR")
			If cTpHr == "N"
				nG1Quant := Int(nG1Quant)
				nG1Quant += ((GG_QUANT-nG1Quant)/60)*100
			EndIf
		EndIf
		If GG_FIXVAR $ " V"
			If IsProdMod(GG_COMP) .And. cUnidMOD != "H"
				nQuantItem := ((nQuant / nG1Quant) / (100 - GG_PERDA)) * 100
			Else
				nQuantItem := ((nQuant * nG1Quant) / (100 - GG_PERDA)) * 100
			EndIf
			nQuantItem := nQuantItem / Iif(nQBase <= 0,1,nQBase)
		Else
			If IsProdMod(GG_COMP) .And. cUnidMOD != "H"
				nQuantItem := (nG1Quant / (100 - GG_PERDA)) * 100
			Else
				nQuantItem := (nG1Quant / (100 - GG_PERDA)) * 100
			EndIf
		Endif
		nQuantItem:=Round(nQuantitem,nDecimal)
	EndIf

	Do Case
		Case (SB1->B1_TIPODEC == "A")
		nBack := Round( nQuantItem,0 )
		Case (SB1->B1_TIPODEC == "I")
		nBack := Int(nQuantItem)+If(((nQuantItem-Int(nQuantItem)) > 0),1,0)
		Case (SB1->B1_TIPODEC == "T")
		nBack := Int( nQuantItem )
		OtherWise
		nBack := nQuantItem
	EndCase

	Set(3,nDecOrig)

Return( nBack )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Grava C.VARIÁVEL Unitário para Orçamento                              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fIncRegCVar()

	Local gpArea := GetArea()

	CT1->( dbSetOrder(1) )
	CT1->( dbSeek(xFilial("CT1") + T003->CCONTAB ) )

	Z29->( dbSetOrder(1) )
	Z29->( dbSeek(xFilial("Z29") + CT1->CT1_YITCUS ) )

	SB1->( dbSetOrder(1) )
	SB1->( dbSeek(xFilial("SB1") + ql_ProdPai ) )

	dbSelectArea("ZBT")
	dbSetOrder(2)
	If !dbSeek(xFilial("ZBT") + MV_PAR15 + MV_PAR16 + MV_PAR17 + ql_ProdPai + T003->CCONTAB)
		RecLock("ZBT", .T.)
		ZBT->ZBT_FILIAL  := xFilial("ZBT")
		ZBT->ZBT_VERSAO  := MV_PAR15
		ZBT->ZBT_REVISA  := MV_PAR16
		ZBT->ZBT_ANOREF  := MV_PAR17
		ZBT->ZBT_COD     := ql_ProdPai
		ZBT->ZBT_CONTA   := T003->CCONTAB
		ZBT->ZBT_ITCUS   := CT1->CT1_YITCUS
	Else
		RecLock("ZBT", .F.)
	EndIf

	If DAY(MV_PAR11) == 1
		ZBT->ZBT_CTOTAL   := T003->CUSTO
	Else
		&("ZBT->ZBT_M" + StrZero(MONTH(MV_PAR11),2))   := T003->CUSTO
	EndIf

	MsUnLock()

	RestArea( gpArea )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Produto               ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"02","Ate Produto              ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"03","Ref. Quantidade          ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Quant. Orig","","","","","Quant. c/Perda","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Quais Grupos Listar      ?","","","mv_ch4","C",99,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Formanto dos Dados       ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Analítico","","","","","Sintético","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Gerar Excel              ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Tipo de Produto          ?","","","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","02"})
	aAdd(aRegs,{cPerg,"08","Caso Tipo PA             ?","","","mv_ch8","N",01,0,0,"C","","mv_par08","Ativos+Filtro","","","","","Apenas Filtro","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Imprime Custo Fixo       ?","","","mv_ch9","N",01,0,0,"C","","mv_par09","Não","","","","","Fixo Total","","","","","Fixo Industrial","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","De Data                  ?","","","mv_cha","D",08,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Até Data                 ?","","","mv_chb","D",08,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Sendo TIPO PA apenas     ?","","","mv_chc","N",01,0,0,"C","","mv_par12","Classe A","","","","","Todas as Classes","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","Filtro Aleatório         ?","","","mv_chd","N",01,0,0,"C","","mv_par13","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Gravar C.Variável p/Orcto?","","","mv_che","N",01,0,0,"C","","mv_par14","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"15","Versão Orçamentária      ?","","","mv_chf","C",10,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"16","Revisão da Versão        ?","","","mv_chg","C",03,0,0,"G","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"17","Ano Ref.                 ?","","","mv_chh","C",04,0,0,"G","","mv_par17","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"18","ForeCast                 ?","","","mv_chi","N",01,0,0,"C","","mv_par18","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"19","Mês a Imprimir           ?","","","mv_chj","C",02,0,0,"G","","mv_par19","","","","","","","","","","","","","","","","","","","","","","","","",""})	
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

Static Function fSeekTpC()

	Local _cTipo	:=	"XX"
	Local _aArea	:=	GetArea()

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+SG1->G1_COD)) .And. SB1->B1_YTPPROD == 'RP'
		If SB1->(DbSeek(xFilial("SB1")+SG1->G1_COMP)) .And. SB1->B1_YEMPEST <> '0101'
			_cTipo	   := SB1->B1_TIPO
		EndIf
	EndIF
	RestArea(_aArea)

Return _cTipo

Static Function fRetTRT(_cCodPro)

	Local _cAlias	:=	GetNextAlias()
	Local _cDataDe	:=	DtoS(MV_PAR10)
	Local _cDataAt	:=	DtoS(MV_PAR11)
	Local _cTrt

	BeginSql Alias _cAlias

		SELECT ISNULL(MAX(GG_TRT),'') GG_TRT
		FROM %TABLE:SGG% SGG
		WHERE GG_FILIAL = %XFILIAL:SGG%
		AND GG_COD = %Exp:_cCodPro%
		AND GG_INI <= %Exp:_cDataDe%
		AND GG_FIM >= %Exp:_cDataAt%
		AND %NotDel%

	EndSql

	_cTrt	:=	(_cAlias)->GG_TRT

	(_cAlias)->(DbCloseArea())
Return _cTrt

Static Function ksGrvZCH()

	kyFever := dtos( UltimoDia( stod( MV_PAR17 + "0201" ) ) )

	TY003 := " WITH FORAMIX "
	TY003 += "      AS (SELECT Z87_PRODUT PRODUT, "
	TY003 += "                 SUM([" + MV_PAR17 + "0131]) AS VMES01, "
	TY003 += "                 SUM([" + kyFever + "]) AS VMES02, "
	TY003 += "                 SUM([" + MV_PAR17 + "0331]) AS VMES03, "
	TY003 += "                 SUM([" + MV_PAR17 + "0430]) AS VMES04, "
	TY003 += "                 SUM([" + MV_PAR17 + "0531]) AS VMES05, "
	TY003 += "                 SUM([" + MV_PAR17 + "0630]) AS VMES06, "
	TY003 += "                 SUM([" + MV_PAR17 + "0731]) AS VMES07, "
	TY003 += "                 SUM([" + MV_PAR17 + "0831]) AS VMES08, "
	TY003 += "                 SUM([" + MV_PAR17 + "0930]) AS VMES09, "
	TY003 += "                 SUM([" + MV_PAR17 + "1031]) AS VMES10, "
	TY003 += "                 SUM([" + MV_PAR17 + "1130]) AS VMES11, "
	TY003 += "                 SUM([" + MV_PAR17 + "1231]) AS VMES12 "
	TY003 += "          FROM (SELECT * "
	TY003 += "                  FROM " + RetSqlName("Z87") + " Z87 "
	TY003 += "                 WHERE Z87_DATARF BETWEEN '" + MV_PAR17 + "0131' AND '" + MV_PAR17 + "1231' "
	TY003 += "                       AND NOT EXISTS ( SELECT * "
	TY003 += "                                          FROM " + RetSqlName("ZCH") + " "
	TY003 += "                                         WHERE ZCH_VERSAO = '" + MV_PAR15 + "' "
	TY003 += "                                               AND ZCH_REVISA = '" + MV_PAR16 + "' "
	TY003 += "                                               AND ZCH_ANOREF = '" + MV_PAR17 + "' "
	TY003 += "                                               AND ZCH_CODPRO = Z87_PRODUT "
	TY003 += "                                               AND D_E_L_E_T_ = ' ') "
	TY003 += "                       AND D_E_L_E_T_ = ' ' "
	TY003 += "               ) TMP PIVOT(SUM(Z87_CUSTO1) FOR Z87_DATARF IN([" + MV_PAR17 + "0131], "
	TY003 += "                                                             [" + kyFever + "], "
	TY003 += "                                                             [" + MV_PAR17 + "0331], "
	TY003 += "                                                             [" + MV_PAR17 + "0430], "
	TY003 += "                                                             [" + MV_PAR17 + "0531], "
	TY003 += "                                                             [" + MV_PAR17 + "0630], "
	TY003 += "                                                             [" + MV_PAR17 + "0731], "
	TY003 += "                                                             [" + MV_PAR17 + "0831], "
	TY003 += "                                                             [" + MV_PAR17 + "0930], "
	TY003 += "                                                             [" + MV_PAR17 + "1031], "
	TY003 += "                                                             [" + MV_PAR17 + "1130], "
	TY003 += "                                                             [" + MV_PAR17 + "1231])) P "
	TY003 += "          GROUP BY Z87_PRODUT) "
	TY003 += "      SELECT '" + xFilial("ZCH") + "' ZCH_FILIAL, "
	TY003 += " 	           '        ' ZCH_DATREF, " 
	TY003 += "             PRODUT ZCH_CODPRO, " 
	TY003 += "             '' ZCH_DESPRO, "
	TY003 += "             '' ZCH_GRPPRO, "
	TY003 += "             0 ZCH_QATU, "
	TY003 += "             0 ZCH_CM1, "
	TY003 += "             '' ZCH_DULENT, "
	TY003 += "             0 ZCH_VULENT, "
	TY003 += "             0 ZCH_YCTREF, "
	TY003 += "             0 ZCH_CUSMAN, "
	TY003 += "             '" + MV_PAR15 + "' ZCH_VERSAO, "
	TY003 += "             '" + MV_PAR16 + "' ZCH_REVISA, "
	TY003 += "             '" + MV_PAR17 + "' ZCH_ANOREF, "
	TY003 += "             0 ZCH_VLIQ, "
	TY003 += "             0 ZCH_VFRET, "
	TY003 += "             0 ZCH_VBRUT, "
	TY003 += "             VMES01 ZCH_VMES01, "
	TY003 += "             VMES02 ZCH_VMES02, "
	TY003 += "             VMES03 ZCH_VMES03, "
	TY003 += "             VMES04 ZCH_VMES04, "
	TY003 += "             VMES05 ZCH_VMES05, "
	TY003 += "             VMES06 ZCH_VMES06, "
	TY003 += "             VMES07 ZCH_VMES07, "
	TY003 += "             VMES08 ZCH_VMES08, "
	TY003 += "             VMES09 ZCH_VMES09, "
	TY003 += "             VMES10 ZCH_VMES10, "
	TY003 += "             VMES11 ZCH_VMES11, "
	TY003 += "             VMES12 ZCH_VMES12 "
	TY003 += "      FROM FORAMIX "
	TY003 += "      WHERE VMES01 + VMES02 + VMES03 + VMES04 + VMES05 + VMES06 + VMES07 + VMES08 + VMES09 + VMES10 + VMES11 + VMES12 <> 0 "
	TYIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TY003),'TY03',.T.,.T.)
	dbSelectArea("TY03")
	dbGoTop()
	While !Eof()

		Reclock("ZCH",.T.)
		ZCH->ZCH_FILIAL := TY03->ZCH_FILIAL
		ZCH->ZCH_DATREF := stod(TY03->ZCH_DATREF)
		ZCH->ZCH_CODPRO := TY03->ZCH_CODPRO
		ZCH->ZCH_DESPRO := TY03->ZCH_DESPRO
		ZCH->ZCH_GRPPRO := TY03->ZCH_GRPPRO
		ZCH->ZCH_QATU   := TY03->ZCH_QATU
		ZCH->ZCH_CM1    := TY03->ZCH_CM1
		ZCH->ZCH_DULENT := stod(TY03->ZCH_DULENT)
		ZCH->ZCH_VULENT := TY03->ZCH_VULENT
		ZCH->ZCH_YCTREF := TY03->ZCH_YCTREF
		ZCH->ZCH_CUSMAN := TY03->ZCH_CUSMAN
		ZCH->ZCH_VERSAO := TY03->ZCH_VERSAO
		ZCH->ZCH_REVISA := TY03->ZCH_REVISA
		ZCH->ZCH_ANOREF := TY03->ZCH_ANOREF
		ZCH->ZCH_VLIQ   := TY03->ZCH_VLIQ
		ZCH->ZCH_VFRET  := TY03->ZCH_VFRET
		ZCH->ZCH_VBRUT  := TY03->ZCH_VBRUT
		ZCH->ZCH_DATIMP := Date()
		ZCH->ZCH_VMES01 := TY03->ZCH_VMES01
		ZCH->ZCH_VMES02 := TY03->ZCH_VMES02
		ZCH->ZCH_VMES03 := TY03->ZCH_VMES03
		ZCH->ZCH_VMES04 := TY03->ZCH_VMES04
		ZCH->ZCH_VMES05 := TY03->ZCH_VMES05
		ZCH->ZCH_VMES06 := TY03->ZCH_VMES06
		ZCH->ZCH_VMES07 := TY03->ZCH_VMES07
		ZCH->ZCH_VMES08 := TY03->ZCH_VMES08
		ZCH->ZCH_VMES09 := TY03->ZCH_VMES09
		ZCH->ZCH_VMES10 := TY03->ZCH_VMES10
		ZCH->ZCH_VMES11 := TY03->ZCH_VMES11
		ZCH->ZCH_VMES12 := TY03->ZCH_VMES12
		ZCH->ZCH_USER   := cUserName
		ZCH->ZCH_HORIMP := Time()
		ZCH->ZCH_FILEIN := ""
		ZCH->(MsUnlock())

		dbSelectArea("TY03")
		dbSkip()

	End
	TY03->(dbCloseArea())
	Ferase(TYIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TYIndex+OrdBagExt())          //indice gerado

Return
