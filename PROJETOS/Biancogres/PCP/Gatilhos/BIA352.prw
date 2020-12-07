#Include "TOPCONN.CH"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'

/*/{Protheus.doc} BIA352
@author Marcos Alberto Soprani
@since 23/01/19
@version 1.0
@description Gatilho para preenchimento dos campos C2_ROTEIRO e C2_YITGMES a partir do CAMPO C2_PRODUTO
@type function
/*/

User Function BIA352()

	Local msRetLinha  := M->C2_LINHA
	Local msRoteiroLn := Space(2)
	Local _aArea      := GetArea()
	Local _aLinhas
	Local oBItgMes    := TIntegracaoMES():New()

	If Posicione("SB1", 1, xFilial("SB1") + M->C2_PRODUTO, "B1_TIPO") == "PA"

		U_BIA736Prc(M->C2_PRODUTO, M->C2_PRODUTO)

	EndIf

	If IsInCallStack("fGeraponta")
		Return msRetLinha
	EndIf

	oBItgMes:GetLinha()

	_aLinhas	:=	oBItgMes:aLinhas

	If aScan(_aLinhas,{|x| Alltrim(x) == Alltrim(msRetLinha)}) > 0

		msRoteiroLn := Substr(msRetLinha, 2, 1) + IIf( Substr(msRetLinha, 3, 1) == "A", "1", IIf(Substr(msRetLinha, 3, 1) == "B", "2", "X") )

		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1") + M->C2_PRODUTO))

			If SB1->B1_TIPO = "PA" .and. SB1->B1_YCLASSE == "1"

				SG2->(dbSetOrder(1))
				If !SG2->(dbSeek(xFilial("SG2") + M->C2_PRODUTO + msRoteiroLn ))

					msRetLinha := ""
					MsgSTOP("Não existe roteiro de operações cadastrado para este Produto / Linha. Favor procurar o departamento Industrial para maiores informações.", "BIA352")

				Else

					M->C2_ROTEIRO := msRoteiroLn
					M->C2_YITGMES := "S"

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(_aArea)

Return ( msRetLinha )
