#include "protheus.ch"
#include "topconn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³ VALOPER  ³ Autor ³ FERNANDO ROCHA        ³ Data ³24/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ FUNCAO PARA BUSCA DE PERMICAO PARA EXECUTAR OPERACAO       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/        

User Function VALOPER(cFuncao,lShowMsg,lAdmLib)   

	Local aArea		:= GetArea()        
	Local lRet 		:= .F.
	Local cAcesso := ""   
	Local I           

	Default lShowMsg := .T.  //SE EXIBE A MENSAGEM DE BLOQUEIO PADRAO
	Default lAdmLib  := .F.  //SE LIBERA SEMPRE PARA USUARIOS DO GRUPO ADMINISTRADOR

	If (IsInCallStack("U_BIPROCPR") .Or. IsInCallStack("U_BIPROCCL")) .And. IsBlind() // Ticket: 24427

		Return(.T.)

	EndIf

	//VALIDACAO PARA LIBERAR ADMINISTRADOR
	IF AllTrim(Upper(cFuncao)) == "ADMIN"
		If PswSeek( __cUserID, .T. )
			aArray := PSWRET() // Retorna vetor com informa?es do usu?io
			IF aScan(aArray[1][10],'000000') > 0
				return(.T.)
			ENDIF
		EndIf
		return(.F.)
	ENDIF

	//VALIDACAO PELO CADASTRO DE OPERACAO - CAMPO ACESSO
	ZZ0->(DbSetOrder(1))
	ZZ0->(DbSeek(XFilial('ZZ0')+cFuncao))
	cAcesso := Alltrim(ZZ0->ZZ0_ACESSO)

	IF !Empty(cAcesso)

		If Type(cAcesso) <> 'A'
			MsgAlert("Conteúdo inválido na regra de acesso a função." + CHR(13) + "Favor contatar o administrador do sistema!")
			return(.F.)
		EndIf

		PswOrder(1)
		If PswSeek( __cUserID, .T. )
			aArray := PSWRET() // Retorna vetor com informa?es do usu?io   

			//libera a funcao se o usuario estiver liberado
			IF AllTrim(__cUserID) $ &(cAcesso)[2]
				lRet := .T.
			ENDIF	

			//libera a funcao se o usuario pertencer a um grupo liberado
			For I := 1 To Len(aArray[1][10]) 
				IF AllTrim(aArray[1][10][I]) $ &(cAcesso)[1]
					lRet := .T.                         
					exit
				ENDIF	
			Next I

			//libera a funcao se o usuario for administrador e o parametro lAdmLib estiver .T.
			IF lAdmLib
				if aScan(aArray[1][10],'000000') > 0
					lRet := .T.
				endif
			ENDIF
		EndIf

	ELSE

		//Se Acesso nao preenchido libera
		lRet := .T.

	ENDIF

	RestArea(aArea)
	IF !lRet .And. lShowMsg
		MsgAlert("Usuário sem acesso a esta operação!" + CRLF + ALLTRIM(UPPER(ZZ0->ZZ0_CODIGO)) + " - " + ALLTRIM(UPPER(ZZ0->ZZ0_DESC)), "Validação de Acesso!!!")
	ENDIF

Return(lRet)
