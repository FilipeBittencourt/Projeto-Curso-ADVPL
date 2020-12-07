#include "TOTVS.CH"

/*/{Protheus.doc} TAFApiAuth
@description Struct com dados para autenticacao
@since 08/10/2018
@version 1.0
@type class
/*/

Class TAFApiAuth from LongClassName

	Data Client_Key
	Data Secret_Key

	Method New(cEmpFil) Constructor

EndClass


Method New(cEmpFil) Class TAFApiAuth

	//ZK7_FILIAL, ZK7_EMPFIL, R_E_C_N_O_, D_E_L_E_T_
	ZK7->(DbSetOrder(1))
	IF ZK7->(DbSeek(XFilial("ZK7")+cEmpFil))


		::Client_Key	:= ZK7->ZK7_CLIKEY
		::Secret_Key	:= ZK7->ZK7_SECRET

		
	Else
	
		::Client_Key	:= ""
		::Secret_Key	:= ""

	EndIf

Return()