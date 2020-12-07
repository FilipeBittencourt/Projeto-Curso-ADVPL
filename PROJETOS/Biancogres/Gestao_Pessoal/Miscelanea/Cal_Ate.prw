#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Cal_Ate        บAutor  ณBRUNO MADALENO      บ Data ณ  07/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ RELATORIO PARA CALCULAR OS CUSTOS DOS ATESTADOS                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 8                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Cal_Ate()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cSQL
Private Enter	:= CHR(13)+CHR(10)
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Custos dos Atestados Medicos"
cTamanho   := ""
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "CalAte"
cPerg      := "CalAte"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Atestados Medicos"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "ATESTA"
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

aDatInicial	:= MV_PAR01
aDatFinal	:= MV_PAR02


//*************************************************************************
//*************************************************************************
//**** Numeros de dias e quantidade de funcionario no mes BIANCOGRES ******
//*************************************************************************
//*************************************************************************
cSQL := ""
cSQL += "ALTER VIEW VW_CALC_ABSE_BIANCOGRES AS   " + Enter
cSQL += "SELECT SETOR, SUM(DIAS) AS DIAS,  SUM(QUANT) AS QUANT  " + Enter
cSQL += "FROM   " + Enter
cSQL += "		 " + Enter
cSQL += "		(SELECT SETOR = CASE WHEN SETOR = '1' OR SETOR = '4' THEN '1'  " + Enter
cSQL += "						WHEN SETOR = '2'  THEN '2'  " + Enter
cSQL += "						ELSE '3' END,  " + Enter
cSQL += "				SUM(DIAS) AS DIAS, MAX(QUANT) AS QUANT  " + Enter
cSQL += " " + Enter
cSQL += "		FROM 	(SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR,   " + Enter
cSQL += "						COUNT(DIA) AS DIAS, " + Enter
cSQL += "						'' AS QUANT   " + Enter
cSQL += "				FROM ABSENTEISMO_01, SRA010 SRA   " + Enter
cSQL += "				WHERE	SRA.RA_MAT = MAT AND   " + Enter
cSQL += "						DIA >= '"+DTOS(aDatInicial)+"' AND DIA <= '"+DTOS(aDatFinal)+"' AND " + Enter
cSQL += "						SUBSTRING(SRA.RA_CLVL,3,2) NOT IN ('03','13') AND   " + Enter
cSQL += "						SRA.D_E_L_E_T_ = '' " + Enter
cSQL += "				GROUP BY SUBSTRING(SRA.RA_CLVL,1,1) 	) AS TT  " + Enter
cSQL += " " + Enter
cSQL += "		GROUP BY SETOR   " + Enter
cSQL += "		UNION ALL  " + Enter
cSQL += "		-- QUANTIDADE DE FUNCIONARIOS NO SETOR BIANCOGRES  " + Enter
cSQL += "		SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR, '' AS DIAS, COUNT(SRA.RA_CLVL) AS QUANT  " + Enter
cSQL += "		FROM SRA010 SRA  " + Enter
cSQL += "		WHERE	SUBSTRING(SRA.RA_CLVL,1,1) IN ('1','2','3') AND  " + Enter
cSQL += "				SUBSTRING(SRA.RA_CLVL,3,2) NOT IN ('03','13') AND  " + Enter
cSQL += "				SRA.RA_SITFOLH <> 'D' AND  " + Enter
cSQL += "				SRA.D_E_L_E_T_ = ''  " + Enter
cSQL += "		GROUP BY SUBSTRING(SRA.RA_CLVL,1,1) ) AS BIANCOGRES  " + Enter
cSQL += "GROUP BY SETOR  " + Enter
TcSQLExec(cSQL)


//*************************************************************************
//*************************************************************************
//**** Numeros de dias e quantidade de funcionario no mes INCESA **********
//*************************************************************************
//*************************************************************************
cSQL := ""
cSQL += "-- NUMERO DE DIAS DE AFASTAMENTO  " + Enter
cSQL += "ALTER VIEW VW_CALC_ABSE_INCESA AS   " + Enter
cSQL += "SELECT SETOR, SUM(DIAS) AS DIAS, SUM(QUANT) AS QUANT FROM   " + Enter
cSQL += "	(SELECT SETOR, SUM(DIAS) AS DIAS, '' AS QUANT FROM  " + Enter
cSQL += "			(SELECT SETOR, SUM(DIAS)	AS DIAS FROM   " + Enter
cSQL += " " + Enter
cSQL += "					(SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR,   " + Enter
cSQL += "							COUNT(DIA) AS DIAS " + Enter
cSQL += "					FROM ABSENTEISMO_05, SRA050 SRA   " + Enter
cSQL += "					WHERE	SRA.RA_MAT = MAT AND   " + Enter
cSQL += "							DIA >= '"+DTOS(aDatInicial)+"' AND DIA <= '"+DTOS(aDatFinal)+"' AND " + Enter
cSQL += "							SRA.D_E_L_E_T_ = '' " + Enter
cSQL += "					GROUP BY SUBSTRING(SRA.RA_CLVL,1,1) " + Enter
cSQL += "					UNION ALL " + Enter
cSQL += "					SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR,   " + Enter
cSQL += "							COUNT(DIA) AS DIAS " + Enter
cSQL += "					FROM ABSENTEISMO_01, SRA010 SRA   " + Enter
cSQL += "					WHERE	SRA.RA_MAT = MAT AND   " + Enter
cSQL += "							DIA >= '"+DTOS(aDatInicial)+"' AND DIA <= '"+DTOS(aDatFinal)+"' AND " + Enter
cSQL += "							SUBSTRING(SRA.RA_CLVL,4,1) IN ('3') AND " + Enter
cSQL += "							SRA.D_E_L_E_T_ = '' " + Enter
cSQL += "					GROUP BY SUBSTRING(SRA.RA_CLVL,1,1)  ) AS TT " + Enter
cSQL += " " + Enter
cSQL += "			GROUP BY SETOR ) AS TT  " + Enter
cSQL += "	GROUP BY SETOR  " + Enter
cSQL += "	UNION  " + Enter
cSQL += "	-- QUANTIDADE DE FUNCIONARIOS NO SETOR INCESA  " + Enter
cSQL += "	SELECT SETOR, '' AS DIAS, SUM(QUANT) AS QUANT FROM  " + Enter
cSQL += "			(SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR, COUNT(SRA.RA_CLVL) AS QUANT  " + Enter
cSQL += "			FROM SRA050 SRA  " + Enter
cSQL += "			WHERE	SUBSTRING(SRA.RA_CLVL,1,1) IN ('1','2','3') AND  " + Enter
cSQL += "					SRA.RA_SITFOLH <> 'D' AND  " + Enter
cSQL += "					SRA.D_E_L_E_T_ = ''  " + Enter
cSQL += "			GROUP BY SUBSTRING(SRA.RA_CLVL,1,1)  " + Enter
cSQL += "			UNION   " + Enter
cSQL += "			SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR, COUNT(SRA.RA_CLVL) AS QUANT    " + Enter
cSQL += "			FROM SRA010 SRA  " + Enter
cSQL += "			WHERE	SUBSTRING(SRA.RA_CLVL,4,1) IN ('3') AND  " + Enter
cSQL += "					SRA.RA_SITFOLH <> 'D' AND  " + Enter
cSQL += "					SRA.D_E_L_E_T_ = ''  " + Enter
cSQL += "			GROUP BY SUBSTRING(SRA.RA_CLVL,1,1)) AS ABSENTEISMO  " + Enter
cSQL += "	GROUP BY SETOR) AS INCESA  " + Enter
cSQL += "GROUP BY SETOR  " + Enter
TcSQLExec(cSQL)


//*************************************************************************
//*************************************************************************
//**** Quantidade de periodos escolhido ***********************************
//*************************************************************************
//*************************************************************************
cSQL := ""
cSQL += "-- CONTAR QUANTOS PERIODOS EXISTEM  " + Enter
cSQL += "ALTER VIEW VW_CALC_ABSE_PERIODO AS  " + Enter
cSQL += "SELECT COUNT(*) AS TOTAL_PERIODO " + Enter
cSQL += "FROM (SELECT PERIODO " + Enter
cSQL += "		FROM (SELECT PERIODO = CASE	 " + Enter
cSQL += "						WHEN SUBSTRING(SR8.R8_DATAINI,7,2) >= '01' THEN SUBSTRING(SR8.R8_DATAINI,1,6) + '01' + ' A ' + SUBSTRING(LTRIM(STR(CONVERT(INT,CONVERT(VARCHAR(8), DATEADD(M,1,SR8.R8_DATAINI) ,112)))),1,6) + '28' " + Enter
cSQL += "						ELSE SUBSTRING(LTRIM(STR(CONVERT(INT,CONVERT(VARCHAR(8), DATEADD(M,-1,SR8.R8_DATAINI) ,112)))),1,6) + '01' + ' A ' +  SUBSTRING(SR8.R8_DATAINI,1,6) + '28' END " + Enter
cSQL += "		FROM SR8010 SR8 " + Enter
cSQL += "		WHERE	SR8.R8_TIPO IN ('O','P','Q','B') AND " + Enter
cSQL += "				SR8.R8_DATAINI >= '"+DTOS(aDatInicial)+"' AND SR8.R8_DATAINI <= '"+DTOS(aDatFinal)+"' AND " + Enter
cSQL += "				SR8.D_E_L_E_T_ = '') AS PERIODO " + Enter
cSQL += "		GROUP BY PERIODO) AS TT " + Enter
TcSQLExec(cSQL)


//*************************************************************************
//*************************************************************************
//**** SOMA DOS SALARIOS DA BIANCOGRES PARA O CALCULO *********************
//*************************************************************************
//*************************************************************************
cSQL := "--Soma dos salarios da biancogres  " + Enter
cSQL += "ALTER VIEW VW_CALC_ABSE_SALARIO AS   " + Enter
cSQL += "SELECT SETOR, SUM(SALARIO) AS SALARIO, SUM(QUANT) AS QUANT, SUM(DIAS) AS DIAS, SUM(PESSOAS) AS PESSOAS FROM 	  " + Enter
cSQL += "	( SELECT SETOR, SUM(SALARIO) AS SALARIO, SUM(QUANT) AS QUANT, SUM(DIAS) AS DIAS, SUM(PESSOAS) AS PESSOAS FROM 	  " + Enter
cSQL += "			((SELECT	SETOR = CASE WHEN SETOR = '1' OR SETOR = '4' THEN '1'  " + Enter
cSQL += "							 WHEN SETOR = '2'  THEN '2'  " + Enter
cSQL += "							 ELSE '3' END,  " + Enter
cSQL += "					SUM(SALARIO) AS SALARIO, '' AS QUANT, SUM(DIAS) AS DIAS, SUM(PESSOAS) AS PESSOAS FROM   " + Enter
cSQL += "							 " + Enter
cSQL += "						(SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR, " + Enter
cSQL += "								RA_NOME, " + Enter
cSQL += "								1 AS PESSOAS, " + Enter
cSQL += "								MAX(RA_SALARIO) AS SALARIO, " + Enter
cSQL += "								COUNT(DIA) AS DIAS " + Enter
cSQL += "						FROM ABSENTEISMO_01, SRA010 SRA    " + Enter
cSQL += "						WHERE	SRA.RA_MAT = MAT AND    " + Enter
cSQL += "								DIA >= '"+DTOS(aDatInicial)+"' AND DIA <= '"+DTOS(aDatFinal)+"' AND " + Enter
cSQL += "								SUBSTRING(SRA.RA_CLVL,3,2) NOT IN ('03','13') AND    " + Enter
cSQL += "								CUSTO = 'SIM' AND " + Enter
cSQL += "								SRA.D_E_L_E_T_ = ''  " + Enter
cSQL += "						GROUP BY RA_NOME, SUBSTRING(SRA.RA_CLVL,1,1) ) AS TT    " + Enter
cSQL += " " + Enter
cSQL += "			GROUP BY SETOR)  " + Enter
cSQL += "			UNION  " + Enter
cSQL += "			-- QUANTIDADE DE FUNCIONARIOS NO SETOR BIANCOGRES  " + Enter
cSQL += "			SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR, '' AS SALARIO, COUNT(SRA.RA_CLVL) AS QUANT, '' AS DIAS, '' AS PESSOAS  " + Enter
cSQL += "			FROM SRA010 SRA  " + Enter
cSQL += "			WHERE	SUBSTRING(SRA.RA_CLVL,1,1) IN ('1','2','3') AND  " + Enter
cSQL += "					SUBSTRING(SRA.RA_CLVL,3,2) NOT IN ('03','13') AND  " + Enter
cSQL += "					SRA.RA_SITFOLH <> 'D' AND  " + Enter
cSQL += "					SRA.D_E_L_E_T_ = ''   " + Enter
cSQL += "			GROUP BY SUBSTRING(SRA.RA_CLVL,1,1)) AS EEE " + Enter
cSQL += " " + Enter
cSQL += "	GROUP BY SETOR )  AS TT  " + Enter
cSQL += "	WHERE SALARIO <> '0'   " + Enter
cSQL += "GROUP BY SETOR  " + Enter
TcSQLExec(cSQL)


//*************************************************************************
//*************************************************************************
//**** Soma dos salarios da incesa para o calculo *************************
//*************************************************************************
//*************************************************************************
cSQL := "--Soma dos salarios da biancogres  " + Enter
cSQL += "ALTER VIEW VW_CALC_ABSE_SALARIO AS   " + Enter
cSQL += "SELECT SETOR, SUM(SALARIO) AS SALARIO, SUM(QUANT) AS QUANT, SUM(DIAS) AS DIAS, SUM(PESSOAS) AS PESSOAS FROM 	  " + Enter
cSQL += "	( SELECT SETOR, SUM(SALARIO) AS SALARIO, SUM(QUANT) AS QUANT, SUM(DIAS) AS DIAS, SUM(PESSOAS) AS PESSOAS FROM 	  " + Enter
cSQL += "			((SELECT	SETOR = CASE WHEN SETOR = '1' OR SETOR = '4' THEN '1'  " + Enter
cSQL += "							 WHEN SETOR = '2'  THEN '2'  " + Enter
cSQL += "							 ELSE '3' END,  " + Enter
cSQL += "					SUM(SALARIO) AS SALARIO, '' AS QUANT, SUM(DIAS) AS DIAS, SUM(PESSOAS) AS PESSOAS FROM   " + Enter
cSQL += "							 " + Enter
cSQL += "						(SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR, " + Enter
cSQL += "									RA_NOME, " + Enter
cSQL += "									1 AS PESSOAS, " + Enter
cSQL += "									MAX(RA_SALARIO) AS SALARIO, " + Enter
cSQL += "									COUNT(DIA) AS DIAS " + Enter
cSQL += "							FROM ABSENTEISMO_05, SRA050 SRA    " + Enter
cSQL += "							WHERE	SRA.RA_MAT = MAT AND    " + Enter
cSQL += "									DIA >= '"+DTOS(aDatInicial)+"' AND DIA <= '"+DTOS(aDatFinal)+"' AND " + Enter
cSQL += "									CUSTO = 'SIM' AND " + Enter
cSQL += "									SRA.D_E_L_E_T_ = ''  " + Enter
cSQL += "							GROUP BY RA_NOME, SUBSTRING(SRA.RA_CLVL,1,1)  " + Enter
cSQL += "							UNION ALL " + Enter
cSQL += "							SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR, " + Enter
cSQL += "									RA_NOME, " + Enter
cSQL += "									1 AS PESSOAS, " + Enter
cSQL += "									MAX(RA_SALARIO) AS SALARIO, " + Enter
cSQL += "									COUNT(DIA) AS DIAS " + Enter
cSQL += "							FROM ABSENTEISMO_01, SRA010 SRA    " + Enter
cSQL += "							WHERE	SRA.RA_MAT = MAT AND    " + Enter
cSQL += "									DIA >= '"+DTOS(aDatInicial)+"' AND DIA <= '"+DTOS(aDatFinal)+"' AND " + Enter
cSQL += "									CUSTO = 'SIM' AND " + Enter
cSQL += "									SUBSTRING(SRA.RA_CLVL,4,1) IN ('3') AND " + Enter
cSQL += "									SRA.D_E_L_E_T_ = ''  " + Enter
cSQL += "							GROUP BY RA_NOME, SUBSTRING(SRA.RA_CLVL,1,1)  ) AS TT    " + Enter
cSQL += " " + Enter
cSQL += "			GROUP BY SETOR)  " + Enter
cSQL += "			UNION  " + Enter
cSQL += "			-- QUANTIDADE DE FUNCIONARIOS NO SETOR BIANCOGRES  " + Enter
cSQL += "			SELECT	SUBSTRING(SRA.RA_CLVL,1,1) AS SETOR, '' AS SALARIO, COUNT(SRA.RA_CLVL) AS QUANT, '' AS DIAS, '' AS PESSOAS  " + Enter
cSQL += "			FROM SRA010 SRA  " + Enter
cSQL += "			WHERE	SUBSTRING(SRA.RA_CLVL,1,1) IN ('1','2','3') AND  " + Enter
cSQL += "					SUBSTRING(SRA.RA_CLVL,3,2) NOT IN ('03','13') AND  " + Enter
cSQL += "					SRA.RA_SITFOLH <> 'D' AND  " + Enter
cSQL += "					SRA.D_E_L_E_T_ = ''   " + Enter
cSQL += "			GROUP BY SUBSTRING(SRA.RA_CLVL,1,1)) AS EEE " + Enter
cSQL += " " + Enter
cSQL += "	GROUP BY SETOR )  AS TT  " + Enter
cSQL += "	WHERE SALARIO <> '0'   " + Enter
cSQL += "GROUP BY SETOR  " + Enter
TcSQLExec(cSQL)

CPER_DE := MV_PAR01
CPER_ATE := MV_PAR02
                   	
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
callcrys("CALC_AB",DTOC(CPER_DE) + ";" + DTOC(CPER_ATE) ,cOpcao)
RETURN