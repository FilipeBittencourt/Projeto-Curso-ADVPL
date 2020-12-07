#include "rwmake.ch"
#include "topconn.ch"

User Function MT100GE2()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT100GE2 บAutor  ณMicrosiga           บ Data ณ  10/29/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ GRAVAR O NUMERO DO PROCESSO NO SE2 CONTAS A PAGAR          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Local cQuery := ""
Local yStatus := ""

Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

cArqSF3 := Alias()
cIndSF3 := IndexOrd()
cRegSF3 := Recno()

cArqSE2 := Alias()
cIndSE2 := IndexOrd()
cRegSE2 := Recno()

sProcex := SPACE(10)
If Alltrim(sProcex)	= ""
	If cArqSF3 <> ""
		dbSelectArea(cArqSF3)
		dbSetOrder(cIndSF3)
		dbGoTo(cRegSF3)
		RetIndex("SF3")
	EndIf
	
	If cArqSE2 <> ""
		dbSelectArea(cArqSE2)
		dbSetOrder(cIndSE2)
		dbGoTo(cRegSE2)
		RetIndex("SE2")
	EndIf
	
	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)
	
	Return
End if
//Selecionando a despesa prevista.
cQuery := "Select * From " + RETSQLNAME("EET") + " where EET_PEDIDO = '" + sProcex + "' And "
cQuery += "EET_YPRVRL = 'P' And EET_CODINT = '"+ Alltrim(SE2->E2_NATUREZ) + "' "
TCQUERY cQuery ALIAS "cTrab" NEW
cTRAB->(DbGoTop())

//VERIFICANDO SE EXISTE DESPESAS PREVISTAS
If !cTrab->(EOF())
	yStatus := "B"
	DbSelectArea("cTrab")
	DbCloseArea()
Else
	cQuery := ""
	cQuery := "Select * From " + RETSQLNAME("SE2") + " where E2_YPROCEX = '" + sProcex + "' And "
	cQuery += "E2_NATUREZ = '"+ SE2->E2_NATUREZ + "'"
	TCQUERY cQuery ALIAS "cTrabRealizadas" NEW
	
	nValor := SE2->E2_VALOR
	Do While !cTrabRealizadas->(EOF())
		nValor += Round(cTrabRealizadas->E2_VALOR,2)
		cTrabRealizadas->(DbSkip())
	End
	//previsto
	If Round(cTrab->EET_VALORR,2) >= nValor
		yStatus := 'L'
	Else
		yStatus := 'B'
	End if
	DbSelectArea("cTrabRealizadas")
	DbCloseArea()
	DbSelectArea("cTrab")
	DbCloseArea()
End If

DbSelectArea("SE2")
cArqSE2 := Alias()
cIndSE2 := IndexOrd()
cRegSE2 := Recno()
Reclock("SE2", .F.)
SE2->E2_YPROCEX := ALLTRIM(sProcex)
SE2->E2_YSTATUS := yStatus
msUnlock()

If cArqSF3 <> ""
	dbSelectArea(cArqSF3)
	dbSetOrder(cIndSF3)
	dbGoTo(cRegSF3)
	RetIndex("SF3")
EndIf

If cArqSE2 <> ""
	dbSelectArea(cArqSE2)
	dbSetOrder(cIndSE2)
	dbGoTo(cRegSE2)
	RetIndex("SE2")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return
