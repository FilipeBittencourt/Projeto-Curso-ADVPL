#include "rwmake.ch"

/*/{Protheus.doc} BIA605
@author MICROSIGA VITORIA
@since 14/06/00
@version 1.0
@description AXCADASTRO CADASTRO DE TAG's
@type function
/*/

User Function BIA605()

	AXCADASTRO("SZC", "CADASTRO DE TAG", , "U_SZCVLINC()")

Return(nil)

User Function SZCVLINC()

	DbSelectArea("SZC")
	DbSetOrder(1)

	If INCLUI
		If DbSeek(xFilial("SZC")+M->ZC_NUM) 
			MsgAlert("Esta TAG já existe!","BIA605")

			Return .F.
		EndIf
	EndIf

Return .T.
