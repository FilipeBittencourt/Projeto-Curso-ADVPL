#include "rwmake.ch"        

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA917     � Autor � RANISSES A. CORONA    � Data � 24/09/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Determina que nao pode ter quantidade quebrada no Contr.Reser潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador x Base                                         潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

User Function BIA917()  
Local oModelAux := FWModelActive()
Local oViewAux 	:= FWViewActive()
Local oModelGrid
Local oViewGrid

//TRATA MVC NA TELA DE RESERVA
Local lMVC 		:= .F.
If Upper(Alltrim(FunName())) == "MATA430" 
	lMVC := U_BIAChkMVC()
EndIf

If lMVC //oModelAux != NIL
	oModelGrid := oModelAux:GetModel('SC0GRID')
EndIf

If lMVC //oViewAux != NIL
	oViewGrid := oViewAux:GetViewStruct('VIEW_GRD')
EndIf

SetPrvt("WALIAS,WNPRODUTO,WNQTDVEN,WNQTDORIG,WNUNSVEN,WXINTEIRO")
SetPrvt("WXDECIMAL,WOPCAO,WNUM,YYN,XXN,XCCAMPO")
SetPrvt("ACOLS,")

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Inicializa variaveis...                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

//Por Marcos Alberto Soprani em 25/05/12 para atender a integra玢o com o programa BIA292 quando executado via Schedule
If Type("_ExcAut292") <> "U"
	Return(M->D3_QUANT)
EndIf

// Incluida regra por Marcos Alberto em 24/08/11 para atender o apontamento autom醫ico de Esmalte
If Upper(Alltrim(funname())) $ "BIA257/BIA271/BIA292/BIA294/BIA701/BIA742/BIA785/BIA570" .Or. IsInCallsTack("U_BIAFG120")
	Return(M->D3_QUANT)
EndIf

wAlias   := Alias()
wnProduto:= ""      // Produto
wnQtdven := 0       // Retorno da Qtde Vendida
wnQtdOrig:= 0       // Qtde Orignal
wnUnsven := 0       // Qtde na Segunda Unidade de Medida
wxInteiro:= 0       // Total Interio
wxDecimal:= 0       // Total Decimal
yyn 	 := n

If lMVC //oModelAux != NIL
	wnProduto 	:= oModelAux:GetValue( 'SC0GRID', 'C0_PRODUTO' 	)
	wnQtdven 	:= oModelAux:GetValue( 'SC0GRID', 'C0_QUANT' 	)
	wnQtdOrig 	:= oModelAux:GetValue( 'SC0GRID', 'C0_QUANT' 	)
Else	
	wnProduto	:= Gdfieldget("C0_PRODUTO",yyn)
	wnQtdven	:= Gdfieldget("C0_QUANT"  ,yyn)
	wnQtdOrig	:= Gdfieldget("C0_QUANT"  ,yyn)
EndIf

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+wnProduto,.T.)

If AllTrim(wnProduto) <> "0000C500" .And. AllTrim(wnProduto) <> "0000C700" .And. AllTrim(wnProduto) <> "0000C800"
	
	If SB1->B1_TIPCONV == "D"
		wnUnsven:= (wnQtdven / SB1->B1_CONV)
	Else
		wnUnsven:= (wnQtdven * SB1->B1_CONV)
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Executa funcao padrao de processamento.                              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If SB1->B1_TIPO == "PA"
		wxInteiro := INT(wnUnsven)
		wxDecimal := (wnUnsven - INT(wnUnsven))
		
		If wxDecimal != 0
			//wnQtdven	:= Gdfieldget("C0_QUANT"  ,yyn)
		//Else
			wnUnsven := wxInteiro + 1			
			If SB1->B1_TIPCONV == "D"
				wnQtdven := (wnUnsven * SB1->B1_CONV)
			Else
				wnQtdven := (wnUnsven / SB1->B1_CONV)
			EndIf
		EndIf
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Fim do Programa Principal                                            �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If wnQtdven <> wnQtdOrig
		MsgAlert("Quantidade Original na 1a. Unidade: "+str(wnQtdOrig,10,2)+", alterada para "+str(wnQtdven,10,2),"BIA917")
	EndIf

	If lMVC //oModelGrid != NIL
	 	oModelGrid:SetValue("C0_QUANT",wnQtdven)
	 	oModelGrid:SetValue("C0_QTDORIG",wnQtdven)
	 	
	 	If lMVC //oViewAux != NIL
			oViewAux:Refresh('VIEW_GRD')
		EndIf
		
	Else
		Gdfieldput("C0_QUANT"  ,wnQtdven,yyn)
		Gdfieldput("C0_QTDORIG",wnQtdven,yyn)
	EndIf

EndIf

Return(wnQtdven)