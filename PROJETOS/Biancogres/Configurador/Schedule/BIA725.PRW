#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"

/*/{Protheus.doc} BIA725
@description Workflow para Integração da terceira unidade de medida para o MES
@author Marcos Alberto Soprani
@since 16/01/19
@version 1.0
/*/

User Function BIA725()

	LOCAL     xv_Emps    := U_BAGtEmpr("01")
	Local x

	For x := 1 to Len(xv_Emps)

		If xv_Emps[x,2] == "01"

			RPCSetType(3)
			RPCSetEnv(xv_Emps[x,1], xv_Emps[x,2], "", "", "", "", {})

			ConOut("HORA: " + TIME() + " - Iniciando Processo BIA725 " + xv_Emps[x,1])

			TR004 := " UPDATE PCF_Integ..TBLInWODet SET "
			TR004 += "        [Integrated] = 0, "
			TR004 += "        Unit1Factor = CASE "
			TR004 += "                        WHEN RTRIM(C.CodeExt) = 'PC' THEN D.B1_CONV / D.B1_YPECA "
			TR004 += "                        WHEN RTRIM(C.CodeExt) = 'CX' THEN D.B1_CONV "
			TR004 += "                        ELSE 1 "
			TR004 += "                      END, "
			TR004 += "        Unit2Code = 'CX', "
			TR004 += "        Unit2Factor = ( 1 / ( D.B1_CONV / D.B1_YPECA ) / D.B1_YPECA ), "
			TR004 += "        Unit3Code = 'PC', "
			TR004 += "        Unit3Factor = 1 / ( D.B1_CONV / D.B1_YPECA ) "
			TR004 += "   FROM PCF_Integ..TBLInWODet A "
			TR004 += "  INNER JOIN " + RetSqlName("SC2") + " B ON B.C2_NUM = SUBSTRING(A.WoCode,1,6) COLLATE Latin1_General_BIN "
			TR004 += "                               AND B.C2_ITEM = SUBSTRING(A.WoCode,7,2) COLLATE Latin1_General_BIN "
			TR004 += "                               AND B.C2_SEQUEN = SUBSTRING(A.WoCode,9,3) COLLATE Latin1_General_BIN "
			TR004 += "                               AND B.D_E_L_E_T_ = ' ' "
			TR004 += "  INNER JOIN " + RetSqlName("SB1") + " D ON D.B1_COD = B.C2_PRODUTO "
			TR004 += "                               AND D.D_E_L_E_T_ = ' ' "
			TR004 += "  INNER JOIN PCF4..TBLResource C ON C.Code = A.ResourceCode "
			TR004 += "  WHERE A.Unit3Code IS NULL "
			TR004 += "    AND A.[Integrated] = 2 "
			TcSQLExec(TR004)

			TR007 := " UPDATE PCF_Integ..TBLInProduct SET "
			TR007 += "        [Integrated] = 0, "
			TR007 += "        [Unit2Code] = 'CX', "
			TR007 += "        [Unit2Factor] = SB1.B1_CONV, "
			TR007 += "        [Unit3Code] = 'PC', "
			TR007 += "        [Unit3Factor] =  SB1.B1_CONV / SB1.B1_YPECA "
			TR007 += "   FROM PCF_Integ..TBLInProduct A "
			TR007 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = A.Code COLLATE Latin1_General_BIN "
			TR007 += "                               AND SB1.D_E_L_E_T_ = ' ' "
			TR007 += "  WHERE A.Unit3Code IS NULL "
			TR007 += "    AND A.[Integrated] = 2 "
			TcSQLExec(TR007)

			TR009 := " UPDATE A SET "
			TR009 += "        [IDUnit2] = 2, "
			TR009 += "        [Unit2Factor] = ROUND(SB1.B1_CONV,4), "
			TR009 += "        [IDUnit3] = 3, "
			TR009 += "        [Unit3Factor] = ROUND(SB1.B1_CONV / SB1.B1_YPECA,4) "
			TR009 += "   FROM PCF4..TBLProduct A "
			TR009 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = A.Code COLLATE Latin1_General_BIN "
			TR009 += "                               AND B1_TIPO IN('PA','PP') "
			TR009 += "                               AND SB1.D_E_L_E_T_ = ' ' "
			TR009 += "  WHERE A.[IDUnit2] IS NULL OR A.[IDUnit3] IS NULL "
			TcSQLExec(TR009)

			TR010	:=	"	UPDATE A	"
			TR010	+=	"	SET A.IDProductFamily = B.IDProductFamily	"
			TR010	+=	"	FROM PCF4..TBLProduct A	"
			TR010	+=	"	JOIN PCF4..TBLProductFamily B ON Substring(A.Code, 1, 2) = B.Code	"
			TR010	+=	"		AND A.IDProductFamily IS NULL	"
			TcSQLExec(TR010)

			TR011 := " UPDATE A "
			TR011 += "   SET "
			TR011 += "       Description = RTRIM(H1_YSEQUEN), "
			TR011 += "       ExtCode = RTRIM(H1_YEXTCOD), "
			TR011 += "       CodeExt = RTRIM(H1_YCODEEX), "
			TR011 += "       FlgValidForAllUsr = 1 "
			TR011 += " FROM PCF4..TBLResource A "
			TR011 += "      INNER JOIN " + RetSqlName("SH1") + " B ON B.H1_CODIGO = A.Code COLLATE Latin1_General_BIN "
			TcSQLExec(TR011)			

			ConOut("HORA: " + TIME() + " - Finalizando Processo BIA725 " + xv_Emps[x,1])

			RpcClearEnv()

		EndIf

	Next x

Return

User Function BIA725JOB()

	STARTJOB("U_BIA725", GetEnvServer(), .F., cEmpAnt, cFilAnt)

Return
