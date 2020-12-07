#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ EST_QUAN_VENDASบAutor  ณBRUNO MADALENO      บ Data ณ  15/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRELATORIOS DE QUANTIDADE DE PEDIDOS INPLANTADOS                   บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function EST_QUAN_VENDAS()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cSQL
PRIVATE ENTER    := CHR(13)+CHR(10)
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "ESTATISTICA DE VENDAS"
cTamanho   := ""
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "ESTQUA"
cPerg      := "ESTQUA"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "ESTATISTICA DE VENDAS"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "ESTQUA"
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

cPedido		:= MV_PAR01
//*************************************************************************
//*************************************************************************
//View para trazer as informacoes do processo e os produtos que o pertence
//*************************************************************************
//*************************************************************************
cSQL := ""
cSQL := "ALTER VIEW VW_ESTATIC_PEDIDO AS " + ENTER
cSQL += "		SELECT 'PALM' AS TIPO, A3_NOME AS VEND, SUBSTRING(CJ_EMISSAO,1,6) AS MESANO, COUNT(CJ_NUM) AS QUANT, COUNT(CJ_NUM) AS QUANT1 " + ENTER
cSQL += "		FROM "+RETSQLNAME("SC5")+" SC5, "+RETSQLNAME("SCJ")+" SCJ, SA3010 SA3 " + ENTER
cSQL += "		WHERE	C5_FILIAL = '01' AND C5_NUM = CJ_NUM AND " + ENTER
cSQL += "				CJ_YPALNUM <> '' AND " + ENTER
cSQL += "				CJ_YVEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTER
cSQL += "				C5_VEND1 <> '999997' AND " + ENTER
cSQL += "				CJ_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND " + ENTER
cSQL += "				SC5.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "				SCJ.D_E_L_E_T_ = '' " + ENTER
cSQL += "				AND SA3.A3_COD = CJ_YVEND " + ENTER
cSQL += "				AND SA3.D_E_L_E_T_ = '' " + ENTER
cSQL += "				AND C5_NUM IN (SELECT C6_NUM " + ENTER
cSQL += "								FROM "+RETSQLNAME("SC6")+" SC6, "+RETSQLNAME("SF4")+" SF4  " + ENTER
cSQL += "								WHERE	SC6.C6_FILIAL = '01' AND SC6.C6_TES = SF4.F4_CODIGO AND " + ENTER
cSQL += "										SF4.F4_DUPLIC = 'S' AND " + ENTER
cSQL += "										SC6.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "										SF4.D_E_L_E_T_ = ''  " + ENTER
cSQL += "								GROUP BY C6_NUM)  " + ENTER
cSQL += "		GROUP BY A3_NOME, SUBSTRING(CJ_EMISSAO,1,6) " + ENTER
cSQL += "		UNION ALL " + ENTER
cSQL += "		SELECT 'REMOTO' AS TIPO, A3_NOME AS VEND, SUBSTRING(CJ_EMISSAO,1,6) AS MESANO,COUNT(CJ_NUM) AS QUANT, COUNT(CJ_NUM) AS QUANT1 " + ENTER
cSQL += "		FROM "+RETSQLNAME("SC5")+" SC5, "+RETSQLNAME("SCJ")+" SCJ, SA3010 SA3 " + ENTER
cSQL += "		WHERE	C5_FILIAL = '01' AND C5_NUM = CJ_NUM AND " + ENTER
cSQL += "				CJ_YPALNUM = '' AND " + ENTER
cSQL += "				CJ_YVEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTER
cSQL += "				C5_VEND1 <> '999997' AND " + ENTER
cSQL += "				CJ_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND " + ENTER
cSQL += "				SC5.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "				SCJ.D_E_L_E_T_ = '' " + ENTER
cSQL += "				AND SA3.A3_COD = CJ_YVEND " + ENTER
cSQL += "				AND SA3.D_E_L_E_T_ = '' " + ENTER
cSQL += "				AND C5_NUM IN (SELECT C6_NUM " + ENTER
cSQL += "								FROM "+RETSQLNAME("SC6")+" SC6, "+RETSQLNAME("SF4")+" SF4  " + ENTER
cSQL += "								WHERE	SC6.C6_FILIAL = '01' AND SC6.C6_TES = SF4.F4_CODIGO AND " + ENTER
cSQL += "										SF4.F4_DUPLIC = 'S' AND " + ENTER
cSQL += "										SC6.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "										SF4.D_E_L_E_T_ = ''  " + ENTER
cSQL += "								GROUP BY C6_NUM)  " + ENTER
cSQL += "		GROUP BY A3_NOME, SUBSTRING(CJ_EMISSAO,1,6) " + ENTER
cSQL += "		UNION ALL " + ENTER
cSQL += "		SELECT 'MANUAL' AS TIPO, A3_NOME AS VEND, SUBSTRING(C5_EMISSAO,1,6) AS MESANO, COUNT(C5_NUM) AS QUANT, COUNT(C5_NUM) AS QUANT1 " + ENTER
cSQL += "		FROM "+RETSQLNAME("SC5")+" SC5, SA3010 SA3 " + ENTER
cSQL += "		WHERE	C5_FILIAL = '01' AND C5_VEND1 BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTER
cSQL += "				C5_VEND1 <> '999997' AND " + ENTER
cSQL += "				C5_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND " + ENTER
cSQL += "				SC5.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "				SC5.C5_NUM NOT IN (SELECT CJ_NUM FROM SCJ010 WHERE D_E_L_E_T_ = '') " + ENTER
cSQL += "				AND SA3.A3_COD = C5_VEND1 " + ENTER
cSQL += "				AND SA3.D_E_L_E_T_ = '' " + ENTER
cSQL += "				AND C5_NUM IN (SELECT C6_NUM " + ENTER
cSQL += "								FROM "+RETSQLNAME("SC6")+" SC6, "+RETSQLNAME("SF4")+" SF4  " + ENTER
cSQL += "								WHERE	SC6.C6_FILIAL = '01' AND SC6.C6_TES = SF4.F4_CODIGO AND " + ENTER
cSQL += "										SF4.F4_DUPLIC = 'S' AND " + ENTER
cSQL += "										SC6.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "										SF4.D_E_L_E_T_ = ''  " + ENTER
cSQL += "								GROUP BY C6_NUM)  " + ENTER
cSQL += "		GROUP BY A3_NOME, SUBSTRING(C5_EMISSAO,1,6) " + ENTER
cSQL += "		 " + ENTER
cSQL += "		UNION ALL " + ENTER
cSQL += "		 " + ENTER
cSQL += "		-- TOTAL GERAL " + ENTER
cSQL += "		SELECT 'PALM' AS TIPO, A3_NOME AS VEND, 'TOTAL GERAL' AS MESANO, COUNT(CJ_NUM) AS QUANT, COUNT(CJ_NUM) AS QUANT1 " + ENTER
cSQL += "		FROM "+RETSQLNAME("SC5")+" SC5, "+RETSQLNAME("SCJ")+" SCJ, SA3010 SA3 " + ENTER
cSQL += "		WHERE	C5_FILIAL = '01' AND C5_NUM = CJ_NUM AND " + ENTER
cSQL += "				CJ_YPALNUM <> '' AND " + ENTER
cSQL += "				CJ_YVEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTER
cSQL += "				C5_VEND1 <> '999997' AND " + ENTER
cSQL += "				CJ_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND " + ENTER
cSQL += "				SC5.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "				SCJ.D_E_L_E_T_ = '' " + ENTER
cSQL += "				AND SA3.A3_COD = CJ_YVEND " + ENTER
cSQL += "				AND SA3.D_E_L_E_T_ = '' " + ENTER
cSQL += "				AND C5_NUM IN (SELECT C6_NUM " + ENTER
cSQL += "								FROM "+RETSQLNAME("SC6")+" SC6, "+RETSQLNAME("SF4")+" SF4  " + ENTER
cSQL += "								WHERE	SC6.C6_FILIAL = '01' AND SC6.C6_TES = SF4.F4_CODIGO AND " + ENTER
cSQL += "										SF4.F4_DUPLIC = 'S' AND " + ENTER
cSQL += "										SC6.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "										SF4.D_E_L_E_T_ = ''  " + ENTER
cSQL += "								GROUP BY C6_NUM)  " + ENTER
cSQL += "		GROUP BY A3_NOME " + ENTER
cSQL += "		UNION ALL " + ENTER
cSQL += "		SELECT 'REMOTO' AS TIPO, A3_NOME AS VEND, 'TOTAL GERAL' AS MESANO,COUNT(CJ_NUM) AS QUANT, COUNT(CJ_NUM) AS QUANT1 " + ENTER
cSQL += "		FROM "+RETSQLNAME("SC5")+" SC5, "+RETSQLNAME("SCJ")+" SCJ, SA3010 SA3 " + ENTER
cSQL += "		WHERE	C5_FILIAL = '01' AND C5_NUM = CJ_NUM AND " + ENTER
cSQL += "				CJ_YPALNUM = '' AND " + ENTER
cSQL += "				CJ_YVEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTER
cSQL += "				C5_VEND1 <> '999997' AND " + ENTER
cSQL += "				CJ_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND " + ENTER
cSQL += "				SC5.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "				SCJ.D_E_L_E_T_ = '' " + ENTER 
cSQL += "				AND SA3.A3_COD = CJ_YVEND " + ENTER
cSQL += "				AND SA3.D_E_L_E_T_ = '' " + ENTER
cSQL += "				AND C5_NUM IN (SELECT C6_NUM " + ENTER
cSQL += "								FROM "+RETSQLNAME("SC6")+" SC6, "+RETSQLNAME("SF4")+" SF4  " + ENTER
cSQL += "								WHERE	SC6.C6_FILIAL = '01' AND SC6.C6_TES = SF4.F4_CODIGO AND " + ENTER
cSQL += "										SF4.F4_DUPLIC = 'S' AND " + ENTER
cSQL += "										SC6.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "										SF4.D_E_L_E_T_ = ''  " + ENTER
cSQL += "								GROUP BY C6_NUM)  " + ENTER
cSQL += "		GROUP BY A3_NOME " + ENTER
cSQL += "		UNION ALL " + ENTER
cSQL += "		SELECT 'MANUAL' AS TIPO, A3_NOME AS VEND, 'TOTAL GERAL' AS MESANO, COUNT(C5_NUM) AS QUANT, COUNT(C5_NUM) AS QUANT1 " + ENTER
cSQL += "		FROM "+RETSQLNAME("SC5")+" SC5, SA3010 SA3 " + ENTER
cSQL += "		WHERE	C5_FILIAL = '01' AND C5_VEND1 BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTER
cSQL += "				C5_VEND1 <> '999997' AND " + ENTER
cSQL += "				C5_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND " + ENTER
cSQL += "				SC5.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "				SC5.C5_NUM NOT IN (SELECT CJ_NUM FROM SCJ010 WHERE D_E_L_E_T_ = '') " + ENTER
cSQL += "				AND SA3.A3_COD = C5_VEND1 " + ENTER
cSQL += "				AND SA3.D_E_L_E_T_ = '' " + ENTER
cSQL += "				AND C5_NUM IN (SELECT C6_NUM " + ENTER
cSQL += "								FROM "+RETSQLNAME("SC6")+" SC6, "+RETSQLNAME("SF4")+" SF4  " + ENTER
cSQL += "								WHERE	SC6.C6_FILIAL = '01' AND SC6.C6_TES = SF4.F4_CODIGO AND " + ENTER
cSQL += "										SF4.F4_DUPLIC = 'S' AND " + ENTER
cSQL += "										SC6.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "										SF4.D_E_L_E_T_ = ''  " + ENTER
cSQL += "								GROUP BY C6_NUM)  " + ENTER
cSQL += "		GROUP BY A3_NOME " + ENTER
//RETURN
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
callcrys("ESTATITISTAVENDAS",cEmpant,cOpcao)
RETURN