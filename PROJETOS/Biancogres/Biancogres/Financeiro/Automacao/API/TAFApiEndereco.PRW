#include "TOTVS.CH"

/*/{Protheus.doc} TAFApiEndereco
@description Classe struct do Endereco
@since 01/10/2018
@version 1.0
@type class
/*/

Class TAFApiEndereco from LongClassName

Data Logradouro
Data Numero
Data Complemento
Data Bairro
Data UF
Data Cidade
Data CEP

//VETOR DE CONVERSAO PROPRIEDADE PARA NOME LONGO API
Data aLstFields

Method New() Constructor

EndClass


Method New() Class TAFApiEndereco

	::Logradouro	:= Nil
	::Numero      	:= Nil
	::Complemento 	:= Nil
	::Bairro        := Nil
	::UF            := Nil
	::Cidade        := Nil
	::CEP           := Nil

	::aLstFields	:= TAFApiListFields():New

	::aLstFields:AddField("Logradouro"	,"LogradouroEndereco")
	::aLstFields:AddField("Numero"		,"LogradouroNumero")
	::aLstFields:AddField("Complemento"	,"LogradouroComplemento")
	::aLstFields:AddField("Bairro"		,"Bairro")
	::aLstFields:AddField("UF"			,"UF")
	::aLstFields:AddField("Cidade"		,"Cidade")
	::aLstFields:AddField("CEP"			,"CEP")

return()