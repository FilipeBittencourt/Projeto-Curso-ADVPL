#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"            

/*/{Protheus.doc} BIA994
@author Ranisses A. Corona
@since 26/07/05
@version 1.0
@description Relacao Plano de Saude por Dependentes 
@type function
/*/

User Function BIA994()

	Private Enter	:= CHR(13)+CHR(10)
	lEnd       := .F.
	cString    := "SRA"
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Relacao Plano de Saude por Dependentes"
	cTamanho   := "P"
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "BIA994"
	cPerg      := "BIA994"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Relacao Plano de Saude por Dependentes"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "BIA994"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t.

	pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

	//Cancela a impressao
	If nLastKey == 27
		Return
	Endif

	cCCDe 	 := MV_PAR01 
	cCCAte	 := MV_PAR02 
	cFuncDe	 := MV_PAR03
	cFuncAte := MV_PAR04
	cOrdem	 := MV_PAR05
	cDemit	 := MV_PAR06 //Considera Demitidos? 1Sim/2Nao
	cDataDe	 := MV_PAR07 //Demitidos De
	cDataAte := MV_PAR08 //Demitidos Ate 

	U_LOG_USO("BIA994")

	DbSelectArea("SRA")
	DbSetOrder(1)
	DbGotop()

	While !Eof()

		//Conta quanto Dependentes tem PLS
		cQuery := "SELECT COUNT(RB_MAT) QUANT FROM "+RetSqlName("SRB")
		cQuery += " WHERE RB_FILIAL = '"+xFilial()+"'"
		cQuery += " AND RB_PLSAUDE = '1'"
		cQuery += " AND RB_MAT = '"+SRA->RA_MAT+" '"
		cQuery += " AND D_E_L_E_T_ <> '*'
		TCQUERY cQuery NEW Alias "TrabSRB"

		//Grava quantidade de Dep. com PLS no Cad. Funcionario
		RecLock("SRA",.F.)
		SRA->RA_DPASSME := StrZero(TrabSRB->QUANT,2)
		MsUnlock()

		DbSkip()
		TrabSRB->(DbCloseArea())

	End

	Private cSQL

	cSql := " ALTER VIEW VW_BIA994 AS " + Enter
	cSql += " SELECT LTRIM(SUBSTRING(RA_DEMISSA,7,2)) AS DAT_EMISSAO, '1' AS TIPO, RA_CLVL, RA_YCODPLS, 'F' AS TP_FUNC, RA_MAT, RA_NOME, RA_ASMEDIC, RA_DPASSME, RA_SITFOLH, " + Enter
	cSql += "        ISNULL(RC_VALOR,0) AS RC_VALOR, " + Enter
	cSql += "        VLR_PLANO = CASE " + Enter
	cSql += "                    WHEN RA_ASMEDIC IN('E1','E4','E5') THEN VLR_PLANO " + Enter
	cSql += "                    ELSE 0 " + Enter
	cSql += "                  END, " + Enter
	cSql += "        VL_FUN = CASE " + Enter
	cSql += "                   WHEN RA_CATFUNC IN ('E','M','P') AND RA_ASMEDIC IN('E1','E4','E5') AND RA_SALARIO < FAIXA_1 THEN VLR_PLANO*FUNC1/100 " + Enter
	cSql += "                   WHEN RA_CATFUNC IN ('E','M','P') AND RA_ASMEDIC IN('E1','E4','E5') AND (RA_SALARIO >= FAIXA_1 AND RA_SALARIO < FAIXA_2) THEN VLR_PLANO*FUNC2/100 " + Enter
	cSql += "                   WHEN RA_CATFUNC IN ('E','M','P') AND RA_ASMEDIC IN('E1','E4','E5') AND (RA_SALARIO >= FAIXA_2 AND RA_SALARIO < FAIXA_3) THEN VLR_PLANO*FUNC3/100 " + Enter
	cSql += "                   WHEN RA_CATFUNC IN ('E','M','P') AND RA_ASMEDIC IN('E1','E4','E5') AND (RA_SALARIO >= FAIXA_3 AND RA_SALARIO < FAIXA_4) THEN VLR_PLANO*FUNC4/100 " + Enter
	cSql += "                   WHEN RA_CATFUNC IN ('E','M','P') AND RA_ASMEDIC IN('E1','E4','E5') AND (RA_SALARIO >= FAIXA_4 AND RA_SALARIO < FAIXA_5) THEN VLR_PLANO*FUNC5/100 " + Enter
	cSql += "                   WHEN RA_CATFUNC IN ('E','M','P') AND RA_ASMEDIC IN('E1','E4','E5') AND (RA_SALARIO >= FAIXA_5 AND RA_SALARIO < FAIXA_6) THEN VLR_PLANO*FUNC6/100 " + Enter
	cSql += "                   ELSE 0 " + Enter
	cSql += "                 END " + Enter

	cSql += "                 	,ISNULL((SELECT RC_VALOR FROM " + RetSqlName("SRC") + " WHERE RC_MAT = A.RA_MAT AND RC_PD = '535' AND D_E_L_E_T_= ''),0) AS ADESAO_FUNC " + Enter
	cSql += "                 	,ISNULL((SELECT RC_VALOR FROM " + RetSqlName("SRC") + " WHERE RC_MAT = A.RA_MAT AND RC_PD = '879' AND D_E_L_E_T_= ''),0) AS ADESAO_EMP " + Enter
	cSql += "                 	,ISNULL((SELECT RC_VALOR FROM " + RetSqlName("SRC") + " WHERE RC_MAT = A.RA_MAT AND RC_PD = '536' AND D_E_L_E_T_= ''),0) AS ADESAO_ODON_FUNC " + Enter
	cSql += "                 	,ISNULL((SELECT RC_VALOR FROM " + RetSqlName("SRC") + " WHERE RC_MAT = A.RA_MAT AND RC_PD = '880' AND D_E_L_E_T_= ''),0) AS ADESAO_ODON_EMP " + Enter


	cSql += " FROM " + RetSqlName("SRA") + " A, " + Enter
	cSql += "      " + RetSqlName("SRC") + " B, " + Enter

	//TIPO 1 CADASTRO PLANO SAUDE EMPRESA 
	cSql += " 	(SELECT RX_COD, SUBSTRING(RX_TXT,1,20) AS PLANO, CONVERT(FLOAT, SUBSTRING(RX_TXT,21,14)) AS VLR_PLANO " + Enter
	cSql += " 	FROM " + RetSqlName("SRX") + " AS SRX " + Enter
	cSql += " 	WHERE RX_TIP = '58' AND D_E_L_E_T_ = '' AND SUBSTRING(RX_COD,5,2) = '01')  AS PLANO, " + Enter

	//TIPO 2 FAIXA SALARIA 1 E 2
	cSql += " 	(SELECT RX_COD, CONVERT(FLOAT, SUBSTRING(RX_TXT,01,14)) AS FAIXA_1, CONVERT(FLOAT, SUBSTRING(RX_TXT,15,6)) AS FUNC1, CONVERT(FLOAT, SUBSTRING(RX_TXT,21,6)) AS DEPEN1, " + Enter
	cSql += "        	        CONVERT(FLOAT, SUBSTRING(RX_TXT,27,14)) AS FAIXA_2, CONVERT(FLOAT, SUBSTRING(RX_TXT,41,6)) AS FUNC2, CONVERT(FLOAT, SUBSTRING(RX_TXT,47,6)) AS DEPEN2 " + Enter
	cSql += " 	FROM " + RetSqlName("SRX")+ " AS SRX " + Enter
	cSql += " 	WHERE RX_TIP = '58' AND D_E_L_E_T_ = '' AND SUBSTRING(RX_COD,5,2) = '02') AS FAIXA1, " + Enter

	//TIPO 3 FAIXA SALARIA 3 E 4
	cSql += " 	(SELECT RX_COD, CONVERT(FLOAT, SUBSTRING(RX_TXT,01,14)) AS FAIXA_3, CONVERT(FLOAT, SUBSTRING(RX_TXT,15,6)) AS FUNC3, CONVERT(FLOAT, SUBSTRING(RX_TXT,21,6)) AS DEPEN3, " + Enter
	cSql += "        	        CONVERT(FLOAT, SUBSTRING(RX_TXT,27,14)) AS FAIXA_4, CONVERT(FLOAT, SUBSTRING(RX_TXT,41,6)) AS FUNC4, CONVERT(FLOAT, SUBSTRING(RX_TXT,47,6)) AS DEPEN4 " + Enter
	cSql += " 	FROM " + RetSqlName("SRX") + " AS SRX " + Enter
	cSql += " 	WHERE RX_TIP = '58' AND D_E_L_E_T_ = '' AND SUBSTRING(RX_COD,5,2) = '03') AS FAIXA2, " + Enter

	//TIPO 4 FAIXA SALARIA 5 E 6
	cSql += " 	(SELECT RX_COD, CONVERT(FLOAT, SUBSTRING(RX_TXT,01,14)) AS FAIXA_5, CONVERT(FLOAT, SUBSTRING(RX_TXT,15,6)) AS FUNC5, CONVERT(FLOAT, SUBSTRING(RX_TXT,21,6)) AS DEPEN5, " + Enter
	cSql += "        	        CONVERT(FLOAT, SUBSTRING(RX_TXT,27,14)) AS FAIXA_6, CONVERT(FLOAT, SUBSTRING(RX_TXT,41,6)) AS FUNC6, CONVERT(FLOAT, SUBSTRING(RX_TXT,47,6)) AS DEPEN6 " + Enter
	cSql += " 	FROM " + RetSqlName("SRX") + " AS SRX " + Enter
	cSql += " 	WHERE RX_TIP = '58' AND D_E_L_E_T_ = '' AND SUBSTRING(RX_COD,5,2) = '04') AS FAIXA3 " + Enter

	cSql += " WHERE A.D_E_L_E_T_ = '' AND " + Enter
	cSql += "       B.D_E_L_E_T_ = '' AND " + Enter
	If cDemit == 1 
		cSql += "      	((RA_DEMISSA BETWEEN '"+dtos(cDataDe)+"' AND '"+dtos(cDataAte)+"') OR "  + Enter
		cSql += "      	 RA_DEMISSA = '') AND " + Enter
	Else	
		cSql += "       RA_SITFOLH <> 'D' AND " + Enter
	End
	cSql += "       RA_MAT *= RC_MAT  AND " + Enter
	cSql += "       RA_CATFUNC <> 'A' AND " + Enter
	//cSql += "       RC_PD = '423'         " + Enter
	IF CEMPANT = "01" 
		cSql += "       RC_PD = '533'         " + Enter
	ELSE
		cSql += "       RC_PD = '533'         " + Enter
	END IF

	cSql += "		AND SUBSTRING(PLANO.RX_COD,3,2) = RA_ASMEDIC " + Enter
	cSql += "		AND SUBSTRING(FAIXA1.RX_COD,3,2) = RA_ASMEDIC " + Enter
	cSql += "		AND SUBSTRING(FAIXA2.RX_COD,3,2) = RA_ASMEDIC " + Enter
	cSql += "		AND SUBSTRING(FAIXA3.RX_COD,3,2) = RA_ASMEDIC " + Enter
	IF ALLTRIM(MV_PAR09) <> ""
		cSql += "		AND RA_ASMEDIC = '"+MV_PAR09+"' " + Enter
	END IF

	cSql += " UNION " + Enter

	cSql += " SELECT LTRIM(SUBSTRING(RA_DEMISSA,7,2)) AS DAT_EMISSAO, '2' AS TIPO, RA_CLVL, RB_YCODPLS, RB_GRAUPAR AS TP_FUNC, RB_MAT, RB_NOME, RA_ASMEDIC, " + Enter
	cSql += "		 RA_DPASSME = CASE "  + Enter
	cSql += "                    WHEN RB_PLSAUDE = '1' THEN RA_DPASSME " + Enter
	cSql += "                    ELSE '00' " + Enter
	cSql += "                  END, " + Enter
	cSql += "		 RA_SITFOLH, '0' AS RC_VALOR, " + Enter
	cSql += "        VLR_PLANO = CASE " + Enter
	cSql += "                    WHEN RB_PLSAUDE = '1' THEN VLR_PLANO " + Enter
	cSql += "                    ELSE 0 " + Enter
	cSql += "                  END, " + Enter
	cSql += "        VL_DEP = CASE " + Enter
	cSql += "                   WHEN RB_PLSAUDE = '1' AND RA_SALARIO < FAIXA_1 THEN VLR_PLANO*DEPEN1/100 " + Enter
	cSql += "                   WHEN RB_PLSAUDE = '1' AND RA_SALARIO >= FAIXA_1 AND RA_SALARIO < FAIXA_2 THEN VLR_PLANO*DEPEN2/100 " + Enter
	cSql += "                   WHEN RB_PLSAUDE = '1' AND RA_SALARIO >= FAIXA_2 AND RA_SALARIO < FAIXA_3 THEN VLR_PLANO*DEPEN3/100 " + Enter
	cSql += "                   WHEN RB_PLSAUDE = '1' AND RA_SALARIO >= FAIXA_3 AND RA_SALARIO < FAIXA_4 THEN VLR_PLANO*DEPEN4/100 " + Enter
	cSql += "                   WHEN RB_PLSAUDE = '1' AND RA_SALARIO >= FAIXA_4 AND RA_SALARIO < FAIXA_5 THEN VLR_PLANO*DEPEN5/100 " + Enter
	cSql += "                   WHEN RB_PLSAUDE = '1' AND RA_SALARIO >= FAIXA_5 AND RA_SALARIO < FAIXA_6 THEN VLR_PLANO*DEPEN6/100 " + Enter
	cSql += "                   ELSE 0 " + Enter
	cSql += "                 END " + Enter

	cSql += "                 	,'0' AS ADESAO_FUNC " + Enter
	cSql += "                 	,'0' AS ADESAO_EMP " + Enter
	cSql += "                 	,'0' AS ADESAO_ODON_FUNC " + Enter
	cSql += "                 	,'0' AS ADESAO_ODON__EMP " + Enter

	cSql += " FROM " + RetSqlName("SRA") + " A, " + Enter
	cSql += "      " + RetSqlName("SRB") + " B, " + Enter

	//TIPO 1 CADASTRO PLANO SAUDE EMPRESA 
	cSql += " 	(SELECT RX_COD, SUBSTRING(RX_TXT,1,20) AS PLANO, CONVERT(FLOAT, SUBSTRING(RX_TXT,21,14)) AS VLR_PLANO " + Enter
	cSql += " 	FROM " + RetSqlName("SRX") + " AS SRX " + Enter
	cSql += " 	WHERE RX_TIP = '58' AND D_E_L_E_T_ = '' AND SUBSTRING(RX_COD,5,2) = '01')  AS PLANO, " + Enter

	//TIPO 2 FAIXA SALARIA 1 E 2
	cSql += " 	(SELECT RX_COD, CONVERT(FLOAT, SUBSTRING(RX_TXT,01,14)) AS FAIXA_1, CONVERT(FLOAT, SUBSTRING(RX_TXT,15,6)) AS FUNC1, CONVERT(FLOAT, SUBSTRING(RX_TXT,21,6)) AS DEPEN1, " + Enter
	cSql += "        	        CONVERT(FLOAT, SUBSTRING(RX_TXT,27,14)) AS FAIXA_2, CONVERT(FLOAT, SUBSTRING(RX_TXT,41,6)) AS FUNC2, CONVERT(FLOAT, SUBSTRING(RX_TXT,47,6)) AS DEPEN2 " + Enter
	cSql += " 	FROM " + RetSqlName("SRX") + " AS SRX " + Enter
	cSql += " 	WHERE RX_TIP = '58' AND D_E_L_E_T_ = '' AND SUBSTRING(RX_COD,5,2) = '02') AS FAIXA1, " + Enter

	//TIPO 3 FAIXA SALARIA 3 E 4
	cSql += " 	(SELECT RX_COD, CONVERT(FLOAT, SUBSTRING(RX_TXT,01,14)) AS FAIXA_3, CONVERT(FLOAT, SUBSTRING(RX_TXT,15,6)) AS FUNC3, CONVERT(FLOAT, SUBSTRING(RX_TXT,21,6)) AS DEPEN3, " + Enter
	cSql += "        	        CONVERT(FLOAT, SUBSTRING(RX_TXT,27,14)) AS FAIXA_4, CONVERT(FLOAT, SUBSTRING(RX_TXT,41,6)) AS FUNC4, CONVERT(FLOAT, SUBSTRING(RX_TXT,47,6)) AS DEPEN4 " + Enter
	cSql += " 	FROM " + RetSqlName("SRX") + " AS SRX " + Enter
	cSql += " 	WHERE RX_TIP = '58' AND D_E_L_E_T_ = '' AND SUBSTRING(RX_COD,5,2) = '03') AS FAIXA2, " + Enter

	//TIPO 4 FAIXA SALARIA 5 E 6
	cSql += " 	(SELECT RX_COD, CONVERT(FLOAT, SUBSTRING(RX_TXT,01,14)) AS FAIXA_5, CONVERT(FLOAT, SUBSTRING(RX_TXT,15,6)) AS FUNC5, CONVERT(FLOAT, SUBSTRING(RX_TXT,21,6)) AS DEPEN5, " + Enter
	cSql += "        	        CONVERT(FLOAT, SUBSTRING(RX_TXT,27,14)) AS FAIXA_6, CONVERT(FLOAT, SUBSTRING(RX_TXT,41,6)) AS FUNC6, CONVERT(FLOAT, SUBSTRING(RX_TXT,47,6)) AS DEPEN6 " + Enter
	cSql += " 	FROM " + RetSqlName("SRX") + " AS SRX " + Enter
	cSql += " 	WHERE RX_TIP = '58' AND D_E_L_E_T_ = '' AND SUBSTRING(RX_COD,5,2) = '04') AS FAIXA3 " + Enter

	cSql += " WHERE A.D_E_L_E_T_ = '' 	AND	" + Enter
	cSql += "       B.D_E_L_E_T_ = ''	AND	" + Enter
	cSql += "       A.RA_MAT = B.RB_MAT AND	" + Enter
	cSql += "       A.RA_CATFUNC <> 'A'	AND	" + Enter
	If cDemit == 1
		cSql += "      	((RA_DEMISSA BETWEEN '"+dtos(cDataDe)+"' AND '"+dtos(cDataAte)+"') OR "  + Enter
		cSql += "      	 RA_DEMISSA = '') " + Enter
	Else	
		cSql += "       A.RA_SITFOLH <> 'D' " + Enter
	End
	cSql += "		AND SUBSTRING(PLANO.RX_COD,3,2) = RA_ASMEDIC " + Enter
	cSql += "		AND SUBSTRING(FAIXA1.RX_COD,3,2) = RA_ASMEDIC " + Enter
	cSql += "		AND SUBSTRING(FAIXA2.RX_COD,3,2) = RA_ASMEDIC " + Enter
	cSql += "		AND SUBSTRING(FAIXA3.RX_COD,3,2) = RA_ASMEDIC " + Enter
	IF ALLTRIM(MV_PAR09) <> ""
		cSql += "		AND RA_ASMEDIC = '"+MV_PAR09+"' " + Enter
	END IF
	//Executa a Query
	TcSQLExec(cSql)

	If aReturn[5]==1
		Private x:="1;0;1;Apuracao"
	Else
		Private x:="3;0;1;Apuracao"
	Endif

	callcrys("BIA994",cCCDe+";"+cCCAte+";"+cFuncDe+";"+cFuncAte+";"+Alltrim(Str(cOrdem))+";"+cempant,x)

Return
