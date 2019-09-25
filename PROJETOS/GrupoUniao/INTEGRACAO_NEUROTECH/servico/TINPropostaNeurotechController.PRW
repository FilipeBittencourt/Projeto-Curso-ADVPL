#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} TINPropostaNeutotechController
@description Classe para tratamento do retorno das requisicoes de proposta neurotech
@author Fernando Rocha / Facile Sistemas
@since 03/12/2018
@version 1.0
/*/


Class TINPropostaNeutotechController From LongClassName

	Data cIdProposta
	
	Method New() Constructor	
	Method GetNextNumero()

EndClass

/*/{Protheus.doc} TINPropostaNeutotechController:New
@description Construir objeto com dados da Proposta / Log para gravacao na base
@author Fernando Rocha
@since 11/12/2018
@version 1.0_description}
@param _oRetWS, , Objeto de retorno do WS Neurotech metodo executarFluxoComParametros
@type method
/*/
Method New() Class TINPropostaNeutotechController	

Return


/*/{Protheus.doc} TINRetornoNeutotech:New
@description Pegar o proximo numero unico para inclusao de nova proposta
@author Fernando Rocha
@since 11/12/2018
@type method
/*/

Method GetNextNumero() Class TINPropostaNeutotechController

	Local cNum := "00659825"

Return cNum
