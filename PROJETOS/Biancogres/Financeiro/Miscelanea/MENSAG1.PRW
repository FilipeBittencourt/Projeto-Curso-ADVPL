#include "rwmake.ch"
#Include "TOPCONN.CH"

User Function MENSAG1() 

SetPrvt("WALIAS,WMENSAG,WMENSAG1,WCLIENTE,WLOJA")
SetPrvt("WPREFIXO,WNUM,WRECNO,LPRIM,")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MENSAG   ³ Autor ³ Ranisses A. Corona    ³ Data ³ 21.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CNAB BANCOS                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Biancogres Ceramica                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Relaciona o intervalo de titulos a serem enviados para       ³
//³ impressao no boleto bancario                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wAlias := Alias()
DbSelectArea("SE1")

wMensag  := ""
wMensag1 := ""
cTipo    := E1_TIPO
wCliente := E1_CLIENTE
wLoja    := E1_LOJA
wPrefixo := E1_PREFIXO
wNum     := E1_NUM
wParc    := E1_PARCELA
wRecno   := Recno()

If Alltrim(cTipo) == "FT"
	//Seleciona os Titulos da Fatura
	cQuery   := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_FATURA "
	cQuery   += " FROM "+RetSqlName("SE1")+" SE1 "
	cQuery   += " WHERE E1_FILIAL		= '"+xFilial("SE1")+"' AND "
	cQuery   += " 			E1_FATPREF	= '"+wPrefixo+"'	AND "
	cQuery   += " 			E1_FATURA		= '"+wNum+"' 			AND "
	cQuery   += "				E1_YPARCFT	= '"+wParc+"' 		AND "
	cQuery   += " 			D_E_L_E_T_	= ''									"
	cQuery   += " ORDER BY E1_NUM, E1_PARCELA							"
	If chkfile("TRB")
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	TCQUERY cQuery ALIAS "TRB" NEW
	
	While !TRB->(EOF())
		wMensag := wMensag + " "+ALLTRIM(TRB->E1_NUM)+"/"+TRB->E1_PARCELA
		TRB->(DbSkip())
	EndDo
	
	If Len(Alltrim(wMensag)) > 0
		wMensag1 := "FATURA REF NF/PARCELA:"+Substr(wMensag,1,97)
	Else
		wMensag1 := ""
	EndIf
EndIf

	
DbGoto(wRecno)
DbSelectArea(wAlias)

Return(wMensag1)