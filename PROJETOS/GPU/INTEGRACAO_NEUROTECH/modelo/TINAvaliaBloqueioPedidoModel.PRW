#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} TINAvaliaBloqueioPedidoModel
@description Classe para avaliacao de regras e se é para bloquear / liberar
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/

#define MSG_REG01 "Cliente com cadastro sem atualização a mais de 6 meses."
#define MSG_REG02
#define MSG_REG03
#define MSG_REG04
#define MSG_REG05

Class TINAvaliaBloqueioPedidoModel From LongClassName

Data Pedido
Data Item
Data Cliente
Data Loja

Data lPermite		//Flag que define se permite ou não continuar a digitacao do Pedido
Data lLiberado		//Flag que define se o pedido vai ser liberado ou bloqueado
Data cMenBloq		//Mensagem de Retorno

Data lRegra01		//Retorno se a Regra 1 foi verificada
Data lRegra02		//Retorno se a Regra 2 foi verificada
Data lRegra03		//Retorno se a Regra 3 foi verificada
Data lRegra04		//Retorno se a Regra 4 foi verificada
Data lRegra05		//Retorno se a Regra 5 foi verificada

Method New() Constructor

//Metodos para avaliar cada uma das regras
Method Regra01()
Method Regra02()
Method Regra03()
Method Regra04()
Method Regra05()

Method AvRegraPed()  //Avaliar as regras conforme dados do pedido e retornar o que tem que ser feito

Method GetMsgRet()

EndClass


Method New() Class TINAvaliaBloqueioPedidoModel

	::Pedido := ""
	::Item := ""
	::Cliente := ""
	::Loja := ""
	::lPermite	:= .T.	
	::lLiberado	:= .T.
	::cMenBloq	:= ""
	::lRegra01 := .F.
	::lRegra02 := .F.
	::lRegra03 := .F.
	::lRegra04 := .F.
	::lRegra05 := .F.

Return Self



/*/{Protheus.doc} AvPermIncl
@description Avaliar se permite a inclusao de pedido / se bloqueia ou se libera
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
@type function
/*/
Method AvRegraPed()  Class TINAvaliaBloqueioPedidoModel
	/*
		::Regra01()

		If ( ::lRegra01 )

			::lPermite := .F.
			::cMenBloq := ::GetMsgRet()
			Return

		EndIf
	*/

	::lPermite := .F.

Return  


/*/{Protheus.doc} AvPermIncl
@description Avaliar Regra 01: Cadastro do cliente revisado por mais de 6 meses (controle por campo de data)
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/

Method Regra01() Class TINAvaliaBloqueioPedidoModel

	Local oCliente := TINCliente():New(::Cliente, ::Loja)

	If (oCliente:Ok .And. oCliente:DataRevisa < (dDataBase - 180) )  //Todo:   verificar calculo de data 6 meses atras

		::lRegra01 := .T.

	EndIf

Return





/*/{Protheus.doc} AvPermIncl
@description Retornar mensagem com motivos dos bloqueios
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
@type function
/*/
Method GetMsgRet() Class TINAvaliaBloqueioPedidoModel

	Local cRet := ""

	If ( ::lRegra01 )

		cRet += MSG_REG01

	EndIf

Return cRet
