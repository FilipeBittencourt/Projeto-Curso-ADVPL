#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} BIA489
@author Wanisay William
@since 12/01/2012
@version 1.0
@description Atualizando status da SC-e 
@history 16/11/2017, Ranisses A. Corona, Melhoria de performance na rotina, após analise do Fabricio Lima - DBA 
@history 02/05/2019, Ranisses A. Corona, Rotina foi desativado do Schedule do Protheus e transferida para um job no SQL Server.
@type function
/*/

User Function BIA489()
	Local xv_Emps := U_BAGtEmpr("01_05_06_07_12_14_13_16_17")
	Local x

	For x := 1 to Len(xv_Emps)

		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

		ConOut("HORA: "+TIME()+" - Inicio - Atualizando status SC " + xv_Emps[x,1])

		//DESATIVADO EM 02/05/2019
		//Processa({|| Analisa_SC()})

		ConOut("HORA: "+TIME()+" - Fim - Atualizando status SC " + xv_Emps[x,1])

		//Finaliza o ambiente criado
		RpcClearEnv()

	Next

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaArq   ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Analisa_SC()
	Local cSql := ""


	//Monta Base do SC1 -- (SC em Cotação de Precos)
	cSql := ""
	cSql += "SELECT STATUS, RECNO_SC1   "
	cSql += "INTO #STATUS_SC1			"
	cSql += "FROM						"
	cSql += "("
	cSql += "SELECT '300001' AS STATUS, R_E_C_N_O_ AS 'RECNO_SC1' 	" //(SC em Cotação de Precos)
	cSql += "FROM "+RetSqlName("SC1")+" SC1 WITH (NOLOCK)			" 				 
	cSql += "WHERE	SC1.C1_FILIAL	= '01'	AND	"					
	cSql += "		SC1.C1_MSEXP    = ''	AND	"
	cSql += "		SC1.C1_PEDIDO   = ''    AND	" 
	cSql += "		SC1.C1_APROV    = 'L'   AND	" 
	cSql += "		SC1.C1_COTACAO <> ''    AND	" 
	cSql += "		SC1.C1_QUJE     = 0		AND	" 
	cSql += "		SC1.C1_YMAT		<> ''	AND	"		 
	cSql += "		SC1.D_E_L_E_T_	= ''		"
	cSql += ") TMP								"
	TCSQLExec(cSql)

	//Atualiza o Status e o campo de controle de atualização 
	cSql := ""
	cSql += "UPDATE "+RetSqlName("SC1")+" SET C1_WFID = TMP.STATUS, C1_MSEXP = CONVERT(VARCHAR,GETDATE(),112) "
	cSql += "FROM #STATUS_SC1 TMP INNER JOIN "+RetSqlName("SC1")+" SC1 ON " 
	cSql += "	TMP.RECNO_SC1 = SC1.R_E_C_N_O_ "
	TCSQLExec(cSql)

	//Apaga tabela temporaria 
	cSql := ""
	cSql += "DROP TABLE #STATUS_SC1 "
	TCSQLExec(cSql)

	//Monta Base SC1xSC7 -- (Demais Status)
	cSql := ""
	cSql += "SELECT STATUS, RECNO_SC1, RECNO_SC7 "
	cSql += "INTO #STATUS_SC1			"
	cSql += "FROM						"
	cSql += "(SELECT STATUS = CASE		" 
	cSql += "					WHEN C1_PEDIDO <> '' AND C7_CONAPRO <> 'L' AND C7_QUJE = 0 AND C7_ENCER = '' AND C7_RESIDUO = ''				THEN '300002' " //(SC com Pedido Bloqueado)
	cSql += "					WHEN C1_PEDIDO <> '' AND C7_CONAPRO  = 'L' AND C7_QUJE = 0 AND C7_ENCER = '' AND C7_RESIDUO = ''				THEN '300003' " //(SC com Pedido Aprovado)
	cSql += "					WHEN C1_PEDIDO <> '' AND C7_RESIDUO  = 'S' AND C7_QUJE > 0														THEN '300005' " //(SC com Pedido Encerrado por Residuo - Entrega Parcial)
	cSql += "					WHEN C1_PEDIDO <> '' AND C7_RESIDUO  = 'S' AND C7_QUJE = 0														THEN '300006' " //(SC com Pedido Encerrado por Residuo - Nenhuma Entrega)
	cSql += "					WHEN C1_PEDIDO <> '' AND C7_RESIDUO  = ' ' AND C7_QUJE > 0 AND C7_QUJE = C7_QUANT								THEN '300004' " //(SC com Pedido Atendido e Encerrado)
	cSql += "					WHEN C1_PEDIDO <> '' AND C7_RESIDUO  = ' ' AND C7_QUJE > 0 AND C7_QUJE <> ROUND(C7_QUANT,2) AND C7_ENCER <> 'E' THEN '300008' " //(SC com Pedido Atendido Parcialmente)
	cSql += "					ELSE ''	"
	cSql += "				END			"
	cSql += "	, RECNO_SC1				"
	cSql += "	, RECNO_SC7				"
	cSql += "FROM 						" 				 
	cSql += "(
	//Todas as SCs com alteração e amarradas a Pedidos 
	cSql += "	SELECT SC1.R_E_C_N_O_ AS 'RECNO_SC1', SC7.R_E_C_N_O_ AS 'RECNO_SC7', C1_PEDIDO, C1_APROV, C1_COTACAO, C1_QUJE, C7_CONAPRO,  C7_QUJE,  C7_ENCER, C7_RESIDUO, C7_QUANT "
	cSql += "	FROM "+RetSqlName("SC1")+" SC1 WITH (NOLOCK)	" 				 
	cSql += "		INNER JOIN "+RetSqlName("SC7")+" SC7 WITH (NOLOCK) ON		"	
	cSql += "		SC7.C7_FILIAL   = '01'			  AND		"	
	cSql += "		SC7.C7_PRODUTO  = SC1.C1_PRODUTO  AND		"	 
	cSql += "		SC7.C7_NUM	    = SC1.C1_PEDIDO	  AND		"	 
	cSql += "		SC7.C7_ITEM	    = SC1.C1_ITEMPED			"  
	cSql += "	WHERE	SC1.C1_FILIAL	= '01'	AND				"					
	cSql += "			SC1.C1_YMAT		<> ''	AND				"			 
	cSql += "			SC1.C1_MSEXP    = '' AND				" 
	cSql += "			SC1.D_E_L_E_T_	= '' AND				" 				 
	cSql += "			SC7.D_E_L_E_T_	= ''					" 					
	cSql += "UNION											" 
	//Todas as SCs amarradas a Pedidos que tiveram alteração
	cSql += "	SELECT SC1.R_E_C_N_O_ AS 'RECNO_SC1', SC7.R_E_C_N_O_ AS 'RECNO_SC7', C1_PEDIDO, C1_APROV, C1_COTACAO, C1_QUJE, C7_CONAPRO, C7_QUJE, C7_ENCER, C7_RESIDUO, C7_QUANT	"
	cSql += "	FROM "+RetSqlName("SC1")+" SC1 WITH (NOLOCK)					" 				 
	cSql += "		INNER JOIN "+RetSqlName("SC7")+" SC7 WITH (NOLOCK) ON		"	
	cSql += "		SC7.C7_FILIAL   = '01'			  AND		"	
	cSql += "		SC7.C7_PRODUTO  = SC1.C1_PRODUTO  AND		"	 
	cSql += "		SC7.C7_NUM	    = SC1.C1_PEDIDO	  AND		"	 
	cSql += "		SC7.C7_ITEM	    = SC1.C1_ITEMPED			"  
	cSql += "	WHERE	SC1.C1_FILIAL	= '01'	AND				"					
	cSql += "			SC1.C1_YMAT		<> ''	AND				"			 
	cSql += "			SC7.C7_MSEXP    = '' AND				" 
	cSql += "			SC1.D_E_L_E_T_	= '' AND				" 				 
	cSql += "			SC7.D_E_L_E_T_	= ''					" 					
	cSql += " )TMP ) TMP										"
	TCSQLExec(cSql)

	//Atualiza o Status e o campo de controle de atualização 
	cSql := ""
	cSql += "UPDATE "+RetSqlName("SC1")+" SET C1_WFID = TMP.STATUS, C1_MSEXP = CONVERT(VARCHAR,GETDATE(),112) "
	cSql += "FROM #STATUS_SC1 TMP INNER JOIN "+RetSqlName("SC1")+" SC1 ON " 
	cSql += "	TMP.RECNO_SC1 = SC1.R_E_C_N_O_ "
	TCSQLExec(cSql)

	//Atualiza o campo de controle de atualização
	cSql := ""
	cSql += "UPDATE "+RetSqlName("SC7")+" SET C7_MSEXP = CONVERT(VARCHAR,GETDATE(),112) "
	cSql += "FROM #STATUS_SC1 TMP INNER JOIN "+RetSqlName("SC7")+" SC7 ON " 
	cSql += "	TMP.RECNO_SC7 = SC7.R_E_C_N_O_ "
	TCSQLExec(cSql)

	//Apaga tabela temporaria (SOMENTE POR SEGURANCA)
	cSql := ""
	cSql += "DROP TABLE #STATUS_SC1 "
	TCSQLExec(cSql)

Return