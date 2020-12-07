#Include 'Protheus.ch'

/*/{Protheus.doc} BIATH004
@author Thiago Haagensen
@since 10/11/2020
@version 1.0
@description AXCadastro para uso no relatório do Power BI - Meta Produto Comprador
@type function
/*/

User Function BIATH004()
 
PRIVATE cCadastro  := "Meta Produto Comprador"
PRIVATE aRotina     := {}

AxCadastro("ZG6", OemToAnsi(cCadastro))

Return Nil
