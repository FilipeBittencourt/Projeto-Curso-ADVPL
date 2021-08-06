#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"

/*/{Protheus.doc} BIA106
@description Programa para montagem de base de teste para PCF4
@author Marcos Alberto Soprani
@since 17/01/19
@version 1.0
/*/

User Function BIA106()

	Local xv_Emps      := U_BAGtEmpr("01")
	Local x
	Local msStaExcQy   := 0
	Private msEnter    := CHR(13) + CHR(10)
	Private xOk        := .F.
	Private msGravaErr := ""

	For x := 1 to Len(xv_Emps)

		If xv_Emps[x,2] == "01"

			RpcSetType(3)
			RpcSetEnv(xv_Emps[x,1], xv_Emps[x,2], "", "", "", "", {})

			xVerRet := .F.	
			Processa({ || fExistTabl("msDtRfPCF4teste") }, "Aguarde...", "Verificando tabela", .F.)
			If xVerRet

				QR001 := Alltrim(" UPDATE A                                          ") + msEnter
				QR001 += Alltrim("   SET                                             ") + msEnter
				QR001 += Alltrim("       UltDtRef = NexDtRef,                        ") + msEnter
				QR001 += Alltrim("       NexDtRef = GETDATE()                        ") + msEnter
				QR001 += Alltrim(" FROM msDtRfPCF4teste A                            ") + msEnter
				U_BIAMsgRun("Atualizando Data de Controle - msDtRfPCF4teste... ",,{|| msStaExcQy := TcSQLExec(QR001) })
				If msStaExcQy >= 0

					QR002 := Alltrim(" INSERT INTO [POTHOS].[PCF4].[dbo].[cTblQuantidade]                                            ") + msEnter
					QR002 += Alltrim(" ([Recurso],                                                                                   ") + msEnter
					QR002 += Alltrim("  [DecimalClassificacao],                                                                      ") + msEnter
					QR002 += Alltrim("  [DecimalTamanho],                                                                            ") + msEnter
					QR002 += Alltrim("  [DecimalMotivo],                                                                             ") + msEnter
					QR002 += Alltrim("  [Quantidade],                                                                                ") + msEnter
					QR002 += Alltrim("  [Integrated],                                                                                ") + msEnter
					QR002 += Alltrim("  [DtLastUpdate],                                                                              ") + msEnter
					QR002 += Alltrim("  [User],                                                                                      ") + msEnter
					QR002 += Alltrim("  [Turno]                                                                                      ") + msEnter
					QR002 += Alltrim(" )                                                                                             ") + msEnter
					QR002 += Alltrim("        SELECT TOP 100000                                                                      ") + msEnter
					QR002 += Alltrim("               [Recurso],                                                                      ") + msEnter
					QR002 += Alltrim("               [DecimalClassificacao],                                                         ") + msEnter
					QR002 += Alltrim("               [DecimalTamanho],                                                               ") + msEnter
					QR002 += Alltrim("               [DecimalMotivo],                                                                ") + msEnter
					QR002 += Alltrim("               [Quantidade],                                                                   ") + msEnter
					QR002 += Alltrim("               0 [Integrated],                                                                 ") + msEnter
					QR002 += Alltrim("               GETDATE() [DtLastUpdate],                                                       ") + msEnter
					QR002 += Alltrim("               [User],                                                                         ") + msEnter
					QR002 += Alltrim("               [Turno]                                                                         ") + msEnter
					QR002 += Alltrim("        FROM [HADES].[PCF4].[dbo].cTblQuantidade A(nolock)                                     ") + msEnter
					QR002 += Alltrim("        WHERE Recurso IN(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)                        ") + msEnter
					QR002 += Alltrim("        AND [DtLastUpdate] >=                                                                  ") + msEnter
					QR002 += Alltrim("        (                                                                                      ") + msEnter
					QR002 += Alltrim("            SELECT UltDtRef                                                                    ") + msEnter
					QR002 += Alltrim("            FROM msDtRfPCF4teste B(nolock)                                                     ") + msEnter
					QR002 += Alltrim("        )                                                                                      ") + msEnter
					U_BIAMsgRun("Inserindo registros PCF4 Base Teste - cTblQuantidade... ",,{|| msStaExcQy := TcSQLExec(QR002) })
					If msStaExcQy >= 0

						QR003 := Alltrim(" INSERT INTO [POTHOS].[PCF4].[dbo].[cTblStatus]                                                   ") + msEnter
						QR003 += Alltrim(" ([Recurso],                                                                                      ") + msEnter
						QR003 += Alltrim("  [Status],                                                                                       ") + msEnter
						QR003 += Alltrim("  [DecimalCausa],                                                                                 ") + msEnter
						QR003 += Alltrim("  [Integrated],                                                                                   ") + msEnter
						QR003 += Alltrim("  [DtLastUpdate],                                                                                 ") + msEnter
						QR003 += Alltrim("  [User],                                                                                         ") + msEnter
						QR003 += Alltrim("  [ErrDescription],                                                                               ") + msEnter
						QR003 += Alltrim("  [Turno]                                                                                         ") + msEnter
						QR003 += Alltrim(" )                                                                                                ") + msEnter
						QR003 += Alltrim("        SELECT [Recurso],                                                                         ") + msEnter
						QR003 += Alltrim("               [Status],                                                                          ") + msEnter
						QR003 += Alltrim("               [DecimalCausa],                                                                    ") + msEnter
						QR003 += Alltrim("               0 [Integrated],                                                                    ") + msEnter
						QR003 += Alltrim("               GETDATE() [DtLastUpdate],                                                          ") + msEnter
						QR003 += Alltrim("               [User],                                                                            ") + msEnter
						QR003 += Alltrim("               NULL [ErrDescription],                                                             ") + msEnter
						QR003 += Alltrim("               [Turno]                                                                            ") + msEnter
						QR003 += Alltrim("        FROM [HADES].[PCF4].[dbo].cTblStatus A(nolock)                                            ") + msEnter
						QR003 += Alltrim("        WHERE Recurso IN(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)                           ") + msEnter
						QR003 += Alltrim("        AND [DtLastUpdate] >=                                                                     ") + msEnter
						QR003 += Alltrim("        (                                                                                         ") + msEnter
						QR003 += Alltrim("            SELECT UltDtRef                                                                       ") + msEnter
						QR003 += Alltrim("            FROM msDtRfPCF4teste B(nolock)                                                        ") + msEnter
						QR003 += Alltrim("        )                                                                                         ") + msEnter
						U_BIAMsgRun("Inserindo registros PCF4 Base Teste - cTblStatus... ",,{|| msStaExcQy := TcSQLExec(QR003) })
						If msStaExcQy >= 0

							xOk := .T.

						Else 

							msGravaErr := TCSQLError()

						EndIf


					Else

						msGravaErr := TCSQLError()

					EndIf

				Else

					msGravaErr := TCSQLError()

				EndIf

			EndIf

		EndIf

	Next x

	//RpcSetEnv( "01", "01" )

	//If Type("__cInternet") == "C"
	//	__cInternet := Nil
	//EndIf

	If xOk

		ConOut("Data: " + dtoc(Date()) + "Hora: " + Time() + " - Processado com sucesso - BIA106 ")

	Else

		ConOut("Data: " + dtoc(Date()) + "Hora: " + Time() + " - Erro no processamento das querys - BIA106 " + msGravaErr)

	EndIf

Return

Static Function fExistTabl(cTabl)

	Local cSQL  := ""
	Local cQry  := ""
	Local lRet  := .F.
	Local msStaExcQy   := 0

	cQry := GetNextAlias()
	cSql := " SELECT COUNT(*) CONTAD
	cSql += " FROM INFORMATION_SCHEMA.TABLES A(NOLOCK)
	cSql += " WHERE TABLE_NAME = '" + cTabl + "';
	TcQuery cSQL New Alias (cQry)

	If (cQry)->CONTAD > 0

		hgQry := GetNextAlias()
		hgSql := " SELECT COUNT(*) CONTAD "
		hgSql += " FROM msDtRfPCF4teste A(NOLOCK) "
		hgSql += " WHERE CONVERT(NUMERIC, GETDATE() - NexDtRef) > 2 "
		TcQuery hgSQL New Alias (hgQry)
		If (hgQry)->CONTAD > 0

			QR005 := Alltrim("DROP TABLE msDtRfPCF4teste                                              ") + msEnter
			U_BIAMsgRun("Deleta Tabela msDtRfPCF4teste... ",,{|| msStaExcQy := TcSQLExec(QR005) })
			If msStaExcQy >= 0

				QR006 := Alltrim("SELECT GETDATE() UltDtRef,                                              ") + msEnter
				QR006 += Alltrim("       DATEADD(DAY, -2, GETDATE()) NexDtRef into msDtRfPCF4teste        ") + msEnter	
				U_BIAMsgRun("Criando Tabela msDtRfPCF4teste... ",,{|| msStaExcQy := TcSQLExec(QR006) })
				If msStaExcQy < 0

					msGravaErr := TCSQLError()

				Else

					lRet := .T.

				EndIf

			EndIf

		Else

			lRet := .T.

		EndIf

		(hgQry)->(DbCloseArea())

	Else

		QR004 := Alltrim("SELECT GETDATE() UltDtRef,                                              ") + msEnter
		QR004 += Alltrim("       DATEADD(DAY, -2, GETDATE()) NexDtRef into msDtRfPCF4teste        ") + msEnter	
		U_BIAMsgRun("Criando Tabela msDtRfPCF4teste... ",,{|| msStaExcQy := TcSQLExec(QR004) })
		If msStaExcQy < 0

			msGravaErr := TCSQLError()

		Else

			lRet  := .T.

		EndIf

	EndIf

	xVerRet := lRet 

	(cQry)->(DbCloseArea())

Return ( lRet )

User Function B106JOB()

	cEmpAnt := "01"
	cFilAnt := "01"

	STARTJOB("U_BIA106", GetEnvServer(), .F., cEmpAnt, cFilAnt)

Return
