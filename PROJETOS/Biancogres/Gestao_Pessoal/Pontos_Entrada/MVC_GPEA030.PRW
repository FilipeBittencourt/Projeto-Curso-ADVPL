#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*
|-----------------------------------------------------------|
| Função:	| GPEA030																					|
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				|
| Data:		| 20/01/16																				|
|-----------------------------------------------------------|
| Desc.:	|	Ponto de entrada (MVC) utilizado para replicar	|
| 				|	a tabela em todas as empresas do grupo 					|
|-----------------------------------------------------------|
*/

User Function GPEA030()
Local aParam := ParamIxb
Local xRet := .T.
Local oObj := ''
Local cIdPonto := ''
Local cIdModel := ''
Local oReplica := TReplicateData():New()

	If aParam <> NIL
		
		oObj := aParam[1]
  	cIdPonto := aParam[2]
   	cIdModel := aParam[3]
    
		// Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS)
    If cIdPonto == 'MODELCOMMITNTTS'    		
			
			If SRJ->RJ_FUNCAO > "6000"
			
				oReplica:cTable := "SRJ"
				oReplica:cKey := SRJ->RJ_FUNCAO
				oReplica:cOpc := cValToChar(oObj:GetOperation())
				
				oReplica:Execute()
			
			EndIf
				    	
		EndIf
            
	EndIf
 
Return(xRet)