#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SOL_WFDI	ºAutor  ³Fernando Rocha      º Data ³ 19/05/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Workflow diario para diretor sobre SI pendentes de aprovacaoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SOL_WFDI()
	Local nCount 	:= 0
	Local _cAux
	Local aPedAt 	:= {} 
	Local I
	Local xv_Emps    := U_BAGtEmpr("01")
	Local nI
	
	Private cSQL 		:= ""
	Private Qry 		:= ""
	Private cHtml		:= ''
	Private cTipoAprov	:= ""
	
	
	cTipoAprov := '1'
	
	For nI := 1 to Len(xv_Emps)
		
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
	
		GetData()
		
		If !(Qry)->(Eof())
		
			GetHeader()
			GetColumnHeader()
		
			While !(Qry)->(Eof())
			
				GetItems()
				                  
				(Qry)->(DbSkip())
			EndDo
			
			cHtml += ' </table>
			GetFooter()
			       
			SendMail()
			
			cHtml := ""  
			aPedAt := {}
			
		EndIf
		
		(Qry)->(dbCloseArea())
		
		RpcClearEnv()
		
	Next
	
	cHtml		:= ""		
	cTipoAprov	:= '2'
	For nI := 1 to Len(xv_Emps)
		
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
	
		GetData()
		
		If !(Qry)->(Eof())
		
			GetHeader()
			GetColumnHeader()
		
			While !(Qry)->(Eof())
			
				GetItems()
				                  
				(Qry)->(DbSkip())
			EndDo
			
			cHtml += ' </table>
			GetFooter()
			       
			SendMail()
			
			cHtml := ""  
			aPedAt := {}
			
		EndIf
		
		(Qry)->(dbCloseArea())
		
		RpcClearEnv()
		
	Next
	
	
Return()


Static Function GetData()
	Local dDiaAnt
	
	If Dow(dDataBase) == 2
		dDiaAnt := dDataBase - 3
	Else
		dDiaAnt := dDataBase - 1
	EndIf
	
	Qry := GetNextAlias()
	
	cSQL := ""
	
	cSQL += " select "+CRLF
	cSQL += " ZO_SI, "+CRLF
	cSQL += " A1_NOME, "+CRLF
	cSQL += " A3_NREDUZ, "+CRLF
	cSQL += " ZO_DATA, "+CRLF
	cSQL += " ZO_VALOR, "+CRLF
	cSQL += " ZO_YOBS = CONVERT(VARCHAR(500),CONVERT(BINARY(500),ZO_YOBS)), "+CRLF
	cSQL += " ZO_YOBSAPR = CONVERT(VARCHAR(500),CONVERT(BINARY(500),ZO_YOBSAPR)), "+CRLF
	cSQL += " ZO_USUAPRO ,"+CRLF
	cSQL += " ZO_OBSSUP = CONVERT(VARCHAR(500),CONVERT(BINARY(500),ZO_OBSSUP)), "+CRLF
	cSQL += " ZO_USUASUP "+CRLF
	cSQL += " from "+RetSQLName("SZO")+" SZO "+CRLF
	cSQL += " join "+RetSQLName("SA1")+" SA1 on A1_COD = ZO_CLIENTE and ZO_LOJA = A1_LOJA "+CRLF
	cSQL += " join "+RetSQLName("SA3")+" SA3 on A3_COD = ZO_REPRE "+CRLF
	cSQL += " where "+CRLF
	
	If (cTipoAprov == '1')
		cSQL += " 	ZO_STATUS = 'Aguard. Aprov. Dir.' "+CRLF
	Else
		cSQL += " 	ZO_STATUS = 'Aguard. Aprov. Sup.' "+CRLF
	EndIf	
	
	cSQL += " 	and SZO.D_E_L_E_T_='' "+CRLF
	cSQL += " 	and SA1.D_E_L_E_T_='' "+CRLF
	cSQL += " 	and SA3.D_E_L_E_T_='' "+CRLF
	
	TcQuery cSQL New Alias (Qry)
Return()

Static Function GetHeader()

	cHtml := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cHtml += '   <html xmlns="http://www.w3.org/1999/xhtml">
	cHtml += '      <head>
	cHtml += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cHtml += '         <title>cabtitpag</title>
	cHtml += '         <style type="text/css">
	cHtml += '			<!--
	cHtml += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.headTexto {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;}
	cHtml += '			.headTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif}
	cHtml += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
	cHtml += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
	cHtml += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
	cHtml += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif }
	cHtml += '			-->
	cHtml += '         </style>
	cHtml += '      </head>
	cHtml += '      <body>

Return()


Static Function GetColumnHeader()

	If (cTipoAprov == '1')
		cHtml += '         <p><div class = "headTexto1">AI aguardando aprovação da Direção: </div></p>
	Else
		cHtml += '         <p><div class = "headTexto1">AI aguardando aprovação da Superintendente: </div></p>
	EndIf	
	
	
	cHtml += '         <p/>
	cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">
	cHtml += '            <tr align=center>
	cHtml += '               <th class = "cabtab" width="5%" scope="col"> Número </th>
	cHtml += '               <th class = "cabtab" width="10%" scope="col"> Cliente </th>
	cHtml += '               <th class = "cabtab" width="5%" scope="col"> Representante </th>
	cHtml += '               <th class = "cabtab" width="5%" scope="col"> Emitida em: </th>
	cHtml += '               <th class = "cabtab" width="10%" scope="col"> Valor(R$) </th>
	cHtml += '               <th class = "cabtab" width="55%" scope="col"> Descrição </th>
	cHtml += '               <th class = "cabtab" width="10%" scope="col"> Aprov. Ger. </th>
	cHtml += '               <th class = "cabtab" width="10%" scope="col"> Obs. Ger. </th>
	
	If (cTipoAprov == '1')
		cHtml += '               <th class = "cabtab" width="10%" scope="col"> Aprov. Sup. </th>
		cHtml += '               <th class = "cabtab" width="10%" scope="col"> Obs. Sup. </th>
	EndIf	
	
	cHtml += '            </tr>

Return()


Static Function GetItems()

	cHtml += " 			<tr align=center>
	cHtml += "          	<td class='style12' width='5'scope='col'>"+ AllTrim((Qry)->ZO_SI) +"</td>
	cHtml += "          	<td class='style12' width='30'scope='col'>"+ AllTrim((Qry)->A1_NOME) +"</td>
	cHtml += "          	<td class='style12' width='10'scope='col'>"+ AllTrim((Qry)->A3_NREDUZ) +"</td>
	cHtml += "          	<td class='style12' width='5'scope='col'>"+ DTOC(STOD((Qry)->ZO_DATA)) +"</td>
	cHtml += "          	<td class='style12' width='5'scope='col'>"+ Transform((Qry)->ZO_VALOR,"@E 999,999.99") +"</td> 
	cHtml += "          	<td class='style12' width='60'scope='col'>"+ AllTrim((Qry)->ZO_YOBS) +"</td>
	cHtml += "              <td class='style12' width='10'scope='col'>"+ AllTrim((Qry)->ZO_USUAPRO) +"</td>
	cHtml += "              <td class='style12' width='10'scope='col'>"+ AllTrim((Qry)->ZO_YOBSAPR) +"</td>
	
	If (cTipoAprov == '1')
		cHtml += "              <td class='style12' width='10'scope='col'>"+ AllTrim((Qry)->ZO_USUASUP) +"</td>
		cHtml += "              <td class='style12' width='10'scope='col'>"+ AllTrim((Qry)->ZO_OBSSUP) +"</td>
	EndIf	
	
	cHtml += "          </tr>

Return()


Static Function GetFooter()

	cHtml += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>
	cHtml += "          <tr>
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (SOL_WFDI).</th>
	cHtml += "			</tr>
	cHtml += "		</table>
	cHtml += "      </body>
	cHtml += "   </html>
	cHtml += "   </html>

Return()


Static Function SendMail()

	Local _lRet    
	Local _cFrom := ""
	Local _cTo := ""
	Local _cSubject := ""
	Local _cBody := ""
	Local _cCC := ""
	Local cAliasTmp, _aUsers, I, _cMail
	Local _cOperDir
	Local _cCodUser	:= ""	     
	
	If (cTipoAprov == '1')
		_cSubject := "Relação de AI aguardando aprovação da Direção" 
	
		If (AllTrim(cEmpAnt) == "01")
			_cOperDir := 'SI2'
		Else
			_cOperDir := 'SI3'
		EndIf
	Else
		_cSubject := "Relação de AI aguardando aprovação da Superintendente" 
		_cOperDir := 'SI1'
	EndIf	
		
	
	//Processando lista de e-mails de usuarios configurador no acesso de diretor do CADOPER SI2/SI3
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
	%NoParser%
	select LISTA = substring(ZZ0_ACESSO,6, LEN(ZZ0_ACESSO)-8) from ZZ0010 where ZZ0_CODIGO = %Exp:_cOperDir% and D_E_L_E_T_=''
	EndSql
	
	If !(cAliasTmp)->(Eof())
	
		_aUsers := StrToKArr((cAliasTmp)->LISTA,";")
		
		_cMail := ""
		For I := 1 To Len(_aUsers)  
			
			_cCodUser := AprovTemp(_aUsers[I])
			_cCodUser := IIF(Empty(_cCodUser), _aUsers[I], _cCodUser)
			
			PswOrder(1)
			If (PswSeek(_cCodUser, .T.))
				aUser := Pswret(1)  
				_cMail += AllTrim(aUser[1][14]) +";"
			EndIf
		
		Next I
	
	EndIf
	
	If Upper(AllTrim(getenvserver())) == "SCHEDULE"
		_cTo := _cMail
		_cTo += ";"+ U_EmailWF("SOL_WFDI",CEMPANT)
		_cCC := ""
	Else          
		_cTo := U_EmailWF("SOL_WFDI",CEMPANT)
		_cTo += ";fernando@facilesistemas.com.br"
		//_cTo += ";"+_cMail
		_cCC := ""
	EndIf
	
	_cBody := cHtml
	_cCCO := ""
	
	_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC, _cCCO)

Return(_lRet)


Static Function AprovTemp(_cCodUser)
	
	Local cQuery	:= ""
	Local cAliasTmp	:= GetNextAlias()
	Local cUserTmp	:= ""	
	
	cQuery += "SELECT TOP 1 ZKQ_APROVT  FROM "+ RetSqlName("ZKQ")+"															"
	cQuery += "			WHERE                                                                                           	"
	cQuery += "			ZKQ_STATUS		= 1		AND                                                                     	"
	cQuery += "			D_E_L_E_T_		= ''	AND                                                                     	"
	cQuery += "			CONVERT(date, GETDATE()) BETWEEN CONVERT(date, ZKQ_DTINI) AND CONVERT(date, ZKQ_DTFIM)          	"
	cQuery += "			AND ZKQ_APROV = '"+_cCodUser+"'	                                                           			"
	
	TcQuery cQuery New Alias (cAliasTmp)
	
	If !(cAliasTmp)->(Eof()) 
		cUserTmp := (cAliasTmp)->ZKQ_APROVT
	EndIf
	
	(cAliasTmp)->(DbCloseArea())
				
Return cUserTmp