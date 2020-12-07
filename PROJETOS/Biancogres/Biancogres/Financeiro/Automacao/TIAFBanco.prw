#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TIAFBanco
@author Tiago Rossini Coradini
@since 13/12/2018
@project Automação Financeira
@version 1.0
@description Classe para tratar os bancos que serao utilizadados nos processos
@type class
/*/

Class TIAFBanco From LongClassName
			
	// Dados do banco
	Data cBanco // Numero do banco
	Data cAgencia // Agencia
	Data cConta // Conta corrente
	Data cSubCta // Subconta da tabela de parametros de bancos			
	
	Method New() Constructor
	
EndClass


Method New() Class TIAFBanco
	
	::cBanco := ""
	::cAgencia := ""
	::cConta := ""
	::cSubCta := ""
	
Return()