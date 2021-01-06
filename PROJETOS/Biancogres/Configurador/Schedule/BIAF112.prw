#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF112
@author Tiago Rossini Coradini
@since 02/07/2018
@version 1.0
@description Workflow de solicitações de compra pendentes de aprovação 
@obs Ticket: 3989
@type Function
/*/

User Function BIAF112()
Local cSQL := ""
Local cQry := GetNextAlias()
Local cMailApr := ""
Local cHtml := ""
Local cItem := ""			
Local cBizagi := ""
	
	RpcSetType(3)
	RpcSetEnv("01", "01")
	
	cBizagi := U_fGetBase("2") 	
		
	cSQL := " SELECT CASE WHEN EMP = '01' THEN 'Biancogres' ELSE 'Incesa' END AS EMP, PROCE AS SC_NUM, SC_SOLIC, SC_DT_EMIS, " 
	cSQL += " SC_ITEM, PRODUTO AS SC_PROD, SC_APROV, SC_APROV_EMAIL "
	cSQL += " FROM "+cBizagi+".dbo.VW_SC_ABERTA "
	cSQL += " WHERE SC_NM_ATIV = 'AprovarSolicitacaodeCompra' "
	cSQL += " ORDER BY SC_APROV_EMAIL, EMP, SC_DT_EMIS, PROCE, SC_ITEM "
	
	TcQuery cSQL New Alias (cQry)
	  			
	cMailApr := (cQry)->SC_APROV_EMAIL
	
	While (cQry)->(!Eof())
        	
		While cMailApr == (cQry)->SC_APROV_EMAIL
		
			cItem	+= fRetItem(@cQry)
			
			cMailApr := (cQry)->SC_APROV_EMAIL
			
			(cQry)->(DbSkip())
			
		EndDo()
					
		cHtml	:= fRetCab()
		cHtml	+= cItem
		cHtml	+= fRetRod()
		
		fSendMail(cMailApr, cHtml)
					
		cItem := ""
		
		If (cQry)->(!Eof())
			
			cMailApr := (cQry)->SC_APROV_EMAIL
			
		EndIf		
		
	EndDo()
	
	(cQry)->(dbCloseArea())
			
	RpcClearEnv()
		
Return()


Static Function fRetCab()
Local cRet := ""

	cRet := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml">
	cRet += '<head>
	cRet += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cRet += '    <title>Workflow</title>
	cRet += '    <style type="text/css">
	cRet += '        <!-- 
	cRet += '		.styleTable{
	cRet += '			border:0;
	cRet += '			cellpadding:3;
	cRet += '			cellspacing:2;
	cRet += '			width:100%;
	cRet += '		}
	cRet += '		.styleTableCabecalho{
	cRet += '            background: #fff;
	cRet += '            color: #ffffff;
	cRet += '            font: 14px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '		}
	cRet += '        .styleCabecalho{
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '		.styleLinha{
	cRet += '            background: #f6f6f6;
	cRet += '            color: #747474;
	cRet += '            font: 11px Arial, Helvetica, sans-serif;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '        .styleRodape{
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '			text-align: center;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '		.styleLabel{
	cRet += '			color:#0c2c65;
	cRet += '		}
	cRet += '		.styleValor{
	cRet += '			color:#747474;
	cRet += '		}
	cRet += '        -->
	cRet += '    </style>
	cRet += '</head>
	cRet += '<body>	

	cRet += '    <table class="styleTable" align="center">
	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Empresa </th>	
	cRet += '            <th class="styleCabecalho" width="85" scope="col"> SC Bizagi </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Solicitante </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Emissão </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Item </th>	
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Produto </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Aprovador </th>	
	
	cRet += '        </tr>
			
Return(cRet)


Static Function fRetItem(cQry)
Local cRet := ""
	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ (cQry)->EMP +' </th>
	cRet += '            <th class="styleLinha" width="85" scope="col"> '+ (cQry)->SC_NUM +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ (cQry)->SC_SOLIC +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ dToC(sToD((cQry)->SC_DT_EMIS)) +' </th>	
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ (cQry)->SC_ITEM +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> '+ (cQry)->SC_PROD +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ (cQry)->SC_APROV +' </th>
	cRet += '        </tr>
		
Return(cRet)


Static Function fRetRod()
Local cRet := ""

	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="styleRodape" width="60" scope="col" colspan="7">
	cRet += '                E-mail enviado automaticamente pelo sistema Protheus (by BIAF112).
	cRet += '            </td>
	cRet += '        </tr>
	cRet += '	</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Static Function fSendMail(cMail, cHtml)
	
	If U_BIAEnvMail(,cMail, "Solicitações de compra pendentes de aprovação", cHtml)
	
		ConOut("[" + cValToChar(dDataBase) + Space(1) + Time() + "] - BIAF112:fSendMail('"+ cMail +"')")
	
	EndIf
		
Return()