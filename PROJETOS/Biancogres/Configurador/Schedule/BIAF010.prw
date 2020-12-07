#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|------------------------------------------------------------|
| Função:	| BIAF010																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 05/11/14																				 |
|------------------------------------------------------------|
| Desc.:	|	Workflow de notas fiscais de saida intercompany  |
|------------------------------------------------------------|
| OS:			|	1880-14 - Usuário: Jean Vitor Morais  		 			 |
|------------------------------------------------------------|
*/

User Function BIAF010()
Local nCount := 0
Private cSQL := ""
Private Qry := ""
Private cHtml := ''
Private aEmp := {}
Private cEmp := ""
Private cEmpName := ""
		
	RpcSetType(3)
	RpcSetEnv("01", "01")
	
	aAdd(aEmp, {"01", "Biancogres"})
	aAdd(aEmp, {"05", "Incesa"})
	aAdd(aEmp, {"06", "JK Serviços"})
	aAdd(aEmp, {"07", "LM Comércio"})
	aAdd(aEmp, {"12", "ST Gestão"})
	aAdd(aEmp, {"13", "Mundi"})
	aAdd(aEmp, {"14", "Vitcer"})
	
	For nCount := 1 To Len(aEmp)
	
		cEmp := aEmp[nCount, 1]
		cEmpName := aEmp[nCount, 2]
		
		If GetData()
			
			GetHtml()
			
			SendMail()						
			
		EndIf
		
		(Qry)->(dbCloseArea())
		
	Next
		
	RpcClearEnv()

Return()


Static Function GetData()
Local lRet := .F.
	        
	Qry := GetNextAlias()
	
	cSQL := "EXEC SP_NOTA_FISCAL_SAIDA_INTERCOMPANY_"+cEmp + ValToSQL(dDataBase-1)
			
	TcQuery cSQL New Alias (Qry)
	  		
	lRet := !Empty((Qry)->F2_EMISSAO)
	
Return(lRet)


Static Function GetHtml()

	GetHeader()
	
	GetColumnHeader()
	
	GetItems()
	
	GetFooter()

Return()


Static Function GetHeader()

	cHtml := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
	cHtml += '   <html xmlns="http://www.w3.org/1999/xhtml">
	cHtml += '      <head>
	cHtml += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cHtml += '         <title>cabtitpag</title>
	cHtml += '         <style type="text/css">
	cHtml += '			<!--
	cHtml += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
	cHtml += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
	cHtml += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
	cHtml += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif } 			
	cHtml += '			--> 
	cHtml += '         </style>
	cHtml += '      </head>
	cHtml += '      <body>

Return()


Static Function GetColumnHeader()

	cHtml += '         <table align="center" width="1200" class = "headProd">
	cHtml += '               <tr>
	cHtml += '                  <div align="left">
	cHtml += "                  <th width='1200' scope='col'>Empresa: "+ cEmpName +"</th>
	cHtml += '					 </div>
	cHtml += '               </tr>
	cHtml += '         </table>
	cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">
	cHtml += '            <tr align=center>
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Data </th>
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Tipo </th>
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Clie./Forn. </th>
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Loja </th>
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Nome </th>
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Nota </th>
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Série </th>	
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Item </th>
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Produto </th>	
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Descrição </th>
	cHtml += '               <th class = "cabtab" width="40" scope="col"> UM </th>	
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Cod. Fiscal </th>		
	cHtml += '               <th class = "cabtab" width="80" scope="col"> Quant. </th>
	cHtml += '               <th class = "cabtab" width="80" scope="col"> Vlr. Unit. </th>	
	cHtml += '               <th class = "cabtab" width="80" scope="col"> Vlr. Total </th>
	cHtml += '               <th class = "cabtab" width="80" scope="col"> Vlr. ICMS </th>
	cHtml += '               <th class = "cabtab" width="80" scope="col"> Vlr. PIS </th>
	cHtml += '               <th class = "cabtab" width="80" scope="col"> Vlr. COF. </th>
	
	cHtml += '            </tr>
	
Return()


Static Function GetItems()
	  		
	While (Qry)->(!Eof())

		cHtml += " 			<tr align=center>
		cHtml += "                   <td class='style12' width='40'scope='col'>"+ DToC(SToD((Qry)->F2_EMISSAO)) +"</td>
		cHtml += "                   <td class='style12' width='20'scope='col'>"+ (Qry)->F2_TIPO +"</td>
		cHtml += "                   <td class='style12' width='40'scope='col'>"+ (Qry)->F2_CLIENTE +"</td>
		cHtml += "                   <td class='style12' width='40'scope='col'>"+ (Qry)->F2_LOJA +"</td>	
		cHtml += "                   <td class='style12' width='300'scope='col'>"+ AllTrim((Qry)->A1_NOME) +"</td>
		
		cHtml += "                   <td class='style12' width='40'scope='col'>"+ AllTrim((Qry)->F2_DOC) +"</td>
		cHtml += "                   <td class='style12' width='40'scope='col'>"+ AllTrim((Qry)->F2_SERIE) +"</td>
		cHtml += "                   <td class='style12' width='40'scope='col'>"+ AllTrim((Qry)->D2_ITEM) +"</td>	
		cHtml += "                   <td class='style12' width='40'scope='col'>"+ AllTrim((Qry)->D2_COD) +"</td>
		
		cHtml += "                   <td class='style12' width='300'scope='col'>"+ AllTrim((Qry)->B1_DESC) +"</td>
		cHtml += "                   <td class='style12' width='40'scope='col'>"+ AllTrim((Qry)->D2_UM) +"</td>
		cHtml += "                   <td class='style12' width='40'scope='col'>"+ (Qry)->D2_CF +"</td>		
		cHtml += "                   <td class='style12' width='80'scope='col'>"+ Transform((Qry)->D2_QUANT, "@E 99999999.99") +"</td>	
		cHtml += "                   <td class='style12' width='80'scope='col'>"+ Transform((Qry)->D2_PRCVEN, "@E 99,999,999.9999") +"</td>
		cHtml += "                   <td class='style12' width='80'scope='col'>"+ Transform((Qry)->D2_TOTAL, "@E 999,999,999.99") +"</td>	
		
		cHtml += "                   <td class='style12' width='80'scope='col'>"+ Transform((Qry)->FT_VALICM, "@E 999,999,999.99") +"</td>	
		cHtml += "                   <td class='style12' width='80'scope='col'>"+ Transform((Qry)->FT_VALPIS, "@E 999,999,999.99") +"</td>
		cHtml += "                   <td class='style12' width='80'scope='col'>"+ Transform((Qry)->FT_VALCOF, "@E 999,999,999.99") +"</td>		
		
		cHtml += "             </tr>
		
		(Qry)->(dbSkip())
		                                                           
	EndDo
		
	cHtml += '         </table>

Return()


Static Function GetFooter()

	cHtml += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>
	cHtml += "            <tr>
	cHtml += "               <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by BIAF010).</th>
	cHtml += "			</tr>  
	cHtml += "		</table>
	cHtml += "      </body>
	cHtml += "   </html>
	cHtml += "   </html>

Return()


Static Function SendMail()

	cTo := U_EmailWF('BIAF010', cEmpAnt)
	cCC	:= ""
	cSubject := "Notas Fiscais de Saída Intercompany - "+ cEmpName
	cBody := cHtml
	cAttach := ""
	
	U_BIAEnvMail(, cTo, cSubject, cBody, '', cAttach, , cCC)
	
Return()