#Include "Protheus.CH"
#Include "TOTVS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"

User Function BIA249VE(_cTicket, _lEnvMail, _lExibeMsg)
	
	
	Private cTicket		:= _cTicket//'533569'
	Private lRetVal		:= .T.
	Private lEnvMail	:= _lEnvMail
	
	Default _lExibeMsg	:= .T.
	
	Private lExibeMsg := _lExibeMsg
	
	
	//RPCSetType(3)
	//WfPrepEnv('01', '01') 
	
	Conout("BIA249VE Inicio ")
		Processa({ || ProcDados() },"Aguarde...","Verificando informações sobre carregamento...",.F.)
	Conout("BIA249VE Fim ")
	
	//RpcClearEnv()
	
		
Return lRetVal

Static Function ValTicket()
	
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= ""
	Local Enter			:= CHR(13)+CHR(10)
	Local aRetTicket	:= .T.
	
	cQuery += " SELECT 													"+ Enter									
	cQuery += " 	Z11_PESAGE											"+ Enter					
	cQuery += " 	FROM Z11010 Z11 (NOLOCK)							"+ Enter									
	cQuery += " 	WHERE												"+ Enter									
	cQuery += " 		Z11.D_E_L_E_T_ 				= ''				"+ Enter
	cQuery += " 		AND Z11.Z11_PESOIN 			> 0.01				"+ Enter
	cQuery += " 		AND Z11.Z11_MERCAD 			<> 1				"+ Enter
	cQuery += " 		AND Z11.Z11_PESOSA 			= 0					"+ Enter									
	cQuery += " 		AND Z11.Z11_PESAGE			= '"+cTicket+"'		"+ Enter								
	
	
	TCQuery cQuery New Alias cAliasTrab
		
	If cAliasTrab->(EoF())
		
		aRetTicket	:= .F.
				
	EndIf
	
	cAliasTrab->(DbCloseArea())
	
Return aRetTicket


Static Function ProcDados()
	
	Local cAliasTrab	:= Nil 
	Local cQuery		:= "" 
	Local cHtml			:= ""
	Local cMsg			:= ""
	Local aRetTicket	:= .T.
	Local aListNum		:= {}
	Local nPos			:= 0
	//If (ValTicket())
	
	cAliasTrab	:= GetNextAlias()
	cQuery		:= MontaQuery()

	cHtml := GetHeader()
	cHtml += GetMsgBody()
	cHtml += GetOTable()
	
	TCQuery cQuery New Alias cAliasTrab
		
	While !cAliasTrab->(EoF())
		
		
		nPos :=  AScan(aListNum, {|x| AllTrim(x) == AllTrim(cAliasTrab->NUMOCE)})
		
		If (nPos == 0)
			cMsg += ""+AllTrim(cAliasTrab->CARGA)+"/"+AllTrim(cAliasTrab->NUMOCE)+", "
		EndIf
		
		
		cHtml += GetRow()
		
		lRetVal := .F.
		
		Aadd(aListNum, cAliasTrab->NUMOCE)
		cAliasTrab->(DbSkip())
	EndDo
	
	cAliasTrab->(DbCloseArea())
	
	cHtml += GetCTable()
	cHtml += GetFooter()
	
	If (!lRetVal .And. lExibeMsg)
		
		cMsg := SUBSTR(cMsg, 1, RAT(",", cMsg) - 1)
		Aviso("Aviso", "A(s) Carga(s)/Número(s) OC Ecosis listadas abaixo estão sem carregamento finalizado :"+CRLF+CRLF+AllTrim(cMsg)+CRLF+CRLF+"para mais informações, favor conferir sua caixa de e-mail.", {"Ok"}, 3)
	
		If (lEnvMail)
			SendMail(cHtml)
		EndIf
		
	EndIf
	
	//EndIf
	
Return

Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	
	cQuery += "	SELECT 	* FROM (																			"+ Enter
	
	
	cQuery += "	SELECT 																						"+ Enter
	cQuery += "		ISNULL((SELECT COUNT(*) FROM DADOSEOS.dbo.fat_ordem_amostras (NOLOCK) FAT_AMT		 	"+ Enter
	cQuery += "		WHERE FAT_AMT.ford_numero = FAT.ford_numero), 0) AS ITEM_AM, 							"+ Enter
	
	cQuery += "		FINALIZADO 	= CASE  WHEN ISNULL(FORD_DATA_FINALIZADO, '') = ''  THEN '0' ELSE '1' END, 	"+ Enter
	cQuery += "		DATA_FI		= FORD_DATA_FINALIZADO, 													"+ Enter	
	cQuery += "		DOC			= SF2.F2_DOC, 																"+ Enter									
	cQuery += "		SERIE		= SF2.F2_SERIE, 															"+ Enter								
	cQuery += "		NUMOCE		= FAT.ford_numero, 															"+ Enter								
	cQuery += "		TICKET		= ZZV.ZZV_TICKET, 															"+ Enter	
	cQuery += "		HORASA		= Z11.Z11_HORASA, 															"+ Enter	
	cQuery += "		CARGA		= ZZV.ZZV_CARGA 															"+ Enter	
	cQuery += "		FROM ZZV010 ZZV (NOLOCK)																"+ Enter	
	
	cQuery += "		INNER JOIN Z11010 Z11 (NOLOCK) ON														"+ Enter				
	cQuery += "			Z11.Z11_PESAGE 		= ZZV.ZZV_TICKET 												"+ Enter
	cQuery += "			AND Z11.D_E_L_E_T_	= '' 															"+ Enter
	
	cQuery += "		INNER JOIN "+RetSQLName("SF2")+" SF2 (NOLOCK) ON										"+ Enter				
	cQuery += "			ZZV.ZZV_CARGA  	= SUBSTRING(SF2.F2_YAGREG, 5, 4)									"+ Enter
	cQuery += "			AND SF2.D_E_L_E_T_			= '' 													"+ Enter
	cQuery += "		INNER JOIN DADOSEOS.dbo.fat_ordem_faturamento FAT (NOLOCK) ON							"+ Enter
	cQuery += "			ZZV.ZZV_CARGA COLLATE Latin1_General_BIN = FAT.ford_num_carga 						"+ Enter
	cQuery += "			AND FAT.ford_cancelada = 0															"+ Enter
	cQuery += "		WHERE																					"+ Enter
	cQuery += "			ZZV.D_E_L_E_T_ 				= ''													"+ Enter
	cQuery += "			AND ZZV.ZZV_TICKET			= '"+cTicket+"'											"+ Enter
			
	cQuery += " ) A 																						"+ Enter 	
	cQuery += " WHERE 																						"+ Enter 	
	cQuery += " FINALIZADO 		= '0'																		"+ Enter 	
	cQuery += " AND ITEM_AM 	= 0																			"+ Enter 			
		
Return cQuery


Static Function SendMail(cHtml)
	
	Local _lRet  		:= .F.
	Local _cTo 			:= ""
	Local _cSubject		:= ""
	Local _cBody 		:= ""
	Local _cCC 			:= ""
	Local _oCC 			:= ""

	_cSubject := "NF sem carregamento finalizado Ecois"
	
	_cTo := U_EmailWF('BIA249VE',cEmpAnt)
	_cTo += "pedro@facilesistemas.com.br"
	_cCC := ""
	
	_cBody := cHtml      
	
	Conout("BIA249VE Enviando e-mail para: "+_cTo)
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
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (BIA249VE).</th>"
	cHtml += "			</tr>"
	cHtml += "		</table>"
	cHtml += "      </body>"
	cHtml += "   </html>"
	cHtml += "   </html>"

Return cHtml

Static Function GetMsgBody()
	Local cHtml := ""

Return cHtml

Static Function GetOTable()
	
	Local cHtml := ""
		
	cHtml := '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
	cHtml += '            <tr align=center>'
		cHtml += '               <th class = "cabtab" width="80" scope="col"> Ticket </th>'
		cHtml += '               <th class = "cabtab" width="80" scope="col"> Hora Saida </th>'
		cHtml += '               <th class = "cabtab" width="80" scope="col"> Carga </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Número OC Ecosis </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Nota Fiscal </th>'
		cHtml += '               <th class = "cabtab" width="80" scope="col"> Série </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Situação </th>'
	cHtml += '            </tr>
	
Return cHtml

Static Function GetCTable()
	Local cHtml := ""
	
	cHtml += '</table>'
Return cHtml



Static Function GetRow()
	
	Local cHtml		:= ""
	Local aRetItem	:= {}
	Local cSituacao	:= ""
	
	If (cAliasTrab->FINALIZADO == '1')
		cSituacao	:= "Carregamento finalizado."
	Else
		cSituacao	:= "Carregamento não finalizado."
	EndIf

	cHtml := " 			<tr align=center>
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->TICKET +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->HORASA +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->CARGA +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->NUMOCE +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->DOC +"</td>"
		cHtml += "          	<td class='style12' width='40' scope='col'>"+ cAliasTrab->SERIE +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cSituacao +"</td>"
	cHtml += "          </tr>"
		
Return cHtml
