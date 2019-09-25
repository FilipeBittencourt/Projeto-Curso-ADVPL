#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TINCliente
@description Classe para busca e tratamento das regras da entidade CLIENTE
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/


Class TINClienteModel From LongClassName

	//Dados parametros

	Data cFilialx // coloquei um x no final, pois estava dando erro de compilação. Deve ser alguma variavel padrão.
	Data cCodigo
	Data cLoja
	Data cNome
	Data cCGC
	Data cRisco
	Data cAvista  // A1_YAVISTA
	Data dRevisao // DATA DA ULTIMA REVISÃO DO CADASTRO A1_YDT_UAT	
	Data dtNeurot // DATA validade de CREDITO NEUROTECH PARA liberar compras apenas com titulos em atraso.
	Data nCredCli // A1_LC
	

	Data nLimitCred // A1_LC - SA1_SALDUP
	Data dTitAtras	
	Data dCredVenc	// date de venciemnto de credito A1_VENCLC
	Data oGrupoEco
	
	Method New() Constructor

EndClass

Method New() Class TINClienteModel 	

Return Self

