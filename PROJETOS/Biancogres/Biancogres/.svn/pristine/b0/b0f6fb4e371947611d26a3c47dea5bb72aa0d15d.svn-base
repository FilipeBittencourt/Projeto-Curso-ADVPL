#include "TOTVS.CH"


/*/{Protheus.doc} TAFApiFieldName
@description Classe com struct para relacionamento entre nomes ADVPL e API
@since 01/10/2018
@version 1.0
@type class
/*/
Class TAFApiFieldName from LongClassName

	Data cNomeERP
	Data cNomeAPI
	Method New() Constructor

EndClass

Method New() Class TAFApiFieldName

	::cNomeERP	:= ""
	::cNomeAPI	:= ""

Return


Class TAFApiListFields from LongClassName

//ARRAYLIST
Data aLstNames

//METODOS
Method New() Constructor
Method AddField(_cNomeERP, _cNomeAPI)
Method GetCount()
Method GetAPIName(cFieldName)

EndClass

Method New() Class TAFApiListFields

	::aLstNames := ArrayList():New()

Return

Method AddField(_cNomeERP, _cNomeAPI) Class TAFApiListFields

	Local oField := TAFApiFieldName():New()

	oField:cNomeERP := _cNomeERP
	oField:cNomeAPI := _cNomeAPI

	::aLstNames:Add(oField)

Return

Method GetCount() Class TAFApiListFields
Return ::aLstNames:GetCount()

Method GetAPIName(cFieldName) Class TAFApiListFields

	Local I

	For I := 1 To ::aLstNames:GetCount()

		If ( AllTrim(Upper(::aLstNames:GetItem(I):cNomeERP)) == AllTrim(Upper(cFieldName)) )

			Return ::aLstNames:GetItem(I):cNomeAPI

		EndIf		

	Next I

Return ""


/*/{Protheus.doc} TAFApiRetorno
@description Classe com struct com os dados retornados pela API
@since 01/10/2018
@version 1.0
@type class
/*/
Class TAFApiRetorno from LongClassName

	Data Ok
	Data Token
	Data Mensagem
	Data RequestJson
	Data oRetorno

	Method New() Constructor

EndClass

Method New() Class TAFApiRetorno

	::Ok			:= .F.
	::Token			:= ""
	::Mensagem		:= ""
	::RequestJson 	:= ""
	::oRetorno		:= Nil

Return()