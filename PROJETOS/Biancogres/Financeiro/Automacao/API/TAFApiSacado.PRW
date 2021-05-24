#include "TOTVS.CH"

/*/{Protheus.doc} TAFApiSacado
@description Classe struct do Sacado
@since 01/10/2018
@version 1.0
@type class
/*/

Class TAFApiSacado from LongClassName

	Data CpfCnpj
	Data Nome
	Data Email
	Data Observacoes
	Data Endereco

	Method New() Constructor
	Method NewByCliente(cCodEmp, cCodFil, cCodCli, cLojCli) Constructor
	Method NewByFornecedor(cCodEmp, cCodFil, cCodCli, cLojCli) Constructor	

EndClass


Method New() Class TAFApiSacado

	::CpfCnpj	:= Nil
	::Nome := Nil
	::Email := Nil
	::Observacoes := Nil
	::Endereco := Nil

Return()


Method NewByCliente(cCodEmp, cCodFil, cCodCli, cLojCli) Class TAFApiSacado
Local cAliasTmp := Nil
Local cTableSA1 := "% SA1"+AllTrim(cCodEmp)+"0 %"

	cAliasTmp := GetNextAlias()

	BeginSql Alias cAliasTmp
	
		%NoParser%

		select * from %Exp:cTableSA1% 
		where A1_FILIAL = %XFILIAL:SA1%
		and A1_COD		= %Exp:cCodCli%
		and A1_LOJA		= %Exp:cLojCli%
		and %NotDel%

	EndSql

	If !(cAliasTmp)->(Eof())

		::CpfCnpj	:= (cAliasTmp)->A1_CGC
		::Nome := EncodeUTF8((cAliasTmp)->A1_NOME)
		::Email := EncodeUTF8((cAliasTmp)->A1_YEMABOL)

		::Endereco := TAFApiEndereco():New()

		::Endereco:Logradouro	:= EncodeUTF8(FwNoAccent(FisGetEnd((cAliasTmp)->A1_ENDCOB,(cAliasTmp)->A1_ESTC)[1]))
		::Endereco:Numero := FisGetEnd((cAliasTmp)->A1_ENDCOB,(cAliasTmp)->A1_ESTC)[2]
		::Endereco:Complemento := EncodeUTF8(FwNoAccent(FisGetEnd((cAliasTmp)->A1_ENDCOB,(cAliasTmp)->A1_ESTC)[4]))
		::Endereco:Bairro := EncodeUTF8(FwNoAccent((cAliasTmp)->A1_BAIRROC))
		::Endereco:UF := EncodeUTF8((cAliasTmp)->A1_ESTC)
		::Endereco:Cidade := EncodeUTF8(FwNoAccent((cAliasTmp)->A1_MUNC))
		::Endereco:CEP := EncodeUTF8((cAliasTmp)->A1_CEPC)

	EndIf
	
	DBCloseArea(cAliasTmp)

Return()



Method NewByFornecedor(cCodEmp, cCodFil, cCodCli, cLojCli) Class TAFApiSacado
	
	Local cAliasTmp := Nil
	Local cTableSA2 := "% SA2"+AllTrim(cCodEmp)+"0 %"

	cAliasTmp := GetNextAlias()

	BeginSql Alias cAliasTmp
	
		%NoParser%

		select * from %Exp:cTableSA2% 
		where A2_FILIAL = %XFILIAL:SA2%
		and A2_COD		= %Exp:cCodCli%
		and A2_LOJA		= %Exp:cLojCli%
		and %NotDel%

	EndSql

	If !(cAliasTmp)->(Eof())

		::CpfCnpj	:= (cAliasTmp)->A2_CGC
		::Nome := EncodeUTF8((cAliasTmp)->A2_NOME)
		::Email := EncodeUTF8((cAliasTmp)->A2_YEMAFIN)

		::Endereco := TAFApiEndereco():New()

		::Endereco:Logradouro	:= EncodeUTF8(FwNoAccent(FisGetEnd((cAliasTmp)->A2_END,(cAliasTmp)->A2_EST)[1]))
		::Endereco:Numero 		:= FisGetEnd((cAliasTmp)->A2_END,(cAliasTmp)->A2_EST)[2]
		::Endereco:Complemento	:= EncodeUTF8(FwNoAccent(FisGetEnd((cAliasTmp)->A2_END,(cAliasTmp)->A2_EST)[4]))
		::Endereco:Bairro 		:= EncodeUTF8(FwNoAccent((cAliasTmp)->A2_BAIRRO))
		::Endereco:UF 			:= EncodeUTF8((cAliasTmp)->A2_EST)
		::Endereco:Cidade 		:= EncodeUTF8(FwNoAccent((cAliasTmp)->A2_MUN))
		::Endereco:CEP 			:= EncodeUTF8((cAliasTmp)->A2_CEP)

	EndIf
	
	DBCloseArea(cAliasTmp)

Return()
