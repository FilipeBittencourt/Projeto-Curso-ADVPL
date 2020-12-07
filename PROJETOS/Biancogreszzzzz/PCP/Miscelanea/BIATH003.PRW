#Include 'Protheus.ch'

/*/{Protheus.doc} BIATH003
@author Thiago Haagensen
@since 22/09/2020
@version 1.0
@description AXCadastro para uso no relatório do Power BI - Aba de Produção
@type function
/*/

User Function BIATH003()
 
PRIVATE cCadastro  := "Acidente de Trabalho"
PRIVATE aRotina     := {}

AxCadastro("ZDE", OemToAnsi(cCadastro))

Return Nil
