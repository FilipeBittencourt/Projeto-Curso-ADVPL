#Include "PROTHEUS.CH"

User Function FROPRT10()

	Local aArea			:= GetArea()
	Local cFiltro		:= ""
	Private cCadastro	:= "Regras de pontas para sugestão de lotes"
	Private aRotina		:= { }

	AADD(aRotina, { "Pesquisar"		, "AxPesqui"			, 0, 1 })
	AADD(aRotina, { "Visualizar"	, "AxVisual"			, 0, 2 })
	AADD(aRotina, { "Incluir"		, "U_ROPRT10F(3)"		, 0, 3 })
	AADD(aRotina, { "Alterar"		, "U_ROPRT10F(4)"		, 0, 4 })
	AADD(aRotina, { "Excluir"		, "AxDeleta"			, 0, 5 })

	DbSelectArea("ZLN")
	ZLN->(DbSetOrder(1))
	
	MBrowse( 6, 1, 22, 75, "ZLN",,,,,, ,,,,,,,,cFiltro)
	
	RestArea(aArea)
	
Return

User Function ROPRT10F(nOpc)
	
	Private bTudoOK := {} 
	
	bTudoOK := {|| ProcTudoOK(nOpc)}
	
	If (nOpc == 3)
		AxInclui("ZLN", ZLN->(Recno()), nOpc,,,, "EVAL(bTudoOK)", .F.,,,,,,.T.,,,,,)
	Else
		AxAltera("ZLN", ZLN->(Recno()), nOpc,,,,,"EVAL(bTudoOK)",    ,,,,,,.T.,,,,,)
	EndIf
	
Return 

Static Function ProcTudoOK(nOpc)

	Local cAliasTmp := Nil
	Local cId		:= IIF(ALTERA, M->(Recno()), "")	
	Local lRet		:= .T.
	
	If (M->ZLN_TIPO == 'N')
	
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			
			SELECT * FROM %Table:ZLN%
				WHERE 
				ZLN_TIPO		= 'N'	AND
				D_E_L_E_T_		= ''	AND
				R_E_C_N_O_ 		<> %Exp:cId%
		EndSql
		
		If (!(cAliasTmp)->(EOF()))
			MsgAlert("Já existe uma regra do Tipo=Normal cadastrada.","")
			lRet := .F.
		EndIf
		
		(cAliasTmp)->(DbCloseArea())
	EndIf
	
	
	If (M->ZLN_TIPO == 'E')
	
		If (!Empty(M->ZLN_FORMAT))
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				
				SELECT * FROM %Table:ZLN%
					WHERE 
					ZLN_FORMAT		= %Exp:M->ZLN_FORMAT%	AND
					D_E_L_E_T_		= ''	AND
					ZLN_TIPO		= 'E'	AND
					R_E_C_N_O_ 		<> %Exp:cId%
			EndSql
			
			If (!(cAliasTmp)->(EOF()))
				MsgAlert("Já existe uma regra com esse formato cadastrada","")
				lRet := .F.
			EndIf
			(cAliasTmp)->(DbCloseArea())
		Else
			MsgAlert("O campo formato e obrigatório para Tipo=Exceção.","")
			lRet := .F.
		EndIf
	
	EndIf
	
	
Return lRet