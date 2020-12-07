#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFIntegracaoAPI
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe com as regras para Integracao dos titulos com a API
@type class
/*/

Class TAFIntegracaoAPI From LongClassName

Data cTipo // R=Receber; P=Pagar
Data cOpcEnv // L=Lote; T=Titulo
Data cReimpr // N=Nao (incluir novo titulo); S=Sim (Reimprimir / Segunda via de boleto)
Data GArqRem
Data CMovRem
Data oLst // Objeto com a lista titulos a processar
Data cIDProc // Identificador do Processo

Method New() Constructor
Method Send() // Envia tirulos para a API
Method Receive() // Recebe titulos da API
Method Validate() // Validacao geral dos titulos

EndClass


Method New() Class TAFIntegracaoAPI

	::cTipo := "P"

	::cOpcEnv := "L"
	::cReimpr := "N"
	::GArqRem := "N"
	::CMovRem := ""
	::oLst := ArrayList():New()
	::cIDProc	:= ""

Return()


Method Send() Class TAFIntegracaoAPI
	Local oObj := Nil

	If ::Validate()

		If ::cTipo == "P"

			oObj := TAFApiRemessaPagar():New()

		ElseIf ::cTipo == "R"

			oObj := TAFApiRemessaReceber():New()
			oObj:CMovRem := ::CMovRem

		EndIf

	EndIf

	oObj:cOpcEnv := ::cOpcEnv
	oObj:cReimpr := ::cReimpr
	oObj:GArqRem := ::GArqRem
	oObj:cIDProc := ::cIDProc
	oObj:oLst := ::oLst

	oObj:Send(::cIDProc)

Return()


Method Receive() Class TAFIntegracaoAPI
	Local oObj := Nil

	If ::Validate()

		If ::cTipo == "P"

			oObj := TAFApiRetornoPagar():New()

		ElseIf ::cTipo == "R"

			oObj := TAFApiRetornoReceber():New()

		ElseIf ::cTipo == "C"

			oObj := TAFApiRetornoConciliacao():New()

		EndIf

	EndIf

	oObj:cIDProc := ::cIDProc

	oObj:Receive()

Return()


Method Validate() Class TAFIntegracaoAPI
	Local lRet := .T.

Return(lRet)