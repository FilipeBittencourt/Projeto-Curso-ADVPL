/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |WFRSP1     | Autor | Marcelo Sousa        | Data | 17.07.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |WORKFLOW UTILIZADO PARA INFORMAR AO RECRUTAMENTO E APROVADOR  |
|          |SOBRE A CRIAÇÃO DE UMA NOVA VAGA.							  |	 
+----------+--------------------------------------------------------------+
|Uso       |RECRUTAMENTO E SELEÇÃO                                        |
+----------+-------------------------------------------------------------*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

/* 
Codigo da Vaga           - cCodVaga 
Descrição da Vaga        - cDcVaga 
Usuário que criou a vaga - cUnVaga 
E-mail destino aprovador - cEmPara
Nome do aprovador        - cNmAp
Ação da função: 1 - Envio de e-mail para o recrutamento / 2 - Envio de e-mail para o aprovador / 3 - Receber e-mail para validacao de aprovacao
*/

User Function BIAFM004(_CodVaga,_DcVaga,_UnVaga,_EmPara,_NmAp,cAct)
    
    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	Private  cCodVaga  := _CodVaga
	Private  cDcVaga   := _DcVaga
    Private  cUnVaga   := _UnVaga
    Private  cEmPara   := _EmPara
    Private  cNmAp     := _NmAp
    
    IF VALTYPE(cAct) == "U"
    
    	cAct := "3"
  
    Else	
    
    	Private  cRec      := U_EmailWF('BIAFM004',"01")
    
    Endif 
    
    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Ação escolhida na chamada de função.                                    ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	
    IF cValToChar(cAct) == "1"
    
    	ENVRSP()
    
    ELSEIF cValToChar(cAct) == "2"
    
    	ENVAPR()
	
	ELSEIF cValToChar(cAct) == "3"
	
		If Select("SX6") == 0    
			
			RPCSetType(3)
			WfPrepEnv("01","01")
			
			cRec      := U_EmailWF('BIAFM004',"01")
			
//			ConOut("HORA: "+TIME()+" - Iniciando Processo BIAFM004 - Aprovação de Vagas")
			
			RECEBE()
		
//			ConOut("HORA: "+TIME()+" - Finalizando Processo BIAFM004 - Aprovação de Vagas")
			
			RpcClearEnv()
		
		Else	
	
			RECEBE()
	
		Endif
	
	
	ENDIF 
	
Return	
	

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Montagem do E-mail para o Recrutamento.                                 ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function ENVRSP()
		
		Local cCabec := "CADASTRO DE VAGA "+cCodVaga+" - CRIACAO"
		
		cMens := '<html>'+CRLF
		cMens += '<body>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">Olá recrutador,' +CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">Foi criada vaga com os seguintes dados abaixo:'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">Vaga criada: '+cCodVaga+' - '+cDcVaga+ CRLF
		cMens += '<FONT SIZE=4 face="arial">Usuario criador: ' +cUnVaga+ CRLF
		cMens += '<FONT SIZE=4 face="arial">Usuario aprovador: ' +cNmAp+ CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">A vaga esta aguardando o seu aceite.<P>'+CRLF
		cMens += '</br>'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<br> <br><FONT SIZE=3>Atenciosamente,</FONT></br>'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=3>Protheus Workflow</FONT>'+CRLF
		cMens += '</body>'+CRLF
		cMens += '</html>'+CRLF
		
	// Enviando e-mail para recrutador
	U_BIAEnvMail(,cRec, cCabec, cMens)		
Return
	
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Montagem do E-mail para o Aprovador   .                                 ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function ENVAPR()
	
	Local cCabec := "CADASTRO DE VAGA "+cCodVaga+" - APROVACAO"
	  
	cMens := '<html>'+CRLF
	cMens += '<body>'+CRLF
	cMens += '<FONT SIZE=4 face="arial">Olá '+cNmAp+',' +CRLF
	cMens += '</br>'+CRLF
	cMens += '<FONT SIZE=4 face="arial">Foi criada vaga com os seguintes dados abaixo:'+CRLF
	cMens += '</br>'+CRLF
	cMens += '<FONT SIZE=4 face="arial">Vaga criada: '+cCodVaga+' - '+cDcVaga+ CRLF
	cMens += '<FONT SIZE=4 face="arial">Usuario criador: ' +cUnVaga+ CRLF
	cMens += '</br>'+CRLF
	cMens += '<a href="mailto:relatorios.biancogres@biancogres.com.br ?subject=Aprovar vaga: '+ cCodVaga + '">Aprovar</a> ou <a href="mailto:relatorios.biancogres@biancogres.com.br ?subject=Reprovar vaga: '+ cCodVaga + '">Reprovar</a>' +CRLF
	cMens += '</br>'+CRLF
	cMens += '</br>'+CRLF
	cMens += '<br> <br><FONT SIZE=3>Atenciosamente,</FONT></br>'+CRLF
	cMens += '</br>'+CRLF
	cMens += '<FONT SIZE=3>Recrutamento Biancogres</FONT>'+CRLF
	cMens += '</body>'+CRLF
	cMens += '</html>'+CRLF

	
	// Enviando e-mail para aprovador da vaga
	U_BIAEnvMail(,cEmPara, cCabec, cMens)
	
Return .T.	

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Montagem do E-mail reprovando a vaga.                                   ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function REPAP(cIDMsg,cDVaga,cResp,cMatResp)
		
				
		Local cCabec := "CADASTRO DE VAGA "+SUBSTR(cIDMsg,3,6)+" - CRIACAO"
		
		cMens := '<html>'+CRLF
		cMens += '<body>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">Olá recrutador,' +CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">A vaga abaixo foi reprovada pelo Aprovador:'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">Vaga criada: '+cIDMsg+' - '+cDVaga+ CRLF
		cMens += '<FONT SIZE=4 face="arial">Usuario aprovador: ' +cResp+ CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">A mesma ficará com status reprovada.<P>'+CRLF
		cMens += '</br>'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<br> <br><FONT SIZE=3>Atenciosamente,</FONT></br>'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=3>Protheus Workflow</FONT>'+CRLF
		cMens += '</body>'+CRLF
		cMens += '</html>'+CRLF
	
		
	// Enviando e-mail da reprovação para o recrutador
	U_BIAEnvMail(,cRec, cCabec, cMens)	
	
Return

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Montagem do E-mail aprovando a vaga.                                    ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function APAP(cIDMsg,cDVaga,cResp,cMatResp)
		
				
		Local cCabec := "CADASTRO DE VAGA "+SUBSTR(cIDMsg,2,6)+" - CRIACAO"
		
		cMens := '<html>'+CRLF
		cMens += '<body>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">Olá recrutador,' +CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">A vaga abaixo foi aprovada pelo Aprovador:'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">Vaga criada: '+cIDMsg+' - '+cDVaga+ CRLF
		cMens += '<FONT SIZE=4 face="arial">Usuario aprovador: ' +cResp+ CRLF
		cMens += '</br>'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<br> <br><FONT SIZE=3>Atenciosamente,</FONT></br>'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=3>Protheus Workflow</FONT>'+CRLF
		cMens += '</body>'+CRLF
		cMens += '</html>'+CRLF
	
		
	// Enviando e-mail da aprovavao para o recrutador
	U_BIAEnvMail(,cRec, cCabec, cMens)	
	
Return

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Funcao para receber os e-mails e selecionar ação para com a vaga.       ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function Recebe()
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	Local nMsg := 0
	Local nTotMsg := 0 	

	Private cNumPed := 0
	Private cCodApr := 0
	Private cEmailApr := 0
	Private cCodAprT := 0
	Private cEmailAprT := 0
	Private oServidor := 0
	Private oMensagem := 0
	Private cServidor := 0
	Private cConta := 0
	Private cSenha := 0
	Private cEmail := 0
	Private lUseSSL := .T.
	
	
	cNumPed := ""
	cCodApr := ""
	cEmailApr := ""
	cCodAprT := ""
	cEmailAprT := ""	
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Recebimento dos dados do e-mail que será lido.                          ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oServidor := TMailManager():New()
	//oMensagem := TMailMessage():New()
	cServidor := SubStr(GetMv("MV_YSRVPOP"),1,RAT(':',GetMv("MV_YSRVPOP"))-1)	
	cConta := GetMV("MV_RELACNT")
	cSenha := GetMV("MV_RELPSW")
	cEmail := GetMV("MV_RELACNT")
	lUseSSL := GetMv("MV_RELSSL")
	
	cPtPOP3:= Val(SubStr(GetMv("MV_YSRVPOP"),RAT(':',GetMv("MV_YSRVPOP"))+1,Len(Alltrim(GetMv("MV_YSRVPOP")))))
	cIDMsg := ""

    oServidor:SetUseSSL(lUseSSL) 
  	oServidor:Init(cServidor, "", cConta, cSenha, cPtPOP3, 0)
    oServidor:SetPopTimeOut(60)  
  
    If oServidor:PopConnect() == 0

    	oServidor:GetNumMsgs(@nTotMsg)	  

    	IF nTotMsg > 0 

    		ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaVagaEMail:Recebe()")
	  
   		ENDIF 
   		
    	For nMsg := 1 To nTotMsg
    		
    		oMensagem := tMailMessage():new() 
    		oMensagem:Clear()
	     
    		oMensagem:Receive(oServidor, nMsg)	    	    	     	    	    
	    
 
	    
    		Valida()
	    	
	    	oServidor:DeleteMsg(nMsg)	  
	    	
    	Next
	  
	    oServidor:POPDisconnect()


	 EndIf
	
Return

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Funcao para validar os conteudos da aprovação e mensagem.               ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function Valida()
	
	Local lRet := .F.

	cIDMsg := RetIDMsg()		
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	DBSELECTAREA("SQS")
	SQS->(DbSetOrder(1))
	SQS->(DBSEEK(XFILIAL("SQS")+CVALTOCHAR(Substr(cIDMsg,At("P",cIDMsg) + 1),6 )))
	
	cDVaga := ALLTRIM(SQS->QS_DESCRIC)
	cMatResp := ALLTRIM(SQS->QS_MATRESP)
	
	dbselectarea("SRA")
    SRA->(dbsetorder(1))
    SRA->(dbSeek(xFilial("SRA")+cMatResp))
    	
    cResp := ALLTRIM(SRA->RA_NOME)
	
	If !Empty(cIDMsg) .And. 'AP' $ cIDMsg .And. Empty(SQS->QS_YAPROV)
	
		RecLock("SQS", .F.)
		
			SQS->QS_YAPROV := "S"  
			
			IF SQS->QS_TIPO <> "4"
				SQS->QS_TIPO   := "3"
			ENDIF 
			
		SQS->(MSUNLOCK())
		
		// ENVIA E-MAIL PARA RECRUTAMENTO SOBRE VAGA APROVADA PELO GESTOR
		APAP(cIDMsg,cDVaga,cResp,cMatResp)
		
		lRet := .T.
	
	ELSEIF !Empty(cIDMsg) .And. 'REP' $ cIDMsg .And. Empty(SQS->QS_YAPROV) 
		
		RecLock("SQS", .F.)
		
			SQS->QS_YAPROV := "N"  
			SQS->QS_TIPO   := "" 	
		
		SQS->(MSUNLOCK())
		
		// ENVIA E-MAIL PARA RECRUTAMENTO SOBRE VAGA REPROVADA PELO GESTOR
		REPAP(cIDMsg,cDVaga,cResp,cMatResp)
		
		lRet := .T.
			
	EndIf
	
	SQS->(DBCLOSEAREA())

Return(lRet)

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Funcao que trata os dados recebidos no e-mail e aciona o envio da       ±± 
±± resposta.               												   ±±	
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function RetIDMsg()
	
	Local cRet := ""

	If 'Aprovar vaga:' $ oMensagem:cSubject
		
		cRet := "AP" + SubStr(AllTrim(oMensagem:cSubject), At('Aprovar vaga:', oMensagem:cSubject) + 13, 6)  
		
	Elseif 'Reprovar vaga:' $ oMensagem:cSubject
	
		cRet := "REP" + SubStr(AllTrim(oMensagem:cSubject), At('Reprovar vaga:', oMensagem:cSubject) + 14, 6)

	Endif	

Return cRet