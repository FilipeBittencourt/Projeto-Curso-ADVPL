#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA486     ³ Autor ³ Wanisay William       ³ Data ³ 01.07.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envio de e-mail com SC bloqueada                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA486(AA_EMP)

If Type("DDATABASE") <> "D"
	DO CASE
	   CASE AA_EMP == "01"
		RPCSETENV("01","01",,,"COM")
     CASE AA_EMP == "05"
		RPCSETENV("05","01",,,"COM")
     CASE AA_EMP == "07"
		RPCSETENV("07","01",,,"COM")
     CASE AA_EMP == "12"
		RPCSETENV("12","01",,,"COM")
     CASE AA_EMP == "13"
		RPCSETENV("13","01",,,"COM")
	ENDCASE
EndIf
													 	// Senha = senha
Private aLista     := {}
Private nI         := 1
Private cMensagem  := ''
Private lOK        := .F.
Private lSexta     := .F.
Private lErro      := .F.
Private cERRO      := ''
Private nLastKey   := 0
Private cItem 	   := 1
Private cMensag    := ''
Private cMens      := ''
Private nItemPrd   := 0
Private cEmail     := ''
Private Enter      := CHR(13)+CHR(10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada de Funcoes                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| Analisa_SC()})

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaArq   ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Enviar e-mail com a relação de SC aguardando aprovação
Static Function Analisa_SC()

cSql7 := "SELECT Z0_CODSUP, C1_NUM, Z0_NOME, ZZ4_NOME, ZZ4_EMAIL, C1_EMISSAO, C1_CLVL  "
cSql7 += "FROM "+RetSqlName("SC1")+" SC1, "+RetSqlName("SZ0")+" SZ0, ZZ4010 ZZ4 "
cSql7 += "WHERE C1_FILIAL = '01' "
cSql7 += "AND C1_YMAT <> '' "
cSql7 += "AND SC1.D_E_L_E_T_ = '' "
cSql7 += "AND SZ0.D_E_L_E_T_ = '' "
cSql7 += "AND C1_YMAT = Z0_MAT "
cSql7 += "AND C1_CLVL = Z0_CLVL "
cSql7 += "AND Z0_CODSUP = ZZ4_COD "
cSql7 += "AND C1_PEDIDO = '' "
cSql7 += "AND C1_APROV = 'B' "
cSql7 += "AND C1_COTACAO = '' "
cSql7 += "AND C1_QUJE = 0 "
cSql7 += "AND SC1.D_E_L_E_T_ = '' "
cSql7 += "AND SZ0.D_E_L_E_T_ = '' "
cSql7 += "GROUP BY Z0_CODSUP, C1_NUM, Z0_NOME, ZZ4_NOME, ZZ4_EMAIL, C1_EMISSAO, C1_CLVL "
cSql7 += "ORDER BY Z0_CODSUP, C1_NUM, Z0_NOME, ZZ4_NOME, ZZ4_EMAIL, C1_EMISSAO, C1_CLVL "
	
If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cSQL7 ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGoTop()
ProcRegua(RecCount())

Setprc(0,0)
cEmail   := ''
cEmailCC := ''
cSup     := QRY->Z0_CODSUP
lProduto := .F.

While ! EOF()
	
	IF !EMPTY(cMENS) .AND. ALLTRIM(cSup) <> ALLTRIM(QRY->Z0_CODSUP)
		Envioemail()
	ENDIF
  
  //Regra inserida a pedido do Beirão para receber o e-mail apenas às 12:00 horas.
	IF SUBS(TIME(),1,2) <> '12' .AND. AT('beirao',QRY->ZZ4_EMAIL) <> 0
		 DbSelectArea("QRY")
		 DbSkip()
	   Loop	
	ENDIF                                                                          
	
  //Regra inserida a pedido do Elaercio para receber o e-mail apenas às 11:00 horas e 17:00 horas.
	IF (SUBS(TIME(),1,2) <> '11' .AND. SUBS(TIME(),1,2) <> '17') .AND. AT('elaercio',QRY->ZZ4_EMAIL) <> 0
		 DbSelectArea("QRY")
		 DbSkip()
	   Loop	
	ENDIF

  //Regra inserida a pedido do Claudeir para receber o e-mail apenas às 08:00 horas, 12:00 horas e 18:00 horas.
	IF (SUBS(TIME(),1,2) <> '08' .AND. SUBS(TIME(),1,2) <> '12' .AND. SUBS(TIME(),1,2) <> '18') .AND. AT('claudeir',QRY->ZZ4_EMAIL) <> 0
		 DbSelectArea("QRY")
		 DbSkip()
	   Loop	
	ENDIF
	
	IF !EMPTY(QRY->ZZ4_EMAIL)
		cEmail   := QRY->ZZ4_EMAIL
		cEmailCC :=	''
	ELSE
		cEmail   := 'wanisay.william@biancogres.com.br'
		cEmailCC := ''
	ENDIF                 
	
	IF cItem = 1
		cMENS := cMENS+'<TR bgcolor="#33CCFF">'
		cItem := 0
	ELSE
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 1
	ENDIF
	
	nItemPrd := nItemPrd + 1
	
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C1_NUM+'</TD>'
	cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+QRY->Z0_NOME+'</TD>'
	cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+QRY->C1_EMISSAO+'</TD>'
	cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+QRY->C1_CLVL+'</TD>'
	cMENS := cMENS+'</TR>'
	
	cSup := QRY->Z0_CODSUP
	
	DbSelectArea("QRY")
	DbSkip()
END

IF !EMPTY(cMENS)
	Envioemail()
ENDIF

DbSelectArea("QRY")
DbCloseArea()

//-------------------------------------------------------------------------------------------
//Enviar e-mail com a relação de SC com produtos/serviços novos aguardando cadastro
cSql8 := "SELECT Z0_MAT, C1_NUM, Z0_NOME, ZZ4_NOME, Z0_EMAIL, C1_EMISSAO, C1_CLVL  "
cSql8 += "FROM "+RetSqlName("SC1")+" SC1, "+RetSqlName("SZ0")+" SZ0, ZZ4010 ZZ4 "
cSql8 += "WHERE C1_FILIAL = '01' "
cSql8 += "AND C1_YMAT <> '' "
cSql8 += "AND SC1.D_E_L_E_T_ = '' "
cSql8 += "AND SZ0.D_E_L_E_T_ = '' "
cSql8 += "AND C1_YMAT = Z0_MAT "
cSql8 += "AND C1_CLVL = Z0_CLVL "
cSql8 += "AND Z0_CODSUP = ZZ4_COD "
cSql8 += "AND C1_PEDIDO = '' "
cSql8 += "AND C1_APROV = 'L' "
cSql8 += "AND C1_COTACAO = '' "
cSql8 += "AND C1_QUJE = 0 "
cSql8 += "AND C1_WFID = '100002' "
cSql8 += "AND SUBSTRING(C1_PRODUTO,1,4) = 'NOVO' "
cSql8 += "GROUP BY Z0_MAT, C1_NUM, Z0_NOME, ZZ4_NOME, Z0_EMAIL, C1_EMISSAO, C1_CLVL "
cSql8 += "ORDER BY Z0_MAT, C1_NUM, Z0_NOME, ZZ4_NOME, Z0_EMAIL, C1_EMISSAO, C1_CLVL "

If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cSQL8 ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGoTop()
ProcRegua(RecCount())

Setprc(0,0)
cEmail   := ''
cEmailCC := ''
cSup     := QRY->Z0_MAT
lProduto := .T.
cItem 	 := 1
cMensag  := ''
cMens    := ''
nItemPrd := 0

While ! EOF()
	
	IF !EMPTY(cMENS) .AND. ALLTRIM(cSup) <> ALLTRIM(QRY->Z0_MAT)
		Envioemail()
	ENDIF

  //Regra inserida a pedido do Beirão para receber o e-mail apenas às 12:00 horas.
	IF SUBS(TIME(),1,2) <> '12' .AND. AT('beirao',QRY->Z0_EMAIL) <> 0
		 DbSelectArea("QRY")
		 DbSkip()
	   Loop	
	ENDIF                                                                          
	
  //Regra inserida a pedido do Elaercio para receber o e-mail apenas às 11:00 horas e 17:00 horas.
	IF (SUBS(TIME(),1,2) <> '11' .AND. SUBS(TIME(),1,2) <> '17') .AND. AT('elaercio',QRY->Z0_EMAIL) <> 0
		 DbSelectArea("QRY")
		 DbSkip()
	   Loop	
	ENDIF

  //Regra inserida a pedido do Claudeir para receber o e-mail apenas às 08:00 horas, 12:00 horas e 18:00 horas.
	IF (SUBS(TIME(),1,2) <> '08' .AND. SUBS(TIME(),1,2) <> '12' .AND. SUBS(TIME(),1,2) <> '18') .AND. AT('claudeir',QRY->Z0_EMAIL) <> 0
		 DbSelectArea("QRY")
		 DbSkip()
	   Loop	
	ENDIF

	IF !EMPTY(QRY->Z0_EMAIL)
		IF cEmpAnt == '01'  .OR. cEmpAnt == '07' .OR. cEmpAnt == '12' .OR. cEmpAnt == '13'
			cEmail   := QRY->Z0_EMAIL+';masato.kuranouchi@biancogres.com.br'        
		ELSE 
			cEmail   := QRY->Z0_EMAIL        			
		ENDIF
		cEmailCC :=	''
	ELSE
		cEmail   := 'wanisay.william@biancogres.com.br'
		cEmailCC := ''
	ENDIF
	
	IF cItem = 1
		cMENS := cMENS+'<TR bgcolor="#33CCFF">'
		cItem := 0
	ELSE
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 1
	ENDIF
	
	nItemPrd := nItemPrd + 1
	
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C1_NUM+'</TD>'
	cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+QRY->Z0_NOME+'</TD>'
	cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+QRY->C1_EMISSAO+'</TD>'
	cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+QRY->C1_CLVL+'</TD>'
	cMENS := cMENS+'</TR>'
	
	cSup := QRY->Z0_MAT
	
	DbSelectArea("QRY")
	DbSkip()
END

IF !EMPTY(cMENS)
	Envioemail()
ENDIF

DbSelectArea("QRY")
DbCloseArea()
Return

Static Function Envioemail()  

Local lOk

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
IF lProduto
	cMensag := cMensag+'<TITLE> Relaçãp de Solicitações de Compras aguardando cadastramento de produto/serviço novo </TITLE> '
ELSE
	cMensag := cMensag+'<TITLE> Relaçãp de Solicitações de Compras não aprovadas </TITLE> '
ENDIF
// DADOS DA BIANCOGRES
cMensag := cMensag+'<BODY> '
cMensag := cMensag+'<FONT face="Verdana" size="1"> '
// MENSAGENS AUTOMATICAS
cMensag := cMensag+'<BR> '
// OBSERVACOES
IF lProduto
	cMensag := cMensag+'<BR> Segue abaixo a relação das solicitações de compras que estão aguardando produtos/serviços novos serem cadastrados na Empresa '+ALLTRIM(SM0->M0_NOMECOM)+':'
ELSE
	cMensag := cMensag+'<BR> Segue abaixo a relação das solicitações de compras não aprovadas até o dia de hoje na Empresa '+ALLTRIM(SM0->M0_NOMECOM)+':'
ENDIF
cMensag := cMensag+'<BR> '
// DADOS DA TABELA
cMensag := cMensag+'<TABLE border="1"> '
cMensag := cMensag+'<TR bgcolor="#0000CC" bordercolor="#999999"> '
cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Número SC-e</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Nome do Solicitante</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Emissão</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Classe de Valor</div></TD> '
cMensag := cMensag+'</TR> '
cMensag := cMensag+cMENS
cMensag := cMensag+'</TABLE> '
// RODAPE
cMensag := cMensag+'<BR> '
cMensag := cMensag+'<BR> Atenciosamente,'
cMensag := cMensag+'<BR> '
cMensag := cMensag+'<BR>Qualquer dúvida entre em contato com o Setor de Almoxarifado. '
cMensag := cMensag+'Este e-mail é automático.'+'<BR> '
cMensag := cMensag+'Não Responda esta mensagem.'+'<BR> '
cMensag := cMensag+'<BR> '

cMensag := cMensag+'</BODY> '
cMensag := cMensag+'</HTML>'						  								 									  // Copia Oculta

IF lProduto
	cAssunto	:= 'Relação das SC-e aguardando cadastro de novo produto/serviço' 			  // Assunto do Email
ELSE
	cAssunto	:= 'Relação das SC-e aguardando aprovação' 			  								// Assunto do Email
ENDIF

lOK := U_BIAEnvMail(,ALLTRIM(cEmail),cAssunto,cMensag,,,,cEmailCC)

IF lOK
	conout('BIA468 - ENVIADO COM SUCESSO')
ELSE
	conout('BIA468 - FALHA AO ENVIAR EMAIL')
ENDIF

cMensag  := ''
cMens    := ''
nItemPrd := 0
Return