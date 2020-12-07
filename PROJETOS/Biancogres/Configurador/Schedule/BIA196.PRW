#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

//--------------------------------------------------------------------------------------------
//								*** WF DE NOTA FISCAL DE SAIDA ***
//--------------------------------------------------------------------------------------------
// Solcitante: Claudia Carvalho
// Desenvolv.: Thiago Dantas
// Danta: 07/07/2014 
//--------------------------------------------------------------------------------------------

User Function BIA196()

Local nI
Private cMensagem  := ''
Private lOK        := .F.
Private lSexta     := .F.
Private lErro      := .F.
Private cERRO      := ''
Private cMensag    := ''
Private cMens      := ''
Private nItemPrd   := 0
Private cEmail     := ''
Private Enter      := CHR(13)+CHR(10)

xv_Emps    := U_BAGtEmpr("01_05")

For nI := 1 to Len(xv_Emps)
	//Inicializa o ambiente
	RPCSetType(3)
	WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
	//Gera o html do WF.
	Processa({|| GeraWF()})
		
	RpcClearEnv()
Next nI

Return
//---------------------------------------(GeraWF)----------------------------------
Static Function GeraWF()

Private C_HTML		:= ''

cQry := GeraSql()

If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cQry ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGotop()

Setprc(0,0)
cEmailCC := ''
cEmailCO := ''

GeraHTML()

DbSelectArea("QRY")
If eof()
	DbCloseArea()
EndIf

Return

//---------------------------------------(GeraHTML)----------------------------------
Static Function GeraHTML()
//caracter de salto de linha
cCrLf := Chr(13) + Chr(10)

GeraCab()
GeraCabCls()

While !EOF()
		
	IncProc()
	nItemPrd += 1
	//Adiciona as NFs da empresa
	GeraItmTb()
	DbSelectArea("QRY")
	DbSkip()

	if Eof()
		GeraFtrFim()
	EndIf
	
	DbSelectArea("QRY")
END
Enviar()
Return

//---------------------------------------(Enviar)----------------------------------
Static Function Enviar()

ldebug := .F.

if ldebug                                              
	Envioemail("wanisay.william@biancogres.com.br")
else
    cDest := U_EmailWF('BIA196',cEmpAnt)
    Envioemail(cDest)
EndIf

cMensag  := ''
cMens    := ''
nItemPrd := 0

Return

//---------------------------------------(Envioemail)----------------------------------
Static Function Envioemail(cEmail)
	  					  		
cRecebe   	:= cEmail														 		
cRecebeCC	:= cEmailCC  												 			
cRecebeCO	:= cEmailCO			  								 					
cAssunto	:= 'WF de NFs de Saída'

cMensag := "Seguem as NFs emitidas da empresa "+ALLTRIM(SM0->M0_NOMECOM) +ENTER+ENTER
cMensag += C_HTML
cArqAnexo := ''

U_BIAEnvMail(,cRecebe,cAssunto,cMensag,'',cArqAnexo,,cRecebeCC)       

Return

//---------------------------------------(GeraCab)----------------------------------
Static Function GeraCab()
C_HTML := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
C_HTML += '   <html xmlns="http://www.w3.org/1999/xhtml">
C_HTML += '      <head>
C_HTML += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
C_HTML += '         <title>Estoque</title>
C_HTML += '         <style type="text/css">
C_HTML += '			<!--
C_HTML += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
C_HTML += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
C_HTML += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
C_HTML += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
C_HTML += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
C_HTML += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
C_HTML += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif } 			
C_HTML += '			--> 
C_HTML += '         </style>
C_HTML += '      </head>
C_HTML += '      <body>

Return

//---------------------------------------(GeraCabCls)----------------------------------
Static Function GeraCabCls()
C_HTML += '         <table align="center" width="800" class = "headProd">
C_HTML += '               <tr>
C_HTML += '                  <div align="left">
C_HTML += "                  <th width='694' scope='col'> Notas Fiscais Emitidas</th>
C_HTML += '					 </div>
C_HTML += '               </tr>
C_HTML += '         </table>
C_HTML += '         <table align="center" width="800" border="1" cellspacing="0" cellpadding="1">
C_HTML += '            <tr align=center>
C_HTML += '               <th class = "cabtab" width="30" scope="col">  </span></th>
C_HTML += '               <th class = "cabtab" width="60" scope="col"> NF </span></th>
C_HTML += '               <th class = "cabtab" width="100" scope="col" > Item </span></th>
C_HTML += '               <th class = "cabtab" width="50" scope="col"> Cod. Fornec. </span></th>
C_HTML += '               <th class = "cabtab" width="100" scope="col"> Fornecedor </span></th>
C_HTML += '               <th class = "cabtab" width="50" scope="col"> Emissão </span></th>
C_HTML += '               <th class = "cabtab" width="100" scope="col"> Transportadora </span></th>
C_HTML += '            </tr>
Return

//---------------------------------------(GeraItmTb)----------------------------------
Static Function GeraItmTb()

C_HTML += " 			<tr align=center>
C_HTML += "                   <td class='style12' width='30'scope='col'>" +STRZERO(nItemPrd,4)			+"</td>
C_HTML += "                   <td class='style12' width='60'scope='col'>"+ALLTRIM(QRY->D2_DOC)			+"</td>
C_HTML += " 				  <td class='style12' width='100'scope='col'>"+ALLTRIM(QRY->B1_DESC)		+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+ALLTRIM(QRY->D2_CLIENTE)		+"</td>
C_HTML += " 				  <td class='style12' width='100'scope='col'>"+ALLTRIM(QRY->A2_NOME)		+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+DToC(SToD(QRY->D2_EMISSAO))	+"</td>
C_HTML += "                   <td class='style12' width='100'scope='col'>"+ALLTRIM(QRY->TRANSP)			+"</td>
C_HTML += "             </tr>

Return

//---------------------------------------(GeraTotItm)----------------------------------
Static Function GeraTotItm()

C_HTML += "		</table>
C_HTML += "		<table align='center' width='800' border='1' cellspacing='0' cellpadding='1'>
C_HTML += "            <tr align=center>
C_HTML += "               <th class = 'tottab' width='156' scope='col'> Total </span></th>
C_HTML += "               <th class = 'tottab' width='70' scope='col'> "+ TRANSFORM(nTotalProd,"@E 9,999,999.99") +" </span></th>
C_HTML += "			   <th class = 'tottab' width='70' scope='col'> "+ TRANSFORM(nTotalEmp ,"@E 9,999,999.99")+" </span></th>
C_HTML += "			   <th class = 'tottab' width='70' scope='col'> "+ TRANSFORM(nTotalDisp,"@E 9,999,999.99")+" </span></th>
C_HTML += "			</tr>  
C_HTML += "		</table>

Return

//---------------------------------------(GeraFooter)----------------------------------
Static Function GeraFooter()
	
	C_HTML +="	<div id='psdg-footer'> &nbsp </div>"

Return

//---------------------------------------(GeraFtrFim)----------------------------------
Static Function GeraFtrFim()

C_HTML += "		<table align='center' width='800' border='1' cellspacing='0' cellpadding='1'>
C_HTML += "            <tr>
C_HTML += "               <th class = 'tottab' width='600' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by BIA196).</th>
C_HTML += "			</tr>  
C_HTML += "		</table>
C_HTML += "      </body>
C_HTML += "   </html>

Return

//---------------------------------------(AddCSS)----------------------------------
Static Function AddCSS()

C_HTML += ' <style type="text/css">
C_HTML += '#psdgraphics-com-table
C_HTML += '{
C_HTML += '	background-color: #D3D3D3;
C_HTML += '	color: #747474;
C_HTML += '	font: 11px Arial, Helvetica, sans-serif;
C_HTML += '	margin: 0;
C_HTML += '	padding: 4px;
C_HTML += '	width: 467px;
C_HTML += '}
C_HTML += '#psdg-header
C_HTML += '{
C_HTML += '	background: #0c2c65;
C_HTML += '	color: #FFF;
C_HTML += '	font-size: 12px;
C_HTML += '	height: 35px;
C_HTML += '	margin: 0;
C_HTML += '	padding: 6px 0 0 24px;
C_HTML += '	width: 442px;
C_HTML += '}
C_HTML += '#psdg-header2
C_HTML += '{
C_HTML += '	background: #0c2c65;
C_HTML += '	color: #FFF;
C_HTML += '	font-size: 12px;
C_HTML += '	height: 15px;
C_HTML += '	margin: 0;
C_HTML += '	padding: 3px 0 0 24px;
C_HTML += '	width: 442px;
C_HTML += '}
C_HTML += '.psdg-bold
C_HTML += '{
C_HTML += '	font: bold 16px Arial, Helvetica, sans-serif;
C_HTML += '}
C_HTML += '#psdg-top
C_HTML += '{
C_HTML += '	background: #eff4ff;
C_HTML += '	border-top: 2px solid #FFF;
C_HTML += '	height: 50px;
C_HTML += '	margin: 0;
C_HTML += '	padding: 0;
C_HTML += '	width: 467px;
C_HTML += '}
C_HTML += '.psdg-top-cell
C_HTML += '{
C_HTML += '	border-right: 1px solid #ced9ec;
C_HTML += '	color: #1f3d71;
C_HTML += '	float: left;
C_HTML += '	font: 13px Arial, Helvetica, sans-serif;
C_HTML += '	height: 45px;
C_HTML += '	padding: 15px 0 0 0;
C_HTML += '	text-align: center;
C_HTML += '	width: 105px;
C_HTML += '}
C_HTML += '#psdg-middle
C_HTML += '{
C_HTML += '	background: #f6f6f6;
C_HTML += '	margin: 0;
C_HTML += '	padding: 0;
C_HTML += '	width: 470px;
C_HTML += '}
C_HTML += '.psdg-left
C_HTML += '{
C_HTML += '	background: #e4ebf8;
C_HTML += '	border-bottom: 1px solid #b3c1db;
C_HTML += '	border-right: 1px solid #ced9ec;
C_HTML += '	color: #1f3d71;
C_HTML += '	float: left;
C_HTML += '	font: 12px Arial, Helvetica, sans-serif;
C_HTML += '	height: 15px;
C_HTML += '	margin: 0;
C_HTML += '	padding: 3px 0 0 24px;
C_HTML += '	text-align: left;
C_HTML += '	width: 105px;
C_HTML += '}
C_HTML += '.psdg-right
C_HTML += '{
C_HTML += '	border-bottom: 1px solid #b3c1db;
C_HTML += '	border-right: 1px solid #ced9ec;
C_HTML += '	float: left;
C_HTML += '	height: 15px;
C_HTML += '	margin: 0;
C_HTML += '	padding: 1px 0 0 0;
C_HTML += '	text-align: center;
C_HTML += '	width: 105px;
C_HTML += '}
C_HTML += '#psdg-bottom
C_HTML += '{
C_HTML += '	background: #e4e3e3;
C_HTML += '	border-top: 2px solid #FFF;
C_HTML += '	clear: both;
C_HTML += '	height: 48px;
C_HTML += '	margin: 0;
C_HTML += '	padding: 0;
C_HTML += '	width: 578px;
C_HTML += '}
C_HTML += '.psdg-bottom-cell
C_HTML += '{
C_HTML += '	border-right: 1px solid #ced9ec;
C_HTML += '	color: #070707;
C_HTML += '	float: left;
C_HTML += '	font: 13px Arial, Helvetica, sans-serif;
C_HTML += '	height: 33px;
C_HTML += '	padding: 15px 0 0 0;
C_HTML += '	text-align: center;
C_HTML += '	width: 105px;
C_HTML += '}
C_HTML += '#psdg-footer
C_HTML += '{
C_HTML += '	background: #f6f6f6;
C_HTML += '	color: #8a8a8a;
C_HTML += '	font-size: 10px;
C_HTML += '	margin: 0;
C_HTML += '	padding: 8px 0 8px 12px;
C_HTML += '	width: 456px;
C_HTML += '}		}</style>

Return
 
 //---------------------------------------(GeraSql)----------------------------------
Static Function GeraSql()

cSQL := ""
cSql += " SELECT D2_YEMP, D2_DOC, B1_DESC, D2_CLIENTE, A2.A2_NOME, D2_EMISSAO,ISNULL(A4.A4_NOME, '-') AS TRANSP	     "
cSql += " FROM VW_SD2 D2                                                                                             "
cSql += " INNER JOIN VW_SF2 F2 ON D2.D2_DOC = F2_DOC AND D2.D2_SERIE = F2.F2_SERIE AND D2.D2_YEMP = F2.F2_YEMP       "
cSql += " LEFT JOIN SA2010 A2 ON A2_COD = D2.D2_CLIENTE AND D2.D2_LOJA = A2.A2_LOJA                                  "
cSql += " LEFT JOIN SB1010 B1 ON B1_COD = D2.D2_COD                                                                  "
cSql += " LEFT JOIN VW_SC5 C5 ON C5.C5_NUM = D2.D2_PEDIDO AND C5.C5_CLIENTE = D2.D2_CLIENTE AND C5.D_E_L_E_T_ = ''									 "
cSql += " LEFT JOIN SA4010 A4 ON A4.A4_COD = C5_TRANSP AND A4.D_E_L_E_T_ = ''	                                     "
cSql += " WHERE D2_CF IN('5915', '6915')                                                                             "
cSql += " AND CONVERT(DATETIME,D2_EMISSAO,103) BETWEEN GETDATE()-7 AND GETDATE() -1                                  "
cSql += " AND D2_YEMP LIKE '"+cEmpAnt+"__' 																			 "
cSql += " AND C5_TIPO = 'B'																							 "		
cSql += " ORDER BY D2_YEMP, D2_EMISSAO, A2_NOME                                                                      "

Return cSQL
