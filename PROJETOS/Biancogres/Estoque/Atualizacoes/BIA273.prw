#Include "Protheus.ch"
#include "topconn.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA273
Empresa   := Biancogres Cerêmicas S/A
Data      := 25/11/11
Uso       := Estoque
Aplicação := Saldo de Estoque atualizado específico para Incesa solicitado
.            pela Ariely.
.            Como ficará evidente na query, este programa foi desenvolvido
.            especificamente para atender a uma necessidade e empresa única
.            se outra empresa do grupo precisar desta informação, um novo
.            tratamento precisará ser feito.
.            Em 03/02/12 foi implementado um segundo bloco de comandos para
.            geração de dados especificamente para as viradas de estoque.
.            Em 26/09/19 foi solicitado retirar o filtro de grupo de produto.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA273()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hhi

	fPerg := "BIA273"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	aDados2 := {}

	If MV_PAR03 == 1
		If MV_PAR01 == 1
			A0001 := SelSalAtu()

			TcQuery A0001 New Alias "A001"
			dbSelectArea("A001")
			dbGoTop()
			ProcRegua(RecCount())
			While !Eof()

				IncProc()

				ZCN->(DbSetOrder(2))

				If MV_PAR06 <= A001->ALMOX .AND. MV_PAR07 >= A001->ALMOX 

					If ZCN->(DbSeek(xFilial("ZCN")+A001->PRODUTO+A001->ALMOX))

						aAdd(aDados2, { "Saldo em "+dtoc(dDataBase),;
						A001->BZ_YLOCAL,;
						A001->ALMOX,;
						ZCN->ZCN_MD,;
						A001->COMUM,;
						ZCN->ZCN_ESTSEG,;
						ZCN->ZCN_PONPED,;
						ZCN->ZCN_POLIT,;
						POSICIONE("SX5",1,xFilial("SX5")+'Y8'+PADR(ZCN->ZCN_POLIT,Tamsx3("X5_CHAVE")[1]),"X5_DESCRI"),;
						A001->PRODUTO,;
						A001->DESC_PROD,;
						A001->UM,;
						A001->GRUPO,;
						A001->DESC_GRUPO,;
						A001->NCM,;
						Transform(SALDO   ,"@E 999,999,999.9999"),;
						Transform(VALOR   ,"@E 999,999,999.9999"),;
						A001->EMISS,;
						A001->SOLICIT,;			
						A001->COD_BAR} )

					EndIf
				EndIf
				dbSelectArea("A001")
				dbSkip()
			End

			aStru1 := ("A001")->(dbStruct())

			A001->(dbCloseArea())

			U_BIAxExcel(aDados2, aStru1, "BIA273"+strzero(seconds()%3500,5),.T. )

		ElseIf MV_PAR01 == 2
			A0001 := SelVirSal()

			TcQuery A0001 New Alias "A001"
			dbSelectArea("A001")
			dbGoTop()
			ProcRegua(RecCount())
			While !Eof()

				IncProc()

				ZCN->(DbSetOrder(2))

				If MV_PAR06 <= A001->ALMOX .AND. MV_PAR07 >= A001->ALMOX

					If ZCN->(DbSeek(xFilial("ZCN")+A001->PRODUTO+A001->ALMOX))

						aAdd(aDados2, { A001->EMPR,;
						"Saldo em "+A001->DtRev,;
						A001->PRODUTO,;
						A001->DESC_PROD,;
						A001->UM,;
						A001->GRUPO,;
						A001->DESC_GRUPO,;
						A001->NCM,;				
						POSICIONE("SX5",1,xFilial("SX5")+'Y8'+PADR(ZCN->ZCN_POLIT,Tamsx3("X5_CHAVE")[1]),"X5_DESCRI"),;
						A001->LOC,;
						A001->ALMOX,;
						Transform(A001->QTD_VIR,"@E 999,999,999.9999"),;
						Transform(A001->VLR_VIR,"@E 999,999,999.9999"),;
						ZCN->ZCN_MD,;
						A001->COMUM,;
						ZCN->ZCN_ESTSEG,;
						ZCN->ZCM_PONPED,;
						A001->COD_BAR,;
						Transform(A001->QTD_ULT_COM,"@E 999,999,999.9999"),;
						Transform(A001->PRC_ULT_COM,"@E 999,999,999.9999"),;
						Transform(A001->CTO_ULT_COM,"@E 999,999,999.9999"),;
						A001->DT_ULT_COM } )

					EndIf
				EndIf
				dbSelectArea("A001")
				dbSkip()
			End

			aStru1 := ("A001")->(dbStruct())

			A001->(dbCloseArea())

			U_BIAxExcel(aDados2, aStru1, "BIA273"+strzero(seconds()%3500,5),.T. )

		ElseIf MV_PAR01 == 3
			A0001 := SelFecham()

			TcQuery A0001 New Alias "A001"
			dbSelectArea("A001")
			dbGoTop()
			ProcRegua(RecCount())
			While !Eof()

				IncProc()

				ZCN->(DbSetOrder(2))

				If MV_PAR06 <= A001->ALMOX .AND. MV_PAR07 >= A001->ALMOX

					If ZCN->(DbSeek(xFilial("ZCN")+A001->PRODUTO+A001->ALMOX))

						aAdd(aDados2, { A001->EMPR,;
						"Saldo em "+A001->DtRev,;
						A001->PRODUTO,;
						A001->DESC_PROD,;
						A001->UM,;
						A001->GRUPO,;
						A001->DESC_GRUPO,;
						A001->NCM,;
						POSICIONE("SX5",1,xFilial("SX5")+'Y8'+PADR(ZCN->ZCN_POLIT,Tamsx3("X5_CHAVE")[1]),"X5_DESCRI"),;
						A001->LOC,;
						A001->ALMOX,;
						Transform(A001->QTD_VIR,"@E 999,999,999.9999"),;
						Transform(A001->VLR_VIR,"@E 999,999,999.9999"),;
						ZCN->ZCN_MD,;
						A001->COMUM,;
						ZCN->ZCN_ESTSEG,;
						ZCN->ZCN_PONPED,;
						A001->COD_BAR,;
						Transform(A001->QTD_ULT_COM,"@E 999,999,999.9999"),;
						Transform(A001->PRC_ULT_COM,"@E 999,999,999.9999"),;
						Transform(A001->CTO_ULT_COM,"@E 999,999,999.9999"),;
						A001->DT_ULT_COM } )					

					EndIf
				EndIf
				dbSelectArea("A001")
				dbSkip()
			End

			aStru1 := ("A001")->(dbStruct())

			A001->(dbCloseArea())

			U_BIAxExcel(aDados2, aStru1, "BIA273"+strzero(seconds()%3500,5),.T. ) 
		EndIf
	Else
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return

Static Function ReportDef()
	Local oReport
	Local oSecEst
	Local Enter := chr(13) + Chr(10)
	Local cTrb := GetNextAlias()
	Local cTitRel := "ITENS DE IMPORTAÇÃO"

	oReport := TReport():New("BIA273", cTitRel, {|| pergunte(fPerg,.F.) }, {|oReport| PrintReport(oReport, cTrb)}, cTitRel)	
	oReport:SetLandscape()
Return(oReport)


Static Function PrintReport(oReport, cTrb)

	Local cSQL := ""
	Local Enter := chr(13) + Chr(10)
	Local linha := 260  
	Local linhaBar := 2.5

	If MV_PAR01 == 1
		A0001 := SelSalAtu()

		TcQuery A0001 New Alias (cTrb)

		While !oReport:Cancel() .And. !(cTrb)->(Eof())
			If linha == 260
				oReport:Say(linha,20,"SaldoEm")
				oReport:Say(linha,160,"| " + "Loc.")
				oReport:Say(linha,280,"| " + "A.D.")
				oReport:Say(linha,400,"| " + "Comum")
				oReport:Say(linha,520,"| " + "EstSeg")
				oReport:Say(linha,690,"| " + "EstMin")
				oReport:Say(linha,860,"| " + "Cód.Pol.")
				oReport:Say(linha,1000,"| " + "Política")
				oReport:Say(linha,1310,"| " + "Código")
				oReport:Say(linha,1440,"| " + "Descrição")
				oReport:Say(linha,2140,"| " + "UM")
				oReport:Say(linha,2200,"| " + "Saldo")
				oReport:Say(linha,2370,"| " + "Valor")
				oReport:Say(linha,2540,"| " + "Emissão")
				oReport:Say(linha,2710,"| " + "Solicitante")
				oReport:Say(linha,3100,"| " + "Cód.Bar.")

				linha += 119
				linhaBar += 1.0
			EndIf

			ZCN->(DbSetOrder(2))

			If MV_PAR06 <= (cTrb)->ALMOX .AND. MV_PAR07 >= (cTrb)->ALMOX

				If ZCN->(DbSeek(xFilial("ZCN")+(cTrb)->PRODUTO+(cTrb)->ALMOX))

					//Say(nRow,nCol,cText,oFont,nWidth,nClrText,nBkMode,nPad)
					oReport:Say(linha,20,dtoc(dDataBase))
					oReport:Say(linha,160,"| " + SubStr((cTrb)->BZ_YLOCAL,1,10))
					oReport:Say(linha,280,"| " + ZCN->ZCN_MD)
					oReport:Say(linha,400,"| " + (cTrb)->COMUM)
					oReport:Say(linha,520,"| " + Transform(ZCN->ZCN_ESTSEG,"@E 999,999.99"))
					oReport:Say(linha,690,"| " + Transform(ZCN->ZCN_PONPED,"@E 999,999.99"))			
					oReport:Say(linha,860,"| " + ZCN->ZCN_POLIT)
					oReport:Say(linha,1000,"| " + SubStr(POSICIONE("SX5",1,xFilial("SX5")+'Y8'+PADR(ZCN->ZCN_POLIT,Tamsx3("X5_CHAVE")[1]),"X5_DESCRI"),1,20))
					oReport:Say(linha,1310,"| " + (cTrb)->PRODUTO)
					oReport:Say(linha,1440,"| " + SubStr((cTrb)->DESC_PROD,1,45))
					oReport:Say(linha,2140,"| " + (cTrb)->UM)
					oReport:Say(linha,2200,"| " + Transform((cTrb)->SALDO,"@E 999,999.99"))
					oReport:Say(linha,2370,"| " + Transform((cTrb)->VALOR,"@E 999,999.99"))
					oReport:Say(linha,2540,"| " + (cTrb)->EMISS)
					oReport:Say(linha,2710,"| " + (cTrb)->SOLICIT)
					MSBAR("CODE128",linhaBar,27.0,RTrim(LTrim((cTrb)->COD_BAR)),@oreport:oPrint,.F.,Nil,Nil,0.02,0.7,.T.,Nil,Nil,.F.)

				EndIf
				linha += 119
				linhaBar += 1.0

			EndIf

			If linha > 2000
				oReport:EndPage(.T.)
				linha := 260
				linhaBar := 2.5
			EndIf

			(cTrb)->(dbSkip())
		End

	ElseIf MV_PAR01 == 2

		A0001 := SelVirSal()

		TcQuery A0001 New Alias (cTrb)

		While !oReport:Cancel() .And. !(cTrb)->(Eof())
			If linha == 260
				oReport:Say(linha,20,"Empresa")
				oReport:Say(linha,170,"| " + "SaldoEm")
				oReport:Say(linha,310,"| " + "Código")
				oReport:Say(linha,440,"| " + "Descrição")
				oReport:Say(linha,890,"| " + "UM")
				oReport:Say(linha,950,"| " + "Política")
				oReport:Say(linha,1260,"| " + "Loc.")
				oReport:Say(linha,1380,"| " + "Al.")
				oReport:Say(linha,1430,"| " + "Qtd.Vir.")
				oReport:Say(linha,1630,"| " + "Vlr.Vir.")
				oReport:Say(linha,1800,"| " + "A.D.")
				oReport:Say(linha,1920,"| " + "Comum")
				oReport:Say(linha,2040,"| " + "EstSeg")
				oReport:Say(linha,2210,"| " + "EstMin")
				oReport:Say(linha,2380,"| " + "QtdUltCom")
				oReport:Say(linha,2550,"| " + "PrcUltCom")
				oReport:Say(linha,2720,"| " + "CtoUltCom")
				oReport:Say(linha,2890,"| " + "DtUltCom")
				oReport:Say(linha,3100,"| " + "Cód.Bar.")

				linha += 119
				linhaBar += 1.0
			EndIf

			ZCN->(DbSetOrder(2))

			If MV_PAR06 <= (cTrb)->ALMOX .AND. MV_PAR07 >= (cTrb)->ALMOX

				If ZCN->(DbSeek(xFilial("ZCN")+(cTrb)->PRODUTO+(cTrb)->ALMOX))

					//Say(nRow,nCol,cText,oFont,nWidth,nClrText,nBkMode,nPad)
					oReport:Say(linha,20,(cTrb)->EMPR)
					oReport:Say(linha,170,"| " + (cTrb)->DtRev)
					oReport:Say(linha,310,"| " + (cTrb)->PRODUTO)
					oReport:Say(linha,440,"| " + SubStr((cTrb)->DESC_PROD,1,30))
					oReport:Say(linha,890,"| " + (cTrb)->UM)
					oReport:Say(linha,950,"| " + SubStr(POSICIONE("SX5",1,xFilial("SX5")+'Y8'+PADR(ZCN->ZCN_POLIT,Tamsx3("X5_CHAVE")[1]),"X5_DESCRI"),1,20))
					oReport:Say(linha,1260,"| " + SubStr((cTrb)->LOC,1,10))
					oReport:Say(linha,1380,"| " + (cTrb)->ALMOX)
					oReport:Say(linha,1430,"| " + Transform((cTrb)->QTD_VIR,"@E 999,999.99"))
					oReport:Say(linha,1630,"| " + Transform((cTrb)->VLR_VIR,"@E 999,999.99"))
					oReport:Say(linha,1800,"| " + ZCN->ZCN_MD)
					oReport:Say(linha,1920,"| " + (cTrb)->COMUM)
					oReport:Say(linha,2040,"| " + Transform(ZCN->ZCN_ESTSEG,"@E 999,999.99"))
					oReport:Say(linha,2210,"| " + Transform(ZCN->ZCN_PONPED,"@E 999,999.99"))
					oReport:Say(linha,2380,"| " + Transform((cTrb)->QTD_ULT_COM,"@E 999,999.99"))
					oReport:Say(linha,2550,"| " + Transform((cTrb)->PRC_ULT_COM,"@E 999,999.99"))
					oReport:Say(linha,2720,"| " + Transform((cTrb)->CTO_ULT_COM,"@E 999,999.99"))
					oReport:Say(linha,2890,"| " + (cTrb)->DT_ULT_COM)
					MSBAR("CODE128",linhaBar,27.0,RTrim(LTrim((cTrb)->COD_BAR)),@oreport:oPrint,.F.,Nil,Nil,0.02,0.7,.T.,Nil,Nil,.F.)

				EndIf

				linha += 119
				linhaBar += 1.0
			EndIf

			If linha > 2000
				oReport:EndPage(.T.)
				linha := 260
				linhaBar := 2.5
			EndIf

			(cTrb)->(dbSkip())
		End

	ElseIf MV_PAR01 == 3

		A0001 := SelFecham()

		TcQuery A0001 New Alias (cTrb)

		While !oReport:Cancel() .And. !(cTrb)->(Eof())
			If linha == 260
				oReport:Say(linha,20,"Empresa")
				oReport:Say(linha,170,"| " + "SaldoEm")
				oReport:Say(linha,310,"| " + "Código")
				oReport:Say(linha,440,"| " + "Descrição")
				oReport:Say(linha,890,"| " + "UM")
				oReport:Say(linha,950,"| " + "Política")
				oReport:Say(linha,1260,"| " + "Loc.")
				oReport:Say(linha,1380,"| " + "Al.")
				oReport:Say(linha,1430,"| " + "Qtd.Vir.")
				oReport:Say(linha,1630,"| " + "Vlr.Vir.")
				oReport:Say(linha,1800,"| " + "A.D.")
				oReport:Say(linha,1920,"| " + "Comum")
				oReport:Say(linha,2040,"| " + "EstSeg")
				oReport:Say(linha,2210,"| " + "EstMin")
				oReport:Say(linha,2380,"| " + "QtdUltCom")
				oReport:Say(linha,2550,"| " + "PrcUltCom")
				oReport:Say(linha,2720,"| " + "CtoUltCom")
				oReport:Say(linha,2890,"| " + "DtUltCom")
				oReport:Say(linha,3100,"| " + "Cód.Bar.")

				linha += 119
				linhaBar += 1.0
			EndIf

			ZCN->(DbSetOrder(2))

			If MV_PAR06 <= (cTrb)->ALMOX .AND. MV_PAR07 >= (cTrb)->ALMOX

				If ZCN->(DbSeek(xFilial("ZCN")+(cTrb)->PRODUTO+(cTrb)->ALMOX))

					//Say(nRow,nCol,cText,oFont,nWidth,nClrText,nBkMode,nPad)
					oReport:Say(linha,20,(cTrb)->EMPR)
					oReport:Say(linha,170,"| " + (cTrb)->DtRev)
					oReport:Say(linha,310,"| " + (cTrb)->PRODUTO)
					oReport:Say(linha,440,"| " + SubStr((cTrb)->DESC_PROD,1,30))
					oReport:Say(linha,890,"| " + (cTrb)->UM)
					oReport:Say(linha,950,"| " + SubStr(POSICIONE("SX5",1,xFilial("SX5")+'Y8'+PADR(ZCN->ZCN_POLIT,Tamsx3("X5_CHAVE")[1]),"X5_DESCRI"),1,20))
					oReport:Say(linha,1260,"| " + SubStr((cTrb)->LOC,1,10))
					oReport:Say(linha,1380,"| " + (cTrb)->ALMOX)
					oReport:Say(linha,1430,"| " + Transform((cTrb)->QTD_VIR,"@E 999,999.99"))
					oReport:Say(linha,1630,"| " + Transform((cTrb)->VLR_VIR,"@E 999,999.99"))
					oReport:Say(linha,1800,"| " + ZCN->ZCN_MD)
					oReport:Say(linha,1920,"| " + (cTrb)->COMUM)
					oReport:Say(linha,2040,"| " + Transform(ZCN->ZCN_ESTSEG,"@E 999,999.99"))
					oReport:Say(linha,2210,"| " + Transform(ZCN->ZCN_PONPED,"@E 999,999.99"))
					oReport:Say(linha,2380,"| " + Transform((cTrb)->QTD_ULT_COM,"@E 999,999.99"))
					oReport:Say(linha,2550,"| " + Transform((cTrb)->PRC_ULT_COM,"@E 999,999.99"))
					oReport:Say(linha,2720,"| " + Transform((cTrb)->CTO_ULT_COM,"@E 999,999.99"))
					oReport:Say(linha,2890,"| " + (cTrb)->DT_ULT_COM)
					MSBAR("CODE128",linhaBar,27.0,RTrim(LTrim((cTrb)->COD_BAR)),@oreport:oPrint,.F.,Nil,Nil,0.02,0.7,.T.,Nil,Nil,.F.)

				EndIf

				linha += 119
				linhaBar += 1.0

			EndIf

			If linha > 2000
				oReport:EndPage(.T.)
				linha := 260
				linhaBar := 2.5
			EndIf

			(cTrb)->(dbSkip())
		End
	EndIf                                                      	

	(cTrb)->(DbCloseArea())

Return()

Static Function SelSalAtu()

	Local Enter := chr(13) + Chr(10)

	// Tratamento Intercompany para listagem dos almoxarifados. Por Marcos Alberto Soprani em 03/01/13
	xAfLcRef := ""
	xCfLcRef := ""

	If cEmpAnt == "14" // Tiago Rossini Coradini - OS: 1590-15 - Sidcley - Acesando pela empresa Vitcer

		xAfLcRef := "01','6V','6B"
		xCfLcRef := "6V"

	ElseIf cEmpAnt == "05"          // Acesando pela empresa Incesa

		xAfLcRef := "01" //','6I','6B"
		xCfLcRef := "--"

	ElseIf cEmpAnt == "01"  // Acesando pela empresa Biancogres

		xAfLcRef := "--"
		xCfLcRef := "01','20"

	EndIf

	A0001 := " SELECT ' ' DTREF," + Enter
	A0001 += "        BZ_YLOCAL," + Enter
	A0001 += "        B2_LOCAL ALMOX," + Enter	
	A0001 += "        BZ_YMD APLIC_DIRETA," + Enter
	A0001 += "        BZ_YCOMUM COMUM," + Enter
	A0001 += "        BZ_ESTSEG ESTSEG," + Enter
	A0001 += "        BZ_EMIN ESTMIN," + Enter
	A0001 += "        BZ_YPOLIT COD_POLITICA," + Enter
	A0001 += "        X5_DESCRI POLITICA," + Enter
	A0001 += "        B2_COD PRODUTO," + Enter
	A0001 += "        B1_DESC DESC_PROD," + Enter
	A0001 += "        B1_UM UM," + Enter
	A0001 += "        B1_GRUPO GRUPO," + Enter
	A0001 += "        BM_DESC DESC_GRUPO," + Enter
	A0001 += "        B1_POSIPI NCM," + Enter
	A0001 += "        SUM(B2_QATU) SALDO," + Enter
	A0001 += "        SUM(B2_VATU1) VALOR," + Enter
	A0001 += "        Convert(Char(10),convert(datetime, SUBSTRING(SOLICIT,1,08)),103) EMISS," + Enter
	A0001 += "        SUBSTRING(SOLICIT,9,10) SOLICIT," + Enter
	A0001 += "        B2_COD AS COD_BAR" + Enter
	A0001 += "   FROM (SELECT "+ If (cEmpAnt == '14', '140', '050') +" TAB," + Enter
	A0001 += "                ZCN_LOCALI BZ_YLOCAL," + Enter
	A0001 += "                BZ_YPOLIT," + Enter
	A0001 += "                BZ_YMD," + Enter
	A0001 += "                BZ_YCOMUM," + Enter
	A0001 += "                BZ_ESTSEG," + Enter
	A0001 += "                BZ_EMIN," + Enter
	A0001 += "                X5_DESCRI," + Enter
	A0001 += "                B2_COD," + Enter
	A0001 += "                SUBSTRING(B1_DESC,1,100) B1_DESC," + Enter
	A0001 += "                B1_UM," + Enter
	A0001 += "                B1_GRUPO," + Enter
	A0001 += "                BM_DESC = (SELECT BM_DESC FROM SBM010 WHERE BM_FILIAL = '' AND BM_GRUPO = SB1.B1_GRUPO AND D_E_L_E_T_ = '')," + Enter
	A0001 += "                B1_POSIPI," + Enter
	A0001 += "                B2_LOCAL," + Enter
	A0001 += "                B2_QATU," + Enter
	A0001 += "                B2_VATU1," + Enter
	A0001 += "                ISNULL((SELECT C1_EMISSAO + C1_SOLICIT" + Enter
	A0001 += "                          FROM SC1"+ If (cEmpAnt == '14', '140', '050')+ "" + Enter
	A0001 += "                         WHERE C1_FILIAL = '01'" + Enter
	A0001 += "                           AND R_E_C_N_O_ IN(SELECT MAX(R_E_C_N_O_)" + Enter
	A0001 += "                                               FROM SC1"+ If (cEmpAnt == '14', '140', '050')+ "" + Enter
	A0001 += "                                              WHERE C1_FILIAL = '01'" + Enter
	A0001 += "                                                AND C1_PRODUTO = B2_COD" + Enter
	A0001 += "                                                AND C1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                                                AND D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                           AND D_E_L_E_T_ = ' '),'19800101-----') SOLICIT" + Enter
	A0001 += "           FROM SB2"+ If (cEmpAnt == '14', '140', '050') +" SB2" + Enter
	A0001 += "          INNER JOIN SB1010 SB1 ON B1_FILIAL = '  '" + Enter
	A0001 += "                               AND B1_COD = B2_COD" + Enter
	//A0001 += "                               AND SUBSTRING(B1_GRUPO,1,3) BETWEEN '201' AND '220'" + Enter	
	A0001 += "                               AND B1_COD < 'A' " + Enter
	A0001 += "                               AND B1_COD BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "'" + Enter
	A0001 += "                               AND SB1.D_E_L_E_T_ = ' '" + Enter
	A0001 += "          INNER JOIN "+RetSqlName("ZCN")+" ZCN ON ZCN_FILIAL = " + ValtoSql(xFilial("ZCN")) +"  " + Enter
	A0001 += "                               AND ZCN_COD = B2_COD" + Enter
	A0001 += "                               AND ZCN_LOCAL = B2_LOCAL" + Enter
	A0001 += "                               AND ZCN.D_E_L_E_T_ = ' '" + Enter	
	A0001 += "           LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON BZ_FILIAL = '"+xFilial("SBZ")+"'" + Enter
	A0001 += "                               AND BZ_COD = B1_COD" + Enter
	A0001 += "                               AND SBZ.D_E_L_E_T_ = ' '" + Enter
	A0001 += "           LEFT JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '  '" + Enter
	A0001 += "                               AND X5_TABELA = 'Y8'" + Enter
	A0001 += "                               AND X5_CHAVE = BZ_YPOLIT" + Enter
	A0001 += "                               AND SX5.D_E_L_E_T_ = ' '" + Enter
	A0001 += "          WHERE B2_FILIAL = '01'" + Enter
	A0001 += "            AND B2_LOCAL IN('"+xAfLcRef+"')" + Enter
	A0001 += "            AND SB2.D_E_L_E_T_ = ' '" + Enter
	A0001 += "         UNION" + Enter
	A0001 += "         SELECT '010' TAB," + Enter
	A0001 += "                ZCN_LOCALI BZ_YLOCAL," + Enter
	A0001 += "                BZ_YPOLIT," + Enter
	A0001 += "                BZ_YMD," + Enter
	A0001 += "                BZ_YCOMUM," + Enter
	A0001 += "                BZ_ESTSEG," + Enter
	A0001 += "                BZ_EMIN," + Enter
	A0001 += "                X5_DESCRI," + Enter
	A0001 += "                B2_COD," + Enter
	A0001 += "                SUBSTRING(B1_DESC,1,100) B1_DESC," + Enter
	A0001 += "                B1_UM," + Enter
	A0001 += "                B1_GRUPO," + Enter
	A0001 += "                BM_DESC = (SELECT BM_DESC FROM SBM010 WHERE BM_FILIAL = '' AND BM_GRUPO = SB1.B1_GRUPO AND D_E_L_E_T_ = '')," + Enter
	A0001 += "                B1_POSIPI," + Enter
	A0001 += "                B2_LOCAL," + Enter
	A0001 += "                B2_QATU," + Enter
	A0001 += "                B2_VATU1," + Enter

	//A0001 += "                ISNULL((SELECT C1_EMISSAO + C1_SOLICIT" + Enter
	//A0001 += "                          FROM SC1010" + Enter
	//A0001 += "                         WHERE C1_FILIAL = '01'" + Enter
	//A0001 += "                           AND R_E_C_N_O_ IN(SELECT MAX(R_E_C_N_O_)" + Enter
	//A0001 += "                                               FROM SC1010" + Enter
	//A0001 += "                                              WHERE C1_FILIAL = '01'" + Enter
	//A0001 += "                                                AND C1_PRODUTO = B2_COD" + Enter
	//A0001 += "                                                AND C1_LOCAL = B2_LOCAL" + Enter
	//A0001 += "                                                AND D_E_L_E_T_ = ' ')" + Enter
	//A0001 += "                           AND D_E_L_E_T_ = ' '),'19800101-----') SOLICIT" + Enter

	//Ticket 11216: Alteração feita para trazer Data de emissão da SC feita na Incesa.
	A0001 += "             ISNULL(ISNULL((SELECT C1_EMISSAO + C1_SOLICIT" + Enter 
	A0001 += "                              FROM SC1010 " + Enter 
	A0001 += "                             WHERE R_E_C_N_O_ IN(SELECT MAX(R_E_C_N_O_)" + Enter  
	A0001 += "                                                   FROM SC1010" + Enter  
	A0001 += "                                                  WHERE C1_FILIAL = '01' " + Enter 
	A0001 += "                                                    AND C1_PRODUTO = B2_COD " + Enter 
	A0001 += "                                                    AND C1_LOCAL = B2_LOCAL " + Enter 
	A0001 += "                                                    AND D_E_L_E_T_ = ' ')" + Enter  
	A0001 += "                               AND D_E_L_E_T_ = ' ')," + Enter 
	A0001 += "                           (SELECT C1_EMISSAO + C1_SOLICIT " + Enter 
	A0001 += "                              FROM SC1050 " + Enter
	A0001 += "                             WHERE R_E_C_N_O_ IN(SELECT MAX(R_E_C_N_O_)" + Enter 
	A0001 += "                                                   FROM SC1050 " + Enter
	A0001 += "                                                  WHERE C1_FILIAL = '01' " + Enter
	A0001 += "                                                    AND C1_PRODUTO = B2_COD " + Enter
	A0001 += "                                                    AND D_E_L_E_T_ = ' ')" + Enter 
	A0001 += "                               AND D_E_L_E_T_ = ' ')),'19800101-----')SOLICIT " + Enter

	A0001 += "           FROM SB2010 SB2" + Enter
	A0001 += "          INNER JOIN SB1010 SB1 ON B1_FILIAL = '  '" + Enter
	A0001 += "                               AND B1_COD = B2_COD" + Enter
	//A0001 += "                               AND SUBSTRING(B1_GRUPO,1,3) BETWEEN '201' AND '220'" + Enter
	A0001 += "                               AND B1_COD < 'A' " + Enter
	A0001 += "                               AND B1_COD BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "'" + Enter
	A0001 += "                               AND B1_MSBLQL <> '1' " + Enter
	A0001 += "                               AND SB1.D_E_L_E_T_ = ' '" + Enter
	A0001 += "          INNER JOIN "+RetSqlName("ZCN")+" ZCN ON ZCN_FILIAL = " + ValtoSql(xFilial("ZCN")) +"  " + Enter
	A0001 += "                               AND ZCN_COD = B2_COD" + Enter
	A0001 += "                               AND ZCN_LOCAL = B2_LOCAL" + Enter
	A0001 += "                               AND ZCN.D_E_L_E_T_ = ' '" + Enter
	A0001 += "           LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON BZ_FILIAL = '"+xFilial("SBZ")+"'" + Enter
	A0001 += "                               AND BZ_COD = B1_COD" + Enter
	A0001 += "                               AND BZ_YATIVO <> 'N' " + Enter
	A0001 += "                               AND SBZ.D_E_L_E_T_ = ' '" + Enter
	A0001 += "           LEFT JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '  '" + Enter
	A0001 += "                               AND X5_TABELA = 'Y8'" + Enter
	A0001 += "                               AND X5_CHAVE = BZ_YPOLIT" + Enter
	A0001 += "                               AND SX5.D_E_L_E_T_ = ' '" + Enter
	A0001 += "          WHERE B2_FILIAL = '01'" + Enter
	A0001 += "            AND B2_LOCAL IN('"+xCfLcRef+"')" + Enter
	A0001 += "            AND SB2.D_E_L_E_T_ = ' '" + Enter
	A0001 += "         ) AS SAL" + Enter
	A0001 += "  GROUP BY BZ_YLOCAL," + Enter
	A0001 += "           B2_LOCAL," + Enter		
	A0001 += "           BZ_YPOLIT," + Enter
	A0001 += "           BZ_YMD," + Enter
	A0001 += "           BZ_YCOMUM," + Enter
	A0001 += "           BZ_ESTSEG," + Enter
	A0001 += "           BZ_EMIN," + Enter
	A0001 += "           X5_DESCRI," + Enter
	A0001 += "           B2_COD," + Enter
	A0001 += "           B1_DESC," + Enter
	A0001 += "           B1_UM," + Enter
	A0001 += "           B1_GRUPO," + Enter
	A0001 += "           BM_DESC," + Enter
	A0001 += "           B1_POSIPI," + Enter
	A0001 += "           SOLICIT" + Enter
	A0001 += "  ORDER BY BZ_YLOCAL," + Enter
	A0001 += "           X5_DESCRI," + Enter
	A0001 += "           B2_COD," + Enter
	A0001 += "           B1_DESC," + Enter
	A0001 += "           B1_UM," + Enter
	A0001 += "           SOLICIT" + Enter

Return A0001

Static Function SelVirSal()

	Local Enter := chr(13) + Chr(10)

	// Tratamento Intercompany para listagem dos almoxarifados. Por Marcos Alberto Soprani em 03/01/13
	xAfLcRef := ""
	xCfLcRef := ""

	If cEmpAnt == "14" // Tiago Rossini Coradini - OS: 1590-15 - Sidcley - Acesando pela empresa Vitcer

		xAfLcRef := "01','6V"
		xCfLcRef := "6V"

	ElseIf cEmpAnt == "05"          // Acesando pela empresa Incesa

		xAfLcRef := "01','6I"
		xCfLcRef := "6I"

	ElseIf cEmpAnt == "01"  // Acesando pela empresa Biancogres

		xAfLcRef := "--"
		xCfLcRef := "01','20"

	EndIf

	A0001 := " SELECT "+ If (cEmpAnt == '14', "'VITCER'", "'INCESA'") +" EMPR," + Enter
	A0001 += "        Convert(Char(10),convert(datetime, B9_DATA),103) DtRev," + Enter
	A0001 += "        B9_COD PRODUTO," + Enter	
	A0001 += "        SUBSTRING(B1_DESC,1,70) DESC_PROD," + Enter
	A0001 += "        B1_UM UM," + Enter
	A0001 += "        B1_GRUPO GRUPO," + Enter
	A0001 += "        DESC_GRUPO = (SELECT BM_DESC FROM SBM010 WHERE BM_FILIAL = '' AND BM_GRUPO = SB1.B1_GRUPO AND D_E_L_E_T_ = '')," + Enter
	A0001 += "        B1_POSIPI NCM," + Enter
	A0001 += "        X5_DESCRI POLITICA," + Enter
	A0001 += "        ZCN_LOCALI LOC," + Enter
	A0001 += "        B9_LOCAL ALMOX," + Enter
	A0001 += "        B9_QINI QTD_VIR," + Enter
	A0001 += "        B9_VINI1 VLR_VIR," + Enter
	A0001 += "        BZ_YMD APLIC_DIR," + Enter
	A0001 += "        BZ_YCOMUM COMUM," + Enter
	A0001 += "        BZ_ESTSEG ESTSEG," + Enter
	A0001 += "        BZ_EMIN ESTMIN," + Enter
	A0001 += "        B9_COD AS COD_BAR," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_QUANT)" + Enter
	A0001 += "                  FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                 INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B9_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                                       INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B9_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) QTD_ULT_COM," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_TOTAL)" + Enter
	A0001 += "                  FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                 INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B9_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                                       INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B9_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) PRC_ULT_COM," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_CUSTO)" + Enter
	A0001 += "                  FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                 INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B9_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                                       INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B9_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) CTO_ULT_COM," + Enter
	A0001 += "        Convert(Char(11), convert(datetime,ISNULL((SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                                     FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                                                    INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                                         AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                                         AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                                         AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                                    WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                                      AND D1_COD = B9_COD" + Enter
	A0001 += "                                                      AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                                                      AND SD1.D_E_L_E_T_ = ' '), '          '), 0 ) ) DT_ULT_COM" + Enter
	A0001 += "   FROM SB9"+ If (cEmpAnt == '14', '140', '050') +" SB9" + Enter
	A0001 += "  INNER JOIN SB1010 SB1 ON B1_FILIAL = '  '" + Enter
	A0001 += "                       AND B1_COD = B9_COD" + Enter
	A0001 += "                       AND B1_TIPO <> 'PI'" + Enter
	//A0001 += "                       AND SUBSTRING(B1_GRUPO,1,3) BETWEEN '201' AND '220'" + Enter
	A0001 += "                       AND B1_COD < 'A' " + Enter
	A0001 += "                       AND B1_COD BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "'" + Enter
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  INNER JOIN "+RetSqlName("SBZ")+" SBZ ON BZ_FILIAL = '"+xFilial("SBZ")+"'" + Enter
	A0001 += "                       AND BZ_COD = B9_COD" + Enter
	A0001 += "                       AND SBZ.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  INNER JOIN "+RetSqlName("ZCN")+" ZCN ON ZCN_FILIAL = " + ValtoSql(xFilial("ZCN")) +"  " + Enter
	A0001 += "                               AND ZCN_COD = BZ_COD" + Enter
	A0001 += "                               AND ZCN_LOCAL = B9_LOCAL" + Enter
	A0001 += "                               AND ZCN.D_E_L_E_T_ = ' '" + Enter
	A0001 += "   LEFT JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '  '" + Enter
	A0001 += "                       AND X5_TABELA = 'Y8'" + Enter
	A0001 += "                       AND X5_CHAVE = BZ_YPOLIT" + Enter
	A0001 += "                       AND SX5.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  WHERE B9_FILIAL = '01'" + Enter
	A0001 += "    AND B9_DATA IN('"+dtos(MV_PAR02)+"')" + Enter
	A0001 += "    AND B9_LOCAL IN('"+xAfLcRef+"')" + Enter
	A0001 += "    AND SB9.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  UNION ALL" + Enter
	A0001 += " SELECT 'BIANCOGRES' EMPR," + Enter
	A0001 += "        Convert(Char(10),convert(datetime, B9_DATA),103) DtRev," + Enter
	A0001 += "        B9_COD PRODUTO," + Enter
	A0001 += "        SUBSTRING(B1_DESC,1,70) DESC_PROD," + Enter
	A0001 += "        B1_UM UM," + Enter
	A0001 += "        B1_GRUPO GRUPO," + Enter
	A0001 += "        DESC_GRUPO = (SELECT BM_DESC FROM SBM010 WHERE BM_FILIAL = '' AND BM_GRUPO = SB1.B1_GRUPO AND D_E_L_E_T_ = '')," + Enter
	A0001 += "        B1_POSIPI NCM," + Enter
	A0001 += "        X5_DESCRI POLITICA," + Enter
	A0001 += "        ZCN_LOCALI LOC," + Enter
	A0001 += "        B9_LOCAL ALMOX," + Enter
	A0001 += "        B9_QINI QTD_VIR," + Enter
	A0001 += "        B9_VINI1 VLR_VIR," + Enter
	A0001 += "        BZ_YMD APLIC_DIR," + Enter
	A0001 += "        BZ_YCOMUM COMUM," + Enter
	A0001 += "        BZ_ESTSEG ESTSEG," + Enter
	A0001 += "        BZ_EMIN ESTMIN," + Enter
	A0001 += "        B9_COD AS COD_BAR," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_QUANT)" + Enter
	A0001 += "                  FROM SD1010 SD1" + Enter
	A0001 += "                 INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B9_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1010 SD1" + Enter
	A0001 += "                                       INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B9_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) QTD_ULT_COM," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_TOTAL)" + Enter
	A0001 += "                  FROM SD1010 SD1" + Enter
	A0001 += "                 INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B9_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1010 SD1" + Enter
	A0001 += "                                       INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B9_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) PRC_ULT_COM," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_CUSTO)" + Enter
	A0001 += "                  FROM SD1010 SD1" + Enter
	A0001 += "                 INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B9_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1010 SD1" + Enter
	A0001 += "                                       INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B9_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) CTO_ULT_COM," + Enter
	A0001 += "        Convert(Char(11), convert(datetime,ISNULL((SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                                     FROM SD1010 SD1" + Enter
	A0001 += "                                                    INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                                         AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                                         AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                                         AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                                    WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                                      AND D1_COD = B9_COD" + Enter
	A0001 += "                                                      AND D1_LOCAL = B9_LOCAL" + Enter
	A0001 += "                                                      AND SD1.D_E_L_E_T_ = ' '), '          '), 0 ) ) DT_ULT_COM" + Enter
	A0001 += "   FROM SB9010 SB9" + Enter
	A0001 += "  INNER JOIN SB1010 SB1 ON B1_FILIAL = '  '" + Enter
	A0001 += "                       AND B1_COD = B9_COD" + Enter
	A0001 += "                       AND B1_TIPO <> 'PI'" + Enter
	//A0001 += "                       AND SUBSTRING(B1_GRUPO,1,3) BETWEEN '201' AND '220'" + Enter
	A0001 += "                       AND B1_COD < 'A' " + Enter
	A0001 += "                       AND B1_COD BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "'" + Enter
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  INNER JOIN "+RetSqlName("SBZ")+" SBZ ON BZ_FILIAL = '"+xFilial("SBZ")+"'" + Enter
	A0001 += "                       AND BZ_COD = B9_COD" + Enter
	A0001 += "                       AND SBZ.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  INNER JOIN "+RetSqlName("ZCN")+" ZCN ON ZCN_FILIAL = " + ValtoSql(xFilial("ZCN")) +"  " + Enter
	A0001 += "                               AND ZCN_COD = BZ_COD" + Enter
	A0001 += "                               AND ZCN_LOCAL = B9_LOCAL" + Enter
	A0001 += "                               AND ZCN.D_E_L_E_T_ = ' '" + Enter
	A0001 += "   LEFT JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '  '" + Enter
	A0001 += "                       AND X5_TABELA = 'Y8'" + Enter
	A0001 += "                       AND X5_CHAVE = BZ_YPOLIT" + Enter
	A0001 += "                       AND SX5.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  WHERE B9_FILIAL = '01'" + Enter
	A0001 += "    AND B9_DATA IN('"+dtos(MV_PAR02)+"')" + Enter
	A0001 += "    AND B9_LOCAL IN('"+xCfLcRef+"')" + Enter
	A0001 += "    AND SB9.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  ORDER BY DtRev, PRODUTO, ALMOX" + Enter

Return A0001

Static Function SelFecham()

	Local Enter := chr(13) + Chr(10)

	// Idem Virada de Saldo mudando para a leitura do SB2 (Fechamento)
	// Tratamento Intercompany para listagem dos almoxarifados. Por Marcos Alberto Soprani em 03/01/13
	xAfLcRef := ""
	xCfLcRef := ""

	If cEmpAnt == "14" // Tiago Rossini Coradini - OS: 1590-15 - Sidcley - Acesando pela empresa Vitcer

		xAfLcRef := "01','6V"
		xCfLcRef := "6V"

	ElseIf cEmpAnt == "05"          // Acesando pela empresa Incesa

		xAfLcRef := "01','6I"
		xCfLcRef := "6I"

	ElseIf cEmpAnt == "01"  // Acesando pela empresa Biancogres

		xAfLcRef := "--"
		xCfLcRef := "01','20"

	EndIf

	A0001 := " SELECT "+ If (cEmpAnt == '14', "'VITCER'", "'INCESA'") +" EMPR," + Enter
	A0001 += "        '"+dtoc(MV_PAR02)+"' DtRev," + Enter
	A0001 += "        B2_COD PRODUTO," + Enter
	A0001 += "        SUBSTRING(B1_DESC,1,70) DESC_PROD," + Enter
	A0001 += "        B1_UM UM," + Enter
	A0001 += "        B1_GRUPO GRUPO," + Enter
	A0001 += "        DESC_GRUPO = (SELECT BM_DESC FROM SBM010 WHERE BM_FILIAL = '' AND BM_GRUPO = SB1.B1_GRUPO AND D_E_L_E_T_ = '')," + Enter
	A0001 += "        B1_POSIPI NCM," + Enter
	A0001 += "        X5_DESCRI POLITICA," + Enter
	A0001 += "        ZCN_LOCAL LOC," + Enter
	A0001 += "        B2_LOCAL ALMOX," + Enter
	A0001 += "        B2_QFIM QTD_VIR," + Enter
	A0001 += "        B2_VFIM1 VLR_VIR," + Enter
	A0001 += "        BZ_YMD APLIC_DIR," + Enter
	A0001 += "        BZ_YCOMUM COMUM," + Enter
	A0001 += "        BZ_ESTSEG ESTSEG," + Enter
	A0001 += "        BZ_EMIN ESTMIN," + Enter
	A0001 += "        B2_COD AS COD_BAR," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_QUANT)" + Enter
	A0001 += "                  FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                 INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B2_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                                       INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B2_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) QTD_ULT_COM," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_TOTAL)" + Enter
	A0001 += "                  FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                 INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B2_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                                       INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B2_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) PRC_ULT_COM," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_CUSTO)" + Enter
	A0001 += "                  FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                 INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B2_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                                       INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B2_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) CTO_ULT_COM," + Enter
	A0001 += "        Convert(Char(11), convert(datetime,ISNULL((SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                                     FROM SD1"+ If (cEmpAnt == '14', '140', '050') +" SD1" + Enter
	A0001 += "                                                    INNER JOIN SF4"+ If (cEmpAnt == '14', '140', '050') +" SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                                         AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                                         AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                                         AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                                    WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                                      AND D1_COD = B2_COD" + Enter
	A0001 += "                                                      AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                                                      AND SD1.D_E_L_E_T_ = ' '), '          '), 0 ) ) DT_ULT_COM" + Enter
	A0001 += "   FROM SB2"+ If (cEmpAnt == '14', '140', '050') +" SB2" + Enter
	A0001 += "  INNER JOIN SB1010 SB1 ON B1_FILIAL = '  '" + Enter
	A0001 += "                       AND B1_COD = B2_COD" + Enter
	A0001 += "                       AND B1_TIPO <> 'PI'" + Enter
	//A0001 += "                       AND SUBSTRING(B1_GRUPO,1,3) BETWEEN '201' AND '220'" + Enter
	A0001 += "                       AND B1_COD < 'A' " + Enter
	A0001 += "                       AND B1_COD BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "'" + Enter
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  INNER JOIN "+RetSqlName("SBZ")+" SBZ ON BZ_FILIAL = '"+xFilial("SBZ")+"'" + Enter
	A0001 += "                       AND BZ_COD = B2_COD" + Enter
	A0001 += "                       AND SBZ.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  INNER JOIN "+RetSqlName("ZCN")+" ZCN ON ZCN_FILIAL = " + ValtoSql(xFilial("ZCN")) +"  " + Enter
	A0001 += "                               AND ZCN_COD = B2_COD" + Enter
	A0001 += "                               AND ZCN_LOCAL = B2_LOCAL" + Enter
	A0001 += "                               AND ZCN.D_E_L_E_T_ = ' '" + Enter	
	A0001 += "   LEFT JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '  '" + Enter
	A0001 += "                       AND X5_TABELA = 'Y8'" + Enter
	A0001 += "                       AND X5_CHAVE = BZ_YPOLIT" + Enter
	A0001 += "                       AND SX5.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  WHERE B2_FILIAL = '01'" + Enter
	A0001 += "    AND B2_LOCAL IN('"+xAfLcRef+"')" + Enter
	A0001 += "    AND SB2.D_E_L_E_T_ = ' '" + Enter

	A0001 += "  UNION ALL" + Enter

	A0001 += " SELECT 'BIANCOGRES' EMPR," + Enter
	A0001 += "        '"+dtoc(MV_PAR02)+"' DtRev," + Enter
	A0001 += "        B2_COD PRODUTO," + Enter
	A0001 += "        SUBSTRING(B1_DESC,1,70) DESC_PROD," + Enter
	A0001 += "        B1_UM UM," + Enter
	A0001 += "        B1_GRUPO GRUPO," + Enter
	A0001 += "        DESC_GRUPO = (SELECT BM_DESC FROM SBM010 WHERE BM_FILIAL = '' AND BM_GRUPO = SB1.B1_GRUPO AND D_E_L_E_T_ = '')," + Enter
	A0001 += "        B1_POSIPI NCM," + Enter	
	A0001 += "        X5_DESCRI POLITICA," + Enter
	A0001 += "        ZCN_LOCALI LOC," + Enter
	A0001 += "        B2_LOCAL ALMOX," + Enter
	A0001 += "        B2_QFIM QTD_VIR," + Enter
	A0001 += "        B2_VFIM1 VLR_VIR," + Enter
	A0001 += "        BZ_YMD APLIC_DIR," + Enter
	A0001 += "        BZ_YCOMUM COMUM," + Enter
	A0001 += "        BZ_ESTSEG ESTSEG," + Enter
	A0001 += "        BZ_EMIN ESTMIN," + Enter
	A0001 += "        B2_COD AS COD_BAR," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_QUANT)" + Enter
	A0001 += "                  FROM SD1010 SD1" + Enter
	A0001 += "                 INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B2_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1010 SD1" + Enter
	A0001 += "                                       INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B2_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) QTD_ULT_COM," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_TOTAL)" + Enter
	A0001 += "                  FROM SD1010 SD1" + Enter
	A0001 += "                 INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B2_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1010 SD1" + Enter
	A0001 += "                                       INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B2_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) PRC_ULT_COM," + Enter
	A0001 += "        ISNULL((SELECT SUM(D1_CUSTO)" + Enter
	A0001 += "                  FROM SD1010 SD1" + Enter
	A0001 += "                 INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                      AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                      AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                 WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                   AND D1_COD = B2_COD" + Enter
	A0001 += "                   AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                   AND D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                        FROM SD1010 SD1" + Enter
	A0001 += "                                       INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                            AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                            AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                            AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                       WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                         AND D1_COD = B2_COD" + Enter
	A0001 += "                                         AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                                         AND SD1.D_E_L_E_T_ = ' ')" + Enter
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) CTO_ULT_COM," + Enter
	A0001 += "        Convert(Char(11), convert(datetime,ISNULL((SELECT MAX(D1_DTDIGIT)" + Enter
	A0001 += "                                                     FROM SD1010 SD1" + Enter
	A0001 += "                                                    INNER JOIN SF4010 SF4 ON F4_FILIAL = '01'" + Enter
	A0001 += "                                                                         AND F4_CODIGO = D1_TES" + Enter
	A0001 += "                                                                         AND F4_ESTOQUE = 'S'" + Enter
	A0001 += "                                                                         AND SF4.D_E_L_E_T_ = ' '" + Enter
	A0001 += "                                                    WHERE D1_FILIAL = '01'" + Enter
	A0001 += "                                                      AND D1_COD = B2_COD" + Enter
	A0001 += "                                                      AND D1_LOCAL = B2_LOCAL" + Enter
	A0001 += "                                                      AND SD1.D_E_L_E_T_ = ' '), '          '), 0 ) ) DT_ULT_COM" + Enter
	A0001 += "   FROM SB2010 SB2" + Enter
	A0001 += "  INNER JOIN SB1010 SB1 ON B1_FILIAL = '  '" + Enter
	A0001 += "                       AND B1_COD = B2_COD" + Enter
	A0001 += "                       AND B1_TIPO <> 'PI'" + Enter
	//A0001 += "                       AND SUBSTRING(B1_GRUPO,1,3) BETWEEN '201' AND '220'" + Enter
	A0001 += "                       AND B1_COD < 'A' " + Enter
	A0001 += "                       AND B1_COD BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "'" + Enter
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  INNER JOIN "+RetSqlName("SBZ")+" SBZ ON BZ_FILIAL = '"+xFilial("SBZ")+"'" + Enter
	A0001 += "                       AND BZ_COD = B2_COD" + Enter
	A0001 += "                       AND SBZ.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  INNER JOIN "+RetSqlName("ZCN")+" ZCN ON ZCN_FILIAL = " + ValtoSql(xFilial("ZCN")) +"  " + Enter
	A0001 += "                               AND ZCN_COD = B2_COD" + Enter
	A0001 += "                               AND ZCN_LOCAL = B2_LOCAL" + Enter
	A0001 += "                               AND ZCN.D_E_L_E_T_ = ' '" + Enter	
	A0001 += "   LEFT JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '  '" + Enter
	A0001 += "                       AND X5_TABELA = 'Y8'" + Enter
	A0001 += "                       AND X5_CHAVE = BZ_YPOLIT" + Enter
	A0001 += "                       AND SX5.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  WHERE B2_FILIAL = '01'" + Enter	
	A0001 += "    AND B2_LOCAL IN('"+xCfLcRef+"')" + Enter
	A0001 += "    AND SB2.D_E_L_E_T_ = ' '" + Enter
	A0001 += "  ORDER BY DtRev, PRODUTO, ALMOX" + Enter

Return A0001

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
	aAdd(aRegs,{cPerg,"01","Quanto aos Saldos    ?","","","mv_ch1","N",01,0,0,"C","","mv_par01","Saldo Atual","","","","","Virada de Saldo","","","","","Fechamento","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Data de Referência   ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Excel                ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Do Produto           ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Ate o Produto        ?","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})

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
