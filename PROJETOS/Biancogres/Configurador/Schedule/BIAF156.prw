#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF156
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Função para gerção via Job dos relatorios de Liquidez - BIAV003
@obs Ticket: 23030
@type function
/*/

User Function BIAF156()
Local aEmp := {}
Local cFil := "01"
Local nCount := 0
Private aBkpPar := {}
	
	aAdd(aEmp, "01")
	aAdd(aEmp, "05")
	aAdd(aEmp, "07")
	
	For nCount := 1 To Len(aEmp)

		RpcSetType(3)
		RpcSetEnv(aEmp[nCount], cFil)
		
			fBackupPar()
		
			fMesAtual()
			
			If fVldExec()
				
				fMesFechado()
				
			EndIf
			
			fRestorePar()
			
			// Envia e-mail informando que o relatorio foi gerado
			fSendMail()
					
		RpcClearEnv()
		
	Next

Return()


Static Function fMesAtual()

	MV_PAR01 := FirstDate(dDataBase)
	MV_PAR02 := LastDate(dDataBase)
	MV_PAR03 := Space(3)
	MV_PAR04 := Replicate("Z", 3)
	MV_PAR05 := Space(10)
	MV_PAR06 := Replicate("Z", 10)
	MV_PAR07 := Space(6)
	MV_PAR08 := Replicate("Z", 6)
	MV_PAR09 := cToD("01/01/90")
	MV_PAR10 := cToD("31/12/35")
	MV_PAR11 := 1
	MV_PAR12 := 1
	MV_PAR13 := 1
	MV_PAR14 := 2
	MV_PAR15 := "01234567FGH"
	MV_PAR16 := 2
	MV_PAR17 := 1
	MV_PAR18 := Space(2)
	MV_PAR19 := Replicate("Z", 2)
	MV_PAR20 := Space(4)
	MV_PAR21 := Replicate("Z", 4)
	MV_PAR22 := Space(2)
	MV_PAR23 := Replicate("Z", 2)
	MV_PAR24 := 2
	MV_PAR25 := 1
	MV_PAR26 := Space(3)
	MV_PAR27 := Replicate("Z", 3)
	MV_PAR28 := ""
	MV_PAR29 := "RA;JP;BOL;" //Ticket 29738 - Alteração de Parametros e Filtros Relatórios automaticos - Power BI  -- Ticket 34554 Tipo BOL
	MV_PAR30 := 2
	MV_PAR31 := cToD("01/01/90")
	MV_PAR32 := cToD("31/12/35")
	MV_PAR33 := Space(2)
	MV_PAR34 := Replicate("Z", 2)
	MV_PAR35 := 2
	MV_PAR36 := 1
	MV_PAR37 := 3
	MV_PAR38 := 2
	MV_PAR39 := 2
	MV_PAR40 := 2
	MV_PAR41 := 1
	MV_PAR42 := 2
	
	U_BIAV003(.T.)

Return()


Static Function fMesFechado()
Local dDatBkp := dDataBase

	dDataBase := LastDate(MonthSub(dDataBase, 1))
    
	MV_PAR01 := FirstDate(dDataBase)
	MV_PAR02 := LastDate(dDataBase)
	MV_PAR03 := Space(3)
	MV_PAR04 := Replicate("Z", 3)
	MV_PAR05 := Space(10)
	MV_PAR06 := Replicate("Z", 10)
	MV_PAR07 := Space(6)
	MV_PAR08 := Replicate("Z", 6)
	MV_PAR09 := cToD("01/01/90")
	MV_PAR10 := cToD("31/12/35")
	MV_PAR11 := 1
	MV_PAR12 := 1
	MV_PAR13 := 1
	MV_PAR14 := 2
	MV_PAR15 := "01234567FGH"
	MV_PAR16 := 2
	MV_PAR17 := 1
	MV_PAR18 := Space(2)
	MV_PAR19 := Replicate("Z", 2)
	MV_PAR20 := Space(4)
	MV_PAR21 := Replicate("Z", 4)
	MV_PAR22 := Space(2)
	MV_PAR23 := Replicate("Z", 2)
	MV_PAR24 := 2
	MV_PAR25 := 1
	MV_PAR26 := Space(3)
	MV_PAR27 := Replicate("Z", 3)
	MV_PAR28 := ""
	MV_PAR29 := "RA;JP;BOL;" //Ticket 29738 - Alteração de Parametros e Filtros Relatórios automaticos - Power BI  -- Ticket 34554 Tipo BOL
	MV_PAR30 := 2
	MV_PAR31 := cToD("01/01/90")
	MV_PAR32 := cToD("31/12/35")
	MV_PAR33 := Space(2)
	MV_PAR34 := Replicate("Z", 2)
	MV_PAR35 := 2
	MV_PAR36 := 1
	MV_PAR37 := 3
	MV_PAR38 := 2
	MV_PAR39 := 2
	MV_PAR40 := 2
	MV_PAR41 := 1
	MV_PAR42 := 2
	
	U_BIAV003(.T.)
	
	dDataBase := dDatBkp 

Return()


Static Function fVldExec()
Local lRet := .F.

	lRet := dDataBase == DataValida(DaySum(FirstDate(dDataBase), 1), .T.)

Return(lRet)


Static Function fBackupPar()
Local nCount := {}
	
	aBkpPar := {}
	
	For nCount := 1 To 42
	
		aAdd(aBkpPar, &("MV_PAR" + StrZero(nCount, 2)))
		
	Next
	
Return()


Static Function fRestorePar()
Local nCount := 0

	For nCount := 1 To 42
		
		&("MV_PAR" + StrZero(nCount, 2)) := aBkpPar[nCount]
	
	Next

Return()


Static Function fSendMail()
Local cDest := U_EmailWF('BIAF156', cEmpAnt)
Local cAssu := "Relatórios de Liquidez - BIAV003 "
Local cErro := cAssu + " não enviado. Favor verificar!!!" 
	
	U_BIAEnvMail(, cDest, cAssu, "Relatório de Baixa atualizado.", cErro)
	
Return()
