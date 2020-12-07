#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GETBIAPAR
@description Funcao Generica de gravar PARAMETROS no banco Multi Empresas
@author Wlysses Cerqueira (Facile)
@since 25/11/2019
@version 1.0
@type class
/*/

User Function GETBIAPAR(cParam, xDefault, cEmp, cFil)

	Local xRet := ""
	
	Default cParam		:= ""
	Default xDefault	:= Nil
	
	cEmp := If(cEmp == Nil .Or. cEmp == "", Space(TamSX3("ZL4_CODEMP")[1]), If(Len(AllTrim(cEmp)) == TamSX3("ZL4_CODEMP")[1], cEmp, PADR(AllTrim(cEmp), TamSX3("ZL4_CODEMP")[1])))
	cFil := If(cFil == Nil .Or. cFil == "", Space(TamSX3("ZL4_CODFIL")[1]), If(Len(AllTrim(cFil)) == TamSX3("ZL4_CODFIL")[1], cFil, PADR(AllTrim(cFil), TamSX3("ZL4_CODFIL")[1])))
	
	cParam := PADR(AllTrim(cParam), TamSX3("ZL4_PARAM")[1])
	
	DBSelectArea("ZL4")
	ZL4->(DBSetOrder(1)) // ZL4_FILIAL, ZL4_CODEMP + ZL4_CODFIL + ZL4_PARAM
	ZL4->(DBGoTop())
	
	If Empty(cEmp) .And. Empty(cFil) // Para saber o parametro na filial logada
	
		If ZL4->(DBSeek(xFilial("ZL4") + cEmpAnt + cFilAnt + cParam))
		
			xRet := ConvType(ZL4->ZL4_CONTEU, ZL4->ZL4_TIPO)
			
		ElseIf ZL4->(DBSeek(xFilial("ZL4") + cEmpAnt + cFil + cParam))
		
			xRet := ConvType(ZL4->ZL4_CONTEU, ZL4->ZL4_TIPO)
			
		ElseIf ZL4->(DBSeek(xFilial("ZL4") + cEmp + cFil + cParam))
			
			xRet := ConvType(ZL4->ZL4_CONTEU, ZL4->ZL4_TIPO)
			
		Else
		
			xRet := xDefault
		
		EndIf
	
	EndIf
	
	If !Empty(cEmp) .And. Empty(cFil) // Para saber o parametro da empresa espefica, sem passar filial.
	
		If ZL4->(DBSeek(xFilial("ZL4") + cEmp + cFil + cParam))
		
			xRet := ConvType(ZL4->ZL4_CONTEU, ZL4->ZL4_TIPO)
		
		
		ElseIf ZL4->(DBSeek(xFilial("ZL4") + Space(Len(cEmp)) + cFil + cParam))
		
			xRet := ConvType(ZL4->ZL4_CONTEU, ZL4->ZL4_TIPO)
			
		Else
		
			xRet := xDefault
		
		EndIf
	
	EndIf
	
	If !Empty(cEmp) .And. !Empty(cFil) // Para saber o parametro na empresa / filial especifica.
	
		If ZL4->(DBSeek(xFilial("ZL4") + cEmp + cFil + cParam))
		
			xRet := ConvType(ZL4->ZL4_CONTEU, ZL4->ZL4_TIPO)

		ElseIf ZL4->(DBSeek(xFilial("ZL4") + cEmp + Space(Len(cFil)) + cParam))
		
			xRet := ConvType(ZL4->ZL4_CONTEU, ZL4->ZL4_TIPO)
			
		ElseIf ZL4->(DBSeek(xFilial("ZL4") + Space(Len(cEmp)) + Space(Len(cFil)) + cParam))
		
			xRet := ConvType(ZL4->ZL4_CONTEU, ZL4->ZL4_TIPO)
			
		Else
		
			xRet := xDefault
		
		EndIf
	
	EndIf

Return(xRet)

User Function PUTBIAPAR(cParam, cConteudo, cEmp, cFil)

	Local xRet := ""
	
	Default cParam		:= ""
	
	cEmp := If(cEmp == Nil .Or. cEmp == "", Space(TamSX3("ZL4_CODEMP")[1]), If(Len(AllTrim(cEmp)) == TamSX3("ZL4_CODEMP")[1], cEmp, PADR(AllTrim(cEmp), TamSX3("ZL4_CODEMP")[1])))
	cFil := If(cFil == Nil .Or. cFil == "", Space(TamSX3("ZL4_CODFIL")[1]), If(Len(AllTrim(cFil)) == TamSX3("ZL4_CODFIL")[1], cFil, PADR(AllTrim(cFil), TamSX3("ZL4_CODFIL")[1])))
	
	cParam := PADR(AllTrim(cParam), TamSX3("ZL4_PARAM")[1])
	
	DBSelectArea("ZL4")
	ZL4->(DBSetOrder(1)) // ZL4_FILIAL, ZL4_CODEMP + ZL4_CODFIL + ZL4_PARAM
	ZL4->(DBGoTop())
	
	If Empty(cEmp) .And. Empty(cFil) // Para saber o parametro na filial logada
	
		If ZL4->(DBSeek(xFilial("ZL4") + cEmpAnt + cFilAnt + cParam))
		
			Update(cConteudo)
			
		ElseIf ZL4->(DBSeek(xFilial("ZL4") + cEmpAnt + cFil + cParam))
		
			Update(cConteudo)
			
		ElseIf ZL4->(DBSeek(xFilial("ZL4") + cEmp + cFil + cParam))
			
			Update(cConteudo)
		
		EndIf
	
	EndIf
	
	If !Empty(cEmp) .And. Empty(cFil) // Para saber o parametro da empresa espefica, sem passar filial.
	
		If ZL4->(DBSeek(xFilial("ZL4") + cEmp + cFil + cParam))
		
			Update(cConteudo)
		
		ElseIf ZL4->(DBSeek(xFilial("ZL4") + Space(Len(cEmp)) + cFil + cParam))
		
			Update(cConteudo)
		
		EndIf
	
	EndIf
	
	If !Empty(cEmp) .And. !Empty(cFil) // Para saber o parametro na empresa / filial especifica.
	
		If ZL4->(DBSeek(xFilial("ZL4") + cEmp + cFil + cParam))
		
			Update(cConteudo)

		ElseIf ZL4->(DBSeek(xFilial("ZL4") + Space(Len(cEmp)) + Space(Len(cFil)) + cParam))
		
			Update(cConteudo)
		
		EndIf
	
	EndIf
	
Return()

Static Function Update(xConteudo)

	Local xRet := Nil
	
	Default xConteudo := ""
	
	If ValType(xConteudo) == "C"
	
		xRet := xConteudo
	
	ElseIf ValType(xConteudo) == "D"
	
		xRet := DTOS(xConteudo)
	
	ElseIf ValType(xConteudo) == "N"
	
		xRet := cValToChar(xConteudo)
	
	ElseIf ValType(xConteudo) == "L"
		
		xRet := If(xConteudo, ".T.", ".F.")
	
	Else
	
		xRet := xConteudo
	
	EndIf
	
	RecLock("ZL4", .F.)
	ZL4->ZL4_CONTEU	:= xRet
	ZL4->(MSUnLock())

Return()

Static Function ConvType(cConteudo, cType)
	
	Local xRet := Nil
	
	Default cType := ""
	Default cConteudo := ""
	
	If AllTrim(cType) == "C"
	
		xRet := AllTrim(cConteudo)
	
	ElseIf AllTrim(cType) == "D"
	
		xRet := CTOD(cConteudo)
	
	ElseIf AllTrim(cType) == "N"
	
		xRet := Val(cConteudo)
	
	ElseIf AllTrim(cType) == "L"
		
		xRet := If(Alltrim(cConteudo) $ ".T.|T", .T., If(Alltrim(cConteudo) $ ".F.|F", .F., Nil))
	
	Else
	
		xRet := cConteudo
	
	EndIf

Return(xRet)