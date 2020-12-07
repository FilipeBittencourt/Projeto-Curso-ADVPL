#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF144
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Funcao para chamada da Classe para calculo do saldo diario acumulado dos clientes - Anual
@type class
/*/

User Function BIAF144()
Local oParam := TParBIAF144():New()

	If oParam:Box()
					
		cHoraIni := Time()
	
		U_BIAMsgRun("Calculando Saldo Acumulado - Periodo: "+ dToC(oParam:dDataDe) + " a " + dToC(oParam:dDataAte), "Aguarde!", {|| fProcess(oParam) })
	
		cHoraFim := Time()
		
		MsgAlert("Tempo de processamento: " + TimeDif(dDataBase, cHoraIni, dDataBase, cHoraFim))
					
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oObj := Nil
	
	oObj := TCalculoSaldoDiarioCliente():New()
	
	oObj:dDate := oParam:dDataDe
	oObj:dStartDate := oParam:dDataDe
	oObj:dEndDate := oParam:dDataAte

	oObj:Process()
	
	FreeObj(oObj)
	
Return()


Static Function TimeDif(dDataIni, cHoraIni, dDataFim, cHoraFim)
Local nDias := dDataFim - dDataIni
Local cTime := ElapTime(Left(cHoraIni + ":00:00:00",8), Left(cHoraFim + ":00:00:00",8))
Local nHora := Val(Left(cTime, 2))
	
	If Empty(StrTran(cHoraIni, ":", "")) .Or. Empty(StrTran(cHoraFim, ":", "")) .Or. Empty(dDataIni) .Or. Empty(dDataFim)
		
		Return("")
		
	Endif
	
	If nDias > 0 .And. Secs(cHoraFim) < Secs(cHoraIni)
		
		nDias--
		
	Endif                 
	
Return(AllTrim(PadL(If(Empty(nDias), "", Str(nDias, 3) + "d "), 5) + cTime + "h"))