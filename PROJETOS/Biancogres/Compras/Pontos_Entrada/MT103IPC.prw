#include "rwmake.ch" 
User Function MT103IPC()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT103IPC ³ Autor ³ Gustav koblinger Jr   ³ Data ³ 10/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao dos itens do Pedido de Compras                  ³±±
±±³          ³ Na Nota de Entrada no Momento de importacao dos itens do   ³±±
±±³          ³ Pedido de Compras (SC7).                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Compras/Estoque                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Private wn		:= ParamIxb[1]	// Numero do item do acols paramixb[1]
Private	aArea	:= GetArea()	// Posicionamento

Gdfieldput('D1_LOTECTL',SC7->C7_LOTECTL,wn)
//nPos	   := AScan(aHeader, { |x| Alltrim(x[2]) == 'D1_LOTECTL'})
//aCols[wn,nPos] := SC7->C7_LOTECTL

Gdfieldput('D1_YTAG',SC7->C7_YTAG,wn)
//nPos	   := AScan(aHeader, { |x| Alltrim(x[2]) == 'D1_YTAG'})
//aCols[wn,nPos] := SC7->C7_YTAG

Gdfieldput('D1_YAPLIC',SC7->C7_YAPLIC,wn)
//nPos	   := AScan(aHeader, { |x| Alltrim(x[2]) == 'D1_YAPLIC'})
//aCols[wn,nPos] := SC7->C7_YAPLIC

Gdfieldput('D1_YSI',SC7->C7_YSI,wn)
//nPos	   := AScan(aHeader, { |x| Alltrim(x[2]) == 'D1_YSI'})
//aCols[wn,nPos] := SC7->C7_YSI

Gdfieldput('D1_YCONTR',SC7->C7_YCONTR, wn)
Gdfieldput('D1_CLVL',SC7->C7_CLVL, wn)
Gdfieldput('D1_ITEMCTA',SC7->C7_ITEMCTA, wn)
Gdfieldput('D1_YSUBITE',SC7->C7_YSUBITE, wn)

//If !Empty(aCols[wn,nPos])
If !Empty(Gdfieldget('D1_CLVL',wn))

	Gdfieldput('D1_YDRIVER',SC7->C7_YDRIVER,wn)

	//Posiciona no Cadastro Produto
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+Gdfieldget('D1_COD',wn),.T.)

	If Alltrim(SB1->B1_TIPO) == "MD"
			If SUBS(Gdfieldget('D1_CLVL',wn),1,1)=="3"
				Gdfieldput('D1_CONTA',SB1->B1_YCTRIND,wn)
			Else
				Gdfieldput('D1_CONTA',SB1->B1_YCTRADM,wn)
			EndIf
	Else	
		Gdfieldput('D1_CONTA',SB1->B1_CONTA,wn)
	EndIf
Else
	Gdfieldput('D1_CONTA',SB1->B1_CONTA,wn)
EndIf	

//Volta Posicionamento
RestArea(aArea)

Return