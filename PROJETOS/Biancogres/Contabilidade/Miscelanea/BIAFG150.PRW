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

	PRIVATE cCadastro	:=	"Planilha para Consolidação dos Expurgos"

	Private msrhEnter   := CHR(13) + CHR(10)
	Private msStaExcQy  := 0
	Private mslOk       := .T.
	Private msGravaErr  := ""

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
	aAdd( aRotina, { 'Incluir'       , 'AxInclui' , 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'       , 'AxAltera' , 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'       , 'AxDeleta' , 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Processar PPC' , 'U_BFG150A', 0, 3, 0, NIL } )

Return aRotina

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

	cAliasEMP_COL := GetNextAlias()
	BeginSql Alias cAliasEMP_COL

		SELECT *,
		(
		SELECT COUNT(*)
		FROM %TABLE:ZN1% ZN1(NOLOCK)
		WHERE D_E_L_E_T_ = ' '
		) REGS
		FROM %TABLE:ZN1% ZN1(NOLOCK)
		WHERE D_E_L_E_T_ = ' '
		ORDER BY ZN1_CODEMP

	EndSql

	ProcRegua((cAliasEMP_COL)->REGS)
	While !(cAliasEMP_COL)->(EOF())

		IncProc("Calculando Operações da Empresa -> " + (cAliasEMP_COL)->ZN1_DESEMP )

		cSql := " SELECT ZN2_EMPORI, "
		cSql += "        ZN2_EMPDES, "
		cSql += "        ZN1_CODCLI, "
		cSql += "        ZN2_CUSIMP, "
		cSql += "        ZN2_DIFPIS, "
		cSql += "        ZN2_DIFCOF "
		cSql += " FROM " + RetSqlName("ZN1") + " ZN1(NOLOCK)"
		cSql += " INNER JOIN " + RetSqlName("ZN2") + " ZN2(NOLOCK) ON ZN2_EMPORI = '" + (cAliasEMP_COL)->ZN1_CODEMP + "' "
		cSql += "                      AND ZN2_EMPORI = ZN1_CODEMP "
		cSql += "                      AND ZN2.D_E_L_E_T_ = ' ' "
		cSql += " WHERE ZN1.D_E_L_E_T_ = ' ' "
		cSql += " GROUP BY ZN2_EMPORI, "
		cSql += "          ZN2_EMPDES, "
		cSql += "          ZN1_CODCLI, "
		cSql += "          ZN2_CUSIMP, "
		cSql += "          ZN2_DIFPIS, "
		cSql += "          ZN2_DIFCOF "
		cSql += " ORDER BY ZN2_EMPORI, "
		cSql += "          ZN2_EMPDES, "
		cSql += "          ZN1_CODCLI "
		If chkfile("OPER_COL")
			dbSelectArea("OPER_COL")
			dbCloseArea()
		EndIf
		TcQuery cSql New Alias "OPER_COL"

		While  !OPER_COL->(EOF())

			IncProc("Processa regras da empresa -> " + (cAliasEMP_COL)->ZN1_DESEMP )

			If !Empty(Alltrim(OPER_COL->ZN1_CODCLI))

				//Apura as informações do PPC - RECEITA
				cSql := "SELECT SUBSTRING(D2_EMISSAO,1,6) MESANO, B1_GRUPO GRUPO, SUM(VALOR) 'VLR_0101', SUM(D2_VALICM) 'VLR_0102', SUM(D2_VALIMP6) 'VLR_0103' , SUM(D2_VALIMP5) 'VLR_0104' " + msrhEnter
				cSql += "FROM 	(                                                                                                                                                           " + msrhEnter
				cSql += "		  SELECT QUANT  = CASE                                                                                                                                      " + msrhEnter
				cSql += "							WHEN D2_TIPO = 'I' AND D2_ICMSRET > 0 THEN 0                                                                                            " + msrhEnter
				cSql += "							WHEN F4_CREDICM = 'S' AND F4_ICM = 'S' AND F4_LFICM = 'T' AND F4_DUPLIC = 'N' THEN 0                                                    " + msrhEnter
				cSql += "						ELSE D2_TOTAL END,                                                                                                                          " + msrhEnter
				cSql += "				 VALOR  = CASE                                                                                                                                      " + msrhEnter
				cSql += "							WHEN D2_TIPO = 'I' AND D2_ICMSRET > 0 THEN 0                                                                                            " + msrhEnter
				cSql += "							WHEN F4_CREDICM = 'S' AND F4_ICM = 'S' AND F4_LFICM = 'T' AND F4_DUPLIC = 'N' THEN 0                                                    " + msrhEnter
				cSql += "						ELSE D2_TOTAL END,                                                                                                                          " + msrhEnter
				cSql += "				D2_CLIENTE, D2_VALICM, D2_VALIMP6, D2_VALIMP5, D2_DOC, D2_COD, D2_EMISSAO, D2_TIPO, D2_CF, F4_CREDICM, F4_ICM, F4_LFICM, F4_DUPLIC                  " + msrhEnter
				cSql += "		FROM SD2" + OPER_COL->ZN2_EMPORI + "0 D2, SF4" + OPER_COL->ZN2_EMPORI + "0 F4                                                                               " + msrhEnter
				cSql += "		WHERE D2.D2_FILIAL 	= '"+xFilial('SD2')+"'  AND                                                                                                             " + msrhEnter
				cSql += "		      D2.D2_TES    	= F4.F4_CODIGO			AND                                                                                                             " + msrhEnter
				cSql += "		      D2.D_E_L_E_T_	= ''					AND                                                                                                             " + msrhEnter
				cSql += "		      F4.D_E_L_E_T_	= ''                                                                                                                                    " + msrhEnter
				cSql += "					      )                                                                                                                                         " + msrhEnter
				cSql += "	  SD2 INNER JOIN SB1010 SB1 ON                                                                                                                                  " + msrhEnter
				cSql += "	  SD2.D2_COD = SB1.B1_COD                                                                                                                                       " + msrhEnter
				cSql += "WHERE SD2.D2_EMISSAO	>= '" + Dtos(MV_PAR01) + "' AND                                                                                                             " + msrhEnter
				cSql += "      SD2.D2_EMISSAO 	<= '" + Dtos(MV_PAR02) + "' AND                                                                                                             " + msrhEnter
				cSql += "      SB1.B1_GRUPO 	IN (SELECT ZN2_TPPROD FROM " + RetSqLName("ZN2") + " ZN2 WHERE ZN2_EMPORI = '" + OPER_COL->ZN2_EMPORI + "' ) AND                            " + msrhEnter
				If OPER_COL->ZN2_EMPORI <> OPER_COL->ZN2_EMPDES
					cSql += "      SD2.D2_CLIENTE 	IN (SELECT ZN1_CODCLI FROM " + RetSqLName("ZN2") + " ZN2, " + RetSqLName("ZN1") + " ZN1 WHERE ZN2_EMPDES = ZN1_CODEMP AND ZN2_EMPORI = '"+OPER_COL->ZN2_EMPORI+"' AND ZN2_EMPDES = '"+OPER_COL->ZN2_EMPDES+"') AND " + msrhEnter
				EndIf
				cSql += "      SD2.D2_TIPO      <> 'D'  				AND                                                                                                                 " + msrhEnter
				cSql += "      (                                                                                                                                                            " + msrhEnter
				cSql += "      (SD2.F4_CREDICM	= 'S'  					AND                                                                                                                 " + msrhEnter
				cSql += "	    SD2.F4_ICM		= 'S'  					AND                                                                                                                 " + msrhEnter
				cSql += "	    SD2.F4_LFICM	= 'T'  					AND                                                                                                                 " + msrhEnter
				cSql += "       SD2.F4_DUPLIC  	= 'N'  					AND                                                                                                                 " + msrhEnter
				cSql += "      ( SUBSTRING(SD2.D2_CF,2,1) IN ('1','4','2') OR SUBSTRING(SD2.D2_CF,2,3) = '923' )  ) OR SD2.F4_DUPLIC = 'S'                                                  " + msrhEnter
				cSql += "      ) 	AND                                                                                                                                                     " + msrhEnter
				cSql += "      SB1.D_E_L_E_T_ 	= ''                                                                                                                                        " + msrhEnter
				cSql += "GROUP BY SUBSTRING(D2_EMISSAO,1,6), B1_GRUPO                                                                                                                       " + msrhEnter
				cSql += "ORDER BY SUBSTRING(D2_EMISSAO,1,6), B1_GRUPO                                                                                                                       " + msrhEnter
				If chkfile("_PPC_R")
					dbSelectArea("_PPC_R")
					dbCloseArea()
				EndIf
				TcQuery cSql New Alias "_PPC_R"

				//Grava as informações do PPC - RECEITA
				While  !_PPC_R->(EOF())

					IncProc("Processa RECEITA -> " + (cAliasEMP_COL)->ZN1_DESEMP )

					//Receita
					GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.01', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0101})
					TcSQLExec(cSql)

					//ICMS
					GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.02', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0102})
					TcSQLExec(cSql)

					//PIS
					GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.03', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0103})
					TcSQLExec(cSql)

					//COFINS
					GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.04', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0104})
					TcSQLExec(cSql)

					If OPER_COL->ZN2_DIFPIS > 0
						//PIS
						GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.05', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0101*OPER_COL->ZN2_DIFPIS})
						TcSQLExec(cSql)
					EndIf

					If OPER_COL->ZN2_DIFCOF > 0
						//COFINS
						GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, '', '01.06', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0101*OPER_COL->ZN2_DIFCOF})
						TcSQLExec(cSql)
					EndIf

					_PPC_R->(dbSkip())

				End

				cSql := "SELECT SUBSTRING(D1_DTDIGIT,1,6) AS 'MESANO', B1_GRUPO AS 'GRUPO', SUM(D1_TOTAL-D1_VALDESC)*-1 'VLR_0201', SUM(D1_VALICM)*-1 'VLR_0202', SUM(D1_VALIMP6)*-1 'VLR_0203', SUM(D1_VALIMP5)*-1 'VLR_0204' " + msrhEnter
				cSql += "FROM SD1"+OPER_COL->ZN2_EMPORI+"0 SD1(NOLOCK) INNER JOIN SD2"+OPER_COL->ZN2_EMPORI+"0 SD2(NOLOCK) ON                                                                                                  " + msrhEnter
				cSql += "	SD1.D1_NFORI	= SD2.D2_DOC		AND                                                                                                                                                            " + msrhEnter
				cSql += "    SD1.D1_ITEMORI	= SD2.D2_ITEM		AND                                                                                                                                                            " + msrhEnter
				cSql += "    SD1.D1_SERIORI	= SD2.D2_SERIE		AND                                                                                                                                                            " + msrhEnter
				cSql += "    SD1.D1_FORNECE	= SD2.D2_CLIENTE	AND                                                                                                                                                            " + msrhEnter
				cSql += "    SD1.D1_LOJA		= SD2.D2_LOJA                                                                                                                                                                  " + msrhEnter
				cSql += "	INNER JOIN SF4"+OPER_COL->ZN2_EMPORI+"0 SF4(NOLOCK) ON                                                                                                                                             " + msrhEnter
				cSql += "    SD2.D2_TES      = SF4.F4_CODIGO                                                                                                                                                                   " + msrhEnter

				//Teste Robert/Fabio
				cSql += "	INNER JOIN SF1"+OPER_COL->ZN2_EMPORI+"0 SF1(NOLOCK) ON                                                                                                                                             " + msrhEnter
				cSql += "    SD1.D1_DOC		= SF1.F1_DOC		AND                                                                                                                                                            " + msrhEnter
				cSql += "    SD1.D1_SERIE	= SF1.F1_SERIE		AND                                                                                                                                                            " + msrhEnter
				cSql += "    SD1.D1_FORNECE	= SF1.F1_FORNECE                                                                                                                                                                   " + msrhEnter

				cSql += "	INNER JOIN SB1010 SB1(NOLOCK) ON                                                                                                                                                                   " + msrhEnter
				cSql += "    SD1.D1_COD      = SB1.B1_COD                                                                                                                                                                      " + msrhEnter
				cSql += "WHERE SD1.D1_FILIAL	= '"+xFilial('SD1')+"' 	AND                                                                                                                                                    " + msrhEnter
				cSql += "	   SD2.D2_FILIAL	= '"+xFilial('SD2')+"' 	AND                                                                                                                                                    " + msrhEnter
				cSql += "	   SF4.F4_FILIAL	= '"+xFilial('SF4')+"'	AND                                                                                                                                                    " + msrhEnter
				cSql += "	   SB1.B1_FILIAL	= '"+xFilial('SB1')+"'	AND                                                                                                                                                    " + msrhEnter
				cSql += "	   SD1.D1_DTDIGIT	>= '"+Dtos(MV_PAR01)+"' AND                                                                                                                                                    " + msrhEnter
				cSql += "      SD1.D1_DTDIGIT	<= '"+Dtos(MV_PAR02)+"' AND                                                                                                                                                    " + msrhEnter
				cSql += "      SB1.B1_GRUPO IN (SELECT ZN2_TPPROD FROM " + RetSqLName("ZN2") + " ZN2 WHERE ZN2_EMPORI = '"+OPER_COL->ZN2_EMPORI+"' ) AND                                                                       " + msrhEnter
				If OPER_COL->ZN2_EMPORI <> OPER_COL->ZN2_EMPDES
					cSql += "      SD1.D1_FORNECE 	IN (SELECT ZN1_CODCLI FROM " + RetSqLName("ZN2") + " ZN2, " + RetSqLName("ZN1") + " ZN1 WHERE ZN2_EMPDES = ZN1_CODEMP AND ZN2_EMPORI = '"+OPER_COL->ZN2_EMPORI+"' AND ZN2_EMPDES = '"+OPER_COL->ZN2_EMPDES+"') AND " + msrhEnter
				EndIf
				cSql += "      SD1.D1_TIPO		=  'D'  				AND                                                                                                                                                    " + msrhEnter
				cSql += "      SF4.F4_DUPLIC	=  'S'  				AND                                                                                                                                                    " + msrhEnter
				cSql += "      SF1.D_E_L_E_T_	=  ''   				AND                                                                                                                                                    " + msrhEnter
				cSql += "      SD1.D_E_L_E_T_	=  ''   				AND                                                                                                                                                    " + msrhEnter
				cSql += "      SD2.D_E_L_E_T_	=  ''   				AND                                                                                                                                                    " + msrhEnter
				cSql += "      SF4.D_E_L_E_T_	=  ''   				AND                                                                                                                                                    " + msrhEnter
				cSql += "      SB1.D_E_L_E_T_	=  ''                                                                                                                                                                          " + msrhEnter
				cSql += "GROUP BY SUBSTRING(D1_DTDIGIT,1,6), B1_GRUPO                                                                                                                                                          " + msrhEnter
				If chkfile("_PPC_D")
					dbSelectArea("_PPC_D")
					dbCloseArea()
				EndIf
				TcQuery cSql New Alias "_PPC_D"

				//Grava as informações do PPC - DEDUCOES
				While  !_PPC_D->(EOF())

					IncProc("Processa DEDUCOES -> " + (cAliasEMP_COL)->ZN1_DESEMP )

					//Devolucao
					GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.01', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0201})
					TcSQLExec(cSql)

					//ICMS
					GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.02', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0202})
					TcSQLExec(cSql)

					//PIS
					GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.03', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0203})
					TcSQLExec(cSql)

					//COFINS
					GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.04', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0204})
					TcSQLExec(cSql)

					If OPER_COL->ZN2_DIFPIS > 0
						//PIS
						GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.05', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0201*OPER_COL->ZN2_DIFPIS})
						TcSQLExec(cSql)
					EndIf

					If OPER_COL->ZN2_DIFCOF > 0
						//COFINS
						GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, '', '02.06', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0201*OPER_COL->ZN2_DIFCOF})
						TcSQLExec(cSql)
					EndIf

					_PPC_D->(dbSkip())

				End

			Else

				If OPER_COL->ZN2_EMPORI <> OPER_COL->ZN2_EMPDES

					For  n := 1 to 2

						If n == 1
							nTD := "C" //CUSTO
						Else
							nTD := "D" //DESPESA
						EndIf

						//Receitas
						cSql := "SELECT FIL, MESANO, GRUPO, SUM(VLR_0101) VLR_0101, SUM(VLR_0102) VLR_0102, SUM(VLR_0103) VLR_0103, SUM(VLR_0104) VLR_0104                            " + msrhEnter
						cSql += "FROM                                                                                                                                                 " + msrhEnter
						cSql += "(SELECT CT2_CREDIT, CT2_DEBITO, SUBSTRING(CT2_DATA,1,6) MESANO, 'SER' GRUPO                                                                                                                                                 " + msrhEnter
						cSql += "	,FIL = CASE                                                                                                                                       " + msrhEnter
						cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000001') OR CT2_DEBITO IN ('41201070000003','41201070000004','41201070000005') THEN '01'    " + msrhEnter
						cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000004') OR CT2_DEBITO IN ('41201070000013','41201070000014','41201070000015') THEN '02'    " + msrhEnter
						cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000005') OR CT2_DEBITO IN ('41201070000023','41201070000024','41201070000025') THEN '03'    " + msrhEnter
						cSql += "			ELSE ''                                                                                                                                   " + msrhEnter
						cSql += "		 END                                                                                                                                          " + msrhEnter
						If OPER_COL->ZN2_EMPORI == "06"
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
						cSql += "FROM CT2"+OPER_COL->ZN2_EMPORI+"0                                                                                                                    " + msrhEnter
						cSql += "WHERE CT2_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"'                                                                                 " + msrhEnter
						If OPER_COL->ZN2_EMPORI <> OPER_COL->ZN2_EMPDES
							cSql += "AND (CT2_ITEMC = 'EMP"+OPER_COL->ZN2_EMPDES+"01"+nTD+"' OR CT2_ITEMD = 'EMP"+OPER_COL->ZN2_EMPDES+"01"+nTD+"' )                                  " + msrhEnter
						EndIf
						cSql += "AND CT2_LOTE <> '888888'                                                                                                                             " + msrhEnter
						cSql += "AND D_E_L_E_T_ = ''                                                                                                                                  " + msrhEnter
						cSql += "GROUP BY CT2_CREDIT, CT2_DEBITO, SUBSTRING(CT2_DATA,1,6)) TMP                                                                                        " + msrhEnter
						cSql += "WHERE FIL <> ''                                                                                                                                      " + msrhEnter
						cSql += "GROUP BY FIL, MESANO, GRUPO                                                                                                                          " + msrhEnter
						cSql += "ORDER BY FIL, MESANO, GRUPO                                                                                                                          " + msrhEnter
						If chkfile("_PPC_R")
							dbSelectArea("_PPC_R")
							dbCloseArea()
						EndIf
						TcQuery cSql New Alias "_PPC_R"

						//Grava as informações do PPC - RECEITA
						While  !_PPC_R->(EOF())

							IncProc("Processa RECEITA -> " + (cAliasEMP_COL)->ZN1_DESEMP )

							//Receita
							GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.01', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0101})
							TcSQLExec(cSql)

							//ICMS
							GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.02', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0102})
							TcSQLExec(cSql)

							//PIS
							GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.03', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0103})
							TcSQLExec(cSql)

							//COFINS
							GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.04', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0104})
							TcSQLExec(cSql)

							If OPER_COL->ZN2_DIFPIS > 0
								//PIS
								GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.05', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0101*OPER_COL->ZN2_DIFPIS})
								TcSQLExec(cSql)
							EndIf

							If OPER_COL->ZN2_DIFCOF > 0
								//COFINS
								GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.06', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0101*OPER_COL->ZN2_DIFCOF})
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
						cSql := "SELECT SUBSTRING(CT2_DATA,1,6) MESANO, 'SER' GRUPO                                                                                           " + msrhEnter
						If OPER_COL->ZN2_EMPORI == "06"
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
						cSql += "FROM CT2"+OPER_COL->ZN2_EMPORI+"0                                                                                                            " + msrhEnter
						cSql += "WHERE CT2_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"'                                                                         " + msrhEnter
						If OPER_COL->ZN2_EMPORI <> OPER_COL->ZN2_EMPDES
							cSql += "AND (CT2_ITEMC = 'EMP"+OPER_COL->ZN2_EMPDES+"01"+nTD+"' OR CT2_ITEMD = 'EMP"+OPER_COL->ZN2_EMPDES+"01"+nTD+"' )                          " + msrhEnter
						EndIf
						cSql += "AND CT2_LOTE <> '888888'                                                                                                                     " + msrhEnter
						cSql += "AND D_E_L_E_T_ = ''                                                                                                                          " + msrhEnter
						cSql += "GROUP BY SUBSTRING(CT2_DATA,1,6)                                                                                                             " + msrhEnter
						If chkfile("_PPC_D")
							dbSelectArea("_PPC_D")
							dbCloseArea()
						EndIf
						TcQuery cSql New Alias "_PPC_D"

						//Grava as informações do PPC - DEDUCOES
						While  !_PPC_D->(EOF())

							IncProc("Processa DEDUCOES -> " + (cAliasEMP_COL)->ZN1_DESEMP )

							//Devolucao
							GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.01', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0201})
							TcSQLExec(cSql)

							//ICMS
							GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.02', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0202})
							TcSQLExec(cSql)

							//PIS
							GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.03', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0203})
							TcSQLExec(cSql)

							//COFINS
							GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.04', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0204})
							TcSQLExec(cSql)

							If OPER_COL->ZN2_DIFPIS > 0
								//PIS
								GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.05', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0201 * OPER_COL->ZN2_DIFPIS})
								TcSQLExec(cSql)
							EndIf

							If OPER_COL->ZN2_DIFCOF > 0
								//COFINS
								GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.06', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0201 * OPER_COL->ZN2_DIFCOF})
								TcSQLExec(cSql)
							EndIf

							_PPC_D->(dbSkip())

						End

					Next

				Else

					nTD := ""
					//Receitas
					cSql := "SELECT FIL, MESANO, GRUPO, SUM(VLR_0101) VLR_0101, SUM(VLR_0102) VLR_0102, SUM(VLR_0103) VLR_0103, SUM(VLR_0104) VLR_0104                             " + msrhEnter
					cSql += "FROM                                                                                                                                                  " + msrhEnter
					cSql += "(SELECT CT2_CREDIT, CT2_DEBITO, SUBSTRING(CT2_DATA,1,6) MESANO, 'SER' GRUPO                                                                           " + msrhEnter
					cSql += "	,FIL = CASE                                                                                                                                        " + msrhEnter
					cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000001') OR CT2_DEBITO IN ('41201070000003','41201070000004','41201070000005') THEN '01'     " + msrhEnter
					cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000004') OR CT2_DEBITO IN ('41201070000013','41201070000014','41201070000015') THEN '02'     " + msrhEnter
					cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000005') OR CT2_DEBITO IN ('41201070000023','41201070000024','41201070000025') THEN '03'     " + msrhEnter
					cSql += "			ELSE ''                                                                                                                                    " + msrhEnter
					cSql += "		 END                                                                                                                                           " + msrhEnter
					If OPER_COL->ZN2_EMPORI == "06"
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
					cSql += "FROM CT2" + OPER_COL->ZN2_EMPORI + "0                                                                                                                     " + msrhEnter
					cSql += "WHERE CT2_DATA BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "'                                                                                  " + msrhEnter
					If OPER_COL->ZN2_EMPORI <> OPER_COL->ZN2_EMPDES
						cSql += "AND (CT2_ITEMC = 'EMP" + OPER_COL->ZN2_EMPDES + "01" + nTD + "' OR CT2_ITEMD = 'EMP" + OPER_COL->ZN2_EMPDES + "01" + nTD + "' )                                   " + msrhEnter
					EndIf
					cSql += "AND CT2_LOTE <> '888888'                                                                                                                              " + msrhEnter
					cSql += "AND D_E_L_E_T_ = ''                                                                                                                                   " + msrhEnter
					cSql += "GROUP BY CT2_CREDIT, CT2_DEBITO, SUBSTRING(CT2_DATA,1,6)) TMP                                                                                         " + msrhEnter
					cSql += "WHERE FIL <> ''                                                                                                                                       " + msrhEnter
					cSql += "GROUP BY FIL, MESANO, GRUPO                                                                                                                           " + msrhEnter
					cSql += "ORDER BY FIL, MESANO, GRUPO                                                                                                                           " + msrhEnter
					If chkfile("_PPC_R")
						dbSelectArea("_PPC_R")
						dbCloseArea()
					EndIf
					TcQuery cSql New Alias "_PPC_R"

					//Grava as informações do PPC - RECEITA
					While  !_PPC_R->(EOF())

						IncProc("Processa RECEITA -> " + (cAliasEMP_COL)->ZN1_DESEMP )

						//Receita
						GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.01', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0101})
						TcSQLExec(cSql)

						//ICMS
						GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.02', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0102})
						TcSQLExec(cSql)

						//PIS
						GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.03', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0103})
						TcSQLExec(cSql)

						//COFINS
						GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.04', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0104})
						TcSQLExec(cSql)

						If OPER_COL->ZN2_DIFPIS > 0
							//PIS
							GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.05', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0101 * OPER_COL->ZN2_DIFPIS})
							TcSQLExec(cSql)
						EndIf

						If OPER_COL->ZN2_DIFCOF > 0
							//COFINS
							GrvZN4T({OPER_COL->ZN2_EMPORI, _PPC_R->FIL, OPER_COL->ZN2_EMPDES, _PPC_R->MESANO, _PPC_R->GRUPO, nTD, '01.06', OPER_COL->ZN2_CUSIMP, _PPC_R->VLR_0101 * OPER_COL->ZN2_DIFCOF})
							TcSQLExec(cSql)
						EndIf

						_PPC_R->(dbSkip())

					End

					nTD := ""
					//Deducoes
					cSql := "SELECT SUBSTRING(CT2_DATA,1,6) MESANO, 'SER' GRUPO                                                                                      " + msrhEnter
					If OPER_COL->ZN2_EMPORI == "06"
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
					cSql += "FROM CT2"+OPER_COL->ZN2_EMPORI+"0                                                                                                       " + msrhEnter
					cSql += "WHERE CT2_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"'                                                                    " + msrhEnter
					If OPER_COL->ZN2_EMPORI <> OPER_COL->ZN2_EMPDES
						cSql += "AND (CT2_ITEMC = 'EMP"+OPER_COL->ZN2_EMPDES+"01"+nTD+"' OR CT2_ITEMD = 'EMP"+OPER_COL->ZN2_EMPDES+"01"+nTD+"' )                     " + msrhEnter
					EndIf
					cSql += "AND CT2_LOTE <> '888888'                                                                                                                " + msrhEnter
					cSql += "AND D_E_L_E_T_ = ''                                                                                                                     " + msrhEnter
					cSql += "GROUP BY SUBSTRING(CT2_DATA,1,6)                                                                                                        " + msrhEnter
					If chkfile("_PPC_D")
						dbSelectArea("_PPC_D")
						dbCloseArea()
					EndIf
					TcQuery cSql New Alias "_PPC_D"

					//Grava as informações do PPC - DEDUCOES
					While  !_PPC_D->(EOF())

						IncProc("Processa DEDUCOES -> " + (cAliasEMP_COL)->ZN1_DESEMP )

						//Devolucao
						GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.01', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0201})
						TcSQLExec(cSql)

						//ICMS
						GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.02', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0202})
						TcSQLExec(cSql)

						//PIS
						GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.03', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0203})
						TcSQLExec(cSql)

						//COFINS
						GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.04', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0204})
						TcSQLExec(cSql)

						If OPER_COL->ZN2_DIFPIS > 0
							//PIS
							GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.05', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0201 * OPER_COL->ZN2_DIFPIS})
							TcSQLExec(cSql)
						EndIf

						If OPER_COL->ZN2_DIFCOF > 0
							//COFINS
							GrvZN4T({OPER_COL->ZN2_EMPORI, '01', OPER_COL->ZN2_EMPDES, _PPC_D->MESANO, _PPC_D->GRUPO, nTD, '02.05', OPER_COL->ZN2_CUSIMP, _PPC_D->VLR_0201 * OPER_COL->ZN2_DIFCOF})
							TcSQLExec(cSql)
						EndIf

						_PPC_D->(dbSkip())

					End

				EndIf

			EndIf

			OPER_COL->(dbSkip())

		End

		(cAliasEMP_COL)->(dbSkip())

	End

	(cAliasEMP_COL)->(dbCloseArea())
	OPER_COL->(dbCloseArea())

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

static function __Dummy()
	if (.F.)
		Menudef()
		__Dummy()
	endif
return(.F.)
