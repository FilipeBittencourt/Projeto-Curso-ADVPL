#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF045
@author Tiago Rossini Coradini
@since 30/08/2016
@version 2.0
@description Workflow de reservas com prazo de solução expirado
@obs OS: 3032-16 - Raul Viana
@obs OS: 4181-16 - Claudeir Fadini - Adicionado tratamento de envio do workflow pela marca do produto
@obs OS: 0039-17 - Claudeir Fadini - Adicionado usuários no recebimento do e-mail.
@type function
/*/


User Function BIAF045()
Local cSQL := ""
Local cSC001 := RetFullName("SC0", "01")
Local cSC005 := RetFullName("SC0", "05")
Local cSC013 := RetFullName("SC0", "13")
Local cQry := GetNextAlias()
Local cHtml := ""
Local cItem := ""
Local cEmpPrd := ""
			
	RpcSetType(3)
	RpcSetEnv("01", "01")
	
	cSQL := " SELECT 'Biancogres' AS EMP, C0_NUM, C0_DOCRES, C0_SOLICIT, C0_PRODUTO, C0_QUANT, C0_EMISSAO, C0_VALIDA, C0_YPRASOL, C0_LOTECTL, C0_OBS, "
	cSQL += " ISNULL( "
	cSQL += " ( "
	cSQL += "		SELECT ZZ7_EMP "
	cSQL += "   FROM " + RetSQLName("SB1") + " SB1 "
	cSQL += " 	INNER JOIN " + RetSQLName("ZZ7") + " ZZ7 "
	cSQL += " 	ON B1_YLINHA = ZZ7_COD "
	cSQL += "		AND B1_YLINSEQ = ZZ7_LINSEQ "
	cSQL += "   WHERE B1_FILIAL = '' "
	cSQL += " 	AND B1_YPCGMR3 IN ( '1', '2', '3', '4', '8', '9' ) "
	cSQL += "   AND B1_MSBLQL <> '1' "
	cSQL += " 	AND SB1.B1_COD = C0_PRODUTO "
	cSQL += " 	AND SB1.D_E_L_E_T_ = '' "
	cSQL += "   AND ZZ7.D_E_L_E_T_ = '' "
	cSQL += "	) "
	cSQL += ", '0101') AS EMP_PRD	"	
	cSQL += " FROM " + cSC001
	cSQL += " WHERE C0_FILIAL = " + ValToSQL(xFilial("SC0"))
	cSQL += " AND C0_PRODUTO IN "
	cSQL += " ( "
	cSQL += " 	SELECT B1_COD "
	cSQL += " 	FROM " + RetSQLName("SB1")
	cSQL += " 	WHERE B1_FILIAL = '' "
	cSQL += " 	AND B1_YPCGMR3 IN ('1', '2', '3', '4', '8', '9') "
	cSQL += " 	AND B1_MSBLQL <> '1' "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND (C0_YPRASOL <> '' AND C0_YPRASOL < CONVERT(VARCHAR, GETDATE(), 112)) "	
	cSQL += " AND D_E_L_E_T_ = '' "
	
	cSQL += " UNION ALL "

	cSQL += " SELECT 'Incesa' AS EMP, C0_NUM, C0_DOCRES, C0_SOLICIT, C0_PRODUTO, C0_QUANT, C0_EMISSAO, C0_VALIDA, C0_YPRASOL, C0_LOTECTL, C0_OBS, "
	cSQL += " ISNULL( "
	cSQL += " ( "
	cSQL += "		SELECT ZZ7_EMP "
	cSQL += "   FROM " + RetSQLName("SB1") + " SB1 "
	cSQL += " 	INNER JOIN " + RetSQLName("ZZ7") + " ZZ7 "
	cSQL += " 	ON B1_YLINHA = ZZ7_COD "
	cSQL += "		AND B1_YLINSEQ = ZZ7_LINSEQ "
	cSQL += "   WHERE B1_FILIAL = '' "
	cSQL += " 	AND B1_YPCGMR3 IN ( '1', '2', '3', '4', '8', '9' ) "
	cSQL += "   AND B1_MSBLQL <> '1' "
	cSQL += " 	AND SB1.B1_COD = C0_PRODUTO "
	cSQL += " 	AND SB1.D_E_L_E_T_ = '' "
	cSQL += "   AND ZZ7.D_E_L_E_T_ = '' "
	cSQL += "	) "
	cSQL += ", '0501') AS EMP_PRD	"	
	cSQL += " FROM " + cSC005
	cSQL += " WHERE C0_FILIAL = " + ValToSQL(xFilial("SC0"))
	cSQL += " AND C0_PRODUTO IN "
	cSQL += " ( "
	cSQL += " 	SELECT B1_COD "
	cSQL += " 	FROM " + RetSQLName("SB1")
	cSQL += " 	WHERE B1_FILIAL = '' "
	cSQL += " 	AND B1_YPCGMR3 IN ('1', '2', '3', '4', '8', '9') "
	cSQL += " 	AND B1_MSBLQL <> '1' "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND (C0_YPRASOL <> '' AND C0_YPRASOL < CONVERT(VARCHAR, GETDATE(), 112)) "	
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

	cSQL += " SELECT 'Mundi' AS EMP, C0_NUM, C0_DOCRES, C0_SOLICIT, C0_PRODUTO, C0_QUANT, C0_EMISSAO, C0_VALIDA, C0_YPRASOL, C0_LOTECTL, C0_OBS, "
	cSQL += " ISNULL( "
	cSQL += " ( "
	cSQL += "		SELECT ZZ7_EMP "
	cSQL += "   FROM " + RetSQLName("SB1") + " SB1 "
	cSQL += " 	INNER JOIN " + RetSQLName("ZZ7") + " ZZ7 "
	cSQL += " 	ON B1_YLINHA = ZZ7_COD "
	cSQL += "		AND B1_YLINSEQ = ZZ7_LINSEQ "
	cSQL += "   WHERE B1_FILIAL = '' "
	cSQL += " 	AND B1_YPCGMR3 IN ( '1', '2', '3', '4', '8', '9' ) "
	cSQL += "   AND B1_MSBLQL <> '1' "
	cSQL += " 	AND SB1.B1_COD = C0_PRODUTO "
	cSQL += " 	AND SB1.D_E_L_E_T_ = '' "
	cSQL += "   AND ZZ7.D_E_L_E_T_ = '' "
	cSQL += "	) "
	cSQL += ", '1301') AS EMP_PRD	"	
	cSQL += " FROM " + cSC013
	cSQL += " WHERE C0_FILIAL = " + ValToSQL(xFilial("SC0"))
	cSQL += " AND C0_PRODUTO IN "
	cSQL += " ( "
	cSQL += " 	SELECT B1_COD "
	cSQL += " 	FROM " + RetSQLName("SB1")
	cSQL += " 	WHERE B1_FILIAL = '' "
	cSQL += " 	AND B1_YPCGMR3 IN ('1', '2', '3', '4', '8', '9') "
	cSQL += " 	AND B1_MSBLQL <> '1' "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND (C0_YPRASOL <> '' AND C0_YPRASOL < CONVERT(VARCHAR, GETDATE(), 112)) "	
	cSQL += " AND D_E_L_E_T_ = '' "
	
	cSQL += " ORDER BY EMP_PRD, EMP, C0_PRODUTO, C0_EMISSAO "	
	
	TcQuery cSQL New Alias (cQry)
	  			
	If !Empty((cQry)->C0_NUM)			
		
		cEmpPrd := (cQry)->EMP_PRD
			
		While (cQry)->(!Eof())			 			
			
			While cEmpPrd == (cQry)->EMP_PRD 
			
				cItem	+= fGetItem(cQry)								
					
				cEmpPrd := (cQry)->EMP_PRD
				
				(cQry)->(DbSkip())							
				
			EndDo()
						
			cHtml	:= fGetCab()
			cHtml	+= cItem
			cHtml	+= fGetRod()
			
			fSendMail(cEmpPrd, cHtml)
						
			cItem := ""
			
			cEmpPrd := (cQry)->EMP_PRD

		EndDo()
		
		(cQry)->(dbCloseArea())
		
	EndIf
	
	RpcClearEnv()
		
Return()


Static Function fGetCab()
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
	
	/*cRet += '        <tr>
	cRet += '			<td colspan="6">
	cRet += '				<table width="100%" cellpadding="0" cellspacing="0">
	cRet += '					<tr class="styleTableCabecalho">
	cRet += '						<td style="padding-bottom:10px;" >
	cRet += '							<span class="styleLabel">Empresa: </span>
	cRet += '							<span class="styleValor">'+ Capital(FWEmpName(cEmpAnt)) +'</span>
	cRet += '						</td>
	cRet += '					</tr>				
	cRet += '				</table>
	cRet += '			</td>
	cRet += '        </tr>*/

	cRet += '        <tr align=center>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Empresa </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Número </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Documento </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Solicitante </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Produto </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Descrição </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Quantidade </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Emissão </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Validade </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Prazo Solução </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Lote </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Observação </th>		
	cRet += '        </tr>
			
Return(cRet)


Static Function fGetItem(cQry)
Local cRet := ""
	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ (cQry)->EMP +' </th>	
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ (cQry)->C0_NUM +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ (cQry)->C0_DOCRES +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ AllTrim((cQry)->C0_SOLICIT) +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ AllTrim((cQry)->C0_PRODUTO) +' </th>
	cRet += '            <th class="styleLinha" width="100" scope="col"> '+ AllTrim(Posicione("SB1", 1, xFilial("SB1") + (cQry)->C0_PRODUTO, "B1_DESC")) +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ cValToChar((cQry)->C0_QUANT) +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ dToC(sToD((cQry)->C0_EMISSAO)) +' </th>	
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ dToC(sToD((cQry)->C0_VALIDA)) +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ dToC(sToD((cQry)->C0_YPRASOL)) +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ AllTrim((cQry)->C0_LOTECTL) +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> '+ AllTrim((cQry)->C0_OBS) +' </th>		
	cRet += '        </tr>
		
Return(cRet)


Static Function fGetRod()
Local cRet := ""

	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="styleRodape" width="60" scope="col" colspan="12">
	cRet += '                E-mail enviado automaticamente pelo sistema Protheus (by BIAF045).
	cRet += '            </td>
	cRet += '        </tr>
	cRet += '	</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)



Static Function fSendMail(cEmpPrd, cHtml)
Local cMail := ""

	
	If cEmpPrd == "0101"
		cMail:= U_EmailWF("BIAF045",SUBSTR(cEmpPrd,1,2))
	Else
		cMail:= U_EmailWF("BIAF045","")
	EndIf

U_BIAEnvMail(,cMail, "Reservas com Prazo de Solução Expirado", cHtml)
		
Return()
