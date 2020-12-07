#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA493     ³ Autor ³ Wanisay William       ³ Data ³ 16.04.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envio de e-mail SC em aberto e PC não entregue.	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA493(AA_EMP)

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
//conout('BIA493-INICIADO')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada de Funcoes                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipo := '1'
Processa({|| Analisa_SC()})

cTipo := '2'
Processa({|| Analisa_PC()})

//conout('BIA493-ENCERRADO')

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaArq   ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Analisa_SC()

//conout('BIA493-1')

cQuery := "SELECT	" + Enter
cQuery := cQuery + "  C1_EMISSAO, C1_NUM, C1_ITEM, C1_PRODUTO, C1_QUANT, C1_WFID, C1_APROV, C1_YDATHOR, C1_YMAT, C1_CLVL, B1_DESC " + Enter
cQuery := cQuery + "  FROM "+RetSqlName("SC1")+" SC1, "+RetSqlName("SB1")+" SB1 " + Enter
cQuery := cQuery + "  WHERE SC1.C1_FILIAL = '"+xFilial("SC1")+"'  " + Enter  
cQuery := cQuery + "  AND B1_FILIAL = '"+xFilial("SB1")+"'  " + Enter 
cQuery := cQuery + "  AND C1_PRODUTO = B1_COD " + Enter
cQuery := cQuery + "  AND C1_QUANT > C1_QUJE " + Enter
cQuery := cQuery + "  AND C1_RESIDUO <> 'S' " + Enter
cQuery := cQuery + "  AND C1_APROV = 'L' " + Enter
cQuery := cQuery + "  AND C1_PRODUTO <= '6' " + Enter
cQuery := cQuery + "  AND C1_PEDIDO = '' " + Enter
//cQuery := cQuery + "  AND C1_YMAT <> '' " + Enter
cQuery := cQuery + "  AND SC1.D_E_L_E_T_ = '' " + Enter 
cQuery := cQuery + "  AND SB1.D_E_L_E_T_ = '' " + Enter
cQuery := cQuery + "  ORDER BY C1_NUM, C1_ITEM " + Enter

If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cQuery ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGotop()
//conout('BIA493-2')
Setprc(0,0)
cEmail   := ''

While ! EOF()
	
	//conout('BIA493-3')
	
	//cEmail   := 'enelcio.araujo@biancogres.com.br;gardenia.stelzer@biancogres.com.br;claudia.carvalho@biancogres.com.br'
	cEmail := U_EmailWF('BIA493',cEmpAnt) 
	
	IF cItem = 1
		cMENS := cMENS+'<TR bgcolor="#33CCFF">'
		cItem := 0
	ELSE
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 1
	ENDIF
	
	nItemPrd := nItemPrd + 1                                                        
	
	cDataLib := SUBSTR(QRY->C1_YDATHOR,1,8) 
	cHoraLib := SUBSTR(QRY->C1_YDATHOR,10,5)	
	
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C1_NUM+" - "+QRY->C1_ITEM+'</TD>' 
	cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+QRY->C1_CLVL+'</TD>'	
	cMENS := cMENS+'<TD width="550  valign="Top"><FONT face="Verdana" size="1">'+QRY->C1_PRODUTO+" - "+ALLTRIM(QRY->B1_DESC)+'</TD>'
	cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->C1_EMISSAO,7,2)+"/"+SUBSTR(QRY->C1_EMISSAO,5,2)+"/"+SUBSTR(QRY->C1_EMISSAO,1,4)+'</TD>' 
	cMENS := cMENS+'<TD width="200" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(cDataLib,7,2)+"/"+SUBSTR(cDataLib,5,2)+"/"+SUBSTR(cDataLib,1,4)+" - "+cHoraLib+'</TD>'	
	cMENS := cMENS+'</TR>'
	
	DbSelectArea("QRY")
	DbSkip()
END

IF !EMPTY(cMENS)
	//conout('BIA493-5')
	Envioemail()
ENDIF

DbSelectArea("QRY")
DbCloseArea()

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaArq   ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Analisa_PC()

//conout('BIA493-1')

cQuery := "SELECT	" + Enter
cQuery := cQuery + "  C7_EMISSAO, C7_NUM, C7_ITEM, C7_PRODUTO, C7_QUANT, C7_QUJE, C7_CLVL, C7_CC, C7_DATPRF, C7_YDATCHE, A2_NOME, B1_DESC " + Enter
cQuery := cQuery + "  FROM "+RetSqlName("SC7")+" SC7, "+RetSqlName("SA2")+" SA2, "+RetSqlName("SB1")+" SB1 " + Enter
cQuery := cQuery + "  WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"'  " + Enter 
cQuery := cQuery + "  AND A2_FILIAL       = '"+xFilial("SA2")+"'  " + Enter 
cQuery := cQuery + "  AND B1_FILIAL       = '"+xFilial("SB1")+"'  " + Enter
cQuery := cQuery + "  AND C7_FORNECE = A2_COD " + Enter
cQuery := cQuery + "  AND C7_LOJA    = A2_LOJA " + Enter
cQuery := cQuery + "  AND C7_PRODUTO = B1_COD " + Enter
cQuery := cQuery + "  AND C7_QUANT > C7_QUJE " + Enter
cQuery := cQuery + "  AND C7_RESIDUO NOT IN ('R','S') " + Enter
cQuery := cQuery + "  AND C7_PRODUTO <= '6' " + Enter
cQuery := cQuery + "  AND SC7.D_E_L_E_T_ = '' " + Enter 
cQuery := cQuery + "  AND SA2.D_E_L_E_T_ = '' " + Enter 
cQuery := cQuery + "  AND SB1.D_E_L_E_T_ = '' " + Enter 
cQuery := cQuery + "  ORDER BY C7_NUM, C7_ITEM " + Enter

If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cQuery ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGotop()
//conout('BIA493-2')
Setprc(0,0)
cEmail   := ''

While ! EOF()
	
	//conout('BIA493-3')
	
	IF (dDatabase - STOD(QRY->C7_YDATCHE)) < 15
		DbSelectArea("QRY")
		DbSkip()
		Loop
	ENDIF

	//cEmail   := 'enelcio.araujo@biancogres.com.br;gardenia.stelzer@biancogres.com.br;claudia.carvalho@biancogres.com.br'
	cEmail := U_EmailWF('BIA493',cEmpAnt) 
	
	IF cItem = 1
		cMENS := cMENS+'<TR bgcolor="#33CCFF">'
		cItem := 0
	ELSE
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 1
	ENDIF
	
	nItemPrd := nItemPrd + 1
	
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_NUM+"/"+QRY->C7_ITEM+'</TD>'
	cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_CLVL+'</TD>'	
	cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+ALLTRIM(QRY->A2_NOME)+'</TD>'	
	cMENS := cMENS+'<TD width="550  valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_PRODUTO+" - "+ALLTRIM(QRY->B1_DESC)+'</TD>'                                                
	cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->C7_EMISSAO,7,2)+"/"+SUBSTR(QRY->C7_EMISSAO,5,2)+"/"+SUBSTR(QRY->C7_EMISSAO,1,4)+'</TD>'	 
	cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->C7_DATPRF,7,2)+"/"+SUBSTR(QRY->C7_DATPRF,5,2)+"/"+SUBSTR(QRY->C7_DATPRF,1,4)+'</TD>'		
	cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->C7_YDATCHE,7,2)+"/"+SUBSTR(QRY->C7_YDATCHE,5,2)+"/"+SUBSTR(QRY->C7_YDATCHE,1,4)+'</TD>'
	cMENS := cMENS+'</TR>'
	
	DbSelectArea("QRY")
	DbSkip()
END

IF !EMPTY(cMENS)
	//conout('BIA493-5')
	Envioemail()
ENDIF

DbSelectArea("QRY")
DbCloseArea()

Return

Static Function Envioemail()

//conout('BIA493-6')
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
IF cTipo == '1'
	cMensag := cMensag+'<TITLE> Relação de Solicitações de Compras em aberto.</TITLE> '
ELSE
	cMensag := cMensag+'<TITLE> Relação de Pedidos de Compras não entregues acima de 15 dias.</TITLE> '
ENDIF

// DADOS DA BIANCOGRES
cMensag := cMensag+'<BODY> '
cMensag := cMensag+'<FONT face="Verdana" size="1"> '
// MENSAGENS AUTOMATICAS
cMensag := cMensag+'<BR> '
// OBSERVACOES
IF cTipo == '1'
	cMensag := cMensag+'<BR> Segue abaixo a relação de solicitações de compras em aberto - '+ALLTRIM(SM0->M0_NOMECOM)+':'
ELSE
	cMensag := cMensag+'<BR> Segue abaixo a relação de pedidos de compras não entregues acima de 15 dias - '+ALLTRIM(SM0->M0_NOMECOM)+':'
ENDIF
cMensag := cMensag+'<BR> '
// DADOS DA TABELA
cMensag := cMensag+'<TABLE border="1"> '
cMensag := cMensag+'<TR bgcolor="#0000CC" bordercolor="#999999"> '
IF cTipo == '1'
	cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Solicitação/Item</div></TD> ' 
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">CV</div></TD> '	
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Produto</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data de Emissão</div></TD> ' 
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data e Horário da Liberação</div></TD> '	
ELSE
	cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Pedido/Item</div></TD> '      
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">CV</div></TD> '		
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Razão Social</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Produto</div></TD> '	               
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data de Emissão</div></TD> '	 
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data da Entrega</div></TD> '		
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data da Chegada Prevista</div></TD> '
eNDIF

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

IF cTipo == '1'
	cAssunto	:= 'Relação de solicitações de compras em aberto' 			  // Assunto do Email
ELSE
	cAssunto	:= 'Relação de pedidos de compras não entregues acima de 15 dias'  			  // Assunto do Email
ENDIF 

U_BIAEnvMail(,cEmail,cAssunto,cMensag)
//conout('BIA493-7')

cMensag  := ''
cMens    := ''
nItemPrd := 0
//conout('BIA493-10')
Return