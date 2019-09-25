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

Class TINClienteDAO From LongClassName

    Data oCliente

    Method New() Constructor
	Method GetIndice(Chave, Indice)
	Method GetCliLoja(Filial, Codigo, Loja)

EndClass

Method New() Class TINClienteDAO

	::oCliente := ""

Return Self


Method GetIndice(chave, indice) Class TINClienteDAO

    Local oGrpEco := TINGrupoEconomicoDAO():New()

	::oCliente := TINClienteModel():New()


	SA1->(DbSetOrder(indice))
	If SA1->(DbSeek(chave))
	    ::oCliente:cFilialx    := SA1->A1_FILIAL
		::oCliente:cRisco      := SA1->A1_RISCO
		::oCliente:cCodigo     := SA1->A1_COD
		::oCliente:cLoja       := SA1->A1_LOJA
		::oCliente:cNome       := SA1->A1_NOME
		::oCliente:cCGC        := SA1->A1_CGC
		::oCliente:cAvista     := SA1->A1_YAVISTA //Verifica se o cliente é comprador AVISTA.
		::oCliente:nCredCli    := SA1->A1_LC
		::oCliente:dRevisao	   :=  SA1->A1_YDT_UAT       // Regra 1: Cadastro do cliente revisado por mais de 6 meses (controle por campo de data);
		::oCliente:nLimitCred  :=  SA1->A1_LC - SA1->A1_SALDUP  // Regra 2: Limite de credito (Saldo) < Valor do Pedido;
		::oCliente:dCredVenc   :=  SA1->A1_VENCLC    // Regra 3: Data do limite de crédito vencida;
		::oCliente:dTitAtras   := .F.                // Regra 4: Títulos em atraso > Regra do risco do cliente;
		::oCliente:dtNeurot    :=  SA1->A1_YDTNEU    // DATA validade de CREDITO NEUROTECH PARA liberar compras apenas com titulos em atraso.
		::oCliente:oGrupoEco   := oGrpEco:GrpEcoCli(::oCliente)
	EndIf

Return ::oCliente


Method GetCliLoja(Filial, Codigo, Loja) Class TINClienteDAO

Return ::GetIndice(Filial+Codigo+Loja, 1)
