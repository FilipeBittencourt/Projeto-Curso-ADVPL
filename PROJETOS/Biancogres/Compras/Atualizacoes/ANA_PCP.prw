#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ANA_PCP        บAutor  ณBRUNO MADALENO      บ Data ณ  30/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRELATORIOS DE ANALISE DO PCP                                      บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ANA_PCP()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cSQL
PRIVATE ENTER    := CHR(13)+CHR(10)

// Retirado de uso em 28/03/14
Return
*********************************************************************
*********************************************************************

lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "ANALISE DO PCP"
cTamanho   := ""
limite     := 80
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "ANAPCP"
cPerg      := "ANAPCP"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "ANALISE DO PCP"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1
wnrel      := "ANAPCP"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT.								     ณ
//ณ Verifica Posicao do Formulario na Impressora.				             ณ
//ณ Solicita os parametros para a emissao do relatorio			             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
//Cancela a impressao
If nLastKey == 27
	Return
Endif

C_ANO_DE	:= SUBSTR(DTOS(MV_PAR01),1,4)
C_ANO_ATE	:= SUBSTR(DTOS(MV_PAR02),1,4)

IF cEmpAnt == '01'
	cSQL := ""
	cSQL := " ALTER VIEW VW_PCP_EMPENHO AS    " + ENTER
	cSQL += " SELECT	OP, C2_PRODUTO, D4_COD, DATA, DESC_PAI, DESC_FILHO, B1_UM, " + ENTER
	cSQL += " 		MAX(C2_QUANT) AS C2_QUANT, MAX(D4_QUANT) AS D4_QUANT, MAX(B2_QATU1) AS B2_QATU1, MAX(TOT_PED) AS TOT_PED " + ENTER
	cSQL += " 		 " + ENTER
	cSQL += " FROM   " + ENTER
	cSQL += " (SELECT	SUBSTRING(D4_OP,1,6) AS OP, C2_PRODUTO, D4_COD, CONVERT(DATETIME,D4_DATA ,106) AS DATA, C2_QUANT, D4_QUANT,   " + ENTER
	cSQL += " 		(SELECT B2_QATU FROM SB2010 WHERE B1_COD = B2_COD AND B2_LOCAL = '03' AND D_E_L_E_T_ = '') AS B2_QATU1,  " + ENTER
	cSQL += " 		(SELECT B1_DESC FROM SB1010 WHERE B1_COD = C2_PRODUTO AND D_E_L_E_T_ = '') AS DESC_PAI,  " + ENTER
	cSQL += " 		(SELECT B1_DESC FROM SB1010 WHERE B1_COD = D4_COD AND D_E_L_E_T_ = '') AS DESC_FILHO,  " + ENTER
	cSQL += " 		(SELECT B1_UM FROM SB1010 WHERE B1_COD = D4_COD AND D_E_L_E_T_ = '') AS B1_UM,  " + ENTER
	cSQL += " 		ISNULL((SELECT SUM(C7_QUANT-C7_QUJE) FROM SC7010 WHERE	C7_LOCAL = '03' AND SUBSTRING(C7_EMISSAO,1,4) BETWEEN '"+C_ANO_DE+"' AND '"+C_ANO_ATE+"' AND 	C7_RESIDUO = '' AND C7_PRODUTO = D4_COD AND D_E_L_E_T_ = ''  ),0) AS TOT_PED  " + ENTER
	cSQL += " FROM SD4010 SD4, SC2010 SC2, SB2050 SB2A, SB1010 SB1  " + ENTER
	cSQL += " WHERE	C2_NUM+C2_ITEM+C2_SEQUEN+'  '= D4_OP   " + ENTER
	cSQL += " 		AND C2_DATRF = ''   " + ENTER
	cSQL += " 		AND D4_COD = SB2A.B2_COD  " + ENTER
	cSQL += " 		AND SB2A.B2_COD = B1_COD  " + ENTER
	cSQL += " 		AND SB2A.B2_LOCAL = '03'  " + ENTER
	cSQL += " 		AND B1_TIPO <> 'PI'   " + ENTER
	cSQL += " 		AND SD4.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND SC2.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND SB1.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND SB2A.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND C2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' " + ENTER
	cSQL += " UNION " + ENTER
	cSQL += "SELECT	SUBSTRING(D4_OP,1,6) AS OP, C2_PRODUTO, D4_COD, CONVERT(DATETIME,D4_DATA ,106) AS DATA, C2_QUANT, D4_QUANT, B2_QATU AS B2_QATU1,  " + ENTER
	cSQL += "		(SELECT B1_DESC FROM SB1010 WHERE B1_COD = C2_PRODUTO AND D_E_L_E_T_ = '') AS DESC_PAI, " + ENTER
	cSQL += "		(SELECT B1_DESC FROM SB1010 WHERE B1_COD = D4_COD AND D_E_L_E_T_ = '') AS DESC_FILHO, " + ENTER
	cSQL += "		(SELECT B1_UM FROM SB1010 WHERE B1_COD = D4_COD AND D_E_L_E_T_ = '') AS B1_UM, " + ENTER
	cSQL += "		ISNULL((SELECT SUM(C7_QUANT-C7_QUJE) FROM "+RETSQLNAME("SC7")+" WHERE	SUBSTRING(C7_EMISSAO,1,4) BETWEEN '"+C_ANO_DE+"' AND '"+C_ANO_ATE+"' AND 	C7_RESIDUO = '' AND C7_PRODUTO = D4_COD AND D_E_L_E_T_ = ''  ),0) AS TOT_PED " + ENTER
	cSQL += "FROM "+RETSQLNAME("SD4")+" SD4, "+RETSQLNAME("SC2")+" SC2, "+RETSQLNAME("SB2")+" SB2, SB1010 SB1 " + ENTER
	cSQL += "WHERE	C2_NUM+C2_ITEM+C2_SEQUEN+'  '= D4_OP  " + ENTER
	cSQL += "		AND C2_DATRF = ''  " + ENTER
	cSQL += "		AND D4_COD = B2_COD  " + ENTER
	cSQL += "		AND B1_COD = B2_COD  " + ENTER
	cSQL += "		AND SB2.B2_LOCAL = '01' " + ENTER
	cSQL += "		AND B1_TIPO <> 'PI'  " + ENTER
	cSQL += "		AND SD4.D_E_L_E_T_ = '' " + ENTER
	cSQL += "		AND SC2.D_E_L_E_T_ = '' " + ENTER
	cSQL += "		AND SB2.D_E_L_E_T_ = '' " + ENTER
	cSQL += "		AND SB1.D_E_L_E_T_ = '' " + ENTER
	cSQL += "		AND C2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') AS TT " + ENTER
	cSQL += " GROUP BY OP, C2_PRODUTO, D4_COD, DATA, DESC_PAI, DESC_FILHO, B1_UM " + ENTER
	TcSQLExec(cSQL)
ELSE
	cSQL := " ALTER VIEW VW_PCP_EMPENHO AS    " + ENTER
	cSQL += " SELECT	OP, C2_PRODUTO, D4_COD, DATA, DESC_PAI, DESC_FILHO, B1_UM, " + ENTER
	cSQL += " 		MAX(C2_QUANT) AS C2_QUANT, MAX(D4_QUANT) AS D4_QUANT, MAX(B2_QATU1) AS B2_QATU1, MAX(TOT_PED) AS TOT_PED " + ENTER
	cSQL += " 		 " + ENTER
	cSQL += " FROM   " + ENTER
	cSQL += " (SELECT	SUBSTRING(D4_OP,1,6) AS OP, C2_PRODUTO, D4_COD, CONVERT(DATETIME,D4_DATA ,106) AS DATA, C2_QUANT, D4_QUANT,   " + ENTER
	cSQL += " 		(SELECT B2_QATU FROM SB2010 WHERE B1_COD = B2_COD AND B2_LOCAL = '03' AND D_E_L_E_T_ = '') AS B2_QATU1,  " + ENTER
	cSQL += " 		(SELECT B1_DESC FROM SB1010 WHERE B1_COD = C2_PRODUTO AND D_E_L_E_T_ = '') AS DESC_PAI,  " + ENTER
	cSQL += " 		(SELECT B1_DESC FROM SB1010 WHERE B1_COD = D4_COD AND D_E_L_E_T_ = '') AS DESC_FILHO,  " + ENTER
	cSQL += " 		(SELECT B1_UM FROM SB1010 WHERE B1_COD = D4_COD AND D_E_L_E_T_ = '') AS B1_UM,  " + ENTER
	cSQL += " 		ISNULL((SELECT SUM(C7_QUANT-C7_QUJE) FROM SC7010 WHERE	C7_LOCAL = '03' AND SUBSTRING(C7_EMISSAO,1,4) BETWEEN '"+C_ANO_DE+"' AND '"+C_ANO_ATE+"' AND 	C7_RESIDUO = '' AND C7_PRODUTO = D4_COD AND D_E_L_E_T_ = ''  ),0) AS TOT_PED  " + ENTER
	cSQL += " FROM SD4050 SD4, SC2050 SC2, SB2010 SB2A, SB1010 SB1  " + ENTER
	cSQL += " WHERE	C2_NUM+C2_ITEM+C2_SEQUEN+'  '= D4_OP   " + ENTER
	cSQL += " 		AND C2_DATRF = ''   " + ENTER
	cSQL += " 		AND D4_COD = SB2A.B2_COD  " + ENTER
	cSQL += " 		AND SB2A.B2_COD = B1_COD  " + ENTER
	cSQL += " 		AND SB2A.B2_LOCAL = '03'  " + ENTER
	cSQL += " 		AND B1_TIPO <> 'PI'   " + ENTER
	cSQL += " 		AND SD4.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND SC2.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND SB1.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND SB2A.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND C2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' " + ENTER
	cSQL += " UNION " + ENTER
	cSQL += " SELECT	SUBSTRING(D4_OP,1,6) AS OP, C2_PRODUTO, D4_COD, CONVERT(DATETIME,D4_DATA ,106) AS DATA, C2_QUANT, D4_QUANT,   " + ENTER
	cSQL += " 		(SELECT B2_QATU FROM SB2050 WHERE B1_COD = B2_COD AND B2_LOCAL = '01' AND D_E_L_E_T_ = '') AS B2_QATU1,  " + ENTER
	cSQL += " 		(SELECT B1_DESC FROM SB1010 WHERE B1_COD = C2_PRODUTO AND D_E_L_E_T_ = '') AS DESC_PAI,  " + ENTER
	cSQL += " 		(SELECT B1_DESC FROM SB1010 WHERE B1_COD = D4_COD AND D_E_L_E_T_ = '') AS DESC_FILHO,  " + ENTER
	cSQL += " 		(SELECT B1_UM FROM SB1010 WHERE B1_COD = D4_COD AND D_E_L_E_T_ = '') AS B1_UM,  " + ENTER
	cSQL += " 		ISNULL((SELECT SUM(C7_QUANT-C7_QUJE) FROM SC7050 WHERE	C7_LOCAL = '01' AND SUBSTRING(C7_EMISSAO,1,4) BETWEEN '"+C_ANO_DE+"' AND '"+C_ANO_ATE+"' AND 	C7_RESIDUO = '' AND C7_PRODUTO = D4_COD AND D_E_L_E_T_ = ''  ),0) AS TOT_PED  " + ENTER
	cSQL += " FROM SD4050 SD4, SC2050 SC2, SB2050 SB2B, SB1010 SB1  " + ENTER
	cSQL += " WHERE	C2_NUM+C2_ITEM+C2_SEQUEN+'  '= D4_OP   " + ENTER
	cSQL += " 		AND C2_DATRF = ''   " + ENTER
	cSQL += " 		AND D4_COD = SB2B.B2_COD  " + ENTER
	cSQL += " 		AND SB2B.B2_COD = B1_COD  " + ENTER
	cSQL += " 		AND SB2B.B2_LOCAL = '01'  " + ENTER
	cSQL += " 		AND B1_TIPO <> 'PI'   " + ENTER
	cSQL += " 		AND SD4.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND SC2.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND SB1.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND SB2B.D_E_L_E_T_ = ''  " + ENTER
	cSQL += " 		AND C2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'  ) AS TT " + ENTER
	cSQL += " GROUP BY OP, C2_PRODUTO, D4_COD, DATA, DESC_PAI, DESC_FILHO, B1_UM " + ENTER
	cSQL += " " + ENTER
	TcSQLExec(cSQL)
ENDIF

cSQL := "ALTER VIEW VW_PCP_PEDIDO AS  " + ENTER
cSQL += "SELECT	C7_PRODUTO, C7_NUM,  " + ENTER
cSQL += "		CONVERT(DATETIME,C7_EMISSAO ,106) AS C7_EMISSAO,  " + ENTER
cSQL += "		CONVERT(DATETIME,C7_DATPRF ,106) AS C7_DATPRF,  " + ENTER
cSQL += "		C7_QUANT, C7_QUJE, (C7_QUANT-C7_QUJE) AS QTD_PENDENTE " + ENTER
cSQL += "FROM "+RETSQLNAME("SC7")+" SC7, SB1010 SB1  " + ENTER
cSQL += "WHERE	SUBSTRING(C7_EMISSAO,1,4) BETWEEN '"+C_ANO_DE+"' AND '"+C_ANO_ATE+"' AND " + ENTER
cSQL += "		C7_RESIDUO = '' AND  C7_PRODUTO = B1_COD AND B1_TIPO <> 'PI' AND " + ENTER
cSQL += "		SC7.D_E_L_E_T_ = ''    AND " + ENTER
cSQL += "		SC7.C7_LOCAL   <> '03' AND " + ENTER
cSQL += "		SB1.D_E_L_E_T_ = ''    AND " + ENTER                  
cSQL += "		C7_DATPRF <> '' AND C7_EMISSAO <> '' " + ENTER

//Empresa Incesa,     sera considerado os Pedidos da Biancogres Local = 03
//Empresa Biancogres, sera considerado os Pedidos da Incesa     Local = 03
If cEmpAnt == "01"
	cSQL += "UNION ALL					" + ENTER
	cSQL += "SELECT	C7_PRODUTO, C7_NUM,	" + ENTER
	cSQL += "		CONVERT(DATETIME,C7_EMISSAO ,106) AS C7_EMISSAO,		" + ENTER
	cSQL += "		CONVERT(DATETIME,C7_DATPRF ,106) AS C7_DATPRF,  		" + ENTER
	cSQL += "		C7_QUANT, C7_QUJE, (C7_QUANT-C7_QUJE) AS QTD_PENDENTE	" + ENTER
	cSQL += "FROM SC7050 SC7, SB1010 SB1  									" + ENTER
	cSQL += "WHERE	SUBSTRING(C7_EMISSAO,1,4) BETWEEN '"+C_ANO_DE+"' AND '"+C_ANO_ATE+"' AND " + ENTER
	cSQL += "		C7_RESIDUO = '' AND  C7_PRODUTO = B1_COD AND B1_TIPO <> 'PI' AND " + ENTER
	cSQL += "		SC7.C7_LOCAL = '03' AND 								" + ENTER
	cSQL += "		SC7.D_E_L_E_T_ = '' AND 								" + ENTER
	cSQL += "		SB1.D_E_L_E_T_ = '' AND 								" + ENTER
	cSQL += "		C7_DATPRF <> '' AND C7_EMISSAO <> '' 					" + ENTER
ELSE
	cSQL += "UNION ALL					" + ENTER
	cSQL += "SELECT	C7_PRODUTO, C7_NUM,	" + ENTER
	cSQL += "		CONVERT(DATETIME,C7_EMISSAO ,106) AS C7_EMISSAO,		" + ENTER
	cSQL += "		CONVERT(DATETIME,C7_DATPRF ,106) AS C7_DATPRF,  		" + ENTER
	cSQL += "		C7_QUANT, C7_QUJE, (C7_QUANT-C7_QUJE) AS QTD_PENDENTE	" + ENTER
	cSQL += "FROM SC7010 SC7, SB1010 SB1  									" + ENTER
	cSQL += "WHERE	SUBSTRING(C7_EMISSAO,1,4) BETWEEN '"+C_ANO_DE+"' AND '"+C_ANO_ATE+"' AND " + ENTER
	cSQL += "		C7_RESIDUO = '' AND  C7_PRODUTO = B1_COD AND B1_TIPO <> 'PI' AND " + ENTER
	cSQL += "		SC7.C7_LOCAL = '03' AND 								" + ENTER
	cSQL += "		SC7.D_E_L_E_T_ = '' AND 								" + ENTER
	cSQL += "		SB1.D_E_L_E_T_ = '' AND 								" + ENTER
	cSQL += "		C7_DATPRF <> '' AND C7_EMISSAO <> '' 					" + ENTER
EndIf
TcSQLExec(cSQL)

If cEmpAnt == "01"
	cSQL := "ALTER VIEW VW_PCP_FORNECEDOR AS " + ENTER
	cSQL += "SELECT C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME	" + ENTER
	cSQL += "FROM 															" + ENTER
	cSQL += " (SELECT C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME " + ENTER
	cSQL += " FROM SC7010 SC7, SA2010 SA2 " + ENTER
	cSQL += " WHERE	C7_FORNECE   = A2_COD   AND " + ENTER
	cSQL += "	  	SC7.C7_LOJA    = A2_LOJA  AND " + ENTER               
	cSQL += "			SC7.C7_LOCAL	 = '01'		  AND	" + ENTER	
	cSQL += "	  	SC7.D_E_L_E_T_ = ''       AND " + ENTER
	cSQL += "	  	SA2.D_E_L_E_T_ = ''   		" + ENTER
	cSQL += "GROUP BY C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME 	" + ENTER
	cSQL += "	UNION ALL 															" + ENTER
	cSQL += "	SELECT C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME		" + ENTER
	cSQL += "	FROM SC7050 SC7, SA2010 SA2 										" + ENTER
	cSQL += "	WHERE	SC7.C7_FORNECE	= A2_COD 	AND  							" + ENTER
	cSQL += "			SC7.C7_LOJA		    = A2_LOJA	AND 							" + ENTER
	cSQL += "			SC7.C7_LOCAL	    = '03'		AND								" + ENTER
	cSQL += "			SC7.D_E_L_E_T_	  = ''      AND 							" + ENTER
	cSQL += "			SA2.D_E_L_E_T_	  = '' 	" + ENTER
	cSQL += "	GROUP BY C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME) TMP " + ENTER
	cSQL += "GROUP BY C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME			" + ENTER
Else
	cSQL := "ALTER VIEW VW_PCP_FORNECEDOR AS 								" + ENTER
	cSQL += "SELECT C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME	" + ENTER
	cSQL += "FROM 															" + ENTER
	cSQL += "	(SELECT C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME " + ENTER
	cSQL += "	FROM SC7050 SC7, SA2010 SA2 " + ENTER
	cSQL += "	WHERE	C7_FORNECE   = A2_COD  AND  " + ENTER
	cSQL += "			SC7.C7_LOJA    = A2_LOJA AND  " + ENTER
	cSQL += "			SC7.C7_LOCAL	 = '01'  	 AND	" + ENTER		
	cSQL += "			SC7.D_E_L_E_T_ = ''      AND  " + ENTER
	cSQL += "			SA2.D_E_L_E_T_ = ''  			" + ENTER
	cSQL += "	GROUP BY C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME 		" + ENTER
	cSQL += "	UNION ALL 															" + ENTER
	cSQL += "	SELECT C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME		" + ENTER
	cSQL += "	FROM SC7010 SC7, SA2010 SA2 										" + ENTER
	cSQL += "	WHERE	SC7.C7_FORNECE	= A2_COD 	AND  							" + ENTER
	cSQL += "			SC7.C7_LOJA	     	= A2_LOJA	AND 							" + ENTER
	cSQL += "			SC7.C7_LOCAL    	= '03'		AND								" + ENTER
	cSQL += "			SC7.D_E_L_E_T_  	= ''      AND								" + ENTER
	cSQL += "			SA2.D_E_L_E_T_	= '' 			" + ENTER
	cSQL += "	GROUP BY C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME) TMP " + ENTER
	cSQL += "GROUP BY C7_PRODUTO, C7_EMISSAO, C7_FORNECE, C7_PRECO, A2_NOME			" + ENTER
EndIf
TcSQLExec(cSQL)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	//Parametros Crystal Em Disco
	Private cOpcao:="1;0;1;Apuracao"
Else
	//Direto Impressora
	Private cOpcao:="3;0;1;Apuracao"
Endif
//AtivaRel()
callcrys("ANA_PCP",cEmpant,cOpcao)
Return
