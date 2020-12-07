#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF149
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao para verificar se existe Politica de Credito em processamento
@type class
/*/

User Function BIAF149(dData, cCliente, cLoja, cGrpVen, cCnpj, cOrigem, lSchedule)
Local lRet := .T.
Local oObj := Nil

	Default dData := dDataBase
	Default cCliente := ""
	Default cLoja := ""
	Default cGrpVen := ""
	Default cCnpj := ""
	Default cOrigem := "1"	
	Default lSchedule := .T.

	If lSchedule

		RpcSetType(3)
		RpcSetEnv("01", "01")
		
	EndIf

	oObj := TPoliticaCredito():New()
	
	oObj:dData := dData
	oObj:cCliente := cCliente
	oObj:cLoja := cLoja
	oObj:cGrpVen := cGrpVen
	oObj:cCnpj := cCnpj
	oObj:cOrigem := cOrigem
		
	lRet := !oObj:InProcess()

	FreeObj(oObj)
			
	If lSchedule	
		
		RpcClearEnv()
		
	EndIf
		
Return(lRet)