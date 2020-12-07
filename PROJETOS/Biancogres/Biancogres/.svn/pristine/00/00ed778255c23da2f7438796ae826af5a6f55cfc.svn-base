#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFCOMWF01	บAutor  ณFernando Rocha      บ Data ณ 24/06/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow de Pedido com Incremento de Comissใo			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BIANCOGRES												  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FCOMWF01(aCab, aItens)
Local nCount := 0
Local _cAux
Local I
               
Private aCabWF := aCab
Private aItensWF := aItens
Private cHtml := ''
	
	GetHeader()
	GetColumnHeader()
	
	For I := 1 To Len(aItensWF)
		GetItems(aItensWF[I])
	Next I
		
	cHtml += ' </table>
	GetFooter()
	SendMail()
	
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

Return()


Static Function GetColumnHeader()

cHtml += '         <p><div class = "headTexto1">Pedido com Incremento de Comissใo: '+aCabWF[1]+'</div></p> 
cHtml += '         <p><div class = "headTexto1">Representante: '+aCabWF[2]+'</div></p>
cHtml += '         <p><div class = "headTexto1">Cliente: '+aCabWF[3]+'</div></p>
cHtml += '         <p/>
cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">
cHtml += '            <tr align=center>
cHtml += '               <th class = "cabtab" width="30" scope="col"> Produto </th>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Qt.Ven. </th>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Vl.Unit </th>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Vl.Total </th> 
cHtml += '               <th class = "cabtab" width="30" scope="col"> Politica </th>
cHtml += '               <th class = "cabtab" width="30" scope="col"> Corre็ใo </th>
cHtml += '               <th class = "cabtab" width="30" scope="col"> Comissใo Original </th> 
cHtml += '               <th class = "cabtab" width="30" scope="col"> Nova Comissใo </th>
cHtml += '            </tr>

Return()


Static Function GetItems(aDados)

cHtml += " 			<tr align=center>
cHtml += "          	<td class='style12' width='10'scope='col'>"+ aDados[1] +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(aDados[2],"@E 999,999.99") +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(aDados[3],"@E 999,999.99") +"</td> 
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(aDados[4],"@E 999,999.99") +"</td> 
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(aDados[5],"@E 99.99") +"</td> 
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(aDados[6],"@E 99.99") +"</td> 
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(aDados[7],"@E 99.99") +"</td> 
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(aDados[8],"@E 99.99") +"</td> 
cHtml += "          </tr>

Return()


Static Function GetFooter()

cHtml += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>
cHtml += "          <tr>
cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (FCOMWF01).</th>
cHtml += "			</tr>
cHtml += "		</table>
cHtml += "      </body>
cHtml += "   </html>
cHtml += "   </html>

Return()


Static Function SendMail()
Local _lRet    
Local _cTo := ""
Local _cSubject := ""
Local _cBody := ""
Local _cCC := ""

SM0->(DbSetOrder(1))
SM0->(DbSeek(cEmpAnt+cFilAnt))
_cSubject := "Pedido com Incremento de Comissใo - "+ AllTrim(SM0->M0_NOME)

_cTo := U_EmailWF("FCOMWF01",cEmpAnt)
_cCC := ""

_cBody := cHtml

_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)

Return(_lRet)
