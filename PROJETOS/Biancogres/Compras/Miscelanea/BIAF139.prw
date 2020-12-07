#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF139
@author Tiago Rossini Coradini
@since 20/12/2019
@version 1.0
@description Função para apagar tabela G3Q que contrila se as rotinas padroes serao executadas via MVC 
@obs Ticket: 20823
@type function
/*/

User Function BIAF139()
Local nCount := 0

	RpcSetType(3)
	RpcSetEnv("01", "01")

	aEmp := FWLoadSM0()
	
	If Len(aEmp)

		For nCount := 1 To Len(aEmp)

			RpcSetType(3)
			RpcSetEnv(aEmp[nCount, 1], aEmp[nCount, 2])
			
			DbSelectArea("SX2")
			SX2->(DbSetOrder(1))
			
			If SX2->(DbSeek("G3Q"))
			
				RecLock( "SX2", .F.)
				
					SX2->(DbDelete())
				
				SX2->(MsUnLock())
			
			EndIf
			
		Next
	
		SM0->(dbCloseArea())
	
	EndIf
		
	RpcClearEnv()
	
Return()