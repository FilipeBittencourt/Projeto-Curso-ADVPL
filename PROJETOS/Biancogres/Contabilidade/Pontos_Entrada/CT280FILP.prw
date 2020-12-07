#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} CT280FILP
@author Marcelo Sousa - Facile Sistemas
@since 16/10/18
@version 1.0
@description O ponto de entrada CT280SKIP valida se o rateio off-line será feito ou não
@obs Criado para que as contas variáveis não entre na lista de contas contábeis que sofrerão rateio
@type function
/*/

user function CT280FILP()

	Local msRet     := .T.
	Local msAreaAtu := GetArea()

	Local msItCus   := Posicione("CT1", 1, xFilial("CT1") + cConta, "CT1_YITCUS")
	Local msTpItCus := Posicione("Z29", 1, xFilial("Z29") + msItCus, "Z29_TIPO")

	If msTpItCus == "CV" 

		msRet := .F.

	EndIf

	RestArea( msAreaAtu )

Return ( msRet )
