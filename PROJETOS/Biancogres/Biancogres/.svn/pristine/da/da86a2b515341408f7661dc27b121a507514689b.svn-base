#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥BIA992    ∫ Autor ≥ Ranisses A. Corona ∫ Data ≥  08/09/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Ranking de Clientes/Representantes                         ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Faturamento                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function BIA992()
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Declaracao de Variaveis                                             ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	local wQuant
	Private Enter := CHR(13)+CHR(10)
	lEnd       := .F.
	cString    := "SF2"
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Ranking de Clientes/Representantes"
	cTamanho   := "P"
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "BIA992"
	cPerg      := "BIA992"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Ranking de Clientes/Representantes"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "BIA992"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .T.        
	lFiltra	   := .F.

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Envia controle para a funcao SETPRINT.								     ≥
	//≥ Verifica Posicao do Formulario na Impressora.				             ≥
	//≥ Solicita os parametros para a emissao do relatorio			             |
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

	pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

	//Cancela a impressao
	If nLastKey == 27
		Return
	Endif

	Do Case
		Case MV_PAR21 == 1 //Revenda
		nTpSeg	:= "R"
		Case MV_PAR21 == 2 //Engenharia
		nTpSeg	:= "E"	
		Case MV_PAR21 == 3 //Home Center
		nTpSeg	:= "H"	
		Case MV_PAR21 == 4 //Exportacao
		nTpSeg	:= "X"	
		Case MV_PAR21 == 5 //Todos
		nTpSeg	:= "T"	
	EndCase

	//Parametros
	cSerieDe		:= MV_PAR01   //Serie De 
	cSerieAte		:= MV_PAR02   //Serie Ate
	cVendDe			:= MV_PAR03   //Vend. De
	cVendAte 		:= MV_PAR04   //Vend. Ate
	cCliDe			:= MV_PAR05   //Cliente De
	cCliAte			:= MV_PAR06   //Cliente Ate
	cOrdem			:= MV_PAR07   //Ordenacao
	CESTDE			:= MV_PAR08
	CESTATE			:= MV_PAR09   	
	cSuperDe		:= MV_PAR10   //Supervidor De
	cSuperAte		:= MV_PAR11   //Supervidor Ate
	CATENDENTE		:= MV_PAR18
	cClasDe			:= MV_PAR19
	cClasAte		:= MV_PAR20
	cSegDe 			:= nTpSeg
	cGerDe	 		:= MV_PAR22  //Gerente De
	cGerAte 		:= MV_PAR23  //Gerente Ate

	cLinhaI			:= ""
	cLinhaF			:= ""

	If Alltrim(MV_PAR01) $ "S1_1" .or. Alltrim(MV_PAR01) == ""
		cLinhaI := "1"
	ElseIf Alltrim(MV_PAR01) $ "S2_2"
		cLinhaI := "2"
	EndIf

	If Alltrim(MV_PAR02) $ "S1_1" 
		cLinhaF := "1"
	ElseIf Alltrim(MV_PAR02) $ "S2_2" .or. Alltrim(MV_PAR02) == "ZZZ" .or. Alltrim(MV_PAR02) == "zzz" .or. Alltrim(MV_PAR02) == "ZZ " .or. Alltrim(MV_PAR02) == "zz "
		cLinhaF := "2"
	EndIf

	MesAno := Subst(Dtos(MV_PAR16),5,2)+Subst(Dtos(MV_PAR16),1,4)

	//Define a Empresa
	If cEmpAnt == "01"
		Do Case
			Case MV_PAR24 == 1 	//BIANCOGRES
			nEmp	:= "0101"
			Case MV_PAR24 == 2 	//INCESA
			nEmp	:= "0501"
			Case MV_PAR24 == 3 	//BELLACASA
			nEmp	:= "0599"
			Case MV_PAR24 == 4		//INCESA/BELLACASA
			nEmp	:= "05"
		EndCase
	Else
		Do Case
			Case MV_PAR24 == 1 	//INCESA
			nEmp	:= "0501"
			Case MV_PAR24 == 2 	//BELLACASA
			nEmp	:= "0599"
			Case MV_PAR24 == 3		//INCESA/BELLACASA
			nEmp	:= "05"
		EndCase
	EndIf

	//Verifca se sera utilizado filtro por Supervisores / Gerente / Segmento
	If !Empty(Alltrim(cSuperDe)) .Or. !Empty(Alltrim(cGerDe)) .Or. cSegDe <> "T"
		lFiltra	:= .T.
	EndIf

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Executar a query de cada periodo (ano, 3 meses, no mes)             ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Private cQuery, wQuant, dMes, dMesI, dAno, dAnoI, dEmisDe, dEmisAte, dtAnoI, dtAnoF, dtTriI, dtTriF, dtAtu

	For wQuant := 1 to 3

		If wQuant == 1 	//Para o Ano
			dtAnoI		:= DTOS(MV_PAR12) 
			dtAnoF		:= DTOS(MV_PAR13) 
			dEmisDe		:= DTOS(MV_PAR12) 
			dEmisAte	:= DTOS(MV_PAR13) 
			nMesAno		:= Round((MV_PAR13 - MV_PAR12)/30,0)
			If nMesAno == 0
				nMesAno := 1
			EndIf
		ElseIf wQuant == 2 	//Ultimos Tres Meses
			dtTriI		:= DTOS(MV_PAR14)
			dtTriF		:= DTOS(MV_PAR15)
			dEmisDe		:= DTOS(MV_PAR14) 
			dEmisAte	:= DTOS(MV_PAR15) 
			nMesTri		:= Round((MV_PAR15 - MV_PAR14)/30,0)
			If nMesTri == 0
				nMesTri := 1
			EndIf
		ElseIf wQuant == 3  //Mes Corrente
			dtAtuI 		:= DTOS(MV_PAR16)
			dtAtuF		:= DTOS(MV_PAR17)
			dEmisDe		:= DTOS(MV_PAR16) 
			dEmisAte	:= DTOS(MV_PAR17) 		
			nMesMes		:= Round((MV_PAR17 - MV_PAR16)/30,0)
			If nMesMes == 0
				nMesMes := 1
			EndIf
		EndIf

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Executa Views Primarias para View Principal  ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
		cQuery := ""	
		cQuery := "ALTER VIEW VW_BIA992_"+Alltrim(Str(wQuant))+" AS" + Enter
		cQuery := cQuery +  " SELECT A3_TIPO, F2_VEND1, A3_NOME, A1_MUN AS REGIAO_CLI, REGIAO, A1_COD, A1_LOJA, A1_NOME, A1_YTPSEG, D2_DOC, D2_SERIE, C5_YRECR, D2_COD, D2_QUANT, 0 AS QUANT_TAB, D2_PRCVEN," + Enter
		cQuery := cQuery +  "	PERC_IMP, VLR_IMP, D2_TOTAL AS VLR_ORI, D2_TOTAL AS VL_NOR_1, " + Enter
		cQuery := cQuery +  "	VL_NOR_2 =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'N' THEN  STR((D2_YPRCTAB*C5_YMAXCND)*((100-D2_YPERC)/100),14,2)*D2_QUANT " + Enter 
		cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN  STR(((D2_YPRCTAB*C5_YMAXCND)*((100-D2_YPERC)/100)*C5_YFATOR),14,2)*D2_QUANT " + Enter 
		cQuery := cQuery +  "					ELSE 0 	" + Enter
		cQuery := cQuery +  "				END,		" + Enter
		cQuery := cQuery +  "	VL_MK_1 =	CASE 		" + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN (D2_TOTAL/C5_YFATOR)-D2_TOTAL " + Enter
		cQuery := cQuery +  "					ELSE 0 	" + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	VL_MK_2 =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'S' THEN ((STR(((D2_YPRCTAB*C5_YMAXCND)*((100-D2_YPERC)/100)*C5_YFATOR),14,2)*D2_QUANT/C5_YFATOR)-STR(((D2_YPRCTAB*C5_YMAXCND)*((100-D2_YPERC)/100)*C5_YFATOR),14,2)*D2_QUANT) " + Enter
		cQuery := cQuery +  "				ELSE 0 " + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	0 VL_TM_1, 0 VL_TM_2, 0 VL_TAB_1, 0 VL_TAB_2 " + Enter
		/*cQuery := cQuery +  "	VL_TM_1  =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'S' AND D3_QUANT IS NOT NULL THEN D2_TOTAL+(D2_TOTAL)/D2_QUANT*D3_QUANT " + Enter
		cQuery := cQuery +  "					ELSE 0 " + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	VL_TM_2  =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'S' AND D3_QUANT IS NOT NULL THEN (((D2_QUANT*(((D2_YPRCTAB*C5_YMAXCND)-(D2_YPRCTAB*D2_YPERC/100))+C5_VLRFRET)* C5_YFATOR))+(((D2_QUANT*(((D2_YPRCTAB*C5_YMAXCND)-(D2_YPRCTAB*D2_YPERC/100))+C5_VLRFRET)))* C5_YFATOR))/D2_QUANT*D3_QUANT " + Enter
		cQuery := cQuery +  "					ELSE 0 " + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	VL_TAB_1 =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'N' AND D3_QUANT IS NOT NULL THEN D3_QUANT*D2_PRCVEN " + Enter
		cQuery := cQuery +  "					ELSE 0 " + Enter
		cQuery := cQuery +  "				END, " + Enter
		cQuery := cQuery +  "	VL_TAB_2 =	CASE " + Enter
		cQuery := cQuery +  "					WHEN C5_YRECR = 'N' AND D3_QUANT IS NOT NULL THEN D3_QUANT*(((D2_YPRCTAB*C5_YMAXCND)-(D2_YPRCTAB*D2_YPERC/100))+C5_VLRFRET) " + Enter
		cQuery := cQuery +  "					ELSE 0 " + Enter
		cQuery := cQuery +  "				END	" + Enter*/

		cQuery := cQuery +  "FROM " + Enter
		cQuery := cQuery +  "	(SELECT SD2.D2_FILIAL, F2_VEND1, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_LOJA, D2_TES, D2_EMISSAO, D2_COD, SUM(D2_QUANT) AS D2_QUANT, " + Enter
		cQuery := cQuery +  "			D2_PRCVEN = CASE " + Enter
		cQuery := cQuery +  "						 WHEN SUM(D2_DESCZFR) > 0 THEN AVG(D2_PRUNIT) " + Enter
		cQuery := cQuery +  "			      		 ELSE AVG(D2_PRCVEN) " + Enter
		cQuery := cQuery +  "			    		END, " + Enter
		cQuery := cQuery +  "	  		D2_TOTAL = CASE " + Enter
		cQuery := cQuery +  "			      		WHEN SUM(D2_DESCZFR) > 0 THEN SUM(D2_QUANT)*AVG(D2_PRUNIT) " + Enter
		cQuery := cQuery +  "			      		ELSE SUM(D2_TOTAL)	" + Enter
		cQuery := cQuery +  "			    	   END, 				" + Enter
		cQuery := cQuery +  "			AVG(D2_YPRCTAB) D2_YPRCTAB, AVG(D2_YPERC) D2_YPERC, " + Enter						
		cQuery := cQuery +  "			SUM(D2_VALICM+D2_VALIMP5+D2_VALIMP6+((D2_COMIS1*D2_TOTAL)/100)) VLR_IMP, " + Enter							
		cQuery := cQuery +  "			ROUND(SUM(1-((D2_VALICM+D2_VALIMP5+D2_VALIMP6+((D2_COMIS1*D2_TOTAL)/100))/D2_TOTAL)),4) PERC_IMP  " + Enter
		cQuery := cQuery +  "         FROM VW_SF2 SF2, VW_SD2 SD2 " + Enter
		cQuery := cQuery +  "         WHERE 	SF2.F2_FILIAL  = '"+xFilial("SF2")+"' 	AND " + Enter
		cQuery := cQuery +  "					SD2.D2_FILIAL  = '"+xFilial("SD2")+"' 	AND " + Enter
		cQuery := cQuery +  "					SF2.F2_SERIE   = SD2.D2_SERIE 			AND " + Enter
		cQuery := cQuery +  "					SF2.F2_DOC     = SD2.D2_DOC   			AND " + Enter
		cQuery := cQuery +  "					SF2.F2_CLIENTE = SD2.D2_CLIENTE 		AND " + Enter
		cQuery := cQuery +  "					SF2.F2_LOJA    = SD2.D2_LOJA 			AND " + Enter
		cQuery := cQuery +  "					SF2.F2_YEMP    = SD2.D2_YEMP			AND " + Enter
		cQuery := cQuery +  "					SF2.F2_YEMPORI = SD2.D2_YEMPORI			AND " + Enter
		cQuery := cQuery +  "					SF2.F2_SERIE   BETWEEN '"+cSerieDe+"'	AND '"+cSerieAte+"'	AND " + Enter
		cQuery := cQuery +  "					SF2.F2_EMISSAO BETWEEN '"+dEmisDe+"'	AND '"+dEmisAte+"'	AND " + Enter
		cQuery := cQuery +  "    				SF2.F2_CLIENTE BETWEEN '"+cCliDe+"'		AND '"+cCliAte+"'	AND " + Enter   
		cQuery := cQuery +  "                	SF2.F2_VEND1   BETWEEN '"+cVendDe+"'	AND '"+cVendAte+"'	AND " + Enter
		If lFiltra 
			cQuery := cQuery +  "					SF2.F2_VEND1   IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"	" + Enter
			cQuery := cQuery +  "										WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND " + Enter
			If cSegDe <> "T"
				cQuery := cQuery +  "											  ZZI_TPSEG  =  '"+cSegDe+"'	AND " + Enter
			EndIf
			If Alltrim(CATENDENTE) <> ""
				cQuery := cQuery +  "											  ZZI_ATENDE = '"+CATENDENTE+"'		AND " + Enter	
			EndIf 
			cQuery := cQuery +  "											  ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"' AND	" + Enter
			cQuery := cQuery +  "											  ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'	AND	" + Enter
			cQuery := cQuery +  "											  D_E_L_E_T_ = '') AND 								" + Enter
		EndIf
		cQuery := cQuery +  "                	SD2.F4_DUPLIC	= 'S'												AND	" + Enter

		If Len(Alltrim(nEmp)) == 4
			cQuery := cQuery +  "                	SF2.F2_YEMP = '"+nEmp+"'										" + Enter //DETERMINA A EMPRESA
		Else
			cQuery := cQuery +  "                	SUBSTRING(SF2.F2_YEMP,1,2) = '"+nEmp+"'			" + Enter //DETERMINA A EMPRESA
		EndIf

		cQuery := cQuery +  "         GROUP BY SD2.D2_FILIAL, F2_VEND1, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_LOJA, D2_TES, D2_EMISSAO, D2_COD) D2, " + Enter

		/*	cQuery := cQuery +  "	(SELECT D3_FILIAL, D3_YNF, D3_YSERIE, D3_COD, SUM(D3_QUANT) AS D3_QUANT " + Enter
		cQuery := cQuery +  "         FROM " + RetSqlName("SD3") + " SD3 " + Enter
		cQuery := cQuery +  "         WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"' AND SD3.D3_YNF <> '' AND SD3.D3_TM = '509' AND SD3.D_E_L_E_T_ = '' " + Enter
		cQuery := cQuery +  "         GROUP BY D3_FILIAL, D3_YNF, D3_YSERIE, D3_COD) D3, " + Enter*/

		cQuery := cQuery +  "	(SELECT A3_YATEBIA, A3_YATEINC, A3_COD, A3_NREDUZ AS A3_NOME, A3_TIPO, A3_MUN AS REGIAO " + Enter
		cQuery := cQuery +  "         FROM 	" + RetSqlName("SA3") + " SA3 " + Enter
		cQuery := cQuery +  "         WHERE 	SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3.D_E_L_E_T_ = '') A3, " + Enter

		cQuery := cQuery +  "	(SELECT A1_COD, A1_LOJA, A1_NOME, A1_MUN, A1_YTPSEG	" + Enter
		/*	cQuery := cQuery +  "			EST = CASE 							 " + Enter
		cQuery := cQuery +  "					WHEN A1_EST = 'ES' THEN 'ES' " + Enter
		cQuery := cQuery +  "					WHEN A1_EST = 'EX' THEN 'EX' " + Enter
		cQuery := cQuery +  "					ELSE 'OU' " + Enter
		cQuery := cQuery +  "				   END " + Enter       */
		cQuery := cQuery +  "         FROM " + RetSqlName("SA1") + " SA1 " + Enter
		If cSegDe <> "T"	
			cQuery := cQuery +  "         WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_YTPSEG = '"+cSegDe+"' AND SA1.D_E_L_E_T_ = '') A1, 	" + Enter	
		Else
			cQuery := cQuery +  "         WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = '') A1, 	" + Enter
		EndIf
		cQuery := cQuery +  "	(SELECT B1_FILIAL, B1_COD, B1_YREFPV	" + Enter
		cQuery := cQuery +  "         FROM " + RetSqlName("SB1") + " SB1 " + Enter
		cQuery := cQuery +  "         WHERE B1_FILIAL  = '"+xFilial("SB1")+"' AND "   + Enter
		cQuery := cQuery +  "				B1_GRUPO   = 'PA' 		AND "   + Enter
		cQuery := cQuery +  "               B1_YCLASSE >= '"+cClasDe+"'	 AND "   + Enter	
		cQuery := cQuery +  "               B1_YCLASSE <= '"+cClasAte+"' AND "   + Enter		
		cQuery := cQuery +  "               B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' AND D_E_L_E_T_ = '' ) B1,  " + Enter

		cQuery := cQuery +  "	VW_SC5 C5																								"  + Enter
		/*	cQuery := cQuery +  "WHERE 	D2.D2_COD     *= D3.D3_COD 		AND " + Enter
		cQuery := cQuery +  "		D2.D2_DOC     *= D3.D3_YNF  	AND " + Enter
		cQuery := cQuery +  "		D2.D2_SERIE   *= D3.D3_YSERIE 	AND " + Enter*/	
		cQuery := cQuery +  "WHERE 	D2.F2_VEND1    = A3.A3_COD 		AND " + Enter
		cQuery := cQuery +  "		D2.D2_CLIENTE  = A1.A1_COD 		AND " + Enter
		cQuery := cQuery +  "		D2.D2_LOJA     = A1.A1_LOJA		AND " + Enter
		cQuery := cQuery +  "		D2.D2_COD      = B1.B1_COD 		AND " + Enter
		cQuery := cQuery +  "		D2.D2_FILIAL   = C5.C5_FILIAL   AND " + Enter
		cQuery := cQuery +  "		D2.D2_PEDIDO   = C5.C5_NUM 		AND " + Enter  
		cQuery := cQuery +  "		D2.D2_CLIENTE  = C5.C5_CLIENTE	AND " + Enter  
		cQuery := cQuery +  "		D2.D2_LOJA     = C5.C5_LOJACLI	AND " + Enter  

		If Len(Alltrim(nEmp)) == 4
			cQuery := cQuery +  "		C5.C5_YEMP	= '"+nEmp+"'		" + Enter //DETERMINA A EMPRESA
		Else
			cQuery := cQuery +  "		SUBSTRING(C5.C5_YEMP,1,2) = '"+nEmp+"'		" + Enter //DETERMINA A EMPRESA
		EndIf	

		//Executa a Query
		TcSQLExec(cQuery)
	Next

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Executa a View para Filtrar Clientes com Movimento em 1 ano  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If cOrdem == 1 //Gera Base dos Clientes que movimentaram no periodo
		cQuery := ""
		cQuery += "ALTER VIEW VW_BIA992_5 AS	" + Enter
		cQuery += "SELECT *  					" + Enter
		cQuery += "FROM 						" + Enter
		cQuery += "(SELECT A1_COD AS F2_CLIENTE, A1_LOJA AS F2_LOJA"	+ Enter
		cQuery += "FROM VW_BIA992_1 			" + Enter
		cQuery += "GROUP BY A1_COD, A1_LOJA 	" + Enter
		cQuery += "UNION  						" + Enter 
		cQuery += "SELECT A1_COD AS F2_CLIENTE, A1_LOJA AS F2_LOJA"	+ Enter
		cQuery += "FROM VW_BIA992_2 			" + Enter
		cQuery += "GROUP BY A1_COD, A1_LOJA 	" + Enter
		cQuery += "UNION   						" + Enter
		cQuery += "SELECT A1_COD AS F2_CLIENTE, A1_LOJA AS F2_LOJA"	+ Enter
		cQuery += "FROM VW_BIA992_3   			" + Enter
		cQuery += "GROUP BY A1_COD, A1_LOJA) AS TESTE	" + Enter	
		cQuery += "UNION   								" + Enter	
		cQuery += "SELECT ZO_CLIENTE, A1_LOJA			" + Enter	
		cQuery += "FROM " + RetSqlName("SZO") + " SZO, 	" + Enter	
		cQuery += "		(SELECT A1_COD, A1_LOJA	" + Enter	
		cQuery += "		FROM SA1010																										" + Enter	
		If cSegDe <> "T"	
			cQuery += "     WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_YTPSEG = '"+cSegDe+"' AND D_E_L_E_T_ = '') SA1 	" + Enter	
		Else
			cQuery += "     WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND D_E_L_E_T_ = '') SA1	" + Enter	
		End
		cQuery += "WHERE D_E_L_E_T_	= ''			AND				" + Enter	
		cQuery += "		ZO_CLIENTE	= SA1.A1_COD	AND				" + Enter	
		cQuery += "		ZO_SERIE	BETWEEN '"+cSerieDe+"'	AND '"+cSerieAte+"'	AND " + Enter
		cQuery += "		ZO_CLIENTE	BETWEEN '"+cCliDe+"'	AND '"+cCliAte+"'	AND " + Enter
		cQuery += "		ZO_REPRE	BETWEEN '"+cVendDe+"'	AND '"+cVendAte+"'	AND " + Enter
		If lFiltra
			cQuery += "		ZO_REPRE   IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"	" + Enter
			cQuery += "						WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND " + Enter
			If cSegDe <> "T"
				cQuery += "							ZZI_TPSEG  =  '"+cSegDe+"'		AND " + Enter
			EndIf
			If Alltrim(CATENDENTE) <> ""
				cQuery += "							ZZI_ATENDE = '"+CATENDENTE+"'	AND " + Enter	
			EndIf 
			cQuery += "							ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"'	AND	" + Enter
			cQuery += "							ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'		AND	" + Enter
			cQuery += "							D_E_L_E_T_ = '') AND 												" + Enter
		EndIf
		cQuery += "		ZO_STATUS 	= 'Baixa Total'					" + Enter	
		cQuery += "GROUP BY ZO_CLIENTE, A1_LOJA						" + Enter	
		cQuery += "UNION											" + Enter
		cQuery += "SELECT C5_CLIENTE, C5_LOJACLI					" + Enter
		cQuery += "FROM " + RetSqlName("SC5") + " SC5, " + RetSqlName("SC6") + " SC6, " + Enter
		cQuery += "		(SELECT A1_COD, A1_LOJA	" + Enter	
		cQuery += "		FROM SA1010																										" + Enter	
		If cSegDe <> "T"	
			cQuery += "     WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_YTPSEG = '"+cSegDe+"' AND D_E_L_E_T_ = '') SA1 	" + Enter	
		Else
			cQuery += "     WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND D_E_L_E_T_ = '') SA1	" + Enter	
		End
		cQuery += "WHERE SC5.C5_FILIAL	= '"+xFilial("SC5")+"'	AND " + Enter
		cQuery += "		SC6.C6_FILIAL	= '"+xFilial("SC6")+"'	AND " + Enter
		cQuery += "		SC5.C5_NUM		= SC6.C6_NUM			AND " + Enter
		cQuery += "		SC5.C5_CLIENTE	= SC6.C6_CLI			AND " + Enter
		cQuery += "		SC5.C5_LOJACLI	= SC6.C6_LOJA			AND " + Enter
		cQuery += "		SC5.C5_CLIENTE	= SA1.A1_COD			AND " + Enter
		cQuery += "		SC5.C5_LOJACLI	= SA1.A1_LOJA			AND " + Enter
		cQuery += "		SC5.C5_CLIENTE BETWEEN '"+cCliDe+"'	AND '"+cCliAte+"'	AND 	" + Enter
		cQuery += "		SC5.C5_VEND1   BETWEEN '"+cVendDe+"'	AND '"+cVendAte+"'	AND " + Enter
		If lFiltra
			cQuery += "		SC5.C5_VEND1	IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"	" + Enter
			cQuery += "							WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND " + Enter
			If cSegDe <> "T"
				cQuery += "								ZZI_TPSEG  =  '"+cSegDe+"'		AND " + Enter
			EndIf
			If Alltrim(CATENDENTE) <> ""
				cQuery += "								ZZI_ATENDE = '"+CATENDENTE+"'	AND " + Enter	
			EndIf 
			cQuery += "								ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"'	AND	" + Enter
			cQuery += "								ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'		AND	" + Enter
			cQuery += "								D_E_L_E_T_ = '') AND 												" + Enter
		EndIf
		cQuery += "		SC5.D_E_L_E_T_ = ''	AND SC6.D_E_L_E_T_ = ''						" + Enter
		cQuery += "GROUP BY C5_CLIENTE, C5_LOJACLI										" + Enter
		//Executa a Query
		TcSQLExec(cQuery)
	ElseIf cOrdem == 2 //Gera base de Representantes que movimentaram no periodo

		cQuery := ""
		cQuery += "ALTER VIEW VW_BIA992_5 AS											" + Enter
		cQuery += "SELECT *																" + Enter
		cQuery += "FROM (SELECT F2_VEND1 AS C5_VEND1, A1_YTPSEG							" + Enter
		cQuery += "		FROM SF2010 SF2, SA1010 SA1										" + Enter
		cQuery += "		WHERE F2_FILIAL	= '"+xFilial("SF2")+"'	AND						" + Enter 
		cQuery += "			F2_CLIENTE  = A1_COD	AND 								" + Enter
		cQuery += "			F2_LOJA     = A1_LOJA   AND 								" + Enter
		cQuery += "			F2_VEND1	BETWEEN '"+cVendDe+"'	AND '"+cVendAte+"'	AND " + Enter
		If lFiltra
			cQuery += "			F2_VEND1   IN (SELECT ZZI_VEND FROM ZZI010					" + Enter
			cQuery += "								WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND " + Enter
			If cSegDe <> "T"
				cQuery += "									ZZI_TPSEG  =  '"+cSegDe+"'		AND " + Enter
			EndIf
			If Alltrim(CATENDENTE) <> ""
				cQuery += "									ZZI_ATENDE = '"+CATENDENTE+"'	AND " + Enter	
			EndIf 
			cQuery += "								ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"' AND	" + Enter
			cQuery += "								ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'	AND	" + Enter
			cQuery += "								D_E_L_E_T_ = '') 					AND " + Enter
		EndIf
		If cSegDe <> "T"
			cQuery += "			SA1.A1_YTPSEG = '"+cSegDe+"'	AND " + Enter
		EndIf
		cQuery += "			SF2.D_E_L_E_T_ = '' 									AND	" + Enter
		cQuery += "			SA1.D_E_L_E_T_ = '' 										" + Enter
		cQuery += "		GROUP BY F2_VEND1, A1_YTPSEG									" + Enter
		cQuery += "		UNION															" + Enter
		cQuery += "		SELECT F2_VEND1 AS C5_VEND1, A1_YTPSEG							" + Enter
		cQuery += "		FROM SF2050	SF2, SA1050 SA1										" + Enter
		cQuery += "		WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND 						" + Enter
		cQuery += "			F2_CLIENTE  = A1_COD	AND 								" + Enter
		cQuery += "			F2_LOJA     = A1_LOJA   AND 								" + Enter
		cQuery += "			F2_VEND1	BETWEEN '"+cVendDe+"'	AND '"+cVendAte+"'	AND " + Enter
		If lFiltra
			cQuery += "			F2_VEND1    IN (SELECT ZZI_VEND FROM ZZI050					" + Enter
			cQuery += "								WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND " + Enter
			If cSegDe <> "T"
				cQuery += "									ZZI_TPSEG  =  '"+cSegDe+"'		AND " + Enter
			EndIf
			If Alltrim(CATENDENTE) <> ""
				cQuery += "									ZZI_ATENDE = '"+CATENDENTE+"'	AND " + Enter	
			EndIf 
			cQuery += "								ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"' AND	" + Enter
			cQuery += "								ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'	AND	" + Enter
			cQuery += "								D_E_L_E_T_ = '') 					AND " + Enter
		EndIf
		If cSegDe <> "T"
			cQuery += "			SA1.A1_YTPSEG = '"+cSegDe+"'	AND " + Enter
		EndIf
		cQuery += "			SF2.D_E_L_E_T_ = ''										AND " + Enter
		cQuery += "			SA1.D_E_L_E_T_ = '' 										" + Enter
		cQuery += "		GROUP BY F2_VEND1, A1_YTPSEG) SF2											" + Enter
		//Executa a Query
		TcSQLExec(cQuery)
	EndIf

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Executa a View Principal         ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	//Ordenado por Cliente
	If cOrdem == 1
		//cQuery := ""
		//cQuery := "ALTER VIEW VW_BIA992_4 AS"	 + Enter
		//cQuery := cQuery +  " SELECT COD = CASE " + Enter
		//cQuery := cQuery +  " 				  WHEN SA1.A1_GRPVEN = '' THEN SA1.A1_COD+'C' " + Enter
		//cQuery := cQuery +  " 				  ELSE SA1.A1_GRPVEN+'G'" + Enter
		//cQuery := cQuery +  "			   END, " + Enter
		//cQuery := cQuery +  "	     NOME = CASE " + Enter
		//cQuery := cQuery +  "				   WHEN SA1.A1_GRPVEN = '' THEN SA1.A1_NOME " + Enter
		//cQuery := cQuery +  "				   ELSE ACY.ACY_DESCRI " + Enter
		//cQuery := cQuery +  "	      		END, "  + Enter
		//cQuery := cQuery +  "		 TIPO = CASE " + Enter
		//cQuery := cQuery +  "				   WHEN SA1.A1_EST <> 'EX'	THEN 'I' " + Enter
		//cQuery := cQuery +  "		           ELSE 'E' " + Enter
		//cQuery := cQuery +  "	            END, " + Enter
		//cQuery := cQuery +  "		  SA1.A1_EST AS EST, SA1.A1_YTPSEG, ISNULL(PED.SALDO,0) AS PEDPEN, ISNULL(EMITI.SALDO,0) AS PEDEMIT, " + Enter
		//cQuery := cQuery +  "		  ISNULL(ANO.QUANT,0) AS QUANT_ANO, ISNULL(ANO.VL1,0) AS VL1_ANO, ISNULL(ANO.VL2,0) AS VL2_ANO, ISNULL(INVANO.VALOR,0) AS VL3_ANO, ISNULL(ANO.PERC_IMP,0) AS PERCIMP_ANO, ISNULL(ANO.VLR_IMP,0) VLRIMP_ANO, ISNULL(ANO.VLR_ORI,0) VLRORI_ANO, " + Enter
		//cQuery := cQuery +  "		  ISNULL(TRI.QUANT,0) AS QUANT_TRI, ISNULL(TRI.VL1,0) AS VL1_TRI, ISNULL(TRI.VL2,0) AS VL2_TRI, ISNULL(INVTRI.VALOR,0) AS VL3_TRI, ISNULL(TRI.PERC_IMP,0) AS PERCIMP_TRI, ISNULL(TRI.VLR_IMP,0) VLRIMP_TRI, ISNULL(TRI.VLR_ORI,0) VLRORI_TRI, " + Enter
		//cQuery := cQuery +  "		  ISNULL(MES.QUANT,0) AS QUANT_MES, ISNULL(MES.VL1,0) AS VL1_MES, ISNULL(MES.VL2,0) AS VL2_MES, ISNULL(INVMES.VALOR,0) AS VL3_MES, ISNULL(MES.PERC_IMP,0) AS PERCIMP_MES, ISNULL(MES.VLR_IMP,0) VLRIMP_MES, ISNULL(MES.VLR_ORI,0) VLRORI_MES, " + Enter
		//cQuery := cQuery +  "		  ISNULL(INVANOCLI.VALOR,0) AS VL4_ANO, ISNULL(INVTRICLI.VALOR,0) AS VL4_TRI, ISNULL(INVMESCLI.VALOR,0) VL4_MES " + Enter

		//cQuery := cQuery +  " FROM " + RetSqlName("SA1") + " SA1, " + RetSqlName("ACY") + " ACY, " + Enter

		//cQuery := cQuery +  " 	(SELECT C5_CLIENTE, C5_LOJACLI, SUM(C6_QTDVEN-C6_QTDENT) AS SALDO	" + Enter
		//cQuery := cQuery +  " 	 FROM VW_SC5 SC5, VW_SC6 SC6, " + RetSqlName("SB1") + " SB1 " + Enter
		//cQuery := cQuery +  " 	 WHERE SC5.C5_FILIAL  = '"+xFilial("SC5")+"'	AND " + Enter
		//cQuery := cQuery +  " 	       SC6.C6_FILIAL  = '"+xFilial("SC6")+"' 	AND " + Enter
		//cQuery := cQuery +  " 	       SC5.C5_NUM     = SC6.C6_NUM 		AND " + Enter
		//cQuery := cQuery +  " 	       SC5.C5_CLIENTE = SC6.C6_CLI 		AND " + Enter
		//cQuery := cQuery +  " 	       SC5.C5_YEMP    = SC6.C6_YEMP     AND " + Enter	
		//cQuery := cQuery +  " 	       SC5.C5_YEMPORI = SC6.C6_YEMPORI  AND " + Enter		
		//cQuery := cQuery +  " 	       SC6.C6_PRODUTO = SB1.B1_COD 		AND " + Enter

		//If Len(Alltrim(nEmp)) == 4
		//	cQuery := cQuery +  " 	       SC5.C5_YEMP    = '"+nEmp+"'	AND " + Enter  							//DETERMINA A EMPRESA	
		//Else
		//	cQuery := cQuery +  " 	       SUBSTRING(SC5.C5_YEMP,1,2)  = '"+nEmp+"'	AND " + Enter		//DETERMINA A EMPRESA	
		//EndIf	

		//cQuery := cQuery +  " 	       SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND " + Enter
		//cQuery := cQuery +  " 	       SB1.D_E_L_E_T_ = '' 				AND " + Enter
		//cQuery := cQuery +  " 	       SC5.C5_TIPO 	  = 'N' 			AND " + Enter
		//cQuery := cQuery +  "		   			SC5.C5_YLINHA BETWEEN '"+cLinhaI+"'  AND '"+cLinhaF+"'   AND " + Enter
		//cQuery := cQuery +  "          SC5.C5_VEND1  BETWEEN '"+cVendDe+"' AND '"+cVendAte+"'	AND " + Enter
		//If lFiltra
		//	cQuery := cQuery +  "		   SC5.C5_VEND1	IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"	" + Enter
		//	cQuery := cQuery +  "							WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND " + Enter
		//	If cSegDe <> "T"
		//		cQuery := cQuery +  "								ZZI_TPSEG  =  '"+cSegDe+"'		AND " + Enter
		//	EndIf
		//	If Alltrim(CATENDENTE) <> ""
		//		cQuery := cQuery +  "								ZZI_ATENDE = '"+CATENDENTE+"'	AND " + Enter	
		//	EndIf 
		//	cQuery := cQuery +  "								ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"'	AND	" + Enter
		//	cQuery := cQuery +  "								ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'		AND	" + Enter
		//	cQuery := cQuery +  "								D_E_L_E_T_ = '') AND 												" + Enter
		//EndIf
		//cQuery := cQuery +  "		   SC6.F4_DUPLIC  = 'S' 			AND " + Enter	
		//cQuery := cQuery +  " 	       SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 	AND " + Enter
		//cQuery := cQuery +  " 	       SC6.C6_BLQ <> 'R'   				AND " + Enter	
		//cQuery := cQuery +  "		   SB1.B1_YCLASSE >= '"+cClasDe+"'	AND " + Enter	
		//cQuery := cQuery +  "		   SB1.B1_YCLASSE <= '"+cClasAte+"'	AND " + Enter		
		//cQuery := cQuery +  " 	       SB1.B1_TIPO    = 'PA' AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' AND B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') " + Enter
		//cQuery := cQuery +  " 	 GROUP BY C5_CLIENTE, C5_LOJACLI) AS PED,	" + Enter

		//cQuery := cQuery +  " 	(SELECT C5_CLIENTE, C5_LOJACLI, SUM(C6_QTDVEN) AS SALDO	" + Enter
		//cQuery := cQuery +  " 	 FROM VW_SC5 SC5, VW_SC6 SC6, " + RetSqlName("SB1") + " SB1 " + Enter
		//cQuery := cQuery +  " 	 WHERE SC5.C5_FILIAL  = '"+xFilial("SC5")+"'	AND " + Enter
		//cQuery := cQuery +  " 	       SC6.C6_FILIAL  = '"+xFilial("SC6")+"' 	AND " + Enter
		//cQuery := cQuery +  " 	       SC5.C5_NUM     = SC6.C6_NUM 		AND " + Enter
		//cQuery := cQuery +  " 	       SC5.C5_CLIENTE = SC6.C6_CLI 		AND " + Enter
		//cQuery := cQuery +  " 	       SC5.C5_YEMP    = SC6.C6_YEMP     AND " + Enter		
		//cQuery := cQuery +  " 	       SC5.C5_YEMPORI = SC6.C6_YEMPORI  AND " + Enter		
		//cQuery := cQuery +  " 	       SC6.C6_PRODUTO = SB1.B1_COD 		AND " + Enter

		//If Len(Alltrim(nEmp)) == 4
		//	cQuery := cQuery +  " 	       SC5.C5_YEMP    = '"+nEmp+"'	AND " + Enter  							//DETERMINA A EMPRESA	
		//Else
		//	cQuery := cQuery +  " 	       SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	AND " + Enter		//DETERMINA A EMPRESA	
		//EndIf

		//cQuery := cQuery +  " 	       SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND " + Enter
		//cQuery := cQuery +  " 	       SB1.D_E_L_E_T_ = '' 				AND " + Enter
		//cQuery := cQuery +  " 	       SC5.C5_TIPO 	  = 'N' 			AND " + Enter
		//cQuery := cQuery +  "		   		 SC5.C5_YLINHA BETWEEN '"+cLinhaI+"'  AND '"+cLinhaF+"'   AND " + Enter
		//cQuery := cQuery +  "          SC5.C5_VEND1  BETWEEN '"+cVendDe+"' AND '"+cVendAte+"'	AND " + Enter
		//If lFiltra
		//	cQuery := cQuery +  "		   SC5.C5_VEND1	IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"	" + Enter
		//	cQuery := cQuery +  "							WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND " + Enter
		//	If cSegDe <> "T"
		//		cQuery := cQuery +  "								ZZI_TPSEG  =  '"+cSegDe+"'		AND " + Enter
		//	EndIf
		//	If Alltrim(CATENDENTE) <> ""
		//		cQuery := cQuery +  "								ZZI_ATENDE = '"+CATENDENTE+"'	AND " + Enter	
		//	EndIf 
		//	cQuery := cQuery +  "								ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"'	AND	" + Enter
		//	cQuery := cQuery +  "								ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'		AND	" + Enter
		//	cQuery := cQuery +  "								D_E_L_E_T_ = '') AND 												" + Enter
		//EndIf
		//cQuery := cQuery +  "		   SC6.F4_DUPLIC  = 'S' 			AND " + Enter	
		//cQuery := cQuery +  " 	       SC5.C5_EMISSAO BETWEEN '"+dEmisDe+"' AND '"+dEmisAte+"' AND " + Enter
		//cQuery := cQuery +  "		   SB1.B1_YCLASSE >= '"+cClasDe+"'	AND " + Enter	
		//cQuery := cQuery +  "		   SB1.B1_YCLASSE <= '"+cClasAte+"'	AND " + Enter		
		//cQuery := cQuery +  " 	       SB1.B1_TIPO    = 'PA' AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' AND B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') " + Enter
		//cQuery := cQuery +  " 	 GROUP BY C5_CLIENTE, C5_LOJACLI) AS EMITI,		" + Enter

		//cQuery := cQuery +  " 	(SELECT A1_COD, A1_LOJA, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2 " + Enter
		//cQuery := cQuery +  "  	 FROM VW_BIA992_1  			" + Enter
		//cQuery := cQuery +  " 	 GROUP BY A1_COD, A1_LOJA) AS ANO,	" + Enter

		//cQuery := cQuery +  " 	(SELECT A1_COD, A1_LOJA, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2 " + Enter
		//cQuery := cQuery +  " 	 FROM VW_BIA992_2  			" + Enter
		//cQuery := cQuery +  " 	 GROUP BY A1_COD, A1_LOJA) AS TRI,	" + Enter

		//cQuery := cQuery +  " 	(SELECT A1_COD, A1_LOJA, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2 " + Enter
		//cQuery := cQuery +  " 	 FROM VW_BIA992_3  			" + Enter
		//cQuery := cQuery +  " 	 GROUP BY A1_COD, A1_LOJA) AS MES, 	" + Enter

		//cQuery := cQuery +  " 	(SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR	" + Enter
		//cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO 		" + Enter
		//cQuery := cQuery +  " 	 WHERE D_E_L_E_T_ = ''	AND					" + Enter
		//cQuery := cQuery +  "		   ZO_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"' AND " + Enter
		//cQuery := cQuery +  "		   ZO_STATUS  = 'Baixa Total'      AND " + Enter
		//cQuery := cQuery +  "		   ZO_DATA  BETWEEN '"+dtAnoI+"'   AND '"+dtAnoF+"' " + Enter
		//cQuery := cQuery +  " 	 GROUP BY ZO_CLIENTE) AS INVANO,			" + Enter

		//cQuery := cQuery +  " 	(SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR	" + Enter
		//cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO 		" + Enter
		//cQuery := cQuery +  " 	 WHERE D_E_L_E_T_ = '' AND					" + Enter
		//cQuery := cQuery +  "		   ZO_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"' AND " + Enter
		//cQuery := cQuery +  "		   ZO_STATUS  = 'Baixa Total'   AND " + Enter
		//cQuery := cQuery +  "		   ZO_DATA BETWEEN '"+dtTriI+"' AND '"+dtTriF+"' " + Enter
		//cQuery := cQuery +  " 	 GROUP BY ZO_CLIENTE) AS INVTRI,			" + Enter

		//cQuery := cQuery +  " 	(SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR	" + Enter
		//cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO 		" + Enter
		//cQuery := cQuery +  " 	 WHERE D_E_L_E_T_ = '' AND 					" + Enter
		//cQuery := cQuery +  "		   ZO_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"' AND " + Enter
		//cQuery := cQuery +  "		   ZO_STATUS  = 'Baixa Total'   AND " + Enter
		//cQuery := cQuery +  "		   ZO_DATA BETWEEN '"+dtAtuI+"' AND '"+dtAtuf+"' " + Enter
		//cQuery := cQuery +  " 	 GROUP BY ZO_CLIENTE) AS INVMES,			" + Enter

		//cQuery := cQuery +  " 	(SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR	" + Enter
		//cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO 		" + Enter
		//cQuery := cQuery +  " 	 WHERE D_E_L_E_T_ = ''	AND					" + Enter
		//cQuery := cQuery +  "		   ZO_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"' AND " + Enter
		//cQuery := cQuery +  "		   ZO_FPAGTO IN ('1','3') AND " + Enter
		//cQuery := cQuery +  "		   ZO_STATUS  = 'Baixa Total'      AND " + Enter
		//cQuery := cQuery +  "		   ZO_DATA  BETWEEN '"+dtAnoI+"'   AND '"+dtAnoF+"' " + Enter
		//cQuery := cQuery +  " 	 GROUP BY ZO_CLIENTE) AS INVANOCLI,			" + Enter

		//cQuery := cQuery +  " 	(SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR	" + Enter
		//cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO 		" + Enter
		//cQuery := cQuery +  " 	 WHERE D_E_L_E_T_ = ''	AND					" + Enter
		//cQuery := cQuery +  "		   ZO_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"' AND " + Enter
		//cQuery := cQuery +  "		   ZO_FPAGTO IN ('1','3') AND " + Enter
		//cQuery := cQuery +  "		   ZO_STATUS  = 'Baixa Total'      AND " + Enter
		//cQuery := cQuery +  "		   ZO_DATA  BETWEEN '"+dtTriI+"'   AND '"+dtTriF+"' " + Enter
		//cQuery := cQuery +  " 	 GROUP BY ZO_CLIENTE) AS INVTRICLI,			" + Enter

		//cQuery := cQuery +  " 	(SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR	" + Enter
		//cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO 		" + Enter
		//cQuery := cQuery +  " 	 WHERE D_E_L_E_T_ = ''	AND					" + Enter
		//cQuery := cQuery +  "		   ZO_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"' AND " + Enter
		//cQuery := cQuery +  "		   ZO_FPAGTO IN ('1','3') AND " + Enter
		//cQuery := cQuery +  "		   ZO_STATUS  = 'Baixa Total'      AND " + Enter
		//cQuery := cQuery +  "		   ZO_DATA  BETWEEN '"+dtAtuI+"'   AND '"+dtAtuF+"' " + Enter
		//cQuery := cQuery +  " 	 GROUP BY ZO_CLIENTE) AS INVMESCLI,			" + Enter

		//cQuery := cQuery +  "	VW_BIA992_5 AS CLI" + Enter

		//cQuery := cQuery +  " WHERE SA1.A1_FILIAL	= '"+xFilial("SA1")+"' AND " + Enter
		//cQuery := cQuery +  "       CLI.F2_CLIENTE	= SA1.A1_COD	AND " + Enter
		//cQuery := cQuery +  "       CLI.F2_LOJA		= SA1.A1_LOJA	AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' AND " + Enter
		//If cSegDe <> "T"
		//	cQuery := cQuery +  "       SA1.A1_YTPSEG	=	'"+cSegDe+"'	AND " + Enter
		//EndIf
		//cQuery := cQuery +  "       SA1.A1_EST		BETWEEN '"+CESTDE+"' AND '"+CESTATE+"' AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= ANO.A1_COD			AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_LOJA		*= ANO.A1_LOJA			AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= TRI.A1_COD			AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_LOJA		*= ANO.A1_LOJA			AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= MES.A1_COD			AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_LOJA		*= ANO.A1_LOJA			AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= PED.C5_CLIENTE		AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= INVANO.ZO_CLIENTE	AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= INVTRI.ZO_CLIENTE	AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= INVMES.ZO_CLIENTE	AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= INVANOCLI.ZO_CLIENTE	AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= INVTRICLI.ZO_CLIENTE	AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= INVMESCLI.ZO_CLIENTE	AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_GRPVEN	*= ACY.ACY_GRPVEN		AND " + Enter
		//cQuery := cQuery +  "       SA1.A1_COD		*= EMITI.C5_CLIENTE		AND " + Enter
		//cQuery := cQuery +  "       SA1.D_E_L_E_T_	= ''					AND " + Enter
		//cQuery := cQuery +  "       ACY.D_E_L_E_T_	= ''						" + Enter




		//ATUALIZA«√O QUERY - SQL ATUAL - 19/01/2016
		cQuery := ""
		cQuery := "ALTER VIEW VW_BIA992_4 AS"	 + Enter
		cQuery := cQuery +  " SELECT COD = CASE " + Enter
		cQuery := cQuery +  " 				  WHEN SA1.A1_GRPVEN = '' THEN SA1.A1_COD+'C' " + Enter
		cQuery := cQuery +  " 				  ELSE SA1.A1_GRPVEN+'G'" + Enter
		cQuery := cQuery +  "			   END, " + Enter
		cQuery := cQuery +  "	     NOME = CASE " + Enter
		cQuery := cQuery +  "				   WHEN SA1.A1_GRPVEN = '' THEN SA1.A1_NOME " + Enter
		cQuery := cQuery +  "				   ELSE ACY.ACY_DESCRI " + Enter
		cQuery := cQuery +  "	      		END, "  + Enter
		cQuery := cQuery +  "		 TIPO = CASE " + Enter
		cQuery := cQuery +  "				   WHEN SA1.A1_EST <> 'EX'	THEN 'I' " + Enter
		cQuery := cQuery +  "		           ELSE 'E' " + Enter
		cQuery := cQuery +  "	            END, " + Enter
		cQuery := cQuery +  "		  SA1.A1_EST AS EST, SA1.A1_YTPSEG, ISNULL(PED.SALDO,0) AS PEDPEN, ISNULL(EMITI.SALDO,0) AS PEDEMIT, " + Enter
		cQuery := cQuery +  "		  ISNULL(ANO.QUANT,0) AS QUANT_ANO, ISNULL(ANO.VL1,0) AS VL1_ANO, ISNULL(ANO.VL2,0) AS VL2_ANO, ISNULL(INVANO.VALOR,0) AS VL3_ANO, ISNULL(ANO.PERC_IMP,0) AS PERCIMP_ANO, ISNULL(ANO.VLR_IMP,0) VLRIMP_ANO, ISNULL(ANO.VLR_ORI,0) VLRORI_ANO, " + Enter
		cQuery := cQuery +  "		  ISNULL(TRI.QUANT,0) AS QUANT_TRI, ISNULL(TRI.VL1,0) AS VL1_TRI, ISNULL(TRI.VL2,0) AS VL2_TRI, ISNULL(INVTRI.VALOR,0) AS VL3_TRI, ISNULL(TRI.PERC_IMP,0) AS PERCIMP_TRI, ISNULL(TRI.VLR_IMP,0) VLRIMP_TRI, ISNULL(TRI.VLR_ORI,0) VLRORI_TRI, " + Enter
		cQuery := cQuery +  "		  ISNULL(MES.QUANT,0) AS QUANT_MES, ISNULL(MES.VL1,0) AS VL1_MES, ISNULL(MES.VL2,0) AS VL2_MES, ISNULL(INVMES.VALOR,0) AS VL3_MES, ISNULL(MES.PERC_IMP,0) AS PERCIMP_MES, ISNULL(MES.VLR_IMP,0) VLRIMP_MES, ISNULL(MES.VLR_ORI,0) VLRORI_MES, " + Enter
		cQuery := cQuery +  "		  ISNULL(INVANOCLI.VALOR,0) AS VL4_ANO, ISNULL(INVTRICLI.VALOR,0) AS VL4_TRI, ISNULL(INVMESCLI.VALOR,0) VL4_MES " + Enter

		cQuery := cQuery +  "FROM " + RetSqlName("SA1") + " SA1 " + Enter
		cQuery := cQuery +  "	LEFT JOIN " + RetSqlName("ACY") + " ACY " + Enter
		cQuery := cQuery +  "		ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN " + Enter
		cQuery := cQuery +  "			AND ACY.D_E_L_E_T_	= '' " + Enter
		cQuery := cQuery +  "	LEFT JOIN (SELECT C5_CLIENTE, C5_LOJACLI, SUM(C6_QTDVEN-C6_QTDENT) AS SALDO	 " + Enter
		cQuery := cQuery +  " 				 FROM VW_SC5 SC5, VW_SC6 SC6, " + RetSqlName("SB1") + " SB1  " + Enter
		cQuery := cQuery +  " 				 WHERE SC5.C5_FILIAL  = '" + xFilial("SC5") + "'	AND  " + Enter
		cQuery := cQuery +  " 					   SC6.C6_FILIAL  = '" + xFilial("SC6") + "' 	AND  " + Enter
		cQuery := cQuery +  " 					   SC5.C5_NUM     = SC6.C6_NUM 		AND " + Enter
		cQuery := cQuery +  " 					   SC5.C5_CLIENTE = SC6.C6_CLI 		AND " + Enter
		cQuery := cQuery +  " 					   SC5.C5_YEMP    = SC6.C6_YEMP     AND " + Enter
		cQuery := cQuery +  " 					   SC5.C5_YEMPORI = SC6.C6_YEMPORI  AND " + Enter
		cQuery := cQuery +  " 					   SC6.C6_PRODUTO = SB1.B1_COD 		AND " + Enter
		If Len(Alltrim(nEmp)) == 4
			cQuery := cQuery +  " 					   SC5.C5_YEMP    = '" + nEmp + "'	AND  " + Enter  //DETERMINA A EMPRESA	
		Else
			cQuery := cQuery +  " 					   SUBSTRING(SC5.C5_YEMP,1,2)  = '" + nEmp + "'	AND " + Enter //DETERMINA A EMPRESA	
		EndIf
		cQuery := cQuery +  " 					   SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND  " + Enter
		cQuery := cQuery +  " 					   SB1.D_E_L_E_T_ = '' 				AND  " + Enter
		cQuery := cQuery +  " 					   SC5.C5_TIPO 	  = 'N' 			AND  " + Enter
		cQuery := cQuery +  "		   			   SC5.C5_YLINHA BETWEEN '" + cLinhaI + "' AND '" + cLinhaF + "'   AND  " + Enter
		cQuery := cQuery +  "					   SC5.C5_VEND1  BETWEEN '" + cVendDe + "' AND '" + cVendAte + "'	AND  " + Enter
		If lFiltra
			cQuery := cQuery +  "					   SC5.C5_VEND1	IN (SELECT ZZI_VEND FROM " + RetSqlName("ZZI") + "	 " + Enter
			cQuery := cQuery +  "		   						WHERE ZZI_FILIAL = '" + xFilial("ZZI") + "'	AND " + Enter
			If cSegDe <> "T"
				cQuery := cQuery +  "		   							ZZI_TPSEG  =  '" + cSegDe + "'		AND " + Enter
			EndIf
			If Alltrim(CATENDENTE) <> ""
				cQuery := cQuery +  "		   							ZZI_ATENDE = '" + CATENDENTE + "'	AND " + Enter
			EndIf 
			cQuery := cQuery +  "		   							ZZI_SUPER  >= '" + cSuperDe + "' AND ZZI_SUPER  <= '" + cSuperAte + "'	AND	 " + Enter
			cQuery := cQuery +  "									ZZI_GERENT >= '" + cGerDe + "' AND ZZI_GERENT <= '" + cGerAte + "'		AND	 " + Enter
			cQuery := cQuery +  "									D_E_L_E_T_ = '') AND " + Enter
		EndIf
		cQuery := cQuery +  "					   SC6.F4_DUPLIC  = 'S' 			AND " + Enter
		cQuery := cQuery +  " 					   SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 	AND " + Enter
		cQuery := cQuery +  " 					   SC6.C6_BLQ <> 'R'   				AND " + Enter
		cQuery := cQuery +  "					   SB1.B1_YCLASSE >= '" + cClasDe + "' AND  " + Enter
		cQuery := cQuery +  "					   SB1.B1_YCLASSE <= '" + cClasAte + "'	AND  " + Enter
		cQuery := cQuery +  " 					   SB1.B1_TIPO    = 'PA' AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' AND B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF')  " + Enter
		cQuery := cQuery +  " 				 GROUP BY C5_CLIENTE, C5_LOJACLI) AS PED " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = PED.C5_CLIENTE " + Enter

		cQuery := cQuery +  " 	LEFT JOIN (SELECT C5_CLIENTE, C5_LOJACLI, SUM(C6_QTDVEN) AS SALDO " + Enter
		cQuery := cQuery +  " 				 FROM VW_SC5 SC5, VW_SC6 SC6, " + RetSqlName("SB1") + " SB1  " + Enter
		cQuery := cQuery +  " 				 WHERE SC5.C5_FILIAL  = '" + xFilial("SC5") + "'	AND  " + Enter
		cQuery := cQuery +  " 					   SC6.C6_FILIAL  = '" + xFilial("SC6") + "' 	AND  " + Enter
		cQuery := cQuery +  " 					   SC5.C5_NUM     = SC6.C6_NUM 		AND  " + Enter
		cQuery := cQuery +  " 					   SC5.C5_CLIENTE = SC6.C6_CLI 		AND  " + Enter
		cQuery := cQuery +  " 					   SC5.C5_YEMP    = SC6.C6_YEMP     AND  " + Enter
		cQuery := cQuery +  " 					   SC5.C5_YEMPORI = SC6.C6_YEMPORI  AND  " + Enter
		cQuery := cQuery +  " 					   SC6.C6_PRODUTO = SB1.B1_COD 		AND  " + Enter
		If Len(Alltrim(nEmp)) == 4
			cQuery := cQuery +  " 					   SC5.C5_YEMP    = '" + nEmp + "'	AND  " + Enter //DETERMINA A EMPRESA	
		Else
			cQuery := cQuery +  " 					   SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	AND " + Enter //DETERMINA A EMPRESA	
		EndIf
		cQuery := cQuery +  " 					   SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND  " + Enter
		cQuery := cQuery +  " 					   SB1.D_E_L_E_T_ = '' 				AND  " + Enter
		cQuery := cQuery +  " 					   SC5.C5_TIPO 	  = 'N' 			AND  " + Enter
		cQuery := cQuery +  "		   			   SC5.C5_YLINHA BETWEEN '" + cLinhaI + "' AND '" + cLinhaF + "'   AND  " + Enter
		cQuery := cQuery +  "					   SC5.C5_VEND1  BETWEEN '" + cVendDe + "' AND '" + cVendAte + "'	AND  " + Enter
		If lFiltra
			cQuery := cQuery +  "					   SC5.C5_VEND1	IN (SELECT ZZI_VEND FROM " + RetSqlName("ZZI") + "	 " + Enter
			cQuery := cQuery +  "					   		WHERE ZZI_FILIAL = '" + xFilial("ZZI") + "'	AND  " + Enter
			If cSegDe <> "T"
				cQuery := cQuery +  "					   			ZZI_TPSEG  =  '" + cSegDe + "'		AND  " + Enter
			EndIf
			If Alltrim(CATENDENTE) <> ""
				cQuery := cQuery +  "					   			ZZI_ATENDE = '" + CATENDENTE + "'	AND  " + Enter
			EndIf 
			cQuery := cQuery +  "					   			ZZI_SUPER  >= '" + cSuperDe + "' AND ZZI_SUPER  <= '" + cSuperAte + "'	AND	 " + Enter
			cQuery := cQuery +  "					   			ZZI_GERENT >= '" + cGerDe + "' AND ZZI_GERENT <= '" + cGerAte + "'		AND	 " + Enter
			cQuery := cQuery +  "					   			D_E_L_E_T_ = '') AND  " + Enter
		EndIf
		cQuery := cQuery +  "					   SC6.F4_DUPLIC  = 'S' 			AND  " + Enter
		cQuery := cQuery +  " 					   SC5.C5_EMISSAO BETWEEN '" + dEmisDe + "' AND '" + dEmisAte + "' AND  " + Enter
		cQuery := cQuery +  "					   SB1.B1_YCLASSE >= '" + cClasDe + "'	AND  " + Enter
		cQuery := cQuery +  "					   SB1.B1_YCLASSE <= '" + cClasAte + "'	AND  " + Enter
		cQuery := cQuery +  " 					   SB1.B1_TIPO    = 'PA' AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' AND B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF')  " + Enter
		cQuery := cQuery +  " 				 GROUP BY C5_CLIENTE, C5_LOJACLI) AS EMITI " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = EMITI.C5_CLIENTE " + Enter

		cQuery := cQuery +  " 	LEFT JOIN (SELECT A1_COD, A1_LOJA, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2  " + Enter
		cQuery := cQuery +  "  				 FROM VW_BIA992_1  " + Enter
		cQuery := cQuery +  " 				 GROUP BY A1_COD, A1_LOJA) AS ANO " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = ANO.A1_COD " + Enter
		cQuery := cQuery +  "			AND SA1.A1_LOJA = ANO.A1_LOJA " + Enter
		cQuery := cQuery +  "	LEFT JOIN (SELECT A1_COD, A1_LOJA, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2  " + Enter
		cQuery := cQuery +  " 				 FROM VW_BIA992_2  " + Enter
		cQuery := cQuery +  " 				 GROUP BY A1_COD, A1_LOJA) AS TRI " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = TRI.A1_COD " + Enter
		cQuery := cQuery +  " 	LEFT JOIN (SELECT A1_COD, A1_LOJA, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2  " + Enter
		cQuery := cQuery +  " 				 FROM VW_BIA992_3  " + Enter
		cQuery := cQuery +  " 				 GROUP BY A1_COD, A1_LOJA) AS MES " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = MES.A1_COD " + Enter

		cQuery := cQuery +  " 	LEFT JOIN (SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR " + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO " + Enter
		cQuery := cQuery +  " 				 WHERE D_E_L_E_T_ = ''	AND	 " + Enter
		cQuery := cQuery +  "					   ZO_SERIE   BETWEEN '" + cSerieDe + "' AND '" + cSerieAte + "' AND  " + Enter
		cQuery := cQuery +  "					   ZO_STATUS  = 'Baixa Total'      AND  " + Enter
		cQuery := cQuery +  "					   ZO_DATA  BETWEEN '" + dtAnoI + "' AND '" + dtAnoF + "'  " + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_CLIENTE) AS INVANO " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = INVANO.ZO_CLIENTE " + Enter
		cQuery := cQuery +  " 	LEFT JOIN (SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR " + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO " + Enter
		cQuery := cQuery +  " 				 WHERE D_E_L_E_T_ = '' AND " + Enter
		cQuery := cQuery +  "					   ZO_SERIE   BETWEEN '" + cSerieDe + "' AND '" + cSerieAte + "' AND " + Enter
		cQuery := cQuery +  "					   ZO_STATUS  = 'Baixa Total'   AND " + Enter
		cQuery := cQuery +  "					   ZO_DATA BETWEEN '" + dtTriI + "' AND '" + dtTriF + "' " + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_CLIENTE) AS INVTRI " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = INVTRI.ZO_CLIENTE " + Enter
		cQuery := cQuery +  " 	LEFT JOIN (SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR " + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO  " + Enter
		cQuery := cQuery +  " 				 WHERE D_E_L_E_T_ = '' AND  " + Enter
		cQuery := cQuery +  "					   ZO_SERIE   BETWEEN '" + cSerieDe + "' AND '" + cSerieAte + "' AND  " + Enter
		cQuery := cQuery +  "					   ZO_STATUS  = 'Baixa Total'   AND  " + Enter
		cQuery := cQuery +  "					   ZO_DATA BETWEEN '20150401'   AND '20150430'  " + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_CLIENTE) AS INVMES " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = INVMES.ZO_CLIENTE " + Enter
		cQuery := cQuery +  " 	LEFT JOIN (SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR " + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO  " + Enter
		cQuery := cQuery +  " 				 WHERE D_E_L_E_T_ = ''	AND	 " + Enter
		cQuery := cQuery +  "					   ZO_SERIE   BETWEEN '" + cSerieDe + "' AND '" + cSerieAte + "' AND  " + Enter
		cQuery := cQuery +  "					   ZO_FPAGTO IN ('1','3') AND  " + Enter
		cQuery := cQuery +  "					   ZO_STATUS  = 'Baixa Total'      AND  " + Enter
		cQuery := cQuery +  "					   ZO_DATA  BETWEEN '" + dtAnoI + "'   AND '" + dtAnoF + "'  " + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_CLIENTE) AS INVANOCLI " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = INVANOCLI.ZO_CLIENTE " + Enter
		cQuery := cQuery +  " 	LEFT JOIN (SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR " + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO  " + Enter
		cQuery := cQuery +  " 				 WHERE D_E_L_E_T_ = ''	AND	 " + Enter
		cQuery := cQuery +  "					   ZO_SERIE   BETWEEN '" + cSerieDe + "' AND '" + cSerieAte + "' AND  " + Enter
		cQuery := cQuery +  "					   ZO_FPAGTO IN ('1','3') AND  " + Enter
		cQuery := cQuery +  "					   ZO_STATUS  = 'Baixa Total'      AND  " + Enter
		cQuery := cQuery +  "					   ZO_DATA  BETWEEN '" + dtTriI + "'   AND '" + dtTriF + "'  " + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_CLIENTE) AS INVTRICLI " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = INVTRICLI.ZO_CLIENTE " + Enter
		cQuery := cQuery +  " 	LEFT JOIN (SELECT ZO_CLIENTE, SUM(ZO_VALOR) AS VALOR " + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO  " + Enter
		cQuery := cQuery +  " 				 WHERE D_E_L_E_T_ = ''	AND	 " + Enter
		cQuery := cQuery +  "					   ZO_SERIE   BETWEEN '" + cSerieDe + "' AND '" + cSerieAte + "' AND  " + Enter
		cQuery := cQuery +  "					   ZO_FPAGTO IN ('1','3') AND  " + Enter
		cQuery := cQuery +  "					   ZO_STATUS  = 'Baixa Total'      AND  " + Enter
		cQuery := cQuery +  "					   ZO_DATA  BETWEEN '" + dtAtuI + "'   AND '" + dtAtuF + "' " + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_CLIENTE) AS INVMESCLI " + Enter
		cQuery := cQuery +  " 		ON SA1.A1_COD = INVMESCLI.ZO_CLIENTE " + Enter
		cQuery := cQuery +  " 	INNER JOIN VW_BIA992_5 AS CLI " + Enter
		cQuery := cQuery +  " 		ON CLI.F2_CLIENTE = SA1.A1_COD " + Enter
		cQuery := cQuery +  "			AND CLI.F2_LOJA = SA1.A1_LOJA " + Enter

		cQuery := cQuery +  " WHERE SA1.A1_FILIAL	= '" + xFilial("SA1") + "' AND " + Enter
		cQuery := cQuery +  "       SA1.A1_COD		BETWEEN '" + cCliDe + "' AND '" + cCliAte + "' AND  " + Enter
		If cSegDe <> "T"
			cQuery := cQuery +  "       SA1.A1_YTPSEG	=	'"+cSegDe+"'	AND  " + Enter
		EndIf
		cQuery := cQuery +  "       SA1.A1_EST		BETWEEN '"+CESTDE+"' AND '"+CESTATE+"' AND " + Enter
		cQuery := cQuery +  "       SA1.D_E_L_E_T_	= '' " + Enter


		//Executa a Query
		TcSQLExec(cQuery)

		cQuery := ""
		cQuery := "ALTER VIEW VW_BIA992 AS"	 + Enter
		cQuery := cQuery +  "SELECT COD, '' AS A1_YTPSEG, 'C' AS BLQ, NOME, TIPO, 0 AS META_REPRES, SUM(PEDPEN) AS PEDPEN, SUM(PEDEMIT) AS PEDEMIT,	" + Enter
		cQuery := cQuery +  "		EST = CASE WHEN SUBSTRING(COD,7,1) = 'C' THEN MAX(EST) ELSE '' END, 				" + Enter
		cQuery := cQuery +  "		SUM(QUANT_ANO/"+Alltrim(Str(nMesAno))+") AS QUANT_ANO, SUM(VL1_ANO/"+Alltrim(Str(nMesAno))+") AS VL1_ANO, SUM(VL2_ANO/"+Alltrim(Str(nMesAno))+") AS VL2_ANO, SUM(VL3_ANO/"+Alltrim(Str(nMesAno))+") AS VL3_ANO,  " + Enter
		cQuery := cQuery +  "		SUM(QUANT_TRI/"+Alltrim(Str(nMesTri))+") AS QUANT_TRI, SUM(VL1_TRI/"+Alltrim(Str(nMesTri))+") AS VL1_TRI, SUM(VL2_TRI/"+Alltrim(Str(nMesTri))+") AS VL2_TRI, SUM(VL3_TRI/"+Alltrim(Str(nMesTri))+") AS VL3_TRI,  " + Enter
		cQuery := cQuery +  "		SUM(QUANT_MES/"+Alltrim(Str(nMesMes))+") AS QUANT_MES, SUM(VL1_MES/"+Alltrim(Str(nMesMes))+") AS VL1_MES, SUM(VL2_MES/"+Alltrim(Str(nMesMes))+") AS VL2_MES, SUM(VL3_MES/"+Alltrim(Str(nMesMes))+") AS VL3_MES,  " + Enter
		cQuery := cQuery +  "		"+Alltrim(Str(nMesAno))+" AS ANOMES, "+Alltrim(Str(nMesTri))+" AS TRIMES, "+Alltrim(Str(nMesMes))+" AS MESMES, 									" + Enter  
		cQuery := cQuery +  "		VL4_MES = CASE																																	" + Enter  
		cQuery := cQuery +  "					WHEN SUM(VLRORI_MES) > 0 THEN ROUND(((SUM(VL4_MES)/(1-SUM(VLRIMP_MES)/SUM(VLRORI_MES)))/"+Alltrim(Str(nMesMes))+"),2) ELSE 0 END,	" + Enter  
		cQuery := cQuery +  "		VL4_TRI = CASE																																	" + Enter  
		cQuery := cQuery +  "					WHEN SUM(VLRORI_TRI) > 0 THEN ROUND(((SUM(VL4_TRI)/(1-SUM(VLRIMP_TRI)/SUM(VLRORI_TRI)))/"+Alltrim(Str(nMesTri))+"),2) ELSE 0 END,	" + Enter  
		cQuery := cQuery +  "		VL4_ANO = CASE																																	" + Enter  
		cQuery := cQuery +  "					WHEN SUM(VLRORI_ANO) > 0 THEN ROUND(((SUM(VL4_ANO)/(1-SUM(VLRIMP_ANO)/SUM(VLRORI_ANO)))/"+Alltrim(Str(nMesAno))+"),2) ELSE 0 END	" + Enter  
		cQuery := cQuery +  "FROM VW_BIA992_4 " + Enter
		cQuery := cQuery +  "GROUP BY COD, NOME, TIPO " + Enter

		//Executa a Query
		TcSQLExec(cQuery)

	ElseIf cOrdem == 2

		//Ordenado por Representante
		cQuery := ""                                                             

		//	cQuery := "ALTER VIEW VW_BIA992_4 AS "	 + Enter
		//	cQuery := cQuery +  " SELECT A3_COD, REP.A1_YTPSEG,	" + Enter //O Codigo do Representante e utilizado para filtrar as metas de cada Representante
		//	cQuery := cQuery +  "			COD = CASE 							" + Enter
		// 	cQuery := cQuery +  "					WHEN SA3.A3_GRPREP = '' THEN SA3.A3_COD+'C' "	 + Enter
		// 	cQuery := cQuery +  "					ELSE SA3.A3_GRPREP+'G' 		" + Enter
		//	cQuery := cQuery +  "					END,						" + Enter
		//	cQuery := cQuery +  "			NOME = CASE 						" + Enter
		//	cQuery := cQuery +  "					WHEN SA3.A3_GRPREP = '' THEN SA3.A3_NREDUZ "	 + Enter
		//	cQuery := cQuery +  "					ELSE ACA.ACA_DESCRI 		" + Enter
		//	cQuery := cQuery +  "					END,						" + Enter
		//	cQuery := cQuery +  " 		 SA3.A3_MSBLQL AS BLQ, SA3.A3_TIPO AS TIPO, A3_EST AS EST, ISNULL(PED.SALDO,0) AS PEDPEN, ISNULL(EMITI.SALDO,0) AS PEDEMIT," + Enter
		//	cQuery := cQuery +  "        ISNULL(ANO.QUANT,0) AS QUANT_ANO, ISNULL(ANO.VL1,0) AS VL1_ANO, ISNULL(ANO.VL2,0) AS VL2_ANO, ISNULL(INVANO.VALOR,0) AS VL3_ANO, ISNULL(ANO.PERC_IMP,0) AS PERCIMP_ANO, ISNULL(ANO.VLR_IMP,0) VLRIMP_ANO, ISNULL(ANO.VLR_ORI,0) VLRORI_ANO, " + Enter
		//	cQuery := cQuery +  "        ISNULL(TRI.QUANT,0) AS QUANT_TRI, ISNULL(TRI.VL1,0) AS VL1_TRI, ISNULL(TRI.VL2,0) AS VL2_TRI, ISNULL(INVTRI.VALOR,0) AS VL3_TRI, ISNULL(TRI.PERC_IMP,0) AS PERCIMP_TRI, ISNULL(TRI.VLR_IMP,0) VLRIMP_TRI, ISNULL(TRI.VLR_ORI,0) VLRORI_TRI, " + Enter
		//	cQuery := cQuery +  "        ISNULL(MES.QUANT,0) AS QUANT_MES, ISNULL(MES.VL1,0) AS VL1_MES, ISNULL(MES.VL2,0) AS VL2_MES, ISNULL(INVMES.VALOR,0) AS VL3_MES, ISNULL(MES.PERC_IMP,0) AS PERCIMP_MES, ISNULL(MES.VLR_IMP,0) VLRIMP_MES, ISNULL(MES.VLR_ORI,0) VLRORI_MES, " + Enter
		//	cQuery := cQuery +  "		 ISNULL(INVANOCLI.VALOR,0) AS VL4_ANO, ISNULL(INVTRICLI.VALOR,0) AS VL4_TRI, ISNULL(INVMESCLI.VALOR,0) VL4_MES " + Enter	
		//	cQuery := cQuery +  " FROM	VW_BIA992_5 AS REP, " + RetSqlName("SA3") + " SA3,  ACA010 ACA, " + Enter
		//	cQuery := cQuery +  " 	(SELECT C5_VEND1, A1_YTPSEG, SUM(C6_QTDVEN-C6_QTDENT) AS SALDO		" + Enter
		//	cQuery := cQuery +  " 	 FROM VW_SC5 SC5, VW_SC6 SC6, " + RetSqlName("SB1") + " SB1, SA1010 SA1 " + Enter
		//	cQuery := cQuery +  " 	 WHERE SC5.C5_FILIAL  = '"+xFilial("SC5")+"'	AND " + Enter
		//	cQuery := cQuery +  " 	       SC6.C6_FILIAL  = '"+xFilial("SC6")+"' 	AND " + Enter 
		//	cQuery := cQuery +  " 	       SA1.A1_FILIAL  = '"+xFilial("SA1")+"' 	AND " + Enter 	
		//	cQuery := cQuery +  " 	       SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND " + Enter
		//	cQuery := cQuery +  "		   SC5.C5_CLIENTE = SA1.A1_COD		AND " + Enter
		//	cQuery := cQuery +  "		   SC5.C5_LOJACLI = SA1.A1_LOJA		AND " + Enter
		//	cQuery := cQuery +  " 	       SC5.C5_NUM     = SC6.C6_NUM 		AND " + Enter
		//	cQuery := cQuery +  " 	       SC5.C5_CLIENTE = SC6.C6_CLI 		AND " + Enter
		//	cQuery := cQuery +  " 	       SC5.C5_YEMP	  = SC6.C6_YEMP     AND " + Enter
		//	cQuery := cQuery +  " 	       SC5.C5_YEMPORI = SC6.C6_YEMPORI  AND " + Enter		
		//	cQuery := cQuery +  " 	       SC6.C6_PRODUTO = SB1.B1_COD 		AND " + Enter

		//	If Len(Alltrim(nEmp)) == 4
		//		cQuery := cQuery +  " 	       SC5.C5_YEMP = '"+nEmp+"'	AND " + Enter  //DETERMINA A EMPRESA		
		//	Else
		//		cQuery := cQuery +  " 	       SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	AND " + Enter  //DETERMINA A EMPRESA		
		//	EndIf	

		//	cQuery := cQuery +  " 	       SC5.C5_TIPO 	  = 'N' 			AND " + Enter
		//	If cSegDe <> "T"	
		//		cQuery := cQuery +  " 	       SA1.A1_YTPSEG = '"+cSegDe+"' AND	" + Enter	
		//	EndIf
		//	cQuery := cQuery +  "		   		  SC5.C5_YLINHA BETWEEN '"+cLinhaI+"'  AND '"+cLinhaF+"'   AND " + Enter
		//	cQuery := cQuery +  "          SC5.C5_VEND1  BETWEEN '"+cVendDe+"'  AND '"+cVendAte+"'	AND " + Enter
		//	If lFiltra
		//		cQuery := cQuery +  "		   SC5.C5_VEND1	IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"	" + Enter
		//		cQuery := cQuery +  "								WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND " + Enter
		//		If cSegDe <> "T"
		//			cQuery := cQuery +  "								ZZI_TPSEG  =  '"+cSegDe+"'		AND " + Enter
		//		EndIf
		//		If Alltrim(CATENDENTE) <> ""
		//			cQuery := cQuery +  "								ZZI_ATENDE = '"+CATENDENTE+"'	AND " + Enter	
		//		EndIf 
		//		cQuery := cQuery +  "								ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"'	AND	" + Enter
		//		cQuery := cQuery +  "								ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'		AND	" + Enter
		//		cQuery := cQuery +  "								D_E_L_E_T_ = '') AND 												" + Enter
		//	EndIf	
		//	cQuery := cQuery +  "		   SC6.F4_DUPLIC  = 'S' 			AND " + Enter
		//	cQuery := cQuery +  " 	       SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 	AND " + Enter     
		//	cQuery := cQuery +  " 	       SC6.C6_BLQ <> 'R'			 	AND " + Enter	
		//	cQuery := cQuery +  "		   SB1.B1_YCLASSE >= '"+cClasDe+"'	AND "   + Enter	
		//	cQuery := cQuery +  "		   SB1.B1_YCLASSE <= '"+cClasAte+"'	AND "   + Enter		
		//	cQuery := cQuery +  " 	       SB1.B1_TIPO    = 'PA' AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' AND B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND " + Enter
		//	cQuery := cQuery +  " 	       SA1.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = ''		" + Enter
		//	cQuery := cQuery +  " 	 GROUP BY C5_VEND1, A1_YTPSEG) AS PED,					" + Enter
		//	cQuery := cQuery +  " 	(SELECT C5_VEND1, A1_YTPSEG, SUM(C6_QTDVEN) AS SALDO	" + Enter
		//	cQuery := cQuery +  " 	 FROM 	VW_SC5 SC5, VW_SC6 SC6, " + RetSqlName("SB1") + " SB1, SA1010 SA1 " + Enter
		//	cQuery := cQuery +  " 	 WHERE SC5.C5_FILIAL  = '"+xFilial("SC5")+"'	AND " + Enter
		//	cQuery := cQuery +  " 	       SC6.C6_FILIAL  = '"+xFilial("SC6")+"' 	AND " + Enter
		//	cQuery := cQuery +  " 	       SA1.A1_FILIAL  = '"+xFilial("SA1")+"' 	AND " + Enter
		//	cQuery := cQuery +  " 	       SB1.B1_FILIAL  = '"+xFilial("SB1")+"' 	AND " + Enter
		//	cQuery := cQuery +  "		   SC5.C5_CLIENTE = SA1.A1_COD		AND " + Enter
		//	cQuery := cQuery +  "		   SC5.C5_LOJACLI = SA1.A1_LOJA		AND " + Enter
		//	cQuery := cQuery +  " 	       SC5.C5_NUM     = SC6.C6_NUM 		AND " + Enter
		//	cQuery := cQuery +  " 	       SC5.C5_CLIENTE = SC6.C6_CLI 		AND " + Enter
		//	cQuery := cQuery +  " 	       SC5.C5_YEMP    = SC6.C6_YEMP     AND " + Enter
		//	cQuery := cQuery +  " 	       SC5.C5_YEMPORI = SC6.C6_YEMPORI  AND " + Enter			
		//	cQuery := cQuery +  " 	       SC6.C6_PRODUTO = SB1.B1_COD 		AND " + Enter

		//	If Len(Alltrim(nEmp)) == 4
		//		cQuery := cQuery +  " 	       SC5.C5_YEMP = '"+nEmp+"'	AND " + Enter  //DETERMINA A EMPRESA		
		//	Else
		//		cQuery := cQuery +  " 	       SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	AND " + Enter  //DETERMINA A EMPRESA		
		//	EndIf	

		//	cQuery := cQuery +  " 	       SC5.C5_TIPO 	  = 'N' 			AND "	 + Enter
		//	If cSegDe <> "T"	
		//		cQuery := cQuery +  " 	       SA1.A1_YTPSEG = '"+cSegDe+"' AND	" + Enter	
		//	EndIf
		//	cQuery := cQuery +  "		   		  SC5.C5_YLINHA BETWEEN '"+cLinhaI+"'  AND '"+cLinhaF+"'   AND " + Enter
		//	cQuery := cQuery +  "          SC5.C5_VEND1  BETWEEN '"+cVendDe+"' AND '"+cVendAte+"'	AND " + Enter
		//	If lFiltra
		//		cQuery := cQuery +  "		   SC5.C5_VEND1	IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"	" + Enter
		//		cQuery := cQuery +  "								WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND " + Enter
		//		If cSegDe <> "T"
		//			cQuery := cQuery +  "								ZZI_TPSEG  =  '"+cSegDe+"'		AND " + Enter
		//		EndIf
		//		If Alltrim(CATENDENTE) <> ""
		//			cQuery := cQuery +  "								ZZI_ATENDE = '"+CATENDENTE+"'	AND " + Enter	
		//		EndIf 
		//		cQuery := cQuery +  "								ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"'	AND	" + Enter
		//		cQuery := cQuery +  "								ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'		AND	" + Enter
		//		cQuery := cQuery +  "								D_E_L_E_T_ = '') AND 												" + Enter
		//	EndIf
		//	cQuery := cQuery +  "		   SC6.F4_DUPLIC  = 'S' 			AND " + Enter	
		//	cQuery := cQuery +  " 	       SC5.C5_EMISSAO BETWEEN '"+dEmisDe+"' AND '"+dEmisAte+"' AND " + Enter
		//	cQuery := cQuery +  "		   SB1.B1_YCLASSE >= '"+cClasDe+"'	AND "   + Enter	
		//	cQuery := cQuery +  "		   SB1.B1_YCLASSE <= '"+cClasAte+"'	AND "   + Enter		
		//	cQuery := cQuery +  " 	       SB1.B1_TIPO    = 'PA'  AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' AND B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND " + Enter
		//	cQuery := cQuery +  " 	       SA1.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = ''	" + Enter
		//	cQuery := cQuery +  " 	 GROUP BY C5_VEND1, A1_YTPSEG) AS EMITI,			" + Enter

		//	cQuery := cQuery +  " 	(SELECT F2_VEND1,  A1_YTPSEG, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2 " + Enter
		//	cQuery := cQuery +  " 	FROM VW_BIA992_1  			" + Enter
		//	cQuery := cQuery +  " 	GROUP BY F2_VEND1, A1_YTPSEG) AS ANO,	" + Enter

		//	cQuery := cQuery +  " 	(SELECT F2_VEND1,  A1_YTPSEG, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2 " + Enter
		//	cQuery := cQuery +  " 	FROM VW_BIA992_2  			" + Enter
		//	cQuery := cQuery +  " 	GROUP BY F2_VEND1, A1_YTPSEG) AS TRI,	" + Enter

		//	cQuery := cQuery +  " 	(SELECT F2_VEND1,  A1_YTPSEG, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2 " + Enter
		//	cQuery := cQuery +  " 	FROM VW_BIA992_3  			" + Enter
		//	cQuery := cQuery +  " 	GROUP BY F2_VEND1, A1_YTPSEG) AS MES,  " + Enter

		//	cQuery := cQuery +  " 	(SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR	" + Enter
		//	cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1		" + Enter
		//	cQuery := cQuery +  " 	 WHERE ZO_FILIAL    = '"+xFilial("SZO")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   A1_FILIAL    = '"+xFilial("SA1")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_CLIENTE	= SA1.A1_COD			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_SERIE		BETWEEN '"+cSerieDe+"'	AND '"+cSerieAte+"' AND	" + Enter
		//	cQuery := cQuery +  "		   ZO_STATUS	= 'Baixa Total'			AND 	" + Enter
		//	cQuery := cQuery +  "		   ZO_DATA		BETWEEN '"+dtAnoI+"' 	AND '"+dtAnoF+"' 	AND " + Enter
		//	If cSegDe <> "T"	
		//		cQuery := cQuery +  "		   A1_YTPSEG = '"+cSegDe+"'				AND		" + Enter	
		//	EndIf
		//	cQuery := cQuery +  "		   SZO.D_E_L_E_T_	= ''				AND		" + Enter
		//	cQuery := cQuery +  "		   SA1.D_E_L_E_T_	= ''						" + Enter
		//	cQuery := cQuery +  " 	 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVANO, 			" + Enter
		//	cQuery := cQuery +  " 	(SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR	" + Enter
		//	cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1		" + Enter
		//	cQuery := cQuery +  " 	 WHERE ZO_FILIAL    = '"+xFilial("SZO")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   A1_FILIAL    = '"+xFilial("SA1")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_CLIENTE	= SA1.A1_COD			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_SERIE		BETWEEN '"+cSerieDe+"'	AND '"+cSerieAte+"' AND	" + Enter
		//	cQuery := cQuery +  "		   ZO_STATUS	= 'Baixa Total'   		AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_DATA		BETWEEN '"+dtTriI+"' 	AND '"+dtTriF+"'	AND " + Enter
		//	If cSegDe <> "T"	
		//		cQuery := cQuery +  "		   A1_YTPSEG = '"+cSegDe+"'				AND		" + Enter	
		//	EndIf
		//	cQuery := cQuery +  "		   SZO.D_E_L_E_T_	= ''				AND		" + Enter
		//	cQuery := cQuery +  "		   SA1.D_E_L_E_T_	= ''						" + Enter
		//	cQuery := cQuery +  " 	 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVTRI,			" + Enter
		//	cQuery := cQuery +  " 	(SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR	" + Enter
		//	cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1		" + Enter
		//	cQuery := cQuery +  " 	 WHERE ZO_FILIAL    = '"+xFilial("SZO")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   A1_FILIAL    = '"+xFilial("SA1")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_CLIENTE	= SA1.A1_COD			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_SERIE		BETWEEN '"+cSerieDe+"' 	AND '"+cSerieAte+"' AND	" + Enter
		//	cQuery := cQuery +  "		   ZO_STATUS	= 'Baixa Total'    		AND 	" + Enter
		//	cQuery := cQuery +  "		   ZO_DATA		BETWEEN '"+dtAtuI+"' 	AND '"+dtAtuf+"' 	AND	" + Enter
		//	If cSegDe <> "T"	
		//		cQuery := cQuery +  "		   A1_YTPSEG = '"+cSegDe+"'				AND		" + Enter	
		//	EndIf
		//	cQuery := cQuery +  "		   SZO.D_E_L_E_T_	= ''				AND		" + Enter
		//	cQuery := cQuery +  "		   SA1.D_E_L_E_T_	= ''						" + Enter
		//	cQuery := cQuery +  " 	 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVMES,			" + Enter
		//	cQuery := cQuery +  " 	(SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR	" + Enter
		//	cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1		" + Enter
		//	cQuery := cQuery +  " 	 WHERE ZO_FILIAL    = '"+xFilial("SZO")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   A1_FILIAL    = '"+xFilial("SA1")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_CLIENTE	= SA1.A1_COD			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_SERIE		BETWEEN '"+cSerieDe+"' 	AND '"+cSerieAte+"' AND	" + Enter
		//	cQuery := cQuery +  "		   ZO_FPAGTO	IN ('1','3')			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_STATUS	= 'Baixa Total'			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_DATA		BETWEEN '"+dtAnoI+"' 	AND '"+dtAnoF+"' 	AND	" + Enter
		//	If cSegDe <> "T"	
		//		cQuery := cQuery +  "		   A1_YTPSEG = '"+cSegDe+"'				AND		" + Enter	
		//	EndIf
		//	cQuery := cQuery +  "		   SZO.D_E_L_E_T_	= ''				AND		" + Enter
		//	cQuery := cQuery +  "		   SA1.D_E_L_E_T_	= ''						" + Enter
		//	cQuery := cQuery +  " 	 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVANOCLI,		" + Enter
		//	cQuery := cQuery +  " 	(SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR	" + Enter
		//	cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1		" + Enter
		//	cQuery := cQuery +  " 	 WHERE ZO_FILIAL    = '"+xFilial("SZO")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   A1_FILIAL    = '"+xFilial("SA1")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_CLIENTE	= SA1.A1_COD			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_SERIE		BETWEEN '"+cSerieDe+"' 	AND '"+cSerieAte+"' AND	" + Enter
		//	cQuery := cQuery +  "		   ZO_FPAGTO	IN ('1','3')			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_STATUS	= 'Baixa Total'			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_DATA		BETWEEN '"+dtTriI+"' 	AND '"+dtTriF+"' 		AND	" + Enter
		//	If cSegDe <> "T"	
		//		cQuery := cQuery +  "		   A1_YTPSEG = '"+cSegDe+"'				AND		" + Enter	
		//	EndIf
		//	cQuery := cQuery +  "		   SZO.D_E_L_E_T_	= ''				AND		" + Enter
		//	cQuery := cQuery +  "		   SA1.D_E_L_E_T_	= ''						" + Enter
		//	cQuery := cQuery +  " 	 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVTRICLI,		" + Enter
		//	cQuery := cQuery +  " 	(SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR	" + Enter
		//	cQuery := cQuery +  " 	 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1		" + Enter
		//	cQuery := cQuery +  " 	 WHERE ZO_FILIAL    = '"+xFilial("SZO")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   A1_FILIAL    = '"+xFilial("SA1")+"'	AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_CLIENTE	= SA1.A1_COD			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_SERIE		BETWEEN '"+cSerieDe+"' 	AND '"+cSerieAte+"' AND	" + Enter
		//	cQuery := cQuery +  "		   ZO_FPAGTO	IN ('1','3')			AND		" + Enter
		//	cQuery := cQuery +  "		   ZO_STATUS	= 'Baixa Total'			AND		" + Enter	
		//	cQuery := cQuery +  "		   ZO_DATA		BETWEEN '"+dtAtuI+"' 	AND '"+dtAtuF+"'	AND " + Enter
		//	If cSegDe <> "T"	
		//		cQuery := cQuery +  "		   A1_YTPSEG = '"+cSegDe+"'				AND		" + Enter	
		//	EndIf
		//	cQuery := cQuery +  "		   SZO.D_E_L_E_T_	= ''				AND		" + Enter
		//	cQuery := cQuery +  "		   SA1.D_E_L_E_T_	= ''						" + Enter
		//	cQuery := cQuery +  " 	 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVMESCLI			" + Enter
		//	cQuery := cQuery +  " WHERE SA3.A3_FILIAL	= '"+xFilial("SA3")+"' AND	" + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	= SA3.A3_COD			AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	BETWEEN '"+cVendDe+"'	AND '"+cVendAte+"'	AND " + Enter
		//	If lFiltra
		//		cQuery := cQuery +  "		REP.C5_VEND1	IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"	" + Enter
		//		cQuery := cQuery +  "								WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND " + Enter
		//		If cSegDe <> "T"
		//			cQuery := cQuery +  "								ZZI_TPSEG  =  '"+cSegDe+"'		AND " + Enter
		//		EndIf
		//		If Alltrim(CATENDENTE) <> ""
		//			cQuery := cQuery +  "								ZZI_ATENDE = '"+CATENDENTE+"'	AND " + Enter	
		//		EndIf 
		//		cQuery := cQuery +  "								ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"'	AND	" + Enter
		//		cQuery := cQuery +  "								ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'		AND	" + Enter
		//		cQuery := cQuery +  "								D_E_L_E_T_ = '') AND 												" + Enter
		//	EndIf
		//	cQuery := cQuery +  "		SA3.A3_EST		BETWEEN '"+CESTDE+"'	AND '"+CESTATE+"'	AND	" + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= ANO.F2_VEND1			AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= ANO.A1_YTPSEG		AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= TRI.F2_VEND1			AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= TRI.A1_YTPSEG		AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= MES.F2_VEND1			AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= MES.A1_YTPSEG		AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= PED.C5_VEND1			AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= PED.A1_YTPSEG		AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= INVANO.ZO_REPRE		AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= INVANO.A1_YTPSEG		AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= INVTRI.ZO_REPRE		AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= INVTRI.A1_YTPSEG		AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= INVMES.ZO_REPRE		AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= INVMES.A1_YTPSEG		AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= INVANOCLI.ZO_REPRE	AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= INVANOCLI.A1_YTPSEG	AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= INVTRICLI.ZO_REPRE	AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= INVTRICLI.A1_YTPSEG	AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= INVMESCLI.ZO_REPRE	AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= INVMESCLI.A1_YTPSEG	AND " + Enter
		//	cQuery := cQuery +  "		REP.C5_VEND1	*= EMITI.C5_VEND1		AND " + Enter
		//	cQuery := cQuery +  "		REP.A1_YTPSEG	*= EMITI.A1_YTPSEG		AND " + Enter
		//	cQuery := cQuery +  "		SA3.A3_GRPREP	*= ACA.ACA_GRPREP		AND " + Enter
		//	cQuery := cQuery +  "		ACA.D_E_L_E_T_	= ''					AND	" + Enter
		//	cQuery := cQuery +  "		SA3.D_E_L_E_T_	= ''						" + Enter


		//ATUALIZA«√O QUERY - SQL ATUAL - 19/01/2016
		cQuery := "ALTER VIEW VW_BIA992_4 AS "	 + Enter
		cQuery := cQuery +  " SELECT A3_COD, REP.A1_YTPSEG,	" + Enter //O Codigo do Representante e utilizado para filtrar as metas de cada Representante
		cQuery := cQuery +  "			COD = CASE 							" + Enter
		cQuery := cQuery +  "					WHEN SA3.A3_GRPREP = '' THEN SA3.A3_COD+'C' "	 + Enter
		cQuery := cQuery +  "					ELSE SA3.A3_GRPREP+'G' 		" + Enter
		cQuery := cQuery +  "					END,						" + Enter
		cQuery := cQuery +  "			NOME = CASE 						" + Enter
		cQuery := cQuery +  "					WHEN SA3.A3_GRPREP = '' THEN SA3.A3_NREDUZ "	 + Enter
		cQuery := cQuery +  "					ELSE ACA.ACA_DESCRI 		" + Enter
		cQuery := cQuery +  "					END,						" + Enter
		cQuery := cQuery +  " 		 SA3.A3_MSBLQL AS BLQ, SA3.A3_TIPO AS TIPO, A3_EST AS EST, ISNULL(PED.SALDO,0) AS PEDPEN, ISNULL(EMITI.SALDO,0) AS PEDEMIT," + Enter
		cQuery := cQuery +  "        ISNULL(ANO.QUANT,0) AS QUANT_ANO, ISNULL(ANO.VL1,0) AS VL1_ANO, ISNULL(ANO.VL2,0) AS VL2_ANO, ISNULL(INVANO.VALOR,0) AS VL3_ANO, ISNULL(ANO.PERC_IMP,0) AS PERCIMP_ANO, ISNULL(ANO.VLR_IMP,0) VLRIMP_ANO, ISNULL(ANO.VLR_ORI,0) VLRORI_ANO, " + Enter
		cQuery := cQuery +  "        ISNULL(TRI.QUANT,0) AS QUANT_TRI, ISNULL(TRI.VL1,0) AS VL1_TRI, ISNULL(TRI.VL2,0) AS VL2_TRI, ISNULL(INVTRI.VALOR,0) AS VL3_TRI, ISNULL(TRI.PERC_IMP,0) AS PERCIMP_TRI, ISNULL(TRI.VLR_IMP,0) VLRIMP_TRI, ISNULL(TRI.VLR_ORI,0) VLRORI_TRI, " + Enter
		cQuery := cQuery +  "        ISNULL(MES.QUANT,0) AS QUANT_MES, ISNULL(MES.VL1,0) AS VL1_MES, ISNULL(MES.VL2,0) AS VL2_MES, ISNULL(INVMES.VALOR,0) AS VL3_MES, ISNULL(MES.PERC_IMP,0) AS PERCIMP_MES, ISNULL(MES.VLR_IMP,0) VLRIMP_MES, ISNULL(MES.VLR_ORI,0) VLRORI_MES, " + Enter
		cQuery := cQuery +  "		 ISNULL(INVANOCLI.VALOR,0) AS VL4_ANO, ISNULL(INVTRICLI.VALOR,0) AS VL4_TRI, ISNULL(INVMESCLI.VALOR,0) VL4_MES " + Enter	
		cQuery := cQuery +  "FROM	VW_BIA992_5 AS REP	" + Enter
		cQuery := cQuery +  "INNER JOIN " + RetSqlName("SA3") + " SA3	" + Enter
		cQuery := cQuery +  "	ON REP.C5_VEND1	= SA3.A3_COD	" + Enter
		cQuery := cQuery +  "		AND SA3.A3_FILIAL = '" + xFilial("SA3") + "'	" + Enter
		cQuery := cQuery +  "		AND SA3.A3_EST BETWEEN '" + CESTDE + "'	AND '" + CESTATE + "'	" + Enter
		cQuery := cQuery +  "		AND SA3.D_E_L_E_T_ = ''	" + Enter
		cQuery := cQuery +  "LEFT JOIN ACA010 ACA	" + Enter
		cQuery := cQuery +  "	ON SA3.A3_GRPREP = ACA.ACA_GRPREP	" + Enter
		cQuery := cQuery +  "		AND ACA.D_E_L_E_T_	= ''	" + Enter
		cQuery := cQuery +  "LEFT JOIN (SELECT C5_VEND1, A1_YTPSEG, SUM(C6_QTDVEN-C6_QTDENT) AS SALDO			" + Enter
		cQuery := cQuery +  " 				 FROM VW_SC5 SC5, VW_SC6 SC6, " + RetSqlName("SB1") + " SB1, SA1010 SA1	" + Enter
		cQuery := cQuery +  " 				 WHERE SC5.C5_FILIAL  = '" + xFilial("SC5") + "'	AND 	" + Enter
		cQuery := cQuery +  " 					   SC6.C6_FILIAL  = '" + xFilial("SC6") + "' 	AND  	" + Enter
		cQuery := cQuery +  " 					   SA1.A1_FILIAL  = '" + xFilial("SA1") + "' 	AND  		" + Enter
		cQuery := cQuery +  " 					   SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND 	" + Enter
		cQuery := cQuery +  "				   	   SC5.C5_CLIENTE = SA1.A1_COD		AND 	" + Enter
		cQuery := cQuery +  "				   	   SC5.C5_LOJACLI = SA1.A1_LOJA		AND 	" + Enter
		cQuery := cQuery +  " 					   SC5.C5_NUM     = SC6.C6_NUM 		AND 	" + Enter
		cQuery := cQuery +  " 					   SC5.C5_CLIENTE = SC6.C6_CLI 		AND 	" + Enter
		cQuery := cQuery +  " 					   SC5.C5_YEMP	  = SC6.C6_YEMP     AND 	" + Enter
		cQuery := cQuery +  " 					   SC5.C5_YEMPORI = SC6.C6_YEMPORI  AND 			" + Enter
		cQuery := cQuery +  " 					   SC6.C6_PRODUTO = SB1.B1_COD 		AND 	" + Enter

		If Len(Alltrim(nEmp)) == 4
			cQuery := cQuery +  " 					   SC5.C5_YEMP = '" + nEmp + "'	AND	" + Enter   //DETERMINA A EMPRESA		
		Else
			cQuery := cQuery +  "	 	       		   SUBSTRING(SC5.C5_YEMP,1,2) = '" + nEmp + "'	AND	" + Enter   //DETERMINA A EMPRESA		
		EndIf	

		cQuery := cQuery +  " 					   SC5.C5_TIPO 	  = 'N' 			AND 	" + Enter
		If cSegDe <> "T"	
			cQuery := cQuery +  " 					   SA1.A1_YTPSEG = '"+cSegDe+"' AND			" + Enter
		EndIf
		cQuery := cQuery +  " 					   SC5.C5_YLINHA BETWEEN '" + cLinhaI + "'  AND '" + cLinhaF + "'   AND 	" + Enter
		cQuery := cQuery +  " 					   SC5.C5_VEND1  BETWEEN '" + cVendDe + "'  AND '" + cVendAte + "'	AND 	" + Enter
		If lFiltra
			cQuery := cQuery +  " 					   SC5.C5_VEND1	IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"		" + Enter
			cQuery := cQuery +  " 					   		WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND 	" + Enter
			If cSegDe <> "T"
				cQuery := cQuery +  " 					   			ZZI_TPSEG  =  '"+cSegDe+"'		AND 	" + Enter
			EndIf
			If Alltrim(CATENDENTE) <> ""
				cQuery := cQuery +  " 					   			ZZI_ATENDE = '"+CATENDENTE+"'	AND 		" + Enter
			EndIf 
			cQuery := cQuery +  " 					   			ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"'	AND		" + Enter
			cQuery := cQuery +  " 					   			ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'		AND		" + Enter
			cQuery := cQuery +  " 					   			D_E_L_E_T_ = '') AND 													" + Enter
		EndIf	
		cQuery := cQuery +  "				   SC6.F4_DUPLIC  = 'S' 			AND 	" + Enter
		cQuery := cQuery +  " 					   SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 	AND      	" + Enter
		cQuery := cQuery +  " 					   SC6.C6_BLQ <> 'R'			 	AND 		" + Enter
		cQuery := cQuery +  "				   SB1.B1_YCLASSE >= '" + cClasDe + "'	AND	" + Enter
		cQuery := cQuery +  "				   SB1.B1_YCLASSE <= '" + cClasAte + "'	AND	" + Enter
		cQuery := cQuery +  " 					   SB1.B1_TIPO    = 'PA' AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' AND B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND 	" + Enter
		cQuery := cQuery +  " 					   SA1.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = ''			" + Enter
		cQuery := cQuery +  " 				 GROUP BY C5_VEND1, A1_YTPSEG) AS PED	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = PED.C5_VEND1	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = PED.A1_YTPSEG	" + Enter

		cQuery := cQuery +  "LEFT JOIN (SELECT C5_VEND1, A1_YTPSEG, SUM(C6_QTDVEN) AS SALDO		" + Enter
		cQuery := cQuery +  " 				 FROM 	VW_SC5 SC5, VW_SC6 SC6, " + RetSqlName("SB1") + " SB1, SA1010 SA1 	" + Enter
		cQuery := cQuery +  " 				 WHERE SC5.C5_FILIAL  = '" + xFilial("SC5") + "'	AND 	" + Enter
		cQuery := cQuery +  " 					   SC6.C6_FILIAL  = '" + xFilial("SC6") + "' 	AND 	" + Enter
		cQuery := cQuery +  " 					   SA1.A1_FILIAL  = '" + xFilial("SA1") + "' 	AND 	" + Enter
		cQuery := cQuery +  " 					   SB1.B1_FILIAL  = '" + xFilial("SB1") + "' 	AND 	" + Enter
		cQuery := cQuery +  "				   	   SC5.C5_CLIENTE = SA1.A1_COD		AND 	" + Enter
		cQuery := cQuery +  "				   	   SC5.C5_LOJACLI = SA1.A1_LOJA		AND 	" + Enter
		cQuery := cQuery +  " 					   SC5.C5_NUM     = SC6.C6_NUM 		AND 	" + Enter
		cQuery := cQuery +  " 					   SC5.C5_CLIENTE = SC6.C6_CLI 		AND 	" + Enter
		cQuery := cQuery +  " 					   SC5.C5_YEMP    = SC6.C6_YEMP     AND 	" + Enter
		cQuery := cQuery +  " 					   SC5.C5_YEMPORI = SC6.C6_YEMPORI  AND 				" + Enter
		cQuery := cQuery +  " 					   SC6.C6_PRODUTO = SB1.B1_COD 		AND 	" + Enter

		If Len(Alltrim(nEmp)) == 4
			cQuery := cQuery +  " 					   SC5.C5_YEMP = '0101'	AND	" + Enter  //DETERMINA A EMPRESA		
		Else
			cQuery := cQuery +  "			 	       SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	AND	" + Enter   //DETERMINA A EMPRESA		
		EndIf	

		cQuery := cQuery +  " 					   SC5.C5_TIPO 	  = 'N' 			AND	" + Enter
		If cSegDe <> "T"	
			cQuery := cQuery +  "			 	       SA1.A1_YTPSEG = '"+cSegDe+"' AND			" + Enter
		EndIf
		cQuery := cQuery +  "	   				   SC5.C5_YLINHA BETWEEN '" + cLinhaI + "' AND '" + cLinhaF + "'   AND 	" + Enter
		cQuery := cQuery +  "				  	   SC5.C5_VEND1  BETWEEN '" + cVendDe + "' AND '" + cVendAte + "'	AND 	" + Enter
		If lFiltra
			cQuery := cQuery +  "					   SC5.C5_VEND1	IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"		" + Enter
			cQuery := cQuery +  "											WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND 	" + Enter
			If cSegDe <> "T"
				cQuery := cQuery +  "												ZZI_TPSEG  =  '"+cSegDe+"'		AND 	" + Enter
			EndIf
			If Alltrim(CATENDENTE) <> ""
				cQuery := cQuery +  "												ZZI_ATENDE = '"+CATENDENTE+"'	AND 		" + Enter
			EndIf 
			cQuery := cQuery +  "											ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"'	AND		" + Enter
			cQuery := cQuery +  "											ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'		AND		" + Enter
			cQuery := cQuery +  "											D_E_L_E_T_ = '') AND 													" + Enter
		EndIf
		cQuery := cQuery +  "				   	   SC6.F4_DUPLIC  = 'S' 			AND 		" + Enter
		cQuery := cQuery +  " 					   SC5.C5_EMISSAO BETWEEN '" + dEmisDe + "' AND '" + dEmisAte + "' AND 	" + Enter
		cQuery := cQuery +  "				   	   SB1.B1_YCLASSE >= '"+cClasDe+"'	AND	" + Enter
		cQuery := cQuery +  "				   	   SB1.B1_YCLASSE <= '"+cClasAte+"'	AND	" + Enter
		cQuery := cQuery +  " 					   SB1.B1_TIPO    = 'PA'  AND SUBSTRING(SB1.B1_COD,1,1) >= 'A' AND B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND 	" + Enter
		cQuery := cQuery +  " 					   SA1.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = ''		" + Enter
		cQuery := cQuery +  " 				 GROUP BY C5_VEND1, A1_YTPSEG) AS EMITI	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = EMITI.C5_VEND1	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = EMITI.A1_YTPSEG	" + Enter

		cQuery := cQuery +  "LEFT JOIN (SELECT F2_VEND1,  A1_YTPSEG, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2 	" + Enter
		cQuery := cQuery +  " 				FROM VW_BIA992_1  				" + Enter
		cQuery := cQuery +  " 				GROUP BY F2_VEND1, A1_YTPSEG) AS ANO	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = ANO.F2_VEND1	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = ANO.A1_YTPSEG	" + Enter
		cQuery := cQuery +  "LEFT JOIN (SELECT F2_VEND1,  A1_YTPSEG, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2 	" + Enter
		cQuery := cQuery +  " 				FROM VW_BIA992_2  				" + Enter
		cQuery := cQuery +  " 				GROUP BY F2_VEND1, A1_YTPSEG) AS TRI	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = TRI.F2_VEND1	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = TRI.A1_YTPSEG	" + Enter
		cQuery := cQuery +  "LEFT JOIN (SELECT F2_VEND1,  A1_YTPSEG, SUM(VLR_IMP) AS VLR_IMP, SUM(VLR_ORI) AS VLR_ORI, AVG(PERC_IMP) PERC_IMP, SUM(D2_QUANT+QUANT_TAB) AS QUANT, SUM((VL_NOR_1+VL_MK_1+VL_TM_1+VL_TAB_1)) AS VL1, SUM((VL_NOR_2+VL_MK_2+VL_TM_2+VL_TAB_2)) AS VL2 	" + Enter
		cQuery := cQuery +  " 				FROM VW_BIA992_3  				" + Enter
		cQuery := cQuery +  " 				GROUP BY F2_VEND1, A1_YTPSEG) AS MES	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = MES.F2_VEND1	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = MES.A1_YTPSEG	" + Enter
		cQuery := cQuery +  "LEFT JOIN (SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR		" + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1	" + Enter
		cQuery := cQuery +  " 				 WHERE ZO_FILIAL    = '" + xFilial("SZO") + "'	AND			" + Enter
		cQuery := cQuery +  "				   A1_FILIAL    = '" + xFilial("SA1") + "'	AND			" + Enter
		cQuery := cQuery +  "				   ZO_CLIENTE	= SA1.A1_COD			AND			" + Enter
		cQuery := cQuery +  "				   ZO_SERIE		BETWEEN '"+cSerieDe+"'	AND '"+cSerieAte+"' AND		" + Enter
		cQuery := cQuery +  "				   ZO_STATUS	= 'Baixa Total'			AND 		" + Enter
		cQuery := cQuery +  "				   ZO_DATA		BETWEEN '"+dtAnoI+"' 	AND '"+dtAnoF+"' 	AND 	" + Enter
		If cSegDe <> "T"	
			cQuery := cQuery +  "				   A1_YTPSEG = '"+cSegDe+"'				AND				" + Enter
		EndIf
		cQuery := cQuery +  "				   SZO.D_E_L_E_T_	= ''				AND			" + Enter
		cQuery := cQuery +  "				   SA1.D_E_L_E_T_	= ''							" + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVANO	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = INVANO.ZO_REPRE	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = INVANO.A1_YTPSEG	" + Enter
		cQuery := cQuery +  "LEFT JOIN (SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR		" + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1			" + Enter
		cQuery := cQuery +  " 				 WHERE ZO_FILIAL    = '" + xFilial("SZO") + "'	AND			" + Enter
		cQuery := cQuery +  "				   A1_FILIAL    = '" + xFilial("SA1") + "'	AND			" + Enter
		cQuery := cQuery +  "				   ZO_CLIENTE	= SA1.A1_COD			AND			" + Enter
		cQuery := cQuery +  "				   ZO_SERIE		BETWEEN '" + cSerieDe + "'	AND '" + cSerieAte + "' AND		" + Enter
		cQuery := cQuery +  "				   ZO_STATUS	= 'Baixa Total'   		AND			" + Enter
		cQuery := cQuery +  "				   ZO_DATA		BETWEEN '" + dtTriI + "' 	AND '" + dtTriF + "'	AND 	" + Enter
		If cSegDe <> "T"	
			cQuery := cQuery +  "				   A1_YTPSEG = '"+cSegDe+"'				AND				" + Enter
		EndIf
		cQuery := cQuery +  "				   SZO.D_E_L_E_T_	= ''				AND			" + Enter
		cQuery := cQuery +  "				   SA1.D_E_L_E_T_	= ''							" + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVTRI	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = INVTRI.ZO_REPRE	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = INVTRI.A1_YTPSEG	" + Enter
		cQuery := cQuery +  "LEFT JOIN (SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR		" + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1			" + Enter
		cQuery := cQuery +  " 				 WHERE ZO_FILIAL    = '" + xFilial("SZO") + "'	AND			" + Enter
		cQuery := cQuery +  "				   A1_FILIAL    = '" + xFilial("SA1") + "'	AND			" + Enter
		cQuery := cQuery +  "				   ZO_CLIENTE	= SA1.A1_COD			AND			" + Enter
		cQuery := cQuery +  "				   ZO_SERIE		BETWEEN '" + cSerieDe + "' 	AND '" + cSerieAte + "' AND		" + Enter
		cQuery := cQuery +  "				   ZO_STATUS	= 'Baixa Total'    		AND 		" + Enter
		cQuery := cQuery +  "				   ZO_DATA		BETWEEN '" + dtAtuI + "' 	AND '" + dtAtuf + "' 	AND		" + Enter
		If cSegDe <> "T"	
			cQuery := cQuery +  "				   A1_YTPSEG = '"+cSegDe+"'				AND				" + Enter
		EndIf
		cQuery := cQuery +  "				   SZO.D_E_L_E_T_	= ''				AND			" + Enter
		cQuery := cQuery +  "				   SA1.D_E_L_E_T_	= ''							" + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVMES	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = INVMES.ZO_REPRE	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = INVMES.A1_YTPSEG	" + Enter
		cQuery := cQuery +  "LEFT JOIN (SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR		" + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1			" + Enter
		cQuery := cQuery +  " 				 WHERE ZO_FILIAL    = '" + xFilial("SZO") + "'	AND			" + Enter
		cQuery := cQuery +  "				   A1_FILIAL    = '" + xFilial("SA1") + "'	AND			" + Enter
		cQuery := cQuery +  "				   ZO_CLIENTE	= SA1.A1_COD			AND			" + Enter
		cQuery := cQuery +  "				   ZO_SERIE		BETWEEN '" + cSerieDe + "' 	AND '" + cSerieAte + "' AND		" + Enter
		cQuery := cQuery +  "				   ZO_FPAGTO	IN ('1','3')			AND			" + Enter
		cQuery := cQuery +  "				   ZO_STATUS	= 'Baixa Total'			AND			" + Enter
		cQuery := cQuery +  "				   ZO_DATA		BETWEEN '" + dtAnoI + "' 	AND '" + dtAnoF + "' 	AND		" + Enter
		If cSegDe <> "T"	
			cQuery := cQuery +  "				   A1_YTPSEG = '"+cSegDe+"'				AND				" + Enter
		EndIf
		cQuery := cQuery +  "				   SZO.D_E_L_E_T_	= ''				AND			" + Enter
		cQuery := cQuery +  "				   SA1.D_E_L_E_T_	= ''							" + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVANOCLI	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = INVANOCLI.ZO_REPRE	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = INVANOCLI.A1_YTPSEG	" + Enter
		cQuery := cQuery +  " 	LEFT JOIN (SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR		" + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1			" + Enter
		cQuery := cQuery +  " 				 WHERE ZO_FILIAL    = '" + xFilial("SZO") + "'	AND			" + Enter
		cQuery := cQuery +  "				   A1_FILIAL    = '" + xFilial("SA1") + "'	AND			" + Enter
		cQuery := cQuery +  "				   ZO_CLIENTE	= SA1.A1_COD			AND			" + Enter
		cQuery := cQuery +  "				   ZO_SERIE		BETWEEN '" + cSerieDe + "' 	AND '" + cSerieAte + "' AND		" + Enter
		cQuery := cQuery +  "				   ZO_FPAGTO	IN ('1','3')			AND			" + Enter
		cQuery := cQuery +  "				   ZO_STATUS	= 'Baixa Total'			AND			" + Enter
		cQuery := cQuery +  "				   ZO_DATA		BETWEEN '" + dtTriI + "' 	AND '" + dtTriF + "' 		AND		" + Enter
		If cSegDe <> "T"	
			cQuery := cQuery +  "				   A1_YTPSEG = '"+cSegDe+"'				AND				" + Enter
		EndIf
		cQuery := cQuery +  "				   SZO.D_E_L_E_T_	= ''				AND			" + Enter
		cQuery := cQuery +  "				   SA1.D_E_L_E_T_	= ''							" + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVTRICLI	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = INVTRICLI.ZO_REPRE	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = INVTRICLI.A1_YTPSEG	" + Enter
		cQuery := cQuery +  "LEFT JOIN (SELECT ZO_REPRE, A1_YTPSEG, SUM(ZO_VALOR) AS VALOR		" + Enter
		cQuery := cQuery +  " 				 FROM " + RetSqlName("SZO") + " SZO, SA1010 SA1			" + Enter
		cQuery := cQuery +  " 				 WHERE ZO_FILIAL    = '" + xFilial("SZO") + "'	AND			" + Enter
		cQuery := cQuery +  "				   A1_FILIAL    = '" + xFilial("SA1") + "'	AND			" + Enter
		cQuery := cQuery +  "				   ZO_CLIENTE	= SA1.A1_COD			AND			" + Enter
		cQuery := cQuery +  "				   ZO_SERIE		BETWEEN '" + cSerieDe + "' 	AND '" + cSerieAte + "' AND		" + Enter
		cQuery := cQuery +  "				   ZO_FPAGTO	IN ('1','3')			AND			" + Enter
		cQuery := cQuery +  "				   ZO_STATUS	= 'Baixa Total'			AND				" + Enter
		cQuery := cQuery +  "				   ZO_DATA		BETWEEN '" + dtAtuI + "' 	AND '" + dtAtuF + "'	AND 	" + Enter
		If cSegDe <> "T"	
			cQuery := cQuery +  "				   A1_YTPSEG = '"+cSegDe+"'				AND				" + Enter
		EndIf
		cQuery := cQuery +  "				   SZO.D_E_L_E_T_	= ''				AND			" + Enter
		cQuery := cQuery +  "				   SA1.D_E_L_E_T_	= ''							" + Enter
		cQuery := cQuery +  " 				 GROUP BY ZO_REPRE, A1_YTPSEG) AS INVMESCLI	" + Enter
		cQuery := cQuery +  " 		ON REP.C5_VEND1 = INVMESCLI.ZO_REPRE	" + Enter
		cQuery := cQuery +  "		AND REP.A1_YTPSEG = INVMESCLI.A1_YTPSEG	" + Enter
		cQuery := cQuery +  " WHERE REP.C5_VEND1	BETWEEN '" + cVendDe + "'	AND '" + cVendAte + "'	" + Enter
		If lFiltra
			cQuery := cQuery +  "		AND REP.C5_VEND1	IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+"		" + Enter
			cQuery := cQuery +  "								WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND 	" + Enter
			If cSegDe <> "T"
				cQuery := cQuery +  "									ZZI_TPSEG  =  '"+cSegDe+"'		AND 	" + Enter
			EndIf
			If Alltrim(CATENDENTE) <> ""
				cQuery := cQuery +  "									ZZI_ATENDE = '"+CATENDENTE+"'	AND 		" + Enter
			EndIf 
			cQuery := cQuery +  "								ZZI_SUPER  >= '"+cSuperDe+"' AND ZZI_SUPER  <= '"+cSuperAte+"'	AND		" + Enter
			cQuery := cQuery +  "								ZZI_GERENT >= '"+cGerDe+"' AND ZZI_GERENT <= '"+cGerAte+"'		AND		" + Enter
			cQuery := cQuery +  "								D_E_L_E_T_ = '')
		EndIf



		//Executa a Query
		TcSQLExec(cQuery)

		cQuery := ""
		cQuery := cQuery +  "ALTER VIEW VW_BIA992 AS																			" + Enter
		If cempant == "01"
			cQuery := cQuery +  "SELECT COD, A1_YTPSEG, 'C' AS BLQ, NOME, TIPO, 												" + Enter 
		Else
			cQuery := cQuery +  "SELECT COD, '' AS A1_YTPSEG, 'C' AS BLQ, NOME, TIPO, 								   			" + Enter 
		EndIf
		cQuery := cQuery +  "		EST = CASE WHEN SUBSTRING(COD,7,1) = 'C' THEN MAX(EST) ELSE '' END, 						" + Enter
		cQuery := cQuery +  "		ISNULL(MAX(ZQ_YVALOR),0) AS META_REPRES,SUM(PEDPEN) AS PEDPEN, SUM(PEDEMIT) AS PEDEMIT, 	" + Enter
		cQuery := cQuery +  "		SUM(QUANT_ANO/"+Alltrim(Str(nMesAno))+") AS QUANT_ANO, SUM(VL1_ANO/"+Alltrim(Str(nMesAno))+") AS VL1_ANO, SUM(VL2_ANO/"+Alltrim(Str(nMesAno))+") AS VL2_ANO, SUM(VL3_ANO/"+Alltrim(Str(nMesAno))+") AS VL3_ANO,  " + Enter
		cQuery := cQuery +  "		SUM(QUANT_TRI/"+Alltrim(Str(nMesTri))+") AS QUANT_TRI, SUM(VL1_TRI/"+Alltrim(Str(nMesTri))+") AS VL1_TRI, SUM(VL2_TRI/"+Alltrim(Str(nMesTri))+") AS VL2_TRI, SUM(VL3_TRI/"+Alltrim(Str(nMesTri))+") AS VL3_TRI,  " + Enter
		cQuery := cQuery +  "		SUM(QUANT_MES/"+Alltrim(Str(nMesMes))+") AS QUANT_MES, SUM(VL1_MES/"+Alltrim(Str(nMesMes))+") AS VL1_MES, SUM(VL2_MES/"+Alltrim(Str(nMesMes))+") AS VL2_MES, SUM(VL3_MES/"+Alltrim(Str(nMesMes))+") AS VL3_MES,  " + Enter
		cQuery := cQuery +  "		"+Alltrim(Str(nMesAno))+" AS ANOMES, "+Alltrim(Str(nMesTri))+" AS TRIMES, "+Alltrim(Str(nMesMes))+" AS MESMES,									" + Enter
		cQuery := cQuery +  "		VL4_MES = CASE																																	" + Enter  
		cQuery := cQuery +  "					WHEN SUM(VLRORI_MES) > 0 THEN ROUND(((SUM(VL4_MES)/(1-SUM(VLRIMP_MES)/SUM(VLRORI_MES)))/"+Alltrim(Str(nMesMes))+"),2) ELSE 0 END,	" + Enter  
		cQuery := cQuery +  "		VL4_TRI = CASE																																	" + Enter  
		cQuery := cQuery +  "					WHEN SUM(VLRORI_TRI) > 0 THEN ROUND(((SUM(VL4_TRI)/(1-SUM(VLRIMP_TRI)/SUM(VLRORI_TRI)))/"+Alltrim(Str(nMesTri))+"),2) ELSE 0 END,	" + Enter  
		cQuery := cQuery +  "		VL4_ANO = CASE																																	" + Enter  
		cQuery := cQuery +  "					WHEN SUM(VLRORI_ANO) > 0 THEN ROUND(((SUM(VL4_ANO)/(1-SUM(VLRIMP_ANO)/SUM(VLRORI_ANO)))/"+Alltrim(Str(nMesAno))+"),2) ELSE 0 END	" + Enter  

		//cQuery := cQuery +  "FROM VW_BIA992_4, " + RetSqlName("SZQ") + " SZQ  " + Enter
		//cQuery := cQuery +  "WHERE 	SZQ.ZQ_YREP		=* A3_COD		AND " + Enter
		//cQuery := cQuery +  "		PEDPEN+PEDEMIT+QUANT_ANO+VL1_ANO+VL2_ANO+VL3_ANO+PERCIMP_ANO+QUANT_TRI+VL1_TRI+VL2_TRI+VL3_TRI+PERCIMP_TRI+QUANT_MES+VL1_MES+VL2_MES+VL3_MES+PERCIMP_MES+VL4_ANO+VL4_TRI+VL4_MES > 0 AND " + Enter
		//If cempant == "01" .And. Dtos(MV_PAR17) >= '20090301' //Biancogres
		//	If cSegDe <> "T"	
		//		cQuery := cQuery +  "		A1_YTPSEG		= '"+cSegDe+"' AND " + Enter          	
		// 		cQuery := cQuery +  "		SZQ.ZQ_YSEGMEN	=* A1_YTPSEG	AND " + Enter          	
		//	Else
		//		cQuery := cQuery +  "		SZQ.ZQ_YSEGMEN	=* A1_YTPSEG	AND " + Enter          	
		//	EndIf
		//Else
		//	cQuery := cQuery +  "		SZQ.ZQ_YSEGMEN	= '1'			AND " + Enter          	
		//EndIf
		//cQuery := cQuery +  "		SZQ.ZQ_YSERIE	BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"' AND "  + Enter
		//cQuery := cQuery +  "		SZQ.ZQ_YMESANO	= '" + MesAno + "' AND	" + Enter
		//cQuery := cQuery +  "		SZQ.D_E_L_E_T_	= ''					" + Enter	
		//If cempant == "01"
		//	cQuery := cQuery +  "GROUP BY COD, A1_YTPSEG, NOME, TIPO		" + Enter
		//Else 
		//	cQuery := cQuery +  "GROUP BY COD, NOME, TIPO					" + Enter	
		//EndIf

		cQuery := cQuery +  "FROM VW_BIA992_4" + Enter
		cQuery := cQuery +  "	LEFT JOIN " + RetSqlName("SZQ") + " SZQ" + Enter
		cQuery := cQuery +  "		ON A3_COD = SZQ.ZQ_YREP" + Enter
		If cempant == "01" .And. Dtos(MV_PAR17) >= '20090301' //Biancogres
			cQuery := cQuery +  "			AND A1_YTPSEG = SZQ.ZQ_YSEGMEN" + Enter
		Else
			cQuery := cQuery +  "			AND SZQ.ZQ_YSEGMEN	= '1'" + Enter          	
		EndIf
		cQuery := cQuery +  "			AND SZQ.ZQ_YSERIE	BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"'" + Enter
		cQuery := cQuery +  "			AND SZQ.ZQ_YMESANO	= '" + MesAno + "'" + Enter
		cQuery := cQuery +  "			AND SZQ.D_E_L_E_T_	= ''" + Enter
		cQuery := cQuery +  "WHERE PEDPEN+PEDEMIT+QUANT_ANO+VL1_ANO+VL2_ANO+VL3_ANO+PERCIMP_ANO+QUANT_TRI+VL1_TRI+VL2_TRI+VL3_TRI+PERCIMP_TRI+QUANT_MES+VL1_MES+VL2_MES+VL3_MES+PERCIMP_MES+VL4_ANO+VL4_TRI+VL4_MES > 0" + Enter
		If cempant == "01" .And. Dtos(MV_PAR17) >= '20090301' //Biancogres
			If cSegDe <> "T"	
				cQuery := cQuery +  "		AND A1_YTPSEG = '"+cSegDe+"'" + Enter     	
			EndIf
		EndIf
		If cempant == "01"
			cQuery := cQuery +  "GROUP BY COD, A1_YTPSEG, NOME, TIPO" + Enter
		Else
			cQuery := cQuery +  "GROUP BY COD, NOME, TIPO" + Enter
		EndIf


		TcSQLExec(cQuery)
	EndIf


	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Se impressao em disco, chama o gerenciador de impressao...          ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If aReturn[5]==1
		//Parametros Crystal Em Disco
		Private x:="1;0;1;Ranking"
	Else
		//Direto Impressora
		Private x:="3;0;1;Ranking"
	Endif

	//Chama o Relatorio em Crystal
	callcrys("BIA992",cSerieDe+";"+cSerieAte+";"+cVendDe+";"+cVendAte+";"+cCliDe+";"+cCliAte+";"+Alltrim(Str(cOrdem))+";"+CESTDE+";"+CESTATE+";"+cSuperDe+";"+cSuperAte+ ";"+ DTOC(MV_PAR12)+ ";"+ DTOC(MV_PAR13)+ ";"+ DTOC(MV_PAR14)+ ";"+ DTOC(MV_PAR15)+ ";"+ DTOC(MV_PAR16)+ ";"+ DTOC(MV_PAR17)+ ";"+ Alltrim(MV_PAR18)+ ";"+ Alltrim(MV_PAR19)+ ";"+Alltrim(MV_PAR20)+";"+Alltrim(Str(MV_PAR21))+";"+cGerDe+";"+cGerAte,x)

Return