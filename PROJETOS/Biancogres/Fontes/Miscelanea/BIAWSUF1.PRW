#Include "Protheus.CH"
#Include "TOTVS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} BIAWSUF
//TODO Descrição auto-gerada.
@author Desenvolvimento1
@since 24/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function BIAWSUF1(cCGC)

	Local aArea 	:= GetArea()
	
	Private cCod := AllTrim(cCGC)
	
	/*If FunName() != 'MATA030'
		RPCSetType(3)
		WfPrepEnv('01', '01') 
	EndIf
	*/		
	Conout("BIAWSUF1 Inicio ")
		Processa({ || ProcDados() },"Aguarde...","Verificando as informações suframa para envio do e-mail...",.F.)
	Conout("BIAWSUF1 Fim ")
	
	/*If FunName() != 'MATA030'
		RpcClearEnv()
	EndIf
	*/
	RestArea(aArea)
Return

Static Function ProcDados()
	
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= MontaQuery()
	Local cHtml			:= ""
	Local lEnvMail		:= .F.
	
	cHtml := GetHeader()
	cHtml += GetMsgBody()
	cHtml += GetOTable()
	
	TCQuery cQuery New Alias cAliasTrab
		
	If !cAliasTrab->(EoF())
		cHtml += GetRow()
		
		lEnvMail := (!Empty(cAliasTrab->CALSUF_CLI) .And. AllTrim(cAliasTrab->CALSUF_CLI) <> 'N')
	EndIf
	
	cAliasTrab->(DbCloseArea())
	
	cHtml += GetCTable()
	cHtml += GetFooter()
	
	If (lEnvMail)
		SendMail(cHtml) //enviar e-mail
	EndIf
Return


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
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (BIAWSUF1).</th>"
	cHtml += "			</tr>"
	cHtml += "		</table>"
	cHtml += "      </body>"
	cHtml += "   </html>"
	cHtml += "   </html>"

Return cHtml

Static Function GetMsgBody()
	Local cHtml := ""

	cHtml := '<p><div class = "headTexto1">Conferência de cadastros de Zona Suframada.</div></p>'
	cHtml += '<p><div class = "headTexto1">Favor confirmar situação cadastrado do cliente no site: https://servicos.suframa.gov.br/servicos</div></p>'	
	cHtml += '<br/>'	
Return cHtml

Static Function GetOTable()
	
	Local cHtml := ""
	
	
	cHtml := '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
	cHtml += '            <tr align=center>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Nome do Cliente </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> CNPJ </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> UF </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Tipo de Venda </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Representante </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Desconto SUFRAMA </th>' 
	cHtml += '            </tr>
	
Return cHtml

Static Function GetCTable()
	Local cHtml := ""
	
	cHtml += '</table>'
Return cHtml

Static Function GDescBox(aCombo, cValor)
	Local cDesc	:= ""
	Local nI	:= 0
	
	For nI:=1 To Len (aCombo)
		If (AllTrim(aCombo[nI][2]) == AllTrim(cValor))
			cDesc := AllTrim(aCombo[nI][3])
			Exit
		EndIf
	Next nI
	
Return cDesc

Static Function GetRow()
	
	Local cHtml		:= ""
	Local aTipo		:= RetSX3Box(GetSX3Cache("A1_TIPO", "X3_CBOX"),,,1)
	Local aCalcSuf	:= RetSX3Box(GetSX3Cache("A1_CALCSUF", "X3_CBOX"),,,1)
	
	cHtml := " 			<tr align=center>
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->NOME_CLI +"</td>"
		cHtml += "          	<td class='style12' width='40' scope='col'>"+ cAliasTrab->CNPJ_CLI +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->UF_CLI +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ GDescBox(aTipo, cAliasTrab->TIPO_CLI) +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->NOME_REP +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ GDescBox(aCalcSuf, cAliasTrab->CALSUF_CLI) +"</td>"
	cHtml += "          </tr>"

Return cHtml


Static Function SendMail(cHtml)
	
	Local _lRet  		:= .F.
	Local _cTo 			:= ""
	Local _cSubject		:= ""
	Local _cBody 		:= ""
	Local _cCC 			:= ""
	Local _oCC 			:= ""

	_cSubject := "Conferência de cadastros de Zona Suframada"
	
	_cTo := "karina.barbosa@biancogres.com.br;ludmilla.servino@biancogres.com.br"
	_cCC := "ranisses.corona@biancogres.com.br"
	
	_cBody := cHtml      
	
	Conout("BIAWSUF1 Enviando e-mail para: "+_cTo)
	_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)

Return(_lRet)


Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	
	cQuery += " SELECT 																						"+ Enter
	cQuery += " A1_NOME		AS NOME_CLI,																	"+ Enter
	cQuery += " A1_CGC		AS CNPJ_CLI,																	"+ Enter
	cQuery += " A1_EST		AS UF_CLI,																		"+ Enter
	cQuery += " A1_TIPO		AS TIPO_CLI,																	"+ Enter
	cQuery += " A1_CALCSUF	AS CALSUF_CLI,																	"+ Enter
	cQuery += " A3_NOME 	AS NOME_REP																		"+ Enter
	cQuery += " FROM "+RetSQLName("SA1")+" SA1 																"+ Enter 
	cQuery += " INNER JOIN  "+RetSQLName("SA3")+" SA3 ON SA1.A1_VEND = SA3.A3_COD AND SA3.D_E_L_E_T_ = ''	"+ Enter 
	cQuery += " WHERE A1_CGC 		= '"+cCod+"'															"+ Enter 	
	cQuery += " AND SA1.D_E_L_E_T_ 	= ''	 																"+ Enter 	
	
	
Return cQuery

