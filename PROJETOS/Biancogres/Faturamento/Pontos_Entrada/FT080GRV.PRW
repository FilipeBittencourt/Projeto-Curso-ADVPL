#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FT080GRV ³ Autor ³ Ranisses A. Corona    ³ Data ³ 18/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Bloqueia a regra caso o desconto informado seja maior que  ³±±
±±³          ³ o parametro MV_YDIRDES e se a regra for do tipo Acrescer   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Faturamento                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FT080GRV()
Private cSql	:= ""
Private Enter	:= CHR(13)+CHR(10)   
Private nLinha  := ACO->ACO_YLINHA
Private nNomEmp := ""
Private lFlag	:= .T.
Private C_HTML	:= ""
Private cCodDir	:= "" //GetMV("MV_YDIRCOD") //Codigo do Diretor para Liberacao
Private	cDesDir	:= 0  //GetMV("MV_YDIRDES") //Percentual para Desconto do Diretor 

//FOI EXECUTADO UMA UNICA VEZ, PARA CORRIGIR A SEQUENCIA DE FAIXA NO ACO E ACP              
cAliasTmp := GetNextAlias()
BeginSql Alias cAliasTmp
	SELECT * FROM %Table:ACO% 	WHERE %NOTDEL%
EndSql
While  !(cAliasTmp)->(EOF())
	cSql := "UPDATE "+RetSqlName("ACO")+" SET ACO_CFAIXA = '"+Inverte(Alltrim(StrZero((cAliasTmp)->ACO_FAIXA,18,2)))+"' WHERE ACO_CODREG = '"+(cAliasTmp)->ACO_CODREG+"' "
	TcSQLExec(cSQL)
	(cAliasTmp)->(DBSKIP())
End
(cAliasTmp)->(dbCloseArea())


cAliasTmp := GetNextAlias()
BeginSql Alias cAliasTmp
	SELECT * FROM %Table:ACP% 	WHERE %NOTDEL% ORDER BY ACP_CODREG
EndSql
nCount := 1
While  !(cAliasTmp)->(EOF())
	cSql := "UPDATE "+RetSqlName("ACP")+" SET ACP_FAIXA = '"+Alltrim(Str(nCount))+"', ACP_CFAIXA = '"+Alltrim(StrZero(nCount,18,2))+"' WHERE R_E_C_N_O_ = '"+Alltrim(Str((cAliasTmp)->R_E_C_N_O_))+"' "
	TcSQLExec(cSQL)
	nCount := nCount + 1
	(cAliasTmp)->(DBSKIP())
End
(cAliasTmp)->(dbCloseArea())


//Busca o Diretor/Desconto para Liberacao
cSql := "SELECT ZM_CODAPRO, ZM_DESC 			"
cSql += "FROM "+RetSqlName("SZM")+"				" 
cSql += "WHERE	ZM_LINHA   = '"+nLinha+"'	AND	"
cSql += "		ZM_TIPO    = '1'			AND	" //Diretor
cSql += "		D_E_L_E_T_ = ''					"
If chkfile("_SZM")
	dbSelectArea("_SZM")
	dbCloseArea()
EndIf
TcQuery cSql ALIAS "_SZM" NEW
cCodDir := _SZM->ZM_CODAPRO
cDesDir := _SZM->ZM_DESC

//Se nao for Diretor ira executar a verificacao e se a Regra nao estiver bloqueada
If cCodDir <> __cUserId .And. ACO->ACO_MSBLQL <> "1"
	//Selecionando maior Desconto da Regra
	cSql := "SELECT ACO.ACO_CODREG, MAX(ACP1.ACP_PERDES) ACP_PERDES				" + Enter
	cSql += "FROM "+RetSqlName("ACO")+" ACO, "+RetSqlName("ACP")+" ACP1	" + Enter
	cSql += "WHERE ACO.ACO_CODREG	= ACP1.ACP_CODREG	AND				" + Enter
	cSql += "      ACO.ACO_CODREG	= '"+ACO->ACO_CODREG+"'	AND	" + Enter
	cSql += "      ACO.ACO_MSBLQL	<> '1'	AND									" + Enter	
	cSql += "      ACO.D_E_L_E_T_	= ''		AND									" + Enter
	cSql += "      ACP1.D_E_L_E_T_ = ''												" + Enter
	cSql += "GROUP BY ACO.ACO_CODREG
	If chkfile("TRB")
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "TRB" NEW

	//Verifica se a Regra e do tipo Acrescer
	cSql := "SELECT COUNT(*) QUANT															" + Enter
	cSql += "FROM "+RetSqlName("ACP")+" ACP1										" + Enter
	cSql += "WHERE ACP1.ACP_CODREG	= '"+ACO->ACO_CODREG+"'	AND	" + Enter
	cSql += "      ACP1.ACP_YTPDES <> 'S'										AND " + Enter
	cSql += "      ACP1.D_E_L_E_T_	= ''												" + Enter
	If chkfile("TRB1")
		dbSelectArea("TRB1")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "TRB1" NEW

	//Bloqueia a Regra caso a Desconto_Regra ultrapasse o Desconto_Diretor
	If TRB->ACP_PERDES > cDesDir
		MsgBox("A Regra "+ACO->ACO_CODREG+" será bloqueada, pois o ultrapassa o percentual de liberação do Diretor! Favor solicitar liberação do Diretor!","Atencao","ALERT")
		lFlag	:= .F.
		RecLock("ACO",.F.)
		ACO_MSBLQL := "1"
		MsUnLock()

		//Grava Mensagem para o E-mail
		C_HTML += '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
		C_HTML += '<html>'
		C_HTML += '<head>'
		C_HTML += '  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">'
		C_HTML += '  <title>Desconto</title>'
		C_HTML += '</head>'
		C_HTML += '<body>'
		C_HTML += '<br style="font-family: Arial Black;">'
		C_HTML += '<span style="font-family: Calibri;">A Regra de Desconto '+Alltrim(ACO->ACO_CODREG)+'-'+Alltrim(ACO->ACO_DESCRI)+', foi cadastrada com percental maior que o de liberação do Diretor e foi bloqueada.</span><br style="font-family: Calibri;">'
		C_HTML += '<br style="font-family: Calibri;">'
		C_HTML += '<span style="font-family: Calibri;">Favor acessar a rotina de Regra de Desconto para efetuar a análise da regra, e se preciso efetuar o desbloqueio.</span>'
		C_HTML += '</body>'
		C_HTML += '</html>'
		
	EndIf

	//Bloqueia a Regra caso a mesma for do tipo "Acrescer"
	If TRB1->QUANT > 0 .And. lFlag
		MsgBox("A Regra "+ACO->ACO_CODREG+" será bloqueada, pois utiliza o conceito Acrescer! Favor solicitar liberação do Diretor!","Atencao","ALERT")
		RecLock("ACO",.F.)
		ACO_MSBLQL := "1"
		MsUnLock()
	
		//Grava Mensagem para o E-mail
		C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
		C_HTML += '<html>'
		C_HTML += '<head>'
		C_HTML += '  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">'
		C_HTML += '  <title>Desconto</title>'
		C_HTML += '</head>'
		C_HTML += '<body>'
		C_HTML += '<br style="font-family: Arial Black;">'
		C_HTML += '<span style="font-family: Calibri;">A Regra de Desconto '+Alltrim(ACO->ACO_CODREG)+'-'+Alltrim(ACO->ACO_DESCRI)+', foi cadastrada com o Tipo de Desconto "Acrescentar" e foi bloqueada.</span><br style="font-family: Calibri;">'
		C_HTML += '<br style="font-family: Calibri;">'
		C_HTML += '<span style="font-family: Calibri;">Favor acessar a rotina de Regra de Desconto para efetuar a análise da regra, e se preciso efetuar o desbloqueio.</span>'
		C_HTML += '</body>'
		C_HTML += '</html>'
	
	EndIf

	If !Empty(C_HTML)
 		
		If nLinha == "1"
			nNomEmp := "BIANCOGRES"
		ElseIf nLinha == "2"
			nNomEmp := "INCESA"
		Else
			nNomEmp := "BELLACASA"
		EndIf
	
		lFormTexto		:= .T.
		aDestinatario	:= UsrRetMail(cCodDir) //E-mail
		aCC				:= ""
		aCCO			:= "ranisses.corona@biancogres.com.br" 
		cTitulo			:= "Bloqueio Regra de Desconto - " + nNomEmp
		cTexto			:= C_HTML
		cErro			:= ""
		cAnexo			:= ""

		//Envia e-mail 
		//U_SendMail(lFormTexto,cTexto,cTitulo,cRemetente,{aDestinatario},{aCC},{aCCO})
		U_BIAEnvMail(,aDestinatario,cTitulo,cTexto,cErro,cAnexo,,aCC,aCCO )
	EndIf
	
EndIf

If chkfile("TRB")
	DbSelectArea("TRB")
	DbCloseArea("TRB")
EndIf

If chkfile("TRB1")
	DbSelectArea("TRB1")
	DbCloseArea("TRB1")
EndIf

Return()