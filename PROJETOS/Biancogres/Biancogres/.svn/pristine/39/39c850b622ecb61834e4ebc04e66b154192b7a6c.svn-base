#INCLUDE "TOTVS.CH"

// Variavel para controlar bug na rotina padrao que executa duas vezes o DelOK(A120DEL)
Static __lBug_A120Del := .F.

User Function FCLA0006; Return()


/*
|-------------------------------------------------------------|
|	Classe:	|	TVldPedCom																			  |
|	Autor:	|	Tiago Rossini Coradini - Facile Sistemas					|
|	Data:		|	20/10/14																					|
|-------------------------------------------------------------|
|	Desc.:	|	Classe responsavel pela validacao dos itens do		|
|					|	pedido de compra																	|
|-------------------------------------------------------------|
| OS:			|	1156-13, 1138-14 - Usuário: Tania de Fatima   		|
|-------------------------------------------------------------|
*/

Class TVldPedCom From LongClassName

	Data lEnable // Indica se a customização esta habilitada para execução
	Data oVldPrd // Objeto para controle do bloqueio de Produtos	
	Data oVldData // Objeto para validacao de datas

	Method New()
	Method Validate() // Validação geral
	Method ValidAll() // Validação de todos os itens (Loop nas linhas)
	Method ValidLine(nLine) // Validação por linha
	Method ValidField() // Validação por campo
	Method ValidWhen() // Validação de edição, permite ou não editar o campo.(Mesma funcionalidade do X3_WHEN)
	Method ValidDelLine() // Validação da deleção por linha, permite ou não deletar a linha
	
EndClass


Method New() Class TVldPedCom

	::lEnable := SuperGetMv("VLD_PEDCOM", .F., .F.)

	::oVldPrd := TVldPrd():New("PEDCOM")
	
	::oVldData := TVldData():New("PEDCOM")
		
Return()


Method Validate() Class TVldPedCom
Local lRet := .T.

	If ::lEnable
		lRet := ::ValidAll()
	EndIf
	
Return(lRet)


Method ValidAll() Class TVldPedCom
Local lRet := .T.
Local nLine := 1

	While lRet .And. nLine <= Len(aCols)
		lRet := ::ValidLine(nLine)
		nLine++
	EndDo
	
Return(lRet)


Method ValidLine(nLine) Class TVldPedCom
Local lRet := .T.

	Default nLine := N
	
	If ::lEnable 
				
		If !::oVldPrd:ValidLine(nLine)
			Return(.F.)
		EndIf
		
		If !::oVldData:ValidLine(nLine)
			Return(.F.)
		EndIf		
		
	EndIf
		
Return(lRet)


Method ValidField() Class TVldPedCom
Local lRet := .T.
Local cField := ReadVar()

	If ::lEnable
			
		If !::oVldPrd:ValidField(cField)
			Return(.F.)
		EndIf
		
		If !::oVldData:ValidField(cField)
			Return(.F.)
		EndIf		
				
	EndIf
	
Return(lRet)


Method ValidWhen() Class TVldPedCom
Local lRet := .T.
		
	If ::lEnable
		
	EndIf
	
Return(lRet)


Method ValidDelLine() Class TVldPedCom
Local lRet := .T.
		
	If ::lEnable
		
	EndIf
	
Return(lRet)


// Responsavel pela validacao de campo do pedido de compra
User Function VldFPedCom()
Local lRet := .T.
Local oVldPedCom := TVldPedCom():New()

	lRet := oVldPedCom:ValidField()
	
Return(lRet)


// Responsavel pela validacao do modo de edicao do pedido de compra
User Function VldWPedCom()
Local lRet := .T.
Local oVldPedCom := TVldPedCom():New()

	lRet := oVldPedCom:ValidWhen()
	
Return(lRet)


// Responsavel pela validacao modo de edicao do pedido de compra
User Function VldDLPedCom()
Local lRet := .T.
Local oVldPedCom := TVldPedCom():New()
	
	If !__lBug_A120Del	
		lRet := oVldPedCom:ValidDelLine()
		__lBug_A120Del := .T.
	Else
		lRet := __lBug_A120Del := .F.
	EndIf				
	
Return(lRet)