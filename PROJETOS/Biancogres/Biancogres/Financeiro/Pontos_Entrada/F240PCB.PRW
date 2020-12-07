#INCLUDE "TOTVS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ 	F240TIT     ³ Autor ³BRUNO MADALENO        ³ Data ³ 22/06/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ VERIFICA SE O TITULO NA MONTAGEM DO BORDERO TEM PA EM ABERTO    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION F240OK()
	
	Local cMvUsrCan := GetNewPar("MV_YUSCANB", "GARDENIA|MIKAELLY|RANISSES")
	
	Private aCampos1
	Private ENTER      := CHR(13) + CHR(10)
	Private lOK        := .F.
	Private nValor     := 0

	Private aLista     := {}
	Private nI         := 1
	Private cMensagem  := ''
	Private lOK_2      := .F.
	Private lSexta     := .F.
	Private lErro      := .F.
	Private cERRO      := ''
	Private nLastKey   := 0
	Private cItem 	   := 1
	Private cMensag    := ''
	Private cMens      := ''
	Private nItemPrd   := 0
	Private cEmail     := ''
	Private cMotivo    := SPACE(60)
	Private cCodigo    := SPACE(3)
	
	If (! Empty(cMvUsrCan) .And. !(Alltrim(cUsername) $ cMvUsrCan)) .AND. !(Alltrim(cUsername) $ "FACILE")
	
		 MsgAlert("Seu usuário não possui permissão para cancelamento de bordero!" + CRLF + CRLF + "Verifique com seu gestor imediato!", "ATENCAO")
		 
		 Return(.F.)
	
	EndIf

	_aCampos1:=	{ {"PREFIXO" 	,"C",03,0},;
		{"NUMERO" 		,"C",09,0},;
		{"PARCELA"	  	,"C",01,0},;
		{"TIPO"  		,"C",03,0},;
		{"FORNECE"   	,"C",06,0},;
		{"LOJA"	     	,"C",02,0},;
		{"VALOR"     	,"N",12,2}}
		
	If ChkFile("_TIT")
	
		dbSelectArea("_TIT")
		dbCloseArea()
		
	EndIf
	
	_TIT := CriaTrab(_aCampos1,.T.)
	
	dbUseArea(.T.,,_TIT,"_TIT")
	
	dbCreateInd(_TIT,"PREFIXO+NUMERO+PARCELA+TIPO+FORNECE+LOJA",{||PREFIXO+NUMERO+PARCELA+TIPO+FORNECE+LOJA})

	cQUERY := "SELECT	EA_PREFIXO, EA_NUM, EA_PARCELA, EA_TIPO, EA_FORNECE, EA_LOJA, EA_YVALOR, EA_DATABOR " + ENTER
	cQUERY += "FROM "+RETSQLNAME("SEA")+" 					" + ENTER
	cQUERY += "WHERE	EA_FILIAL	=  '"+xFilial("SEA")+"'	" + ENTER
	cQUERY += "			AND	EA_NUMBOR   =  '"+MV_PAR01+"'	" + ENTER
	cQUERY += "			AND EA_CART     = 'P'				" + ENTER
	cQUERY += "			AND D_E_L_E_T_ 	= ' '				" + ENTER
	If ChkFile("QRY")
		dbSelectArea("QRY")
		dbCloseArea()		
	EndIf
	TCQUERY cQUERY ALIAS "QRY" NEW

	QRY->(DbGoTop())

	If QRY->(EOF())
		
		MsgAlert("Borderô não encontrado!")
		
		Return(.F.)

	EndIf

	While !QRY->(EOF())
	
		RecLock("_TIT",.T.)
		_TIT->PREFIXO 		:= QRY->EA_PREFIXO
		_TIT->NUMERO 	  	:= QRY->EA_NUM
		_TIT->PARCELA 		:= QRY->EA_PARCELA
		_TIT->TIPO			:= QRY->EA_TIPO
		_TIT->FORNECE		:= QRY->EA_FORNECE
		_TIT->LOJA 			:= QRY->EA_LOJA
		_TIT->VALOR		  	:= QRY->EA_YVALOR
		MsUnlock()
	
		nValor := nValor + QRY->EA_YVALOR
	
		cEmail := 'mikaelly.viana@biancogres.com.br;gardenia.stelzer@biancogres.com.br'
	
		IF cItem = 1
			cMENS := cMENS+'<TR bgcolor="#33CCFF">'
			cItem := 0
		ELSE
			cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
			cItem := 1
		EndIf

		DbSelectArea("SA2")
		DbSeek(xFilial("SA2")+QRY->EA_FORNECE+QRY->EA_LOJA)
  	
		nItemPrd := nItemPrd + 1
	
		cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
		cMENS := cMENS+'<TD width="150" valign="Top"><FONT face="Verdana" size="1">'+ALLTRIM(QRY->EA_PREFIXO)+"/"+ALLTRIM(QRY->EA_NUM)+"/"+ALLTRIM(QRY->EA_PARCELA)+"/"+ALLTRIM(QRY->EA_TIPO)+'</TD>'
		cMENS := cMENS+'<TD width="300" valign="Top"><FONT face="Verdana" size="1">'+QRY->EA_FORNECE+"/"+QRY->EA_LOJA+" - "+SA2->A2_NOME+'</TD>'
		cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+TRANSFORM(QRY->EA_YVALOR,"@E 999,999.99")+'</TD>'
		cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->EA_DATABOR,7,2)+"/"+SUBSTR(QRY->EA_DATABOR,5,2)+"/"+SUBSTR(QRY->EA_DATABOR,3,2)+'</TD>'
		cMENS := cMENS+'</TR>'
	
		QRY->(DbSkip())
		
	EndDo

	aCampos1 := {}
	
	AADD(aCampos1,{"PREFIXO"	, "Prefixo" 		,3})
	AADD(aCampos1,{"NUMERO"		, "Numero" 			,9})
	AADD(aCampos1,{"PARCELA"	, "Parcela" 		,3})
	AADD(aCampos1,{"TIPO"		, "Tipo" 			,3})
	AADD(aCampos1,{"FORNECE"	, "Fornecedor"  	,6})
	AADD(aCampos1,{"LOJA"		, "Loja" 	  		,2})
	AADD(aCampos1,{"VALOR"	  	, "Valor"  			,16})

	Markbrow1()

Return(lOK_2)

Static Function Markbrow1()

	@ 96,42 TO 750,1000 DIALOG oEntra01 TITLE "BORDERÔS" //FRMULARIO
	@ 02,03 TO 50 ,475   // PRIMEIRO FRAME FRAME
	@ 010,007 SAY "Número do Borderô: " + Alltrim(MV_PAR01)
	@ 025,007 SAY "Valor   do   Borderô: R$ " + Alltrim(Transform(nValor, "@E 99,999,999.99"))
	@ 040,007 SAY "Motivo do cancelamento: "
	@ 040,070 GET cCodigo  PICTURE "@!" F3 "ZX" VALID fValid()
	@ 040,102 GET cMotivo  PICTURE "@!" When .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta MarkBrowse...                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrowse := IW_Browse(70,09,260,470,"_TIT",,,aCampos1)

	@ 275,007 BUTTON "_Confirmar" SIZE 30,15 ACTION FConfirma()   // Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 55,20 BUTTON "_Submeter" SIZE 30,15 ACTION Execute(fSubmit)
	@ 275,040 BUTTON "_Sair"      SIZE 30,15 ACTION FSair()       // Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 55,60 BUTTON "_Abortar"  SIZE 30,15 ACTION Execute(fAborta)

	ACTIVATE DIALOG oEntra01 ON INIT Eval({|| MsAguarde(), _TIT->(DbGoTop()), oBrowse:oBrowse:Refresh(), }) Centered

Return()

Static Function FSair()

	lOK_2 := .F.
	Close(oEntra01)
	MsgBox("O Borderô: "+ALLTRIM(MV_PAR01)+" não foi cancelado!","STOP")

Return()

Static Function FConfirma()

	Local oObjBor := TAFBorderoPagar():New()

	lOK_2 := .T.
	
	oObjBor:CleanRegra(MV_PAR01)
	
	Close(oEntra01)
	
	MsgBox("O Borderô: "+ALLTRIM(MV_PAR01)+" foi cancelado!","ALERT")

	IF !EMPTY(cMENS)
	
		Envioemail()
		
	EndIf
	
Return()

Static Function Envioemail()

	cMensag  := ''
	cMensag := cMensag+'<HTML>'
	cMensag := cMensag+'<script language="JavaScript"><!--'+;
		'function MM_reloadPage(init) {  //reloads the window if Nav4 resized'+;
		'if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {'+;
		'document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}'+;
		'else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();'+;
		'}'+;
		'MM_reloadPage(true);// -->'

	cMensag := cMensag+'</script> '
	cMensag := cMensag+'<TITLE> Cancelamento de Borderô.</TITLE> '

	// DADOS DA BIANCOGRES
	cMensag := cMensag+'<BODY> '
	cMensag := cMensag+'<FONT face="Verdana" size="1"> '
	// MENSAGENS AUTOMATICAS
	cMensag := cMensag+'<BR> '
	// OBSERVACOES
	cMensag := cMensag+'<BR> Segue abaixo a relação de títulos do borderô cancelado: '+ALLTRIM(MV_PAR01)
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<BR> Valor Total do Borderô: R$ '+Alltrim(Transform(nValor, "@E 99,999,999.99"))
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<BR> Motivo do cancelamento: '+Alltrim(cMotivo)
	// DADOS DA TABELA
	cMensag := cMensag+'<TABLE border="1"> '
	cMensag := cMensag+'<TR bgcolor="#0000CC" bordercolor="#999999"> '
	cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Título => Prefixo/Número/Parcela/Tipo</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Fornecedor/Loja e Razão Social</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Valor em R$</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data do Borderô</div></TD> '

	cMensag := cMensag+'</TR> '
	cMensag := cMensag+cMENS
	cMensag := cMensag+'</TABLE> '
	// RODAPE
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<BR> Atenciosamente,'
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<BR>Qualquer dúvida entre em contato com o setor de TI. '
	cMensag := cMensag+'Este e-mail é automático.'+'<BR> '
	cMensag := cMensag+'Não Responda esta mensagem.'+'<BR> '
	cMensag := cMensag+'<BR> '

	cMensag := cMensag+'</BODY> '
	cMensag := cMensag+'</HTML>'

	cRecebe   	:= cEmail						// Email do(s) receptor(es)
	cAssunto	:= 'Cancelamento de Borderô'    // Assunto do Email

	U_BIAEnvMail(,cRecebe,cAssunto,cMensag)

	cMensag  := ''
	cMens    := ''
	nItemPrd := 0

Return()

Static Function fValid()

	Local lRet := .F.
	Local cDesc := ""
	
	cDesc := Tabela("ZX", cCodigo, .F.)
	
	If !Empty(cDesc)
	
		lRet := .T.
		cMotivo := cDesc
		
	EndIf
	
Return(lRet)