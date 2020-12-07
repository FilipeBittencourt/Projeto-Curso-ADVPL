#include "rwmake.ch"
#include "topconn.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA806     ³ Autor ³ Ranisses A. Corona    ³ Data ³ 07/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata uso da Condicao Pagamento conforme Tipo Cliente        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA806()  

//Tratamento especial para Replcacao de pedido LM
If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
	Return(M->C5_CONDPAG)
EndIf

Private wCondPag, wForma, cSql, nEst, nRegEsp := ""
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

wCondPag	:= M->C5_CONDPAG
wTipoCli	:= M->C5_TIPOCLI
nEst		:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EST")
nRegEsp		:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YREGESP")

cSql := "SELECT E4_CODIGO, E4_SOLID, E4_YREP FROM "+RetSqlName("SE4")+" "
cSql += "WHERE	E4_YATIVO = '1' AND "
cSql += "		E4_CODIGO = '"+Alltrim(wCondPag)+"' AND "
cSql += "		D_E_L_E_T_ = '' "
If chkfile("R001")
	dbSelectArea("R001")
	dbCloseArea()
EndIf
TcQuery cSql ALIAS "R001" NEW

nGrupo := Posicione("SB1",1,xFilial("SB1")+Gdfieldget('C6_PRODUTO',1),"B1_GRUPO")

If nGrupo == "PA"
	//If Alltrim(wTipoCli) == "S"	 .And. nEst $ "MG_BA" .And. Alltrim(cempant) $ "01_05_07" .And. Empty(Alltrim(nRegEsp))
	If Alltrim(wTipoCli) == "S"	 .And. nEst $ GetMV("MV_YUFSTCD") .And. Alltrim(cempant) $ "01_05_07_14" .And. Empty(Alltrim(nRegEsp))
		If R001->E4_SOLID <> "S"
			wCondPag := ""
			MsgBox("Favor escolher uma Condição de Pagamento de ST!","BIA806","ALERT")
		EndIf
	Else
		If R001->E4_SOLID == "S"
			wCondPag := ""
			MsgBox("Favor escolher uma Condição de Pagamento diferente de ST!","BIA806","ALERT")
		EndIf
	EndIf
EndIf

//Trata condicao pagamento antecipada para LM
If Alltrim(M->C5_CONDPAG) == "145" .And. Alltrim(M->C5_CLIENTE) <> "010064" .AND. Alltrim(cempant) == "01"
	wCondPag := ""
	MsgBox("A Condição de Pagamento 145 deverá ser utilizada somente para o Cliente 010064 - LM!","BIA806","ALERT")
EndIf

If Alltrim(M->C5_CONDPAG) == "975" .And. Alltrim(M->C5_CLIENTE) <> "010064" .AND. Alltrim(cempant) == "05"
	wCondPag := ""
	MsgBox("A Condição de Pagamento 975 deverá ser utilizada somente para o Cliente 010064 - LM!","BIA806","ALERT")
EndIf

//Bloqueia a Condicao de Pagamento de acordo com a Linha do Pedido
If nGrupo == "PA"
	
	If Alltrim(M->C5_YLINHA) <> "4" .OR. Alltrim(R001->E4_YREP) <> "4" .OR. !cEmpAnt $ ("13_14") //LIBERA TODAS AS CONDICOES PAGAMENTO PARA A EMPRESA MUNDI OU AS CONDICOES PARA AS DUAS EMPRESAS	
		//Biancogres
		If cEmpAnt == "01" .And. Alltrim(M->C5_YLINHA) == "1" .And. Alltrim(R001->E4_YREP) <> "1"
			wCondPag := ""
			MsgBox("Favor verificar a Condição de Pagamento com a Linha do Pedido!","BIA806","ALERT")
	
		//Incesa
		ElseIf cEmpAnt == "05" .And. Alltrim(M->C5_YLINHA) $ "2/3" .And. Alltrim(R001->E4_YREP) == "1"
			wCondPag := ""
			MsgBox("Favor verificar a Condição de Pagamento com a Linha do Pedido!","BIA806","ALERT")
	
		//LM - Biancogres	
		ElseIf cEmpAnt == "07" .And. Alltrim(M->C5_YLINHA) == "1" .And. Alltrim(R001->E4_YREP) <> "1"
			wCondPag := ""
			MsgBox("Favor verificar a Condição de Pagamento com a Linha do Pedido!","BIA806","ALERT")
	
		//LM - Incesa/Bellacasa/Mundi
		ElseIf cEmpAnt == "07" .And. Alltrim(M->C5_YLINHA) $ "2/3/4" .And. Alltrim(R001->E4_YREP) == "1"
			wCondPag := ""
			MsgBox("Favor verificar a Condição de Pagamento com a Linha do Pedido!","BIA806","ALERT")
		
		//LM - Pegasus
		ElseIf cEmpAnt == "07" .And. Alltrim(M->C5_YLINHA) $ "5" .And. !(Alltrim(R001->E4_YREP) $ "1_5") 
			wCondPag := ""
			MsgBox("Favor verificar a Condição de Pagamento com a Linha do Pedido!","BIA806","ALERT")
		
		//LM - VINILICO
		ElseIf cEmpAnt == "07" .And. Alltrim(M->C5_YLINHA) $ "6" .And. !(Alltrim(R001->E4_YREP) $ "1") 
			wCondPag := ""
			MsgBox("Favor verificar a Condição de Pagamento com a Linha do Pedido!","BIA806","ALERT")
			
		EndIf
	EndIf

    /*
	If Alltrim(M->C5_YLINHA) <> "4" .OR. Alltrim(R001->E4_YREP) == "4" //LIBERA TODAS AS CONDICOES PAGAMENTO PARA A EMPRESA MUNDI OU AS CONDICOES PARA AS DUAS EMPRESAS
		If Alltrim(M->C5_YLINHA) == "2" .And. Alltrim(R001->E4_YREP) == "1"
			wCondPag := ""
			MsgBox("Favor verificar a Condição de Pagamento com a Linha do Pedido!","BIA806","ALERT")
		ElseIf Alltrim(M->C5_YLINHA) <> "2" .And. Alltrim(M->C5_YLINHA) <> Alltrim(R001->E4_YREP)
			wCondPag := ""
			MsgBox("Favor verificar a Condição de Pagamento com a Linha do Pedido!","BIA806","ALERT")
		EndIf
	EndIf
	*/

EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(wCondPag)
