#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-------------------------------------------------------------------|
| Função:	| BIAF024										        |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas	        |
| Data:		| 03/08/15										        |
|-------------------------------------------------------------------|
| Desc.:	|	Rotina para controle de processos que dependem de	|
| 			|	regularização referente a venda com intuito de  	|
| 			|	Exportação   			 							|
|-------------------------------------------------------------------|
| OS:		|	2392-15 Usuário: Wanisay William  					|
|-------------------------------------------------------------------|
*/


User Function BIAF024A

ConOut("HORA: "+ Time() +" - INICIANDO PROCESSO BIAF024 - BIANCOGRES")
Startjob("U_BIAF024", "SCHEDULE", .T., "01")
ConOut("HORA: "+ Time() +" - FINALIZANDO PROCELUANSSO BIAF024 - BIANCOGRES")

ConOut("HORA: "+ Time() +" - INICIANDO PROCESSO BIAF024 - INCESA")
Startjob("U_BIAF024", "SCHEDULE", .T., "05")
ConOut("HORA: "+ Time() +" - FINALIZANDO PROCESSO BIAF024 - INCESA")

ConOut("HORA: "+ Time() +" - INICIANDO PROCESSO BIAF024 - LM")
Startjob("U_BIAF024", "SCHEDULE", .T., "07")
ConOut("HORA: "+ Time() +" - FINALIZANDO PROCESSO BIAF024 - LM")

ConOut("HORA: "+ Time() +" - INICIANDO PROCESSO BIAF024 - MUNDI")
Startjob("U_BIAF024", "SCHEDULE", .T., "13")
ConOut("HORA: "+ Time() +" - FINALIZANDO PROCESSO BIAF024 - MUNDI")

Return()


User Function BIAF024(cEmp)

Private cItemAte30 := 1
Private cItem30a60 := 1
Private cItemAci60 := 1
Private cMensag := ''
Private cMensAte30 := ''
Private cMens30a60 := ''
Private cMensAci60 := ''
Private nItemPrdAte30 := 0
Private nItemPrd30a60 := 0
Private nItemPrdAci60 := 0
Private cEmail := ''
Private cTipo :=1
Private Enter := CHR(13)+CHR(10)

//cEmp := "01"

If Type("DDATABASE") <> "D"
	
	RpcSetEnv(cEmp, "01",,, "FAT")
	
	fExecute()
	
EndIf

Return


Static Function fExecute()
Local cSQL := ""
Local cQry := GetNextAlias()

cEmail := U_EmailWF('BIAF024', cEmpAnt)
//cEMail := 'luana.ribeiro@biancogres.com.br'

//cSQL := " SELECT F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, A1_NOME, F2_EMISSAO "
//cSQL += " FROM "+RetSqlName("SF2")+" SF2, "+ RetSqlName("SD2") +" SD2, "+ RetSQLName("SA1")+" SA1 "
//cSQL += " WHERE F2_FILIAL = '"+xFilial("SF2")+"'  "
//cSQL += " AND D2_FILIAL = '"+xFilial("SD2")+"'  "
//cSQL += " AND A1_FILIAL = '"+xFilial("SA1")+"'  "
//cSQL += " AND F2_CLIENTE = A1_COD "
//cSQL += " AND F2_LOJA = A1_LOJA "
//cSQL += " AND F2_DOC = D2_DOC "
//cSQL += " AND F2_SERIE = D2_SERIE "
//cSQL += " AND F2_CLIENTE = D2_CLIENTE "
//cSQL += " AND F2_LOJA = D2_LOJA "
//cSQL += " AND D2_ITEM = '01' "
//cSQL += " AND D2_CF IN ('5501','5502','7101','7102') "                    
////cSQL += " AND A1_YREGIMP = 'S' "
//cSQL += " AND F2_TIPO = 'N' "
//cSQL += " AND F2_YDTINT = ''  "
//cSQL += " AND F2_EMISSAO > '20140101' "
//cSQL += " AND SF2.D_E_L_E_T_ = '' "
//cSQL += " AND SD2.D_E_L_E_T_ = '' "
//cSQL += " AND SA1.D_E_L_E_T_ = '' "
//cSQL += " ORDER BY F2_CLIENTE, F2_LOJA, A1_NOME"

cSQL := "SELECT F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, A1_NOME, F2_EMISSAO "
cSQL += "FROM " + RetSqlName("SF2") + " SF2 "
cSQL += "	INNER JOIN " + RetSqlName("SD2") + " SD2 "
cSQL += "		ON F2_DOC = D2_DOC "
cSQL += "			AND F2_SERIE = D2_SERIE "
cSQL += "			AND F2_CLIENTE = D2_CLIENTE "
cSQL += "			AND F2_LOJA = D2_LOJA "
cSQL += "			AND D2_FILIAL = '" + xFilial("SD2") + "' "
cSQL += "			AND D2_ITEM = '01' "
cSQL += "			AND D2_CF IN ('5501','5502','7101','7102') "
cSQL += "			AND SD2.D_E_L_E_T_ = '' "
cSQL += "	INNER JOIN " + RetSQLName("SA1") + " SA1 "
cSQL += "		ON F2_CLIENTE = A1_COD "
cSQL += "			AND F2_LOJA = A1_LOJA "
cSQL += "			AND A1_FILIAL = '" + xFilial("SA1") + "' "
//cSQL += "			AND A1_YREGIMP = 'S' "
cSQL += "			AND SA1.D_E_L_E_T_ = '' "
cSQL += "WHERE F2_FILIAL = '" + xFilial("SF2") + "' "
cSQL += "	AND F2_TIPO = 'N' "
cSQL += "	AND F2_YDTEXP = '' "
cSQL += "	AND F2_EMISSAO > '20140101' "
cSQL += "	AND SF2.D_E_L_E_T_ = '' "
cSQL += "ORDER BY F2_CLIENTE, F2_LOJA, A1_NOME, F2_EMISSAO "


TcQuery cSQL New Alias (cQry)

While !(cQry)->(Eof())
	
	If (dDataBase - sToD((cQry)->F2_EMISSAO)) <= 30  //envia mensagem de aviso
		
		If cItemAte30 = 1
			
			cMensAte30 += '<TR bgcolor="#33CCFF">'
			cItemAte30 := 0
			
		Else
			
			cMensAte30 += '<TR bgcolor="#FFFFFF">'
			cItemAte30 := 1
			
		EndIf
		
		nItemPrdAte30 := nItemPrdAte30 + 1
		
		nDias := dDataBase - (sToD((cQry)->F2_EMISSAO) + 60)
		dPrazo := dToS(sToD((cQry)->F2_EMISSAO) + 60)
		
		cMensAte30 += '<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrdAte30,5)+'</TD>'
		cMensAte30 += '<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+(cQry)->F2_CLIENTE+"/"+(cQry)->F2_LOJA+'</TD>'
		cMensAte30 += '<TD width="450" valign="Top"><FONT face="Verdana" size="1">'+(cQry)->A1_NOME+'</TD>'
		cMensAte30 += '<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+(cQry)->F2_SERIE+"/"+(cQry)->F2_DOC+'</TD>'
		cMensAte30 += '<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR((cQry)->F2_EMISSAO,7,2)+"/"+SUBSTR((cQry)->F2_EMISSAO,5,2)+"/"+SUBSTR((cQry)->F2_EMISSAO,1,4)+'</TD>'
		cMensAte30 += '<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(dPrazo,7,2)+"/"+SUBSTR(dPrazo,5,2)+"/"+SUBSTR(dPrazo,1,4)+'</TD>'
		cMensAte30 += '<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nDias,5)+'</TD>'
		cMensAte30 += '</TR>'
	ElseIf (dDataBase - sToD((cQry)->F2_EMISSAO)) > 30 .And. (dDataBase - sToD((cQry)->F2_EMISSAO)) <= 60  //envia mensagem de aviso
		
		If cItem30a60 = 1
			
			cMens30a60 += '<TR bgcolor="#33CCFF">'
			cItem30a60 := 0
			
		Else
			
			cMens30a60 += '<TR bgcolor="#FFFFFF">'
			cItem30a60 := 1
			
		EndIf
		
		nItemPrd30a60 := nItemPrd30a60 + 1
		
		nDias := dDataBase - (sToD((cQry)->F2_EMISSAO) + 60)
		dPrazo := dToS(sToD((cQry)->F2_EMISSAO) + 60)
		
		cMens30a60 += '<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd30a60,5)+'</TD>'
		cMens30a60 += '<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+(cQry)->F2_CLIENTE+"/"+(cQry)->F2_LOJA+'</TD>'
		cMens30a60 += '<TD width="450" valign="Top"><FONT face="Verdana" size="1">'+(cQry)->A1_NOME+'</TD>'
		cMens30a60 += '<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+(cQry)->F2_SERIE+"/"+(cQry)->F2_DOC+'</TD>'
		cMens30a60 += '<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR((cQry)->F2_EMISSAO,7,2)+"/"+SUBSTR((cQry)->F2_EMISSAO,5,2)+"/"+SUBSTR((cQry)->F2_EMISSAO,1,4)+'</TD>'
		cMens30a60 += '<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(dPrazo,7,2)+"/"+SUBSTR(dPrazo,5,2)+"/"+SUBSTR(dPrazo,1,4)+'</TD>'
		cMens30a60 += '<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nDias,5)+'</TD>'
		cMens30a60 += '</TR>'
		
	ElseIf (dDataBase - sToD((cQry)->F2_EMISSAO)) > 60  //envia mensagem de aviso e bloqueia cliente nos ambientes cabíveis
		
		If cItemAci60 = 1
			
			cMensAci60 += '<TR bgcolor="#33CCFF">'
			cItemAci60 := 0
			
		Else
			
			cMensAci60 += '<TR bgcolor="#FFFFFF">'
			cItemAci60 := 1
			
		EndIf
		
		nItemPrdAci60 := nItemPrdAci60 + 1
		
		nDias := dDataBase - (sToD((cQry)->F2_EMISSAO) + 60)
		dPrazo := dToS(sToD((cQry)->F2_EMISSAO) + 60)
		
		cMensAci60 += '<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrdAci60,5)+'</TD>'
		cMensAci60 += '<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+(cQry)->F2_CLIENTE+"/"+(cQry)->F2_LOJA+'</TD>'
		cMensAci60 += '<TD width="450" valign="Top"><FONT face="Verdana" size="1">'+(cQry)->A1_NOME+'</TD>'
		cMensAci60 += '<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+(cQry)->F2_SERIE+"/"+(cQry)->F2_DOC+'</TD>'
		cMensAci60 += '<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR((cQry)->F2_EMISSAO,7,2)+"/"+SUBSTR((cQry)->F2_EMISSAO,5,2)+"/"+SUBSTR((cQry)->F2_EMISSAO,1,4)+'</TD>'
		cMensAci60 += '<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(dPrazo,7,2)+"/"+SUBSTR(dPrazo,5,2)+"/"+SUBSTR(dPrazo,1,4)+'</TD>'
		cMensAci60 += '<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nDias,5)+'</TD>'
		cMensAci60 += '</TR>'
		
		cQuery  := ""
		cQuery  += "UPDATE SA1010 "
		cQuery  += "SET A1_RISCO = 'E', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '" + (cQry)->F2_CLIENTE + "' AND "
		cQuery  += " A1_LOJA  = '" + (cQry)->F2_LOJA + "' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)
		
		cQuery  := ""
		cQuery  += "UPDATE SA1050 "
		cQuery  += "SET A1_RISCO = 'E', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '" + (cQry)->F2_CLIENTE + "' AND "
		cQuery  += " A1_LOJA  = '" + (cQry)->F2_LOJA + "' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)
		
		cQuery  := ""
		cQuery  += "UPDATE SA1070 "
		cQuery  += "SET A1_RISCO = 'E', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '" + (cQry)->F2_CLIENTE + "' AND "
		cQuery  += " A1_LOJA  = '" + (cQry)->F2_LOJA + "' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)
		
		cQuery  := ""
		cQuery  += "UPDATE SA1120 "
		cQuery  += "SET A1_RISCO = 'E', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '" + (cQry)->F2_CLIENTE + "' AND "
		cQuery  += " A1_LOJA  = '" + (cQry)->F2_LOJA + "' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)
		
		cQuery  := ""
		cQuery  += "UPDATE SA1130 "
		cQuery  += "SET A1_RISCO = 'E', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '" + (cQry)->F2_CLIENTE + "' AND "
		cQuery  += " A1_LOJA  = '" + (cQry)->F2_LOJA + "' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)
		
		cQuery  := ""
		cQuery  += "UPDATE SA1140 "
		cQuery  += "SET A1_RISCO = 'E', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '" + (cQry)->F2_CLIENTE + "' AND "
		cQuery  += " A1_LOJA  = '" + (cQry)->F2_LOJA + "' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)
	EndIf
	
	(cQry)->(DbSkip())
	
EndDo

(cQry)->(DbCloseArea())


If !Empty(cMensAte30)
	cItem := 1
	fEnviaEMail()
ENDIF

If !Empty(cMens30a60)
	cItem := 2
	fEnviaEMail()
ENDIF

If !Empty(cMensAci60)
	cItem := 3
	fEnviaEMail()
ENDIF

Return()



Static Function fEnviaEMail()

cMensag := ''
cMensag += '<HTML>'
cMensag += '<script language="JavaScript"><!--'+;
'function MM_reloadPage(init) {  //reloads the window if Nav4 resized'+;
'if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {'+;
'document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}'+;
'else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();'+;
'}'+;
'MM_reloadPage(true);// -->'

cMensag += '</script> '
If cItem == 1
	cMensag += '<TITLE> Relação de Clientes com documentação de Exportação em aberto até 30 dias.</TITLE> '
ElseIf cItem == 2
	cMensag += '<TITLE> Relação de Clientes com documentação de Exportação em aberto de 31 a 60 dias.</TITLE> '
ElseIf cItem == 3
	cMensag += '<TITLE> Relação de Clientes com documentação de Exportação em aberto acima de 60 dias.</TITLE> '
EndIf

// DADOS DA BIANCOGRES
cMensag += '<BODY> '
cMensag += '<FONT face="Verdana" size="1"> '

// MENSAGENS AUTOMATICAS
cMensag += '<BR> '

// OBSERVACOES
If cItem == 1
	cMensag += '<BR> Segue abaixo a relação de clientes com documentação de Exportação em aberto até 30 dias - '+AllTrim(SM0->M0_NOMECOM)+':'
ElseIf cItem == 2
	cMensag += '<BR> Segue abaixo a relação de clientes com documentação de Exportação em aberto de 31 a 60 dias - '+AllTrim(SM0->M0_NOMECOM)+':'
ElseIf cItem == 3
	cMensag += '<BR> Segue abaixo a relação de clientes com documentação de Exportação em aberto acima de 60 dias - '+AllTrim(SM0->M0_NOMECOM)+':'
EndIf

cMensag += '<BR> '

// DADOS DA TABELA
cMensag += '<TABLE border="1"> '
cMensag += '<TR bgcolor="#0000CC" bordercolor="#999999"> '
cMensag += '<TD width="30"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '
cMensag += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Cliente/Loja</div></TD> '
cMensag += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Razão Social</div></TD> '
cMensag += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Serie/NF</div></TD> '
cMensag += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Data da emissão</div></TD> '
cMensag += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Prazo de validade para Bloqueio</div></TD> '
cMensag += '<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Atraso em dias</div></TD> '
cMensag += '</TR> '
If cItem == 1
	cMensag += cMensAte30
ElseIf cItem == 2
	cMensag += cMens30a60
ElseIf cItem == 3
	cMensag += cMensAci60
EndIf
cMensag += '</TABLE> '

// RODAPE
cMensag += '<BR> '
cMensag += '<BR> Atenciosamente,'
cMensag += '<BR> '
cMensag += '<BR>Qualquer dúvida entre em contato com o departamento contábil. '
cMensag += 'Este e-mail é automático.'+'<BR> '
cMensag += 'Não Responda esta mensagem.'+'<BR> '
cMensag += '<BR> '

cMensag += '</BODY> '
cMensag += '</HTML>'

If cItem == 1
	cAssunto	:= 'Relação de Clientes com documentação de Exportação em aberto até 30 dias'
ElseIf cItem == 2
	cAssunto	:= 'Relação de Clientes com documentação de Exportação em aberto de 31 a 60 dias'
ElseIf cItem == 3
	cAssunto	:= 'Relação de Clientes com documentação de Exportação em aberto acima de 60 dias'
EndIf

U_BIAEnvMail(,cEmail,cAssunto,cMensag)

cMensag := ''
cMens := ''
nItemPrd := 0

Return()
