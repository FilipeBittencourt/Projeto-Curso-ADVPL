#INCLUDE "TOTVS.CH"

User Function FCLA0007; Return()

/*
|-------------------------------------------------------------|
|	Classe:	|	TVldPrd																			      |
|	Autor:	|	Tiago Rossini Coradini - Facile Sistemas					|
|	Data:		|	20/10/14																					|
|-------------------------------------------------------------|
|	Desc.:	|	Classe responsavel pela validacao de produtos		  |
|-------------------------------------------------------------|
| OS:			|	1156-13, 1138-14 - Usuário: Tania de Fatima   		|
|-------------------------------------------------------------|
*/

Class TVldPrd
  
	Data cId // Identificador
	Data cFItem // Nome do Campo Item
	Data cFProd // Nome do campo Produto
	
	Data cItem // Item
	Data cProd // Produto
	Data cGrp // Grupo
	Data cNcm // Ncm
	Data cUM // Unidade de Medida
	Data cCtaCon // Conta Contabil
	Data cCtaRes // Conta Resultado
	Data cCtaResInd // Conta Resultado Industrial
	Data cCtaResAdm // Conta Resultado Administrativo
	
	Data cMsg // Mensagem de bloqueio
		
	Method New(cId)
	Method GetValue(nLine) // Retorna valores
	Method ValidLine(nLine) // Valida linha
	Method ValidField(cMField) // Valida campo
	
EndClass


Method New(cId) CLass TVldPrd

	::cId := Upper(cId)

	If Upper(::cId) == "PEDCOM" // Pedido de Compra
	
		::cFItem := "C7_ITEM"
		::cFProd := "C7_PRODUTO"
		
  EndIf
  
  ::cItem := ""
	::cProd := ""
	::cGrp := ""
	::cNcm := ""
	::cUM := ""
	::cCtaCon := ""
	::cCtaRes := ""
	::cCtaResInd := ""
	::cCtaResAdm := ""
  
  ::cMsg := ""
 	
Return()


Method GetValue(nLine) Class TVldPrd
	
	::cItem := If (!Empty(::cFItem), GDFieldGet(::cFItem, nLine), StrZero(nLine, 4)) 
	::cProd := GDFieldGet(::cFProd, nLine, .T.)
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	If SB1->(DbSeek(xFilial("SB1") + ::cProd))

		::cGrp := SB1->B1_GRUPO
		::cNcm := SB1->B1_POSIPI
		::cUM := SB1->B1_UM
		::cCtaCon := SB1->B1_CONTA
		::cCtaRes := SB1->B1_YCTARES
		::cCtaResInd := SB1->B1_YCTRIND
		::cCtaResAdm := SB1->B1_YCTRADM
		
		::cMsg := "O Item: "+ ::cItem +" - Produto: "+ AllTrim(::cProd) +" se encontra BLOQUEADO."+ Chr(13)+Chr(10) +"Motivo: "
		
	EndIf
	
Return()


Method ValidLine(nLine) Class TVldPrd
Local lRet := .T.

	::GetValue(nLine)	
	  
	If !Empty(::cProd)
	
		// OS: 1156-13 - Usuário: Tania de Fatima
		If ::cGrp >= "400" .And. ::cGrp <= "499"
		
			If SubStr(::cCtaCon, 1, 3) <> "165" .AND. SubStr(::cCtaCon, 1, 3) <> "168"
				
				lRet := .F.
				MsgAlert(::cMsg + "Conta Contábil: "+ AllTrim(::cCtaCon) +" Inválida para o grupo: "+ Alltrim(::cGrp) +", favor verificar o cadastro de produtos.", "Bloqueio de Movimentação")
				
			EndIf
			
		EndIf
								

		// OS: 1138-14 - Usuário: Tania de Fatima
		If Empty(::cNcm) .Or. Len(AllTrim(::cNcm)) <> 8
	
			lRet := .F.
			MsgAlert(::cMsg + "NCM Inválido ou conteúdo do campo diferente de 8 posições, favor veridicar o cadastro de produtos.", "Bloqueio de Movimentação")
											
		ElseIf Empty(::cUM)
			
			lRet := .F.
			MsgAlert(::cMsg + "Unidade de medida Inválida, favor veridicar o cadastro de produtos.", "Bloqueio de Movimentação")
			
		ElseIf Empty(::cCtaCon)
			
			lRet := .F.
			MsgAlert(::cMsg + "Conta Contábil Inválida, favor veridicar o cadastro de produtos.", "Bloqueio de Movimentação")

		ElseIf Empty(::cCtaRes)
			
			lRet := .F.
			MsgAlert(::cMsg + "Conta Resultado Inválida, favor veridicar o cadastro de produtos.", "Bloqueio de Movimentação")

		ElseIf Empty(::cCtaResInd)
			
			lRet := .F.
			MsgAlert(::cMsg + "Conta Resultado Industrial Inválida, favor veridicar o cadastro de produtos.", "Bloqueio de Movimentação")

		ElseIf Empty(::cCtaResAdm)
			
			lRet := .F.
			MsgAlert(::cMsg + "Conta Resultado Administrativo Inválida, favor veridicar o cadastro de produtos.", "Bloqueio de Movimentação")			
		
		EndIf
		
	EndIf
	
Return(lRet)


Method ValidField(cMField) Class TVldPrd
Local lRet := .T. 
Local cField := SubStr(cMField, 4, Len(cMField))
	
	If cField $ ::cFProd
	
		If !::ValidLine(N)
			lRet := .F.	    			
		EndIf
		
	EndIf
		
Return(lRet)