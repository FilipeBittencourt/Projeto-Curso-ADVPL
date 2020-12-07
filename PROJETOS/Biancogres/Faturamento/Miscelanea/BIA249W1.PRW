#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} function_method_class_name
//TODO Descrição auto-gerada.
@author author
@since 04/12/2019
@version version
@example
(examples)
@see (links_or_references)
/*/

User Function BIA249W1()

	RPCSetType(3)
	WfPrepEnv('01', '01') 
	
		ProcDados() 

	RpcClearEnv()
	
Return                 


Static Function ProcDados()
	
	Local cAliasTrab	:= GetNextAlias()
	Local cAliasTemp	:= Nil
	Local cQuery		:= MontaQuery()
	Local cHtml			:= ""
	Local lEnviar		:= .F.
	
	cHtml := GetHeader()
	cHtml += GetMsgBody()
	cHtml += GetOTable()
	
	TCQuery cQuery New Alias cAliasTrab
		
	While !cAliasTrab->(EoF())
		
		cHtml += GetRow()
					
		U_GravaPZ2(cAliasTrab->ID, "ZZV", cAliasTrab->ZZV_CARGA, "ENV_MAIL", "S", "", "SISTEMA")
		
		lEnviar := .T.
		
		cAliasTrab->(DbSkip())
	EndDo
	
	cAliasTrab->(DbCloseArea())
	
	cHtml += GetCTable()
	cHtml += GetFooter()
	
	If (lEnviar)
		//enviar e-mail
		SendMail(cHtml)
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
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (BIA249W1).</th>"
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
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Carga </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Peso Carga </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Placa </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Motorista </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Peso Entrada </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Capacidade </th>'
	cHtml += '            </tr>
	
Return cHtml

Static Function GetCTable()
	Local cHtml := ""
	
	cHtml += '</table>'
Return cHtml

Static Function GetRow()
	
	Local cHtml 		:= ""
	
	cHtml := " 			<tr align=center>
		
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->ZZV_CARGA +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ Transform(cAliasTrab->PESO,"@E 999,999,999.99") +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->ZZV_PLACA +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->ZZV_MOTOR +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ Transform(cAliasTrab->Z11_PESOIN,"@E 999,999,999.99") +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ Transform(cAliasTrab->DA3_CAPACN,"@E 999,999,999.99") +"</td>"
		
	cHtml += "          </tr>"

Return cHtml

Static Function GetNEmp()
	Local cNome := ""
	
	If (AllTrim(cEmpAnt) == '01')
		cNome := "Biancogres"
	ElseIf (AllTrim(cEmpAnt) == '13')
		cNome := "Mundi"
	EndIf
		
Return cNome


Static Function SendMail(cHtml)
	
	Local _lRet  		:= .F.

	Local _cTo 			:= ""
	Local _cSubject		:= ""
	Local _cBody 		:= ""
	Local _cCC 			:= ""
	Local _oCC 			:= ""
	
	_cSubject := "Divergência de capacidade carga(s), Empresa: "+GetNEmp()
	
	_cTo := U_EmailWF('BIA249W1', cEmpAnt)
	_cCC := "pedro@facilesistemas.com.br"
	
	If !(Upper(AllTrim(getenvserver())) == "SCHEDULE")
		_cTo := "pedro@facilesistemas.com.br"
	EndIf
	
	_cBody := cHtml      

	Conout("BIA249W1 Enviando e-mail para: "+_cTo)
	_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", .F., _cCC)
	
	
Return(_lRet)


Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	
	cQuery += " select * from (																													"	
	cQuery += "                                                                                                                         		"	
	cQuery += " 	select  ID=ZZV_E.R_E_C_N_O_,                                                                                           		"	
	cQuery += " 	PESO=(                                                                                                              		"	
	cQuery += " 		select  SUM(PESO) FROM (                                                                                        		"	
	cQuery += " 			select                                                                                                      		"	
	cQuery += " 			ZZW_CARGA, 							                                                                          		"	
	cQuery += " 			PESO=(select [dbo].[GET_PESO_PRODUTO] (C9_PRODUTO, C9_LOTECTL, C9_QTDLIB))                                  		"	
	cQuery += " 			from  " + RETSQLNAME("SC9") + " SC9 (nolock)                                                                   		"	
	cQuery += "                                                                                                                         		"	
	cQuery += " 			join (select ZZW_CARGA, ZZW_PEDIDO, ZZW_ITEM, ZZW_SEQUEN, ZZW_STATUS from " + RETSQLNAME("ZZV") + " ZZV_I      		"	
	cQuery += " 				join " + RETSQLNAME("ZZW") + " ZZW_I ON ZZV_I.ZZV_CARGA = ZZW_I.ZZW_CARGA AND ZZW_I.D_E_L_E_T_ = ''        		"	
	cQuery += " 				where ZZV_I.ZZV_CARGA = ZZV_E.ZZV_CARGA                                                                 		"	
	cQuery += " 				AND ZZV_I.D_E_L_E_T_ = '') A ON                                                                         		"	
	cQuery += " 				ZZW_PEDIDO = C9_PEDIDO AND ZZW_ITEM = C9_ITEM AND ZZW_SEQUEN = C9_SEQUEN AND ZZW_STATUS <> 'X'          		"	
	cQuery += "                                                                                                                         		"	
	cQuery += " 			where                                                                                                       		"	
	cQuery += " 			SC9.C9_FILIAL = '"+xFilial("SC9")+"'                                                                           		"	
	cQuery += " 			AND SC9.D_E_L_E_T_ = ''                                                                                     		"	
	cQuery += " 			) B                                                                                                         		"	
	cQuery += " 		group by ZZW_CARGA                                                                                              		"	
	cQuery += " 	)                                                                                                                   		"	
	cQuery += " 	,DA3_CAPACN, Z11_PESOIN, ZZV_CARGA, ZZV_PLACA, ZZV_MOTOR                                                            		"	
	cQuery += " 	from " + RETSQLNAME("Z11") + " Z11                                                                                     		"	
	cQuery += " 	join " + RETSQLNAME("ZZV") + " ZZV_E ON Z11_PESAGE = ZZV_E.ZZV_TICKET AND ZZV_E.D_E_L_E_T_ = ''                        		"	
	cQuery += " 	join " + RETSQLNAME("DA3") + " DA3 ON DA3_PLACA = ZZV_E.ZZV_PLACA AND DA3.D_E_L_E_T_ = ''                              		"	
	cQuery += " 	where 1=1                                                                                                           		"	
	cQuery += " 	AND Convert(Date, Z11_DATAIN) = Convert(Date,GETDATE())	                                                            		"	
	cQuery += " 	AND Z11_PESOIN		> 0                                                                                             		"	
	cQuery += " 	AND Z11_PESOIN		<> 0.01 	                                                                                    		"	
	cQuery += " 	AND Z11_FILIAL		= ''					                                                                        		"	
	cQuery += " 	AND Z11_MERCAD		= '2' 																				            		"	
	cQuery += " 	AND Z11_PESOSA		= 0														                                        		"	
	cQuery += " 	AND Z11_SITUAC		<> 'C'														                                    		"	
	cQuery += " 	AND Z11_DATASA		= ''	 	                                                                                    		"	
	cQuery += " 	AND Z11.D_E_L_E_T_	= ''                                                                                            		"	
	cQuery += "                                                                                                                         		"	
	cQuery += " ) C                                                                                                                     		"	
	cQuery += " where (PESO+Z11_PESOIN) > DA3_CAPACN                                                                                    			"	                              
	cQuery += " AND ((((PESO+Z11_PESOIN)/DA3_CAPACN) - 1) * 100) >= 2                                                                      			"	                              
	cQuery += " AND (select COUNT(*) from " + RETSQLNAME("PZ2") + "  where PZ2_CODENT = 'ZZV' AND PZ2_CAMPO = 'ENV_MAIL' AND PZ2_ID = ID  AND D_E_L_E_T_ = '') = 0	"	                              
	              
	                              
Return cQuery

