#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF124
@author Tiago RossinPos CoradinPos
@since 12/11/2018
@version 1.0
@description Workflow de variacao de pesos 
@obs Projeto PBI: Tickets: 8204
@type Function
/*/

User Function BIAF124(cTicket)
Local cSQL := ""
Local cQry := GetNextAlias()
	
	cSQL := " SELECT EMPRESA, C5_EMISSAO, ZZI_ATENDE, C5_VEND1, C5_CLIENTE, C5_LOJACLI, C6_NUM, C6_ITEM, PEDIDO_LM, C6_PRODUTO, B1_DESC, C6_QTDVEN, PZ0_OPNUM, C6_YLOTSUG, C6_YQTDSUG "
	cSQL += " FROM "
	cSQL += " ( "
	cSQL += " 	SELECT 'Biancogres' AS EMPRESA, C5_EMISSAO, "
	cSQL += " 	C5_VEND1 = CASE WHEN C5_CLIENTE <> '010064' THEN C5_VEND1 ELSE (SELECT TOP 1 LM.C5_VEND1 FROM SC5070 LM WHERE LM.C5_YPEDORI = SC5.C5_NUM AND LM.C5_YEMPPED = '01' AND LM.D_E_L_E_T_ = '') END, "
	cSQL += " 	C5_CLIENTE = CASE WHEN C5_YCLIORI <> '' THEN C5_YCLIORI ELSE C5_CLIENTE END, "
	cSQL += " 	C5_LOJACLI = CASE WHEN C5_YLOJORI <> '' THEN C5_YLOJORI ELSE C5_LOJACLI END, "
	cSQL += " 	C6_NUM, C6_ITEM, "
	cSQL += " 	"
	
	TcQuery cSQL New Alias (cQry)
	  			
	While (cQry)->(!Eof())		
		
		(cQry)->(DbSkip())
		
	EndDo()
	
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
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Emissão </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Atendente </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Representante </th>
	cRet += '            <th class="styleCabecalho" width="300" scope="col"> Cliente </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Pedido </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Item </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Pedido LM </th>
	cRet += '            <th class="styleCabecalho" width="300" scope="col"> Produto </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Quantidade </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Num. OP </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Lote Sugerido </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Qtd. Lt. Sugerido </th>
	
	cRet += '        </tr>
			
Return(cRet)


Static Function fRetItem(aPedVen)
Local cRet := ""
		
	cRet += '        <tr align=center>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_DesEmp] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_DatEmi] +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> '+ aPedVen[_NomAte] +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> '+ aPedVen[_NomVen] +' </th>	
	cRet += '            <th class="styleLinha" width="300" scope="col"> '+ aPedVen[_Cliente] + " - " + aPedVen[_Loja] + " - " + aPedVen[_NomCli] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_NumPed] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_ItePed] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_NumPedLM] +' </th>
	cRet += '            <th class="styleLinha" width="300" scope="col"> '+ aPedVen[_Produto] + " - " + aPedVen[_DesPro] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_QtdVen] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_NumOp] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_LotSug] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_QtdSug] +' </th>
	cRet += '        </tr>
		
Return(cRet)


Static Function fRetRod()
Local cRet := ""

	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="styleRodape" width="60" scope="col" colspan="13">
	cRet += '                E-mail enviado automaticamente pelo sistema Protheus (by BIAF124).
	cRet += '            </td>
	cRet += '        </tr>
	cRet += '	</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Static Function fSendMail(cMail, cHtml)
			
	cMail += ";" + U_EmailWF("BIAF124", cEmpAnt)
	
	If U_BIAEnvMail(, cMail, "Pedidos com Sugestão de Lote Recusada", cHtml)
	
		ConOut("[" + cValToChar(dDataBase) + Space(1) + Time() + "] - BIAF124:fSendMail('"+ cMail +"')")
	
	EndIf
		
Return()