Static Function WorkEnv(aCliSuper,dIni,dLimite,cNomOper,cEmailDest)
	
	Local cHtml := ""	
	cHtml := '<!DOCTYPE html>'
	cHtml += '<html>'
	cHtml += '<head>'
	cHtml += '<style>'
	cHtml +='table {'
	cHtml +='    	font-family: Arial,Helvetica,sans-serif;'
	cHtml +=' 		border-collapse: collapse;'
	cHtml +='    	width: 100%;}'
	cHtml +='td, th {'
	cHtml +='	    border: 2px solid #dddddd;'
	cHtml +='		font-size: 14px;'
	cHtml +='	    text-align: left;'
	cHtml +='	    padding: 7px;}'
	cHtml +='tr:nth-child(even) {'
	cHtml +='					  background-color: #dddddd;}'
	cHtml +='</style>'
	cHtml +='</head>'
	
	cHtml +='<h2 class="with-breadcrumbs" style="margin: 0px; padding: 0px; line-height: 1.25; color: rgb(0, 0, 0); font-family: Arial,Helvetica,sans-serif; font-size: 28px;"><strong><span style="font-size: 36px;"><span style="font-family: &quot;trebuchet ms&quot;,helvetica,sans-serif;"><span dir="rtl"><img alt="" dir="ltr" src="http://www.grupouniaosa.com.br/wp-content/themes/grupouniao/images/logo.png" style="opacity: 0.9; width: 120px; height: 43px;" /></span></span></span></strong>&nbsp;<span style="font-size: 36px; font-weight: normal;">Workflow Telecobran&ccedil;a</span><span style="font-weight: normal;">&nbsp; &nbsp;</span></h2>'
	cHtml +='<hr style="color: rgb(0, 0, 0); font-family: Arial,Helvetica,sans-serif;" />'
	cHtml +='<p  style="color: rgb(0, 0, 0); font-family: Arial,Helvetica,sans-serif;"><span style="font-size: 24px;">Cliente(s) transferido(s) para r&eacute;gua superior</span></p>'
	cHtml +='<p  style="color: rgb(0, 0, 0); font-family: Arial,Helvetica,sans-serif; font-size: 14px;">Ol&aacute; &nbsp;'+cNomOper+',</p>'
	cHtml +='<p  style="color: rgb(0, 0, 0); font-family: Arial,Helvetica,sans-serif; font-size: 14px;">Empresa: '+cEmpAnt + ' - ' + Posicione("SM0",1, cEmpAnt, "M0_NOME") + '</p>'
	cHtml +='<p  style="color: rgb(0, 0, 0); font-family: Arial,Helvetica,sans-serif; font-size: 14px;">Os clientes abaixo foram transferidos para uma r&eacute;gua superior devido existir um titulo que ultrapassa sua r&eacute;gua de cobran&ccedil;a, sendo assim, a cobran&ccedil;a deste ser&aacute; tratada com um operador da r&eacute;gua acima.</p>'
	cHtml +='<p  style="color: rgb(0, 0, 0); font-family: Arial,Helvetica,sans-serif; font-size: 14px;">Datas de vencimentos que sua r&eacute;gua de cobran&ccedil;a atende: '+ DTOC(dIni) +'&nbsp;&agrave; '+ DTOC(dLimite)+'</p>'
	
	cHtml +='<body>'
	
	cHtml +='<table>'
	cHtml +='  	<tr>'
	cHtml +='		<th>Razão Social</th>'
	cHtml +='		<th>Atrasos</th>'
	cHtml +='    	<th>Titulo responsável pela virada de régua</th>'
	cHtml +='	 </tr>'
	
    /*
	For n:= 1 to len(aCliSuper)
		cHtml +='  <tr>'
		cHtml +='    <td>' + aCliSuper[n][1] + ' - ' +  aCliSuper[n][2] + '</td>'
		cHtml +='    <td>' + cValtochar(DateDiffDay(dDatabase, aCliSuper[n][3])) + ' dias</td>'
		cHtml +='    <td>** Vencimento: ' 	+ PADR(DTOC(aCliSuper[n][3]),TamSX3("K1_VENCREA")[1]+2) + ;
			' ** (Prefixo: ' 	+ PADR(aCliSuper[n][4],TamSX3("K1_PREFIXO")[1]," ") + ;
			' 	/ Titulo: ' 	+ PADR(aCliSuper[n][5],TamSX3("K1_NUM")[1]," ") + ;
			' 	/ Parcela: ' 	+ PADR(aCliSuper[n][6],TamSX3("K1_PARCELA")[1]," ") + ;
			' 	/ Tipo: ' 		+ PADR(aCliSuper[n][7],TamSX3("K1_TIPO")[1]," ") + ')</td>'
		cHtml +='  </tr>'
	Next*/
	
	cHtml +='</table>'
	cHtml +='</body>'
	cHtml +='</html>'
	
    //EnvEmail(cDestin,cAssunto,cMensagem,cAnexos,lUsaLogado)
		U_EnvEmail(cEmailDest, " Clientes subiram de régua - Empresa: " + cEmpAnt + ' - '+ Alltrim(Posicione("SM0",1, cEmpAnt, "M0_NOME")) +  "   " + cNomOper ,cHtml)

Return
