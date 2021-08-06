#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Função: | BIA230																    			|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 08/07/15																			  |
|-----------------------------------------------------------|
| Desc.:	|	Relatorio de Acompanhamento de Pesagem 					|
|-----------------------------------------------------------|
*/


User Function BIA230()
	Local oReport
	Private cPerg 		:= "BIA230"
	Private cQry 		:= GetNextAlias()

	If !Alltrim(cEmpAnt) $ "01_05_13_14"
		MsgAlert('Este relatório somente poderá ser emitido nas empresas Biancogres, Incesa e Mundi')
		Return
	EndIf

	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)

	ValidPerg()

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	If (MV_PAR13 == 1)
		oReport:= ReportDefP()
		oReport:PrintDialog()
	Else
		oReport:= ReportDefA()
		oReport:PrintDialog()
	EndIf

Return
//---------------------------------------------------------------------------
Static Function ReportDefP()

	Local oSecTotal	:= Nil

	cTitulo := "Carregamentos"

	oReport:= TReport():New(cTitulo,"Carregamentos - "+ dToc(MV_PAR07)+ " até "+ dToc(MV_PAR08), , {|oReport| PrintReport(oReport, cQry)},"Carregamentos")

	// Altera tipo de impressao para paisagem
	oReport:SetLandScape(.T.)

	oSecCar := TRSection():New(oReport, "Carregamento", cQry)

	TRCell():New(oSecCar,"Z11_PESAGE", cQry, "Ticket",, 12)
	TRCell():New(oSecCar,"ZZV_CARGA", cQry, "Carga",, 10)
	TRCell():New(oSecCar,"AMOSTRA", cQry, "Amostra",, 10, , {|| If ((cQry)->AMOSTRA > 0,"x","") })
	TRCell():New(oSecCar,"Z11_PCAVAL", cQry, "Placa",, 14)
	TRCell():New(oSecCar,"Z11_MOTPAT", cQry, "M. Pat?",, 8,, {|| If (AllTrim((cQry)->Z11_MOTPAT)=='S',"Sim","Não") })
	TRCell():New(oSecCar,"Z11_MOTORI",cQry, "Motorista",, 60)
	TRCell():New(oSecCar,"Z11_HORACH", cQry, "Hr Apr Mot",, 10)
	TRCell():New(oSecCar,"A4_NOME", cQry, "Transportadora",, 60)
	TRCell():New(oSecCar,"QTD", cQry, "Qtd. m²", "@E 99999999.99", 12)
	TRCell():New(oSecCar,"Z11_HORAIN", cQry, "Hr Ini",, 10)
	TRCell():New(oSecCar,"Z11_HORASA", cQry, "Hr Fin",, 10)
	TRCell():New(oSecCar,"Z11_PESMAX", cQry, "Pes Max.", "@E 99999999.99", 20)
	TRCell():New(oSecCar,"Z11_TARA", cQry, "Tara", "@E 99999999.99", 20)
	TRCell():New(oSecCar,"Z11_PESOIN", cQry, "Pes Ini", "@E 99999999.99", 20)
	TRCell():New(oSecCar,"Z11_PESOSA", cQry, "Pes Fin", "@E 99999999.99", 20)
	TRCell():New(oSecCar,"Z11_PESLIQ", cQry, "Pes Liq", "@E 99999999.99", 20)
	TRCell():New(oSecCar,"Z11_OBSER", cQry, "Observação",, 150)


	//TRFunction():New(oSecCar:Cell("QTD"), Nil, "SUM", oBreak, Nil, Nil, Nil, .F., .F.)
	TRFunction():New(oSecCar:Cell("QTD"), NIL,"SUM",,NIL,NIL,NIL,.F.,.F.)


	oSecTotal := TRSection():New(oReport, "Totais", "TEMP")
	TRCell():New( oSecTotal, "DESCRICAO"	,,"Forno"		,"@"					,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSecTotal, "QUANT1"		,,"Quant. M2"	,"@"					,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSecTotal, "QUANT2"		,,"Caixas"		,"@"					,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSecTotal, "QUANT3"		,,"PESO BR (Kg)","@"					,20,/*lPixel*/,/*{|| code-block de impressao }*/)


Return(oReport)


Static Function ReportDefA()

	//Local cQry 		:= GetNextAlias()
	Local oSecTotal	:= Nil
	Local nI		:= 0
	Local cDesc		:= ""
	Local aListaG 	:= {}


	cTitulo := "Carregamentos Agendados"

	oReport:= TReport():New(cTitulo,"Carregamentos Agendados - "+ dToc(MV_PAR07)+ " até "+ dToc(MV_PAR08), , {|oReport| PrintReport(oReport, cQry)},"Carregamentos")

	// Altera tipo de impressao para paisagem
	oReport:SetLandScape(.T.)

	oSecCar := TRSection():New(oReport, "Carregamento", cQry)

	TRCell():New(oSecCar, "EMP"	,cQry, "Emp.",, 20)

	TRCell():New(oSecCar,"ZZV_DATAAG"	,cQry, "Data Age.",, 20, , {|| stod(cvaltochar((cQry)->ZZV_DATAAG))})
	TRCell():New(oSecCar,"ZZV_HORAAG"	,cQry, "Hora Age.",, 20)
	TRCell():New(oSecCar,"Z11_HORACH"	,cQry, "Hr Apr Mot",, 10)
	TRCell():New(oSecCar,"ZZV_CARGA"	,cQry, "Carga",, 10)
	TRCell():New(oSecCar,"AMOSTRA"		,cQry, "Amostra",, 10, , {|| If ((cQry)->AMOSTRA > 0,"x","") })
	TRCell():New(oSecCar,"Z11_PCAVAL"	,cQry, "Placa",, 14)
	//TRCell():New(oSecCar,"PLACA_NOVA"	,cQry, "P. Nova",, 14)
	TRCell():New(oSecCar,"Z11_MOTPAT"	,cQry, "M. Pat?",, 8,, {|| If (AllTrim((cQry)->Z11_MOTPAT)=='S',"Sim","Não") })
	TRCell():New(oSecCar,"Z11_MOTORI"	,cQry, "Motorista",, 60)
	TRCell():New(oSecCar,"A4_NOME"		,cQry, "Transportadora",, 60)
	TRCell():New(oSecCar,"TIPO_V"		,cQry, "Tp. Veiculo",, 40)
	TRCell():New(oSecCar,"QTD"			, cQry, "Quant. M2", "", 30)

	/*For nI:=1 to Len(cListaG)
		cDesc := cListaG[nI]
		TRCell():New(oSecCar, "GALPAO_"+cvaltochar(nI), cQry, cDesc,, 20)
Next nI
	*/

aListaG := ListGalpao()
For nI:=1 to Len(aListaG)

	cDesc := NormaGalpao(aListaG[nI])
	TRCell():New(oSecCar, "GALPAO_"+cvaltochar(nI), cQry, cDesc,, 20)
Next nI

TRFunction():New(oSecCar:Cell("QTD"), NIL,"SUM",,NIL,NIL,NIL,.T.,.F.)

For nI:=1 to Len(aListaG)
	TRFunction():New(oSecCar:Cell("GALPAO_"+cvaltochar(nI)), NIL,"SUM",,NIL,NIL,NIL,.T.,.F.)
Next nI


oSecCar:SetTotalText("TOTAIS")

oSecCar:SetTotalInLine(.F.)


oSecTotal := TRSection():New(oReport, "Totais", "TEMP")
TRCell():New( oSecTotal, "DESCRICAO"	,,"Forno"		,"@"					,40,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecTotal, "QUANT1"		,,"Quant. M2"	,"@"					,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecTotal, "QUANT2"		,,"Caixas"		,"@"					,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecTotal, "QUANT3"		,,"PESO BR (Kg)","@"					,20,/*lPixel*/,/*{|| code-block de impressao }*/)
oSecTotal:SetHeaderSection(.F.)

Return(oReport)


//---------------------------------------------------------------------------
Static Function PrintReport(oReport, cQry)
	Local oSecCar 		:= oReport:Section(1)
	Local aListaG		:= ListGalpao()
	Local nI			:= 0
	Local cDesc			:= ""
	Local nPos 			:= 0
	Local aListQuant	:= {}


	Local nJ		:= 0
	Local aListEmp	:= {cEmpAnt} //{'01', '05'}
	Local cEmp		:= ""


	Private cNomeTab	:= ""


	For nJ=1 To Len (aListEmp)
		cEmp := aListEmp[nJ]

		cNomeTab	:= "##BIA230"+cEmp+__cUserID+strzero(seconds()*3500,10)
		//cQry 		:= GetNextAlias()

		cSQL := GetSQL(1, cEmp)

		TcQuery cSQL New Alias (cQry)

		If (MV_PAR13 == 1)
			oSecCar:Print()
		Else

			oSecCar:Init()

			While ((cQry)->(!Eof()))

				_cPlaca 	:= IIF(!Empty((cQry)->Z11_PCAVAL), (cQry)->Z11_PCAVAL, (cQry)->ZZV_PLACA)
				_cNomeMot	:= IIF(!Empty((cQry)->Z11_MOTORI), (cQry)->Z11_MOTORI, (cQry)->ZZV_MOTOR)
				_cNomeTrans	:= (cQry)->A4_NOME
				_cTipoVei	:= (cQry)->Z58_DESC

				If (Empty((cQry)->A4_NOME))
					DbSelectArea('SA4')
					SA4->(DbSetOrder(1))
					If (SA4->(DbSeek(xFilial('SA4')+(cQry)->ZZV_TRANSP)))
						_cNomeTrans := SA4->A4_NOME
					EndIf
				EndIf

				oSecCar:Cell("EMP"		):SetValue((cQry)->EMP)

				oSecCar:Cell("ZZV_DATAAG"		):SetValue(stod(cvaltochar((cQry)->ZZV_DATAAG)))
				oSecCar:Cell("ZZV_HORAAG"		):SetValue((cQry)->ZZV_HORAAG)
				oSecCar:Cell("Z11_HORACH"		):SetValue((cQry)->Z11_HORACH)
				oSecCar:Cell("ZZV_CARGA"		):SetValue((cQry)->ZZV_CARGA)
				oSecCar:Cell("AMOSTRA"			):SetValue(If ((cQry)->AMOSTRA > 0,"x",""))
				oSecCar:Cell("Z11_PCAVAL"		):SetValue(_cPlaca)
				//oSecCar:Cell("PLACA_NOVA"		):SetValue("")
				oSecCar:Cell("Z11_MOTPAT"		):SetValue(If (AllTrim((cQry)->Z11_MOTPAT)=='S',"Sim","Não"))
				oSecCar:Cell("Z11_MOTORI"		):SetValue(_cNomeMot)
				oSecCar:Cell("A4_NOME"			):SetValue(_cNomeTrans)
				oSecCar:Cell("TIPO_V"			):SetValue(_cTipoVei)
				oSecCar:Cell("QTD"			):SetValue(cvaltochar(TRANSFORM((cQry)->QTD, "@E 99999999.99")))


				aListQuant := InfGalpao((cQry)->ZZV_CARGA, cEmp)
				For nI:=1 to Len(aListaG)


					cDesc := NormaGalpao(aListaG[nI])

					nPos := AScan( aListQuant, {|x| x[1] == cDesc})

					If(nPos > 0)
						oSecCar:Cell("GALPAO_"+cvaltochar(nI)):SetValue(aListQuant[nPos][2])
						//oSecCar:Cell("GALPAO_"+cvaltochar(nI)):SetAlign("CENTER")
					Else
						oSecCar:Cell("GALPAO_"+cvaltochar(nI)):SetValue(0)
						//oSecCar:Cell("GALPAO_"+cvaltochar(nI)):SetAlign("CENTER")
					EndIf

				Next nI

				oSecCar:PrintLine()

				(cQry)->(DbSkip())
			EndDo

			oSecCar:Finish()
		EndIf


		(cQry)->(DbCloseArea())

		TabTemp(cEmp)
		ImpTotal(oReport, cEmp)

	Next nJ

Return

Static Function NormaGalpao(cNome)

	Local cDesc := ""

	cDesc := STRTRAN(cNome, "Biancoges", "Bia.")
	cDesc := STRTRAN(cDesc, "Biancogres", "Bia.")
	cDesc := STRTRAN(cDesc, "Incesa", "Inc.")
	cDesc := STRTRAN(cDesc, "Industrial", "Ind.")

Return AllTrim(cDesc)


//---------------------------------------------------------------------------
Static Function GetSQL(cTpFiltro, cEmp)
	Local cSql 		:= ""
	Local Enter		:= CHR(13)+CHR(10)

	If (cTpFiltro == 1)
		cSql +=" SELECT EMP='"+cEmp+"',Z11_PESAGE, Z11_PCAVAL, Z11_MOTPAT, Z11_MOTORI, " +CRLF 
		cSql +="        Z11_HORACH,Z11_CODTRA,SA4.A4_NOME,Z11_CLVEIC, Z58.Z58_DESC, " +CRLF  
		cSql +="        ZZV.ZZV_CARGA, ZZV.ZZV_DATAAG, ZZV.ZZV_HORAAG, ZZV.ZZV_GALPAO, Z11_HORAIN, " +CRLF  
		cSql +="        Z11_HORASA, Z11_PESMAX, Z11_TARA,Z11_PESOIN, Z11_PESOSA, Z11_PESLIQ, " +CRLF 
		
		cSql +="        (SELECT SUM(ISNULL(C9_QTDLIB,0)) " +CRLF 
		cSql +="           FROM SC9"+cEmp+"0 SC9 WITH (NOLOCK) " +CRLF 
		cSql +="          WHERE C9_AGREG = ZZV.ZZV_CARGA " +CRLF 
		cSql +="            AND SC9.D_E_L_E_T_ = '') AS QTD, Z11.Z11_OBSER, " +CRLF 
		
		cSql +="        (SELECT COUNT(*)" +CRLF  
		cSql +="           FROM SC9"+cEmp+"0 SC9 WITH (NOLOCK) " +CRLF 
		cSql +="          WHERE C9_AGREG = ZZV.ZZV_CARGA " +CRLF 
		cSql +="            AND SC9.D_E_L_E_T_ = '' " +CRLF 
		cSql +="            AND C9_LOTECTL IN ('AMT', '')) AS AMOSTRA, " +CRLF 
		
		cSql +="        ZZV_PLACA, ZZV_MOTOR, ZZV_TRANSP"  +CRLF
	Else
		cSql +=" SELECT ZZV.ZZV_CARGA " +CRLF
	EndIf

	If (MV_PAR13 == 1)

		cSql +=" FROM Z11"+cEmp+"0 Z11 WITH (NOLOCK)" +CRLF
		cSql +=" LEFT JOIN "+RetSqlName('Z58')+" Z58 WITH (NOLOCK) ON Z11_CLVEIC = Z58_CODIGO " +CRLF
		cSql +=" LEFT JOIN "+RetSqlName('SA4')+" SA4 WITH (NOLOCK) ON SA4.A4_COD = Z11.Z11_CODTRA " +CRLF
		cSql +=" LEFT JOIN ZZV"+cEmp+"0 ZZV WITH (NOLOCK) ON Z11.Z11_PESAGE = ZZV.ZZV_TICKET " +CRLF
		cSql +=" WHERE Z11_MOTORI BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +CRLF
		cSql +=" AND Z11_PCAVAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'	" +CRLF
		cSql +=" AND Z11_CODTRA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'	" +CRLF
		cSql +=" AND Z11_MERCAD = 2 " +CRLF

	Else //layout agendamento

		cSql +=" FROM ZZV"+cEmp+"0 ZZV WITH (NOLOCK) "  +CRLF
		cSql +=" LEFT JOIN Z11"+cEmp+"0 Z11 WITH (NOLOCK) ON Z11.Z11_PESAGE = ZZV.ZZV_TICKET AND Z11.D_E_L_E_T_ = ''	" +CRLF

		If (cTpFiltro == 1)
			cSql +=" LEFT JOIN "+RetSqlName('Z58')+" Z58 WITH (NOLOCK) ON Z11_CLVEIC = Z58_CODIGO 		AND Z58.D_E_L_E_T_ = ''	" +CRLF
			cSql +=" LEFT JOIN "+RetSqlName('SA4')+" SA4 WITH (NOLOCK) ON SA4.A4_COD = Z11.Z11_CODTRA 	AND SA4.D_E_L_E_T_ = ''	" +CRLF
		EndIf


		cSql +=" WHERE ISNULL(Z11_MOTORI, '') 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' 						" +CRLF
		cSql +=" AND ISNULL(Z11_PCAVAL,'') 		BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'						" +CRLF
		cSql +=" AND ISNULL(Z11_CODTRA,'') 		BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'						" +CRLF
		//cSql +=" AND ISNULL(Z11_MERCAD,2) 		= 2 															"

	EndIf



		/*If (MV_PAR13 == 1)
			cSql +=" AND Z11_DATAIN BETWEEN '"+dtos(MV_PAR07)+"' AND '"+dtos(MV_PAR08)+"' "
Else
			cSql +=" AND ZZV.ZZV_DATAAG BETWEEN '"+dtos(MV_PAR07)+"' AND '"+dtos(MV_PAR08)+"' "
EndIf
		*/

cSql +=" AND ZZV.ZZV_DATAAG BETWEEN '"+dtos(MV_PAR07)+"' AND '"+dtos(MV_PAR08)+"' " +CRLF


If MV_PAR14 == 2
	cSql +=" AND ZZV.ZZV_TPAGEN = 'A' " +CRLF
ElseIf MV_PAR14 == 3
	cSql +=" AND ZZV.ZZV_TPAGEN = 'E' " +CRLF
ElseIf MV_PAR14 == 4
	cSql +=" AND ZZV.ZZV_TPAGEN = 'R' " +CRLF
EndIf

		/*If MV_PAR9 == 2
			cSql +=" AND Z11_PESOIN = 0 AND Z11_PESOSA = 0 "
ElseIf MV_PAR09 == 3
			cSql +=" Z11_PESOIN = 0.01 AND Z11_PESOSA = 0 "
ElseIf MV_PAR09 == 4
			cSql +=" AND Z11_PESOIN > 0.01	AND Z11_PESOSA = 0 "
ElseIf MV_PAR09 == 5
			cSql +=" AND Z11_PESOIN <> 0 AND Z11_PESOSA <> 0 "		
EndIf
		*/

If MV_PAR10 == 2
	cSql +=" AND Z11_SITUAC <> 'C' " +CRLF
ElseIf MV_PAR10 == 3
	cSql +=" AND ISNULL(Z11_SITUAC, 'C') = 'C' " +CRLF
EndIf

If MV_PAR11 == 2
	cSql +=" AND ISNULL(Z11_MOTPAT, 'S') = 'S' " +CRLF
ElseIf MV_PAR11 == 3
	cSql +=" AND ISNULL(Z11_MOTPAT, 'N') = 'N' " +CRLF
EndIf

If MV_PAR12 == 2
	cSql +=" AND ISNULL((SELECT COUNT(*) FROM ZZW"+cEmp+"0 ZZW WITH (NOLOCK) WHERE ZZW_CARGA = ZZV_CARGA AND  ZZW_STATUS <> '1' AND ZZW.D_E_L_E_T_ = '' ), 0) > 0 " +CRLF
ElseIf MV_PAR12 == 3
	cSql +=" AND ISNULL((SELECT COUNT(*) FROM ZZW"+cEmp+"0 ZZW ZZW WITH (NOLOCK) WHERE ZZW_CARGA = ZZV_CARGA AND  ZZW_STATUS = '1' AND ZZW.D_E_L_E_T_ = '' ), 0) > 0 " +CRLF
EndIf

If (MV_PAR13 == 1)

	cSql +=" AND Z11.D_E_L_E_T_ = '' " +CRLF
	cSql +=" AND Z58.D_E_L_E_T_ = '' " +CRLF
	cSql +=" AND SA4.D_E_L_E_T_ = '' " +CRLF

EndIf

cSql +=" AND ZZV.D_E_L_E_T_ = '' " +CRLF


If (cTpFiltro == 1)
	If (MV_PAR13 == 1)
		cSql +=" ORDER BY Z11_DATAIN, Z11_HORAIN, Z11_DATASA, Z11_HORASA " +CRLF
	Else
		cSql +=" ORDER BY ZZV.ZZV_DATAAG, ZZV.ZZV_HORAAG " +CRLF
	EndIf
EndIf

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
	aAdd(aRegs,{cPerg,"01","Do  Motorista  		?","","","mv_ch1","C",30,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Motorista   	?","","","mv_ch2","C",30,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da  Placa   		?","","","mv_ch3","C",07,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Ate Placa     		?","","","mv_ch4","C",07,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Da  Transportadora  ?","","","mv_ch5","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA4"})
	aAdd(aRegs,{cPerg,"06","Ate Transportadora  ?","","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA4"})
	aAdd(aRegs,{cPerg,"07","Da  Data   			?","","","mv_ch7","D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Ate Data   			?","","","mv_ch8","D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})
//aAdd(aRegs,{cPerg,"09","Status Pesagem  ","","","mv_ch9","N",01,0,0,"C","","mv_par09","Todas","","","","","Agendada","","","","","Liberada","","","","","Sem Saida Veiculo","","","","","Concluída","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Carga Associada ?","","","mv_ch10","N",1,0,0,"C","","mv_par10","Todas","","","","","Sim","","","","","Não","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Motorista no Patio ?","","","mv_ch11","N",1,0,0,"C","","mv_par11","Todas","","","","","Sim","","","","","Não","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Integrado ao ECOSIS ?","","","mv_ch12","N",1,0,0,"C","","mv_par12","Todas","","","","","Sim","","","","","Não","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","Layout  ?","","","mv_ch13","N",1,0,0,"C","","mv_par13","Padrão","","","","","Agendamento","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Tipo Agendamento ?","","","mv_ch14","N",1,0,0,"C","","mv_par14","Agendado & Encaixe","","","","","Agendado","","","","","Encaixe","","","","","Refaturamento","","","","","","","","",""})



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

Return()


Static Function InfGalpao(cCarga, cEmp)

	Local cAliasTrab := GetNextAlias()
	Local cQuery	 := ""
	Local cBanco	 := ""
	Local aListaG	 := {}
	Local Enter		 := CHR(13)+CHR(10)

	If(AllTrim(cEmp) == '01')
		cBanco		:= "DADOSEOS"
	ElseIf(AllTrim(cEmp) == '05')
		cBanco		:= "DADOS_05_EOS"
	ElseIf(AllTrim(cEmp) == '13')
		cBanco		:= "DADOS_13_EOS"
	ElseIf(AllTrim(cEmp) == '14')
		cBanco		:= "DADOS_14_EOS"			
	EndIf


	cQuery := "SELECT DESCRICAO=T5.dsc_local, PALETE = SUM(T3.fie_qtdade_pallet) FROM 				  	" +CRLF
	cQuery +=	" ["+cBanco+"].[dbo].[fat_ordem_faturamento]				T1 (nolock)  				" +CRLF
	cQuery +=	" INNER JOIN ["+cBanco+"].[dbo].[fat_itens_ordem]			T2 (nolock)  ON T1.ford_numero	= T2.ford_numero		" +CRLF
	cQuery +=	" INNER JOIN ["+cBanco+"].[dbo].[fat_itens_etiquetas]		T3 (nolock)  ON T1.ford_numero	= T3.ford_numero AND  T2.id_itens = T3.id_itens " +CRLF
	cQuery +=	" INNER JOIN ["+cBanco+"].[dbo].[cep_etiqueta_endereco]		T4 (nolock)  ON T3.cod_endereco	= T4.cod_endereco	" +CRLF
	cQuery +=	" INNER JOIN ["+cBanco+"].[dbo].[cep_cad_local]				T5 (nolock)  ON T4.end_local	= T5.end_local AND T4.cod_deposito	= T5.cod_deposito			" +CRLF
	cQuery +=	" WHERE ford_num_carga = '"+AllTrim(cCarga)+"'							" +CRLF
	cQuery +=	" GROUP BY T5.dsc_local													" +CRLF


	TCQUERY cQuery NEW ALIAS cAliasTrab

	While !(cAliasTrab->(Eof()))

		cDesc := NormaGalpao(cAliasTrab->DESCRICAO)
		Aadd(aListaG, {AllTrim(cDesc), cAliasTrab->PALETE})

		cAliasTrab->(DbSkip())

	EndDo

	cAliasTrab->(DbCloseArea())

Return aListaG


Static Function ListGalpao()

	Local cAliasTrab 	:= GetNextAlias()
	Local cQuery		:= ""
	Local cBanco		:= ""
	Local aListaG		:= {}

	If(AllTrim(cEmpAnt) == '01')
		cBanco		:= "DADOSEOS"
	ElseIf(AllTrim(cEmpAnt) == '05')
		cBanco		:= "DADOS_05_EOS"
	ElseIf(AllTrim(cEmpAnt) == '13')
		cBanco		:= "DADOS_13_EOS"
	ElseIf(AllTrim(cEmpAnt) == '14')
		cBanco		:= "DADOS_14_EOS"		
	EndIf

	cQuery := "SELECT DISTINCT DESCRICAO=dsc_local FROM ["+cBanco+"].[dbo].[cep_cad_local] (nolock)  ORDER BY 1"

	TCQUERY cQuery NEW ALIAS cAliasTrab

	While !(cAliasTrab->(Eof()))

		Aadd(aListaG, AllTrim(cAliasTrab->DESCRICAO))
		cAliasTrab->(DbSkip())

	EndDo

	cAliasTrab->(DbCloseArea())

Return aListaG



Static function ImpTotal(oReport, cEmp)

	Local cAliasTrab	:= Nil
	Local cAliasInt		:= Nil
	Local cMQuery		:= ""
	Local nI			:= 0
	Local aEmpresa		:= {"Baincogres", "Incesa"}
	Local aListaFor		:= {"F01/F02/F03", "F04/F05"}
	Local nSoma1		:= 0
	Local nSoma2		:= 0
	Local nSoma3		:= 0
	Local nSomaTot1		:= 0
	Local nSomaTot2		:= 0
	Local nSomaTot3		:= 0
	Local oSecTotal 	:= oReport:Section(2)

	oSecTotal:Init()

	oSecTotal:Cell("DESCRICAO"	):SetValue("Forno")
	oSecTotal:Cell("QUANT1"		):SetValue("Quant. M2")
	oSecTotal:Cell("QUANT2"		):SetValue("Caixas")
	oSecTotal:Cell("QUANT3"		):SetValue("PESO BR (Kg)")
	oSecTotal:PrintLine()

	oReport:ThinLine()


	For nI:=1 To Len (aListaFor)

		cMQuery		:= MontaQuery(aListaFor[nI], 1, cEmp)
		cAliasTrab 	:= GetNextAlias()


		TCQUERY cMQuery NEW ALIAS cAliasTrab

		oSecTotal:Cell("DESCRICAO"	):SetAlign(1)
		oSecTotal:Cell("QUANT1"		):SetAlign(1)
		oSecTotal:Cell("QUANT2"		):SetAlign(1)
		oSecTotal:Cell("QUANT2"		):SetAlign(1)

		If (!(cAliasTrab->(Eof())))

			oSecTotal:Cell("DESCRICAO"	):SetValue(aEmpresa[nI])
			oSecTotal:Cell("QUANT1"		):SetValue("")
			oSecTotal:Cell("QUANT2"		):SetValue("")
			oSecTotal:Cell("QUANT3"		):SetValue("")
			oSecTotal:PrintLine()

			nSoma1 := 0
			nSoma2 := 0
			nSoma3 := 0
			While !(cAliasTrab->(Eof()))

				oSecTotal:Cell("DESCRICAO"	):SetValue(cvaltochar(cAliasTrab->DESCRICAO))
				oSecTotal:Cell("QUANT1"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT1,"@E 999,999,999.99")))
				oSecTotal:Cell("QUANT2"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT2,"@E 999,999,999.99")))
				oSecTotal:Cell("QUANT3"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT3,"@E 999,999,999.99")))
				oSecTotal:PrintLine()

				nSoma1 += cAliasTrab->QUANT1
				nSoma2 += cAliasTrab->QUANT2
				nSoma3 += cAliasTrab->QUANT3
				cAliasTrab->(DbSkip())
			EndDo

			nSomaTot1 += nSoma1
			nSomaTot2 += nSoma2
			nSomaTot3 += nSoma3

			If (nSoma1 > 0 .Or. nSoma2 > 0 .Or. nSoma3 > 0)
				oReport:SkipLine()
				oSecTotal:Cell("DESCRICAO"		):SetAlign(3)
				oSecTotal:Cell("DESCRICAO"		):SetValue("Total:")
				oSecTotal:Cell("QUANT1"		):SetAlign(1)
				oSecTotal:Cell("QUANT1"		):SetValue(cvaltochar(TRANSFORM(nSoma1,"@E 999,999,999.99")))
				oSecTotal:Cell("QUANT2"		):SetAlign(1)
				oSecTotal:Cell("QUANT2"		):SetValue(cvaltochar(TRANSFORM(nSoma2,"@E 999,999,999.99")))
				oSecTotal:Cell("QUANT3"		):SetAlign(1)
				oSecTotal:Cell("QUANT3"		):SetValue(cvaltochar(TRANSFORM(nSoma3,"@E 999,999,999.99")))

				oSecTotal:PrintLine()
				oReport:SkipLine()
			EndIf

			oReport:SkipLine()

		EndIf

		cAliasTrab->(DbCloseArea())
	Next nI


	//Total por Categoria
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()


	cMQuery		:= MontaQuery("", 2, cEmp)
	cAliasTrab 	:= GetNextAlias()

	TCQUERY cMQuery NEW ALIAS cAliasTrab

	While !(cAliasTrab->(Eof()))

		oSecTotal:Cell("DESCRICAO"		):SetAlign(1)
		oSecTotal:Cell("DESCRICAO"	):SetValue(cvaltochar(cAliasTrab->DESCRICAO))
		oSecTotal:Cell("QUANT1"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT1,"@E 999,999,999.99")))
		oSecTotal:Cell("QUANT2"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT2,"@E 999,999,999.99")))
		oSecTotal:Cell("QUANT3"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT3,"@E 999,999,999.99")))
		oSecTotal:PrintLine()

		cAliasTrab->(DbSkip())

	EndDo
	cAliasTrab->(DbCloseArea())
	//Fim total Categoria


	//Total por Vendedor
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()


	cMQuery		:= MontaQuery("", 3, cEmp)
	cAliasTrab 	:= GetNextAlias()

	TCQUERY cMQuery NEW ALIAS cAliasTrab

	oSecTotal:Cell("DESCRICAO"	):SetAlign(1)
	oSecTotal:Cell("DESCRICAO"	):SetValue("Vendedores")
	oSecTotal:Cell("QUANT1"		):SetValue('Cliente')
	oSecTotal:Cell("QUANT2"		):SetValue('')
	oSecTotal:Cell("QUANT3"		):SetValue('Quant. M2')

	oSecTotal:PrintLine()


	While !(cAliasTrab->(Eof()))


		oSecTotal:Cell("DESCRICAO"		):SetAlign(1)
		oSecTotal:Cell("DESCRICAO"	):SetValue(cvaltochar(cAliasTrab->DESCRICAO))
		oSecTotal:Cell("QUANT1"		):SetValue('')
		oSecTotal:Cell("QUANT2"		):SetValue('')
		oSecTotal:Cell("QUANT3"		):SetValue(cvaltochar(TRANSFORM(cAliasTrab->QUANT1,"@E 999,999,999.99")))
		oSecTotal:PrintLine()

		oReport:SkipLine()
		oReport:SkipLine()

		If (!Empty(cAliasTrab->COD))


			cAliasInt 	:= GetNextAlias()
			cMQuery		:=  MontaQuery(cAliasTrab->COD, 4, cEmp)
			TCQUERY cMQuery NEW ALIAS cAliasInt

			While !(cAliasInt->(Eof()))

				oSecTotal:Cell("DESCRICAO"	):SetAlign(1)
				oSecTotal:Cell("DESCRICAO"	):SetValue('')
				oSecTotal:Cell("QUANT1"		):SetValue(cvaltochar(cAliasInt->DESCRICAO))
				oSecTotal:Cell("QUANT2"		):SetValue('')
				oSecTotal:Cell("QUANT3"		):SetValue(cvaltochar(TRANSFORM(cAliasInt->QUANT1,"@E 999,999,999.99")))
				oSecTotal:PrintLine()

				cAliasInt->(DbSkip())

			EndDo
			cAliasInt->(DbCloseArea())

		EndIf

		oReport:SkipLine()

		cAliasTrab->(DbSkip())

	EndDo
	cAliasTrab->(DbCloseArea())
	//Fim total Vendedor



	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()
	oSecTotal:Cell("DESCRICAO"		):SetAlign(3)
	oSecTotal:Cell("DESCRICAO"		):SetValue("Total:")
	oSecTotal:Cell("QUANT1"		):SetAlign(1)
	oSecTotal:Cell("QUANT1"		):SetValue(cvaltochar(TRANSFORM(nSomaTot1,"@E 999,999,999.99")))
	oSecTotal:Cell("QUANT2"		):SetAlign(1)
	oSecTotal:Cell("QUANT2"		):SetValue(cvaltochar(TRANSFORM(nSomaTot2,"@E 999,999,999.99")))
	oSecTotal:Cell("QUANT3"		):SetAlign(1)
	oSecTotal:Cell("QUANT3"		):SetValue(cvaltochar(TRANSFORM(nSomaTot3,"@E 999,999,999.99")))
	oSecTotal:PrintLine()



	oSecTotal:Finish()

Return

Static Function TabTemp(cEmp)

	Local cQuery 		:= ""

	cQuery += " SELECT * INTO "+cNomeTab             		                                                +CRLF
	cQuery += " FROM ( SELECT                       		                                               "+CRLF
	cQuery += "               FORNO	=ZZ6_FORNOP,			                                               "+CRLF
	cQuery += "               CATEGORIA	=RTRIM(Z41.Z41_DESCR), 			                                   "+CRLF
	cQuery += "               VENDEDOR	=SA3.A3_COD,					                                   "+CRLF
	cQuery += "               CLIENTE		=A1_COD,		 		                                       "+CRLF
	cQuery += "               QUANT1=ISNULL(C9_QTDLIB , 0),		                                           "+CRLF
	cQuery += "               QUANT2=ISNULL(C9_QTDLIB2 , 0), 		                                       "+CRLF
	cQuery += "               QUANT3=CASE WHEN B1_TIPCONV = 'M' THEN                                       "+CRLF 
	cQuery += "                             (C9_QTDLIB * ZZ9_PESO) + ((C9_QTDLIB * B1_CONV) * ZZ9_PESEMB)  "+CRLF					
    cQuery += "			                  ELSE                                                             "+CRLF  
    cQuery += "                             (C9_QTDLIB * ZZ9_PESO ) + ((C9_QTDLIB / B1_CONV) * ZZ9_PESEMB) "+CRLF
    cQuery += "		                 END                                                                   "+CRLF	
	/*
	cQuery += " QUANT3=CASE WHEN B1_TIPCONV = 'M' 	"+CRLF
	cQuery += " THEN (Z9_QTDLIB  * 					"+CRLF
	cQuery += " ISNULL((SELECT ZZ9_PESO "+CRLF
	cQuery += "           FROM "+RetSQLName("ZZ9")+" ZZ9 (nolock)"+CRLF 
	cQuery += "          WHERE ZZ9_PRODUT = C9_PRODUTO "+CRLF
	cQuery += "            AND ZZ9_LOTE = C9_LOTECTL "+CRLF
	cQuery += "            AND ZZ9.D_E_L_E_T_<>'*'),B1_PESO))"+CRLF
	cQuery += " + ((Z9_QTDLIB * B1_CONV) *  " +CRLF
	cQuery += " ISNULL((SELECT ZZ9_PESEMB "+CRLF
	cQuery += "           FROM "+RetSQLName("ZZ9")+" ZZ9 (nolock) "+CRLF
	cQuery += "          WHERE ZZ9_PRODUT = C9_PRODUTO "+CRLF
	cQuery += "            AND ZZ9_LOTE = C9_LOTECTL "+CRLF
	cQuery += "            AND ZZ9.D_E_L_E_T_<>'*'),B1_YPESEMB))	"+CRLF
	cQuery += " ELSE (Z9_QTDLIB  * ISNULL((SELECT ZZ9_PESO "+CRLF
	cQuery += "                              FROM "+RetSQLName("ZZ9")+" ZZ9 (nolock)"+CRLF 
	cQuery += "                             WHERE ZZ9_PRODUT = C9_PRODUTO "+CRLF
	cQuery += "                               AND ZZ9_LOTE = C9_LOTECTL"+CRLF 
	cQuery += "                               AND ZZ9.D_E_L_E_T_<>'*'),B1_PESO))				"+CRLF
	cQuery += " + ((Z9_QTDLIB / B1_CONV) * ISNULL((SELECT ZZ9_PESEMB "+CRLF
	cQuery += "                                      FROM "+RetSQLName("ZZ9")+" ZZ9 (nolock)"+CRLF 
	cQuery += "                                     WHERE ZZ9_PRODUT = C9_PRODUTO "+CRLF
	cQuery += "                                       AND ZZ9_LOTE = C9_LOTECTL "+CRLF
	cQuery += "                                       AND ZZ9.D_E_L_E_T_<>'*'),B1_YPESEMB)) 	"+CRLF
	cQuery += " END  "+CRLF
*/
	cQuery += " FROM ZZV"+cEmp+"0 ZZV (nolock)                               		                 "+CRLF
	cQuery += " JOIN ZZW"+cEmp+"0 ZZW (nolock)                                                       "+CRLF
	cQuery += "   ON ZZV_FILIAL = ZZW_FILIAL	                                                     "+CRLF
	cQuery += "  AND ZZV_CARGA = ZZW_CARGA	                                                         "+CRLF
	//cQuery += "  AND ZZW.D_E_L_E_T_ <> '*'                                               "+CRLF
	cQuery += "  AND ZZW.D_E_L_E_T_ = ''                                                             "+CRLF
	
	cQuery += " JOIN SC9"+cEmp+"0 SC9 (nolock)                              		                 "+CRLF
	cQuery += "   ON C9_FILIAL = ZZW_FILIAL	                                                         "+CRLF
	cQuery += "  AND C9_PEDIDO = ZZW_PEDIDO                                                          "+CRLF
	cQuery += "  AND C9_ITEM = ZZW_ITEM		                                                         "+CRLF
	cQuery += "  AND C9_SEQUEN = ZZW_SEQUEN	                                                         "+CRLF
	//cQuery += " 	 SC9.D_E_L_E_T_ <> '*'                                          "+CRLF
	cQuery += "  AND SC9.D_E_L_E_T_ = ''                                                             "+CRLF

	cQuery += " JOIN SC5"+cEmp+"0 SC5 (nolock)                              		                 "+CRLF
	cQuery += "   ON C9_FILIAL = C5_FILIAL	                                                         "+CRLF
	cQuery += "  AND C9_PEDIDO = C5_NUM		                                                         "+CRLF
	//cQuery += " 	SC5.D_E_L_E_T_ <> '*'                                           "+CRLF
	cQuery += "  AND SC5.D_E_L_E_T_ = ''                                                             "+CRLF

	/*cQuery += " JOIN SZ9"+cEmp+"0  SZ9 (nolock) ON                             			"+CRLF
	cQuery += " 	C9_PEDIDO = Z9_PEDIDO	AND                                         "+CRLF
	cQuery += " 	C9_PRODUTO = Z9_PRODUTO	AND                                         "+CRLF
	cQuery += " 	C9_ITEM	 = Z9_ITEM		AND                                         "+CRLF
	cQuery += " 	C9_SEQUEN = Z9_SEQUEN	AND                                         "+CRLF
	cQuery += " 	SZ9.D_E_L_E_T_ <> '*'                                               "+CRLF*/
	
	cQuery += " JOIN "+RetSQLName("SB1")+" SB1 (nolock)                              	                "+CRLF
	cQuery += "   ON B1_FILIAL		= '  '			                                                    "+CRLF
	//cQuery += "  AND B1_COD			= Z9_PRODUTO	                                                    "+CRLF
	cQuery += "  AND B1_COD			= C9_PRODUTO	                                                    "+CRLF
	//cQuery += " 	SB1.D_E_L_E_T_ <> '*'                                               "+CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ''                                                                "+CRLF
	
	cQuery += " JOIN "+RetSQLName("ZZ6")+" ZZ6 (nolock)                              	                "+CRLF
	cQuery += "   ON ZZ6_FILIAL = '  '		                                                            "+CRLF
	cQuery += "  AND ZZ6_COD = B1_YFORMAT	                                                            "+CRLF
	//cQuery += " 	ZZ6.D_E_L_E_T_ <> '*'                                               "+CRLF
	cQuery += "  AND ZZ6.D_E_L_E_T_ = ''                                                                "+CRLF
	
	cQuery += " JOIN "+RetSQLName("ZZ9")+"  ZZ9 (nolock)                                                "+CRLF                          
 	cQuery += "   ON ZZ9_FILIAL = ''                                                                    "+CRLF
	cQuery += "  AND ZZ9_PRODUT = C9_PRODUTO                                                            "+CRLF
	cQuery += "  AND ZZ9_LOTE   = C9_LOTECTL                                                            "+CRLF                           
 	cQuery += "  AND ZZ9.D_E_L_E_T_ = ''                                                                "+CRLF 	
 	
    cQuery += " LEFT JOIN SC5070 SC5L WITH (NOLOCK)                                                     "+CRLF
	cQuery += "   ON SC5L.C5_FILIAL 	= '01'                                                          "+CRLF
	cQuery += "  AND SC5L.C5_FILIAL	 = SC5.C5_FILIAL                                                    "+CRLF
	cQuery += "  AND SC5L.C5_YPEDORI = SC5.C5_NUM	                                                    "+CRLF
	cQuery += "  AND SC5L.C5_CLIENTE = SC5.C5_YCLIORI                                                   "+CRLF
	cQuery += "  AND SC5L.C5_LOJACLI = SC5.C5_YLOJORI                                                   "+CRLF
	cQuery += "  AND SC5L.C5_YEMPPED = "+cEmp                                                            +CRLF
	cQuery += "  AND SC5L.D_E_L_E_T_ = ''                                                               "+CRLF

	/*ccQuery += " INNER JOIN SA1"+cEmp+"0 SA1  (nolock) ON A1_COD+A1_LOJA = 				"+CRLF
	Query += " ISNULL((select C5_YCLIORI+C5_YLOJORI 
	cQuery += "           from "+RetSQLName("SC5")+" SC5 (nolock) "+CRLF
	cQuery += "          WHERE C5_NUM = ZZW_PEDIDO 
	cQuery += "            AND SC5.C5_YCLIORI<>'' 
	cQuery += "            AND SC5.D_E_L_E_T_<>'*'),ZZW_CCLI+ZZW_LCLI) AND SA1.D_E_L_E_T_ = ''	"+CRLF*/
	
	cQuery += " INNER JOIN SA1"+cEmp+"0 SA1  (nolock)                                                   "+CRLF
	cQuery += "    ON A1_COD = ISNULL(SC5L.C5_CLIENTE,SC5.C5_CLIENTE)                                   "+CRLF
	cQuery += "   AND A1_LOJA = ISNULL(SC5L.C5_LOJACLI,SC5.C5_LOJACLI)                                  "+CRLF
	cQuery += "   AND SA1.D_E_L_E_T_ = ''                                                               "+CRLF

	/*cQuery += " LEFT JOIN SA3"+cEmp+"0 SA3  (nolock) ON A3_COD =			 											"+CRLF
	cQuery += " ISNULL((select SC5_07.C5_VEND1 from SC5070 SC5_07 (nolock) 												"+CRLF
	cQuery += " WHERE SC5_07.C5_YPEDORI = ZZW_PEDIDO AND SC5_07.D_E_L_E_T_ =''), SC5.C5_VEND1) AND SA3.D_E_L_E_T_ = ''	"+CRLF*/
	
	cQuery += " LEFT JOIN SA3"+cEmp+"0 SA3  (nolock)                                                    "+CRLF
	cQuery += "   ON A3_COD = ISNULL(SC5L.C5_VEND1,SC5.C5_VEND1)                                        "+CRLF
	cQuery += "  AND SA3.D_E_L_E_T_ = ''                                                                "+CRLF     	  

	cQuery += " LEFT JOIN "+RetSQLName("Z41")+" Z41  (nolock)                                           "+CRLF
	cQuery += "   ON Z41.Z41_TPSEG  = SA1.A1_YTPSEG                                                     "+CRLF
	cQuery += "  AND Z41.D_E_L_E_T_ = '' 	                                                            "+CRLF

	cQuery += " WHERE ZZV.D_E_L_E_T_ = ''                                                               "+CRLF
	cQuery += " AND ZZV.ZZV_FILIAL	 = '01'                                                             "+CRLF
	cQuery += " AND ZZV.ZZV_CARGA 	 IN ("+GetSQL(2, cEmp)+")						                    "+CRLF

	cQuery += ") TAB"	
	
	TCSqlExec(cQuery)

Return

Static Function MontaQuery(cFiltro, cTipo, cEmp)

	Local cQuery	:= ""

	//forno
	If (cTipo == 1)
		cQuery += " SELECT DESCRICAO=FORNO,               "+CRLF 
		cQuery += "        QUANT1=SUM(QUANT1),            "+CRLF 
		cQuery += "        QUANT2=SUM(QUANT2),            "+CRLF 
		cQuery += "        QUANT3=SUM(QUANT3)             "+CRLF  
		cQuery += "   FROM "+cNomeTab+"  WITH (NOLOCK)    "+CRLF
		cQuery += "  WHERE FORNO IN "+FormatIn(cFiltro,"/")+CRLF
		cQuery += "  GROUP BY FORNO                       "+CRLF
	EndIf

	//forno
	If (cTipo == 2)
		cQuery += " SELECT DESCRICAO=CATEGORIA,       "+CRLF
		cQuery += "        QUANT1=SUM(QUANT1),        "+CRLF
		cQuery += "        QUANT2=SUM(QUANT2),        "+CRLF
		cQuery += "        QUANT3=SUM(QUANT3)         "+CRLF  
		cQuery += "   FROM "+cNomeTab+"	WITH (NOLOCK) "+CRLF
		cQuery += "  GROUP BY CATEGORIA	              "+CRLF
	EndIf

	//vendedor
	If (cTipo == 3)
		cQuery += " SELECT COD=VENDEDOR, "+CRLF
		cQuery += "        DESCRICAO=VENDEDOR+' - '+(SELECT TOP 1 A3_NREDUZ                "+CRLF
		cQuery += "                                    FROM SA3"+cEmp+"0 SA3 WITH (NOLOCK) "+CRLF
		cQuery += "                                   WHERE SA3.A3_COD = VENDEDOR          "+CRLF
		cQuery += "                                     AND SA3.D_E_L_E_T_= ''),           "+CRLF
		cQuery += "        QUANT1=SUM(QUANT1), QUANT2=SUM(QUANT2), QUANT3=SUM(QUANT3)	   "+CRLF	
		cQuery += "   FROM "+cNomeTab+" WITH (NOLOCK)                                      "+CRLF
		cQuery += "  GROUP BY VENDEDOR  						                           "+CRLF
	EndIf

	//cliente
	If (cTipo == 4)
		cQuery += " SELECT DESCRICAO=(SELECT TOP 1 A1_NREDUZ                "+CRLF
		cQuery += "                     FROM SA1"+cEmp+"0 SA1 WITH (NOLOCK) "+CRLF
		cQuery += "                    WHERE SA1.A1_COD = CLIENTE           "+CRLF
		cQuery += "                      AND SA1.D_E_L_E_T_= ''),           "+CRLF
		cQuery += "        QUANT1=SUM(QUANT1),                              "+CRLF
		cQuery += "        QUANT2=SUM(QUANT2),                              "+CRLF 
		cQuery += "        QUANT3=SUM(QUANT3)	                            "+CRLF	
		cQuery += "   FROM "+cNomeTab+"   WITH (NOLOCK)                     "+CRLF
		cQuery += "  WHERE VENDEDOR IN "+FormatIn(cFiltro,"/")               +CRLF
		cQuery += "  GROUP BY CLIENTE                                       "+CRLF
	EndIf

Return cQuery
