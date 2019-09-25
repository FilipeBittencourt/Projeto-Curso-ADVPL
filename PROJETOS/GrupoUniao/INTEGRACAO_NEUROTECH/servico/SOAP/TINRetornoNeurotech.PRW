#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} TINRetornoNeutotech
@description Classe para tratamento do retorno das requisicoes de proposta neurotech
@author Fernando Rocha / Facile Sistemas
@since 03/12/2018
@version 1.0
/*/


Class TINRetornoNeutotech From LongClassName

	Data cIdProposta
	Data oRetorno

	Method New(_cIDProp) Constructor

	Method SetRetEnvio(_oRetWS)
	
	Method SetRetAnalise(_oRet)
	
	Method SetErro(_cMsgErro)

	Method GravarLog()

EndClass

/*/{Protheus.doc} TINRetornoNeutotech:New
@description Construir objeto de retorno passadno o ID unico da proposta na base
@author Fernando Rocha
@since 11/12/2018
@version 1.0_description}
@param _oRetWS, , Objeto de retorno do WS Neurotech metodo executarFluxoComParametros
@type method
/*/
Method New(_cIDProp) Class TINRetornoNeutotech

	::cIdProposta := _cIDProp
	::oRetorno := Nil

REturn

/*/{Protheus.doc} TINRetornoNeutotech:New
@description metodo para tratar o retorno recebido pelas requests a neurotech
@author Fernando Rocha
@since 11/12/2018
@param _oRetWS, , Objeto de retorno do WS Neurotech metodo executarFluxoComParametros
@type method
/*/
Method SetRetEnvio(_oRetWS) Class TINRetornoNeutotech

	::oRetorno := _oRetWS

	::GravarLog()

Return


/*/{Protheus.doc} TINRetornoNeutotech:New
@description metodo para tratar o retorno recebido da Neurotech apos Analise
@author Fernando Rocha
@since 11/12/2018
@param _oRetWS, , Objeto de retorno do WS Neurotech metodo executarFluxoComParametros
@type method
/*/
Method SetRetAnalise(_oRet) Class TINRetornoNeutotech


Return


Method SetErro(_cMsgErro) Class TINRetornoNeutotech

	Default _cMsgErro := ""

	_cMsgErro := "Erro executando serviço Neurotech => Proposta: "+::cIdProposta+IIf(!Empty(_cMsgErro)," Erro: "+_cMsgErro,"")

	ConOut(_cMsgErro)
	
	::GravarLog()

Return


Method GravarLog() Class TINRetornoNeutotech


Return