#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBIA997    บ Autor ณ Ranisses A. Corona บ Data ณ  27/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Apuracao do % Medio do Preco Venda p/ Representante        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Faturamento                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BIA997()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lEnd       := .F.
cString    := "SF2"
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Projecao da Variacao % Media s/ Tab+Pol+Fin"
cTamanho   := "P"
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "BIA997"
cPerg      := "BIA997"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Projecao da Variacao % Media s/ Tab+Pol+Fin"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "BIA997"
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

dEmisDe		:= MV_PAR01
dEmisAte	:= MV_PAR02
cSerieDe	:= MV_PAR03
cSerieAte	:= MV_PAR04
cVendDe		:= MV_PAR05
cVendAte 	:= MV_PAR06
cCliDe		:= MV_PAR07
cCliAte		:= MV_PAR08
cOrdem		:= MV_PAR09

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Executar a query para encontrar as vendas                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cQuery 

//cQuery := "ALTER VIEW VW_BIA997 AS"	
//cQuery := cQuery +  " SELECT "+Str(GetMV("MV_YMAXPER"))+" AS POL1, "+Str(GetMV("MV_YMXPER2"))+" AS POL2, A3_TIPO, F2_VEND1, A3_NOME, ISNULL(A1_MUN,'SEM REGIรO') AS REGIAO_CLI, ISNULL(REGIAO,'SEM REGIรO') AS REGIAO, A1_COD, A1_NOME, D2_DOC, D2_SERIE, C5_YRECR, D2_COD, D2_QUANT, ISNULL(D3_QUANT,0) AS QUANT_TAB, D2_PRCVEN,"	
//cQuery := cQuery +  "	D2_TOTAL AS VL_NOR_1, "
//cQuery := cQuery +  "	VL_NOR_2 =	CASE "
//cQuery := cQuery +  "									WHEN C5_YRECR = 'N' THEN D2_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET) "
//cQuery := cQuery +  "									WHEN C5_YRECR = 'S' THEN D2_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET)*"+Str(GetMV("MV_YRECR"))
//cQuery := cQuery +  "           			ELSE 0 				
//cQuery := cQuery +  "				END, "
//cQuery := cQuery +  "	VL_MK_1 =	CASE "
//cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN D2_TOTAL*1.1 "
//cQuery := cQuery +  "					ELSE 0 "
//cQuery := cQuery +  "				END, "
//cQuery := cQuery +  "	VL_MK_2 =	CASE "
//cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN D2_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET)*"+Str(GetMV("MV_YRECR"))+"*1.1 "
//cQuery := cQuery +  "					ELSE 0 "
//cQuery := cQuery +  "				END, "
//cQuery := cQuery +  "	VL_TM_1  =	CASE "
//cQuery := cQuery +  "					WHEN C5_YRECR = 'S' AND D3_QUANT IS NOT NULL THEN D2_TOTAL+(D2_TOTAL*1.1)/D2_QUANT*D3_QUANT "
//cQuery := cQuery +  "					ELSE 0 "
//cQuery := cQuery +  "				END, "
//cQuery := cQuery +  "	VL_TM_2  =	CASE "
//cQuery := cQuery +  "					WHEN C5_YRECR = 'S' AND D3_QUANT IS NOT NULL THEN (((D2_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET)*"+Str(GetMV("MV_YRECR"))+"))+(((D2_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET)))*"+Str(GetMV("MV_YRECR"))+"*1.1))/D2_QUANT*D3_QUANT "
//cQuery := cQuery +  "					ELSE 0 "
//cQuery := cQuery +  "				END, "
//cQuery := cQuery +  "	VL_TAB_1 =	CASE "
//cQuery := cQuery +  "					WHEN C5_YRECR = 'N' AND D3_QUANT IS NOT NULL THEN D3_QUANT*D2_PRCVEN "
//cQuery := cQuery +  "					ELSE 0 "
//cQuery := cQuery +  "				END, "
//cQuery := cQuery +  "	VL_TAB_2 =	CASE "
//cQuery := cQuery +  "					WHEN C5_YRECR = 'N' AND D3_QUANT IS NOT NULL THEN D3_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET) "
//cQuery := cQuery +  "					ELSE 0 "
//cQuery := cQuery +  "				END	"

//cQuery := cQuery +  "FROM " 
//cQuery := cQuery +  "	(SELECT SD2.D2_FILIAL, F2_VEND1, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_TES, D2_EMISSAO, D2_COD, SUM(D2_QUANT) AS D2_QUANT, "
//cQuery := cQuery +  "			D2_PRCVEN = CASE "
//cQuery := cQuery +  "			      	 		WHEN MAX(F2_EST) = 'AM' AND SUM(F2_VALICM) = 0 THEN AVG(D2_PRUNIT) "
//cQuery := cQuery +  "			      			ELSE AVG(D2_PRCVEN) "
//cQuery := cQuery +  "			    		END, "
//cQuery := cQuery +  "			D2_TOTAL = CASE "
//cQuery := cQuery +  "			      			WHEN MAX(F2_EST) = 'AM' AND SUM(F2_VALICM) = 0 THEN SUM(D2_QUANT)*AVG(D2_PRUNIT) "
//cQuery := cQuery +  "			      			ELSE SUM(D2_TOTAL) "
//cQuery := cQuery +  "			    		END "
//cQuery := cQuery +  "         FROM " + RetSqlName("SF2") + " SF2, " + RetSqlName("SD2") + " SD2 "
//cQuery := cQuery +  "         WHERE 	SF2.F2_FILIAL  = '"+xFilial("SF2")+"' AND "
//cQuery := cQuery +  "					SD2.D2_FILIAL  = '"+xFilial("SD2")+"' AND "
//cQuery := cQuery +  "					SF2.D_E_L_E_T_ = '' AND "
//cQuery := cQuery +  "					SD2.D_E_L_E_T_ = '' AND "
//cQuery := cQuery +  "					SF2.F2_SERIE   = SD2.D2_SERIE AND "
//cQuery := cQuery +  "					SF2.F2_DOC     = SD2.D2_DOC   AND "
//cQuery := cQuery +  "					SF2.F2_CLIENTE = SD2.D2_CLIENTE AND "
//cQuery := cQuery +  "					SF2.F2_LOJA    = SD2.D2_LOJA AND "
//cQuery := cQuery +  "                	SF2.F2_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"' AND "
//cQuery := cQuery +  "   				SF2.F2_EMISSAO BETWEEN '"+dtos(dEmisDe)+"' AND '"+dtos(dEmisAte)+"' AND "
//cQuery := cQuery +  "    				SF2.F2_CLIENTE BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' AND "
//cQuery := cQuery +  "                	SF2.F2_VEND1   BETWEEN '"+cVendDe+"' AND '"+cVendAte+"' "
//cQuery := cQuery +  "         GROUP BY SD2.D2_FILIAL, F2_VEND1, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_TES, D2_EMISSAO, D2_COD) D2, "

//cQuery := cQuery +  "	(SELECT D3_FILIAL, D3_YNF, D3_YSERIE, D3_COD, SUM(D3_QUANT) AS D3_QUANT "
//cQuery := cQuery +  "         FROM " + RetSqlName("SD3") + " SD3 "
//cQuery := cQuery +  "         WHERE SD3.D_E_L_E_T_ = '' AND SD3.D3_YNF <> '' AND SD3.D3_TM = '509' "
//cQuery := cQuery +  "         GROUP BY D3_FILIAL, D3_YNF, D3_YSERIE, D3_COD) D3, "

//cQuery := cQuery +  "	(SELECT A3_COD, A3_NOME, A3_TIPO, A3_MUN AS REGIAO "
//cQuery := cQuery +  "         FROM 	" + RetSqlName("SA3") + " SA3 "
//cQuery := cQuery +  "         WHERE 	SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3.D_E_L_E_T_ = '') A3, "

//cQuery := cQuery +  "	(SELECT A1_COD, A1_NOME, A1_MUN, EST = CASE "
//cQuery := cQuery +  "                            WHEN A1_EST = 'ES' THEN 'ES' "
//cQuery := cQuery +  "                            WHEN A1_EST = 'EX' THEN 'EX' "
//cQuery := cQuery +  "                            ELSE 'OU' "
//cQuery := cQuery +  "                         END "
//cQuery := cQuery +  "         FROM " + RetSqlName("SA1") + " SA1 "
//cQuery := cQuery +  "         WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = '') A1, "

//cQuery := cQuery +  "	(SELECT B1_FILIAL, B1_COD, B1_YREFPV, CLASSE = CASE "
//cQuery := cQuery +  "                               			WHEN SUBSTRING(B1_COD,6,1) = '1' THEN 'A' "
//cQuery := cQuery +  "                               			WHEN SUBSTRING(B1_COD,6,1) = '2' THEN 'C' "
//cQuery := cQuery +  "                               			WHEN SUBSTRING(B1_COD,6,1) = '3' THEN 'D' "
//cQuery := cQuery +  "                               			WHEN SUBSTRING(B1_COD,6,1) = '5' THEN 'E' "
//cQuery := cQuery +  "                               			ELSE 'B' "
//cQuery := cQuery +  "                             		     END "
//cQuery := cQuery +  "         FROM " + RetSqlName("SB1") + " SB1 "
//cQuery := cQuery +  "         WHERE B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_GRUPO = 'PA' AND SB1.D_E_L_E_T_ = '' AND "
//cQuery := cQuery +  "               SUBSTRING(SB1.B1_COD,1,1) NOT IN ('K','L','M','N','O','P')) B1, 					  "
                     
//cQuery := cQuery +  "	" + RetSqlName("SZ1") + " Z1, " + RetSqlName("SC5") + " C5, " + RetSqlName("SF4") + " F4 " 

//cQuery := cQuery +  "WHERE 	D2.D2_FILIAL  *= D3.D3_FILIAL 	AND "
//cQuery := cQuery +  "		D2.D2_COD     *= D3.D3_COD 		AND "
//cQuery := cQuery +  "		D2.D2_DOC     *= D3.D3_YNF  	AND "
//cQuery := cQuery +  "		D2.D2_SERIE   *= D3.D3_YSERIE 	AND "
//cQuery := cQuery +  "		D2.F2_VEND1    = A3.A3_COD 		AND "
//cQuery := cQuery +  "		D2.D2_CLIENTE  = A1.A1_COD 		AND "
//cQuery := cQuery +  "		D2.D2_COD      = B1.B1_COD 		AND "
//cQuery := cQuery +  "		B1.B1_FILIAL  *= Z1.Z1_FILIAL   AND "
//cQuery := cQuery +  "		B1.B1_YREFPV  *= Z1.Z1_REFER 	AND "
//cQuery := cQuery +  "		B1.CLASSE     *= Z1.Z1_CLASSE  	AND "
//cQuery := cQuery +  "		A1.EST        *= Z1_EST 		AND "
//cQuery := cQuery +  "		D2.D2_FILIAL   = C5.C5_FILIAL   AND "
//cQuery := cQuery +  "		D2.D2_PEDIDO   = C5.C5_NUM 		AND "
//cQuery := cQuery +  "		D2.D2_TES      = F4.F4_CODIGO	AND "
//cQuery := cQuery +  "		F4.F4_DUPLIC   = 'S' 			AND "
//cQuery := cQuery +  "		Z1.D_E_L_E_T_  = ''				AND "
//cQuery := cQuery +  "		C5.D_E_L_E_T_  = ''				AND "
//cQuery := cQuery +  "		F4.D_E_L_E_T_  = '' 				"


//ATUALIZAวรO QUERY - SQL ATUAL - 05/10/2015
cQuery := "ALTER VIEW VW_BIA997 AS"	
cQuery := cQuery +  " SELECT "+Str(GetMV("MV_YMAXPER"))+" AS POL1, "+Str(GetMV("MV_YMXPER2"))+" AS POL2, A3_TIPO, F2_VEND1, A3_NOME, ISNULL(A1_MUN,'SEM REGIรO') AS REGIAO_CLI, ISNULL(REGIAO,'SEM REGIรO') AS REGIAO, A1_COD, A1_NOME, D2_DOC, D2_SERIE, C5_YRECR, D2_COD, D2_QUANT, ISNULL(D3_QUANT,0) AS QUANT_TAB, D2_PRCVEN,"	
cQuery := cQuery +  "	D2_TOTAL AS VL_NOR_1, "
cQuery := cQuery +  "	VL_NOR_2 =	CASE "
cQuery := cQuery +  "									WHEN C5_YRECR = 'N' THEN D2_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET) "
cQuery := cQuery +  "									WHEN C5_YRECR = 'S' THEN D2_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET)*"+Str(GetMV("MV_YRECR"))
cQuery := cQuery +  "           			ELSE 0 				
cQuery := cQuery +  "				END, "
cQuery := cQuery +  "	VL_MK_1 =	CASE "
cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN D2_TOTAL*1.1 "
cQuery := cQuery +  "					ELSE 0 "
cQuery := cQuery +  "				END, "
cQuery := cQuery +  "	VL_MK_2 =	CASE "
cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN D2_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET)*"+Str(GetMV("MV_YRECR"))+"*1.1 "
cQuery := cQuery +  "					ELSE 0 "
cQuery := cQuery +  "				END, "
cQuery := cQuery +  "	VL_TM_1  =	CASE "
cQuery := cQuery +  "					WHEN C5_YRECR = 'S' AND D3_QUANT IS NOT NULL THEN D2_TOTAL+(D2_TOTAL*1.1)/D2_QUANT*D3_QUANT "
cQuery := cQuery +  "					ELSE 0 "
cQuery := cQuery +  "				END, "
cQuery := cQuery +  "	VL_TM_2  =	CASE "
cQuery := cQuery +  "					WHEN C5_YRECR = 'S' AND D3_QUANT IS NOT NULL THEN (((D2_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET)*"+Str(GetMV("MV_YRECR"))+"))+(((D2_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET)))*"+Str(GetMV("MV_YRECR"))+"*1.1))/D2_QUANT*D3_QUANT "
cQuery := cQuery +  "					ELSE 0 "
cQuery := cQuery +  "				END, "
cQuery := cQuery +  "	VL_TAB_1 =	CASE "
cQuery := cQuery +  "					WHEN C5_YRECR = 'N' AND D3_QUANT IS NOT NULL THEN D3_QUANT*D2_PRCVEN "
cQuery := cQuery +  "					ELSE 0 "
cQuery := cQuery +  "				END, "
cQuery := cQuery +  "	VL_TAB_2 =	CASE "
cQuery := cQuery +  "					WHEN C5_YRECR = 'N' AND D3_QUANT IS NOT NULL THEN D3_QUANT*((Z1_VALOR*C5_YMAXCND-Z1_VALOR*C5_YMAXCND*C5_YPERC/100)+C5_VLRFRET) "
cQuery := cQuery +  "					ELSE 0 "
cQuery := cQuery +  "				END	"
cQuery := cQuery +  "FROM (SELECT SD2.D2_FILIAL, F2_VEND1, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_TES, D2_EMISSAO, D2_COD, SUM(D2_QUANT) AS D2_QUANT, "
cQuery := cQuery +  "				D2_PRCVEN = CASE "
cQuery := cQuery +  "					WHEN MAX(F2_EST) = 'AM' AND SUM(F2_VALICM) = 0 THEN AVG(D2_PRUNIT) "
cQuery := cQuery +  "					ELSE AVG(D2_PRCVEN) "
cQuery := cQuery +  "					END, "
cQuery := cQuery +  "				D2_TOTAL = CASE "
cQuery := cQuery +  "					WHEN MAX(F2_EST) = 'AM' AND SUM(F2_VALICM) = 0 THEN SUM(D2_QUANT)*AVG(D2_PRUNIT) "
cQuery := cQuery +  "					ELSE SUM(D2_TOTAL) "
cQuery := cQuery +  "					END "
cQuery := cQuery +  "			FROM " + RetSqlName("SF2") + " SF2, " + RetSqlName("SD2") + " SD2 "
cQuery := cQuery +  "			WHERE 	SF2.F2_FILIAL  = '"+xFilial("SF2")+"' AND "
cQuery := cQuery +  "				SD2.D2_FILIAL  = '"+xFilial("SD2")+"' AND "
cQuery := cQuery +  "				SF2.D_E_L_E_T_ = '' AND "
cQuery := cQuery +  "				SD2.D_E_L_E_T_ = '' AND "
cQuery := cQuery +  "				SF2.F2_SERIE   = SD2.D2_SERIE AND "
cQuery := cQuery +  "				SF2.F2_DOC     = SD2.D2_DOC   AND "
cQuery := cQuery +  "				SF2.F2_CLIENTE = SD2.D2_CLIENTE AND "
cQuery := cQuery +  "				SF2.F2_LOJA    = SD2.D2_LOJA AND "
cQuery := cQuery +  "				SF2.F2_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"' AND "
cQuery := cQuery +  "				SF2.F2_EMISSAO BETWEEN '"+dtos(dEmisDe)+"' AND '"+dtos(dEmisAte)+"' AND "
cQuery := cQuery +  "				SF2.F2_CLIENTE BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' AND "
cQuery := cQuery +  "				SF2.F2_VEND1   BETWEEN '"+cVendDe+"' AND '"+cVendAte+"' "
cQuery := cQuery +  "			GROUP BY SD2.D2_FILIAL, F2_VEND1, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_TES, D2_EMISSAO, D2_COD) D2 "
cQuery := cQuery +  "	LEFT JOIN (SELECT D3_FILIAL, D3_YNF, D3_YSERIE, D3_COD, SUM(D3_QUANT) AS D3_QUANT "
cQuery := cQuery +  "			FROM " + RetSqlName("SD3") + " SD3 "
cQuery := cQuery +  "			WHERE SD3.D_E_L_E_T_ = '' AND SD3.D3_YNF <> '' AND SD3.D3_TM = '509' "
cQuery := cQuery +  "			GROUP BY D3_FILIAL, D3_YNF, D3_YSERIE, D3_COD) D3 "
cQuery := cQuery +  "		ON D2.D2_FILIAL = D3.D3_FILIAL AND "
cQuery := cQuery +  "			D2.D2_COD = D3.D3_COD AND "
cQuery := cQuery +  "			D2.D2_DOC = D3.D3_YNF AND "
cQuery := cQuery +  "			D2.D2_SERIE = D3.D3_YSERIE "
cQuery := cQuery +  "	INNER JOIN (SELECT A3_COD, A3_NOME, A3_TIPO, A3_MUN AS REGIAO "
cQuery := cQuery +  "			FROM 	" + RetSqlName("SA3") + " SA3 "
cQuery := cQuery +  "			WHERE 	SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3.D_E_L_E_T_ = '') A3 "
cQuery := cQuery +  "		ON D2.F2_VEND1 = A3.A3_COD "
cQuery := cQuery +  "	INNER JOIN (SELECT A1_COD, A1_NOME, A1_MUN, EST = CASE "
cQuery := cQuery +  "					WHEN A1_EST = 'ES' THEN 'ES' "
cQuery := cQuery +  "					WHEN A1_EST = 'EX' THEN 'EX' "
cQuery := cQuery +  "					ELSE 'OU' "
cQuery := cQuery +  "					END "
cQuery := cQuery +  "			FROM " + RetSqlName("SA1") + " SA1 "
cQuery := cQuery +  "			WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = '') A1 "
cQuery := cQuery +  "		ON D2.D2_CLIENTE = A1.A1_COD "
cQuery := cQuery +  "	INNER JOIN (SELECT B1_FILIAL, B1_COD, B1_YREFPV, CLASSE = CASE "
cQuery := cQuery +  "					WHEN SUBSTRING(B1_COD,6,1) = '1' THEN 'A' "
cQuery := cQuery +  "					WHEN SUBSTRING(B1_COD,6,1) = '2' THEN 'C' "
cQuery := cQuery +  "					WHEN SUBSTRING(B1_COD,6,1) = '3' THEN 'D' "
cQuery := cQuery +  "					WHEN SUBSTRING(B1_COD,6,1) = '5' THEN 'E' "
cQuery := cQuery +  "					ELSE 'B' "
cQuery := cQuery +  "					END "
cQuery := cQuery +  "			FROM " + RetSqlName("SB1") + " SB1 "
cQuery := cQuery +  "			WHERE B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_GRUPO = 'PA' AND SB1.D_E_L_E_T_ = '' AND "
cQuery := cQuery +  "				SUBSTRING(SB1.B1_COD,1,1) NOT IN ('K','L','M','N','O','P')) B1 "
cQuery := cQuery +  "		ON D2.D2_COD      = B1.B1_COD "
cQuery := cQuery +  "	LEFT JOIN " + RetSqlName("SZ1") + " Z1 "
cQuery := cQuery +  "		ON B1.B1_FILIAL = Z1.Z1_FILIAL AND "
cQuery := cQuery +  "			B1.B1_YREFPV = Z1.Z1_REFER AND "
cQuery := cQuery +  "			B1.CLASSE = Z1.Z1_CLASSE AND "
cQuery := cQuery +  "			A1.EST = Z1_EST AND "
cQuery := cQuery +  "			Z1.D_E_L_E_T_  = '' "
cQuery := cQuery +  "	INNER JOIN " + RetSqlName("SC5") + " C5 "
cQuery := cQuery +  "		ON D2.D2_FILIAL = C5.C5_FILIAL AND "
cQuery := cQuery +  "			D2.D2_PEDIDO = C5.C5_NUM AND "
cQuery := cQuery +  "			C5.D_E_L_E_T_  = '' "
cQuery := cQuery +  "	INNER JOIN " + RetSqlName("SF4") + " F4 "
cQuery := cQuery +  "		ON D2.D2_TES = F4.F4_CODIGO	AND "
cQuery := cQuery +  "			F4.F4_DUPLIC = 'S' AND "
cQuery := cQuery +  "			F4.D_E_L_E_T_ = '' "

//Executa a Query
TcSQLExec(cQuery)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aReturn[5]==1
	//Parametros Crystal Em Disco
	Private x:="1;0;1;Apuracao"
Else
	//Direto Impressora
	Private x:="3;0;1;Apuracao"
Endif

//Chama o Relatorio em Crystal
callcrys("BIA997",dtos(dEmisDe)+";"+dtos(dEmisAte),x)

Return