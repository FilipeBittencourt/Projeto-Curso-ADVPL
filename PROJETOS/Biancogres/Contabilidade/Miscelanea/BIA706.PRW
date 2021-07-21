#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA706
@author Marcos Alberto Soprani
@since 15/07/21
@version 1.0
@description Atualiza o campo CVF_ORDEM conforme campo CVF_YRFDRE
@Obs Projeto A-59
@type function
/*/

User Function BIA706()

	Local lRet          := .T.

	Private msCanPrc    := .F.
	Private xVerRet     := .T.
	Private xCodPla     := ""
	Private msEnter     := CHR(13) + CHR(10)
	Private msStaExcQy  := 0
	Private hhTmpINI
	Private msErroQuery

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := "Define variable value"
	Private xoSay1
	Private xoDlg

	If ValidPerg()

		hhTmpINI := TIME()
		xCodPla  := MV_PAR01

		BQ001 := GetNextAlias()
		BeginSql Alias BQ001

			SELECT COUNT(*) CONTAD
			FROM %TABLE:CVE% CVE(NOLOCK)
			WHERE CVE_FILIAL = %xFilial:CVE%
			AND CVE_CODIGO = %Exp:xCodPla%
			AND CVE_YTPVSG = '5'
			AND CVE.%NotDel%

		EndSql 

		If (BQ001)->CONTAD < 1

			lRet  := .F.
			msErroQuery := "A Visão Gerencial selecionada não está preparada para sofrer reorganização no campo ORDEM a partir do campo RFDRE"

		Else

			smMsnPrc := "Processamento 1"
			oPrc0001 := MsNewProcess():New({|lEnd| qkProc01(@oPrc0001) }, "Primeiro Processamento...", smMsnPrc, .T.)
			oPrc0001:Activate()

			lRet := xVerRet

			If xVerRet

				smMsnPrc := "Processamento 2"
				oPrc0002 := MsNewProcess():New({|lEnd| qkProc02(@oPrc0002) }, "Segundo Processamento...", smMsnPrc, .T.)
				oPrc0002:Activate()

				lRet := xVerRet

				If xVerRet

					smMsnPrc := "Processamento 3"
					oPrc0003 := MsNewProcess():New({|lEnd| qkProc03(@oPrc0003) }, "Terceiro Processamento...", smMsnPrc, .T.)
					oPrc0003:Activate()

					lRet := xVerRet

					If xVerRet

						smMsnPrc := "Processamento 4"
						oPrc0004 := MsNewProcess():New({|lEnd| qkProc04(@oPrc0004) }, "Quarto Processamento...", smMsnPrc, .T.)
						oPrc0004:Activate()

						lRet := xVerRet

						If !xVerRet

							msCanPrc  := .F.

						EndIf

					Else

						msCanPrc  := .F.

					EndIf

				Else

					msCanPrc  := .F.

				EndIf

			Else

				msCanPrc  := .F.

			EndIf


		EndIf

	Else

		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		If !lRet

			xcMultiGe1 := "Erro de Query: " + msEnter + msEnter + msErroQuery

			DEFINE MSDIALOG xoDlg TITLE "Atenção!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de Erro. Apanhe o erro e abra um ticket." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		Else

			MsgINFO("Fim do Processamento!!!" + msEnter + msEnter + Alltrim(ElapTime(hhTmpINI, TIME())), "Atenção!!!")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")

	EndIf

Return

Static Function ValidPerg()

	local cLoad	    := "BIA706" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(03)

	aAdd( aPergs ,{1, "Visão Gerencial"  ,MV_PAR01 ,""            ,"EXISTCPO('CVE')",'CVE'  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Atualiza Ordem da Visão Gerencial",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)

	EndIf

Return lRet

Static Function qkProc01(oPrc0001)

	Local lRet := .T.

	oPrc0001:SetRegua1(1)
	oPrc0001:SetRegua2(1000)

	Begin Transaction

		ET001 := Alltrim(" UPDATE CVF                                                                                                      ") + msEnter
		ET001 += Alltrim("   SET                                                                                                           ") + msEnter
		ET001 += Alltrim("       CVF_ORDEM = RIGHT('0000000000' + CONVERT(VARCHAR, CONVERT(NUMERIC, CVF_ORDEM) + 10000), 10)               ") + msEnter
		ET001 += Alltrim(" FROM " + RetSqlName("CVF") + " CVF                                                                              ") + msEnter
		ET001 += Alltrim(" WHERE CVF_FILIAL = '" + xFilial("CVF") + "'                                                                     ") + msEnter
		ET001 += Alltrim("       AND CVF_CODIGO = '" + xCodPla + "'                                                                        ") + msEnter
		ET001 += Alltrim("       AND CVF.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
		U_BIAMsgRun("Aguarde... Primeiro Processamento... ",,{|| msStaExcQy := TcSQLExec(ET001) })

		If msStaExcQy < 0
			lRet := .F.
		EndIf

		If !lRet

			msErroQuery := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction

	xVerRet := lRet 

Return ( lRet )

Static Function qkProc02(oPrc0002)

	Local lRet := .T.

	oPrc0002:SetRegua1(1)
	oPrc0002:SetRegua2(1000)

	Begin Transaction

		ET002 := Alltrim(" WITH PROC02                                                                                                     ") + msEnter
		ET002 += Alltrim("      AS (SELECT CVF_YRFDRE,                                                                                     ") + msEnter
		ET002 += Alltrim("                 CVF.R_E_C_N_O_,                                                                                 ") + msEnter
		ET002 += Alltrim("                 ORDEM = RIGHT('0000000000' + CONVERT(VARCHAR, CONVERT(NUMERIC, ROW_NUMBER() OVER(               ") + msEnter
		ET002 += Alltrim("                               ORDER BY CVF_YRFDRE))), 10)                                                       ") + msEnter
		ET002 += Alltrim("          FROM " + RetSqlName("CVF") + " CVF                                                                     ") + msEnter
		ET002 += Alltrim("          WHERE CVF_FILIAL = '" + xFilial("CVF") + "'                                                            ") + msEnter
		ET002 += Alltrim("                AND CVF_CODIGO = '" + xCodPla + "'                                                               ") + msEnter
		ET002 += Alltrim("                AND CVF_YRFDRE <> ''                                                                             ") + msEnter
		ET002 += Alltrim("                AND CVF.D_E_L_E_T_ = ' ')                                                                        ") + msEnter
		ET002 += Alltrim("      UPDATE XXX                                                                                                 ") + msEnter
		ET002 += Alltrim("        SET                                                                                                      ") + msEnter
		ET002 += Alltrim("            CVF_ORDEM = PRC02.ORDEM                                                                              ") + msEnter
		ET002 += Alltrim("      FROM PROC02 PRC02                                                                                          ") + msEnter
		ET002 += Alltrim("           INNER JOIN " + RetSqlName("CVF") + " XXX ON XXX.R_E_C_N_O_ = PRC02.R_E_C_N_O_                         ") + msEnter
		U_BIAMsgRun("Aguarde... Segundo Processamento... ",,{|| msStaExcQy := TcSQLExec(ET002) })

		If msStaExcQy < 0
			lRet := .F.
		EndIf

		If !lRet

			msErroQuery := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction

	xVerRet := lRet 

Return ( lRet )

Static Function qkProc03(oPrc0003)

	Local lRet := .T.

	oPrc0003:SetRegua1(1)
	oPrc0003:SetRegua2(1000)

	Begin Transaction

		ET003 := Alltrim(" WITH PROC03                                                                                                     ") + msEnter
		ET003 += Alltrim("      AS (SELECT CVF_ORDEM,                                                                                      ") + msEnter
		ET003 += Alltrim("                 CVF.R_E_C_N_O_,                                                                                 ") + msEnter
		ET003 += Alltrim("                 ORDEM = RIGHT('0000000000' + CONVERT(VARCHAR, CONVERT(NUMERIC,                                  ") + msEnter
		ET003 += Alltrim("          (                                                                                                      ") + msEnter
		ET003 += Alltrim("              SELECT COUNT(*)                                                                                    ") + msEnter
		ET003 += Alltrim("              FROM " + RetSqlName("CVF") + " XXX                                                                 ") + msEnter
		ET003 += Alltrim("              WHERE XXX.CVF_FILIAL = '" + xFilial("CVF") + "'                                                    ") + msEnter
		ET003 += Alltrim("                    AND XXX.CVF_CODIGO = '" + xCodPla + "'                                                       ") + msEnter
		ET003 += Alltrim("                    AND XXX.CVF_YRFDRE <> ''                                                                     ") + msEnter
		ET003 += Alltrim("                    AND XXX.D_E_L_E_T_ = ' '                                                                     ") + msEnter
		ET003 += Alltrim("          ) + ROW_NUMBER() OVER(                                                                                 ") + msEnter
		ET003 += Alltrim("          ORDER BY CVF.CVF_ORDEM))), 10)                                                                         ") + msEnter
		ET003 += Alltrim("          FROM " + RetSqlName("CVF") + " CVF                                                                     ") + msEnter
		ET003 += Alltrim("          WHERE CVF_FILIAL = '" + xFilial("CVF") + "'                                                            ") + msEnter
		ET003 += Alltrim("                AND CVF_CODIGO = '" + xCodPla + "'                                                               ") + msEnter
		ET003 += Alltrim("                AND CVF_YRFDRE = ''                                                                              ") + msEnter
		ET003 += Alltrim("                AND CVF.D_E_L_E_T_ = ' ')                                                                        ") + msEnter
		ET003 += Alltrim("      UPDATE XXX                                                                                                 ") + msEnter
		ET003 += Alltrim("        SET                                                                                                      ") + msEnter
		ET003 += Alltrim("            CVF_ORDEM = PRC03.ORDEM                                                                              ") + msEnter
		ET003 += Alltrim("      FROM PROC03 PRC03                                                                                          ") + msEnter
		ET003 += Alltrim("           INNER JOIN " + RetSqlName("CVF") + " XXX ON XXX.R_E_C_N_O_ = PRC03.R_E_C_N_O_                         ") + msEnter
		U_BIAMsgRun("Aguarde... Terceiro Processamento... ",,{|| msStaExcQy := TcSQLExec(ET003) })

		If msStaExcQy < 0
			lRet := .F.
		EndIf

		If !lRet

			msErroQuery := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction

	xVerRet := lRet 

Return ( lRet )

Static Function qkProc04(oPrc0004)

	Local lRet := .T.

	oPrc0004:SetRegua1(1)
	oPrc0004:SetRegua2(1000)

	Begin Transaction

		ET004 := Alltrim(" UPDATE CTS                                                                                                      ") + msEnter
		ET004 += Alltrim("   SET                                                                                                           ") + msEnter
		ET004 += Alltrim("       CTS_ORDEM = CVF_ORDEM                                                                                     ") + msEnter
		ET004 += Alltrim(" FROM " + RetSqlName("CTS") + " CTS(NOLOCK)                                                                      ") + msEnter
		ET004 += Alltrim("      INNER JOIN " + RetSqlName("CVF") + " CVF(NOLOCK) ON CVF_CODIGO = CTS_CODPLA                                ") + msEnter
		ET004 += Alltrim("                                       AND CVF_CONTAG = CTS_CONTAG                                               ") + msEnter
		ET004 += Alltrim("                                       AND CVF_CTASUP = CTS_CTASUP                                               ") + msEnter
		ET004 += Alltrim("                                       AND CVF.D_E_L_E_T_ = ' '                                                  ") + msEnter
		ET004 += Alltrim(" WHERE CTS_FILIAL = '" + xFilial("CTS") + "'                                                                     ") + msEnter
		ET004 += Alltrim("       AND CTS_CODPLA = '" + xCodPla + "'                                                                        ") + msEnter
		ET004 += Alltrim("       AND CTS.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
		U_BIAMsgRun("Aguarde... Quarto Processamento... ",,{|| msStaExcQy := TcSQLExec(ET004) })

		If msStaExcQy < 0
			lRet := .F.
		EndIf

		If !lRet

			msErroQuery := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction

	xVerRet := lRet 

Return ( lRet )
