#include "TOTVS.CH"

/*/{Protheus.doc} TAFApiSacado
@description Classe struct do Sacado
@since 01/10/2018
@version 1.0
@type class
/*/

Class TAFApiArquivo from LongClassName

	Data oid
	Data nome
	Data path
	Data banco
	Data agencia
	Data dvAgencia
	Data conta
	Data dvConta
	Data convenio
	Data tpArquivo
	Data tpOperacao
	
	Data Registros

	Method New() Constructor
EndClass


Method New() Class TAFApiArquivo

	::oid       	:= Nil
	::nome      	:= Nil
	::path      	:= Nil
	::banco     	:= Nil
	::agencia   	:= Nil
	::dvAgencia 	:= Nil
	::conta     	:= Nil
	::dvConta   	:= Nil
	::convenio  	:= Nil
	::tpArquivo 	:= Nil
	::tpOperacao	:= Nil
	
	::Registros		:= {}

Return()