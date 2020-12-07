#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGES_TRANSF      บAutor  ณRanisses A. Corona  บ Data ณ  18/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio em Crystal para gerar os produtos em situacao de compra.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEstoque                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GES_TRANSF()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private Enter := CHR(13)+CHR(10)
Private cSQL
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Gestใo de Transferencia"
cTamanho   := ""
limite     := 80
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "GESTRA"
cPerg      := "GESTRA"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "GESTรO DE TRANSFERสNCIA"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1
wnrel      := "GESTRA"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT.								     ณ
//ณ Verifica Posicao do Formulario na Impressora.				       ณ
//ณ Solicita os parametros para a emissao do relatorio			   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
//Cancela a impressao
If nLastKey == 27
	Return
Endif

If !cEmpAnt $ "05/14" 
	MsgAlert("Este relat๓rio poderแ ser emitido apenas nas empresas Incesa/Vitcer!")
	Return
EndIf

//*************************************************************************
//*************************************************************************
//View para trazer as informacoes do processo e os produtos que o pertence
//*************************************************************************
//*************************************************************************
//cSQL := "ALTER VIEW VW_GEST_TRANSF AS		" + Enter
//cSQL += "SELECT * FROM (								" + Enter
//cSQL += "SELECT SB1.B1_COD, SB2.B2_QATU, SBZ.BZ_EMIN, SB1.B1_GRUPO, SBM.BM_DESC, SBZ.BZ_ESTSEG, SB1.B1_DESC, 	" + Enter
//cSQL += "		(SELECT SUM(B2_QATU) QUANT FROM SB2010 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '6B' AND D_E_L_E_T_ = '') SALDO_6B, " + Enter
//cSQL += "		(SELECT MAX(BZ_YLOCAL) LOCAL  FROM SBZ010 WHERE BZ_FILIAL = '"+xFilial("SBZ")+"' AND BZ_COD = SB1.B1_COD AND D_E_L_E_T_ = '') LOCAL_6B, " + Enter
//cSQL += "		ISNULL(SB3.B3_Q01,0) AS B3_Q01, ISNULL(SB3.B3_Q02,0) AS B3_Q02, ISNULL(SB3.B3_Q03,0) AS B3_Q03, ISNULL(SB3.B3_Q04,0) AS B3_Q04, " + Enter
//cSQL += "		ISNULL(SB3.B3_Q05,0) AS B3_Q05, ISNULL(SB3.B3_Q06,0) AS B3_Q06, ISNULL(SB3.B3_Q07,0) AS B3_Q07, ISNULL(SB3.B3_Q08,0) AS B3_Q08, " + Enter
//cSQL += "		ISNULL(SB3.B3_Q09,0) AS B3_Q09, ISNULL(SB3.B3_Q10,0) AS B3_Q10, ISNULL(SB3.B3_Q11,0) AS B3_Q11, ISNULL(SB3.B3_Q12,0) AS B3_Q12, " + Enter
//cSQL += "		SB1.B1_TIPO, SB2.B2_COD, B2_LOCAL AS B1_LOCPAD, SBZ.BZ_YPOLIT, " + Enter
//// Tiago Rossini Coradini - Saldo em pedido somente da empresa Bianco
//cSQL += "		(SELECT ISNULL(SUM(C7_QUANT - C7_QUJE),0) AS QUANT_SC7 FROM SC7010 " + Enter
////cSQL += "		 WHERE C7_PRODUTO = SB1.B1_COD AND C7_QUANT <> C7_QUJE AND C7_RESIDUO <> 'S' AND C7_CONAPRO = 'L' AND C7_ENCER <> 'E' AND D_E_L_E_T_ = '') AS B2_SALPEDI,	" + Enter
//cSQL += "		 WHERE C7_PRODUTO = SB1.B1_COD AND C7_QUANT <> C7_QUJE AND C7_RESIDUO = '' AND C7_ENCER <> 'E' AND D_E_L_E_T_ = '') AS B2_SALPEDI,	" + Enter

//// Tiago Rossini Coradini - Saldo em solicita็ใo somente da empresa Bianco
//cSQL += "		(SELECT ISNULL(SUM(C1_QUANT - C1_QUJE),0) AS QUANT_SC1 FROM SC1010 " + Enter
////cSQL += "		 WHERE C1_PRODUTO = SB1.B1_COD AND C1_QUANT <> C1_QUJE AND C1_PEDIDO = ' ' AND C1_APROV NOT IN ('B','R') AND D_E_L_E_T_ = '') AS C1_QUANT,	" + Enter
//cSQL += "		 WHERE C1_PRODUTO = SB1.B1_COD AND C1_QUANT <> C1_QUJE AND C1_PEDIDO = ' ' AND C1_APROV <> 'R' AND C1_YMAT = '' AND D_E_L_E_T_ = '') AS C1_QUANT,	" + Enter

//cSQL += "		(SELECT SUM(QUANT_1) - SUM(QUANT_2) AS QUANT FROM  												" + Enter
//cSQL += "				(SELECT ISNULL(SUM(D3_QUANT),0) AS QUANT_1, 0 AS QUANT_2 FROM "+RETSQLNAME("SD3")+" 	" + Enter
//cSQL += "				WHERE	D3_FILIAL = '"+xFilial("SD3")+"' AND D3_TM > '500' AND  						" + Enter
//cSQL += "						SUBSTRING(D3_EMISSAO,1,6) = SUBSTRING(CONVERT(VARCHAR(8),GETDATE(),112),1,6)	" + Enter
//cSQL += "						AND D3_COD = SB1.B1_COD AND D_E_L_E_T_ = '' 									" + Enter
//cSQL += "				UNION  																					" + Enter
//cSQL += "				SELECT	0 AS QUANT_1, ISNULL(SUM(D3_QUANT),0) AS QUANT_2 FROM "+RETSQLNAME("SD3")+" 	" + Enter
//cSQL += "				WHERE	D3_FILIAL = '"+xFilial("SD3")+"' AND D3_TM < '500' AND							" + Enter
//cSQL += "						SUBSTRING(D3_EMISSAO,1,6) = SUBSTRING(CONVERT(VARCHAR(8),GETDATE(),112),1,6) 	" + Enter
//cSQL += "						AND D3_COD = SB1.B1_COD  AND D_E_L_E_T_ = '' ) AS TESTE ) AS ATUAL 				" + Enter
//cSQL += "FROM   SB1010 SB1,																										" + Enter
//cSQL += "				(SELECT B2_COD, B2_LOCAL, SUM(B2_QATU) B2_QATU, D_E_L_E_T_							" + Enter
//cSQL += "				FROM 																													" + Enter

//If cEmpAnt == "05"
//	cSQL += "					(SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2010 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '6I' AND D_E_L_E_T_ = '' " + Enter
//	cSQL += "					UNION ALL																										" + Enter
//	cSQL += "					 SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2050 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '6I' AND D_E_L_E_T_ = '') WWW			" + Enter
//ElseIf cEmpAnt == "14"
//	cSQL += "					(SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2010 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '6V' AND D_E_L_E_T_ = '' " + Enter
//	cSQL += "					UNION ALL																										" + Enter
//	cSQL += "					 SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2140 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '6V' AND D_E_L_E_T_ = '') WWW			" + Enter
//EndIf

//cSQL += "				GROUP BY B2_COD, B2_LOCAL, D_E_L_E_T_) SB2,															" + Enter
//cSQL += " "+RETSQLNAME("SBZ")+" SBZ, SBM010 SBM, "+RETSQLNAME("SB3")+" SB3		" + Enter
//cSQL += "WHERE		SB1.B1_FILIAL   = '"+xFilial("SB1")+"' AND " + Enter
//cSQL += "			SB3.B3_FILIAL   = '"+xFilial("SB3")+"' AND " + Enter
//cSQL += "			SB1.B1_COD		=  SB2.B2_COD 	AND		" + Enter
////cSQL += "			SB1.B1_LOCPAD	=  SB2.B2_LOCAL AND		" + Enter
//cSQL += "			SBM.BM_GRUPO	=  SB1.B1_GRUPO AND		" + Enter
//cSQL += "			SB1.B1_COD		*= SB3.B3_COD 	AND		" + Enter 
//cSQL += "			SB1.B1_COD		=  SBZ.BZ_COD  	AND		" + Enter
//cSQL += "			SBZ.BZ_YPOLIT	=  '1' 			AND		" + Enter
//cSQL += "			SB1.B1_ATIVO = 'S' AND 					" + Enter
//cSQL += "			SUBSTRING(SB1.B1_COD,4,4) <> '0000' AND " + Enter
////cSQL += "			SB1.B1_TIPO		IN ('MC','ME')	AND		" + Enter
//cSQL += "			SB1.B1_TIPO		IN ('MC','ME','MD','OI')	AND		" + Enter
//cSQL += "			SBZ.BZ_YMD		<> 'S'	AND	" + Enter
//cSQL += "			SBZ.BZ_YCOMUM =  'S'	AND	" + Enter
//cSQL += "			(SB2.B2_QATU <= SBZ.BZ_EMIN) AND " + Enter
//cSQL += "			SB2.D_E_L_E_T_	=  '' AND  				" + Enter
//cSQL += "			SB1.D_E_L_E_T_	=  '' AND 				" + Enter 
//cSQL += "			SBZ.D_E_L_E_T_	=  '' AND 				" + Enter
//cSQL += "			SB3.D_E_L_E_T_	=  '' ) AS TMP		" + Enter
////cSQL += "	WHERE		" + Enter  				//COMENTEI ESSA LINHA TAMBษM PARA CORRIGIR O ERRO, PORษM NรO SEI PQ FOI RETIRADO O FILTRO // EM 12/08/15 RANISSES OS 3191-15
////cSQL += " B2_SALPEDI+C1_QUANT = 0 " + Enter	//ESSA LINHA ESTAVA COMENTADA GERANDO ERRO NO RELATำRIO / EM 12/08/15 RANISSES




//ATUALIZAวรO QUERY - SQL ATUAL - 05/10/2015
cSQL := "ALTER VIEW VW_GEST_TRANSF AS " + Enter
cSQL += "SELECT * FROM ( " + Enter
cSQL += "SELECT SB1.B1_COD, SB2.B2_QATU, SBZ.BZ_EMIN, SB1.B1_GRUPO, SBM.BM_DESC, SBZ.BZ_ESTSEG, SB1.B1_DESC, 	" + Enter
cSQL += "		(SELECT SUM(B2_QATU) QUANT FROM SB2010 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_COD = SB1.B1_COD AND B2_LOCAL = '6B' AND D_E_L_E_T_ = '') SALDO_6B, " + Enter
cSQL += "		(SELECT MAX(BZ_YLOCAL) LOCAL  FROM SBZ010 WHERE BZ_FILIAL = '"+xFilial("SBZ")+"' AND BZ_COD = SB1.B1_COD AND D_E_L_E_T_ = '') LOCAL_6B, " + Enter
cSQL += "		ISNULL(SB3.B3_Q01,0) AS B3_Q01, ISNULL(SB3.B3_Q02,0) AS B3_Q02, ISNULL(SB3.B3_Q03,0) AS B3_Q03, ISNULL(SB3.B3_Q04,0) AS B3_Q04, " + Enter
cSQL += "		ISNULL(SB3.B3_Q05,0) AS B3_Q05, ISNULL(SB3.B3_Q06,0) AS B3_Q06, ISNULL(SB3.B3_Q07,0) AS B3_Q07, ISNULL(SB3.B3_Q08,0) AS B3_Q08, " + Enter
cSQL += "		ISNULL(SB3.B3_Q09,0) AS B3_Q09, ISNULL(SB3.B3_Q10,0) AS B3_Q10, ISNULL(SB3.B3_Q11,0) AS B3_Q11, ISNULL(SB3.B3_Q12,0) AS B3_Q12, " + Enter
cSQL += "		SB1.B1_TIPO, SB2.B2_COD, B2_LOCAL AS B1_LOCPAD, SBZ.BZ_YPOLIT, " + Enter
// Tiago Rossini Coradini - Saldo em pedido somente da empresa Bianco
cSQL += "		(SELECT ISNULL(SUM(C7_QUANT - C7_QUJE),0) AS QUANT_SC7 FROM SC7010 " + Enter
//cSQL += "		 WHERE C7_PRODUTO = SB1.B1_COD AND C7_QUANT <> C7_QUJE AND C7_RESIDUO <> 'S' AND C7_CONAPRO = 'L' AND C7_ENCER <> 'E' AND D_E_L_E_T_ = '') AS B2_SALPEDI,	" + Enter
cSQL += "		 WHERE C7_PRODUTO = SB1.B1_COD AND C7_QUANT <> C7_QUJE AND C7_RESIDUO = '' AND C7_ENCER <> 'E' AND D_E_L_E_T_ = '') AS B2_SALPEDI,	" + Enter

// Tiago Rossini Coradini - Saldo em solicita็ใo somente da empresa Bianco
cSQL += "		(SELECT ISNULL(SUM(C1_QUANT - C1_QUJE),0) AS QUANT_SC1 FROM SC1010 " + Enter
//cSQL += "		 WHERE C1_PRODUTO = SB1.B1_COD AND C1_QUANT <> C1_QUJE AND C1_PEDIDO = ' ' AND C1_APROV NOT IN ('B','R') AND D_E_L_E_T_ = '') AS C1_QUANT,	" + Enter
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
cSql += "FROM SB1010 SB1 " + Enter
cSql += "	INNER JOIN (SELECT B2_COD, B2_LOCAL, SUM(B2_QATU) B2_QATU, D_E_L_E_T_ " + Enter
If cEmpAnt == "05"
cSql += "				FROM (SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2010 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '6I' AND D_E_L_E_T_ = ''  " + Enter
cSql += "				UNION ALL " + Enter
cSql += "				SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2050 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '6I' AND D_E_L_E_T_ = '') WWW " + Enter
ElseIf cEmpAnt == "14"
cSql += "				FROM (SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2010 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '6V' AND D_E_L_E_T_ = '' " + Enter
cSql += "				UNION ALL " + Enter
cSql += "				SELECT B2_COD, B2_LOCAL, B2_QATU, D_E_L_E_T_ FROM SB2140 WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '6V' AND D_E_L_E_T_ = '') WWW " + Enter
EndIf
cSql += "				GROUP BY B2_COD, B2_LOCAL, D_E_L_E_T_) SB2 " + Enter
cSql += "		ON SB1.B1_COD = SB2.B2_COD " + Enter
cSql += "			AND SB2.D_E_L_E_T_	=  '' " + Enter
cSql += "	INNER JOIN "+RETSQLNAME("SBZ")+" SBZ " + Enter
cSql += "		ON SB1.B1_COD = SBZ.BZ_COD " + Enter
cSql += "			AND SBZ.BZ_YPOLIT = '1' " + Enter
cSql += "			AND SBZ.BZ_YMD <> 'S' " + Enter
cSql += "			AND SBZ.BZ_YCOMUM = 'S' " + Enter
cSql += "			AND (SB2.B2_QATU <= SBZ.BZ_EMIN) " + Enter
//Inserido por Wanisay em 28/03/16 conforme OS 1363-16        
cSQL += "	        AND	SBZ.BZ_YATIVO <> 'N' " + Enter
cSql += "			AND SBZ.D_E_L_E_T_	=  '' " + Enter
cSql += "	INNER JOIN SBM010 SBM " + Enter
cSql += "		ON SBM.BM_GRUPO = SB1.B1_GRUPO " + Enter
cSql += "	LEFT JOIN "+RETSQLNAME("SB3")+" SB3 " + Enter
cSql += "		ON SB1.B1_COD = SB3.B3_COD " + Enter
cSql += "			AND SB3.B3_FILIAL = '"+xFilial("SB3")+"' " + Enter
cSql += "			AND SB3.D_E_L_E_T_	=  '' " + Enter
cSql += "WHERE SB1.B1_FILIAL   = '"+xFilial("SB1")+"' " + Enter
//cSql += "	AND SB1.B1_ATIVO = 'S' " + Enter
cSql += "	AND SUBSTRING(SB1.B1_COD,4,4) <> '0000' " + Enter
cSql += "	AND SB1.B1_TIPO IN ('MC','ME','MD','OI') " + Enter
cSql += "	AND SB1.D_E_L_E_T_ = '') AS TMP " + Enter



TcSQLExec(cSQL)             
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	//Parametros Crystal Em Disco
	Private cOpcao:="1;0;1;Gestao"
Else
	//Direto Impressora
	Private cOpcao:="3;0;1;Gestao"
Endif
callcrys("GesTra",,cOpcao)
Return