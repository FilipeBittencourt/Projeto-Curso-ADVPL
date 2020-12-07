/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |RSPA100INC | Autor | Marcelo Sousa        | Data | 23.05.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |PONTO DE ENTRADA UTILIZADO PARA TRATAR SE O USUARIO DO SISTEMA|
|          |TEM A PERMISSÃO DE CADASTRAR UMA VAGA. TRATA TAMBÉM DO ENVIO  |
|          |DE E-MAIL PARA O SETOR DE RECRUTAMENTO   					  |	
+----------+--------------------------------------------------------------+
|Retorno   |.T. OU .F.                                                    |
+----------+--------------------------------------------------------------+
|Uso       |RECRUTAMENTO E SELEÇÃO                                        |
+----------+-------------------------------------------------------------*/

#Include "protheus.ch"
#Include "topconn.ch"

User Function RSPA100INC()
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/ 
    cUsrtst := __cUserID
    aUsrtst2 := UsrRetGrp(cUsrtst)
	lAlt := .F.
	lCria := .F.
	lAprov := .F.
	aUsr   := cUserName
	
	DBSELECTAREA("ZR3")
	ZR3->(dbsetorder(1))
	ZR3->(DBSEEK(xFilial("ZR3")+cUsrtst))
	
	IF ALTERA
		
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
		±± Verificando permissão de alteração                                      ±±
		Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		IF ZR3->ZR3_USUARI == cUsrtst .AND. ZR3->ZR3_RECRUT == "1"
			lAlt := .T.
		ENDIF
		
		IF !lAlt
		
			MSGALERT((cUserName) + ", você não possui permissão de alteração. Favor solicitar suporte no setor de recrutamento.","Erro de Permissao")
			Return .F.
		
		ENDIF
		
	ENDIF
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Verificando permissão para cadastrar vagas.                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	IF ZR3->ZR3_USUARI == cUsrtst .AND. ZR3->ZR3_CRIA == "1"
		lCria := .T.
	ENDIF

	IF !lCria
	    
		Alert("Usuario " + (cUserName) + " não possui permissão para cadastrar vagas. Favor solicitar permissão no setor de recrutamento")
		Return .F.
	
	ENDIF
    
    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Enviando vaga para o funcionário de recrutamento realizar a aprovação   ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/ 
    IF INCLUI .OR. ALTERA
    
    	
    	cCodVaga := M->QS_VAGA
    	cDcVaga  := M->QS_DESCRIC
    	
    	dbselectarea("SRA")
    	SRA->(dbsetorder(1))
    	SRA->(dbSeek(xFilial("SRA")+M->QS_MATRESP))
    	
    	IF !EMPTY(SRA->RA_EMAIL) .AND. !EMPTY(M->QS_MATRESP)
    		
    		IF M->QS_TIPO <> "4"
    			M->QS_TIPO := ""	
    		ENDIF
    		
    		M->QS_YAPROV := ""    			
    		cNmAp    := ALLTRIM(SRA->RA_NOME)
    		cEmPara  := SRA->RA_EMAIL
    	    U_BIAFM004(cCodVaga,cDcVaga,aUsr,cEmPara,cNmAp,"1")
    		Alert("Aviso de vaga enviado para " + cNmAp + ". Favor entrar em contato com o mesmo para efetuar a aprovação da vaga")
    		Return .T.
    	
    	ELSE
    	
    		Alert("Não foi encontrado endereço de E-mail do Aprovador. Favor entrar em contato com a equipe de Recrutamento.")
    		Return .F.
    	
    	ENDIF
    	

    	
    Endif

Return