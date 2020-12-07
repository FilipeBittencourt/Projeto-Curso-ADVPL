#include "rwmake.ch"       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ BIA342   ³ Autor ³ Magnago               ³ Data ³ 09/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Bloqueia a Liberacao dos Pedidos de Vendas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDMAKE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA342()     

Private wBlq	:= Gdfieldget("C6_BLQ",n)
Private _wsQtd	:= Gdfieldget("C6_QTDLIB",n)

Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

Private cArqSC5	:= ""
Private cIndSC5	:= 0
Private cRegSC5	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SC5")
cArqSC5 := Alias()
cIndSC5 := IndexOrd()
cRegSC5 := Recno()

//For xxn := 1 to Len(aHeader)
//	xcCampo := Trim(aHeader[xxn][2])
//	If xcCampo == "C6_BLQ"
//		wBlq := aCols[n][xxn]
//	Endif
//	If xcCampo == "C6_QTDLIB"
//		_wsQtd := aCols[n][xxn]
//	Endif
//Next

If AllTrim(wBlq) == "S"
	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5")+SC6->C6_NUM,.F.)
	While !Eof() .And. SC6->C6_FILIAL+SC6->C6_NUM == SC5->C5_FILIAL+SC5->C5_NUM

		While ! Reclock("SC5",.F.) ; End
		SC5->C5_LIBEROK := "S"
		DbUnlock()
		DbSkip()

	EndDo
	_wsQtd := 0
	DbSkip(-1)
	MsgAlert("Este Pedido tem que ser Liberado por "+SC5->C5_YAAPROV)
EndIf

If cArqSC5 <> ""
	dbSelectArea(cArqSC5)
	dbSetOrder(cIndSC5)
	dbGoTo(cRegSC5)
	RetIndex("SC5")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(_wsQtd)