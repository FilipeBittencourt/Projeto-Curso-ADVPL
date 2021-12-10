#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/*
Função: A010TOK
------------------------------------------------------------------------------------------------------------
Escopo     : Função de Usuário
Descrição  : PONTO DE ENTRADA ANTES DA INCLUSÃO/ALTERAÇÃO DE UM PRODUTO
Uso:       : Inclusão, alteração e deleção de registros no cadastro
Parâmetros : Nenhum
Retorno    : Nulo
------------------------------------------------------------------------------------------------------------
Atualizações:
- 21/10/2018 - FILIPE VIEIRA - Construção inicial
------------------------------------------------------------------------------------------------------------
*/


User Function A010TOK()

	Local lExecuta := .T. // variavel responsavel por retornar a ação do ponto de entrada
	Local cTipo  := AllTrim(M->B1_TIPO)
	Local cConta := AllTrim(M->B1_CONTA)
	
	If(cTipo == "PA" .AND. cConta == "001")
		Alert("A conta <b>"+cConta+"</b> não pode estar associada a um produto do tipo <b>"+cTipo+"</b>")
		lExecuta := .F.
	EndIF
	
Return lExecuta

