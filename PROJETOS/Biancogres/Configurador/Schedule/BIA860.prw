#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
##############################################################################################################
# PROGRAMA...: BIA860
# AUTOR......: Ranisses A. Corona
# DATA.......: 08/01/2014
# DESCRICAO..: Workflow para envio das informações dos Pedidos Liberados que foram estornados por falta de 
#			   saldo de RA.
#			   CONFIGURADO JOB SEMANAL
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/
User Function BIA860()

	Local x
	Private cEmail      := ""
	Private c_HTML  	:= ""
	Private lOK         := .F.
	Private xv_Emps     := U_BAGtEmpr("01_05_07_13_14")
	//Private xv_Emps     := U_BAGtEmpr("01")

	For x := 1 to Len(xv_Emps)

		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

		ConOut("HORA: "+TIME()+" - INICIO ROTINA BIA860 " + xv_Emps[x,1])

		/*If cEmpAnt == "07"
			CSQL := ""
			CSQL += "if exists (select 1 from Tempdb..SysObjects where Name = '##TMP_ZZI' and type = 'U') drop table ##TMP_ZZI "
			TcSQLExec(cSQL)					

			CSQL := ""
			CSQL += "SELECT * INTO ##TMP_ZZI FROM 										"
			CSQL += "(SELECT ZZI_VEND, ZZI_TPSEG, ZZI_ATENDE, ZZI_GERENT, D_E_L_E_T_	"
			CSQL += "FROM ZZI010														"
			CSQL += "WHERE D_E_L_E_T_ = ''												"
			CSQL += "UNION 																"
			CSQL += "SELECT ZZI_VEND, ZZI_TPSEG, ZZI_ATENDE, ZZI_GERENT, D_E_L_E_T_		"
			CSQL += "FROM ZZI050														"
			CSQL += "WHERE D_E_L_E_T_ = '') TMP         								"
			TcSQLExec(cSQL)					
		Else
			CSQL := ""
			CSQL += "if exists (select 1 from Tempdb..SysObjects where Name = '##TMP_ZZI' and type = 'U') drop table ##TMP_ZZI "
			TcSQLExec(cSQL)					

			CSQL := ""
			CSQL += "SELECT * INTO ##TMP_ZZI FROM 										"
			CSQL += "(SELECT ZZI_VEND, ZZI_TPSEG, ZZI_ATENDE, ZZI_GERENT, D_E_L_E_T_	"
			CSQL += "FROM "+RetSqlName("ZZI")+"											"
			CSQL += "WHERE D_E_L_E_T_ = '') TMP											"
			TcSQLExec(cSQL)					
		EndIf
		*/
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄìŽBìŽB˜¿
		//³ENVIA MENSAGEM DOS PEDIDOS ESTORNADOS POR FALTA DE SALDO DE RA
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄìŽBìŽB˜Ù

		//Envia E-mail para os Vendedores
		//CSQL := ""
		//CSQL += "SELECT C5_NUM, C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, C5_VEND1 AS COD		"	
		//CSQL += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1, ##TMP_ZZI AS ZZI, "+RetSqlName("SC9")+" SC9	"
		//CSQL += "WHERE	C9_YRASTAT		=  '3'			AND						   "
		////CSQL += "		C9_YRADTEX		>= CONVERT(nvarchar, GETDATE()-7 ,112) AND "
		//CSQL += "		C9_YRADTEX		= CONVERT(nvarchar, GETDATE() ,112) AND "
		//CSQL += "		C5_NUM			= C9_PEDIDO		AND "
		//CSQL += "		C5_CLIENTE		= C9_CLIENTE	AND "
		//CSQL += "		C5_LOJACLI		= C9_LOJA		AND "
		//CSQL += "		C5_CLIENTE		= A1_COD		AND "
		//CSQL += "		C5_LOJACLI		= A1_LOJA		AND "
		//CSQL += "		C5_VEND1		*= ZZI_VEND		AND "
		//CSQL += "		A1_YTPSEG		*= ZZI_TPSEG	AND "
		//CSQL += "		C5_YCLIORI      =  ''			AND " //NÃO CONSIDERA LM
		//CSQL += "		SC5.D_E_L_E_T_  =  ''			AND "
		//CSQL += "		SA1.D_E_L_E_T_  =  ''			AND "
		//CSQL += "		ZZI.D_E_L_E_T_  =  ''			AND "
		//CSQL += "		SC9.D_E_L_E_T_  =  '*'				"
		//If cEmpAnt $ "01_05"
		//	CSQL += "UNION ALL "	
		//	CSQL += "SELECT SC5.C5_NUM, SC5.C5_EMISSAO, SA1.A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, SC5_07.C5_VEND1 AS COD		"	
		//	CSQL += "FROM "+RetSqlName("SC5")+" SC5, SC5070 SC5_07, "+RetSqlName("SA1")+" SA1, ##TMP_ZZI AS ZZI, "+RetSqlName("SC9")+" SC9	"
		//	CSQL += "WHERE	C9_YRASTAT			=  '3'			AND						   "
		//	//CSQL += "		C9_YRADTEX			>= CONVERT(nvarchar, GETDATE()-7 ,112) AND "
		//	CSQL += "		C9_YRADTEX			= CONVERT(nvarchar, GETDATE() ,112) AND "
		//	CSQL += "		SC5.C5_NUM			= C9_PEDIDO		AND "
		//	CSQL += "		SC5.C5_CLIENTE		= C9_CLIENTE	AND "
		//	CSQL += "		SC5.C5_LOJACLI		= C9_LOJA		AND "
		//	CSQL += "		SC5.C5_YCLIORI		= A1_COD		AND "
		//	CSQL += "		SC5.C5_YLOJORI		= A1_LOJA		AND "
		//	CSQL += "		SC5.C5_NUM			= SC5_07.C5_YPEDORI AND "
		// 	CSQL += "		SC5_07.C5_YEMPPED 	= '"+cEmpAnt+"'	AND "	
		//	CSQL += "		SC5_07.C5_VEND1		*= ZZI_VEND		AND "
		// 	CSQL += "		SA1.A1_YTPSEG		*= ZZI_TPSEG	AND "
		//	CSQL += "		SC5.C5_YCLIORI      <> ''			AND " //CONSIDERA LM
		//	CSQL += "		SC5.D_E_L_E_T_  	=  ''			AND "
		//	CSQL += "		SC5_07.D_E_L_E_T_  	=  ''			AND "
		//	CSQL += "		SA1.D_E_L_E_T_  	=  ''			AND "
		//	CSQL += "		ZZI.D_E_L_E_T_  	=  ''			AND "
		//	CSQL += "		SC9.D_E_L_E_T_  	=  '*'				"
		//EndIf
		//CSQL += "ORDER BY COD, SC5.C5_NUM						"



		//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
		//os dois selects seguintes foram apagados e colocados o select novo, pra não ficar muito código comentado.
		//ambos são iguais ao select abaixo, mudando apenas a coluna COD
		CSQL := ""
		CSQL += "SELECT C5_NUM, C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, C5_VEND1 AS COD "
		CSQL += "FROM " + RetSqlName("SC9") + " SC9 "
		CSQL += "	INNER JOIN " + RetSqlName("SC5") + " SC5 "
		CSQL += "		ON C5_NUM = C9_PEDIDO "
		CSQL += "			AND C5_CLIENTE = C9_CLIENTE "
		CSQL += "			AND C5_LOJACLI = C9_LOJA "
		CSQL += "			AND C5_YCLIORI      =  '' " //NÃO CONSIDERA LM
		CSQL += "			AND SC5.D_E_L_E_T_ = '' "
		CSQL += "	INNER JOIN " + RetSqlName("SA1") + " SA1 "
		CSQL += "		ON C5_CLIENTE = A1_COD "
		CSQL += "			AND C5_LOJACLI = A1_LOJA "
		CSQL += "			AND SA1.D_E_L_E_T_ = '' "
		//CSQL += "	LEFT JOIN ##TMP_ZZI AS ZZI "
		//CSQL += "		ON C5_VEND1 = ZZI_VEND "
		//CSQL += "			AND A1_YTPSEG = ZZI_TPSEG "
		//CSQL += "			AND ZZI.D_E_L_E_T_ = '' "
		CSQL += "WHERE C9_YRASTAT = '3' AND "
		//CSQL += "		C9_YRADTEX		>= CONVERT(nvarchar, GETDATE()-7 ,112) AND "
		CSQL += "		C9_YRADTEX		= CONVERT(nvarchar, GETDATE() ,112) AND "
		CSQL += "		SC9.D_E_L_E_T_ = '*' "
		
		If cEmpAnt $ "01_05"
			CSQL += "	UNION ALL "
			CSQL += "	SELECT SC5.C5_NUM, SC5.C5_EMISSAO, SA1.A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, SC5_07.C5_VEND1 AS COD "
			CSQL += "	FROM " + RetSqlName("SC9") + " SC9 "
			CSQL += "		INNER JOIN " + RetSqlName("SC5") + " SC5 "
			CSQL += "			ON SC5.C5_NUM = C9_PEDIDO "
			CSQL += "				AND SC5.C5_CLIENTE = C9_CLIENTE "
			CSQL += "				AND SC5.C5_LOJACLI = C9_LOJA "
			CSQL += "				AND SC5.C5_YCLIORI <> '' " //CONSIDERA LM
			CSQL += "				AND SC5.D_E_L_E_T_ =  '' "
			CSQL += "		INNER JOIN SC5070 SC5_07 "
			CSQL += "			ON SC5.C5_NUM = SC5_07.C5_YPEDORI "
			CSQL += "				AND SC5_07.C5_YEMPPED = '" + cEmpAnt + "' "
			CSQL += "				AND SC5_07.D_E_L_E_T_ = '' "
			CSQL += "		INNER JOIN " + RetSqlName("SA1") + " SA1 "
			CSQL += "			ON SC5.C5_YCLIORI = A1_COD "
			CSQL += "				AND SC5.C5_YLOJORI = A1_LOJA "
			CSQL += "				AND SA1.D_E_L_E_T_  = '' "
		//	CSQL += "		LEFT JOIN ##TMP_ZZI AS ZZI "
		//	CSQL += "			ON SC5_07.C5_VEND1 = ZZI_VEND "
		//	CSQL += "				AND SA1.A1_YTPSEG = ZZI_TPSEG "
		//	CSQL += "				AND ZZI.D_E_L_E_T_ = '' "
			CSQL += "	WHERE	C9_YRASTAT = '3' AND "
			//CSQL += "		C9_YRADTEX			>= CONVERT(nvarchar, GETDATE()-7 ,112) AND "
			CSQL += "		C9_YRADTEX = CONVERT(nvarchar, GETDATE() ,112) AND "
			CSQL += "		SC9.D_E_L_E_T_ = '*' "
		EndIf
		CSQL += "ORDER BY COD, SC5.C5_NUM "

		If chkfile("TRJ")
			dbSelectArea("TRJ")
			dbCloseArea()
		EndIf
		TcQuery cSql New Alias "TRJ"	
		GeraHtml(1)    

		//Envia E-mail para os Atendentes

		//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
		//o select seguinte foi apagado e colocado o select novo, pra não ficar muito código comentado.
		//ele é iguail ao select acima, mudando apenas a coluna COD
		CSQL := ""
		CSQL += "SELECT C5_NUM, C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, "
		CSQL += " (SELECT ATENDE FROM [dbo].[GET_ZKP] (SA1.A1_YTPSEG, SC5.C5_YEMP, SA1.A1_EST, SC5.C5_VEND1, SA1.A1_YCAT, '')) AS COD "
		CSQL += "FROM " + RetSqlName("SC9") + " SC9 "
		CSQL += "	INNER JOIN " + RetSqlName("SC5") + " SC5 "
		CSQL += "		ON C5_NUM = C9_PEDIDO "
		CSQL += "			AND C5_CLIENTE = C9_CLIENTE "
		CSQL += "			AND C5_LOJACLI = C9_LOJA "
		CSQL += "			AND C5_YCLIORI      =  '' " //NÃO CONSIDERA LM
		CSQL += "			AND SC5.D_E_L_E_T_ = '' "
		CSQL += "	INNER JOIN " + RetSqlName("SA1") + " SA1 "
		CSQL += "		ON C5_CLIENTE = A1_COD "
		CSQL += "			AND C5_LOJACLI = A1_LOJA "
		CSQL += "			AND SA1.D_E_L_E_T_ = '' "
		//CSQL += "	LEFT JOIN ##TMP_ZZI AS ZZI "
		//CSQL += "		ON C5_VEND1 = ZZI_VEND "
		//CSQL += "			AND A1_YTPSEG = ZZI_TPSEG "
		//CSQL += "			AND ZZI.D_E_L_E_T_ = '' "
		
		CSQL += "WHERE C9_YRASTAT = '3' AND "
		//CSQL += "		C9_YRADTEX		>= CONVERT(nvarchar, GETDATE()-7 ,112) AND "
		CSQL += "		C9_YRADTEX		= CONVERT(nvarchar, GETDATE() ,112) AND "
		CSQL += "		SC9.D_E_L_E_T_ = '*' "
		If cEmpAnt $ "01_05"
			CSQL += "	UNION ALL "
			CSQL += "	SELECT SC5.C5_NUM, SC5.C5_EMISSAO, SA1.A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, "
			CSQL += " (SELECT ATENDE FROM [dbo].[GET_ZKP] (SA1.A1_YTPSEG, SC5.C5_YEMP, SA1.A1_EST, SC5.C5_VEND1, SA1.A1_YCAT, '')) AS COD "
			CSQL += "	FROM " + RetSqlName("SC9") + " SC9 "
			CSQL += "		INNER JOIN " + RetSqlName("SC5") + " SC5 "
			CSQL += "			ON SC5.C5_NUM = C9_PEDIDO "
			CSQL += "				AND SC5.C5_CLIENTE = C9_CLIENTE "
			CSQL += "				AND SC5.C5_LOJACLI = C9_LOJA "
			CSQL += "				AND SC5.C5_YCLIORI <> '' " //CONSIDERA LM
			CSQL += "				AND SC5.D_E_L_E_T_ =  '' "
			CSQL += "		INNER JOIN SC5070 SC5_07 "
			CSQL += "			ON SC5.C5_NUM = SC5_07.C5_YPEDORI "
			CSQL += "				AND SC5_07.C5_YEMPPED = '" + cEmpAnt + "' "
			CSQL += "				AND SC5_07.D_E_L_E_T_ = '' "
			CSQL += "		INNER JOIN " + RetSqlName("SA1") + " SA1 "
			CSQL += "			ON SC5.C5_YCLIORI = A1_COD "
			CSQL += "				AND SC5.C5_YLOJORI = A1_LOJA "
			CSQL += "				AND SA1.D_E_L_E_T_  = '' "
			
			//CSQL += "		LEFT JOIN ##TMP_ZZI AS ZZI "
			//CSQL += "			ON SC5_07.C5_VEND1 = ZZI_VEND "
			//CSQL += "				AND SA1.A1_YTPSEG = ZZI_TPSEG "
			//CSQL += "				AND ZZI.D_E_L_E_T_ = '' "
			
			CSQL += "	WHERE	C9_YRASTAT = '3' AND "
			//CSQL += "		C9_YRADTEX			>= CONVERT(nvarchar, GETDATE()-7 ,112) AND "
			CSQL += "		C9_YRADTEX = CONVERT(nvarchar, GETDATE() ,112) AND "
			CSQL += "		SC9.D_E_L_E_T_ = '*' "
		EndIf
		CSQL += "ORDER BY COD, SC5.C5_NUM "

		If chkfile("TRJ")
			dbSelectArea("TRJ")
			dbCloseArea()
		EndIf
		TcQuery cSql New Alias "TRJ"	
		GeraHtml(2) //Atendentes

		//Envia E-mail para os Gerentes	

		//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
		//o select seguinte foi apagado e colocado o select novo, pra não ficar muito código comentado.
		//ele é iguail ao select acima, mudando apenas a coluna COD
		CSQL := ""
		CSQL += "SELECT C5_NUM, C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, "
		CSQL += " ISNULL((SELECT GERENT FROM [dbo].[GET_ZKP] (SA1.A1_YTPSEG, SC5.C5_YEMP, SA1.A1_EST, SC5.C5_VEND1, SA1.A1_YCAT, '')), '') AS COD "
		CSQL += "FROM " + RetSqlName("SC9") + " SC9 "
		CSQL += "	INNER JOIN " + RetSqlName("SC5") + " SC5 "
		CSQL += "		ON C5_NUM = C9_PEDIDO "
		CSQL += "			AND C5_CLIENTE = C9_CLIENTE "
		CSQL += "			AND C5_LOJACLI = C9_LOJA "
		CSQL += "			AND C5_YCLIORI      =  '' " //NÃO CONSIDERA LM
		CSQL += "			AND SC5.D_E_L_E_T_ = '' "
		CSQL += "	INNER JOIN " + RetSqlName("SA1") + " SA1 "
		CSQL += "		ON C5_CLIENTE = A1_COD "
		CSQL += "			AND C5_LOJACLI = A1_LOJA "
		CSQL += "			AND SA1.D_E_L_E_T_ = '' "
		//CSQL += "	LEFT JOIN ##TMP_ZZI AS ZZI "
		//CSQL += "		ON C5_VEND1 = ZZI_VEND "
		//CSQL += "			AND A1_YTPSEG = ZZI_TPSEG "
		//CSQL += "			AND ZZI.D_E_L_E_T_ = '' "
		CSQL += "WHERE C9_YRASTAT = '3' AND "
		//CSQL += "		C9_YRADTEX		>= CONVERT(nvarchar, GETDATE()-7 ,112) AND "
		CSQL += "		C9_YRADTEX		= CONVERT(nvarchar, GETDATE() ,112) AND "
		CSQL += "		SC9.D_E_L_E_T_ = '*' "
		If cEmpAnt $ "01_05"
			CSQL += "	UNION ALL "
			CSQL += "	SELECT SC5.C5_NUM, SC5.C5_EMISSAO, SA1.A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, "
			CSQL += " ISNULL((SELECT GERENT FROM [dbo].[GET_ZKP] (SA1.A1_YTPSEG, SC5.C5_YEMP, SA1.A1_EST, SC5.C5_VEND1, SA1.A1_YCAT, '')), '') AS COD "
			CSQL += "	FROM " + RetSqlName("SC9") + " SC9 "
			CSQL += "		INNER JOIN " + RetSqlName("SC5") + " SC5 "
			CSQL += "			ON SC5.C5_NUM = C9_PEDIDO "
			CSQL += "				AND SC5.C5_CLIENTE = C9_CLIENTE "
			CSQL += "				AND SC5.C5_LOJACLI = C9_LOJA "
			CSQL += "				AND SC5.C5_YCLIORI <> '' " //CONSIDERA LM
			CSQL += "				AND SC5.D_E_L_E_T_ =  '' "
			CSQL += "		INNER JOIN SC5070 SC5_07 "
			CSQL += "			ON SC5.C5_NUM = SC5_07.C5_YPEDORI "
			CSQL += "				AND SC5_07.C5_YEMPPED = '" + cEmpAnt + "' "
			CSQL += "				AND SC5_07.D_E_L_E_T_ = '' "
			CSQL += "		INNER JOIN " + RetSqlName("SA1") + " SA1 "
			CSQL += "			ON SC5.C5_YCLIORI = A1_COD "
			CSQL += "				AND SC5.C5_YLOJORI = A1_LOJA "
			CSQL += "				AND SA1.D_E_L_E_T_  = '' "
			//CSQL += "		LEFT JOIN ##TMP_ZZI AS ZZI "
			//CSQL += "			ON SC5_07.C5_VEND1 = ZZI_VEND "
			//CSQL += "				AND SA1.A1_YTPSEG = ZZI_TPSEG "
			//CSQL += "				AND ZZI.D_E_L_E_T_ = '' "
			CSQL += "	WHERE	C9_YRASTAT = '3' AND "
			//CSQL += "		C9_YRADTEX			>= CONVERT(nvarchar, GETDATE()-7 ,112) AND "
			CSQL += "		C9_YRADTEX = CONVERT(nvarchar, GETDATE() ,112) AND "
			CSQL += "		SC9.D_E_L_E_T_ = '*' "
		EndIf
		CSQL += "ORDER BY COD, SC5.C5_NUM "

		If chkfile("TRJ")
			dbSelectArea("TRJ")
			dbCloseArea()
		EndIf
		TcQuery cSql New Alias "TRJ"	
		GeraHtml(3) //Gerentes


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄìŽBìŽB˜¿
		//³ENVIA MENSAGEM DOS PEDIDOS LIBERADOS AGUARDANDO SALDO DE RA³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄìŽBìŽB˜Ù

		//Envia E-mail para os Vendedores
		//CSQL := ""
		//CSQL += "SELECT C5_NUM, C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, C5_VEND1 AS COD		"	
		//CSQL += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1, ##TMP_ZZI AS ZZI, "+RetSqlName("SC9")+" SC9	"
		//CSQL += "WHERE	C9_YRASTAT		= '2'			AND	"
		//CSQL += "		C9_NFISCAL		= ''			AND "
		//CSQL += "		C5_NUM			= C9_PEDIDO		AND "
		//CSQL += "		C5_CLIENTE		= C9_CLIENTE	AND "
		//CSQL += "		C5_LOJACLI		= C9_LOJA		AND "
		//CSQL += "		C5_CLIENTE		= A1_COD		AND "
		//CSQL += "		C5_LOJACLI		= A1_LOJA		AND "
		//CSQL += "		C5_VEND1		*= ZZI_VEND		AND "
		//CSQL += "		A1_YTPSEG		*= ZZI_TPSEG	AND "
		//CSQL += "		C5_YCLIORI      =  ''			AND " //NÃO CONSIDERA LM
		//CSQL += "		SC5.D_E_L_E_T_  =  ''			AND "
		//CSQL += "		SA1.D_E_L_E_T_  =  ''			AND "
		//CSQL += "		ZZI.D_E_L_E_T_  =  ''			AND "
		//CSQL += "		SC9.D_E_L_E_T_  =  ''				"
		//If cEmpAnt $ "01_05"
		//	CSQL += "UNION ALL "	
		//	CSQL += "SELECT SC5.C5_NUM, SC5.C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, SC5_07.C5_VEND1 AS COD "	
		//	CSQL += "FROM "+RetSqlName("SC5")+" SC5, SC5070 SC5_07, "+RetSqlName("SA1")+" SA1, ##TMP_ZZI AS ZZI, "+RetSqlName("SC9")+" SC9	"
		//	CSQL += "WHERE	C9_YRASTAT			=  '2'			AND	"
		//	CSQL += "		C9_NFISCAL			= ''			AND "
		// 	CSQL += "		SC5.C5_NUM			= C9_PEDIDO		AND "
		//	CSQL += "		SC5.C5_CLIENTE		= C9_CLIENTE	AND "
		//	CSQL += "		SC5.C5_LOJACLI		= C9_LOJA		AND "
		//	CSQL += "		SC5.C5_YCLIORI		= A1_COD		AND "
		//	CSQL += "		SC5.C5_YLOJORI		= A1_LOJA		AND "
		//	CSQL += "		SC5.C5_NUM			= SC5_07.C5_YPEDORI AND "
		//  	CSQL += "		SC5_07.C5_YEMPPED 	= '"+cEmpAnt+"'	AND "	
		//	CSQL += "		SC5_07.C5_VEND1		*= ZZI_VEND		AND "
		//	CSQL += "		SA1.A1_YTPSEG		*= ZZI_TPSEG	AND "
		//	CSQL += "		SC5.C5_YCLIORI      <>  ''			AND " //CONSIDERA LM
		//	CSQL += "		SC5.D_E_L_E_T_  =  ''			AND "
		// 	CSQL += "		SC5_07.D_E_L_E_T_  =  ''		AND "
		//	CSQL += "		SA1.D_E_L_E_T_  =  ''			AND "
		//	CSQL += "		ZZI.D_E_L_E_T_  =  ''			AND "
		//	CSQL += "		SC9.D_E_L_E_T_  =  ''				"
		//EndIf
		//CSQL += "ORDER BY COD, C5_NUM							"



		//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
		//os dois selects seguintes foram apagados e colocados o select novo, pra não ficar muito código comentado.
		//ambos são iguais ao select abaixo, mudando apenas a coluna COD
		CSQL := ""	
		CSQL += "SELECT C5_NUM, C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, C5_VEND1 AS COD, '' AS C5_VEND1, "
		CSQL += " (SELECT TOP 1 E1_VENCTO FROM " + RetSqlName("SE1") + " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1")) +" AND E1_CLIENTE = SA1.A1_COD AND E1_LOJA = SA1.A1_LOJA AND E1_PEDIDO = SC5.C5_NUM AND D_E_L_E_T_ = '') AS E1_VENCTO "
		CSQL += "FROM " + RetSqlName("SC9") + " SC9	"
		CSQL += "	INNER JOIN " + RetSqlName("SC5") + " SC5	"
		CSQL += "		ON C5_NUM = C9_PEDIDO	"
		CSQL += "			AND C5_CLIENTE = C9_CLIENTE	"
		CSQL += "			AND C5_LOJACLI = C9_LOJA	"
		CSQL += "			AND C5_YCLIORI = ''	" //NÃO CONSIDERA LM
		CSQL += "			AND SC5.D_E_L_E_T_ = ''	"
		CSQL += "	INNER JOIN " + RetSqlName("SA1") + " SA1	"
		CSQL += "		ON C5_CLIENTE = A1_COD	"
		CSQL += "			AND C5_LOJACLI = A1_LOJA	"
		CSQL += "			AND SA1.D_E_L_E_T_  =  ''	"
		//CSQL += "	LEFT JOIN ##TMP_ZZI AS ZZI	"
		//CSQL += "		ON C5_VEND1 = ZZI_VEND	"
		//CSQL += "			AND A1_YTPSEG = ZZI_TPSEG	"
		//CSQL += "			AND ZZI.D_E_L_E_T_ = ''	"
		CSQL += "WHERE C9_YRASTAT = '2' AND	"
		CSQL += "		C9_NFISCAL = '' AND	"
		CSQL += "		SC9.D_E_L_E_T_  =  ''	"
		If cEmpAnt $ "01_05"
			CSQL += "	UNION ALL	"
			CSQL += "	SELECT SC5.C5_NUM, SC5.C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, SC5_07.C5_VEND1 AS COD, '' AS C5_VEND1,	"
			CSQL += " (SELECT TOP 1 E1_VENCTO FROM SE1070 WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1")) +" AND E1_CLIENTE = SA1.A1_COD AND E1_LOJA = SA1.A1_LOJA AND E1_PEDIDO = SC5_07.C5_NUM AND D_E_L_E_T_ = '') AS E1_VENCTO "		
			CSQL += "	FROM " + RetSqlName("SC9") + " SC9	"
			CSQL += "		INNER JOIN " + RetSqlName("SC5") + " SC5	"
			CSQL += "			ON SC5.C5_NUM = C9_PEDIDO	"
			CSQL += "				AND SC5.C5_CLIENTE = C9_CLIENTE	"
			CSQL += "				AND SC5.C5_LOJACLI = C9_LOJA	"
			CSQL += "				AND SC5.C5_YCLIORI <> ''	" //CONSIDERA LM
			CSQL += "				AND SC5.D_E_L_E_T_ = ''	"
			CSQL += "		INNER JOIN SC5070 SC5_07	"
			CSQL += "			ON SC5.C5_NUM = SC5_07.C5_YPEDORI	"
			CSQL += "	  			AND SC5_07.C5_YEMPPED = '" + cEmpAnt + "'	"
			CSQL += "	  			AND SC5_07.D_E_L_E_T_ = ''	"
			CSQL += "	  	INNER JOIN " + RetSqlName("SA1") + " SA1	"
			CSQL += "	  		ON SC5.C5_YCLIORI = A1_COD	"
			CSQL += "				AND SC5.C5_YLOJORI = A1_LOJA	"
			CSQL += "				AND SA1.D_E_L_E_T_ = ''	"
			//CSQL += "		LEFT JOIN ##TMP_ZZI AS ZZI	"
			//CSQL += "			ON SC5_07.C5_VEND1 = ZZI_VEND	"
			//CSQL += "				AND SA1.A1_YTPSEG = ZZI_TPSEG	"
			//CSQL += "				AND ZZI.D_E_L_E_T_ = ''	"
			CSQL += "	WHERE C9_YRASTAT = '2' AND	"
			CSQL += "			C9_NFISCAL = '' AND	"
			CSQL += "			SC9.D_E_L_E_T_ = ''	"
		EndIf
		CSQL += "ORDER BY COD, C5_NUM	"


		If chkfile("TRJ")
			dbSelectArea("TRJ")
			dbCloseArea()
		EndIf
		TcQuery cSql New Alias "TRJ"	
		GeraHtml(4)    

		//Envia E-mail para os Atendentes

		//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
		//o select seguinte foi apagado e colocado o select novo, pra não ficar muito código comentado.
		//ele é iguail ao select acima, mudando apenas a coluna COD
		CSQL := ""	
		CSQL += "SELECT C5_NUM, C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, C5_VEND1, "
		CSQL += " ISNULL((SELECT ATENDE FROM [dbo].[GET_ZKP] (SA1.A1_YTPSEG, SC5.C5_YEMP, SA1.A1_EST, SC5.C5_VEND1, SA1.A1_YCAT, '')), '') AS COD, "
		CSQL += " (SELECT TOP 1 E1_VENCTO FROM " + RetSqlName("SE1") + " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1")) +" AND E1_CLIENTE = SA1.A1_COD AND E1_LOJA = SA1.A1_LOJA AND E1_PEDIDO = SC5.C5_NUM AND D_E_L_E_T_ = '') AS E1_VENCTO "	
		CSQL += "FROM " + RetSqlName("SC9") + " SC9	"
		CSQL += "	INNER JOIN " + RetSqlName("SC5") + " SC5	"
		CSQL += "		ON C5_NUM = C9_PEDIDO	"
		CSQL += "			AND C5_CLIENTE = C9_CLIENTE	"
		CSQL += "			AND C5_LOJACLI = C9_LOJA	"
		CSQL += "			AND C5_YCLIORI = ''	" //NÃO CONSIDERA LM
		CSQL += "			AND SC5.D_E_L_E_T_ = ''	"
		CSQL += "	INNER JOIN " + RetSqlName("SA1") + " SA1	"
		CSQL += "		ON C5_CLIENTE = A1_COD	"
		CSQL += "			AND C5_LOJACLI = A1_LOJA	"
		CSQL += "			AND SA1.D_E_L_E_T_  =  ''	"
	//	CSQL += "	LEFT JOIN ##TMP_ZZI AS ZZI	"
	//	CSQL += "		ON C5_VEND1 = ZZI_VEND	"
	//	CSQL += "			AND A1_YTPSEG = ZZI_TPSEG	"
	//	CSQL += "			AND ZZI.D_E_L_E_T_ = ''	"
		CSQL += "WHERE C9_YRASTAT = '2' AND	"
		CSQL += "		C9_NFISCAL = '' AND	"
		CSQL += "		SC9.D_E_L_E_T_  =  ''	"
		If cEmpAnt $ "01_05"
			CSQL += "	UNION ALL	"
			CSQL += "	SELECT SC5.C5_NUM, SC5.C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX,  SC5_07.C5_VEND1, "
			CSQL += " ISNULL((SELECT ATENDE FROM [dbo].[GET_ZKP] (SA1.A1_YTPSEG, SC5.C5_YEMP, SA1.A1_EST, SC5.C5_VEND1, SA1.A1_YCAT, '')), '') AS COD ,"
			CSQL += " (SELECT TOP 1 E1_VENCTO FROM SE1070 WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1")) +" AND E1_CLIENTE = SA1.A1_COD AND E1_LOJA = SA1.A1_LOJA AND E1_PEDIDO = SC5_07.C5_NUM AND D_E_L_E_T_ = '') AS E1_VENCTO "		
			CSQL += "	FROM " + RetSqlName("SC9") + " SC9	"
			CSQL += "		INNER JOIN " + RetSqlName("SC5") + " SC5	"
			CSQL += "			ON SC5.C5_NUM = C9_PEDIDO	"
			CSQL += "				AND SC5.C5_CLIENTE = C9_CLIENTE	"
			CSQL += "				AND SC5.C5_LOJACLI = C9_LOJA	"
			CSQL += "				AND SC5.C5_YCLIORI <> ''	" //CONSIDERA LM
			CSQL += "				AND SC5.D_E_L_E_T_ = ''	"
			CSQL += "		INNER JOIN SC5070 SC5_07	"
			CSQL += "			ON SC5.C5_NUM = SC5_07.C5_YPEDORI	"
			CSQL += "	  			AND SC5_07.C5_YEMPPED = '" + cEmpAnt + "'	"
			CSQL += "	  			AND SC5_07.D_E_L_E_T_ = ''	"
			CSQL += "	  	INNER JOIN " + RetSqlName("SA1") + " SA1	"
			CSQL += "	  		ON SC5.C5_YCLIORI = A1_COD	"
			CSQL += "				AND SC5.C5_YLOJORI = A1_LOJA	"
			CSQL += "				AND SA1.D_E_L_E_T_ = ''	"
		//	CSQL += "		LEFT JOIN ##TMP_ZZI AS ZZI	"
		//	CSQL += "			ON SC5_07.C5_VEND1 = ZZI_VEND	"
		//	CSQL += "				AND SA1.A1_YTPSEG = ZZI_TPSEG	"
		//	CSQL += "				AND ZZI.D_E_L_E_T_ = ''	"
			CSQL += "	WHERE C9_YRASTAT = '2' AND	"
			CSQL += "			C9_NFISCAL = '' AND	"
			CSQL += "			SC9.D_E_L_E_T_ = ''	"
		EndIf
		CSQL += "ORDER BY COD, C5_NUM	"	

		If chkfile("TRJ")
			dbSelectArea("TRJ")
			dbCloseArea()
		EndIf
		TcQuery cSql New Alias "TRJ"	
		GeraHtml(5) //Atendentes

		//Envia E-mail para os Gerentes

		//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
		//o select seguinte foi apagado e colocado o select novo, pra não ficar muito código comentado.
		//ele é iguail ao select acima, mudando apenas a coluna COD
		CSQL := ""	
		CSQL += "SELECT C5_NUM, C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, C5_VEND1, "
		CSQL += " ISNULL((SELECT GERENT FROM [dbo].[GET_ZKP] (SA1.A1_YTPSEG, SC5.C5_YEMP, SA1.A1_EST, SC5.C5_VEND1, SA1.A1_YCAT, '')), '') AS COD ,"
		CSQL += " (SELECT TOP 1 E1_VENCTO FROM " + RetSqlName("SE1") + " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1")) +" AND E1_CLIENTE = SA1.A1_COD AND E1_LOJA = SA1.A1_LOJA AND E1_PEDIDO = SC5.C5_NUM AND D_E_L_E_T_ = '') AS E1_VENCTO "	
		CSQL += "FROM " + RetSqlName("SC9") + " SC9	"
		CSQL += "	INNER JOIN " + RetSqlName("SC5") + " SC5	"
		CSQL += "		ON C5_NUM = C9_PEDIDO	"
		CSQL += "			AND C5_CLIENTE = C9_CLIENTE	"
		CSQL += "			AND C5_LOJACLI = C9_LOJA	"
		CSQL += "			AND C5_YCLIORI = ''	" //NÃO CONSIDERA LM
		CSQL += "			AND SC5.D_E_L_E_T_ = ''	"
		CSQL += "	INNER JOIN " + RetSqlName("SA1") + " SA1	"
		CSQL += "		ON C5_CLIENTE = A1_COD	"
		CSQL += "			AND C5_LOJACLI = A1_LOJA	"
		CSQL += "			AND SA1.D_E_L_E_T_  =  ''	"
	//	CSQL += "	LEFT JOIN ##TMP_ZZI AS ZZI	"
	//	CSQL += "		ON C5_VEND1 = ZZI_VEND	"
//		CSQL += "			AND A1_YTPSEG = ZZI_TPSEG	"
//		CSQL += "			AND ZZI.D_E_L_E_T_ = ''	"
		CSQL += "WHERE C9_YRASTAT = '2' AND	"
		CSQL += "		C9_NFISCAL = '' AND	"
		CSQL += "		SC9.D_E_L_E_T_  =  ''	"
		If cEmpAnt $ "01_05"
			CSQL += "	UNION ALL	"
			CSQL += "	SELECT SC5.C5_NUM, SC5.C5_EMISSAO, A1_NOME, C9_PRODUTO, C9_YNOMPRD, C9_QTDLIB, C9_YRASTAT, C9_YRADTEX, SC5_07.C5_VEND1, "
			CSQL += " ISNULL((SELECT GERENT FROM [dbo].[GET_ZKP] (SA1.A1_YTPSEG, SC5.C5_YEMP, SA1.A1_EST, SC5.C5_VEND1, SA1.A1_YCAT, '')), '') AS COD ,"
			CSQL += " (SELECT TOP 1 E1_VENCTO FROM SE1070 WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1")) +" AND E1_CLIENTE = SA1.A1_COD AND E1_LOJA = SA1.A1_LOJA AND E1_PEDIDO = SC5_07.C5_NUM AND D_E_L_E_T_ = '') AS E1_VENCTO "
			CSQL += "	FROM " + RetSqlName("SC9") + " SC9	"
			CSQL += "		INNER JOIN " + RetSqlName("SC5") + " SC5	"
			CSQL += "			ON SC5.C5_NUM = C9_PEDIDO	"
			CSQL += "				AND SC5.C5_CLIENTE = C9_CLIENTE	"
			CSQL += "				AND SC5.C5_LOJACLI = C9_LOJA	"
			CSQL += "				AND SC5.C5_YCLIORI <> ''	" //CONSIDERA LM
			CSQL += "				AND SC5.D_E_L_E_T_ = ''	"
			CSQL += "		INNER JOIN SC5070 SC5_07	"
			CSQL += "			ON SC5.C5_NUM = SC5_07.C5_YPEDORI	"
			CSQL += "	  			AND SC5_07.C5_YEMPPED = '" + cEmpAnt + "'	"
			CSQL += "	  			AND SC5_07.D_E_L_E_T_ = ''	"
			CSQL += "	  	INNER JOIN " + RetSqlName("SA1") + " SA1	"
			CSQL += "	  		ON SC5.C5_YCLIORI = A1_COD	"
			CSQL += "				AND SC5.C5_YLOJORI = A1_LOJA	"
			CSQL += "				AND SA1.D_E_L_E_T_ = ''	"
			//CSQL += "		LEFT JOIN ##TMP_ZZI AS ZZI	"
			//CSQL += "			ON SC5_07.C5_VEND1 = ZZI_VEND	"
			//CSQL += "				AND SA1.A1_YTPSEG = ZZI_TPSEG	"
			//CSQL += "				AND ZZI.D_E_L_E_T_ = ''	"
			CSQL += "	WHERE C9_YRASTAT = '2' AND	"
			CSQL += "			C9_NFISCAL = '' AND	"
			CSQL += "			SC9.D_E_L_E_T_ = ''	"
		EndIf
		CSQL += "ORDER BY COD, C5_NUM	"

		If chkfile("TRJ")
			dbSelectArea("TRJ")
			dbCloseArea()
		EndIf
		TcQuery cSql New Alias "TRJ"	
		GeraHtml(6) //Gerentes

		ConOut("HORA: "+TIME()+" - FINAL ROTINA BIA860 " + xv_Emps[x,1])

		//cSql := ""
		//cSql += "if exists (select 1 from Tempdb..SysObjects where Name = '##TMP_ZZI' and type = 'U' ) drop table ##TMP_ZZI "
		//TcSQLExec(cSQL)								

		If chkfile("TRJ")
			dbSelectArea("TRJ")
			dbCloseArea()
		EndIf

		//Finaliza o ambiente criado
		RpcClearEnv()

	Next

Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function GeraHtml(cOpc)
	Local 	nCod	:= ""
	Private nOpc	:= cOpc

	C_HTML  := ""

	WHILE !TRJ->(EOF())

		nCod := TRJ->COD	

		If nOpc == 2 .Or. nOpc == 5 
			psworder(1)
			pswseek(TRJ->COD,.t.)
			cEmail	:= ALLTRIM(pswret(1)[1][14])
		Else
			cEmail	:= Posicione("SA3",1,xFilial("SA3")+TRJ->COD,"A3_EMAIL")
		EndIf

		//MsgAlert(cEmail)
		//cEmail  := "ranisses.corona@biancogres.com.br"

		IF TRJ->COD <> nCod
			C_HTML  := ""
		ELSE
			C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
			C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
			C_HTML += '<head> '
			C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
			C_HTML += '<title>Untitled Document</title> '
			C_HTML += '<style type="text/css"> '
			C_HTML += '<!-- '
			C_HTML += '.style12 {font-size: 9px; } '
			C_HTML += '.style21 {color: #FFFFFF; font-size: 9px; } '
			C_HTML += '--> '
			C_HTML += '</style> '
			C_HTML += '</head> '
			C_HTML += ' '
			C_HTML += '<body> '

			C_HTML += '<table width="900" border="1"> '
			C_HTML += '  <tr> '

			If nOpc <= 3
				C_HTML += '    <th scope="col"><div align="left">Segue abaixo informações dos Pedidos/Produtos que foram estornados por falta de saldo de RA.<BR>'
			Else
				C_HTML += '    <th scope="col"><div align="left">Segue abaixo informações dos Pedidos liberados que estão aguardando saldo de RA.<BR>'
			EndIf

			C_HTML += '  </tr> '
			C_HTML += '   '
			C_HTML += '  <tr> '
			C_HTML += '    <td>&nbsp;</td> '
			C_HTML += '  </tr> '
			C_HTML += '</table> '
			C_HTML += '<table width="900" border="1"> '
			C_HTML += '   '
			C_HTML += '  <tr bgcolor="#0066CC"> '

			C_HTML += '    <th width="30" scope="col"><span class="style21"> PEDIDO </span></th> '
			C_HTML += '    <th width="20" scope="col"><span class="style21"> EMISSAO </span></th> '

			If nOpc >= 4
				C_HTML += '    <th width="20" scope="col"><span class="style21"> VENCIMENTO </span></th> '
				C_HTML += '    <th width="20" scope="col"><span class="style21"> REPRESENTANTE </span></th> '
			EndIf

			C_HTML += '    <th width="20" scope="col"><span class="style21"> CLIENTE </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> COD. PROD. </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> NOME PROD. </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> QTD. LIB. </span></th> '
			C_HTML += '  </tr> '

			WHILE !TRJ->(EOF()) .And. TRJ->COD == nCod

				C_HTML += '  <tr>
				C_HTML += '    <td class="style12"> <div align="center">'+ TRJ->C5_NUM 					+'</td> '
				C_HTML += '    <td class="style12"> <div align="center">'+ dtoc(stod(TRJ->C5_EMISSAO))	+'</td> '

				If nOpc >= 4				

					C_HTML += '    <td class="style12"> <div align="center">'+ dtoc(stod(TRJ->E1_VENCTO))	+'</td> '

					If !Empty(TRJ->C5_VEND1)
						C_HTML += '    <td class="style12"> <div align="center">'+ TRJ->C5_VEND1 +'</td> '
					Else
						C_HTML += '    <td class="style12"> <div align="center">'+ TRJ->COD +'</td> '
					EndIf

				EndIf

				C_HTML += '    <td class="style12">'+ Alltrim(TRJ->A1_NOME)		+'</td> '
				C_HTML += '    <td class="style12">'+ Alltrim(TRJ->C9_PRODUTO)	+'</td> '
				C_HTML += '    <td class="style12">'+ Substr(Alltrim(TRJ->C9_YNOMPRD),1,20)	+'</td> '
				C_HTML += '    <td class="style12"> <div align="right">'+ TRANSFORM(TRJ->C9_QTDLIB ,"@E 999,999.99") +'</td> '
				C_HTML += '  </tr>
				TRJ->(DBSKIP())
			ENDDO

			C_HTML += '</table> '
			C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder.</b></u> '
			C_HTML += '<p>&nbsp;	</p> '
			C_HTML += '</body> '
			C_HTML += '</html> '

			IF C_HTML <> ""
				//SENDMAIL()
				EnvMailMult()
			ENDIF

		ENDIF
	ENDDO

RETURN

//---------------------------------------------------------------------------------------------------
// (Thiago Dantas - 02/06/14) ***  Novo método de envio de email pegando parametros do servidor. ***
//---------------------------------------------------------------------------------------------------
Static Function EnvMailMult()

	cRecebe     := ALLTRIM(CEMAIL) 									// Email do(s) receptor(es)	
	cEmpresa	:= ""

	DO CASE
		CASE cEmpAnt == "01"
		cEmpresa := "BIANCOGRES"	// Assunto do Email
		CASE cEmpAnt == "05"
		cEmpresa := "INCESA" 		// Assunto do Email
		CASE cEmpAnt == "07"
		cEmpresa := "LM" 			// Assunto do Email
		CASE cEmpAnt == "14"
		cEmpresa := "VITCER"		// Assunto do Email
	ENDCASE

	If nOpc <= 3
		cAssunto := "Pedidos Estornados sem saldo de RA - "+cEmpresa	// Assunto do Email
	Else
		cAssunto := "Pedidos Liberados aguardando saldo de RA - "+cEmpresa	// Assunto do Email
	Endif

	cMensagem   := C_HTML
	
	U_BIAEnvMail(,cRecebe,cAssunto,cMensagem)

Return
//---------------------------------------------------------------------------------------------------