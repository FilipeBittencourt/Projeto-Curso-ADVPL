#include "rwmake.ch"
#include "topconn.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA801     ³ Autor ³ Ranisses A. Corona    ³ Data ³ 09/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava o campo C5_YFORMA conforme Condicao Pagto.	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Faturamento                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                           	

User Function BIA801()
Local aArea	:= GetArea()

//Tratamento especial para Replcacao de pedido LM
If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02") 
	Return(M->C5_YFORMA)
EndIf

Private wCondPag := "" 
Private wForma	:= ""
Private wLinha	:= ""
Private cSql 	:= ""
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0
Private lRet	:= .F.

If ALLTRIM(FUNNAME()) == "MATA410" .Or. ALLTRIM(FUNNAME()) == "MATA416"
	wCondPag	:= M->C5_CONDPAG
	wCliente	:= M->C5_CLIENTE
	wLoja		:= M->C5_LOJACLI
	wLinha		:= M->C5_YLINHA
Else
	wCondPag	:= M->CJ_CONDPAG
	wCliente	:= M->CJ_CLIENTE
	wLoja		:= M->CJ_LOJA
	wLinha		:= M->CJ_YLINHA
EndIf

//Posiciona no Cliente (ja deve estar posicionado)
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+wCliente+wLoja))

//Definindo a Forma de Pagamento
If U_fValidaRA(wCondPag) 
	//OP e RA
	wForma := "3"
Else
	//Forma de Pagamento do Cliente
	wForma := SA1->A1_YFORMA
EndIf

//Para Pedidos "Devolucao" ou "Utiliza Fornecedor" lanca OP
If ALLTRIM(FUNNAME()) == "MATA410"
	If Alltrim(M->C5_TIPO) $ "D_B"
		wForma := "3" //OP
	EndIf
EndIf

//Verifica se e um Pedido de Contrato
If Alltrim(wCondPag) $ "142_972_A76" //Estas condicoes sao utilizadas nos pedidos de contratos
	lRet := MsgBox("Deseja alterar a Forma de Pagamento para Contrato - CT? ","Atencao","YesNo")
	If lRet
		wForma := "4"
	EndIf
EndIf

//TRATAMENTO PARA O CAMPO TIPO DE CREDITO - EM 30/09/15 RANISSES
//Se for Pedido de Contrato, atualiza o campo Tipo de Credito
If wForma == "4"
	M->C5_YTPCRED := "2" //Contrato
EndIf

//Se o Cliente for de Engenharia, altera o Tipo de Credito
If !Alltrim(M->C5_YSUBTP) $ "A_B_G_O_C_M_" .And. Alltrim(SA1->A1_YTPSEG) == "E" .And. Alltrim(wForma) <> "4"
	M->C5_YTPCRED := "5" //Eng.
EndIf

RestArea(aArea)

Return(wForma)
