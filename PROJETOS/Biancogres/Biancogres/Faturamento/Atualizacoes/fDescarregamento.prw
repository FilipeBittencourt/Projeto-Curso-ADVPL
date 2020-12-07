#Include "Totvs.Ch"
#Include "RwMake.Ch"
#Include "TopConn.Ch"

//////////////////////////////////////////////////////////////////////////////////////////////////////
// Empresa: Facile Sistemas																			//
// Desenv.: Paulo Cesar Camata Jr																	//
// Dt Des.: 10/07/2013																				//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Objetivo do Programa																				//
// Criar tela para que o usuario possa estar informando as 5 placas e a observacao para ser apresen	//
// tado na televisao (Programa TelaTv que é responsavel pela apresentacao)							//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// ATUALIZACOES																						//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// DESENV.		// DATA 	// ALTERACOES															//
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Paulo Camata	// 14.01.14	// Trocando as informacoes de parametros para tabela no banco de dados	//
//	(Facile)	//			// devido a problemas na exibicao dos dados na televisao				//
//////////////////////////////////////////////////////////////////////////////////////////////////////
User Function fDescarregamento()

	Local oDlg

	Local oFont1 := TFont():New("Arial",,018,,.F.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("Arial",,024,,.F.,,,,,.F.,.F.)

	Local oGet1
	Local oGet2
	Local oGet3
	Local oGet4
	Local oGet5
	Local oGet6
	Local oGet7
	Local oGet8
	Local oGet9
	Local oGet10
	Local oGet11
	
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	
	Private oSay8
	
	Private nTamPlaca := TamSx3("PZ1_PLDES1")[1] // Tamanho da Campo Placa
	Private nTamMotor := TamSx3("PZ1_MTDES1")[1] // Tamanho do Campo Motorista
	Private nTamObser := TamSx3("PZ1_OBSDES")[1] // Tamanho do Campo Observacao
	
	Private cGet1 := Space(nTamPlaca)
	Private cGet2 := Space(nTamMotor)
	Private cGet3 := Space(nTamPlaca)
	Private cGet4 := Space(nTamMotor)
	Private cGet5 := Space(nTamPlaca)
	Private cGet6 := Space(nTamMotor)
	Private cGet7 := Space(nTamPlaca)
	Private cGet8 := Space(nTamMotor)
	Private cGet9 := Space(nTamPlaca)
	Private cGet10:= Space(nTamMotor)

	Private cGet11:= Space(nTamObser)

	DEFINE MSDIALOG oDlg TITLE "PLACAS PARA DESCARREGAMENTO" FROM 000, 000  TO 370, 800 COLORS CLR_BLACK PIXEL
    
    @ 006, 072 SAY oSay1 PROMPT "INFORME AS PLACAS PARA DESCARREGAMENTO" SIZE 300, 012 OF oDlg FONT oFont2 COLORS CLR_BLACK PIXEL
    
    @ 030, 032 SAY oSay2 PROMPT "Placa 1:" SIZE 027, 007 OF oDlg FONT oFont1 COLORS CLR_BLACK PIXEL
    @ 028, 060 MSGET oGet1 VAR cGet1 SIZE 045, 012 OF oDlg PICTURE "@!R AAA-9999" COLORS CLR_BLACK FONT oFont1 PIXEL
    @ 028, 120 MSGET oGet2 VAR cGet2 SIZE 150, 012 OF oDlg PICTURE "@!" COLORS CLR_BLACK FONT oFont1 PIXEL
    
    @ 050, 032 SAY oSay3 PROMPT "Placa 2:" SIZE 027, 007 OF oDlg FONT oFont1 COLORS CLR_BLACK PIXEL
    @ 048, 060 MSGET oGet3 VAR cGet3 SIZE 045, 012 OF oDlg PICTURE "@!R AAA-9999" COLORS CLR_BLACK FONT oFont1 PIXEL
    @ 048, 120 MSGET oGet4 VAR cGet4 SIZE 150, 012 OF oDlg PICTURE "@!" COLORS CLR_BLACK FONT oFont1 PIXEL
    
    @ 070, 032 SAY oSay4 PROMPT "Placa 3:" SIZE 027, 007 OF oDlg FONT oFont1 COLORS CLR_BLACK PIXEL
    @ 068, 060 MSGET oGet5 VAR cGet5 SIZE 045, 012 OF oDlg PICTURE "@!R AAA-9999" COLORS CLR_BLACK FONT oFont1 PIXEL
    @ 068, 120 MSGET oGet6 VAR cGet6 SIZE 150, 012 OF oDlg PICTURE "@!" COLORS CLR_BLACK FONT oFont1 PIXEL
    
    @ 090, 032 SAY oSay5 PROMPT "Placa 4:" SIZE 027, 007 OF oDlg FONT oFont1 COLORS CLR_BLACK PIXEL
    @ 088, 060 MSGET oGet7 VAR cGet7 SIZE 045, 012 OF oDlg PICTURE "@!R AAA-9999" COLORS CLR_BLACK FONT oFont1 PIXEL
    @ 088, 120 MSGET oGet8 VAR cGet8 SIZE 150, 012 OF oDlg PICTURE "@!" COLORS CLR_BLACK FONT oFont1 PIXEL
    
    @ 110, 032 SAY oSay6 PROMPT "Placa 5:" SIZE 027, 007 OF oDlg FONT oFont1 COLORS CLR_BLACK PIXEL
    @ 108, 060 MSGET oGet9 VAR cGet9 SIZE 045, 012 OF oDlg PICTURE "@!R AAA-9999" COLORS CLR_BLACK FONT oFont1 PIXEL
    @ 108, 120 MSGET oGet10 VAR cGet10 SIZE 150, 012 OF oDlg PICTURE "@!" COLORS CLR_BLACK FONT oFont1 PIXEL
    
    @ 130, 032 SAY oSay7 PROMPT "Obs.:" SIZE 021, 007 OF oDlg FONT oFont1 COLORS CLR_BLACK PIXEL
    @ 128, 060 MSGET oGet11 VAR cGet11 SIZE 300, 014 OF oDlg PICTURE "@!" COLORS CLR_BLACK FONT oFont1 PIXEL
    
    // Objeto Say para descrever a data e hora da ultima atualizacao que as informacoes sofreram
    oSay8 := TSay():New( 155, 032, {|| }, oDlg, , oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 200,8)
    
    aButtons := {}
    Aadd( aButtons, {"GLOMER", {|| fBusAtual()}, "Dad. Atual", "Dad. Atual" , {|| .T.}} ) 
    
    EnchoiceBar(oDlg, {|| fAtualiza() }, {|| oDlg:End()}, , aButtons)
    
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////
// Funcao para atualizar os parametros caso haja modificacao //
///////////////////////////////////////////////////////////////
Static Function fAtualiza()
	// Verificando se foi informado alguma placa repetida
	Do Case
		Case cGet1 == cGet3 .And. !Empty(cGet1)
			MsgStop("Placa 1 igual a Placa 2. Verifique.")
			Return Nil
		
		Case cGet1 == cGet5 .And. !Empty(cGet1)
			MsgStop("Placa 1 igual a Placa 3. Verifique.")
			Return Nil
		
		Case cGet1 == cGet7 .And. !Empty(cGet1)
			MsgStop("Placa 1 igual a Placa 4. Verifique.")
			Return Nil
			
		Case cGet1 == cGet9 .And. !Empty(cGet1)
			MsgStop("Placa 1 igual a Placa 5. Verifique.")
			Return Nil
			
		Case cGet3 == cGet5 .And. !Empty(cGet3)
			MsgStop("Placa 2 igual a Placa 3. Verifique.")
			Return Nil
			
		Case cGet3 == cGet7 .And. !Empty(cGet3)
			MsgStop("Placa 2 igual a Placa 4. Verifique.")
			Return Nil
			
		Case cGet3 == cGet9 .And. !Empty(cGet3)
			MsgStop("Placa 2 igual a Placa 5. Verifique.")
			Return Nil
			
		Case cGet5 == cGet7 .And. !Empty(cGet5)
			MsgStop("Placa 3 igual a Placa 4. Verifique.")
			Return Nil
			
		Case cGet5 == cGet9 .And. !Empty(cGet5)
			MsgStop("Placa 3 igual a Placa 5. Verifique.")
			Return Nil
			
		Case cGet7 == cGet9 .And. !Empty(cGet7)
			MsgStop("Placa 4 igual a Placa 5. Verifique.")
			Return Nil
		
		// Verificando se foi informado alguma placa sem nome do motorista
		Case !Empty(cGet1) .And. Empty(cGet2)
			MsgStop("Foi informado a placa 1 e está sem nome do motorista. Verifique.")
			Return Nil
			
		Case !Empty(cGet3) .And. Empty(cGet4)
			MsgStop("Foi informado a placa 2 e está sem nome do motorista. Verifique.")
			Return Nil
		
		Case !Empty(cGet5) .And. Empty(cGet6)
			MsgStop("Foi informado a placa 3 e está sem nome do motorista. Verifique.")
			Return Nil
		
		Case !Empty(cGet7) .And. Empty(cGet8)
			MsgStop("Foi informado a placa 4 e está sem nome do motorista. Verifique.")
			Return Nil
		
		Case !Empty(cGet9) .And. Empty(cGet10)
			MsgStop("Foi informado a placa 5 e está sem nome do motorista. Verifique.")
			Return Nil
		
	EndCase
	
	// Atualizando informacoes
	If Posicione("PZ1", 1, xFilial("PZ1"), "FOUND()")
		RecLock("PZ1", .F.)
	Else
		RecLock("PZ1", .T.)
	EndIf		
	
		PZ1->PZ1_FILIAL := xFilial("PZ1")
		PZ1->PZ1_PLDES1 := cGet1
		PZ1->PZ1_MTDES1 := cGet2
		PZ1->PZ1_PLDES2 := cGet3
		PZ1->PZ1_MTDES2 := cGet4
		PZ1->PZ1_PLDES3 := cGet5
		PZ1->PZ1_MTDES3 := cGet6
		PZ1->PZ1_PLDES4 := cGet7
		PZ1->PZ1_MTDES4 := cGet8
		PZ1->PZ1_PLDES5 := cGet9
		PZ1->PZ1_MTDES5 := cGet10
		PZ1->PZ1_OBSDES := cGet11
		PZ1->PZ1_ATUDES := DTOC(Date()) + " - " + Time()
		PZ1->PZ1_STATUS := "A"
			
	PZ1->(MsUnlock())
	
	MsgInfo("Dados Atualizados com sucesso!")

	oSay8:SetText("Atualizado em " + PZ1->PZ1_ATUDES)	
	
	// LIMPANDO OS DADOS DA TELA
	cGet1 := Space(nTamPlaca)
	cGet2 := Space(nTamMotor)
	cGet3 := Space(nTamPlaca)
	cGet4 := Space(nTamMotor)
	cGet5 := Space(nTamPlaca)
	cGet6 := Space(nTamMotor)
	cGet7 := Space(nTamPlaca)
	cGet8 := Space(nTamMotor)
	cGet9 := Space(nTamPlaca)
	cGet10:= Space(nTamMotor)
	cGet11:= Space(nTamObser)
	
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcao para buscar os dados que estao sendo apresentados na tela da TV (Caso usuario queira alterar apenas alguma informacao) //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fBusAtual()
	
	// Verificando se existe informacao a ser carregada
	If Posicione("PZ1", 1, xFilial("PZ1"), "FOUND()")
	
		cGet1 := PadR(PZ1->PZ1_PLDES1, nTamPlaca)
		cGet2 := PadR(PZ1->PZ1_MTDES1, nTamMotor)
		cGet3 := PadR(PZ1->PZ1_PLDES2, nTamPlaca)
		cGet4 := PadR(PZ1->PZ1_MTDES2, nTamMotor)
		cGet5 := PadR(PZ1->PZ1_PLDES3, nTamPlaca)
		cGet6 := PadR(PZ1->PZ1_MTDES3, nTamMotor)
		cGet7 := PadR(PZ1->PZ1_PLDES4, nTamPlaca)
		cGet8 := PadR(PZ1->PZ1_MTDES4, nTamMotor)
		cGet9 := PadR(PZ1->PZ1_PLDES5, nTamPlaca)
		cGet10:= PadR(PZ1->PZ1_MTDES5, nTamMotor)
		cGet11:= PadR(PZ1->PZ1_OBSDES, nTamObser)
	
		// Bucando data de atualizacao
		oSay8:SetText("Atualizado em " + PZ1->PZ1_ATUDES)
	Else
		MsgInfo("Nao Existem informacoes a serem carregadas. Verifique.", "FDESCARREGAMENTO")
	EndIf
	
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------