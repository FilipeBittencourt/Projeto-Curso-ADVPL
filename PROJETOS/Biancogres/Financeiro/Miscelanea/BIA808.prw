#include "rwmake.ch"
#include "topconn.ch"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA808     � Autor � Ranisses A. Corona    � Data � 02/03/09 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Busca o Valor da Tarifa Bancaria para ST, de acorod com UF.  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Financeiro                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
If SA1->A1_YTFGNRE == "S"  .And. SE1->E1_YFDCVAL == 0 //Apenas para clientes com cobranca de GNRE
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