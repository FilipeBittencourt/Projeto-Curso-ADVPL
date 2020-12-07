#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MVC_ITEM
@author Tiago Rossini Coradini
@since 07/01/2020
@version 1.0
@description Pontos de entrada MVC da rotina EECAT140 - Cotação de Moedas - O ID do modelo da dados da rotina EECAT140 é EXPP013.
@type function
/*/

User Function EXPP013()
Local aParam := ParamIxb
Local xRet := .T.
Local oObj := ""
Local cIdPonto := ""
Local cIdModel := ""
Local nOp := 0
Local aArea := GetArea()

	If !Empty(aParam)

		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		nOp := oObj:GetOperation()
	
    // Chamada na ativação do modelo de dados
    If cIdPonto == "MODELVLDACTIVE"

    // Chamada na validação total do modelo
    ElseIf cIdPonto == "MODELPOS"    

    // Chamada na validação total do formulário
    ElseIf cIdPonto == "FORMPOS"

    // Chamada na pré validação da linha do formulário
    ElseIf cIdPonto == "FORMLINEPRE"

    // Chamada na validação da linha do formulário.
    ElseIf cIdPonto == "FORMLINEPOS"

    // Chamada após a gravação total do modelo e dentro da transação
    ElseIf cIdPonto == "MODELCOMMITTTS"
        
      // Incluir
      If nOp == 3 .Or. nOp == 4
      
      	U_BIAF141(nOp)

      // Excluir
      ElseIf nOp == 5
      	
      EndIf
        
    // Chamada após a gravação total do modelo e fora da transação
    ElseIf cIdPonto == "MODELCOMMITNTTS"
        
    // Chamada após a gravação da tabela do formulário
    ElseIf cIdPonto == "FORMCOMMITTTSPRE"
        
    // Chamada após a gravação da tabela do formulário
    ElseIf cIdPonto == "FORMCOMMITTTSPOS"

    // Chamada no Botão Cancelar
    ElseIf cIdPonto == "MODELCANCEL"
        
    // Adicionando Botao na Barra de Botoes (BUTTONBAR)
    ElseIf cIdPonto == "BUTTONBAR"

    EndIf
	    
	EndIf
	
	RestArea(aArea)	
	
Return(xRet)