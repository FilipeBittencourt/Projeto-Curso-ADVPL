#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAMsgRun
@author Tiago Rossini Coradini
@since 13/11/2017
@version 1.0
@description Função generica que exibe um painel com animação e texto durante o processamento de um bloco de código permite atualizar o texto em tempo de execução 
@type function
/*/

User Function BIAMsgRun(cText, cHeader, bAction)
	
	Default bAction := {|| .T.}
	Default cHeader := "Processando"
	Default cText := "Processando a rotina..."
	
	FWMsgRun(, bAction, cHeader, cText)

Return()