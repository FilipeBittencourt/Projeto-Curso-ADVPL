#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TINCliente
@description Classe para busca e tratamento das regras da entidade CLIENTE
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/


Class TINGrupoEconomicoModel From LongClassName

	//Dados parametros 
	Data cFilialx // coloquei um x no final, pois estava dando erro de compilação. Deve ser alguma variavel padrão.
	Data cCodigo 
	Data cDesc
	Data nLimiteGrp
	Data nSaldoGrp
	Data cCodCli
	Data cLoja
	Data cOrigem
	
	Method New() Constructor

EndClass

Method New() Class TINGrupoEconomicoModel 	

Return Self

