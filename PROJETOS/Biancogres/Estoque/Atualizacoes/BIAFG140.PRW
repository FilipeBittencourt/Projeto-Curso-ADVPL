#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG140
@author Gabriel Rossi Mafioletti
@since 15/04/2020
@version 1.0
@description Rotina de Ajustes de controle de MD	
@type function
/*/


User Function BIAFG140()

	Local aArea := GetArea()
	Local oBrowse := Nil
	Private aRotina := MenuDef()
	Private cCadastro := "Controle de MD"    

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZCZ')
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

	RestArea(aArea)

Return  

Static Function MenuDef() 

	Local aRotina := {}

	aAdd(aRotina, {'Pesquisar', 'PesqBrw'   , 0, 1, 0, NIL})
	aAdd(aRotina, {'Rel. Kardex MD', 'U_BIAFG138', 0, 6, 0, NIL})
	aAdd(aRotina, {'Rel. Saldo MD', 'U_BIAFG139', 0, 7, 0, NIL})
	aAdd(aRotina, {'Libera MD', 'U_BIAFG141', 0, 8, 0, NIL})
	aAdd(aRotina, {'Entrada MD', 'U_BIAFG142', 0, 9, 0, NIL})
	aAdd(aRotina, {'Saída MD', 'U_BIAFG143', 0, 9, 0, NIL})
	aAdd(aRotina, {'Correção MD', 'U_BIAFG144', 0, 9, 0, NIL})


return(aRotina)
