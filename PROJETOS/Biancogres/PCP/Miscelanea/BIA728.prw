#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"

/*/{Protheus.doc} BIA728
@description Workflow para marcar registros marcados como Integrated = 3
@author Marcos Alberto Soprani
@since 17/01/19
@version 1.0
/*/

User Function BIA728()

	LOCAL     xv_Emps    := U_BAGtEmpr("01")
	Local x

	For x := 1 to Len(xv_Emps)

		If xv_Emps[x,2] == "01"

			RPCSetType(3)
			RPCSetEnv(xv_Emps[x,1], xv_Emps[x,2], "", "", "", "", {})

			ConOut("Data: " + dtoc(Date()) + "Hora: " + Time() + " - Iniciando Processo BIA728 " + xv_Emps[x,1])

			/*
			TR004 := " UPDATE PCF4..cTblQuantidade SET [Integrated] = '0', [ErrDescription] =  RTRIM([ErrDescription]) + ' [Reprocessado Protheus]' "
			TR004 += "   FROM PCF4..cTblQuantidade "
			TR004 += "  WHERE [Integrated] = '3' "
			TR004 += "    AND [ErrDescription] LIKE '%Recurso sem OP alocada%' "
			TR004 += "    AND [ErrDescription] NOT LIKE '%Reprocessado Protheus%' "
			TR004 += "    AND [DtLastUpdate] >= DATEADD(DAY, -1, GETDATE()) "
			TcSQLExec(TR004)
			*/

			TR007 := " UPDATE PCF4..cTblStatus SET [Integrated] = '0', [ErrDescription] =  RTRIM([ErrDescription]) + ' [Reprocessado Protheus]' "
			TR007 += "   FROM PCF4..cTblStatus "
			TR007 += "  WHERE [Integrated] = '3' "
			TR007 += "    AND [ErrDescription] NOT LIKE '%Reprocessado Protheus%' " 
			TR007 += "    AND [DtLastUpdate] >= DATEADD(DAY, -1, GETDATE()) "
			TcSQLExec(TR007)

			/*
			TR003 := " UPDATE PCF4..cTblQuantidade SET [Integrated] = '9', ErrDescription = RTRIM(ErrDescription) + ' [Processado Protheus]' "
			TR003 += "   FROM PCF4..cTblQuantidade "
			TR003 += "  WHERE [Integrated] = '3' "
			TR003 += "    AND Recurso IN('6','7','13','14') "
			TR003 += "    AND ErrDescription = 'Sem classificação.' "
			TcSQLExec(TR003)
			*/

			TR009 := " UPDATE PCF4..cTblQuantidade SET [DecimalClassificacao] = '1', [Integrated] = '0', [ErrDescription] =  RTRIM([ErrDescription]) + ' [Reprocessado Protheus - DC]' "
			TR009 += "   FROM PCF4..cTblQuantidade "
			TR009 += "  WHERE [DecimalClassificacao] = 0 "
			TR009 += "    AND [Integrated] <> 2 "
			TR009 += "    AND [Recurso] IN(6, 7, 13, 14) "
			TR009 += "    AND [DtLastUpdate] >= DATEADD(DAY, -1, GETDATE()) "
			TcSQLExec(TR009)

			ConOut("Data: " + dtoc(Date()) + "Hora: " + Time() + " - Finalizando Processo BIA728 " + xv_Emps[x,1])

			RESET ENVIRONMENT

		EndIf

	Next x

Return

User Function BIA728JOB()

	STARTJOB("U_BIA728", GetEnvServer(), .F., cEmpAnt, cFilAnt)

Return
