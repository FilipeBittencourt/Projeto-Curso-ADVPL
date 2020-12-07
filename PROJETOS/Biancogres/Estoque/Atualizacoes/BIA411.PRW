#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA411()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA411     ³ Autor ³ WANISAY WILLIAM       ³ Data ³ 24/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ AXCADASTRO CADASTRO DE FORMATOS                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador x Base                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//AxCadastro("ZZ6","CADASTRO DE FORMATOS DOS PRODUTOS")
AxCadastro("ZZ6","CADASTRO DE FORMATOS DOS PRODUTOS","U_BIA44_DEL()","U_BIA44_ALT()")

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01


/*
##############################################################################################################
# PROGRAMA...: BIA44_ALT         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 03/02/2014                      
# DESCRICAO..: FUNCAO PARA VALIDAR SE HOUVE ALTERACAO NO CADASTRO DE FORMA (ZZ6) PARA ALTERAR NAS TABELAS DO EXPVISION	 				 
##############################################################################################################
*/
User Function BIA44_ALT()
	Local lRet := .T.
	Local _aArea	:=	GetArea()
	
	DbSelectArea("SYC")
	SYC->(DbSetOrder(1))
	
	If Inclui
		If SYC->(DbSeek(xFilial("SYC")+PADR(M->ZZ6_COD,TAMSX3("YC_COD")[1])))
			Reclock("SYC",.F.)
		Else
			Reclock("SYC",.T.)
			SYC->YC_FILIAL :=	xFilial("SYC")
		EndIf
		
		SYC->YC_COD		:=	M->ZZ6_COD
		SYC->YC_NOME	:=	M->ZZ6_DESC
		SYC->YC_IDIOMA	:=	"PORT. -PORTUGUES         "
		
		SYC->(MsUnlock())
		
	ElseIf Altera
		If SYC->(DbSeek(xFilial("SYC")+PADR(ZZ6->ZZ6_COD,TAMSX3("YC_COD")[1])))
			Reclock("SYC",.F.)
		Else
			Reclock("SYC",.T.)
			SYC->YC_FILIAL :=	xFilial("SYC")
		EndIf
		
		SYC->YC_COD		:=	M->ZZ6_COD
		SYC->YC_NOME	:=	M->ZZ6_DESC
		SYC->YC_IDIOMA	:=	"PORT. -PORTUGUES         "
		
		SYC->(MsUnlock())
	EndIf
	
	If Inclui .Or. Altera
		
		fItgMes()
		
	EndIf
	
	
	RestArea(_aArea)
return lRet                                            

User Function BIA44_DEL()

	Local _lRet	:=	.T.
	
	If SYC->(DbSeek(xFilial("SYC")+PADR(ZZ6->ZZ6_COD,TAMSX3("YC_COD")[1])))
		Reclock("SYC",.F.)
		SYC->(DbDelete())
		SYC->(MsUnlock())
	EndIf

Return _lRet


Static Function fItgMes()

	Local _cAlias	:=	GetNextAlias()
	Local _cSql		:=	""


	BeginSql Alias _cAlias
		%NoParser%
		SELECT *
			FROM PCF4..tblProductFamily
			WHERE Code = %Exp:SYC->YC_COD%
			
	EndSql

	If (_cAlias)->(!EOF())
		_cSql	:=	"UPDATE PCF4..tblProductFamily SET Name = " + ValtoSql(SYC->YC_NOME) + " WHERE Code = " + ValtoSql((_cAlias)->Code)
	Else
		_cSql	:=	"INSERT INTO PCF4..tblProductFamily(Code,Name,FlgEnable) VALUES("+ValtoSql(SYC->YC_COD)+","+ValtoSql(SYC->YC_NOME)+",1 )"
	EndIf
	
	TcSqlExec(_cSql)
	
	(_cAlias)->(DbCloseArea())
	
Return