#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BIA991    º Autor ³ Ranisses A. Corona º Data ³  26/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Desconto Por Representante/Cliente            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BIA991()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local wQuant
	Private Enter := CHR(13)+CHR(10)
	lEnd       := .F.
	cString    := "SA1"
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Relacao Desconto Clientes/Representantes"
	cTamanho   := "P"
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "BIA991"
	cPerg      := "BIA991"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Relacao Desconto Clientes/Representantes"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "BIA991"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t.        

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.								     ³
	//³ Verifica Posicao do Formulario na Impressora.				             ³
	//³ Solicita os parametros para a emissao do relatorio			             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

	//Cancela a impressao
	If nLastKey == 27
		Return
	Endif

	//Parametros
	cVendDe		:= MV_PAR01   //Vend. De
	cVendAte 	:= MV_PAR02   //Vend. Ate
	cCliDe		:= MV_PAR03   //Cliente De
	cCliAte		:= MV_PAR04   //Cliente Ate
	cTipo   	:= MV_PAR05   //Tipo=Analitico/Sintetico                     
	cValor  	:= MV_PAR06   //Valor Desconto
	dData1		:= MV_PAR07   //Primeiro Periodo
	dData2		:= MV_PAR08   //Segundo Periodo
	dData3		:= MV_PAR09   //Terceiro Periodo


	Private CSQL := "" 

	For wQuant := 1 to 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa Views Primarias para View Principal  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		//	cQuery := ""	
		//	cQuery := "ALTER VIEW VW_BIA991_"+Alltrim(Str(wQuant))+" AS" + Enter
		//	cQuery := cQuery +  " SELECT A3_TIPO, F2_VEND1, A3_NOME, A1_MUN AS REGIAO_CLI, REGIAO, A1_COD, A1_NOME, D2_DOC, D2_SERIE, C5_YRECR, D2_COD, D2_QUANT, ISNULL(D3_QUANT,0) AS QUANT_TAB, D2_PRCVEN," + Enter
		//	cQuery := cQuery +  "	D2_TOTAL AS VL_NOR_1, " + Enter
		//	cQuery := cQuery +  "	VL_NOR_2 =	CASE " + Enter
		//	cQuery := cQuery +  "						WHEN C5_YRECR = 'N' THEN  STR((Z1_VALOR*C5_YMAXCND)*((100-C5_YPERC)/100),14,2)*D2_QUANT " + Enter 
		//	cQuery := cQuery +  "						WHEN C5_YRECR = 'S' THEN  STR(((Z1_VALOR*C5_YMAXCND)*((100-C5_YPERC)/100)*C5_YFATOR),14,2)*D2_QUANT " + Enter 
		//	cQuery := cQuery +  "				ELSE 0 " + Enter
		//	cQuery := cQuery +  "				END, " + Enter
		//	cQuery := cQuery +  "	VL_MK_1 =	CASE " + Enter
		//	cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN (D2_TOTAL/C5_YFATOR)-D2_TOTAL " + Enter
		//	cQuery := cQuery +  "					ELSE 0 " + Enter
		//	cQuery := cQuery +  "				END, " + Enter
		//	cQuery := cQuery +  "	VL_MK_2 =	CASE " + Enter
		//	cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN ((STR(((Z1_VALOR*C5_YMAXCND)*((100-C5_YPERC)/100)*C5_YFATOR),14,2)*D2_QUANT/C5_YFATOR)-STR(((Z1_VALOR*C5_YMAXCND)*((100-C5_YPERC)/100)*C5_YFATOR),14,2)*D2_QUANT) " + Enter
		//	cQuery := cQuery +  "				ELSE 0 " + Enter
		//	cQuery := cQuery +  "				END, " + Enter
		//	cQuery := cQuery +  "	VL_TM_1  =	CASE " + Enter
		//	cQuery := cQuery +  "					WHEN C5_YRECR = 'S' AND D3_QUANT IS NOT NULL THEN D2_TOTAL+(D2_TOTAL)/D2_QUANT*D3_QUANT " + Enter
		//	cQuery := cQuery +  "					ELSE 0 " + Enter
		//	cQuery := cQuery +  "				END, " + Enter
		//	cQuery := cQuery +  "	VL_TM_2  =	CASE " + Enter
		//	cQuery := cQuery +  "					WHEN C5_YRECR = 'S' AND D3_QUANT IS NOT NULL THEN (((D2_QUANT*(((Z1_VALOR*C5_YMAXCND)-(Z1_VALOR*C5_YPERC/100))+C5_VLRFRET)* C5_YFATOR))+(((D2_QUANT*(((Z1_VALOR*C5_YMAXCND)-(Z1_VALOR*C5_YPERC/100))+C5_VLRFRET)))* C5_YFATOR))/D2_QUANT*D3_QUANT " + Enter
		//	cQuery := cQuery +  "					ELSE 0 " + Enter
		//	cQuery := cQuery +  "				END, " + Enter
		//	cQuery := cQuery +  "	VL_TAB_1 =	CASE " + Enter
		//	cQuery := cQuery +  "					WHEN C5_YRECR = 'N' AND D3_QUANT IS NOT NULL THEN D3_QUANT*D2_PRCVEN " + Enter
		//	cQuery := cQuery +  "					ELSE 0 " + Enter
		//	cQuery := cQuery +  "				END, " + Enter
		//	cQuery := cQuery +  "	VL_TAB_2 =	CASE " + Enter
		//	cQuery := cQuery +  "					WHEN C5_YRECR = 'N' AND D3_QUANT IS NOT NULL THEN D3_QUANT*(((Z1_VALOR*C5_YMAXCND)-(Z1_VALOR*C5_YPERC/100))+C5_VLRFRET) " + Enter
		//	cQuery := cQuery +  "					ELSE 0 " + Enter
		//	cQuery := cQuery +  "				END	" + Enter

		//	cQuery := cQuery +  "FROM " + Enter
		//	cQuery := cQuery +  "	(SELECT SD2.D2_FILIAL, F2_VEND1, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_TES, D2_EMISSAO, D2_COD, SUM(D2_QUANT) AS D2_QUANT, " + Enter
		//	cQuery := cQuery +  "			D2_PRCVEN = CASE " + Enter
		//	cQuery := cQuery +  "						 WHEN MAX(F2_EST) = 'AM' AND SUM(F2_VALICM) = 0 THEN AVG(D2_PRUNIT) " + Enter
		//	cQuery := cQuery +  "			      		 ELSE AVG(D2_PRCVEN) " + Enter
		//	cQuery := cQuery +  "			    		END, " + Enter
		//	cQuery := cQuery +  "	  		D2_TOTAL = CASE " + Enter
		//	cQuery := cQuery +  "			      		WHEN MAX(F2_EST) = 'AM' AND SUM(F2_VALICM) = 0 THEN SUM(D2_QUANT)*AVG(D2_PRUNIT) " + Enter
		//	cQuery := cQuery +  "			      		ELSE SUM(D2_TOTAL) " + Enter
		//	cQuery := cQuery +  "			    	   END "	 + Enter
		//	cQuery := cQuery +  "         FROM " + RetSqlName("SF2") + " SF2, " + RetSqlName("SD2") + " SD2 " + Enter
		//	cQuery := cQuery +  "         WHERE 	SF2.F2_FILIAL  = '"+xFilial("SF2")+"' 	AND " + Enter
		//	cQuery := cQuery +  "					SD2.D2_FILIAL  = '"+xFilial("SD2")+"' 	AND " + Enter
		//	cQuery := cQuery +  "					SF2.D_E_L_E_T_ = '' 					AND " + Enter
		//	cQuery := cQuery +  "					SD2.D_E_L_E_T_ = '' 					AND " + Enter
		//	cQuery := cQuery +  "					SF2.F2_SERIE   = SD2.D2_SERIE 			AND " + Enter
		//	cQuery := cQuery +  "					SF2.F2_DOC     = SD2.D2_DOC   			AND " + Enter
		//	cQuery := cQuery +  "					SF2.F2_CLIENTE = SD2.D2_CLIENTE 		AND " + Enter
		//	cQuery := cQuery +  "					SF2.F2_LOJA    = SD2.D2_LOJA 			AND " + Enter
		//	If wQuant == 1
		//		cQuery := cQuery +  "   				SUBSTRING(SF2.F2_EMISSAO,1,6)  =	'"+dData1+"' " + Enter
		//	ElseIf wQuant == 2
		//		cQuery := cQuery +  "   				SUBSTRING(SF2.F2_EMISSAO,1,6)  =	'"+dData2+"' " + Enter
		//	ElseIf wQuant == 3
		//		cQuery := cQuery +  "   				SUBSTRING(SF2.F2_EMISSAO,1,6)  =	'"+dData3+"' " + Enter
		//	EndIf
		//	cQuery := cQuery +  "         GROUP BY SD2.D2_FILIAL, F2_VEND1, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_TES, D2_EMISSAO, D2_COD) D2, " + Enter

		//	cQuery := cQuery +  "	(SELECT D3_FILIAL, D3_YNF, D3_YSERIE, D3_COD, SUM(D3_QUANT) AS D3_QUANT " + Enter
		//	cQuery := cQuery +  "         FROM " + RetSqlName("SD3") + " SD3 " + Enter
		//	cQuery := cQuery +  "         WHERE SD3.D_E_L_E_T_ = '' AND SD3.D3_YNF <> '' AND SD3.D3_TM = '509' " + Enter
		//	cQuery := cQuery +  "         GROUP BY D3_FILIAL, D3_YNF, D3_YSERIE, D3_COD) D3, " + Enter

		//	cQuery := cQuery +  "	(SELECT A3_COD, A3_NREDUZ AS A3_NOME, A3_TIPO, A3_MUN AS REGIAO " + Enter
		//	cQuery := cQuery +  "         FROM 	" + RetSqlName("SA3") + " SA3 " + Enter
		//	cQuery := cQuery +  "         WHERE 	SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3.D_E_L_E_T_ = '') A3, " + Enter

		//	cQuery := cQuery +  "	(SELECT A1_COD, A1_NOME, A1_MUN, EST = CASE " + Enter
		//	cQuery := cQuery +  "                            WHEN A1_EST = 'ES' THEN 'ES' " + Enter
		//	cQuery := cQuery +  "                            WHEN A1_EST = 'EX' THEN 'EX' " + Enter
		//	cQuery := cQuery +  "                            ELSE 'OU' " + Enter
		//	cQuery := cQuery +  "                         END " + Enter
		//	cQuery := cQuery +  "         FROM " + RetSqlName("SA1") + " SA1 " + Enter
		//	cQuery := cQuery +  "         WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = '') A1, " + Enter

		//	cQuery := cQuery +  "	(SELECT B1_FILIAL, B1_COD, B1_YREFPV, ZZ8_DESC AS CLASSE " + Enter
		//	cQuery := cQuery +  "         FROM " + RetSqlName("SB1") + " SB1, ZZ8010 ZZ8 " + Enter
		//	cQuery := cQuery +  "         WHERE B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_GRUPO = 'PA' AND SB1.D_E_L_E_T_ = '' AND "   + Enter
		//	cQuery := cQuery +  "               B1_YCLASSE = ZZ8_COD AND ZZ8.D_E_L_E_T_ = ''  AND "   + Enter	
		//	cQuery := cQuery +  "               B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' ) B1,  " + Enter

		//	cQuery := cQuery +  "	" + RetSqlName("SZ1") + " Z1, " + RetSqlName("SC5") + " C5, " + RetSqlName("SF4") + " F4 , " + RetSqlName("SZ2") + " Z2 "  + Enter

		//	cQuery := cQuery +  "WHERE 	D2.D2_FILIAL  *= D3.D3_FILIAL 	AND " + Enter
		//	cQuery := cQuery +  "		D2.D2_COD     *= D3.D3_COD 		AND " + Enter
		//	cQuery := cQuery +  "		D2.D2_DOC     *= D3.D3_YNF  	AND " + Enter
		//	cQuery := cQuery +  "		D2.D2_SERIE   *= D3.D3_YSERIE 	AND " + Enter
		//	cQuery := cQuery +  "		D2.F2_VEND1    = A3.A3_COD 		AND " + Enter
		//	cQuery := cQuery +  "		D2.D2_CLIENTE  = A1.A1_COD 		AND " + Enter
		//	cQuery := cQuery +  "		D2.D2_COD      = B1.B1_COD 		AND " + Enter

		//	cQuery := cQuery +  "		B1.B1_FILIAL  *= Z1.Z1_FILIAL   AND " + Enter
		//	cQuery := cQuery +  "		B1.B1_YREFPV  *= Z1.Z1_REFER 	AND " + Enter
		//	cQuery := cQuery +  "		B1.CLASSE     *= Z1.Z1_CLASSE  	AND " + Enter
		//	cQuery := cQuery +  "		A1.EST        *= Z1_EST 		AND " + Enter

		//	cQuery := cQuery +  "		Z2.Z2_REFER    *= Z1.Z1_REFER 	AND " + Enter
		//	cQuery := cQuery +  "		Z2.Z2_DTINIPR  *= Z1.Z1_DTINIPR	AND " + Enter

		//	cQuery := cQuery +  "		Z2.Z2_REFER    =  B1.B1_YREFPV	AND " + Enter
		//	cQuery := cQuery +  "		Z2.Z2_DTINIPR  <= C5.C5_EMISSAO AND " + Enter
		//	cQuery := cQuery +  "		Z2.Z2_DTFIMPR  >= C5.C5_EMISSAO AND " + Enter


		//	cQuery := cQuery +  "		D2.D2_FILIAL   = C5.C5_FILIAL   AND " + Enter
		//	cQuery := cQuery +  "		D2.D2_PEDIDO   = C5.C5_NUM 		AND " + Enter
		//	cQuery := cQuery +  "		D2.D2_TES      = F4.F4_CODIGO	AND " + Enter
		//	cQuery := cQuery +  "		F4.F4_DUPLIC   = 'S' 			AND " + Enter
		//	cQuery := cQuery +  "		Z1.D_E_L_E_T_  = ''				AND " + Enter
		//	cQuery := cQuery +  "		Z2.D_E_L_E_T_  = ''				AND " + Enter
		//	cQuery := cQuery +  "		C5.D_E_L_E_T_  = ''				AND " + Enter
		//	cQuery := cQuery +  "		F4.D_E_L_E_T_  = '' 				" + Enter


		//ATUALIZAÇÃO QUERY - SQL ATUAL - 09/10/2015
		cQuery := ""	
		cQuery := "ALTER VIEW VW_BIA991_"+Alltrim(Str(wQuant))+" AS" + Enter
		cQuery := cQuery +  " SELECT A3_TIPO, F2_VEND1, A3_NOME, A1_MUN AS REGIAO_CLI, REGIAO, A1_COD, A1_NOME, D2_DOC, D2_SERIE, C5_YRECR, D2_COD, D2_QUANT, ISNULL(D3_QUANT,0) AS QUANT_TAB, D2_PRCVEN," + Enter
		cQuery := cQuery +  "	D2_TOTAL AS VL_NOR_1, " + Enter
		cQuery := cQuery +  "	VL_NOR_2 =	CASE " + Enter
		cQuery := cQuery +  "						WHEN C5_YRECR = 'N' THEN  STR((Z1_VALOR*C5_YMAXCND)*((100-C5_YPERC)/100),14,2)*D2_QUANT " + Enter 
		cQuery := cQuery +  "						WHEN C5_YRECR = 'S' THEN  STR(((Z1_VALOR*C5_YMAXCND)*((100-C5_YPERC)/100)*C5_YFATOR),14,2)*D2_QUANT " + Enter 
		cQuery := cQuery +  "				ELSE 0 " + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	VL_MK_1 =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN (D2_TOTAL/C5_YFATOR)-D2_TOTAL " + Enter
		cQuery := cQuery +  "					ELSE 0 " + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	VL_MK_2 =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN ((STR(((Z1_VALOR*C5_YMAXCND)*((100-C5_YPERC)/100)*C5_YFATOR),14,2)*D2_QUANT/C5_YFATOR)-STR(((Z1_VALOR*C5_YMAXCND)*((100-C5_YPERC)/100)*C5_YFATOR),14,2)*D2_QUANT) " + Enter
		cQuery := cQuery +  "				ELSE 0 " + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	VL_TM_1  =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'S' AND D3_QUANT IS NOT NULL THEN D2_TOTAL+(D2_TOTAL)/D2_QUANT*D3_QUANT " + Enter
		cQuery := cQuery +  "					ELSE 0 " + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	VL_TM_2  =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'S' AND D3_QUANT IS NOT NULL THEN (((D2_QUANT*(((Z1_VALOR*C5_YMAXCND)-(Z1_VALOR*C5_YPERC/100))+C5_VLRFRET)* C5_YFATOR))+(((D2_QUANT*(((Z1_VALOR*C5_YMAXCND)-(Z1_VALOR*C5_YPERC/100))+C5_VLRFRET)))* C5_YFATOR))/D2_QUANT*D3_QUANT " + Enter
		cQuery := cQuery +  "					ELSE 0 " + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	VL_TAB_1 =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'N' AND D3_QUANT IS NOT NULL THEN D3_QUANT*D2_PRCVEN " + Enter
		cQuery := cQuery +  "					ELSE 0 " + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	VL_TAB_2 =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'N' AND D3_QUANT IS NOT NULL THEN D3_QUANT*(((Z1_VALOR*C5_YMAXCND)-(Z1_VALOR*C5_YPERC/100))+C5_VLRFRET) " + Enter
		cQuery := cQuery +  "					ELSE 0 " + Enter
		cQuery := cQuery +  "				END	" + Enter

		cQuery := cQuery + "FROM (SELECT SD2.D2_FILIAL, F2_VEND1, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_TES, D2_EMISSAO, D2_COD, SUM(D2_QUANT) AS D2_QUANT, " + Enter
		cQuery := cQuery + "				D2_PRCVEN = CASE " + Enter
		cQuery := cQuery + "					WHEN MAX(F2_EST) = 'AM' AND SUM(F2_VALICM) = 0 THEN AVG(D2_PRUNIT) " + Enter
		cQuery := cQuery + "					ELSE AVG(D2_PRCVEN) " + Enter
		cQuery := cQuery + "					END, " + Enter
		cQuery := cQuery + "				D2_TOTAL = CASE " + Enter
		cQuery := cQuery + "					WHEN MAX(F2_EST) = 'AM' AND SUM(F2_VALICM) = 0 THEN SUM(D2_QUANT)*AVG(D2_PRUNIT) " + Enter
		cQuery := cQuery + "					ELSE SUM(D2_TOTAL) " + Enter
		cQuery := cQuery + "					END " + Enter
		cQuery := cQuery + "			FROM " + RetSqlName("SF2") + " SF2, " + RetSqlName("SD2") + " SD2 " + Enter
		cQuery := cQuery + "			WHERE 	SF2.F2_FILIAL  = '"+xFilial("SF2")+"' 	AND " + Enter
		cQuery := cQuery + "				SD2.D2_FILIAL  = '"+xFilial("SD2")+"' 	AND " + Enter
		cQuery := cQuery + "				SF2.D_E_L_E_T_ = '' 					AND " + Enter
		cQuery := cQuery + "				SD2.D_E_L_E_T_ = '' 					AND " + Enter
		cQuery := cQuery + "				SF2.F2_SERIE   = SD2.D2_SERIE 			AND " + Enter
		cQuery := cQuery + "				SF2.F2_DOC     = SD2.D2_DOC   			AND " + Enter
		cQuery := cQuery + "				SF2.F2_CLIENTE = SD2.D2_CLIENTE 		AND " + Enter
		cQuery := cQuery + "				SF2.F2_LOJA    = SD2.D2_LOJA 			AND " + Enter
		If wQuant == 1
			cQuery := cQuery + "				SUBSTRING(SF2.F2_EMISSAO,1,6) = '"+dData1+"' "  + Enter
		ElseIf wQuant == 2
			cQuery := cQuery + "				SUBSTRING(SF2.F2_EMISSAO,1,6) = '"+dData2+"' " + Enter
		ElseIf wQuant == 3
			cQuery := cQuery + "				SUBSTRING(SF2.F2_EMISSAO,1,6) = '"+dData3+"' " + Enter
		EndIf
		cQuery := cQuery + "			GROUP BY SD2.D2_FILIAL, F2_VEND1, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_TES, D2_EMISSAO, D2_COD) D2 " + Enter
		cQuery := cQuery + "	LEFT JOIN (SELECT D3_FILIAL, D3_YNF, D3_YSERIE, D3_COD, SUM(D3_QUANT) AS D3_QUANT " + Enter
		cQuery := cQuery + "			FROM " + RetSqlName("SD3") + " SD3 " + Enter
		cQuery := cQuery + "			WHERE SD3.D_E_L_E_T_ = '' AND SD3.D3_YNF <> '' AND SD3.D3_TM = '509' " + Enter
		cQuery := cQuery + "			GROUP BY D3_FILIAL, D3_YNF, D3_YSERIE, D3_COD) D3 " + Enter
		cQuery := cQuery + "		ON D2.D2_FILIAL = D3.D3_FILIAL " + Enter
		cQuery := cQuery + "			AND D2.D2_COD = D3.D3_COD " + Enter
		cQuery := cQuery + "			AND D2.D2_DOC = D3.D3_YNF " + Enter
		cQuery := cQuery + "			AND D2.D2_SERIE = D3.D3_YSERIE " + Enter
		cQuery := cQuery + "	INNER JOIN (SELECT A3_COD, A3_NREDUZ AS A3_NOME, A3_TIPO, A3_MUN AS REGIAO " + Enter
		cQuery := cQuery + "			FROM 	" + RetSqlName("SA3") + " SA3 " + Enter
		cQuery := cQuery + "			WHERE 	SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3.D_E_L_E_T_ = '') A3 " + Enter
		cQuery := cQuery + "		ON D2.F2_VEND1 = A3.A3_COD " + Enter
		cQuery := cQuery + "	INNER JOIN (SELECT A1_COD, A1_NOME, A1_MUN, EST = CASE " + Enter
		cQuery := cQuery + "				WHEN A1_EST = 'ES' THEN 'ES' " + Enter
		cQuery := cQuery + "				WHEN A1_EST = 'EX' THEN 'EX' " + Enter
		cQuery := cQuery + "				ELSE 'OU' " + Enter
		cQuery := cQuery + "				END " + Enter
		cQuery := cQuery + "			FROM " + RetSqlName("SA1") + " SA1 " + Enter
		cQuery := cQuery + "			WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = '') A1 " + Enter
		cQuery := cQuery + "		ON D2.D2_CLIENTE = A1.A1_COD " + Enter
		cQuery := cQuery + "	INNER JOIN (SELECT B1_FILIAL, B1_COD, B1_YREFPV, ZZ8_DESC AS CLASSE " + Enter
		cQuery := cQuery + "			FROM " + RetSqlName("SB1") + " SB1, ZZ8010 ZZ8 " + Enter
		cQuery := cQuery + "			WHERE B1_FILIAL = '  ' AND SB1.B1_GRUPO = 'PA' AND SB1.D_E_L_E_T_ = '' AND " + Enter
		cQuery := cQuery + "				B1_YCLASSE = ZZ8_COD AND ZZ8.D_E_L_E_T_ = ''  AND " + Enter
		cQuery := cQuery + "				B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' ) B1 " + Enter
		cQuery := cQuery + "		ON D2.D2_COD = B1.B1_COD " + Enter
		cQuery := cQuery + "	INNER JOIN " + RetSqlName("SZ2") + " Z2 " + Enter
		cQuery := cQuery + "		ON B1.B1_YREFPV = Z2.Z2_REFER " + Enter
		cQuery := cQuery + "			AND Z2.D_E_L_E_T_  = '' " + Enter
		cQuery := cQuery + "	LEFT JOIN " + RetSqlName("SZ1") + " Z1 " + Enter
		cQuery := cQuery + "		ON B1.B1_FILIAL = Z1.Z1_FILIAL " + Enter
		cQuery := cQuery + "			AND B1.B1_YREFPV = Z1.Z1_REFER " + Enter
		cQuery := cQuery + "			AND B1.CLASSE = Z1.Z1_CLASSE " + Enter
		cQuery := cQuery + "			AND A1.EST = Z1_EST " + Enter
		cQuery := cQuery + "			AND Z2.Z2_REFER = Z1.Z1_REFER " + Enter
		cQuery := cQuery + "			AND Z2.Z2_DTINIPR = Z1.Z1_DTINIPR " + Enter
		cQuery := cQuery + "			AND Z1.D_E_L_E_T_  = '' " + Enter
		cQuery := cQuery + "	INNER JOIN " + RetSqlName("SC5") + " C5 " + Enter
		cQuery := cQuery + "		ON D2.D2_FILIAL = C5.C5_FILIAL " + Enter
		cQuery := cQuery + "			AND D2.D2_PEDIDO = C5.C5_NUM " + Enter
		cQuery := cQuery + "			AND Z2.Z2_DTINIPR <= C5.C5_EMISSAO " + Enter
		cQuery := cQuery + "			AND Z2.Z2_DTFIMPR >= C5.C5_EMISSAO " + Enter
		cQuery := cQuery + "			AND C5.D_E_L_E_T_  = '' " + Enter
		cQuery := cQuery + "	INNER JOIN " + RetSqlName("SF4") + " F4 " + Enter
		cQuery := cQuery + "		ON D2.D2_TES = F4.F4_CODIGO " + Enter
		cQuery := cQuery + "			AND F4.F4_DUPLIC = 'S' " + Enter
		cQuery := cQuery + "			AND F4.D_E_L_E_T_  = '' "


		//Executa a Query
		TcSQLExec(cQuery)
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a query principal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//CSQL := ""
	//CSQL += "ALTER VIEW VW_BIA991 AS " + Enter
	//CSQL += "SELECT A3_COD, A3_NREDUZ AS A3_NOME, A1_MUN, A1_GRPVEN, SA1.A1_COD, A1_NOME, A1_EST, A1_YDESCLI, A1_YOSBDES, STR(ISNULL(PERC1.PERC,0),14,2) PERC1, STR(ISNULL(PERC2.PERC,0),14,2) PERC2, STR(ISNULL(PERC3.PERC,0),14,2) PERC3  " + Enter
	//CSQL += "FROM " + RetSqlName("SA1") + " SA1 , SA3010 SA3, " + Enter

	//CSQL += "(SELECT A1_COD, 100-(SUM(VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)/SUM(VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)*100) AS PERC "  + Enter
	//CSQL += " FROM VW_BIA991_1 " + Enter
	//CSQL += " WHERE VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2 > 0 "  + Enter
	//CSQL += " GROUP BY A1_COD) AS PERC1, 				"  + Enter

	//CSQL += "(SELECT A1_COD, 100-(SUM(VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)/SUM(VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)*100) AS PERC "  + Enter
	//CSQL += " FROM VW_BIA991_2 " + Enter
	//CSQL += " WHERE VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2 > 0 "  + Enter
	//CSQL += " GROUP BY A1_COD) AS PERC2, 				"  + Enter

	//CSQL += "(SELECT A1_COD, 100-(SUM(VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)/SUM(VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)*100) AS PERC "  + Enter
	//CSQL += " FROM VW_BIA991_3 " + Enter
	//CSQL += " WHERE VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2 > 0 "  + Enter
	//CSQL += " GROUP BY A1_COD) AS PERC3 				"  + Enter

	//CSQL += "WHERE	SA1.D_E_L_E_T_ 	=	''	AND " + Enter
	//CSQL += "		SA3.D_E_L_E_T_	=	''	AND " + Enter
	//CSQL += "		SA1.A1_TIPO		<>	'F'	AND " + Enter
	//CSQL += "		SA1.A1_ULTCOM	>=	CONVERT(NVARCHAR(8), GETDATE()-180,112) AND " + Enter
	//CSQL += "		SA1.A1_YDESCLI	>=	'"+Alltrim(Str(cValor))+"' AND " + Enter
	//CSQL += "		SA1.A1_COD 		*= 	PERC1.A1_COD AND "	+ Enter
	//CSQL += "		SA1.A1_COD 		*= 	PERC2.A1_COD AND "  + Enter
	//CSQL += "		SA1.A1_COD 		*= 	PERC3.A1_COD AND "	+ Enter
	//If cempant = "01"
	//	CSQL += "		A1_VEND = A3_COD AND " + Enter
	//	CSQL += "		A1_VEND BETWEEN '"+cVendDe+"' AND '"+cVendAte+"' AND " + Enter
	//ElseIf cempant = "05"
	//	CSQL += "		A1_YVENDI = A3_COD AND " + Enter
	//	CSQL += "		A1_YVENDI BETWEEN '"+cVendDe+"' AND '"+cVendAte+"' AND " + Enter
	//EndIf
	//CSQL += "      SA1.A1_COD BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' " + Enter



	//ATUALIZAÇÃO QUERY - SQL ATUAL - 09/10/2015
	CSQL := ""
	CSQL += "ALTER VIEW VW_BIA991 AS " + Enter
	CSQL += "SELECT A3_COD, A3_NREDUZ AS A3_NOME, A1_MUN, A1_GRPVEN, SA1.A1_COD, A1_NOME, A1_EST, A1_YDESCLI, A1_YOSBDES, STR(ISNULL(PERC1.PERC,0),14,2) PERC1, STR(ISNULL(PERC2.PERC,0),14,2) PERC2, STR(ISNULL(PERC3.PERC,0),14,2) PERC3  " + Enter
	CSQL += "FROM " + RetSqlName("SA1") + " SA1 " + Enter
	CSQL += "	INNER JOIN SA3010 SA3 " + Enter
	If cempant = "01"
		CSQL += "		ON A1_VEND = A3_COD " + Enter
	ElseIf cempant = "05"
		CSQL += "		ON A1_YVENDI = A3_COD " + Enter
	EndIf
	CSQL += "			AND SA3.D_E_L_E_T_	=	'' " + Enter
	CSQL += "	LEFT JOIN (SELECT A1_COD, 100-(SUM(VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)/SUM(VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)*100) AS PERC " + Enter
	CSQL += "				FROM VW_BIA991_1 " + Enter
	CSQL += "				WHERE VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2 > 0 " + Enter
	CSQL += "				GROUP BY A1_COD) AS PERC1 " + Enter
	CSQL += "		ON SA1.A1_COD = PERC1.A1_COD " + Enter
	CSQL += "	LEFT JOIN (SELECT A1_COD, 100-(SUM(VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)/SUM(VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)*100) AS PERC " + Enter
	CSQL += "				FROM VW_BIA991_2 " + Enter
	CSQL += "				WHERE VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2 > 0 " + Enter
	CSQL += "				GROUP BY A1_COD) AS PERC2 " + Enter
	CSQL += "		ON SA1.A1_COD = PERC2.A1_COD " + Enter
	CSQL += "	LEFT JOIN (SELECT A1_COD, 100-(SUM(VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)/SUM(VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)*100) AS PERC " + Enter
	CSQL += "				FROM VW_BIA991_3 " + Enter
	CSQL += "				WHERE VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2 > 0 " + Enter
	CSQL += "				GROUP BY A1_COD) AS PERC3 " + Enter
	CSQL += "		ON SA1.A1_COD = PERC3.A1_COD " + Enter
	CSQL += "WHERE	SA1.D_E_L_E_T_ 	=	''	AND " + Enter
	CSQL += "		SA1.A1_TIPO		<>	'F'	AND " + Enter
	CSQL += "		SA1.A1_ULTCOM	>=	CONVERT(NVARCHAR(8), GETDATE()-180,112)-- AND " + Enter
	CSQL += "		SA1.A1_YDESCLI	>=	'"+Alltrim(Str(cValor))+"' AND " + Enter
	CSQL += "		
	If cempant = "01"
		CSQL += "		A1_VEND BETWEEN '"+cVendDe+"' AND '"+cVendAte+"' AND " + Enter
	ElseIf cempant = "05"
		CSQL += "		A1_YVENDI BETWEEN '"+cVendDe+"' AND '"+cVendAte+"' AND " + Enter
	EndIf
	CSQL += "		SA1.A1_COD BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' " + Enter




	//Executa a Query
	TcSQLExec(CSQL)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5]==1
		//Parametros Crystal Em Disco
		Private x:="1;0;1;Ranking"
	Else
		//Direto Impressora
		Private x:="3;0;1;Ranking"
	Endif

	//Chama o Relatorio em Crystal
	If cTipo = 1 //Analitico
		callcrys("BIA991A",cVendDe+";"+cVendAte+";"+cCliDe+";"+cCliAte+";"+cempant+";"+Alltrim(Str(cValor))+";"+dData1+";"+dData2+";"+dData3,x)
	Else //Sintetico
		callcrys("BIA991S",cVendDe+";"+cVendAte+";"+cCliDe+";"+cCliAte+";"+cempant+";"+Alltrim(Str(cValor))+";"+dData1+";"+dData2+";"+dData3,x)
	EndIf

Return