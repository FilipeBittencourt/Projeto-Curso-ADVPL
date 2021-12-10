#include "rwmake.ch"

/*/{Protheus.doc} BIAGI001
@author Filipe Bittencourt (Facile)
@since 13/10/2021
@project 28966
@version 1.0
@description gatilho para conhecimento de frente. O digistar um CTE no campo f1_chave o sistema irá verificar 
se a chave digita bate com o número digitado na tabela SF3

@type function
/*/

//U_BIAGI001
User Function BIAGI001()

	Local lRet := .T.
	Local cChave :=  m->F1_CHVNFE

	ALERT(cChave)


Return cChave
