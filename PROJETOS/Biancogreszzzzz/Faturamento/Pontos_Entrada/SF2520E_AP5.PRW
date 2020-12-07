#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} SF2520E
@author GUSTAV KOBLINGER JR, WLADIMIR ILLIUSHENKO, Ranisses A. Corona
@since 19/06/17
@version 1.0
@description Antes de deletar o registro do SF2
@type function
/*/

User Function SF2520E()

	Private aLista     := {}
	Private nI         := 1
	Private cMensagem  := ''
	Private lOK        := .F.
	Private lErro      := .F.
	Private cERRO      := ''
	Private nLastKey   := 0
	Private cMensag    := ''
	Private cMens      := ''
	Private cEmail     := ''
	Private cMotivo		:= 'Não Informado.'

	//Variaveis de Posicionamento
	Private aAreaGer	:= GetArea()
	Private cArqANT 	:= Alias()
	Private cIndANT 	:= IndexOrd()
	Private cRegANT 	:= Recno()

	SX0005 := ""
	SX0005 += " SELECT SX5.X5_DESCRI "
	SX0005 += "   FROM "+RetSqlName("SF3") + " SF3 "
	SX0005 += "  INNER JOIN "+RetSqlName("SX5") + " SX5 "
	SX0005 += "     ON SX5.X5_FILIAL = '"+xFilial("SX5")+"' "
	SX0005 += "    AND SX5.X5_CHAVE = SF3.F3_YMOTIVO "
	SX0005 += "    AND SX5.X5_TABELA = 'ZY' "
	SX0005 += "    AND SX5.D_E_L_E_T_ = ' ' "
	SX0005 += "  WHERE SF3.F3_NFISCAL = '"+SF2->F2_DOC+"' "
	SX0005 += "    AND SF3.F3_SERIE = '" +SF2->F2_SERIE+"' "
	SX0005 += "    AND SF3.F3_FILIAL = '"+xFilial("SF3")+"' "
	SX0005 += "    AND SF3.D_E_L_E_T_ = ''	"
	If chkfile("_SX005")
		dbSelectArea("_SX005")
		dbCloseArea()
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SX0005),'_SX005',.T.,.T.)
	_SX005->(DbGotop())
	If !_SX005->(EOF())
		cMotivo := _SX005->X5_DESCRI
	EndIf

	cEmail   := ''
	cEmailCC := ''

	DO CASE

		//Ticket 24250 - Pablo S. Nascimento: solicitação do Claudeir para remover emails e adicionar um.
		//Ticket 24618 - Pablo S. Nascimento: solicitação do Breno Barbieri para removê-lo da listagem do email.
		CASE cEmpAnt == '01'
		cEmail   := 'tatiane.perpetua@biancogres.com.br;dalvina.ferreira@biancogres.com.br;barbara.madeira@biancogres.com.br'
		CASE cEmpAnt == '05'
		cEmail   := 'william.pernes@biancogres.com.br;tatiane.perpetua@biancogres.com.br'
		CASE cEmpAnt == '07'
		IF ALLTRIM(SF2->F2_SERIE) == '1'
			cEmail := 'dalvina.ferreira@biancogres.com.br;barbara.madeira@biancogres.com.br'
		ELSE
			cEmail := 'william.pernes@biancogres.com.br;tatiane.perpetua@biancogres.com.br'
		ENDIF
		CASE cEmpAnt == '12'
		cEmail   := 'tatiane.perpetua@biancogres.com.br'
		CASE cEmpAnt == '13'
		cEmail   := 'rodolfo.stanke@.mundi@biancogres.com.br;dalvina.ferreira@biancogres.com.br;tatiane.perpetua@biancogres.com.br;william.pernes@biancogres.com.br'
		CASE cEmpAnt == '14'
		cEmail   := 'tatiane.perpetua@biancogres.com.br;ingrid.balista@vitcer.com.br;joan.mareto@vitcer.com.br;wagner.bolzan@vitcer.com.br'
		OTHERWISE
		cEmail   := 'tatiane.perpetua@biancogres.com.br'

	ENDCASE

	cMENS := cMENS+'<TR bgcolor="#33CCFF">'
	cMENS := cMENS+'<TD width="45"  valign="Top"><FONT face="Verdana" size="1">'+SF2->F2_DOC+'</TD>'
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+SF2->F2_SERIE+'</TD>'
	cMENS := cMENS+'<TD width="45"  valign="Top"><FONT face="Verdana" size="1">'+SF2->F2_CLIENTE+'</TD>'
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+SF2->F2_LOJA+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+TRANSFORM(SF2->F2_VALBRUT,"@E 999,999.99")+'</TD>'
	cMENS := cMENS+'<TD width="40"  valign="Top"><FONT face="Verdana" size="1">'+SF2->F2_EST+'</TD>'
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+SF2->F2_YSUBTP+'</TD>'
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+cMotivo+'</TD>'
	cMENS := cMENS+'<TD width="200" valign="Top"><FONT face="Verdana" size="1">'+SF2->F2_CHVNFE+'</TD>'
	cMENS := cMENS+'</TR>'

	IF !EMPTY(cMENS)
		Envioemail()
	ENDIF

	//(Thiago Dantas - 07/01/15)
	fExcFunc() //Essa rotina está com problema para excluir NF de Saida de Funcionario - tem que debugar para encontrar o erro
	_SX005->(DbCloseArea())

	If cArqANT <> ""
		dbSelectArea(cArqANT)
		dbSetOrder(cIndANT)
		dbGoTo(cRegANT)
	EndIf
	RestArea(aAreaGer)

Return

//------------------------------------------------------------------(Envioemail)----------------------------------------------------
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
	cMensag := cMensag+'<TITLE> Nota Fiscal Cancelada.</TITLE> '

	cMensag := cMensag+'<BODY> '
	cMensag := cMensag+'<FONT face="Verdana" size="3"> '
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<BR> Segue abaixo as informações referente ao cancelamento da NF '+ALLTRIM(SF2->F2_DOC)+' da empresa '+ALLTRIM(SM0->M0_NOMECOM)+'. '
	cMensag := cMensag+'<BR> Favor verificar no site da Receita Federal se o cancelamento desta NF foi autorizado.'
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<TABLE border="1"> '
	cMensag := cMensag+'<TR bgcolor="#0000CC" bordercolor="#999999"> '
	cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">NF</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Série</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Cliente</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Loja</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Valor</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Estado</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Tipo</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Motivo</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Chave</div></TD> '
	cMensag := cMensag+'</TR> '
	cMensag := cMensag+cMENS
	cMensag := cMensag+'</TABLE> '
	cMensag := cMensag+'<BR> Atenciosamente,'
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'<BR>Qualquer dúvida entre em contato com o setor de TI. '
	cMensag := cMensag+'Este e-mail é automático.'+'<BR> '
	cMensag := cMensag+'Não Responda esta mensagem.'+'<BR> '
	cMensag := cMensag+'<BR> '
	cMensag := cMensag+'</BODY> '
	cMensag := cMensag+'</HTML>'

	cAssunto	:= 'Nota Fiscal Cancelada.'  // Assunto do Email

	U_BIAEnvMail(,cEmail,cAssunto,cMensag,,,.F.,cEmailCC)

	cMensag  := ''
	cMens    := ''

Return

//-------------------------------------------------------------(fExcFunc)---------------------------------------------------------
// Desenv	: Thiago Dantas
// Data		: 23/09/14
// Desc		: Envia noticação para o RH caso seja NF de Funcionário.
//----------------------------------------------------------------------------------------------------------------------------------
Static Function fExcFunc()

	Local cRKSql := ''
	
	// Marcelo - Facile - 30/01/2019 - OS 12107
	// Tratamento para forçar posicionamento da SA1 do cliente antes da deleção.
	Local aGetArea := SA1->(GetArea())
		
	DBSELECTAREA("SA1")
	SA1->(DBSEEK(XFILIAL("SA1")+SF2->F2_CLIENTE))
			
	If SA1->A1_TIPO == "F" .And. ((!SF2->F2_COND $ "000/169" .And. cEmpAnt == "01") .Or. (!SF2->F2_COND $ "900/976" .And. cEmpAnt == "05"))

		cRKSql := GetSqlDeb()
		TcQuery cRKSql New Alias 'RK01'
		RK01->(DbGotop())
		If (RK01->QTD > 0 )
			cMensag  := GeraEmail()
			cEnvia 	 := "workflow@biancogres.com.br"
			cAssunto := "Cancelamento de NF de Venda a funcionários"
			cRecebe  := U_EmailWF('SF250E',cEmpAnt)
			U_BIAEnvMail(cEnvia,cRecebe,cAssunto,cMensag,'','',.F.)

		EndIf
		RK01->(DbCloseArea())

		///////  OS 2607-15 - Luana Marin Ribeiro
		// Verifica se realmente é FUNCIONÁRIO
		AL005 := " SELECT COUNT(*) CONTAD, MAX(RA_MAT) MATRIC, MAX(RA_CC) CC, MAX(RA_NOME) NOMEF, MAX(RA_CLVL) CLVL
		AL005 += "   FROM " + RetSqlName("SRA")
		AL005 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		AL005 += "    AND RA_CIC = '"+Alltrim(SA1->A1_CGC)+"'
		AL005 += "    AND RA_SITFOLH <> 'D'
		AL005 += "    AND D_E_L_E_T_ = ' '
		ALIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,AL005),'AL05',.T.,.T.)
		dbSelectArea("AL05")
		dbGoTop()
		If AL05->CONTAD >= 1

			// Verifica o número do RECNO na SRK
			AX007 := "SELECT SRK.R_E_C_N_O_ REGSRK "
			AX007 += "  FROM " + RetSqlName("SRK") + " SRK "
			AX007 += " WHERE SRK.RK_FILIAL = '" + xFilial("SRK") + "' "
			AX007 += "	 AND SRK.RK_YNFISCA = '" + SF2->F2_DOC + "' "
			AX007 += " 	 AND SRK.RK_YSERNF = '" + SF2->F2_SERIE + "' "
			AX007 += "	 AND RK_MAT = '" + AL05->MATRIC + "' "
			AX007 += "	 AND RK_VALORTO = RK_VLSALDO "
			AX007 += "	 AND SRK.D_E_L_E_T_ = ' ' "
			AXIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,AX007),'AX07',.T.,.T.)
			dbSelectArea("AX07")
			dbGoTop()
			While !AX07->(Eof())
				SRK->(dbGoto(AX07->REGSRK))
				SRK->(Reclock("SRK",.F.))
				SRK->(DbDelete())
				SRK->(MsUnlock())			
				AX07->(dbSkip())
			End
			AX07->(dbCloseArea())

			Ferase(AXIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(AXIndex+OrdBagExt())          //indice gerado

		EndIf

		AL05->(dbCloseArea())
		Ferase(ALIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(ALIndex+OrdBagExt())          //indice gerado	

	EndIf

	RestArea(aGetArea)

Return

//-----------------------------------------------------------------(GetDebFol)-----------------------------------------------------
Static Function GetSqlDeb()

	Local cSqlRet := ""

	cSqlRet += " SELECT SRA.RA_MAT RK_MAT, "
	cSqlRet += "        SRA.RA_NOME, "
	cSqlRet += "        SA1.A1_CGC, "
	cSqlRet += "        COUNT(0) QTD "
	cSqlRet += "   FROM " + RetSqlName("SF2") + " SF2 WITH(NOLOCK) "
	cSqlRet += "  INNER JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cSqlRet += "                                    AND SA1.A1_COD = SF2.F2_CLIENTE "
	cSqlRet += "                                    AND SA1.A1_LOJA = SF2.F2_LOJA "
	cSqlRet += "                                    AND SA1.D_E_L_E_T_ = ' ' "
	cSqlRet += "  INNER JOIN " + RetSqlName("SRA") + " SRA WITH(NOLOCK) ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
	cSqlRet += "                                    AND SRA.RA_CIC = SA1.A1_CGC "
	cSqlRet += "                                    AND SRA.RA_SITFOLH <> 'D' "
	cSqlRet += "                                    AND SRA.D_E_L_E_T_ = ' ' "
	cSqlRet += "  INNER JOIN " + RetSqlName("SRK") + " SRK WITH(NOLOCK) ON SRK.RK_FILIAL = '" + xFilial("SRK") + "' "
	cSqlRet += "                                    AND SRK.RK_MAT = SRA.RA_MAT "
	cSqlRet += "                                    AND SRK.RK_YNFISCA = SF2.F2_DOC "
	cSqlRet += "                                    AND SRK.RK_YSERNF = SF2.F2_SERIE "
	cSqlRet += "                                    AND SRK.D_E_L_E_T_ = ' ' "
	cSqlRet += "  WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
	cSqlRet += "    AND SF2.F2_DOC = '" + SF2->F2_DOC + "' "
	cSqlRet += "    AND SF2.F2_SERIE = '" + SF2->F2_SERIE + "' "
	cSqlRet += "    AND SF2.D_E_L_E_T_ = ' ' "
	cSqlRet += "  GROUP BY SRA.RA_MAT, SRA.RA_NOME, SA1.A1_CGC "

Return cSqlRet

//------------------------------------------------------------------(GeraEmail)----------------------------------------------------
Static Function GeraEmail()

	Local cRetMail := ""

	cRetMail := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRetMail += ' <html xmlns="http://www.w3.org/1999/xhtml">
	cRetMail += ' <head>
	cRetMail += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	cRetMail += ' <title>Untitled Document</title>
	cRetMail += ' </head>
	cRetMail += ' <body>
	cRetMail += ' <font face="Verdana" size="2">
	cRetMail += ' <p>&nbsp;</p>
	cRetMail += ' <p>Para conhecimento,</p>
	cRetMail += ' <p>&nbsp;</p>
	cRetMail += ' <p>Foi cancelada a nota fiscal '+SF2->F2_DOC+' série '+AllTrim(SF2->F2_SERIE)+', nesta data ('+dtoc(SF2->F2_EMISSAO)+'), para pagamento em '+Alltrim(Str(RK01->QTD))+' parcelas contra o funcionário '+RK01->RA_NOME+' CPF: '+Transform(Alltrim(RK01->A1_CGC), "@R 999.999.999-99")+' no valor total de R$ '+Alltrim(Transform(SF2->F2_VALBRUT, "@E 999,999,999.99"))+'.</p>
	//cRetMail += ' <p>O registro para pagamento futuro já foi efetuado nas tabelas de controle da folha de pagamento contra a matrícula '+AL05->MATRIC+', empresa '+Alltrim(SM0->M0_NOME)+'.</p>
	cRetMail += ' <p>Favor efetuar as conferências necessárias.</p>
	cRetMail += ' <p>&nbsp;</p>
	cRetMail += ' <p>Atenciosamente,</p>
	cRetMail += ' <p>&nbsp;</p>
	cRetMail += ' <p>Setor Comercial.</p>
	cRetMail += ' <p>&nbsp;</p>
	cRetMail += ' <p>Informações geradas automaticamente por meio de parametrização do sistema Protheus via ponto de entrada SF2520E.</p>
	cRetMail += ' </font>
	cRetMail += ' </body>
	cRetMail += ' </html>

Return cRetMail
