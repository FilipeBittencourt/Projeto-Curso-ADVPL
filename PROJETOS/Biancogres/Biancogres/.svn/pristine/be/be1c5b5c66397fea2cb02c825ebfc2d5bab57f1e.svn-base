#include "rwmake.ch"        

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA917     ³ Autor ³ RANISSES A. CORONA    ³ Data ³ 24/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Determina que nao pode ter quantidade quebrada no Contr.Reser³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador x Base                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Por Marcos Alberto Soprani em 25/05/12 para atender a integração com o programa BIA292 quando executado via Schedule
If Type("_ExcAut292") <> "U"
	Return(M->D3_QUANT)
EndIf

// Incluida regra por Marcos Alberto em 24/08/11 para atender o apontamento automático de Esmalte
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa funcao padrao de processamento.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fim do Programa Principal                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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