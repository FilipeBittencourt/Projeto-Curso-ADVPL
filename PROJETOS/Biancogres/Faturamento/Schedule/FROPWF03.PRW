#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} FROPWF03
//TODO Descrição auto-gerada.
@author Pedro HEnrique
@since 10/01/2019
@version 1.0
@return ${return}, ${return_description}
@param _lManual,
@type function
/*/

User Function FROPWF03(_lManual)

	Local aArea  := GetArea()
	
	Private lManual := _lManual

	If (Upper(AllTrim(getenvserver())) == "SCHEDULE")
		lManual := .F.
	Else
		lManual := .T.
	EndIf

	Conout("FROPWF03 Inicio - lManual = "+IIf(lManual,"SIM","NAO"))
	
	
	If (!lManual)
		RPCSetType(3)
		WfPrepEnv('01', '01') 
	EndIf
			
	Processa({ || ProcDados() },"Aguarde...","Processando as informações para envio do e-mail...",.F.)
	
	If (lManual)
		MsgInfo("Finalizado com sucesso!","Workflow Pedidos com reserva de estoque e data de entrega vencida")
	EndIf

	If (!lManual)
		RpcClearEnv()
	EndIf
	
	Conout("FROPWF03 Fim - lManual = "+IIf(lManual,"SIM","NAO"))
	
	
	RestArea(aArea)	
Return                 


Static Function ProcDados()
	
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= MontaQuery()
	Local cHtml			:= ""
	Local aListaCod		:= {}
	Local nAchou		:= 0
	
	cHtml := GetHeader()
	cHtml += GetMsgBody()
	cHtml += GetOTable()
	
	TCQuery cQuery New Alias cAliasTrab
		
	While !cAliasTrab->(EoF())
		
		If !(Empty(cAliasTrab->COD_VEN))
			nAchou := aScan(aListaCod,{|x| Alltrim(x[1]) == Alltrim(cAliasTrab->COD_VEN)})
			If (nAchou == 0)
				Aadd(aListaCod, {cAliasTrab->COD_VEN, cAliasTrab->TPSEG})
			EndIf			
		EndIf
		
		cHtml += GetRow()
		
		cAliasTrab->(DbSkip())
	EndDo
	
	cAliasTrab->(DbCloseArea())
	
	cHtml += GetCTable()
	cHtml += GetFooter()
	
	//enviar e-mail
	SendMail(aListaCod, cHtml)
	
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
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (FROPWF03).</th>"
	cHtml += "			</tr>"
	cHtml += "		</table>"
	cHtml += "      </body>"
	cHtml += "   </html>"
	cHtml += "   </html>"

Return cHtml

Static Function GetMsgBody()
	Local cHtml := ""

	cHtml := '<p><div class = "headTexto1">Pedidos com reserva de estoque e data de entrega vencida.</div></p>'
	cHtml += '<br/>'	
Return cHtml

Static Function GetOTable()
	
	Local cHtml := ""
	
	cHtml := '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
	cHtml += '            <tr align=center>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Empresa </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Dt.Entrega </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Dt.Emis. Pedido </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Cod. Cliente </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Nome Cliente </th>' 
		cHtml += '               <th class = "cabtab" width="20" scope="col"> UF </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Cod. Vendedor </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Vendedor (Nome Reduzido) </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Pedido </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Item </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Cod.Produto </th>'
		cHtml += '               <th class = "cabtab" width="100" scope="col"> Descricao Prod. </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Lote </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Qtde </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Nº Reserva </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Marca Prod. </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Atendente </th>'
	cHtml += '            </tr>
	
Return cHtml

Static Function GetCTable()
	Local cHtml := ""
	
	cHtml += '</table>'
Return cHtml

Static Function GetRow()
	
	Local cHtml 		:= ""
	Local cDadosAten	:= ""
	Local cRetNome		:= ""
	
	oGerenteAtendente	:= TGerenteAtendente():New()
	oResult 			:= oGerenteAtendente:GetCliente(cAliasTrab->EMPRESA+'01', cAliasTrab->COD_CLI, cAliasTrab->LOJA_CLI, cAliasTrab->COD_VEN)
	
	If(!Empty(oResult:cAtendente))
		PswOrder(1)
		If (PswSeek(oResult:cAtendente, .T.))
			aUser		:= Pswret(1)  
			cRetNome	:= AllTrim(aUser[1][2])
		EndIf
	EndIf
	
	cHtml := " 			<tr align=center>
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->EMPRESA +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cvaltochar(DToC(cAliasTrab->DATA_ENT)) +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cvaltochar(DToC(cAliasTrab->DATA_EMI)) +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->COD_CLI +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->NOME_CLI +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->UF +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->COD_VEN +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->NOME_VEN +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->PEDIDO +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->ITEMP +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->COD_PROD +"</td>"
		cHtml += "          	<td class='style12' width='100' scope='col'>"+ cAliasTrab->NOME_PROD +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->LOTE +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ Transform(cAliasTrab->QUANT,"@E 999,999,999.99") +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->NUM_RES +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ cAliasTrab->MARCA +"</td>"
		cHtml += "          	<td class='style12' width='20' scope='col'>"+ oResult:cAtendente+" - "+cRetNome+"</td>"
	cHtml += "          </tr>"

Return cHtml

Static Function ListaEmail(aListaCod)
	
	Local nI	 	 	:= 0	
	Local cLToEmail	:= "" 
	Local cLCcEmail	:= "" 
	
	Local cAGMail		:= ""
	Local cAteMail		:= ""
	Local cGerMail		:= ""
	Local aList			:= {}
	Local nAchou		:= 0 
	Local aUsuarios		:= {}
	Local _cDest 		:= U_EmailWF("FROPWF03",AllTrim(cEmpAnt))

	
	cLToEmail	:= "claudeir.fadini@biancogres.com.br;lohayne.moreira@biancogres.com.br;"
	cLToEmail	+= "tatiane.perpetua@biancogres.com.br"
	
	cLCcEmail	+= "keytiane.coutinho@biancogres.com.br;barbara.madeira@biancogres.com.br;karina.barbosa@biancogres.com.br;claudeir.fadini@biancogres.com.br;"
	cLCcEmail	+= "ana.barreto@biancogres.com.br;ludmilla.servino@biancogres.com.br;camila.oliveira@biancogres.com.br;"
	cLCcEmail	+= "micheli.zanoni@biancogres.com.br;joicy.kuster@biancogres.com.br;caroline.almeida@biancogres.com.br;bruno.andrade@biancogres.com.br"
	
	
	//cadastro de não estava correto
	/*
	aList		:= {;
						'claudeir.fadini@biancogres.com.br',; 
						'lohayne.moreira@biancogres.com.br',;  
						'claudeir.fadini@biancogres.com.br',; 
						'raul.grossi@biancogres.com.br',; 
						'tatiane.perpetua@biancogres.com.br',; 
						'keytiane.coutinho@biancogres.com.br',;
						'barbara.madeira@biancogres.com.br',;
						'karina.barbosa@biancogres.com.br',;
						'ana.barreto@biancogres.com.br',;
						'ludmilla.servino@biancogres.com.br',;
						'micheli.zanoni@biancogres.com.br',;
						'joicy.kuster@biancogres.com.br',;
						'caroline.almeida@biancogres.com.br',;						
					}
	
	
	//atendentes vendedores
	For nI := 1 To Len(aListaCod)
		
		//Email dos atendentes/gerente 
		cAGMail		:= MailAteGer(aListaCod[nI]) 
		cAteMail	:= cAGMail[1] //atendente
		
		If !(Empty(cAteMail))
			
			nAchou := aScan(aList,{|x| Alltrim(x) == Alltrim(cAteMail)})
			If (nAchou == 0)
				Aadd(aList, cAteMail)
				cLCcEmail += cAteMail+";"
			EndIf	
					
		EndIf
	Next nI
	
	
	//lista de todos atendentes
	aAtend := MailTodAte()
	
	For nI := 1 To Len(aAtend)
		cAteMail	:= aAtend[nI]
		
		If ('administrator' $ cAteMail)
			Loop
		EndIf
		
		nAchou		:= aScan(aList,{|x| Alltrim(x) == cAteMail})
		
		If (nAchou == 0)
			Aadd(aList, cAteMail)
			cLCcEmail += cAteMail+";"
		EndIf	
	Next nI	
	*/
		
Return {cLToEmail,cLCcEmail}

Static Function SendMail(aListaCod, cHtml)
	
	Local _lRet  		:= .F.
	Local _cTo 			:= ""
	Local _cSubject		:= ""
	Local _cBody 		:= ""
	Local _cCC 			:= ""
	Local _oCC 			:= ""
	Local _ListMail		:= ""
	
	
	Local cDataBase    := AllTrim(U_DBNAME())

	_cSubject := "Pedidos com reserva de estoque e data de entrega vencida"
	
	//cListMail	:= ListaEmail(aListaCod)
	
	//_cTo := cListMail[1]
	_cTo := U_EmailWF("FROPWF03",AllTrim(cEmpAnt))
	//_cCC := cListMail[2]
	
	//If !(Upper(AllTrim(getenvserver())) == "SCHEDULE" .Or. Upper(AllTrim(getenvserver())) == "PRODUCAO") .Or. ( cDataBase <> "DADOSADV" )
	//	_cTo := "jussara.nobrega@biancogres.com.br"
	//EndIf
	
	_cBody := cHtml      
	
	Conout("FROPWF03 Enviando e-mail para: "+_cTo)
	_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)


Return(_lRet)


Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	Local cCodEmp	:= CEMPANT
	
	cQuery += " SELECT * FROM ( "+ Enter 
	
	cQuery += " SELECT * FROM ( "+ Enter 
	cQuery += "  	SELECT   "+ Enter 
	cQuery += "  		CONVERT(DATE, C6_YEMISSA)		AS DATA_EMI, "+ Enter 
	cQuery += "  		CONVERT(DATE, C6_ENTREG)		AS DATA_ENT, "+ Enter 
	cQuery += "  		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_COD	ELSE SA1_2.A1_COD		END AS COD_CLI,"+ Enter
	cQuery += "  		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_LOJA	ELSE SA1_2.A1_LOJA		END AS LOJA_CLI,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_NOME	ELSE SA1_2.A1_NOME		END AS NOME_CLI,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_YTPSEG	ELSE SA1_2.A1_YTPSEG	END AS TPSEG,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_EST	ELSE SA1_2.A1_EST		END AS UF,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA3_1.A3_COD	ELSE SA3_2.A3_COD		END AS COD_VEN,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA3_1.A3_NREDUZ	ELSE SA3_2.A3_NREDUZ	END AS NOME_VEN,"+ Enter 
	cQuery += " 		C0_YPEDIDO		AS PEDIDO, "+ Enter 
	cQuery += "  		C0_YITEMPV		AS ITEMP,  "+ Enter 
	cQuery += "  		C0_PRODUTO		AS COD_PROD, "+ Enter 
	cQuery += "  		B1_DESC			AS NOME_PROD, "+ Enter 
	cQuery += "  		C0_LOTECTL		AS LOTE, "+ Enter 
	cQuery += "  		C0_QUANT		AS QUANT, "+ Enter 
	cQuery += "  		C0_NUM			AS NUM_RES, "+ Enter 
	cQuery += "  		Z37_DESCR		AS MARCA, "+ Enter 
	cQuery += "  		C0_YUSER		AS USUARIO, "+ Enter 
	cQuery += "  		'01'			AS EMPRESA "+ Enter 
	cQuery += "  	FROM SC0010 SC0 "+ Enter 
	cQuery += "  	INNER JOIN SB1010 SB1 ON (SC0.C0_PRODUTO	=  SB1.B1_COD	AND SB1.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	INNER JOIN SC5010 SC5 ON (SC0.C0_YPEDIDO	=  SC5.C5_NUM	AND	SC0.C0_FILIAL = SC5.C5_FILIAL		AND	SC5.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	INNER JOIN SC6010 SC6 ON (SC0.C0_YPEDIDO	=  SC6.C6_NUM	AND	SC0.C0_PRODUTO = SC6.C6_PRODUTO		AND SC0.C0_YITEMPV = SC6.C6_ITEM AND	SC6.D_E_L_E_T_ = '') "+ Enter 
	cQuery += " "+ Enter 
	cQuery += " 	LEFT JOIN SC5070 SC5_7 ON (SC0.C0_YPEDIDO	=  SC5_7.C5_YPEDORI	AND	SC0.C0_FILIAL = SC5_7.C5_FILIAL	AND	SC5_7.D_E_L_E_T_ = '' AND SC5_7.C5_YEMPPED = '"+cCodEmp+"') "+ Enter 
	cQuery += "  	"+ Enter 
	cQuery += "  	LEFT JOIN SA1010 SA1_1 ON (SC5_7.C5_CLIENTE		=  SA1_1.A1_COD		AND SC5_7.C5_LOJACLI	= SA1_1.A1_LOJA	AND SA1_1.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	LEFT JOIN SA1010 SA1_2 ON (SC5.C5_CLIENTE		=  SA1_2.A1_COD		AND SC5.C5_LOJACLI		= SA1_2.A1_LOJA	AND SA1_2.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	"+ Enter 
	cQuery += " 	LEFT JOIN SA3010 SA3_1 ON (SC5_7.C5_VEND1		=  SA3_1.A3_COD	AND SA3_1.D_E_L_E_T_ = '')"+ Enter 
	cQuery += " 	LEFT JOIN SA3010 SA3_2 ON (SC5.C5_VEND1			=  SA3_2.A3_COD	AND SA3_2.D_E_L_E_T_ = '') "+ Enter 
	cQuery += " "+ Enter 
	cQuery += "  	LEFT JOIN ZZ7010  ZZ7 ON (SB1.B1_YLINHA		= ZZ7.ZZ7_COD	AND SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ		AND	ZZ7.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	LEFT JOIN Z37010  Z37 ON (ZZ7.ZZ7_EMP		= Z37.Z37_MARCA AND Z37.D_E_L_E_T_ = '')  "+ Enter 
	cQuery += "  	WHERE  "+ Enter 
	cQuery += "  	SC0.C0_YTEMP			= 'N'	 "+ Enter 
	cQuery += "  	AND SC0.D_E_L_E_T_		= '' "+ Enter 
	cQuery += "  	AND SC0.C0_LOCALIZ  <> 'AMT' "+ Enter 
	cQuery += "  	 "+ Enter 
	cQuery += "  ) A "+ Enter 
	cQuery += "  WHERE  "+ Enter 
	cQuery += "  DATA_ENT <= CONVERT (DATE, GETDATE())    "+ Enter 
	
	cQuery += " UNION ALL "+ Enter 

	//empresa 05
	cQuery += " SELECT * FROM ( "+ Enter 
	cQuery += "  	SELECT   "+ Enter 
	cQuery += "  		CONVERT(DATE, C6_YEMISSA)		AS DATA_EMI, "+ Enter 
	cQuery += "  		CONVERT(DATE, C6_ENTREG)		AS DATA_ENT, "+ Enter 
	cQuery += "  		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_COD	ELSE SA1_2.A1_COD		END AS COD_CLI,"+ Enter 
	cQuery += "  		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_LOJA	ELSE SA1_2.A1_LOJA		END AS LOJA_CLI,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_NOME	ELSE SA1_2.A1_NOME		END AS NOME_CLI,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_YTPSEG	ELSE SA1_2.A1_YTPSEG	END AS TPSEG,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_EST	ELSE SA1_2.A1_EST		END AS UF,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA3_1.A3_COD	ELSE SA3_2.A3_COD		END AS COD_VEN,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA3_1.A3_NREDUZ	ELSE SA3_2.A3_NREDUZ	END AS NOME_VEN,"+ Enter 
	cQuery += " 		C0_YPEDIDO		AS PEDIDO, "+ Enter 
	cQuery += "  		C0_YITEMPV		AS ITEMP,  "+ Enter 
	cQuery += "  		C0_PRODUTO		AS COD_PROD, "+ Enter 
	cQuery += "  		B1_DESC			AS NOME_PROD, "+ Enter 
	cQuery += "  		C0_LOTECTL		AS LOTE, "+ Enter 
	cQuery += "  		C0_QUANT		AS QUANT, "+ Enter 
	cQuery += "  		C0_NUM			AS NUM_RES, "+ Enter 
	cQuery += "  		Z37_DESCR		AS MARCA, "+ Enter 
	cQuery += "  		C0_YUSER		AS USUARIO, "+ Enter 
	cQuery += "  		'05'			AS EMPRESA "+ Enter 
	cQuery += "  	FROM SC0050 SC0 "+ Enter 
	cQuery += "  	INNER JOIN SB1010 SB1 ON (SC0.C0_PRODUTO	=  SB1.B1_COD	AND SB1.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	INNER JOIN SC5050 SC5 ON (SC0.C0_YPEDIDO	=  SC5.C5_NUM	AND	SC0.C0_FILIAL = SC5.C5_FILIAL		AND	SC5.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	INNER JOIN SC6050 SC6 ON (SC0.C0_YPEDIDO	=  SC6.C6_NUM	AND	SC0.C0_PRODUTO = SC6.C6_PRODUTO		AND SC0.C0_YITEMPV = SC6.C6_ITEM AND	SC6.D_E_L_E_T_ = '') "+ Enter 
	cQuery += " "+ Enter 
	cQuery += " 	LEFT JOIN SC5070 SC5_7 ON (SC0.C0_YPEDIDO	=  SC5_7.C5_YPEDORI	AND	SC0.C0_FILIAL = SC5_7.C5_FILIAL	AND	SC5_7.D_E_L_E_T_ = '' AND SC5_7.C5_YEMPPED = '05') "+ Enter 
	cQuery += "  	"+ Enter 
	cQuery += "  	LEFT JOIN SA1010 SA1_1 ON (SC5_7.C5_CLIENTE		=  SA1_1.A1_COD		AND SC5_7.C5_LOJACLI	= SA1_1.A1_LOJA	AND SA1_1.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	LEFT JOIN SA1010 SA1_2 ON (SC5.C5_CLIENTE		=  SA1_2.A1_COD		AND SC5.C5_LOJACLI		= SA1_2.A1_LOJA	AND SA1_2.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	"+ Enter 
	cQuery += " 	LEFT JOIN SA3010 SA3_1 ON (SC5_7.C5_VEND1		=  SA3_1.A3_COD	AND SA3_1.D_E_L_E_T_ = '')"+ Enter 
	cQuery += " 	LEFT JOIN SA3010 SA3_2 ON (SC5.C5_VEND1			=  SA3_2.A3_COD	AND SA3_2.D_E_L_E_T_ = '') "+ Enter 
	cQuery += " "+ Enter 
	cQuery += "  	LEFT JOIN ZZ7010  ZZ7 ON (SB1.B1_YLINHA		= ZZ7.ZZ7_COD	AND SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ		AND	ZZ7.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	LEFT JOIN Z37010  Z37 ON (ZZ7.ZZ7_EMP		= Z37.Z37_MARCA AND Z37.D_E_L_E_T_ = '')  "+ Enter 
	cQuery += "  	WHERE  "+ Enter 
	cQuery += "  	SC0.C0_YTEMP			= 'N'	 "+ Enter 
	cQuery += "  	AND SC0.D_E_L_E_T_		= '' "+ Enter 
	cQuery += "  	AND SC0.C0_LOCALIZ  <> 'AMT' "+ Enter 
	cQuery += "  	 "+ Enter 
	cQuery += "  ) A "+ Enter 
	cQuery += "  WHERE  "+ Enter 
	cQuery += "  DATA_ENT <= CONVERT (DATE, GETDATE())    "+ Enter 

	cQuery += " UNION ALL "+ Enter 

	//empresa 14
	cQuery += " SELECT * FROM ( "+ Enter 
	cQuery += "  	SELECT   "+ Enter 
	cQuery += "  		CONVERT(DATE, C6_YEMISSA)		AS DATA_EMI, "+ Enter 
	cQuery += "  		CONVERT(DATE, C6_ENTREG)		AS DATA_ENT, "+ Enter 
	cQuery += "  		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_COD	ELSE SA1_2.A1_COD		END AS COD_CLI,"+ Enter 
	cQuery += "  		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_LOJA	ELSE SA1_2.A1_LOJA		END AS LOJA_CLI,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_NOME	ELSE SA1_2.A1_NOME		END AS NOME_CLI,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_YTPSEG	ELSE SA1_2.A1_YTPSEG	END AS TPSEG,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_EST	ELSE SA1_2.A1_EST		END AS UF,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA3_1.A3_COD	ELSE SA3_2.A3_COD		END AS COD_VEN,"+ Enter 
	cQuery += " 		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA3_1.A3_NREDUZ	ELSE SA3_2.A3_NREDUZ	END AS NOME_VEN,"+ Enter 
	cQuery += " 		C0_YPEDIDO		AS PEDIDO, "+ Enter 
	cQuery += "  		C0_YITEMPV		AS ITEMP,  "+ Enter 
	cQuery += "  		C0_PRODUTO		AS COD_PROD, "+ Enter 
	cQuery += "  		B1_DESC			AS NOME_PROD, "+ Enter 
	cQuery += "  		C0_LOTECTL		AS LOTE, "+ Enter 
	cQuery += "  		C0_QUANT		AS QUANT, "+ Enter 
	cQuery += "  		C0_NUM			AS NUM_RES, "+ Enter 
	cQuery += "  		Z37_DESCR		AS MARCA, "+ Enter 
	cQuery += "  		C0_YUSER		AS USUARIO, "+ Enter 
	cQuery += "  		'14'			AS EMPRESA "+ Enter 
	cQuery += "  	FROM SC0140 SC0 "+ Enter 
	cQuery += "  	INNER JOIN SB1010 SB1 ON (SC0.C0_PRODUTO	=  SB1.B1_COD	AND SB1.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	INNER JOIN SC5140 SC5 ON (SC0.C0_YPEDIDO	=  SC5.C5_NUM	AND	SC0.C0_FILIAL = SC5.C5_FILIAL		AND	SC5.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	INNER JOIN SC6140 SC6 ON (SC0.C0_YPEDIDO	=  SC6.C6_NUM	AND	SC0.C0_PRODUTO = SC6.C6_PRODUTO		AND SC0.C0_YITEMPV = SC6.C6_ITEM AND	SC6.D_E_L_E_T_ = '') "+ Enter 
	cQuery += " "+ Enter 
	cQuery += " 	LEFT JOIN SC5070 SC5_7 ON (SC0.C0_YPEDIDO	=  SC5_7.C5_YPEDORI	AND	SC0.C0_FILIAL = SC5_7.C5_FILIAL	AND	SC5_7.D_E_L_E_T_ = '' AND SC5_7.C5_YEMPPED = '14') "+ Enter 
	cQuery += "  	"+ Enter 
	cQuery += "  	LEFT JOIN SA1010 SA1_1 ON (SC5_7.C5_CLIENTE		=  SA1_1.A1_COD		AND SC5_7.C5_LOJACLI	= SA1_1.A1_LOJA	AND SA1_1.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	LEFT JOIN SA1010 SA1_2 ON (SC5.C5_CLIENTE		=  SA1_2.A1_COD		AND SC5.C5_LOJACLI		= SA1_2.A1_LOJA	AND SA1_2.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	"+ Enter 
	cQuery += " 	LEFT JOIN SA3010 SA3_1 ON (SC5_7.C5_VEND1		=  SA3_1.A3_COD	AND SA3_1.D_E_L_E_T_ = '')"+ Enter 
	cQuery += " 	LEFT JOIN SA3010 SA3_2 ON (SC5.C5_VEND1			=  SA3_2.A3_COD	AND SA3_2.D_E_L_E_T_ = '') "+ Enter 
	cQuery += " "+ Enter 
	cQuery += "  	LEFT JOIN ZZ7010  ZZ7 ON (SB1.B1_YLINHA		= ZZ7.ZZ7_COD	AND SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ		AND	ZZ7.D_E_L_E_T_ = '') "+ Enter 
	cQuery += "  	LEFT JOIN Z37010  Z37 ON (ZZ7.ZZ7_EMP		= Z37.Z37_MARCA AND Z37.D_E_L_E_T_ = '')  "+ Enter 
	cQuery += "  	WHERE  "+ Enter 
	cQuery += "  	SC0.C0_YTEMP			= 'N'	 "+ Enter 
	cQuery += "  	AND SC0.D_E_L_E_T_		= '' "+ Enter 
	cQuery += "  	AND SC0.C0_LOCALIZ  <> 'AMT' "+ Enter 
	cQuery += "  	 "+ Enter 
	cQuery += "  ) A "+ Enter 
	cQuery += "  WHERE  "+ Enter 
	cQuery += "  DATA_ENT <= CONVERT (DATE, GETDATE())    "+ Enter 

	cQuery += "  ) B  "+ Enter 
	
	cQuery += "  ORDER BY EMPRESA, DATA_ENT, COD_CLI, LOJA_CLI, PEDIDO, ITEMP, COD_PROD"+ Enter 

Return cQuery
