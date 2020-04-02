#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TEZClienteModel
@author  Filipe Vieira
@since 18/01/2019
@version 1.0
/*/


Class TEZClienteModel From LongClassName

	//Dados parametros

	Data cFilialx // coloquei um x no final, pois FILIAL É variavel padrão TOTVS
	Data cCodClient
	Data cCodLoja
	Data cRazClient
	Data cEstClient
	Data cNome
	Data cCGC
	Data cMunClient
	Data cCEP
	Data cEndereco
	Data cComplem
	Data cUF
	Data cDDD
	Data cTelefone

	Method New() Constructor

EndClass

Method New() Class TEZClienteModel

	::cFilialx		:= ""
	::cCodClient	:= ""
	::cCodLoja		:= ""
	::cRazClient	:= ""
	::cEstClient	:= ""
	::cMunClient	:= ""
	::cNome			:= ""
	::cCGC			:= ""
	::cCEP			:= ""
	::cEndereco		:= ""
	::cComplem		:= ""
	::cUF			:= ""
	::cDDD			:= ""
	::cTelefone		:= ""

Return Self
