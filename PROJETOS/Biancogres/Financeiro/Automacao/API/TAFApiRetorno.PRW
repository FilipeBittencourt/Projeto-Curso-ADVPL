#include "TOTVS.CH"

/*/{Protheus.doc} TAFApiRetornoArquivo
@description Classe para fazer a busca por informacoes de Retornos bancarios na API
@since 01/10/2018
@version 1.0
@type class
/*/

Class TAFApiRetornoArquivo from LongClassName

	Data cCodBanco
	Data oCedente
	Data TipoOperacao
Data CNPJ
	
	Method New() Constructor	
	Method SetParametros(cCNPJ, cBanco, cAgencia, cConta, cSubCta, cTipo) // Setar os parametros do Banco/Conta usada para a remessa
	Method Get()

EndClass


Method New() Class TAFApiRetornoArquivo

	::cCodBanco := ""
	::oCedente := Nil
	::TipoOperacao := "" // 1 = Recebimentos; 2 = Pagamentos
	::CNPJ := ""
	
Return()


Method SetParametros(cCNPJ, cBanco, cAgencia, cConta, cSubCta, cTipo) Class TAFApiRetornoArquivo

	If !Empty(cBanco)
	::cCodBanco	:= cBanco
	::oCedente := TAFApiCedente():New(cCNPJ, cBanco, cAgencia, cConta, cSubCta)
	EndIf

	::CNPJ := cCNPJ
	::TipoOperacao := IIf (cTipo == "R", "1", IIf(cTipo == "C", "3", "2") )

Return()


Method Get() Class TAFApiRetornoArquivo
Local oApi := TAFApiNet():New()
Local oRet := Nil
Local oPostRet

	// Conectar api e buscar token de acesso
	oRet := oApi:GetAcessToken()

	If !oRet:Ok
		
		Return(oRet)
		
	EndIf

	If (::oCedente <> Nil .And. !Empty(::oCedente:CPFCNPJ))

		oPostRet := TAFApiRetornoArquivoParams():New(::oCedente:Codigo, ::oCedente:CPFCNPJ, ::TipoOperacao)

	Else

		oPostRet := TAFApiRetornoArquivoParams():New("", ::CNPJ, ::TipoOperacao)

	EndIf

	oRet := oApi:PostObj("/retorno", oPostRet)

Return(oRet)


Class TAFApiRetornoArquivoParams from LongClassName

	Data CodigoCedente
	Data CNPJ
	Data TipoOperacao

	Method New() Constructor

EndClass


Method New(CodigoCedente, CNPJ, TipoOperacao) Class TAFApiRetornoArquivoParams

	::CodigoCedente	:= CodigoCedente
	::CNPJ := CNPJ
	::TipoOperacao := TipoOperacao

Return()