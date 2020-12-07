#Include "Protheus.CH"
#Include "TOTVS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"

User Function BIAFPH08()
	
	RpcSetEnv('01','01')
	Conout("BIAFPH08 Inicio ")
		ProcDados() 
	Conout("BIAFPH08 Fim ")
	
	RpcClearEnv()
		
Return

Static Function ProcDados()
	
	Local cAliasTrab	:=  GetNextAlias() 
	Local cQuery		:= "" 
	Local cHtml			:= ""
	Local lEnvMail		:= .F.
	
	cQuery		:= MontaQuery()

	cHtml := GetHeader()
	cHtml += GetMsgBody()
	cHtml += GetOTable()
	
	TCQuery cQuery New Alias cAliasTrab
		
	While !cAliasTrab->(EoF())
		
		cHtml += GetRow()
		
		lEnvMail := .T.
		
		cAliasTrab->(DbSkip())
	EndDo
	
	cAliasTrab->(DbCloseArea())
	
	cHtml += GetCTable()
	cHtml += GetFooter()
	
	If (lEnvMail)
		SendMail(cHtml)
	EndIf
	
Return

Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	
	cQuery	:=	"SELECT 	*																		"
	cQuery	+=	" FROM "+RetSQLName("ZLJ")+" ZLJ													"
	cQuery	+=	" WHERE D_E_L_E_T_	= ''					AND										"	
	cQuery	+=	" ZLJ_STATUS		= '3'															"	
	cQuery	+=	" ORDER BY	R_E_C_N_O_																"
		
Return cQuery


Static Function SendMail(cHtml)
	
	Local _lRet  		:= .F.
	Local _cFrom	 	:= ""
	Local _cTo 			:= ""
	Local _cSubject		:= ""
	Local _cBody 		:= ""
	Local _cCC 			:= ""
	Local _oCC 			:= ""

	_cSubject := "Integração dados do coletor web para polimento"
	
	_cTo := U_EmailWF('BIAFPH08',cEmpAnt)
	//_cTo += "pedro@facilesistemas.com.br"
	_cCC := ""
	
	_cBody := cHtml      
	
	Conout("BIAFPH08 Enviando e-mail para: "+_cTo)
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
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (BIAFPH08).</th>"
	cHtml += "			</tr>"
	cHtml += "		</table>"
	cHtml += "      </body>"
	cHtml += "   </html>"
	cHtml += "   </html>"

Return cHtml

Static Function GetMsgBody()
	Local cHtml := "<p>Erro integração dos itens abaixo: </p>"

Return cHtml

Static Function GetOTable()
	
	Local cHtml := ""
		
	cHtml := '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
	cHtml += '            <tr align=center>'
		cHtml += '               <th class = "cabtab" width="80" scope="col"> Tipo </th>'
		cHtml += '               <th class = "cabtab" width="80" scope="col"> Produto </th>'
		cHtml += '               <th class = "cabtab" width="80" scope="col"> Quantidade </th>'
	cHtml += '            </tr>
	
Return cHtml

Static Function GetCTable()
	Local cHtml := ""
	
	cHtml += '</table>'
Return cHtml

Static Function GetRow()
	
	Local cHtml		:= ""
	Local cDescricao:= ""
	
	If (AllTrim(cAliasTrab->ZLJ_TIPO) == 'T')
		cDescricao := 'Transferência'
	ElseIf (AllTrim(cAliasTrab->ZLJ_TIPO) == 'D')
		cDescricao := 'Devolução'
	Else
		cDescricao := 'Requisição'
	EndIf

	cHtml := " 			<tr align=center>
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cDescricao +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->ZLJ_PROD +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ Transform(cAliasTrab->ZLJ_QUANT,"@E 999,999,999.99") +"</td>"
	cHtml += "          </tr>"
		
Return cHtml
