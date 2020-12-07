#Include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³ FROPTE10 ³ Autor ³ FERNANDO ROCHA        ³ Data ³13/04/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ TELA DE SENHA DE SUPERIRO PARA LIBERAR EMPENHO COM PONTA   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ BIANCOGRES                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FROPTE10(_coLProd,_coLLote,_coLQSol,_coLQRest,_coLSaldo,_cGerente, _lEstorno)
	Local oButCancel
	Local oButOk 
	Local oButTrAut

	Local oFont1 := TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)
	Local oFont3 := TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)
	Local oGroup1
	Local oLLote
	Local oLProd
	Local oLQRest
	Local oLQSol
	Local oLSaldo
	Local oPanel1
	Local oPanel2
	Local oPanel3
	Local oPanel4
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local _lOk := .F. 
	Local I

	Default _lEstorno := .F.

	Private _aUsr  
	Private _nIndAut
	Private _cNomeLib
	Private _cUserLib 
	Private oGetPsw
	Private cGetPsw := Space(30)
	Private oDlgSPsw   
	Private oLGerente 
	Private oGetCodMot
	Private cGetCodMot := Space(3)
	Private oGetDescMot
	Private cGetDescMot := Space(200)   

	Private _cF3Mot := "ZW"

	_aUsr := StrToKarr(_cGerente,"#")
	For I := 1 To Len(_aUsr)
		PswOrder(2)
		If PswSeek( _aUsr[I] , .T. ) 
			_nIndAut := I
			_cUserLib := _aUsr[I]
			_cNomeLib := PswRet()[1][4]
			exit
		EndIf
	Next I


	DEFINE MSDIALOG oDlgSPsw TITLE "Autorização de Superior" FROM 000, 000  TO 400, 450 COLORS 0, 16777215 PIXEL

	@ 000, 000 MSPANEL oPanel1 SIZE 225, 175 OF oDlgSPsw COLORS 0, 16777215 RAISED
	@ 154, 000 MSPANEL oPanel2 SIZE 224, 020 OF oPanel1 COLORS 0, 16777215 RAISED
	@ 000, 178 BUTTON oButOk PROMPT "AUTORIZAR" SIZE 045, 019 OF oPanel2 PIXEL  ACTION( _lOk := Autoriza() )
	@ 000, 129 BUTTON oButCancel PROMPT "CANCELAR" SIZE 049, 019 OF oPanel2 PIXEL ACTION( _lOk := .F., oDlgSPsw:End() )
	@ 000, 129 BUTTON oButTrAut PROMPT "TR.AUTOR." SIZE 049, 019 OF oPanel2 PIXEL ACTION( TrocaAut() )

	@ 033, 000 MSPANEL oPanel3 SIZE 224, 145 OF oPanel1 COLORS 0, 16777215 RAISED
	@ 000, 000 GROUP oGroup1 TO 070, 223 PROMPT "Dados do produto" OF oPanel3 COLOR 8421504, 16777215 PIXEL
	@ 015, 007 SAY oSay2 PROMPT "Produto:" SIZE 042, 010 OF oPanel3 FONT oFont2 COLORS 8421504, 16777215 PIXEL
	@ 040, 007 SAY oSay3 PROMPT "Qtd. Solicitada:" SIZE 057, 010 OF oPanel3 FONT oFont2 COLORS 8421504, 16777215 PIXEL
	@ 028, 075 SAY oSay4 PROMPT "Saldo em Estoque:" SIZE 072, 010 OF oPanel3 FONT oFont2 COLORS 8421504, 16777215 PIXEL
	@ 052, 007 SAY oSay5 PROMPT "Saldo Restante:" SIZE 060, 010 OF oPanel3 FONT oFont2 COLORS 8421504, 16777215 PIXEL
	@ 027, 007 SAY oSay6 PROMPT "Lote:" SIZE 022, 010 OF oPanel3 FONT oFont2 COLORS 8421504, 16777215 PIXEL

	@ 015, 044 SAY oLProd PROMPT _coLProd SIZE 150, 010 OF oPanel3 FONT oFont3 COLORS 0, 16777215 PIXEL
	@ 027, 030 SAY oLLote PROMPT _coLLote SIZE 029, 010 OF oPanel3 FONT oFont3 COLORS 0, 16777215 PIXEL
	@ 040, 065 SAY oLQSol PROMPT _coLQSol SIZE 050, 010 OF oPanel3 FONT oFont3 COLORS 0, 16777215 PIXEL
	@ 052, 065 SAY oLQRest PROMPT _coLQRest SIZE 050, 010 OF oPanel3 FONT oFont3 COLORS 0, 16777215 PIXEL
	@ 028, 145 SAY oLSaldo PROMPT _coLSaldo SIZE 050, 010 OF oPanel3 FONT oFont3 COLORS 0, 16777215 PIXEL

	@ 074, 007 SAY oSayMotivo PROMPT "Motivo:" SIZE 068, 011 OF oPanel3 FONT oFont1 COLORS 255, 16777215 PIXEL
	@ 085, 007 MSGET oGetCodMot VAR cGetCodMot SIZE 026, 013 OF oPanel3 COLORS 0, 16777215 FONT oFont3 PIXEL F3 _cF3Mot VALID ( PesqMot() )
	@ 085, 050 MSGET oGetDescMot VAR cGetDescMot SIZE 172, 013 OF oPanel3 COLORS 0, 16777215 FONT oFont3 PIXEL WHEN .F.

	@ 105, 007 SAY oSay7 PROMPT "Solicite senha do" SIZE 068, 011 OF oPanel3 FONT oFont1 COLORS 8421504, 16777215 PIXEL
	@ 105, 070 SAY oLGerente PROMPT _cNomeLib SIZE 135, 011 OF oPanel3 FONT oFont1 COLORS 8421504, 16777215 PIXEL
	@ 117, 105 MSGET oGetPsw VAR cGetPsw SIZE 100, 013 OF oPanel3 COLORS 0, 16777215 FONT oFont3 PIXEL PASSWORD

	@ 000, 000 MSPANEL oPanel4 SIZE 224, 033 OF oPanel1 COLORS 0, 16777215 RAISED

	If !_lEstorno
		@ 000, 003 SAY oSay8 PROMPT "ATENÇÃO! Essa liberação vai gerar uma ponta no estoque. Para prosseguir será necessária autorização do Gerente Adm. de Vendas." SIZE 223, 031 OF oPanel4 FONT oFont1 COLORS 255, 16777215 PIXEL
	Else
		@ 000, 003 SAY oSay8 PROMPT "ATENÇÃO! Esse ESTORNO de empenho vai gerar uma ponta no estoque. Para prosseguir será necessária autorização do Gerente Adm. de Vendas." SIZE 223, 031 OF oPanel4 FONT oFont1 COLORS 255, 16777215 PIXEL
	EndIf

	// Don't change the Align Order
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	oGroup1:Align := CONTROL_ALIGN_TOP
	oPanel4:Align := CONTROL_ALIGN_TOP
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
	oButOk:Align := CONTROL_ALIGN_RIGHT
	oButCancel:Align := CONTROL_ALIGN_RIGHT
	oButTrAut:Align := CONTROL_ALIGN_RIGHT

	ACTIVATE MSDIALOG oDlgSPsw CENTERED   

	_aRet := {_lOk, _cNomeLib, cGetCodMot, cGetDescMot}

Return(_aRet)

Static Function Autoriza() 

	If Empty(cGetCodMot) .Or. Empty(cGetDescMot)
		MsgAlert("INFORMAR MOTIVO!","Obrigatório a informação do Motivo de geração de ponta.")
		cGetCodMot := Space(3)
		oGetCodMot:SetFocus() 
		oDlgSPsw:Refresh()
		Return(.F.)
	EndIf

	PswOrder(2)
	If PswSeek(_cUserLib)
		If !PswName(AllTrim(cGetPsw))
			MsgAlert("SENHA INVÁLIDA!","Autorização de Superior")
			cGetPsw := Space(30)
			oGetPsw:SetFocus()  
			oDlgSPsw:Refresh()

			Return(.F.)
		EndIf
	EndIf

	oDlgSPsw:End()
Return(.T.) 

Static Function TrocaAut()

	If _nIndAut+1 > Len(_aUsr)
		_nIndAut := 1
	Else
		_nIndAut := _nIndAut + 1
	EndIf

	PswOrder(2)
	If PswSeek( _aUsr[_nIndAut] , .T. )
		_cUserLib := _aUsr[_nIndAut]
		_cNomeLib := PswRet()[1][4]

		cGetPsw := Space(30)
		oGetPsw:SetFocus()
		oLGerente:Refresh()
		oDlgSPsw:Refresh()
	EndIf

Return   

Static Function PesqMot()

	SX5->(DbSetOrder(1))
	If SX5->(DbSeek(XFilial("SX5")+_cF3Mot+cGetCodMot))

		cGetDescMot := SX5->X5_DESCRI
		oGetDescMot:Refresh()
		oDlgSPsw:Refresh()

	EndIf

Return