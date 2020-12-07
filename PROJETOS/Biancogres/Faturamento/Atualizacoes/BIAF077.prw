#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF077
@author Tiago Rossini Coradini
@since 26/05/2017
@version 1.0
@description Rotina de cadastro de Parametros Comissao Variavel dos Vendedores 
@obs OS: 4308-16 - Mateus Fadini
@type function
/*/

User Function BIAF077()
Local bOK := {|| fValid() }
  
	AxCadastro("Z92", "Parametros Comissao Variavel", ".T.", ".T.",,, bOK)  

Return()


Static Function fValid()
Local lRet := .T.
Local aArea := Z92->(GetArea())
Local nRecNo := Z92->(RecNo())

	If Inclui .Or. Altera
	
		If M->Z92_CODEMP == "1"
		
			If !M->Z92_CODMAR $ "2/3/4"
			
				lRet := .F.
				
				MsgAlert("Atenção, marca não permitida na empresa Incesa.")
			
			EndIf
		
		EndIf
						
		If lRet
						
			DbSelectArea("Z92")
			DbSetOrder(3)			
			
			If Z92->(DbSeek(xFilial("Z92") + M->(Z92_CODVEN + Z92_CODEMP + Z92_CODMAR + Z92_CODPAC))) .And. (Inclui .Or. (Altera .And. Z92->(RecNo()) <> nRecNo))
				
				lRet := .F.
				
				MsgAlert("Atenção, o vendedor já está associado a essa empresa/marca/pacote.")
							
			EndIf
			
		EndIf
		
	EndIf
	
	RestArea(aArea)

Return(lRet)