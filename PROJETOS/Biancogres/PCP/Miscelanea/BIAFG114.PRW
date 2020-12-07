#include 'protheus.ch'

/*/{Protheus.doc} BIAFG114
@author Gabriel Rossi Mafioletti
@since 28/10/19
@version 1.0
@description Função para geração da tabela de Pseudo Apontamento Projetado - SD3
@type function
/*/

User Function BIAFG114()

	Local nHandle

	Private _nMesAtu	:=	0

	nHandle := fCreate('BIAFG114.$$$')

	If(nHandle == -1)

		MsgInfo("Processo sendo executado por outro usuário!","BIAFG114")
		Return

	Endif 

	cHInicio := Time()
	If !ValidPerg()
		Return
	EndIf

	Processa({|| fProces()})

	fClose(nHandle)

	MsgINFO("Fim do Processamento...")

Return

Static Function fProces()

	Local _cQuery

	Private _cDataDe	:=	Dtos(MV_PAR04)
	Private _cDataAte	:=	Dtos(MV_PAR05)

	Private _cVersao	:=	MV_PAR01
	Private _cRevisa	:=	MV_PAR02
	Private _cAnoRef	:=	MV_PAR03

	_cQuery := " DELETE FROM " + RetSqlName("ZCX") + " "
	_cQuery += "  WHERE ZCX_FILIAL = " + ValtoSql(xFilial("ZCX")) + " "
	_cQuery += "    AND ZCX_VERSAO = " + ValtoSql(_cVersao)
	_cQuery += "    AND ZCX_REVISA = " + ValtoSql(_cRevisa)
	_cQuery += "    AND ZCX_ANOREF = " + ValtoSql(_cAnoRef)	
	_cQuery += "    AND D_E_L_E_T_ = ' ' "
	tcSqlExec(_cQuery)


	_cQuery	:=	"	INSERT INTO " + RetSqlName("ZCX") + "	"
	_cQuery	+=	"	SELECT '  ' 
	_cQuery	+=	"	," + ValToSql(_cVersao) + " "
	_cQuery	+=	"	," + ValToSql(_cRevisa) + " "
	_cQuery	+=	"	," + ValToSql(_cANoRef) + " "	
	_cQuery	+=	"	,ORIGTAB															        "
	_cQuery	+=	"	,ORIGTAB															        "
	_cQuery	+=	"	,PROD_OP                                                                        "
	_cQuery	+=	"		,TM                                                                         "
	_cQuery	+=	"		,CF                                                                         "
	_cQuery	+=	"		,CONTA                                                                      "
	_cQuery	+=	"		,COD_APON                                                                   "
	_cQuery	+=	"		,SUM(QUANT) QUANT                                                           "
	_cQuery	+=	"		,SUM(CUSTO) CUSTO                                                           "
	_cQuery	+=	"	,' '															        "	
	_cQuery	+=	"		,ROW_NUMBER() OVER(ORDER BY PROD_OP) + (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM " + RetSqlName("ZCX") + ") "
	_cQuery	+=	"	,0															        "
	_cQuery +=	" , ISNULL((SELECT Z47_QTDM01 + Z47_QTDM02 + Z47_QTDM03 + Z47_QTDM04 + Z47_QTDM05 + Z47_QTDM06 + Z47_QTDM07 + Z47_QTDM08 + Z47_QTDM09 + Z47_QTDM10 + Z47_QTDM11 + Z47_QTDM12	"
	_cQuery +=	"			FROM " + RetSqlName("Z47") + " Z47 WITH(NOLOCK)                                                                                                                                                     "
	_cQuery +=	"			WHERE Z47_VERSAO = "+ValtoSql(_cVersao)+"                                                                                                                                        "
	_cQuery +=	"				AND Z47_REVISA = "+ValtoSql(_cRevisa)+"                                                                                                                                          "
	_cQuery +=	"				AND Z47_ANOREF = "+ValtoSql(_cAnoRef)+"                                                                                                                                         "
	_cQuery +=	"				AND SUBSTRING(Z47_PRODUT,1,7) = SUBSTRING(PROD_OP,1,7)                                                                                                                                        "
	_cQuery +=	"				AND Z47.D_E_L_E_T_ = ''),0)                                             "
	_cQuery	+=	" ,'' "
	_cQuery	+=	"	FROM (                                                                          "
	_cQuery	+=	"		SELECT ZBP_ORITAB ORIGTAB                                                   "
	_cQuery	+=	"			,(                                                                      "
	_cQuery	+=	"				SELECT XZBP.ZBP_COD                                                 "
	_cQuery	+=	"				FROM " + RetSqlName("ZBP") + " XZBP WITH (NOLOCK)                                      "
	_cQuery	+=	"				WHERE XZBP.ZBP_SEQREG = ZBP.ZBP_SEQREG                              "
	_cQuery	+=	"					AND XZBP.ZBP_TM = '010'                                         "
	_cQuery	+=	"					AND XZBP.ZBP_ORITAB = ZBP.ZBP_ORITAB                            "
	_cQuery	+=	"					AND XZBP.ZBP_VERSAO = "+ValtoSql(_cVersao)+"                                 "
	_cQuery	+=	"					AND XZBP.ZBP_REVISA = "+ValtoSql(_cRevisa)+"                                     "
	_cQuery	+=	"					AND XZBP.ZBP_ANOREF = "+ValtoSql(_cAnoRef)+"                                    "
	_cQuery	+=	"					AND XZBP.D_E_L_E_T_ = ' '                                       "
	_cQuery	+=	"				) PROD_OP                                                           "
	_cQuery	+=	"			,ZBP_TM TM                                                              "
	_cQuery	+=	"			,ZBP_CF CF                                                              "
	_cQuery	+=	"			,CASE WHEN SB1.B1_TIPO = 'PP' THEN '11307001' ELSE SB1.B1_YCTRIND END CONTA                                                   "
	_cQuery	+=	"			,ZBP_COD COD_APON                                                       "
	_cQuery	+=	"			,ZBP_QUANT * ISNULL((                                                   "
	_cQuery	+=	"					SELECT CASE                                                     "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '01'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM01                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '02'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM02                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '03'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM03                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '04'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM04                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '05'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM05                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '06'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM06                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '07'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM07                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '08'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM08                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '09'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM09                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '10'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM10                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '11'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM11                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '12'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM12                                 "
	_cQuery	+=	"							END                                                     "
	_cQuery	+=	"					FROM " + RetSqlName("ZBP") + "  XZBP WITH (NOLOCK)                                  "
	_cQuery	+=	"					JOIN " + RetSqlName("Z47") + " Z47 WITH (NOLOCK) ON SUBSTRING(Z47.Z47_PRODUT,1,7) = SUBSTRING(XZBP.ZBP_COD,1,7)  "
	_cQuery	+=	"						AND Z47.Z47_VERSAO = "+ValtoSql(_cVersao)+"                              "
	_cQuery	+=	"						AND Z47.Z47_REVISA = "+ValtoSql(_cRevisa)+"                                  "
	_cQuery	+=	"						AND Z47.Z47_ANOREF = "+ValtoSql(_cAnoRef)+"                                 "
	_cQuery	+=	"						AND Z47.D_E_L_E_T_ = ''                                     "
	_cQuery	+=	"					WHERE XZBP.ZBP_SEQREG = ZBP.ZBP_SEQREG                          "
	_cQuery	+=	"						AND XZBP.ZBP_TM = '010'                                     "
	_cQuery	+=	"						AND XZBP.ZBP_ORITAB = ZBP.ZBP_ORITAB                        "
	_cQuery	+=	"						AND XZBP.ZBP_VERSAO = "+ValtoSql(_cVersao)+"                             "
	_cQuery	+=	"						AND XZBP.ZBP_REVISA = "+ValtoSql(_cRevisa)+"                                 "
	_cQuery	+=	"						AND XZBP.ZBP_ANOREF = "+ValtoSql(_cAnoRef)+"                                "
	_cQuery	+=	"						AND XZBP.D_E_L_E_T_ = ' '                                   "
	_cQuery	+=	"					), 0) QUANT                                                     "
	_cQuery	+=	"			,ZBP_CUSTO1 * ISNULL((                                                  "
	_cQuery	+=	"					SELECT CASE                                                     "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '01'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM01                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '02'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM02                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '03'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM03                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '04'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM04                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '05'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM05                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '06'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM06                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '07'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM07                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '08'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM08                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '09'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM09                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '10'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM10                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '11'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM11                                 "
	_cQuery	+=	"							WHEN SUBSTRING(ZBP.ZBP_EMISSA, 5, 2) = '12'             "
	_cQuery	+=	"								THEN Z47.Z47_QTDM12                                 "
	_cQuery	+=	"							END                                                     "
	_cQuery	+=	"					FROM " + RetSqlName("ZBP") + " XZBP WITH (NOLOCK)                                  "
	_cQuery	+=	"					JOIN " + RetSqlName("Z47") + " Z47 WITH (NOLOCK) ON SUBSTRING(Z47.Z47_PRODUT,1,7) = SUBSTRING(XZBP.ZBP_COD,1,7)	"
	_cQuery	+=	"						AND Z47.Z47_VERSAO = "+ValtoSql(_cVersao)+"								"
	_cQuery	+=	"						AND Z47.Z47_REVISA = "+ValtoSql(_cRevisa)+"                                  "
	_cQuery	+=	"						AND Z47.Z47_ANOREF = "+ValtoSql(_cAnoRef)+"                                 "
	_cQuery	+=	"						AND Z47.D_E_L_E_T_ = ''                                     "
	_cQuery	+=	"					WHERE XZBP.ZBP_SEQREG = ZBP.ZBP_SEQREG                          "
	_cQuery	+=	"						AND XZBP.ZBP_TM = '010'                                     "
	_cQuery	+=	"						AND XZBP.ZBP_ORITAB = ZBP.ZBP_ORITAB                        "
	_cQuery	+=	"						AND XZBP.ZBP_VERSAO = "+ValtoSql(_cVersao)+"                             "
	_cQuery	+=	"						AND XZBP.ZBP_REVISA = "+ValtoSql(_cRevisa)+"                                 "
	_cQuery	+=	"						AND XZBP.ZBP_ANOREF = "+ValtoSql(_cAnoRef)+"                                "
	_cQuery	+=	"						AND XZBP.D_E_L_E_T_ = ' '                                   "
	_cQuery	+=	"					), 0) CUSTO                                                     "
	_cQuery	+=	"		FROM " + RetSqlName("ZBP") + " ZBP                                                             "
	_cQuery	+=	"		INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON SB1.B1_COD = ZBP.ZBP_COD             "
	_cQuery	+=	"			AND SB1.D_E_L_E_T_ = ' '                                                "
	_cQuery	+=	"		LEFT JOIN " + RetSqlName("CT1") + " CT1 WITH (NOLOCK) ON CT1_CONTA = SB1.B1_YCTRIND            "
	_cQuery	+=	"			AND CT1.D_E_L_E_T_ = ' '                                                "
	_cQuery	+=	"		WHERE ZBP.ZBP_VERSAO = "+ValtoSql(_cVersao)+"                                            "
	_cQuery	+=	"			AND ZBP.ZBP_REVISA = "+ValtoSql(_cRevisa)+"                                              "
	_cQuery	+=	"			AND ZBP.ZBP_ANOREF = "+ValtoSql(_cAnoRef)+"                                             "
	_cQuery	+=	"			AND ZBP.D_E_L_E_T_ = ' '                                                "
	_cQuery	+=	"		) A                                                                         "
	_cQuery	+=	"	GROUP BY ORIGTAB                                                                "
	_cQuery	+=	"		,PROD_OP                                                                    "
	_cQuery	+=	"		,TM                                                                         "
	_cQuery	+=	"		,CF                                                                         "
	_cQuery	+=	"		,CONTA                                                                      "
	_cQuery	+=	"		,COD_APON                                                                   "
	_cQuery	+=	"	ORDER BY PROD_OP                                                                "
	_cQuery	+=	"		,TM                                                                         "	

	tcSqlExec(_cQuery)


//	_cQuery :=	"	WITH ACUMULADO                                                                                                    "
//	_cQuery +=	"	AS (                                                                                                              "
	_cQuery :=	"		SELECT MAX(NUMSEQ) NUMSEQ                                                                                     "
	_cQuery +=	"			,PROD_OP                                                                                                  "
	_cQuery +=	"			,TM                                                                                                       "
	_cQuery +=	"			,CF                                                                                                       "
	_cQuery +=	"			,CONTA                                                                                                    "
	_cQuery +=	"			,ITCUS                                                                                                    "
	_cQuery +=	"			,COD_APON                                                                                                 "
	_cQuery +=	"			,SUM(QUANT)/PROD_TOT QUANT                                                                                         "
	_cQuery +=	"			,SUM(CUSTO)/PROD_TOT CUSTO                                                                                         "
	_cQuery +=	"		INTO #ACUMULADO	"
	_cQuery +=	"		FROM (                                                                                                        "
	_cQuery +=	"			SELECT 'SD3' ORIGTAB                                                                                      "
	_cQuery +=	"				,SD3.D3_NUMSEQ NUMSEQ                                                                                 "
	_cQuery +=	"				,SC2.C2_PRODUTO PROD_OP                                                                               "
	_cQuery +=	"				,SD3.D3_EMISSAO EMISSAO                                                                               "
	_cQuery +=	"				,SD3.D3_TM TM                                                                                         "
	_cQuery +=	"				,SD3.D3_CF CF                                                                                         "
	_cQuery +=	"				,SD3.D3_CONTA CONTA                                                                                   "
	_cQuery +=	"				,SD3.D3_COD COD_APON                                                                                  "
	_cQuery +=	"				,SD3.D3_QUANT QUANT                                                                                      "
	_cQuery +=	"					,(SELECT SUM(D3_QUANT)                                                                                   "
	_cQuery +=	"					FROM " + RetSqlName("SD3") + " D3PAI WITH (NOLOCK)                                                                   "
	_cQuery +=	"					WHERE D3PAI.D3_FILIAL = " + ValtoSql(xFilial("SD3")) + "                                                                            "
	_cQuery +=	"						AND D3PAI.D3_ESTORNO = ' '                                                                      "
	_cQuery +=	"						AND D3PAI.D3_EMISSAO BETWEEN "+ValtoSql(_cDataDe)+" AND "+ValtoSql(_cDataAte)+"                "
	_cQuery +=	"						AND D3PAI.D3_TM = '010'                                                                       "
	_cQuery +=	"						AND D3PAI.D3_COD = SC2.C2_PRODUTO                                                                       "
	_cQuery +=	"						AND D3PAI.D_E_L_E_T_ = ' '                                                                    "
	_cQuery +=	"					) PROD_TOT                                                                                         "
	_cQuery +=	"				,SD3.D3_CUSTO1 CUSTO                                                                                           "
	_cQuery +=	"				,D3_DOC DOCUMEN                                                                                       "
	_cQuery +=	"				,D3_YITCUS ITCUS                                                                                      "
	_cQuery +=	"			FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)                                                                             "
	_cQuery +=	"			INNER JOIN " + RetSqlName("SC2") + " SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = " + ValtoSql(xFilial("SC2")) + "                                               "
	_cQuery +=	"				AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP, 1, 6)                                                           "
	_cQuery +=	"				AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP, 7, 2)                                                          "
	_cQuery +=	"				AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP, 9, 3)                                                        "
	_cQuery +=	"				AND SC2.D_E_L_E_T_ = ' '                                                                              "
	_cQuery +=	"			LEFT JOIN " + RetSqlName("Z29") + " Z29 WITH (NOLOCK) ON Z29.Z29_FILIAL = " + ValtoSql(xFilial("Z29")) + "                                               "
	_cQuery +=	"				AND Z29.Z29_COD_IT = SD3.D3_YITCUS	                                                           "
	_cQuery +=	"				AND Z29.D_E_L_E_T_ = ' '                                                                              "
	_cQuery +=	"			WHERE SD3.D3_FILIAL = " + ValtoSql(xFilial("SD3")) + "                                                                                "
	_cQuery +=	"				AND SD3.D3_EMISSAO BETWEEN "+ValtoSql(_cDataDe)+"                                                 "
	_cQuery +=	"					AND "+ValtoSql(_cDataAte)+"                                                                                      "
	_cQuery +=	"				AND SD3.D3_ESTORNO = ' '                                                                              "
	_cQuery +=	"				AND SD3.D_E_L_E_T_ = ' '                                                                              "
	If MV_PAR06 == "2"
		_cQuery +=	"				AND ISNULL(Z29.Z29_YMODAT,'') <> '1'                                                                              "	
	EndIf
	_cQuery +=	"				AND SD3.D3_NUMSEQ IN (                                                                                "
	_cQuery +=	"					SELECT D3_NUMSEQ                                                                                  "
	_cQuery +=	"					FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                   "
	_cQuery +=	"					WHERE D3_COD IN (                                                                                 "
	_cQuery +=	"							SELECT ZBP_COD                                                                            "
	_cQuery +=	"							FROM " + RetSqlName("ZBP") + " ZBP WITH (NOLOCK)                                                                          "
	_cQuery +=	"							JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON SB1.B1_COD = ZBP.ZBP_COD
	_cQuery +=	"								AND SB1.B1_TIPO IN ('PA','PP')
	_cQuery +=	"								AND SB1.D_E_L_E_T_ = ''
	_cQuery +=	"							WHERE ZBP_VERSAO = "+ValtoSql(_cVersao)+"                                                              "
	_cQuery +=	"								AND ZBP_REVISA = "+ValtoSql(_cRevisa)+"                                                                "
	_cQuery +=	"								AND ZBP_ANOREF = "+ValtoSql(_cAnoRef)+"                                                               "
	_cQuery +=	"								AND ZBP.D_E_L_E_T_ = ''                                                                   "
	_cQuery +=	"								AND ZBP_TM = '010'                                                                    "
	_cQuery +=	"							)                                                                                         "
	_cQuery +=	"						AND SD3.D3_FILIAL = " + ValtoSql(xFilial("SD3")) + "                                                                    "
	_cQuery +=	"						AND SD3.D3_EMISSAO BETWEEN "+ValtoSql(_cDataDe)+"                                          "
	_cQuery +=	"							AND "+ValtoSql(_cDataAte)+"                                                                              "
	_cQuery +=	"						AND SD3.D3_ESTORNO = ' '                                                                      "
	_cQuery +=	"						AND SD3.D3_TM = '010'                                                                         "
	_cQuery +=	"						AND SD3.D_E_L_E_T_ = ' '                                                                      "
	_cQuery +=	"					)                                                                                                 "
	_cQuery +=	"			) A                                                                                                       "
	_cQuery +=	"		GROUP BY PROD_OP                                                                                              "
	_cQuery +=	"			,TM                                                                                                       "
	_cQuery +=	"			,CF                                                                                                       "
	_cQuery +=	"			,CONTA                                                                                                    "
	_cQuery +=	"			,ITCUS                                                                                                    "
	_cQuery +=	"			,COD_APON                                                                                                 "
	_cQuery +=	"			,PROD_TOT                                                                                                 "
//	_cQuery +=	"		)                                                                                                             "
	_cQuery	+=	"	INSERT INTO " + RetSqlName("ZCX") + "	"
	_cQuery +=	"	SELECT '  '	"
	_cQuery	+=	"		," + ValToSql(_cVersao) + " "
	_cQuery	+=	"		," + ValToSql(_cRevisa) + " "
	_cQuery	+=	"		," + ValToSql(_cANoRef) + " "
	_cQuery +=	"		,'SD3'                                                                                                      "
	_cQuery +=	"		,'SD3'                                                                                                      "	
	_cQuery +=	"		,PROD_OP                                                                                                      "
	_cQuery +=	"		,TM                                                                                                           "
	_cQuery +=	"		,CF                                                                                                           "
	_cQuery +=	"		,CONTA                                                                                                        "
	_cQuery +=	"		,COD_APON                                                                                                     "
	_cQuery +=	"		,ISNULL(QUANT * (																									
	_cQuery +=	"			SELECT Z47_QTDM01 + Z47_QTDM02 + Z47_QTDM03 + Z47_QTDM04 + Z47_QTDM05 + Z47_QTDM06 + Z47_QTDM07 + Z47_QTDM08 + Z47_QTDM09 + Z47_QTDM10 + Z47_QTDM11 + Z47_QTDM12	"
	_cQuery +=	"			FROM " + RetSqlName("Z47") + " Z47 WITH(NOLOCK)                                                                                                                                                     "
	_cQuery +=	"			WHERE Z47_VERSAO = "+ValtoSql(_cVersao)+"                                                                                                                                        "
	_cQuery +=	"				AND Z47_REVISA = "+ValtoSql(_cRevisa)+"                                                                                                                                          "
	_cQuery +=	"				AND Z47_ANOREF = "+ValtoSql(_cAnoRef)+"                                                                                                                                         "
	_cQuery +=	"				AND SUBSTRING(Z47_PRODUT,1,7) = SUBSTRING(PROD_OP,1,7)                                                                                                                                        "
	_cQuery +=	"				AND Z47.D_E_L_E_T_ = ''                                                                                                                                         "
	_cQuery +=	"			),0) QUANT                                                                                                                                                             "
	_cQuery +=	"		,ISNULL(CUSTO * (                                                                                                                                                               "
	_cQuery +=	"			SELECT Z47_QTDM01 + Z47_QTDM02 + Z47_QTDM03 + Z47_QTDM04 + Z47_QTDM05 + Z47_QTDM06 + Z47_QTDM07 + Z47_QTDM08 + Z47_QTDM09 + Z47_QTDM10 + Z47_QTDM11 + Z47_QTDM12    "
	_cQuery +=	"			FROM " + RetSqlName("Z47") + " Z47 WITH(NOLOCK)                                                                                                                                                     "
	_cQuery +=	"			WHERE Z47_VERSAO = "+ValtoSql(_cVersao)+"                                                                                                                                        "
	_cQuery +=	"				AND Z47_REVISA = "+ValtoSql(_cRevisa)+"                                                                                                                                          "
	_cQuery +=	"				AND Z47_ANOREF = "+ValtoSql(_cAnoRef)+"                                                                                                                                         "
	_cQuery +=	"				AND SUBSTRING(Z47_PRODUT,1,7) = SUBSTRING(PROD_OP,1,7)                                                                                                                                        "
	_cQuery +=	"				AND Z47.D_E_L_E_T_ = ''                                                                                                                                         "
	_cQuery +=	"			),0) CUSTO                                                                                                                                                             "
	_cQuery +=	"		,' '	"
	_cQuery	+=	"		,ROW_NUMBER() OVER(ORDER BY PROD_OP) + (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM " + RetSqlName("ZCX") + ") "	
	_cQuery +=	"		,0 "
	_cQuery +=	" 		, ISNULL((SELECT Z47_QTDM01 + Z47_QTDM02 + Z47_QTDM03 + Z47_QTDM04 + Z47_QTDM05 + Z47_QTDM06 + Z47_QTDM07 + Z47_QTDM08 + Z47_QTDM09 + Z47_QTDM10 + Z47_QTDM11 + Z47_QTDM12	"
	_cQuery +=	"			FROM " + RetSqlName("Z47") + " Z47 WITH(NOLOCK)                                                                                                                                                     "
	_cQuery +=	"			WHERE Z47_VERSAO = "+ValtoSql(_cVersao)+"                                                                                                                                        "
	_cQuery +=	"				AND Z47_REVISA = "+ValtoSql(_cRevisa)+"                                                                                                                                          "
	_cQuery +=	"				AND Z47_ANOREF = "+ValtoSql(_cAnoRef)+"                                                                                                                                         "
	_cQuery +=	"				AND SUBSTRING(Z47_PRODUT,1,7) = SUBSTRING(PROD_OP,1,7)                                                                                                                                        "
	_cQuery +=	"				AND Z47.D_E_L_E_T_ = ''),0)                                             "
	_cQuery +=	"		,ITCUS "	
	_cQuery +=	"	FROM #ACUMULADO A                                                                                                                                                            "

	tcSqlExec(_cQuery)

	_cQuery	:=	"	INSERT INTO " + RetSqlName("ZCX") + "                                      "
	_cQuery	+=	"	SELECT ZCX_FILIAL                                       "
	_cQuery	+=	"		,ZCX_VERSAO                                         "
	_cQuery	+=	"		,ZCX_REVISA                                         "
	_cQuery	+=	"		,ZCX_ANOREF                                         "
	_cQuery	+=	"		,'SD3'                                              "
	_cQuery	+=	"		,ZCX_TBREAL                                         "
	_cQuery	+=	"		,ZCX_PRODOP                                         "
	_cQuery	+=	"		,ZCX_TM                                             "
	_cQuery	+=	"		,ZCX_CF                                             "
	_cQuery	+=	"		,ZCX_CONTA                                          "
	_cQuery	+=	"		,ZCX_CDAPON                                         "
	_cQuery	+=	"		,ZCX_QUANT                                          "
	_cQuery	+=	"		,ZCX_CUSTO                                          "
	_cQuery	+=	"		,D_E_L_E_T_                                         "
	_cQuery	+=	"		,ROW_NUMBER() OVER (                                "
	_cQuery	+=	"			ORDER BY ZCX_PRODOP                             "
	_cQuery	+=	"			) + (                                           "
	_cQuery	+=	"			SELECT MAX(R_E_C_N_O_)                          "
	_cQuery	+=	"			FROM " + RetSqlName("ZCX") + "                                     "
	_cQuery	+=	"			)                                               "
	_cQuery	+=	"		,0                                                  "
	_cQuery	+=	"		,ZCX_QTDORC                                                "
	_cQuery	+=	"		,ZCX_ITCUS                                                "
	_cQuery	+=	"	FROM " + RetSqlName("ZCX") + " ZCX                                         "
	_cQuery	+=	"	WHERE ZCX.ZCX_VERSAO = "+ValtoSql(_cVersao)+"                        "
	_cQuery	+=	"		AND ZCX.ZCX_REVISA = "+ValtoSql(_cRevisa)+"                          "
	_cQuery	+=	"		AND ZCX.ZCX_ANOREF = "+ValtoSql(_cAnoRef)+"                         "
	_cQuery	+=	"		AND ZCX.ZCX_ORITAB = 'SGG'                          "
	_cQuery	+=	"		AND ZCX.D_E_L_E_T_ = ''                             "
	_cQuery	+=	"		AND NOT EXISTS (                                    "
	_cQuery	+=	"			SELECT 1                                        "
	_cQuery	+=	"			FROM " + RetSqlName("ZCX") + " ZCXD3                               "
	_cQuery	+=	"			WHERE ZCX.ZCX_VERSAO = ZCXD3.ZCX_VERSAO         "
	_cQuery	+=	"				AND ZCX.ZCX_REVISA = ZCXD3.ZCX_REVISA       "
	_cQuery	+=	"				AND ZCX.ZCX_ANOREF = ZCXD3.ZCX_ANOREF       "
	_cQuery	+=	"				AND ZCX.ZCX_PRODOP = ZCXD3.ZCX_PRODOP       "
	_cQuery	+=	"				AND ZCXD3.ZCX_ORITAB = 'SD3'                "
	_cQuery	+=	"			)												"
	
	tcSqlExec(_cQuery)

	//Calcula o Item de Custo Orçado
	_cQuery	:=	"	UPDATE ZCX                                      "
	_cQuery	+=	"	SET ZCX.ZCX_ITCUS = CASE                        "
	_cQuery	+=	"			WHEN SB1.B1_YITCUS <> ''                "
	_cQuery	+=	"				THEN SB1.B1_YITCUS                  "
	_cQuery	+=	"			WHEN ZB1.B1_YITCUS <> ''                "
	_cQuery	+=	"				THEN ZB1.B1_YITCUS                  "
	_cQuery	+=	"			WHEN ZCX_TM = '010'                     "
	_cQuery	+=	"				THEN '001'                          "
	_cQuery	+=	"			WHEN ZCX_TM = '999'                     "
	_cQuery	+=	"				AND ZB1.B1_TIPO IN (                "
	_cQuery	+=	"					'PA'                            "
	_cQuery	+=	"					,'PS'                           "
	_cQuery	+=	"					)                               "
	_cQuery	+=	"				THEN '065'                          "
	_cQuery	+=	"			ELSE CT1.CT1_YITCUS                     "
	_cQuery	+=	"			END                                     "
	_cQuery	+=	"	FROM "+RetSqlName("ZCX")+" ZCX                                 "
	_cQuery	+=	"	JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = " + ValtoSql(xFilial("SB1"))+ "           "
	_cQuery	+=	"		AND SB1.B1_COD = ZCX.ZCX_PRODOP             "
	_cQuery	+=	"		AND SB1.B1_TIPO IN (                        "
	_cQuery	+=	"			'PP'                                    "
	_cQuery	+=	"			,'PA'                                   "
	_cQuery	+=	"			,'PS'                                   "
	_cQuery	+=	"			)                                       "
	_cQuery	+=	"		AND SB1.D_E_L_E_T_ = ''                     "
	_cQuery	+=	"	JOIN "+RetSqlName("SB1")+" ZB1 ON ZB1.B1_FILIAL = " + ValtoSql(xFilial("SB1"))+ "           "
	_cQuery	+=	"		AND ZB1.B1_COD = ZCX.ZCX_CDAPON             "
	_cQuery	+=	"		AND ZB1.D_E_L_E_T_ = ''                     "
	_cQuery	+=	"	LEFT JOIN "+RetSqlName("CT1")+" CT1 ON CT1.CT1_FILIAL = " + ValtoSql(xFilial("CT1"))+ "     "
	_cQuery	+=	"		AND CT1.CT1_CONTA = ZCX.ZCX_CONTA           "
	_cQuery	+=	"		AND CT1.D_E_L_E_T_ = ''                     "
	_cQuery	+=	"	WHERE ZCX.ZCX_TBREAL = 'SGG'                    "
	_cQuery	+=	"		AND ZCX.D_E_L_E_T_ = ''						"
	_cQuery	+=	"		AND ZCX.ZCX_VERSAO = "+ValtoSql(_cVersao)+"                        "
	_cQuery	+=	"		AND ZCX.ZCX_REVISA = "+ValtoSql(_cRevisa)+"                          "
	_cQuery	+=	"		AND ZCX.ZCX_ANOREF = "+ValtoSql(_cAnoRef)+"                         "
	

	tcSqlExec(_cQuery)

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG114" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}
	local aOpcs 	:= {"1=Sim","2=Não"}

	MV_PAR01	:= SPACE(TAMSX3("Z98_VERSAO")[1])
	MV_PAR02	:= SPACE(TAMSX3("Z98_REVISA")[1])
	MV_PAR03	:= SPACE(TAMSX3("Z98_ANOREF")[1])
	MV_PAR04	:= Stod("")
	MV_PAR05	:= Stod("")
	MV_PAR06	:= "1"

	aAdd( aPergs ,{1,"Versão " 	   		,MV_PAR01 ,""  ,"",'ZB5'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Revisão " 	   	,MV_PAR02 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"AnoRef " 	   		,MV_PAR03 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Data De " 	   		,MV_PAR04 ,""  ,"",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data Até " 	   		,MV_PAR05 ,""  ,"",''  ,'.T.',50,.T.})
	aAdd( aPergs ,{2,"Lista MOD Auto " 	,"1" ,aOpcs,60,'.T.',.F.})

	If ParamBox(aPergs ,"Pseudo Apontamento Projetado",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)

	EndIf

Return lRet
