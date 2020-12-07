#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PESOS          ºAutor  ³ HARLEY DIAS KOEHLERº Data ³  13/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ COMPARATIVO DE PESOS = ENTRADAS X SAIDAS                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PESOS()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	cNomeprog  := "PESOS"
	cPerg      := "PESOS"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Comparativo de Pesos - Entradas x Saidas  "
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1
	wnrel      := "PESOS"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t.


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria parametros se nao existir e chama os parametros na tela           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ValidPerg()

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


	cSql := ""
	cSql += "ALTER VIEW VW_PESOS AS " + Enter
	cSql += "SELECT DATA, SUM(PESO_SAIDA) PESO_SAIDA, SUM(PESO_ENTRADA) PESO_ENTRADA, SUM(PESO_REQUIS) PESO_REQUIS, SUM(PESO_ENTRADA-PESO_SAIDA) DIF_ES, " + Enter
	cSql += "				SUM(PESO_REQUIS-PESO_SAIDA) DIF_RS,	'' GRUPO, '' UNID, '' TM " + Enter
	cSql += "FROM (									" + Enter
	cSql += "--VENDAS " + Enter
	cSql += "SELECT	SUBSTRING(D2_EMISSAO,1,6) AS DATA, " + Enter
	cSql += "		D2_GRUPO AS GRUPO,	" + Enter
	cSql += "		B1_UM AS UNID, 		" + Enter
	cSql += "		PESO_SAIDA = CASE	" + Enter
	cSql += "						WHEN MAX(D2_COD) = '1010148' THEN ROUND(SUM(D2_QUANT*1000),2)	" + Enter
	cSql += "						WHEN B1_UM = 'M2' THEN ROUND(SUM(D2_QUANT*D2_PESO),2)	" + Enter
	cSql += "						WHEN B1_UM = 'PC' THEN ROUND(SUM(D2_QUANT*D2_PESO),2)	" + Enter
	cSql += "						WHEN B1_UM = 'T'  THEN ROUND(SUM(D2_QUANT*1000),2)		" + Enter
	cSql += "						WHEN SUM(D2_PESO) = 0  THEN ROUND(SUM(D2_QUANT),2)		" + Enter
	cSql += "						ELSE ROUND(SUM(D2_QUANT*D2_PESO),2)						" + Enter
	cSql += "					 END,	" + Enter
	cSql += "		0 AS PESO_ENTRADA, 	" + Enter
	cSql += "		0 AS PESO_REQUIS, 	" + Enter
	cSql += "		0 AS TM 			" + Enter
	cSql += "FROM	" + RetSqlName("SD2") + " SD2, " + Enter
	cSql += "		" + RetSqlName("SF4") + " SF4, SB1010 SB1 " + Enter
	cSql += "WHERE	SD2.D2_FILIAL	= '"+xFilial("SD2")+"'	AND	" + Enter
	cSql += "		SF4.F4_FILIAL	= '"+xFilial("SF4")+"'	AND	" + Enter
	cSql += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND	" + Enter
	cSql += "		SD2.D2_GRUPO	= 'PA'				AND	" + Enter
	cSql += "		SD2.D2_TES		= SF4.F4_CODIGO		AND	" + Enter
	cSql += "		SD2.D2_COD		= SB1.B1_COD   		AND	" + Enter
	cSql += "		(SF4.F4_ESTOQUE	= 'S' OR SD2.D2_COD = '25084090')		AND	" + Enter
	cSql += "		SUBSTRING(D2_EMISSAO,1,6) BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " + Enter
	cSql += "		SD2.D_E_L_E_T_	= ''	AND " + Enter
	cSql += "		SF4.D_E_L_E_T_	= ''	AND " + Enter
	cSql += "		SB1.D_E_L_E_T_	= ''		" + Enter
	cSql += "GROUP BY SUBSTRING(D2_EMISSAO,1,6), D2_GRUPO, B1_UM " + Enter
	cSql += "UNION	" + Enter
	cSql += "--DEVOLUCAO DE VENDAS	" + Enter

	cSql += "SELECT	SUBSTRING(D1_EMISSAO,1,6) AS DATA, " + Enter
	cSql += "		D1_GRUPO AS GRUPO,	" + Enter
	cSql += "		B1_UM AS UNID, 		" + Enter
	cSql += "		PESO_SAIDA = CASE	" + Enter
	cSql += "						WHEN MAX(D1_COD) = '1010148' THEN ROUND(SUM(D1_QUANT*1000*-1),2)	" + Enter
	cSql += "						WHEN B1_UM = 'M2' THEN ROUND(SUM(D1_QUANT*B1_PESO*-1),2)	" + Enter
	cSql += "						WHEN B1_UM = 'PC' THEN ROUND(SUM(D1_QUANT*B1_PESO*-1),2)	" + Enter
	cSql += "						WHEN B1_UM = 'T'  THEN ROUND(SUM(D1_QUANT*1000*-1),2)		" + Enter
	cSql += "						WHEN SUM(B1_PESO) = 0  THEN ROUND(SUM(D1_QUANT*-1),2)		" + Enter
	cSql += "						ELSE ROUND(SUM(D1_QUANT*B1_PESO*-1),2)						" + Enter
	cSql += "					 END,	" + Enter
	cSql += "		0 AS PESO_ENTRADA,	" + Enter
	cSql += "		0 AS PESO_REQUIS, 	" + Enter
	cSql += "		0 AS TM " + Enter
	cSql += "FROM	" + RetSqlName("SD1") + " SD1, " + Enter
	cSql += "		SB1010 SB1,	ZZ9010 ZZ9, " + Enter
	cSql += "		" + RetSqlName("SF4") + " SF4	" + Enter
	cSql += "WHERE	SD1.D1_FILIAL	= '"+xFilial("SD1")+"'	AND	" + Enter
	cSql += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND	" + Enter

	cSql += "		ZZ9.ZZ9_PRODUT	= (SB1.B1_YFORMAT + SB1.B1_YFATOR + SB1.B1_YLINHA + SB1.B1_YCLASSE) AND	" + Enter
	cSql += "		ZZ9.ZZ9_LOTE	= SD1.D1_LOTECTL AND	" + Enter

	cSql += "		SF4.F4_FILIAL	= '"+xFilial("SF4")+"'	AND	" + Enter
	cSql += "		SD1.D1_TIPO		= 'D'	AND " + Enter
	cSql += "		SD1.D1_GRUPO	= 'PA'	AND	" + Enter
	cSql += "		SD1.D1_COD		= SB1.B1_COD	AND	" + Enter
	cSql += "		SD1.D1_TES		= SF4.F4_CODIGO	AND	" + Enter
	cSql += "		(SF4.F4_ESTOQUE	= 'S' OR SD1.D1_COD = '25084090')	AND	" + Enter
	cSql += "		SUBSTRING(D1_EMISSAO,1,6) BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " + Enter
	cSql += "		SD1.D_E_L_E_T_ = '' AND " + Enter
	cSql += "		SB1.D_E_L_E_T_ = '' AND	" + Enter
	cSql += "		ZZ9.D_E_L_E_T_ = '' AND	" + Enter
	cSql += "		SF4.D_E_L_E_T_ = ''	" + Enter
	cSql += "GROUP BY SUBSTRING(D1_EMISSAO,1,6), D1_GRUPO, B1_UM " + Enter


	cSql += "UNION  " + Enter
	cSql += "--ENTRADAS " + Enter
	cSql += "SELECT	SUBSTRING(D1_DTDIGIT,1,6) AS DATA, " + Enter
	cSql += "		SD1.D1_GRUPO AS GRUPO, " 	+ Enter
	cSql += "		SB1.B1_UM AS UNID, " 		+ Enter
	cSql += "		0 AS PESO_SAIDA, " 			+ Enter
	cSql += "		PESO_ENTRADA = 	CASE  " 	+ Enter
	cSql += "							WHEN MAX(D1_COD) = '1010148' THEN SUM(SD1.D1_QUANT*1000) " + Enter
	cSql += "							WHEN B1_UM = 'KG' THEN SUM(SD1.D1_QUANT) " + Enter
	cSql += "							WHEN B1_UM = 'M3' THEN SUM(SD1.D1_QUANT*1500) " + Enter
	cSql += "							WHEN B1_UM = 'T'  THEN SUM(SD1.D1_QUANT*1000) " + Enter
	cSql += "							WHEN B1_UM = 'TL' THEN SUM(SD1.D1_QUANT*1000) " + Enter
	cSql += "							ELSE SUM(SD1.D1_QUANT) " + Enter
	cSql += "						END, " + Enter
	cSql += "		0 AS PESO_REQUIS, " + Enter
	cSql += "		0 AS TM " + Enter
	cSql += "FROM	" + RetSqlName("SD1") + " SD1, " + Enter
	cSql += "		" + RetSqlName("SF4") + " SF4, SB1010 SB1 " + Enter
	cSql += "WHERE	SD1.D1_FILIAL	= '"+xFilial("SD1")+"'	AND	" + Enter
	cSql += "		SF4.F4_FILIAL	= '"+xFilial("SF4")+"'	AND	" + Enter
	cSql += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND	" + Enter
	cSql += "		SD1.D1_COD		= SB1.B1_COD		AND	" + Enter
	cSql += "		SUBSTRING(SD1.D1_GRUPO,1,3)	IN ('101','102')	AND	" + Enter
	cSql += "		SF4.F4_CODIGO	= SD1.D1_TES		AND " + Enter
	cSql += "		SF4.F4_ESTOQUE	= 'S'				AND " + Enter
	cSql += "		SD1.D_E_L_E_T_	= ''				AND " + Enter
	cSql += "		SB1.D_E_L_E_T_	= ''				AND " + Enter
	cSql += "		SF4.D_E_L_E_T_	= ''				AND " + Enter
	cSql += "		SUBSTRING(D1_DTDIGIT,1,6) BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + Enter
	cSql += "GROUP BY SUBSTRING(D1_DTDIGIT,1,6), SD1.D1_GRUPO, SB1.B1_UM 	" + Enter

	cSql += "UNION	" + Enter
	cSql += "--DEVOLUCAO ENTRADAS " + Enter
	cSql += "SELECT	SUBSTRING(D2_EMISSAO,1,6) AS DATA, " + Enter
	cSql += "		D2_GRUPO AS GRUPO,	" + Enter
	cSql += "		B1_UM AS UNID, 		" + Enter
	cSql += "		0 AS PESO_SAIDA, 	" + Enter
	cSql += "		PESO_ENTRADA = 	CASE  " + Enter
	cSql += "							WHEN MAX(D2_COD) = '1010148' THEN SUM((SD2.D2_QUANT*1000)*-1)			" + Enter
	cSql += "							WHEN B1_UM = 'KG' THEN SUM(SD2.D2_QUANT*-1)			" + Enter
	cSql += "							WHEN B1_UM = 'M3' THEN SUM(SD2.D2_QUANT*1500*-1) 	" + Enter
	cSql += "							WHEN B1_UM = 'T'  THEN SUM(SD2.D2_QUANT*1000*-1) 	" + Enter
	cSql += "							WHEN B1_UM = 'TL' THEN SUM(SD2.D2_QUANT*1000*-1) 	" + Enter
	cSql += "							ELSE SUM(SD2.D2_QUANT) 	" + Enter
	cSql += "						END, " + Enter
	cSql += "		0 AS PESO_REQUIS, " + Enter
	cSql += "		0 AS TM " + Enter
	cSql += "FROM	" + RetSqlName("SD2") + " SD2, " + Enter
	cSql += "		" + RetSqlName("SF4") + " SF4, SB1010 SB1 " + Enter
	cSql += "WHERE	SD2.D2_FILIAL	= '"+xFilial("SD2")+"'	AND " + Enter
	cSql += "		SF4.F4_FILIAL	= '"+xFilial("SF4")+"'	AND " + Enter
	cSql += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + Enter
	cSql += "		SD2.D2_COD		= SB1.B1_COD		AND	" + Enter
	cSql += "		SUBSTRING(SD2.D2_GRUPO,1,3)	IN ('101','102')	AND	" + Enter
	cSql += "		SD2.D2_TIPO		= 'D' 				AND " + Enter
	cSql += "		SD2.D2_TES		= SF4.F4_CODIGO		AND	" + Enter
	cSql += "		SF4.F4_ESTOQUE	= 'S'				AND " + Enter
	cSql += "		SUBSTRING(D2_EMISSAO,1,6) BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " + Enter
	cSql += "		SD2.D_E_L_E_T_	= ''	AND " + Enter
	cSql += "		SB1.D_E_L_E_T_	= ''	AND " + Enter
	cSql += "		SF4.D_E_L_E_T_	= ''		" + Enter
	cSql += "GROUP BY SUBSTRING(D2_EMISSAO,1,6), D2_GRUPO, B1_UM " + Enter

	cSql += "UNION  " + Enter
	cSql += "--REQUISICAO " + Enter
	cSql += "SELECT	SUBSTRING(D3_EMISSAO,1,6) AS DATA, 	" + Enter
	cSql += "		SD3.D3_GRUPO AS GRUPO, 	" + Enter
	cSql += "		SB1.B1_UM AS UNID, 		" + Enter
	cSql += "		0 AS PESO_SAIDA, 		" + Enter
	cSql += "		0 AS PESO_ENTRADA, 		" + Enter
	cSql += "		PESO_REQUIS = CASE  	" + Enter
	cSql += "							WHEN MAX(D3_COD) = '1010148' THEN SUM(SD3.D3_QUANT*1000)	 			" + Enter
	cSql += "							WHEN B1_UM = 'KG' AND D3_TM = '502' THEN SUM(SD3.D3_QUANT) 			" + Enter
	cSql += "							WHEN B1_UM = 'KG' AND D3_TM = '005' THEN SUM(SD3.D3_QUANT*-1) 		" + Enter
	cSql += "							WHEN B1_UM = 'M3' AND D3_TM = '502' THEN SUM(SD3.D3_QUANT*1500) 	" + Enter
	cSql += "							WHEN B1_UM = 'M3' AND D3_TM = '005' THEN SUM(SD3.D3_QUANT*1500*-1) 	" + Enter
	cSql += "							WHEN B1_UM = 'T'  AND D3_TM = '502' THEN SUM(SD3.D3_QUANT*1000) 	" + Enter
	cSql += "							WHEN B1_UM = 'T'  AND D3_TM = '005' THEN SUM(SD3.D3_QUANT*1000*-1) 	" + Enter
	cSql += "							WHEN B1_UM = 'TL' AND D3_TM = '502' THEN SUM(SD3.D3_QUANT*1000) 	" + Enter
	cSql += "							WHEN B1_UM = 'TL' AND D3_TM = '002' THEN SUM(SD3.D3_QUANT*1000*-1) 	" + Enter
	cSql += "							WHEN B1_UM = 'KG' AND D3_TM = '999' AND D3_CF = 'RE1' THEN SUM(SD3.D3_QUANT)			" + Enter
	cSql += "							WHEN B1_UM = 'M3' AND D3_TM = '999' AND D3_CF = 'RE1' THEN SUM(SD3.D3_QUANT*1500) " + Enter
	cSql += "							WHEN B1_UM = 'T'  AND D3_TM = '999' AND D3_CF = 'RE1' THEN SUM(SD3.D3_QUANT*1000) " + Enter
	cSql += "							WHEN B1_UM = 'TL' AND D3_TM = '999' AND D3_CF = 'RE1' THEN SUM(SD3.D3_QUANT*1000) " + Enter
	cSql += "							ELSE SUM(SD3.D3_QUANT) 	" + Enter
	cSql += "						END, " + Enter
	cSql += "		D3_TM  " + Enter
	cSql += "FROM	" + RetSqlName("SD3") + " SD3, SB1010 SB1 " + Enter
	cSql += "WHERE	SD3.D3_FILIAL	=	'"+xFilial("SD3")+"'	AND " + Enter
	cSql += "		SB1.B1_FILIAL	=	'"+xFilial("SB1")+"'	AND " + Enter
	cSql += "		SD3.D3_COD		= SB1.B1_COD		AND " + Enter
	cSql += "		SUBSTRING(SD3.D3_GRUPO,1,3)	IN	('101','102')	AND " + Enter
	cSql += "		SD3.D3_ESTORNO	= ''				AND	" + Enter
	cSql += "		SD3.D_E_L_E_T_	=	''				AND " + Enter
	cSql += "		SB1.D_E_L_E_T_	=	''				AND	" + Enter
	cSql += "		SUBSTRING(D3_EMISSAO,1,6) BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + Enter
	cSql += "GROUP BY SUBSTRING(D3_EMISSAO,1,6), SD3.D3_GRUPO, SB1.B1_UM, D3_TM,D3_CF) TTT " + Enter

	cSql += "GROUP BY DATA " + Enter



	TcSQLExec(cSql)

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
	//AtivaRel()
	callcrys("PESOS",MV_PAR01+";"+MV_PAR02+";"+cempant,cOpcao)
Return

//+
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ValidPerg    ³ Autor ³ MAGNAGO                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria as perguntas no SX1                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
	Local _j, _i
	Private _aPerguntas := {}

	AAdd(_aPerguntas,{cPerg,"01","Periodo Inicial de:"	,"","","mv_ch01","C",06,0,0,"G","","mv_par01",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Periodo Final ate :"	,"","","mv_ch02","C",06,0,0,"G","","mv_par02",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	For _i:= 1 to Len(_aPerguntas)
		If !DbSeek( cPerg + StrZero(_i,2) )
			RecLock("SX1",.T.)
			For _j:= 1 to FCount()
				FieldPut(_j,_aPerguntas[_i,_j])
			Next _j
			MsUnLock()
		Endif
	Next _i
Return
