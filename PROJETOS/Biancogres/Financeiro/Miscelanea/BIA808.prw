#include "rwmake.ch"
#include "topconn.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA808     ³ Autor ³ Ranisses A. Corona    ³ Data ³ 02/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca o Valor da Tarifa Bancaria para ST, de acorod com UF.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Financeiro                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA808()
Local nTarifa	:= 0

Private nRet	:= Strzero(SE1->E1_SALDO*100,13)
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0
 

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

//Apenas titulos de ST
If SA1->A1_YTFGNRE == "S" //Apenas para clientes com cobranca de GNRE
	If SE1->E1_YCLASSE == "1" 
		
		oTafNFRE	:= TAFTarifaGNRE():New()
		nTarifa 	:= oTafNFRE:TarifaPorEstado(SE1->E1_YUFCLI)
		nRet		:= Strzero((SE1->E1_SALDO + nTarifa) * 100 , 13)
				
				
		/*
		If Alltrim(SE1->E1_YUFCLI) == "MG"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLMG"))*100,13)
		ElseIf Alltrim(SE1->E1_YUFCLI) == "ES"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLES"))*100,13)
		ElseIf Alltrim(SE1->E1_YUFCLI) == "SP"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLSP"))*100,13)
		ElseIf Alltrim(SE1->E1_YUFCLI) == "BA"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLBA"))*100,13)
		ElseIf Alltrim(SE1->E1_YUFCLI) == "RJ"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLRJ"))*100,13)
		ElseIf Alltrim(SE1->E1_YUFCLI) == "AL"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLAL"))*100,13)
		ElseIf Alltrim(SE1->E1_YUFCLI) == "RS"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLRS"))*100,13)
		ElseIf Alltrim(SE1->E1_YUFCLI) == "SC"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLSC"))*100,13)
		ElseIf Alltrim(SE1->E1_YUFCLI) == "PR"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLPR"))*100,13)
		ElseIf Alltrim(SE1->E1_YUFCLI) == "AP"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLAP"))*100,13)
		ElseIf Alltrim(SE1->E1_YUFCLI) == "PE"
			nRet	:= Strzero((SE1->E1_SALDO+GetMv("MV_YVLBLPE"))*100,13)
		Else
			nRet	:= 0
		EndIf
		
		*/
		
	EndIf
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(nRet)