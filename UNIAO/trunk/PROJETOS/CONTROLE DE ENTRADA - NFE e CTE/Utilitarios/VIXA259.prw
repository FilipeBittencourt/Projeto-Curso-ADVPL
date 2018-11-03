#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} VIXA259
FONTE COM FUNCOES GENERICAS DO PROJETO VALIDACAO XML CTE / NFE
@type function
@author WLYSSES CERQUEIRA / FILIPE VIEIRA (FACILE)
@since 26/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function VIXA259(cUsrLog, cPswLog)

	Local aArea := GetArea()
	Local oGrpLog
	Local oBtnConf

	Private lRetorno := .F.
	Private oDlgPvt
	//Says e Gets
	Private oSayUsr
	Private oGetUsr, cGetUsr := Space(25)
	Private oSayPsw
	Private oGetPsw, cGetPsw := Space(20)
	Private oGetErr, cGetErr := ""
	//Dimens�es da janela
	Private nJanLarg := 200
	Private nJanAltu := 200

	//Criando a janela
	DEFINE MSDIALOG oDlgPvt TITLE "Login" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

	//Grupo de Login
	@ 003, 001     GROUP oGrpLog TO (nJanAltu/2)-1, (nJanLarg/2)-3         PROMPT "Login: "     OF oDlgPvt COLOR 0, 16777215 PIXEL
	//Label e Get de Usu�rio
	@ 013, 006   SAY   oSayUsr PROMPT "Usu�rio:"        SIZE 030, 007 OF oDlgPvt                    PIXEL
	@ 020, 006   MSGET oGetUsr VAR    cGetUsr           SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL

	//Label e Get da Senha
	@ 033, 006   SAY   oSayPsw PROMPT "Senha:"          SIZE 030, 007 OF oDlgPvt                    PIXEL
	@ 040, 006   MSGET oGetPsw VAR    cGetPsw           SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL PASSWORD

	//Get de Log, pois se for Say, n�o da para definir a cor
	@ 060, 006   MSGET oGetErr VAR    cGetErr        SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 NO BORDER PIXEL
	oGetErr:lActive := .F.
	oGetErr:setCSS("QLineEdit{color:#FF0000; background-color:#FEFEFE;}")

	//Bot�es
	@ (nJanAltu/2)-18, 006 BUTTON oBtnConf PROMPT "Confirmar"             SIZE (nJanLarg/2)-12, 015 OF oDlgPvt ACTION (U_VIXA259V()) PIXEL
	oBtnConf:SetCss("QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }")

	ACTIVATE MSDIALOG oDlgPvt CENTERED

	//Se a rotina foi confirmada e deu certo, atualiza o usu�rio e a senha
	If lRetorno
		cUsrLog := Alltrim(cGetUsr)
		cPswLog := Alltrim(cGetPsw)
	EndIf

	RestArea(aArea)

Return lRetorno

User Function VIXA259V()

	Local cUsrAux := Alltrim(cGetUsr)
	Local cPswAux := Alltrim(cGetPsw)
	Local cCodAux := ""

	//Pega o c�digo do usu�rio
	PswOrder(2)

	If !Empty(cUsrAux) .And. PswSeek(cUsrAux)

		cCodAux := PswRet(1)[1][1]

		If cCodAux <> cCodGestor

			cGetErr := "Usu�rio n�o � gestor de compras!"
			oGetErr:Refresh()
			Return

		EndIf

		//Agora verIfica se a senha bate com o usu�rio
		If !PswName(cPswAux)
			cGetErr := "Senha inv�lida!"
			oGetErr:Refresh()
			Return

			//Sen�o, atualiza o retorno como verdadeiro
		Else
			lRetorno := .T.
		endIf

		//Sen�o atualiza o erro e retorna para a rotina
	Else
		cGetErr := "Usu�rio n�o encontrado!"
		oGetErr:Refresh()
		Return
	EndIf

	//Se o retorno for v�lido, fecha a janela
	If lRetorno
		oDlgPvt:End()
	EndIf

Return()

Static _cValAnt := ""
Static _cValAtu := ""
Static _cRet	:= ""

User Function VIX259UF()

	Local cCampo := ""

	If ReadVar() == "M->ZZ0_CIDORI"

		_cValAtu := FwFldGet("ZZ0_UFORIG")

	ElseIf ReadVar() == "M->ZZ0_CIDDES"

		_cValAtu := FwFldGet("ZZ0_UFDEST")

	ElseIf ReadVar() == "M->ZZE_CIDORI"

		_cValAtu := FwFldGet("ZZE_UFORIG")

	ElseIf ReadVar() == "M->ZZE_CIDDES"

		_cValAtu := FwFldGet("ZZE_UFDEST")

	EndIf

	If _cValAtu <> _cValAnt .Or. Empty(_cValAtu + _cValAnt)

		_cRet := "CC2->CC2_EST == '" + _cValAtu + "'"

		_cValAnt := _cValAtu

	EndIf

Return(_cRet)

User Function VIX259CR(cNum_, cFornece_, cLoja)

	Local nW			:= 0
	Local nX			:= 0
	Local cCampoConv	:= ""
	Local cRetorno		:= ""
	Local aAreaZZ0		:= ZZ0->(GetArea())
	Local aAreaZZE		:= ZZE->(GetArea())
	Local aAreaSX3		:= SX3->(GetArea())
	Local aAreaSA2		:= SA2->(GetArea())
	
	Default cNum_ := ""
	Default cFornece_ := ""
	Default cLoja := ""
	
	DBSelectArea("SX3")
	SX3->(DBSetOrder(2))

	DBSelectArea("ZZ0")
	ZZ0->(DBSetOrder(1)) // ZZ0_FILIAL, ZZ0_CODFOR, ZZ0_LOJA, ZZ0_CTRANS, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("ZZE")
	ZZE->(DBSetOrder(1)) // ZZE_FILIAL, ZZE_NUM, ZZE_CTRANS, R_E_C_N_O_, D_E_L_E_T_

	If !ZZE->(DBSeek(xFilial("ZZE") + cNum_))

		If ZZ0->(DBSeek(xFilial("ZZ0") + cFornece_ + cLoja))

			RecLock("ZZE", .T.) // Inclui PC X Trecho (ZZE)

			For nX := 1 to ZZ0->(FCount())

				cCampoConv := Replace(ZZ0->(Field(nX)), "ZZ0", "ZZE")

				If SX3->(DBSeek(cCampoConv))
						
					If !(cCampoConv $ "ZZE_FILIAL|ZZE_CODIGO")
						
						&(cCampoConv) := ZZ0->(FieldGet(nX))
						
					Endif
						
				EndIf

			Next nX
				
			ZZE->ZZE_FILIAL	:= xFilial("ZZE")
			ZZE->ZZE_CODIGO	:= GetSXENum("ZZE", "ZZE_CODIGO")
			ZZE->ZZE_NUM	:= cNum_

			ZZE->(MsUnlock())
			
			cRetorno += ' Existe rotas para o fornecedor '+ Posicione('SA2',1,FWXFilial('ZZ0')+ZZ0->ZZ0_CODFOR,'A2_NOME') + ' - ' +  SA2->A2_COD
			
		Else
			
			cRetorno += ' N�o Existe rotas para o fornecedor '+ Posicione('SA2',1,FWXFilial('SA2')+SA2->A2_COD,'A2_NOME') + ' - ' +  SA2->A2_COD
			
		EndIf
		
	EndIf

	RestArea(aAreaZZ0)
	RestArea(aAreaZZE)
	RestArea(aAreaSX3)
	RestArea(aAreaSA2)

Return(cRetorno)

User Function VIX259CD()

	Local lRet		 := .T.
	Local cUsrAux	 := ""
	Local cPswAux	 := ""
	Local nW		 := 0
	
	Local aRetC7	 := {}
	Local aRetA2 	 := {}
	Local aRetMe 	 := {}
	
	Local nParcA2	 := 0
	Local nParcC7	 := 0
	LOcal nParcMe	 := 0
	
	Private cCodGestor := GetNewPar("MV_YVLROTX", "000000")
	
	If ALTERA .Or. INCLUI
	
		aRetA2 := Condicao(1000, SA2->A2_COND, , dDataBase)
			
		aRetC7 := Condicao(1000, SC7->C7_COND, , dDataBase)
		
		aRetMe := Condicao(1000, cCondicao	 , , dDataBase)
		
		For nW := 1 To Len(aRetA2)
			
			nParcA2 += DateDiffDay(dDataBase, aRetA2[nW][1])
			
		Next nW

		For nW := 1 To Len(aRetC7)
			
			nParcC7 += DateDiffDay(dDataBase, aRetC7[nW][1])
			
		Next nW
		
		For nW := 1 To Len(aRetMe)
			
			nParcMe += DateDiffDay(dDataBase, aRetMe[nW][1])
			
		Next nW
		
		If nParcMe > nParcA2 
		
			If !(RetCodUsr() $ cCodGestor)
			
				If Aviso("ATENCAO", "O prazo da condi��o de pagamento escolhida "+;
									"[" + cCondicao 	+ " - " + cValTochar(nParcMe) + " dias] " +;
									"� maior que do cadastro do fornecedor " +;
									"[" + SA2->A2_COND  + " - " + cValTochar(nParcA2) + " dias]" + CRLF, {"Autoriza��o Gestor", "Cancela"}, 3) == 1
	
					If !U_VIXA259(@cUsrAux, @cPswAux)
	
						lRet := .F.
	
					EndIf
	
				Else
	
					lRet := .F.
	
				EndIf
			
			EndIf
						
		Endif
	
	EndIf

Return(lRet)