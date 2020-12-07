#include "rwmake.ch"  
#Include "TOPCONN.CH"

User Function MSGBRADES()

SetPrvt("WALIAS,WMENSAG,WMENSAG1,WCLIENTE,WLOJA")
SetPrvt("WPREFIXO,WNUM,WRECNO,LPRIM,")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MENSAG   ³ Autor ³ Ranisses A. Corona    ³ Data ³ 21.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CNAB BANCOS - Exclusivo Para o Bradesco                    ³±±
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
        
cTipo    := E1_TIPO
wMensag  := ""
wMensag1 := ""
wCliente := E1_CLIENTE
wLoja    := E1_LOJA
wPrefixo := E1_PREFIXO
wParc	 := E1_PARCELA
wNum     := E1_NUM
wRecno   := Recno()

If Alltrim(cTipo) == "FT"

	//Seleciona os Titulos da Fatura
	cQuery   := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_FATURA "
	cQuery   += " FROM "+RetSqlName("SE1")+" SE1 "
	cQuery   += " WHERE E1_FILIAL 	= '"+xFilial("SE1")+"'	AND "
	cQuery   += " 		E1_FATPREF		= '"+wPrefixo+"' 				AND "
	cQuery   += " 		E1_FATURA			= '"+wNum+"' 						AND "
	//If Alltrim(E1_ORIGEM) == "BIA507"
	If Alltrim(SE1->E1_YCLASSE) == "5"
		cQuery   += "			E1_YPARCFT		= '"+wParc+"' 					AND "
	EndIf
	cQuery   += " 		D_E_L_E_T_		= ''												"
	cQuery   += " ORDER BY E1_NUM, E1_PARCELA										"
	If chkfile("TRB")
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	TCQUERY cQuery ALIAS "TRB" NEW

	While !TRB->(EOF())
		wMensag += Alltrim(TRB->E1_NUM)+Alltrim(TRB->E1_PARCELA)+"-"
		TRB->(DbSkip())
	EndDo

Else

	wMensag  := Alltrim(E1_NUM)+Iif(Empty(Alltrim(E1_PARCELA)),"","/"+E1_PARCELA)

EndIf

wMensag1 := "OS 9 DIAS CORRIDOS-REF.NF: "+Substr(wMensag,1,40)	

DbGoto(wRecno)
DbSelectArea(wAlias)

Return(wMensag1)
