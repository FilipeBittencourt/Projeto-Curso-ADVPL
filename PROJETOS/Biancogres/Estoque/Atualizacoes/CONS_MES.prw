#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CONS_MES       บAutor  ณBRUNO MADALENO      บ Data ณ  15/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRELATORIOS DE CONSUMES POR MES                                    บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 8 R4                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CONS_MES()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cSQL
PRIVATE ENTER    := CHR(13)+CHR(10)
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Consumo por M๊s"
cTamanho   := ""
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "CONMES"
cPerg      := "CONMES"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "CONSUMO MES"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "CONMES"
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


//*************************************************************************
//*************************************************************************
//            QUANTIDADES DE PESAGEM E NOTAS
//*************************************************************************
//*************************************************************************
cSQL := ""
cSQL := "ALTER VIEW VW_CONSUMO_MES AS " + ENTER
cSQL += "SELECT D3_COD, B1_DESC, D3_UM, D3_TIPO, D3_GRUPO, D3_LOCAL, SUM(REQ_QUANT) AS REQ_QUANT, SUM(REQ_VAL) AS REQ_VAL " + ENTER
cSQL += "FROM	(SELECT	D3_COD, B1_DESC, D3_UM, D3_TIPO, D3_GRUPO, D3_LOCAL, SUM(D3_QUANT) AS REQ_QUANT, SUM(D3_CUSTO1) AS REQ_VAL " + ENTER
cSQL += "				--,SD3.*  " + ENTER
cSQL += "		FROM "+RETSQLNAME("SD3")+" SD3, SB1010 SB1, "+RETSQLNAME("ZCN")+" ZCN " + ENTER
cSQL += "		WHERE	SD3.D3_FILIAL = '01' AND " + ENTER
cSQL += "				SD3.D3_TM > '500' AND " + ENTER
cSQL += "				SD3.D3_ESTORNO <> 'S' AND " + ENTER

cSQL += "				SD3.D3_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " + ENTER
cSQL += "				SD3.D3_EMISSAO BETWEEN '"+DTOS(MV_PAR09)+"' AND '"+DTOS(MV_PAR10)+"' AND " + ENTER
cSQL += "				SD3.D3_TIPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTER
cSQL += "				SD3.D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND " + ENTER
cSQL += "				SD3.D3_LOCAL BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND " + ENTER

cSQL += "				SB1.B1_FILIAL	=	'"+xFilial("SB1")+"'	AND	" + ENTER
cSQL += "				SB1.B1_COD 		=	SD3.D3_COD 						AND	" + ENTER
cSQL += "				SD3.D3_TM NOT IN  ('999','499') 			AND	" + ENTER
cSQL += "				ZCN.ZCN_FILIAL	= '"+xFilial("ZCN")+"'	AND	" + ENTER
cSQL += "				ZCN.ZCN_COD		=	SD3.D3_COD 						AND	" + ENTER
cSQL += "				ZCN.ZCN_LOCAL	=	SD3.D3_LOCAL 						AND	" + ENTER
IF MV_PAR11 == 1
	 cSQL += "    ZCN.ZCN_MD   = 'S' AND " + ENTER
ELSE
	 cSQL += "    ZCN.ZCN_MD   = 'N' AND " + ENTER
ENDIF

cSQL += "				ZCN.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "				SD3.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "				SB1.D_E_L_E_T_ = '' " + ENTER
cSQL += "		GROUP BY D3_COD, B1_DESC, D3_UM, D3_TIPO, D3_GRUPO, D3_LOCAL " + ENTER
cSQL += "		UNION ALL " + ENTER
cSQL += "		SELECT	D3_COD, B1_DESC, D3_UM, D3_TIPO, D3_GRUPO, D3_LOCAL, SUM(D3_QUANT) * -1 AS REQ_QUANT, SUM(D3_CUSTO1) * -1 AS REQ_VAL  " + ENTER
cSQL += "				--,SD3.*  " + ENTER
cSQL += "		FROM "+RETSQLNAME("SD3")+" SD3, SB1010 SB1, "+RETSQLNAME("ZCN")+" ZCN " + ENTER
cSQL += "		WHERE	SD3.D3_FILIAL = '01' AND " + ENTER
cSQL += "				SD3.D3_TM < '500' AND " + ENTER
cSQL += "				SD3.D3_ESTORNO <> 'S' AND " + ENTER

cSQL += "				SD3.D3_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " + ENTER
cSQL += "				SD3.D3_EMISSAO BETWEEN '"+DTOS(MV_PAR09)+"' AND '"+DTOS(MV_PAR10)+"' AND " + ENTER
cSQL += "				SD3.D3_TIPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + ENTER
cSQL += "				SD3.D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND " + ENTER
cSQL += "				SD3.D3_LOCAL BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND " + ENTER

cSQL += "				SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + ENTER
cSQL += "				SB1.B1_COD 		= SD3.D3_COD 						AND  " + ENTER
cSQL += "				SD3.D3_TM NOT IN  ('999','499') 			AND	" + ENTER

cSQL += "				ZCN.ZCN_FILIAL = '"+xFilial("ZCN")+"' AND " + ENTER
cSQL += "				ZCN.ZCN_COD    = SD3.D3_COD AND  " + ENTER
cSQL += "				ZCN.ZCN_LOCAL    = SD3.D3_LOCAL AND  " + ENTER
IF MV_PAR11 == 1
	 cSQL += "    ZCN.ZCN_MD   = 'S' AND " + ENTER
ELSE
	 cSQL += "    ZCN.ZCN_MD   = 'N' AND " + ENTER
ENDIF
                                                 
cSQL += "				ZCN.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "				SD3.D_E_L_E_T_ = '' AND " + ENTER
cSQL += "				SB1.D_E_L_E_T_ = '' " + ENTER
cSQL += "		GROUP BY D3_COD, B1_DESC, D3_UM, D3_TIPO, D3_GRUPO, D3_LOCAL) AS T " + ENTER
cSQL += "GROUP BY D3_COD, B1_DESC, D3_UM, D3_TIPO, D3_GRUPO, D3_LOCAL " + ENTER
TcSQLExec(cSQL)
                 	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF ARETURN[5]==1
	//PARAMETROS CRYSTAL EM DISCO
	PRIVATE cOpcao:="1;0;1;APURACAO"
ELSE
	//DIRETO IMPRESSORA
	PRIVATE cOpcao:="3;0;1;APURACAO"
ENDIF
//ATIVAREL()
callcrys("CONS_MES",cEmpAnt,cOpcao)
//callcrys("GesEst",lComum+";"+cEmpAnt,cOpcao)
Return