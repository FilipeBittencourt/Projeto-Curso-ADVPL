#Include "Totvs.Ch"
#Include "RwMake.Ch"
#Include "TopConn.Ch"

//////////////////////////////////////////////////////////////////////////////////////////////////////
// Empresa: Facile Sistemas																			//
// Desenv.: Paulo Cesar Camata Jr																	//
// Dt Des.: 16/09/2013																				//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Objetivo do Programa																				//
// Criar tela para que o usuario possa estar informando as 5 placas e a observacao para ser apresen	//
// tado na televisao (Programa TelaTv que é responsavel pela apresentacao). Tela foi alterada para	//
// que possa ser passado a empresa como parametro para a funcao e a mesma busque as informacoes da	//
// empresa que foi passada no parametro.															//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// ATUALIZACOES																						//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// DESENV.		// DATA 	// ALTERACOES															//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Paulo Camata	// 14.01.14	// Trocando as informacoes de parametros para tabela no banco de dados	//
//	(Facile)	//			// devido a problemas na exibicao dos dados na televisao				//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Paulo Camata	// 11.08.14	// Alterando tela para que sejam colocadas apenas as placas e Local de	//
//	(Facile)	//			// carregamento. Foi inserido também funções de Prox. Reg. e Não Carreg.//
//////////////////////////////////////////////////////////////////////////////////////////////////////
User Function fCarregamento() 

	Local oDlg

	Local oFont1 := TFont():New("Arial",,018,,.F.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("Arial",,024,,.F.,,,,,.F.,.F.)

	Local _nDifLinha := 20

	Local aItems := Nil

	If (AllTrim(CEMPANT) $ "01_05")
		aItems := StrTokArr(GetNewPar("MV_YLOCCAR", " /G5/G7/G12/G12 E G5/G12 E G7/G5 E G7/G12 G5 E G7"), "/") // Itens para selecao nos combos de Locais
	Else
		aItems := StrTokArr(GetNewPar("MV_YLOCCAR", " /G5/G12/VITCER/MUNDI/INCESA"), "/") // Itens para selecao nos combos de Locais
	EndIf


	Private cGet1   := Space(TamSx3("PZ1_PLCG01")[1])
	Private cGet2   := Space(TamSx3("PZ1_PLCG02")[1])
	Private cGet3   := Space(TamSx3("PZ1_PLCG03")[1])
	Private cGet4   := Space(TamSx3("PZ1_PLCG04")[1])
	Private cGet5   := Space(TamSx3("PZ1_PLCG05")[1])
	Private cGet6   := Space(TamSx3("PZ1_PLCG06")[1])
	Private cGet7   := Space(TamSx3("PZ1_PLCG07")[1])
	Private cGet8   := Space(TamSx3("PZ1_PLCG08")[1])
	Private cGet9   := Space(TamSx3("PZ1_PLCG09")[1])
	Private cGet10  := Space(TamSx3("PZ1_PLCG10")[1])
	Private cGet11  := Space(TamSx3("PZ1_PLCG11")[1])
	Private cGet12  := Space(TamSx3("PZ1_PLCG12")[1])

	Private cCombo1  := Space(TamSx3("PZ1_LCCG01")[1])
	Private cCombo2  := Space(TamSx3("PZ1_LCCG02")[1])
	Private cCombo3  := Space(TamSx3("PZ1_LCCG03")[1])
	Private cCombo4  := Space(TamSx3("PZ1_LCCG04")[1])
	Private cCombo5  := Space(TamSx3("PZ1_LCCG05")[1])
	Private cCombo6  := Space(TamSx3("PZ1_LCCG06")[1])
	Private cCombo7  := Space(TamSx3("PZ1_LCCG07")[1])
	Private cCombo8  := Space(TamSx3("PZ1_LCCG08")[1])
	Private cCombo9  := Space(TamSx3("PZ1_LCCG09")[1])
	Private cCombo10 := Space(TamSx3("PZ1_LCCG10")[1])
	Private cCombo11 := Space(TamSx3("PZ1_LCCG11")[1])
	Private cCombo12 := Space(TamSx3("PZ1_LCCG12")[1])

	Private cGetObs  := Space(TamSx3("PZ1_OBSCAR")[1])

	Private nQtdPlacas := 12

	// Nome da Empresa
	cNomEmp := SM0->M0_NOME

	Define MsDialog oDlg Title "PLACAS PARA CARREGAMENTO" From 000, 000 To 660, 800 COLORS 0, 16777215 Pixel

	@ 006, 072 Say oSay PROMPT "INFORME AS PLACAS PARA CARREGAMENTO " Size 230, 012 Of oDlg FONT oFont2 COLORS 0, 16777215 Pixel CENTERED
	@ 020, 072 Say oSay PROMPT "EMPRESA: " + AllTrim(Upper(cEmpAnt + " - " + cNomEmp)) Size 230, 012 OF oDlg FONT oFont2 COLORS 0, 16777215 Pixel CENTERED

	_nLin := 40
	_nCol1 := 32
	_nCol2 := 65
	_nCol3 := 105
	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 1:" Size 027, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet1 VAR cGet1 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG01") Valid If(!Empty(cGet1), U_VldPlaca(cGet1), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo1 := u, cCombo1)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo1")	
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 2:" Size 027, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet2 VAR cGet2 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG02") Valid If(!Empty(cGet2), U_VldPlaca(cGet2), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo2 := u, cCombo2)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo2")	
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 3:" Size 027, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet3 VAR cGet3 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG03") Valid If(!Empty(cGet3), U_VldPlaca(cGet3), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo3 := u, cCombo3)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo3")	
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 4:" Size 027, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet4 VAR cGet4 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG04") Valid If(!Empty(cGet4), U_VldPlaca(cGet4), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo4 := u, cCombo4)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo4")	
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 5:" Size 027, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet5 VAR cGet5 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG05") Valid If(!Empty(cGet5), U_VldPlaca(cGet5), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo5 := u, cCombo5)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo5")	
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 6:" Size 027, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet6 VAR cGet6 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG06") Valid If(!Empty(cGet6), U_VldPlaca(cGet6), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo6 := u, cCombo6)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo6")	
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 7:" Size 027, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet7 VAR cGet7 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG07") Valid If(!Empty(cGet7), U_VldPlaca(cGet7), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo7 := u, cCombo7)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo7")	
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 8:" Size 027, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet8 VAR cGet8 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG08") Valid If(!Empty(cGet8), U_VldPlaca(cGet8), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo8 := u, cCombo8)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo8")	
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 9:" Size 027, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet9 VAR cGet9 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG09") Valid If(!Empty(cGet9), U_VldPlaca(cGet9), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo9 := u, cCombo9)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo9")
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 10:" Size 035, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet10 VAR cGet10 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG10") Valid If(!Empty(cGet10), U_VldPlaca(cGet10), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo10 := u, cCombo10)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo10")
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 11:" Size 035, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet11 VAR cGet11 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG11") Valid If(!Empty(cGet11), U_VldPlaca(cGet11), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo11 := u, cCombo11)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo11")
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay PROMPT "Placa 12:" Size 035, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet12 VAR cGet12 Size 050, 012 Of oDlg Picture PesqPict("PZ1", "PZ1_PLCG12") Valid If(!Empty(cGet12), U_VldPlaca(cGet12), .T.) COLORS 0, 16777215 FONT oFont1 F3 "Z11" Pixel
	oCombo := TComboBox():Create(oDlg, {|u| If(PCount() > 0, cCombo12 := u, cCombo12)}, _nLin, 120, aItems, _nCol3, 20,,,,,,.T.,,,,,,,,,"cCombo12")
	_nLin += _nDifLinha

	@ _nLin,   _nCol1 Say oSay12 PROMPT "Obs.:" Size 021, 007 Of oDlg FONT oFont1 COLORS 0, 16777215 Pixel
	@ _nLin-2, _nCol2 MsGet oGet13 VAR cGetObs  Size 300, 014 Of oDlg Picture "@!" COLORS 0, 16777215 FONT oFont1 Pixel

	// Objeto Say para descrever a data e hora da ultima atualizacao que as informacoes sofreram
	_nLin += _nDifLinha
	oSay13 := TSay():New( _nLin, _nCol1, {|| " "}, oDlg, , oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 200,8)

	aButtons := {}
	Aadd( aButtons, {"GLOMER", {|| fBusAtual()},  "Dad. Atual", "Dad. Atual" , {|| .T.}} ) 
	Aadd( aButtons, {"GLOMER", {|| fProxReg() },  "Prox. Reg.", "Prox. Reg." , {|| .T.}} ) 
	Aadd( aButtons, {"GLOMER", {|| fNaoCarreg()}, "Nao Carreg", "Nao Carreg" , {|| .T.}} ) 

	EnchoiceBar(oDlg, {|| fAtualiza() }, {|| oDlg:End()}, , aButtons)

	Activate MsDialog oDlg Centered

	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////
// Funcao para validar se a Placa informada no GET é válida //
//////////////////////////////////////////////////////////////
User Function VldPlaca(_cPlaca, _lMsg)
	// Regra para validacao
	Local _cEoL := Chr(13) + Chr(10)
	Local _lRet := .F.

	Default _lMsg := .T.

	// Comando SQL para buscar o Nome do motorista pela placa
	_cSelect := "SELECT Z11_MOTORI " + _cEoL
	_cSelect += "  FROM " + RetSqlName("Z11") + _cEoL
	_cSelect += " WHERE Z11_FILIAL = " + ValToSql(xFilial("Z11")) + _cEoL
	_cSelect += "   AND Z11_PESOIN = 0 " + _cEoL
	_cSelect += "   AND Z11_PESOSA = 0 " + _cEoL
	_cSelect += "   AND Z11_PCAVAL = " + ValToSql(_cPlaca) + _cEoL
	_cSelect += "   AND D_E_L_E_T_ = '' " + _cEoL

	TcQuery _cSelect New Alias "MOTORISTA"

	If !MOTORISTA->(EoF())
		_lRet := .T.
	ElseIf _lMsg
		MsgStop("Placa não encontrada no registro de Pesagem (Z11). Verifique.", "FCARREGAMENTO")
	EndIf
	MOTORISTA->(DbCloseArea())

	Return _lRet
	*-----------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////
// Funcao para atualizar os parametros caso haja modificacao //
///////////////////////////////////////////////////////////////
Static Function fAtualiza()

	Local i

	// Valida se nao ha dados repetidos nos campos
	If !fVldPlRepet()
		Return Nil
	EndIf

	// Efetuando a validacao de todas as placas
	For  i := 1 To nQtdPlacas
		If !Empty(&("cGet" + AllTrim(Str(i)))) .And. !U_VldPlaca(&("cGet" + AllTrim(Str(i))), .F.)
			MsgStop("Placa " + cValToChar(i) + " não foi cadastrada ou já foi carregada. Verifique", "FCARREGAMENTO")
			Return Nil
		EndIf
	Next i

	// Atualizando informacoes na tabela PZ1
	PZ1->(DbGoTop())
	If Posicione("PZ1", 1, xFilial("PZ1"), "FOUND()")
		RecLock("PZ1", .F.)
	Else
		RecLock("PZ1", .T.)
	EndIf		

	PZ1->PZ1_FILIAL := xFilial("PZ1")

	For i := 1 To nQtdPlacas
		&("PZ1->PZ1_PLCG" + StrZero(i, 2)) := &("cGet" + AllTrim(Str(i)))
		&("PZ1->PZ1_LCCG" + StrZero(i, 2)) := &("cCombo" + AllTrim(Str(i)))
	Next i

	PZ1->PZ1_OBSCAR := cGetObs
	PZ1->PZ1_ATUCAR := DTOC(Date()) + " - " + Time()
	PZ1->PZ1_STATUS := "A"

	PZ1->(MsUnlock())

	MsgInfo("Dados Atualizados com sucesso!")

	// Limpando dados da tela
	fLimpaTela()

	// Texto da ultima atualizacao
	oSay13:SetText("Atualizado em " + PZ1->PZ1_ATUCAR)

	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcao para buscar os dados que estao sendo apresentados na tela da TV (Caso usuario queira alterar apenas alguma informacao) //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fBusAtual()

	Local i

	// Verificando se existem informacao para a empresa selecionada
	PZ1->(DbGoTop())
	If Posicione("PZ1", 1, xFilial("PZ1"), "FOUND()")
		// Buscando todos os registros da tabela PZ1 para buscar atualizacoes
		For i := 1 To nQtdPlacas
			&("cGet" + AllTrim(Str(i)))   := &("PZ1->PZ1_PLCG" + StrZero(i, 2))
			&("cCombo" + AllTrim(Str(i))) := &("PZ1->PZ1_LCCG" + StrZero(i, 2))
		Next i

		// Observacao
		cGetObs := PZ1->PZ1_OBSCAR
		oSay13:SetText("Atualizado em " + PZ1->PZ1_ATUCAR) // Atualizacao

	Else // Nao encontrado registro na tabela
		MsgInfo("Não foram encontrados dados de Carregamento para a empresa " + cEmpAnt, "FCARREGAMENTO")
	EndIf

	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcao para Incluir um registro novo na primeira posicao, fazendo com que todos os outros sejam deslocados uma posicao	//
// automaticamente o ultimo registro sera deletado da tela																	//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fProxReg()

	Local i

	// Verifica se o primeiro Registro esta preenchido, caso esteja apenas move todos os registros para baixo
	If Empty(cGet1)
		fBusAtual()
	EndIf

	// Movendo todos os registros para baixo
	For i := nQtdPlacas To 2 Step -1
		&("cGet" + AllTrim(Str(i)))   := &("cGet" + AllTrim(Str(i-1)))
		&("cCombo" + AllTrim(Str(i))) := &("cCombo" + AllTrim(Str(i-1)))
	Next i

	// Deixando os primeiros registros em branco (Proposta da Funcao)
	cGet1   := Space(TamSx3("PZ1_PLCG01")[1])
	cCombo1 := Space(TamSx3("PZ1_LCCG01")[1])

	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////
// Funcao para verificar se foi informado algum elemento repetido (Placa) //
////////////////////////////////////////////////////////////////////////////
Static Function fVldPlRepet()

	Local i, j

	// Varrendo todas as placas
	For i := 1 To nQtdPlacas
		// Varrendo proximas placas ate o final
		For j := i + 1 To nQtdPlacas
			If !Empty(&("cGet" + cValToChar(i))) .And. &("cGet" + cValToChar(i)) == &("cGet" + cValToChar(j))
				MsgStop("Existem informações repetidas. Placa " + cValToChar(i) + " e placa " + cValToChar(j), "TelaTvFull")
				Return .F.
			EndIf
		Next j
	Next i

	Return .T.
	*-----------------------------------------------------------------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////////////////////////////////
// Funcao Responsavel em atualizar as placas na tabela PZ1 com somente as que foram carregadas //
/////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fNaoCarreg()

	Local i

	_aPlaAux := {}
	_aLocAux := {}

	PZ1->(DbGoTop())
	If Posicione("PZ1", 1, xFilial("PZ1"), "FOUND()")

		// Percorrendo todas as placas e verificando se existe na Tabela Z11
		For i := 1 To nQtdPlacas

			_cPlaAux := &("PZ1->PZ1_PLCG" + StrZero(i, 2))

			If !Empty(_cPlaAux) .And. U_VldPlaca(_cPlaAux, .F.)
				aAdd(_aPlaAux, _cPlaAux)
				aAdd(_aLocAux, &("PZ1->PZ1_LCCG" + StrZero(i, 2)))
			EndIf
		Next i

		// Limpando todos os campos da Tela 
		fLimpaTela()

		// Carregando os campos
		For i := 1 To Len(_aPlaAux)
			&("cGet" + AllTrim(Str(i)))   := _aPlaAux[i]
			&("cCombo" + AllTrim(Str(i))) := _aLocAux[i]
		Next i

		// Verifica se pelo menos o primeiro item foi preenchido
		If !Empty(cGet1)
			// Observacao
			cGetObs := PZ1->PZ1_OBSCAR
			oSay13:SetText("Atualizado em " + PZ1->PZ1_ATUCAR) // Atualizacao
		EndIf

	EndIf

	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////
// Funcao para Limpar todos os campos da Tela //
////////////////////////////////////////////////
Static Function fLimpaTela()

	Local  i

	/*
	cGet1    := Space(TamSx3("PZ1_PLCG01")[1])
	cGet2    := Space(TamSx3("PZ1_PLCG02")[1])
	cGet3    := Space(TamSx3("PZ1_PLCG03")[1])
	cGet4    := Space(TamSx3("PZ1_PLCG04")[1])
	cGet5    := Space(TamSx3("PZ1_PLCG05")[1])
	cGet6    := Space(TamSx3("PZ1_PLCG06")[1])
	cGet7    := Space(TamSx3("PZ1_PLCG07")[1])
	cGet8    := Space(TamSx3("PZ1_PLCG08")[1])
	cGet9    := Space(TamSx3("PZ1_PLCG09")[1])
	cGet10   := Space(TamSx3("PZ1_PLCG10")[1])
	cGet11   := Space(TamSx3("PZ1_PLCG11")[1])
	cGet12   := Space(TamSx3("PZ1_PLCG12")[1])

	cCombo1  := Space(TamSx3("PZ1_LCCG01")[1])
	cCombo2  := Space(TamSx3("PZ1_LCCG02")[1])
	cCombo3  := Space(TamSx3("PZ1_LCCG03")[1])
	cCombo4  := Space(TamSx3("PZ1_LCCG04")[1])
	cCombo5  := Space(TamSx3("PZ1_LCCG05")[1])
	cCombo6  := Space(TamSx3("PZ1_LCCG06")[1])
	cCombo7  := Space(TamSx3("PZ1_LCCG07")[1])
	cCombo8  := Space(TamSx3("PZ1_LCCG08")[1])
	cCombo9  := Space(TamSx3("PZ1_LCCG09")[1])
	cCombo10 := Space(TamSx3("PZ1_LCCG10")[1])
	cCombo11 := Space(TamSx3("PZ1_LCCG11")[1])
	cCombo12 := Space(TamSx3("PZ1_LCCG12")[1])
	*/

	For i := 1 To nQtdPlacas
		&("cGet" + cValToChar(i)) := Space(TamSx3("PZ1_PLCG" + StrZero(i, 2))[1])
		&("cCombo" + cValToChar(i)) := Space(TamSx3("PZ1_LCCG" + StrZero(i, 2))[1])
	Next i

	cGetObs  := Space(TamSx3("PZ1_OBSCAR")[1])
	Return Nil
	*-----------------------------------------------------------------------------------------------------------------------------------