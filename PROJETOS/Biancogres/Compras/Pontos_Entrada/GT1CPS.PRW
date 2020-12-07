#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} GT1CPS
//Ponto de entrada para adicionar campos de usuario editaveis na Importação de NFE
para informacao desses campos ser carregada para o mata103 eh necessario o P.E. GT1ITEM

@author
@since 07/06/2017
@version undefined

@type function
/*/
User Function GT1CPS()

	Local aAdItem := {}

	//esses campos devem ser cadastrados na tabela do Importador contida no parametro MV_XGTTAB2
	AAdd(aAdItem, "_LOTECT")
	AAdd(aAdItem, "_DTVALI")
	AAdd(aAdItem, "_CLVL")

Return(aAdItem)