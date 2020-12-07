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

User Function BIA197()

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
    cDest := U_EmailWF('BIA197',cEmpAnt)
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
cAssunto	:= 'NFs de Remessa em Garantia'

cMensag := " Seguem as NF's de frete emitidas à partir de pedido de remessa em garantia da empresa "+ALLTRIM(SM0->M0_NOMECOM) +ENTER+ENTER
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
C_HTML += '               <th class = "cabtab" width="60" scope="col"> NF </span></th>
C_HTML += '               <th class = "cabtab" width="30" scope="col"> ITEM </span></th>
C_HTML += '               <th class = "cabtab" width="50" scope="col"> COD. CLIENTE </span></th>
C_HTML += '               <th class = "cabtab" width="100" scope="col"> DESTINATARIO </span></th>
C_HTML += '               <th class = "cabtab" width="50" scope="col" > EMISSAO </span></th>
C_HTML += '               <th class = "cabtab" width="100" scope="col"> TRANSPORTADORA </span></th>
C_HTML += '               <th class = "cabtab" width="30" scope="col"> TIPO FRETE </span></th>
C_HTML += '               <th class = "cabtab" width="50" scope="col"> PEDIDO </span></th>
C_HTML += '            </tr>
Return

//---------------------------------------(GeraItmTb)----------------------------------
Static Function GeraItmTb()

C_HTML += " 			<tr align=center>
C_HTML += "                   <td class='style12' width='60'scope='col'>"+ALLTRIM(QRY->D2_DOC)			+"</td>
C_HTML += "                   <td class='style12' width='30'scope='col'>"+ALLTRIM(QRY->D2_ITEM)			+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+ALLTRIM(QRY->D2_CLIENTE)		+"</td>
C_HTML += " 				  <td class='style12' width='100'scope='col'>"+ALLTRIM(QRY->A1_NOME)		+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+DToC(SToD(QRY->D2_EMISSAO))	+"</td>
C_HTML += "                   <td class='style12' width='100'scope='col'>"+ALLTRIM(QRY->TRANSP)			+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+ALLTRIM(QRY->TPFRETE)			+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+ALLTRIM(QRY->D2_PEDIDO)		+"</td>
C_HTML += "             </tr>

Return

//---------------------------------------(GeraFooter)----------------------------------
Static Function GeraFooter()
	
	C_HTML +="	<div id='psdg-footer'> &nbsp </div>"

Return

//---------------------------------------(GeraFtrFim)----------------------------------
Static Function GeraFtrFim()

C_HTML += "		</table>
C_HTML += "		<table align='center' width='800' border='1' cellspacing='0' cellpadding='1'>
C_HTML += "             <tr>
C_HTML += "               <th class = 'tottab' width='600' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by BIA197).</th>
C_HTML += "				</tr>  
C_HTML += "		</table>
C_HTML += "   </body>
C_HTML += "   </html>

Return

 //---------------------------------------(GeraSql)----------------------------------
Static Function GeraSql()

cSQL := ""
cSql += " SELECT D2_YEMP, D2_DOC, D2_ITEM, D2_PEDIDO, B1_DESC, D2_CLIENTE, A1.A1_NOME, D2_EMISSAO,ISNULL(A4.A4_NOME, '-') AS TRANSP,	     "
cSql += " CASE C5_TPFRETE WHEN 'C' THEN 'CIF' WHEN 'F' THEN 'FOB' ELSE '-' END TPFRETE	"
cSql += " FROM VW_SD2 D2                                                                                             "
cSql += " LEFT JOIN SA1010 A1 ON A1_COD = D2.D2_CLIENTE AND D2.D2_LOJA = A1.A1_LOJA  AND A1.D_E_L_E_T_ = ''          "
cSql += " LEFT JOIN SB1010 B1 ON B1_COD = D2.D2_COD AND B1.D_E_L_E_T_ = ''                                           "
cSql += " LEFT JOIN VW_SC5 C5 ON C5.C5_NUM = D2.D2_PEDIDO AND C5.C5_CLIENTE = D2.D2_CLIENTE AND C5.D_E_L_E_T_ = ''	 "
cSql += " LEFT JOIN SA4010 A4 ON A4.A4_COD = C5_TRANSP AND A4.D_E_L_E_T_ = ''	                                     "
cSql += " WHERE CONVERT(DATETIME,D2_EMISSAO,103) BETWEEN GETDATE()-7 AND GETDATE() -1								 "
cSql += " AND D2_YEMP LIKE '"+cEmpAnt+"__' 																			 "
cSql += " AND C5_YSUBTP = 'G'																						 "		
cSql += " ORDER BY D2_YEMP, D2_EMISSAO, D2_DOC, D2_ITEM, A1_NOME                                                     "

Return cSQL
