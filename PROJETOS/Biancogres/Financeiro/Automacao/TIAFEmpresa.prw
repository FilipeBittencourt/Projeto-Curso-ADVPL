#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TIAFEmpresa
@author Tiago Rossini Coradini
@since 17/12/2018
@project Automação Financeira
@version 1.0
@description Classe para tratar as empresas que serao executadas nos processo
@type class
/*/

Class TIAFEmpresa From LongClassName
			
	// Dados do banco
	Data cEmp // Codigo da Empresa
	Data cFil // Codigo da Filial da Empresa
	
	Method New() Constructor
	
EndClass


Method New() Class TIAFEmpresa
	
	::cEmp := ""
	::cFil := ""
	
Return()