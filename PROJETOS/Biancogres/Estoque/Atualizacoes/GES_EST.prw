#include "rwMake.ch"
#include "Topconn.ch"

/*/{Protheus.doc} GES_EST
@author BRUNO MADALENO
@since 15/09/05
@version 1.0
@description Relatorio em Crystal para gerar os produtos em situacao de compra
@author Marcos Alberto Soprani
@obs Em 07/03/17... Ajustes na rotina para atender ao Projeto Buy Now
@type function
/*/

User Function GES_EST()

	Private Enter := CHR(13)+CHR(10)
	Private cSQL

	lEnd       := .F.
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Gestão de Estoque"
	cTamanho   := ""
	limite     := 80
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "GESEST"
	cPerg      := "GESEST"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "GESTÃO DE ESTOQUE"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1
	wnrel      := "GESEST"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t.

	pergunte(cPerg,.F.)
	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	lComum := Iif(MV_PAR01==1,"N","S")

	If lComum == "S"
		MsgInfo("Atenção, a opção do produto comum não esta mais habilitada.")
		Return()
	EndIf

	//*************************************************************************
	//View para trazer as informacoes do processo e os produtos que o pertence
	//*************************************************************************
	cSQL := "ALTER VIEW VW_GEST_EST AS 																				" + Enter
	cSQL += "SELECT * FROM (	" + Enter

	// Tiago Rossini Coradini - Facile - 08/12/2015 - Alteração de produto comum - Solicitação enviada por e-mail pelo Wanisay
	If lComum == "N"
		cSQL += "SELECT SB1.B1_COD, SUM(SB2.B2_QATU) B2_QATU,  MAX(SBZ.BZ_EMIN) BZ_EMIN, " + Enter
	Else
		cSQL += "SELECT SB1.B1_COD, SB2.B2_QATU, SBZ.BZ_EMIN, " + Enter
	EndIf

	// Tiago Rossini Coradini - Facile - 17/04/2015
	// Produto COMUM = SIM
	// Inseri colunas de ponto de pedido para as empresas Biancogres (Almoxarifado '6B'), Incesa (Almoxarifado '6I') e VITCER (Almoxarifado '6V') (Tabela SBZ).
	If lComum == "S"

		cSQL += " ISNULL((SELECT BZ_EMIN FROM SBZ010 WHERE BZ_COD = SBZ.BZ_COD AND BZ_YPOLIT = SBZ.BZ_YPOLIT AND BZ_YCOMUM = SBZ.BZ_YCOMUM AND BZ_YMD = SBZ.BZ_YMD AND D_E_L_E_T_ = ''),0) AS PP6B, " + Enter
		cSQL += "	ISNULL((SELECT BZ_EMIN FROM SBZ050 WHERE BZ_COD = SBZ.BZ_COD AND BZ_YPOLIT = SBZ.BZ_YPOLIT AND BZ_YCOMUM = SBZ.BZ_YCOMUM AND BZ_YMD = SBZ.BZ_YMD AND D_E_L_E_T_ = ''),0) AS PP6I, " + Enter
		cSQL += "	ISNULL((SELECT BZ_EMIN FROM SBZ140 WHERE BZ_COD = SBZ.BZ_COD AND BZ_YPOLIT = SBZ.BZ_YPOLIT AND BZ_YCOMUM = SBZ.BZ_YCOMUM AND BZ_YMD = SBZ.BZ_YMD AND D_E_L_E_T_ = ''),0) AS PP6V, " + Enter

	Else

		cSQL += " 0 AS PP6B, " + Enter
		cSQL += "	0 AS PP6I, " + Enter
		cSQL += "	0 AS PP6V, " + Enter

	EndIf

	cSQL += "		SB1.B1_GRUPO, SBM.BM_DESC, SBZ.BZ_ESTSEG, SB1.B1_DESC, 	" + Enter
	cSQL += "		MAX(ISNULL(SB3.B3_Q01,0)) AS B3_Q01, MAX(ISNULL(SB3.B3_Q02,0)) AS B3_Q02, MAX(ISNULL(SB3.B3_Q03,0)) AS B3_Q03, MAX(ISNULL(SB3.B3_Q04,0)) AS B3_Q04, " + Enter
	cSQL += "		MAX(ISNULL(SB3.B3_Q05,0)) AS B3_Q05, MAX(ISNULL(SB3.B3_Q06,0)) AS B3_Q06, MAX(ISNULL(SB3.B3_Q07,0)) AS B3_Q07, MAX(ISNULL(SB3.B3_Q08,0)) AS B3_Q08, " + Enter
	cSQL += "		MAX(ISNULL(SB3.B3_Q09,0)) AS B3_Q09, MAX(ISNULL(SB3.B3_Q10,0)) AS B3_Q10, MAX(ISNULL(SB3.B3_Q11,0)) AS B3_Q11, MAX(ISNULL(SB3.B3_Q12,0)) AS B3_Q12, " + Enter

	// Tiago Rossini Coradini - Facile - 08/12/2015 - Alteração de produto comum - Solicitação enviada por e-mail pelo Wanisay
	If lComum == "N"	                                                                                                                         
		cSQL += "	SB1.B1_TIPO, SB1.B1_COD AS B2_COD, '01' AS B1_LOCPAD, '' AS BZ_YPOLIT, " + Enter
	Else
		cSQL += "	SB1.B1_TIPO, SB2.B2_COD, SB1.B1_LOCPAD, SBZ.BZ_YPOLIT, " + Enter
	EndIf

	cSQL += "		(SELECT ISNULL(SUM(C7_QUANT - C7_QUJE),0) AS QUANT_SC7 FROM "+RETSQLNAME("SC7")+"   " + Enter
	cSQL += "		 WHERE C7_PRODUTO = SB1.B1_COD AND C7_QUANT <> C7_QUJE AND C7_RESIDUO = '' AND C7_ENCER <> 'E' AND D_E_L_E_T_ = '') AS B2_SALPEDI,	" + Enter
	cSQL += "		(SELECT ISNULL(SUM(C1_QUANT - C1_QUJE),0) AS QUANT_SC1 FROM "+RETSQLNAME("SC1")+"   " + Enter
	cSQL += "		 WHERE C1_PRODUTO = SB1.B1_COD AND C1_QUANT <> C1_QUJE AND C1_PEDIDO = ' ' AND C1_APROV <> 'R' AND C1_YMAT = '' AND D_E_L_E_T_ = '') AS C1_QUANT,	" + Enter

	cSQL += "		(SELECT SUM(QUANT_1) - SUM(QUANT_2) AS QUANT FROM  												" + Enter
	cSQL += "				(SELECT ISNULL(SUM(D3_QUANT),0) AS QUANT_1, 0 AS QUANT_2 FROM "+RETSQLNAME("SD3")+" 	" + Enter
	cSQL += "				WHERE	D3_FILIAL = '"+xFilial("SD3")+"' AND D3_TM > '500' AND  						" + Enter
	cSQL += "						SUBSTRING(D3_EMISSAO,1,6) = SUBSTRING(CONVERT(VARCHAR(8),GETDATE(),112),1,6)	" + Enter
	cSQL += "						AND D3_COD = SB1.B1_COD AND D_E_L_E_T_ = '' 									" + Enter
	cSQL += "				UNION  																					" + Enter
	cSQL += "				SELECT	0 AS QUANT_1, ISNULL(SUM(D3_QUANT),0) AS QUANT_2 FROM "+RETSQLNAME("SD3")+" 	" + Enter
	cSQL += "				WHERE	D3_FILIAL = '"+xFilial("SD3")+"' AND D3_TM < '500' AND							" + Enter
	cSQL += "						SUBSTRING(D3_EMISSAO,1,6) = SUBSTRING(CONVERT(VARCHAR(8),GETDATE(),112),1,6) 	" + Enter
	cSQL += "						AND D3_COD = SB1.B1_COD  AND D_E_L_E_T_ = '' ) AS TESTE ) AS ATUAL 				" + Enter

	If lComum == "N"

		//11/02/2016 - ALTERAÇÃO DE MODIFICAÇÃO DOS SELECTS, INCLUINDO JOINS - LUANA MARIN RIBEIRO
		cSQL += "FROM   SB1010 SB1 " + Enter
		cSQL += "		INNER JOIN " + RETSQLNAME("SB2") + " SB2 " + Enter
		cSQL += "			ON SB1.B1_COD	=  SB2.B2_COD 	AND " + Enter
		// Tiago Rossini Coradini - Facile - 08/12/2015 - Alteração de produto comum - Solicitação enviada por e-mail pelo Wanisay
		If cEmpAnt == "01"
			cSQL += "				SB2.B2_LOCAL IN ('01', '6B') AND " + Enter
		ElseIf cEmpAnt == "05"
			cSQL += "				SB2.B2_LOCAL IN ('01', '6I') AND " + Enter
		Else
			cSQL += "				SB1.B1_LOCPAD	= SB2.B2_LOCAL AND " + Enter
		EndIf
		cSQL += "				SB2.D_E_L_E_T_	=  '' " + Enter
		cSQL += "		INNER JOIN " + RETSQLNAME("SBZ") + " SBZ " + Enter
		cSQL += "			ON SB1.B1_COD		=  SBZ.BZ_COD  	AND " + Enter
		cSQL += "				SBZ.BZ_YPOLIT	=  '1' 			AND " + Enter
		cSQL += "				SBZ.BZ_YMD		<> 'S'			AND " + Enter
		cSQL += "				SBZ.D_E_L_E_T_	=  '' " + Enter
		cSQL += "		INNER JOIN SBM010 SBM " + Enter
		cSQL += "			ON SB1.B1_GRUPO = SBM.BM_GRUPO " + Enter
		cSQL += "		LEFT JOIN " + RETSQLNAME("SB3") + " SB3 " + Enter
		cSQL += "			ON SB1.B1_COD		= SB3.B3_COD 	AND " + Enter
		cSQL += "				SB3.B3_FILIAL   = '"+xFilial("SB3")+"' AND " + Enter
		cSQL += "				SB3.D_E_L_E_T_	=  '' " + Enter

	Else
		cSQL += "FROM   SB1010 SB1 " + Enter
		cSQL += "		INNER JOIN (SELECT B2_COD, SUM(B2_QATU) B2_QATU, D_E_L_E_T_	" + Enter
		cSQL += "				FROM " + Enter
		cSQL += "					(SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2010 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL IN ('6B', '6I', '6V') AND D_E_L_E_T_ = '' " + Enter
		cSQL += "					UNION ALL																									" + Enter
		cSQL += "					 SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2050 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '6I' AND D_E_L_E_T_ = '' " + Enter

		// Tiago Rossini Coradini - Facile - 17/04/2015
		cSQL += "					UNION ALL																									" + Enter
		cSQL += "					 SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2140 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '6V' AND D_E_L_E_T_ = '') SALDO	" + Enter	
		cSQL += "				GROUP BY B2_COD, D_E_L_E_T_) SB2 " + Enter                                                                                     
		cSQL += "			ON SB1.B1_COD	=  SB2.B2_COD 	AND " + Enter
		cSQL += "				SB2.D_E_L_E_T_	=  '' " + Enter

		// Tiago Rossini Coradini - Facile - 05/05/2015
		cSQL += "		INNER JOIN ( " + Enter
		cSQL += "				SELECT BZ_COD, SUM(BZ_EMIN) AS BZ_EMIN, SUM(BZ_ESTSEG) AS BZ_ESTSEG, BZ_YPOLIT, BZ_YCOMUM, BZ_YMD, D_E_L_E_T_ " + Enter
		cSQL += "				FROM " + Enter
		cSQL += "				( " + Enter
		cSQL += "					SELECT BZ_COD, ISNULL(BZ_EMIN,0) AS BZ_EMIN, ISNULL(BZ_ESTSEG,0) AS BZ_ESTSEG, BZ_YPOLIT, BZ_YCOMUM, BZ_YMD, D_E_L_E_T_ " + Enter
		cSQL += "					FROM SBZ010 " + Enter
		cSQL += "					UNION ALL " + Enter
		cSQL += "					SELECT BZ_COD, ISNULL(BZ_EMIN,0) AS BZ_EMIN, ISNULL(BZ_ESTSEG,0) AS BZ_ESTSEG, BZ_YPOLIT, BZ_YCOMUM, BZ_YMD, D_E_L_E_T_ " + Enter
		cSQL += "					FROM SBZ050 " + Enter
		cSQL += "					UNION ALL " + Enter
		cSQL += "					SELECT BZ_COD, ISNULL(BZ_EMIN,0) AS BZ_EMIN, ISNULL(BZ_ESTSEG,0) AS BZ_ESTSEG, BZ_YPOLIT, BZ_YCOMUM, BZ_YMD, D_E_L_E_T_ " + Enter
		cSQL += "					FROM SBZ140 " + Enter
		cSQL += "				) SBZ_TMP " + Enter
		cSQL += "				GROUP BY BZ_COD, BZ_YPOLIT, BZ_YCOMUM, BZ_YMD, D_E_L_E_T_ " + Enter
		cSQL += "				) SBZ " + Enter
		SQL += "			ON SB1.B1_COD		=  SBZ.BZ_COD  	AND " + Enter
		cSQL += "				SBZ.BZ_YPOLIT	=  '1' 			AND " + Enter
		cSQL += "				SBZ.BZ_YMD		<> 'S'			AND " + Enter
		cSQL += "				SBZ.D_E_L_E_T_	=  '' " + Enter

		cSQL += "		INNER JOIN SBM010 SBM " + Enter
		cSQL += "			ON SB1.B1_GRUPO = SBM.BM_GRUPO " + Enter

		cSQL += "		LEFT JOIN (  " + Enter
		cSQL += "				SELECT B3_FILIAL, B3_COD, SUM(B3_Q01) B3_Q01, SUM(B3_Q02) AS B3_Q02, SUM(B3_Q03) AS B3_Q03, SUM(B3_Q04) AS B3_Q04,  " + Enter
		cSQL += "				SUM(B3_Q05) AS B3_Q05, SUM(B3_Q06) AS B3_Q06, SUM(B3_Q07) AS B3_Q07, SUM(B3_Q08) AS B3_Q08,  " + Enter
		cSQL += "				SUM(B3_Q09) AS B3_Q09, SUM(B3_Q10) AS B3_Q10, SUM(B3_Q11) AS B3_Q11, SUM(B3_Q12) AS B3_Q12, D_E_L_E_T_ " + Enter
		cSQL += "				FROM " + Enter
		cSQL += "				( " + Enter
		cSQL += "					SELECT B3_FILIAL, B3_COD, ISNULL(B3_Q01,0) AS B3_Q01, ISNULL(B3_Q02,0) AS B3_Q02, ISNULL(B3_Q03,0) AS B3_Q03, ISNULL(B3_Q04,0) AS B3_Q04,  " + Enter
		cSQL += "					ISNULL(B3_Q05,0) AS B3_Q05, ISNULL(B3_Q06,0) AS B3_Q06, ISNULL(B3_Q07,0) AS B3_Q07, ISNULL(B3_Q08,0) AS B3_Q08,  " + Enter
		cSQL += "					ISNULL(B3_Q09,0) AS B3_Q09, ISNULL(B3_Q10,0) AS B3_Q10, ISNULL(B3_Q11,0) AS B3_Q11, ISNULL(B3_Q12,0) AS B3_Q12, D_E_L_E_T_ " + Enter
		cSQL += "					FROM SB3010 " + Enter
		cSQL += "					UNION ALL " + Enter
		cSQL += "					SELECT B3_FILIAL, B3_COD, ISNULL(B3_Q01,0) AS B3_Q01, ISNULL(B3_Q02,0) AS B3_Q02, ISNULL(B3_Q03,0) AS B3_Q03, ISNULL(B3_Q04,0) AS B3_Q04,  " + Enter
		cSQL += "					ISNULL(B3_Q05,0) AS B3_Q05, ISNULL(B3_Q06,0) AS B3_Q06, ISNULL(B3_Q07,0) AS B3_Q07, ISNULL(B3_Q08,0) AS B3_Q08,  " + Enter
		cSQL += "					ISNULL(B3_Q09,0) AS B3_Q09, ISNULL(B3_Q10,0) AS B3_Q10, ISNULL(B3_Q11,0) AS B3_Q11, ISNULL(B3_Q12,0) AS B3_Q12, D_E_L_E_T_ " + Enter
		cSQL += "					FROM SB3050 " + Enter
		cSQL += "					UNION ALL " + Enter
		cSQL += "					SELECT B3_FILIAL, B3_COD, ISNULL(B3_Q01,0) AS B3_Q01, ISNULL(B3_Q02,0) AS B3_Q02, ISNULL(B3_Q03,0) AS B3_Q03, ISNULL(B3_Q04,0) AS B3_Q04, " + Enter
		cSQL += "					ISNULL(B3_Q05,0) AS B3_Q05, ISNULL(B3_Q06,0) AS B3_Q06, ISNULL(B3_Q07,0) AS B3_Q07, ISNULL(B3_Q08,0) AS B3_Q08, " + Enter
		cSQL += "					ISNULL(B3_Q09,0) AS B3_Q09, ISNULL(B3_Q10,0) AS B3_Q10, ISNULL(B3_Q11,0) AS B3_Q11, ISNULL(B3_Q12,0) AS B3_Q12, D_E_L_E_T_ " + Enter
		cSQL += "					FROM SB3140 " + Enter
		cSQL += "				) SB3_TMP " + Enter
		cSQL += "				GROUP BY B3_FILIAL, B3_COD, D_E_L_E_T_ " + Enter
		cSQL += "				) AS SB3 " + Enter	
		cSQL += "			ON SB1.B1_COD		= SB3.B3_COD 	AND " + Enter
		cSQL += "				SB3.B3_FILIAL   = '"+xFilial("SB3")+"' AND " + Enter
		cSQL += "				SB3.D_E_L_E_T_	=  '' " + Enter

	EndIf

	cSQL += "WHERE		SB1.B1_FILIAL   = '"+xFilial("SB1")+"' AND " + Enter
	cSQL += "			SB1.B1_TIPO		IN ('MC','ME','MD','OI')	AND		" + Enter
	cSQL += "			SUBSTRING(SB1.B1_COD,4,4) <> '0000' AND " + Enter
	cSQL += "			SB1.B1_GRUPO	BETWEEN  '"+MV_PAR02+"'	AND '"+MV_PAR03+"'	AND	" + Enter

	//O filtro abaixo de produto ativo foi retornado conforme OS 0869-16
	//cSQL += "			SB1.B1_ATIVO  = 'S'  AND 					" + Enter
	//Inserido por Wanisay em 28/03/16 conforme OS 1363-16        
	cSQL += "			SBZ.BZ_YATIVO <> 'N' AND 					" + Enter

	//cSQL += "			SB1.B1_TIPO		IN ('MC','ME')	AND		" + Enter
	// Tiago Rossini Coradini - 23/12/2015 - Filtro de produto importado - Solicitação enviada pelo Wanisay por e-mail
	If MV_PAR05 == 1
		cSQL += " SB1.B1_IMPORT	= 'S' AND " + Enter
	Else
		cSQL += " SB1.B1_IMPORT	<> 'S' AND " + Enter
	EndIf
	cSQL += "			SB1.D_E_L_E_T_	=  '' " + Enter

	// Tiago Rossini Coradini - Facile - 08/12/2015 - Alteração de produto comum - Solicitação enviada por e-mail pelo Wanisay
	If lComum == "N"
		cSQL += " GROUP BY SB1.B1_COD, B1_GRUPO, BM_DESC, BZ_ESTSEG, B1_DESC, B1_TIPO " + Enter
	EndIf

	cSQL += " ) AS TMP		" + Enter

	IF MV_PAR04 == 2
		cSQL += "	WHERE		" + Enter
		cSQL += " B2_QATU+B2_SALPEDI+C1_QUANT < BZ_ESTSEG " + Enter
	ENDIF

	TcSQLExec(cSQL)

	If aReturn[5]==1
		//Parametros Crystal Em Disco
		Private cOpcao:="1;0;1;Apuracao"
	Else
		//Direto Impressora
		Private cOpcao:="3;0;1;Apuracao"
	Endif

	// Tiago Rossini Coradini - Facile - 17/04/2015
	If lComum == "S"
		CallCrys("GesEstComum",lComum+";"+cEmpAnt,cOpcao)
	Else			
		CallCrys("GesEst",lComum+";"+cEmpAnt,cOpcao)
	EndIf

Return
