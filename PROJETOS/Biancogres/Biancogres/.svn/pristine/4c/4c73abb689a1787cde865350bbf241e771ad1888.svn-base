#Include "TOTVS.CH"
#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA741
@author Marcos Alberto Soprani
@since 21/11/13
@version 1.0
@description Relatório de Custo Realizado
@type function
/*/

/*/{Protheus.doc} BIA741
@author Artur Antunes
@since 20/04/2017
@version 1.1
@description Inclusão de layout de produtos em linha e reformulação do layout antigo
@obs OS 0784-17
@type function
/*/

User Function BIA741()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	private aPergs := {}

	If !ValidPerg()
		Return
	EndIf

	if MV_PAR04 == 1
		fModLinha()
	else
		fModColuna()
	endif

return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fModColuna ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 03.05.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fModColuna()

	Local cM002     := GetNextAlias() 
	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM) 
	local cTitulo   := "Relatório de Custo Realizado"  
	local nRegAtu   := 0
	local nTotReg   := 0
	local cChave	:= ''
	local cArqXML   := "BIAF741_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	local cQuery	:= ''
	local nDecQtd	:= TamSX3("D3_QUANT")[2]
	local nDecCust	:= TamSX3("D3_CUSTO1")[2]
	local aColuna	:= {}
	local nx		:= 0
	local cAlinh	:= ''

	local cCab1Fon	:= 'Arial' 
	local nCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local ny

	ProcRegua(0)

	xrQtdP   := 0
	axVetPro := {}
	axVetCab := {}
	M0001 := " SELECT COUNT(*) CONTAD " + CRLF
	M0001 += "   FROM (SELECT D3_COD " + CRLF
	M0001 += "           FROM " + RetSqlName("SD3")+" SD3 WITH (NOLOCK) " + CRLF
	M0001 += "          WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
	M0001 += "            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + CRLF
	M0001 += "            AND D3_TM = '010' " + CRLF
	M0001 += "            AND D3_TIPO = '"+MV_PAR03+"' " + CRLF
	M0001 += "            AND D3_ESTORNO = ' ' " + CRLF
	M0001 += "            AND D_E_L_E_T_ = ' ' " + CRLF
	M0001 += "          GROUP BY D3_COD " + CRLF
	M0001 += "          UNION ALL " + CRLF
	M0001 += "         SELECT D3_COD " + CRLF
	M0001 += "           FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) " + CRLF
	M0001 += "          INNER JOIN "+RetSqlName("SF5")+" SF5 WITH (NOLOCK) ON F5_FILIAL = '"+xFilial("SF5")+"' " + CRLF
	M0001 += "                                             AND F5_CODIGO = D3_TM " + CRLF
	M0001 += "                                             AND F5_VAL = 'S' " + CRLF
	M0001 += "                                             AND F5_QTDZERO <> '2' " + CRLF
	M0001 += "                                             AND SF5.D_E_L_E_T_ = ' ' " + CRLF
	M0001 += "          WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
	M0001 += "            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + CRLF
	M0001 += "            AND D3_TIPO = '"+MV_PAR03+"' " + CRLF
	M0001 += "            AND D3_ESTORNO = ' ' " + CRLF
	M0001 += "            AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	M0001 += "          GROUP BY D3_COD) AS TAB " + CRLF
	TcQuery M0001 New Alias "M001"
	dbSelectArea("M001")
	dbGoTop()
	xrQtdP := M001->CONTAD + 1 + 1 + IIF(MV_PAR03 == "PI", 1, 1)   +  20
	xrQtdP += IIF(cEmpAnt == "14", 1, 0)
	M001->(dbCloseArea())

	M0002 := " SELECT REFERENCIA, " + CRLF
	M0002 += "        SUBSTRING(B1_DESC,1,50) PRODUTO, " + CRLF
	M0002 += "        D3_TM TM, " + CRLF
	M0002 += "        DESCR, " + CRLF
	M0002 += "        D3_CONTA, " + CRLF
	M0002 += "        SUM(D3_QUANT) QUANT, " + CRLF
	M0002 += "        SUM(D3_CUSTO1) CUSTO " + CRLF
	M0002 += "   FROM (SELECT SUBSTRING(D3_EMISSAO,1,6) PERIODO, " + CRLF
	M0002 += "                D3_NUMSEQ, " + CRLF
	M0002 += "                ISNULL(CT1_DESC01,'RATEIO '+SUBSTRING(D3_COD,4,12)) DESCR, " + CRLF
	M0002 += "                C2_PRODUTO REFERENCIA, " + CRLF
	M0002 += "                D3_COD, " + CRLF
	M0002 += "                D3_TM, " + CRLF
	M0002 += "                D3_CONTA, " + CRLF
	M0002 += "                D3_QUANT, " + CRLF
	M0002 += "                D3_CUSTO1 " + CRLF
	M0002 += "           FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) " + CRLF
	M0002 += "           LEFT JOIN "+RetSqlName("CT1")+" CT1 WITH (NOLOCK) ON CT1_FILIAL = '"+xFilial("CT1")+"' " + CRLF
	M0002 += "                               AND CT1_CONTA = D3_CONTA " + CRLF
	M0002 += "                               AND CT1.D_E_L_E_T_ = ' ' " + CRLF
	M0002 += "          INNER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
	M0002 += "                               AND C2_NUM = SUBSTRING(D3_OP,1,6) " + CRLF
	M0002 += "                               AND C2_ITEM = SUBSTRING(D3_OP,7,2) " + CRLF
	M0002 += "                               AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) " + CRLF
	M0002 += "                               AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	M0002 += "          INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
	M0002 += "                               AND B1_COD = C2_PRODUTO " + CRLF
	M0002 += "                               AND B1_TIPO = '"+MV_PAR03+"' " + CRLF
	M0002 += "                               AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	M0002 += "          WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
	M0002 += "            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + CRLF
	M0002 += "            AND D3_ESTORNO = ' ' " + CRLF
	M0002 += "            AND SD3.D_E_L_E_T_ = ' ' " + CRLF

	If MV_PAR03 $ "PA/PP"

		M0002 += "          UNION ALL " + CRLF
		M0002 += "         SELECT SUBSTRING(D3_EMISSAO,1,6) PERIODO, " + CRLF
		M0002 += "                D3_YRFCUST D3_NUMSEQ, " + CRLF
		M0002 += "                ISNULL(CT1_DESC01,'RATEIO '+SUBSTRING(D3_COD,4,12)) DESCR, " + CRLF
		M0002 += "                CASE " + CRLF
		M0002 += "                  WHEN B1_TIPO = 'PP' THEN SUBSTRING(Z18_COD,1,7) + '        ' " + CRLF
		M0002 += "                  ELSE Z18_COD " + CRLF
		M0002 += "                END REFERENCIA, " + CRLF
		M0002 += "                D3_COD, " + CRLF
		M0002 += "                CASE " + CRLF
		M0002 += "                  WHEN D3_TM = '711' THEN '010' " + CRLF
		M0002 += "                  WHEN D3_TM = '211' THEN '999' " + CRLF
		M0002 += "                END D3_TM, " + CRLF
		M0002 += "                D3_CONTA, " + CRLF
		M0002 += "                D3_QUANT * (-1) D3_QUANT, " + CRLF
		M0002 += "                D3_CUSTO1 * (-1) D3_CUSTO1 " + CRLF
		M0002 += "           FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) " + CRLF
		M0002 += "           LEFT JOIN "+RetSqlName("CT1")+" CT1 WITH (NOLOCK) ON CT1_FILIAL = '"+xFilial("CT1")+"' " + CRLF
		M0002 += "                                             AND CT1_CONTA = D3_CONTA " + CRLF
		M0002 += "                                             AND CT1.D_E_L_E_T_ = ' ' " + CRLF
		M0002 += "          INNER JOIN "+RetSqlName("Z18")+" Z18 WITH (NOLOCK) ON Z18_FILIAL = '"+xFilial("Z18")+"' " + CRLF
		M0002 += "                                             AND Z18_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + CRLF
		If MV_PAR03 == "PA"
			M0002 += "                                             AND Z18_NSQSD3 = D3_YRFCUST " + CRLF
			M0002 += "                                             AND Z18_NSQSD3 <> '         ' " + CRLF
		ElseIf MV_PAR03 == "PP"
			M0002 += "                                             AND Z18_SQD3PP = D3_YRFCUST " + CRLF
			M0002 += "                                             AND Z18_SQD3PP <> '         ' " + CRLF
		EndIf
		M0002 += "                                             AND Z18.Z18_DOCSD3 <> 'XDOCECANC' " + CRLF
		M0002 += "                                             AND Z18.D_E_L_E_T_ = ' ' " + CRLF
		M0002 += "          INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		If MV_PAR03 == "PA"
			M0002 += "                                             AND B1_COD = Z18_COD " + CRLF
			M0002 += "                                             AND B1_TIPO = 'PA' " + CRLF
		ElseIf MV_PAR03 == "PP"
			M0002 += "                                             AND SUBSTRING(B1_COD,1,7) = SUBSTRING(Z18_COD,1,7) " + CRLF
			M0002 += "                                             AND B1_TIPO = 'PP' " + CRLF
		EndIf
		M0002 += "                                             AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		M0002 += "          WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
		M0002 += "            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + CRLF
		M0002 += "            AND (D3_TM = '711' OR ( D3_TM = '211' AND D3_TIPO NOT IN('PA','PP') ) ) " + CRLF
		M0002 += "            AND D3_ESTORNO = ' ' " + CRLF
		M0002 += "            AND SD3.D_E_L_E_T_ = ' ' " + CRLF

	EndIf
	M0002 += "            ) AS TAB " + CRLF
	M0002 += "   LEFT JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
	M0002 += "                       AND B1_COD = REFERENCIA " + CRLF
	M0002 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	M0002 += "  GROUP BY REFERENCIA, " + CRLF
	M0002 += "           SUBSTRING(B1_DESC,1,50), " + CRLF
	M0002 += "           SUBSTRING(D3_CONTA,1,5), " + CRLF
	M0002 += "           D3_TM, " + CRLF
	M0002 += "           DESCR, " + CRLF
	M0002 += "           D3_CONTA " + CRLF
	M0002 += "  ORDER BY REFERENCIA, " + CRLF
	M0002 += "           D3_TM, " + CRLF
	M0002 += "           SUBSTRING(D3_CONTA,1,5), " + CRLF
	M0002 += "           DESCR " + CRLF
	TcQuery M0002 New Alias (cM002)
	(cM002)->(DbGoTop())
	Count To nTotReg 
	if nTotReg < 1
		MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
		return
	endif
	(cM002)->(dbGoTop())
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Carregando Dados - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	Aadd( axVetCab, {"Seq"   , "C", 03, 0} )
	Aadd( axVetCab, {"Código", "C", 20, 0} )
	Aadd( axVetCab, {"KEY",    "C", 20, 0} )

	Aadd( axVetPro, Array(xrQtdP) )
	axVetPro[len(axVetPro)][1] := "001"
	axVetPro[len(axVetPro)][2] := "Referência"
	axVetPro[len(axVetPro)][3] := ""
	Aadd( axVetPro, Array(xrQtdP) )
	axVetPro[len(axVetPro)][1] := "002"
	axVetPro[len(axVetPro)][2] := "Quantidade"
	axVetPro[len(axVetPro)][3] := ""
	xCtCol := 3
	xSeqIt := "003"

	While (cM002)->(!Eof())

		xCtCol ++
		ftCodPA := (cM002)->REFERENCIA

		Aadd( axVetCab, {Alltrim(ftCodPA), "C", 40, 0} )

		axVetPro[1][xCtCol] := Alltrim((cM002)->PRODUTO)
		axVetPro[2][xCtCol] := Transform((cM002)->QUANT, "@E 999999999999.99999")
		ftQtdPA := (cM002)->QUANT
		ftCstPA := 0

		While (cM002)->(!Eof()) .and. (cM002)->REFERENCIA == ftCodPA

			nRegAtu++
			IncProc("Carregando Dados - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

			xyQuadro := Alltrim((cM002)->DESCR)
			nPos := aScan(axVetPro,{|x| Alltrim(x[2]) == Alltrim(xyQuadro) })
			If nPos == 0
				xSeqIt := Soma1(xSeqIt)
				Aadd( axVetPro, Array(xrQtdP) )
				nPos := Len(axVetPro)
				axVetPro[nPos][1] := xSeqIt
				axVetPro[nPos][2] := xyQuadro
				axVetPro[nPos][3] := (cM002)->D3_CONTA
			EndIf
			If (cM002)->TM <> "010"
				axVetPro[nPos][xCtCol] := Transform((cM002)->CUSTO, "@E 999999999999.99999")
				ftCstPA += (cM002)->CUSTO
			EndIf

			(cM002)->(dbSkip())

		End

		// Valorização da Produção do período não apropriado pela rotina de OP
		TP005 := " SELECT D3_YRFCUST, D3_TM, F5_TEXTO, SUM(D3_CUSTO1) CUSTO
		TP005 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
		TP005 += "  INNER JOIN "+RetSqlName("SF5")+" SF5 WITH (NOLOCK) ON F5_FILIAL = '"+xFilial("SF5")+"'
		TP005 += "                       AND F5_CODIGO = D3_TM
		TP005 += "                       AND F5_VAL = 'S'
		TP005 += "                       AND F5_QTDZERO <> '2'
		TP005 += "                       AND SF5.D_E_L_E_T_ = ' '
		TP005 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		TP005 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		TP005 += "    AND D3_COD = '"+ftCodPA+"'

		// Tratamento provisório até que se defina devidamente os procedimentos para apropriação do custo de terceiros sem misturar com o de produção própria.
		// até que as baixas de PS durante o processo de retífica própría sejam feitas de forma automática.
		// Retirado ajuste manual (principalmente no que se refere ao mes 10/2013 porque foi necessário fazer uma movimentação para zerar um saldo não distribuido para PP/PS)
		TP005 += "    AND RTRIM(D3_YRFCUST) NOT IN('BIA705','MANUAL')

		TP005 += "    AND D3_ESTORNO = ' '
		TP005 += "    AND SD3.D_E_L_E_T_ = ' '
		TP005 += "  GROUP BY D3_YRFCUST, D3_TM, F5_TEXTO
		TPIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,TP005),'TP05',.T.,.T.)
		dbSelectArea("TP05")
		dbGoTop()
		While !Eof()

			If Alltrim(TP05->D3_YRFCUST) == "BIA704"
				xyQuadro := Alltrim("RAT. DIRETO NAO APROPRIADO")
			ElseIf Alltrim(TP05->D3_YRFCUST) == "BIA705"
				xyQuadro := Alltrim(TP05->F5_TEXTO)
			ElseIf Alltrim(TP05->D3_YRFCUST) == "BIA709"
				xyQuadro := Alltrim("RAT. FINAIS DAS SOBRAS DE CUSTO")
			ElseIf Alltrim(TP05->D3_YRFCUST) == "BIA710"
				xyQuadro := Alltrim("AJUSTES DE CENTAVOS P/ VIRADA")
			Else
				xyQuadro := Alltrim(TP05->F5_TEXTO)
			EndIf
			If TP05->D3_TM < "500"
				xyQuadro := "(Dev) " + Alltrim(xyQuadro)
			Else
				xyQuadro := "(Req) " + Alltrim(xyQuadro)
			EndIf

			nPos := aScan(axVetPro,{|x| Alltrim(x[2]) == Alltrim(xyQuadro) })
			If nPos == 0
				xSeqIt := Soma1(xSeqIt)
				Aadd( axVetPro, Array(xrQtdP) )
				nPos := Len(axVetPro)
				axVetPro[nPos][1] := xSeqIt
				axVetPro[nPos][2] := xyQuadro
				axVetPro[nPos][3] := "TM-" + TP05->D3_TM
			EndIf

			xCustoMov := TP05->CUSTO
			If TP05->D3_TM > "500"
				xCustoMov := TP05->CUSTO * (-1)
			EndIf
			axVetPro[nPos][xCtCol] := Transform(xCustoMov, "@E 999999999999.99999")

			ftCstPA += xCustoMov

			dbSelectArea("TP05")
			dbSkip()
		End

		TP05->(dbCloseArea())
		Ferase(TPIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(TPIndex+OrdBagExt())          //indice gerado

		// Totaliza o Médio dos movimentos
		xyQuadro := "MÉDIOS"
		nPos := aScan(axVetPro,{|x| Alltrim(x[2]) == Alltrim(xyQuadro) })
		If nPos == 0
			Aadd( axVetPro, Array(xrQtdP) )
			nPos := Len(axVetPro)
			axVetPro[nPos][1] := "999"
			axVetPro[nPos][2] := xyQuadro
			axVetPro[nPos][3] := "MÉDIOS"
		EndIf
		axVetPro[nPos][xCtCol] := Transform(ftCstPA/ftQtdPA, "@E 999999999999.99999")

	End

	(cM002)->(dbCloseArea())

	nRegAtu++
	IncProc("Carregando Dados - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")	

	//U_BIAxExcel(axVetPro, axVetCab, "BIA741"+strzero(seconds()%3500,5) )

	nRegAtu := 0
	nTotReg := len(axVetPro)
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	aSort(axVetPro,,,{ |x,y| x[1] < y[1] })    

	AADD(aColuna,20)
	for nx:= 1 to len(axVetCab)
		AADD(aColuna,90)
	next nx
	AADD(aColuna,20)

	oExcel := ARSexcel():New() 
	oExcel:AddPlanilha('Relatorio',aColuna)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,len(aColuna)-3) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,len(aColuna)-3) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,len(aColuna)-3)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(14) 
	oExcel:AddCelula()  
	for nx:= 1 to len(axVetCab)
		oExcel:AddCelula(axVetCab[nx,1]	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	next nx

	for nx:= 1 to len(axVetPro)

		if MOD(nx,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif	

		oExcel:AddLinha(14) 
		oExcel:AddCelula()   			

		for ny:= 1 to len(axVetCab)

			if ny > 3 .and. nx > 1
				cAlinh	:= "R"
			else
				cAlinh	:= "L"
			endif

			oExcel:AddCelula( axVetPro[nx,ny] ,0 ,cAlinh,cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		next ny
		oExcel:AddCelula()

		nRegAtu++
		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	
	next nx

	fGeraParametros()
	oExcel:SaveXml(Alltrim(MV_PAR05),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")	

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fModLinha  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 03.05.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fModLinha()

	Local cTab     	:= GetNextAlias() 
	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM) 
	local cTitulo   := "Relatório de Custo Realizado"  
	local nRegAtu   := 0
	local nTotReg   := 0
	local cChave	:= ''
	local cArqXML   := "BIAF741_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	local cQuery	:= ''
	local nDecQtd	:= TamSX3("D3_QUANT")[2]
	local nDecCust	:= TamSX3("D3_CUSTO1")[2]

	local cCab1Fon	:= 'Calibri' 
	local nCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'

	ProcRegua(0)

	M0002 := " SELECT " + CRLF 
	M0002 += " 		  PERIODO, " + CRLF
	M0002 += " 		  REFERENCIA, " + CRLF
	M0002 += "        SUBSTRING(B1_DESC,1,50) PRODUTO, " + CRLF
	M0002 += "        D3_TM TM, " + CRLF
	M0002 += "        DESCR, " + CRLF
	M0002 += "        D3_CONTA, " + CRLF
	M0002 += " 	      CT1_DESC01, " + CRLF
	M0002 += " 		  D3_YITCUS, " + CRLF
	M0002 += " 		  Z29_DESCR, " + CRLF
	M0002 += "        SUM(D3_QUANT) QUANT, " + CRLF
	M0002 += "        SUM(D3_CUSTO1) CUSTO " + CRLF
	M0002 += "   FROM (SELECT SUBSTRING(D3_EMISSAO,1,6) PERIODO, " + CRLF
	M0002 += "                D3_NUMSEQ, " + CRLF
	M0002 += "                ISNULL(CT1_DESC01,'RATEIO '+SUBSTRING(D3_COD,4,12)) DESCR, " + CRLF
	M0002 += "                C2_PRODUTO REFERENCIA, " + CRLF
	M0002 += "                D3_COD, " + CRLF
	M0002 += "                D3_TM, " + CRLF
	M0002 += "                D3_CONTA, " + CRLF
	M0002 += " 				  CT1_DESC01, " + CRLF
	M0002 += " 				  D3_YITCUS, " + CRLF
	M0002 += "                D3_QUANT, " + CRLF
	M0002 += "                D3_CUSTO1 " + CRLF
	M0002 += "           FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) " + CRLF
	M0002 += "           LEFT JOIN "+RetSqlName("CT1")+" CT1 WITH (NOLOCK) ON CT1_FILIAL = '"+xFilial("CT1")+"' " + CRLF
	M0002 += "                               AND CT1_CONTA = D3_CONTA " + CRLF
	M0002 += "                               AND CT1.D_E_L_E_T_ = ' ' " + CRLF
	M0002 += "          INNER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
	M0002 += "                               AND C2_NUM = SUBSTRING(D3_OP,1,6) " + CRLF
	M0002 += "                               AND C2_ITEM = SUBSTRING(D3_OP,7,2) " + CRLF
	M0002 += "                               AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) " + CRLF
	M0002 += "                               AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	M0002 += "          INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
	M0002 += "                               AND B1_COD = C2_PRODUTO " + CRLF
	M0002 += "                               AND B1_TIPO = '"+MV_PAR03+"' " + CRLF
	M0002 += "                               AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	M0002 += "          WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
	M0002 += "            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + CRLF
	M0002 += "            AND D3_ESTORNO = ' ' " + CRLF
	M0002 += "            AND SD3.D_E_L_E_T_ = ' ' " + CRLF

	If MV_PAR03 $ "PA/PP"
		M0002 += "          UNION ALL " + CRLF
		M0002 += "         SELECT SUBSTRING(D3_EMISSAO,1,6) PERIODO, " + CRLF
		M0002 += "                D3_YRFCUST D3_NUMSEQ, " + CRLF
		M0002 += "                ISNULL(CT1_DESC01,'RATEIO '+SUBSTRING(D3_COD,4,12)) DESCR, " + CRLF
		M0002 += "                CASE " + CRLF
		M0002 += "                  WHEN B1_TIPO = 'PP' THEN SUBSTRING(Z18_COD,1,7) + '        ' " + CRLF
		M0002 += "                  ELSE Z18_COD " + CRLF
		M0002 += "                END REFERENCIA, " + CRLF
		M0002 += "                D3_COD, " + CRLF
		M0002 += "                CASE " + CRLF
		M0002 += "                  WHEN D3_TM = '711' THEN '010' " + CRLF
		M0002 += "                  WHEN D3_TM = '211' THEN '999' " + CRLF
		M0002 += "                END D3_TM, " + CRLF
		M0002 += "                D3_CONTA, " + CRLF
		M0002 += " 				  CT1_DESC01, " + CRLF
		M0002 += " 				  D3_YITCUS, " + CRLF
		M0002 += "                D3_QUANT * (-1) D3_QUANT, " + CRLF
		M0002 += "                D3_CUSTO1 * (-1) D3_CUSTO1 " + CRLF
		M0002 += "           FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) " + CRLF
		M0002 += "           LEFT JOIN "+RetSqlName("CT1")+" CT1 WITH (NOLOCK) ON CT1_FILIAL = '"+xFilial("CT1")+"' " + CRLF
		M0002 += "                                             AND CT1_CONTA = D3_CONTA " + CRLF
		M0002 += "                                             AND CT1.D_E_L_E_T_ = ' ' " + CRLF
		M0002 += "          INNER JOIN "+RetSqlName("Z18")+" Z18 WITH (NOLOCK) ON Z18_FILIAL = '"+xFilial("Z18")+"' " + CRLF
		M0002 += "                                             AND Z18_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + CRLF
		If MV_PAR03 == "PA"
			M0002 += "                                             AND Z18_NSQSD3 = D3_YRFCUST " + CRLF
			M0002 += "                                             AND Z18_NSQSD3 <> '         ' " + CRLF
		ElseIf MV_PAR03 == "PP"
			M0002 += "                                             AND Z18_SQD3PP = D3_YRFCUST " + CRLF
			M0002 += "                                             AND Z18_SQD3PP <> '         ' " + CRLF
		EndIf
		M0002 += "                                             AND Z18.Z18_DOCSD3 <> 'XDOCECANC' " + CRLF
		M0002 += "                                             AND Z18.D_E_L_E_T_ = ' ' " + CRLF
		M0002 += "          INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		If MV_PAR03 == "PA"
			M0002 += "                                             AND B1_COD = Z18_COD " + CRLF
			M0002 += "                                             AND B1_TIPO = 'PA' " + CRLF
		ElseIf MV_PAR03 == "PP" 
			M0002 += "                                             AND SUBSTRING(B1_COD,1,7) = SUBSTRING(Z18_COD,1,7) " + CRLF
			M0002 += "                                             AND B1_TIPO = 'PP' " + CRLF
		EndIf
		M0002 += "                                             AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		M0002 += "          WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
		M0002 += "            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + CRLF
		M0002 += "            AND (D3_TM = '711' OR ( D3_TM = '211' AND D3_TIPO NOT IN('PA','PP') ) ) " + CRLF
		M0002 += "            AND D3_ESTORNO = ' ' " + CRLF
		M0002 += "            AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	EndIf

	M0002 += "            ) AS TAB " + CRLF
	M0002 += "   LEFT JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
	M0002 += "                       								AND B1_COD = REFERENCIA " + CRLF
	M0002 += "                       								AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	M0002 += " 	 LEFT JOIN "+RetSqlName("Z29")+" Z29 WITH ( NOLOCK ) ON Z29_FILIAL = '  ' " + CRLF
	M0002 += "                                        				 AND Z29_COD_IT = TAB.D3_YITCUS " + CRLF
	M0002 += "                                        				 AND Z29.D_E_L_E_T_ = ' ' " + CRLF
	M0002 += "  GROUP BY PERIODO, " + CRLF
	M0002 += "  		 REFERENCIA, " + CRLF
	M0002 += "           SUBSTRING(B1_DESC,1,50), " + CRLF
	M0002 += "           SUBSTRING(D3_CONTA,1,5), " + CRLF
	M0002 += "           D3_TM, " + CRLF
	M0002 += "           DESCR, " + CRLF
	M0002 += "           D3_CONTA, " + CRLF
	M0002 += "  		 CT1_DESC01, " + CRLF
	M0002 += "  		 D3_YITCUS, " + CRLF
	M0002 += "  		 Z29_DESCR " + CRLF
	M0002 += "  ORDER BY PERIODO, " + CRLF
	M0002 += "  		 REFERENCIA, " + CRLF
	M0002 += "           D3_TM, " + CRLF
	M0002 += "           SUBSTRING(D3_CONTA,1,5), " + CRLF
	M0002 += "           DESCR " + CRLF

	TcQuery M0002 Alias (cTab) New
	(cTab)->(DbGoTop())
	Count To nTotReg 
	if nTotReg < 1
		MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
		return
	endif
	(cTab)->(dbGoTop())
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New() 
	oExcel:AddPlanilha('Relatorio',{20,70,80,170,170,50,90,150,70,150,90,90,90,20},7)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,11) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,11) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,11)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()  
	oExcel:AddCelula("Periodo" 		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Referencia" 	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Produto"	  	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("TM"			,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Conta"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descr. Conta"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Item Custo"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descr. Item"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Qtdade Prod"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Quantidade"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	frQtdProd := (cTab)->QUANT
	While !(cTab)->(Eof())

		nRegAtu++
		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		// Em 03/05/17... por Marcos Alberto Soprani... 
		If (cTab)->TM == "010"
			frQtdProd :=  (cTab)->QUANT
		EndIf

		oExcel:AddLinha(14) 
		oExcel:AddCelula()   			

		oExcel:AddCelula( (cTab)->PERIODO	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->REFERENCIA,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->PRODUTO	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->DESCR	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->TM		,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->D3_CONTA	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->CT1_DESC01,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->D3_YITCUS	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->Z29_DESCR	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( frQtdProd     	,nDecQtd ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->QUANT	 	,nDecQtd ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->CUSTO		,nDecCust,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 

		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

		(cTab)->(DbSkip())                
	EndDo    

	fGeraParametros()
	oExcel:SaveXml(Alltrim(MV_PAR05),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")	
return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGeraParametros ¦ Autor ¦ Marcos A.   S  ¦ Data ¦ 03.05.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGeraParametros()

	local nCont		 := 0 
	local cCorFundo  := ""
	local cTitulo	 := 'Parametros'

	local cFonte1    := 'Calibri' 
	local nTamFont1  := 9
	local cCorFont1  := '#FFFFFF'
	local cCorFund1  := '#4F81BD'

	local cFonte2    := 'Arial' 
	local nTamFont2  := 9
	local cCorFont2  := '#000000'

	local cCorFundo  := ''

	aPergs[1,3] := MV_PAR01 
	aPergs[2,3] := MV_PAR02  
	aPergs[3,3] := MV_PAR03     
	aPergs[4,3] := MV_PAR04         
	aPergs[5,3] := MV_PAR05         

	oExcel:AddPlanilha('Parametros',{30,80,120,270})
	oExcel:AddLinha(18)
	oExcel:AddCelula(cTitulo,0,'C','Arial',12,'#FFFFFF',,,'#4F81BD',,,,,.T.,2,2) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula( "Sequencia" ,0,'C',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Pergunta"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Conteudo"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 

	for nCont := 1 to Len(aPergs)	

		if MOD(nCont,2) > 0 
			cCorFundo := '#DCE6F1'	
		else
			cCorFundo := '#B8CCE4'	
		endif	  

		oExcel:AddLinha(16) 
		oExcel:AddCelula()
		oExcel:AddCelula( strzero(nCont,2) ,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,2]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,3]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo 

	next aPergs
return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 03.05.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local cLoad	    := "BIA741Y" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	local aTipos 	:= {"1=Linha", "2=Coluna"} 

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := space(TamSx3("B1_TIPO")[1])
	MV_PAR04 := "1"
	MV_PAR05 := space(100)

	aAdd( aPergs ,{1,"Data de? " 	   		,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até?" 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Tipo de Produto?"		,MV_PAR03 ,"@!",'.T.'		,"02",'.T.',50,.F.})	

	aAdd( aPergs ,{2,"Layout do Produto?" 	,MV_PAR04 ,aTipos,60,".T.",.F.})

	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR05 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Relatório de Custo Realizado",,,,,,,,cLoad,.T.,.T.)  

		lRet := .T.

		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)     
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03) 
		MV_PAR04 := Val(ParamLoad(cFileName,,4,MV_PAR04))  
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)  

		if empty(MV_PAR05) 
			MV_PAR05 := AllTrim(GetTempPath()) 	
		endif  	
	endif

return lRet
