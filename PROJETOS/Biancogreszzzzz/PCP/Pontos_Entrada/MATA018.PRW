#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA018   ºAutor  ³Ranisses A. Corona  º Data ³  06/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Replica o Cadastro de Indicador para demais empresass       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function MATA018()

	Local cTipo := ""
	Local cCod  := ""

	If Inclui
		cTipo := "I"
		cCod	:= M->BZ_COD
	ElseIf Altera
		cTipo := "A"
		cCod	:= SBZ->BZ_COD
	ElseIf IsInCallStack("A018DELETA")
		cTipo := "E"
		cCod	:= SBZ->BZ_COD
	EndIf        

	If Inclui .or. Altera .or. IsInCallStack("A018DELETA")

		If cEmpAnt $ "01_05_07_12_13_14_16_17"
			If cEmpAnt == "01"
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "05"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "07"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "12"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "13"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "14"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "16"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			ElseIf cEmpAnt == "17"
				U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
				U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			EndIf
		EndIf

	EndIf

Return
