#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA624
@author Marcos Alberto Soprani
@since 28/03/16
@version 1.0
@description Cadastro de Escala para Equipes Operacionais
@type class
/*/

User Function BIA624()

	Private msrhEnter   := CHR(13) + CHR(10)

	dbSelectArea("Z73")
	dbGoTop()

	n := 1
	cCadastro := " ....: Cadastro de Escala para Equipes :.... "

	aRotina   := {  {"Pesquisar"        ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar"       ,'AxVisual'                             ,0, 2},;
	{                "Incluir"          ,'AxInclui'                             ,0, 3},;
	{                "Alterar"          ,'AxAltera'                             ,0, 4},;
	{                "Excluir"          ,'AxDeleta'                             ,0, 5},;
	{                "Replica Escala"   ,'U_BIA624A'                            ,0, 6} }

	mBrowse(6,1,22,75, "Z73", , , , , ,)

Return

User Function BIA624A()

	fPerg := "BIA624A"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	Processa({ || biaRptDet() })

Return

Static Function biaRptDet()

	Local msStaExcQy    := 0
	Local lOk           := .T.
	Local msMensPrc     := ""

	msMensPrc += "Esta rotina somente poderá ser usada enquanto as escalas seguirem o processo linear de controle." + msrhEnter + msrhEnter
	msMensPrc += "Caso algum dia este processo de escala seja alterado, será necessário adequar esta rotina." + msrhEnter + msrhEnter
	msMensPrc += "Confirma prosseguir?"

	If MsgYESNO(msMensPrc,"BIA624")

		Begin Transaction

			UP007 := " INSERT INTO " + RetSqlName("Z73") + " "
			UP007 += " (Z73_FILIAL, "
			UP007 += "  Z73_DIA, "
			UP007 += "  Z73_EQ1, "
			UP007 += "  Z73_EQ2, "
			UP007 += "  Z73_EQ3, "
			UP007 += "  Z73_EQ4, "
			UP007 += "  D_E_L_E_T_, " 
			UP007 += "  R_E_C_N_O_, "
			UP007 += "  Z73_TUREQ1, "
			UP007 += "  Z73_TUREQ2, "
			UP007 += "  Z73_TUREQ3, "
			UP007 += "  Z73_TUREQ4 "
			UP007 += " ) "
			UP007 += "        SELECT Z73_FILIAL, "
			UP007 += "               CONVERT(VARCHAR, DATA, 112) Z73_DIA, "
			UP007 += "               Z73_EQ1, "
			UP007 += "               Z73_EQ2, "
			UP007 += "               Z73_EQ3, "
			UP007 += "               Z73_EQ4, "
			UP007 += "               D_E_L_E_T_, "
			UP007 += "        ( "
			UP007 += "            SELECT ISNULL(MAX(R_E_C_N_O_), 0) "
			UP007 += "            FROM " + RetSqlName("Z73") + " "
			UP007 += "        ) + ROW_NUMBER() OVER( "
			UP007 += "               ORDER BY B.DATA) AS R_E_C_N_O_, "
			UP007 += "               Z73_TUREQ1, "
			UP007 += "               Z73_TUREQ2, "
			UP007 += "               Z73_TUREQ3, "
			UP007 += "               Z73_TUREQ4 "
			UP007 += "        FROM " + RetSqlName("Z73") + " Z73 "
			UP007 += "             LEFT JOIN FNC_CALENDARIO('" + dtos(MV_PAR02) + "', '" + dtos(MV_PAR03) + "') B ON 1 = 1 "
			UP007 += "        WHERE Z73_DIA = '" + dtos(MV_PAR01) + "' "
			UP007 += "              AND NOT EXISTS "
			UP007 += "        ( "
			UP007 += "            SELECT NULL "
			UP007 += "            FROM " + RetSqlName("Z73") + " XXX "
			UP007 += "            WHERE XXX.Z73_DIA = B.DATA "
			UP007 += "        ) "
			UP007 += "              AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Replicando escalas... ",,{|| msStaExcQy := TcSQLExec(UP007) })

			If msStaExcQy < 0
				lOk := .F.
			EndIf

			If !lOk

				msGravaErr := TCSQLError()
				DisarmTransaction()

			EndIf

		End Transaction

	Else

		lOk := .F.
		msGravaErr := "Mudança do quadrante de escala."

	EndIf

	If lOk

		MsgINFO("Processo concluído com sucesso")

	Else

		MsgSTOP("Processo cancelado: "  + msrhEnter + msrhEnter + msGravaErr)

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 15/07/19 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Data de referência    ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Dt Ini replica        ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Dt Fim replica        ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
