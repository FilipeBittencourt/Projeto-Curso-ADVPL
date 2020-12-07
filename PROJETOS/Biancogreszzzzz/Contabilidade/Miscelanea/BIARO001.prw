#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Rodrigo Ribeiro Agostini
Programa  := BIARO001
Empresa   := Biancogres Cerâmica S/A
Data      := 30/01/19
Uso       := Controladoria / Contabilidade
Projeto	  := A-13 Portaria Fiscal
Aplicação := Relatórios de Conferência
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIARO001()

	Local aPergs := {}
	Private aRet   := {1,ctod("  /  /  "),ctod("  /  /  ")}
	Private oExcel := FWMSEXCEL():New()
	Private Enter := chr(13) + Chr(10)	

	If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
	EndIf

	aAdd( aPergs ,{2, "Relatórios de Conferência", "1", {"1=Diferença entre Impostos DESCONTINUADO","2=Custo","3=SF1 / SF3","4=Conferência CFOP DESCONTINUADO"}, 100,".T.",.F.})
	aAdd( aPergs ,{1, "De Data (Digitação)" , FirstDate(dDataBase), , ".T.", ,".T.", 50, .F.})
	aAdd( aPergs ,{1, "Até Data (Digitação)", LastDate(dDataBase), , ".T.", ,".T.", 50, .F.})

	If !ParamBox(aPergs, "Parâmetros do Relatório", aRet, , , , , , , , .F., .F.)
		Return
	EndIf

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	If aRet[1] == "1"
		Alert("Este relatório foi descontinuado.")
		Return
		//RlConf001()			
		//cNomeRel := "dif_impostos"
	EndIf

	If aRet[1] == "2"
		RlConf002()
		cNomeRel := "dif_custo"	
	EndIf

	If aRet[1] == "3"
		RlConf003()		
		cNomeRel := "sf1_x_sf3"	
	EndIf

	If aRet[1] == "4"
		Alert("Este relatório foi descontinuado.")
		Return		
		//RlConf004()	
		//cNomeRel := "cfop"	
	EndIf

	xArqTemp := "BIARO001_Conferencia_"+cNomeRel+"_"+cEmpAnt

	If File("C:\TEMP\"+xArqTemp+".xml")
		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

/* ------------------------------------- */
/* RELATÓRIO : Diferença entre Impostos  */
/* ------------------------------------- */
Static Function RlConf001()

	cTabelaPth = RecDadosProtheus()
	cTabelaCnx = RecDadosConexao()

	nxPlan1 := "PROTHEUS x CONEXAO"
	oExcel:AddworkSheet(nxPlan1)

	/* TAB 1 */
	nxTab1 := "DIFERENÇA  ENTRE LANÇAMENTOS ( PROTHEUS X CONEXÃO )"

	oExcel:AddTable (nxPlan1, nxTab1)
	oExcel:AddColumn(nxPlan1, nxTab1, "NUMERO",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "SERIE",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "CNPJ",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "EMISSAO",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "TOTALNF",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "BCICMS",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "ICMS",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "IPI",1,1)	
	oExcel:AddColumn(nxPlan1, nxTab1, "PR_ESPECIE",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "CX_ESPECIE",1,1)		
	oExcel:AddColumn(nxPlan1, nxTab1, "PR_NF",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "CX_NF",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "PR_SERIE",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "CX_SERIE",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "PR_CNPJ",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "CX_CNPJ",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "PR_EMISSAO",1,4)
	oExcel:AddColumn(nxPlan1, nxTab1, "CX_EMISSAO",1,4)
	oExcel:AddColumn(nxPlan1, nxTab1, "PR_VALOR",1,3)
	oExcel:AddColumn(nxPlan1, nxTab1, "CX_VALOR",1,3)
	oExcel:AddColumn(nxPlan1, nxTab1, "PR_BASE ICMS",1,3)
	oExcel:AddColumn(nxPlan1, nxTab1, "CX_BASE ICMS",1,3)
	oExcel:AddColumn(nxPlan1, nxTab1, "PR_VALOR ICMS",1,3)
	oExcel:AddColumn(nxPlan1, nxTab1, "CX_VALOR ICMS",1,3)
	oExcel:AddColumn(nxPlan1, nxTab1, "PR_VALOR IPI",1,3)
	oExcel:AddColumn(nxPlan1, nxTab1, "CX_VALOR IPI",1,3)

	SQL001 := "SELECT(CASE P.NF WHEN C.NF THEN 'OK' ELSE 'ERRADO' END) AS 'NUMERO', "
	SQL001 += "      (CASE P.SERIE WHEN C.SERIE THEN 'OK' ELSE 'ERRADO' END) AS 'SERIE', "
	SQL001 += "      (CASE P.CNPJ WHEN C.CNPJ THEN 'OK' ELSE 'ERRADO' END) AS 'CNPJ', "
	SQL001 += "      (CASE P.EMISSAO WHEN C.EMISSAO THEN 'OK' ELSE 'ERRADO' END) AS 'EMISSAO', "
	SQL001 += "      (CASE ROUND(P.VALOR,2) WHEN ROUND(C.VALOR,2) THEN 'OK' ELSE 'ERRADO' END) AS 'TOTALNF', " 
	SQL001 += "      (CASE ROUND(P.BASEICMS,2) WHEN ROUND(C.BASEICMS,2) THEN 'OK' ELSE 'ERRADO' END) AS 'BCICMS', " 
	SQL001 += "      (CASE ROUND(P.VLICMS,2) WHEN ROUND(C.VLICMS,2) THEN 'OK' ELSE 'ERRADO' END) AS 'ICMS', " 
	SQL001 += "      (CASE ROUND(P.VLIPI,2) WHEN ROUND(C.VLIPI,2) THEN 'OK' ELSE 'ERRADO' END) AS 'IPI', " 
	SQL001 += "      P.ESPECIE AS 'PR_ESPECIE', " 
	SQL001 += "	  	 P.CNPJ AS 'PR_CNPJ', " 
	SQL001 += "      P.NF AS 'PR_NF', " 
	SQL001 += "      P.SERIE AS 'PR_SERIE', " 
	SQL001 += "      P.EMISSAO AS 'PR_EMISSAO', " 
	SQL001 += "      P.VALOR AS 'PR_VALOR', " 
	SQL001 += "      P.BASEICMS AS 'PR_BASEICMS', " 
	SQL001 += "      P.VLICMS AS 'PR_VLICMS', " 
	SQL001 += "      P.VLIPI AS 'PR_VLIPI', " 
	SQL001 += "      P.LANCAMENTO AS 'PR_LANCAMENTO', "
	SQL001 += "      C.ESPECIE AS 'CX_ESPECIE', " 
	SQL001 += "	     C.CNPJ AS 'CX_CNPJ', " 
	SQL001 += "      C.NF AS 'CX_NF', " 
	SQL001 += "      C.SERIE AS 'CX_SERIE', " 
	SQL001 += "      C.EMISSAO AS 'CX_EMISSAO', " 
	SQL001 += "      C.VALOR AS 'CX_VALOR', " 
	SQL001 += "      C.BASEICMS AS 'CX_BASEICMS', " 
	SQL001 += "      C.VLICMS AS 'CX_VLICMS', " 
	SQL001 += "      C.VLIPI AS 'CX_VLIPI'"
	SQL001 += "FROM ( SELECT CHAVE, ESPECIE, CNPJ, NF, SERIE, EMISSAO, VALOR, SUM(BASEICMS) 'BASEICMS', SUM(VLICMS) 'VLICMS', SUM(VLIPI) 'VLIPI' "
	SQL001 += "       FROM " + cTabelaCnx
	SQL001 += "       GROUP BY CHAVE, ESPECIE, CNPJ, NF, SERIE, EMISSAO, VALOR ) C "
	SQL001 += "INNER JOIN ( SELECT CHAVE, ESPECIE, CNPJ, NF, SERIE, EMISSAO, VALOR, SUM(BASEICMS) 'BASEICMS', SUM(VLICMS) 'VLICMS', SUM(VLIPI) 'VLIPI', LANCAMENTO "
	SQL001 += "             FROM  " + cTabelaPth
	SQL001 += "             GROUP BY CHAVE, ESPECIE, CNPJ, NF, SERIE, EMISSAO, VALOR, LANCAMENTO ) P ON C.CHAVE = P.CHAVE "
	SQL001 += "WHERE((P.NF <> C.NF) "
	SQL001 += "      OR (P.SERIE <> C.SERIE) "
	SQL001 += "      OR (P.CNPJ <> C.CNPJ) "
	SQL001 += "      OR (P.EMISSAO <> C.EMISSAO) "
	SQL001 += "      OR (P.VALOR <> C.VALOR) "
	SQL001 += "      OR (P.BASEICMS <> C.BASEICMS) "
	SQL001 += "      OR (P.VLICMS <> C.VLICMS) "
	SQL001 += "      OR (P.VLIPI <> C.VLIPI)) "
	SQL001 += "      AND P.LANCAMENTO BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' "

	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL001),'SQL001',.F.,.T.)
	dbSelectArea("SQL001")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan1, nxTab1, {SQL001->NUMERO,;
		SQL001->SERIE,;
		SQL001->CNPJ,;
		SQL001->EMISSAO,;
		SQL001->TOTALNF,;
		SQL001->BCICMS,;
		SQL001->ICMS,;
		SQL001->IPI,;
		SQL001->PR_ESPECIE,;
		SQL001->CX_ESPECIE,;
		SQL001->PR_NF,;
		SQL001->CX_NF,;
		SQL001->PR_SERIE,;
		SQL001->CX_SERIE,;
		SQL001->PR_CNPJ,;
		SQL001->CX_CNPJ,;											
		StoD(SQL001->PR_EMISSAO),;
		StoD(SQL001->CX_EMISSAO),;
		SQL001->PR_VALOR,;
		SQL001->CX_VALOR,;
		SQL001->PR_BASEICMS,;
		SQL001->CX_BASEICMS,;
		SQL001->PR_VLICMS,;
		SQL001->CX_VLICMS,;
		SQL001->PR_VLIPI,;											
		SQL001->CX_VLIPI})

		dbSelectArea("SQL001")
		dbSkip()	

	End

	SQL001->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())	

	nxPlan2 := "PROTHEUS"
	oExcel:AddworkSheet(nxPlan2)

	/* TAB 2 */
	nxTab2 := "PROTHEUS"

	oExcel:AddTable (nxPlan2, nxTab2)
	oExcel:AddColumn(nxPlan2, nxTab2, "FILIAL",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "ESPECIE",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "CHAVE",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "FORNECEDOR",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "LOJA",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "CNPJ",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "NF",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "SERIE",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "EMISSAO",1,4)
	oExcel:AddColumn(nxPlan2, nxTab2, "VALOR",1,3)
	oExcel:AddColumn(nxPlan2, nxTab2, "BASE ICMS",1,3)
	oExcel:AddColumn(nxPlan2, nxTab2, "ALIQ ICMS",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "VALOR ICMS",1,3)
	oExcel:AddColumn(nxPlan2, nxTab2, "ALIQ IPI",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "VALOR IPI",1,3)
	oExcel:AddColumn(nxPlan2, nxTab2, "ITEM",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "PRODUTO",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "CFOP",1,1)

	SQL002 := ""
	SQL002 += "SELECT C.FILIAL, C.ESPECIE, C.CHAVE, C.FORNECEDOR, C.LOJA, C.CNPJ, C.NF, C.SERIE, C.EMISSAO, C.VLUNIT, C.VALOR, C.QTDE, C.BASEICMS "
	SQL002 += ", C.ALQICMS, C.VLICMS, C.ALQIPI, C.VLIPI, C.ITEM, C.PRODUTO, C.CFOP "
	SQL002 += "FROM " + cTabelaCnx + " C "	
	SQL002 += "INNER JOIN ( SELECT CHAVE, ESPECIE, CNPJ, NF, SERIE, EMISSAO, VALOR, SUM(BASEICMS) 'BASEICMS', SUM(VLICMS) 'VLICMS', SUM(VLIPI) 'VLIPI', LANCAMENTO "
	SQL002 += "             FROM  " + cTabelaPth + " "
	SQL002 += "             GROUP BY CHAVE, ESPECIE, CNPJ, NF, SERIE, EMISSAO, VALOR, LANCAMENTO ) P ON C.CHAVE = P.CHAVE AND LANCAMENTO BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' "		

	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL002),'SQL002',.F.,.T.)
	dbSelectArea("SQL002")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan2, nxTab2, { SQL002->FILIAL,;
		SQL002->ESPECIE,;
		SQL002->CHAVE,;
		SQL002->FORNECEDOR,;
		SQL002->LOJA,;
		SQL002->CNPJ,;
		SQL002->NF,;
		SQL002->SERIE,;
		StoD(SQL002->EMISSAO),;
		SQL002->VALOR,;
		SQL002->BASEICMS,;
		SQL002->ALQICMS,;
		SQL002->VLICMS,;
		SQL002->ALQIPI,;
		SQL002->VLIPI,;
		SQL002->ITEM,;
		SQL002->PRODUTO,;
		SQL002->CFOP})

		dbSelectArea("SQL002")
		dbSkip()	

	End

	SQL002->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())		

	nxPlan3 := "CONEXAO"
	oExcel:AddworkSheet(nxPlan3)

	/* TAB 3 */
	nxTab3 := "CONEXAO"

	oExcel:AddTable (nxPlan3, nxTab3)
	oExcel:AddColumn(nxPlan3, nxTab3, "FILIAL",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "ESPECIE",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "CHAVE",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "FORNECEDOR",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "LOJA",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "CNPJ",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "NF",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "SERIE",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "EMISSAO",1,4)
	oExcel:AddColumn(nxPlan3, nxTab3, "VALOR",1,3)
	oExcel:AddColumn(nxPlan3, nxTab3, "BASE ICMS",1,3)
	oExcel:AddColumn(nxPlan3, nxTab3, "ALIQ ICMS",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "VALOR ICMS",1,3)
	oExcel:AddColumn(nxPlan3, nxTab3, "ALIQ IPI",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "VALOR IPI",1,3)
	oExcel:AddColumn(nxPlan3, nxTab3, "ITEM",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "PRODUTO",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "CFOP",1,1)

	SQL003 := ""
	SQL003 += "SELECT FILIAL, ESPECIE, CHAVE, FORNECEDOR, LOJA, CNPJ, NF, SERIE, EMISSAO, VALOR, BASEICMS "
	SQL003 += ", ALQICMS, VLICMS, ALQIPI, VLIPI, ITEM , PRODUTO, CFOP "
	SQL003 += "FROM " + cTabelaPth + " "
	SQL003 += "WHERE LANCAMENTO BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' "

	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL003),'SQL003',.F.,.T.)
	dbSelectArea("SQL003")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan3, nxTab3, { SQL003->FILIAL,;
		SQL003->ESPECIE,;
		SQL003->CHAVE,;
		SQL003->FORNECEDOR,;
		SQL003->LOJA,;
		SQL003->CNPJ,;
		SQL003->NF,;
		SQL003->SERIE,;
		StoD(SQL003->EMISSAO),;
		SQL003->VALOR,;
		SQL003->BASEICMS,;
		SQL003->ALQICMS,;
		SQL003->VLICMS,;
		SQL003->ALQIPI,;
		SQL003->VLIPI,;
		SQL003->ITEM,;
		SQL003->PRODUTO,;
		SQL003->CFOP})		                               

		dbSelectArea("SQL003")
		dbSkip()	

	End

	SQL003->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())

	SQL000 := ""
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTabelaCnx + "' and type = 'U') drop table " + cTabelaCnx

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao excluir tabela temporária (RlConf001) - Erro : " + TCSQLError())
		Return
	endif

	SQL000 := ""
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTabelaPth + "' and type = 'U') drop table " + cTabelaPth

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao excluir tabela temporária (RlConf001) - Erro : " + TCSQLError())
		Return
	endif

Return 

/* ------------------------------------------ */
/* RELATÓRIO : Diferença Lançamento de Custo  */
/* ------------------------------------------ */
Static Function RlConf002()

	nxPlan := "Superior a 10%"

	oExcel:AddworkSheet(nxPlan)
	nxTab1 := "Superior a 10%"

	oExcel:AddTable (nxPlan, nxTab1)
	oExcel:AddColumn(nxPlan, nxTab1, "CODIGO",1,1)
	oExcel:AddColumn(nxPlan, nxTab1, "DESCRICAO",1,1)
	oExcel:AddColumn(nxPlan, nxTab1, "TIPO",1,1)
	oExcel:AddColumn(nxPlan, nxTab1, "ULTIMO",1,4)
	oExcel:AddColumn(nxPlan, nxTab1, "CUSTO_UN",1,3)
	oExcel:AddColumn(nxPlan, nxTab1, "DOCUMENTO",1,1)
	oExcel:AddColumn(nxPlan, nxTab1, "PENULTIMO",1,4)
	oExcel:AddColumn(nxPlan, nxTab1, "CUSTO_UN",1,3)
	oExcel:AddColumn(nxPlan, nxTab1, "DOCUMENTO",1,1)
	oExcel:AddColumn(nxPlan, nxTab1, "PORCENTAGEM",1,1)				

	SQL002 := "" + Enter 
	SQL002 += "WITH TBLCUSTO_ULT (CODIGO, DESCRICAO, TIPO, DIGITACAO, VALOR, CUSTO, CUSTO_UN,RECNO, QTDE, DOCUMENTO, UM) AS " + Enter
	SQL002 += "(SELECT CODIGO, " + Enter
	SQL002 += "       DESCRICAO, " + Enter
	SQL002 += "       TIPO, " + Enter
	SQL002 += "       DIGITACAO, " + Enter
	SQL002 += "       VALOR, " + Enter
	SQL002 += "       CUSTO, " + Enter
	SQL002 += "       CUSTO_UN, " + Enter
	SQL002 += "       RECNO, " + Enter
	SQL002 += "       QTDE, " + Enter
	SQL002 += "       DOCUMENTO, " + Enter
	SQL002 += "       UM " + Enter
	SQL002 += "FROM ( SELECT D1.D1_COD AS 'CODIGO', " + Enter
	SQL002 += "              B1.B1_DESC AS 'DESCRICAO', " + Enter
	SQL002 += "              B1.B1_TIPO AS 'TIPO', " + Enter
	SQL002 += "              D1.D1_DTDIGIT AS 'DIGITACAO', " + Enter
	SQL002 += "              D1.D1_VUNIT AS 'VALOR', " + Enter
	SQL002 += "              D1.D1_CUSTO AS 'CUSTO', " + Enter
	SQL002 += "              ROUND((D1.D1_CUSTO/D1.D1_QUANT),2) AS 'CUSTO_UN', " + Enter
	SQL002 += "              D1.R_E_C_N_O_ AS 'RECNO', " + Enter
	SQL002 += "              D1.D1_QUANT AS 'QTDE', " + Enter
	SQL002 += "              D1.D1_DOC AS 'DOCUMENTO', " + Enter
	SQL002 += "              D1.D1_UM AS 'UM', " + Enter
	SQL002 += "              ROW_NUMBER() OVER (PARTITION BY D1.D1_COD ORDER BY D1.D1_DTDIGIT DESC, D1.R_E_C_N_O_ DESC) AS RN " + Enter
	SQL002 += "       FROM " + RetSqlName("SD1") + " D1 WITH(NOLOCK) " + Enter
	SQL002 += "            INNER JOIN " + RetSqlName("SB1") + " B1 WITH(NOLOCK) ON B1.B1_COD = D1.D1_COD " + Enter
	SQL002 += "            INNER JOIN " + RetSqlName("SF4") + " F4 WITH(NOLOCK) ON F4.F4_CODIGO = D1.D1_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + Enter
	SQL002 += "       WHERE D1.D1_DTDIGIT BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' " + Enter
	SQL002 += "       AND B1.B1_TIPO NOT IN ('PA','PP') AND D1_GRUPO NOT IN ('306','306A','306B') AND D1_QUANT <> 0 AND D1.D_E_L_E_T_ = '' AND B1.D_E_L_E_T_ = '' ) TAB " + Enter
	SQL002 += "WHERE RN = 1 ), TBLCUSTO_PENULT (CODIGO, DESCRICAO, TIPO, DIGITACAO, VALOR, CUSTO, CUSTO_UN, RECNO, QTDE, DOCUMENTO, UM) AS " + Enter
	SQL002 += "(SELECT CODIGO, " + Enter
	SQL002 += "       DESCRICAO, " + Enter
	SQL002 += "       TIPO, " + Enter
	SQL002 += "       DIGITACAO, " + Enter
	SQL002 += "       VALOR, " + Enter
	SQL002 += "       CUSTO, " + Enter
	SQL002 += "       CUSTO_UN, " + Enter
	SQL002 += "       RECNO, " + Enter
	SQL002 += "       QTDE, " + Enter
	SQL002 += "       DOCUMENTO, " + Enter
	SQL002 += "       UM " + Enter
	SQL002 += "FROM ( SELECT D1.D1_COD AS 'CODIGO', " + Enter
	SQL002 += "              B1.B1_DESC AS 'DESCRICAO', " + Enter
	SQL002 += "              B1.B1_TIPO AS 'TIPO', " + Enter
	SQL002 += "              D1.D1_DTDIGIT AS 'DIGITACAO', " + Enter
	SQL002 += "              D1.D1_VUNIT AS 'VALOR', " + Enter
	SQL002 += "              D1.D1_CUSTO AS 'CUSTO', " + Enter
	SQL002 += "              ROUND((D1.D1_CUSTO/D1.D1_QUANT),2) AS 'CUSTO_UN', " + Enter
	SQL002 += "              D1.R_E_C_N_O_ AS 'RECNO', " + Enter
	SQL002 += "              D1.D1_QUANT AS 'QTDE', " + Enter
	SQL002 += "              D1.D1_DOC AS 'DOCUMENTO', " + Enter
	SQL002 += "              D1.D1_UM AS 'UM', " + Enter
	SQL002 += "              ROW_NUMBER() OVER (PARTITION BY D1.D1_COD ORDER BY D1.D1_DTDIGIT DESC, D1.R_E_C_N_O_ DESC) AS RN " + Enter
	SQL002 += "       FROM " + RetSqlName("SD1") + " D1 WITH(NOLOCK) " + Enter
	SQL002 += "            INNER JOIN " + RetSqlName("SB1") + " B1 WITH(NOLOCK) ON B1.B1_COD = D1.D1_COD " + Enter
	SQL002 += "            INNER JOIN " + RetSqlName("SF4") + " F4 WITH(NOLOCK) ON F4.F4_CODIGO = D1.D1_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + Enter
	SQL002 += "       WHERE D1.D1_DTDIGIT BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' " + Enter
	SQL002 += "       AND B1.B1_TIPO NOT IN ('PA','PP') AND D1_GRUPO NOT IN ('306','306A','306B') AND D1_QUANT <> 0 AND D1.D_E_L_E_T_ = '' AND B1.D_E_L_E_T_ = '' ) TAB " + Enter
	SQL002 += "WHERE RN = 2 ) " + Enter
	SQL002 += " " + Enter
	SQL002 += "SELECT RTRIM(LTRIM(T1.CODIGO)) CODIGO,  " + Enter
	SQL002 += "       RTRIM(LTRIM(T1.DESCRICAO)) DESCRICAO, " + Enter
	SQL002 += "       T1.TIPO 'TIPO_ULTIMO', " + Enter
	SQL002 += "       T1.RECNO 'RECNO_ULTIMO'," + Enter
	SQL002 += "       T1.DIGITACAO 'DT_ULTIMO',  " + Enter
	SQL002 += "       T1.VALOR 'VL_ULTIMO', " + Enter
	SQL002 += "       T1.CUSTO_UN 'CST_ULTIMO', " + Enter
	SQL002 += "       T1.QTDE 'QTDE_ULTIMO', " + Enter
	SQL002 += "       T1.UM 'UM_ULTIMO', " + Enter
	SQL002 += "       T1.DOCUMENTO 'DOC_ULTIMO', " + Enter
	SQL002 += "       T2.TIPO 'TIPO_PENULTIMO', " + Enter		
	SQL002 += "       T2.RECNO 'RECNO_ULTIMO', " + Enter
	SQL002 += "       T2.DIGITACAO 'DT_PENULTIMO',  " + Enter
	SQL002 += "       T2.VALOR 'VL_PENULTIMO', " + Enter
	SQL002 += "       T2.CUSTO_UN 'CST_PENULTIMO', " + Enter
	SQL002 += "       T2.QTDE 'QTDE_PENULTIMO', "  + Enter
	SQL002 += "       T2.UM 'UM_PENULTIMO', " + Enter
	SQL002 += "       T2.DOCUMENTO 'DOC_PENULTIMO', " + Enter
	SQL002 += "       ROUND(((T1.CUSTO_UN - T2.CUSTO_UN)/T1.CUSTO_UN),3) 'PORCENTAGEM' " + Enter
	SQL002 += "FROM TBLCUSTO_ULT T1 " + Enter
	SQL002 += "     INNER JOIN TBLCUSTO_PENULT T2 ON T1.CODIGO = T2.CODIGO " + Enter
	SQL002 += "WHERE ROUND(((T1.CUSTO_UN - T2.CUSTO_UN)/T1.CUSTO_UN),3) >= 0.1 " + Enter // Custo maior que 10% do ultimo custo informado
	SQL002 += "ORDER BY 5 DESC "

	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL002),'SQL002',.F.,.T.)
	dbSelectArea("SQL002")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc()			

		oExcel:AddRow(nxPlan, nxTab1, {SQL002->CODIGO;
		,SQL002->DESCRICAO;
		,SQL002->TIPO_ULTIMO;
		,StoD(SQL002->DT_ULTIMO);
		,SQL002->CST_ULTIMO;
		,SQL002->DOC_ULTIMO;
		,StoD(SQL002->DT_PENULTIMO);
		,SQL002->CST_PENULTIMO;
		,SQL002->DOC_PENULTIMO;
		,SQL002->PORCENTAGEM})

		dbSelectArea("SQL002")
		dbSkip()	

	End

	SQL002->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())

	/* TAB2 */
	nxPlan2 := "Inferior a 10%"

	oExcel:AddworkSheet(nxPlan2)
	nxTab2 := "Inferior a 10%"

	oExcel:AddTable (nxPlan2, nxTab2)
	oExcel:AddColumn(nxPlan2, nxTab2, "CODIGO",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "DESCRICAO",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "TIPO",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "ULTIMO",1,4)
	oExcel:AddColumn(nxPlan2, nxTab2, "CUSTO_UN",1,3)
	oExcel:AddColumn(nxPlan2, nxTab2, "DOCUMENTO",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "PENULTIMO",1,4)
	oExcel:AddColumn(nxPlan2, nxTab2, "CUSTO_UN",1,3)
	oExcel:AddColumn(nxPlan2, nxTab2, "DOCUMENTO",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "PORCENTAGEM",1,1)				

	SQL002 := "" + Enter 
	SQL002 += "WITH TBLCUSTO_ULT (CODIGO, DESCRICAO, TIPO, DIGITACAO, VALOR, CUSTO, CUSTO_UN,RECNO, QTDE, DOCUMENTO, UM) AS " + Enter
	SQL002 += "(SELECT CODIGO, " + Enter
	SQL002 += "       DESCRICAO, " + Enter
	SQL002 += "       TIPO, " + Enter
	SQL002 += "       DIGITACAO, " + Enter
	SQL002 += "       VALOR, " + Enter
	SQL002 += "       CUSTO, " + Enter
	SQL002 += "       CUSTO_UN, " + Enter
	SQL002 += "       RECNO, " + Enter
	SQL002 += "       QTDE, " + Enter
	SQL002 += "       DOCUMENTO, " + Enter
	SQL002 += "       UM " + Enter
	SQL002 += "FROM ( SELECT D1.D1_COD AS 'CODIGO', " + Enter
	SQL002 += "              B1.B1_DESC AS 'DESCRICAO', " + Enter
	SQL002 += "              B1.B1_TIPO AS 'TIPO', " + Enter
	SQL002 += "              D1.D1_DTDIGIT AS 'DIGITACAO', " + Enter
	SQL002 += "              D1.D1_VUNIT AS 'VALOR', " + Enter
	SQL002 += "              D1.D1_CUSTO AS 'CUSTO', " + Enter
	SQL002 += "              ROUND((D1.D1_CUSTO/D1.D1_QUANT),2) AS 'CUSTO_UN', " + Enter
	SQL002 += "              D1.R_E_C_N_O_ AS 'RECNO', " + Enter
	SQL002 += "              D1.D1_QUANT AS 'QTDE', " + Enter
	SQL002 += "              D1.D1_DOC AS 'DOCUMENTO', " + Enter
	SQL002 += "              D1.D1_UM AS 'UM', " + Enter
	SQL002 += "              ROW_NUMBER() OVER (PARTITION BY D1.D1_COD ORDER BY D1.D1_DTDIGIT DESC, D1.R_E_C_N_O_ DESC) AS RN " + Enter
	SQL002 += "       FROM " + RetSqlName("SD1") + " D1 WITH(NOLOCK) " + Enter
	SQL002 += "            INNER JOIN " + RetSqlName("SB1") + " B1 WITH(NOLOCK) ON B1.B1_COD = D1.D1_COD " + Enter
	SQL002 += "            INNER JOIN " + RetSqlName("SF4") + " F4 WITH(NOLOCK) ON F4.F4_CODIGO = D1.D1_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + Enter
	SQL002 += "       WHERE D1.D1_DTDIGIT BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' " + Enter
	SQL002 += "       AND B1.B1_TIPO NOT IN ('PA','PP') AND D1_GRUPO NOT IN ('306','306A','306B') AND D1_QUANT <> 0 AND D1.D_E_L_E_T_ = '' AND B1.D_E_L_E_T_ = '' ) TAB " + Enter
	SQL002 += "WHERE RN = 1 ), TBLCUSTO_PENULT (CODIGO, DESCRICAO, TIPO, DIGITACAO, VALOR, CUSTO, CUSTO_UN, RECNO, QTDE, DOCUMENTO, UM) AS " + Enter
	SQL002 += "(SELECT CODIGO, " + Enter
	SQL002 += "       DESCRICAO, " + Enter
	SQL002 += "       TIPO, " + Enter
	SQL002 += "       DIGITACAO, " + Enter
	SQL002 += "       VALOR, " + Enter
	SQL002 += "       CUSTO, " + Enter
	SQL002 += "       CUSTO_UN, " + Enter
	SQL002 += "       RECNO, " + Enter
	SQL002 += "       QTDE, " + Enter
	SQL002 += "       DOCUMENTO, " + Enter
	SQL002 += "       UM " + Enter
	SQL002 += "FROM ( SELECT D1.D1_COD AS 'CODIGO', " + Enter
	SQL002 += "              B1.B1_DESC AS 'DESCRICAO', " + Enter
	SQL002 += "              B1.B1_TIPO AS 'TIPO', " + Enter
	SQL002 += "              D1.D1_DTDIGIT AS 'DIGITACAO', " + Enter
	SQL002 += "              D1.D1_VUNIT AS 'VALOR', " + Enter
	SQL002 += "              D1.D1_CUSTO AS 'CUSTO', " + Enter
	SQL002 += "              ROUND((D1.D1_CUSTO/D1.D1_QUANT),2) AS 'CUSTO_UN', " + Enter
	SQL002 += "              D1.R_E_C_N_O_ AS 'RECNO', " + Enter
	SQL002 += "              D1.D1_QUANT AS 'QTDE', " + Enter
	SQL002 += "              D1.D1_DOC AS 'DOCUMENTO', " + Enter
	SQL002 += "              D1.D1_UM AS 'UM', " + Enter
	SQL002 += "              ROW_NUMBER() OVER (PARTITION BY D1.D1_COD ORDER BY D1.D1_DTDIGIT DESC, D1.R_E_C_N_O_ DESC) AS RN " + Enter
	SQL002 += "       FROM " + RetSqlName("SD1") + " D1 WITH(NOLOCK) " + Enter
	SQL002 += "            INNER JOIN " + RetSqlName("SB1") + " B1 WITH(NOLOCK) ON B1.B1_COD = D1.D1_COD " + Enter
	SQL002 += "            INNER JOIN " + RetSqlName("SF4") + " F4 WITH(NOLOCK) ON F4.F4_CODIGO = D1.D1_TES AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = '' " + Enter
	SQL002 += "       WHERE D1.D1_DTDIGIT BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' " + Enter
	SQL002 += "       AND B1.B1_TIPO NOT IN ('PA','PP') AND D1_GRUPO NOT IN ('306','306A','306B') AND D1_QUANT <> 0 AND D1.D_E_L_E_T_ = '' AND B1.D_E_L_E_T_ = '' ) TAB " + Enter
	SQL002 += "WHERE RN = 2 ) " + Enter
	SQL002 += " " + Enter
	SQL002 += "SELECT RTRIM(LTRIM(T1.CODIGO)) CODIGO,  " + Enter
	SQL002 += "       RTRIM(LTRIM(T1.DESCRICAO)) DESCRICAO, " + Enter
	SQL002 += "       T1.TIPO 'TIPO_ULTIMO', " + Enter
	SQL002 += "       T1.RECNO 'RECNO_ULTIMO'," + Enter
	SQL002 += "       T1.DIGITACAO 'DT_ULTIMO',  " + Enter
	SQL002 += "       T1.VALOR 'VL_ULTIMO', " + Enter
	SQL002 += "       T1.CUSTO_UN 'CST_ULTIMO', " + Enter
	SQL002 += "       T1.QTDE 'QTDE_ULTIMO', " + Enter
	SQL002 += "       T1.UM 'UM_ULTIMO', " + Enter
	SQL002 += "       T1.DOCUMENTO 'DOC_ULTIMO', " + Enter
	SQL002 += "       T2.TIPO 'TIPO_PENULTIMO', " + Enter		
	SQL002 += "       T2.RECNO 'RECNO_ULTIMO', " + Enter
	SQL002 += "       T2.DIGITACAO 'DT_PENULTIMO',  " + Enter
	SQL002 += "       T2.VALOR 'VL_PENULTIMO', " + Enter
	SQL002 += "       T2.CUSTO_UN 'CST_PENULTIMO', " + Enter
	SQL002 += "       T2.QTDE 'QTDE_PENULTIMO', "  + Enter
	SQL002 += "       T2.UM 'UM_PENULTIMO', " + Enter
	SQL002 += "       T2.DOCUMENTO 'DOC_PENULTIMO', " + Enter
	SQL002 += "       ROUND(((T1.CUSTO_UN - T2.CUSTO_UN)/T1.CUSTO_UN),3) 'PORCENTAGEM' " + Enter
	SQL002 += "FROM TBLCUSTO_ULT T1 " + Enter
	SQL002 += "     INNER JOIN TBLCUSTO_PENULT T2 ON T1.CODIGO = T2.CODIGO " + Enter
	SQL002 += "WHERE ROUND(((T1.CUSTO_UN - T2.CUSTO_UN)/T1.CUSTO_UN),3) <= 0.1 " + Enter 
	SQL002 += "AND ROUND(((T1.CUSTO_UN - T2.CUSTO_UN)/T1.CUSTO_UN),3) <= -0.1 " + Enter
	SQL002 += "ORDER BY 5 DESC "

	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL002),'SQL002',.F.,.T.)
	dbSelectArea("SQL002")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc()			

		oExcel:AddRow(nxPlan2, nxTab2, {SQL002->CODIGO;
		,SQL002->DESCRICAO;
		,SQL002->TIPO_ULTIMO;
		,StoD(SQL002->DT_ULTIMO);
		,SQL002->CST_ULTIMO;
		,SQL002->DOC_ULTIMO;
		,StoD(SQL002->DT_PENULTIMO);
		,SQL002->CST_PENULTIMO;
		,SQL002->DOC_PENULTIMO;
		,SQL002->PORCENTAGEM})

		dbSelectArea("SQL002")
		dbSkip()	

	End

	SQL002->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())

Return

/* ------------------------------------------------------------------ */
/* RELATÓRIO : Comparação Cabeçalho NF x Livros Fiscais ( SF1 x SF3 ) */
/* ------------------------------------------------------------------ */
Static Function RlConf003()

	Local cTblSF1nm := "##TBIARO001SF1_" + __cUserID +"_"+ dToS(Date()) + StrTran(Time(), ":", "") 
	Local cTblSF3nm := "##TBIARO001SF3_" + __cUserID +"_"+ dToS(Date()) + StrTran(Time(), ":", "") 
	Local cTblDifnm := "##TBIARO001DIF_" + __cUserID +"_"+ dToS(Date()) + StrTran(Time(), ":", "") 

	SQL000 := ""
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTblSF1nm + "' and type = 'U') drop table " + cTblSF1nm

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao recuperar informações (SF1) - Erro : " + TCSQLError())
		Return
	endif

	SQL000 := "SELECT * "
	SQL000 += "INTO " + cTblSF1nm  + " FROM ( "	
	SQL000 += "SELECT F1.F1_DOC AS 'NF' " 
	SQL000 += ", F1.F1_FORNECE AS 'CODFOR' " 
	SQL000 += ", A2.A2_NOME AS 'FORNECEDOR' " 
	SQL000 += ", F1.F1_DTDIGIT AS 'DIGITACAO' " 
	SQL000 += ", ROUND(F1.F1_VALBRUT,2) AS 'VALOR' " 
	SQL000 += ", F1.F1_ESPECIE AS 'ESPECIE' " 
	SQL000 += "FROM " + RetSqlName("SF1") + " F1 WITH(NOLOCK) " 
	SQL000 += "INNER JOIN " + RetSqlName("SA2") + " A2  WITH(NOLOCK) ON A2.A2_COD = F1.F1_FORNECE AND A2.A2_LOJA = F1.F1_LOJA " 
	SQL000 += "WHERE F1_DTDIGIT BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' " 
	SQL000 += "AND ( F1_ESPECIE <> '' AND F1_ESPECIE <> 'RPS' ) " 
	SQL000 += "AND ( F1.F1_TIPO NOT IN ('B','D') ) " 
	SQL000 += "AND F1.D_E_L_E_T_ = '' " 
	SQL000 += "AND A2.D_E_L_E_T_ = '' "
	SQL000 += " UNION ALL "		
	SQL000 += "SELECT F1.F1_DOC AS 'NF' " 
	SQL000 += ", F1.F1_FORNECE AS 'CODFOR' " 
	SQL000 += ", A1.A1_NOME AS 'FORNECEDOR' " 
	SQL000 += ", F1.F1_DTDIGIT AS 'DIGITACAO' " 
	SQL000 += ", ROUND(F1.F1_VALBRUT,2) AS 'VALOR' " 
	SQL000 += ", F1.F1_ESPECIE AS 'ESPECIE' " 
	SQL000 += "FROM " + RetSqlName("SF1") + " F1 WITH(NOLOCK) " 
	SQL000 += "INNER JOIN " + RetSqlName("SA1") + " A1  WITH(NOLOCK) ON A1.A1_COD = F1.F1_FORNECE AND A1.A1_LOJA = F1.F1_LOJA " 
	SQL000 += "WHERE F1_DTDIGIT BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' " 
	SQL000 += "AND ( F1_ESPECIE <> '' AND F1_ESPECIE <> 'RPS' ) "
	SQL000 += "AND ( F1.F1_TIPO IN ('B','D') ) "
	SQL000 += "AND F1.D_E_L_E_T_ = '' " 
	SQL000 += "AND A1.D_E_L_E_T_ = '' ) SF1 "

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao recuperar informações (SF1) - Erro : " + TCSQLError())
		Return
	endif

	SQL000 := ""
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTblSF3nm + "' and type = 'U') drop table " + cTblSF3nm 

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao recuperar informações (SF3) - Erro : " + TCSQLError())
		Return
	endif

	SQL000 := "SELECT * "
	SQL000 += "INTO " + cTblSF3nm  + " FROM ( "	
	SQL000 += "SELECT F3.F3_NFISCAL AS 'NF' " 
	SQL000 += ", F3.F3_CLIEFOR AS 'CODFOR' " 
	SQL000 += ", A2.A2_NOME AS 'FORNECEDOR' " 
	SQL000 += ", F3.F3_ENTRADA AS 'ENTRADA' " 
	SQL000 += ", ROUND(SUM(F3.F3_VALCONT),2) AS 'VALOR' " 
	SQL000 += ", F3.F3_ESPECIE AS 'ESPECIE' " 		
	SQL000 += "FROM " + RetSqlName("SF3") + " F3 WITH(NOLOCK) " 
	SQL000 += "INNER JOIN " + RetSqlName("SA2") + " A2 WITH(NOLOCK) ON A2.A2_COD = F3.F3_CLIEFOR AND A2.A2_LOJA = F3.F3_LOJA " 
	SQL000 += "WHERE F3_ENTRADA BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' " 
	SQL000 += "AND F3.F3_CFO < '5000' " 
	SQL000 += "AND ( F3.F3_TIPO NOT IN ('B','D') ) "
	SQL000 += "AND F3.F3_DTCANC = '' " 
	SQL000 += "AND F3.D_E_L_E_T_ = '' " 
	SQL000 += "AND A2.D_E_L_E_T_ = '' " 
	SQL000 += "GROUP BY F3.F3_NFISCAL " 
	SQL000 += ", F3.F3_CLIEFOR " 
	SQL000 += ", A2.A2_NOME " 
	SQL000 += ", F3.F3_ENTRADA " 
	SQL000 += ", F3.F3_ESPECIE "
	SQL000 += " UNION ALL "		
	SQL000 += "SELECT F3.F3_NFISCAL AS 'NF' " 
	SQL000 += ", F3.F3_CLIEFOR AS 'CODFOR' " 
	SQL000 += ", A1.A1_NOME AS 'FORNECEDOR' " 
	SQL000 += ", F3.F3_ENTRADA AS 'ENTRADA' " 
	SQL000 += ", ROUND(SUM(F3.F3_VALCONT),2) AS 'VALOR' " 
	SQL000 += ", F3.F3_ESPECIE AS 'ESPECIE' " 
	SQL000 += "FROM " + RetSqlName("SF3") + " F3 WITH(NOLOCK) " 
	SQL000 += "INNER JOIN " + RetSqlName("SA1") + " A1 WITH(NOLOCK) ON A1.A1_COD = F3.F3_CLIEFOR AND A1.A1_LOJA = F3.F3_LOJA " 
	SQL000 += "WHERE F3_ENTRADA BETWEEN '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' " 
	SQL000 += "AND F3.F3_CFO < '5000' " 
	SQL000 += "AND ( F3.F3_TIPO IN ('B','D')) "
	SQL000 += "AND F3.F3_DTCANC = '' " 
	SQL000 += "AND F3.D_E_L_E_T_ = '' " 
	SQL000 += "AND A1.D_E_L_E_T_ = '' " 
	SQL000 += "GROUP BY F3.F3_NFISCAL " 
	SQL000 += ", F3.F3_CLIEFOR " 
	SQL000 += ", A1.A1_NOME " 
	SQL000 += ", F3.F3_ENTRADA " 
	SQL000 += ", F3.F3_ESPECIE ) SF3 "

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao recuperar informações (SF3) - Erro : " + TCSQLError())
		Return
	endif

	SQL000 := ""
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTblDifnm + "' and type = 'U') drop table " + cTblDifnm

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao recuperar informações (SF3) - Erro : " + TCSQLError())
		Return
	endif

	SQL000 = ""
	SQL000 += "SELECT TAB.[DATA], "
	SQL000 += "       SUM(TAB.[TOTAL SF1]) AS 'SF1', "
	SQL000 += "       SUM(TAB.[TOTAL SF3]) AS 'SF3' "
	SQL000 += "INTO " + cTblDifnm + " "
	SQL000 += "FROM "
	SQL000 += "( "
	SQL000 += "    SELECT T1.DIGITACAO AS 'DATA', "
	SQL000 += "           SUM(T1.VALOR) AS 'TOTAL SF1',  "
	SQL000 += "           '' AS 'TOTAL SF3' "
	SQL000 += "    FROM " + cTblSF1nm + " T1 "
	SQL000 += "    GROUP BY T1.DIGITACAO "
	SQL000 += "    UNION ALL "
	SQL000 += "    SELECT T3.ENTRADA AS 'DATA', "
	SQL000 += "           '' AS 'TOTAL SF1',  "
	SQL000 += "           SUM(T3.VALOR) AS 'TOTAL SF3' "
	SQL000 += "    FROM " + cTblSF3nm + " T3 "
	SQL000 += "    GROUP BY T3.ENTRADA "
	SQL000 += ") TAB "
	SQL000 += "GROUP BY TAB.[DATA] "

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao recuperar informações (SF3) - Erro : " + TCSQLError())
		Return
	endif

	nxPlan := "SF1"
	oExcel:AddworkSheet(nxPlan)

	/* TAB 1 */
	nxTab1 := "SF1"

	oExcel:AddTable (nxPlan, nxTab1)
	oExcel:AddColumn(nxPlan, nxTab1, "NF",1,1)
	oExcel:AddColumn(nxPlan, nxTab1, "CODFOR",1,1)
	oExcel:AddColumn(nxPlan, nxTab1, "FORNECEDOR",1,1)
	oExcel:AddColumn(nxPlan, nxTab1, "DIGITACAO",1,4)
	oExcel:AddColumn(nxPlan, nxTab1, "VALOR",1,3)
	oExcel:AddColumn(nxPlan, nxTab1, "ESPECIE",1,1)

	SQL003 := ""
	SQL003 += "SELECT NF, CODFOR, FORNECEDOR, DIGITACAO, VALOR, ESPECIE FROM " + cTblSF1nm + " "  + Enter 
	SQL003 += "ORDER BY 1"

	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL003),'SQL003',.F.,.T.)
	dbSelectArea("SQL003")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc()

		If SQL003->VALOR > 0

			oExcel:AddRow(nxPlan, nxTab1, {SQL003->NF,; 
			SQL003->CODFOR,; 
			SQL003->FORNECEDOR,; 
			StoD(SQL003->DIGITACAO),;
			SQL003->VALOR,;
			SQL003->ESPECIE})

		EndIf

		dbSelectArea("SQL003")
		dbSkip()	

	End

	SQL003->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())

	nxPlan2 := "SF3"
	oExcel:AddworkSheet(nxPlan2)

	/* TAB 2 */
	nxTab2 := "SF3"

	oExcel:AddTable (nxPlan2, nxTab2)
	oExcel:AddColumn(nxPlan2, nxTab2, "NF",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "CODFOR",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "FORNECEDOR",1,1)
	oExcel:AddColumn(nxPlan2, nxTab2, "ENTRADA",1,4)
	oExcel:AddColumn(nxPlan2, nxTab2, "VALOR",1,3)
	oExcel:AddColumn(nxPlan2, nxTab2, "ESPECIE",1,1)

	SQL003 := ""
	SQL003 += "SELECT  NF, CODFOR, FORNECEDOR, ENTRADA, VALOR, ESPECIE FROM " + cTblSF3nm + " " + Enter 
	SQL003 += "ORDER BY 1"

	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL003),'SQL003',.F.,.T.)
	dbSelectArea("SQL003")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc()

		If SQL003->VALOR > 0

			oExcel:AddRow(nxPlan2, nxTab2, {SQL003->NF,; 
			SQL003->CODFOR,; 
			SQL003->FORNECEDOR,; 
			StoD(SQL003->ENTRADA),; 
			SQL003->VALOR,; 
			SQL003->ESPECIE})

		EndIf

		dbSelectArea("SQL003")
		dbSkip()	

	End

	SQL003->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())

	nxPlan3 := "Existe SF1 e não existe SF3"
	oExcel:AddworkSheet(nxPlan3)

	/* TAB 3 */
	nxTab3 := "Existe SF1 e não existe SF3"

	oExcel:AddTable (nxPlan3, nxTab3)
	oExcel:AddColumn(nxPlan3, nxTab3, "NF",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "FORNECEDOR",1,1)
	oExcel:AddColumn(nxPlan3, nxTab3, "DIGITACAO",1,4)
	oExcel:AddColumn(nxPlan3, nxTab3, "VALOR",1,3)
	oExcel:AddColumn(nxPlan3, nxTab3, "ESPECIE",1,1)

	SQL003 := ""
	SQL003 += "SELECT T1.NF, T1.FORNECEDOR, T1.DIGITACAO, T1.VALOR, T1.ESPECIE " + Enter 
	SQL003 += "FROM " + cTblSF1nm + " T1 " + Enter 
	SQL003 += "LEFT JOIN " + cTblSF3nm + " T3 ON T3.NF = T1.NF " + Enter 
	SQL003 += "                    AND T3.VALOR = T1.VALOR " + Enter 
	SQL003 += "                    AND T3.ENTRADA = T1.DIGITACAO " + Enter 
	SQL003 += "                    AND T3.ESPECIE = T1.ESPECIE " + Enter 
	SQL003 += "                    AND T3.CODFOR = T1.CODFOR " + Enter 
	SQL003 += "WHERE T3.NF IS NULL"

	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL003),'SQL003',.F.,.T.)
	dbSelectArea("SQL003")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc() 
		
		if SQL003->VALOR > 0
			oExcel:AddRow(nxPlan3, nxTab3, {SQL003->NF,; 
			SQL003->FORNECEDOR,; 
			StoD(SQL003->DIGITACAO),; 
			SQL003->VALOR,; 
			SQL003->ESPECIE}) 
		EndIf

		dbSelectArea("SQL003")
		dbSkip()	

	End

	SQL003->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())

	//TAB 4
	nxPlan4 := "Existe SF3 e não existe SF1"
	oExcel:AddworkSheet(nxPlan4) 

	nxTab4 := "Existe SF3 e não existe SF1"

	oExcel:AddTable (nxPlan4, nxTab4)
	oExcel:AddColumn(nxPlan4, nxTab4, "NF",1,1)
	oExcel:AddColumn(nxPlan4, nxTab4, "FORNECEDOR",1,1)
	oExcel:AddColumn(nxPlan4, nxTab4, "ENTRADA",1,4)
	oExcel:AddColumn(nxPlan4, nxTab4, "VALOR",1,3)
	oExcel:AddColumn(nxPlan4, nxTab4, "ESPECIE",1,1)

	SQL003 = ""
	SQL003 += "SELECT T3.NF, T3.FORNECEDOR, T3.ENTRADA, T3.VALOR, T3.ESPECIE " + Enter 
	SQL003 += "FROM " + cTblSF1nm + " T1 " + Enter 
	SQL003 += "RIGHT JOIN " + cTblSF3nm + " T3 ON T3.NF = T1.NF " + Enter 
	SQL003 += "                    AND T3.VALOR = T1.VALOR " + Enter 
	SQL003 += "                    AND T3.ENTRADA = T1.DIGITACAO " + Enter 
	SQL003 += "                    AND T3.ESPECIE = T1.ESPECIE " + Enter 
	SQL003 += "                    AND T3.CODFOR = T1.CODFOR " + Enter 
	SQL003 += "WHERE T1.NF IS NULL"		

	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL003),'SQL003',.F.,.T.)
	dbSelectArea("SQL003")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc()

		If SQL003->VALOR > 0

			oExcel:AddRow(nxPlan4, nxTab4, {SQL003->NF,; 
			SQL003->FORNECEDOR,; 
			StoD(SQL003->ENTRADA),; 
			SQL003->VALOR,; 
			SQL003->ESPECIE})

		EndIf

		dbSelectArea("SQL003")
		dbSkip()	

	End

	SQL003->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())

	//TAB 5 
	nxPlan5 := "Diferença"
	oExcel:AddworkSheet(nxPlan5) 

	nxTab5 := "Diferença"

	oExcel:AddTable (nxPlan5, nxTab5)
	oExcel:AddColumn(nxPlan5, nxTab5, "Data",1,4)
	oExcel:AddColumn(nxPlan5, nxTab5, "SF1",1,3)
	oExcel:AddColumn(nxPlan5, nxTab5, "SF3",1,3)
	oExcel:AddColumn(nxPlan5, nxTab5, "Diferença",1,3)

	SQL003 = ""
	SQL003 += "SELECT [DATA], ROUND(SF1,2) 'F1', ROUND(SF3,2) 'F3', ROUND((SF1 - SF3),2) AS 'DIFERENCA' " + Enter
	SQL003 += "FROM " + cTblDifnm + " " 		


	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL003),'SQL003',.F.,.T.)
	dbSelectArea("SQL003")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan5, nxTab5, {StoD(SQL003->DATA),; 
		SQL003->F1,; 
		SQL003->F3,; 
		SQL003->DIFERENCA})

		dbSelectArea("SQL003")
		dbSkip()	

	End

	SQL003->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())		

	/*  */
	SQL000 := ""
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTblSF1nm + "' and type = 'U') drop table " + cTblSF1nm + " "		
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTblSF3nm + "' and type = 'U') drop table " + cTblSF3nm + " "
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTblDifnm + "' and type = 'U') drop table " + cTblDifnm + " "

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao excluir tabela temporária (RlConf003)- Erro : " + TCSQLError())
		Return
	endif

Return

/* ----------------------------- */
/* RELATÓRIO : Conferência CFOP  */
/* ----------------------------- */
Static Function RlConf004()

	cTabelaProtheus = RecDadosProtheus()
	cTabelaConexao = RecDadosConexao()

	nxPlan1 := "CFOP ( PROTHEUS X CONEXÃO )"
	oExcel:AddworkSheet(nxPlan1)

	/* TAB 1 */
	nxTab1 := "CFOP ( PROTHEUS X CONEXÃO )"

	oExcel:AddTable (nxPlan1, nxTab1)
	oExcel:AddColumn(nxPlan1, nxTab1, "DIGITACAO",1,4)
	oExcel:AddColumn(nxPlan1, nxTab1, "NF",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "PRODUTO",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "DESCRICAO PRODUTO",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "GRUPO",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "DESCRICAO GRUPO",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "CFOP (Conexão)",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "CFOP (Protheus)",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "FORNECEDOR",1,1)
	oExcel:AddColumn(nxPlan1, nxTab1, "CHAVE NF",1,1)

	SQL004 := ""
	SQL004 += "SELECT P.LANCAMENTO AS PR_LANCAMENTO, P.NF AS PR_NF, P.PRODUTO AS PR_PRODUTO, PROD.B1_DESC AS PR_DESCPRODUTO, G.BM_GRUPO AS PR_GRUPO, " 
	SQL004 += "G.BM_DESC AS PR_DESCGRUPO, C.CFOP AS PR_CFOP, P.CFOP AS CX_CFOP, P.FORNECEDOR AS PR_FORNECEDOR, P.CHAVE AS PR_CHAVE "
	SQL004 += "FROM " + cTabelaProtheus + " P "
	SQL004 += "INNER JOIN " + cTabelaConexao + " C ON C.CHAVE = P.CHAVE AND C.ITEM = P.ITEM "
	SQL004 += "INNER JOIN " + RetSqlName("SB1") + " PROD ON PROD.B1_COD = P.PRODUTO "
	SQL004 += "INNER JOIN " + RetSqlName("SBM") + " G ON G.BM_GRUPO = PROD.B1_GRUPO "
	SQL004 += "WHERE P.LANCAMENTO BETWEEN  '" + DtoS(aRet[2]) + "' AND '" + DtoS(aRet[3]) + "' "

	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQL004),'SQL004',.F.,.T.)
	dbSelectArea("SQL004")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan1, nxTab1, {SQL004->PR_LANCAMENTO,;	
		SQL004->PR_NF,;
		SQL004->PR_PRODUTO,;
		AllTrim(SQL004->PR_DESCPRODUTO),;
		SQL004->PR_GRUPO,;
		AllTrim(SQL004->PR_DESCGRUPO),;
		SQL004->PR_CFOP,;
		SQL004->CX_CFOP,;
		SQL004->PR_FORNECEDOR,;
		SQL004->PR_CHAVE})	

		dbSelectArea("SQL004")
		dbSkip()	

	End

	SQL004->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())
	Ferase(GUcIndex+OrdBagExt())	

	SQL000 := ""
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTabelaProtheus + "' and type = 'U') drop table " + cTabelaProtheus

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao excluir tabela temporária (RlConf004) - Erro : " + TCSQLError())
		Return
	endif

	SQL000 := ""
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTabelaConexao + "' and type = 'U') drop table " + cTabelaConexao

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao excluir tabela temporária (RlConf004) - Erro : " + TCSQLError())
		Return
	endif

Return

/* ------------------------------------ */
/* RECUPERA DADOS PROTHEUS				*/
/* ------------------------------------ */
Static Function RecDadosProtheus()

	Local cTblPTH := "##TBIARO001PTH_" + __cUserID +"_"+ dToS(Date()) + StrTran(Time(), ":", "") 

	SQL000 := ""
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTblPTH + "' and type = 'U') drop table " + cTblPTH

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao recuperar informações referentes ao Conexão NFe e Protheus - Erro : " + TCSQLError())
		Return
	endif

	SQL000 := ""
	SQL000 += "SELECT "
	SQL000 += "  D1.D1_FILIAL AS 'FILIAL' "
	SQL000 += ", F1.F1_ESPECIE AS 'ESPECIE' "
	SQL000 += ", F1.F1_CHVNFE AS 'CHAVE' "
	SQL000 += ", F1.F1_FORNECE AS 'FORNECEDOR' "
	SQL000 += ", F1.F1_LOJA AS 'LOJA' "
	SQL000 += ", ( CASE D1.D1_TIPO " 
	SQL000 += "         WHEN 'D' THEN ( SELECT A1.A1_CGC "
	SQL000 += "                         FROM SA1010 A1 WITH(NOLOCK) "
	SQL000 += "                         WHERE A1.A1_COD = D1.D1_FORNECE "
	SQL000 += "                             AND A1.A1_LOJA = D1.D1_LOJA "
	SQL000 += "                             AND A1.D_E_L_E_T_ = '' ) "
	SQL000 += "         WHEN 'B' THEN ( SELECT A1.A1_CGC "
	SQL000 += "                         FROM SA1010 A1 WITH(NOLOCK) "
	SQL000 += "                         WHERE A1.A1_COD = D1.D1_FORNECE "
	SQL000 += "                             AND A1.A1_LOJA = D1.D1_LOJA "
	SQL000 += "                             AND A1.D_E_L_E_T_ = '' ) " 
	SQL000 += "         ELSE ( SELECT A2.A2_CGC "
	SQL000 += "             FROM SA2010 A2 WITH(NOLOCK) "
	SQL000 += "             WHERE A2.A2_COD = D1.D1_FORNECE "
	SQL000 += "                     AND A2.A2_LOJA = D1.D1_LOJA "
	SQL000 += "                     AND A2.D_E_L_E_T_ = '' ) "
	SQL000 += "     END ) AS 'CNPJ' "
	SQL000 += ", D1.D1_DOC AS 'NF' "
	SQL000 += ", D1.D1_SERIE AS 'SERIE' "
	SQL000 += ", D1.D1_EMISSAO AS 'EMISSAO' "
	SQL000 += ", D1.D1_VUNIT AS 'VLUNIT' "
	SQL000 += ", D1.D1_CUSTO AS 'VLCUSTO' "
	SQL000 += ", ((F1.F1_VALMERC + F1.F1_FRETE + F1.F1_SEGURO + F1.F1_DESPESA) - F1.F1_DESCONT) 'VALOR' "
	SQL000 += ", D1.D1_QTDPEDI AS 'QTDE' "
	SQL000 += ", D1.D1_BASEICM AS 'BASEICMS' "
	SQL000 += ", D1.D1_PICM AS 'ALQICMS' "
	SQL000 += ", D1.D1_VALICM AS 'VLICMS' "
	SQL000 += ", D1.D1_ALQPIS AS 'ALQIPI' "
	SQL000 += ", D1.D1_VALIPI AS 'VLIPI' "
	SQL000 += ", D1.D1_ITEM AS 'ITEM' "
	SQL000 += ", D1.D1_COD AS 'PRODUTO' "
	SQL000 += ", D1.D1_CF AS 'CFOP' "
	SQL000 += ", D1.D1_DTDIGIT AS 'LANCAMENTO' "
	SQL000 += "INTO  " + cTblPTH + " "
	SQL000 += "FROM " + RetSqlName("SD1") + " D1 WITH(NOLOCK)"
	SQL000 += "INNER JOIN " + RetSqlName("SF1") + " F1 WITH(NOLOCK) "
	SQL000 += "        ON F1.F1_FILIAL = D1.D1_FILIAL "
	SQL000 += "       AND F1.F1_DOC = D1.D1_DOC "
	SQL000 += "       AND F1.F1_SERIE = D1.D1_SERIE "
	SQL000 += "       AND F1.F1_FORNECE = D1.D1_FORNECE "
	SQL000 += "       AND F1.F1_LOJA = D1.D1_LOJA "
	SQL000 += "       AND F1.D_E_L_E_T_ = '' "
	SQL000 += "WHERE D1.D_E_L_E_T_ = '' AND D1.D1_EMISSAO > '20180101' "		

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao recuperar informações (SF1) - Erro : " + TCSQLError())
		Return
	endif

Return cTblPTH

/* ------------------------------------ */
/* RECUPERA DADOS PROTHEUS				*/
/* ------------------------------------ */
Static Function RecDadosConexao()

	Local cTblCNX := "##TBIARO001CNX_" + __cUserID +"_"+ dToS(Date()) + StrTran(Time(), ":", "")

	SQL000 := ""
	SQL000 += "if exists (select 1 from Tempdb..SysObjects where Name = '" + cTblCNX + "' and type = 'U') drop table " + cTblCNX

	nRetSql := TCSqlExec(SQL000)		
	if (nRetSql < 0)
		MsgINFO("Erro ao recuperar informações referentes ao Conexão NFe e Protheus - Erro : " + TCSQLError())
		Return
	endif


	SQL000 := ""
	/*
	SQL000 += "SELECT "
	SQL000 += "  DS.DS_FILIAL AS 'FILIAL' "
	SQL000 += ", DS.DS_ESPECI AS 'ESPECIE' "
	SQL000 += ", DS.DS_CHAVENF AS 'CHAVE' "
	SQL000 += ", DS.DS_FORNEC AS 'FORNECEDOR' "
	SQL000 += ", DS.DS_LOJA AS 'LOJA' "
	SQL000 += ", DS.DS_CNPJ AS 'CNPJ' "
	SQL000 += ", DS.DS_DOC AS 'NF' "
	SQL000 += ", DS.DS_SERIE AS 'SERIE' "
	SQL000 += ", DS.DS_EMISSA AS 'EMISSAO' "
	SQL000 += ", ((DS.DS_VALMERC + DS.DS_FRETE + DS.DS_SEGURO + DS.DS_DESPESA) - DS.DS_DESCONT) AS 'VALOR' "
	SQL000 += ", DT.DT_YXMLBIC AS 'BASEICMS' "
	SQL000 += ", DT.DT_ALIQICM AS 'ALQICMS' "
	SQL000 += ", DT.DT_XMLICM AS 'VLICMS' "
	SQL000 += ", '' AS 'QTDE' "
	SQL000 += ", '' AS 'VLUNIT' "
	SQL000 += ", DT.DT_ALIQIPI AS 'ALQIPI' "
	SQL000 += ", DT.DT_XMLIPI AS 'VLIPI' "
	SQL000 += ", DT.DT_ITEM AS 'ITEM' "
	SQL000 += ", DT.DT_COD AS 'PRODUTO' "
	SQL000 += ", DT.DT_YCFOP AS 'CFOP' "
	SQL000 += "INTO  " + cTblCNX + " "
	SQL000 += "FROM " + RetSqlName("SDT") + " DT WITH(NOLOCK) "
	SQL000 += "INNER JOIN " + RetSqlName("SDS") + " DS WITH(NOLOCK) "
	SQL000 += "        ON DS.DS_FILIAL = DT.DT_FILIAL "
	SQL000 += "       AND DS.DS_FORNEC = DT.DT_FORNEC "
	SQL000 += "       AND DS.DS_LOJA = DT.DT_LOJA "
	SQL000 += "       AND DS.DS_SERIE = DT.DT_SERIE "
	SQL000 += "       AND DS.DS_DOC = DT.DT_DOC "
	SQL000 += "       AND DS.D_E_L_E_T_ = '' "
	SQL000 += "WHERE DT.D_E_L_E_T_ = '' AND DS.DS_EMISSA > '20180101'"
	*/

	SQL000 += "SELECT "
	SQL000 += "ZAA.ZAA_FILIAL AS 'FILIAL' "
	SQL000 += ",ZAA.ZAA_ESPECI AS 'ESPECIE' "
	SQL000 += ",ZAA.ZAA_CHAVE AS 'CHAVE' "
	SQL000 += ",ZAA_CODEMI AS 'FORNECEDOR' "
	SQL000 += ",ZAA.ZAA_LOJEMI AS 'LOJA' "
	SQL000 += ",ZAA.ZAA_CGCEMI AS 'CNPJ' "
	SQL000 += ",ZAA.ZAA_DOC AS 'NF' "
	SQL000 += ",ZAA.ZAA_SERIE AS 'SERIE' "
	SQL000 += ",ZAA.ZAA_DTEMIS AS 'EMISSAO' "
	SQL000 += ",ZAB.ZAB_TOTAL AS 'VALOR' "
	SQL000 += ",ZAB.ZAB_BASEIC AS 'BASEICMS' "
	SQL000 += ",ZAB.ZAB_PICM AS 'ALQICMS' "
	SQL000 += ",ZAB.ZAB_VALICM AS 'VLICMS' "
	SQL000 += ",ZAB.ZAB_QUANT1 AS 'QTDE' "
	SQL000 += ",ZAB.ZAB_QUANT2 AS 'QTDE SEGUN' "
	SQL000 += ",ZAB.ZAB_VUNIT AS 'VLUNIT' "
	SQL000 += ",ZAB.ZAB_IPI AS 'ALQIPI' "
	SQL000 += ",ZAB.ZAB_VALIPI AS 'VLIPI' "
	SQL000 += ",ZAB.ZAB_ITEM AS 'ITEM' "
	SQL000 += ",ZAB.ZAB_COD AS 'PRODUTO' "
	SQL000 += ",ZAB.ZAB_CF AS 'CFOP' "
	SQL000 += "INTO " + cTblCNX + " "
	SQL000 += "FROM " + RetSqlName("ZAA") + " ZAA "
	SQL000 += "INNER JOIN " + RetSqlName("ZAB") + " ZAB ON ZAB.ZAB_CHAVE = ZAA.ZAA_CHAVE "
	SQL000 += "WHERE ZAA.D_E_L_E_T_ = '' "
	SQL000 += "AND ZAB.D_E_L_E_T_ = '' "

	nRetSql := TCSqlExec(SQL000)
	if (nRetSql < 0)
		MsgINFO("Erro ao recuperar informações (SF1) - Erro : " + TCSQLError())
		Return
	endif

Return cTblCNX
