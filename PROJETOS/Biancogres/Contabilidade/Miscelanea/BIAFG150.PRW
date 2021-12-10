#include 'protheus.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG150
@author Marcos Alberto Soprani
@since 15/07/21
@version 1.0
@description Rotina para Geração da Planilha para Consolidação dos Expurgos
@Obs Desmembrada da rotina BIAFG130
@type function
/*/

User Function BIAFG150()

	Local oBrowse := NIL

	Private smMsnPrc
	Private cCadastro	:=	"Planilha para Consolidação dos Expurgos"

	Private msrhEnter   := CHR(13) + CHR(10)
	Private msStaExcQy  := 0
	Private mslOk       := .T.
	Private msGravaErr  := ""

	Private nRecSM0 := SM0->(Recno())

	If cEmpAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado.", "BIAFG150", "STOP")
		Return
	EndIf

	If cEmpAnt == "90" .and. cFilAnt <> "01"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado, Filial 01, devido as amarrações com as tabelas origens.", "BIAFG150", "STOP")
		Return
	EndIf

	DbSelectArea('ZN4')

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('ZN4')
	oBrowse:SetDescription('Planilha para Consolidação dos Expurgos')

	oBrowse:Activate()

Return

Static Function Menudef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar'     , 'AxPesqui' , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar'    , 'AxVisual' , 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Processa PPC'  , 'U_BFG150A', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Novo Extrator' , 'U_BFG150N', 0, 3, 0, NIL } )

Return aRotina

Static Function __Dummy()

	If ( .F. )
		Menudef()
		__Dummy()
	Endif

Return ( .F. )

USER Function BFG150A()

	Processa({|| aRptFG150() }, "Processando...", , .F.)

Return

Static Function aRptFG150()

	Local n	

	fPerg := "BIAFG150"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf	

	If Substr(dtos(MV_PAR01), 1, 6) <> Substr(dtos(MV_PAR02), 1, 6)
		MsgALERT("Não podem ser informados Ano e Mês diferentes para o intervalo de tempo a ser processado.", "Atenção!!!")
		Return
	EndIf

	EX005 := Alltrim(" SELECT COUNT(*) CONTAD                                            ") + msrhEnter
	EX005 += Alltrim(" FROM " + RetSqlName("ZN4") + " ZN4                                ") + msrhEnter
	EX005 += Alltrim(" WHERE ZN4_FILIAL = '" + xFilial("ZN4") + "'                       ") + msrhEnter
	EX005 += Alltrim("       AND ZN4_MESANO = '" +Substr(dtos(MV_PAR01), 1, 6)+ "'       ") + msrhEnter
	EX005 += Alltrim("       AND ZN4.D_E_L_E_T_ = ' '                                    ") + msrhEnter
	EXIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,EX005),'EX05',.F.,.T.)
	dbSelectArea("EX05")
	dbGoTop()
	If EX05->CONTAD > 0

		mslOk := MsgNOYES("Já existem registros na base de dados para o período informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

	EndIf

	EX05->(dbCloseArea())
	Ferase(EXIndex+GetDBExtension())
	Ferase(EXIndex+OrdBagExt())

	If mslOk

		Begin Transaction

			ET005 := Alltrim(" DELETE ZN4                                                        ") + msrhEnter
			ET005 += Alltrim(" FROM " + RetSqlName("ZN4") + " ZN4                                ") + msrhEnter
			ET005 += Alltrim(" WHERE ZN4_FILIAL = '" + xFilial("ZN4") + "'                       ") + msrhEnter
			ET005 += Alltrim("       AND ZN4_MESANO = '" +Substr(dtos(MV_PAR01), 1, 6)+ "'       ") + msrhEnter
			ET005 += Alltrim("       AND ZN4.D_E_L_E_T_ = ' '                                    ") + msrhEnter
			U_BIAMsgRun("Aguarde... Zerando processamentos anteriores... ",,{|| msStaExcQy := TcSQLExec(ET005) })

			If msStaExcQy < 0
				mslOk := .F.
			EndIf

			If !mslOk

				msGravaErr := TCSQLError()
				DisarmTransaction()

			EndIf

		End Transaction

		If !mslOk
			Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )
			Return
		EndIf 	

	Else

		MsgSTOP("Processamento cancelado", "Atenção!!!")
		Return

	EndIf

	//EC007 := GetNextAlias()
	//BeginSql Alias EC007

	cSql := " SELECT *, "
	cSql += "        ( "
	cSql += "        SELECT COUNT(*) "
	cSql += "        FROM " + RetSqlName("ZN1") + " ZN1(NOLOCK) "
	cSql += "        WHERE D_E_L_E_T_ = ' ' "
	cSql += "        ) REGS "
	cSql += " FROM " + RetSqlName("ZN1") + " ZN1(NOLOCK) "
	cSql += " WHERE D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY ZN1_CODEMP "

	//EndSql
	If chkfile("EC007")
		dbSelectArea("EC007")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "EC007"

	ProcRegua(EC007->REGS)
	While !EC007->(EOF())

		IncProc("Calculando Operações da Empresa -> " + EC007->ZN1_DESEMP )

		cSql := " SELECT ZN2.ZN2_EMPORI, "
		cSql += "        ZN2.ZN2_EMPDES, "
		cSql += "        ZN1.ZN1_CODCLI, "
		cSql += "        ZN2.ZN2_CUSIMP, "
		cSql += "        ZN2.ZN2_DIFPIS, "
		cSql += "        ZN2.ZN2_DIFCOF "
		cSql += " FROM " + RetSqlName("ZN1") + " ZN1(NOLOCK) "
		cSql += " INNER JOIN " + RetSqlName("ZN2") + " ZN2(NOLOCK) ON ZN2.ZN2_FILIAL = '" + xFilial("ZN2") + "' "
		cSql += "                      AND ZN2.ZN2_EMPORI = ZN1.ZN1_CODEMP "
		cSql += "                      AND ZN2.ZN2_EMPORI = '" + EC007->ZN1_CODEMP + "' "
		cSql += "                      AND ZN2.D_E_L_E_T_ = ' ' "
		cSql += " WHERE ZN1.D_E_L_E_T_ = ' ' "
		cSql += " GROUP BY ZN2.ZN2_EMPORI, "
		cSql += "          ZN2.ZN2_EMPDES, "
		cSql += "          ZN1.ZN1_CODCLI, "
		cSql += "          ZN2.ZN2_CUSIMP, "
		cSql += "          ZN2.ZN2_DIFPIS, "
		cSql += "          ZN2.ZN2_DIFCOF "
		cSql += " ORDER BY ZN2.ZN2_EMPORI, "
		cSql += "          ZN2.ZN2_EMPDES, "
		cSql += "          ZN1.ZN1_CODCLI "
		If chkfile("CK003")
			dbSelectArea("CK003")
			dbCloseArea()
		EndIf
		TcQuery cSql New Alias "CK003"

		While  !CK003->(EOF())

			IncProc("Processa regras da empresa -> " + EC007->ZN1_DESEMP )

			If !Empty(Alltrim(CK003->ZN1_CODCLI))

				//Apura as informações do PPC - RECEITA
				cSql := " SELECT SUBSTRING(D2_EMISSAO,1,6) MESANO,                                                                                                                          " + msrhEnter
				cSql += "        B1_GRUPO GRUPO,                                                                                                                                            " + msrhEnter
				cSql += "        SUM(VALOR) 'VLR_0101',                                                                                                                                     " + msrhEnter
				cSql += "        SUM(D2_VALICM) 'VLR_0102',                                                                                                                                 " + msrhEnter
				cSql += "        SUM(D2_VALIMP6) 'VLR_0103',                                                                                                                                " + msrhEnter
				cSql += "        SUM(D2_VALIMP5) 'VLR_0104'                                                                                                                                 " + msrhEnter
				cSql += " FROM (  SELECT QUANT = CASE                                                                                                                                       " + msrhEnter
				cSql += "							WHEN D2_TIPO = 'I'                                                                                                                      " + msrhEnter
				cSql += "							     AND D2_ICMSRET > 0                                                                                                                 " + msrhEnter
				cSql += "							THEN 0                                                                                                                                  " + msrhEnter
				cSql += "							WHEN F4_CREDICM = 'S'                                                                                                                   " + msrhEnter
				cSql += "							     AND F4_ICM = 'S'                                                                                                                   " + msrhEnter
				cSql += "							     AND F4_LFICM = 'T'                                                                                                                 " + msrhEnter
				cSql += "							     AND F4_DUPLIC = 'N'                                                                                                                " + msrhEnter
				cSql += "							THEN 0                                                                                                                                  " + msrhEnter
				cSql += "						    ELSE D2_TOTAL                                                                                                                           " + msrhEnter
				cSql += "						 END,                                                                                                                                       " + msrhEnter
				cSql += "				 VALOR = CASE                                                                                                                                       " + msrhEnter
				cSql += "							WHEN D2_TIPO = 'I'                                                                                                                      " + msrhEnter
				cSql += "							     AND D2_ICMSRET > 0                                                                                                                 " + msrhEnter
				cSql += "							THEN 0                                                                                                                                  " + msrhEnter
				cSql += "							WHEN F4_CREDICM = 'S'                                                                                                                   " + msrhEnter
				cSql += "							     AND F4_ICM = 'S'                                                                                                                   " + msrhEnter
				cSql += "							     AND F4_LFICM = 'T'                                                                                                                 " + msrhEnter
				cSql += "							     AND F4_DUPLIC = 'N'                                                                                                                " + msrhEnter
				cSql += "							THEN 0                                                                                                                                  " + msrhEnter
				cSql += "						    ELSE D2_TOTAL                                                                                                                           " + msrhEnter
				cSql += "                        END,                                                                                                                                       " + msrhEnter
				cSql += "                D2_CLIENTE,                                                                                                                                        " + msrhEnter
				cSql += "                D2_VALICM,                                                                                                                                         " + msrhEnter
				cSql += "                D2_VALIMP6,                                                                                                                                        " + msrhEnter
				cSql += "                D2_VALIMP5,                                                                                                                                        " + msrhEnter
				cSql += "                D2_DOC,                                                                                                                                            " + msrhEnter
				cSql += "                D2_COD,                                                                                                                                            " + msrhEnter
				cSql += "                D2_EMISSAO,                                                                                                                                        " + msrhEnter
				cSql += "                D2_TIPO,                                                                                                                                           " + msrhEnter
				cSql += "                D2_CF,                                                                                                                                             " + msrhEnter
				cSql += "                F4_CREDICM,                                                                                                                                        " + msrhEnter
				cSql += "                F4_ICM,                                                                                                                                            " + msrhEnter
				cSql += "                F4_LFICM,                                                                                                                                          " + msrhEnter
				cSql += "                F4_DUPLIC                                                                                                                                          " + msrhEnter
				cSql += "		FROM SD2" + CK003->ZN2_EMPORI + "0 D2,                                                                                                                      " + msrhEnter
				cSql += "            SF4" + CK003->ZN2_EMPORI + "0 F4                                                                                                                       " + msrhEnter
				cSql += "		WHERE D2.D2_FILIAL = '" + xFilial('SD2') + "' AND                                                                                                           " + msrhEnter
				cSql += "		      D2.D2_TES = F4.F4_CODIGO AND                                                                                                                          " + msrhEnter
				cSql += "		      D2.D_E_L_E_T_	= ' ' AND                                                                                                                               " + msrhEnter
				cSql += "		      F4.D_E_L_E_T_	= ' ') SD2                                                                                                                              " + msrhEnter
				cSql += "	   INNER JOIN SB1010 SB1 ON SD2.D2_COD = SB1.B1_COD AND                                                                                                         " + msrhEnter
				cSql += "                               SB1.B1_GRUPO IN (SELECT ZN2_TPPROD                                                                                                  " + msrhEnter
				cSql += "                                                FROM " + RetSqLName("ZN2") + " ZN2                                                                                 " + msrhEnter
				cSql += "                                                WHERE ZN2_EMPORI = '" + CK003->ZN2_EMPORI + "' ) AND                                                               " + msrhEnter
				cSql += "                               SB1.D_E_L_E_T_ = ' '                                                                                                                " + msrhEnter
				cSql += " WHERE SD2.D2_EMISSAO >= '" + Dtos(MV_PAR01) + "' AND                                                                                                              " + msrhEnter
				cSql += "      SD2.D2_EMISSAO <= '" + Dtos(MV_PAR02) + "' AND                                                                                                               " + msrhEnter
				If CK003->ZN2_EMPORI <> CK003->ZN2_EMPDES
					cSql += "      SD2.D2_CLIENTE IN (SELECT ZN1_CODCLI                                                                                                                     " + msrhEnter
					cSql += "                         FROM " + RetSqLName("ZN2") + " ZN2,                                                                                                   " + msrhEnter
					cSql += "                              " + RetSqLName("ZN1") + " ZN1                                                                                                    " + msrhEnter
					cSql += "                         WHERE ZN2_EMPDES = ZN1_CODEMP AND                                                                                                     " + msrhEnter
					cSql += "                               ZN2_EMPORI = '" + CK003->ZN2_EMPORI + "' AND                                                                                    " + msrhEnter
					cSql += "                               ZN2_EMPDES = '" + CK003->ZN2_EMPDES + "') AND                                                                                   " + msrhEnter
				EndIf
				cSql += "      SD2.D2_TIPO <> 'D' AND                                                                                                                                       " + msrhEnter
				cSql += "      ( (SD2.F4_CREDICM = 'S' AND                                                                                                                                  " + msrhEnter
				cSql += "	      SD2.F4_ICM = 'S' AND                                                                                                                                      " + msrhEnter
				cSql += "	      SD2.F4_LFICM = 'T' AND                                                                                                                                    " + msrhEnter
				cSql += "         SD2.F4_DUPLIC = 'N' AND                                                                                                                                   " + msrhEnter
				cSql += "        ( SUBSTRING(SD2.D2_CF,2,1) IN ('1','4','2') OR SUBSTRING(SD2.D2_CF,2,3) = '923' )  ) OR SD2.F4_DUPLIC = 'S'                                                " + msrhEnter
				cSql += "      )                                                                                                                                                            " + msrhEnter
				cSql += " GROUP BY SUBSTRING(D2_EMISSAO,1,6), B1_GRUPO                                                                                                                      " + msrhEnter
				cSql += " ORDER BY SUBSTRING(D2_EMISSAO,1,6), B1_GRUPO                                                                                                                      " + msrhEnter
				If chkfile("_PPC_R")
					dbSelectArea("_PPC_R")
					dbCloseArea()
				EndIf
				TcQuery cSql New Alias "_PPC_R"

				//Grava as informações do PPC - RECEITA
				While  !_PPC_R->(EOF())

					IncProc("Processa RECEITA -> " + EC007->ZN1_DESEMP )

					//Receita
					GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.01', CK003->ZN2_CUSIMP, _PPC_R->VLR_0101})
					TcSQLExec(cSql)

					//ICMS
					GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.02', CK003->ZN2_CUSIMP, _PPC_R->VLR_0102})
					TcSQLExec(cSql)

					//PIS
					GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.03', CK003->ZN2_CUSIMP, _PPC_R->VLR_0103})
					TcSQLExec(cSql)

					//COFINS
					GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.04', CK003->ZN2_CUSIMP, _PPC_R->VLR_0104})
					TcSQLExec(cSql)

					If CK003->ZN2_DIFPIS > 0
						//Diferencial de PIS
						GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.05', CK003->ZN2_CUSIMP, _PPC_R->VLR_0101*CK003->ZN2_DIFPIS})
						TcSQLExec(cSql)
					EndIf

					If CK003->ZN2_DIFCOF > 0
						//Diferencial de COFINS
						GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.06', CK003->ZN2_CUSIMP, _PPC_R->VLR_0101*CK003->ZN2_DIFCOF})
						TcSQLExec(cSql)
					EndIf

					_PPC_R->(dbSkip())

				End

				cSql := " SELECT SUBSTRING(D1_DTDIGIT,1,6) AS 'MESANO',                                                                                                                                                        " + msrhEnter
				cSql += "        B1_GRUPO AS 'GRUPO',                                                                                                                                                                          " + msrhEnter
				cSql += "        SUM(D1_TOTAL-D1_VALDESC)*-1 'VLR_0201',                                                                                                                                                       " + msrhEnter
				cSql += "        SUM(D1_VALICM)*-1 'VLR_0202',                                                                                                                                                                 " + msrhEnter
				cSql += "        SUM(D1_VALIMP6)*-1 'VLR_0203',                                                                                                                                                                " + msrhEnter
				cSql += "        SUM(D1_VALIMP5)*-1 'VLR_0204'                                                                                                                                                                 " + msrhEnter
				cSql += " FROM SD1" + CK003->ZN2_EMPORI + "0 SD1(NOLOCK)                                                                                                                                                       " + msrhEnter
				cSql += " INNER JOIN SD2" + CK003->ZN2_EMPORI + "0 SD2(NOLOCK) ON                                                                                                                                              " + msrhEnter
				cSql += "	                SD1.D1_NFORI	= SD2.D2_DOC		AND                                                                                                                                            " + msrhEnter
				cSql += "	                SD1.D1_ITEMORI	= SD2.D2_ITEM		AND                                                                                                                                            " + msrhEnter
				cSql += "	                SD1.D1_SERIORI	= SD2.D2_SERIE		AND                                                                                                                                            " + msrhEnter
				cSql += "	                SD1.D1_FORNECE	= SD2.D2_CLIENTE	AND                                                                                                                                            " + msrhEnter
				cSql += "	                SD1.D1_LOJA		= SD2.D2_LOJA       AND                                                                                                                                            " + msrhEnter
				cSql += "                   SD2.D_E_L_E_T_	=  ''   				                                                                                                                                           " + msrhEnter
				cSql += "	INNER JOIN SF4" + CK003->ZN2_EMPORI + "0 SF4(NOLOCK) ON                                                                                                                                            " + msrhEnter
				cSql += "                   SD2.D2_TES      = SF4.F4_CODIGO     AND                                                                                                                                            " + msrhEnter
				cSql += "                   SF4.F4_DUPLIC	=  'S'  			AND                                                                                                                                            " + msrhEnter
				cSql += "                   SF4.D_E_L_E_T_	=  ''   				                                                                                                                                           " + msrhEnter

				//Teste Robert/Fabio
				cSql += "	INNER JOIN SF1" + CK003->ZN2_EMPORI + "0 SF1(NOLOCK) ON                                                                                                                                            " + msrhEnter
				cSql += "                   SD1.D1_DOC		= SF1.F1_DOC		AND                                                                                                                                            " + msrhEnter
				cSql += "                   SD1.D1_SERIE	= SF1.F1_SERIE		AND                                                                                                                                            " + msrhEnter
				cSql += "                   SD1.D1_FORNECE	= SF1.F1_FORNECE    AND                                                                                                                                            " + msrhEnter
				cSql += "                   SF1.D_E_L_E_T_	=  ''   				                                                                                                                                           " + msrhEnter

				cSql += "	INNER JOIN SB1010 SB1(NOLOCK) ON                                                                                                                                                                   " + msrhEnter
				cSql += "                   SD1.D1_COD      = SB1.B1_COD AND                                                                                                                                                   " + msrhEnter
				cSql += "                   SB1.D_E_L_E_T_	=  ''                                                                                                                                                              " + msrhEnter
				cSql += " WHERE SD1.D1_FILIAL	= '" + xFilial('SD1') + "' 	AND                                                                                                                                                " + msrhEnter
				cSql += "	   SD2.D2_FILIAL	= '" + xFilial('SD2') + "' 	AND                                                                                                                                                " + msrhEnter
				cSql += "	   SF4.F4_FILIAL	= '" + xFilial('SF4') + "'	AND                                                                                                                                                " + msrhEnter
				cSql += "	   SB1.B1_FILIAL	= '" + xFilial('SB1') + "'	AND                                                                                                                                                " + msrhEnter
				cSql += "	   SD1.D1_DTDIGIT	>= '" + Dtos(MV_PAR01) + "' AND                                                                                                                                                " + msrhEnter
				cSql += "      SD1.D1_DTDIGIT	<= '" + Dtos(MV_PAR02) + "' AND                                                                                                                                                " + msrhEnter
				cSql += "      SB1.B1_GRUPO IN (SELECT ZN2_TPPROD                                                                                                                                                              " + msrhEnter
				cSql += "                       FROM " + RetSqLName("ZN2") + " ZN2                                                                                                                                             " + msrhEnter
				cSql += "                       WHERE ZN2_EMPORI = '" + CK003->ZN2_EMPORI + "' ) AND                                                                                                                           " + msrhEnter
				If CK003->ZN2_EMPORI <> CK003->ZN2_EMPDES
					cSql += "      SD1.D1_FORNECE IN (SELECT ZN1_CODCLI                                                                                                                                                        " + msrhEnter
					cSql += "                         FROM " + RetSqLName("ZN2") + " ZN2,                                                                                                                                      " + msrhEnter
					cSql += "                              " + RetSqLName("ZN1") + " ZN1                                                                                                                                       " + msrhEnter
					cSql += "                         WHERE ZN2_EMPDES = ZN1_CODEMP AND                                                                                                                                        " + msrhEnter
					cSql += "                               ZN2_EMPORI = '" + CK003->ZN2_EMPORI + "' AND                                                                                                                       " + msrhEnter
					cSql += "                               ZN2_EMPDES = '" + CK003->ZN2_EMPDES + "') AND                                                                                                                      " + msrhEnter
				EndIf
				cSql += "      SD1.D1_TIPO		=  'D'  				AND                                                                                                                                                    " + msrhEnter
				cSql += "      SD1.D_E_L_E_T_	=  ''   				                                                                                                                                                       " + msrhEnter
				cSql += " GROUP BY SUBSTRING(D1_DTDIGIT,1,6), B1_GRUPO                                                                                                                                                         " + msrhEnter
				If chkfile("_PPC_D")
					dbSelectArea("_PPC_D")
					dbCloseArea()
				EndIf
				TcQuery cSql New Alias "_PPC_D"

				//Grava as informações do PPC - DEDUCOES
				While  !_PPC_D->(EOF())

					IncProc("Processa DEDUCOES -> " + EC007->ZN1_DESEMP )

					//Devolucao
					GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.01', CK003->ZN2_CUSIMP, _PPC_D->VLR_0201})
					TcSQLExec(cSql)

					//ICMS
					GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.02', CK003->ZN2_CUSIMP, _PPC_D->VLR_0202})
					TcSQLExec(cSql)

					//PIS
					GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.03', CK003->ZN2_CUSIMP, _PPC_D->VLR_0203})
					TcSQLExec(cSql)

					//COFINS
					GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.04', CK003->ZN2_CUSIMP, _PPC_D->VLR_0204})
					TcSQLExec(cSql)

					If CK003->ZN2_DIFPIS > 0
						//Diferencial de PIS
						GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.05', CK003->ZN2_CUSIMP, _PPC_D->VLR_0201*CK003->ZN2_DIFPIS})
						TcSQLExec(cSql)
					EndIf

					If CK003->ZN2_DIFCOF > 0
						//Diferencial de COFINS
						GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.06', CK003->ZN2_CUSIMP, _PPC_D->VLR_0201*CK003->ZN2_DIFCOF})
						TcSQLExec(cSql)
					EndIf

					_PPC_D->(dbSkip())

				End

			Else

				If CK003->ZN2_EMPORI <> CK003->ZN2_EMPDES

					For  n := 1 to 2

						If n == 1
							nTD := "C" //CUSTO
						Else
							nTD := "D" //DESPESA
						EndIf

						//Receitas
						cSql := " SELECT FIL,                                                                                                                                         " + msrhEnter
						cSql += "        MESANO,                                                                                                                                      " + msrhEnter
						cSql += "        GRUPO,                                                                                                                                       " + msrhEnter
						cSql += "        SUM(VLR_0101) VLR_0101,                                                                                                                      " + msrhEnter
						cSql += "        SUM(VLR_0102) VLR_0102,                                                                                                                      " + msrhEnter
						cSql += "        SUM(VLR_0103) VLR_0103,                                                                                                                      " + msrhEnter
						cSql += "        SUM(VLR_0104) VLR_0104                                                                                                                       " + msrhEnter
						cSql += " FROM                                                                                                                                                " + msrhEnter
						cSql += " (SELECT CT2_CREDIT,                                                                                                                                 " + msrhEnter
						cSql += "         CT2_DEBITO,                                                                                                                                 " + msrhEnter
						cSql += "         SUBSTRING(CT2_DATA,1,6) MESANO,                                                                                                             " + msrhEnter
						cSql += "         'SER' GRUPO                                                                                                                                 " + msrhEnter
						cSql += "	,FIL = CASE                                                                                                                                       " + msrhEnter
						cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000001') OR CT2_DEBITO IN ('41201070000003','41201070000004','41201070000005') THEN '01'    " + msrhEnter
						cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000004') OR CT2_DEBITO IN ('41201070000013','41201070000014','41201070000015') THEN '02'    " + msrhEnter
						cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000005') OR CT2_DEBITO IN ('41201070000023','41201070000024','41201070000025') THEN '03'    " + msrhEnter
						cSql += "			ELSE ''                                                                                                                                   " + msrhEnter
						cSql += "		 END                                                                                                                                          " + msrhEnter
						If CK003->ZN2_EMPORI $ "06/12"
							cSql += "	  ,VLR_0101 = ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41101030000001','41101030000003','41101030000004','41101030000005') THEN CT2_VALOR END),0) " + msrhEnter
							cSql += "	  ,VLR_0102 = ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR END),0)                  " + msrhEnter
							cSql += "	  ,VLR_0103	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR END),0)                  " + msrhEnter
							cSql += "	  ,VLR_0104	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR END),0)                  " + msrhEnter
						Else
							cSql += "	  ,VLR_0101	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41101030000001') THEN CT2_VALOR END),0)                                                    " + msrhEnter
							cSql += "	  ,VLR_0102	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR END),0)                  " + msrhEnter
							cSql += "	  ,VLR_0103	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR END),0)                  " + msrhEnter
							cSql += "	  ,VLR_0104	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR END),0)                  " + msrhEnter
						EndIf
						cSql += " FROM CT2" + CK003->ZN2_EMPORI + "0                                                                                                                  " + msrhEnter
						cSql += " WHERE CT2_DATA BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "'                                                                        " + msrhEnter
						If CK003->ZN2_EMPORI <> CK003->ZN2_EMPDES
							cSql += "    AND (CT2_ITEMC = 'EMP" + CK003->ZN2_EMPDES + "01" + nTD + "' OR CT2_ITEMD = 'EMP" + CK003->ZN2_EMPDES + "01" + nTD + "' )                    " + msrhEnter
						EndIf
						cSql += "    AND CT2_LOTE <> '888888'                                                                                                                         " + msrhEnter
						cSql += "    AND D_E_L_E_T_ = ''                                                                                                                              " + msrhEnter
						cSql += " GROUP BY CT2_CREDIT, CT2_DEBITO, SUBSTRING(CT2_DATA,1,6)) TMP                                                                                       " + msrhEnter
						cSql += " WHERE FIL <> ''                                                                                                                                     " + msrhEnter
						cSql += " GROUP BY FIL, MESANO, GRUPO                                                                                                                         " + msrhEnter

						If CK003->ZN2_EMPORI $ "06/12" .and. nTD == "C"
							cSql += " UNION ALL                                                                                                                                           " + msrhEnter
							cSql += " SELECT FIL = '  ',                                                                                                                                  " + msrhEnter
							cSql += "        MESANO = '" + Substr(dtos(MV_PAR02),1,6) + "',                                                                                               " + msrhEnter
							cSql += "        GRUPO = 'ARG',                                                                                                                               " + msrhEnter
							cSql += "        VLR_0101 = SUM(VLR_0101),                                                                                                                    " + msrhEnter
							cSql += "        VLR_0102 = SUM(VLR_0102),                                                                                                                    " + msrhEnter
							cSql += "        VLR_0103 = SUM(VLR_0103),                                                                                                                    " + msrhEnter
							cSql += "        VLR_0104 = SUM(VLR_0104)                                                                                                                     " + msrhEnter
							cSql += " FROM                                                                                                                                                " + msrhEnter
							cSql += " (                                                                                                                                                   " + msrhEnter
							cSql += "     SELECT CLIENTE = SUBSTRING(CT2_YHIST, 39, 6),                                                                                                   " + msrhEnter
							cSql += "            VLR_0101 = ISNULL((CASE                                                                                                                  " + msrhEnter
							cSql += "                                   WHEN CT2_CREDIT IN('41101010000011')                                                                              " + msrhEnter
							cSql += "                                   THEN CT2_VALOR                                                                                                    " + msrhEnter
							cSql += "                               END), 0),                                                                                                             " + msrhEnter
							cSql += "            VLR_0102 = ISNULL((CASE                                                                                                                  " + msrhEnter
							cSql += "                                   WHEN CT2_DEBITO IN('41201040000003')                                                                              " + msrhEnter
							cSql += "                                   THEN CT2_VALOR                                                                                                    " + msrhEnter
							cSql += "                               END), 0),                                                                                                             " + msrhEnter
							cSql += "            VLR_0103 = ISNULL((CASE                                                                                                                  " + msrhEnter
							cSql += "                                   WHEN CT2_DEBITO IN('41201040000004')                                                                              " + msrhEnter
							cSql += "                                   THEN CT2_VALOR                                                                                                    " + msrhEnter
							cSql += "                               END), 0),                                                                                                             " + msrhEnter
							cSql += "            VLR_0104 = ISNULL((CASE                                                                                                                  " + msrhEnter
							cSql += "                                   WHEN CT2_DEBITO IN('41201040000005')                                                                              " + msrhEnter
							cSql += "                                   THEN CT2_VALOR                                                                                                    " + msrhEnter
							cSql += "                               END), 0)                                                                                                              " + msrhEnter
							cSql += "     FROM CT2" + CK003->ZN2_EMPORI + "0 CT2(NOLOCK)                                                                                                  " + msrhEnter
							cSql += "     WHERE CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'                                                                    " + msrhEnter
							cSql += "           AND CT2_LOTE <> '888888'                                                                                                                  " + msrhEnter
							cSql += "           AND (CT2_CREDIT IN('41101010000011')                                                                                                      " + msrhEnter
							cSql += "     OR (CT2_DEBITO IN('41201040000003', '41201040000004', '41201040000005')))                                                                       " + msrhEnter
							cSql += "     AND CT2.D_E_L_E_T_ = ' '                                                                                                                        " + msrhEnter
							cSql += " ) AS TEMP1                                                                                                                                          " + msrhEnter
							cSql += " INNER JOIN Z35010 Z35(NOLOCK) ON Z35_CODCLI = CLIENTE                                                                                               " + msrhEnter
							cSql += "                                  AND Z35_EMP = '" + CK003->ZN2_EMPDES + "'                                                                          " + msrhEnter
							cSql += "                                  AND Z35.D_E_L_E_T_ = ' '                                                                                           " + msrhEnter
							cSql += " GROUP BY CLIENTE,                                                                                                                                   " + msrhEnter
							cSql += "          Z35_CNPJ                                                                                                                                   " + msrhEnter						
						EndIf

						cSql += " ORDER BY FIL, MESANO, GRUPO                                                                                                                         " + msrhEnter
						If chkfile("_PPC_R")
							dbSelectArea("_PPC_R")
							dbCloseArea()
						EndIf
						TcQuery cSql New Alias "_PPC_R"

						//Grava as informações do PPC - RECEITA
						While  !_PPC_R->(EOF())

							IncProc("Processa RECEITA -> " + EC007->ZN1_DESEMP )

							//Receita
							GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.01', CK003->ZN2_CUSIMP, _PPC_R->VLR_0101})
							TcSQLExec(cSql)

							//ICMS
							GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.02', CK003->ZN2_CUSIMP, _PPC_R->VLR_0102})
							TcSQLExec(cSql)

							//PIS
							GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.03', CK003->ZN2_CUSIMP, _PPC_R->VLR_0103})
							TcSQLExec(cSql)

							//COFINS
							GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.04', CK003->ZN2_CUSIMP, _PPC_R->VLR_0104})
							TcSQLExec(cSql)

							If CK003->ZN2_DIFPIS > 0
								//Diferencial de PIS
								GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.05', CK003->ZN2_CUSIMP, _PPC_R->VLR_0101*CK003->ZN2_DIFPIS})
								TcSQLExec(cSql)
							EndIf

							If CK003->ZN2_DIFCOF > 0
								//Diferencial de COFINS
								GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.06', CK003->ZN2_CUSIMP, _PPC_R->VLR_0101*CK003->ZN2_DIFCOF})
								TcSQLExec(cSql)
							EndIf

							_PPC_R->(dbSkip())

						End

					Next

					For  n := 1 to 2

						If n == 1
							nTD := "C" //CUSTO
						Else
							nTD := "D" //DESPESA
						EndIf

						//Deducoes
						cSql := " SELECT SUBSTRING(CT2_DATA,1,6) MESANO,                                                                                                      " + msrhEnter
						cSql += "        'SER' GRUPO                                                                                                                          " + msrhEnter
						If CK003->ZN2_EMPORI $ "06/12"
							cSql += "	  ,VLR_0201 = ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000011') THEN CT2_VALOR*-1 END),0)                                         " + msrhEnter
							cSql += "	  ,VLR_0202 = ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR*-1 END),0)       " + msrhEnter
							cSql += "	  ,VLR_0203	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR*-1 END),0)       " + msrhEnter
							cSql += "	  ,VLR_0204	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR*-1 END),0)       " + msrhEnter
						Else
							cSql += "	  ,VLR_0201	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000011') THEN CT2_VALOR END),0)                                            " + msrhEnter
							cSql += "	  ,VLR_0202	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR*-1 END),0)       " + msrhEnter
							cSql += "	  ,VLR_0203	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR*-1 END),0)       " + msrhEnter
							cSql += "	  ,VLR_0204	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR*-1 END),0)       " + msrhEnter
						EndIf
						cSql += " FROM CT2" + CK003->ZN2_EMPORI + "0                                                                                                          " + msrhEnter
						cSql += " WHERE CT2_DATA BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "'                                                                " + msrhEnter
						If CK003->ZN2_EMPORI <> CK003->ZN2_EMPDES
							cSql += "    AND (CT2_ITEMC = 'EMP" + CK003->ZN2_EMPDES + "01" + nTD + "' OR CT2_ITEMD = 'EMP" + CK003->ZN2_EMPDES + "01" + nTD + "' )            " + msrhEnter
						EndIf
						cSql += "    AND CT2_LOTE <> '888888'                                                                                                                 " + msrhEnter
						cSql += "    AND D_E_L_E_T_ = ''                                                                                                                      " + msrhEnter
						cSql += " GROUP BY SUBSTRING(CT2_DATA,1,6)                                                                                                            " + msrhEnter

						If CK003->ZN2_EMPORI $ "06/12" .and. nTD == "C" .and. CK003->ZN2_EMPDES == "01"
							cSql += " UNION ALL                                                                                                                                           " + msrhEnter
							cSql += " SELECT MESANO = '" + Substr(dtos(MV_PAR02),1,6) + "',                                                                                               " + msrhEnter
							cSql += "        GRUPO = 'ARG',                                                                                                                               " + msrhEnter
							cSql += "        VLR_0101 = SUM(VLR_0101),                                                                                                                    " + msrhEnter
							cSql += "        VLR_0102 = SUM(VLR_0102),                                                                                                                    " + msrhEnter
							cSql += "        VLR_0103 = SUM(VLR_0103),                                                                                                                    " + msrhEnter
							cSql += "        VLR_0104 = SUM(VLR_0104)                                                                                                                     " + msrhEnter
							cSql += " FROM                                                                                                                                                " + msrhEnter
							cSql += " (                                                                                                                                                   " + msrhEnter
							cSql += "     SELECT CLIENTE = SUBSTRING(CT2_YHIST, 39, 6),                                                                                                   " + msrhEnter
							cSql += "            VLR_0101 = ISNULL((CASE                                                                                                                  " + msrhEnter
							cSql += "                                   WHEN CT2_DEBITO IN('41101010000011')                                                                              " + msrhEnter
							cSql += "                                   THEN CT2_VALOR                                                                                                    " + msrhEnter
							cSql += "                               END), 0) * (-1),                                                                                                      " + msrhEnter
							cSql += "            VLR_0102 = ISNULL((CASE                                                                                                                  " + msrhEnter
							cSql += "                                   WHEN CT2_CREDIT IN('41201040000003')                                                                              " + msrhEnter
							cSql += "                                   THEN CT2_VALOR                                                                                                    " + msrhEnter
							cSql += "                               END), 0) * (-1),                                                                                                      " + msrhEnter
							cSql += "            VLR_0103 = ISNULL((CASE                                                                                                                  " + msrhEnter
							cSql += "                                   WHEN CT2_CREDIT IN('41201040000004')                                                                              " + msrhEnter
							cSql += "                                   THEN CT2_VALOR                                                                                                    " + msrhEnter
							cSql += "                               END), 0) * (-1),                                                                                                      " + msrhEnter
							cSql += "            VLR_0104 = ISNULL((CASE                                                                                                                  " + msrhEnter
							cSql += "                                   WHEN CT2_CREDIT IN('41201040000005')                                                                              " + msrhEnter
							cSql += "                                   THEN CT2_VALOR                                                                                                    " + msrhEnter
							cSql += "                               END), 0) * (-1)                                                                                                       " + msrhEnter
							cSql += "     FROM CT2" + CK003->ZN2_EMPORI + "0 CT2(NOLOCK)                                                                                                  " + msrhEnter
							cSql += "     WHERE CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'                                                                    " + msrhEnter
							cSql += "           AND CT2_LOTE <> '888888'                                                                                                                  " + msrhEnter
							cSql += "           AND (CT2_DEBITO IN('41101010000011')                                                                                                      " + msrhEnter
							cSql += "     OR (CT2_CREDIT IN('41201040000003', '41201040000004', '41201040000005')))                                                                       " + msrhEnter
							cSql += "     AND CT2.D_E_L_E_T_ = ' '                                                                                                                        " + msrhEnter
							cSql += " ) AS TEMP1                                                                                                                                          " + msrhEnter
							cSql += " GROUP BY CLIENTE                                                                                                                                    " + msrhEnter						
						EndIf

						cSql += " ORDER BY MESANO, GRUPO                                                                                                                                  " + msrhEnter
						If chkfile("_PPC_D")
							dbSelectArea("_PPC_D")
							dbCloseArea()
						EndIf
						TcQuery cSql New Alias "_PPC_D"

						//Grava as informações do PPC - DEDUCOES
						While  !_PPC_D->(EOF())

							IncProc("Processa DEDUCOES -> " + EC007->ZN1_DESEMP )

							//Devolucao
							GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.01', CK003->ZN2_CUSIMP, _PPC_D->VLR_0201})
							TcSQLExec(cSql)

							//ICMS
							GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.02', CK003->ZN2_CUSIMP, _PPC_D->VLR_0202})
							TcSQLExec(cSql)

							//PIS
							GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.03', CK003->ZN2_CUSIMP, _PPC_D->VLR_0203})
							TcSQLExec(cSql)

							//COFINS
							GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.04', CK003->ZN2_CUSIMP, _PPC_D->VLR_0204})
							TcSQLExec(cSql)

							If CK003->ZN2_DIFPIS > 0
								//Diferencial de PIS
								GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.05', CK003->ZN2_CUSIMP, _PPC_D->VLR_0201 * CK003->ZN2_DIFPIS})
								TcSQLExec(cSql)
							EndIf

							If CK003->ZN2_DIFCOF > 0
								//Diferencial de COFINS
								GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.06', CK003->ZN2_CUSIMP, _PPC_D->VLR_0201 * CK003->ZN2_DIFCOF})
								TcSQLExec(cSql)
							EndIf

							_PPC_D->(dbSkip())

						End

					Next

				Else

					nTD := ""
					//Receitas
					cSql := " SELECT FIL,                                                                                                                                          " + msrhEnter
					cSql += "        MESANO,                                                                                                                                       " + msrhEnter
					cSql += "        GRUPO,                                                                                                                                        " + msrhEnter
					cSql += "        SUM(VLR_0101) VLR_0101,                                                                                                                       " + msrhEnter
					cSql += "        SUM(VLR_0102) VLR_0102,                                                                                                                       " + msrhEnter
					cSql += "        SUM(VLR_0103) VLR_0103,                                                                                                                       " + msrhEnter
					cSql += "        SUM(VLR_0104) VLR_0104                                                                                                                        " + msrhEnter
					cSql += " FROM                                                                                                                                                 " + msrhEnter
					cSql += " (SELECT CT2_CREDIT,                                                                                                                                  " + msrhEnter
					cSql += "         CT2_DEBITO,                                                                                                                                  " + msrhEnter
					cSql += "         SUBSTRING(CT2_DATA,1,6) MESANO,                                                                                                              " + msrhEnter
					cSql += "         'SER' GRUPO                                                                                                                                  " + msrhEnter
					cSql += "	,FIL = CASE                                                                                                                                        " + msrhEnter
					cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000001') OR CT2_DEBITO IN ('41201070000003','41201070000004','41201070000005') THEN '01'     " + msrhEnter
					cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000004') OR CT2_DEBITO IN ('41201070000013','41201070000014','41201070000015') THEN '02'     " + msrhEnter
					cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000005') OR CT2_DEBITO IN ('41201070000023','41201070000024','41201070000025') THEN '03'     " + msrhEnter
					cSql += "			ELSE ''                                                                                                                                    " + msrhEnter
					cSql += "		 END                                                                                                                                           " + msrhEnter
					If CK003->ZN2_EMPORI $ "06/12"
						cSql += "	  ,VLR_0101 = ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41101030000001','41101030000003','41101030000004','41101030000005') THEN CT2_VALOR END),0)  " + msrhEnter
						cSql += "	  ,VLR_0102 = ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR END),0)                   " + msrhEnter
						cSql += "	  ,VLR_0103	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR END),0)                   " + msrhEnter
						cSql += "	  ,VLR_0104	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR END),0)                   " + msrhEnter
					Else
						cSql += "	  ,VLR_0101	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41101030000001') THEN CT2_VALOR END),0)                                                     " + msrhEnter
						cSql += "	  ,VLR_0102	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR END),0)                   " + msrhEnter
						cSql += "	  ,VLR_0103	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR END),0)                   " + msrhEnter
						cSql += "	  ,VLR_0104	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR END),0)                   " + msrhEnter
					EndIf
					cSql += " FROM CT2" + CK003->ZN2_EMPORI + "0                                                                                                                   " + msrhEnter
					cSql += " WHERE CT2_DATA BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "'                                                                         " + msrhEnter
					If CK003->ZN2_EMPORI <> CK003->ZN2_EMPDES
						cSql += "    AND (CT2_ITEMC = 'EMP" + CK003->ZN2_EMPDES + "01" + nTD + "' OR CT2_ITEMD = 'EMP" + CK003->ZN2_EMPDES + "01" + nTD + "' )                     " + msrhEnter
					EndIf
					cSql += "    AND CT2_LOTE <> '888888'                                                                                                                          " + msrhEnter
					cSql += "    AND D_E_L_E_T_ = ''                                                                                                                               " + msrhEnter
					cSql += " GROUP BY CT2_CREDIT, CT2_DEBITO, SUBSTRING(CT2_DATA,1,6)) TMP                                                                                        " + msrhEnter
					cSql += " WHERE FIL <> ''                                                                                                                                      " + msrhEnter
					cSql += " GROUP BY FIL, MESANO, GRUPO                                                                                                                          " + msrhEnter
					cSql += " ORDER BY FIL, MESANO, GRUPO                                                                                                                          " + msrhEnter
					If chkfile("_PPC_R")
						dbSelectArea("_PPC_R")
						dbCloseArea()
					EndIf
					TcQuery cSql New Alias "_PPC_R"

					//Grava as informações do PPC - RECEITA
					While  !_PPC_R->(EOF())

						IncProc("Processa RECEITA -> " + EC007->ZN1_DESEMP )

						//Receita
						GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.01', CK003->ZN2_CUSIMP, _PPC_R->VLR_0101})
						TcSQLExec(cSql)

						//ICMS
						GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.02', CK003->ZN2_CUSIMP, _PPC_R->VLR_0102})
						TcSQLExec(cSql)

						//PIS
						GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.03', CK003->ZN2_CUSIMP, _PPC_R->VLR_0103})
						TcSQLExec(cSql)

						//COFINS
						GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.04', CK003->ZN2_CUSIMP, _PPC_R->VLR_0104})
						TcSQLExec(cSql)

						If CK003->ZN2_DIFPIS > 0
							//Diferencial de PIS
							GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.05', CK003->ZN2_CUSIMP, _PPC_R->VLR_0101 * CK003->ZN2_DIFPIS})
							TcSQLExec(cSql)
						EndIf

						If CK003->ZN2_DIFCOF > 0
							//Diferencial de COFINS
							GrvZN4T({CK003->ZN2_EMPORI, _PPC_R->FIL, CK003->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.06', CK003->ZN2_CUSIMP, _PPC_R->VLR_0101 * CK003->ZN2_DIFCOF})
							TcSQLExec(cSql)
						EndIf

						_PPC_R->(dbSkip())

					End

					nTD := ""
					//Deducoes
					cSql := " SELECT SUBSTRING(CT2_DATA,1,6) MESANO,                                                                                                 " + msrhEnter
					cSql += "        'SER' GRUPO                                                                                                                     " + msrhEnter
					If CK003->ZN2_EMPORI $ "06/12"
						cSql += "	  ,VLR_0201 = ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000011') THEN CT2_VALOR*-1 END),0)                                    " + msrhEnter
						cSql += "	  ,VLR_0202 = ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR*-1 END),0)  " + msrhEnter
						cSql += "	  ,VLR_0203	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR*-1 END),0)  " + msrhEnter
						cSql += "	  ,VLR_0204	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR*-1 END),0)  " + msrhEnter
					Else
						cSql += "	  ,VLR_0201	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000011') THEN CT2_VALOR END),0)                                       " + msrhEnter
						cSql += "	  ,VLR_0202	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR*-1 END),0)  " + msrhEnter
						cSql += "	  ,VLR_0203	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR*-1 END),0)  " + msrhEnter
						cSql += "	  ,VLR_0204	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR*-1 END),0)  " + msrhEnter
					EndIf
					cSql += " FROM CT2" + CK003->ZN2_EMPORI + "0                                                                                                     " + msrhEnter
					cSql += " WHERE CT2_DATA BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "'                                                           " + msrhEnter
					If CK003->ZN2_EMPORI <> CK003->ZN2_EMPDES
						cSql += "    AND (CT2_ITEMC = 'EMP" + CK003->ZN2_EMPDES + "01" + nTD + "' OR CT2_ITEMD = 'EMP" + CK003->ZN2_EMPDES + "01" + nTD + "' )       " + msrhEnter
					EndIf
					cSql += "    AND CT2_LOTE <> '888888'                                                                                                            " + msrhEnter
					cSql += "    AND D_E_L_E_T_ = ''                                                                                                                 " + msrhEnter
					cSql += " GROUP BY SUBSTRING(CT2_DATA,1,6)                                                                                                       " + msrhEnter
					If chkfile("_PPC_D")
						dbSelectArea("_PPC_D")
						dbCloseArea()
					EndIf
					TcQuery cSql New Alias "_PPC_D"

					//Grava as informações do PPC - DEDUCOES
					While  !_PPC_D->(EOF())

						IncProc("Processa DEDUCOES -> " + EC007->ZN1_DESEMP )

						//Devolucao
						GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.01', CK003->ZN2_CUSIMP, _PPC_D->VLR_0201})
						TcSQLExec(cSql)

						//ICMS
						GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.02', CK003->ZN2_CUSIMP, _PPC_D->VLR_0202})
						TcSQLExec(cSql)

						//PIS
						GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.03', CK003->ZN2_CUSIMP, _PPC_D->VLR_0203})
						TcSQLExec(cSql)

						//COFINS
						GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.04', CK003->ZN2_CUSIMP, _PPC_D->VLR_0204})
						TcSQLExec(cSql)

						If CK003->ZN2_DIFPIS > 0
							//Diferencial de PIS
							GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.05', CK003->ZN2_CUSIMP, _PPC_D->VLR_0201 * CK003->ZN2_DIFPIS})
							TcSQLExec(cSql)
						EndIf

						If CK003->ZN2_DIFCOF > 0
							//Diferencial de COFINS
							GrvZN4T({CK003->ZN2_EMPORI, '01', CK003->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.05', CK003->ZN2_CUSIMP, _PPC_D->VLR_0201 * CK003->ZN2_DIFCOF})
							TcSQLExec(cSql)
						EndIf

						_PPC_D->(dbSkip())

					End

				EndIf

			EndIf

			CK003->(dbSkip())

		End

		EC007->(dbSkip())

	End

	EC007->(dbCloseArea())
	CK003->(dbCloseArea())

	Msgbox("CÁLCULO das planilhas finalizadas com sucesso.", "BIAFG150", "INFO")

Return

Static Function GrvZN4T( msVetVal )

	RecLock("ZN4",.T.)

	ZN4->ZN4_FILIAL  := xFilial("ZN4")
	ZN4->ZN4_EMPORI  := msVetVal[1]
	ZN4->ZN4_FIL     := msVetVal[2]
	ZN4->ZN4_EMPDES  := msVetVal[3]
	ZN4->ZN4_MESANO  := msVetVal[4]
	ZN4->ZN4_TPPROD  := msVetVal[5]
	ZN4->ZN4_TPCTB   := msVetVal[6]
	ZN4->ZN4_TPVAL   := msVetVal[7]
	ZN4->ZN4_CUSIMP  := msVetVal[8]
	ZN4->ZN4_VALOR   := msVetVal[9]

	MsUnlock()

Return

User Function BFG150N()

	Local oProcess
	Local nW	:= 0
	Local oEmp 	:= Nil
	Local lRet           := .T.	

	Private xVerRet      := .T.
	Private msStaExcQy   := 0

	Private xStringFAT   := ""
	Private xStringCTB   := ""
	Private hhTmpINI

	Private msEmpAtu  := cEmpAnt
	Private msFilAtu  := cFilAnt
	Private msCanPrc  := .F.

	Private msErroQuery

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := ""
	Private xoSay1
	Private xoDlg

	MsgSTOP("A rotina será interrompida, pois ainda está em construção: é possível que seja retirada daqui e migrada para o programa BIA766")
	Return

	oEmp := TLoadEmpresa():New()

	If xValidPerg()

		dDataIni := stod(MV_PAR01 + '01')
		dDataFin := UltimoDia(stod(MV_PAR01 + '01'))

		//Chamada de tela para seleção da Empresa/Filial
		oEmp:GSEmpFil()		
		msArryEmp := oEmp:aEmpSel

		If Len(msArryEmp) > 0

			hhTmpINI  := TIME()

			RpcSetType(3)
			RpcSetEnv( cEmpAnt, cFilAnt )
			RpcClearEnv()

			RpcSetEnv( msEmpAtu, msFilAtu )
			oPrcZera := MsNewProcess():New({|lEnd| ExistThenD(@oPrcZera) }, "Deletando...", smMsnPrc, .T.)
			oPrcZera:Activate()
			lRet := xVerRet
			RpcClearEnv()

			If xVerRet

				For nW := 1 To Len(msArryEmp)

					RpcSetType(3)
					RpcSetEnv( msArryEmp[nW][1], Substr(msArryEmp[nW][2], 1, 2) )

					smMsnPrc := msArryEmp[nW][1] + "/" + Substr(msArryEmp[nW][2], 1, 2) + " - " + Alltrim(msArryEmp[nW][4])

					oProcess := MsNewProcess():New({|lEnd| aPrcG150(@oProcess) }, "Gravando...", smMsnPrc, .T.)
					oProcess:Activate()

					lRet := xVerRet

					If nW + 1 <= Len(msArryEmp)

						xStringFAT += Alltrim(" UNION ALL                                                                                                                                    ") + msrhEnter
						xStringCTB += Alltrim(" UNION ALL                                                                                                                                    ") + msrhEnter

					EndIf

					// processamento... implementar

					RpcClearEnv()

					If xVerRet

						Exit

					EndIf


				Next nW

			Else

				msCanPrc  := .F.

			EndIf

		Else

			msCanPrc  := .T.

		EndIf

	Else

		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		RpcSetEnv( msEmpAtu, msFilAtu )

		If Type("__cInternet") == "C"
			__cInternet := Nil
		EndIf

		If !lRet

			xcMultiGe1 := "Erro de Query: " + msrhEnter + msrhEnter + msErroQuery

			DEFINE MSDIALOG xoDlg TITLE "Atenção!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de Erro. Apanhe o erro e abra um ticket." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		Else

			BFG150QR()

		EndIf

	EndIf

Return

Static Function aPrcG150(oProcess)

	Local lRet := .T.

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(1000)             

	oProcess:IncRegua1(smMsnPrc)
	oProcess:IncRegua2("Gravando a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

	// String para obtenção dos dados oriundos do FATURAMENTO
	QR007 := Alltrim(" SELECT '" + cEmpAnt + "' EMPORI,                                                                                                             ") + msrhEnter
	QR007 += Alltrim("        D2_FILIAL FILORI,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        Z35_EMP EMPDES,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        Z35_FIL FILDES,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        'SAI' ORIGMOV,                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("        CLIENTE = D2_CLIENTE,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        LOJA = D2_LOJA,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        VALICM = D2_VALICM,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        VALIPI = D2_VALIPI,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        VALIMP6 = D2_VALIMP6,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        VALIMP5 = D2_VALIMP5,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        DOC = D2_DOC,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        SERIE = D2_SERIE,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        COD = D2_COD,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        GRUPO = B1_GRUPO,                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("        YTPPROD = B1_YTPPROD,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        EMISSAO = D2_EMISSAO,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        TIPO = D2_TIPO,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        CF = D2_CF,                                                                                                                           ") + msrhEnter
	QR007 += Alltrim("        CREDICM = F4_CREDICM,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        ICM = F4_ICM,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        LFICM = F4_LFICM,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        DUPLIC = F4_DUPLIC,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        QUANT = CASE                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("                    WHEN D2_TIPO = 'I'                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                         AND D2_ICMSRET > 0                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    WHEN F4_CREDICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_ICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_LFICM = 'T'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                         AND F4_DUPLIC = 'N'                                                                                                  ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    ELSE D2_QUANT                                                                                                             ") + msrhEnter
	QR007 += Alltrim("                END,                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("        VALOR = CASE                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("                    WHEN D2_TIPO = 'I'                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                         AND D2_ICMSRET > 0                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    WHEN F4_CREDICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_ICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_LFICM = 'T'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                         AND F4_DUPLIC = 'N'                                                                                                  ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    ELSE D2_TOTAL                                                                                                             ") + msrhEnter
	QR007 += Alltrim("                END,                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("        EST = D2_EST,                                                                                                                               ") + msrhEnter
	QR007 += Alltrim("        YCCONT = F4_YCCONT,                                                                                                                            ") + msrhEnter
	QR007 += Alltrim("        CTA_REC = CASE                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                      WHEN D2_EST = 'EX'                                                                                                      ") + msrhEnter
	QR007 += Alltrim("                      THEN Z6_CTRSVDE                                                                                                         ") + msrhEnter
	QR007 += Alltrim("                      WHEN F4_YCCONT = '560'                                                                                                  ") + msrhEnter
	QR007 += Alltrim("                      THEN Z6_CTASERV                                                                                                         ") + msrhEnter
	QR007 += Alltrim("                      ELSE Z6_CTRSVDI                                                                                                         ") + msrhEnter
	QR007 += Alltrim("                  END,                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("        CTA_IPI = Z6_CTAIPI,                                                                                                                  ") + msrhEnter
	QR007 += Alltrim("        CTA_ICM = Z6_CTAICMS,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        CTA_PIS = Z6_CTAPIS,                                                                                                                  ") + msrhEnter
	QR007 += Alltrim("        CTA_COF = Z6_CTACOF                                                                                                                   ") + msrhEnter
	QR007 += Alltrim(" FROM " + RetSqlName("SD2") + " SD2(NOLOCK)                                                                                                   ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SF4") + " SF4(NOLOCK) ON SF4.F4_FILIAL = SD2.D2_FILIAL                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND SF4.F4_CODIGO = SD2.D2_TES                                                                         ") + msrhEnter
	QR007 += Alltrim("                                       AND ((SF4.F4_CREDICM = 'S'                                                                             ") + msrhEnter
	QR007 += Alltrim("                                             AND SF4.F4_ICM = 'S'                                                                             ") + msrhEnter
	QR007 += Alltrim("                                             AND SF4.F4_LFICM = 'T'                                                                           ") + msrhEnter
	QR007 += Alltrim("                                             AND SF4.F4_DUPLIC = 'N'                                                                          ") + msrhEnter
	QR007 += Alltrim("                                             AND (SUBSTRING(SD2.D2_CF, 2, 1) IN('1', '4', '2')                                                ") + msrhEnter
	QR007 += Alltrim("                                                  OR SUBSTRING(SD2.D2_CF, 2, 3) = '923'))                                                     ") + msrhEnter
	QR007 += Alltrim("                                            OR SF4.F4_DUPLIC = 'S')                                                                           ") + msrhEnter
	QR007 += Alltrim("                                       AND SF4.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                                            ") + msrhEnter
	QR007 += Alltrim("                                       AND SB1.B1_COD = SD2.D2_COD                                                                            ") + msrhEnter
	QR007 += Alltrim("                                       AND SB1.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("Z35") + " Z35(NOLOCK) ON Z35_FILIAL = '" + xFilial("Z35") + "'                                               ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.Z35_CODCLI = SD2.D2_CLIENTE                                                                    ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.Z35_LOJCLI = SD2.D2_LOJA                                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND NOT Z35_TIPO IN('04', '05')                                                                        ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      LEFT JOIN " + RetSqlName("SZ6") + " SZ6(NOLOCK) ON SZ6.Z6_FILIAL = '" + xFilial("SZ6") + "'                                             ") + msrhEnter
	QR007 += Alltrim("                                       AND SZ6.Z6_TPPROD = SB1.B1_YTPPROD                                                                     ") + msrhEnter
	QR007 += Alltrim("                                       AND SZ6.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim(" WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'                                                                                               ") + msrhEnter
	QR007 += Alltrim("       AND SD2.D2_EMISSAO BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'                                                       ") + msrhEnter
	QR007 += Alltrim("       AND SD2.D2_TIPO <> 'D'                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("       AND SD2.D_E_L_E_T_ = ' '                                                                                                               ") + msrhEnter
	QR007 += Alltrim(" UNION ALL                                                                                                                                    ") + msrhEnter
	QR007 += Alltrim(" SELECT '" + cEmpAnt + "' EMPORI,                                                                                                             ") + msrhEnter
	QR007 += Alltrim("        D1_FILIAL FILORI,                                                                                                                     ") + msrhEnter	
	QR007 += Alltrim("        Z35_EMP EMPDES,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        Z35_FIL FILDES,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        'DEV' ORIGMOV,                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("        CLIENTE = D1_FORNECE,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        LOJA = D1_LOJA,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        VALICM = D1_VALICM,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        VALIPI = D1_VALIPI,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        VALIMP6 = D1_VALIMP6,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        VALIMP5 = D1_VALIMP5,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        DOC = D1_DOC,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        SERIE = D1_SERIE,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        COD = D1_COD,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        GRUPO = B1_GRUPO,                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("        YTPPROD = B1_YTPPROD,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        EMISSAO = D1_EMISSAO,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        TIPO = D1_TIPO,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        CF = D1_CF,                                                                                                                           ") + msrhEnter
	QR007 += Alltrim("        CREDICM = F4_CREDICM,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        ICM = F4_ICM,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        LFICM = F4_LFICM,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        DUPLIC = F4_DUPLIC,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        QUANT = CASE                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("                    WHEN D1_TIPO = 'I'                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                         AND D1_ICMSRET > 0                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    WHEN F4_CREDICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_ICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_LFICM = 'T'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                         AND F4_DUPLIC = 'N'                                                                                                  ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    ELSE D1_QUANT                                                                                                             ") + msrhEnter
	QR007 += Alltrim("                END,                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("        VALOR = CASE                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("                    WHEN D1_TIPO = 'I'                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                         AND D1_ICMSRET > 0                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    WHEN F4_CREDICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_ICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_LFICM = 'T'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                         AND F4_DUPLIC = 'N'                                                                                                  ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    ELSE D1_TOTAL                                                                                                             ") + msrhEnter
	QR007 += Alltrim("                END,                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("        EST = D2_EST,                                                                                                                               ") + msrhEnter
	QR007 += Alltrim("        YCCONT = F4_YCCONT,                                                                                                                            ") + msrhEnter
	QR007 += Alltrim("        CTA_REC = ISNULL(Z6_CTARSDV, ''),                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        CTA_IPI = ISNULL(Z6_CTIPIDV, ''),                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        CTA_ICM = ISNULL(Z6_CTICMDV, ''),                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        CTA_PIS = ISNULL(Z6_CTPISDV, ''),                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        CTA_COF = ISNULL(Z6_CTCOFDV, '')                                                                                                      ") + msrhEnter
	QR007 += Alltrim(" FROM " + RetSqlName("SD1") + " SD1(NOLOCK)                                                                                                   ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SD2") + " SD2(NOLOCK) ON SD2.D2_FILIAL = SD1.D1_FILIAL                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D2_DOC = SD1.D1_NFORI                                                                          ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D2_ITEM = SD1.D1_ITEMORI                                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D2_SERIE = SD1.D1_SERIORI                                                                      ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D2_CLIENTE = SD1.D1_FORNECE                                                                    ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D2_LOJA = SD1.D1_LOJA                                                                          ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SF4") + " SF4(NOLOCK) ON SF4.F4_FILIAL = SD1.D1_FILIAL                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND SF4.F4_CODIGO = SD2.D2_TES                                                                         ") + msrhEnter
	QR007 += Alltrim("                                       AND SF4.F4_DUPLIC = 'S'                                                                                ") + msrhEnter
	QR007 += Alltrim("                                       AND SF4.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SF1") + " SF1(NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND SF1.F1_DOC = SD1.D1_DOC                                                                            ") + msrhEnter
	QR007 += Alltrim("                                       AND SF1.F1_SERIE = SD1.D1_SERIE                                                                        ") + msrhEnter
	QR007 += Alltrim("                                       AND SF1.F1_FORNECE = SD1.D1_FORNECE                                                                    ") + msrhEnter
	QR007 += Alltrim("                                       AND SF1.F1_LOJA = SD1.D1_LOJA                                                                          ") + msrhEnter
	QR007 += Alltrim("                                       AND SF1.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                                            ") + msrhEnter
	QR007 += Alltrim("                                       AND SB1.B1_COD = SD1.D1_COD                                                                            ") + msrhEnter
	QR007 += Alltrim("                                       AND SB1.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("Z35") + " Z35(NOLOCK) ON Z35_FILIAL = '" + xFilial("Z35") + "'                                               ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.Z35_CODCLI = SD2.D2_CLIENTE                                                                    ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.Z35_LOJCLI = SD2.D2_LOJA                                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND NOT Z35_TIPO IN('04', '05')                                                                        ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      LEFT JOIN " + RetSqlName("SZ6") + " SZ6(NOLOCK) ON SZ6.Z6_FILIAL = '" + xFilial("SZ6") + "'                                             ") + msrhEnter
	QR007 += Alltrim("                                       AND SZ6.Z6_TPPROD = SB1.B1_YTPPROD                                                                     ") + msrhEnter
	QR007 += Alltrim("                                       AND SZ6.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim(" WHERE SD1.D1_FILIAL = '" + xFilial("SD1")+ "'                                                                                                ") + msrhEnter
	QR007 += Alltrim("       AND SD1.D1_DTDIGIT BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'                                                       ") + msrhEnter
	QR007 += Alltrim("       AND SD1.D1_TIPO = 'D'                                                                                                                  ") + msrhEnter
	QR007 += Alltrim("       AND SD1.D_E_L_E_T_ = ' '                                                                                                               ") + msrhEnter

	xStringFAT += QR007

	// String para obtenção dos dados oriundos do CONTABIL
	QR004 := Alltrim(" SELECT EMPORI = '" + cEmpAnt + "',                                                                            ") + msrhEnter
	QR004 += Alltrim("        FILORI = CT2_FILIAL,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        EMPDES = SUBSTRING(CT2_ITEMD, 4, 2),                                                                   ") + msrhEnter
	QR004 += Alltrim("        FILDES = SUBSTRING(CT2_ITEMD, 6, 2),                                                                   ") + msrhEnter
	QR004 += Alltrim("        DTREF = CT2_DATA,                                                                                      ") + msrhEnter
	QR004 += Alltrim("        DC = 'DEB',                                                                                            ") + msrhEnter
	QR004 += Alltrim("        CONTA = CT2_DEBITO,                                                                                    ") + msrhEnter
	QR004 += Alltrim("        ITCONTA = CT2_ITEMD,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        VALOR = CT2_VALOR,                                                                                     ") + msrhEnter
	QR004 += Alltrim("        HISTORIC = CT2_HIST,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        ROTINA = CT2_ROTINA                                                                                    ") + msrhEnter
	QR004 += Alltrim(" FROM " + RetSqlName("CT2") + " CT2(NOLOCK)                                                                    ") + msrhEnter
	QR004 += Alltrim(" WHERE CT2_FILIAL = '" + xFilial("CT2") + "'                                                                   ") + msrhEnter
	QR004 += Alltrim("       AND CT2_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'                              ") + msrhEnter
	QR004 += Alltrim("       AND SUBSTRING(CT2_DEBITO, 1, 3) IN('411', '412')                                                        ") + msrhEnter
	QR004 += Alltrim(" AND NOT CT2_ROTINA IN('MATA460   ', 'MATA520   ', 'MATA103   ')                                               ") + msrhEnter
	QR004 += Alltrim(" AND CT2.D_E_L_E_T_ = ' '                                                                                      ") + msrhEnter
	QR004 += Alltrim(" UNION ALL                                                                                                     ") + msrhEnter
	QR004 += Alltrim(" SELECT EMPORI = '" + cEmpAnt + "',                                                                            ") + msrhEnter
	QR004 += Alltrim("        FILORI = CT2_FILIAL,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        EMPDES = SUBSTRING(CT2_ITEMC, 4, 2),                                                                   ") + msrhEnter
	QR004 += Alltrim("        FILDES = SUBSTRING(CT2_ITEMC, 6, 2),                                                                   ") + msrhEnter
	QR004 += Alltrim("        DTREF = CT2_DATA,                                                                                      ") + msrhEnter
	QR004 += Alltrim("        DC = 'CRD',                                                                                            ") + msrhEnter
	QR004 += Alltrim("        CONTA = CT2_CREDIT,                                                                                    ") + msrhEnter
	QR004 += Alltrim("        ITCONTA = CT2_ITEMC,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        VALOR = CT2_VALOR,                                                                                     ") + msrhEnter
	QR004 += Alltrim("        HISTORIC = CT2_HIST,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        ROTINA = CT2_ROTINA                                                                                    ") + msrhEnter
	QR004 += Alltrim(" FROM " + RetSqlName("CT2") + " CT2(NOLOCK)                                                                    ") + msrhEnter
	QR004 += Alltrim(" WHERE CT2_FILIAL = '" + xFilial("CT2") + "'                                                                   ") + msrhEnter
	QR004 += Alltrim("       AND CT2_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'                              ") + msrhEnter
	QR004 += Alltrim("       AND SUBSTRING(CT2_CREDIT, 1, 3) IN('411', '412')                                                        ") + msrhEnter
	QR004 += Alltrim(" AND NOT CT2_ROTINA IN('MATA460   ', 'MATA520   ', 'MATA103   ')                                               ") + msrhEnter
	QR004 += Alltrim(" AND CT2.D_E_L_E_T_ = ' '                                                                                      ") + msrhEnter

	xStringCTB += QR004

	// Carga de dados na nova tabela PPC - Por padrão o insert será realizado apenas na empresa 90.
	QR009 := Alltrim(" INSERT INTO ZNC900 (ZNC_FILIAL, ZNC_DATPRC, ZNC_EMPORI, ZNC_FILORI, ZNC_EMPDES, ZNC_FILDES, ZNC_TABMOV, ZNC_ORIMOV, ZNC_DATMOV, ZNC_DOC, ZNC_SERIE, ZNC_CODPRD, ZNC_TIPONF, ZNC_CFOP, ZNC_GRPPRD, ZNC_YTPPRO, ZNC_CRDICM, ZNC_CALICM, ZNC_LFICM, ZNC_DUPLIC, ZNC_YCCONT, ZNC_CLIENT, ZNC_LOJA, ZNC_ESTADO, ZNC_ITCTA, ZNC_HISLAN, ZNC_ROTINA, ZNC_QUANT, ZNC_CTACTB, ZNC_CTAREC, ZNC_CTAICM, ZNC_CTAPIS, ZNC_CTACOF, ZNC_CTAIPI, ZNC_VLRCTB, ZNC_VLRREC, ZNC_VLRICM, ZNC_VLRPIS, ZNC_VLRCOF, ZNC_VLRIPI, D_E_L_E_T_, R_E_C_N_O_, R_E_C_D_E_L_)   ") + msrhEnter
	QR009 += Alltrim(" SELECT ZNC_FILIAL = '  ',                                                                                                                                                                                            ") + msrhEnter
	QR009 += Alltrim("        ZNC_DATPRC = '" + dtos(dDataFin) + "',                                                                                                                                                                        ") + msrhEnter
	QR009 += Alltrim("        ZNC_EMPORI = EMPORI,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_FILORI = FILORI,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_EMPDES = EMPDES,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_FILDES = FILDES,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_TABMOV = 'FAT',                                                                                                                                                                                           ") + msrhEnter
	QR009 += Alltrim("        ZNC_ORIMOV = ORIGMOV,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_DATMOV = EMISSAO,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_DOC = DOC,                                                                                                                                                                                                ") + msrhEnter
	QR009 += Alltrim("        ZNC_SERIE = SERIE,                                                                                                                                                                                            ") + msrhEnter
	QR009 += Alltrim("        ZNC_CODPRD = COD,                                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_TIPONF = TIPO,                                                                                                                                                                                            ") + msrhEnter
	QR009 += Alltrim("        ZNC_CFOP = CF,                                                                                                                                                                                                ") + msrhEnter
	QR009 += Alltrim("        ZNC_GRPPRD = GRUPO,                                                                                                                                                                                           ") + msrhEnter
	QR009 += Alltrim("        ZNC_YTPPRO = YTPPROD,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_CRDICM = CREDICM,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_CALICM = ICM,                                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_LFICM = LFICM,                                                                                                                                                                                            ") + msrhEnter
	QR009 += Alltrim("        ZNC_DUPLIC = DUPLIC,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_YCCONT = YCCONT,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_CLIENT = CLIENTE,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_LOJA = LOJA,                                                                                                                                                                                              ") + msrhEnter
	QR009 += Alltrim("        ZNC_ESTADO = EST,                                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_ITCTA = '',                                                                                                                                                                                               ") + msrhEnter
	QR009 += Alltrim("        ZNC_HISLAN = '',                                                                                                                                                                                              ") + msrhEnter
	QR009 += Alltrim("        ZNC_ROTINA = '',                                                                                                                                                                                              ") + msrhEnter
	QR009 += Alltrim("        ZNC_QUANT = QUANT,                                                                                                                                                                                            ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTACTB = '',                                                                                                                                                                                              ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTAREC = CTA_REC,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTAICM = CTA_ICM,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTAPIS = CTA_PIS,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTACOF = CTA_COF,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTAIPI = CTA_IPI,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRCTB = 0,                                                                                                                                                                                               ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRREC = VALOR,                                                                                                                                                                                           ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRICM = VALICM,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRPIS = VALIMP6,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRCOF = VALIMP5,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRIPI = VALIPI,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        D_E_L_E_T_ = ' ',                                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        R_E_C_N_O_ = (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM ZNC900) + ROW_NUMBER() OVER(ORDER BY EMPORI),                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        R_E_C_D_E_L_ = 0                                                                                                                                                                                              ") + msrhEnter
	QR009 += Alltrim(" FROM                                                                                                                                                                                                                 ") + msrhEnter
	QR009 += Alltrim(" (                                                                                                                                                                                                                    ") + msrhEnter
	QR009 += QR007
	QR009 += Alltrim(" ) AS TEMP1                                                                                                                                                                                                           ") + msrhEnter
	U_BIAMsgRun("Aguarde... Gravando Registros FAT... ",,{|| msStaExcQy := TcSQLExec(QR009) })

	If msStaExcQy < 0
		lRet := .F.
	EndIf

	If !lRet

		msErroQuery := TCSQLError()

	Else

		QR009 := Alltrim(" INSERT INTO ZNC900 (ZNC_FILIAL, ZNC_DATPRC, ZNC_EMPORI, ZNC_FILORI, ZNC_EMPDES, ZNC_FILDES, ZNC_TABMOV, ZNC_ORIMOV, ZNC_DATMOV, ZNC_DOC, ZNC_SERIE, ZNC_CODPRD, ZNC_TIPONF, ZNC_CFOP, ZNC_GRPPRD, ZNC_YTPPRO, ZNC_CRDICM, ZNC_CALICM, ZNC_LFICM, ZNC_DUPLIC, ZNC_YCCONT, ZNC_CLIENT, ZNC_LOJA, ZNC_ESTADO, ZNC_ITCTA, ZNC_HISLAN, ZNC_ROTINA, ZNC_QUANT, ZNC_CTACTB, ZNC_CTAREC, ZNC_CTAICM, ZNC_CTAPIS, ZNC_CTACOF, ZNC_CTAIPI, ZNC_VLRCTB, ZNC_VLRREC, ZNC_VLRICM, ZNC_VLRPIS, ZNC_VLRCOF, ZNC_VLRIPI, D_E_L_E_T_, R_E_C_N_O_, R_E_C_D_E_L_)   ") + msrhEnter
		QR009 += Alltrim(" SELECT ZNC_FILIAL = '  ',                                                                                                                                                                                            ") + msrhEnter
		QR009 += Alltrim("        ZNC_DATPRC = '" + dtos(dDataFin) + "',                                                                                                                                                                        ") + msrhEnter
		QR009 += Alltrim("        ZNC_EMPORI = EMPORI,                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_FILORI = FILORI,                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_EMPDES = EMPDES,                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_FILDES = FILDES,                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_TABMOV = 'CTB',                                                                                                                                                                                           ") + msrhEnter
		QR009 += Alltrim("        ZNC_ORIMOV = DC,                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_DATMOV = DTREF,                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_DOC = '',                                                                                                                                                                                                ") + msrhEnter
		QR009 += Alltrim("        ZNC_SERIE = '',                                                                                                                                                                                            ") + msrhEnter
		QR009 += Alltrim("        ZNC_CODPRD = '',                                                                                                                                                                                             ") + msrhEnter
		QR009 += Alltrim("        ZNC_TIPONF = '',                                                                                                                                                                                            ") + msrhEnter
		QR009 += Alltrim("        ZNC_CFOP = '',                                                                                                                                                                                                ") + msrhEnter
		QR009 += Alltrim("        ZNC_GRPPRD = '',                                                                                                                                                                                           ") + msrhEnter
		QR009 += Alltrim("        ZNC_YTPPRO = '',                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_CRDICM = '',                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_CALICM = '',                                                                                                                                                                                             ") + msrhEnter
		QR009 += Alltrim("        ZNC_LFICM = '',                                                                                                                                                                                            ") + msrhEnter
		QR009 += Alltrim("        ZNC_DUPLIC = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_YCCONT = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_CLIENT = '',                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_LOJA = '',                                                                                                                                                                                              ") + msrhEnter
		QR009 += Alltrim("        ZNC_ESTADO = '',                                                                                                                                                                                             ") + msrhEnter
		QR009 += Alltrim("        ZNC_ITCTA = ITCONTA,                                                                                                                                                                                               ") + msrhEnter
		QR009 += Alltrim("        ZNC_HISLAN = HISTORIC,                                                                                                                                                                                              ") + msrhEnter
		QR009 += Alltrim("        ZNC_ROTINA = ROTINA,                                                                                                                                                                                              ") + msrhEnter
		QR009 += Alltrim("        ZNC_QUANT = 0,                                                                                                                                                                                            ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTACTB = CONTA,                                                                                                                                                                                              ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTAREC = '',                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTAICM = '',                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTAPIS = '',                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTACOF = '',                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTAIPI = '',                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRCTB = VALOR,                                                                                                                                                                                               ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRREC = 0,                                                                                                                                                                                           ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRICM = 0,                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRPIS = 0,                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRCOF = 0,                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRIPI = 0,                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        D_E_L_E_T_ = ' ',                                                                                                                                                                                             ") + msrhEnter
		QR009 += Alltrim("        R_E_C_N_O_ = (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM ZNC900) + ROW_NUMBER() OVER(ORDER BY EMPORI),                                                                                                             ") + msrhEnter
		QR009 += Alltrim("        R_E_C_D_E_L_ = 0                                                                                                                                                                                              ") + msrhEnter
		QR009 += Alltrim(" FROM                                                                                                                                                                                                                 ") + msrhEnter
		QR009 += Alltrim(" (                                                                                                                                                                                                                    ") + msrhEnter
		QR009 += QR004
		QR009 += Alltrim(" ) AS TEMP1                                                                                                                                                                                                           ") + msrhEnter
		U_BIAMsgRun("Aguarde... Gravando Registros CTB... ",,{|| msStaExcQy := TcSQLExec(QR009) })

		If msStaExcQy < 0
			lRet := .F.
		EndIf

		If !lRet

			msErroQuery := TCSQLError()

		EndIf

	EndIf

	xVerRet := lRet 

Return ( lRet )

Static Function BFG150QR()

	Local oMultiGe1
	Local oMultiGe2
	Local oSay1
	Local oSay2
	Local oButton1
	Local oButton2
	Local oButton3

	Private cMultiGe1 := xStringFAT
	Private cMultiGe2 := xStringCTB
	Private GMToDlg

	DEFINE MSDIALOG GMToDlg TITLE "Consulta Querys" FROM 000, 000  TO 500, 1025 COLORS 0, 16777215 PIXEL

	@ 031, 005 GET oMultiGe1 VAR cMultiGe1 OF GMToDlg MULTILINE SIZE 150, 212 COLORS 0, 16777215 HSCROLL PIXEL
	@ 031, 159 GET oMultiGe2 VAR cMultiGe2 OF GMToDlg MULTILINE SIZE 150, 212 COLORS 0, 16777215 HSCROLL PIXEL

	@ 022, 006 SAY oSay1 PROMPT "FAT" SIZE 030, 007 OF GMToDlg COLORS 0, 16777215 PIXEL
	@ 022, 161 SAY oSay2 PROMPT "CTB" SIZE 025, 007 OF GMToDlg COLORS 0, 16777215 PIXEL

	@ 031, 469 BUTTON oButton1 PROMPT "Fecha"     SIZE 037, 012 OF GMToDlg ACTION GMToDlg:End() PIXEL
	@ 046, 469 BUTTON oButton2 PROMPT "Excel FAT" SIZE 037, 012 OF GMToDlg ACTION fExcFAT() PIXEL
	@ 061, 469 BUTTON oButton3 PROMPT "Excel CTB" SIZE 037, 012 OF GMToDlg ACTION fExcCTB() PIXEL

	ACTIVATE MSDIALOG GMToDlg CENTERED

Return

Static Function fExcFAT()

	Local msrhEnter    := CHR(13) + CHR(10)

	Local nRegAtu    := 0
	Local cCab1Fon   := 'Calibri' 
	Local cCab1TamF  := 8   
	Local cCab1CorF  := '#FFFFFF'
	Local cCab1Fun   := '#4F81BD'

	Local cFonte1	 := 'Arial'
	Local nTamFont1	 := 12   
	Local cCorFont1  := '#FFFFFF'
	Local cCorFun1	 := '#4F81BD'

	Local cFonte2	 := 'Arial'
	Local nTamFont2	 := 8   
	Local cCorFont2  := '#000000'
	Local cCorFun2	 := '#B8CCE4'

	Local cEmpresa   := ""
	Local msVetColun := 32
	Local msNomeFunc := "BiaFg150fat" 

	Local cArqXML    := UPPER(Alltrim(msNomeFunc)) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	Private cDirDest := "c:\temp\"

	OpenSm0()
	SM0->(DbGoTo(nRecSM0)) 

	cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio", {20, 70, 70, 70, 70, 150, 50, 150, 60, 60}, 6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, (1 + msVetColun + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, (1 + msVetColun + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Orçamento - " + msNomeFunc, 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, (1 + msVetColun + 1) - 3 )  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("EMPORI"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FILORI"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("EMPDES"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FILDES"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ORIGMOV"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CLIENTE"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("LOJA"               , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VALICM"             , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VALIPI"             , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VALIMP6"            , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VALIMP5"            , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DOC"                , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("SERIE"              , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("COD"                , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("GRUPO"              , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("YTPPROD"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("EMISSAO"            , 0, "C", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TIPO"               , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CF"                 , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CREDICM"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ICM"                , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("LFICM"              , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DUPLIC"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("QUANT"              , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VALOR"              , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("EST"                , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("YCCONT"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CTA_REC"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CTA_IPI"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CTA_ICM"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CTA_PIS"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CTA_COF"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

	QPIndex := CriaTrab(Nil,.f.)

	lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,xStringFAT),'QP001',.T.,.T.) },,.T.,,)
	If !lEvalBlock
		msErroQuery := "Problema: " + msrhEnter + msrhEnter
		msErroQuery += xStringFAT
		lRet := .F.
		Return
	EndIf

	dbSelectArea("QP001")
	dbGoTop()

	While !QP001->(Eof())

		nRegAtu++
		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()
		oExcel:AddCelula( QP001->EMPORI                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->FILORI                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->EMPDES                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->FILDES                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ORIGMOV                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CLIENTE                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->LOJA                       , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->VALICM                     , 0 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->VALIPI                     , 0 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->VALIMP6                    , 0 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->VALIMP5                    , 0 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->DOC                        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->SERIE                      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->COD                        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->GRUPO                      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->YTPPROD                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( dtoc(stod(QP001->EMISSAO))        , 0 , "C", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->TIPO                       , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CF                         , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CREDICM                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ICM                        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->LFICM                      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->DUPLIC                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->QUANT                      , 0 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->VALOR                      , 0 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->EST                        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->YCCONT                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CTA_REC                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CTA_IPI                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CTA_ICM                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CTA_PIS                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CTA_COF                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)

		QP001->(dbSkip())

	End

	QP001->(dbCloseArea())
	Ferase(QPIndex+GetDBExtension())
	Ferase(QPIndex+OrdBagExt())

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

Return

Static Function fExcCTB()

	Local msrhEnter    := CHR(13) + CHR(10)

	Local nRegAtu    := 0
	Local cCab1Fon   := 'Calibri' 
	Local cCab1TamF  := 8   
	Local cCab1CorF  := '#FFFFFF'
	Local cCab1Fun   := '#4F81BD'

	Local cFonte1	 := 'Arial'
	Local nTamFont1	 := 12   
	Local cCorFont1  := '#FFFFFF'
	Local cCorFun1	 := '#4F81BD'

	Local cFonte2	 := 'Arial'
	Local nTamFont2	 := 8   
	Local cCorFont2  := '#000000'
	Local cCorFun2	 := '#B8CCE4'

	Local cEmpresa   := ""
	Local msVetColun := 11
	Local msNomeFunc := "BiaFg150ctb" 

	Local cArqXML    := UPPER(Alltrim(msNomeFunc)) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	Private cDirDest := "c:\temp\"

	OpenSm0()
	SM0->(DbGoTo(nRecSM0)) 

	cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio", {20, 70, 70, 70, 70, 150, 50, 150, 60, 60}, 6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, (1 + msVetColun + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, (1 + msVetColun + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Orçamento - " + msNomeFunc, 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, (1 + msVetColun + 1) - 3 )  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("EMPORI"                           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FILORI"                           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("EMPDES"                           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FILDES"                           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DTREF"                            , 0, "C", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DC"                               , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CONTA"                            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ITCONTA"                          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VALOR"                            , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("HISTORIC"                         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ROTINA"                           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

	QPIndex := CriaTrab(Nil,.f.)

	lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,xStringFAT),'QP001',.T.,.T.) },,.T.,,)
	If !lEvalBlock
		msErroQuery := "Problema: " + msrhEnter + msrhEnter
		msErroQuery += xStringFAT
		lRet := .F.
		Return
	EndIf

	dbSelectArea("QP001")
	dbGoTop()

	While !QP001->(Eof())

		nRegAtu++
		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()
		oExcel:AddCelula( QP001->EMPORI                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->FILORI                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->EMPDES                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->FILDES                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( dtoc(stod(QP001->DTREF))          , 0 , "C", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->DC                         , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CONTA                      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ITCONTA                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->VALOR                      , 0 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->HISTORIC                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ROTINA                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)

		QP001->(dbSkip())

	End

	QP001->(dbCloseArea())
	Ferase(QPIndex+GetDBExtension())
	Ferase(QPIndex+OrdBagExt())

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

Return

Static Function ExistThenD(oPrcZera)

	Local cSQL  := ""
	Local cQry  := ""
	Local lRet  := .T.

	If fExistTabl(RetSqlName("ZNC"))

		cQry := GetNextAlias()

		cSql := " DELELE ZNC "
		cSql += " FROM " + RetSqlName("ZNC") + " ZNC (NOLOCK) "
		cSql += " WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "' "
		cSql += "       AND ZNC_DATPRC = '" + dtos(dDataFin) + "' "
		cSql += "       AND ZNC.D_E_L_E_T_    = ' ' "
		U_BIAMsgRun("Aguarde... Gravando Registros CTB... ",,{|| msStaExcQy := TcSQLExec(cSql) })

		If msStaExcQy < 0
			lRet := .F.
		EndIf

		If !lRet

			msErroQuery := TCSQLError()

		EndIf

	Else

		msErroQuery := "Empresa: " + cEmpAnt + msrhEnter + msrhEnter
		msErroQuery += "Filial: " + cFilAnt + msrhEnter + msrhEnter
		msErroQuery += "A tabela ZNC não está configurada para este empresa. Favor Verificar."
		lRet := .F.

	EndIf

	xVerRet := lRet 

Return ( lRet )

Static Function fExistTabl(cTabl)

	Local cSQL  := ""
	Local cQry  := ""
	Local lRet  := .F.

	cQry := GetNextAlias()

	cSql := " SELECT COUNT(*) CONTAD
	cSql += " FROM INFORMATION_SCHEMA.TABLES
	cSql += " WHERE TABLE_NAME = '" + cTabl + "';

	TcQuery cSQL New Alias (cQry)

	If (cQry)->CONTAD > 0
		lRet := .T.
	EndIf

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

Static Function xValidPerg()

	local cLoad	    := "BIAFG150" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(06)

	aAdd( aPergs ,{1, "Ano/Mês"          ,MV_PAR01 ,"@R 9999/99"  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Processa GMT",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet

