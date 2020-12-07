#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ WORK_5DIAS_CLI บAUTOR  ณBRUNO MADALENO      บ DATA ณ  28/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ WORKFLOW RESPONSAVEL EM ENVIAR OS ROMANEIOS QUE ESTAO COM MAIS   บฑฑ
ฑฑบ          ณ DE 5 DIAS EM ATRASO                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ AP 8 - R4                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION WORK_5DIAS_CLI(AA_EMPRESA)
PRIVATE ENTER			:= CHR(13)+CHR(10)
PRIVATE CEMAIL		:= ""
PRIVATE C_HTML		:= ""
PRIVATE LOK				:= .F.
PRIVATE CSQL			:= ""
Private C_HTML		:= ""
PRIVATE CCC_TEXTO	:= ""


IF TYPE("DDATABASE") <> "D"
	PREPARE ENVIRONMENT EMPRESA AA_EMPRESA FILIAL "01" MODULO "FAT" TABLES "SC5,SC6"
END IF

//If AA_EMPRESA == "01"
	CSQL := ""
	CSQL := "SELECT A1_COD, A1_LOJA, A1_EMAIL, A1_NOME																		" + Enter
	CSQL += "FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("SC6")+" SC6,	SA1010 SA1,	" + ENTER
	CSQL += "		(SELECT	C5_FILIAL, C5_NUM, C5_TIPO, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C5_YLINHA,	" + Enter
	CSQL += "							C5_VEND1 = CASE 																															" + ENTER
	CSQL += "													WHEN C5_YCLIORI <> '' AND C5_EMISSAO <= '20111231' THEN C5_VEND1 	" + ENTER
	CSQL += "													WHEN C5_YCLIORI <> '' AND C5_EMISSAO >= '20120101' THEN (SELECT MAX(C5_VEND1) FROM SC5070 WHERE C5_FILIAL = '01' AND C5_YPEDORI = C5.C5_NUM AND C5_YEMPPED = '"+AA_EMPRESA+"' AND D_E_L_E_T_ = '')  " + ENTER
	CSQL += "													ELSE C5_VEND1 " + ENTER
	CSQL += "												END,						" + ENTER
	CSQL += "				C5_YCLIORI = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END,	" + Enter
	CSQL += "				C5_YLOJORI = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END	" + Enter
	CSQL += "		FROM "+RetSqlName("SC5")+" C5														" + Enter
	CSQL += "		WHERE	C5_FILIAL = '"+xFilial("SC5")+"' AND C5.D_E_L_E_T_ = '') AS SC5				" + Enter
	CSQL += "WHERE	SC9.C9_FILIAL	= '"+xFilial("SC9")+"'	AND	" + ENTER
	CSQL += "		SA1.A1_FILIAL		= '"+xFilial("SA1")+"'	AND	" + ENTER
	CSQL += "		SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + ENTER
	CSQL += "		SC5.C5_YCLIORI	= SA1.A1_COD		AND	" + Enter
	CSQL += "		SC5.C5_YLOJORI	= SA1.A1_LOJA		AND	" + Enter
	CSQL += "		SC5.C5_NUM			= SC6.C6_NUM		AND		" + ENTER
	CSQL += "		SC5.C5_CLIENTE	= SC6.C6_CLI		AND		" + ENTER
	CSQL += "		SC5.C5_LOJACLI	= SC6.C6_LOJA		AND		" + ENTER
	CSQL += "		SC6.C6_NUM			= SC9.C9_PEDIDO 	AND 	" + ENTER
	CSQL += "		SC6.C6_PRODUTO	= SC9.C9_PRODUTO	AND 	" + ENTER
	CSQL += "		SC6.C6_ITEM			= SC9.C9_ITEM		AND 	" + ENTER
	cSql += "		SC9.C9_NFISCAL	= '' AND " + Enter
	cSql += "		SC9.C9_BLEST		= '' AND " + Enter //NOVO
	cSql += "		SC9.C9_BLCRED		= '' AND " + Enter //NOVO
	CSQL += "		SC6.C6_ENTREG		= '"+DTOS(DDATABASE)+"'	AND	" + ENTER
	CSQL += "		SC9.D_E_L_E_T_  = ''				AND 	" + ENTER
	CSQL += "		SC6.D_E_L_E_T_  = ''			  			" + ENTER
	CSQL += "GROUP BY A1_COD, A1_LOJA, A1_EMAIL, A1_NOME 	" + Enter
	CSQL += "ORDER BY A1_COD, A1_LOJA, A1_EMAIL, A1_NOME 	" + Enter

/*Else
	CSQL	:= "SELECT A1_COD, A1_LOJA, A1_EMAIL, A1_NOME																		" + Enter
	CSQL	+= "FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("SZ9")+" SZ9, SA1010 SA1, "+RetSqlName("SC6")+" SC6,				" + Enter
	CSQL	+= "		(SELECT	C5_FILIAL, C5_NUM, C5_TIPO, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C5_VEND1, C5_VEND2, C5_YLINHA,	" + Enter
	CSQL	+= "				C5_YCLIORI = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END,	" + Enter
	CSQL	+= "				C5_YLOJORI = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END	" + Enter
	CSQL	+= "		FROM "+RetSqlName("SC5")+" C5														" + Enter
	CSQL	+= "		WHERE	C5_FILIAL = '"+xFilial("SC5")+"' AND C5.D_E_L_E_T_ = '') AS SC5				" + Enter
	CSQL	+= "WHERE	SC9.C9_FILIAL	= '"+xFilial("SC9")+"'	AND		" + Enter
	CSQL	+= "		SZ9.Z9_FILIAL	= '"+xFilial("SZ9")+"'	AND		" + Enter
	CSQL	+= "		SA1.A1_FILIAL	= '"+xFilial("SA1")+"'	AND		" + Enter
	CSQL	+= "		SC6.C6_FILIAL	= '"+xFilial("SC6")+"'	AND		" + Enter
	CSQL	+= "		SC5.C5_YCLIORI	= SA1.A1_COD		AND	" + Enter
	CSQL	+= "		SC5.C5_YLOJORI	= SA1.A1_LOJA		AND	" + Enter
	CSQL	+= "		SC5.C5_NUM		= SC6.C6_NUM		AND	" + Enter
	CSQL	+= "		SC5.C5_CLIENTE	= SC6.C6_CLI		AND	" + Enter
	CSQL	+= "		SC5.C5_LOJACLI	= SC6.C6_LOJA		AND	" + Enter
	CSQL	+= "		SC6.C6_NUM		= SC9.C9_PEDIDO 	AND " + Enter
	CSQL	+= "		SC6.C6_PRODUTO	= SC9.C9_PRODUTO	AND " + Enter
	CSQL	+= "		SC6.C6_ITEM		= SC9.C9_ITEM		AND " + Enter
	CSQL	+= "		SC9.C9_PEDIDO	= SZ9.Z9_PEDIDO		AND " + Enter
	CSQL	+= "		SC9.C9_PRODUTO	= SZ9.Z9_PRODUTO	AND	" + Enter
	CSQL	+= "		SC9.C9_ITEM		= SZ9.Z9_ITEM		AND " + Enter
	CSQL	+= "		SC9.C9_AGREG	= SZ9.Z9_AGREG		AND " + Enter
	CSQL	+= "		SC9.C9_SEQUEN	= SZ9.Z9_SEQUEN		AND " + Enter
	CSQL	+= "		SC9.C9_NFISCAL	= ''    			AND " + Enter
	CSQL	+= "		SC6.C6_ENTREG	= '"+DTOS(DDATABASE)+"'	AND	" + Enter
	CSQL	+= "		SC9.D_E_L_E_T_  = ''				AND " + Enter
	CSQL	+= "		SZ9.D_E_L_E_T_  = ''				AND	" + Enter
	CSQL	+= "		SA1.D_E_L_E_T_  = ''				AND	" + Enter
	CSQL	+= "		SC6.D_E_L_E_T_  = ''			  		" + Enter
	CSQL	+= "GROUP BY A1_COD, A1_LOJA, A1_EMAIL, A1_NOME 	" + Enter
	CSQL	+= "ORDER BY A1_COD, A1_LOJA, A1_EMAIL, A1_NOME 	" + Enter
EndIf*/
IF CHKFILE("_TRAB")
	DBSELECTAREA("_TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TRAB" NEW

DO WHILE ! _TRAB->(EOF())
	
	CEMAIL	:= ALLTRIM(_TRAB->A1_EMAIL)
	CCODIGO	:= ALLTRIM(_TRAB->A1_COD)
	CNOME		:= ALLTRIM(_TRAB->A1_NOME)
	//If AA_EMPRESA == "01"
//		cSql := ""
//		cSql += "SELECT	A1_COD, A1_NOME, A1_CGC, A1_TEL, A1_BAIRRO, A1_MUN, A1_EST, Z9_PEDIDO, SUM(Z9_PESOBR) AS Z9_PESOBR, AVG(DIAS) AS DIAS  " + Enter
//		cSql += "FROM " + Enter
//		cSql += "(SELECT A4_COD, A4_NOME, A4_TEL, A3_COD, A3_NOME, A3_NREDUZ, A3_TEL, A1_COD, C5_YCLIORI, C5_YLOJORI,	" + Enter
//		cSql += "				A1_NOME = CASE	" + Enter
//		cSql += "									WHEN C5_TIPO = 'N' THEN A1_NOME ELSE (SELECT A2_NOME FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '') 	" + Enter
//		cSql += "			 					END,		" + Enter
//		cSql += "				A1_CGC = CASE 	" + Enter
//		cSql += "									WHEN C5_TIPO = 'N' THEN A1_CGC ELSE (SELECT A2_CGC FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '') 	" + Enter
//		cSql += "				 				END, 		" + Enter
//		cSql += "				A1_TEL = CASE 	" + Enter
//		cSql += "									WHEN C5_TIPO = 'N' THEN A1_TEL ELSE (SELECT A2_TEL FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '') 	" + Enter
//		cSql += "								END, 		" + Enter
//		cSql += "				GRUPO = CASE 		" + Enter
//		cSql += "									WHEN A1_GRPVEN = '' THEN A1_COD ELSE A1_GRPVEN			" + Enter
//		cSql += "				 				END,		" + Enter
//		cSql += "				NOMEGRU = CASE  " + Enter
//		cSql += "				   				WHEN A1_GRPVEN = '' AND C5_TIPO = 'N' THEN A1_NOME	" + Enter
//		cSql += "				   				WHEN A1_GRPVEN = '' AND C5_TIPO = 'B' THEN (SELECT A2_NOME FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '')		" + Enter
//		cSql += "				   				ELSE ACY_DESCRI		" + Enter
//		cSql += "	      				END, 			" + Enter
//		cSql += "				A1_BAIRRO = CASE	" + Enter
//		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN A1_BAIRRO	" + Enter
//		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT A2_BAIRRO FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '')	" + Enter
//		cSql += "									ELSE C5_YBAIRRO 	" + Enter
//		cSql += "				 				END, 			" + Enter
//		cSql += "				A1_MUN = CASE			" + Enter
//		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN A1_MUN	" + Enter
//		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT A2_MUN FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '')	" + Enter
//		cSql += "									ELSE C5_YMUN			" + Enter
//		cSql += "				 				END,			" + Enter
//		cSql += "				A1_EST = CASE 		" + Enter
//		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN A1_EST 	" + Enter
//		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT A2_EST FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '') 	" + Enter
//		cSql += "									ELSE C5_YEST 	" + Enter
//		cSql += "				 				END,			" + Enter
//		cSql += "				C6_ENTREG, C9_DATALIB AS Z9_EMISSAO, C5_EMISSAO, ((C9_QTDLIB*ZZ9_PESO)+(C9_QTDLIB2*ZZ9_PESEMB)) AS Z9_PESOBR,	" + Enter
//		cSql += "				C5_VEND1, C5_VEND2, C9_PEDIDO AS Z9_PEDIDO, C9_AGREG AS Z9_AGREG, '' AS Z9_NUMERO, C9_PRODUTO AS Z9_PRODUTO, C6_DESCRI AS Z9_DESCRIC, C6_UM AS B1_UM, C9_QTDLIB AS Z9_QTDLIB, C9_QTDLIB2 AS Z9_QTDLIB2,	" + Enter
//		cSql += "				DIAS = CASE WHEN C6_ENTREG > C9_QTDLIB THEN DATEDIFF(D,C6_ENTREG, GETDATE()) 	ELSE DATEDIFF(D,C9_QTDLIB, GETDATE()) END " + Enter
//		cSql += "FROM	" + Enter
//		cSql += "			(SELECT C5_FILIAL, C5_NUM, C5_TIPO, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C5_YLINHA,	" + Enter
//		cSql += "							C5_VEND1 = CASE " + Enter
//		cSql += "													WHEN C5_YCLIORI <> '' AND C5_EMISSAO <= '20111231' THEN C5_VEND1 " + Enter
//		cSql += "													WHEN C5_YCLIORI <> '' AND C5_EMISSAO >= '20120101' THEN (SELECT MAX(C5_VEND1) FROM SC5070 WHERE C5_FILIAL = '01' AND C5_YPEDORI = C5.C5_NUM AND C5_YEMPPED = '"+AA_EMPRESA+"' AND D_E_L_E_T_ = '')  " + Enter
//		cSql += "													ELSE C5_VEND1 " + Enter
//		cSql += "												END,		" + Enter
//		cSql += "							C5_VEND2 = CASE 	" + Enter
//		cSql += "													WHEN C5_YCLIORI <> '' AND C5_EMISSAO <= '20111231' THEN C5_VEND2	" + Enter
//		cSql += "													WHEN C5_YCLIORI <> '' AND C5_EMISSAO >= '20120101' THEN (SELECT MAX(C5_VEND2) FROM SC5070 WHERE C5_FILIAL = '01' AND C5_YPEDORI = C5.C5_NUM  AND C5_YEMPPED = '"+AA_EMPRESA+"' AND D_E_L_E_T_ = '') 	" + Enter
//		cSql += "													ELSE C5_VEND2	" + Enter
//		cSql += "												END,		" + Enter
//		cSql += "						ISNULL((SELECT MAX(C5_TRANSP) FROM SC5070 A WHERE A.C5_FILIAL = '01' AND A.C5_YPEDORI = C5.C5_NUM  AND C5_YEMPPED = '"+AA_EMPRESA+"' AND A.D_E_L_E_T_ = ''),C5_TRANSP) AS C5_TRANSP, " + Enter
//		cSql += "						C5_YCLIORI = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END,	" + Enter
//		cSql += "						C5_YLOJORI = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END,	" + Enter
//		cSql += "						C5_YFLAG, C5_YBAIRRO, C5_YMUN, C5_YEST	" + Enter
//		cSql += "			FROM "+RetSqlName("SC5")+" C5									" + Enter
//		cSql += "			WHERE	C5.C5_FILIAL 	= '"+xFilial("SC5")+"' AND C5.D_E_L_E_T_	= '') SC5, " + Enter
//		cSql += "			"+RetSqlName("SC6")+" SC6, "+RetSqlName("SC9")+" SC9, "+RetSqlName("SA1")+" SA1, "+RetSqlName("ACY")+" ACY, "+RetSqlName("SA3")+" SA3, "+RetSqlName("SA4")+" SA4, "+RetSqlName("ZZ9")+" ZZ9	" + Enter
//		cSql += "WHERE	SC6.C6_FILIAL		= '"+xFilial("SC6")+"' AND " + Enter
//		cSql += "				SC9.C9_FILIAL		= '"+xFilial("SC9")+"' AND " + Enter
//		cSql += "				SA1.A1_FILIAL		= '"+xFilial("SA1")+"' 	AND " + Enter
//		cSql += "				ACY.ACY_FILIAL	= '"+xFilial("ACY")+"' 	AND " + Enter
//		cSql += "				SA3.A3_FILIAL		= '"+xFilial("SA3")+"' 	AND " + Enter
//		cSql += "				SA4.A4_FILIAL		= '"+xFilial("SA4")+"' 	AND	" + Enter
//		cSql += "				ZZ9.ZZ9_FILIAL	= '"+xFilial("ZZ9")+"'	AND " + Enter
//		cSql += "				SC5.C5_NUM			= SC6.C6_NUM	AND	" + Enter
//		cSql += "				SC5.C5_CLIENTE	= SC6.C6_CLI	AND	" + Enter
//		cSql += "				SC5.C5_LOJACLI	= SC6.C6_LOJA	AND	" + Enter
//		cSql += "				SC5.C5_NUM			= SC9.C9_PEDIDO		AND " + Enter
//		cSql += "				SC5.C5_CLIENTE	= SC9.C9_CLIENTE	AND " + Enter
//		cSql += "				SC5.C5_LOJACLI	= SC9.C9_LOJA		AND " + Enter
//		cSql += "				SC6.C6_NUM			= SC9.C9_PEDIDO 	AND	" + Enter
//		cSql += "				SC6.C6_PRODUTO	= SC9.C9_PRODUTO	AND	" + Enter
//		cSql += "				SC6.C6_ITEM			= SC9.C9_ITEM		AND	" + Enter
//		cSql += "				SC9.C9_PRODUTO	*= ZZ9.ZZ9_PRODUT	AND " + Enter
//		cSql += "				SC9.C9_LOTECTL	*= ZZ9.ZZ9_LOTE		AND " + Enter
//		cSql += "				SC9.C9_NFISCAL	= '' AND " + Enter
//		cSql += "				SC9.C9_BLEST		= '' AND " + Enter
//		cSql += "				SC9.C9_BLCRED		= '' AND " + Enter
//		cSql += "				SC5.C5_YCLIORI	= SA1.A1_COD		AND  " + Enter
//		cSql += "				SC5.C5_YLOJORI	= SA1.A1_LOJA		AND  " + Enter
//		cSql += "				SA1.A1_GRPVEN		*= ACY.ACY_GRPVEN	AND " + Enter
//		cSql += "				SC5.C5_VEND1		= SA3.A3_COD		AND " + Enter
//		cSql += "				SC5.C5_TRANSP		= SA4.A4_COD		AND " + Enter   
//		cSql += "				SA1.A1_COD			= '"+_TRAB->A1_COD+"' AND " + Enter
//		cSql += "				SA1.A1_LOJA			= '"+_TRAB->A1_LOJA+"' AND " + Enter
//		cSql += "				SC6.C6_ENTREG		= '"+DTOS(DDATABASE)+"'	AND	" + Enter
//		cSql += "				SC6.D_E_L_E_T_	= '' AND " + Enter
//		cSql += "				SC9.D_E_L_E_T_	= '' AND " + Enter
//		cSql += "				SA1.D_E_L_E_T_	= '' AND " + Enter
//		cSql += "				ACY.D_E_L_E_T_	= '' AND " + Enter
//		cSql += "				SA3.D_E_L_E_T_	= '' AND " + Enter
//		cSql += "				SA4.D_E_L_E_T_	= '' AND " + Enter
//		cSql += "				ZZ9.D_E_L_E_T_	= '' 		 ) TTT " + Enter
//		cSql += "WHERE DIAS > 5 " + Enter
//		cSql += "GROUP BY A1_COD, A1_NOME, A1_CGC, A1_TEL, A1_BAIRRO, A1_MUN, A1_EST, Z9_PEDIDO " + Enter
		
		
		
		
		
		
		//ATUALIZAวรO QUERY - SQL ATUAL - 14/10/2015
		cSql := ""
		cSql += "SELECT	A1_COD, A1_NOME, A1_CGC, A1_TEL, A1_BAIRRO, A1_MUN, A1_EST, Z9_PEDIDO, SUM(Z9_PESOBR) AS Z9_PESOBR, AVG(DIAS) AS DIAS  " + Enter
		cSql += "FROM " + Enter
		cSql += "(SELECT A4_COD, A4_NOME, A4_TEL, A3_COD, A3_NOME, A3_NREDUZ, A3_TEL, A1_COD, C5_YCLIORI, C5_YLOJORI,	" + Enter
		cSql += "				A1_NOME = CASE	" + Enter
		cSql += "									WHEN C5_TIPO = 'N' THEN A1_NOME ELSE (SELECT A2_NOME FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '') 	" + Enter
		cSql += "			 					END,		" + Enter
		cSql += "				A1_CGC = CASE 	" + Enter
		cSql += "									WHEN C5_TIPO = 'N' THEN A1_CGC ELSE (SELECT A2_CGC FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '') 	" + Enter
		cSql += "				 				END, 		" + Enter
		cSql += "				A1_TEL = CASE 	" + Enter
		cSql += "									WHEN C5_TIPO = 'N' THEN A1_TEL ELSE (SELECT A2_TEL FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '') 	" + Enter
		cSql += "								END, 		" + Enter
		cSql += "				GRUPO = CASE 		" + Enter
		cSql += "									WHEN A1_GRPVEN = '' THEN A1_COD ELSE A1_GRPVEN			" + Enter
		cSql += "				 				END,		" + Enter
		cSql += "				NOMEGRU = CASE  " + Enter
		cSql += "				   				WHEN A1_GRPVEN = '' AND C5_TIPO = 'N' THEN A1_NOME	" + Enter
		cSql += "				   				WHEN A1_GRPVEN = '' AND C5_TIPO = 'B' THEN (SELECT A2_NOME FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '')		" + Enter
		cSql += "				   				ELSE ACY_DESCRI		" + Enter
		cSql += "	      				END, 			" + Enter
		cSql += "				A1_BAIRRO = CASE	" + Enter
		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN A1_BAIRRO	" + Enter
		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT A2_BAIRRO FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '')	" + Enter
		cSql += "									ELSE C5_YBAIRRO 	" + Enter
		cSql += "				 				END, 			" + Enter
		cSql += "				A1_MUN = CASE			" + Enter
		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN A1_MUN	" + Enter
		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT A2_MUN FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '')	" + Enter
		cSql += "									ELSE C5_YMUN			" + Enter
		cSql += "				 				END,			" + Enter
		cSql += "				A1_EST = CASE 		" + Enter
		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN A1_EST 	" + Enter
		cSql += "									WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT A2_EST FROM SA2010 WHERE A2_COD = C5_YCLIORI AND A2_LOJA = C5_YLOJORI AND D_E_L_E_T_ = '') 	" + Enter
		cSql += "									ELSE C5_YEST 	" + Enter
		cSql += "				 				END,			" + Enter
		cSql += "				C6_ENTREG, C9_DATALIB AS Z9_EMISSAO, C5_EMISSAO, ((C9_QTDLIB*ZZ9_PESO)+(C9_QTDLIB2*ZZ9_PESEMB)) AS Z9_PESOBR,	" + Enter
		cSql += "				C5_VEND1, C5_VEND2, C9_PEDIDO AS Z9_PEDIDO, C9_AGREG AS Z9_AGREG, '' AS Z9_NUMERO, C9_PRODUTO AS Z9_PRODUTO, C6_DESCRI AS Z9_DESCRIC, C6_UM AS B1_UM, C9_QTDLIB AS Z9_QTDLIB, C9_QTDLIB2 AS Z9_QTDLIB2,	" + Enter
		cSql += "				DIAS = CASE WHEN C6_ENTREG > C9_QTDLIB THEN DATEDIFF(D,C6_ENTREG, GETDATE()) 	ELSE DATEDIFF(D,C9_QTDLIB, GETDATE()) END " + Enter
		cSql += "FROM	" + Enter
		cSql += "			(SELECT C5_FILIAL, C5_NUM, C5_TIPO, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C5_YLINHA,	" + Enter
		cSql += "							C5_VEND1 = CASE " + Enter
		cSql += "													WHEN C5_YCLIORI <> '' AND C5_EMISSAO <= '20111231' THEN C5_VEND1 " + Enter
		cSql += "													WHEN C5_YCLIORI <> '' AND C5_EMISSAO >= '20120101' THEN (SELECT MAX(C5_VEND1) FROM SC5070 WHERE C5_FILIAL = '01' AND C5_YPEDORI = C5.C5_NUM AND C5_YEMPPED = '"+AA_EMPRESA+"' AND D_E_L_E_T_ = '')  " + Enter
		cSql += "													ELSE C5_VEND1 " + Enter
		cSql += "												END,		" + Enter
		cSql += "							C5_VEND2 = CASE 	" + Enter
		cSql += "													WHEN C5_YCLIORI <> '' AND C5_EMISSAO <= '20111231' THEN C5_VEND2	" + Enter
		cSql += "													WHEN C5_YCLIORI <> '' AND C5_EMISSAO >= '20120101' THEN (SELECT MAX(C5_VEND2) FROM SC5070 WHERE C5_FILIAL = '01' AND C5_YPEDORI = C5.C5_NUM  AND C5_YEMPPED = '"+AA_EMPRESA+"' AND D_E_L_E_T_ = '') 	" + Enter
		cSql += "													ELSE C5_VEND2	" + Enter
		cSql += "												END,		" + Enter
		cSql += "						ISNULL((SELECT MAX(C5_TRANSP) FROM SC5070 A WHERE A.C5_FILIAL = '01' AND A.C5_YPEDORI = C5.C5_NUM  AND C5_YEMPPED = '"+AA_EMPRESA+"' AND A.D_E_L_E_T_ = ''),C5_TRANSP) AS C5_TRANSP, " + Enter
		cSql += "						C5_YCLIORI = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END,	" + Enter
		cSql += "						C5_YLOJORI = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END,	" + Enter
		cSql += "						C5_YFLAG, C5_YBAIRRO, C5_YMUN, C5_YEST	" + Enter
		cSql += "				FROM "+RetSqlName("SC5")+" C5									" + Enter
		cSql += "		   		WHERE	C5.C5_FILIAL 	= '"+xFilial("SC5")+"' AND C5.D_E_L_E_T_	= '') SC5 " + Enter
		cSql += "		INNER JOIN " + RetSqlName("SC6") + " SC6 " + Enter
		cSql += "			ON SC5.C5_NUM = SC6.C6_NUM	 " + Enter
		cSql += "				AND SC5.C5_CLIENTE = SC6.C6_CLI " + Enter
		cSql += "				AND SC5.C5_LOJACLI = SC6.C6_LOJA " + Enter
		cSql += "				AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' " + Enter
		cSql += "				AND SC6.C6_ENTREG = '"+DTOS(DDATABASE)+"' " + Enter
		cSql += "				AND SC6.D_E_L_E_T_ = '' " + Enter
		cSql += "		INNER JOIN " + RetSqlName("SC9") + " SC9 " + Enter
		cSql += "			ON SC5.C5_NUM = SC9.C9_PEDIDO " + Enter
		cSql += "				AND SC5.C5_CLIENTE = SC9.C9_CLIENTE " + Enter
		cSql += "				AND SC5.C5_LOJACLI = SC9.C9_LOJA " + Enter
		cSql += "				AND SC6.C6_NUM = SC9.C9_PEDIDO " + Enter
		cSql += "				AND SC6.C6_PRODUTO = SC9.C9_PRODUTO " + Enter
		cSql += "				AND SC6.C6_ITEM = SC9.C9_ITEM " + Enter
		cSql += "				AND SC9.C9_FILIAL = '" + xFilial("SC9") + "' " + Enter
		cSql += "				AND SC9.C9_NFISCAL = '' " + Enter
		cSql += "				AND SC9.C9_BLEST = '' " + Enter
		cSql += "				AND SC9.C9_BLCRED = '' " + Enter
		cSql += "				AND SC9.D_E_L_E_T_ = '' " + Enter
		cSql += "		INNER JOIN " + RetSqlName("SA1") + " SA1 " + Enter
		cSql += "			ON SC5.C5_YCLIORI = SA1.A1_COD " + Enter
		cSql += "				AND SC5.C5_YLOJORI	= SA1.A1_LOJA " + Enter
		cSql += "				AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " + Enter
		cSql += "				AND SA1.A1_COD = '"+_TRAB->A1_COD+"' " + Enter
		cSql += "				AND SA1.A1_LOJA = '"+_TRAB->A1_LOJA+"' " + Enter
		cSql += "				AND SA1.D_E_L_E_T_ = '' " + Enter
		cSql += "		LEFT JOIN " + RetSqlName("ACY") + " ACY " + Enter
		cSql += "			ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN " + Enter
		cSql += "				AND ACY.ACY_FILIAL = '" + xFilial("ACY") + "' " + Enter
		cSql += "				AND ACY.D_E_L_E_T_ = '' " + Enter
		cSql += "		INNER JOIN " + RetSqlName("SA3") + " SA3 " + Enter
		cSql += "			ON SC5.C5_VEND1 = SA3.A3_COD " + Enter
		cSql += "				AND SA3.A3_FILIAL = '" + xFilial("SA3") + "' " + Enter
		cSql += "				AND SA3.D_E_L_E_T_ = '' " + Enter
		cSql += "		INNER JOIN " + RetSqlName("SA4") + " SA4 " + Enter
		cSql += "			ON SC5.C5_TRANSP= SA4.A4_COD " + Enter
		cSql += "				AND SA4.A4_FILIAL = '" + xFilial("SA4") + "' " + Enter
		cSql += "				AND SA4.D_E_L_E_T_ = '' " + Enter
		cSql += "		LEFT JOIN " + RetSqlName("ZZ9") + " ZZ9 " + Enter
		cSql += "			ON SC9.C9_PRODUTO = ZZ9.ZZ9_PRODUT " + Enter
		cSql += "				AND SC9.C9_LOTECTL = ZZ9.ZZ9_LOTE " + Enter
		cSql += "				AND ZZ9.ZZ9_FILIAL = '" + xFilial("ZZ9") + "' " + Enter
		cSql += "				AND ZZ9.D_E_L_E_T_ = '') TTT  " + Enter
		cSql += "WHERE DIAS > 5  " + Enter
		cSql += "GROUP BY A1_COD, A1_NOME, A1_CGC, A1_TEL, A1_BAIRRO, A1_MUN, A1_EST, Z9_PEDIDO "
				
	/*Else
		cSql := ""
		CSQL	:= "SELECT	A1_COD, A1_NOME, A1_CGC, A1_TEL, A1_BAIRRO, A1_MUN, A1_EST, Z9_PEDIDO, SUM(Z9_PESOBR) AS Z9_PESOBR, AVG(DIAS) AS DIAS  " + Enter
		CSQL	+= "FROM  																						" + Enter
		CSQL	+= "	(SELECT DIAS = CASE WHEN C6_ENTREG > Z9_EMISSAO THEN DATEDIFF(D,C6_ENTREG, GETDATE())	" + Enter
		CSQL	+= "						ELSE DATEDIFF(D,Z9_EMISSAO, GETDATE()) END  , * FROM   " + Enter
		CSQL	+= "(
		CSQL	+= "SELECT	A1_COD,  		" + Enter
		CSQL	+= "		A1_NOME = CASE  " + Enter
		CSQL	+= "					WHEN C5_TIPO = 'N' THEN A1_NOME  " + Enter
		CSQL	+= "					ELSE (SELECT A2_NOME FROM SA2010 WHERE A2_COD = C5_YCLIORI AND D_E_L_E_T_ = '')  " + Enter
		CSQL	+= "				 END,  " + Enter
		CSQL	+= "		A1_CGC = CASE  " + Enter
		CSQL	+= "					WHEN C5_TIPO = 'N' THEN A1_CGC  " + Enter
		CSQL	+= "					ELSE (SELECT A2_CGC FROM SA2010 WHERE A2_COD = C5_YCLIORI AND D_E_L_E_T_ = '')  " + Enter
		CSQL	+= "				 END,  " + Enter
		CSQL	+= "		A1_TEL = CASE  " + Enter
		CSQL	+= "					WHEN C5_TIPO = 'N' THEN A1_TEL  " + Enter
		CSQL	+= "					ELSE (SELECT A2_TEL FROM SA2010 WHERE A2_COD = C5_YCLIORI AND D_E_L_E_T_ = '')  " + Enter
		CSQL	+= "				 END,  " + Enter
		CSQL	+= "		A1_BAIRRO = CASE  " + Enter
		CSQL	+= "					WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN A1_BAIRRO  " + Enter
		CSQL	+= "					WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT A2_BAIRRO FROM SA2010 WHERE A2_COD = C5_YCLIORI AND D_E_L_E_T_ = '')  " + Enter
		CSQL	+= "					ELSE C5_YBAIRRO  " + Enter
		CSQL	+= "				 END,  " + Enter
		CSQL	+= "		A1_MUN = CASE  " + Enter
		CSQL	+= "					WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN A1_MUN  " + Enter
		CSQL	+= "					WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT A2_MUN FROM SA2010 WHERE A2_COD = C5_YCLIORI AND D_E_L_E_T_ = '')  " + Enter
		CSQL	+= "					ELSE C5_YMUN  " + Enter
		CSQL	+= "				 END,  " + Enter
		CSQL	+= "		A1_EST = CASE  " + Enter
		CSQL	+= "					WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN A1_EST  " + Enter
		CSQL	+= "					WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT A2_EST FROM SA2010 WHERE A2_COD = C5_YCLIORI AND D_E_L_E_T_ = '')  " + Enter
		CSQL	+= "					ELSE C5_YEST  " + Enter
		CSQL	+= "				 END,  " + Enter
		CSQL	+= "		(SELECT C6.C6_ENTREG FROM " + RetSqlName("SC6") + " AS C6 WHERE C6.C6_FILIAL = '01' AND C6.C6_NUM = C9_PEDIDO AND C6.C6_PRODUTO = C9_PRODUTO AND C6.C6_ITEM = C9_ITEM AND C6.D_E_L_E_T_ = '') C6_ENTREG ,  " + Enter
		CSQL	+= "		Z9_EMISSAO, C5_EMISSAO, Z9_PESOBR, C5_VEND1, C5_VEND2, Z9_PEDIDO, Z9_AGREG, Z9_NUMERO, Z9_PRODUTO, Z9_DESCRIC, B1_UM, Z9_QTDLIB, Z9_QTDLIB2  " + Enter
		CSQL	+= "FROM	(SELECT C5_FILIAL, C5_NUM, C5_TIPO, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C5_VEND1, C5_VEND2, C5_YLINHA,	" + Enter     
		CSQL	+= "			   C5_YCLIORI = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END, 				" + Enter     
		CSQL	+= "			   C5_YLOJORI = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END,   			" + Enter     
		CSQL	+= "			   C5_YFLAG, C5_YBAIRRO, C5_YMUN, C5_YEST 													" + Enter     
		CSQL	+= "		FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SC6")+" C6											" + Enter     
		CSQL	+= "		WHERE	C5_FILIAL 	= '"+xFilial("SC5")+"' AND 	" + Enter     
		CSQL	+= "				C6_FILIAL 	= '"+xFilial("SC6")+"' AND 	" + Enter     
		CSQL	+= "				C5_NUM		= C6_NUM		AND " + Enter
		CSQL	+= "				C5_CLIENTE	= C6_CLI		AND " + Enter
		CSQL	+= "				C5_LOJACLI	= C6_LOJA		AND " + Enter
		CSQL	+= "				C6_ENTREG	= '"+DTOS(DDATABASE)+"' AND   " + Enter
		CSQL	+= "				C5.D_E_L_E_T_ = '' 			AND " + Enter
		CSQL	+= "				C6.D_E_L_E_T_ = '' 				" + Enter
		CSQL	+= "		GROUP BY  C5_FILIAL, C5_NUM, C5_TIPO, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C5_VEND1, C5_VEND2, C5_YLINHA, C5_TRANSP, C5_YCLIORI, C5_YLOJORI, C5_YFLAG, C5_YBAIRRO, C5_YMUN, C5_YEST	) AS SC5," + Enter
		CSQL	+= "		" + RetSqlName("SC9") + " SC9,  " + Enter
		CSQL	+= "		(SELECT Z9_PEDIDO, Z9_AGREG, Z9_NUMERO, Z9_PRODUTO, Z9_DESCRIC, B1_UM, Z9_ITEM, Z9_SEQUEN, Z9_EMISSAO, SUM(Z9_QTDLIB) Z9_QTDLIB, SUM(Z9_QTDLIB2) Z9_QTDLIB2, SUM((Z9_QTDLIB*ZZ9_PESO)+(Z9_QTDLIB2*ZZ9_PESEMB)) AS Z9_PESOBR   " + Enter
		cSql 	+= "				FROM "+RetSqlName("SZ9")+" SZ9, ZZ9010 ZZ9, SB1010 SB1, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SC9")+" SC9 " + Enter
		CSQL	+= "				WHERE	SZ9.Z9_FILIAL	= '"+xFilial("SZ9")+"'	AND   " + Enter
		CSQL	+= "						ZZ9.ZZ9_FILIAL	= '"+xFilial("ZZ9")+"'	AND   " + Enter
		CSQL	+= "						SC9.C9_FILIAL	= '"+xFilial("SC9")+"'	AND   " + Enter	
		CSQL	+= "						SB1.B1_FILIAL 	= '"+xFilial("SB1")+"'	AND   " + Enter
		CSQL	+= "						SZ9.Z9_PRODUTO	= ZZ9.ZZ9_PRODUT		AND   " + Enter
		CSQL	+= "						SZ9.Z9_PRODUTO	= SB1.B1_COD		AND   " + Enter
		CSQL	+= "						SZ9.Z9_LOTECTL	= ZZ9.ZZ9_LOTE		AND   " + Enter
		CSQL	+= "						SZ9.D_E_L_E_T_ = '' AND   " + Enter
		CSQL	+= "						SB1.D_E_L_E_T_ = '' AND  ZZ9.D_E_L_E_T_ = ''  " + Enter
		CSQL	+= "						AND SC6.D_E_L_E_T_ = ''  AND SC9.D_E_L_E_T_ = ''   " + Enter
		CSQL	+= "		  " + Enter
		CSQL	+= "						AND C6_NUM = C9_PEDIDO 	AND C6_PRODUTO = C9_PRODUTO  " + Enter
		CSQL	+= "						AND C6_ITEM = C9_ITEM AND C9_NFISCAL = ''  " + Enter
		CSQL	+= "						AND C9_PEDIDO	= Z9_PEDIDO	AND C9_PRODUTO	= Z9_PRODUTO  " + Enter
		CSQL	+= "						AND C9_ITEM		= Z9_ITEM	AND C9_AGREG	= Z9_AGREG	 " + Enter
		CSQL	+= "						AND C9_SEQUEN	= Z9_SEQUEN	AND C6_ENTREG	= '"+DTOS(DDATABASE)+"'  " + Enter
		CSQL	+= "		GROUP BY Z9_PEDIDO, Z9_AGREG, Z9_NUMERO, Z9_PRODUTO, Z9_DESCRIC, B1_UM, Z9_ITEM, Z9_SEQUEN, Z9_EMISSAO) AS SZ9,  " + Enter
		CSQL 	+= "		" + RetSqlName("SA1") + " SA1 " + Enter
		CSQL	+= "WHERE	A1_FILIAL	= '"+xFilial("SA1")+"' 	AND " + Enter
		CSQL	+= "		C5_NUM		= C9_PEDIDO		AND  		" + Enter
		CSQL	+= "		C5_CLIENTE	= C9_CLIENTE	AND C5_LOJACLI	= C9_LOJA		AND " + Enter
		CSQL	+= "		C9_PEDIDO	= Z9_PEDIDO		AND C9_AGREG	= Z9_AGREG		AND " + Enter
		CSQL	+= "		C9_PRODUTO	= Z9_PRODUTO	AND C9_AGREG	= Z9_AGREG		AND " + Enter
		CSQL	+= "		C9_ITEM		= Z9_ITEM		AND C9_SEQUEN	= Z9_SEQUEN		AND " + Enter
		CSQL	+= "		C9_NFISCAL	= ''			AND C9_BLEST	= ''			AND " + Enter
		CSQL	+= "		C9_BLCRED	= ''			AND C5_YCLIORI	= A1_COD		AND	" + Enter
		CSQL	+= "		C5_LOJACLI	= A1_LOJA		AND 								" + Enter
		CSQL	+= "		A1_MSBLQL	<> '1'			AND	" + Enter	
		CSQL	+= "		A1_COD		= '"+_TRAB->A1_COD+"' AND A1_LOJA = '"+_TRAB->A1_LOJA+"' AND " + Enter
		CSQL	+= "		SC9.D_E_L_E_T_ = ''			AND	" + Enter
		CSQL	+= "		SA1.D_E_L_E_T_ = ''				" + Enter	
		CSQL	+= "		) AS TTT						" + Enter
		CSQL	+= "		) AS TT							" + Enter
		CSQL	+= "		WHERE DIAS > 5  				" + Enter
		CSQL	+= "GROUP BY A1_COD, A1_NOME, A1_CGC, A1_TEL, A1_BAIRRO, A1_MUN, A1_EST, Z9_PEDIDO " + Enter
	EndIf*/
	IF CHKFILE("_TRAB_AUX")
		DBSELECTAREA("_TRAB_AUX")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_TRAB_AUX" NEW
	
	NTO_GE_QU := 0
	NTO_GE_PE := 0
	NTO_GE_DI := 0
	NTO_DIAS  := 0
	IF ! _TRAB_AUX->(EOF())
		
		IF ALLTRIM(CEMAIL) <> ""
			C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
			C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
			C_HTML += '<head> '
			C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
			C_HTML += '<title>Untitled Document</title> '
			C_HTML += '<style type="text/css"> '
			C_HTML += '<!-- '
			C_HTML += '.style12 {font-size: 9px; } '
			C_HTML += '.style18 {font-size: 10} '
			C_HTML += '.style21 {color: #FFFFFF; font-size: 9px; } '
			C_HTML += '.style22 { '
			C_HTML += '	font-size: 10pt; '
			C_HTML += '	font-weight: bold; '
			C_HTML += '} '
			C_HTML += '.style35 {font-size: 10pt; } '
			C_HTML += '.style36 {font-size: 9pt; } '
			C_HTML += '.style39 {font-size: 12pt; } '
			C_HTML += '.style41 { '
			C_HTML += '	font-size: 12px; '
			C_HTML += '	font-weight: bold; '
			C_HTML += '} '
			C_HTML += ' '
			C_HTML += '--> '
			C_HTML += '</style> '
			C_HTML += '</head> '
			C_HTML += ' '
			C_HTML += '<body> '
			C_HTML += '<table width="956" border="1"> '
			C_HTML += '  <tr> '
			C_HTML += '    <th width="751" rowspan="3" scope="col"> PEDIDOS DISPONIBILIZADOS PARA RETIRADA COM MAIS DE 5 DIAS DE ATRASO </th> '
			C_HTML += '    <td width="189" class="style12"><div align="right"> DATA EMISSรO: '+ dtoC(DDATABASE) +' </div></td> '
			C_HTML += '  </tr> '
			C_HTML += '  <tr> '
			C_HTML += '    <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+SUBS(TIME(),1,8)+' </div></td> '
			C_HTML += '  </tr> '
			C_HTML += '  <tr> '
			IF CEMPANT = "05"
				C_HTML += '    <td><div align="center" class="style41"> INCESA CERAMICA LTDA </div></td> '
			ELSE
				C_HTML += '    <td><div align="center" class="style41"> BIANCOGRES CERยMICA SA </div></td> ' '
			END IF
			C_HTML += '  </tr> '
			C_HTML += '</table> '
			
			C_HTML += '<table width="956" border="1"> '
			
			// CLIENTE
			C_HTML += '  <tr bgcolor="#FFFFFF"> '
			C_HTML += '    <th colspan="5" scope="col"><div align="left" class="style39">Cliente: '+ _TRAB_AUX->A1_COD +' - '+ _TRAB_AUX->A1_NOME + ' - CGC: '+ _TRAB_AUX->A1_CGC +' </div></th> '
			C_HTML += '  </tr> '
			
			// CABECALHO
			C_HTML += '  <tr bgcolor="#0066CC"> '
			C_HTML += '    <th width="223"	scope="col"><span class="style21"> Produto  </span></th> '
			C_HTML += '    <th width="380" scope="col"><span class="style21"> Descri็ใo </span></th> '
			C_HTML += '    <th width="132" 	scope="col"><span class="style21"> Quantidade </span></th> '
			C_HTML += '    <th width="126" scope="col"><span class="style21"> Peso </span></th> '
			C_HTML += '    <th width="61" scope="col"><span class="style21"> Tempo M้dio </span></th> '
			C_HTML += '  </tr>
			
			
			
			S_PEDIDO 	:= ""
			NTOT_QUANT 	:= 0
			NTOT_PESO  	:= 0
			NTOT_DIAS 	:= 0
			NQUANT 		:= 0
			DO WHILE ! _TRAB_AUX->(EOF())
				// VENDEDOR
				IF S_PEDIDO <> _TRAB_AUX->Z9_PEDIDO
					S_PEDIDO := _TRAB_AUX->Z9_PEDIDO
					IF NTOT_QUANT <> 0
						C_HTML += ' <tr>
						C_HTML += '    <td colspan="2" class="style18"><span class="style22">Total do Pedido : '+SS_PEDIDO +'  </span></td> '
						C_HTML += '    <td class="style35"> <div align="right"> '+TRANSFORM(NTOT_QUANT	,"@E 999,999,999.99")+' </div></td> '
						C_HTML += ' 	 <td class="style35"> <div align="right"> '+TRANSFORM(NTOT_PESO	,"@E 999,999,999")+' </div></td> '
						C_HTML += '  	 <td class="style35"> <div align="right"> '+TRANSFORM(NTOT_DIAS/NQUANT	,"@E 999,999,999")+' </div></td> '
						C_HTML += '  </tr> '
					END IF
					NTOT_QUANT := 0
					NTOT_PESO  	:= 0
					NTOT_DIAS 	:= 0
					NQUANT := 0
					
					C_HTML += '  <tr bordercolor="#FFFFFF"> '
					C_HTML += '    <td colspan="5">&nbsp;</td> '
					C_HTML += '  </tr> '
					
					C_HTML += '   <tr bgcolor="#FFFFFF"> '
					C_HTML += '    <th colspan="5" scope="col"><div align="left" class="style39">Pedido N&ordm; '+S_PEDIDO + ' - TIPO DE PEDIDO: ' + _TRAB_AUX->TIPO + ' </div></th> '
					C_HTML += '  </tr> '
					
				END IF
				
				C_HTML += '  <tr> '
				C_HTML += '    <td class="style12"> '+_TRAB_AUX->Z9_PRODUTO+' </td> '
				C_HTML += '    <td class="style12"> '+ALLTRIM(_TRAB_AUX->Z9_DESCRIC)+' </td> '
				C_HTML += '    <td class="style12"> <div align="right"> '+TRANSFORM(_TRAB_AUX->Z9_QTDLIB	,"@E 999,999,999.99")+' </td> '
				C_HTML += '    <td class="style12"> <div align="right"> '+TRANSFORM(_TRAB_AUX->Z9_PESOBR	,"@E 999,999,999")+' </td> '
				C_HTML += '    <td class="style12"> <div align="right"> '+TRANSFORM(_TRAB_AUX->DIAS	,"@E 999,999,999")+' </td> '
				C_HTML += '  </tr>
				NTOT_QUANT 	+= _TRAB_AUX->Z9_QTDLIB
				NTOT_PESO  	+= _TRAB_AUX->Z9_PESOBR
				NTOT_DIAS 	+= _TRAB_AUX->DIAS
				NTO_GE_QU 	+= _TRAB_AUX->Z9_QTDLIB
				NTO_GE_PE 	+= _TRAB_AUX->Z9_PESOBR
				NTO_GE_DI 	+= _TRAB_AUX->DIAS
				NQUANT		++
				NTO_DIAS	++
				
				SS_CLIENTE 	:= + _TRAB_AUX->A1_COD +' - '+ _TRAB_AUX->A1_NOME
				SS_PEDIDO 	:= _TRAB_AUX->Z9_PEDIDO
				_TRAB_AUX->(DBSKIP())
			END DO
			
			C_HTML += ' <tr>
			C_HTML += '    <td colspan="2" class="style18"><span class="style22">Total do Pedido : '+SS_PEDIDO +'  </span></td> '
			C_HTML += '    <td class="style35"> <div align="right"> '+TRANSFORM(NTOT_QUANT	,"@E 999,999,999.99")+' </div></td> '
			C_HTML += ' 	 <td class="style35"> <div align="right"> '+TRANSFORM(NTOT_PESO	,"@E 999,999,999")+' </div></td> '
			C_HTML += '  	 <td class="style35"> <div align="right"> '+TRANSFORM(NTOT_DIAS/NQUANT	,"@E 999,999,999")+' </div></td> '
			C_HTML += '  </tr> '
			
			
			C_HTML += '<tr bordercolor="#FFFFFF" class="style18"> '
			C_HTML += '    <td colspan="5" class="style36">&nbsp;</td> '
			C_HTML += '  </tr> '
			
			C_HTML += '  <tr bgcolor="#FFFFFF">'
			C_HTML += '    <th colspan="2" scope="col"><div align="left" class="style35">Total por Cliente: '+ SS_CLIENTE +' </div></th>'
			C_HTML += '     <td class="style35"> <div align="right"> '+TRANSFORM(NTO_GE_QU	,"@E 999,999,999.99")+' </div></td>'
			C_HTML += ' 	 <td class="style35"> <div align="right"> '+TRANSFORM(NTO_GE_PE	,"@E 999,999,999")+' </div></td>'
			C_HTML += '  	 <td class="style35"> <div align="right"> '+TRANSFORM(NTO_GE_DI / NTO_DIAS	,"@E 999,999,999")+' </div></td>'
			C_HTML += '  </tr>
			
			C_HTML += '  <tr bordercolor="#FFFFFF" class="style18"> '
			C_HTML += '    <td colspan="5" class="style12">&nbsp;</td> '
			C_HTML += '  </tr> '
			C_HTML += '</table> '
			C_HTML += 'Esta ษ uma mensagem automมtica, favor nใo responde-la.'
			C_HTML += '</body> '
			C_HTML += '</html> '
			
			COMIS_EMAIL()
		ELSE
			CCC_TEXTO += 'EMAIL NรO CADASTRADO NO CLIENTE: ' + CCODIGO +' - '+ CNOME + Enter
		END IF
	END IF
	_TRAB->(DBSKIP())
END DO

IF ALLTRIM(CCC_TEXTO) <> ""
	EMA_N_CADAS(CCC_TEXTO)
END IF

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบ COMIS_EMAIL         บAutor  ณ MADALENO           บ Data ณ  26/06/07   บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.       ROTINA PARA GERAR O EMAIL E ENVIAR O MESMO                 บฑฑฒ
ฒฑฑบ                                                                       บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION COMIS_EMAIL()

Local lOk

IF CEMPANT == "01"
	cRecebe		:= CEMAIL 
	cRecebeCC	:= "" //;ranisses.corona@biancogres.com.br" 
	cAssunto	:= 'BIANCOGRES - RELAวรO DE ROMANEIO POR CLIENTE '	
ELSE
	cRecebe		:= CEMAIL 
	cRecebeCC	:= "tatiane.perpetua@biancogres.com.br" //;ranisses.corona@biancogres.com.br"
	cAssunto	:= 'INCESA - RELAวรO DE ROMANEIO POR CLIENTE '
END IF


lOK := U_BIAEnvMail(,cRecebe,cAssunto,C_HTML,,,.F.,cRecebeCC)

IF !lOK
	EMA_N_CADAS("EMAIL INVมLIDO: " + _TRAB_AUX->A1_COD +' - '+ _TRAB_AUX->A1_NOME + ' - ' + CEMAIL)
ENDIF

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบ EMA_N_CADAS         บAutor  ณ MADALENO           บ Data ณ  26/06/07   บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.       ROTINA PARA GERAR O EMAIL PARA CLAUDEIR QUANDO O EMAIL     บฑฑฒ
ฒฑฑบ            DER ERRO.                                                  บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION EMA_N_CADAS(CCMENSAGEM)  

IF CEMPANT == "01"
	cRecebe		:= "" //;ranisses.corona@biancogres.com.br"
	cRecebeCC	:= "" 
ELSE
	cRecebe		:= "tatiane.perpetua@biancogres.com.br" //;ranisses.corona@biancogres.com.br" 
	cRecebeCC	:= ""
END IF
cAssunto	:= 'EMAIL NรO CADASTRADO DO CLIENTE: ' //+ CCODIGO +' - '+ CNOME
      
U_BIAEnvMail(,cRecebe,cAssunto,CCMENSAGEM,,,.F.)

RETURN
