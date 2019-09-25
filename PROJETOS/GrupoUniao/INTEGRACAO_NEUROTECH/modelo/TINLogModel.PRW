#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TINLogModel
@description Classe para gerar logs vindos da integração neurotech
@author Fernando Rocha / Filipe Vieira
@since 19/12/2018
@version 1.0
/*/


Class TINLogModel From LongClassName

	//Dados parametros
	Data cFilialx
	Data cNumPedido  //pedido de venda
	Data cNumNeu    // numero ou codigo gerado pela neurotech
	Data dDtEnvNeu
	Data cHrEnvNeu
	Data dDtResNeu
	Data cHrResNeu
	Data cLimitNeu
	Data cMotivNeu // motivo da rejeição da Neurotech
	Data cCodVend
	Data cCodOper
	Data cStatus
	
	Data cCodCli
	Data cCliLoja
	Data cCliNome
	Data cCliCGC

	Data cMotivLib // motivo da libereção de forma manual feita pelo user.
	Data cRotina
	Data cOutXML
	Data cInXML
	Data cErroNeu //Error da Neurotech
	Data cCodNeu  //Codigo da transação da neurotech
	Data nVlrNeu  //Valor vindo da neurotech
	
	 
	
	Method New() Constructor

EndClass

Method New() Class TINLogModel 	
	::nVlrNeu := 0
Return Self

