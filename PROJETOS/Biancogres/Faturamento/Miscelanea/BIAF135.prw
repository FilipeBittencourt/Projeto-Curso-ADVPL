#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF135
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Função para Inclusão via Job de Vistorias em Obras de Engenharia
@obs Ticket: 19122
@type function
/*/

User Function BIAF135()
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
		
			oObj := TVistoriaObraEngenharia():New()
			
			oObj:dEmiDe := DaySub(dDataBase, 2)
			oObj:dEmiAte := DaySub(dDataBase, 2)
			
			oObj:Process()
			
			FreeObj(oObj)
				
		RpcClearEnv()
		
	Next

Return()

/*
// TESTE para forçar geração de termo de vistoria que não foi gerado na pasta
User Function BIAPNT()
Local aEmp := {}
Local cFil := "01"
Local nCount := 0
Local oObj := Nil

	RpcSetType(3)
	RpcSetEnv("07", cFil)
	
		oObj := TTermoVistoriaObraEngenharia():New()
		
		oObj:docto := "000267276101"
		oObj:Process()
		
		FreeObj(oObj)
			
	RpcClearEnv()

Return()

// TESTE para forçar envio de workflow
User Function BIAPNTW()
Local aEmp := {}
Local cFil := "01"
Local nCount := 0
Local oObj := Nil

	RpcSetType(3)
	RpcSetEnv("07", cFil)
	
		oObj := TWorkflowVistoriaObraEngenharia():New()
		
		oObj:SendWorkFlow(DTOS(Date()), "009216", "Cliente teste", "", "000267276101", "cDescObr", "pablo.nascimento@biancogres.com.br")
		
		FreeObj(oObj)
			
	RpcClearEnv()

Return()
*/
