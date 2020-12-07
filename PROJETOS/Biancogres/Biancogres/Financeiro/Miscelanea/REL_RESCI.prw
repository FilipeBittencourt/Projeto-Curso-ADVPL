#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} REL_RESCI
@author Bruno Madaleno
@since 08/01/10
@version 1.0
@description Relatório de Rescisão do Representante
@history 06/03/2018, Ranisses A. Corona, Ticket 2877 - Verificacao de valores duplicados / Barra progressão durante geração do relatorio
@history 14/08/2019, Jussara Nóbrega, Ticket 17294 - Retirado o filtro para não filtrar as comissoes dos vendedores por marca
@type function
/*/

USER FUNCTION REL_RESCI()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local I
	Private cSQL
	Private Enter		:= CHR(13)+CHR(10) 
	PRIVATE nLastKey    := 0
	Private lFiltra		:= .F. //Define se irá filtras os registros na tabela SE1 e SE3 por Marca
	Private cMarca		:= ""  //Marca de acordo com o parametro MV_PAR04 e a variavel cEmpAnt

	lEnd       := .F.
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "RESCISAO REPRESENTANTE"
	cTamanho   := ""
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "REL_RESCI"              
	cPerg      := "REL_RESCI"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "RESCISAO REPRESENTANTE"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := ""
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t. 
	nDescrObs  := ""
	nVlrObs	   := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.								     ³
	//³ Verifica Posicao do Formulario na Impressora.				             ³
	//³ Solicita os parametros para a emissao do relatorio			             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PERGUNTE("REL_RESCI",.F.)
	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
	//Cancela a impressao
	if (nLastKey == 27) .OR. (LastKey() == 27)
		Return
	endif


	//BUSCANDO A OBSERVACAO 1
	//@ 000,000 TO 150,350 DIALOG oDialog TITLE "Selecao"
	//@ 005,005 SAY "Digite abaixo separando por ; cada classe de valor:"
	//@ 020,005 GET cCLVL SIZE 130,050 MEMO
	//@ 060,140 BMPBUTTON TYPE BT_OK ACTION fFinaliza()
	//ACTIVATE DIALOG oDialog CENTERED
	//IF len(aCLVL) == 0
	//	cCLVL := "''"
	//ENDIF

	//MV_PAR01 - DEMITIDO (SIM/NAO) / DEFINE SE SERA REALIZADO CALCULO DE 1/12 AVOS SOMENTE NO RELATORIO - QUADRO 2
	//MV_PAR02 - 
	//MV_PAR03 - 
	//MV_PAR04 - CÓDIGO DO VENDEDOR 
	//MV_PAR05 - TIPO (PROVISÃO / RESCISÃO)
	//MV_PAR06 - AVISO PREVIO (SIM / NÃO) QUADRO 1 
	//MV_PAR07 - OSBSERVACAO CAMPO 8
	//MV_PAR08 - VALOR CAMPO 8


	//Verifica se ja foi realizado a rescisao do Representante
	Z78->(DbSetOrder(2))

	If Z78->(DbSeek(xFilial("Z78")+MV_PAR04+MV_PAR09)) .And. MV_PAR05 <> 1
		MsgBox("A rescisão do Representante " + MV_PAR04 + IIf(!Empty(Z78->Z78_MARCA),", para a Marca "+Z78->Z78_MARCA+",","") + " foi realizada no dia "+DTOC(Z78->Z78_DTRESC)+". Este relatório somente poderá ser emitido utilizando o Tipo = RESCISÃO!","REL_RESCI","STOP")
		Return
	EndIf

	If !Z78->(DbSeek(xFilial("Z78")+MV_PAR04+MV_PAR09)) .And. MV_PAR05 == 1
		MsgBox("A rescisão do Representante " + MV_PAR04 + IIf(!Empty(MV_PAR09),", para a Marca "+MV_PAR09+",","") + " ainda não foi realizada. Este relatório somente poderá ser emitido utilizando o Tipo = PROVISÃO!","REL_RESCI","STOP")
		Return
	EndIf

	//CARREGA PARAMETROS / ALIMENTA VARIAVEIS
	If MV_PAR01 == 1 
		DEMITIDO := "SIM"
	Else
		DEMITIDO := "NAO"
	EndIf

	//Bloqueia o uso da Marca nas empresas Biancogres, Incesa e Vitcer
	If cEmpAnt $ "01_05_14" .And. !Empty(Alltrim(MV_PAR09))
		MsgBox("O parâmetro MARCA não pode ser utilizado nesta empresa!","RES_REPRE","STOP")	
		Return()
	EndIf

	//Para Empresa LM, pode realizar a pesquisa/filtro por Marca
	If cEmpAnt == "07"

		lFiltra := .F.	

		// Tiago Rossini Coradini - 07-02-2017 - Adcionado tratamento para prefixo 9 - Comissão variavel
		If MV_PAR09 == "0101"
			cMarca += "1/9/01"
		ElseIf MV_PAR09 == "0501"
			cMarca := "2/9"
		ElseIf MV_PAR09 == "0599"
			cMarca := "3/9"
		ElseIf MV_PAR09 == "1399"
			cMarca := "4/9"
		ElseIf MV_PAR09 == "    "	
			cMarca := "1/2/3/4/9"
		Else
			MsgAlert("Esta Marca não possui faturamento nesta empresa!")
			Return()
		EndIf	

	EndIf

	If MV_PAR05 == 1
		//Z78->(DbSetOrder(1))
		Z78->(DbSetOrder(2))
		If Z78->(DbSeek(xFilial("Z78")+MV_PAR04+MV_PAR09))
			nDescrObs	:= Z78->Z78_OBS
			nVlrObs		:= Z78->Z78_VALOR
		EndIf
	Else
		nDescrObs	:= MV_PAR07
		nVlrObs		:= MV_PAR08
	EndIf

	// COMISSõES PAGAS NOS UMTIMOS 3 MESSES
	If MV_PAR06 == 1
		FOR I:=0 TO 3
			Qtmeses := STR(I*-1)
			cSQL := " -- COMISSOES PAGAS 															" + Enter
			cSQL += " ALTER VIEW VW_COMIS_COMISSOES_PAGAS_0"+ALLTRIM(STR(I))+" AS  					" + Enter
			cSQL += " SELECT	A1_COD, A1_NOME, E3_YVENDRC, E3_EMISSAO, E3_BASE, E3_PORC, E3_COMIS	" + Enter
			cSQL += " FROM "+RETSQLNAME("SE3")+" SE3 WITH (NOLOCK) INNER JOIN "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) ON " + Enter
			cSQL += " 		E3_CODCLI = A1_COD AND		" + Enter
			cSQL += " 		E3_LOJA = A1_LOJA 		 	" + Enter				
			cSQL += " WHERE	E3_FILIAL	= '"+xFilial("SE3")+"'	AND " + Enter 
			cSQL += "		E3_VEND 	= '"+MV_PAR04+"' 		AND " + Enter
			If lFiltra
				cSQL += "		E3_PREFIXO IN ("+ U_MontaSQLIN(cMarca, '/', 3)+")			AND  " + Enter
			EndIf
			cSQL += " 		SUBSTRING(E3_DATA,1,6) = SUBSTRING(CONVERT(VARCHAR(13),DATEADD(MONTH,"+Qtmeses+",GETDATE()),112),1,6) AND	" + Enter
			cSQL += " 		SE3.D_E_L_E_T_ = '' AND	" + Enter
			cSQL += " 		SA1.D_E_L_E_T_ = '' 	" + Enter
			//TcSQLExec(cSQL)
			//I := I+1
			U_BIAMsgRun("Gerando Base... Comissões Pagas nos ultimos 3 meses...",,{|| TcSQLExec(cSql)})				
		NEXT
	EndIf

	//COMISSAO PEDIDOS EM CARTEIRA
	IF MV_PAR05 == 1
		For I := 1 to 5
			If I == 1
				cSQL := " ALTER VIEW VW_COMIS_MAPA_DE_PEDIDOS AS  " + Enter
			End
			cSQL += " SELECT A1_COD, A1_NOME, C5_NUM, C5_EMISSAO, C6_PRODUTO, C6_DESCRI, C6_PRCVEN,  ((C6_QTDVEN-C6_QTDENT) * C6_PRCVEN) AS SALDO,  " + Enter
			If I == 1
				cSQL += " 		C6_YPCREC AS C6_COMIS1, C6_YVLCREC AS VAL_COMI " + Enter
			Else
				cSQL += " 		C6_YPCREC"+ALLTRIM(STR(I))+" AS C6_COMIS1, C6_YVLCRE"+ALLTRIM(STR(I))+" AS VAL_COMI " + Enter
			EndIf
			cSQL += " FROM "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK)					" + Enter
			cSQL += "		INNER JOIN "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) ON	" + Enter 
			cSQL += "		SC5.C5_NUM		= SC6.C6_NUM 							" + Enter		
			cSQL += "       INNER JOIN "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) ON	" + Enter 
			cSQL += " 		SC5.C5_CLIENTE	= SA1.A1_COD 	AND						" + Enter
			cSQL += " 		SC5.C5_LOJACLI	= SA1.A1_LOJA							" + Enter   
			cSQL += "		INNER JOIN "+RETSQLNAME("SF4")+" SF4 WITH (NOLOCK) ON	" + Enter 
			cSQL += "		SC6.C6_TES		= SF4.F4_CODIGO							" + Enter					
			cSQL += " WHERE SC5.C5_FILIAL	= '"+xFilial("SC5")+"'	AND 			" + Enter
			cSQL += "		SC6.C6_FILIAL	= '"+xFilial("SC6")+"'	AND 			" + Enter	
			If I == 1
				cSQL += " 	    SC6.C6_YVENDRC = '"+MV_PAR04+"' AND " + Enter
			Else
				cSQL += " 	    SC6.C6_YVENDR"+ALLTRIM(STR(I))+" = '"+MV_PAR04+"' AND " + Enter
			EndIf
			If lFiltra
				cSQL += "		SC5.C5_YEMP	   = '"+MV_PAR09+"' AND " + ENTER 
			EndIf
			cSQL += "		SF4.F4_DUPLIC  = 'S' 			AND " + Enter
			cSQL += " 		SC6.D_E_L_E_T_ = '' 			AND " + Enter
			cSQL += " 		SC5.D_E_L_E_T_ = '' 			AND " + Enter
			cSQL += " 		SA1.D_E_L_E_T_ = '' 			AND " + Enter
			cSQL += " 		SF4.D_E_L_E_T_ = '' 				" + Enter		
			If I <> 5 
				cSQL += " UNION ALL									" + Enter
			EndIf
		Next
	Else
		For I := 1 to 5
			If I == 1
				cSQL := " ALTER VIEW VW_COMIS_MAPA_DE_PEDIDOS AS  " + Enter
			End
			cSQL += " SELECT A1_COD, A1_NOME, C5_NUM, C5_EMISSAO, C6_PRODUTO, C6_DESCRI, C6_PRCVEN,  ((C6_QTDVEN-C6_QTDENT) * C6_PRCVEN) AS SALDO,  " + Enter
			cSQL += " 		C6_COMIS"+ALLTRIM(STR(I))+", ((((C6_QTDVEN-C6_QTDENT) * C6_PRCVEN) / 100)*C6_COMIS"+ALLTRIM(STR(I))+") VAL_COMI " + Enter
			cSQL += " FROM "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK)					" + Enter
			cSQL += "		INNER JOIN "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) ON	" + Enter 
			cSQL += "		SC5.C5_NUM		= SC6.C6_NUM 							" + Enter		
			cSQL += "       INNER JOIN "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) ON	" + Enter 
			cSQL += " 		SC5.C5_CLIENTE	= SA1.A1_COD 	AND						" + Enter
			cSQL += " 		SC5.C5_LOJACLI	= SA1.A1_LOJA							" + Enter   
			cSQL += "		INNER JOIN "+RETSQLNAME("SF4")+" SF4 WITH (NOLOCK) ON	" + Enter 
			cSQL += "		SC6.C6_TES		= SF4.F4_CODIGO							" + Enter							
			cSQL += " WHERE SC5.C5_FILIAL	= '"+xFilial("SC5")+"'	AND " + Enter
			cSQL += "		SC6.C6_FILIAL	= '"+xFilial("SC6")+"'	AND " + Enter	
			cSQL += " 	    SC5.C5_VEND"+ALLTRIM(STR(I))+" = '"+MV_PAR04+"' 	AND " + Enter
			If lFiltra
				cSQL += "		SC5.C5_YEMP	   = '"+MV_PAR09+"' AND " + Enter 
			EndIf		
			cSQL += "		SC6.C6_QTDVEN-SC6.C6_QTDENT > 0	AND " + Enter
			cSQL += "		SC6.C6_BLQ <> 'R' 				AND " + Enter
			cSQL += "		SF4.F4_DUPLIC  = 'S' 			AND " + Enter
			cSQL += " 		SC6.D_E_L_E_T_ = '' 			AND " + Enter
			cSQL += " 		SC5.D_E_L_E_T_ = '' 			AND " + Enter
			cSQL += " 		SA1.D_E_L_E_T_ = '' 			AND " + Enter
			cSQL += " 		SF4.D_E_L_E_T_ = '' 				" + Enter
			If I <> 5 
				cSQL += " UNION ALL									" + Enter
			EndIf
		Next
	EndIf
	//TcSQLExec(cSQL)
	U_BIAMsgRun("Gerando Base... Pedidos em Carteira...",,{|| TcSQLExec(cSql)})

	//Limpa tabela com os Titulos a Receber
	TcSqlExec("DELETE FROM TMP_REL_RESCI_TITULOS_VENCER")

	//Seleciona os Títulos em Aberto do Vendedor
	If MV_PAR05 == 1
		For I := 1 to 5
			cSQL := " SELECT SE1.R_E_C_N_O_, A1_COD, A1_NOME, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_SALDO, E1_VENCTO, 0 BASE_COMIS, 0 AS PERC_COMIS, 0 AS VL_COMIS,  " + Enter		
			If I == 1
				cSQL += " 		E1_YPCREC AS E1_COMIS1, E1_YVLCREC AS VALOR_COMIS " + Enter
			Else
				cSQL += " 		E1_YPCREC"+ALLTRIM(STR(I))+" AS E1_COMIS1, E1_YVLCRE"+ALLTRIM(STR(I))+" AS VALOR_COMIS " + Enter
			EndIf
			cSQL += " FROM "+RETSQLNAME("SE1")+" SE1 WITH (NOLOCK) INNER JOIN "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) ON " + Enter
			cSQL += " 		SE1.E1_CLIENTE	= 	A1_COD	AND " + Enter
			cSQL += " 		SE1.E1_LOJA 	= 	A1_LOJA		" + Enter    			
			cSQL += " WHERE SA1.A1_FILIAL =  '"+xFilial("SA1")+"' AND " + Enter
			cSQL += "		SE1.E1_FILIAL =  '"+xFilial("SE1")+"' AND " + Enter
			If I == 1
				cSQL += " 	    SE1.E1_YVENDRC	= '"+MV_PAR04+"' AND " + Enter
			Else	
				cSQL += " 	    SE1.E1_YVENDR"+ALLTRIM(STR(I))+" = '"+MV_PAR04+"' AND " + Enter
			EndIf
			If lFiltra
				cSQL += "	   	SE1.E1_PREFIXO IN ("+ U_MontaSQLIN(cMarca, '/', 3)+")	AND  " + Enter
			EndIf
			cSQL += " 		SE1.E1_TIPO 	NOT IN ('RA','BOL') AND " + Enter
			cSQL += " 		SE1.D_E_L_E_T_ 	= 	'' 		AND " + Enter
			cSQL += " 		SA1.D_E_L_E_T_ 	=	''			" + Enter
			If chkfile("_SE1")
				dbSelectArea("_SE1")
				dbCloseArea()
			EndIf
			TcQuery cSQL ALIAS "_SE1" NEW
			dbSelectArea("_SE1")
			dbGoTop()

			//Grava Titulo a Receber - FOI IMPLEMENTADO PARA EXIBIR MENSAGEM DURANTE A GERAÇÃO DO RELATORIO
			U_BIAMsgRun("Gerando Base... Titulos em Aberto...",,{|| fGrvTit(I) })

		Next
	Else
		For I := 1 to 5
			cSQL := " SELECT SE1.R_E_C_N_O_, A1_COD, A1_NOME, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_SALDO, E1_VENCTO, 0 BASE_COMIS, 0 AS PERC_COMIS, 0 AS VL_COMIS,  " + Enter
			cSQL += " 		 E1_COMIS"+ALLTRIM(STR(I))+", ((E1_SALDO/100)*E1_COMIS"+ALLTRIM(STR(I))+") AS VALOR_COMIS " + Enter
			cSQL += " FROM "+RETSQLNAME("SE1")+" SE1 WITH (NOLOCK) INNER JOIN "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) ON " + Enter
			cSQL += " 		SE1.E1_CLIENTE	= 	A1_COD	AND " + Enter
			cSQL += " 		SE1.E1_LOJA 	= 	A1_LOJA		" + Enter    					
			cSQL += " WHERE SA1.A1_FILIAL =  '"+xFilial("SA1")+"' AND " + Enter
			cSQL += "		SE1.E1_FILIAL =  '"+xFilial("SE1")+"' AND " + Enter
			cSQL += " 	    SE1.E1_VEND"+ALLTRIM(STR(I))+" = '"+MV_PAR04+"' AND " + Enter
			If lFiltra
				cSQL += "	   	SE1.E1_PREFIXO IN ("+ U_MontaSQLIN(cMarca, '/', 3)+")		AND  " + ENTER
			EndIf
			cSQL += " 		SE1.E1_SALDO 	> 	0 			 AND " + Enter
			cSQL += "		SA1.A1_YCALCCM  <> 'N'			 AND " + Enter	
			cSQL += " 		SE1.E1_TIPO 	NOT IN ('RA','BOL') AND " + Enter
			cSQL += " 		SE1.D_E_L_E_T_ 	= 	'' 		AND " + Enter
			cSQL += " 		SA1.D_E_L_E_T_ 	=	''			" + Enter		
			If chkfile("_SE1")
				dbSelectArea("_SE1")
				dbCloseArea()
			EndIf		
			TcQuery cSQL ALIAS "_SE1" NEW
			dbSelectArea("_SE1")
			dbGoTop()

			//Grava Titulo a Receber - FOI IMPLEMENTADO PARA EXIBIR MENSAGEM DURANTE A GERAÇÃO DO RELATORIO
			U_BIAMsgRun("Gerando Base... Titulos em Aberto...",,{|| fGrvTit(I) })	

		Next
	EndIf

	// TITULOS A VENCER
	cSQL := " ALTER VIEW VW_COMIS_TITULOS_VENCER AS			" + Enter
	cSQL += " SELECT A1_COD, A1_NOME, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_SALDO, E1_VENCTO, BASE_COMIS, PERC_COMIS, VL_COMIS, E1_COMIS1, VALOR_COMIS " + Enter
	cSQL += " FROM TMP_REL_RESCI_TITULOS_VENCER 			" + Enter
	TcSQLExec(cSQL)

	// COMISSOES A PAGAR
	cSQL := " ALTER VIEW VW_COMIS_COMISSOES_PAGAR AS  				" + Enter
	cSQL += " SELECT	A1_COD, A1_NOME, E3_YVENDRC, E3_EMISSAO,  	" + Enter
	IF MV_PAR05 == 1
		cSQL += " 		E3_BASE, E3_YPCREC AS E3_PORC, E3_YVLCREC AS E3_COMIS " + Enter
	ELSE
		cSQL += " 		E3_BASE, E3_PORC, E3_COMIS 					" + Enter
	ENDIF
	cSQL += " FROM "+RETSQLNAME("SE3")+" SE3 WITH (NOLOCK) INNER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON " + Enter
	cSQL += " 		SE3.E3_CODCLI	= SA1.A1_COD 	AND " + Enter
	cSQL += " 		SE3.E3_LOJA		= SA1.A1_LOJA		" + Enter
	cSQL += " WHERE	E3_FILIAL	= '"+xFilial("SE3")+"'	AND " + Enter
	IF MV_PAR05 == 1
		cSQL += " 		E3_YVENDRC	= '"+MV_PAR04+"'		AND " + Enter
	ELSE
		cSQL += " 		E3_VEND 	= '"+MV_PAR04+"' 		AND " + Enter
		cSQL += " 		E3_DATA 	= '' 					AND " + Enter
	ENDIF
	If lFiltra
		cSQL += "		E3_PREFIXO IN ("+ U_MontaSQLIN(cMarca, '/', 3)+")			AND  " + Enter
	EndIf
	cSQL += " 		SE3.D_E_L_E_T_	= '' 			AND " + Enter
	cSQL += " 		SA1.D_E_L_E_T_	= '' 				" + Enter
	//TcSQLExec(cSQL)
	U_BIAMsgRun("Gerando Base... Comissões a Pagar...",,{|| TcSQLExec(cSql)})


	cSQL := "ALTER VIEW VW_COMIS_CAPA AS " + Enter
	cSQL += "SELECT	MAX(A3_COD) AS A3_COD, MAX(A3_NOME) AS A3_NOME, MAX(A3_MUN) AS A3_MUN, " + Enter
	cSQL += "		SUM(VALOR_COMIS_TITULO) AS VALOR_COMIS_TITULO, " + Enter
	cSQL += "		SUM(VAL_COMI_PEDIDOS) AS VAL_COMI_PEDIDOS, " + Enter
	cSQL += "		SUM(VALOR_COMIS_PAGAR) AS VALOR_COMIS_PAGAR, " + Enter
	IF (MV_PAR06 == 1)
		cSQL += "		SUM(MES_ANTE_01) AS MES_ANTE_01, " + Enter
		cSQL += "		SUM(MES_ANTE_02) AS MES_ANTE_02, " + Enter
		cSQL += "		SUM(MES_ANTE_03) AS MES_ANTE_03, " + Enter
	ELSE
		cSQL += "		0 AS MES_ANTE_01, " + Enter
		cSQL += "		0 AS MES_ANTE_02, " + Enter
		cSQL += "		0 AS MES_ANTE_03, " + Enter
	ENDIF                          
	cSQL += "		SUM(COMIS_PAGAS) AS COMIS_PAGAS, " + Enter

	cSQL += "		(CASE '" + cEmpAnt + "' WHEN '07' THEN " + Enter
	cSQL += "			(CASE '" + MV_PAR09 + "' WHEN '0101' THEN " + Enter
	cSQL += "					'LM/BIANCOGRES' " + Enter
	cSQL += "				WHEN '0501' THEN " + Enter
	cSQL += "					'LM/INCESA' " + Enter
	cSQL += "				WHEN '0599' THEN " + Enter
	cSQL += "					'LM/BELLACASA' " + Enter
	cSQL += "				WHEN '1399' THEN " + Enter
	cSQL += "					'LM/MUNDIALLI' " + Enter
	cSQL += "				ELSE '- / -' END) " + Enter
	cSQL += "			WHEN '01' THEN " + Enter
	cSQL += "				'BIANCOGRES/ -' " + Enter
	cSQL += "			WHEN '05' THEN " + Enter
	cSQL += "				'INCESA/ -' " + Enter
	cSQL += "			WHEN '13' THEN " + Enter
	cSQL += "				'MUNDI/ -' " + Enter
	cSQL += "			ELSE '- / -' END) AS EMP_MARCA " + Enter

	cSQL += "FROM " + Enter
	cSQL += "( " + Enter
	cSQL += "-- REPRESENTANTES " + Enter
	cSQL += "SELECT	A3_COD, A3_NOME, A3_MUN,0 AS VAL_COMI_PEDIDOS, 0 AS VALOR_COMIS_TITULO, 0 AS VALOR_COMIS_PAGAR, 0 AS MES_ANTE_01, 0 AS MES_ANTE_02, 0 AS MES_ANTE_03, 0  AS COMIS_PAGAS " + Enter
	cSQL += "FROM SA3010 " + Enter
	cSQL += "WHERE A3_COD = '"+MV_PAR04+"' AND D_E_L_E_T_ = '' " + Enter
	cSQL += "UNION ALL " + Enter
	cSQL += "-- PEDIDOS NÃO ATENDIDOS " + Enter
	cSQL += "SELECT	'' AS A, '' AS B, '' AS C, SUM(VAL_COMI) VAL_COMI_PEDIDOS, 0 AS VALOR_COMIS_TITULO, 0 AS VALOR_COMIS_PAGAR, 0 AS A01, 0 AS A02, 0 AS A03, 0 AS COMIS_PAGAS " + Enter
	cSQL += "FROM VW_COMIS_MAPA_DE_PEDIDOS " + Enter
	cSQL += "-- TITULOS A RECEBER " + Enter
	cSQL += "UNION ALL " + Enter
	cSQL += "SELECT	'' AS A, '' AS B, '' AS C,0 AS VAL_COMI_PEDIDOS, SUM(VALOR_COMIS) VALOR_COMIS_TITULO, 0 AS VALOR_COMIS_PAGAR, 0 AS A01, 0 AS A02, 0 AS A03, 0 AS COMIS_PAGAS " + Enter
	cSQL += "FROM VW_COMIS_TITULOS_VENCER " + Enter
	cSQL += "-- COMISSOES A PAGAR " + Enter
	cSQL += "UNION ALL " + Enter
	cSQL += "SELECT	'' AS A, '' AS B, '' AS C, 0 AS VAL_COMI_PEDIDOS, 0 AS VALOR_COMIS_TITULO, SUM(E3_COMIS) AS VALOR_COMIS_PAGAR, 0 AS A01, 0 AS A02, 0 AS A03, 0 AS COMIS_PAGAS " + Enter
	cSQL += "FROM VW_COMIS_COMISSOES_PAGAR " + Enter
	cSQL += "-- COMISSAO PAGAS MESSES ANTERIORES " + Enter
	cSQL += "UNION ALL " + Enter
	If (MV_PAR06 == 1)
		cSQL += "SELECT '' AS BB1,'' AS BB2,'' AS BB3, '' AS BB4,0 AS BBB, 0 AS BB, SUM(E3_COMIS) AS MES_ANTE_01, 0 AS B8, 0 AS B9, 0 AS COMIS_PAGAS " + Enter
		cSQL += "FROM VW_COMIS_COMISSOES_PAGAS_01 " + Enter
		cSQL += "UNION ALL " + Enter
		cSQL += "SELECT '' AS BB1,'' AS BB2,'' AS BB3, '' AS BB4,0 AS BBB, 0 AS BB, 0 AS B6,SUM(E3_COMIS) AS MES_ANTE_02, 0 AS B10, 0 AS COMIS_PAGAS " + Enter
		cSQL += "FROM VW_COMIS_COMISSOES_PAGAS_02 " + Enter
		cSQL += "UNION ALL " + Enter
		cSQL += "SELECT '' AS BB1,'' AS BB2,'' AS BB3, '' AS BB4,0 AS BBB, 0 AS BB, 0 AS B7, 0 AS B8, SUM(E3_COMIS) AS MES_ANTE_03, 0 AS COMIS_PAGAS " + Enter
		cSQL += "FROM VW_COMIS_COMISSOES_PAGAS_03 " + Enter
		cSQL += "UNION ALL " + Enter
	EndIf
	cSQL += "-- TODAS AS COMISSÕES PAGAS ATE HOJE " + Enter
	cSQL += "SELECT	'' AS BB1,'' AS BB2,'' AS BB3, '' AS BB4,0 AS BBB, 0 AS BB, 0 AS B7, 0 AS B8, 0 AS MES_ANTE_03, SUM(E3_COMIS) AS COMIS_PAGAS " + Enter
	cSQL += "FROM  "+RETSQLNAME("SE3")+" WITH (NOLOCK) " + Enter
	cSQL += "WHERE	E3_FILIAL	= '"+xFilial("SE3")+"'	AND " + Enter
	cSQL += "		E3_VEND 	= '"+MV_PAR04+"' 		AND " + Enter
	cSQL += "		E3_DATA 	<> '' 					AND " + Enter
	If lFiltra
		cSQL += "		E3_PREFIXO IN ("+ U_MontaSQLIN(cMarca, '/', 3)+")			AND  " + Enter
	EndIf
	cSQL += "		D_E_L_E_T_ = '' " + Enter
	cSQL += ") AS SS " + Enter
	TcSQLExec(cSQL)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5]==1
		//Parametros Crystal Em Disco
		Private cOpcao:="1;0;1;Apuracao"
	Else
		//Direto Impressora
		Private cOpcao:="3;0;1;Apuracao"
	Endif

	callcrys("RESC_REP",cEmpant+";"+(DEMITIDO)+";"+ALLTRIM(STR(MV_PAR03))+";"+ALLTRIM(STR(MV_PAR02))+";"+ALLTRIM(nDescrObs)+";"+ALLTRIM(STR(nVlrObs)),cOpcao)

RETURN()

//------------------------------------------------------------------------------------------------------------------------------------
//Função para Calculo e Gravação dos Títulos a Receber com Comissão
Static Function fGrvTit(I)

	If MV_PAR05 == 1 		
		//Grava tabela temporaria
		While !_SE1->(EOF())
			nBase	:= Alltrim(Str(0))
			nPerc 	:= Alltrim(Str(_SE1->E1_COMIS1))
			nValCom	:= Alltrim(Str(_SE1->VALOR_COMIS))
			cSQL 	:= "INSERT INTO TMP_REL_RESCI_TITULOS_VENCER VALUES ('"+_SE1->A1_COD+"','"+STRTRAN(_SE1->A1_NOME,"'","")+"','','"+_SE1->E1_PREFIXO+"','"+_SE1->E1_NUM+"','"+_SE1->E1_PARCELA+"','"+_SE1->E1_TIPO+"','"+_SE1->E1_VENCTO+"',"+Alltrim(Str(_SE1->E1_SALDO))+","+nBase+","+nPerc+","+nValCom+","+nPerc+","+nPerc+","+nValCom+")"
			TcSqlExec(cSQL)
			_SE1->(dbSkip())
		End
	Else
		//Utiliza funcao padrao para calcular a comissão e gravar os titulos
		While !_SE1->(EOF())		
			dbSelectArea("SE1")
			dbGoTo(_SE1->R_E_C_N_O_)
			aBases	:= U_fCalcComiss(SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,I)
			If SE1->E1_SALDO == SE1->E1_VALOR
				nBase	:= Alltrim(Str(aBases[1]))
				nPerc 	:= Alltrim(Str(aBases[2]/aBases[1]*100))
				nValCom	:= Alltrim(Str(aBases[2]))
			Else
				nBase	:= Alltrim(Str(SE1->E1_SALDO))
				nPerc 	:= Alltrim(Str(aBases[2]/aBases[1]*100))
				nValCom	:= Alltrim(Str(Round((SE1->E1_SALDO*(aBases[2]/aBases[1]*100)/100),2)))
			EndIf
			cSQL 	:= "INSERT INTO TMP_REL_RESCI_TITULOS_VENCER VALUES ('"+_SE1->A1_COD+"','"+STRTRAN(_SE1->A1_NOME,"'","")+"','','"+_SE1->E1_PREFIXO+"','"+_SE1->E1_NUM+"','"+_SE1->E1_PARCELA+"','"+_SE1->E1_TIPO+"','"+_SE1->E1_VENCTO+"',"+Alltrim(Str(_SE1->E1_SALDO))+","+nBase+","+nPerc+","+nValCom+","+nPerc+","+nPerc+","+nValCom+")"
			TcSqlExec(cSQL)
			_SE1->(dbSkip())
		End
	EndIf

Return()

//------------------------------------------------------------------------------------------------------------------------------------
User Function MT130HED()
	Local aHead := {}

	aadd(aHead,{'Estado','A2_EST'   ,'@!',02,0,''              ,' ','C',' ',' ' })
	aadd(aHead,{'Endereço','A2_END'   ,'@!',14,0,''              ,' ','C',' ',' ' })

Return(aHead)

//------------------------------------------------------------------------------------------------------------------------------------
User Function MT130COL()
	Local aColsU := {}
	aadd(aColsU,SA2->A2_EST)
	aadd(aColsU,SA2->A2_END)

Return(aColsU)