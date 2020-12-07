#Include "Protheus.CH"
#Include "TOTVS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"


User Function BIAVTMDF(cNInicio, cNFim, cSerie)
	
	Private cNI 	:= cNInicio //'000081328'//
	Private cNF 	:= cNFim //'000081331'//
	Private cNS 	:= cSerie //'1'//
	Private lRetMDF	:= .F.
	
	//RPCSetType(3)
	//WfPrepEnv('07', '01') 
	
	Conout("BIAVTMFD Inicio ")
		Processa({ || ProcDados() },"Aguarde...","Verificando informações sobre MDFe...",.F.)
	Conout("BIAVTMFD Fim ")
	
	//RpcClearEnv()
		
Return lRetMDF


Static Function ProcDados()
	
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= MontaQuery()
	Local cHtml			:= ""
	Local cMsg			:= ""
	
	cHtml := GetHeader()
	cHtml += GetMsgBody()
	cHtml += GetOTable()
	
	TCQuery cQuery New Alias cAliasTrab
		
	While !cAliasTrab->(EoF())
		lRetMDF := .T.
		cMsg += ""+AllTrim(cAliasTrab->DOC)+"/"+AllTrim(cAliasTrab->SERIE)+", "
	
		cHtml += GetRow()
		
		cAliasTrab->(DbSkip())
	EndDo
	
	cAliasTrab->(DbCloseArea())
	
	cHtml += GetCTable()
	cHtml += GetFooter()
	
	
	If (lRetMDF)
		SendMail(cHtml)
		cMsg := SUBSTR(cMsg, 1, RAT(",", cMsg) - 1)
		Aviso("SPED", "A(s) NF/Série com transportadora autônoma listadas abaixo não tem MDFe:"+CRLF+CRLF+AllTrim(cMsg)+CRLF+CRLF+"para mais informações, favor conferir sua caixa de e-mail.", {"Ok"}, 3)
	EndIf
	
Return

Static Function SendMail(cHtml)
	
	Local _lRet  		:= .F.
	Local _cTo 			:= ""
	Local _cSubject		:= ""
	Local _cBody 		:= ""
	Local _cCC 			:= ""
	Local _oCC 			:= ""
	
	_cSubject := "NF com transportadora autônoma sem MDFe"
	
	_cTo := U_EmailWF('BIAVTMDF',cEmpAnt)
	_cTo += "pedrohenriquecruzcosta@gmail.com"
	_cCC := ""
	
	_cBody := cHtml      
	
	Conout("BIAVTMFD Enviando e-mail para: "+_cTo)
	_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)

Return(_lRet)



Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	
	cQuery += " SELECT 																			"+ Enter
	
	
	cQuery += " CASE  WHEN CC0_STATUS IS NOT NULL  THEN '1' ELSE '0' END AS EXISTE_MFD,						"+ Enter
	
	cQuery += " A1_MUN 							AS MUN_CLI,													"+ Enter
	cQuery += " A1_EST 							AS EST_CLI,													"+ Enter
	
	cQuery += " F2_DOC 							AS DOC,														"+ Enter
	cQuery += " F3_SERIE						AS SERIE,													"+ Enter
	cQuery += " A4_COD							AS COD_TRANS,							 					"+ Enter
	cQuery += " A4_NOME							AS NOME_TRANS,							 					"+ Enter
	cQuery += "	ISNULL(DA3_COD, '')				AS COD_VEI,													"+ Enter	
	cQuery += "	ISNULL(DA3_DESC, '')			AS DESC_VEI, 												"+ Enter
	cQuery += "	ISNULL(DA3_PLACA, '')			AS PLACA, 													"+ Enter
	cQuery += "	ISNULL(DA3_ESTPLA, '')			AS ESTPLA, 													"+ Enter																
	cQuery += "	ISNULL(DA3_MUNPLA, '')			AS MUNPLA,													"+ Enter
	cQuery += "	ISNULL(DA4_COD, '')				AS COD_MO,													"+ Enter
	cQuery += "	ISNULL(DA4_NOME, '')			AS NOME_MO,													"+ Enter
	cQuery += "	ISNULL(CC0_STATUS, '')			AS MFD_STATUS												"+ Enter
	
	cQuery += "	FROM "+RetSQLName("SF3")+" SF3 													"+ Enter
	cQuery += " INNER JOIN "+RetSQLName("SF2")+" SF2 ON (										"+ Enter
	cQuery += "			F3_FILIAL = F2_FILIAL	AND 											"+ Enter
	cQuery += "			F3_NFISCAL = F2_DOC		AND 											"+ Enter
	cQuery += "			F3_SERIE = F2_SERIE		AND 											"+ Enter
	cQuery += "			F3_CLIEFOR = F2_CLIENTE AND 											"+ Enter
	cQuery += "			F3_LOJA = F2_LOJA		AND 											"+ Enter
	cQuery += "			SF2.D_E_L_E_T_ = '')													"+ Enter
	
	cQuery += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON (										"+ Enter
	cQuery += "			A1_COD = F2_CLIENTE 	AND												"+ Enter
	cQuery += "			A1_LOJA = F2_LOJA		AND 											"+ Enter
	cQuery += "			SA1.D_E_L_E_T_ = '')													"+ Enter
	
	
	cQuery += " INNER JOIN "+RetSQLName("SA4")+" SA4 ON (										"+ Enter
	cQuery += " 		A4_COD = F2_TRANSP AND SA4.D_E_L_E_T_ = '' )							"+ Enter
	cQuery += " LEFT JOIN "+RetSQLName("CC0")+" CC0 ON (										"+ Enter
	cQuery += "			F2_NUMMDF = CC0_NUMMDF	AND 											"+ Enter
	cQuery += "			F2_SERMDF = CC0_SERMDF	AND  											"+ Enter
	cQuery += "			CC0.D_E_L_E_T_ = '' )													"+ Enter
	
	cQuery += " LEFT JOIN "+RetSQLName("DA3")+" DA3 ON (										"+ Enter
	cQuery += "			F2_VEICUL1 = DA3_COD AND DA3.D_E_L_E_T_ = '')							"+ Enter
	cQuery += " LEFT JOIN "+RetSQLName("DA4")+" DA4 ON ( 										"+ Enter
	cQuery += "			DA3_MOTORI = DA4_COD AND DA4.D_E_L_E_T_ = '')							"+ Enter
	
	cQuery += "				WHERE													"+ Enter
	cQuery += "				SF3.F3_FILIAL = '"+xFilial('SF3')+"'		AND			"+ Enter
	cQuery += "				SF3.F3_SERIE = '"+cNS+"'		 			AND			"+ Enter
	cQuery += "				SF3.F3_NFISCAL >= '"+cNI+"'			 		AND			"+ Enter
	cQuery += "				SF3.F3_NFISCAL <= '"+cNF+"'					AND			"+ Enter
	cQuery += "				SubString(SF3.F3_CFO,1,1) >= '6'		 	AND			"+ Enter
	cQuery += "				F3_ESTADO <> 'ES'						 	AND			"+ Enter
	cQuery += "				F3_EMISSAO >= '20190101'				 	AND			"+ Enter
	//notas antigas campo F2_NUMMDF F2_SERMDF não estão preenchidos
	
	cQuery += "				SF3.F3_DTCANC = '"+Space(8)+"' 				AND			"+ Enter
	cQuery += "				SF3.D_E_L_E_T_ 	= '' 						AND			"+ Enter
	cQuery += "				SA4.A4_YTIPO = '1'			 				AND			"+ Enter
	cQuery += "				ISNULL (CC0.CC0_STATUS, '') NOT IN ('3', '6') 						"+ Enter
	
Return cQuery


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
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (BIAVTMDF).</th>"
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
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Nota Fiscal </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Série </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> UF - Município </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Transportadora </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Veiculo </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Placa </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> UF Placa </th>' 
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Motorista </th>'  
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Situação </th>'  
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
	Local cSituacao	:= ""
	Local aEvento   := RetSX3Box(GetSX3Cache("CC0_STATUS", "X3_CBOX"),,,1)
		

	If (AllTrim(cAliasTrab->EXISTE_MFD) == "0")
		cSituacao := 'Não existe MDFe vinculado'
	Else
		cSituacao := 'MDFe com status: '+GDescBox(aEvento, cAliasTrab->MFD_STATUS)	
	EndIf
	
	cHtml := " 			<tr align=center>
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->DOC +"</td>"
		cHtml += "          	<td class='style12' width='40' scope='col'>"+ cAliasTrab->SERIE +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->EST_CLI+" - "+cAliasTrab->MUN_CLI +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->COD_TRANS+" - "+cAliasTrab->NOME_TRANS +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->COD_VEI+" - "+cAliasTrab->DESC_VEI  +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->PLACA +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->ESTPLA +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->COD_MO+" - "+cAliasTrab->NOME_MO   +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cSituacao +"</td>"
	cHtml += "          </tr>"
	
Return cHtml
