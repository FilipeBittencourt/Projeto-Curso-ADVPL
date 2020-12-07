#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} FROPWF04
//TODO Descrição auto-gerada.
@author Desenvolvimento1
@since 18/02/2019
@version 1.0
@return ${return}, ${return_description}
@param _lManual, , descricao
@type function
/*/

User Function FROPWF04(_lManual)

	Local aArea  		:= GetArea()
	Private lManual 	:= _lManual
	Private cListAlmo	:= "05" //TODO passar como parametro para futuro outros almoxaridados 
	Private cDescAlmo	:= "05"
	
	If (Upper(AllTrim(getenvserver())) == "SCHEDULE")
		lManual := .F.
	Else
		lManual := .T.
	EndIf

	Conout("FROPWF04 Inicio - lManual = "+IIf(lManual,"SIM","NAO"))
	
	If (!lManual)
		RPCSetType(3)
		WfPrepEnv('01', '01') 
	EndIf
	
	Processa({ || ProcDados() },"Aguarde...","Processando as informações para envio do e-mail...",.F.)
	
	If (lManual)
		MsgInfo("Finalizado com sucesso!", "Workflow estoque dos produtos do(s) almoxarifado(s): "+cDescAlmo+"")
	EndIf

	If (!lManual)
		RpcClearEnv()
	EndIf
	
	Conout("FROPWF04 Fim - lManual = "+IIf(lManual,"SIM","NAO"))
	
	RestArea(aArea)	
Return                 


Static Function ProcDados()
	
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= MontaQuery()
	Local cHtml			:= ""
	
	cHtml := GetHeader()
	cHtml += GetMsgBody()
	cHtml += GetOTable()
	
	TCQuery cQuery New Alias cAliasTrab
		
	While !cAliasTrab->(EoF())
		
		cHtml += GetRow()
		
		cAliasTrab->(DbSkip())
	EndDo
	
	cAliasTrab->(DbCloseArea())
	
	cHtml += GetCTable()
	cHtml += GetFooter()
	
	//enviar e-mail
	SendMail(cHtml)
	
Return

Static Function GetEmailRe()
	
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= ""
	Local Enter			:= CHR(13)+CHR(10)
	Local aLista		:= {}
	Local cEmpresa		:= cEmpAnt
	
	cQuery := ""
	cQuery += "SELECT A3_COD, A3_NOME, A3_YEMP, A3_EMAIL	"  + Enter
	cQuery += "FROM " + RETSQLNAME("SA3") + " SA3 			"  + Enter
	cQuery += "WHERE A3_MSBLQL <> '1' 						"  + Enter
	DO CASE
		CASE cEmpresa == "01"
		cQuery += "AND A3_YEMP LIKE '%0101%' 				"  + Enter
		CASE cEmpresa == "05"
		cQuery += "AND (A3_YEMP LIKE '%0501%' OR  A3_YEMP LIKE '%0599%') "  + Enter
		cQuery += "AND A3_COD NOT IN ('A00013')"			+ Enter
		CASE cEmpresa == "13"
		cQuery += "AND A3_YEMP LIKE '%13__%' 				"  + Enter
		OTHERWISE
	ENDCASE
	cQuery += " AND SA3.D_E_L_E_T_ = '' 					"  + Enter
	cQuery += " ORDER BY A3_COD 	  						"  + Enter

	TCQuery cQuery New Alias cAliasTrab
	
	While !cAliasTrab->(EoF())
		If (!Empty(cAliasTrab->A3_EMAIL))
			Aadd(aLista, ALLTRIM(cAliasTrab->A3_EMAIL)) 
		EndIf
		cAliasTrab->(DbSkip())
	EndDo
	cAliasTrab->(DbCloseArea())
	
Return aLista

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
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (FROPWF04).</th>"
	cHtml += "			</tr>"
	cHtml += "		</table>"
	cHtml += "      </body>"
	cHtml += "   </html>"
	cHtml += "   </html>"

Return cHtml

Static Function GetMsgBody()
	Local cHtml := ""

	cHtml := '<p><div class = "headTexto1">Estoque dos produtos do(s) almoxarifado(s): '+cDescAlmo+'</div></p>'
	cHtml += '<br/>'	
Return cHtml

Static Function GetOTable()
	
	Local cHtml := ""
	
	cHtml := '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
	cHtml += '            <tr align=center>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Empresa </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Produto </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Saldo </th>'
	cHtml += '            </tr>
	
Return cHtml

Static Function GetCTable()
	Local cHtml := ""
	
	cHtml += '</table>'
Return cHtml

Static Function GetRow()
	
	Local cHtml 		:= ""
	
	cHtml := " 			<tr align=center>
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ GetNEmp(cAliasTrab->EMP) +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ AllTrim(cAliasTrab->COD_PROD)+" - "+AllTrim(cAliasTrab->NOME_PROD)+"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ Transform(cAliasTrab->SALDO,"@E 999,999,999.99") +"</td>"
	cHtml += "          </tr>"

Return cHtml

Static Function GetNEmp(cCod)
	Local cNome := ""
	
	If (AllTrim(cCod) == '0101')
		cNome := "Biancogres"
	ElseIf (AllTrim(cCod) == '0501')
		cNome := "Incesa"
	ElseIf (AllTrim(cCod) == '0599')
		cNome := "Bellacasa"
	ElseIf (AllTrim(cCod) == '1399')
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
	Local _aListMail	:= GetEmailRe()
	Local nI			:= 0
	
	Local cDataBase    := AllTrim(U_DBNAME())

	_cSubject := "Estoque dos produtos do(s) almoxarifado(s): "+cDescAlmo
	
	_cTo := "robson.laurett@biancogres.com.br"	
	_cCC := "pedro@facilesistemas.com.br"
	
	If !(Upper(AllTrim(getenvserver())) == "SCHEDULE" .Or. Upper(AllTrim(getenvserver())) == "PRODUCAO") .Or. ( cDataBase <> "DADOSADV" )
		_cTo := "pedro@facilesistemas.com.br"
	EndIf
	
	_cBody := cHtml      
	
	//_cTo := "pedrohenriquecruzcosta@gmail.com"
	//_cCC := ""
	
	Conout("FROPWF04 Enviando e-mail para: "+_cTo)
	_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)
	
	For nI:= 1 To Len(_aListMail)
		_cTo := _aListMail[nI]
		_cCC := ""
		Conout("FROPWF04 Enviando e-mail para: "+_cTo)
		_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)
	Next nI
	
Return(_lRet)


Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	
	cQuery += " SELECT "+ Enter 
	cQuery += " T1.*,"+ Enter 
	cQuery += " ISNULL(T1.QUANT, 0) - ( ISNULL(T1.EMPENHO, 0) ) AS SALDO"+ Enter 
	cQuery += " FROM"+ Enter 
	cQuery += " (SELECT "+ Enter 
	cQuery += " 		ZZ7.ZZ7_EMP							AS EMP,"+ Enter 
	cQuery += " 		B1_COD								AS COD_PROD,"+ Enter 
	cQuery += " 		B1_DESC								AS NOME_PROD,"+ Enter 
	cQuery += " 		("+ Enter 
	cQuery += " 			ISNULL((SELECT SUM(BF_QUANT) FROM SBF010 SBF1 WHERE SBF1.BF_PRODUTO = SB1.B1_COD AND SBF1.D_E_L_E_T_ = '' AND SBF1.BF_LOCAL IN "+ FormatIn(cListAlmo,"/") +" ), 0)"+ Enter 
	cQuery += " 			+"+ Enter 
	cQuery += " 			ISNULL((SELECT SUM(BF_QUANT) FROM SBF050 SBF5 WHERE SBF5.BF_PRODUTO = SB1.B1_COD AND SBF5.D_E_L_E_T_ = '' AND SBF5.BF_LOCAL IN "+ FormatIn(cListAlmo,"/") +" ), 0)"+ Enter 
	cQuery += " 			"+ Enter 
	cQuery += " 		) AS QUANT,"+ Enter 
	cQuery += " 		("+ Enter 
	cQuery += " 			ISNULL((SELECT SUM(BF_EMPENHO) FROM SBF010 SBF1 WHERE SBF1.BF_PRODUTO = SB1.B1_COD AND SBF1.D_E_L_E_T_ = '' AND SBF1.BF_LOCAL IN "+ FormatIn(cListAlmo,"/") +" ), 0)"+ Enter 
	cQuery += " 			+"+ Enter 
	cQuery += " 			ISNULL((SELECT SUM(BF_EMPENHO) FROM SBF050 SBF5 WHERE SBF5.BF_PRODUTO = SB1.B1_COD AND SBF5.D_E_L_E_T_ = '' AND SBF5.BF_LOCAL IN "+ FormatIn(cListAlmo,"/") +" ), 0)"+ Enter 
	cQuery += " 		) AS EMPENHO "+ Enter 
	cQuery += " 	FROM SB1010 AS SB1 "+ Enter 
	cQuery += " 	INNER JOIN ZZ6010 ZZ6 ON (SB1.B1_YFORMAT	= ZZ6.ZZ6_COD)  "+ Enter 
	cQuery += " 	INNER JOIN ZZ7010 ZZ7 ON (SB1.B1_YLINHA		= ZZ7.ZZ7_COD AND SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ) "+ Enter 
	cQuery += " 	WHERE  "+ Enter 
	cQuery += " 	SB1.B1_FILIAL	= '  '	AND															"+ Enter 
	cQuery += " 	SB1.D_E_L_E_T_	= ''	AND															"+ Enter 
	cQuery += " 	ZZ6.D_E_L_E_T_	= ''	AND"+ Enter 
	cQuery += " 	ZZ7.D_E_L_E_T_	= ''	AND"+ Enter 
	cQuery += " 	SB1.B1_COD		IN "+ Enter 
	cQuery += " 	("+ Enter 
	cQuery += " 			SELECT"+ Enter 
	cQuery += " 				DISTINCT(B1_COD) AS COD"+ Enter 
	cQuery += " 				FROM SB1010 SB1"+ Enter 
	cQuery += " 				LEFT JOIN ("+ Enter 
	cQuery += " 					SELECT BF_PRODUTO, BF_QUANT FROM SBF010 WHERE D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 					UNION ALL"+ Enter 
	cQuery += " 					SELECT BF_PRODUTO, BF_QUANT FROM SBF050 WHERE D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 					)  SBF ON SB1.B1_COD = SBF.BF_PRODUTO"+ Enter 
	cQuery += " 				WHERE "+ Enter 
	cQuery += " 				  SB1.B1_TIPO = 'PA'"+ Enter 
	cQuery += " 				  AND SB1.B1_MSBLQL <> '1'"+ Enter 
	cQuery += " 				  AND SB1.B1_YCLASSE = '1'"+ Enter 
	cQuery += " 				  AND (ISNULL(BF_QUANT, 0) > 0)  "+ Enter 
	cQuery += " 				  AND B1_YSTATUS = '1'"+ Enter 
	cQuery += " 				  AND B1_YIMPTAB IN ('S', ' ') "+ Enter 
	cQuery += " 				  AND SB1.D_E_L_E_T_ = ''"+ Enter 
	cQuery += " 	)"+ Enter 
	cQuery += " )T1"+ Enter 
	cQuery += " WHERE "+ Enter 
	cQuery += " (ISNULL(T1.QUANT, 0) -  ISNULL(T1.EMPENHO, 0)) > 0 
	cQuery += "  ORDER BY EMP, COD_PROD"+ Enter 

Return cQuery
