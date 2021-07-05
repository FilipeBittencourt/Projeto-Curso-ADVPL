#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF146
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao para processamento automatico de Politica de Credito
@type class
/*/

User Function BIAF146(dData, cCliente, cLoja, cGrpVen, cCnpj, nLimCreSol, nVlrObr, cOrigem, lSchedule)
Local cRet := ""
Local oObj := Nil

	Default dData := dDataBase
	Default cCliente := ""
	Default cLoja := ""
	Default cGrpVen := ""
	Default cCnpj := ""
	Default nLimCreSol := 0
	Default nVlrObr := 0 
	Default cOrigem := "1"	
	Default lSchedule := .T.

	If lSchedule

		RpcSetType(3)
		RpcSetEnv("01", "01")
		
	EndIf

	If !U_fValFunc(Alltrim(cCnpj))

		oObj := TPoliticaCredito():New()
		
		oObj:dData := dData
		oObj:cCliente := cCliente
		oObj:cLoja := cLoja
		oObj:cGrpVen := cGrpVen
		oObj:cCnpj := cCnpj
		oObj:nLimCreSol := nLimCreSol
		oObj:nVlrObr := nVlrObr
		oObj:cOrigem := cOrigem
			
		oObj:Process()
		
		cRet := oObj:cCodPro

		FreeObj(oObj)
	
	EndIf 

	If lSchedule	
		
		RpcClearEnv()
		
	EndIf
		
Return(cRet)
