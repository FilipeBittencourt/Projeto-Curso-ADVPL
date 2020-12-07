#Include "Protheus.CH"
#Include "TOTVS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"

User Function BFATWF04(_lManual)
	
	Local aArea  := GetArea()

	Private lManual 	:= _lManual
	Private nTempoEsp	:= 1.5 //tempo de espera

	If (Upper(AllTrim(getenvserver())) == "SCHEDULE")
		lManual := .F.
	Else
		lManual := .T.
	EndIf
	
	//RPCSetType(3)
	//WfPrepEnv('01', '01') 
	

	Conout("BFATWF04 Inicio - lManual = "+IIf(lManual,"SIM","NAO"))
	
	If (!lManual)
		RPCSetType(3)
		WfPrepEnv('01', '01') 
	EndIf
			
	Processa({ || ProcDados() },"Aguarde...","Processando as informações para envio do e-mail...",.F.)
	
	If (lManual)
		MsgInfo("Finalizado com sucesso!","Workflow Tempo de carregamento")
	EndIf

	Conout("BFATWF04 Fim - lManual = "+IIf(lManual,"SIM","NAO"))
	
	RestArea(aArea)	
	
	If (!lManual)
		RpcClearEnv()
	EndIf
	
	
	//RpcClearEnv()	
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
	
	cQuery += " SELECT 	* FROM	(																				"+ Enter
	
	cQuery += " SELECT 																			"+ Enter					
	cQuery += "	 PESAGE		= Z11_PESAGE,														"+ Enter					
	cQuery += "	 NOME_MOT	= Z11_MOTORI, 														"+ Enter						
	cQuery += "	 PLACA		= Z11_PCAVAL,														"+ Enter
	cQuery += "	 DATA		= OPE_TICKET.DATA,													"+ Enter
	cQuery += "	 HORAIN		= Convert(Char(05),CONVERT(TIME,OPE_TICKET.DATA)),					"+ Enter		
	cQuery += "	 MINUTOS	= DATEDIFF(minute, CONVERT(TIME,OPE_TICKET.DATA), CONVERT (time, GETDATE()) ),	"+ Enter		
	cQuery += "	 TEMPO		= CONVERT(DECIMAL(16,4), DATEDIFF(minute, CONVERT(TIME,OPE_TICKET.DATA), CONVERT (time, GETDATE()) )) / 60  "+ Enter	
	cQuery += "	 FROM Z11010	Z11								 								"+ Enter
	cQuery += "	 INNER JOIN (																	"+ Enter
	cQuery += "	  SELECT PLACA=OTK_PLACA_VEICULO, DATA=CONVERT(datetime, MIN( CHQ.OTK_DATA))	"+ Enter
	cQuery += " 				FROM ZEUS.GUARDIAN.dbo.tbOperacoesTicket CHQ 					"+ Enter
	cQuery += " 				WHERE															"+ Enter
	cQuery += "				CHQ.OTK_ESTADO <> 0 												"+ Enter
	cQuery += " 			AND NOT CHQ.PRF_SEQUENCIAL IS NULL 									"+ Enter
	cQuery += "				AND CONVERT(date, CHQ.OTK_DATA) = CONVERT(date,  GETDATE())			"+ Enter
	cQuery += "				GROUP BY OTK_PLACA_VEICULO											"+ Enter
	cQuery += "																					"+ Enter
	cQuery += "	 ) OPE_TICKET ON (REPLACE( PLACA,'-','') COLLATE Latin1_General_BIN = REPLACE( Z11_PCAVAL,'-','')) "+ Enter
	cQuery += "	 WHERE																			"+ Enter
	cQuery += "	 Z11_MERCAD <> '1'											 					"+ Enter	
	cQuery += "	 AND CONVERT(date, Z11_DATAIN) >= DATEADD(DAY, -7, GETDATE())					"+ Enter
	cQuery += "	 AND Z11_HORASA = '' 										 					"+ Enter
	cQuery += "	 AND D_E_L_E_T_ = '' 															"+ Enter
	
	cQuery += " ) A 														"+ Enter 	
	cQuery += " WHERE 														"+ Enter 	
	cQuery += " TEMPO	 > "+cvaltochar(nTempoEsp)+"						"+ Enter 				
	
		
Return cQuery


Static Function SendMail(cHtml)
	
	Local _lRet  		:= .F.
	Local _cTo 			:= ""
	Local _cSubject		:= ""
	Local _cBody 		:= ""
	Local _cCC 			:= ""
	Local _oCC 			:= ""
	
	_cSubject := "Tempo de carregamento"
	
	_cTo := U_EmailWF('BFATWF04',cEmpAnt)
	_cTo += "pedro@facilesistemas.com.br"
	_cCC := ""
	
	_cBody := cHtml      
	
	Conout("BFATWF04 Enviando e-mail para: "+_cTo)
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
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (BFATWF04).</th>"
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
		cHtml += '               <th class = "cabtab" width="80" scope="col"> Sequêncial </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Motorista </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Placa </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Hora Entrada </th>'
		cHtml += '               <th class = "cabtab" width="80" scope="col"> Tempo </th>'
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
	
	cHtml := " 			<tr align=center>
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->PESAGE +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->NOME_MOT +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->PLACA +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->HORAIN +"</td>"
		cHtml += "          	<td class='style12' width='40' scope='col'>"+ MinToHo(cAliasTrab->MINUTOS) +"</td>"
	cHtml += "          </tr>"
	
Return cHtml



Static function MinToHo(nValor)
	
	Local nMinutos	:= 0
	Local nHoras	:= 0
	Local cHora		:= ""
	
	nHoras 		:= INT(nValor / 60)
	nMinutos	:= INT(nValor % 60)
	
	cHora 		:= StrZero(nHoras, 2)+":"+StrZero(nMinutos, 2)
return cHora
