#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFS001
@description Rotina executada via scheduler / via programa que irá atualizar o campo status ZO_STATUS = 'Expirado', quando for AG
@author Emerson Salvador
@since 12/07/2021
@type function
/*/

User Function BIAFS001()

	Local cQuery    := ""
	Local nRetQry   := 0
	Local lJob      := select("SX6")==0    // Verifica se a rotina esta rodando em scheduler .T. em scheduler / .F. via sistema
	Local aEmp  	:= {}
	Local cEmp      := "01"
	Local cFil      := "01"
	Local x         := 0

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil)
		aEmp	:=	FWLoadSM0()     // Localiza todas as empresas/filiais
		RPCClearEnv()               // ENCERRA O AMBIENTE
	Endif

	For x:=1 to IIF(lJob, Len(aEmp), 1)

		If lJob
			cEmp := aEmp[x][03]
			cFil := aEmp[x][05]
			RpcSetType(3)
			RpcSetEnv(cEmp, cFil)
		Endif

		cQuery  := "UPDATE " + RetSqlName("SZO")
		cQuery  += " SET ZO_STATUS = 'Expirado' "
		cQuery  += "WHERE ZO_FILIAL = '" + xFilial("SZO") + "' "
		cQuery  += " AND ZO_YTPACOR IN ('AG') "
		cQuery  += " AND ZO_YDTVLD <> '' AND ZO_YDTVLD < '" + DTOS(dDataBase) + "' "
		cQuery  += " AND D_E_L_E_T_ = '' "

		nRetQry := TCSQLExec(cQuery)

		If (nRetQry < 0)
			DisarmTransaction()
			CONOUT("ATUALIZACAO NAO REALIZADA | SQL Error : " + TCSQLError())
		Else
			CONOUT("********** Tudo ok **************")
		Endif

		If lJob
			RPCClearEnv() // ENCERRA O AMBIENTE
		Endif
	Next

Return
