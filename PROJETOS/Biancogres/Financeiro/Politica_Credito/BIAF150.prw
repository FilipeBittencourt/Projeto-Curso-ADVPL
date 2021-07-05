#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF150
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao para geracao automatica de Politica de Credito para Clientes da Carteira Ativa
@type class
/*/

User Function BIAF150()
Local _cSql := ""
Local cQry := ""

	RpcSetType(3)
	RpcSetEnv("01", "01")

	ConOut("BIAF150 => [Gestao Carteira Ativa Rocket] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

	//Limpa temp
	_cSql := ""
	_cSql += "DROP TABLE IF EXISTS ##CLIENTE"
	TcSQLExec(_cSql)

	_cSql := ""
	_cSql += "SELECT * "
	_cSql += "INTO ##CLIENTE "
	_cSql += "FROM "
	_cSql += "(SELECT	A1_COD, A1_LOJA, A1_NOME, A1_GRPVEN, A1_CGC, A1_YTIPOLC, A1_RISCO, A1_LC, A1_VENCLC, A1_YTPSEG "
	_cSql += "		,CODIGO = CASE WHEN A1_YTIPOLC = 'G' THEN A1_YTIPOLC+'-'+A1_GRPVEN ELSE A1_YTIPOLC+'-'+A1_COD END "
	_cSql += "		,RISCO = CASE WHEN A1_RISCO = 'A' THEN 999999 " 
	_cSql += "					WHEN A1_RISCO = 'E' THEN 0 " 
	_cSql += "				ELSE 4 END " //MESMO VALOR DO PARAMETRO MV_RISCOB, MV_RISCOC e MV_RISCOD 
	_cSql += "FROM SA1010 WITH (NOLOCK) " 
	_cSql += "WHERE A1_FILIAL = '' AND  D_E_L_E_T_ = '' ) TMP "
	TcSQLExec(_cSql)


	//Limpa temp
	_cSql := ""
	_cSql += "DROP TABLE IF EXISTS ##TITULO"
	TcSQLExec(_cSql)

	_cSql := ""
	_cSql += "SELECT E1_CLIENTE, E1_LOJA, MIN(E1_VENCREA) VENCREA, SUM(E1_SALDO) SALDO "
	_cSql += "INTO ##TITULO "
	_cSql += "FROM VW_SE1 "
	_cSql += "WHERE  E1_FILIAL = '01' "
	_cSql += "   AND E1_SALDO > 0  "
 	_cSql += "  AND E1_TIPO NOT IN ('NCC', 'NDC', 'RA', 'BOL') "
	_cSql += "GROUP BY E1_CLIENTE, E1_LOJA "
	TcSQLExec(_cSql)


	//Limpa temp
	_cSql := ""
	_cSql += "DROP TABLE IF EXISTS ##COMPRA"
	TcSQLExec(_cSql)

	_cSql := ""
	_cSql += "SELECT CLIENTE, LOJA, 'SIM' COMPRA "
	_cSql += "INTO ##COMPRA "
	_cSql += "FROM VW_SAP_CML_MOVVENDAS "
	_cSql += "WHERE DTEMIS >= CONVERT(VARCHAR,DATEADD(MONTH,-6,GETDATE()),112) "  
	_cSql += "	AND PRAZOMEDIO > 0 "
	_cSql += "	AND RESULT1 = 'S' "
	_cSql += "	AND RESULT2 = 'S' "
	_cSql += "	AND ATUDPL = 'S' "
	_cSql += "	AND D_E_L_E_T_ = ''  "
	_cSql += "GROUP BY CLIENTE, LOJA "
	TcSQLExec(_cSql)

	_cSql := ""
	_cSql += "DELETE ##CLIENTE "
	_cSql += "FROM ##CLIENTE CLI INNER JOIN (SELECT CODIGO FROM ##CLIENTE WHERE A1_RISCO <> 'D') RISCO ON CLI.CODIGO = RISCO.CODIGO "
	TcSQLExec(_cSql)

	_cSql := ""
	_cSql += "DELETE ##CLIENTE "
	_cSql += "FROM ##CLIENTE CLI INNER JOIN (SELECT DISTINCT(REPLICATE('0',11-LEN(numcpf))+CONVERT(nvarchar,numcpf)) CPF FROM VETORH.dbo.r034fun WITH (NOLOCK) ) FUNC ON CLI.A1_CGC = FUNC.CPF "
	TcSQLExec(_cSql)

	_cSql := ""
	_cSql += "DELETE ##CLIENTE "
	_cSql += "FROM ##CLIENTE CLI INNER JOIN (SELECT CODIGO FROM ##CLIENTE CLI INNER JOIN (SELECT A3_CGC AS CNPJ FROM SA3010 WITH (NOLOCK) WHERE A3_CGC <> ''  AND D_E_L_E_T_ = '' GROUP BY A3_CGC ) REPR ON CLI.A1_CGC = REPR.CNPJ) REP ON CLI.CODIGO = REP.CODIGO "
	TcSQLExec(_cSql)

	_cSql := ""
	_cSql += "DELETE ##CLIENTE "
	_cSql += "FROM ##CLIENTE CLI INNER JOIN (SELECT CODIGO FROM ##CLIENTE WHERE A1_LC = 0 ) LIMITE ON CLI.CODIGO = LIMITE.CODIGO "
	TcSQLExec(_cSql)

	_cSql := ""
	_cSql += "DELETE ##CLIENTE "
	_cSql += "FROM ##CLIENTE CLI INNER JOIN  "
	_cSql += "	(SELECT CODIGO  "
	_cSql += "	FROM ##CLIENTE INNER JOIN ##TITULO ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA   "
	_cSql += "	WHERE  DATEDIFF (D , VENCREA , GETDATE ()) > RISCO) ATRASO "
	_cSql += "	ON CLI.CODIGO = ATRASO.CODIGO "
	TcSQLExec(_cSql)

	_cSql := ""
	_cSql += "DELETE ##CLIENTE "
	_cSql += "FROM ##CLIENTE CLI INNER JOIN (SELECT CODIGO FROM ##CLIENTE WHERE  A1_VENCLC > CONVERT(VARCHAR,DATEADD(DAY,10,GETDATE()),112) ) VENCLC ON CLI.CODIGO = VENCLC.CODIGO "
	TcSQLExec(_cSql)

	cQry := GetNextAlias()

	_cSql := " SELECT * "
	_cSql += " FROM( "
	_cSql += " SELECT CODIGO, A1_COD AS CLIENTE, A1_LOJA LOJA, A1_GRPVEN AS GRUPOCLI, A1_CGC AS CNPJ, A1_LC AS LC, A1_YTPSEG AS TPSEG , A1_VENCLC "
	_cSql += " 		, ROW_NUMBER() OVER(PARTITION BY CODIGO ORDER BY CODIGO ASC) LINHA "
	_cSql += " FROM ##CLIENTE  "
	_cSql += " 		INNER JOIN ##COMPRA COMP ON A1_COD = COMP.CLIENTE AND A1_LOJA = COMP.LOJA  "
	_cSql += " 		INNER JOIN ##TITULO TIT  ON A1_COD = E1_CLIENTE  AND A1_LOJA = E1_LOJA ) TMP "
	_cSql += " WHERE LINHA = 1 "
	TcQuery _cSql New Alias (cQry)

	While !(cQry)->(Eof())
	
		U_BIAF146(dDataBase, (cQry)->CLIENTE, (cQry)->LOJA, (cQry)->GRUPOCLI, (cQry)->CNPJ, (cQry)->LC, If ((cQry)->TPSEG == "E", (cQry)->LC, 0), "4", .F.)
	
		(cQry)->(DbSkip())
								
	EndDo()

	(cQry)->(DbCloseArea())		

	ConOut("BIAF150 => [Gestao Carteira Ativa Rocket] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

	RpcClearEnv()
		
Return()
