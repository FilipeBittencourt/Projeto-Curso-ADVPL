#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GPM5002
@author Marcos Alberto Soprani
@since 02/08/2016
@version 1.0
@description Este ponto de entrada destina-se à validação de usuário, para permitir a execução da rotina do cálculo do vale-transporte.
.            Contudo, para o nosso caso, ele foi utilizado para criar uma variável pública de controle de filtro de tipo de vale - bpmFiltM0Tr
@obs OS: 2536-16 - Jessica Silva
@type function
/*/

USER FUNCTION GPM050CA()

	Local cgrRet := .T.
	Public bpmFiltM0Tr := Space(200)

Return ( cgrRet )