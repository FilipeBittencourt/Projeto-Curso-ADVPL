#INCLUDE "TOTVS.CH"

/*
|-------------------------------------------------------------|
|	Função:	|	MT120SCR  																			  |
|	Autor:	|	Tiago Rossini Coradini - Facile Sistemas					|
|	Data:		|	20/10/14																					|
|-------------------------------------------------------------|
|	Desc.:	|	Ponto de entrada dentro da rotina que monta a 		|
|					|	dialog do pedido de compras, logo apos a montagem |
|					|	dos folders, disponibiliza como parametro o  	    |
|					|	objeto da dialog 'odlg' para manipulacao do       |
|					|	usuario        															      |
|-------------------------------------------------------------|
| OS:			|	1156-13, 1138-14 - Usuário: Tania de Fatima   		|
|-------------------------------------------------------------|
*/

Static o_oDlg	:=	Nil

User Function MT120SCR()

	o_oDlg	:=	Nil

	If IsInCallStack("MATA094")
		o_oDlg	:=	PARAMIXB
	EndIf

	If Inclui .Or. Altera
		fAddValid(ParamIxb)
	EndIf

Return Nil


// Adiciona validações ao objeto GetDados do Pedido de Compra
Static Function fAddValid(oDlg)
Local nCount := 0
		
	For nCount := 1 To Len(oDlg:aControls)
		
		If oDlg:aControls[nCount]:ClassName() == "MSBRGETDBASE"
			
			fAddFieldOK(@oDlg:aControls[nCount]:oMother:cFieldOk)

			/*
			If Altera .And. !IsInCallStack("A120COPIA")
				fAddDelOK(@oDlg:aControls[nCount]:oMother:cDelOK)
				fAddWhen(@oDlg:aControls[nCount]:oMother)
			EndIf
			*/
			
		EndIf
		
	Next

Return()


// Adiciona validação dos campos
Static Function fAddFieldOK(cFieldOK)
Local cAnd := " .And. "
Local cFunc := "U_VLDFPEDCOM()"	
	cFieldOK := If (!Empty(cFieldOK), cFieldOK + cAnd + cFunc, cFunc)
Return()


// Adiciona validação de deleção de linha
Static Function fAddDelOK(cDelOK)
Local cAnd := " .And. "
Local cFunc := "U_VLDDLPEDCOM()"	
	cDelOK := If (!Empty(cDelOK), cDelOK + cAnd + cFunc, cFunc)
Return()


// Adiciona validação de modo de edição
Static Function fAddWhen(oGetPC)
Local cAnd := " .And. "
Local cFunc := "U_VLDWPEDCOM()"
Local nCount := 0

	For nCount := 1 To Len(oGetPC:aInfo)
		If oGetPC:aInfo[nCount,5] <> "V"
			oGetPC:aInfo[nCount,4] := If (!Empty(oGetPC:aInfo[nCount,4]), oGetPC:aInfo[nCount,4] + cAnd + cFunc, cFunc)		
		EndIf
	Next

Return()

User Function M120SCGD()

	o_oDlg:End()

Return 

