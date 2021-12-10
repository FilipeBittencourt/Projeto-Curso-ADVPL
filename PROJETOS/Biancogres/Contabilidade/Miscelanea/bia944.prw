#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA944
@author Marcos Alberto Soprani
@since 15/12/17
@version 1.0
@description Cria uma nova revisão para a versão orçamentária vigente  
@type function
/*/

User Function BIA944()

	Local _cAreaAtu   := GetArea()
	Local M001        := GetNextAlias()
	Local M002        := GetNextAlias()
	Local _ms
	Local oEmp 	:= Nil
	Local nW	:= 0
	Local oProcess
	Local oPrcZera

	Private msEmpAtu  := cEmpAnt
	Private msFilAtu  := cFilAnt
	Private msrhEnter := CHR(13) + CHR(10)
	Private xfMensCompl := ""
	Private _cTlbAfetad := ""


	fPerg := "BIA944"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03
	_cNewRev   := MV_PAR04

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Status diferente de Fechado" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND ZB5.ZB5_STATUS <> 'F'
		AND ZB5.%NotDel%
	EndSql

	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 0
		MsgALERT("A versão informada não está devidamente fechada para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos na tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	oEmp := TLoadEmpresa():New()

	oEmp:GSEmpFil()

	If Len(oEmp:aEmpSel) > 0

		//Begin Transaction

		For nW := 1 To Len(oEmp:aEmpSel)

			RpcSetEnv( oEmp:aEmpSel[nW][1], Substr(oEmp:aEmpSel[nW][2], 1, 2) )

			smMsnPrc := oEmp:aEmpSel[nW][1] + "/" + Substr(oEmp:aEmpSel[nW][2], 1, 2) + " - " + Alltrim(oEmp:aEmpSel[nW][4])

			oProcess := MsNewProcess():New({|lEnd| fProcessa(@oProcess,oEmp:aEmpSel[nW][1], Substr(oEmp:aEmpSel[nW][2], 1, 2)) }, "Gravando...", smMsnPrc, .T.)
			oProcess:Activate()

			RpcClearEnv()

		Next nW

		Aviso("Réplica de Versão - BIA944", "Fim do processamento..." + msrhEnter + msrhEnter + _cTlbAfetad + msrhEnter + msrhEnter + " Necessário abrir a versão correspondente!!!", {'Ok'}, 3)

		RpcSetEnv( msEmpAtu, msFilAtu )

		If Type("__cInternet") == "C"
			__cInternet := Nil
		EndIf


	Else
		Aviso("Réplica de Versão - BIA944", "Não foram selecionadas empresas! Processamento não realizado" , {'Ok'}, 3)
	EndIf

	RestArea( _cAreaAtu )

Return

Static Function fProcessa(oProcess,_cEmp,_cFil)	

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(1000)             

	oProcess:IncRegua1(smMsnPrc)
	oProcess:IncRegua2("Verificando Tabelas...")

	//	StartJob("U_BIA944P",GetEnvServer(),.T.,_cEmp,_cFil,_cVersao,_cRevisa,_cAnoRef,_cNewRev)
	U_BIA944P(_cEmp,_cFil,_cVersao,_cRevisa,_cAnoRef,_cNewRev,oProcess)

Return


User Function BIA944P(_cEmp,_cFil,_cVersao,_cRevisa,_cAnoRef,_cNewRev,oProcess)


	Local M002        
	Private msrhEnter := CHR(13) + CHR(10)

	M002 := GetNextAlias()

	// ,'Z96'
	// ,'ZOY' eu criei a tabela na familia errada e com o nome do campo _VERSAO errado.
	//             Tabelas Avulsas                           Família de Tabelas usadas desde 2017                                                                                                                                                                                    Família de tabelas passas a serem usada a partir do orçamento 2021
	_cVetTabl  := {'ZCH','Z42','Z45','Z46','Z47','Z50','Z98','ZB0','ZB1','ZB2','ZB3','ZB4','ZB5','ZB6','ZB7','ZB8','ZB9','ZBA','ZBB','ZBC','ZBD','ZBE','ZBF','ZBG','ZBH','ZBI','ZBJ','ZBK','ZBL','ZBM','ZBN','ZBO','ZBP','ZBQ','ZBR','ZBS','ZBT','ZBU','ZBV','ZBW','ZBX','ZBY','ZBZ','ZO0','ZO1','ZO2','ZO3','ZO4','ZO5','ZO6','ZO7','ZO8','ZO9','ZOA','ZOB','ZOC','ZOD','ZOE','ZOF','ZOG','ZOH','ZOI','ZOJ','ZOK','ZOL','ZOM','ZON','ZOO','ZOP','ZOQ','ZOR','ZOS','ZOT','ZOU','ZOV','ZOW','ZOX','ZOZ'}
	_cTlbAfetad := ""

	For _ms := 1 to Len(_cVetTabl)

		dbSelectArea("SX2")
		dbSetOrder(1)
		dbSeek(_cVetTabl[_ms])

		msProsseg := .F.

		BeginSql Alias M002
			%noParser%
			Exec SP_BIA944 %Exp:RetSqlName(SX2->X2_CHAVE)%
		EndSql
		If (M002)->(EXISTE) = "S"
			msProsseg := .T.
		EndIf
		(M002)->(DbCloseArea())

		If msProsseg

			_cCampTab := ""
			_cIntoCam := ""
			_cTemVers := .F.

			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek(SX2->X2_CHAVE)

			If Substr(RetSqlName(SX2->X2_CHAVE),4,2) == cEmpAnt

				While !Eof() .and. SX3->X3_ARQUIVO == SX2->X2_CHAVE 

					If SX3->X3_CONTEXT <> "V"

						If "VERSAO" $ Alltrim(SX3->X3_CAMPO) 
							_cTemVers := .T.
						EndIf

						If "REVISA" $ Alltrim(SX3->X3_CAMPO) 
							_cCampTab += Alltrim(SX3->X3_CAMPO) + " = '" + _cNewRev + "', "
						Else
							_cCampTab += Alltrim(SX3->X3_CAMPO) + ", "
						EndIf

						_cIntoCam += Alltrim(SX3->X3_CAMPO) + ", "

					EndIf

					dbSelectArea("SX3")
					dbSkip()

				End

				XK001 := ""
				// Tabelas sem R_E_C_D_E_L_
				If SX2->X2_CHAVE $ "Z42/Z45/Z46/Z47/Z50/Z96"
					_cCampTab += " D_E_L_E_T_, (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName(SX2->X2_CHAVE) + ") + ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) AS R_E_C_N_O_"
					_cIntoCam += " D_E_L_E_T_, R_E_C_N_O_ "
				Else
					_cCampTab += " D_E_L_E_T_, R_E_C_D_E_L_, (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName(SX2->X2_CHAVE) + ") + ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) AS R_E_C_N_O_"
					_cIntoCam += " D_E_L_E_T_, R_E_C_D_E_L_, R_E_C_N_O_ "
				EndIf

				If _cTemVers

					msCopiaTbl := .F.
					FK001 := " SELECT VERIFICA = COUNT(*) "
					FK001 += "   FROM " + RetSqlName(SX2->X2_CHAVE) + " A "
					FK001 += "  WHERE " + SX2->X2_CHAVE + "_VERSAO = '" + _cVersao + "' "
					FK001 += "    AND " + SX2->X2_CHAVE + "_REVISA = '" + _cNewRev + "' "
					FK001 += "    AND " + SX2->X2_CHAVE + "_ANOREF = '" + _cAnoRef + "' "
					FK001 += "    AND D_E_L_E_T_ = ' ' "
					FKcIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,FK001),'FK01',.F.,.T.)
					dbSelectArea("FK01")
					dbGoTop()
					If FK01->VERIFICA == 0
						msCopiaTbl := .T.
					EndIf
					FK01->(dbCloseArea())
					Ferase(FKcIndex+GetDBExtension())     //arquivo de trabalho
					Ferase(FKcIndex+OrdBagExt())          //indice gerado

					If msCopiaTbl

						msQtdRegCp := 0
						EK002 := " SELECT VERIFICA = COUNT(*) "
						EK002 += "   FROM " + RetSqlName(SX2->X2_CHAVE) + " A "
						EK002 += "  WHERE " + SX2->X2_CHAVE + "_VERSAO = '" + _cVersao + "' "
						EK002 += "    AND " + SX2->X2_CHAVE + "_REVISA = '" + _cRevisa + "' "
						EK002 += "    AND " + SX2->X2_CHAVE + "_ANOREF = '" + _cAnoRef + "' "
						EK002 += "    AND D_E_L_E_T_ = ' ' "
						EKcIndex := CriaTrab(Nil,.f.)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,EK002),'EK02',.F.,.T.)
						dbSelectArea("EK02")
						dbGoTop()
						msQtdRegCp := EK02->VERIFICA 
						EK02->(dbCloseArea())
						Ferase(EKcIndex+GetDBExtension())     //arquivo de trabalho
						Ferase(EKcIndex+OrdBagExt())          //indice gerado

						_cTlbAfetad += SX2->X2_CHAVE + " - " + Alltrim(Upper(SX2->X2_NOME)) + " Reg.: " + Alltrim(Str(msQtdRegCp)) + msrhEnter

						XK001 := " INSERT INTO " + RetSqlName(SX2->X2_CHAVE) + "( " + _cIntoCam + " )"
						XK001 += " SELECT " + _cCampTab + " "
						XK001 += "   FROM " + RetSqlName(SX2->X2_CHAVE) + " "
						XK001 += "  WHERE " + SX2->X2_CHAVE + "_VERSAO = '" + _cVersao + "' "
						XK001 += "    AND " + SX2->X2_CHAVE + "_REVISA = '" + _cRevisa + "' "
						XK001 += "    AND " + SX2->X2_CHAVE + "_ANOREF = '" + _cAnoRef + "' "
						XK001 += "    AND D_E_L_E_T_ = ' ' "
						//U_BIAMsgRun("Aguarde... Replicando tabela: " + SX2->X2_CHAVE ,,{|| TcSQLExec(XK001) })
						oProcess:IncRegua2("Replicando tabela: " + SX2->X2_CHAVE)
						TcSQLExec(XK001)

						If SX2->X2_CHAVE == "ZBM"

							cQuery := " UPDATE " + RetSqlName("ZBM") + " "
							cQuery += "    SET ZBM_ATIVO = 'N' "
							cQuery += "  WHERE ZBM_FILIAL = '" + xFilial("ZBM") + "' "
							cQuery += "    AND ZBM_VERSAO = '" + _cVersao + "' "
							cQuery += "    AND ZBM_REVISA = '" + _cRevisa + "' "
							cQuery += "    AND ZBM_ANOREF = '" + _cAnoRef + "' "
							cQuery += "    AND D_E_L_E_T_ = ' ' "
							//							U_BIAMsgRun("Aguarde... Encerrando Sequencia GMR anterior: " + SX2->X2_CHAVE ,,{|| TcSQLExec(cQuery) })
							oProcess:IncRegua2("Encerrando Sequencia GMR anterior: " + SX2->X2_CHAVE)
							TcSQLExec(cQuery)
						EndIf						

					EndIf

				EndIf

			EndIf

		EndIf

	Next _ms

	//	Aviso("Réplica de Versão - BIA944", "Fim do processamento..." + msrhEnter + msrhEnter + _cTlbAfetad + msrhEnter + msrhEnter + " Necessário abrir a versão correspondente!!!", {'Ok'}, 3)

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
	_sAlias := GetArea()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Versão Orçamentária      ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"02","Revisão Ativa            ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ano de Referência        ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Nova Revisão             ?","","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

	RestArea(_sAlias)

Return

/*

USE [DADOSADV]
GO

****** Object:  StoredProcedure [dbo].[SP_BIA944]    Script Date: 30/11/2020 17:58:24 ******
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_BIA944](@TABELA VARCHAR(6))
AS
BEGIN
IF(EXISTS
(
SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = @TABELA
))
BEGIN
SELECT EXISTE = 'S';
END;
ELSE
SELECT EXISTE = 'N';
END;
GO

*/
