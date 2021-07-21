#Include 'Protheus.ch'

/*/{Protheus.doc} BIATH005
@author Thiago Haagensen
@since 14/07/2021
@version 1.0
@description AXCadastro para uso no relatório do Power BI - Cadastro de Metas
@type function
/*/

User Function BIATH005()
 
PRIVATE cCadastro  := "Cadastro de Metas"
PRIVATE aRotina     := {}

AxCadastro("ZG7", OemToAnsi(cCadastro))

Return Nil
