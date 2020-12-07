#Include "protheus.ch"
#Include 'TOPCONN.CH'


User Function BIA249RT()
	
	Local oReport	:= Nil
	Local cLoad	    := "BIA249RT" + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	
	Private dDataI	:= Nil
	Private dDataF	:= NiL
	
	Private MV_PAR01 := STOD('')
	Private MV_PAR02 := STOD('')
	
	Private aPergs := {}
	
	aAdd( aPergs ,{1,"Da data" 	   			,MV_PAR01 ,""  ,"", ''		,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até data" 	   		,MV_PAR02 ,""  ,"", '' 		,'.T.',50,.F.})	
	
	If ParamBox(aPergs ,"Filtro fat. con. (Protheus X Ecois) sem encerramento do ticket",,,,,,,,cLoad,.T.,.T.)

		MV_PAR01 := ParamLoad(cFileName,	,	1,	MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,	,	2,	MV_PAR02)
		
		dDataI	:= IIF(!Empty(MV_PAR01), DTOS(MV_PAR01), MV_PAR01)
		dDataF	:= IIF(!Empty(MV_PAR02), DTOS(MV_PAR02), MV_PAR02)
			
		oReport := reportDef()
		oReport:printDialog()
					
	EndIf
	
Return
 
 
Static Function reportDef()
	
	Local oReport	:= Nil	
	Local oSection1	:= Nil
	Local cTitulo 	:= 'FATURAMENTO CONCLUIDO (Protheus X Ecois) SEM ENCERRAMENTO DO TICKET'
 
	oReport := TReport():New('BIA249RT', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir os faturamento concluido (Protheus X Ecois) sem encerramento do ticket.")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	
	oSection1 := TRSection():New(oReport, "TICKET_SEM_ENCERRAMENTO",{})
	oSection1:SetTotalInLine(.F.)
	
	TRCell():New(oSection1, "DATA"				, , 'Hora Entrada'			, , TamSX3("Z11_HORAIN")[1]+20	,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)		
	TRCell():New(oSection1, "NUM_DOC"			, , 'Nota Fiscal'			, , TamSX3("F2_DOC")[1]+20		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "SERIE"				, , 'Série'					, , TamSX3("F2_SERIE")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "CARGA"				, , 'Carga'					, , TamSX3("ZZV_CARGA")[1]+10	,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "NUMERO_OC"			, , 'Número OC Ecosis'		, , TamSX3("ZZV_CARGA")[1]+20	,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "TICKET"			, , 'Ticket'				, , TamSX3("Z11_PESAGE")[1]+10	,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)			
		
Return (oReport)
 
 
Static Function PrintReport(oReport)

	Local oSection1 	:= oReport:Section(1)
	Local cQuery		:= MontaQuery()
	Local cAliasTrab	:= GetNextAlias()
	
	TCQUERY cQuery NEW ALIAS cAliasTrab	
	
	oReport:SetMeter(cAliasTrab->(RecCount()))
	
	While !(cAliasTrab->(Eof()))
		
		If (oReport:Cancel())
			Exit
		EndIf
		
		
		oSection1:Init()
		
		oReport:IncMeter()
		
		oSection1:Cell("DATA"):SetValue(cvaltochar(DToC(cAliasTrab->DATA)))
		oSection1:Cell("NUM_DOC"):SetValue(AllTrim(cAliasTrab->NUM_DOC))
		oSection1:Cell("SERIE"):SetValue(AllTrim(cAliasTrab->SERIE))
		oSection1:Cell("CARGA"):SetValue(AllTrim(cAliasTrab->CARGA))
		oSection1:Cell("NUMERO_OC"):SetValue(AllTrim(cAliasTrab->NUMERO_OC))
		oSection1:Cell("TICKET"):SetValue(AllTrim(cAliasTrab->TICKET))
		oSection1:Printline()				
		
		oReport:SkipLine()
 		
 		cAliasTrab->(DbSkip())		
	EndDo
	
	oSection1:Finish()
	cAliasTrab->(DbCloseArea())
	
Return


Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	
	
	cQuery += " SELECT 	 																			"+ Enter
	cQuery += " TICKET		= Z11_PESAGE,															"+ Enter
	cQuery += " HORA		= Z11_HORAIN,															"+ Enter
	cQuery += " DATA		= CONVERT(date, Z11_DATAIN),											"+ Enter
	cQuery += " CARGA		= ZZV_CARGA,															"+ Enter
	cQuery += " NUMERO_OC	= FAT.ford_numero,														"+ Enter
	cQuery += " NUM_DOC		= F2_DOC,																"+ Enter
	cQuery += " SERIE		= F2_SERIE																"+ Enter
	cQuery += " FROM Z11010 Z11 (NOLOCK) 															"+ Enter
	cQuery += " INNER JOIN ZZV010 ZZV (NOLOCK) ON													"+ Enter
	cQuery += " 	 Z11.Z11_PESAGE		= ZZV.ZZV_TICKET 											"+ Enter
	cQuery += " 	 AND ZZV.D_E_L_E_T_	= ''														"+ Enter
	cQuery += " INNER JOIN "+RetSQLName("SF2")+" SF2  (NOLOCK) ON 									"+ Enter
	cQuery += " 	 SUBSTRING(SF2.F2_YAGREG, 5, 4)		= ZZV.ZZV_CARGA 							"+ Enter
	cQuery += " 	 AND SF2.D_E_L_E_T_	= '' 														"+ Enter
	cQuery += " 	 AND F2_CHVNFE		<> '' 														"+ Enter
	cQuery += " INNER JOIN DADOSEOS.dbo.fat_ordem_faturamento FAT (NOLOCK) ON 						"+ Enter							
	cQuery += " 			ZZV.ZZV_CARGA COLLATE Latin1_General_BIN = FAT.ford_num_carga 			"+ Enter				
	cQuery += " 			AND FAT.ford_cancelada = 0												"+ Enter
	cQuery += " WHERE  																				"+ Enter
	cQuery += " 	Z11.D_E_L_E_T_	= '' 															"+ Enter
	cQuery += " 	AND Z11_PESOIN	> 0.01															"+ Enter
	cQuery += " 	AND Z11_PESOSA	= 0 															"+ Enter
	
	If (!Empty(dDataI) .And. !Empty(dDataF))
		cQuery += "	AND Z11_DATAIN BETWEEN  '"+dDataI+"' AND '"+dDataF+"' 							"+ Enter
	EndIf	
		
Return cQuery

