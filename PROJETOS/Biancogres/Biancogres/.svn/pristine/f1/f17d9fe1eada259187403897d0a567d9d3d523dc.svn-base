#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  PRA_ENT       บAutor  ณ BRUNO MADALENO     บ Data ณ  18/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio em Crystal para gerar OS PRAZIOS DE ENTREGA             บฑฑ
ฑฑบ          ณ																 																	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PRA_ENT()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cSQL
Private Enter := CHR(13)+CHR(10) 
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Informa็๕es dos prazos de entrega           "
cTamanho   := ""
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "PR_ENT"
cPerg      := "PR_ENT"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Informa็oes sobre prazo medio"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "PR_ENT"
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
EndIf

If MV_PAR16 = 1
	GeraDuplicata := "S"
ElseIf MV_PAR16 = 2
	GeraDuplicata := "N"
Else
	GeraDuplicata := "A"
EndIf

If MV_PAR17 = 1
	AtualizaEstoque := "S"
ElseIf MV_PAR17 = 2
	AtualizaEstoque := "N"
Else
	AtualizaEstoque := "A"
EndIf

cSQL := ""
cSQL += "ALTER VIEW VW_PRAZO_ENTREGA AS   " + Enter
If MV_PAR11 = 1
	cSQL += "SELECT	(SELECT MAX(CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_ENTREG),103) ) " + Enter
Else
	cSQL += "SELECT	(SELECT MAX(CONVERT(VARCHAR(10),CONVERT(DATETIME,C6_YEMISSA),103) ) " + Enter
EndIf
cSQL += "		 FROM "+ RetSqlName("SC6")+"   " + Enter
cSQL += "		 WHERE	C6_FILIAL  	= '"+xFilial("SC6")+"' AND " + Enter
cSQL += "				C6_NUM	   	= SD2.D2_PEDIDO	AND	" + Enter
cSQL += "				C6_PRODUTO 	= SD2.D2_COD	AND " + Enter
cSQL += "				C6_ITEM		= SD2.D2_ITEMPV	AND " + Enter
cSQL += "				C6_CLI		= SD2.D2_CLIENTE	AND  " + Enter
cSQL += "				C6_LOJA 	= SD2.D2_LOJA	AND " + Enter
cSQL += "     			D_E_L_E_T_ = '') AS DATA , 		" + Enter
cSQL += "	--SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_VEND1,  " + Enter
cSQL += "	 " + Enter
cSQL += "	SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, CONVERT(VARCHAR(10),CONVERT(DATETIME,F2_EMISSAO),103) AS F2_EMISSAO,  " + Enter
cSQL += "	SD2.D2_COD, SB1.B1_DESC, SD2.D2_QUANT,  " + Enter
cSQL += "	SA1.A1_NOME, " + Enter
cSQL += "	SA3.A3_NOME, F2_VEND1  " + Enter
cSQL += "  " + Enter
cSQL += "  " + Enter
cSQL += "FROM "+ RetSqlName("SF2")+" SF2, "+ RetSqlName("SD2")+" SD2, "+ RetSqlName("SA1")+" SA1, "+ RetSqlName("SA3")+" SA3, "+ RetSqlName("SB1")+" SB1, "+ RetSqlName("SF4")+" SF4  " + Enter
cSQL += "WHERE	SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND " + Enter
cSQL += "		SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND " + Enter
cSQL += "		SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND " + Enter
cSQL += "		SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND " + Enter
cSQL += "		SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND " + Enter
cSQL += "		SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND " + Enter
cSQL += " " + Enter
cSQL += "		SF2.F2_DOC		= SD2.D2_DOC AND  " + Enter
cSQL += "		SF2.F2_SERIE	= SD2.D2_SERIE AND  " + Enter
cSQL += "		SF2.F2_CLIENTE  = SD2.D2_CLIENTE AND " + Enter
cSQL += "		SF2.F2_LOJA		= SD2.D2_LOJA	AND " + Enter
cSQL += "		SF2.F2_CLIENTE  = SA1.A1_COD	AND   " + Enter
cSQL += "		SF2.F2_LOJA     = SA1.A1_LOJA	AND   " + Enter
cSQL += "		SF2.F2_VEND1	= SA3.A3_COD	AND    " + Enter
cSQL += "		SD2.D2_COD		= SB1.B1_COD	AND  " + Enter
cSQL += "		SD2.D2_TES		= SF4.F4_CODIGO AND   " + Enter
cSQL += " " + Enter

cSQL += "		SF2.F2_CLIENTE	BETWEEN '"+  MV_PAR07 +"'  AND '"+  MV_PAR08 +"' 	AND  " + Enter
cSQL += "		SF2.F2_VEND1	BETWEEN '"+  MV_PAR05 +"'  AND '"+  MV_PAR06 +"' 	AND  " + Enter
cSQL += "		SF2.F2_EMISSAO	BETWEEN '"+  DTOS(MV_PAR01) +"'  AND '"+  DTOS(MV_PAR02) +"' AND  " + Enter
cSQL += "		SF2.F2_SERIE	BETWEEN '"+  MV_PAR03 +"'  AND '"+  MV_PAR04 +"' 	AND  " + Enter
cSQL += "		SA3.A3_SUPER	BETWEEN '"+  MV_PAR12 +"' AND '"+  MV_PAR13 +"' AND  " + Enter
cSQL += "		SB1.B1_GRUPO	BETWEEN '"+  MV_PAR14 +"' AND '"+  MV_PAR15 +"' AND " + Enter
cSQL += "		SB1.B1_COD		BETWEEN '"+  MV_PAR09 +"' AND '"+  MV_PAR10 +"' AND " + Enter
cSQL += "		SB1.B1_YFORMAT BETWEEN '"+  MV_PAR18 +"' AND '"+  MV_PAR19 +"' AND " + Enter // Tiago Rossini Coradini - OS: 2350-15 
If MV_PAR20 <> ""
	cSQL += "		SB1.B1_YFORMAT IN ('"+  Replace(AllTrim(MV_PAR20),"/","','") +"') AND " + Enter
EndIf
If AtualizaEstoque <> "A" 
	cSQL += "	SF4.F4_ESTOQUE = '"+  AtualizaEstoque +"' AND " + Enter
EndIf
If GeraDuplicata <> "A" 
	cSQL += "	SF4.F4_DUPLIC = '"+  GeraDuplicata +"' AND " + Enter
EndIf
cSQL += " " + Enter
cSQL += " " + Enter
cSQL += "		SF2.D_E_L_E_T_ = '' AND  " + Enter
cSQL += "		SD2.D_E_L_E_T_ = '' AND  " + Enter
cSQL += "		SA1.D_E_L_E_T_ = '' AND  " + Enter
cSQL += "		SA3.D_E_L_E_T_ = '' AND  " + Enter
cSQL += "		SB1.D_E_L_E_T_ = '' AND  " + Enter
cSQL += "		SF4.D_E_L_E_T_ = ''   " + Enter
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
EndIf
callcrys("PR_ENT",cEmpant+";"+ALLTRIM(STR(MV_PAR11)),cOpcao)
Return