#include "TOTVS.CH"

/*/{Protheus.doc} TAFApiCedente
@description Classe struct do Cedente
@since 01/10/2018
@version 1.0
@type class
/*/

Class TAFApiCedente from LongClassName

	Data CPFCNPJ 

	Data Codigo
	Data CodigoDV
	Data Nome
	Data Banco
	Data Agencia
	Data Conta
	Data SubCta

	Method New(cCNPJ, cBanco, cAgencia, cConta, cSubCta) Constructor

	Method Get(cCNPJ, cBanco, cAgencia, cConta, cSubCta) Constructor

EndClass


Method New(cCNPJ, cBanco, cAgencia, cConta, cSubCta) Class TAFApiCedente

	::CPFCNPJ 			:= cCNPJ
	::Codigo			:= Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) + Alltrim(cSubCta)

	::Banco				:= cBanco
	::Agencia			:= cAgencia
	::Conta				:= cConta
	::SubCta			:= cSubCta

	::CodigoDV			:= Nil
	::Nome				:= Nil

return()


Method Get(cCNPJ, cBanco, cAgencia, cConta, cSubCta) Class TAFApiCedente

	Local cAliasTmp
	Local cAgTam := Len(AllTrim(cAgencia))
	Local cCCTam := Len(AllTrim(cConta))

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NoParser%

		select EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA 
		from %Table:SEE%
		where EE_FILIAL = '  '
		and EE_CODIGO = %Exp:cBanco%
		and LEFT(REPLACE(REPLACE(EE_AGENCIA,'.',''),'-',''),%Exp:cAgTam%) = %Exp:cAgencia%
		and LEFT(REPLACE(REPLACE(EE_CONTA,'.',''),'-',''),%Exp:cCCTam%) = %Exp:cConta%
		and EE_SUBCTA = %Exp:cSubCta%
		and D_E_L_E_T_=''

	EndSql

	ConOut(GetLastQuery()[2])

	If !(cAliasTmp)->(Eof())

		::CPFCNPJ 			:= cCNPJ
		::Codigo			:= Alltrim((cAliasTmp)->EE_CODIGO) + Alltrim((cAliasTmp)->EE_AGENCIA) + Alltrim((cAliasTmp)->EE_CONTA) + Alltrim((cAliasTmp)->EE_SUBCTA)
		::Banco				:= (cAliasTmp)->EE_CODIGO
		::Agencia			:= (cAliasTmp)->EE_AGENCIA
		::Conta				:= (cAliasTmp)->EE_CONTA
		::SubCta			:= (cAliasTmp)->EE_SUBCTA
		::CodigoDV			:= Nil
		::Nome				:= Nil

	EndIf

return