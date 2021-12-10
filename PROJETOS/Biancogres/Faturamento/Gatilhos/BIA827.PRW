#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ BIA827		  ºAutor  ³ Ranisses A. Corona º DATA ³  15/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ Define a tabela de Preco padrao para o Pedido de Venda			º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ Faturamento                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA827()
Local wRet 		:= ""
Local wLinha	:= ""
Local cUF		:= ""

//Tratamento especial para Replcacao de pedido LM
If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC")
	wLinha	:= Alltrim(M->C5_YLINHA)
	If wLinha == "1"			//BIANCOGRES
		wRet := Tabela("ZF","1E")
	ElseIf wLinha == "2"		//INCESA
		wRet := Tabela("ZF","2E")
	ElseIf wLinha == "3"		//BELLACASA
		wRet := Tabela("ZF","3E")
	ElseIf wLinha == "4"		//MUNDI
		wRet := Tabela("ZF","4E")
	ElseIf wLinha == "5"		//PEGASUS
		wRet := Tabela("ZF","5E")
	ElseIf wLinha == "6"		//VINILICO
		wRet := Tabela("ZF","6E")
	EndIf

	//Tabela Preço Filal LM SP
	If Alltrim(wLinha) == "6" .And. cEmpAnt == '07' .And. cFilAnt == '05' 
		
		wRet := Tabela("ZF","V03")
			
	ElseIf Alltrim(M->C5_YLINHA) == "6" .And. cEmpAnt == '13' //tabela de replicação
		
		wRet := Tabela("ZF","VRP")
		
	EndIf

	Return(wRet)
EndIf
              
If AllTrim(FunName()) $ "BFATTE01###BIA229"  //Obras e Prosposta Comercial Engenharia - Fernando em 03/03/2016
	wLinha	:= Alltrim(M->Z68_LINHA)
ElseIf Funname() == "MATA415"					//Orcamento
	wLinha	:= Alltrim(M->CJ_YLINHA)
ElseIf Funname() == "RPC"
	wLinha	:= Alltrim(M->CJ_YLINHA)
Else 											//Pedido de Venda
	wLinha	:= Alltrim(M->C5_YLINHA)
EndIf

If wLinha == "1"			//BIANCOGRES
	wRet := Tabela("ZF","1E")
ElseIf wLinha == "2"		//INCESA
	wRet := Tabela("ZF","2E")
ElseIf wLinha == "3"		//BELLACASA
	wRet := Tabela("ZF","3E")
ElseIf wLinha == "4"		//MUNDI
	wRet := Tabela("ZF","4E")
ElseIf wLinha == "5"		//PEGASUS
	wRet := Tabela("ZF","5E")
ElseIf wLinha == "6"		//VINILICO
	wRet := Tabela("ZF","6E")	
EndIf

//Tabela Preço Filal LM SP
If Alltrim(wLinha) == "6" .And. cEmpAnt == '07' .And. cFilAnt == '05'
	
		wRet := Tabela("ZF","V03")
		
ElseIf Alltrim(M->C5_YLINHA) == "6" .And. cEmpAnt == '13' //tabela de replicação
	
	wRet := Tabela("ZF","VRP")
	
EndIf

Return(wRet)	
