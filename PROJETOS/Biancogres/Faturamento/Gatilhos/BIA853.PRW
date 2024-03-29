#include "protheus.ch"
#include "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA853   � Autor � Ranisses A. Corona    � Data � 11/04/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para exibir informacao de pallet fechado ou nao  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Faturamento (Pedido/Orcamento)                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function BIA853() 
Local nProduto	:= ""
Local nLote		:= ""
Local nQtdM2	:= 0    
Local nQtdM2Ori	:= 0 
Local nQtdCX	:= 0
Local nQtdCXOri	:= 0
Local nQtdPalet	:= 0
Local nDivPA	:= 0        
Local nInteiro	:= 0
Local nDecimal	:= 0
Local lRet		:= .F. 
                    
//Retirado esse gatilho - Fernando/Facile - ja est� fazendo na sugestao de LOTE - avaliar.
Return(M->C6_QTDVEN)

//Tratamento especial para Replcacao de pedido LM 
//Manter se o Return acima for tirado
If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
	Return(M->C6_QTDVEN)
EndIf

If Alltrim(FUNNAME()) $ "MATA410_MATA416"
	nProduto	:= Gdfieldget('C6_PRODUTO',n) 
	nLote		:= Gdfieldget('C6_LOTECTL',n) 	
	nQtdM2		:= Gdfieldget('C6_QTDVEN',n)   
	nQtdM2Ori	:= nQtdM2
Else
	nProduto	:= TMP1->CK_PRODUTO
	nLote		:= TMP1->CK_LOTECTL
	nQtdM2		:= TMP1->CK_QTDVEN
	nQtdM2Ori	:= nQtdM2
EndIf


If Empty(Alltrim(nProduto))
	MsgBox("O produto n�o foi informado. Favor verificar!","BIA853","STOP")
	Return(0)
EndIf

//Busca informa��es do Lote do Produto 
cAliasZZ9 := GetNextAlias()
BeginSql Alias cAliasZZ9
	SELECT ZZ9_DIVPA 
	FROM  %Table:ZZ9%
	WHERE ZZ9_PRODUT = %Exp:nProduto% AND ZZ9_LOTE = %Exp:nLote% AND %NOTDEL%
EndSql

//Busca informa��es do Produto
//B1_YVDFRAC - adicionado para validacao da venda por pallet - projeto reserva de OP - fernando/facile em 10/06/2014
cAliasSB1 := GetNextAlias()
BeginSql Alias cAliasSB1
	SELECT B1_COD, B1_TIPO, B1_TIPCONV, B1_CONV, B1_YDIVPA, B1_YVDFRAC
	FROM  %Table:SB1%
	WHERE B1_COD = %Exp:nProduto% AND %NOTDEL%
EndSql

//Define quantidade na 2�Unidade de Medida
If (cAliasSB1)->B1_TIPCONV == "D"
	nQtdCX		:= (nQtdM2 / (cAliasSB1)->B1_CONV)
	nQtdCXOri	:= nQtdCX
Else
	nQtdCX		:= (nQtdM2 * (cAliasSB1)->B1_CONV)
	nQtdCXOri	:= nQtdCX	
EndIf

//Caso o produto n�o tenha informa��o de PRODUTO/LOTE busca informacao somente do PRODUTO
If !(cAliasZZ9)->(EOF())
	nDivPA := (cAliasZZ9)->ZZ9_DIVPA
Else
	nDivPA := (cAliasSB1)->B1_YDIVPA
EndIf

//Realiza a verifica��o de pallet quebrado
If Alltrim((cAliasSB1)->B1_TIPO) == "PA"

	nQtdPalet	:= nQtdCX / nDivPA
	nInteiro	:= INT(nQtdPalet)
	nDecimal	:= (nQtdPalet - INT(nQtdPalet))

	If nDecimal <> 0 
		//Define as novas quantidades
		nQtdPalet	:= nInteiro + 1
		nQtdCX		:= nQtdPalet * nDivPA
		If (cAliasSB1)->B1_TIPCONV == "D"
			nQtdM2	:= (nQtdCX * (cAliasSB1)->B1_CONV)
		Else
			nQtdM2	:= (nQtdCX / (cAliasSB1)->B1_CONV)
		EndIf
		   
		
		If nQtdM2 <> nQtdM2Ori   
		
			If !((cAliasSB1)->B1_YVDFRAC == "N")
				lRet := MsgBox("A quantidade informada em M2 n�o atende a quantidade de PALLET fechado. Deseja alterar para "+Alltrim(Str(nQtdM2,10,2))+" M2 - "+Alltrim(Str(nQtdCX))+" CX - "+Alltrim(Str(nQtdPalet))+" PALLETS?","BIA853","YesNo")        
			Else
				MsgBox("A quantidade informada em M2 n�o atende a quantidade de PALLET fechado."+CRLF+;
						"Este produto N�O permite venda FRACIONADA."+CRLF+;
						"A quantidade ser� alterar para "+Alltrim(Str(nQtdM2,10,2))+" M2 - "+Alltrim(Str(nQtdCX))+" CX - "+Alltrim(Str(nQtdPalet))+" PALLETS.","BIA853")        
				lRet := .T.
			EndIf
			
			If lRet
	            nQtdM2 := nQtdM2
			Else
	            nQtdM2 := nQtdM2Ori
			EndIf	
		Else
            nQtdM2 := nQtdM2Ori
		EndIf

	EndIf

EndIf  

//Grava pre�o para expositores
If lRet 
   If Alltrim(FUNNAME()) == "MATA410"
	  	Gdfieldput('C6_QTDVEN',nQtdM2,n)
		Gdfieldput('C6_UNSVEN',nQtdCX,n)	   
   Else
   	   TMP1->CK_PRCVEN	:= nQtdM2
   	   TMP1->CK_VALOR	:= ROUND(TMP1->CK_PRCVEN*TMP1->CK_QTDVEN,2)
   EndIf   
EndIf

(cAliasSB1)->(dbCloseArea())
(cAliasZZ9)->(dbCloseArea())

Return(nQtdM2)
