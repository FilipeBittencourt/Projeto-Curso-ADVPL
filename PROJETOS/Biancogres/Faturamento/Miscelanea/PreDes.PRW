#include "rwMake.ch"
#include "Topconn.ch"
/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  � PREVDES        �Autor  � HARLEY DIAS KOEHLER� Data �  14/03/07   ���
�������������������������������������������������������������������������������͹��
���Desc.     � RELATORIO DE PREVISAO DE DESPESAS - MARKETING                    ���
�������������������������������������������������������������������������������͹��
���Uso       � AP 7                                                             ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
User Function PREDES()
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Private cSQL
Private Enter := CHR(13)+CHR(10) 
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Comparativo de Pesos "
cTamanho   := ""
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "PREDES"
cPerg      := "PREDES"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Relatorio Previsao de Despesas - Marketing"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "PREDES"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t. 

      
//��������������������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT.								     �
//� Verifica Posicao do Formulario na Impressora.				             �
//� Solicita os parametros para a emissao do relatorio			             |
//����������������������������������������������������������������������������
pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
//Cancela a impressao
If nLastKey == 27
	Return
Endif

cSQL := ""
cSQL += "ALTER VIEW VW_PREDES AS " + Enter
cSQL += "SELECT ZO_DATA AS DATA, A3_NOME AS REPRESENTANTE,	A1_NOME AS CLIENTE, ZO_VALOR AS VALOR, " + Enter
cSQL += "		ZO_TPDES AS TIPODESP, ZO_FPAGTO AS FORMAPAG, ZO_DESCR AS DESCRICAO, A1_COD, A1_GRPVEN " + Enter
cSQL += "FROM " + RetSqlName("SZO") + " SZO, " + RetSqlName("SA1") + " SA1, " + RetSqlName("SA3") + " SA3 "+ Enter
cSQL += "WHERE 	SZO.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' AND SA3.D_E_L_E_T_ = '' AND " + Enter
cSQL += "		ZO_REPRE = A3_COD AND ZO_CLIENTE = A1_COD AND ZO_LOJA = A1_LOJA AND " + Enter
cSQL += "		ZO_STATUS		= 'Baixa Total' AND " + Enter
cSQL += "		ZO_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' AND " + Enter
cSQL += "		ZO_REPRE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + Enter
cSQL += "		ZO_CLIENTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + Enter
cSQL += "		AND SA1.A1_GRPVEN BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'  " + Enter
cSQL += "		AND SZO.ZO_SERIE BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'  " + Enter
IF ALLTRIM(MV_PAR11) <> ""
	cSQL += "		AND SA3.A3_COD IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+" WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND ZZI_ATENDE = '"+MV_PAR11+"'	AND D_E_L_E_T_ = '') " + Enter
END IF 

TcSQLExec(cSQL)                    	
//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������
If aReturn[5]==1
	//Parametros Crystal Em Disco
	Private cOpcao:="1;0;1;Apuracao"
Else
	//Direto Impressora
	Private cOpcao:="3;0;1;Apuracao"
Endif
callcrys("PREDES",Dtoc(MV_PAR01)+";"+Dtoc(MV_PAR02)+";"+MV_PAR03+";"+MV_PAR04+";"+MV_PAR05+";"+MV_PAR06+";"+MV_PAR07+";"+MV_PAR08+";"+cempant,cOpcao)

Return