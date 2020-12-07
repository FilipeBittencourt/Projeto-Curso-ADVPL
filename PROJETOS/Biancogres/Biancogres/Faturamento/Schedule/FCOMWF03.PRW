#include "PROTHEUS.CH"
#include "TOPCONN.CH"

User Function FCOMWF03()
	
	Local aArea  	:= GetArea()

	Private lManual := (Select('SX2') > 0)

	Conout("FCOMWF03 Inicio - lManual = "+IIf(lManual,"SIM","NAO"))
	
	If (!lManual)
		RPCSetType(3)
		WfPrepEnv('01', '01') 
	EndIf
			
	Processa({ || ProcDados() },"Aguarde...","Processando as informações para envio do e-mail...",.F.)
	
	If (lManual)
		MsgInfo("Finalizado com sucesso!","Workflow de OP's não explodidas")
	EndIf

	Conout("FCOMWF03 Fim - lManual = "+IIf(lManual,"SIM","NAO"))
	
	RestArea(aArea)	
	
	If (!lManual)
		RpcClearEnv()
	EndIf
	
Return

Static Function ProcDados()
	
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= MontaQuery()
	Local cHtml			:= ""
	Local lRetVal		:= .F.
	
	cHtml := GetHeader()
	cHtml += GetMsgBody()
	cHtml += GetOTable()
	
	TCQuery cQuery New Alias cAliasTrab
		
	While !cAliasTrab->(EoF())
		
		cHtml += GetRow()
		
		lRetVal := .T.
		
		cAliasTrab->(DbSkip())
	EndDo
	
	cAliasTrab->(DbCloseArea())
	
	cHtml += GetCTable()
	cHtml += GetFooter()
	
	If (lRetVal)
		SendMail(cHtml)
	EndIf
	
Return

Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	
	cQuery += "select C2_NUM, C2_PRODUTO, C2_EMISSAO 															"+Enter								
	cQuery += "from  " + RETSQLNAME("SC2") + " SC2                                                              "+Enter
	cQuery += "join  " + RETSQLNAME("SB1") + " SB1 on  B1_COD = C2_PRODUTO                                      "+Enter
	cQuery += "where                                                                                            "+Enter
	cQuery += "SB1.B1_TIPO					= 'PA'                                                              "+Enter
	cQuery += "and SC2.D_E_L_E_T_			= ''                                                                "+Enter
	cQuery += "and SB1.D_E_L_E_T_			= ''                                                                "+Enter
	cQuery += "and convert (date, SC2.C2_EMISSAO) = dateadd(day , -1 , convert (date, getdate()))               "+Enter
	cQuery += "and SC2.C2_BATCH <> 'S'                                                                          "+Enter
		
Return cQuery


Static Function SendMail(cHtml)
	
	Local _lRet  		:= .F.
	Local _cTo 			:= ""
	Local _cSubject		:= ""
	Local _cBody 		:= ""
	Local _cCC 			:= ""
	Local _oCC 			:= ""

	_cSubject := "Workflow de OP's não explodidas"
	
	_cTo := U_EmailWF('FCOMWF03',cEmpAnt)
	_cCC := ""
	
	_cBody := cHtml      
	
	Conout("FCOMWF03 Enviando e-mail para: "+_cTo)
	_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)

Return(_lRet)

Static Function GetHeader()
	
	Local cHtml := ""
	
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

Return cHtml

Static Function GetFooter()
	
	Local cHtml := ""
	
	cHtml := "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>"
	cHtml += "          <tr>"
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (FCOMWF03).</th>"
	cHtml += "			</tr>"
	cHtml += "		</table>"
	cHtml += "      </body>"
	cHtml += "   </html>"

Return cHtml

Static Function GetMsgBody()
	Local cHtml := ""

Return cHtml

Static Function GetOTable()
	
	Local cHtml := ""
		
	cHtml := '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
	cHtml += '            <tr align=center>'
		cHtml += '               <th class = "cabtab" width="80" scope="col"> OP </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Emissão </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Produto </th>'
	cHtml += '            </tr>
	
Return cHtml

Static Function GetCTable()
	Local cHtml := ""
	
	cHtml += '</table>'
Return cHtml



Static Function GetRow()
	
	Local cHtml		:= ""
	
	cHtml := " 			<tr align=center>
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->C2_NUM +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->C2_EMISSAO +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->C2_PRODUTO +"</td>"
	cHtml += "          </tr>"
	
Return cHtml
