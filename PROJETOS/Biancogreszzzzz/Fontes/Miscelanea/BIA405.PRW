#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA405     ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envio de e-mail de pedidos nao aprovados.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA405(AA_EMP)

If Type("DDATABASE") <> "D"
	DO CASE
		CASE AA_EMP == "01"
			RPCSETENV("01","01",,,"FAT")
		CASE AA_EMP == "05"
			RPCSETENV("05","01",,,"FAT")
		CASE AA_EMP == "07"
			RPCSETENV("07","01",,,"FAT")
		CASE AA_EMP == "12"
			RPCSETENV("12","01",,,"FAT")
		CASE AA_EMP == "13"
			RPCSETENV("13","01",,,"FAT")
	ENDCASE
EndIf

Private aLista     := {}
Private nI         := 1
Private cMensagem  := ''
Private lOK        := .F.
Private lPassei    := .F.
Private lSexta     := .F.
Private lErro      := .F.
Private cERRO      := ''
Private nLastKey   := 0
Private cItem 	   := 1
Private cMensag    := ''
Private cMens      := ''
Private nItemPrd   := 0
Private cFornece   := ''
Private cLoja      := ''
Private cAprov     := ''
Private cEmail     := ''
Private cDia       := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada de Funcoes                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| Analisa_PC()})

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

Local cNumAnt 		:= ''
Local cLinhaAnt 	:= ''
Local cLinhaAux 	:= ''
Local cAprovTemp 	:= ''
DbSelectArea("SCR")
DbSetOrder(1)
conout('BIA405-1')
  
cQuery := " SELECT CR_FILIAL, CR_NUM, CR_NIVEL, CR_USER, CR_STATUS, CR_TOTAL, CR_EMISSAO, CR_APROV, AK_NOME, AK_COD, AK_USER, AK_APROSUP "
cQuery += " FROM "+RetSqlName("SCR")+" SCR "
cQuery += " LEFT JOIN "+RetSqlName("SAK")+" SAK" 
cQuery += " ON AK_COD = CR_APROV "                      
cQuery += " WHERE CR_FILIAL = " + ValToSQL(xFilial("SCR"))
cQuery += " AND CR_LIBAPRO = '' "
cQuery += " AND CR_DATALIB = '' "
cQuery += " AND CR_USERLIB = '' "
cQuery += " AND CR_VALLIB = 0 "
cQuery += " AND SCR.D_E_L_E_T_ = '' "
cQuery += " AND AK_FILIAL = " + ValToSQL(xFilial("SAK"))
cQuery += " AND SAK.D_E_L_E_T_ = '' "
cQuery += " ORDER BY AK_COD, CR_NUM "

TCQUERY cQuery ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGotop()
conout('BIA405-2')
Setprc(0,0)

While ! EOF() 

	cNumAnt := Alltrim(QRY->CR_NUM)
	cAprov := QRY->AK_COD
	conout('BIA405-3')
	
	//Se for Sexta, colocar apenas  e-mail do Sr. Luis/Fabiola. Senao colocar e-mail do aprovador.
	cDia := ALLTRIM(UPPER(GpeDiaSem(dDatabase)))
	
	IF SUBSTR(cDia,1,5) <> 'SEXTA'
		
		lSexta := .F.

		//RUBENS JÚNIOR - 25/08/14 - SOLICITADO PELO WANISAY, PARA O BEIRAO NAO RECEBER MAIS ESSES EMAIL
		If(QRY->AK_USER == '000046')
			cEmail := " "
		Else
			//RUBENS JÚNIOR - 28/05/14 - ERRO AO BUSCAR EMAIL DOS USUARIOS		
			cEmail := Alltrim(UsrRetMail(QRY->AK_USER))
			
			//(20/01/15 - Thiago) - Enviar email para o aprovador temporário.
			dbSelectArea("SAK")
			dbSetOrder(1)
			dbGotop()
			
			cAprovTemp := AllTrim(Posicione("SAK",1,xFilial("SAK")+SAK->AK_APROSUP,"AK_USER"))
			
			If !Empty(cAprovTemp)
				cEmail +=  '; '+Alltrim(UsrRetMail(cAprovTemp))
			EndIf
						
			If Empty(cEmail)
				cEmail   := 'wanisay.william@biancogres.com.br'
				lErro    := .T.
			EndIf
		EndIf
		
		WHILE (QRY->CR_APROV == cAprov) //.Or. ((QRY->CR_APROV != cAprov) .And. (Alltrim(cNumAnt) == Alltrim(QRY->CR_NUM))))
			lPassei := .F.
			DbSelectArea("SC7")
			DbSetOrder(1)
			DbSeek(xFilial("SC7")+ALLTRIM(QRY->CR_NUM),.F.)
			cFornece := SC7->C7_FORNECE
			cLoja    := SC7->C7_LOJA
			
			WHILE SC7->C7_NUM == ALLTRIM(QRY->CR_NUM) .AND. !Eof()
				IF SC7->C7_RESIDUO <> 'S' .AND. (SC7->C7_QUANT - SC7->C7_QUJE) > 0
					lPassei := .T.
					Exit
				ENDIF
				DbSelectArea("SC7")
				DbSkip()
			END
			
			IF lPassei
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+cFornece+cLoja,.F.)
				
				IF cItem = 1
					cMENS := cMENS+'<TR bgcolor="#33CCFF">'
					cItem := 0
				ELSE
					cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
					cItem := 1
				ENDIF
				
				nItemPrd := nItemPrd + 1 
							
				cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
				cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->CR_NUM+'</TD>'
				cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+SA2->A2_NOME+'</TD>'
				cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->CR_EMISSAO,7,2)+"/"+SUBSTR(QRY->CR_EMISSAO,5,2)+"/"+SUBSTR(QRY->CR_EMISSAO,3,2)+'</TD>'
				cMENS := cMENS+'<TD width="70"  valign="Top"><FONT face="Verdana" size="1">'+STR(QRY->CR_TOTAL,9,2)+'</TD>'
				cMENS := cMENS+'<TD width="250" valign="Top"><FONT face="Verdana" size="1">'+QRY->CR_APROV+"-"+QRY->AK_NOME+'</TD>'
				cMENS := cMENS+'</TR>'
			ENDIF
			
			cNumAnt := Alltrim(QRY->CR_NUM)
			
			DbSelectArea("QRY")
			DbSkip()
		END
		
		IF !EMPTY(cMENS)
			conout('BIA405-4')
			Envioemail()
		ENDIF
	ELSE
		lSexta := .T.
		IF SUBSTR(ALLTRIM(SM0->M0_NOMECOM),1,1) == 'B'
			cEmail  := "marcelo.guizzardi@biancogres.com.br;vagner.salles@biancogres.com.br;glauco.santos@biancogres.com.br;rosilene.murrer@biancogres.com.br"
			cEmail  += ";rosicarla.ferreira@biancogres.com.br;avelino.lopes@biancogres.com.br;anuplio.filho@biancogres.com.br;leonardo.mengal@biancogres.com.br;leticia.vicente@biancogres.com.br"
		ELSE
			cEmail  := "marcelo.guizzardi@biancogres.com.br;vagner.salles@biancogres.com.br;glauco.santos@biancogres.com.br;rosilene.murrer@biancogres.com.br"
			cEmail  += ";rosicarla.ferreira@biancogres.com.br;avelino.lopes@biancogres.com.br;anuplio.filho@biancogres.com.br;leonardo.mengal@biancogres.com.br;leticia.vicente@biancogres.com.br"
		ENDIF
		
		lPassei := .F.
		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek(xFilial("SC7")+ALLTRIM(QRY->CR_NUM),.F.)
		cFornece := SC7->C7_FORNECE
		cLoja    := SC7->C7_LOJA
		
		WHILE SC7->C7_NUM == ALLTRIM(QRY->CR_NUM) .AND. !Eof()
			IF SC7->C7_RESIDUO <> 'S' .AND. (SC7->C7_QUANT - SC7->C7_QUJE) > 0
				lPassei := .T.
				Exit
			ENDIF
			DbSelectArea("SC7")
			DbSkip()
		END
		
		IF lPassei
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+cFornece+cLoja,.F.)
			
			IF cItem = 1
				cMENS := cMENS+'<TR bgcolor="#33CCFF">'
				cItem := 0
			ELSE
				cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
				cItem := 1
			ENDIF
			
			nItemPrd := nItemPrd + 1
			
			cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
			cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->CR_NUM+'</TD>'
			cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+SA2->A2_NOME+'</TD>'
			cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(QRY->CR_EMISSAO,7,2)+"/"+SUBSTR(QRY->CR_EMISSAO,5,2)+"/"+SUBSTR(QRY->CR_EMISSAO,3,2)+'</TD>'
			cMENS := cMENS+'<TD width="70"  valign="Top"><FONT face="Verdana" size="1">'+STR(QRY->CR_TOTAL,9,2)+'</TD>'
			cMENS := cMENS+'<TD width="250" valign="Top"><FONT face="Verdana" size="1">'+QRY->CR_APROV+"-"+QRY->AK_NOME+'</TD>'
			cMENS := cMENS+'</TR>'
		ENDIF
		conout('BIA405 - PEDIDO ='+QRY->CR_NUM)
		cNumAnt := Alltrim(QRY->CR_NUM)
		DbSelectArea("QRY")
		DbSkip()
	ENDIF
	
	IF !lSexta
	ELSE
	ENDIF
END

IF lSexta
	conout('BIA405-5')
	Envioemail()
ENDIF

DbSelectArea("QRY")
DbCloseArea()

Return

Static Function Envioemail()
Local lOk
Local lDebug := .F.
conout('BIA405-6')
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
cMensag := cMensag+'<TITLE> Relaçãp de Pedidos de Compras não liberados </TITLE> '
// DADOS DA BIANCOGRES
cMensag := cMensag+'<BODY> '
cMensag := cMensag+'<FONT face="Verdana" size="1"> '
// MENSAGENS AUTOMATICAS
cMensag := cMensag+'<BR> '
// OBSERVACOES
cMensag := cMensag+'<BR> Segue abaixo a relação de pedidos de compras não liberados até o presente momento da Empresa '+ALLTRIM(SM0->M0_NOMECOM)+':'
cMensag := cMensag+'<BR> '
// DADOS DA TABELA
cMensag := cMensag+'<TABLE border="1"> '
cMensag := cMensag+'<TR bgcolor="#0000CC" bordercolor="#999999"> '
cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Número PC</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Nome do Fornecedor</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data de Emissão</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Valor</div></TD> '
cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Aprovador</div></TD> '
cMensag := cMensag+'</TR> '
cMensag := cMensag+cMENS
cMensag := cMensag+'</TABLE> '
// RODAPE
cMensag := cMensag+'<BR> '
cMensag := cMensag+'<BR> Atenciosamente,'
cMensag := cMensag+'<BR> '
cMensag := cMensag+'<BR>Qualquer dúvida entre em contato com o departamento de compras. '
cMensag := cMensag+'Este e-mail é automático.'+'<BR> '
cMensag := cMensag+'Não Responda esta mensagem.'+'<BR> '
cMensag := cMensag+'<BR> '

cMensag := cMensag+'</BODY> '
cMensag := cMensag+'</HTML>'   

cRecebe     := cEmail																    		// Email do(s) receptor(es)
cRecebeCC	:= ""																							// Com Copia
cRecebeCO	:= ""																							// Copia Oculta
cAssunto	:= 'Relação de Pedidos de Compras não liberados' 	// Assunto do Email

If lDebug
	cRecebe := "tiago@facilesistemas.com.br"
Endif 

If !Empty(cEmail)
	lOK := U_BIAEnvMail(,cRecebe,cAssunto,cMensag)

	If lOk
		conout('BIA405 - ENVIADO')
	ELSE
		conout('BIA405 - FALHA AO ENVIAR EMAIL')
	ENDIF
EndIf

cMensag  := ''
cMens    := ''
nItemPrd := 0
conout('BIA405-10')
Return