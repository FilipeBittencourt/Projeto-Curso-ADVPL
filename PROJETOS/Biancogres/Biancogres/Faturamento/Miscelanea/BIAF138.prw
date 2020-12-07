#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF138
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Função via Job para envio de Workflow de Atrasos de Vistorias em Obras de Engenharia
@obs Ticket: 19122
@type function
/*/

User Function BIAF138()
Local aEmp := {}
Local cFil := "01"
Local nCount := 0
Local oObj := Nil
	
	aAdd(aEmp, "01")
	aAdd(aEmp, "05")	
	aAdd(aEmp, "07")
	
	For nCount := 1 To Len(aEmp)

		RpcSetType(3)
		RpcSetEnv(aEmp[nCount], cFil)
		
			// Email para Representante
			oObj := TWorkflowAtrasoVistoriaObraEngenharia():New()
			
			oObj:cType := "1"
			oObj:dData := dDataBase
			
			oObj:Process()
			
			FreeObj(oObj)
			
			// Email para Gestores
			oObj := TWorkflowAtrasoVistoriaObraEngenharia():New()
			
			oObj:cType := "2"
			oObj:dData := dDataBase
			
			oObj:Process()
			
			FreeObj(oObj)			
				
		RpcClearEnv()
		
	Next

Return()