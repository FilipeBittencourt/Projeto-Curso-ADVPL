#include "protheus.ch"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"


User Function TST999()


	Local dNewDT  := CToD('//')

	Local dDtNCli := CToD("07/07/21")



	RpcClearEnv()
	If Select("SX6") <= 0
		//RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SX5","SF1", "SF2"})
		RpcSetEnv("01",'0'+"01"+'0001',"schedule.rh","Mudar@@123",,GetEnvServer(),{"SB1","SF1", "SF2"})
	EndIf

	dNewDT := DataValida(DaySum(dDtNCli, 7))


return dNewDT

/*
User Function UPD999()

	Local lDtVal  := .T.
	Local dNewDT  := CToD('//')
	Local nCountD := 1
	Local dDtNCli := CToD("07/07/21")
	Local dC6DTNERE := CToD("07/07/21")


	RpcClearEnv()
	If Select("SX6") <= 0
		RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SX5","SF1", "SF2"})
	EndIf

	dNewDT := DataValida(DaySum(dDtNCli, 7))



	IF Empty(dDtNCli)

		MSGSTOP( "Este pedido está com o campo 'Dt.Nec.Clien'. Favor preencha para prosseguir com o recebimento antecipado em OP.", "M440STTS" )

	else

		dNewDT := DataValida(DaySum(dDtNCli, 7))

		If DataValida(dDtNCli+7, lDtVal)

			dC6DTNERE :=  DaySum(dDtNCli, 7)

		Else

			dDtNCli  :=  DaySum(dDtNCli, 7+nCountD)

			while DataValida(dDtNCli) == .F.

				dDtNCli  :=  DaySum(dDtNCli, nCountD++)

			EndDo

		EndIf

	EndIf

	dC6DTNERE :=  dDtNCli

*/