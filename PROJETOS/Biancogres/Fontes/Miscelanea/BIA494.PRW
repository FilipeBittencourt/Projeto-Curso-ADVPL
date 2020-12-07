#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA494     ³ Autor ³ Wanisay William       ³ Data ³ 03.05.12      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara envio de e-mail para NF da LM sem saida na empresa origem ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA494(AA_EMP)

If Type("DDATABASE") <> "D"
	DO CASE
		CASE AA_EMP == "01"
			RPCSETENV("01","01",,,"FAT")
		CASE AA_EMP == "05"
			RPCSETENV("05","01",,,"FAT")
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
//conout('BIA494-INICIADO')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada de Funcoes                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipo := '1'
Processa({|| Analisa_NF()})

//conout('BIA494-ENCERRADO')

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaArq   ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Analisa_NF()

//conout('BIA494-1')

DO CASE
	CASE cEmpAnt == '01'
		cQuery := "SELECT	" + Enter
		cQuery := cQuery + "  F1_SERIE, F1_DOC, F1_FORNECE, F1_LOJA, F1_EMISSAO, F1_DTDIGIT, DATEDIFF(day,F1_EMISSAO, GETDATE()) AS DIAS, * " + Enter
		cQuery := cQuery + "  FROM  SF1070 SF1, SD1070 SD1 " + Enter
		cQuery := cQuery + "  WHERE	F1_FORNECE = '000534'   AND " + Enter
		cQuery := cQuery + "  		F1_DOC       = D1_DOC     AND " + Enter
		cQuery := cQuery + "  		F1_SERIE     = D1_SERIE   AND " + Enter
		cQuery := cQuery + "  		F1_FORNECE   = D1_FORNECE AND " + Enter 
		cQuery := cQuery + "  		F1_LOJA      = D1_LOJA    AND " + Enter 
		cQuery := cQuery + "  		D1_ITEM      = '0001'     AND " + Enter 
		cQuery := cQuery + "  		D1_COD BETWEEN 'A' AND 'ZZZZZZ' AND " + Enter
		cQuery := cQuery + "  		F1_DOC NOT IN (SELECT F2_DOC FROM "+RetSqlName("SF2")+" SF2 WHERE F2_CLIENTE = '010064' AND D_E_L_E_T_ = '') AND "   + Enter
		cQuery := cQuery + "  		F1_DTDIGIT >= '20120101' AND " + Enter
		cQuery := cQuery + "  		DATEDIFF(day,F1_EMISSAO, GETDATE()) >= 2 AND " + Enter
		cQuery := cQuery + "  		SF1.D_E_L_E_T_ = '' AND " + Enter 
		cQuery := cQuery + "  		SD1.D_E_L_E_T_ = '' " + Enter		
	CASE cEmpAnt == '05'
		cQuery := "SELECT	" + Enter
		cQuery := cQuery + "  F1_SERIE, F1_DOC, F1_FORNECE, F1_LOJA, F1_EMISSAO, F1_DTDIGIT, DATEDIFF(day,F1_EMISSAO, GETDATE()) AS DIAS, * " + Enter
		cQuery := cQuery + "  FROM  SF1070 SF1, SD1070 SD1 " + Enter
		cQuery := cQuery + "  WHERE	F1_FORNECE = '002912' AND  "
		cQuery := cQuery + "  		F1_DOC       = D1_DOC     AND " + Enter
		cQuery := cQuery + "  		F1_SERIE     = D1_SERIE   AND " + Enter
		cQuery := cQuery + "  		F1_FORNECE   = D1_FORNECE AND " + Enter 
		cQuery := cQuery + "  		F1_LOJA      = D1_LOJA    AND " + Enter 
		cQuery := cQuery + "  		D1_ITEM      = '0001'     AND " + Enter 
		cQuery := cQuery + "  		D1_COD BETWEEN 'A' AND 'ZZZZZZ' AND " + Enter
		cQuery := cQuery + "  		F1_DOC NOT IN (SELECT F2_DOC FROM "+RetSqlName("SF2")+" SF2 WHERE F2_CLIENTE = '010064' AND D_E_L_E_T_ = '') AND "   + Enter
		cQuery := cQuery + "  		F1_DTDIGIT >= '20120101' AND " + Enter
		cQuery := cQuery + "  		DATEDIFF(day,F1_EMISSAO, GETDATE()) >= 2 AND " + Enter
		cQuery := cQuery + "  		SF1.D_E_L_E_T_ = '' AND " + Enter 
		cQuery := cQuery + "  		SD1.D_E_L_E_T_ = '' " + Enter		
	CASE cEmpAnt == '13'
		cQuery := "SELECT	" + Enter
		cQuery := cQuery + "  F1_SERIE, F1_DOC, F1_FORNECE, F1_LOJA, F1_EMISSAO, F1_DTDIGIT, DATEDIFF(day,F1_EMISSAO, GETDATE()) AS DIAS, * " + Enter
		cQuery := cQuery + "  FROM  SF1070 SF1, SD1070 SD1 " + Enter
		cQuery := cQuery + "  WHERE	F1_FORNECE = '004695' AND  "
		cQuery := cQuery + "  		F1_DOC       = D1_DOC     AND " + Enter
		cQuery := cQuery + "  		F1_SERIE     = D1_SERIE   AND " + Enter
		cQuery := cQuery + "  		F1_FORNECE   = D1_FORNECE AND " + Enter 
		cQuery := cQuery + "  		F1_LOJA      = D1_LOJA    AND " + Enter 
		cQuery := cQuery + "  		D1_ITEM      = '0001'     AND " + Enter 
		cQuery := cQuery + "  		D1_COD BETWEEN 'A' AND 'ZZZZZZ' AND " + Enter
		cQuery := cQuery + "  		F1_DOC NOT IN (SELECT F2_DOC FROM "+RetSqlName("SF2")+" SF2 WHERE F2_CLIENTE = '010064' AND D_E_L_E_T_ = '') AND "   + Enter
		cQuery := cQuery + "  		F1_DTDIGIT >= '20120101' AND " + Enter
		cQuery := cQuery + "  		DATEDIFF(day,F1_EMISSAO, GETDATE()) >= 2 AND " + Enter
		cQuery := cQuery + "  		SF1.D_E_L_E_T_ = '' AND " + Enter 
		cQuery := cQuery + "  		SD1.D_E_L_E_T_ = '' " + Enter		
	OTHERWISE
ENDCASE

If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cQuery ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGotop()
//conout('BIA494-2')
Setprc(0,0)
cEmail   := ''

While ! EOF()
	
	//conout('BIA494-3')
	
	cEmail := U_EmailWF('BIA494',cEmpAnt) 
	IF cItem = 1
		cMENS := cMENS+'<TR bgcolor="#33CCFF">'
		cItem := 0
	ELSE
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 1
	ENDIF
	
	nItemPrd := nItemPrd + 1
	
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+ALLTRIM(QRY->F1_SERIE)+"/"+ALLTRIM(QRY->F1_DOC)+'</TD>'
	cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+QRY->F1_FORNECE+'</TD>'
    cMENS := cMENS+'<TD width="600  valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->F1_EMISSAO,7,2)+"/"+SUBSTR(QRY->F1_EMISSAO,5,2)+"/"+SUBSTR(QRY->F1_EMISSAO,3,2)+'</TD>'
    cMENS := cMENS+'<TD width="600  valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->F1_DTDIGIT,7,2)+"/"+SUBSTR(QRY->F1_DTDIGIT,5,2)+"/"+SUBSTR(QRY->F1_DTDIGIT,3,2)+'</TD>'
	cMENS := cMENS+'<TD width="50" valign="Top"><FONT face="Verdana" size="1">'+STR(QRY->DIAS)+'</TD>'
	cMENS := cMENS+'</TR>'
	
	DbSelectArea("QRY")
	DbSkip()
END

IF !EMPTY(cMENS)
	//conout('BIA494-5')
	Envioemail()
ENDIF

DbSelectArea("QRY")
DbCloseArea()

Return

Static Function Envioemail()

//conout('BIA494-6')
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
cMensag := cMensag+'<TITLE> Relação de notas fiscais que não existem na empresa origem.</TITLE> '

// DADOS DA BIANCOGRES
cMensag := cMensag+'<BODY> '
cMensag := cMensag+'<FONT face="Verdana" size="1"> '
// MENSAGENS AUTOMATICAS
cMensag := cMensag+'<BR> '
// OBSERVACOES
cMensag := cMensag+'<BR> Segue abaixo notas fiscais que não existem na empresa origem - '+ALLTRIM(SM0->M0_NOMECOM)+':'
cMensag := cMensag+'<BR> '
// DADOS DA TABELA
cMensag := cMensag+'<TABLE border="1"> '
cMensag := cMensag+'<TR bgcolor="#0000CC" bordercolor="#999999"> '
cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Série/Nota Fiscal</div></TD> ' 
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Fornecedor</div></TD> ' 
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data de Emissão</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data de Digitação</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Dias</div></TD> '

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

cAssunto	:= 'Relação de notas fiscais que não existem na empresa origem' 			  // Assunto do Email

U_BIAEnvMail(,cEmail,cAssunto,cMensag)

cMensag  := ''
cMens    := ''
nItemPrd := 0
//conout('BIA494-10')
Return