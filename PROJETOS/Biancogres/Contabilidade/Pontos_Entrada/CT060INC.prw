#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} CT060INC
@author Marcelo Sousa - Facile Sistemas
@since 16/10/18
@version 1.0
@description O ponto de entrada CT060INC é executado na inclusao da classe de valor
@obs Criado para que no momento da criação de uma classe de valor, o sistema crie também um departamento com mesmo código e descrição
@type function
/*/

User Function CT060INC()

	cExiste := ""

	// Verificando se já existe o departamento criado
	DBSELECTAREA("SQB")
	SQB->(DBGOTOP())
	cExiste := SQB->(DBSEEK(CTH->CTH_FILIAL+CTH->CTH_CLVL))	
	
	If INCLUI .AND. !cExiste
		
		RECLOCK("SQB",.T.)
		
			SQB->QB_DEPTO := CTH->CTH_CLVL
			SQB->QB_DESCRIC := CTH->CTH_DESC01
		
		SQB->(MSUNLOCK())
			
	ELSEIF ALTERA .AND. !cExiste
	
		RECLOCK("SQB",.T.)
		
			SQB->QB_DEPTO := CTH->CTH_CLVL
			SQB->QB_DESCRIC := CTH->CTH_DESC01
		
		SQB->(MSUNLOCK())
	
	ENDIF
	
	If Inclui 
	
		If SubStr(CTH->CTH_CLVL, 1, 1) == "8"
	
			fAddItem(CTH->CTH_CLVL)
			
		EndIf
	
	EndIf
	
Return()


User Function fAddItem(cClvl)

	Begin Transaction
	
		fAdd(cClvl)
	
	End Transaction
				
Return()


Static Function fAdd(cClvl)
Local cCodRef := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT * "
	cSQL += " FROM _SUBITEM_PADRAO "
	
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		RecLock("ZMA", .T.)
		
			cCodRef := GetSxEnum('ZMA', 'ZMA_CODIGO')

			ZMA->ZMA_FILIAL := xFilial("ZMA")
			ZMA->ZMA_CODIGO := cCodRef
			ZMA->ZMA_CLVL := cClvl
			ZMA->ZMA_ITEMCT := (cQry)->ITEMCT
			
		ZMA->(MsUnLock())
	
		RecLock("ZMB", .T.)
		
			ZMB->ZMB_FILIAL := xFilial("ZMB")
			ZMB->ZMB_CODREF := cCodRef
			ZMB->ZMB_SUBITE := (cQry)->SUBITE
			ZMB->ZMB_DESC := (cQry)->DESCR
		
		ZMB->(MsUnLock())

		(cQry)->(DbSkip())
		
	EndDo()
				
	(cQry)->(DbCloseArea())
			
Return()