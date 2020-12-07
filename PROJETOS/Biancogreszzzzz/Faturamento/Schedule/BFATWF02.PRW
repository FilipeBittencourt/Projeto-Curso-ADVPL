#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BFATWF02	ºAutor  ³Fernando Rocha      º Data ³ 23/03/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Workflow propostas inclusas no dia anterior				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BFATWF02()
Local nCount := 0
Local _cAux
Local aPedAt := {} 
Local I
Local xv_Emps    := U_BAGtEmpr("01")
Local nI
Private cSQL := ""
Private Qry := ""
Private cHtml := ''
Private _cAteMail := ""

For nI := 1 to Len(xv_Emps)
	//Inicializa o ambiente
	RPCSetType(3)
	WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 

	GetData()
	
	If !(Qry)->(Eof())
	
		GetHeader()
		GetColumnHeader()
	
		While !(Qry)->(Eof())
	
			GetItems()
			                  
			(Qry)->(DbSkip())
		EndDo
		
		cHtml += ' </table>
		GetFooter()
		
		SendMail()
		
		cHtml := ""  
		_cAteMail := ""
		aPedAt := {}
		
	EndIf
	
	(Qry)->(dbCloseArea())
	
	RpcClearEnv()
	
Next

Return()


Static Function GetData()
Local dDiaAnt

If Dow(dDataBase) == 2
	dDiaAnt := dDataBase - 3
Else
	dDiaAnt := dDataBase - 1
EndIf

Qry := GetNextAlias()

cSQL := ""
cSQL += " with tab_z68 as ( "+CRLF
cSQL += " select distinct "+CRLF
cSQL += " Z68_NUM "+CRLF
cSQL += " from "+RetSqlName("Z68")+" Z68 "+CRLF
cSQL += " where  "+CRLF
cSQL += " ( Z68_EMISSA = '"+DTOS(dDiaAnt)+"' OR Z68_DTAPRO = '"+DTOS(dDiaAnt)+"' ) "+CRLF
cSQL += " and Z68.D_E_L_E_T_ = ''  "+CRLF
cSQL += " group by Z68_NUM "+CRLF
cSQL += " ) "+CRLF
cSQL += " , tab_rev as ( "+CRLF
cSQL += " select "+CRLF
cSQL += " Z68_NUM, "+CRLF
cSQL += " Z68_REV = (select MAX(Z68_REV) from "+RetSqlName("Z68")+" X where X.Z68_NUM = tab_z68.Z68_NUM and X.D_E_L_E_T_='') "+CRLF
cSQL += " from tab_z68 "+CRLF
cSQL += " ) "+CRLF
cSQL += " select "+CRLF
cSQL += " Z68.Z68_NUM,  "+CRLF
cSQL += " Z68.Z68_REV, "+CRLF
cSQL += " STATUS = case when Z68_STATUS = '0' then 'Nova Proposta' when Z68_STATUS = '1' then 'Revisão' when Z68_STATUS = '2' then 'Aprovada' when Z68_STATUS = '3' then 'Rejeitada' when Z68_STATUS = '4' then 'Pedido' else 'Vencida' end,  "+CRLF
cSQL += " Z68_EMISSA, "+CRLF
cSQL += " Z68_CODCLI,  "+CRLF
cSQL += " Z68_LOJCLI,  "+CRLF
cSQL += " Z68_NOMCLI, "+CRLF
cSQL += " A3_NOME,  "+CRLF
cSQL += " Z68_COND, "+CRLF
cSQL += " DESC_COND = E4_COND,  "+CRLF
cSQL += " Z68_CODVEN,  "+CRLF
cSQL += " Z68_DTVALI, "+CRLF
cSQL += " TOTAL_QTDE = (select sum(Z69_QTDVEN) from "+RetSqlName("Z69")+" X where X.Z69_FILIAL = Z68.Z68_FILIAL and X.Z69_NUM = Z68.Z68_NUM and X.Z69_REV = Z68.Z68_REV and X.D_E_L_E_T_=' '), "+CRLF
cSQL += " TOTAL_VALOR = (select sum(Z69_VALOR) from "+RetSqlName("Z69")+" X where X.Z69_FILIAL = Z68.Z68_FILIAL and X.Z69_NUM = Z68.Z68_NUM and X.Z69_REV = Z68.Z68_REV and X.D_E_L_E_T_=' ') "+CRLF
cSQL += " from tab_rev "+CRLF
cSQL += " join "+RetSqlName("Z68")+" Z68 on Z68.Z68_NUM = tab_rev.Z68_NUM and Z68.Z68_REV = tab_rev.Z68_REV "+CRLF
cSQL += " join "+RetSqlName("SE4")+" SE4 on E4_FILIAL = '  ' and E4_CODIGO = Z68_COND  "+CRLF
cSQL += " join "+RetSqlName("SA3")+" SA3 on A3_FILIAL = '  ' and A3_COD = Z68_CODVEN "+CRLF
cSQL += " where  "+CRLF
cSQL += " Z68.D_E_L_E_T_ = ''  "+CRLF
cSQL += " and SE4.D_E_L_E_T_ = ''  "+CRLF
cSQL += " and SA3.D_E_L_E_T_ = '' "+CRLF

TcQuery cSQL New Alias (Qry)
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

cHtml += '         <p><div class = "headTexto1">Propostas inclusas ou modificadas no dia anterior: </div></p>
cHtml += '         <p/>
cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">
cHtml += '            <tr align=center>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Número </th>
cHtml += '               <th class = "cabtab" width="30" scope="col"> Revisão </th>
cHtml += '               <th class = "cabtab" width="20" scope="col"> Status </th>
cHtml += '               <th class = "cabtab" width="15" scope="col"> Representante </th>
cHtml += '               <th class = "cabtab" width="15" scope="col"> Cliente </th>
cHtml += '               <th class = "cabtab" width="30" scope="col"> Qtde(m2) </th>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Valor(R$) </th>
cHtml += '            </tr>

Return()


Static Function GetItems()

cHtml += " 			<tr align=center>
cHtml += "          	<td class='style12' width='100'scope='col'>"+ (Qry)->Z68_NUM +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->Z68_REV +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->STATUS +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->A3_NOME +"</td>
cHtml += "              <td class='style12' width='40'scope='col'>"+ (Qry)->Z68_NOMCLI +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->TOTAL_QTDE,"@E 999,999.99") +"</td> 
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->TOTAL_VALOR,"@E 99,999,999.99") +"</td>
cHtml += "          </tr>

Return()


Static Function GetFooter()

cHtml += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>
cHtml += "          <tr>
cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (BFATWF02).</th>
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


_cSubject := "Propostas de Engenharia de - "+ DTOC(dDataBase-1)

If Upper(AllTrim(getenvserver())) == "SCHEDULE"
	_cTo := U_EmailWF("BFATWF02",CEMPANT)
	_cCC := ""
Else          
	_cTo := U_EmailWF("BFATWF02",CEMPANT)
	_cTo += ";fernando@facilesistemas.com.br"
	_cCC := ""
EndIf

_cBody := cHtml

_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)

Return(_lRet)
