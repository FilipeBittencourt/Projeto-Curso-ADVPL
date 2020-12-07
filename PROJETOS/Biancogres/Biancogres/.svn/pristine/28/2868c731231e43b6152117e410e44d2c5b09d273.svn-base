#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2

#DEFINE VBOX      080
#DEFINE VSPACE    008
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030
#DEFINE MAXITEM   010                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2 044                                                // Máximo de produtos para a pagina 2 (caso nao utilize a opção de impressao em verso)
#DEFINE MAXITEMP3 015                                                // Máximo de produtos para a pagina 2 (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMP4 022                                                // Máximo de produtos para a pagina 2 (caso contenha main info cpl que suporta a primeira pagina)
#DEFINE MAXITEMC  012                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN 110                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG    006                                                // Máximo de dados adicionais na primeira página
#DEFINE MAXMSG2   019                                                // Máximo de dados adicionais na segunda página
#DEFINE MAXBOXH   800                                                // Tamanho maximo do box Horizontal
#DEFINE MAXBOXV   600
#DEFINE INIBOXH   -10
#DEFINE MAXMENL   080                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXVALORC 008                                                // Máximo de caracteres por linha de valores numéricos

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA245
Empresa   := Biancogres Cerâmica S/A
Data      := 18/09/12
Uso       := Gestão de Pessoal
Aplicação := Autorização de Pagamento - Pensão Alimentícia
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA245()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local kLp
	Local aArea     := GetArea()
	Local lExistNfe := .F.
	Local lAdjustToLegacy := .T.  // Usado para montar o Objeto Printer
	Local lDisableSetup   := .T.  // Usado para montar o Objeto Printer

	Private nHPage
	Private nVPage
	Private nLine
	Private nBaseTxt
	Private nBaseCol

	Private oPagtoRH   := FWMsPrinter():New( "pagtorh.rel", IMP_PDF, lAdjustToLegacy, "c:\temp\", .T., , , , , , , , )

	Private oSetup
	Private nConsNeg := 0.40 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
	Private nConsTex := 0.38 // Constante para concertar o cálculo retornado pelo GetTextWidth.

	PRIVATE oFont20n   := TFontEx():New(oPagtoRH,"Arial",20,20,.T.,.T.,.F.)
	PRIVATE oFont20    := TFontEx():New(oPagtoRH,"Arial",20,20,.F.,.T.,.F.)
	PRIVATE oFont15n   := TFontEx():New(oPagtoRH,"Arial",15,15,.T.,.T.,.F.)
	PRIVATE oFont15    := TFontEx():New(oPagtoRH,"Arial",15,15,.F.,.T.,.F.)
	PRIVATE oFont10n   := TFontEx():New(oPagtoRH,"Arial",10,10,.T.,.T.,.F.)
	PRIVATE oFont10    := TFontEx():New(oPagtoRH,"Arial",10,10,.F.,.T.,.F.)
	PRIVATE oFont12n   := TFontEx():New(oPagtoRH,"Arial",12,12,.T.,.T.,.F.)
	PRIVATE oFntEx12   := TFontEx():New(oPagtoRH,"Lucida Console",12,12,.T.,.T.,.F.)
	PRIVATE oFont09n   := TFontEx():New(oPagtoRH,"Arial",09,09,.T.,.T.,.F.)
	PRIVATE oFont09    := TFontEx():New(oPagtoRH,"Arial",09,09,.F.,.T.,.F.)
	PRIVATE oFont08n   := TFontEx():New(oPagtoRH,"Arial",08,08,.T.,.T.,.F.)
	PRIVATE oFont08    := TFontEx():New(oPagtoRH,"Arial",08,08,.F.,.T.,.F.)

	Private PixelX := oPagtoRH:nLogPixelX()
	Private PixelY := oPagtoRH:nLogPixelY()
	oBrush         := TBrush():New( , CLR_BLACK )

	fPerg := "BIA245"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If !oPagtoRH:Canceled()

		// Ordem obrigátoria de configuração do relatório
		oPagtoRH:SetResolution(72)
		oPagtoRH:SetPortrait()
		oPagtoRH:SetPaperSize(DMPAPER_A4)
		oPagtoRH:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
		oPagtoRH:cPathPDF := "c:\temp\" // Caso seja utilizada impressão em IMP_PDF
		aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"

		xPrntPdf := .T.
		If Alltrim(oPagtoRH:cPrinter) <> "PDF" .or. Len(Alltrim(oPagtoRH:cPrinter)) > 3
			xPrntPdf := .F.
		EndIf

		P0041 := " IF   EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VW_"+RetSqlName("SRQ")+"]'))
		P0041 += " DROP VIEW [dbo].[VW_"+RetSqlName("SRQ")+"]
		TcSQLExec(P0041)

		P0044 := " CREATE VIEW [dbo].[VW_"+RetSqlName("SRQ")+"]
		P0044 += " AS
		P0044 += "   SELECT *
		P0044 += "     FROM (SELECT RQ_MAT,
		P0044 += "                  RQ_ORDEM,
		P0044 += "                  RQ_SEQUENC,
		P0044 += "                  RQ_CIC,
		P0044 += "                  RQ_NOME,
		P0044 += "                  RQ_BCDEPBE,
		P0044 += "                  RQ_CTDEPBE,
		P0044 += "                  RQ_VERBADT RQ_VERBA,
		P0044 += "                  RQ_YTIPCON
		P0044 += "             FROM "+RetSqlName("SRQ")
		P0044 += "            WHERE RQ_FILIAL = '"+xFilial("SRQ")+"'
		P0044 += "              AND RQ_DTFIM = '        '
		P0044 += "              AND D_E_L_E_T_ = ' '
		P0044 += "           UNION
		P0044 += "           SELECT RQ_MAT,
		P0044 += "                  RQ_ORDEM,
		P0044 += "                  RQ_SEQUENC,
		P0044 += "                  RQ_CIC,
		P0044 += "                  RQ_NOME,
		P0044 += "                  RQ_BCDEPBE,
		P0044 += "                  RQ_CTDEPBE,
		P0044 += "                  RQ_VERBFOL RQ_VERBA,
		P0044 += "                  RQ_YTIPCON
		P0044 += "             FROM "+RetSqlName("SRQ")
		P0044 += "            WHERE RQ_FILIAL = '"+xFilial("SRQ")+"'
		P0044 += "              AND RQ_DTFIM = '        '
		P0044 += "              AND D_E_L_E_T_ = ' '
		P0044 += "           UNION
		P0044 += "           SELECT RQ_MAT,
		P0044 += "                  RQ_ORDEM,
		P0044 += "                  RQ_SEQUENC,
		P0044 += "                  RQ_CIC,
		P0044 += "                  RQ_NOME,
		P0044 += "                  RQ_BCDEPBE,
		P0044 += "                  RQ_CTDEPBE,
		P0044 += "                  RQ_VERBFER RQ_VERBA,
		P0044 += "                  RQ_YTIPCON
		P0044 += "             FROM "+RetSqlName("SRQ")
		P0044 += "            WHERE RQ_FILIAL = '"+xFilial("SRQ")+"'
		P0044 += "              AND RQ_DTFIM = '        '
		P0044 += "              AND D_E_L_E_T_ = ' '
		P0044 += "           UNION
		P0044 += "           SELECT RQ_MAT,
		P0044 += "                  RQ_ORDEM,
		P0044 += "                  RQ_SEQUENC,
		P0044 += "                  RQ_CIC,
		P0044 += "                  RQ_NOME,
		P0044 += "                  RQ_BCDEPBE,
		P0044 += "                  RQ_CTDEPBE,
		P0044 += "                  RQ_VERB131 RQ_VERBA,
		P0044 += "                  RQ_YTIPCON
		P0044 += "             FROM "+RetSqlName("SRQ")
		P0044 += "            WHERE RQ_FILIAL = '"+xFilial("SRQ")+"'
		P0044 += "              AND RQ_DTFIM = '        '
		P0044 += "              AND D_E_L_E_T_ = ' '
		P0044 += "           UNION
		P0044 += "           SELECT RQ_MAT,
		P0044 += "                  RQ_ORDEM,
		P0044 += "                  RQ_SEQUENC,
		P0044 += "                  RQ_CIC,
		P0044 += "                  RQ_NOME,
		P0044 += "                  RQ_BCDEPBE,
		P0044 += "                  RQ_CTDEPBE,
		P0044 += "                  RQ_VERB132 RQ_VERBA,
		P0044 += "                  RQ_YTIPCON
		P0044 += "             FROM "+RetSqlName("SRQ")
		P0044 += "            WHERE RQ_FILIAL = '"+xFilial("SRQ")+"'
		P0044 += "              AND RQ_DTFIM = '        '
		P0044 += "              AND D_E_L_E_T_ = ' '
		P0044 += "           UNION
		P0044 += "           SELECT RQ_MAT,
		P0044 += "                  RQ_ORDEM,
		P0044 += "                  RQ_SEQUENC,
		P0044 += "                  RQ_CIC,
		P0044 += "                  RQ_NOME,
		P0044 += "                  RQ_BCDEPBE,
		P0044 += "                  RQ_CTDEPBE,
		P0044 += "                  RQ_VERBPLR RQ_VERBA,
		P0044 += "                  RQ_YTIPCON
		P0044 += "             FROM "+RetSqlName("SRQ")
		P0044 += "            WHERE RQ_FILIAL = '"+xFilial("SRQ")+"'
		P0044 += "              AND RQ_DTFIM = '        '
		P0044 += "              AND D_E_L_E_T_ = ' ') AS TAB
		P0044 += "    WHERE RQ_VERBA <> '   '
		TcSQLExec(P0044)

		P0048 := " SELECT RQ_MAT,
		P0048 += "        RQ_SEQUENC,
		P0048 += "        RQ_CIC,
		P0048 += "        RQ_NOME,
		P0048 += "        RQ_BCDEPBE,
		P0048 += "        RQ_CTDEPBE,
		P0048 += "        RA_NOME,
		P0048 += "        RA_CC,
		P0048 += "		  RQ_YTIPCON,
		If MV_PAR02 == 1
			P0048 += "        RC_CLVL CLVL,
			P0048 += "        RC_DATA RD_DATPGT,
			P0048 += "        SUM(RC_VALOR) RD_VALOR
		ElseIf MV_PAR02 == 2
			P0048 += "        RD_CLVL CLVL,
			P0048 += "        RD_DATPGT,
			P0048 += "        SUM(RD_VALOR) RD_VALOR
		ElseIf MV_PAR02 == 3
			P0048 += "        RI_CLVL CLVL,
			P0048 += "        RI_DATA RD_DATPGT,
			P0048 += "        SUM(RI_VALOR) RD_VALOR
		ElseIf MV_PAR02 == 4
			P0048 += "        RR_CLVL CLVL,
			P0048 += "        RR_DATA RD_DATPGT,
			P0048 += "        SUM(RR_VALOR) RD_VALOR
		EndIf
		P0048 += "   FROM VW_"+RetSqlName("SRQ")+" SRQ
		If MV_PAR02 == 1
			P0048 += "  INNER JOIN "+RetSqlName("SRC")+" SRC ON RC_FILIAL = '"+xFilial("SRC")+"'
			P0048 += "                       AND RC_MAT = RQ_MAT
			P0048 += "                       AND RC_PD = RQ_VERBA
			P0048 += "                       AND SRC.D_E_L_E_T_ = ' '
		ElseIf MV_PAR02 == 2
			P0048 += "  INNER JOIN "+RetSqlName("SRD")+" SRD ON RD_FILIAL = '"+xFilial("SRD")+"'
			P0048 += "                       AND RD_DATARQ = '"+MV_PAR01+"'
			P0048 += "                       AND RD_MAT = RQ_MAT
			P0048 += "                       AND RD_PD = RQ_VERBA
			P0048 += "                       AND SRD.D_E_L_E_T_ = ' '
		ElseIf MV_PAR02 == 3
			P0048 += "   INNER JOIN "+RetSqlName("SRI")+" SRI ON RI_FILIAL = '"+xFilial("SRI")+"'
			P0048 += "                        AND RI_MAT = RQ_MAT
			P0048 += "                        AND RI_PD = RQ_VERBA
			P0048 += "                        AND SRI.D_E_L_E_T_ = ' '
		ElseIf MV_PAR02 == 4
			P0048 += "   INNER JOIN "+RetSqlName("SRR")+" SRR ON RR_FILIAL = '"+xFilial("SRR")+"'
			P0048 += "                        AND SUBSTRING(RR_DATA,1,6) = '"+MV_PAR01+"'
			P0048 += "                        AND RR_MAT = RQ_MAT
			P0048 += "                        AND RR_PD = RQ_VERBA
			P0048 += "                        AND SRR.D_E_L_E_T_ = ' '
		EndIf
		P0048 += "  INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_FILIAL = '"+xFilial("SRV")+"'
		P0048 += "                       AND RV_COD = RQ_VERBA
		P0048 += "                       AND SRV.D_E_L_E_T_ = ' '
		P0048 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
		P0048 += "                       AND RA_MAT = RQ_MAT
		P0048 += "                       AND SRA.D_E_L_E_T_ = ' '
		P0048 += "  GROUP BY RQ_MAT,
		P0048 += "           RQ_SEQUENC,
		P0048 += "           RQ_CIC,
		P0048 += "           RQ_NOME,
		P0048 += "           RQ_BCDEPBE,
		P0048 += "           RQ_CTDEPBE,
		P0048 += "           RA_NOME,
		P0048 += "           RA_CC,
		P0048 += "           RQ_YTIPCON,
		If MV_PAR02 == 1
			P0048 += "           RC_CLVL,
			P0048 += "           RC_DATA
		ElseIf MV_PAR02 == 2
			P0048 += "           RD_CLVL,
			P0048 += "           RD_DATPGT
		ElseIf MV_PAR02 == 3
			P0048 += "           RI_CLVL,
			P0048 += "           RI_DATA
		ElseIf MV_PAR02 == 4
			P0048 += "           RR_CLVL,
			P0048 += "           RR_DATA
		EndIf
		P0048 := ChangeQuery(P0048)
		cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,P0048),'P048',.T.,.T.)
		dbSelectArea("P048")
		dbGoTop()
		xQdPag := 1
		xLnhOld := 0
		While !Eof()

			If xQdPag == 1

				oPagtoRH:StartPage()
				nHPage := oPagtoRH:nHorzRes()
				nHPage *= (300/PixelX)
				nHPage -= HMARGEM
				nVPage := oPagtoRH:nVertRes()
				nVPage *= (300/PixelY)
				nVPage -= VBOX
				nBaseTxt := 50
				nBaseCol := 50

			EndIf

			nLine  := xLnhOld
			nLine  += IIF(xPrntPdf, 220, 220)

			// O limite da Margem é nHPage - 270
			oPagtoRH:Box(nLine+000, nBaseCol, nLine+070, nHPage - 770, "-4")
			oPagtoRH:Say(nLine+055, nBaseTxt+300, Padc("AUTORIZAÇÃO DE PAGAMENTO",050) , oFont20n:oFont)
			If File(aBitmap)
				oPagtoRH:SayBitmap( nLine+005, nBaseCol+005, aBitmap, 0300, 0075 )
			EndIf

			oPagtoRH:Box(nLine+070, nBaseCol     , nLine+0102, nHPage - 1830, "-4")
			oPagtoRH:Say(nLine+095, nBaseTxt     , Padc("Revisão Anterior: 27/06/2012",080)     , oFont08n:oFont)
			oPagtoRH:Box(nLine+070, nHPage - 1830, nLine+0102, nHPage - 1260, "-4")
			oPagtoRH:Say(nLine+095, nHPage - 1830, Padc("Revisão Atual: 27/06/2012",095)        , oFont08n:oFont)
			oPagtoRH:Box(nLine+070, nHPage - 1260, nLine+0102, nHPage - 0770, "-4")
			oPagtoRH:Say(nLine+095, nHPage - 1260, Padc("Revisão: 00",090)                      , oFont08n:oFont)
			oPagtoRH:Box(nLine+000, nHPage - 0770, nLine+100, nHPage - 270, "-4")
			oPagtoRH:Say(nLine+065, nHPage - 0770, Padc("BG-FO-CPT-03",040)                     , oFont15n:oFont)

			oPagtoRH:Say(nLine+180, nBaseTxt+0020, "De: SETOR DE PESSOAL"                       , oFont15n:oFont)
			oPagtoRH:Say(nLine+250, nBaseTxt+0020, "Para: CONTAS A PAGAR"                       , oFont15n:oFont)
			oPagtoRH:Say(nLine+180, nHPage - 850, "Classe de Valor: "+Alltrim(P048->CLVL)       , oFont15n:oFont)
			oPagtoRH:Say(nLine+250, nHPage - 850, "Centro de Custo: "+Alltrim(P048->RA_CC)      , oFont15n:oFont)

			nLine += 250
			nLine += 100
			oPagtoRH:Say(nLine    , nBaseTxt+0020, "Vencimento: " + dtoc(DataValida(stod(P048->RD_DATPGT)-1,.F.))                                  , oFont15n:oFont)
			nLine += 050
			oPagtoRH:Say(nLine    , nBaseTxt+0020, "Valor: " + Transform(P048->RD_VALOR,"999,999,999.99")                                          , oFont15n:oFont)
			nLine += 050
			oPagtoRH:Say(nLine    , nBaseTxt+0020, Substr(RTrim(Substr(Extenso(P048->RD_VALOR),   1, 120)) + " " + Replicate("X",120), 1, 120)     , oFntEx12:oFont)
			nLine += 050
			oPagtoRH:Say(nLine    , nBaseTxt+0020, Substr(RTrim(Substr(Extenso(P048->RD_VALOR), 121, 120)) + " " + Replicate("X",120), 1, 120)     , oFntEx12:oFont)

			nLine += 100
			oPagtoRH:Say(nLine    , nBaseTxt+0020, "Favorecido: " + P048->RQ_NOME                                                                  , oFont12n:oFont)
			nLine += 050
			oPagtoRH:Say(nLine    , nBaseTxt+0020, "CPF: " + P048->RQ_CIC                                                                          , oFont12n:oFont)
			nLine += 050
			nNomeBco := Alltrim(Posicione("SA6", 1, xFilial("SA6")+P048->RQ_BCDEPBE, "A6_NOME"))
			oPagtoRH:Say(nLine    , nBaseTxt+0020, "Banco:   " + Substr(P048->RQ_BCDEPBE,1,3)+"  -  " + nNomeBco                                   , oFont12n:oFont)
			nLine += 050
			oPagtoRH:Say(nLine    , nBaseTxt+0020, "Agência: " + Substr(P048->RQ_BCDEPBE,4,5)                                                      , oFont12n:oFont)
			nLine += 050

			// Carlos Junqueira - 08/05/2014
			If P048->RQ_YTIPCON == '1'
				oPagtoRH:Say(nLine    , nBaseTxt+0020, "Conta Corrente: "+ P048->RQ_CTDEPBE                                                        , oFont12n:oFont)
			Elseif P048->RQ_YTIPCON == '2'
				oPagtoRH:Say(nLine    , nBaseTxt+0020, "Conta Poupança: "+ P048->RQ_CTDEPBE    		                                               , oFont12n:oFont)
			Else
				oPagtoRH:Say(nLine    , nBaseTxt+0020, "Conta: "+ P048->RQ_CTDEPBE                                                                 , oFont12n:oFont)
			EndIf

			xf_Ref := "Pagamento Pensão Alimentícia do colaborador "+Alltrim(P048->RA_NOME)+" referênte pagamento do mês de "+MesExtenso(Substr(MV_PAR01,5,2))+"/"+Substr(MV_PAR01,1,4)+"."
			nLine += 100
			oPagtoRH:Say(nLine    , nBaseTxt+0020, "Referência: " + Substr(xf_Ref, 1, 120)                                                         , oFont12n:oFont)
			nLine += 050
			oPagtoRH:Say(nLine    , nBaseTxt+0020, Substr(xf_Ref, 121, 120)                                                                        , oFont12n:oFont)

			nLine += 100
			oPagtoRH:Line (nLine, nBaseCol, nLine, 1000)
			oPagtoRH:Say(nLine-05 , nBaseCol+1700, Padc(dtoc(UltimoDia(stod(MV_PAR01+"01"))),11)                                                   , oFont12n:oFont)

			nLine += 050
			oPagtoRH:Say(nLine    , nBaseCol     , Padc("Assinatura Autorizada",110)                                                               , oFont12n:oFont)
			oPagtoRH:Say(nLine    , nBaseCol+1700, Padc("Data",11)                                                                                 , oFont12n:oFont)

			If xQdPag == 1

				xQdPag  := 2
				xLnhOld := nLine + 30

			Else

				xQdPag := 1
				xLnhOld := 0
				oPagtoRH:EndPage()

			EndIf

			dbSelectArea("P048")
			dbSkip()
		End

		Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(cIndex+OrdBagExt())          //indice gerado
		P048->(dbCloseArea())

		oPagtoRH:EndPage()
		oPagtoRH:Preview()

	EndIf

	FreeObj(oPagtoRH)
	oPagtoRH := Nil
	RestArea(aArea)

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
	aAdd(aRegs,{cPerg,"01","Ano/Mes de Referencia ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Lançamentos           ?","","","mv_ch2","N",01,0,0,"C","","mv_par02","Mensais","","","","","Acumulados","","","","","Seg. Parc 13","","","","","Férias","","","","","","","","",""})
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
