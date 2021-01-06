#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA531     ³ Autor ³ Wanisay William       ³ Data ³ 23.01.13      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail com pedidos aguardando aprovação 		             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA531(AA_EMP)
Private cNome   := ''
Private cSolAnt := ''

If Type("DDATABASE") <> "D"
	DO CASE
		CASE AA_EMP == "01"
			RPCSETENV("01","01",,,"COM")
		CASE AA_EMP == "05"
			RPCSETENV("05","01",,,"COM")
		CASE AA_EMP == "12"
			RPCSETENV("12","01",,,"COM")
		CASE AA_EMP == "13"
			RPCSETENV("13","01",,,"COM")
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
Private cEmpresa   := AA_EMP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada de Funcoes                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipo := '1'
Processa({|| PC_Prz1()})

cTipo := '2'
Processa({|| PC_Prz2()})

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaArq   ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PC_Prz1()

Local cBizagi	:= U_fGetBase("2") 

//ATUALIZAÇÃO QUERY - SQL ATUAL - 13/10/2015
cSQL := ""
cSQL += "	SELECT C1_YMAT, C1_YBIZAGI, C7_NUM, C7_ITEM, C7_EMISSAO, C7_PRODUTO, 

// Tiago Rossini Coradini - 03-05-16 - Wanisay - Atualização do campo CR_YDTINCL para tratamento de pedidos com atraso na aprovação
cSQL += " CASE WHEN CR_YDTINCL <> '' THEN CR_YDTINCL ELSE C7_EMISSAO END AS CR_YDTINCL, "
cSQL += " DATEDIFF(DAY, (CASE WHEN CR_YDTINCL <> '' THEN CR_YDTINCL ELSE C7_EMISSAO END), GETDATE()) AS ATRASO, "
cSQL += " C7_YCONTR, C3_MSBLQL, C7_NUMSC, C7_ITEMSC, C7_TOTAL, C7_USER, CR_USER, CR_APROV, AK_NOME, B1_DESC, AK_APROSUP, "  + Enter
cSQL += "(SELECT Solicitante FROM "+cBizagi+".dbo.DADOS_SOLICITANTE_SC WHERE NumeroBizagi = SC1.C1_YBIZAGI COLLATE SQL_Latin1_General_CP1_CI_AS) AS Z0_EMAIL, "  + Enter
cSQL += "(SELECT Email       FROM "+cBizagi+".dbo.DADOS_SOLICITANTE_SC WHERE NumeroBizagi = SC1.C1_YBIZAGI COLLATE SQL_Latin1_General_CP1_CI_AS) AS Z0_NOME "  + Enter
cSQL += "FROM " + RETSQLNAME("SC7") + "  SC7 "  + Enter
cSQL += "	INNER JOIN " + RetSqlName("SC1") + " SC1 "  + Enter
cSQL += "		ON C7_NUMSC = C1_NUM  "  + Enter
cSQL += "			AND C7_ITEMSC  = C1_ITEM "  + Enter
cSQL += "			AND SC1.D_E_L_E_T_ = '' "  + Enter
cSQL += "	INNER JOIN " + RetSqlName("SB1") + " SB1 "  + Enter
cSQL += "		ON C7_PRODUTO = B1_COD "  + Enter
cSQL += "			AND SB1.D_E_L_E_T_ = '' "  + Enter
cSQL += "	INNER JOIN "+RetSqlName("SCR")+" SCR "  + Enter
cSQL += "		ON C7_NUM = CR_NUM "  + Enter
cSQL += "			AND SCR.D_E_L_E_T_ = '' "  + Enter
cSQL += "	INNER JOIN " + RetSqlName("SAK") + " SAK "  + Enter
cSQL += "		ON CR_APROV = AK_COD "  + Enter
cSQL += "			AND SAK.D_E_L_E_T_ = '' "  + Enter
cSQL += "	LEFT JOIN " + RetSqlName("SC3") + " SC3 "  + Enter
cSQL += "		ON C7_YCONTR = C3_NUM "  + Enter
cSQL += "			AND C3_ITEM = '0001' "  + Enter
cSQL += "			AND SC3.D_E_L_E_T_ = '' "  + Enter
cSQL += "WHERE C7_QUANT   > C7_QUJE "  + Enter
cSQL += "	AND C7_RESIDUO = ''  "  + Enter
cSQL += "	AND C7_ENCER   <> 'E'  "  + Enter
cSQL += "	AND C7_CONAPRO <> 'L'  "  + Enter

// Tiago Rossini Coradini - 03-05-16 - Wanisay - Atualização do campo CR_YDTINCL para tratamento de pedidos com atraso na aprovação
cSQL += "	AND DATEDIFF(DAY, (CASE WHEN CR_YDTINCL <> '' THEN CR_YDTINCL ELSE C7_EMISSAO END), GETDATE()) BETWEEN 7 AND 10  "  + Enter

cSQL += "	AND SC7.D_E_L_E_T_ = '' "  + Enter
cSQL += "ORDER BY C1_YMAT, C7_EMISSAO, C7_NUM "  + Enter

If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGotop()

Setprc(0,0)
cEmailCC := ''
cEmailCO := ''        
eMailSol := ''
cSolAnt  := QRY->C1_YMAT

While ! EOF()
	
	IF QRY->C1_YMAT <> cSolAnt .AND. !EMPTY(cMENS) .AND. !EMPTY(eMailSol)
		Envioemail(eMailSol)
		cMENS    := ''
		eMailSol := ''
	ENDIF
	
	cNome := ALLTRIM(QRY->Z0_NOME)
	
	IF cItem = 1
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 0
	ELSE
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 1
	ENDIF
	
	IF QRY->C3_MSBLQL == '1'
		cStatus := "Sim"
	ELSE
		cStatus := "Não"
	ENDIF
	
	cNomeCom := ALLTRIM(UsrRetName(QRY->C7_USER))
	eMailCom := ALLTRIM(UsrRetMail(QRY->C7_USER))
	eMailApr := ALLTRIM(UsrRetMail(QRY->CR_USER))
	eMailSol := ALLTRIM(QRY->Z0_EMAIL)
	
	If !Empty(QRY->AK_APROSUP)
		//(20/01/15 - Thiago) - Enviar email para o aprovador temporário.
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbGotop()
		
		cAprovTemp := AllTrim(Posicione("SAK",1,xFilial("SAK")+SAK->AK_APROSUP,"AK_USER"))
		
		If !Empty(cAprovTemp)
			eMailApr +=  '; '+Alltrim(UsrRetMail(cAprovTemp))
		EndIf
		
		dbSelectArea("QRY")
	EndIf
	
	nItemPrd := nItemPrd + 1
	
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_NUM+'</TD>'
	cMENS := cMENS+'<TD width="75"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_ITEM+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_PRODUTO+'</TD>'
	cMENS := cMENS+'<TD width="200" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->B1_DESC,1,30)+'</TD>'
	cMENS := cMENS+'<TD width="55"  valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->C7_EMISSAO,7,2)+"/"+SUBSTR(QRY->C7_EMISSAO,5,2)+"/"+SUBSTR(QRY->C7_EMISSAO,3,2)+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+TRANSFORM(QRY->C7_TOTAL,"@E 999,999.99")+'</TD>'
	
	// Tiago Rossini Coradini - 03-05-16 - Wanisay - Atualização do campo CR_YDTINCL para tratamento de pedidos com atraso na aprovação
	cMENS := cMENS+'<TD width="55"  valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->CR_YDTINCL,7,2)+"/"+SUBSTR(QRY->CR_YDTINCL,5,2)+"/"+SUBSTR(QRY->CR_YDTINCL,3,2)+'</TD>'	
	
	cMENS := cMENS+'<TD width="50"  valign="Top"><FONT face="Verdana" size="1">'+STR(QRY->ATRASO)+'</TD>'
	cMENS := cMENS+'<TD width="200" valign="Top"><FONT face="Verdana" size="1">'+cNomeCom+'</TD>'
	cMENS := cMENS+'<TD width="200" valign="Top"><FONT face="Verdana" size="1">'+QRY->AK_NOME+'</TD>'
	cMENS := cMENS+'<TD width="55"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_YCONTR+'</TD>'
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+cStatus+'</TD>'
	
	cMENS := cMENS+'</TR>'
	
	cSolAnt := QRY->C1_YMAT
	
	DbSelectArea("QRY")
	DbSkip()
END

IF !EMPTY(cMENS)
	IF !EMPTY(eMailSol)
		Envioemail(eMailSol)
	ENDIF
ENDIF

cMensag  := ''
cMens    := ''
nItemPrd := 0

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaArq   ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PC_Prz2()

Local cBizagi	:= U_fGetBase("2")

//ATUALIZAÇÃO QUERY - SQL ATUAL - 13/10/2015
cSQL := ""
cSQL += " SELECT C1_YMAT, C7_NUM, C7_ITEM, C7_EMISSAO, C7_PRODUTO, "

// Tiago Rossini Coradini - 03-05-16 - Wanisay - Atualização do campo CR_YDTINCL para tratamento de pedidos com atraso na aprovação
cSQL += " CASE WHEN CR_YDTINCL <> '' THEN CR_YDTINCL ELSE C7_EMISSAO END AS CR_YDTINCL, "
cSQL += " DATEDIFF(DAY, (CASE WHEN CR_YDTINCL <> '' THEN CR_YDTINCL ELSE C7_EMISSAO END), GETDATE()) AS ATRASO, "
cSQL += " C7_YCONTR, C3_MSBLQL, C7_NUMSC, C7_ITEMSC, C7_TOTAL, C7_USER, CR_USER, CR_APROV, AK_NOME, B1_DESC,AK_APROSUP, "  + Enter
cSQL += "(SELECT Solicitante FROM "+cBizagi+".dbo.DADOS_SOLICITANTE_SC WHERE NumeroBizagi = SC1.C1_YBIZAGI COLLATE SQL_Latin1_General_CP1_CI_AS) AS Z0_EMAIL, "  + Enter
cSQL += "(SELECT Email       FROM "+cBizagi+".dbo.DADOS_SOLICITANTE_SC WHERE NumeroBizagi = SC1.C1_YBIZAGI COLLATE SQL_Latin1_General_CP1_CI_AS) AS Z0_NOME "  + Enter
cSQL += "FROM " + RETSQLNAME("SC7") + " SC7 "  + Enter
cSQL += "	INNER JOIN " + RetSqlName("SC1") + " SC1 "  + Enter
cSQL += "		ON C7_NUMSC = C1_NUM  "  + Enter
cSQL += "			AND C7_ITEMSC  = C1_ITEM "  + Enter
cSQL += "			AND SC1.D_E_L_E_T_ = '' "  + Enter
cSQL += "	INNER JOIN " + RetSqlName("SB1") + " SB1 "  + Enter
cSQL += "		ON C7_PRODUTO = B1_COD "  + Enter
cSQL += "			AND SB1.D_E_L_E_T_ = ''	 "  + Enter
cSQL += "	INNER JOIN " + RetSqlName("SCR") + " SCR "  + Enter
cSQL += "		ON C7_NUM = CR_NUM "  + Enter
cSQL += "			AND SCR.D_E_L_E_T_ = '' "  + Enter
cSQL += "	INNER JOIN " + RetSqlName("SAK") + " SAK "  + Enter
cSQL += "		ON CR_APROV = AK_COD "  + Enter
cSQL += "			AND SAK.D_E_L_E_T_ = '' "  + Enter
cSQL += "	LEFT JOIN " + RetSqlName("SC3") + " SC3 "  + Enter
cSQL += "		ON C7_YCONTR = C3_NUM "  + Enter
cSQL += "			AND C3_ITEM = '0001' "  + Enter
cSQL += "			AND SC3.D_E_L_E_T_ = '' "  + Enter
cSQL += "WHERE C7_QUANT   > C7_QUJE "  + Enter
cSQL += "	AND C7_RESIDUO = ''  "  + Enter
cSQL += "	AND C7_ENCER   <> 'E'  "  + Enter
cSQL += "	AND C7_CONAPRO <> 'L'  "  + Enter

// Tiago Rossini Coradini - 03-05-16 - Wanisay - Atualização do campo CR_YDTINCL para tratamento de pedidos com atraso na aprovação
cSQL += "	AND DATEDIFF(DAY, (CASE WHEN CR_YDTINCL <> '' THEN CR_YDTINCL ELSE C7_EMISSAO END), GETDATE()) > 10 "  + Enter

cSQL += "	AND SC7.D_E_L_E_T_ = '' "  + Enter
cSQL += "ORDER BY C1_YMAT, C7_EMISSAO, C7_NUM "  + Enter

If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGotop()

Setprc(0,0)
cEmailCC := ''
cEmailCO := ''
eMailSol := ''
cSolAnt  := QRY->C1_YMAT

While ! EOF()
	
	IF QRY->C1_YMAT <> cSolAnt .AND. !EMPTY(cMENS) .AND. !EMPTY(eMailSol)
		Envioemail(eMailSol)
		cMENS    := ''
		eMailSol := ''
	ENDIF

	cNome := ALLTRIM(QRY->Z0_NOME)
		
	IF cItem = 1
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 0
	ELSE
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 1
	ENDIF
	
	IF QRY->C3_MSBLQL == '1'
		cStatus := "Sim"
	ELSE
		cStatus := "Não"
	ENDIF
	
	cNomeCom := ALLTRIM(UsrRetName(QRY->C7_USER))
	eMailCom := ALLTRIM(UsrRetMail(QRY->C7_USER))
	eMailApr := ALLTRIM(UsrRetMail(QRY->CR_USER))
	eMailSol := ALLTRIM(QRY->Z0_EMAIL)
	
	If !Empty(QRY->AK_APROSUP)
		//(20/01/15 - Thiago) - Enviar email para o aprovador temporário.
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbGotop()
		
		cAprovTemp := AllTrim(Posicione("SAK",1,xFilial("SAK")+SAK->AK_APROSUP,"AK_USER"))
		
		If !Empty(cAprovTemp)
			eMailApr +=  '; '+Alltrim(UsrRetMail(cAprovTemp))
		EndIf
		
		dbSelectArea("QRY")
	EndIf
	
	nItemPrd := nItemPrd + 1
	
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_NUM+'</TD>'
	cMENS := cMENS+'<TD width="75"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_ITEM+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_PRODUTO+'</TD>'
	cMENS := cMENS+'<TD width="200" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->B1_DESC,1,30)+'</TD>'
	cMENS := cMENS+'<TD width="55"  valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->C7_EMISSAO,7,2)+"/"+SUBSTR(QRY->C7_EMISSAO,5,2)+"/"+SUBSTR(QRY->C7_EMISSAO,3,2)+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+TRANSFORM(QRY->C7_TOTAL,"@E 999,999.99")+'</TD>'
	
	// Tiago Rossini Coradini - 03-05-16 - Wanisay - Atualização do campo CR_YDTINCL para tratamento de pedidos com atraso na aprovação
	cMENS := cMENS+'<TD width="55"  valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->CR_YDTINCL,7,2)+"/"+SUBSTR(QRY->CR_YDTINCL,5,2)+"/"+SUBSTR(QRY->CR_YDTINCL,3,2)+'</TD>'	
	
	cMENS := cMENS+'<TD width="50"  valign="Top"><FONT face="Verdana" size="1">'+STR(QRY->ATRASO)+'</TD>'
	cMENS := cMENS+'<TD width="200" valign="Top"><FONT face="Verdana" size="1">'+cNomeCom+'</TD>'
	cMENS := cMENS+'<TD width="200" valign="Top"><FONT face="Verdana" size="1">'+QRY->AK_NOME+'</TD>'
	cMENS := cMENS+'<TD width="55"  valign="Top"><FONT face="Verdana" size="1">'+QRY->C7_YCONTR+'</TD>'
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+cStatus+'</TD>'
	
	cMENS := cMENS+'</TR>'
	
	cSolAnt  := QRY->C1_YMAT
	
	xnPerc 		:= 100.00
	xdEmisDe 	:= CTOD("01/01/80")
	xdEmisAte 	:= CTOD("31/12/20")
	xcCodigoDe 	:= QRY->C7_NUM
	xcCodigoAte := QRY->C7_NUM
	xcProdDe 	:= ''
	xcProdAte 	:= 'ZZZZZZZZZZZZZZZ'
	xcTipo 		:= 1
	xcFornDe 	:= ''
	xcFornAte 	:= 'ZZZZZZ'
	xdDatprfde 	:= CTOD("01/01/80")
	xdDatPrfAte := CTOD("31/12/20")
	xcItemDe 	:= ''
	xcItemAte 	:= 'ZZZZ'
	xlConsEIC 	:= .T.
	MV_PAR16    := 2
	MV_PAR17    := 2
	lMT235G1    := .T.
	
	//Elimina resíduo dos pedidos automaticamente cm base nos parâmetros fixos acima.
	//Processa({|lEnd| MA235PC(mv_par01,mv_par08,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par09,mv_par10,mv_par11,mv_par12,mv_par14,mv_par15)})
	//MA235PC(xnPerc, xcTipo, xdEmisDe, xdEmisAte, xcCodigoDe, xcCodigoAte, xcProdDe, xcProdAte, xcFornDe, xcFornAte, xdDatprfde, xdDatPrfAte, xcItemDe, xcItemAte, xlConsEIC)
	//MA235PCCTB()
	
	DbSelectArea("QRY")
	DbSkip()
END

IF !EMPTY(cMENS)
	IF  !EMPTY(eMailSol)
		Envioemail(eMailSol)
	ENDIF
ENDIF

cMensag  := ''
cMens    := ''
nItemPrd := 0

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
IF cTipo == '1'
	cMensag := cMensag+'<TITLE> Relação de pedidos de compras bloqueados entre 7 e 10 dias à partir de sua emissão.</TITLE> '
ELSE
	cMensag := cMensag+'<TITLE> Relação de pedidos de compras eliminados (Bloqueado acima de 10 dias à partir de sua emissão).</TITLE> '
ENDIF

// DADOS DA BIANCOGRES
cMensag := cMensag+'<BODY> '
cMensag := cMensag+'<FONT face="Verdana" size="1"> '
// MENSAGENS AUTOMATICAS
cMensag := cMensag+'<BR> '
cMensag := cMensag+'<BR> Prezado (a) '+cNome+':'
cMensag := cMensag+'<BR> '
// OBSERVACOES
IF cTipo == '1'
	cMensag := cMensag+'<BR> Segue abaixo a relação de pedidos de compras bloqueados entre 7 e 10 dias à partir de sua emissão.'
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<BR> Favor entrar em contato com o seu aprovador, para verificar a liberação, pois conforme IT UN-IT-SUP-01, no prazo de 10 dias, o mesmo será eliminado automaticamente pelo sistema.'
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<BR> Empresa: '+ALLTRIM(SM0->M0_NOMECOM)+':'
ELSE
	cMensag := cMensag+'<BR> Segue abaixo a relação de pedidos de compras eliminados por ultrapassar o prazo de 10 dias sem a devida aprovação, conforme IT UN-IT-SUP-01.'
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<BR> Empresa: '+ALLTRIM(SM0->M0_NOMECOM)+':'
ENDIF
cMensag := cMensag+'<BR> '
// DADOS DA TABELA
cMensag := cMensag+'<TABLE border="1"> '
cMensag := cMensag+'<TR bgcolor="#0000CC" bordercolor="#999999"> '
cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Numero PC</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item PC</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Produto</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Descrição</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Emissão</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Valor em R$</div></TD> '

// Tiago Rossini Coradini - 03-05-16 - Wanisay - Atualização do campo CR_YDTINCL para tratamento de pedidos com atraso na aprovação
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Dt Envio Aprovação</div></TD> '

cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Dias de atraso</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Comprador</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Aprovador</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Contrato</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Contrato Bloqueado?</div></TD> '

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
cRecebe     := eMailSol													 		// Email do(s) receptor(es)
cRecebeCC	:= eMailCom															// Com Copia
//cRecebe     := 'wanisay.william@biancogres.com.br'							// Email do(s) receptor(es)
cRecebeCC	:= ''																// Com Copia
cRecebeCO	:= cEmailCO			  								 				// Copia Oculta

IF cTipo == '1'
	cAssunto	:= 'Pedidos aguardando aprovação' 									// Assunto do Email
ELSE
	cAssunto	:= 'Pedidos eliminados por falta de aprovação' 						// Assunto do Email
ENDIF 

U_BIAEnvMail(,cRecebe,cAssunto,cMensag,,,,cRecebeCC)

Return