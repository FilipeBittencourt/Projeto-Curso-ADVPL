#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TINCliente
@description Classe para busca e tratamento das regras da entidade CLIENTE
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/

#define RISCO_A "A"
#define RISCO_B "B"
#define RISCO_C "C"
#define RISCO_D "D"
#define RISCO_E "E"

Class TINClienteController From LongClassName

    Data oCliente 
	Method New() Constructor
	Method GetCliLoja(Filial, Codigo, Loja) 

EndClass

Method New() Class TINClienteController

	::oCliente	:= ""

Return  Self

 
Method GetCliLoja(Filial, Codigo, Loja) Class TINClienteController

    Local oCliente := TINClienteDAO():New()		 
	::oCliente := oCliente:GetCliLoja(Filial, Codigo, Loja)		 

Return  ::oCliente		