#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA491     ³ Autor ³ Wanisay William       ³ Data ³ 16.04.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envio de e-mail SUFRAMA. ate 90 dias 						            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA491(AA_EMP)

If Type("DDATABASE") <> "D"
	DO CASE
		CASE AA_EMP == "01"
			RPCSETENV("01","01",,,"FAT")
		CASE AA_EMP == "05"
			RPCSETENV("05","01",,,"FAT")
		CASE AA_EMP == "07"
			RPCSETENV("07","01",,,"FAT")
		CASE AA_EMP == "13"
			RPCSETENV("13","01",,,"FAT")
	ENDCASE
EndIf

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
//conout('BIA491-INICIADO')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada de Funcoes                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| Analisa_SUF()})

//conout('BIA491-ENCERRADO')

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaArq   ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Analisa_SUF()

//conout('BIA491-1')

cQuery := "SELECT	" + Enter
cQuery := cQuery + "  F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, A1_NOME, F2_EMISSAO " + Enter
cQuery := cQuery + "  FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SA1")+" SA1, "+RetSqlName("SD2")+" SD2 " + Enter

cQuery := cQuery + "  WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'  "
cQuery := cQuery + "  AND SA1.A1_FILIAL   = '"+xFilial("SA1")+"' "
cQuery := cQuery + "  AND SD2.D2_FILIAL   = '"+xFilial("SD2")+"' "
cQuery := cQuery + "  AND SF2.F2_CLIENTE = SA1.A1_COD     "
cQuery := cQuery + "  AND SF2.F2_LOJA    = SA1.A1_LOJA    "

cQuery := cQuery + "  AND SF2.F2_DOC     = SD2.D2_DOC     "
cQuery := cQuery + "  AND SF2.F2_SERIE   = SD2.D2_SERIE   "
cQuery := cQuery + "  AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
cQuery := cQuery + "  AND SF2.F2_LOJA    = SD2.D2_LOJA    "
cQuery := cQuery + "  AND SD2.D2_ITEM    = '01'           "
cQuery := cQuery + "  AND SD2.D2_CF IN ('5101','6101','5118','6118','5107','6107','5109','6109','5110','6110','5401','6401','5922','6922') "

cQuery := cQuery + "  AND SF2.F2_EST IN ('AM','AP','AC','RO','RR') "
cQuery := cQuery + "  AND SA1.A1_SUFRAMA <> '' "
cQuery := cQuery + "  AND SF2.F2_TIPO   = 'N' "
cQuery := cQuery + "  AND SF2.F2_YDTINT = ''  "

cQuery := cQuery + "  AND SF2.D_E_L_E_T_ = '' " + Enter
cQuery := cQuery + "  AND SA1.D_E_L_E_T_ = '' " + Enter
cQuery := cQuery + "  ORDER BY SF2.F2_CLIENTE, SF2.F2_LOJA, SA1.A1_NOME " + Enter

If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cQuery ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGotop()
//conout('BIA491-2')
Setprc(0,0)
cEmail   := ''

While ! EOF()
	
	//conout('BIA491-3')
	
	IF (dDatabase - STOD(QRY->F2_EMISSAO)) >= 60 .AND. (dDatabase - STOD(QRY->F2_EMISSAO)) < 90
		cEmail := U_EmailWF('BIA491',cEmpAnt) 
		IF cItem = 1
			cMENS := cMENS+'<TR bgcolor="#33CCFF">'
			cItem := 0
		ELSE
			cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
			cItem := 1
		ENDIF
		
		nItemPrd := nItemPrd + 1
		
		nDias := DDATABASE - (STOD(QRY->F2_EMISSAO) + 120)
		dPrazo := DTOS(STOD(QRY->F2_EMISSAO) + 120)
		
		cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
		cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->F2_CLIENTE+"/"+QRY->F2_LOJA+'</TD>'
		cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+QRY->A1_NOME+'</TD>'
		cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->F2_SERIE+"/"+QRY->F2_DOC+'</TD>'
		cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->F2_EMISSAO,7,2)+"/"+SUBSTR(QRY->F2_EMISSAO,5,2)+"/"+SUBSTR(QRY->F2_EMISSAO,1,4)+'</TD>'
		cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(dPrazo,7,2)+"/"+SUBSTR(dPrazo,5,2)+"/"+SUBSTR(dPrazo,1,4)+'</TD>'
		cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nDias,5)+'</TD>'
		cMENS := cMENS+'</TR>'
	ENDIF
	
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
cMensag := cMensag+'<TITLE> Relação de Clientes com documentação SUFRAMA em aberto até 90 dias.</TITLE> '

// DADOS DA BIANCOGRES
cMensag := cMensag+'<BODY> '
cMensag := cMensag+'<FONT face="Verdana" size="1"> '
// MENSAGENS AUTOMATICAS
cMensag := cMensag+'<BR> '
// OBSERVACOES
cMensag := cMensag+'<BR> Segue abaixo a relação de clientes com documentação SUFRAMA em aberto até 90 dias - '+ALLTRIM(SM0->M0_NOMECOM)+':'
cMensag := cMensag+'<BR> '
// DADOS DA TABELA
cMensag := cMensag+'<TABLE border="1"> '
cMensag := cMensag+'<TR bgcolor="#0000CC" bordercolor="#999999"> '
cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Cliente/Loja</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Razão Social</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Serie/NF</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data da emissão</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Prazo de validade para Bloqueio</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Atraso em dias</div></TD> '
cMensag := cMensag+'</TR> '
cMensag := cMensag+cMENS
cMensag := cMensag+'</TABLE> '
// RODAPE
cMensag := cMensag+'<BR> '
cMensag := cMensag+'<BR> Atenciosamente,'
cMensag := cMensag+'<BR> '
cMensag := cMensag+'<BR>Qualquer dúvida entre em contato com o departamento contábil. '
cMensag := cMensag+'Este e-mail é automático.'+'<BR> '
cMensag := cMensag+'Não Responda esta mensagem.'+'<BR> '
cMensag := cMensag+'<BR> '

cMensag := cMensag+'</BODY> '
cMensag := cMensag+'</HTML>'

cAssunto	:= 'Relação de Clientes com documentação SUFRAMA em aberto até 90 dias' 			  // Assunto do Email

U_BIAEnvMail(,cEmail,cAssunto,cMensag)

cMensag  := ''
cMens    := ''
nItemPrd := 0
Return