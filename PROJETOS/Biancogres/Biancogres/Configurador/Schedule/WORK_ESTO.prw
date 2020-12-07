#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} Work_Esto
@author Tiago Rossini Coradini
@since 18/10/2016
@version 2.0
@description Workflow - Quebra de estoque menor que 30 M2
@obs OS: 3886-16 - Tatiane Karina
@type function
/*/

User Function Work_Esto(cEmp)

	Prepare Environment Empresa cEmp Filial "01"
	
	fSendWF()

Return()


Static Function fSendWF()
Local cSQL := ""
Local cQry := GetNextAlias()
Local cHtml := ""

	cSQL := " SELECT B1_COD, B1_DESC, BF_LOCALIZ, BF_LOTECTL, SUM(BF_QUANT - BF_EMPENHO) AS DISPONIVEL "  
	cSQL += " FROM " + RetSQLName("SB1") + " SB1, " + RetSQLName("SBF") +" SBF "
	cSQL += " WHERE	B1_COD = BF_PRODUTO " 
	cSQL += " AND BF_QUANT - BF_EMPENHO > 0 "
	cSQL += " AND LEN(B1_COD) = 8 "
	cSQL += " AND B1_COD >= 'A' "
	
	If cEmpAnt == "05" 
		
		cSQL += " AND SB1.B1_YPCGMR3 <> '8' "		
		cSQL += " AND SBF.BF_LOTECTL <> 'AMT' "
		
	EndIf
	
	cSQL += " AND SB1.D_E_L_E_T_ = '' " 
	cSQL += " AND SBF.D_E_L_E_T_ = '' "
	cSQL += " GROUP BY B1_COD, B1_DESC, BF_LOCALIZ, BF_LOTECTL "
	cSQL += " HAVING SUM(BF_QUANT - BF_EMPENHO) <= 30 "
	cSQL += " ORDER BY B1_COD, BF_LOCALIZ, BF_LOTECTL "
	
	TcQuery cSQL New Alias (cQry)
	
	If !(cQry)->(Eof())
        
		cHtml += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
		cHtml += '<html xmlns="http://www.w3.org/1999/xhtml"> '
		cHtml += '<head> '
		cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
		cHtml += '<title>Untitled Document</title> '
		cHtml += '<style type="text/css"> '
		cHtml += '<!-- '
		cHtml += '.style12 {font-size: 9px; } '
		cHtml += '.style21 {color: #FFFFFF; font-size: 9px; } '
		cHtml += '.style41 { '
		cHtml += '	font-size: 12px; '
		cHtml += '	font-weight: bold; '
		cHtml += '} '
		cHtml += '.style42 {font-size: 10}V
		cHtml += ' '
		cHtml += '--> '
		cHtml += '</style> '
		cHtml += '</head> '
		cHtml += ' '
		cHtml += '<body> '
		cHtml += '<table width="708" border="1"> '
		cHtml += '  <tr> '
		cHtml += '    <th width="506" rowspan="3" scope="col"> Relação de produtos com estoque menor que 30 m2</th> '
		cHtml += '    <td width="186" class="style12"><div align="right"> Data: '+ dtoC(dDataBase) +' </div></td> '
		cHtml += '  </tr> '
		cHtml += '  <tr> '
		cHtml += '    <td class="style12"><div align="right">Hora: '+ SubStr(Time(), 1, 8) +' </div></td> '
		cHtml += '  </tr> '
		cHtml += '  <tr> '
		
		IF cEmpAnt = "01"
			cHtml += '    <td><div align="center" class="style41"> Biancogres </div></td> '
		Else
			cHtml += '    <td><div align="center" class="style41"> Incesa </div></td> '
		EndIf
		
		cHtml += '  </tr> '
		cHtml += '</table> '
		cHtml += '<table width="707" border="1"> '
		cHtml += '  <tr bgcolor="#0066CC"> '
		cHtml += '    <th width="93"	scope="col"><span class="style21"> Código </span></th> '
		cHtml += '    <th width="410"	scope="col"><span class="style21"> Produto </span></th> '
		cHtml += '    <th width="58" 	scope="col"><span class="style21"> Rua </span></th> '
		cHtml += '    <th width="46" 	scope="col"><span class="style21"> Lote </span></th> '
		cHtml += '	<th width="66" 	scope="col"><span class="style21"> Quantidade </span></th> '
	
		While !(cQry)->(Eof())
					
			cHtml += '	<tr bgcolor="#FFFFFF"> '
			cHtml += '	<th scope="col"><div align="left" class="style41"> '+ AllTrim((cQry)->B1_COD) +' </div></th> '
			cHtml += '	<th scope="col"><div align="left" class="style41"> '+ AllTrim((cQry)->B1_DESC) +' </div></th>  '
			cHtml += '	<th scope="col"><div align="left" class="style41"> '+ (cQry)->BF_LOCALIZ +' </div></th> '
			cHtml += '	<th scope="col"><div align="left" class="style41"> '+ (cQry)->BF_LOTECTL +' </div></th>  '
			cHtml += '	<th scope="col"><div align="left" class="style41"> '+ Transform((cQry)->DISPONIVEL, "@E 999,999,999.99") +' </div></th>  '
			cHtml += ' 	</tr>		
			
			(cQry)->(DbSkip())
					
		EndDo 
	
		cHtml += '		</table> '
		cHtml += '		</body> '
		cHtml += '		</html> '		
		
		U_BIAEnvMail(, U_EmailWF("WORK_ESTO", cEmpAnt), "Produtos com estoque menor que 30 m2", cHtml)
	
	EndIf

Return()