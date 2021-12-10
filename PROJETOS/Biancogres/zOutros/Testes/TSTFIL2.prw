//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOPCONN.CH"



// U_TSTFIL2()
User Function TSTFIL2()

	Local oObj   := Nil
	Local cHTML  := ""

	RpcClearEnv()
	If Select("SX6") <= 0
		RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1", "SF1", "SF2"})
	EndIf
// TICKET:23276
	oObj         := TAprovaPedidoCompraEMail():New()
	oObj:cNumPed := "PAQMTC"
  cHTML        := oObj:RetHtml()

Return cHTML

