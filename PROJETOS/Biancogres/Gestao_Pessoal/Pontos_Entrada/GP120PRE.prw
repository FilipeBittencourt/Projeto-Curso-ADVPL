#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GP120PRE
@author Wlysses Cerqueira (Facile)
@since 01/04/2019
@project Automação Financeira
@version 1.0
@description 
@type PE chamado no fechamento de periodo depois do abatimento da parcela de lancamento futuro (RCK).
/*/

User Function GP120PRE()
	
	Local oObj := TBaixaDacaoReceber():New("FOL")
	
	oObj:Processa()

Return()

/*
User Function wsc()

	Local oObj := Nil
	Local nRecnoRCH := 2703
	Local nRecnoSRK := 2214
	Local nRecnoSRA := 1877
	
	If SELECT("SX2") == 0
		RpcSetEnv("01", "01")
	ENDIF
	
	DBSELECTAREA("RCH")
	DBSELECTAREA("SRK")
	
	RCH->(DBGoto(nRecnoRCH))
	SRK->(DBGoto(nRecnoSRK))
	SRA->(DBGoto(nRecnoSRA))
	
	oObj := TBaixaDacaoReceber():New("FOL")
	
	oObj:Processa()
	
	If SELECT("SX2") == 0
		RpcClearEnv()
	ENDIF
	
return()
*/