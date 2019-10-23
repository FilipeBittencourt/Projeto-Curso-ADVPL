#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TEZClienteController
@author  Filipe Vieira
@since 18/01/2019
@version 1.0
/*/

Class TEZClienteController From LongClassName

    Data oClienteM

	Method New() Constructor
	Method Get(cChave, nIndex)

EndClass

Method New() Class TEZClienteController

	::oClienteM	:= Nil

Return  Self


Method Get(cChave, nIndex) Class TEZClienteController

    Local oClienteD := TEZClienteDAO():New()
	::oClienteM := oClienteD:Get(cChave, nIndex)

Return  ::oClienteM