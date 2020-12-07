#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF052
@author Tiago Rossini Coradini
@since 01/11/2016
@version 1.0
@description Rotina para seleção de pacotes GMR3 no relatorio de apuração de comissões variáveis. 
@obs OS: 3700-16 - Mateus Fadini
@type function
/*/

User Function BIAF052(lOneEle, lTipRet)
Local cTitulo := ""
Local MvPar
Local MvParDef :=""	
Private aPac := {}

	Default lOneEle := .F.
	Default lTipRet := .T.
	
	cAlias := Alias()
	
	If lTipRet
		
		// Carrega Nome da Variavel do Get em Questao
		MvPar := &(Alltrim(ReadVar()))
		
		// Iguala Nome da Variavel ao Nome variavel de Retorno		
		MvRet := Alltrim(ReadVar())
		
	EndIf
	
	DbSelectArea("SX5")
	DbSetOrder(1)
	If SX5->(DbSeek(cFilial + "00ZH"))
	   cTitulo := Alltrim(Left(X5Descri(), 20))
	EndIf
	
	If SX5->(DbSeek(cFilial+"ZH"))
		
		While !SX5->(Eof()) .And. AllTrim(SX5->X5_TABELA) == "ZH"
			
			aAdd(aPac, Left(SX5->X5_CHAVE, 1) + " - " + AllTrim(X5Descri()))
			
			MvParDef += Left(SX5->X5_CHAVE, 1)
			
			SX5->(DbSkip())
		
		EndDo()
		
	EndIf
	
	
	If lTipRet
	
		// Chama funcao f_Opcoes
		If f_Opcoes(@MvPar, cTitulo, aPac, MvParDef, 12, 49, lOneEle)
			
			// Devolve Resultado
			&MvRet := MvPar
			
		EndIf
		
	EndIf
	
	DbSelectArea(cAlias)
		
Return(If (lTipRet, .T., MvParDef))