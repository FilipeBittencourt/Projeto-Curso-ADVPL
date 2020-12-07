#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VENDAS         บAutor  ณBRUNO MADALENO      บ Data ณ  01/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio em Crystal para gerar AS VENDAS                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VENDAS()
Local Enter := CHR(13)+CHR(10)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
Private cSQL
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "As Vendas"
cTamanho   := ""
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "VENDAS"
cPerg      := "VENDAS"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "VENDAS"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "VENDAS"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.
cEmpresa   := cEmpant 
cPARAMETROS := ""
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT.								     ณ
//ณ Verifica Posicao do Formulario na Impressora.				             ณ
//ณ Solicita os parametros para a emissao do relatorio			             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
U_LOG_USO("VENDAS")

pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
//Cancela a impressao
If nLastKey == 27
	Return
Endif

MESANODE1 	:= SUBSTRING(DTOS(MV_PAR01),5,2) + "/" + SUBSTRING(DTOS(MV_PAR01),1,4) 	//FATURAMENTO INICIAL
MESANOATE1 	:= SUBSTRING(DTOS(MV_PAR02),5,2) + "/" + SUBSTRING(DTOS(MV_PAR02),1,4) 	//FATURAMENTO FINAL
MESANODE2	:= SUBSTRING(DTOS(MV_PAR03),5,2) + "/" + SUBSTRING(DTOS(MV_PAR03),1,4) 	//FATURAMENTO INICIAL
MESANOATE2 	:= SUBSTRING(DTOS(MV_PAR04),5,2) + "/" + SUBSTRING(DTOS(MV_PAR04),1,4) 	//FATURAMENTO FINAL
MESANODE3 	:= SUBSTRING(DTOS(MV_PAR05),5,2) + "/" + SUBSTRING(DTOS(MV_PAR05),1,4) 	//FATURAMENTO INICIAL
MESANOATE3 	:= SUBSTRING(DTOS(MV_PAR06),5,2) + "/" + SUBSTRING(DTOS(MV_PAR06),1,4) 	//FATURAMENTO FINAL
LINHADE 		:= MV_PAR07       //LINHADE
LINHATE 		:= MV_PAR08       //LINHADE
QUANTIDADE 		:= ALLTRIM(STR(VAL(MV_PAR09))) + "." + SUBSTR( SUBSTR(MV_PAR09,1)  ,  LEN(ALLTRIM(STR(VAL(MV_PAR09)))) + 2  ,  100 )    

//*************************************************************************
//*************************************************************************
//View para trazer as informacoes doS LIMITES DE CREDITO
//*************************************************************************
//*************************************************************************
cSQL := ""
cSQL += "ALTER VIEW VW_VENDAS AS " + Enter
cSQL += "SELECT 'EMPRESA' AS EMPRESA, " + Enter  	//-- QUERY PERIODO 1 MAIOR LINHA 1 
cSQL += "         MERCADO =  " + Enter
cSQL += "         CASE  " + Enter
cSQL += "            WHEN SA1.A1_EST <> 'EX' THEN 'A' " + Enter //-- MERCADO INTERNO
cSQL += "            ELSE 'B'                         " + Enter  //-- MERCADO EXTERNO
cSQL += "         END, " + Enter
cSQL += "         SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD,  " + Enter
cSQL += "         SA1.A1_NOME, (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE1) + "' ,4,4)+SUBSTRING( '" +  (MESANODE1) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE1) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE1) + "' ,1,2)+'01'))+1)) AS QUANT1, 0 AS QUANT2, 0 AS QUANT3  " + Enter
cSQL += "   FROM SB1010 SB1, " + RETSQLNAME("SA1") + " SA1, " + RETSQLNAME("SA3") + " SA3, " + RETSQLNAME("SD2") + " SD2, " + RETSQLNAME("SF4") + " SF4        " + Enter
cSQL += "   WHERE SD2.D_E_L_E_T_ =  '' AND               " + Enter
cSQL += "         SF4.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA1.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA3.D_E_L_E_T_ =  '' AND " + Enter 
cSQL += "         SB1.D_E_L_E_T_ =  '' AND " + Enter //RANISSES

IF SM0->M0_CODIGO ="01"
	cSQL += "         SA3.A3_COD     =* SA1.A1_VEND    AND " + Enter
ELSE
	cSQL += "         SA3.A3_COD     =* SA1.A1_YVENDI  AND  " + Enter
	cSQL += "		  SD2.D2_CLIENTE <> '000481'	   AND  " + Enter // ALTERACAO PARA EXCLUIR AS VENDAS REALIZADAS DA INCESA PARA BIANCOGRES EM 23/09/08
END IF

cSQL += "         SA1.A1_COD     =  SD2.D2_CLIENTE AND " + Enter
cSQL += "         SA1.A1_LOJA    =  SD2.D2_LOJA    AND " + Enter
cSQL += "         SD2.D2_FILIAL  =  SF4.F4_FILIAL  AND " + Enter
cSQL += "         SD2.D2_TES     =  SF4.F4_CODIGO  AND " + Enter
cSQL += "         SD2.D2_COD     =  SB1.B1_COD     AND " + Enter //RANISSES
//cSQL += "		  SF4.F4_ESTOQUE =  'S'            AND " + Enter //RANISSES
cSQL += "         SF4.F4_DUPLIC  =  'S'            AND " + Enter
cSQL += "         SD2.D2_GRUPO   =  'PA'           AND " + Enter
cSQL += "         SD2.D2_SERIE BETWEEN '"+ LINHADE +"' AND '"+ LINHATE +"' AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) >= SUBSTRING( '" +  (MESANODE1) + "' ,4,4)+SUBSTRING( '" +  (MESANODE1) + "' ,1,2)   AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) <= SUBSTRING( '" +  (MESANOATE1) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE1) + "' ,1,2) AND " + Enter
cSQL += "		  SB1.B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND SUBSTRING(SB1.B1_COD,1,1) >= 'A'  " + Enter
//cSQL += "         SUBSTRING(D2_COD,1,1) <> 'P' " + Enter //RANISSES
cSQL += "   GROUP BY SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD, SA1.A1_NOME  " + Enter
cSQL += "   HAVING (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE1) + "' ,4,4)+SUBSTRING( '" +  (MESANODE1) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE1) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE1) + "' ,1,2)+'01'))+1)) >=  '" + QUANTIDADE + "'  " + Enter

cSQL += "   UNION " + Enter

cSQL += "   SELECT 'EMPRESA' AS EMPRESA,							-- QUERY PERIODO 2 MAIOR LINHA 1 " + Enter
cSQL += "         MERCADO =  " + Enter
cSQL += "         CASE  " + Enter
cSQL += "            WHEN SA1.A1_EST <> 'EX' THEN 'A' -- MERCADO INTERNO " + Enter
cSQL += "            ELSE 'B'                         -- MERCADO EXTERNO " + Enter
cSQL += "         END, " + Enter
cSQL += "         SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD,  " + Enter
cSQL += "         SA1.A1_NOME, 0 AS QUANT1, (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE2) + "' ,4,4)+SUBSTRING( '" +  (MESANODE2) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE2) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE2) + "' ,1,2)+'01'))+1)) AS QUANT2, 0 AS QUANT3  " + Enter
cSQL += "   FROM SB1010 SB1, " + RETSQLNAME("SA1") + " SA1, " + RETSQLNAME("SA3") + " SA3, " + RETSQLNAME("SD2") + " SD2, " + RETSQLNAME("SF4") + " SF4        " + Enter
cSQL += "   WHERE SD2.D_E_L_E_T_ =  '' AND               " + Enter
cSQL += "         SF4.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA1.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA3.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SB1.D_E_L_E_T_ =  '' AND " + Enter

IF SM0->M0_CODIGO ="01"
	cSQL += "         SA3.A3_COD     =* SA1.A1_VEND    AND " + Enter
ELSE
	cSQL += "         SA3.A3_COD     =* SA1.A1_YVENDI  AND  " + Enter  
	cSQL += "		  SD2.D2_CLIENTE <> '000481'	   AND  " + Enter // ALTERACAO PARA EXCLUIR AS VENDAS REALIZADAS DA INCESA PARA BIANCOGRES EM 23/09/08
END IF

cSQL += "         SA1.A1_COD     =  SD2.D2_CLIENTE AND " + Enter
cSQL += "         SA1.A1_LOJA    =  SD2.D2_LOJA    AND " + Enter
cSQL += "         SD2.D2_FILIAL  =  SF4.F4_FILIAL  AND " + Enter
cSQL += "         SD2.D2_TES     =  SF4.F4_CODIGO  AND " + Enter
cSQL += "         SD2.D2_COD     =  SB1.B1_COD     AND " + Enter //RANISSES
//cSQL += "         SF4.F4_ESTOQUE =  'S'            AND " + Enter
cSQL += "         SF4.F4_DUPLIC  =  'S'            AND " + Enter
cSQL += "         SD2.D2_GRUPO   =  'PA'           AND " + Enter
cSQL += "         SD2.D2_SERIE BETWEEN '"+ LINHADE +"' AND '"+ LINHATE +"' AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) >= SUBSTRING( '" +  (MESANODE2) + "' ,4,4)+SUBSTRING( '" +  (MESANODE2) + "' ,1,2)   AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) <= SUBSTRING( '" +  (MESANOATE2) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE2) + "' ,1,2) AND        " + Enter
cSQL += "		  SB1.B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND SUBSTRING(SB1.B1_COD,1,1) >= 'A'  " + Enter
//cSQL += "         SUBSTRING(D2_COD,1,1) <> 'P' " + Enter //RANISSES
cSQL += "   GROUP BY SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD, SA1.A1_NOME  " + Enter
cSQL += "   HAVING (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE2) + "' ,4,4)+SUBSTRING( '" +  (MESANODE2) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE2) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE2) + "' ,1,2)+'01'))+1)) >=  '" + QUANTIDADE + "'  " + Enter

cSQL += "   UNION " + Enter

cSQL += "   SELECT 'EMPRESA' AS EMPRESA,							-- QUERY PERIODO 3 MAIOR LINHA 1 " + Enter
cSQL += "         MERCADO =  " + Enter
cSQL += "         CASE  " + Enter
cSQL += "            WHEN SA1.A1_EST <> 'EX' THEN 'A' -- MERCADO INTERNO " + Enter
cSQL += "            ELSE 'B'                         -- MERCADO EXTERNO " + Enter
cSQL += "         END, " + Enter
cSQL += "         SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD,  " + Enter
cSQL += "         SA1.A1_NOME, 0 AS QUANT1, 0 AS QUANT2, (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE3) + "' ,4,4)+SUBSTRING( '" +  (MESANODE3) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE3) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE3) + "' ,1,2)+'01'))+1)) AS QUANT3  " + Enter
cSQL += "   FROM SB1010 SB1, " + RETSQLNAME("SA1") + " SA1, " + RETSQLNAME("SA3") + " SA3, " + RETSQLNAME("SD2") + " SD2, " + RETSQLNAME("SF4") + " SF4        " + Enter
cSQL += "   WHERE SD2.D_E_L_E_T_ =  '' AND               " + Enter
cSQL += "         SF4.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA1.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA3.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SB1.D_E_L_E_T_ =  '' AND " + Enter //RANISSES

IF SM0->M0_CODIGO ="01"
	cSQL += "         SA3.A3_COD     =* SA1.A1_VEND    AND " + Enter
ELSE
	cSQL += "         SA3.A3_COD     =* SA1.A1_YVENDI  AND  " + Enter
	cSQL += "		  SD2.D2_CLIENTE <> '000481'	   AND  " + Enter // ALTERACAO PARA EXCLUIR AS VENDAS REALIZADAS DA INCESA PARA BIANCOGRES EM 23/09/08	
END IF

cSQL += "         SA1.A1_COD     =  SD2.D2_CLIENTE AND " + Enter
cSQL += "         SA1.A1_LOJA    =  SD2.D2_LOJA    AND " + Enter
cSQL += "         SD2.D2_FILIAL  =  SF4.F4_FILIAL  AND " + Enter
cSQL += "         SD2.D2_TES     =  SF4.F4_CODIGO  AND " + Enter
cSQL += "         SD2.D2_COD     =  SB1.B1_COD     AND " + Enter //RANISSES
//cSQL += "         SF4.F4_ESTOQUE =  'S'            AND " + Enter
cSQL += "         SF4.F4_DUPLIC  =  'S'            AND " + Enter
cSQL += "         SD2.D2_GRUPO   =  'PA'           AND " + Enter
cSQL += "         SD2.D2_SERIE BETWEEN '"+ LINHADE +"' AND '"+ LINHATE +"' AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) >= SUBSTRING( '" +  (MESANODE3) + "' ,4,4)+SUBSTRING( '" +  (MESANODE3) + "' ,1,2)   AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) <= SUBSTRING( '" +  (MESANOATE3) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE3) + "' ,1,2) AND " + Enter
cSQL += "		  SB1.B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND SUBSTRING(SB1.B1_COD,1,1) >= 'A'  " + Enter
//cSQL += "         SUBSTRING(D2_COD,1,1) <> 'P' " + Enter
cSQL += "   GROUP BY SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD, SA1.A1_NOME  " + Enter
cSQL += "   HAVING (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE3) + "' ,4,4)+SUBSTRING( '" +  (MESANODE3) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE3) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE3) + "' ,1,2)+'01'))+1)) >=  '" + QUANTIDADE + "'  " + Enter

cSQL += "   UNION " + Enter

cSQL += "   SELECT 'EMPRESA' AS EMPRESA,							-- QUERY PERIODO 1 MENOR LINHA 1 " + Enter
cSQL += "         MERCADO =  " + Enter
cSQL += "         CASE  " + Enter
cSQL += "            WHEN SA1.A1_EST <> 'EX' THEN 'A' -- MERCADO INTERNO " + Enter
cSQL += "            ELSE 'B'                         -- MERCADO EXTERNO " + Enter
cSQL += "         END, " + Enter
cSQL += "         SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD,  " + Enter
cSQL += "         'Y OUTROS' A1_NOME, (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE1) + "' ,4,4)+SUBSTRING( '" +  (MESANODE1) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE1) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE1) + "' ,1,2)+'01'))+1)) AS QUANT1, 0 AS QUANT2, 0 AS QUANT3  " + Enter
cSQL += "   FROM SB1010 SB1, " + RETSQLNAME("SA1") + " SA1, " + RETSQLNAME("SA3") + " SA3, " + RETSQLNAME("SD2") + " SD2, " + RETSQLNAME("SF4") + " SF4        " + Enter
cSQL += "   WHERE SD2.D_E_L_E_T_ =  '' AND               " + Enter
cSQL += "         SF4.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA1.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA3.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SB1.D_E_L_E_T_ =  '' AND " + Enter //RANISSES

IF SM0->M0_CODIGO ="01"
	cSQL += "         SA3.A3_COD     =* SA1.A1_VEND    AND " + Enter
ELSE
	cSQL += "         SA3.A3_COD     =* SA1.A1_YVENDI  AND  " + Enter 
	cSQL += "		  SD2.D2_CLIENTE <> '000481'	   AND  " + Enter // ALTERACAO PARA EXCLUIR AS VENDAS REALIZADAS DA INCESA PARA BIANCOGRES EM 23/09/08	
END IF

cSQL += "         SA1.A1_COD     =  SD2.D2_CLIENTE AND " + Enter
cSQL += "         SA1.A1_LOJA    =  SD2.D2_LOJA    AND " + Enter
cSQL += "         SD2.D2_FILIAL  =  SF4.F4_FILIAL  AND " + Enter
cSQL += "         SD2.D2_TES     =  SF4.F4_CODIGO  AND " + Enter
cSQL += "         SD2.D2_COD     =  SB1.B1_COD     AND " + Enter //RANISSES
//cSQL += "         SF4.F4_ESTOQUE =  'S'            AND " + Enter
cSQL += "         SF4.F4_DUPLIC  =  'S'            AND " + Enter
cSQL += "         SD2.D2_GRUPO   =  'PA'           AND " + Enter
cSQL += "         SD2.D2_SERIE BETWEEN '"+ LINHADE +"' AND '"+ LINHATE +"' AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) >= SUBSTRING( '" +  (MESANODE1) + "' ,4,4)+SUBSTRING( '" +  (MESANODE1) + "' ,1,2)   AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) <= SUBSTRING( '" +  (MESANOATE1) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE1) + "' ,1,2) AND         " + Enter
cSQL += "		  SB1.B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND SUBSTRING(SB1.B1_COD,1,1) >= 'A'  " + Enter
//cSQL += "         SUBSTRING(D2_COD,1,1) <> 'P' " + Enter
cSQL += "   GROUP BY SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD, SA1.A1_NOME  " + Enter
cSQL += "   HAVING (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE1) + "' ,4,4)+SUBSTRING( '" +  (MESANODE1) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE1) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE1) + "' ,1,2)+'01'))+1)) <  '" + QUANTIDADE + "'  " + Enter

cSQL += "   UNION " + Enter

cSQL += "   SELECT 'EMPRESA' AS EMPRESA,							-- QUERY PERIODO 2 MENOR LINHA 1 " + Enter
cSQL += "         MERCADO =  " + Enter
cSQL += "         CASE  " + Enter
cSQL += "            WHEN SA1.A1_EST <> 'EX' THEN 'A' -- MERCADO INTERNO " + Enter
cSQL += "            ELSE 'B'                         -- MERCADO EXTERNO " + Enter
cSQL += "         END, " + Enter
cSQL += "         SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD,  " + Enter
cSQL += "         'Y OUTROS' AS A1_NOME, 0 AS QUANT1, (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE2) + "' ,4,4)+SUBSTRING( '" +  (MESANODE2) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE2) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE2) + "' ,1,2)+'01'))+1)) AS QUANT2, 0 AS QUANT3  " + Enter
cSQL += "   FROM SB1010 SB1, " + RETSQLNAME("SA1") + " SA1, " + RETSQLNAME("SA3") + " SA3, " + RETSQLNAME("SD2") + " SD2, " + RETSQLNAME("SF4") + " SF4        " + Enter
cSQL += "   WHERE SD2.D_E_L_E_T_ =  '' AND               " + Enter
cSQL += "         SF4.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA1.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA3.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SB1.D_E_L_E_T_ =  '' AND " + Enter //RANISSES

IF SM0->M0_CODIGO ="01"
	cSQL += "         SA3.A3_COD     =* SA1.A1_VEND    AND " + Enter
ELSE
	cSQL += "         SA3.A3_COD     =* SA1.A1_YVENDI  AND  " + Enter
	cSQL += "		  SD2.D2_CLIENTE <> '000481'	   AND  " + Enter // ALTERACAO PARA EXCLUIR AS VENDAS REALIZADAS DA INCESA PARA BIANCOGRES EM 23/09/08	
END IF

cSQL += "         SA1.A1_COD     =  SD2.D2_CLIENTE AND " + Enter
cSQL += "         SA1.A1_LOJA    =  SD2.D2_LOJA    AND " + Enter
cSQL += "         SD2.D2_FILIAL  =  SF4.F4_FILIAL  AND " + Enter
cSQL += "         SD2.D2_TES     =  SF4.F4_CODIGO  AND " + Enter
cSQL += "         SD2.D2_COD     =  SB1.B1_COD     AND " + Enter //RANISSES
//cSQL += "         SF4.F4_ESTOQUE =  'S'            AND " + Enter
cSQL += "         SF4.F4_DUPLIC  =  'S'            AND " + Enter
cSQL += "         SD2.D2_GRUPO   =  'PA'           AND " + Enter
cSQL += "         SD2.D2_SERIE BETWEEN '"+ LINHADE +"' AND '"+ LINHATE +"' AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) >= SUBSTRING( '" +  (MESANODE2) + "' ,4,4)+SUBSTRING( '" +  (MESANODE2) + "' ,1,2)   AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) <= SUBSTRING( '" +  (MESANOATE2) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE2) + "' ,1,2) AND        " + Enter
cSQL += "		  SB1.B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND SUBSTRING(SB1.B1_COD,1,1) >= 'A'  " + Enter
//cSQL += "         SUBSTRING(D2_COD,1,1) <> 'P' " + Enter
cSQL += "   GROUP BY SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD, SA1.A1_NOME " + Enter
cSQL += "   HAVING (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE2) + "' ,4,4)+SUBSTRING( '" +  (MESANODE2) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE2) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE2) + "' ,1,2)+'01'))+1)) <  '" + QUANTIDADE + "'  " + Enter

cSQL += "   UNION " + Enter

cSQL += "   SELECT 'EMPRESA' AS EMPRESA,							-- QUERY PERIODO 3 MENOR LINHA 1 " + Enter
cSQL += "         MERCADO =  " + Enter
cSQL += "         CASE  " + Enter
cSQL += "            WHEN SA1.A1_EST <> 'EX' THEN 'A' -- MERCADO INTERNO " + Enter
cSQL += "            ELSE 'B'                         -- MERCADO EXTERNO " + Enter
cSQL += "         END, " + Enter
cSQL += "         SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD,  " + Enter
cSQL += "         'Y OUTROS' AS A1_NOME, 0 AS QUANT1, 0 AS QUANT2, (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE3) + "' ,4,4)+SUBSTRING( '" +  (MESANODE3) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE3) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE3) + "' ,1,2)+'01'))+1)) AS QUANT3  " + Enter
cSQL += "   FROM SB1010 SB1, " + RETSQLNAME("SA1") + " SA1, " + RETSQLNAME("SA3") + " SA3, " + RETSQLNAME("SD2") + " SD2, " + RETSQLNAME("SF4") + " SF4        " + Enter
cSQL += "   WHERE SD2.D_E_L_E_T_ =  '' AND               " + Enter
cSQL += "         SF4.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA1.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SA3.D_E_L_E_T_ =  '' AND " + Enter
cSQL += "         SB1.D_E_L_E_T_ =  '' AND " + Enter //RANISSES

IF SM0->M0_CODIGO ="01"
	cSQL += "         SA3.A3_COD     =* SA1.A1_VEND    AND " + Enter
ELSE
	cSQL += "         SA3.A3_COD     =* SA1.A1_YVENDI  AND  " + Enter //INCESA
	cSQL += "		  SD2.D2_CLIENTE <> '000481'	   AND  " + Enter // ALTERACAO PARA EXCLUIR AS VENDAS REALIZADAS DA INCESA PARA BIANCOGRES EM 23/09/08	
END IF

cSQL += "         SA1.A1_COD     =  SD2.D2_CLIENTE AND " + Enter
cSQL += "         SA1.A1_LOJA    =  SD2.D2_LOJA    AND " + Enter
cSQL += "         SD2.D2_FILIAL  =  SF4.F4_FILIAL  AND " + Enter
cSQL += "         SD2.D2_TES     =  SF4.F4_CODIGO  AND " + Enter
cSQL += "         SD2.D2_COD     =  SB1.B1_COD     AND " + Enter //RANISSES
//cSQL += "         SF4.F4_ESTOQUE =  'S'            AND " + Enter
cSQL += "         SF4.F4_DUPLIC  =  'S'            AND " + Enter
cSQL += "         SD2.D2_GRUPO   =  'PA'           AND " + Enter
cSQL += "         SD2.D2_SERIE BETWEEN '"+ LINHADE +"' AND '"+ LINHATE +"' AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) >= SUBSTRING( '" +  (MESANODE3) + "' ,4,4)+SUBSTRING( '" +  (MESANODE3) + "' ,1,2)   AND " + Enter
cSQL += "         SUBSTRING(D2_EMISSAO,1,6) <= SUBSTRING( '" +  (MESANOATE3) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE3) + "' ,1,2) AND " + Enter
cSQL += "		  SB1.B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND SUBSTRING(SB1.B1_COD,1,1) >= 'A'  " + Enter
//cSQL += "         SUBSTRING(D2_COD,1,1) <> 'P' " + Enter
cSQL += "   GROUP BY SA1.A1_EST, SA1.A1_MUN, SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD, SA1.A1_NOME " + Enter
cSQL += "   HAVING (SUM(D2_QUANT)/(DATEDIFF(month, CONVERT(DATETIME, SUBSTRING( '" +  (MESANODE3) + "' ,4,4)+SUBSTRING( '" +  (MESANODE3) + "' ,1,2)+'01'), CONVERT(DATETIME, SUBSTRING( '" +  (MESANOATE3) + "' ,4,4)+SUBSTRING( '" +  (MESANOATE3) + "' ,1,2)+'01'))+1)) <  '" + QUANTIDADE + "'   " + Enter
TcSQLExec(cSQL)

If aReturn[5]==1
	//Parametros Crystal Em Disco
	cOpcao:="1;0;1;Apuracao"
Else
	//Direto Impressora
	cOpcao:="3;0;1;Apuracao"
Endif
callcrys("VENDAS", DTOC(MV_PAR01)+";"+DTOC(MV_PAR02)+";"+DTOC(MV_PAR03)+";"+DTOC(MV_PAR04)+";"+DTOC(MV_PAR05)+";"+DTOC(MV_PAR06)+";"+MV_PAR07+";"+MV_PAR08+";"+MV_PAR09+";"+cEmpant ,cOpcao)

Return