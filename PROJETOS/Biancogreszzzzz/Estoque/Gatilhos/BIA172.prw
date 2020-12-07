#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA172
@author Marcos Alberto Soprani
@since 19/02/19
@version 1.0
@description Gatilho para preenchimento do campo D3_CLVL caso ele tenha sido declarado no corpo da rotina MATA241
@type function
/*/

User Function BIA172()

	Local msClvlMov := Space(9)

	If Alltrim(FunName()) == "MATA241"

		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek("D3_CLVL")

		If X3USO(SX3->X3_USADO)
			msClvlMov := aCV[1][2]
		EndIf 

	EndIf 

Return ( msClvlMov )
