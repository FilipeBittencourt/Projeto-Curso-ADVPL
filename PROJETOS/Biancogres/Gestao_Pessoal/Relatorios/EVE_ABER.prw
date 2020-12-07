#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EVE_ABER       ºAutor  ³ BRUNO MADALENO     º Data ³  18/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio em Crystal para gerar OS EMPRESTIMOS E COMPRAS DE PISOS º±±
±±º          ³COMPRADO PELOS FUNCIONARIOS
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EVE_ABER()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cSQL
	Private Enter := CHR(13)+CHR(10) 
	lEnd       := .F.
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Informaçoes de imprestimos e compra de pisos"
	cTamanho   := ""
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "EVEABE"
	cPerg      := "EVE_AB"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Informaçoes sobre ferias vencidas"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "EVEABE"
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
	cSQL := ""
	cSQL += "ALTER VIEW EVENTOS_ABERTOS AS " + Enter
	cSQL += "SELECT CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112) AS DATA_REF, RK_DTMOVI, RK_MAT, RA_NOME, RK_PD, RV_DESC, RK_VALORTO, RK_PARCELA, RK_VALORPA, RK_DTVENC, RK_CC " + Enter
	cSQL += "		,(RK_VALORTO-RK_VLRPAGO) AS VALOR_ABERTO, (RK_PARCELA - RK_PARCPAG) AS PARC_RESTANTES  " + Enter
	cSQL += "FROM 	" + RetSqlName("SRK") + " SRK, 	" + RetSqlName("SRV") + " SRV, 	" + RetSqlName("SRA") + " SRA " + Enter
	cSQL += "WHERE	SRV.RV_COD = SRK.RK_PD	 AND " + Enter
	cSQL += "	SRA.RA_MAT = SRK.RK_MAT	 AND " + Enter
	//Alterado por Wanisay dia 31/08/15 conforme OS 3077-15 (Claudia)
	//cSQL += "	SRK.RK_DTVENC > '"+  DTOS(MV_PAR01) +"' AND " + Enter
	cSQL += "	SRK.RK_DTVENC >= '"+  DTOS(MV_PAR01) +"' AND " + Enter
	cSQL += "	SRK.RK_QUITAR <> '1' AND " + Enter
	cSQL += "	SRK.D_E_L_E_T_  = ''	 AND " + Enter
	cSQL += "	SRV.D_E_L_E_T_  = ''	 AND " + Enter
	cSQL += "	SRA.D_E_L_E_T_  = '' " + Enter
	cSQL += "	AND RK_PARCELA - RK_PARCPAG <> 0 " + Enter
	/*cSQL += "UNION ALL " + Enter

	cSQL += "-- BUSCANDO O TOTAL DE DEBITO DE FAMACIA " + Enter
	cSQL += "SELECT	CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112) AS DATA_REF, R8_DATAINI, RA_MAT, RA_NOME, '411', 'DESCONTO FARMACIA',   " + Enter
	cSQL += "		ISNULL((SELECT SUM(VALOR) FROM  " + Enter
	cSQL += "						(SELECT	  " + Enter
	cSQL += "								VALOR = CASE WHEN RD_PD IN('199') THEN (RD_VALOR*-1)  " + Enter
	cSQL += "											ELSE RD_VALOR END  " + Enter
	cSQL += "								,*  " + Enter
	cSQL += "						FROM	" + RetSqlName("SRD") + "    " + Enter
	cSQL += "						WHERE	RD_PD IN('411') AND    " + Enter
	cSQL += "								D_E_L_E_T_ = ''   " + Enter
	cSQL += "								AND RD_MAT = R8_MAT AND RD_DATARQ >= SUBSTRING(R8_DATAINI,1,6)  " + Enter
	cSQL += "								AND RD_MAT+RD_DATARQ NOT IN (SELECT RD_MAT+RD_DATARQ FROM " + RetSqlName("SRD") + " WHERE RD_PD = '799' AND D_E_L_E_T_ = '' GROUP BY RD_MAT, RD_DATARQ)  " + Enter
	cSQL += "								AND SUBSTRING(RD_DATARQ,5,2) <> 13 " + Enter
	cSQL += "						) AS SS),0) AS TTT,   " + Enter
	cSQL += "			'1', 0, '', RA_CC, 0, '0'  " + Enter
	cSQL += "		 " + Enter
	cSQL += "FROM " + RetSqlName("SR8") + " SR8, " + RetSqlName("SRA") + " SRA " + Enter
	cSQL += "WHERE	R8_FILIAL = '01' AND " + Enter
	cSQL += "		R8_MAT = RA_MAT AND " + Enter
	cSQL += "		(R8_DATAFIM = '' OR (R8_TIPO = 'F' AND SUBSTRING(R8_DATAINI,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' ) ) AND " + Enter
	cSQL += "		SR8.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "		SRA.D_E_L_E_T_ = '' " + Enter
	cSQL += "UNION ALL " + Enter

	cSQL += "-- BUSCANDO O TOTAL DE UTILIZAÇÃO PLANO SAUDE " + Enter
	cSQL += "SELECT	CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112) AS DATA_REF, R8_DATAINI, RA_MAT, RA_NOME, '423', 'UTIL. PLANO SAUDE',  " + Enter
	cSQL += "		ISNULL((SELECT SUM(VALOR) FROM  " + Enter
	cSQL += "						(SELECT	  " + Enter
	cSQL += "								VALOR = CASE WHEN RD_PD IN('199') THEN (RD_VALOR*-1)  " + Enter
	cSQL += "											ELSE RD_VALOR END  " + Enter
	cSQL += "								,*  " + Enter
	cSQL += "						FROM	" + RetSqlName("SRD") + "    " + Enter
	cSQL += "						WHERE	RD_PD IN('423') AND    " + Enter
	cSQL += "								D_E_L_E_T_ = ''   " + Enter
	cSQL += "								AND RD_MAT = R8_MAT AND RD_DATARQ >= SUBSTRING(R8_DATAINI,1,6)  " + Enter
	cSQL += "								AND RD_MAT+RD_DATARQ NOT IN (SELECT RD_MAT+RD_DATARQ FROM " + RetSqlName("SRD") + " WHERE RD_PD = '799' AND D_E_L_E_T_ = '' GROUP BY RD_MAT, RD_DATARQ)  " + Enter
	cSQL += "								AND SUBSTRING(RD_DATARQ,5,2) <> 13 " + Enter
	cSQL += "						) AS SS),0) AS TTT,   " + Enter
	cSQL += "			'1', 0, '', RA_CC, 0, '0'  " + Enter
	cSQL += "		 " + Enter
	cSQL += "FROM " + RetSqlName("SR8") + " SR8, " + RetSqlName("SRA") + " SRA " + Enter
	cSQL += "WHERE	R8_FILIAL = '01' AND " + Enter
	cSQL += "		R8_MAT = RA_MAT AND " + Enter
	cSQL += "		(R8_DATAFIM = '' OR (R8_TIPO = 'F' AND SUBSTRING(R8_DATAINI,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' ) ) AND " + Enter
	cSQL += "		SR8.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "		SRA.D_E_L_E_T_ = '' " + Enter
	cSQL += "UNION ALL " + Enter

	cSQL += "-- BUSCANDO O TOTAL DE PLANO DE SAUDE " + Enter
	cSQL += "SELECT	CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112) AS DATA_REF, R8_DATAINI, RA_MAT, RA_NOME, '406', 'ASSISTENCIA MÉDICA',  " + Enter
	cSQL += "		ISNULL((SELECT SUM(VALOR) FROM  " + Enter
	cSQL += "						(SELECT	  " + Enter
	cSQL += "								VALOR = CASE WHEN RD_PD IN(SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE D_E_L_E_T_ = '' AND RV_TIPOCOD = '1' AND RV_COD NOT IN('124','489')) THEN (RD_VALOR*-1) " + Enter
	cSQL += "											ELSE RD_VALOR END  " + Enter
	cSQL += "								,*  " + Enter
	cSQL += "						FROM	" + RetSqlName("SRD") + "    " + Enter
	cSQL += "						WHERE	RD_PD IN(SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE D_E_L_E_T_ = '' AND RV_COD NOT IN('124','489','411','423') AND RV_TIPOCOD IN ('1','2')) AND " + Enter
	cSQL += "								D_E_L_E_T_ = ''   " + Enter
	cSQL += "								AND RD_MAT = R8_MAT AND RD_DATARQ >= SUBSTRING(R8_DATAINI,1,6)  " + Enter
	cSQL += "								AND RD_MAT+RD_DATARQ NOT IN (SELECT RD_MAT+RD_DATARQ FROM " + RetSqlName("SRD") + " WHERE RD_PD = '799' AND D_E_L_E_T_ = '' GROUP BY RD_MAT, RD_DATARQ)  " + Enter
	cSQL += "								AND SUBSTRING(RD_DATARQ,5,2) <> 13 " + Enter

	cSQL += "				UNION ALL " + Enter
	cSQL += "				SELECT	   " + Enter
	cSQL += "						(RD_VALOR*-1) AS VALOR " + Enter
	cSQL += "						,*   " + Enter
	cSQL += "				FROM	SRD010 AS SRD    " + Enter
	cSQL += "				WHERE	RD_PD = '489' AND     " + Enter
	cSQL += "						D_E_L_E_T_ = ''    " + Enter
	cSQL += "						AND RD_MAT = R8_MAT AND RD_DATARQ >= SUBSTRING(R8_DATAINI,1,6)   " + Enter
	cSQL += "						AND 2 = (SELECT COUNT(RD_DATARQ) FROM SRD010 WHERE RD_DATARQ = SRD.RD_DATARQ AND RD_MAT = SRD.RD_MAT AND RD_PD IN('799','489')) " + Enter
	cSQL += "						) AS SS),0) AS TTT,   " + Enter
	cSQL += "			'1', 0, '', RA_CC, 0, '0'  " + Enter
	cSQL += "		 " + Enter
	cSQL += "FROM " + RetSqlName("SR8") + " SR8, " + RetSqlName("SRA") + " SRA " + Enter
	cSQL += "WHERE	R8_FILIAL = '01' AND " + Enter
	cSQL += "		R8_MAT = RA_MAT AND " + Enter
	cSQL += "		(R8_DATAFIM = '' OR (R8_TIPO = 'F' AND SUBSTRING(R8_DATAINI,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' ) ) AND " + Enter
	cSQL += "		SR8.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "		SRA.D_E_L_E_T_ = '' " + Enter
	cSQL += "UNION ALL " + Enter

	cSQL += "-- BUSCANDO O TOTAL DE REEMB.PGTO INDEVIDO " + Enter
	cSQL += "SELECT	CONVERT(DATETIME, '"+  DTOS(MV_PAR01) +"', 112) AS DATA_REF, R8_DATAINI, RA_MAT, RA_NOME, '527', 'REEMB.PGTO INDEVIDO ',  "
	cSQL += "		ISNULL((SELECT SUM(VALOR) FROM  " + Enter
	cSQL += "						(SELECT	  " + Enter
	cSQL += "								VALOR = CASE WHEN RD_PD IN('199') THEN (RD_VALOR*-1)  " + Enter
	cSQL += "											ELSE RD_VALOR END  " + Enter
	cSQL += "								,*  " + Enter
	cSQL += "						FROM	" + RetSqlName("SRD") + "    " + Enter
	cSQL += "						WHERE	RD_PD IN('527') AND    " + Enter
	cSQL += "								D_E_L_E_T_ = ''   " + Enter
	cSQL += "								AND RD_MAT = R8_MAT AND RD_DATARQ >= SUBSTRING(R8_DATAINI,1,6)  " + Enter
	cSQL += "								--AND RD_MAT+RD_DATARQ NOT IN (SELECT RD_MAT+RD_DATARQ FROM " + RetSqlName("SRD") + " WHERE RD_PD = '799' AND D_E_L_E_T_ = '' GROUP BY RD_MAT, RD_DATARQ)  " + Enter
	cSQL += "								AND SUBSTRING(RD_DATARQ,5,2) <> 13 " + Enter
	cSQL += "						) AS SS),0) AS TTT,   " + Enter
	cSQL += "			'1', 0, '', RA_CC, 0, '0'  " + Enter
	cSQL += "		 " + Enter
	cSQL += "FROM " + RetSqlName("SR8") + " SR8, " + RetSqlName("SRA") + " SRA " + Enter
	cSQL += "WHERE	R8_FILIAL = '01' AND " + Enter
	cSQL += "		R8_MAT = RA_MAT AND " + Enter
	cSQL += "		R8_DATAFIM = '' AND " + Enter
	cSQL += "		SR8.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "		SRA.D_E_L_E_T_ = '' " + Enter
	*/
	TcSQLExec(cSQL)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5]==1
		//Parametros Crystal Em Disco
		Private cOpcao:="6;0;1;Apuracao"
	Else
		//Direto Impressora
		Private cOpcao:="3;0;1;Apuracao"
	Endif
	//AtivaRel()
	callcrys("EVE_ABE",cEmpant,cOpcao,.T.,.T.,.T.,.F.)

Return

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
	Local _i, _j
	Private _aPerguntas := {}

	AAdd(_aPerguntas,{cPerg,"01","Data de Referencia ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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