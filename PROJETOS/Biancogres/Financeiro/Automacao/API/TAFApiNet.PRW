#include "TOTVS.CH"

/*/{Protheus.doc} TAFApiNet
@description Classe para consumo dos metodos da API Web
@since 08/10/2018
@version 1.0
@type class
/*/

Class TAFApiNet from LongClassName

	Data oAuth
	Data cAcessToken
	Data cURLBase
	Data aHeadStr

	Method New() Constructor
	Method GetAcessToken()
	Method PostObj(cUrlApi, oObject)

EndClass


Method New() Class TAFApiNet

	::oAuth	:= TAFApiAuth():New(AllTrim(cEmpAnt)+AllTrim(cFilAnt))

	//If Upper(AllTrim(GetEnvServer())) == "PRODUCAO" .Or. Upper(AllTrim(GetEnvServer())) == "AUTOJOB-FIN" .Or. Upper(AllTrim(GetEnvServer())) == "COMP-FERNANDO"
	If(Upper(AllTrim(GetSrvProfString("DbAlias", ""))) == "PRODUCAO")
		
		::cURLBase := GETNEWPAR("FA_FAPIPH","http://iris:4909/api")
		
	Else
		
		::cURLBase := GETNEWPAR("FA_FAPIPH","http://iris:4901/api")
				
	EndIf

	::aHeadStr := {"Content-Type: application/json"}

	::cAcessToken	:= ""

Return()


Method GetAcessToken() Class TAFApiNet

	Local cRespJSON
	Local oRetorno
	Local cHeaderRet 
	Local cPOSTParms:= ""
	Local cURLTMP	:= "/Access/Authenticate"

	Local cUrl		:= ::cURLBase+cURLTMP+cPOSTParms
	Local aMsgErro	:= {}
	Local cRet		:= ""
	Local cJSon		:= ""

	Local oJson := TAFApiJson():New()	
	Local oRet
	Local cErro

	Local bErro := ErrorBlock( { |oErr| cErro := oErr:Description })

	oRet := TAFApiRetorno():New()

	If ( Empty(::oAuth:Client_Key) )

		oRet:Ok 		:= .F.
		oRet:Mensagem	:= "EMPRESA NAO CONFIGURADA PARA USO DA API."
		Return oRet

	EndIf

	Begin Sequence

		cJSon := oJson:GerarJson(::oAuth)	

		oRet:RequestJson := cJSon

		cRespJSON := HTTPPost(cUrl,,cJSon,1200,::aHeadStr,@cHeaderRet)

		If cRespJSON <> NIL

			FWJsonDeserialize(cRespJSON, @oRetorno)

		EndIf

		//Tratamento de Erro caso haja falha na integração com a Mercado Livre
		If oRetorno <> NIL  .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

			::cAcessToken	:= oRetorno:token

			oRet:Ok 		:= .T.
			oRet:Token		:= ::cAcessToken
			oRet:oRetorno	:= oRetorno

			aadd(::aHeadStr, "Authorization: Bearer " + ::cAcessToken)	

			//todo:  verificar vencimento de Token e Renew

		Else

			oRet:Ok 		:= .F.
			oRet:Mensagem	:= "post em: "+cUrl+", erro: "+iif(cHeaderRet==NIL,"",cHeaderRet)
			oRet:oRetorno	:= oRetorno

			//todo: Email com Erro de conexao com a API

		EndIf

	End Sequence
	ErrorBlock( bErro )

	If (!oRet:Ok) .And. ValType(cErro) <> "U"

		oRet:Ok 		:= .F.
		oRet:Mensagem	:= cErro

	EndIf

Return oRet


Method PostObj(cUrlApi, oObject) Class TAFApiNet

	Local cRespJSON
	Local oRetorno
	Local cHeaderRet 
	Local cPOSTParms:= ""
	Local cURLTMP	:= cUrlApi

	Local cUrl		:= ::cURLBase+cURLTMP+cPOSTParms
	Local aMsgErro	:= {}
	Local cRet		:= ""
	Local cJSon		:= ""

	Local oJson := TAFApiJson():New()	
	Local oRet

	Local cErro
	Local bErro := ErrorBlock( { |oErr| cErro := oErr:Description })

	oRet := TAFApiRetorno():New()

	Begin Sequence

		cJSon := oJson:GerarJson(oObject)	

		oRet:RequestJson := cJSon 	

		cRespJSON := HTTPPost(cUrl,,cJSon,1200,::aHeadStr,@cHeaderRet)

		If cRespJSON <> NIL

			FWJsonDeserialize(cRespJSON, @oRetorno)

		EndIf

		//Tratamento de Erro caso haja falha na integração com a Mercado Livre
		If oRetorno <> NIL  .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

			oRet:Ok 		:= oRetorno:Ok
			oRet:Mensagem	:= oRetorno:mensagemRetorno
			oRet:oRetorno	:= oRetorno

		Else

			oRet:Ok 		:= .F.
			oRet:Mensagem	:= "POST url: "+cUrl+", erro: "+iif(cHeaderRet==NIL,"",cHeaderRet)
			oRet:oRetorno	:= oRetorno

			//todo:EmailErro

		EndIf

	End Sequence
	ErrorBlock( bErro )

	If (!oRet:Ok) .And. ValType(cErro) <> "U"

		oRet:Ok 		:= .F.
		oRet:Mensagem	:= cErro

	EndIf

Return(oRet)