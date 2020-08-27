/*
	Ponto de entrada chamado ao Incluir/Alterar/Excluir tabela de preço,
	pedindo senha para que possa concluir.
*/
User Function OM010TOK
	Local lRet     := .F.
	Local aPergs   := {}
	Local aRet     := {"", Space(9)}

	aAdd(aPergs, {9, "Para ativar a tabela, você deve informar a senha do superior.", 180, 30, .T.})
	aAdd(aPergs, {8, "Senha", Space(9), "@!",,, '.T.', 40, .T.})
	ParamBox(aPergs, "Ativar Tabela", @aRet, {|| lRet := ConfSenha(aRet[2])},,,,,,,.F.,.F.)

	If !lRet
		Help(NIL, NIL, "Ativar Tabela", NIL, "A senha informada não está correta.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Digite a senha correta."})
	EndIf
Return(lRet)

Static Function ConfSenha(cSenha)
	Local cPass := Chr(116) + Chr(101) + Chr(99) + Chr(118) + Chr(97) + Chr(108) + Chr(101) + Chr(100) + Chr(119) //
	Local lRet  := Upper(cPass) == cSenha

	If !lRet
		Aviso("Ativar Tabela", "A senha informada não está correta. Tente novamente.", {"Ok"}, 1)
	EndIf
Return(lRet)
