#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA477
@author Marcos Alberto Soprani
@since 31/05/19
@version 1.0
@description Gatilho para preenchimento do campo D3_CONTA
@type function
/*/

User Function BIA477()

	Local msCtaCon := Space(20)
	Local msCLVL   := Space(09)
	Local msCodPrd := Space(15)

	If Alltrim(FunName()) == "MATA241"

		msCLVL   := PADR(aCV[1][2], TAMSX3("D3_CLVL")[1])
		msCodPrd := Gdfieldget('D3_COD',n)

	ElseIf Alltrim(FunName()) == "MATA240"

		msCLVL   := M->D3_CLVL
		msCodPrd := M->D3_COD

	EndIf 

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + msCodPrd))

	If U_B478RTCC(msCLVL)[2] == "D"
		msCtaCon	:= SB1->B1_YCTRADM

	ElseIf U_B478RTCC(msCLVL)[2] == "C"
		msCtaCon  := SB1->B1_YCTRIND

	ElseIf U_B478RTCC(msCLVL)[2] $ "A/I"
		msCtaCon  := "16503" + Substr(msCLVL,2,8)

	EndIf

Return ( msCtaCon )
