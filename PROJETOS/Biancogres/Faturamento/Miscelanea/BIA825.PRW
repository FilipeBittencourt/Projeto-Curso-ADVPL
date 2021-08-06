#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ BIA825		  ºAutor  ³ Ranisses A. Corona º DATA ³  10/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ Grava Vendedor/Comissao no Pedido de Venda       				º±±
±±º          ³ ExecBlock("BIA825",.F.,.F.,"V1")						       		º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ Faturamento                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA825()
	Local wOpcao	:= Paramixb
	/*Opcoes
	V1 - Vendedor 1
	V2 - Vendedor 2
	V3 - Vendedor 2
	C1 - Comissao 1
	C2 - Comissao 2
	C3 - Comissao 3 */
	Local wRet		:= ""  

	//Tratamento especial para Replcacao de pedido LM
	If !Alltrim(M->C5_TIPOCLI) == "X" //Somente para pedidos Mercado Interno
		If Alltrim(M->C5_YLINHA) == "1" //BIANCOGRES
			Do Case
				Case wOpcao == "V1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_VEND")
				Case wOpcao == "V2"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENDB2")
				Case wOpcao == "V3"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENDB3")
				Case wOpcao == "C1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_COMIS")
				Case wOpcao == "C2"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMB2")
				Case wOpcao == "C3"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMB3")
			EndCase
		ElseIf Alltrim(M->C5_YLINHA) == "2" //INCESA
			Do Case
				Case wOpcao == "V1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENDI")
				Case wOpcao == "V2"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENDI2")
				Case wOpcao == "V3"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENDI3")
				Case wOpcao == "C1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMISI")
				Case wOpcao == "C2"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMI2")
				Case wOpcao == "C3"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMI3")
			EndCase
		ElseIf Alltrim(M->C5_YLINHA) == "3" //BELLACASA
			Do Case
				Case wOpcao == "V1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENBE1")
				Case wOpcao == "V2"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENBE2")
				Case wOpcao == "V3"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENBE3")
				Case wOpcao == "C1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMBE1")
				Case wOpcao == "C2"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMBE2")
				Case wOpcao == "C3"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMBE3")
			EndCase
		ElseIf Alltrim(M->C5_YLINHA) == "4" //MUNDIALLI
			Do Case
				Case wOpcao == "V1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENML1")
				Case wOpcao == "V2"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENML2")
				Case wOpcao == "V3"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENML3")
				Case wOpcao == "C1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMML1")
				Case wOpcao == "C2"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMML2")
				Case wOpcao == "C3"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMML3")
			EndCase
		ElseIf Alltrim(M->C5_YLINHA) == "5" //Pegasus
			Do Case
				Case wOpcao == "V1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENPEG")
				Case wOpcao == "V2"
				wRet := ""
				Case wOpcao == "V3"
				wRet := ""
				Case wOpcao == "C1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMPEG")
				Case wOpcao == "C2"
				wRet := 0
				Case wOpcao == "C3"
				wRet := 0
			EndCase
		ElseIf Alltrim(M->C5_YLINHA) == "6" //VINILICO
			Do Case
				Case wOpcao == "V1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YVENVI1")
				Case wOpcao == "V2"
				wRet := ""
				Case wOpcao == "V3"
				wRet := ""
				Case wOpcao == "C1"
				wRet := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YCOMVI1")
				Case wOpcao == "C2"
				wRet := 0
				Case wOpcao == "C3"
				wRet := 0
			EndCase	
			
		EndIf

	Else
		Do Case
			Case wOpcao == "C1"
			wRet := M->C5_COMIS1
			Case wOpcao == "C2"
			wRet := M->C5_COMIS2
			Case wOpcao == "C3"
			wRet := M->C5_COMIS3
		EndCase
	EndIf

	//Nao permite % Comissao MAIOR que o cadastrado no Cliente
	Do Case
		Case Alltrim(__READVAR) == 'M->C5_COMIS1'
		If M->C5_COMIS1 > wRet
			Return(wRet)
		Else
			Return(M->C5_COMIS1)
		EndIf
		Case Alltrim(__READVAR) == 'M->C5_COMIS2'
		If M->C5_COMIS2 > wRet
			Return(wRet)
		Else
			Return(M->C5_COMIS2)
		EndIf
		Case Alltrim(__READVAR) == 'M->C5_COMIS3'
		If M->C5_COMIS3 > wRet
			Return(wRet)
		Else
			Return(M->C5_COMIS3)
		EndIf
	EndCase

Return(wRet)
