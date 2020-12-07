/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SCHED500 ³ Autor ³ Facile - Wladimir Illiushenko ³ Data ³ 25.10.19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envio de e-mail de notificação de atraso para os clientes.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Schedule                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "RwMake.ch"
#Include "Colors.ch"
#Include "Tbiconn.ch"
#Include "Protheus.ch"

#Define CR chr(13)

User Function SCHED500( _aParams )
Local _aDiasAnalise  := {}
Local _cAlsQry       := ""
Local _cMVCC         := ""
Local _cQuery        := ""
Local _cSMTPAdt      := ""
Local _lMVJobAtivo   := .F.
Local _nMVDiasAtraso := 0
Local _nMVDiasAvanco := 0
Local _ni            := 0

PRIVATE _aClientes := {}
PRIVATE _aTitulos  := {}
PRIVATE _cMyEmp    := ""
PRIVATE _cMyFil    := ""

DEFAULT _aParams := {}

_cMyEmp := iif(empty(_aParams), PARAMIXB[04], _aParams[1])
_cMyFil := iif(empty(_aParams), PARAMIXB[05], _aParams[2])

conout("")
conout("")
conout("--------------------------------------------------------------------------------------------------------------------------")
conout("[SCHED500]  [Emp.: "+_cMyEmp+"] [Fil.: "+_cMyFil+"] "+dtoc(date())+" "+time()+" Inicio do Job de Envio de Notificacoes de Titulos em Atraso aos Clientes...")

// Abre uma nova conexao sem consumir licenças
RPCSetType(3)
RPCSetEnv(_cMyEmp,_cMyFil)

// Identifica parametrizações
_lMVJobAtivo   := GetMV("MV_YSCH04A") // Job Ativo
_aDiasAnalise  := StrTokArr( GetMV("MV_YSCH04B"), "|") // Intervalor de Análise
_cMVCC         := GetMV("MV_YSCH04C") // Enderço de e-mail para o envio de copia
_cSMTPAdt      := GetMv("MV_MAILADT") // Conta de E-Mail de Auditoria

//Se o job estiver habilitado para uso via parametro de sistema e houver um intrvalo de análise definido, prossegue com a execução
if _lMVJobAtivo .AND. (len(_aDiasAnalise) == 2)
	
	_nMVDiasAtraso := val(_aDiasAnalise[1]) // Dias de Antecedência
	_nMVDiasAvanco := val(_aDiasAnalise[2]) // Dias Posteriores
	
	// Identifica clientes em situação de atraso e que estejam habilitados para cobrança
	_cAlsQry := GetNextAlias()
	_cQuery  := "SELECT"
	_cQuery  += CR + "  SA1.A1_COD+'-'+SA1.A1_LOJA _CODCLI,"
	_cQuery  += CR + "  SA1.A1_NOME                _NOME,"
	_cQuery  += CR + "  SA1.A1_EMAIL               _EMAIL,"
	_cQuery  += CR + "  SE1.E1_PREFIXO             _PREFIXO,"
	_cQuery  += CR + "  SE1.E1_NUM                 _NUMERO,"
	_cQuery  += CR + "  SE1.E1_PARCELA             _PARCELA,"
	_cQuery  += CR + "  SE1.E1_TIPO                _TIPO,"
	_cQuery  += CR + "  SE1.E1_VALOR               _VALOR,"
	_cQuery  += CR + "  SE1.E1_EMISSAO             _EMISSAO,"
	_cQuery  += CR + "  SE1.E1_VENCTO              _VENCTO,"
	_cQuery  += CR + "  SE1.E1_VENCREA             _VENCREAL"
	_cQuery  += CR
	_cQuery  += CR + "FROM "+RetSQLName("SE1")+" SE1 WITH (NOLOCK)"
	_cQuery  += CR
	_cQuery  += CR + "INNER JOIN "+RetSQLName("SA1")+" SA1 WITH (NOLOCK)"
	_cQuery  += CR + "ON"
	_cQuery  += CR + "      SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"
	_cQuery  += CR + "  AND SA1.A1_COD     = SE1.E1_CLIENTE"
	_cQuery  += CR + "  AND SA1.A1_LOJA    = SE1.E1_LOJA"
	_cQuery  += CR + "  AND SA1.A1_EMAIL   <> ''"
	_cQuery  += CR + "  AND SA1.A1_YNOTFAT <> 'N'" // Notifica atraso diferente de 'NÃO'
	_cQuery  += CR + "  AND SA1.D_E_L_E_T_ = ''"
	_cQuery  += CR
	_cQuery  += CR + "WHERE"
	_cQuery  += CR + "      SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"
	_cQuery  += CR + "  AND SE1.E1_VENCTO  BETWEEN '"+dtos(Date()-_nMVDiasAtraso)+"' AND '"+dtos(Date()+_nMVDiasAvanco)+"'"
	_cQuery  += CR + "  AND SE1.E1_SALDO   > 0"
	_cQuery  += CR + "  AND SE1.E1_TIPO    = 'NF'"
	_cQuery  += CR + "  AND SE1.D_E_L_E_T_ = ''"
	_cQuery  += CR
	_cQuery  += CR + "ORDER BY"
	_cQuery  += CR + "  SE1.E1_CLIENTE,"
	_cQuery  += CR + "  SE1.E1_LOJA,"
	_cQuery  += CR + "  SE1.E1_VENCREA,"
	_cQuery  += CR + "  SE1.E1_NUM,"
	_cQuery  += CR + "  SE1.E1_PARCELA"
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,strtran(_cQuery,CR," ")),_cAlsQry,.T.,.T.)
	
	//Captura informações para o envio da notificação
	do while !(_cAlsQry)->(eof())
		
		//Monta relação de clientes
		if ( ascan(_aClientes, {|a| a[1] == (_cAlsQry)->_CODCLI}) == 0 )
			aadd(_aClientes, {;
			/* 1 - Cliente*/ (_cAlsQry)->_CODCLI,;
			/* 2 - Nome   */ (_cAlsQry)->_NOME,;
			/* 3 - Email  */ (_cAlsQry)->_EMAIL} )
			
			conout("")
			conout("[SCHED500]  [Emp.: "+_cMyEmp+"] [Fil.: "+_cMyFil+"] "+dtoc(date())+" "+time()+" Identificando titulos em atraso do cliente: "+(_cAlsQry)->_CODCLI+" - "+alltrim((_cAlsQry)->_NOME))
			
		endif
		
		//Monta relacao de titulos
		aadd(_aTitulos, {;
		/* 01 - Cliente       */ (_cAlsQry)->_CODCLI,;
		/* 02 - Prefixo       */ (_cAlsQry)->_PREFIXO,;
		/* 03 - Numero        */ (_cAlsQry)->_NUMERO,;
		/* 04 - Parcela       */ (_cAlsQry)->_PARCELA,;
		/* 05 - Tipo          */ (_cAlsQry)->_TIPO,;
		/* 06 - Nota Fiscal   */ (_cAlsQry)->_NUMERO,;
		/* 07 - Emissao       */ stod((_cAlsQry)->_EMISSAO),;
		/* 08 - Vencto        */ stod((_cAlsQry)->_VENCTO),;
		/* 09 - Vencto Real   */ stod((_cAlsQry)->_VENCREAL),;
		/* 10 - Valor         */ (_cAlsQry)->_VALOR,;
		/* 11 - Dias de atraso*/ Date() - stod((_cAlsQry)->_VENCREAL)})
		
		conout("[SCHED500]  [Emp.: "+_cMyEmp+"] [Fil.: "+_cMyFil+"] "+dtoc(date())+" "+time()+" titulo: "+(_cAlsQry)->_PREFIXO+(_cAlsQry)->_NUMERO+(_cAlsQry)->_PARCELA+(_cAlsQry)->_TIPO)
		
		(_cAlsQry)->(DBSkip())
	enddo
	(_cAlsQry)->(DBCloseArea())
	
	//Monta o corpo do e-mail para os clientes
	conout("")
	conout("")
	for _ni := 1 to len(_aClientes)
		
		//Envia o e-mail para o cliente
	    conout("")
	    conout("===============================================================")
		conout("[SCHED500]  [Emp.: "+_cMyEmp+"] [Fil.: "+_cMyFil+"] "+dtoc(date())+" "+time()+" Enviando e-mail para o cliente: "+alltrim(_aClientes[_ni,1])+" "+alltrim(_aClientes[_ni,2])+" - ("+alltrim(_aClientes[_ni,3])+")...")
		
		if fEnviaEml(;
			/* Para      ... */ alltrim(_aClientes[_ni,3]),;
			/* Com Cópia ... */ _cMVCC,;
			/* Assunto ...   */ "[SCHED500] - Lembrete de Vencimento",;
			/* Corpo ...     */ fMontaMsg(_aClientes[_ni,1]))
			
	        conout("")
			conout("[SCHED500]  [Emp.: "+_cMyEmp+"] [Fil.: "+_cMyFil+"] "+dtoc(date())+" "+time()+" ...e-mail enviado com sucesso!")
	        conout("===============================================================")
			
		else
			
	        conout("")
			conout("[SCHED500]  [Emp.: "+_cMyEmp+"] [Fil.: "+_cMyFil+"] "+dtoc(date())+" "+time()+" ...ERRO! no envio do e-mail ... Notificando administracao do sistema ["+_cSMTPAdt+"].")
	        conout("###############################################################")
			
		endif
		
	next _ni
	
	conout("")
	conout("")
endif _lMVJobAtivo

// Fechando ambiente
RpcClearEnv()

conout("[SCHED500]  [Emp.: "+_cMyEmp+"] [Fil.: "+_cMyFil+"] "+dtoc(date())+" "+time()+" Fim do Job de Envio de Notificacoes de Titulos em Atraso aos Clientes.")
conout("--------------------------------------------------------------------------------------------------------------------------")

Return



/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Funcao para envio de e-mail.                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fEnviaEml( _cTO, _cCC, _cSubject, _cMensagem )
Local _cSMTPSrv  := GetMv("MV_RELSERV") // Servidor SMTP
Local _cSMTPAct  := GetMv("MV_RELACNT") // Conta de E-Mail Workflow
Local _cSMTPPsw  := GetMv("MV_RELAPSW") // Senha da Conta de E-Mail de Workflow
Local _cSMTPAdt  := GetMv("MV_MAILADT") // Conta de E-Mail de Auditoria
Local _lOK       := .F.
Local _cErros    := ""

Default _cCC := ""

CONNECT SMTP SERVER _cSMTPSrv ACCOUNT _cSMTPAct PASSWORD _cSMTPPsw RESULT _lOK

if _lOK
	
	// Autenticacao para envio
	Mailauth(_cSMTPAct,_cSMTPPsw)
	
	SEND MAIL;
	FROM    _cSMTPAct;  //DE
	TO      _cTO;       //PARA
	BCC     _cCC;       //COM COPIA
	SUBJECT _cSubject;  //ASSUNTO
	BODY    _cMensagem; //CONTEUDO
	RESULT _lOK
	
	if !_lOK
		
		GET MAIL ERROR _cErros
		
		SEND MAIL;
		FROM    _cSMTPAct;
		TO      _cSMTPAdt;
		SUBJECT "FALHA no envio do email: "+_cSubject;
		BODY "ANTEN?O!"+CRLF+;
		CRLF+"Ocorreu um erro ao enviar o e-mail com o subject '"+alltrim(_cSubject)+"'."+CRLF+;
		CRLF+"Segue detalhes do erro:"+CRLF+_cErros
		
	endif
	
else
	
	GET MAIL ERROR _cErros
	
	SEND MAIL;
	FROM    _cSMTPAct;
	TO      _cSMTPAdt;
	SUBJECT "FALHA no envio do email: "+_cSubject;
	BODY "ANTEN?O!"+CRLF+;
	CRLF+"Ocorreu um erro ao enviar o e-mail com o subject '"+alltrim(_cSubject)+"'."+CRLF+;
	CRLF+"Segue detalhes do erro:"+CRLF+_cErros
	
endif
Return _lOK



/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta corpo da Mensagem.                                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fMontaMsg( _cCodCli )
Local _cMailBody := ""
Local _nc        := ascan(_aClientes,{|a| a[1] == _cCodCli})
Local _nt        := ascan(_aTitulos ,{|a| a[1] == _cCodCli})

if (_nc > 0) .AND. (_nt > 0) // cliente possui titulos
	
	//Monta cabecalho do e-mail
	_cMailBody += '<p>Prezado&nbsp;<strong>'+alltrim(_aClientes[_nc][2])+'</strong>;</p>'
	
	_cMailBody += '<p style="text-align:justify">Para o seu melhor controle informamos do vencimento do(s) seguinte(s) titulo(s) em seu nome:</p>'
	
	//Monta relação de titulos
	_cMailBody += '<p style="text-align: justify;">&nbsp;</p>'
	_cMailBody += '<table align="center" border="2" cellpadding="1" cellspacing="1" style="width:750px">'
	_cMailBody += '	<caption><strong>t&iacute;tulo(s) em aberto</strong></caption>'
	_cMailBody += '	<thead>'
	_cMailBody += '		<tr>'
	_cMailBody += '			<th scope="col">N.Fiscal</th>'
	_cMailBody += '			<th scope="col">Emiss&atilde;o</th>'
	_cMailBody += '			<th scope="col">Venc.</th>'
	_cMailBody += '			<th scope="col">Valor</th>'
	_cMailBody += '		</tr>'
	_cMailBody += '	</thead>'
	_cMailBody += '	<tbody>'
	do while (_nt <= len(_aTitulos)) .AND. (_aTitulos[_nt][1] == _cCodCli)
		
		_cMailBody += '		<tr>'
		_cMailBody += '			<td style="text-align:center">'+_aTitulos[_nt][06]+'</td>'       //NFiscal
		_cMailBody += '			<td style="text-align:center">'+dtoc(_aTitulos[_nt][07])+'</td>' //Emissao
		_cMailBody += '			<td style="text-align:center">'+dtoc(_aTitulos[_nt][08])+'</td>' //Vencto
		_cMailBody += '			<td style="text-align:right"> R$ '+alltrim(transform(_aTitulos[_nt][10],"@E 999,999,999.99"))+'</td>' //Valor
		_cMailBody += '		</tr>'
		
		_nt++
	enddo
	_cMailBody += '	</tbody>'
	_cMailBody += '</table>'
	
	//Rodape do e-mail
	_cMailBody += '<p style="text-align: justify;">&nbsp;</p>'
	
	
	//Se a filial for 'OXITRIO', mensagem especifica
	if 	(_cMyFil == "0201")
		
		_cMailBody += '<p style="text-align: justify;">Caso j&aacute; tenha efetuado o pagamento, favor desconsiderar esse aviso!&nbsp;Em caso de d&uacute;vidas, '
		_cMailBody += 'favor entrar&nbsp;em contato com o Departamento Financeiro da OXITRIO GASES atrav&eacute;s dos&nbsp;seguintes&nbsp;telefones: (27) 3225-6533 '
		_cMailBody += '/ (27) 3336-2163 / (27) 99287-0100 ou pelo E-mail: <a href="mailto:financeiro@tecnocryo.com.br?subject=R%3A%20Lembrete%20de%20Vencimento">financeiromg@tecnocryo.com.br</a></p>'
		
	else //Senao, mensagem especifica para a 'TECNOCRYO'
		
		_cMailBody += '<p style="text-align: justify;">Caso j&aacute; tenha efetuado o pagamento, favor desconsiderar esse aviso!&nbsp;Em caso de d&uacute;vidas, '
		_cMailBody += 'favor entrar&nbsp;em contato com o Departamento Financeiro da TECNOCRYO GASES atrav&eacute;s dos&nbsp;seguintes&nbsp;telefones: (27) 3225-6533 '
		_cMailBody += '/ (27) 3336-2163 / (27) 99287-0100 ou pelo E-mail: <a href="mailto:financeiro@tecnocryo.com.br?subject=R%3A%20Lembrete%20de%20Vencimento">financeiro@tecnocryo.com.br</a></p>'
		
	endif
	
	_cMailBody += '<p>&nbsp;</p>'
	_cMailBody += '<p>Atenciosamente,</p>'
	
	_cMailBody += '<p>&nbsp;</p>'
	_cMailBody += '<p><strong><em>Equipe Tecnocryo Gases</em></strong></p>'
	
	_cMailBody += '<p>&nbsp;</p>'
	_cMailBody += '<p><span style="font-family:times new roman,times,serif">&lt;&lt; Este &eacute; um e-mail gerado automaticamente por sistema, favor n&atilde;o respond&ecirc;-lo! &gt;&gt;</span></p>'
	
endif
Return _cMailBody