#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA484()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA484     ³ Autor ³ WANISAY               ³ Data ³ 25/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gatilho CK_ENTREG                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BIANCOGRES                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                         
PRIVATE nPosEnt  := Ascan(aHeader,{|x| x[2] == "CK_ENTREG "})
PRIVATE dDataEnt := M->CK_ENTREG
//PRIVATE dDataEnt := aCols[n,nPosEnt]

//Valida a data de emissao e data de entrega do pedido
IF INCLUI
	IF M->CJ_EMISSAO < dDatabase
		Alert("A Data de Emissao do pedido não pode ser menor do que a data base do sistema!")
		dDataEnt := CTOD("  /  /  ")
	ENDIF
	IF TMP1->CK_ENTREG < dDatabase
		Alert("A Data de Entrega do item pedido não pode ser menor do que a Data de Emissao do pedido!")
		dDataEnt := CTOD("  /  /  ")
	ENDIF
ENDIF

IF TMP1->CK_ENTREG < M->CJ_EMISSAO
	Alert("A Data de Entrega do item pedido não pode ser menor do que a Data de Emissao do pedido!")
	dDataEnt := CTOD("  /  /  ")
ENDIF


If Alltrim(Funname()) <> "RPC"
	If !Empty(TMP1->CK_ENTREG)
		TMP1->CK_OBS := "DT. ENTREGA USUARIO"
	Else
		TMP1->CK_OBS := ""
	EndIf
EndIf

Return(dDataEnt)