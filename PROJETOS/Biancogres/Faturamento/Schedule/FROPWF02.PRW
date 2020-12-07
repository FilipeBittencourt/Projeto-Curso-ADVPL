#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FROPWF02	ºAutor  ³Fernando Rocha      º Data ³ 30/03/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Workflow de geracao de pontas no empenho de pedidos		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FROPWF02()
Local nCount := 0
Local _cAux
Local aPedAt := {} 
Local I
Local xv_Emps    := U_BAGtEmpr("01_05")
LOcal nI

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
	
		While !(Qry)->(Eof())
	
			GetHeader()
			GetColumnHeader()
			__CMARCA := (Qry)->MARCA
			
			While !(Qry)->(Eof()) .And. __CMARCA == (Qry)->MARCA
					
				GetItems()
					
				SC9->(DbSetOrder(0)) 
				SC9->(DbGoto((Qry)->RECNO))
				If !SC9->(Eof())
				
					_cAux := U_FMAILATE(SC9->C9_PEDIDO)
					If !(_cAux $ AllTrim(_cAteMail)) .And. !Empty(_cAux)
						_cAteMail += AllTrim(_cAux)+";"
					EndIf			
				
					aAdd(aPedAt,(Qry)->RECNO)
				EndIf     
				
				(Qry)->(DbSkip())
			EndDo
				
			cHtml += ' </table>
			GetFooter()
			If SendMail(_cAteMail, __CMARCA)
				
				For I := 1 To Len(aPedAt)
					
					SC9->(DbSetOrder(0)) 
					SC9->(DbGoto(aPedAt[I]))
					If !SC9->(Eof())
						U_GravaPZ2(SC9->(RecNo()),"SC9",SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN),"PONTAWF",AllTrim(FunName()),"WFP", "WORKFLOW")
					EndIf
					
				Next I
				
			EndIf
			
			cHtml := ""  
			_cAteMail := ""
			aPedAt := {}
			
		EndDo
		
	EndIf
	
	(Qry)->(dbCloseArea())
	
	RpcClearEnv()
	
Next

Return()


Static Function GetData()
Qry := GetNextAlias()

cSQL := "EXEC SP_CONSULTA_PONTAS_ARREMATE_"+CEMPANT+" 3, '"+DTOS(dDataBase-1)+"', '"+DTOS(dDataBase)+"'

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

cHtml += '         <p><div class = "headTexto1">Ocorreu geração de ponta de estoque no empenho dos seguintes pedidos:</div></p>
cHtml += '         <p/>
cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">
cHtml += '            <tr align=center>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Pedido </th>
cHtml += '               <th class = "cabtab" width="30" scope="col"> Cliente </th>
cHtml += '               <th class = "cabtab" width="20" scope="col"> Representante </th>
cHtml += '               <th class = "cabtab" width="15" scope="col"> Atendente </th>
cHtml += '               <th class = "cabtab" width="15" scope="col"> Data Empenho </th>
cHtml += '               <th class = "cabtab" width="30" scope="col"> Produto </th>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Lote </th>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Qt.Lib. </th>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Saldo Lote </th>
cHtml += '               <th class = "cabtab" width="10" scope="col"> Qt.Um Palete </th> 
cHtml += '               <th class = "cabtab" width="30" scope="col"> Motivo </th>
cHtml += '            </tr>

Return()


Static Function GetItems()

SB1->(DbSetOrder(1))
SB1->(DbSeek(XFilial("SB1")+(Qry)->COD_PRODUTO))

cHtml += " 			<tr align=center>
cHtml += "          	<td class='style12' width='100'scope='col'>"+ (Qry)->PEDIDO +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->NOME +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->REPRESENTANTE +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->ATENDENTE +"</td>
cHtml += "              <td class='style12' width='40'scope='col'>"+ DToC(SToD((Qry)->DATA_EMPENHO)) +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ AllTrim((Qry)->PRODUTO) +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->LOTE +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->QTD_LIB,"@E 999,999.99") +"</td> 
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->SALDO_LOTE,"@E 999,999.99") +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->Q_UM_PALETE,"@E 999,999.99") +"</td>
cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->MOTIVO +"</td>
cHtml += "          </tr>

Return()


Static Function GetFooter()

cHtml += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>
cHtml += "          <tr>
cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (FROPWF02).</th>
cHtml += "			</tr>
cHtml += "		</table>
cHtml += "      </body>
cHtml += "   </html>
cHtml += "   </html>

Return()


Static Function SendMail(_cAteMail, _cMarca)
	Local _lRet    

	Local _cTo := ""
	Local _cSubject := ""
	Local _cBody := ""
	Local _cCC := ""
	
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(_cMarca+'01'))
	
	_cSubject := "Geração de PONTA no estoque - "+ AllTrim(SM0->M0_NOME)
	
	_cTo := U_EmailWF("FROPWF02",_cMarca)
	_cCC := _cAteMail
	
	_cBody := cHtml
	
	_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)
	if _lRet
		Conout("FROPWF02 -> E-mail enviado para:"+_cTo) 
	else
		Conout("FROPWF02 -> Erro ao enviar e-mail") 
	endif
Return(_lRet)
