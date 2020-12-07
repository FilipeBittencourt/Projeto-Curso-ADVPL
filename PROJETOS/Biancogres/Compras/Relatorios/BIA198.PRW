#INCLUDE "PROTHEUS.CH"  
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"


//---------------------------------------------------------------------------
// Programa:	Relatório de Calculo Tempo Medio
// 				Thiago Dantas
// 				15/08/14
//---------------------------------------------------------------------------
User Function BIA198()

	Local oReport
	Local cPerg      := "TEMMED"
	Private nEmp	 := ""

	If !Alltrim(cEmpAnt) $ "01_05"
		MsgAlert('Este relatório somente poderá ser emitido nas empresas Biancogres e Incesa')
		Return
	EndIf
	
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	
	//ValidPerg()
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	oReport:= ReportDef()
	oReport:PrintDialog()
	
Return
//---------------------------------------------------------------------------
Static Function ReportDef()
     
	Enter 	   := CHR(13)+CHR(10)

	cSql := ""
	cSql += " SELECT C7_NUM, C7_ITEM, C7_EMISSAO, C7_NUMSC, C1_YDATHOR, DATEDIFF(DAY,CONVERT(DATETIME,C1_YDATHOR),CONVERT(DATETIME,C7_EMISSAO)) AS DIAS  " +Enter
	cSql += " FROM 																													" +Enter
	cSql += " (																														" +Enter
	cSql += " SELECT C7_NUM, C7_ITEM, C7_EMISSAO, C7_NUMSC, C7_ITEMSC, C7_PRODUTO, C1_EMISSAO,										" +Enter
	cSql += " 		CASE 																											" +Enter
	cSql += "           WHEN SUBSTRING(C1_YDATHOR,1,8) = ' ' AND C1_YMAT = ' ' 				 THEN C1_EMISSAO						" +Enter
	cSql += "           WHEN C1_YDTINCB <> '' AND SUBSTRING(C1_YDATHOR,1,8) <> C1.C1_YDTINCB THEN C1_YDTINCB  						" +Enter
	cSql += "           ELSE 																										" +Enter
	cSql += "             CASE 																										" +Enter
	cSql += "               WHEN SUBSTRING(C1_YDTCDNP,1,8) > SUBSTRING(C1_YDATHOR,1,8) THEN 										" +Enter
	cSql += "                 SUBSTRING(C1_YDTCDNP,1,8) 																			" +Enter
	cSql += "               ELSE 																									" +Enter
	cSql += "                 SUBSTRING(C1_YDATHOR,1,8) 																			" +Enter
	cSql += "               END 																									" +Enter
	cSql += " 		END C1_YDATHOR 																									" +Enter
	cSql += " FROM 			"+RetSqlName("SC7")+" C7																				" +Enter
	cSql += " INNER JOIN 	"+RetSqlName("SC1")+" C1 ON C1_NUM = C7_NUMSC AND C1_ITEM = C7_ITEMSC AND C1.D_E_L_E_T_ = '' 			" +Enter
	cSql += " WHERE	C7_RESIDUO = ' ' 																								" +Enter
	cSql += " AND	C7.D_E_L_E_T_ = ''																								" +Enter
	cSql += " ) TMP																													" +Enter
	cSql += " WHERE DATEDIFF(DAY,CONVERT(DATETIME,C1_YDATHOR),CONVERT(DATETIME,C7_EMISSAO)) >= 0									" +Enter
	cSql += " AND C1_YDATHOR <> ' ' 																								" +Enter
	cSql += " AND  C7_EMISSAO BETWEEN '" +DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02) +"'												" +Enter
	If MV_PAR03 == 1
		// Filtra Produto
		cSql += "    AND SUBSTRING(C7_PRODUTO,1,3) <> '306' " + Enter
	Else
		// Filtra Serviços
		cSql += "    AND SUBSTRING(C7_PRODUTO,1,3) = '306' " + Enter
	EndIf
	cSql += " ORDER BY C7_NUM, C7_ITEM, C7_NUMSC																						" +Enter
	
	IF chkfile("TAB0001")
		dbSelectArea("TAB0001")
		dbCloseArea()
	ENDIF
	TcQuery cSql New Alias "TAB0001"
	DbSelectArea("TAB0001")
	
	cTitulo := ""
	cGenero := ""
	If MV_PAR03 == 1
		cTitulo := "Tempo Compra de Produtos"
		cGenero := "Produtos Comprados"
	Else
		cTitulo := "Tempo Contratação de Serviços"
		cGenero := "Serviços Contratados"
	EndIF
	
	oReport:= TReport():New(cTitulo,"Tempo Medio", , {|oReport| PrintReport(oReport)},"Tempo Medio")	
	
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
    
	oSection1 := TRSection():New(oReport,OemToAnsi("Pedidos"),{"TAB0001"})    
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1,"SOLICITACAO"	,/**/, "Solicitação"		,/**/,7,/**/	)
	TRCell():New(oSection1,"EMISSAO"		,/**/, "Data Solicitação"	,/**/,12,/**/	)
	TRCell():New(oSection1,"PEDIDO"			,/**/, "Pedido"				,/**/,7,/**/	)
	TRCell():New(oSection1,"ITEM"			,/**/, "Item"				,/**/,4,/**/	)
	TRCell():New(oSection1,"DTPEDIDO"		,/**/, "Data Pedido"		,/**/,12,/**/	)	
	TRCell():New(oSection1,"DIAS"			,/**/, "Tempo(dias)"		,/**/,10,/**/	)
	
	//TRFUNCTION():New(oCell				,cName ,cFunction ,oBreak, cTitle		, cPicture, uFormula   ,lEndSection,lEndReport    ,lEndPage,oParent,bCondition,lDisable,bCanPrint) 	
	oFuncao := TRFunction():New(oSection1:Cell("DIAS") ,"MEDIA","AVERAGE" ,		 ,"Tempo Médio" ,"@E 999" ,/*uFormula*/,/*secao*/.F.,/*report*/.T.,/*pagina*/.F.)
	oFuncao:SetTotalText("Tempo Médio Gasto")
	oFuncao:ShowFooter()

Return oReport
//---------------------------------------------------------------------------
Static Function PrintReport(oReport)
	
	Local lImprime := .F.
	Local oSection1 := oReport:Section(1)
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
	
	DbSelectArea("TAB0001")
	dbGoTop()
	
	oReport:SetMeter(TAB0001->(RecCount()))

  	While TAB0001->(!Eof())

		lImprime := .T.
		
		If oReport:Cancel()
			Exit
		EndIf  
	
		oReport:IncMeter()
		oSection1 := oReport:Section(1)
		oSection1:Init()

		oSection1:Cell("SOLICITACAO"	):SetValue(TAB0001->C7_NUMSC)
		oSection1:Cell("SOLICITACAO"	):SetAlign("CENTER")
		
		oSection1:Cell("EMISSAO"		):SetValue(STOD(TAB0001->C1_YDATHOR))
		oSection1:Cell("EMISSAO"		):SetAlign("CENTER")
	 		
		oSection1:Cell("PEDIDO"			):SetValue(TAB0001->C7_NUM)
		oSection1:Cell("PEDIDO"			):SetAlign("CENTER")

		oSection1:Cell("ITEM"			):SetValue(TAB0001->C7_ITEM)
		oSection1:Cell("ITEM"			):SetAlign("CENTER")

		oSection1:Cell("DTPEDIDO"		):SetValue(STOD(TAB0001->C7_EMISSAO))
		oSection1:Cell("DTPEDIDO"		):SetAlign("CENTER")
		
		oSection1:Cell("DIAS"			):SetValue(TAB0001->DIAS)
		oSection1:Cell("DIAS"			):SetAlign("CENTER")
		
		oSection1:PrintLine()
		TAB0001->(DBSKIP())
	End
    TAB0001->(dbCloseArea())
    
	If lImprime
		//oSection1:GetFunction("MEDIA_DIAS")	
		oSection1:Finish()
	EndIf
	
	
Return                                                                       
//---------------------------------------------------------------------------
Static Function ValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","De Data             ?"		,"","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Data            ?"		,"","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
//aAdd(aRegs,{cPerg,"03","De Produto          ?"		,"","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
//aAdd(aRegs,{cPerg,"04","Ate Produto         ?"		,"","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
//aAdd(aRegs,{cPerg,"05","De Cliente         ?"		,"","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA1"})
//aAdd(aRegs,{cPerg,"06","Ate Cliente        ?"		,"","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA1"})
//aAdd(aRegs,{cPerg,"07","De Representante         ?"	,"","","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA3"})
//aAdd(aRegs,{cPerg,"08","Ate Representante        ?"	,"","","mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SA3"})


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