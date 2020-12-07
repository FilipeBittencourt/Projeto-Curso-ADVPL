#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAFG011
@author Gabriel Rossi Mafioletti
@since 19/06/17
@version 1.0
@description Pseudo Apontamento de Produção
@type function
/*/
User Function BIAFG011()

	Local aArea := GetArea()
	Local oBrowse := Nil
	Private aRotina := MenuDef()
	Private cCadastro := "Pseudo Apontamento"    

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z97')
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

	RestArea(aArea)

Return   

Static Function MenuDef() 

	Local aRotina := {}

	aAdd(aRotina, {'Pesquisar', 'PesqBrw'   , 0, 1, 0, NIL})
	aAdd(aRotina, {'Proc. SGG', 'U_BIAFG010', 0, 3, 0, NIL})
	aAdd(aRotina, {'Proc. SG1', 'U_BIAFG012', 0, 3, 0, NIL})
	aAdd(aRotina, {'Relatório', 'U_BIAFG013', 0, 4, 0, NIL})

return(aRotina)
