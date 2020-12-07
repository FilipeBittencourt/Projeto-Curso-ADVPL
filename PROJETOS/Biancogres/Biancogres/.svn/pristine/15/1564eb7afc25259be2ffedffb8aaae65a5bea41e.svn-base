#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFProcess
@author Tiago Rossini Coradini
@since 24/10/2018
@project Automação Financeira
@version 1.0
@description Classe para gerenciamento de processos
@type class
/*/

Class TAFProcess From LongClassName

	Data cIDProc
	Data oWFP
	Data lAviso
	
	Method New() Constructor
	Method GetNewID()
	Method Start()
	Method Finish()
	Method SetConsoleLog(cPar)
	
EndClass


Method New() Class TAFProcess
	
	::lAviso := .F.
	
	::cIDProc := ""
	
	::oWFP := TAFWorkFlowProcess():New()
	 	
Return()


Method GetNewID() Class TAFProcess
Local cRet := ""
Local nOrdem := 2
Local cChaveID := ""

	cRet := GetSxENum("ZK2", "ZK2_IDPROC", "ZK2_IDPROC", nOrdem)
	
	cChaveID := cRet
		
	DbSelectArea("ZK2")
	ZK2->(DbSetOrder(nOrdem))
	
	While ZK2->(MsSeek(cChaveID))
		
		If __lSx8
		
			ConfirmSX8()
		
		EndIf
		
		cRet := GetSxENum("ZK2", "ZK2_IDPROC", "ZK2_IDPROC", nOrdem)
		
		cChaveID := cRet
		
	EndDo

	ConfirmSx8()

Return(cRet)


Method Start() Class TAFProcess
	
	::cIDProc := ::GetNewID()
	
	::SetConsoleLog("I")
	
Return(::cIDProc)


Method Finish() Class TAFProcess
		
	::oWFP:cIDProc := ::cIDProc
	::oWFP:lAviso := ::lAviso
	::oWFP:Send()
		
	::SetConsoleLog("F")
	
Return()


Method SetConsoleLog(cPar) Class TAFProcess
Local cLog := ""
Local cTit := ""

	If cPar == "I"

		cTit := "Iniciado"

	ElseIf cPar == "F"

		cTit := "Finalizado"
		
	EndIf

	cLog := Replicate("-", 120) + Chr(13)
	cLog += "[" + Dtoc(Date()) + Space(1) + Time() + "] -- Automacao Financeira -- [Empresa: "+ cEmpAnt +"] -- [Filial: "+ cFilAnt +"] -- [Processo: " + ::cIDProc + "] -- " + cTit + Chr(13)
	cLog += Replicate("-", 120)
	
	ConOut(Chr(13) + cLog)

Return()