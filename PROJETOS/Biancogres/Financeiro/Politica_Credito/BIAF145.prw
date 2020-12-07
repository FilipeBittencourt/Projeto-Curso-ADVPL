#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF145
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Funcao para chamada da Classe para calculo do saldo diario acumulado dos clientes - Mensal/Diario
@type class
/*/

User Function BIAF145()
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

			oObj := TCalculoSaldoDiarioCliente():New()
			
			oObj:lAuto := .T.
			
			oObj:Process()
			
			FreeObj(oObj)
				
		RpcClearEnv()
		
	Next
	
Return()