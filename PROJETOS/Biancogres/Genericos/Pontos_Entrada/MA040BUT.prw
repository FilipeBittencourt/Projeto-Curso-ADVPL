#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MA040BUT
@author Tiago Rossini Coradini
@since 29/11/2016
@version 1.0
@description Ponto de entrada para adicionar botões no cadastro de vendedores 
@obs OS: 3861-16 - Ranisses Corona
@type function
/*/

User Function MA040BUT()
Local aButton := {}
	
	aButton := {{"Rescisão", {|| U_BIAF055() }, "Rescisão"}}

Return(aButton)