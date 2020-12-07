#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MVC_ITEM
@author Tiago Rossini Coradini
@since 07/01/2020
@version 1.0
@description Pontos de entrada MVC da rotina MATA020 - Fornecedor - O ID do modelo da dados da rotina MATA020 é CUSTOMERVENDOR.
@type function
/*/

User Function CustomerVendor()
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
    
    	xRet := .T.
    	
			If Alltrim(M->A2_EST) == "EX"
				
				If Alltrim(M->A2_CGC) == "" .Or. Alltrim(M->A2_CGC) == "."
					
					xRet := .T.
					
				EndIf
				
			Else
			
				If Alltrim(M->A2_CGC) <> ""
					
					xRet := .T.
					
				Else
									
					MessageBox("Estado diferente de 'EX' favor preencher o campo CNPJ/CPF para continuar.", cIdModel + "/" + cIdPonto, 48) //"STOP")
					
					xRet := .F.
					
				EndIf
				
			EndIf
			
			If Alltrim(M->A2_TIPO) <> "X" .AND. Alltrim(M->A2_EST) <> "EX"
			
				If Empty(M->A2_COD_MUN)
				
					MessageBox("Favor preencher o Código do Município no cadastro de fornecedores.", cIdModel + "/" + cIdPonto, 48)//"STOP")
				
					xRet := .F.
					
				EndIf
				
			EndIf

    // Chamada na validação total do formulário
    ElseIf cIdPonto == "FORMPOS"
    	
    	xRet := U_BIAF062()

    // Chamada na pré validação da linha do formulário
    ElseIf cIdPonto == "FORMLINEPRE"

    // Chamada na validação da linha do formulário.
    ElseIf cIdPonto == "FORMLINEPOS"

    // Chamada após a gravação total do modelo e dentro da transação
    ElseIf cIdPonto == "MODELCOMMITTTS"
        
      // Incluir
      If nOp == 3 .Or. nOp == 4
      
      	U_BIAF140(nOp)

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