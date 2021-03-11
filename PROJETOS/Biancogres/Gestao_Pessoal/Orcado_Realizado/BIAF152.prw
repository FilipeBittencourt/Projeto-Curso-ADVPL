#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF152
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao para Cadastro de Rubricas de Custo Funcionario
@type class
/*/

User Function BIAF152()

	cCadastro := Upper(Alltrim("Configuração de Rubricas"))
	aRotina   := { {"Pesquisar"    ,"AxPesqui"	    				    ,0,1},;
	{               "Visualizar"   ,'AxVisual'                          ,0,2},;
	{               "Incluir"      ,'AxInclui'                          ,0,3},;
	{               "Alterar"      ,'AxAltera'                          ,0,3},;
	{               "Excluir"      ,'AxDeleta'                          ,0,3},;
	{               "Replicar Reg" ,'ExecBlock("BXF152A",.F.,.F.)'      ,0,3}}

	dbSelectArea("ZBW")
	dbSetOrder(1)
	dbGoTop()

	mBrowse(06,01,22,75,"ZBW")	

Return

User Function BXF152A()

	Local lRet        := .F.
	Local msStaExcQy  := 0
	Local lOk         := .T.

	Default cMsg := ""

	fPerg := "BIAF152"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cCampTab := ""
	_cIntoCam := ""

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("ZBW")

	While !Eof() .and. SX3->X3_ARQUIVO == "ZBW" 

		If SX3->X3_CONTEXT <> "V"

			If "VERSAO" $ Alltrim(SX3->X3_CAMPO) 
				_cCampTab += Alltrim(SX3->X3_CAMPO) + " = '" + MV_PAR04 + "', "

			ElseIf "REVISA" $ Alltrim(SX3->X3_CAMPO) 
				_cCampTab += Alltrim(SX3->X3_CAMPO) + " = '" + MV_PAR05 + "', "

			ElseIf "ANOREF" $ Alltrim(SX3->X3_CAMPO) 
				_cCampTab += Alltrim(SX3->X3_CAMPO) + " = '" + MV_PAR06 + "', "

			Else
				_cCampTab += Alltrim(SX3->X3_CAMPO) + ", "

			EndIf

			_cIntoCam += Alltrim(SX3->X3_CAMPO) + ", "

		EndIf

		dbSelectArea("SX3")
		dbSkip()

	End

	Begin Transaction

		_cCampTab += " D_E_L_E_T_, R_E_C_D_E_L_, (SELECT ISNULL(MAX(R_E_C_N_O_), 0) FROM " + RetSqlName("ZBW") + ") + ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) AS R_E_C_N_O_"
		_cIntoCam += " D_E_L_E_T_, R_E_C_D_E_L_, R_E_C_N_O_ "

		UP0054 := " INSERT INTO " + RetSqlName("ZBW") + "( " + _cIntoCam + " )"
		UP0054 += " SELECT " + _cCampTab + " "
		UP0054 += " FROM " + RetSQLName("ZBW") + " ZBW(NOLOCK) "
		UP0054 += " WHERE ZBW_VERSAO = '" + MV_PAR01 + "' "
		UP0054 += "       AND ZBW_REVISA = '" + MV_PAR02 + "' "
		UP0054 += "       AND ZBW_ANOREF = '" + MV_PAR03 + "' "
		UP0054 += "       AND (ZBW_EVENTO <> '' OR ZBW_TABELA = '3') "
		UP0054 += "       AND ZBW_EVENTO NOT IN
		UP0054 += " (
		UP0054 += "     SELECT XXX.ZBW_EVENTO
		UP0054 += "     FROM " + RetSQLName("ZBW") + " XXX(NOLOCK)
		UP0054 += "     WHERE XXX.ZBW_VERSAO = '" + MV_PAR04 + "'
		UP0054 += "           AND XXX.ZBW_REVISA = '" + MV_PAR05 + "'
		UP0054 += "           AND XXX.ZBW_ANOREF = '" + MV_PAR06 + "'
		UP0054 += "           AND XXX.D_E_L_E_T_ = ' '
		UP0054 += " )
		UP0054 += "       AND ZBW.D_E_L_E_T_ = ' ' "	
		U_BIAMsgRun("Aguarde... Gravando registros ZBW... ",,{|| msStaExcQy := TcSQLExec(UP0054) })
		If msStaExcQy < 0
			lOk := .F.
		EndIf

		If lOk

			lRet := .T.

		Else

			msGravaErr := TCSQLError()
			DisarmTransaction()

		EndIf

		xVerRet := lRet 

	End Transaction

	If lOk

		MsgINFO("Processamento realizado com sucesso.", "BIAF152")

	Else

		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )

	EndIf

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
	aAdd(aRegs,{cPerg,"01","Versão Orçamentária (Anterior)?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"02","Revisão Ativa (Anterior)      ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ano de Referência (Anterior)  ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Versão Orçamentária (Atual)   ?","","","mv_ch4","C",10,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"05","Revisão Ativa (Atual)         ?","","","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Ano de Referência (Atual)     ?","","","mv_ch6","C",04,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
