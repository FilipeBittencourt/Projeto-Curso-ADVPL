#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TINGrupoEconomicoController
@description Classe de controle/regras para Grupo Economico
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/

#define RISCO_A "A"
#define RISCO_B "B"
#define RISCO_C "C"
#define RISCO_D "D"
#define RISCO_E "E"

Class TINGrupoEconomicoController From LongClassName

    Data oGrpEcoCli
	Method New() Constructor
	Method GrpEcoCli(oCliente) 

EndClass

Method New() Class TINGrupoEconomicoController

	::oGrpEcoCli := ""

Return  Self

 
Method GrpEcoCli(oCliente) Class TINGrupoEconomicoController

    Local oGrpEco := TINGrupoEconomicoDAO():New()	
	::oGrpEcoCli := oGrpEco:GrpEcoCli(oCliente)		 

Return  ::oGrpEcoCli		