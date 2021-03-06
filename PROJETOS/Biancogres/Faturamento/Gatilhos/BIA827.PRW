#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���PROGRAMA  � BIA827		  �Autor  � Ranisses A. Corona � DATA �  15/09/10   ���
�������������������������������������������������������������������������������͹��
���DESC.     � Define a tabela de Preco padrao para o Pedido de Venda			���
�������������������������������������������������������������������������������͹��
���USO       � Faturamento                                                      ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
User Function BIA827()
Local wRet 		:= ""
Local wLinha	:= ""

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
	//ElseIf wLinha == "6"		//VINILICO
	//	wRet := Tabela("ZF","6E")
	EndIf
	Return(wRet)
EndIf
              
If AllTrim(FunName()) $ "BFATTE01###BIA229"  //Obras e Prosposta Comercial Engenharia - Fernando em 03/03/2016
	wLinha	:= Alltrim(M->Z68_LINHA)
ElseIf Funname() == "MATA415"						//Orcamento
	wLinha	:= Alltrim(M->CJ_YLINHA)
ElseIf Funname() == "RPC"
	wLinha	:= Alltrim(M->CJ_YLINHA)
Else 											//Pedido de Venda
	wLinha	:= Alltrim(M->C5_YLINHA)
EndIf

If wLinha == "1"				//BIANCOGRES
	wRet := Tabela("ZF","1E")
ElseIf wLinha == "2"		//INCESA
	wRet := Tabela("ZF","2E")
ElseIf wLinha == "3"		//BELLACASA
	wRet := Tabela("ZF","3E")
ElseIf wLinha == "4"		//MUNDI
	wRet := Tabela("ZF","4E")
ElseIf wLinha == "5"		//PEGASUS
	wRet := Tabela("ZF","5E")
//ElseIf wLinha == "6"		//VINILICO
//	wRet := Tabela("ZF","6E")	
EndIf

// Implementado por Marcos Alberto Soprani em 26/01/2015 para resolver problema de pedido de retorno de remessa
If cEmpAnt == "14"
	If Alltrim(M->C5_YSUBTP) $ "RR/RQ"
		wRet := "002"
	EndIf
EndIf

Return(wRet)
	