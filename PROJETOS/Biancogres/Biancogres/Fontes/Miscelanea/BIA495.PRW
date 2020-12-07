#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA495     ³ Autor ³ Wanisay William       ³ Data ³ 03.05.12      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara envio de e-mail caso a LM tenha produtos em estoque       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA495(AA_EMP)

If Type("DDATABASE") <> "D"
	DO CASE
		CASE AA_EMP == "07"
			RPCSETENV("07","01",,,"FAT")
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
//conout('BIA495-INICIADO')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada de Funcoes                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipo := '1'
Processa({|| Analisa_EST()})

//conout('BIA495-ENCERRADO')

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaArq   ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Analisa_EST()

//conout('BIA495-1')

		cQuery := "SELECT	" + Enter
		cQuery := cQuery + "  B2_COD, B1_DESC, B2_LOCAL, B1_UM, B2_QATU, B1_SEGUM, B2_QTSEGUM  " + Enter
		cQuery := cQuery + "  FROM SB2070 SB2, SB1010 SB1  " + Enter
		cQuery := cQuery + "  WHERE B2_FILIAL = '"+xFilial('SB2')+"' " + Enter
		cQuery := cQuery + "  AND B2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZ'  " + Enter
		cQuery := cQuery + "  AND B1_TIPO = 'PA'  " + Enter
		cQuery := cQuery + "  AND B1_COD = B2_COD   " + Enter
		cQuery := cQuery + "  AND B2_QATU > 0   " + Enter
		cQuery := cQuery + "  AND SB1.D_E_L_E_T_ = ''  " + Enter
		cQuery := cQuery + "  AND SB2.D_E_L_E_T_ = ''  " + Enter
		cQuery := cQuery + "  ORDER BY B2_COD  " + Enter

If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cQuery ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGotop()
//conout('BIA495-2')
Setprc(0,0)
cEmail   := ''

While ! EOF()
	
	//conout('BIA495-3')

	cEmail := U_EmailWF('BIA495',cEmpAnt) 
	
	IF cItem = 1
		cMENS := cMENS+'<TR bgcolor="#33CCFF">'
		cItem := 0
	ELSE
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 1
	ENDIF
	
	nItemPrd := nItemPrd + 1
	
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
	cMENS := cMENS+'<TD width="300" valign="Top"><FONT face="Verdana" size="1">'+ALLTRIM(QRY->B2_COD)+" - "+ALLTRIM(QRY->B1_DESC)+'</TD>'
	cMENS := cMENS+'<TD width="35" valign="Top"><FONT face="Verdana" size="1">'+QRY->B2_LOCAL+'</TD>'
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+QRY->B1_UM+'</TD>'
	cMENS := cMENS+'<TD width="100"  valign="Top"><FONT face="Verdana" size="1">'+TRANSFORM(QRY->B2_QATU,"@E 999,999.99")+'</TD>'
	cMENS := cMENS+'<TD width="35" valign="Top"><FONT face="Verdana" size="1">'+QRY->B1_SEGUM+'</TD>'   
	cMENS := cMENS+'<TD width="100"  valign="Top"><FONT face="Verdana" size="1">'+TRANSFORM(QRY->B2_QTSEGUM,"@E 999,999.99")+'</TD>'	
	cMENS := cMENS+'</TR>'
	
	DbSelectArea("QRY")
	DbSkip()
END

IF !EMPTY(cMENS)
	//conout('BIA495-5')
	Envioemail()
ENDIF

DbSelectArea("QRY")
DbCloseArea()

Return

Static Function Envioemail()

//conout('BIA495-6')
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
cMensag := cMensag+'<TITLE> Relação de produtos que permaneceram no estoque da empresa LM.</TITLE> '

// DADOS DA BIANCOGRES
cMensag := cMensag+'<BODY> '
cMensag := cMensag+'<FONT face="Verdana" size="1"> '
// MENSAGENS AUTOMATICAS
cMensag := cMensag+'<BR> '
// OBSERVACOES
cMensag := cMensag+'<BR> Segue abaixo a relação de produtos que permaneceram no estoque da empresa '+ALLTRIM(SM0->M0_NOMECOM)+':'
cMensag := cMensag+'<BR> '
// DADOS DA TABELA
cMensag := cMensag+'<TABLE border="1"> '
cMensag := cMensag+'<TR bgcolor="#0000CC" bordercolor="#999999"> '
cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Produto</div></TD> ' 
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Local</div></TD> ' 
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">1ª UM</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Quantidade 1ª UM</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">2ª UM</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Quantidade 2ª UM</div></TD> '

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
													 											// Email do(s) receptor(es)
cAssunto	:= 'Relação de produtos que permaneceram no estoque da empresa LM'  // Assunto do Email

U_BIAEnvMail(,cEmail,cAssunto,cMensag)

cMensag  := ''
cMens    := ''
nItemPrd := 0
//conout('BIA495-10')
Return