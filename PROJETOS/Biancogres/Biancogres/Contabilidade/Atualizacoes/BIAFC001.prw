#INCLUDE "TOTVS.CH"

/*
|-----------------------------------------------------------|
| Função: | BIAFR003																			  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 18/11/14																			  |
|-----------------------------------------------------------|
| Desc.:	| Cadastro de tipos de operçãoes fiscais  			  |
|-----------------------------------------------------------|
| OS:			|	1747-12 - Usuário: Fabiana Aparecida Corona			|
| OS:			|	1743-14 - Usuário: Tania de Fatima Monico	 			|
| OS:			|	2138-12 - Usuário: Antonio Marcio   		 			  |
|-----------------------------------------------------------|
*/

User Function BIAFC001()
Local cVldExc := "U_Z52EXC()"
Local cVldAlt := "U_Z52ALT()"
Private cString := "Z52"

	dbSelectArea(cString)
	dbSetOrder(1)

	AxCadastro(cString, "Operações Fiscais", cVldExc, cVldAlt)
		
Return()


User Function Z52EXC()
Local lRet := .T.
Local aArea := GetArea()	
		
	DbSelectArea("Z53")
	DbSetOrder(2)
	If Z53->(DbSeek(xFilial("Z53") + Z52->Z52_CODIGO))
		
		lRet := .F.
		MsgStop("Atenção, não é possível excluir o Tipo de Movimento, pois o mesmo está associado ao Parâmetro: " + Z53->Z53_CODIGO)
		
	EndIf
		
	RestArea(aArea)
	
Return(lRet)


User Function Z52ALT()
Local lRet := .T.
Local aArea := GetArea()	
		
	DbSelectArea("Z53")
	DbSetOrder(2)
	If Z53->(DbSeek(xFilial("Z53") + Z52->Z52_CODIGO))
		
		While !Z53->(Eof()) .And. Z53->Z53_IDOPFI == Z52->Z52_CODIGO
		
			RecLock("Z53", .F.)
				Z53->Z53_DSOPFI := M->Z52_DESC
			Z53->(MsUnLock())						
			
			Z53->(DbSkip())
		
		EndDo
		
	EndIf
		
	RestArea(aArea)
	
Return(lRet)