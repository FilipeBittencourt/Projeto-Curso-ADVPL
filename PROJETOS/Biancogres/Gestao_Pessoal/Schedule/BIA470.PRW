#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

#DEFINE TPSALARIO 1
#DEFINE TPFUNCAO 2

//------------------------------------------------------------------------------
// Função 	 : BIA470
// Autor 	 : Wanisay		
// Descricao : Envio de e-mail na alteracao de salario e funcao.
//------------------------------------------------------------------------------
User Function BIA470(AA_EMP)
Private lDebug := .F.

	If lDebug
		AA_EMP := '01'	
	EndIf
	
	RPCSetType(3)
	
	If Type("DDATABASE") <> "D"
		If AA_EMP == "01"
			RPCSETENV("01","01",,,"FAT")
		Else
			RPCSETENV("05","01",,,"FAT")
		EndIf
	EndIf

Private aLista     := {}
Private nI         := 1
Private cMENS	   := ''
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
Private nVrTotAnt := 0
Private nVrTotAtu := 0

Processa({|| Analisa(TPSALARIO)})
Processa({|| Analisa(TPFUNCAO)})

Return


Static Function Envioemail()
Local cEmail := ''
Local cEmailCC := ''
Local lOk

	cMensag := cMENS
	
	If (SubStr(AllTrim(cCLVL),1,1) == '8' .Or. AllTrim(cCLVL) $ '4000/4080')
		cEmail := 'darks.casotti@biancogres.com.br'
		cEmailCC := ''
	Else
		cEmail := U_EmailWF('BIA470',cEmpAnt,AllTrim(cCLVL)) 
	EndIf
	
	
	If Empty(cEmail)
		cEmail := 'wanisay.william@biancogres.com.br'
	EndIf
	
	
	cEnvia := "administrador@biancogres.com.br"		  					  // Email do Emissor
	cRecebe := cEmail														  // Email do(s) receptor(es)
	cRecebeCC	:= cEmailCC  												  // Com Copia
	cRecebeCO	:= ""						  								  // Copia Oculta
	
	
	If tpAnalise == TPSALARIO
		cAssunto := 'Relação de alterações salariais' 			  // Assunto do Email
	Else
		cAssunto := 'Relação de alterações funcionais' 			  // Assunto do Email
	EndIf
	 
	
	If lDebug
		cAssunto += ' - ' + cRecebe
		cRecebe := 'barbara.coelho@biancogres.com.br'//'tiago@facilesistemas.com.br'
		cRecebeCC := ''
	EndIf    
	
	
	lOK := U_BIAEnvMail(,cRecebe,cAssunto,cMensag)
	
	If !lOK
		ConOut("ERRO AO ENVIAR EMAIL... WORKFLOW BIA470")
	Else
		ConOut("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIA470")
	EndIf

Return()


Static Function Analisa(pTPAnalise)
Local lEnvia := .F.
Private tpAnalise := pTPAnalise

	cMENS := ''
	
	DbSelectArea("SRA")
	DbSetOrder(1)
	
	dDataIni := DTOS(Ddatabase - 7)
	dDataFim := DTOS(Ddatabase)
	
	cQuery := GetSql()
	If chkfile("QRY")
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf	
	TCQUERY cQuery ALIAS "QRY" NEW
	
	DbSelectArea("QRY")
	DbGoTop()
	
	Setprc(0,0)
	
	While !EOF()
		
		cMENS := ""	
		cCLVL := QRY->RA_CLVL
		nItemPrd := 0
		lEnvia := .F.
		
		GetCabec()
		
		While !EOF() .And. AllTrim(cCLVL) == AllTrim(QRY->RA_CLVL)
			
			lEnvia := .T.
			
			nItemPrd++
			
			GeraItem()
			
			DbSelectArea("QRY")
			
			("QRY")->(DbSkip())
			
		EndDo	    
	    
	 	
	 	If lEnvia
	    
	 		GetRodape()
			
			Envioemail()
	    
	  EndIf
	    
		DbSelectArea("QRY")
		
	EndDo
	
	
	DbSelectArea("QRY")
	DbCloseArea()

Return 


Static Function GetCabec()

	cMENS := ''
	cMENS += '<HTML>'
	cMENS += '<script language="JavaScript"><!--'
	cMENS +='function MM_reloadPage(init) {  //reloads the window if Nav4 resized'
	cMENS +='if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {'
	cMENS +='document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}'
	cMENS +='else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();'
	cMENS +='}'
	cMENS +='MM_reloadPage(true);// -->'
	cMENS += '</script> ' + Enter
	
	If tpAnalise == TPSALARIO
		cMENS += '<TITLE> Relação de Alterações Salariais </TITLE> '
	Else
		cMENS += '<TITLE> Relaçãp de Alterações Funcionais </TITLE> '
	EndIf
	
	cMENS += '<TITLE> Relação de Alterações Salariais e Funcionais </TITLE> '
	
	cMENS += '<BODY> '
	cMENS += '<FONT face="Verdana" size="1"> '
	cMENS := cMENS+'<BR> '
	
	If tpAnalise == TPSALARIO
		cMENS += '<BR> Segue abaixo a relação das alterações salariais nesta semana '+Alltrim(SM0->M0_NOMECOM)+':'
	Else
		cMENS += '<BR> Segue abaixo a relação das alterações funcionais nesta semana '+Alltrim(SM0->M0_NOMECOM)+':'
	EndIf
	
	cMENS +='<BR> '
	cMENS += '<TABLE border="1"> '
	cMENS += '<TR bgcolor="#0000CC" bordercolor="#999999"> '
	cMENS += '<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
	cMENS += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Matrícula</div></TD> '
	cMENS += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Nome do Funcionário</div></TD> '
	cMENS += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Função</div></TD> '
	cMENS += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Classe de Valor</div></TD> '
	cMENS += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data da Alteração</div></TD> '
	cMENS += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Alterado por</div></TD> '
	cMENS += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Campo alterado</div></TD> '
	cMENS += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Conteúdo Anterior</div></TD> '
	cMENS += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Conteúdo Atual</div></TD> '
	
	If tpAnalise == TPSALARIO
		cMENS += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">% de Reajuste</div></TD> '
	EndIf
	
	cMENS += '</TR>'
	
Return


Static Function GeraItem()

	If tpAnalise == TPFUNCAO
		cQry := "SELECT	RJ_DESC " + Enter
		cQry += "  FROM "+RetSqlName("SRJ")+" SRJ    " + Enter
		cQry += "  WHERE	RJ_FUNCAO = '"+ALLTRIM(QRY->CONTEUDO)+"' " + Enter
		cQry += "        AND SRJ.D_E_L_E_T_ =  '' " + Enter
		If chkfile("QRY1")
			dbSelectArea("QRY1")
			dbCloseArea()
		EndIf
		TCQUERY cQry ALIAS "QRY1" NEW
		DbSelectArea("QRY1")
		cDescAnt := QRY1->RJ_DESC
		
		cQry := "SELECT	RJ_DESC " + Enter
		cQry := cQry + "  FROM "+RetSqlName("SRJ")+" SRJ    " + Enter
		cQry := cQry + "  WHERE	RJ_FUNCAO = '"+ALLTRIM(QRY->RA_CODFUNC)+"' " + Enter
		cQry := cQry + "        AND SRJ.D_E_L_E_T_ =  '' " + Enter
		If chkfile("QRY2")
			dbSelectArea("QRY2")
			dbCloseArea()
		EndIf
		TCQUERY cQry ALIAS "QRY2" NEW
		DbSelectArea("QRY2")
		cDescAtu := QRY2->RJ_DESC
		
		("QRY2")->(dbCloseArea())
	EndIf
	
	cQry := "SELECT	RJ_DESC " + Enter
	cQry += "  FROM "+RetSqlName("SRA")+" SRA, "+RetSqlName("SRJ")+" SRJ " + Enter
	cQry += "  WHERE	RA_MAT = '"+QRY->RA_MAT+"' " + Enter
	cQry += "        AND RA_CODFUNC = RJ_FUNCAO " + Enter
	cQry += "        AND SRJ.D_E_L_E_T_ =  '' " + Enter
	cQry += "        AND SRA.D_E_L_E_T_ =  '' " + Enter
	
	If chkfile("QRY3")
		dbSelectArea("QRY3")
		dbCloseArea()
	EndIf
	
	TCQUERY cQry ALIAS "QRY3" NEW
	DbSelectArea("QRY3")
	cFuncao := AllTrim(QRY3->RJ_DESC)
	("QRY3")->(dbCloseArea())
	
	cMENS += '<TR>'
	cMENS += '<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
	cMENS += '<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+QRY->RA_MAT+'</TD>'
	cMENS += '<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+QRY->RA_NOME+'</TD>'
	cMENS += '<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+cFuncao+'</TD>'
	cMENS += '<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+QRY->RA_CLVL+'</TD>'
	cMENS += '<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+QRY->DATAALT+'</TD>'
	cMENS += '<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+QRY->USUARIO+'</TD>'
	
	If tpAnalise == TPSALARIO

		cMENS += '<TD width="100" valign="Top"><FONT face="Verdana" size="1">Salário</TD>'
		cMENS += '<TD width="70"  valign="Top"><FONT face="Verdana" size="1">'+STR(Val(QRY->CONTEUDO),9,2)+'</TD>'
		cMENS += '<TD width="250" valign="Top"><FONT face="Verdana" size="1">'+STR(QRY->RA_SALARIO,9,2)+'</TD>'
		
		nVrTotAnt += Val(QRY->CONTEUDO)
		nVrTotAtu += QRY->RA_SALARIO
		
	Else
		cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">Função</TD>'
		cMENS := cMENS+'<TD width="70"  valign="Top"><FONT face="Verdana" size="1">'+QRY->CONTEUDO+"-"+cDescAnt+'</TD>'
		cMENS := cMENS+'<TD width="250" valign="Top"><FONT face="Verdana" size="1">'+ALLTRIM(QRY->RA_CODFUNC)+"-"+cDescAtu+'</TD>'	
  EndIf
	
	nPercent := QRY->RA_SALARIO - Val(QRY->CONTEUDO)
	nPercent := (100* nPercent) / Val(QRY->CONTEUDO)
	
	If tpAnalise == TPSALARIO
		cMENS += '<TD width="250" valign="Top"><FONT face="Verdana" size="1">'+STR(nPercent,9,2)+'% </TD>' 
	EndIf
  
	cMENS += '</TR>'
	
Return


Static Function GetRodape()
	
	If tpAnalise == TPSALARIO
		
		cMENS += '<TR>' 
		cMENS += '<TD style="text-align: right;" colspan="8" rowspan="1"><FONT face="Verdana" size="1"></TD>'
	 	cMENS += '<TD valign="Top"><FONT face="Verdana" size="1">'+Str(nVrTotAnt,9,2)+'</TD>'
	 	cMENS += '<TD valign="Top"><FONT face="Verdana" size="1">'+Str(nVrTotAtu,9,2)+'</TD>'	 	
	  cMENS += '</TR>'
	  
	EndIf

	cMENS += '</TABLE>'
	cMENS += '<BR>Qualquer dúvida entre em contato com o departamento de Gestão de Pessoal. '
	cMENS += 'Este e-mail é automático (BIA470).'+'<BR> '
	cMENS += 'Não Responda esta mensagem.'+'<BR> '
	cMENS += '<BR> '
	cMENS += '</BODY> '
	cMENS += '</HTML>'
	
	nVrTotAnt := 0
	nVrTotAtu := 0	

Return()


Static Function GetSql()
Local cSql := ''

cSql := " SELECT	" + Enter
cSql += "  AT_NAME AS USUARIO, CONVERT(VARCHAR(10),CONVERT(DATETIME,AT_DATE),103) AS DATAALT, AT_TIME AS HORA, " + Enter
cSql += "  OPERACAO = CASE " + Enter
cSql += "       WHEN AT_OP = 'I' THEN 'INCLUSÃO'    " + Enter
cSql += "       WHEN AT_OP = 'U' THEN 'ALTERAÇÃO'   " + Enter
cSql += "       WHEN AT_OP = 'D' THEN 'EXCLUSÃO'    " + Enter
cSql += "       WHEN AT_OP = 'O' THEN 'PROGRAMA'    " + Enter
cSql += "       WHEN AT_OP = 'X' THEN 'COMANDO SQL' " + Enter
cSql += "       ELSE AT_OP END,                     " + Enter
cSql += "  AT_TABLE AS TABELA, AT_RECID AS RECNO, AT_FIELD AS CAMPO, AT_CONTENT AS CONTEUDO,   " + Enter
cSql += "  ISNULL(CONVERT(VARCHAR(500),CONVERT(BINARY(500),AT_EXECUTE)),'') AS 'COMANDO SQL',  " + Enter
cSql += "  RA_SALARIO, RA_MAT, RA_CLVL, RA_NOME, RA_SITFOLH, RA_CODFUNC, RA_CBO, RA_YSEMAIL " + Enter
//cSql += " FROM DADOSAUDIT_2014..AUDIT_TRAIL"+ Enter
//cSql += " FROM DADOSAUDIT_2015..AUDIT_TRAIL"+ Enter
//cSql += " FROM DADOSAUDIT_2016..AUDIT_TRAIL"+ Enter
//cSql += " FROM ZEUS.DADOSAUDIT_2017.dbo.AUDIT_TRAIL"+ Enter
//cSql += " FROM ZEUS.DADOSAUDIT_2018.dbo.AUDIT_TRAIL"+ Enter
//cSql += " FROM ZEUS.DADOSAUDIT_2019.dbo.AUDIT_TRAIL AS TMP " + Enter
cSql += " FROM ZEUS.DADOSAUDIT_2020.dbo.AUDIT_TRAIL AS TMP " + Enter
cSql +=	" INNER JOIN " + RetSqlName("SRA") + " SRA ON AT_RECID =  SRA.R_E_C_N_O_ " + Enter

If lDebug
	cSql += " WHERE	AT_DATE	BETWEEN '20190318' AND '20190328' " + Enter 
Else
	cSql += " WHERE	AT_DATE	BETWEEN '"+dDataIni+"' AND '"+dDataFim+"'  " + Enter
EndIf

//cSql += " AND AT_TABLE LIKE '"+RetSqlName("SRA")+"%' " + Enter

If tpAnalise == TPSALARIO
	cSql += " AND AT_FIELD LIKE 'RA_SALARIO%'    " + Enter
Else
	cSql += " AND AT_FIELD LIKE 'RA_CODFUNC%'    " + Enter
EndIf

cSql += " AND SRA.D_E_L_E_T_ =  '' " + Enter
cSql += " ORDER BY RA_CLVL, DATAALT, RA_NOME " + Enter

Return cSql