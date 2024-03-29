#include "TOTVS.CH"

/*/{Protheus.doc} TPATApiNet
@description Classe para consumo dos metodos da API Web - Projeto Pedido Automatico
@since 08/10/2018
@version 1.0
@type class
/*/

Class TPATApiNet from LongClassName

	Data oAuth
	Data cAcessToken
	Data cURLBase
	Data aHeadStr

	Method New() Constructor
	Method GetJson(cUrlApi, cParams)
	Method GetJsonList(cUrlApi, cParams)
	Method PostObj(cUrlApi, oObject)

EndClass


Method New() Class TPATApiNet

	::oAuth	:= TAFApiAuth():New(AllTrim(cEmpAnt)+AllTrim(cFilAnt))


	::cURLBase := GETNEWPAR("FA_PAAPIPH","http://iris:4939/api") // PARA AMBIENTE DE PRODUCAO

	//::cURLBase := GETNEWPAR("FA_PAAPIPH","http://iris:4950/api") // PARA AMBIENTE DE TESTES

	::aHeadStr := {"Content-Type: application/json"}

	::cAcessToken	:= ""

Return()

Method GetJson(cUrlApi, cParams) Class TPATApiNet

	Local cRespJSON
	Local oRetorno
	Local cHeaderRet
	Local cPOSTParms:= ""
	Local cURLTMP	:= cUrlApi
	Local cUrl		:= ::cURLBase+cURLTMP+cPOSTParms
	Local oRet
	Local cErro
	Local bErro := ErrorBlock( { |oErr| cErro := oErr:Description })

	oRet := TAFApiRetorno():New()

	Begin Sequence

		cRespJSON := HTTPGet(::cURLBase+cUrlApi,cParams,,,@cHeaderRet)

		If cRespJSON <> NIL

			FWJsonDeserialize(cRespJSON, @oRetorno)

		EndIf

		//Tratamento de Erro caso haja falha na integra��o com a Mercado Livre
		If oRetorno <> NIL  .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

			oRet:Ok 		:= .T.
			oRet:Mensagem	:= cRespJSON
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


Method GetJsonList(cUrlApi, cParams, aList) Class TPATApiNet

	Local oRet
	Local aRet
	Local nI, nJ

	oRet := ::GetJson(cUrlApi, cParams)

	If  (oRet:Ok)

		oList := oRet:oRetorno:list
		aRet := {}

		If (ValType(oList) == "A")

			For nI := 1 To Len (oList)

				__obj := oList[nI]

				aLinha := {}
				For nJ := 1 To Len(aList)

					If aScan(ClassDataArr(__obj),{|x|  alltrim(x[1]) == AllTrim(aList[nJ])}) > 0

						xRet := &('__obj:'+aList[nJ])
						Aadd(aLinha, xRet)

					else

						MSGALERT( "EXCEL com estrutura inv�lida de colunas para este processo", "API Import. Excel" )
						Return({})

					EndIf

				Next nJ

				Aadd(aRet, aLinha)
			Next nI

		Else

			MSGALERT( "Erro retorno API", "API Import. Excel" )
			Return({})

		EndIf

	EndIf

Return(aRet)


Method PostObj(cUrlApi, oObject) Class TPATApiNet

	Local cRespJSON
	Local oRetorno
	Local cHeaderRet
	Local cPOSTParms:= ""
	Local cURLTMP	:= cUrlApi

	Local cUrl		:= ::cURLBase+cURLTMP+cPOSTParms
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

		//Tratamento de Erro caso haja falha na integra��o com a Mercado Livre
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