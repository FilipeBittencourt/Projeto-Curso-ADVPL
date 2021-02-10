#Include 'TOTVS.CH'
#Include "TopConn.ch"

/*
------------------------------------------------------------------------------------------------------------
Função   	: PCMOTOR0
Tipo		  : MAIN job
Descrição	: função para CHAMAR TODOS OS JOBS
Autor     : Filipe Bittencourt - Facile
*/


//U_PCMOTOR0
User Function  PCMOTOR0(xParam1,xParam2)

  /*
  Local oError    := ErrorBlock({|e| cError := e:Description})
  Local cEmMOTOR  :=  ""

  Local cEmp		:= ""
  Local cFil		:= ""

  Private lMsErroAuto := .F.

  If ValType(xParam1) == "A"
    cEmp 		:= xParam1[1]
    cFil 		:= xParam1[2]
  ElseIf ValType(xParam1) == "C"
    cEmp 		:= xParam1
    cFil 		:= xParam2
  Else
    ConOut('## ERROR - NÃO FOI INFORMADO EMPRESA E FILIAL ##')
    ConOut('## ERROR - FIM DO JOB ##')
    //Return
  EndIf

  If Empty(cEmp) .OR.  Empty(cEmp)
    cEmp 		:= "08"
    cFil 		:= "01"
  EndIf
 */


  If Select("SX6") <= 0
    RPCSetEnv("11", "01", NIL, NIL, "COM", NIL, {"SB1","SF2","Z42"})
  EndIf

  DbSelectArea("Z42")
  X31UPDTABLE('Z42')
  X31UPDTABLE('SC5')
  X31UPDTABLE('SC7')


Return
