#include "protheus.ch"
#include "topconn.ch"

static aKeepValid as array

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

	local bValOper 	 as block

	local cMsg 		 as character
	local cThreadID	 as character
	local cServerIP	 as character
	local cEnvServer as character
	local cKeepValid as character	

	local lRet		 as logical
	local lDev		 as logical
	local lIsBlind	 as logical

	local nKeepValid as numeric

	DEFAULT aKeepValid:=array(0)

	DEFAULT cFuncao:=""
	DEFAULT lShowMsg:=.T. //SE EXIBE A MENSAGEM DE BLOQUEIO PADRAO
	DEFAULT lAdmLib:=.F.  //SE LIBERA SEMPRE PARA USUARIOS DO GRUPO ADMINISTRADOR

	begin sequence
	
		lRet:=stackTools():IsInStackCall({"ProcPedido","ProcessaDevolucao"})
	
		if (lRet)
			break
		endif

		cServerIP:=strTran(getServerIP(),".","")
		cEnvServer:=upper(getEnvServer())

		lDev:=((cServerIP=="1921682018").or.("DEV"$cEnvServer))
    
		if (lDev)
			lRet:=lDev
			break
		endif

    	cThreadID:=cValToChar(ThreadID())
    
		cKeepValid:=cFuncao
		cKeepValid+=cServerIP
		cKeepValid+=cThreadID
		cKeepValid+=cEnvServer		
		if (type("__cUserID")=="C")
			cKeepValid+=&("__cUserID")
		endif

		nKeepValid:=aScan(aKeepValid,{|k|(k[1]==cKeepValid)})
		if (nKeepValid>0)
			lRet:=aKeepValid[nKeepValid][2]
			if (!lRet)
				cMsg:=aKeepValid[nKeepValid][3]
				if (!empty(cMsg))
					if (lShowMsg)
						Help(nil,nil,"","__VALIDA_ACESSO__",cMsg,1,0,!IsBlind(),nil,nil,nil,.T.)
					endif
				endif
			endif
			break
		endif

		lIsBlind:=IsBlind()

		bValOper:={||VALOPER(@cFuncao,@lShowMsg,@lAdmLib,@cMsg)}
		lRet:=evalBlock():evalBlock(bValOper,nil,!lIsBlind)
	
		aAdd(aKeepValid,{cKeepValid,lRet,cMsg})

	end sequence

	DEFAULT lRet:=.F.
	
	return(lRet)

static function VALOPER(cFuncao,lShowMsg,lAdmLib,cMsg)   

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
	CHKFILE("ZZ0")
	ZZ0->(DbSetOrder(1))
	ZZ0->(DbSeek(XFilial('ZZ0')+cFuncao))
	cAcesso := Alltrim(ZZ0->ZZ0_ACESSO)

	IF !Empty(cAcesso)

		If Type(cAcesso) <> 'A'
			cMsg:="Conteúdo inválido na regra de acesso a função." + CHR(13) + "Favor contatar o administrador do sistema!"
			if (lShowMsg)
				Help(nil,nil,"","__VALIDA_ACESSO__",cMsg,1,0,!IsBlind(),nil,nil,nil,.T.)
			endif
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
	IF (!lRet )
		cMsg:="Usuário sem acesso a esta operação!" + CRLF + ALLTRIM(UPPER(ZZ0->ZZ0_CODIGO)) + " - " + ALLTRIM(UPPER(ZZ0->ZZ0_DESC)) 
		if (lShowMsg)
			Help(nil,nil,"","__VALIDA_ACESSO__",cMsg,1,0,!IsBlind(),nil,nil,nil,.T.)
		endif
	ENDIF

	Return(lRet)
