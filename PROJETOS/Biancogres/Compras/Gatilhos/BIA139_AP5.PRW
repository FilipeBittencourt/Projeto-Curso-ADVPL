#include "rwmake.ch"

User Function BIA139()

SetPrvt("XXN,XCCAMPO,WPROD,WCLVL,")

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ BIA139	  ³ Autor ³ MICROSIGA VITORIA 	  ³ Data ³ 11/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obriga a digitacao do Classe de Valor   Solicitacao/Pedido 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Interpretador x Base 										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Private nPosProd, nPosCLVL

nPosProd := Ascan(aHeader,{|x| x[2] == "D1_COD    "})
nPosCLVL := Ascan(aHeader,{|x| x[2] == "D1_CLVL   "})

wProd := aCols[n,nPosProd]
wCLVL := aCols[n,nPosCLVL]

If Len(Alltrim(wProd)) == 7 .and. Subs(wProd,4,4) == "0000" .and. Len(Alltrim(wCLVL)) == 0
	MsgStop("Para este Produto e obrigatorio a Classe de Valor...")
	wCLVL := ""
EndIf

Return(wCLVL)
