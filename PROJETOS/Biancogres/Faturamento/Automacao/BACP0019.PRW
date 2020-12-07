#Include "Protheus.ch"


User Function BACP0019()
	
	Local aArea			:= GetArea()
	Local cFiltro		:= ""
	Private cCadastro	:= "Aprovadores Temporários"
	Private aRotina		:= { }

	AADD(aRotina, { "Pesquisar"		, "AxPesqui"	, 0, 1 })
	AADD(aRotina, { "Visualizar"	, "AxVisual"	, 0, 2 })
	AADD(aRotina, { "Incluir"		, "U_BACP019F(3)"	, 0, 3 })
	AADD(aRotina, { "Alterar"		, "U_BACP019F(4)"	, 0, 4 })
	AADD(aRotina, { "Excluir"		, "AxDeleta"	, 0, 5 })

	DbSelectArea("ZKQ")
	ZKQ->(DbSetOrder(1))
	
	If !U_VALOPER("APT", .F.)
		cFiltro := " ZKQ_APROV = "+__cUserID
	EndIf
	
	MBrowse( 6, 1, 22, 75, "ZKQ",,,,,, ,,,,,,,,cFiltro)
	
	RestArea(aArea)
	
Return

User Function BACP019F(nOpc)
	
	Private bTudoOK := {} 
	
	bTudoOK := {|| ProcTudoOK(nOpc)}
	
	If (nOpc == 3)
		AxInclui("ZKQ", ZKQ->(Recno()), nOpc,,,, "EVAL(bTudoOK)", .F.,,,,,,.T.,,,,,)
	Else
		AxAltera("ZKQ", ZKQ->(Recno()), nOpc,,,,,"EVAL(bTudoOK)",    ,,,,,,.T.,,,,,)
	EndIf
	
Return 

Static Function ProcTudoOK(nOpc)

	Local lRet := .T.
	
	If (M->ZKQ_DTFIM < M->ZKQ_DTINI)
		MsgStop("O campo 'Dt. Fim' deve ser maior que 'Dt. Inicio'.","Alerta")
		lRet := .F.	
	EndIf
	
	If (lRet)
		If nOpc == 4
		
			If (ZKQ->ZKQ_DTINI <= dDataBase .And. M->ZKQ_DTINI <> ZKQ->ZKQ_DTINI)
				MsgStop("Não é possivel alterar a 'Dt. Inicio' pois a mesma já estar em vigor.","Alerta")
				lRet := .F.	
			EndIf
		
		EndIf
	EndIf
	
	If (lRet)
		If (TmpAtivoAprov())
			MsgStop("Existe um regra ativa para esse aprovador no periodo informado.","Alerta")
			lRet := .F.	
		EndIf	
	EndIf

Return lRet

Static Function TmpAtivoAprov()

	Local cAliasTmp := GetNextAlias()
	Local cAprov	:= M->ZKQ_APROV
	Local dDtIni	:= M->ZKQ_DTINI
	Local dDtFim	:= M->ZKQ_DTFIM	
	Local cId		:= IIF(ALTERA, M->(Recno()), "")	
	
	BeginSql Alias cAliasTmp
		
		SELECT * FROM %Table:ZKQ%
			WHERE 
			ZKQ_STATUS		= 1		AND
			D_E_L_E_T_		= ''	AND
			(
				CONVERT(date, %Exp:dDtIni%) BETWEEN CONVERT(date, ZKQ_DTINI) AND CONVERT(date, ZKQ_DTFIM)
				OR
				CONVERT(date, %Exp:dDtFim%) BETWEEN CONVERT(date, ZKQ_DTINI) AND CONVERT(date, ZKQ_DTFIM)	
			)
			AND ZKQ_APROV 	= %Exp:cAprov%
			AND R_E_C_N_O_ <> %Exp:cId%
		
	EndSql
	
	
	If (!(cAliasTmp)->(EOF()))
		(cAliasTmp)->(DbCloseArea())
		Return .T.
	EndIf

	(cAliasTmp)->(DbCloseArea())
Return .F.