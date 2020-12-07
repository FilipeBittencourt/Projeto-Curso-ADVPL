#INCLUDE "PROTHEUS.CH"  
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

//---------------------------------------------------------------------------
// Programa:	Relatório de Solicitações Pendentes
// 				Thiago Dantas
// 				19/02/15
//---------------------------------------------------------------------------
User Function BIA231()

	Local oReport
	Private cPerg    := "BIA231"
	Private nEmp	 := ""

	If !Alltrim(cEmpAnt) $ "01_05_13_14"
		MsgAlert('A empresa atual não realiza Solicitação de Compras!')
		Return
	EndIf
	
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	
	ValidPerg()
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	oReport:= ReportDef()
	oReport:PrintDialog()
	
Return
//---------------------------------------------------------------------------
Static Function ReportDef()
    
	Enter 	:= CHR(13)+CHR(10)
	cSql	:= getSql()
	
	IF chkfile("BIA231")
		dbSelectArea("BIA231")
		dbCloseArea()
	ENDIF
	TcQuery cSql New Alias "BIA231"
	DbSelectArea("BIA231")
	                                                       
	cTitulo := "Solicitações Pendentes"

	oReport:= TReport():New(cTitulo,"Solicitações Pendentes", , {|oReport| PrintReport(oReport)},"Solicitações Pendentes")	
	
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
    
	oSection1 := TRSection():New(oReport,OemToAnsi("Solicitações"),{"BIA231"})    
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1,"BIZAGI"	 	,/**/, "Num Bizagi"		,/**/,10,/**/	)
	TRCell():New(oSection1,"SC"	 		,/**/, "Num SC"			,/**/,10,/**/	)	
	TRCell():New(oSection1,"ITEM"	 	,/**/, "Item"			,/**/,10,/**/	)
	TRCell():New(oSection1,"DESCRICAO"	,/**/, "Descrição"		,/**/,100,/**/	)
	TRCell():New(oSection1,"GRUPO"	 	,/**/, "Grupo"			,/**/,10,/**/	)
	TRCell():New(oSection1,"EMISSAO" 	,/**/, "Data Emissão"	,/**/,15,/**/	)
	TRCell():New(oSection1,"APROVACAO" 	,/**/, "Data Aprovação"	,/**/,15,/**/	)
	TRCell():New(oSection1,"SOLICITANTE",/**/, "Solicitante"	,/**/,50,/**/	)
	TRCell():New(oSection1,"DTINCLUSAO" ,/**/, "Dt.Inclusão"	,/**/,15,/**/	)
	TRCell():New(oSection1,"ALMOX" ,/**/, "Almox."	,/**/,10,/**/	)

Return oReport
//---------------------------------------------------------------------------
Static Function PrintReport(oReport)
	
	Local lImprime  := .F.
	Local oSection1 := oReport:Section(1)
	Local nValorTot := 0
	Local nPrazoTot := 0
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
	
	DbSelectArea("BIA231")
	dbGoTop()
	
	oReport:SetMeter(BIA231->(RecCount()))

  	While BIA231->(!Eof())

		lImprime := .T.
		
		If oReport:Cancel()
			Exit
		EndIf  
	
		oReport:IncMeter()
		oSection1 := oReport:Section(1)
		oSection1:Init()

		oSection1:Cell("BIZAGI"	):SetValue(BIA231->C1_YBIZAGI)
		oSection1:Cell("BIZAGI"	):SetAlign("CENTER")

		oSection1:Cell("SC"	):SetValue(BIA231->C1_NUM)
		oSection1:Cell("SC"	):SetAlign("CENTER")

		oSection1:Cell("ITEM"	):SetValue(BIA231->C1_ITEM)
		oSection1:Cell("ITEM"	):SetAlign("CENTER")

		oSection1:Cell("DESCRICAO"	):SetValue(BIA231->C1_DESCRI)
		oSection1:Cell("DESCRICAO"	):SetAlign("LEFT")

		oSection1:Cell("GRUPO"	):SetValue(BIA231->B1_GRUPO)
		oSection1:Cell("GRUPO"	):SetAlign("CENTER")		

		oSection1:Cell("EMISSAO"	):SetValue(DToC(SToD(BIA231->C1_EMISSAO)))
		oSection1:Cell("EMISSAO"	):SetAlign("CENTER")
        
		oSection1:Cell("APROVACAO"	):SetValue(DToC(SToD(BIA231->C1_YDATHOR)))
		oSection1:Cell("APROVACAO"	):SetAlign("CENTER")

		oSection1:Cell("SOLICITANTE"):SetValue(BIA231->SOLICIT)
		oSection1:Cell("SOLICITANTE"):SetAlign("LEFT")

		oSection1:Cell("DTINCLUSAO"):SetValue(DToC(SToD(BIA231->C1_YDTINCB)))
		oSection1:Cell("DTINCLUSAO"):SetAlign("CENTER")

		oSection1:Cell("ALMOX"):SetValue(BIA231->C1_LOCAL)
		oSection1:Cell("ALMOX"):SetAlign("CENTER")

		oSection1:PrintLine()
		BIA231->(DBSKIP())
	End
	
    BIA231->(dbCloseArea())
    
	If lImprime
		oSection1:Finish()
	EndIf
	
	
Return
//---------------------------------------------------------------------------
Static Function getSql()
Local cSql := ""

cSql += "SELECT C1_YBIZAGI" + Enter
cSql += "	, C1_NUM" + Enter
cSql += "	, C1_ITEM" + Enter
cSql += "	, C1_DESCRI" + Enter
cSql += "	, C1_EMISSAO" + Enter
cSql += "	, C1_YDATHOR" + Enter
cSql += "	, C1_YMAT" + Enter
cSql += "	, C1_SOLICIT" + Enter
cSql += "	, C1_YDTINCB" + Enter
cSql += "	, RA_NOME" + Enter
cSql += "	, ISNULL(RA_NOME, C1_SOLICIT) AS SOLICIT" + Enter
cSql += "	, B1_GRUPO" + Enter
cSql += "	, C1_LOCAL" + Enter
cSql += "FROM " + RetSqlName("SC1") + " SC1 WITH(NOLOCK)" + Enter
cSql += "	INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON B1_COD = SC1.C1_PRODUTO AND SB1.D_E_L_E_T_ = ''" + Enter
cSql += "	LEFT JOIN " + RetSqlName("SRA") + " SRA WITH(NOLOCK) ON RA_MAT = C1_YMAT AND SRA.D_E_L_E_T_ = ''" + Enter
cSql += "WHERE C1_FILIAL = '" + xFilial("SC1") + "'" + Enter
cSql += "	AND C1_RESIDUO <> 'S'" + Enter
cSql += "	AND C1_COTACAO <> 'IMPORX'" + Enter
cSql += "	AND SC1.C1_APROV NOT IN ('B','R')" + Enter
cSql += "	AND ((C1_PEDIDO = ''" + Enter
cSql += "			AND SC1.C1_QUJE = 0" + Enter
cSql += "			AND NOT EXISTS (SELECT *" + Enter
cSql += "				FROM " + RetSqlName("SC7") + "" + Enter
cSql += "				WHERE C7_FILIAL = '" + xFilial("SC7") + "'" + Enter
cSql += "					AND C7_NUMSC = C1_NUM" + Enter
cSql += "					AND C7_PRODUTO = C1_PRODUTO" + Enter
cSql += "					AND C7_ITEMSC  = C1_ITEM" + Enter
cSql += "					AND C7_RESIDUO <> 'S'" + Enter
cSql += "					AND D_E_L_E_T_ = ''))" + Enter
cSql += "		OR (C1_PEDIDO <> ''" + Enter
cSql += "			AND SC1.C1_QUJE <> SC1.C1_QUANT" + Enter
cSql += "			AND EXISTS (SELECT *" + Enter
cSql += "				FROM " + RetSqlName("SC7") + "" + Enter
cSql += "				WHERE C7_FILIAL = '" + xFilial("SC7") + "'" + Enter
cSql += "					AND C7_NUMSC = C1_NUM" + Enter
cSql += "					AND C7_PRODUTO = C1_PRODUTO" + Enter
cSql += "					AND C7_ITEMSC  = C1_ITEM" + Enter
cSql += "					AND C7_RESIDUO <> 'S'" + Enter
cSql += "					AND D_E_L_E_T_ = '')))" + Enter
cSql += "	AND SC1.C1_YBIZAGI BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + Enter
cSql += "	AND SC1.C1_NUM BETWEEN '" + MV_PAR03 + "' AND '"+MV_PAR04 + "'" + Enter
cSql += "	AND SC1.C1_EMISSAO BETWEEN '" + DToS(MV_PAR05) + "' AND '" + DToS(MV_PAR06) + "'" + Enter
cSql += "	AND SC1.D_E_L_E_T_ = ''" + Enter
cSql += "	AND B1_GRUPO <> 'PA'" + Enter
cSql += "ORDER BY C1_NUM, C1_ITEM" + Enter

Return cSql
//---------------------------------------------------------------------------
Static Function ValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Da  SC Bizagi  		?","","","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate SC Bizagi   	?","","","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Da  Numero SC  		?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Ate Numero SC  		?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Da  Data   			?","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Ate Data   			?","","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
//---------------------------------------------------------------------------