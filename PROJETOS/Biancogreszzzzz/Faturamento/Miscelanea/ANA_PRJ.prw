#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ ANA_PROJ       บAUTOR  ณBRUNO MADALENO      บ DATA ณ  28/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณRELATORIO EM CRYSTAL PARA GERAR AS ANALISES E PROJECOES - ESTOQUE บฑฑ
ฑฑบ          ณ X VENDAS                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ AP 8 - R4                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION ANA_PRJ()
//U_LOG_USO("ANALPR")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ DECLARACAO DE VARIAVEIS                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE CSQL
PRIVATE ENTER := CHR(13)+CHR(10)
LEND       := .F.
CSTRING    := ""
CDESC1     := "ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
CDESC2     := "DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
CDESC3     := "ANALISE E PROJECOES"
CTAMANHO   := ""
LIMITE     := 80		
ARETURN    := { "ZEBRADO", 1, "ADMINISTRACAO", 2, 2, 1, "", 1}
CNOMEPROG  := "ANAPR"
CPERG      := "ANALPR"
ALINHA     := {}
NLASTKEY   := 0
CTITULO	   := "ANALISE E PROJECOES"
CABEC1     := ""
CABEC2     := ""
NBEGIN     := 0
CDESCRI    := ""
CCANCEL    := "***** CANCELADO PELO OPERADOR *****"
M_PAG      := 1                                    
WNREL      := "ANAPR"
LPRIM      := .T.
LI         := 80
NTIPO      := 0
WFLAG      := .T.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ ENVIA CONTROLE PARA A FUNCAO SETPRINT.								     ณ
//ณ VERIFICA POSICAO DO FORMULARIO NA IMPRESSORA.				             ณ
//ณ SOLICITA OS PARAMETROS PARA A EMISSAO DO RELATORIO			             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PERGUNTE(CPERG,.F.)
WNREL := SETPRINT(CSTRING,CNOMEPROG,CPERG,@CTITULO,CDESC1,CDESC2,CDESC3,.F.,    ,.T.,CTAMANHO,,.F.)
//CANCELA A IMPRESSAO
IF NLASTKEY == 27
	RETURN
ENDIF


CFORMATO_DE		:= MV_PAR01
CFORMATO_AT		:= MV_PAR02
CCLASSE_DE		:= MV_PAR03
CCLASSE_AT		:= MV_PAR04
CPRODUTO_DE		:= MV_PAR05
CPRODUTO_AT		:= MV_PAR06
CENTREGA_ATE	:= DTOS(MV_PAR07)
//RUBENS JUNIOR (FACILE SISTEMAS) OS:1043-13
//FILTRAR ALMOXARIFADO
CLOCAL			:= MV_PAR08
CSTATUS			:= MV_PAR09

If MV_PAR10 = 1
	CEMPRESA := "0101"
ElseIf MV_PAR10 = 2
	CEMPRESA := "0501"
ElseIf MV_PAR10 = 3
	CEMPRESA := "0599"
ElseIf MV_PAR10 = 4
	CEMPRESA := "1399"
ElseIf MV_PAR10 = 5
	CEMPRESA := "1401"
Else
	CEMPRESA := ""
EndIf
//CEMPRESA		:= MV_PAR10

// *************************************************************************
// *************************************************************************
//VIEW PARA TRAZER AS INFORMACOES DO PROCESSO E OS PRODUTOS QUE O PERTENCE
// *************************************************************************
// *************************************************************************
CSQL := " " + ENTER
CSQL += "ALTER VIEW VW_ANALISE_PROJECOES AS  " + ENTER
CSQL += "SELECT B1_YFORMAT, B1_DESC, B1_YSTATUS, B1_COD,  " + ENTER
CSQL += "		SUM(A) AS A, SUM(B) AS B, SUM(C) AS C,  " + ENTER
CSQL += "		SUM(D) AS D, SUM(E) AS E, SUM(F) AS F,  " + ENTER
CSQL += "		SUM(ESTOQUE_ATUAL) AS ESTOQUE_ATUAL, SUM(CARTEIRA_ATU) AS CARTEIRA_ATU,  " + ENTER
CSQL += "		SUM(CARTEIRA_PROX) AS CARTEIRA_PROX, SUM(CARTEIRA_ULTIMO) AS CARTEIRA_ULTIMO,  " + ENTER
CSQL += "		SUM(RESERVA) AS RESERVA, " + ENTER
CSQL += "		SUM(SALDO_P3) AS SALDO_P3 " + ENTER // SALDO_OP
CSQL += "FROM " + ENTER
CSQL += "		(SELECT B1_YFORMAT + ' - ' + ZZ6_DESC AS B1_YFORMAT, RTRIM(SB1.B1_DESC) AS B1_DESC, B1_YSTATUS, B1_COD,  " + ENTER
CSQL += "					ISNULL((SELECT	(SUM(SC6.C6_QTDVEN)) AS QUANT " + ENTER
CSQL += "					FROM VW_ANA_PRJ_EMP SC6
CSQL += "					WHERE SC6.C6_PRODUTO = SB1.B1_COD " + ENTER
CSQL += "					AND SC6.EMPRESA = '"+cEmpAnt+"' " + ENTER
CSQL += "					AND (SC6.C6_ENTREG <= '"+AllTrim(CENTREGA_ATE)+"' OR '"+AllTrim(CENTREGA_ATE)+"' = '') " + ENTER
CSQL += "					AND (SC6.C6_LOCAL = '"  +AllTrim(CLOCAL)+"' OR '"+AllTrim(CLOCAL) + "'='' )
CSQL += "					AND SUBSTRING(SC6.C6_YEMISSA,1,6) = SUBSTRING(CONVERT(VARCHAR(8),DATEADD(month,-5,GETDATE()),112),1,6)),0 ) AS A," + ENTER

CSQL += " " + ENTER
CSQL += "					ISNULL((SELECT	(SUM(SC6.C6_QTDVEN)) AS QUANT " + ENTER
CSQL += "					FROM VW_ANA_PRJ_EMP SC6 "+ ENTER
CSQL += "					WHERE	SC6.C6_PRODUTO = SB1.B1_COD " + ENTER
CSQL += "					AND SC6.EMPRESA = '"+cEmpAnt+"' " + ENTER
CSQL += "					AND (SC6.C6_ENTREG <= '"+AllTrim(CENTREGA_ATE)+"' OR '"+AllTrim(CENTREGA_ATE)+"' = '') " + ENTER
CSQL += "					AND (SC6.C6_LOCAL = '"  +AllTrim(CLOCAL)+"' OR '"+AllTrim(CLOCAL) + "'='' )" + ENTER
CSQL += "					AND SUBSTRING(SC6.C6_YEMISSA,1,6) = SUBSTRING(CONVERT(VARCHAR(8),DATEADD(month,-4,GETDATE()),112),1,6)),0)AS B, " + ENTER 

CSQL += " " + ENTER
CSQL += "					ISNULL((SELECT	(SUM(SC6.C6_QTDVEN)) AS QUANT " + ENTER
CSQL += "					FROM VW_ANA_PRJ_EMP SC6 "+ ENTER
CSQL += "					WHERE SC6.C6_PRODUTO = SB1.B1_COD " + ENTER	
CSQL += "					AND SC6.EMPRESA = '"+cEmpAnt+"' " + ENTER
CSQL += "					AND (SC6.C6_ENTREG <= '"+AllTrim(CENTREGA_ATE)+"' OR '"+AllTrim(CENTREGA_ATE)+"' = '') " + ENTER
CSQL += "					AND (SC6.C6_LOCAL = '"  +AllTrim(CLOCAL)+"' OR '"+AllTrim(CLOCAL) + "'='' )" + ENTER
CSQL += "					AND SUBSTRING(SC6.C6_YEMISSA,1,6) = SUBSTRING(CONVERT(VARCHAR(8),DATEADD(month,-3,GETDATE()),112),1,6)),0) AS C, " + ENTER		

CSQL += " " + ENTER
CSQL += "					ISNULL((SELECT	(SUM(SC6.C6_QTDVEN)) AS QUANT " + ENTER
CSQL += "					FROM VW_ANA_PRJ_EMP SC6 "+ ENTER
CSQL += "					WHERE SC6.C6_PRODUTO = SB1.B1_COD " + ENTER	
CSQL += "					AND SC6.EMPRESA = '"+cEmpAnt+"' " + ENTER
CSQL += "					AND (SC6.C6_ENTREG <= '"+AllTrim(CENTREGA_ATE)+"' OR '"+AllTrim(CENTREGA_ATE)+"' = '') " + ENTER
CSQL += "					AND (SC6.C6_LOCAL = '"  +AllTrim(CLOCAL)+"' OR '"+AllTrim(CLOCAL) + "'='' )
CSQL += "					AND SUBSTRING(SC6.C6_YEMISSA,1,6) = SUBSTRING(CONVERT(VARCHAR(8),DATEADD(month,-2,GETDATE()),112),1,6)),0) AS D, " + ENTER		

CSQL += " " + ENTER
CSQL += "					ISNULL((SELECT	(SUM(SC6.C6_QTDVEN)) AS QUANT " + ENTER
CSQL += "					FROM VW_ANA_PRJ_EMP SC6 "+ ENTER
CSQL += "					WHERE SC6.C6_PRODUTO = SB1.B1_COD " + ENTER
CSQL += "					AND SC6.EMPRESA = '"+cEmpAnt+"' " + ENTER	
CSQL += "					AND (SC6.C6_ENTREG <= '"+AllTrim(CENTREGA_ATE)+"' OR '"+AllTrim(CENTREGA_ATE)+"' = '') " + ENTER
CSQL += "					AND (SC6.C6_LOCAL = '"  +AllTrim(CLOCAL)+"' OR '"+AllTrim(CLOCAL) + "'='' )" + ENTER
CSQL += "					AND SUBSTRING(SC6.C6_YEMISSA,1,6) = SUBSTRING(CONVERT(VARCHAR(8),DATEADD(month,-1,GETDATE()),112),1,6)),0) AS E, " + ENTER		

CSQL += " " + ENTER
CSQL += "					ISNULL((SELECT	(SUM(SC6.C6_QTDVEN)) AS QUANT " + ENTER
CSQL += "					FROM VW_ANA_PRJ_EMP SC6 "+ ENTER
CSQL += "					WHERE SC6.C6_PRODUTO = SB1.B1_COD " + ENTER
CSQL += "					AND SC6.EMPRESA = '"+cEmpAnt+"' " + ENTER	
CSQL += "					AND (SC6.C6_ENTREG <= '"+AllTrim(CENTREGA_ATE)+"' OR '"+AllTrim(CENTREGA_ATE)+"' = '') " + ENTER
CSQL += "					AND (SC6.C6_LOCAL = '"  +AllTrim(CLOCAL)+"' OR '"+AllTrim(CLOCAL) + "'='' )" + ENTER
CSQL += "					AND SUBSTRING(SC6.C6_YEMISSA,1,6) = SUBSTRING(CONVERT(VARCHAR(8),GETDATE(),112),1,6)),0) AS F, " + ENTER

CSQL += "					ISNULL((SELECT (SUM(B2_QATU)) AS B2_QATU " + ENTER
CSQL += "					FROM "+RETSQLNAME("SB2")+" SB2 " + ENTER
CSQL += "					WHERE	SB2.B2_COD = SB1.B1_COD " + ENTER
CSQL += "					AND (SB2.B2_LOCAL = '"  +AllTrim(CLOCAL)+"' OR '"+AllTrim(CLOCAL) + "'='' )" + ENTER
CSQL += "					AND SB2.D_E_L_E_T_ = ''),0) AS ESTOQUE_ATUAL, " + ENTER

CSQL += " " + ENTER
CSQL += "					ISNULL((SELECT	(SUM(SC6.C6_QTDVEN-SC6.C6_QTDENT)) AS QUANT " + ENTER
CSQL += "					FROM VW_ANA_PRJ_EMP SC6 "+ ENTER
CSQL += "					WHERE SC6.C6_PRODUTO = SB1.B1_COD " + ENTER
CSQL += "					AND SC6.EMPRESA = '"+cEmpAnt+"' " + ENTER	
CSQL += "					AND (SC6.C6_ENTREG <= '"+AllTrim(CENTREGA_ATE)+"' OR '"+AllTrim(CENTREGA_ATE)+"' = '') " + ENTER
CSQL += "					AND (SC6.C6_LOCAL = '"  +AllTrim(CLOCAL)+"' OR '"+AllTrim(CLOCAL) + "'='' )" + ENTER
CSQL += "					AND SUBSTRING(SC6.C6_ENTREG,1,6) <= SUBSTRING(CONVERT(VARCHAR(8),GETDATE(),112),1,6)),0) AS CARTEIRA_ATU, " + ENTER		

CSQL += " " + ENTER
CSQL += "					ISNULL((SELECT	(SUM(SC6.C6_QTDVEN-SC6.C6_QTDENT)) AS QUANT " + ENTER
CSQL += "					FROM VW_ANA_PRJ_EMP SC6 "+ ENTER
CSQL += "					WHERE SC6.C6_PRODUTO = SB1.B1_COD " + ENTER	
CSQL += "					AND SC6.EMPRESA = '"+cEmpAnt+"' " + ENTER
CSQL += "					AND (SC6.C6_ENTREG <= '"+AllTrim(CENTREGA_ATE)+"' OR '"+AllTrim(CENTREGA_ATE)+"' = '') " + ENTER
CSQL += "					AND (SC6.C6_LOCAL = '"  +AllTrim(CLOCAL)+"' OR '"+AllTrim(CLOCAL) + "'='' )" + ENTER
CSQL += "					AND SUBSTRING(SC6.C6_ENTREG,1,6) = SUBSTRING(CONVERT(VARCHAR(8),DATEADD(month,1,GETDATE()),112),1,6)),0) AS CARTEIRA_PROX, " + ENTER		

CSQL += " " + ENTER
CSQL += "					ISNULL((SELECT	(SUM(SC6.C6_QTDVEN-SC6.C6_QTDENT)) AS QUANT " + ENTER
CSQL += "					FROM VW_ANA_PRJ_EMP SC6 "+ ENTER
CSQL += "					WHERE SC6.C6_PRODUTO = SB1.B1_COD " + ENTER	
CSQL += "					AND SC6.EMPRESA = '"+cEmpAnt+"' " + ENTER
CSQL += "					AND (SC6.C6_ENTREG <= '"+AllTrim(CENTREGA_ATE)+"' OR '"+AllTrim(CENTREGA_ATE)+"' = '') " + ENTER
CSQL += "					AND (SC6.C6_LOCAL = '"  +AllTrim(CLOCAL)+"' OR '"+AllTrim(CLOCAL) + "'='' )" + ENTER
CSQL += "					AND SUBSTRING(SC6.C6_ENTREG,1,6) >=  SUBSTRING(CONVERT(VARCHAR(8),DATEADD(month,2,GETDATE()),112),1,6)),0) AS CARTEIRA_ULTIMO, " + ENTER

CSQL += " " + ENTER
CSQL += "					ISNULL((SELECT (SUM(C0_QUANT)) AS C0_QUANT FROM "+RETSQLNAME("SC0")+" SC0 " + ENTER
CSQL += "					WHERE	SC0.C0_QUANT  > 0 AND " + ENTER
CSQL += "							SC0.C0_PRODUTO = SB1.B1_COD AND " + ENTER
CSQL += "							SC0.C0_YPEDIDO = '' AND " + ENTER
CSQL += "							SC0.D_E_L_E_T_ = '' ),0) AS RESERVA, " + ENTER

CSQL += " " + ENTER
CSQL += " ISNULL((SELECT(SUM( CASE WHEN C2_DATRF = '' THEN (C2_QUANT - C2_QUJE) ELSE 0 END)) AS QUANT " + ENTER
CSQL += " FROM "+ RetSQLName("SC2") + ENTER
CSQL += " WHERE C2_FILIAL = " + ValToSQL(xFilial("SC2")) 
CSQL += " AND C2_PRODUTO = SB1.B1_COD " + ENTER
CSQL += " AND C2_EMISSAO >= '20170101' " + ENTER
CSQL += " AND D_E_L_E_T_ = ''),0) AS SALDO_P3 " + ENTER // SALDO_OP

CSQL += " " + ENTER
CSQL += "		FROM SB1010 SB1 " + ENTER
CSQL += "			INNER JOIN ZZ6010 ZZ6 ON   " + ENTER
CSQL += "				ZZ6.ZZ6_COD = B1_YFORMAT AND  " + ENTER
CSQL += "				ZZ6.D_E_L_E_T_ = '' " + ENTER
If Trim(CEMPRESA)<>""
	CSQL += "			INNER JOIN ZZ7010 ZZ7 ON   " + ENTER
	CSQL += "				B1_YLINHA=ZZ7_COD AND  " + ENTER 
	CSQL += "				B1_YLINSEQ=ZZ7_LINSEQ AND  " + ENTER
	CSQL += "				ZZ7_EMP='" + CEMPRESA + "' AND  " + ENTER
	CSQL += "				ZZ7.D_E_L_E_T_ = '' " + ENTER
EndIf
CSQL += "		WHERE	SB1.B1_YFORMAT <> '' AND  " + ENTER
CSQL += "				SB1.B1_TIPO = 'PA' AND  " + ENTER
CSQL += "				SB1.B1_RASTRO = 'L' AND  " + ENTER
CSQL += "				SB1.B1_MSBLQL = '2' AND  " + ENTER
CSQL += "				B1_YCLASSE <> '' AND " + ENTER
CSQL += "				SB1.D_E_L_E_T_ = ''  " + ENTER
CSQL += "				AND B1_YFORMAT BETWEEN '" + CFORMATO_DE + "' AND '" + CFORMATO_AT + "'  " + ENTER
CSQL += "				AND B1_YCLASSE BETWEEN '" + CCLASSE_DE + "' AND '" + CCLASSE_AT + "'  " + ENTER
CSQL += "				AND B1_COD BETWEEN '" + CPRODUTO_DE + "' AND '" + CPRODUTO_AT + "'  " + ENTER
CSQL += "		) AS PRINCIPAL " + ENTER
//CSQL += "WHERE (A+B+C+D+E+F) <> '000000' " + ENTER
CSQL += "WHERE ( (A+B+C+D+E+F) <> '000000' OR ESTOQUE_ATUAL > 0 OR SALDO_P3 > 0) " + ENTER 
If CSTATUS == 1 //ativo
	CSQL += "	AND B1_YSTATUS IN ('1')" + ENTER
ElseIf CSTATUS == 2 //descontinuado
	CSQL += "	AND B1_YSTATUS IN ('2')" + ENTER
ElseIf CSTATUS == 3 //obsoleto
	CSQL += "	AND B1_YSTATUS IN ('3')" + ENTER
ElseIf CSTATUS == 4 //descontinuado e obsoleto
	CSQL += "	AND B1_YSTATUS IN ('2','3')" + ENTER
EndIf
CSQL += " GROUP BY B1_YFORMAT, B1_DESC, B1_YSTATUS, B1_COD "
//DTOS(dDatabase)
TCSQLEXEC(CSQL)

             
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SE IMPRESSAO EM DISCO, CHAMA O GERENCIADOR DE IMPRESSAO...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF ARETURN[5]==1
	//PARAMETROS CRYSTAL EM DISCO
	PRIVATE COPCAO:="1;0;1;ANALISE"
ELSE
	//DIRETO IMPRESSORA
	PRIVATE COPCAO:="3;0;1;ANALISE"
ENDIF
//ATIVAREL()
CALLCRYS("ANA_PROJ",CEMPANT,COPCAO)
RETURN