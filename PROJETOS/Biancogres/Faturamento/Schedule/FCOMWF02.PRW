#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} FCOMWF02
@description Workflow apos cancelamento de reserva de OP - ped. futuros
@author Fernando Rocha
@since 13/03/2018
@version 1.0
@type function
@obs revisado em 13/03/18 para incluir a funcao CALC_SALDO_OP
/*/
User Function FCOMWF02()

Local xv_Emps    := U_BAGtEmpr("01_05_14")
Local nI

For nI := 1 to Len(xv_Emps)
	//Inicializa o ambiente
	RPCSetType(3)
	WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2])
	
	//Processar
	Processa({|| U_FCWF02PR()})
	
	RpcClearEnv()
Next nI

Return

User Function FCWF02PR()
Local nCount := 0
Local _cAux
Local I                
Local _aArrayUsu 
Local _cMailUsu := ""
               
Private cHtml := ''   
Private cAlias1
Private cAlias2
	         
	//Pesquisa todas as reservas de OP canceladas manualmente
	GetData1() 
	
	//grava log de execucao com a ultima data/hora para nao repetir
	U_GravaPZ2(0,"WF2","","FCOMWF02",AllTrim(FunName()),"WF2", CUSERNAME)
	
	(cAlias1)->(DbGoTop())
	While !(cAlias1)->(Eof())
	                   
		//Verifica se atualmente a OP possui saldo disponivel
		If (cAlias1)->QTD_DISPO > 0
		             
			//Pesquisa se tem algum pedido com enttrega posterior e que pode ser antecipado para a OP origem
			GetData2((cAlias1)->PZ0_CODPRO, (cAlias1)->OP, (cAlias1)->PZ0_DATENT, (cAlias1)->QTD_DISPO)
			
			(cAlias2)->(DbGoTop())
			                   
			//Tem pedidos possiveis de antecipar
			If !(cAlias2)->(Eof())
			
				//Workflow   
				GetHeader()
				GetColumnHeader(DTOC(STOD((cAlias1)->PZ2_DATA))+" - "+(cAlias1)->PZ2_HORA,(cAlias1)->PZ2_USURES,(cAlias1)->PZ0_PEDIDO,(cAlias1)->PZ0_ITEMPV,(cAlias1)->CLIENTE,AllTrim((cAlias1)->PZ0_CODPRO)+"-"+AllTrim((cAlias1)->B1_DESC),(cAlias1)->PZ0_QUANT, DTOC(STOD((cAlias1)->PZ0_DATENT)), SubStr((cAlias1)->OP,1,6), (cAlias1)->QTD_DISPO)
				
				While !(cAlias2)->(Eof())
				
					GetItems((cAlias2)->CLIENTE, (cAlias2)->PZ0_PEDIDO, (cAlias2)->PZ0_QUANT, (cAlias2)->PZ0_OPNUM, DTOC(STOD((cAlias2)->PZ0_DATENT)))
				
					(cAlias2)->(DbSkip())
				EndDo
				(cAlias2)->(DbCloseArea())				
				cHtml += ' </table>
				GetFooter()               
				
				PswOrder(2)
				If PswSeek( (cAlias1)->PZ2_USURES, .T. )
			   		_aArrayUsu := PSWRET() // Retorna vetor com informações do usuário
			   		_cMailUsu := _aArrayUsu[1][14]
				EndIf

				SendMail(AllTrim(_cMailUsu))
				
			EndIf
		
		EndIf
		
		(cAlias1)->(DbSkip())
	EndDo 
	(cAlias1)->(DbCloseArea())
	
Return()


Static Function GetData1()

Local cFncSOp

cFncSOp := "% FNC_ROP_CALC_SALDO_OP_"+AllTrim(CEMPANT)+" %"

cAlias1 := GetNextAlias()
BeginSQL Alias cAlias1
%NOPARSER%

select distinct                     
PZ2_DATA
,PZ2_HORA
,PZ2_USURES
,CLIENTE = (case when C5_YCLIORI <> '' then (select A1_NOME from %TABLE:SA1% SA1 where A1_FILIAL = '  ' and A1_COD = C5_YCLIORI and SA1.D_E_L_E_T_='') else (select A1_NOME from %TABLE:SA1% SA1 where A1_FILIAL = '  ' and A1_COD = C5_CLIENTE and SA1.D_E_L_E_T_='') end)
,PZ0_PEDIDO
,PZ0_ITEMPV
,PZ0_CODPRO
,B1_DESC
,PZ0_QUANT
,PZ0_DATENT = C2_YDTDISP
,OP = PZ0_OPNUM+PZ0_OPITEM+PZ0_OPSEQ
,QTD_DISPO = dbo.%Exp:cFncSOp%(SC2.C2_FILIAL,SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,'','',1)

from %TABLE:PZ2% PZ2 (nolock)
join %TABLE:PZ0% PZ0 (nolock) on PZ2_FILIAL = PZ0_FILIAL and PZ0.R_E_C_N_O_ = PZ2.PZ2_ID
join %TABLE:SC5% SC5 (nolock) on C5_FILIAL = PZ0_FILIAL and C5_NUM = PZ0_PEDIDO
join %TABLE:SC2% SC2 (nolock) on C2_FILIAL = PZ0_FILIAL and C2_NUM = PZ0_OPNUM and C2_ITEM = PZ0_OPITEM and C2_SEQUEN = PZ0_OPSEQ
join %TABLE:SB1% SB1 (nolock) on B1_FILIAL = '  ' AND B1_COD = C2_PRODUTO 
join %TABLE:ZZ6% ZZ6 (nolock) on ZZ6_FILIAL = '  ' AND ZZ6_COD = B1_YFORMAT	
where
PZ2_FILIAL = '01'
and convert(smalldatetime,PZ2_DATA+' '+PZ2_HORA) >= isnull(convert(smalldatetime,(select top 1 PZ2_DATA+' '+PZ2_HORA from %TABLE:PZ2% where PZ2_CAMPO = 'FCOMWF02  ' and D_E_L_E_T_='' order by R_E_C_N_O_ desc)),'')
and ((PZ2_CAMPO = 'ALTPED') or (PZ2_CODMOT = 'XIT')) 
and C2_DATRF = ' '
and PZ2.D_E_L_E_T_=' '
and PZ0.D_E_L_E_T_='*'
and SC5.D_E_L_E_T_=' '
and SC2.D_E_L_E_T_=' '
and SB1.D_E_L_E_T_=' '
and ZZ6.D_E_L_E_T_=' '
order by CLIENTE, PZ0_PEDIDO, PZ0_ITEMPV

EndSQL

Return


Static Function GetData2(_CPRODUTO, _COPORI, _CDATAENT, _NQTDDISPO)

cAlias2 := GetNextAlias()
BeginSQL Alias cAlias2
%NOPARSER%

select 
CLIENTE = (case when C5_YCLIORI <> '' then (select A1_NOME from %TABLE:SA1% SA1 where A1_FILIAL = '  ' and A1_COD = C5_YCLIORI and SA1.D_E_L_E_T_='') else (select A1_NOME from %TABLE:SA1% SA1 where A1_FILIAL = '  ' and A1_COD = C5_CLIENTE and SA1.D_E_L_E_T_='') end)
,PZ0_PEDIDO
,PZ0_CODPRO
,PZ0_QUANT = sum(PZ0_QUANT)    
,PZ0_OPNUM
,PZ0_DATENT
from %TABLE:PZ0% PZ0
join %TABLE:SC5% SC5 (nolock) on C5_FILIAL = PZ0_FILIAL and C5_NUM = PZ0_PEDIDO

where PZ0_FILIAL = %XFILIAL:PZ0%
and PZ0_CODPRO = %EXP:_CPRODUTO%
and PZ0_OPNUM+PZ0_OPITEM+PZ0_OPSEQ <> %EXP:_COPORI%
and PZ0_DATENT > %EXP:_CDATAENT%
and PZ0.D_E_L_E_T_ = ''
group by C5_YCLIORI, C5_CLIENTE, PZ0_PEDIDO, PZ0_CODPRO, PZ0_OPNUM, PZ0_DATENT
having sum(PZ0_QUANT) <= %EXP:_NQTDDISPO%
order by PZ0_PEDIDO

EndSQL

Return


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


Static Function GetColumnHeader(_CDATAHORA,_CUSURES,_CPEDIDO,_CITEM,_CCLIENTE,_CPRODUTO,_NQTDCANC,_CDATAENT,_COPORI,_NQTDDISPO)
                                                                                     
cHtml += '         <p><div class = "headTexto">RESERVA DE OP CANCELADA - EXISTEM PEDIDOS QUE PODEM SER ANTECIPADOS</div></p> 
cHtml += '         <p><div class = "headTexto">Cliente: '+_CCLIENTE+'</div></p>
cHtml += '         <br>
cHtml += '         <p><div class = "headTexto1">Reserva Cancelada:</div></p> 
cHtml += '         <p><div>
cHtml += '         <table align="center-left" width="300" border="1" cellspacing="0" cellpadding="1">

cHtml += ' 			<tr align=left>
cHtml += '          	<td class="cabtab" width="10" scope="col">Data Cancelamento</td>
cHtml += '          	<td class="cabtab" width="10" scope="col">'+_CDATAHORA+'</td>
cHtml += '          </tr>

cHtml += ' 			<tr align=left>
cHtml += '          	<td class="cabtab" width="10" scope="col">Usuário</td>
cHtml += '          	<td class="cabtab" width="10" scope="col">'+_CUSURES+'</td>
cHtml += '          </tr>

cHtml += ' 			<tr align=left>
cHtml += '          	<td class="cabtab" width="10" scope="col">Pedido/Item</td>
cHtml += '          	<td class="cabtab" width="10" scope="col">'+_CPEDIDO+'/'+_CITEM+'</td>
cHtml += '          </tr>

cHtml += ' 			<tr align=left>
cHtml += '          	<td class="cabtab" width="10" scope="col">Produto</td>
cHtml += '          	<td class="cabtab" width="10" scope="col">'+_CPRODUTO+'</td>
cHtml += '          </tr>

cHtml += ' 			<tr align=left>
cHtml += '          	<td class="cabtab" width="10" scope="col">Qtd.Cancelada</td>
cHtml += '          	<td class="cabtab" width="10" scope="col">'+Transform(_NQTDCANC,"@E 999,999.99")+'</td>
cHtml += '          </tr>

cHtml += ' 			<tr align=left>
cHtml += '          	<td class="cabtab" width="10" scope="col">Data de Entrega</td>
cHtml += '          	<td class="cabtab" width="10" scope="col">'+_CDATAENT+'</td>
cHtml += '          </tr>

cHtml += ' 			<tr align=left>
cHtml += '          	<td class="cabtab" width="10" scope="col">OP</td>
cHtml += '          	<td class="cabtab" width="10" scope="col">'+_COPORI+'</td>
cHtml += '          </tr>

cHtml += ' 			<tr align=left>
cHtml += '          	<td class="cabtab" width="10" scope="col">Saldo Disponivel</td>
cHtml += '          	<td class="cabtab" width="10" scope="col">'+Transform(_NQTDDISPO,"@E 999,999.99")+'</td>
cHtml += '          </tr> 

cHtml += ' 			</table>
cHtml += ' 			</div></p> 

cHtml += '         <br>

cHtml += '         <p><div class = "headTexto1">Pedidos/Reservas de OP com data de entrega posterior:</div></p> 
cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">
cHtml += '            <tr align=center>
cHtml += '               <th class = "cabtab" width="30" scope="col"> Cliente </th>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Pedido </th>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Qtde </th>         
cHtml += '               <th class = "cabtab" width="10" scope="col"> OP </th> 
cHtml += '               <th class = "cabtab" width="10" scope="col"> Data Entrega </th> 
cHtml += '            </tr>

Return()


Static Function GetItems(_CCLIENTE, _CPEDIDO, _NQTDPED, _COPDEST, _CDATARES)

cHtml += " 			<tr align=center>
cHtml += "          	<td class='style12' width='10'scope='col'>"+ _CCLIENTE +"</td>
cHtml += "          	<td class='style12' width='10'scope='col'>"+ _CPEDIDO +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(_NQTDPED,"@E 999,999.99") +"</td>
cHtml += "          	<td class='style12' width='10'scope='col'>"+ _COPDEST +"</td>
cHtml += "          	<td class='style12' width='10'scope='col'>"+ _CDATARES +"</td>
cHtml += "          </tr>

Return()


Static Function GetFooter()

cHtml += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>
cHtml += "          <tr>
cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (FCOMWF02).</th>
cHtml += "			</tr>
cHtml += "		</table>
cHtml += "      </body>
cHtml += "   </html>
cHtml += "   </html>

Return()


Static Function SendMail(_cMailUsu)
Local _lRet    
Local _cTo := ""
Local _cSubject := ""
Local _cBody := ""
Local _cCC := ""

SM0->(DbSetOrder(1))
SM0->(DbSeek(cEmpAnt+cFilAnt))

_cSubject := "Cancelamento de Reserva de OP - "+ AllTrim(SM0->M0_NOME)

_cTo := U_EmailWF("FCOMWF02",cEmpAnt)+IIf(!Empty(_cMailUsu),";"+_cMailUsu,"")  


_cBody := cHtml 

_cCC += "" //Thiago Haagensen - Ticket 26232 - Retirado o endereço mayara.trigueiro@biancogres.com.br.

_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)

Return(_lRet)
