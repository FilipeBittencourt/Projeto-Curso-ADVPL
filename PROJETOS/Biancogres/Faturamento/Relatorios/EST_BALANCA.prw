#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ EST_BALANCA    บAutor  ณBRUNO MADALENO      บ Data ณ  15/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRELATORIOS DE ESTATISTICA BALANCA                                 บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function EST_BALANCA()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cSQL
PRIVATE ENTER    := CHR(13)+CHR(10)
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "ESTATISTICA BALANวA"
cTamanho   := ""
limite     := 80
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "BALSTA"
cPerg      := "BALSTA"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "ESTATISTICA DA BALANวA"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1
wnrel      := "BALSTA"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .T.
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
cSQL += "ALTER VIEW VW_PESA_RESQUANT AS  " + ENTER
cSQL += "SELECT 'QUANTIDADE PESAGEM' AS TIPO, COUNT(Z11_PESAGE) AS QUANT " + ENTER
cSQL += "FROM --"+RETSQLNAME("Z11")+" Z11,  " + ENTER

cSQL += "		(SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE,Z11_PESAGE FROM Z11010 Z11, Z12010 Z12 WHERE  Z11.D_E_L_E_T_ = '' AND Z12_NFISC <> '' AND Z12.D_E_L_E_T_ = '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"' " + ENTER
cSQL += "		UNION  " + ENTER
cSQL += "		SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE,Z11_PESAGE FROM Z11050 Z11, Z12050 Z12 WHERE  Z11.D_E_L_E_T_ = '' AND Z12_NFISC <> '' AND Z12.D_E_L_E_T_ = '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"') AS AB  " + ENTER
cSQL += "WHERE	Z11_DATAIN BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " + ENTER
cSQL += "		Z11_MERCAD = '1' " + ENTER

cSQL += "UNION ALL " + ENTER

cSQL += "SELECT 'QUANTIDADE NOTA FISCAL' AS TIPO, COUNT(D1_COD) AS QUANT " + ENTER
cSQL += "FROM "+RETSQLNAME("SD1")+" " + ENTER
cSQL += "WHERE 	D1_FILIAL = '01' AND  " + ENTER
cSQL += "		D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " //CONVERT(INT,CONVERT(VARCHAR(8), DATEADD(D,5,'"+DTOS(MV_PAR02)+"') ,112)) AND " + ENTER
cSQL += "		D1_ITEM = '0001' AND " + ENTER
cSQL += "		SUBSTRING(D1_COD,1,1) = '1' AND " + ENTER
cSQL += "		SUBSTRING(D1_CF,2,3) IN ('101') AND " + ENTER
cSQL += "		D_E_L_E_T_ = '' " + ENTER
TcSQLExec(cSQL)



//*************************************************************************
//*************************************************************************
//            ESTATISTICAS DE DIVERGENCIA
//*************************************************************************
//*************************************************************************
cSQL := "-- NOTAS DA PESAGEM QUE NรO EXISTE NO SF1 " + ENTER
cSQL += "ALTER VIEW VW_PESA_RESDIVER AS  " + ENTER
cSQL += "SELECT 'NF NA PESAGEM SEM NF CADASTRADA' AS TIPO, COUNT(Z12_PESAGE) AS QUANT " + ENTER
cSQL += "FROM   " + ENTER

cSQL += "		(SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE FROM Z11010 Z11, Z12010 Z12 WHERE  Z11.D_E_L_E_T_ = '' AND Z12_NFISC <> '' AND Z12.D_E_L_E_T_ = '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"' " + ENTER
cSQL += "		UNION  " + ENTER
cSQL += "		SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE FROM Z11050 Z11, Z12050 Z12 WHERE  Z11.D_E_L_E_T_ = '' AND Z12_NFISC <> '' AND Z12.D_E_L_E_T_ = '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"') AS AB  " + ENTER

cSQL += "WHERE	Z11_DATAIN BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " + ENTER
cSQL += "		Z11_MERCAD = '1' " + ENTER
cSQL += "		AND Z12_NFISC NOT IN(SELECT D1_DOC " + ENTER
cSQL += "							FROM "+RETSQLNAME("SD1")+" " + ENTER
cSQL += "							WHERE 	D1_FILIAL = '01' AND  " + ENTER
cSQL += "									D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND  '"+DTOS(MV_PAR02)+"' AND " //CONVERT(INT,CONVERT(VARCHAR(8), DATEADD(D,7,'"+DTOS(MV_PAR02)+"') ,112)) AND " + ENTER
cSQL += "									D1_ITEM = '0001' AND " + ENTER
cSQL += "									SUBSTRING(D1_COD,1,1) = '1' AND " + ENTER
cSQL += "									SUBSTRING(D1_CF,2,3) IN ('101') AND " + ENTER
cSQL += "									D_E_L_E_T_ = '') " + ENTER
cSQL += "UNION ALL " + ENTER
cSQL += "-- NOTAS DO SF1 NรO EXISTE NA PESAGEM " + ENTER
cSQL += "SELECT 'NF CADASTRADA SEM NF NA PESAGEM' AS TIPO, COUNT(D1_DOC) AS QUANT " + ENTER
cSQL += "FROM "+RETSQLNAME("SD1")+" " + ENTER
cSQL += "WHERE 	D1_FILIAL = '01' AND  " + ENTER
cSQL += "		D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " + ENTER
cSQL += "		D1_ITEM = '0001' AND " + ENTER
cSQL += "		SUBSTRING(D1_COD,1,1) = '1' AND " + ENTER
cSQL += "		SUBSTRING(D1_CF,2,3) IN ('101') AND " + ENTER
cSQL += "		D_E_L_E_T_ = ''   " + ENTER
cSQL += "		AND	D1_DOC NOT IN(SELECT Z12_NFISC " + ENTER
cSQL += "							FROM 	 " + ENTER

cSQL += "									(SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE FROM Z11010 Z11, Z12010 Z12 WHERE  Z11.D_E_L_E_T_ = '' AND Z12_NFISC <> '' AND Z12.D_E_L_E_T_ = '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"' " + ENTER
cSQL += "									UNION  " + ENTER
cSQL += "									SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE FROM Z11050 Z11, Z12050 Z12 WHERE  Z11.D_E_L_E_T_ = '' AND Z12_NFISC <> '' AND Z12.D_E_L_E_T_ = '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"') AS AB  " + ENTER

cSQL += "							WHERE	Z11_DATAIN BETWEEN  '"+DTOS(MV_PAR01)+"'   AND '"+DTOS(MV_PAR02)+"' AND " + ENTER
cSQL += "									Z11_MERCAD = '1' )" + ENTER
TcSQLExec(cSQL)



//*************************************************************************
//*************************************************************************
//            LISTA DE ESTATISTICAS DE DIVERGENCIA
//*************************************************************************
//*************************************************************************
cSQL := "ALTER VIEW VW_PESA_LISTDIVER_Z11 AS  " + ENTER
cSQL += "SELECT Z11_DATAIN, Z11_PESLIQ, Z11_PESAGE, Z12_NFISC " + ENTER
cSQL += "FROM --"+RETSQLNAME("Z11")+" Z11,  " + ENTER

cSQL += "		(SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE,Z11_PESLIQ,Z11_PESAGE FROM Z11010 Z11, Z12010 Z12 WHERE  Z11.D_E_L_E_T_ = '' AND Z12_NFISC <> '' AND Z12.D_E_L_E_T_ = '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"' " + ENTER
cSQL += "		UNION  " + ENTER
cSQL += "		SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE,Z11_PESLIQ,Z11_PESAGE FROM Z11050 Z11, Z12050 Z12 WHERE  Z11.D_E_L_E_T_ = '' AND Z12_NFISC <> '' AND Z12.D_E_L_E_T_ = '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"') AS AB  " + ENTER

cSQL += "WHERE	Z11_DATAIN BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " + ENTER
cSQL += "		Z11_MERCAD = '1'  " + ENTER
cSQL += "		AND Z12_NFISC NOT IN(SELECT D1_DOC " + ENTER
cSQL += "							FROM "+RETSQLNAME("SD1")+" " + ENTER
cSQL += "							WHERE 	D1_FILIAL = '01' AND  " + ENTER
cSQL += "									D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND  '"+DTOS(MV_PAR02)+"' AND " //CONVERT(INT,CONVERT(VARCHAR(8), DATEADD(D,7,'"+DTOS(MV_PAR02)+"') ,112)) AND " + ENTER
cSQL += "									D1_ITEM = '0001' AND " + ENTER
cSQL += "									SUBSTRING(D1_COD,1,1) = '1' AND " + ENTER
cSQL += "									SUBSTRING(D1_CF,2,3) IN ('101') AND " + ENTER
cSQL += "									D_E_L_E_T_ = '') " + ENTER
TcSQLExec(cSQL)

cSQL := "ALTER VIEW VW_PESA_LISTDIVER_SF1 AS  " + ENTER
cSQL += "SELECT D1_DTDIGIT, D1_DOC, D1_FORNECE, D1_LOJA, A2_NREDUZ AS A2_NOME " + ENTER
cSQL += "FROM "+RETSQLNAME("SD1")+"  SD1, SA2010 SA2 " + ENTER
cSQL += "WHERE 	D1_FILIAL = '01' AND  " + ENTER      
cSQL += "		D1_FORNECE = A2_COD AND " + ENTER      
cSQL += "		D1_LOJA = A2_LOJA AND " + ENTER      
cSQL += "		D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " + ENTER
cSQL += "		D1_ITEM = '0001' AND " + ENTER
cSQL += "		SUBSTRING(D1_COD,1,1) = '1' AND " + ENTER
cSQL += "		SUBSTRING(D1_CF,2,3) IN ('101') AND " + ENTER
cSQL += "		SD1.D_E_L_E_T_ = ''   AND " + ENTER
cSQL += "		SA2.D_E_L_E_T_ = ''  " + ENTER
cSQL += "		AND	D1_DOC NOT IN(SELECT Z12_NFISC " + ENTER
cSQL += "							FROM 	 " + ENTER

cSQL += "									(SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE FROM Z11010 Z11, Z12010 Z12 WHERE  Z11.D_E_L_E_T_ = '' AND Z12_NFISC <> '' AND Z12.D_E_L_E_T_ = '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"' " + ENTER
cSQL += "									UNION  " + ENTER
cSQL += "									SELECT Z11_DATAIN,Z11_MERCAD,Z12_NFISC,Z12_PESAGE FROM Z11050 Z11, Z12050 Z12 WHERE  Z11.D_E_L_E_T_ = '' AND Z12_NFISC <> '' AND Z12.D_E_L_E_T_ = '' AND Z12.Z12_PESAGE = Z11.Z11_PESAGE AND Z12_EMP = '"+CEMPANT+"') AS AB  " + ENTER

cSQL += "							WHERE	Z11_DATAIN BETWEEN  '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " + ENTER
cSQL += "									Z11_MERCAD = '1' )" + ENTER
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
callcrys("BALANCA__NOTAFISCAL",cEmpant,cOpcao)
Return