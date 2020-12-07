#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF045
@author Fernando Rocha
@since 04/03/2020
@project Automação Financeira
@version 1.0
@description Prorrogacao de boletos a receber - Envio de Arquivo de Alteracao para Banco
@type function
/*/

User Function BAF045()

    Local oObj := Nil

    //RpcSetEnv("01", "01")
    
    oObj := TAFAlteraVencimentoReceber():New()
    oObj:Send()
		
	//RpcClearEnv()

Return()
