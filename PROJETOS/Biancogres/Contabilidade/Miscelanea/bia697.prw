#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA697
@author Marcos Alberto Soprani
@since 16/06/21
@version 1.0
@description Rotina de processamento e preenchimento do campo Negócio para as tabelas envolvidas no projeto A-35
.            ZOW(AJST), Z48(EXTR), ZBZ(ORCA), CT2(REAL), ZOZ(VERS)
@Obs Projeto A-35
@type function
/*/

User Function BIA697()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .T.
	Local oProcess

	Private cTitulo := "Processamento para preenchimento do campo NEGÓCIO"

	Private dDataIni
	Private dDataFin
	Private xVersao
	Private xRevisa
	Private xAnoRef
	Private xCodPla
	Private xRubVis
	Private msEnter   := CHR(13) + CHR(10)
	Private msEmpAtu  := cEmpAnt
	Private msFilAtu  := cFilAnt
	Private hhTmpINI
	Private smMsnPrc
	Private msCanPrc  := .F.
	Private xVerRet   := .T.
	Private msErroQuery

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := "Define variable value"
	Private xoSay1
	Private xoDlg

	oEmp := TLoadEmpresa():New()

	If ValidPerg()

		dDataIni := MV_PAR01
		dDataFin := MV_PAR02

		oEmp:GSA35EmpFil()

		If Len(oEmp:aEmpSel) > 0

			hhTmpINI  := TIME()

			RpcSetType(3)
			RpcSetEnv( cEmpAnt, cFilAnt )
			RpcClearEnv()

			//Begin Transaction

			For nW := 1 To Len(oEmp:aEmpSel)

				RpcSetType(3)
				RpcSetEnv( oEmp:aEmpSel[nW][1], Substr(oEmp:aEmpSel[nW][2], 1, 2) )

				smMsnPrc := oEmp:aEmpSel[nW][1] + "/" + Substr(oEmp:aEmpSel[nW][2], 1, 2) + " - " + Alltrim(oEmp:aEmpSel[nW][4])
				oProcess := MsNewProcess():New({|lEnd| Prc697EX(@oProcess) }, "Gravando...", smMsnPrc, .T.)
				oProcess:Activate()

				lRet := xVerRet

				If !xVerRet

					//DisarmTransaction()
					msCanPrc  := .F.
					Exit

				EndIf


				RpcClearEnv()

			Next nW

			//End Transaction

		Else

			msCanPrc  := .T.

		EndIf

	Else

		msCanPrc  := .T.

	EndIf

	RpcSetEnv( msEmpAtu, msFilAtu )

	If Type("__cInternet") == "C"
		__cInternet := Nil
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

	local cLoad	    := "BIA697" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	ctod("  /  /  ")
	MV_PAR02 := ctod("  /  /  ")
	MV_PAR03 := Space(10)
	MV_PAR04 :=	Space(03)
	MV_PAR05 :=	Space(04)
	MV_PAR06 :=	Space(03)

	aAdd( aPergs ,{1, "Data Inicial"     ,MV_PAR01 ,""  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Data Final"       ,MV_PAR02 ,""  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Processa campo NEGÓCIO",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)

	EndIf

Return lRet

Static Function Prc697EX(oProcess)

	Local fk
	Local lRet	      := .T.

	Local msStaExcQy  := 0
	Local lOk         := .T.
	Local tyTblPrc    := {}
	Local msTabela

	oProcess:SetRegua1(4)
	oProcess:SetRegua2(8)             

	aAdd(tyTblPrc, { 1,	"ZOW", "_NEGOCI" })
	aAdd(tyTblPrc, { 2,	"Z48", "_NEGOCI" })
	aAdd(tyTblPrc, { 3,	"ZBZ", "_NEGOCI" })
	aAdd(tyTblPrc, { 4,	"CT2", "_YNEGOC" })
	aAdd(tyTblPrc, { 5,	"ZOZ", "_NEGOCI" })

	oProcess:IncRegua1(smMsnPrc)

	For fk := 1 to Len(tyTblPrc)

		msTabela := tyTblPrc[fk][2]
		msCampo  := tyTblPrc[fk][3]

		If fExistTabl(RetSqlName(msTabela))

			oProcess:IncRegua2("Tabela: " + msTabela + " tempo: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

			UP001 := Alltrim(" WITH UPDTNEGOCIO                                                                                                                                                                 ") + msEnter
			UP001 += Alltrim("      AS (SELECT DISTINCT                                                                                                                                                         ") + msEnter
			UP001 += Alltrim("                 REGTBL = @TBL.R_E_C_N_O_,                                                                                                                                        ") + msEnter
			UP001 += Alltrim("                 NEGOCIO = CASE                                                                                                                                                   ") + msEnter
			UP001 += Alltrim("                               WHEN('" + cEmpAnt + "' = '01')                                                                                                                     ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL = '01')                                                                                                               ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '05')                                                                                                                  ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL = '05')                                                                                                               ") + msEnter
			UP001 += Alltrim("                               THEN '1'                                                                                                                                           ") + msEnter
			UP001 += Alltrim("                               WHEN('" + cEmpAnt + "' = '16')                                                                                                                     ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL = '16')                                                                                                               ") + msEnter
			UP001 += Alltrim("                               THEN '4'                                                                                                                                           ") + msEnter
			UP001 += Alltrim("                               WHEN('" + cEmpAnt + "' = '07'                                                                                                                      ") + msEnter
			UP001 += Alltrim("                                    AND @TBL.@TBL_DEBITO = '41101010000008')                                                                                                      ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL = '07'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_DEBITO = '41101010000008')                                                                                                   ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '07'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO, 1, 8) = '41201028')                                                                                        ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL = '07'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO, 1, 8) = '41201028')                                                                                        ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' IN('13', '14')                                                                                                           ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_DEBITO IN('41501010', '31701004', '31701005'))                                                                               ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL IN('13', '14')                                                                                                        ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_DEBITO IN('41501010', '31701004', '31701005'))                                                                               ") + msEnter
			UP001 += Alltrim("                                   OR (CTH.CTH_YENTID = '0013'                                                                                                                    ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO,1,1) IN('3','6'))                                                                                           ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' IN('13', '14')                                                                                                           ") + msEnter
			UP001 += Alltrim("                                       AND CTH.CTH_YENTID = '0015'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO,1,1) IN('3','6'))                                                                                           ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL IN('13', '14')                                                                                                        ") + msEnter
			UP001 += Alltrim("                                       AND CTH.CTH_YENTID = '0015'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO,1,1) IN('3','6'))                                                                                           ") + msEnter
			UP001 += Alltrim("                               THEN '2'                                                                                                                                           ") + msEnter
			UP001 += Alltrim("                               WHEN('" + cEmpAnt + "' = '06'                                                                                                                      ") + msEnter
			UP001 += Alltrim("                                    AND @TBL.@TBL_DEBITO = '41101010000011')                                                                                                      ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL = '06'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_DEBITO = '41101010000011')                                                                                                   ") + msEnter			
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '06'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO, 1, 3) = '412')                                                                                             ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL = '06'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO, 1, 3) = '412')                                                                                             ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '06'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO, 1, 2) = '61')                                                                                              ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL = '06'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO, 1, 2) = '61')                                                                                              ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' IN('06')                                                                                                                 ") + msEnter
			UP001 += Alltrim("                                       AND CTH.CTH_YENTID = '0015'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO,1,1) IN('3','6'))                                                                                           ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL IN('06')                                                                                                              ") + msEnter
			UP001 += Alltrim("                                       AND CTH.CTH_YENTID = '0015'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO,1,1) IN('3','6'))                                                                                           ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' IN('06')                                                                                                                 ") + msEnter
			UP001 += Alltrim("                                       AND CTH.CTH_YENTID = '0055'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO,1,1) IN('3','6'))                                                                                           ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL IN('06')                                                                                                              ") + msEnter
			UP001 += Alltrim("                                       AND CTH.CTH_YENTID = '0055'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO,1,1) IN('3','6'))                                                                                           ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '06'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO, 1, 3) = '414')                                                                                             ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL = '06'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO, 1, 3) = '414')                                                                                             ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '06'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO, 1, 3) = '318')                                                                                             ") + msEnter
			UP001 += Alltrim("                                   OR ('" + cEmpAnt + "' = '90'                                                                                                                   ") + msEnter
			UP001 += Alltrim("                                       AND @TBL.@TBL_FILIAL = '06'                                                                                                                ") + msEnter
			UP001 += Alltrim("                                       AND SUBSTRING(@TBL.@TBL_DEBITO, 1, 3) = '318')                                                                                             ") + msEnter
			UP001 += Alltrim("                               THEN '3'                                                                                                                                           ") + msEnter
			UP001 += Alltrim("                               ELSE '0'                                                                                                                                           ") + msEnter
			UP001 += Alltrim("                           END                                                                                                                                                    ") + msEnter
			UP001 += Alltrim("          FROM " + RetSqlName(msTabela) + " @TBL(NOLOCK)                                                                                                                          ") + msEnter
			UP001 += Alltrim("               INNER JOIN " + RetSqlName("CVE") + " CVE(NOLOCK) ON CVE.CVE_FILIAL = '" + xFilial("CVE") + "'                                                                      ") + msEnter
			UP001 += Alltrim("                                                AND CVE.CVE_YTPVSG = '2'                                                                                                          ") + msEnter
			UP001 += Alltrim("                                                AND CVE.D_E_L_E_T_ = ' '                                                                                                          ") + msEnter
			UP001 += Alltrim("               INNER JOIN " + RetSqlName("CTS") + " CTS(NOLOCK) ON CTS.CTS_FILIAL = '" + xFilial("CTS") + "'                                                                      ") + msEnter
			UP001 += Alltrim("                                                AND CTS.CTS_CODPLA = CVE.CVE_CODIGO                                                                                               ") + msEnter
			UP001 += Alltrim("                                                AND CTS.D_E_L_E_T_ = ' '                                                                                                          ") + msEnter
			UP001 += Alltrim("               LEFT JOIN CTH010 CTH(NOLOCK) ON CTH.CTH_FILIAL = '" + xFilial("CTH") + "'                                                                                          ") + msEnter
			UP001 += Alltrim("                                               AND CTH.CTH_CLVL = @TBL_CLVLDB                                                                                                     ") + msEnter
			UP001 += Alltrim("                                               AND CTH.D_E_L_E_T_ = ' '                                                                                                           ") + msEnter
			UP001 += Alltrim("          WHERE @TBL.@TBL_FILIAL = '" + xFilial(msTabela) + "'                                                                                                                    ") + msEnter
			UP001 += Alltrim("                AND @TBL.@TBL_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'                                                                                  ") + msEnter
			UP001 += Alltrim("                AND @TBL.@TBL_DEBITO <> '                    '                                                                                                                    ") + msEnter
			UP001 += Alltrim("                AND @TBL.@TBL_DEBITO BETWEEN CTS.CTS_CT1INI AND CTS.CTS_CT1FIM                                                                                                    ") + msEnter
			UP001 += Alltrim("                AND @TBL.D_E_L_E_T_ = ' ')                                                                                                                                        ") + msEnter
			UP001 += Alltrim("      UPDATE @TBL                                                                                                                                                                 ") + msEnter
			UP001 += Alltrim("        SET                                                                                                                                                                       ") + msEnter
			UP001 += Alltrim("            @TBL_YNEGOC = UPD.NEGOCIO                                                                                                                                             ") + msEnter
			UP001 += Alltrim("      FROM UPDTNEGOCIO UPD                                                                                                                                                        ") + msEnter
			UP001 += Alltrim("           INNER JOIN " + RetSqlName(msTabela) + " @TBL(NOLOCK) ON @TBL.R_E_C_N_O_ = UPD.REGTBL                                                                                   ") + msEnter
			UP001 += Alltrim("      WHERE UPD.NEGOCIO <> ' '                                                                                                                                                    ") + msEnter

			UP001 := Replace(UP001, "@TBL"    , msTabela)
			UP001 := Replace(UP001, "_YNEGOC" , msCampo)

			U_BIAMsgRun("Aguarde... Processando Tabela " + msTabela + "... ",,{|| msStaExcQy := TcSQLExec(UP001) })

			If msStaExcQy < 0
				lOk := .F.
			EndIf

			If lOk

				lRet := .T.

				UP002 := UP001 
				UP002 := Replace(UP002, "_DEBITO"    , "_CREDIT")
				UP002 := Replace(UP002, "_CLVLDB"    , "_CLVLCR")

				U_BIAMsgRun("Aguarde... Processando Tabela " + msTabela + "... ",,{|| msStaExcQy := TcSQLExec(UP002) })

				If msStaExcQy < 0
					lOk := .F.
				EndIf

				If lOk

					lRet := .T.

				Else

					msErroQuery := TCSQLError()

				EndIf

			Else

				msErroQuery := TCSQLError()

			EndIf

		Else 

			msErroQuery := "A tabela " + msTabela + " não existe na database para a empresa selecionada: " + cEmpAnt

		EndIf

	Next fk

	xVerRet := lRet

Return( lRet )

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
