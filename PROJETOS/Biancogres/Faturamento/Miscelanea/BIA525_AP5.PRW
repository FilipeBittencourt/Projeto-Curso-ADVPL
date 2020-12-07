#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA525   ³ Autor ³ Magnago               ³ Data ³ 17/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Bloqueia Cliente se o mesmo tiver titulos em atraso        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExecBlock                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Codigo do Cliente                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION BIA525()

//Tratamento especial para Replcacao de pedido LM
If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
	Return M->C5_CLIENTE
EndIf

Private Enter		:= CHR(13) + CHR(10)
Private wFim		:= .T.
Private wsFim		:= .T.
Private wsCli		:= "" 
Private wsLoja		:= ""
Private wCondPag	:= ""
Private wSubTp		:= ""
Private wTpCred		:= ""
Private cSql		:= ""
Private wsRisco		:= 0
Private wsAtraso	:= 0
Private wTotPed		:= 0
Private wSalDisp	:= 0
Private wVencto		
Private wDataBase	

Private cArq		:= ""
Private cInd		:= 0
Private cReg		:= 0

Private cArqSA1		:= ""
Private cIndSA1		:= 0
Private cRegSA1		:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SA1")
cArqSA1 := Alias()
cIndSA1 := IndexOrd()
cRegSA1 := Recno()

aArea := GetArea()

If !(cEmpAnt $ "01/05/07")
	Return M->C5_CLIENTE
EndIf
If Alltrim(Funname()) == "BIA1001R" .OR. Alltrim(Funname()) == "MATA415" .OR. Alltrim(Funname()) == "REPL_ORCA"  .OR. Alltrim(Funname()) == "RPC" .OR. Alltrim(Funname()) == "MATA416"
	wsCli  		:= M->CJ_CLIENTE
	wsLoja 		:= M->CJ_LOJA 
	wCondPag	:= M->CJ_CONDPAG
	wSubTp		:= "A" //UTILIZADO PARA PEDIDO DE AMOSTRA
	wTpCred		:= "1" //UTILIZADO PARA PEDIDO DE AMOSTRA 
ElseIF ALLTRIM(FUNNAME()) == "EECAP100"
	wsCli  		:= M->EE7_IMPORT
	wsLoja 		:= M->EE7_IMLOJA
	wCondPag	:= "001"
	wSubTp		:= "A"
	wTpCred     := "1"
ELSE
	wsCli  		:= M->C5_CLIENTE
	wsLoja 		:= M->C5_LOJACLI
	wCondPag	:= M->C5_CONDPAG
	wSubTp		:= M->C5_YSUBTP
	wTpCred		:= M->C5_YTPCRED
Endif

While wFim
	//Chama a rotina
	Carga()
	wsFim := .F.
	//U_SIT_FIN(wsCli,wsLoja, .T.) ->
EndDo

If Select("TRB") > 1
	TRB->(DbCloseArea())
EndIf

If Select("_SE1") > 1
	_SE1->(DbCloseArea())
EndIf

If Select("PEDIDO") > 1
	PEDIDO->(DbCloseArea())
EndIf

If Select("_RA") > 1
	_RA->(DbCloseArea())
EndIf

If Select("_PEDFAT") > 1
	_PEDFAT->(DbCloseArea())
EndIf

RestArea(aArea)

Return(wsCLi)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa Verificacao de Credito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Carga()

//Tratamento do Crédito do Cliente, para o novo processo de inclusão de PV
Local lRA 		:= U_fValidaRA(wCondPag)
Local lVldPV	:= .T.
Local lDebug	:= .F.

//If Alltrim(wSubTp) $ "A_B_G_O_C_" .OR. wTpCred <> "0"  //TIPO PEDIDO = (AMOSTRA BONIFICAÇÃO GARANTIA OUTROS CONSIGNADO OS 1674-15) OU TIPO CREDITO DIFERENTE DE 0=NORMAL
//If Alltrim(wSubTp) $ "A_B_G_O_C_M_R2_" .OR. wTpCred <> "0"  //TIPO PEDIDO = INCLUIR TIPO M = MOSTRUARIO OS 3067-15
If Alltrim(wSubTp) $ "A_B_D_G_O_C_M_R2_" .OR. wTpCred <> "0"  //TIPO PEDIDO = INCLUIR TIPO M = MOSTRUARIO OS 3067-15
	lVldPV := .F.
EndIf

If lVldPV	
	If !U_SIT_FIN(wsCLi,wsLoja,.T.)
		MsgBox("Este Cliente possui restrição de crédito e não será possível realizar a inclusão do Pedido de Venda!","BIA525","STOP")
		wsCli := ""
	EndIf
Else
	If Alltrim(wTpCred) $ ("1_2_3_4_5_") //Contrato, Del Crédere ou Termo Resp.
		If wTpCred == "2"
			MsgBox("Para Pedidos de Venda de Contrato, não será feito nálise de crédito na Inclusão do Pedido!","Atenção","ALERT")	
			MsgBox("Para realizar a montagem de Carga, o crédito deverá ser analisado e liberado pelo Setor de Crédito e Cobrança!","Atenção","ALERT")
		ElseIf wTpCred == "3"
			MsgBox("Para Pedidos de Venda de Del Crédere, não será feito análise de crédito na Inclusão do Pedido!","Atenção","ALERT")	
			MsgBox("Para realizar a montagem de Carga, é necessário que o documento assinado com firma reconhecida em cartório, esteja em poder do setor de Crédito para liberação do mesmo!","Atenção","ALERT")
		ElseIf wTpCred == "4"
			MsgBox("Para Pedidos de Venda de Termo Resp., não será feito análise de crédito na Inclusão do Pedido!","Atenção","ALERT")	
			MsgBox("Para realizar a montagem de Carga é necessário que o documento assinado com firma reconhecida em cartório, esteja em poder do setor de Crédito para liberação do mesmo!","Atenção","ALERT")
		ElseIf wTpCred == "5" 
			MsgBox("Para o canal de ENGENHARIA, não será feito análise de crédito durante a inclusão do Pedido!","MTA410","ALERT")	
			MsgBox("Para realizar a montagem de Carga, o crédito deverá ser analisado e liberado pelo Setor de Crédito e Cobrança!","MTA410","ALERT")
		EndIf
	EndIf
EndIf
wFim	:= .F.
wsFim	:= .F.

If cArqSA1 <> ""
	dbSelectArea(cArqSA1)
	dbSetOrder(cIndSA1)
	dbGoTo(cRegSA1)
	RetIndex("SA1")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return
//-----------------------------------------------------------------------------------------------------