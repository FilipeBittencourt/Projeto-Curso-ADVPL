#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF154
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Função para geração via Job dos relatorios de Liquidez - BIAV001
@obs Ticket: 23030
@type function
/*/

User Function BIAF154()
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
				
		RpcClearEnv()
		
	Next

Return()


Static Function fMesAtual()

	MV_PAR01 := Space(6)
	MV_PAR02 := Replicate("Z", 6)
	MV_PAR03 := Space(3)
	MV_PAR04 := Replicate("Z", 3)
	MV_PAR05 := Space(6)
	MV_PAR06 := Replicate("Z", 6)
	MV_PAR07 := Space(3)
	MV_PAR08 := Replicate("Z", 3)
	MV_PAR09 := FirstDate(dDataBase)
	MV_PAR10 := DataValida(DaySub(dDataBase, 1), .F.)
	MV_PAR11 := Space(10)
	MV_PAR12 := Replicate("Z", 10)
	MV_PAR13 := cToD("01/01/90")
	MV_PAR14 := cToD("31/12/35")
	MV_PAR15 := 1
	MV_PAR16 := 2
	MV_PAR17 := 2
	MV_PAR18 := 2
	MV_PAR19 := 1
	MV_PAR20 := 1
	MV_PAR21 := 1
	MV_PAR22 := Space(2)
	MV_PAR23 := Replicate("Z", 2)
	MV_PAR24 := Space(2)
	MV_PAR25 := Replicate("Z", 2)
	MV_PAR26 := 2
	MV_PAR27 := cToD("01/01/90")
	MV_PAR28 := cToD("31/12/30")
	MV_PAR29 := 2
	MV_PAR30 := 1
	MV_PAR31 := ""
	MV_PAR32 := "RA;JP;BOL;" //Ticket 29738 - Alteração de Parametros e Filtros Relatórios automaticos - Power BI  -- Ticket 34554 Tipo BOL
	MV_PAR33 := 2
	MV_PAR34 := 2
	MV_PAR35 := 2
	MV_PAR36 := dDataBase
	MV_PAR37 := 1
	MV_PAR38 := 2
	MV_PAR39 := 2
	MV_PAR40 := 1
	MV_PAR41 := 2
	MV_PAR42 := 2
	MV_PAR43 := 2
	
	U_BIAV001(.T.)

Return()


Static Function fMesFechado()

	MV_PAR01 := Space(6)
	MV_PAR02 := Replicate("Z", 6)
	MV_PAR03 := Space(3)
	MV_PAR04 := Replicate("Z", 3)
	MV_PAR05 := Space(6)
	MV_PAR06 := Replicate("Z", 6)
	MV_PAR07 := Space(3)
	MV_PAR08 := Replicate("Z", 3)
	MV_PAR09 := FirstDate(MonthSub(dDataBase, 1))
	MV_PAR10 := LastDate(MonthSub(dDataBase, 1))
	MV_PAR11 := Space(10)
	MV_PAR12 := Replicate("Z", 10)
	MV_PAR13 := cToD("01/01/90")
	MV_PAR14 := cToD("31/12/35")
	MV_PAR15 := 1
	MV_PAR16 := 2
	MV_PAR17 := 2
	MV_PAR18 := 2
	MV_PAR19 := 1
	MV_PAR20 := 1
	MV_PAR21 := 1
	MV_PAR22 := Space(2)
	MV_PAR23 := Replicate("Z", 2)
	MV_PAR24 := Space(2)
	MV_PAR25 := Replicate("Z", 2)
	MV_PAR26 := 2
	MV_PAR27 := cToD("01/01/90")
	MV_PAR28 := cToD("31/12/30")
	MV_PAR29 := 2
	MV_PAR30 := 1
	MV_PAR31 := ""
	MV_PAR32 := "RA;JP;BOL;" //Ticket 29738 - Alteração de Parametros e Filtros Relatórios automaticos - Power BI -- Ticket 34554 Tipo BOL
	MV_PAR33 := 2
	MV_PAR34 := 2
	MV_PAR35 := 2
	MV_PAR36 := LastDate(MonthSub(dDataBase, 1))
	MV_PAR37 := 1
	MV_PAR38 := 2
	MV_PAR39 := 2
	MV_PAR40 := 1
	MV_PAR41 := 2
	MV_PAR42 := 2
	MV_PAR43 := 2
	
	U_BIAV001(.T.)
	

Return()


Static Function fVldExec()
Local lRet := .F.

	lRet := dDataBase == DataValida(DaySum(FirstDate(dDataBase), 1), .T.)

Return(lRet)


Static Function fBackupPar()
Local nCount := {}
	
	aBkpPar := {}
	
	For nCount := 1 To 43
	
		aAdd(aBkpPar, &("MV_PAR" + StrZero(nCount, 2)))
		
	Next
	
Return()


Static Function fRestorePar()
Local nCount := 0

	For nCount := 1 To 43
		
		&("MV_PAR" + StrZero(nCount, 2)) := aBkpPar[nCount]
	
	Next

Return()

//Thiago Haagensen - Ticket 26109 - Notificação por e-mail
User function wfSend01()
	Local df_Dest := ""
	Local df_Assu := "Relatórios de Liquidez - BIAV001 "
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!" 

	df_Dest:=U_EmailWF('BIAF154', cEmpAnt)
	
	U_BIAEnvMail(, df_Dest, df_Assu, "Relatório de Liquidez Atraso atualizado.", df_Erro)	
return
