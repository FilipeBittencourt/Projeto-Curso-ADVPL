#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

//--------------------------------------------------------------------------------------------
//								*** WF DE NOTA FISCAL DE SAIDA ***
//--------------------------------------------------------------------------------------------
// Solcitante: Tatiane - Incesa
// Desenvolv.: Thiago Dantas
// Danta: 08/09/2014 
//--------------------------------------------------------------------------------------------
// O intuito do WF é enviar para o comercial as NFS que foram lanças para cliente LM
// mas que não forma faturadas na LM.
//--------------------------------------------------------------------------------------------
User Function BIA200()

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

xv_Emps    := U_BAGtEmpr("01_05_13_14")

For nI := 1 to Len(xv_Emps)
	//Inicializa o ambiente
	RPCSetType(3)
	WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
	//Gera o html do WF.
	Processa({|| GeraWF()})
		
	RpcClearEnv()
Next nI

Return .T.
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
If !Eof()
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
EndIf
Return

//---------------------------------------(Enviar)----------------------------------
Static Function Enviar()

ldebug := .F.

if ldebug                                              
	Envioemail("wanisay.william@biancogres.com.br")
else
    cDest := U_EmailWF('BIA200',cEmpAnt)
    Envioemail(cDest)
EndIf

cMensag  := ''
cMens    := ''
nItemPrd := 0

Return

//---------------------------------------(Envioemail)----------------------------------
Static Function Envioemail(cEmail)
	  					  		
cRecebe   	:= cEmail														 		
cRecebeCC	:= ""  												 			
cRecebeCO	:= ""			  								 					
cAssunto	:= 'Notas não registradas na LM'

cMensag := " Seguem as NF's emitidas na "+ALLTRIM(SM0->M0_NOMECOM) +" mas não deram entrada na LM. "+ENTER+ENTER
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
C_HTML += '               <th class = "cabtab" width="50" scope="col"> SERIE </span></th>
C_HTML += '               <th class = "cabtab" width="50" scope="col"> SEQ. </span></th>
C_HTML += '               <th class = "cabtab" width="50" scope="col"> PEDIDO </span></th>
C_HTML += '               <th class = "cabtab" width="60" scope="col"> PRODUTO </span></th>
C_HTML += '               <th class = "cabtab" width="50" scope="col"> LOTE </span></th>
C_HTML += '               <th class = "cabtab" width="60" scope="col"> QUANT. </span></th>
C_HTML += '               <th class = "cabtab" width="50" scope="col" > EMISSAO </span></th>
C_HTML += '            </tr>
Return

//---------------------------------------(GeraItmTb)----------------------------------
Static Function GeraItmTb()

C_HTML += " 			<tr align=center>
C_HTML += "                   <td class='style12' width='60'scope='col'>"+ALLTRIM(QRY->D2_DOC)			+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+ALLTRIM(QRY->D2_SERIE)		+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+ALLTRIM(QRY->D2_NUMSEQ)		+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+ALLTRIM(QRY->D2_PEDIDO)		+"</td>
C_HTML += "                   <td class='style12' width='60'scope='col'>"+ALLTRIM(QRY->D2_COD)			+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+ALLTRIM(QRY->D2_LOTECTL)		+"</td>
C_HTML += "                   <td class='style12' width='60'scope='col'>"+ Transform((QRY->D2_QUANT)	, "@E 999,999,999.99") 	+"</td>
C_HTML += "                   <td class='style12' width='50'scope='col'>"+DToC(SToD(QRY->D2_EMISSAO))	+"</td>
C_HTML += "             </tr>

Return

//---------------------------------------(GeraFooter)----------------------------------
Static Function GeraFooter()
	
	C_HTML +="	<div id='psdg-footer'> &nbsp </div>"

Return

//---------------------------------------(GeraFtrFim)----------------------------------
Static Function GeraFtrFim()
C_HTML += "     </table>
C_HTML += "		<table align='center' width='800' border='1' cellspacing='0' cellpadding='1'>
C_HTML += "            <tr>
C_HTML += "               <th class = 'tottab' width='600' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by BIA200).</th>
C_HTML += "			</tr>  
C_HTML += "		</table>
C_HTML += "      </body>
C_HTML += "   </html>

Return

//---------------------------------------(GeraSql)--------------------------------------
Static Function GeraSql()

cSQL := ""
cSql += " SELECT D2.D2_DOC, D2.D2_SERIE, D2.D2_NUMSEQ, D2.D2_EMISSAO, D2.D2_PEDIDO, D2.D2_CLIENTE, D2.D2_COD, D2.D2_LOTECTL, D2.D2_QUANT, D2.D2_YEMP
cSql += " FROM VW_SF2_EMP F2
cSql += " INNER JOIN VW_SD2_EMP D2 
cSql += " ON F2.F2_EMP = D2.D2_EMP AND F2.F2_DOC = D2.D2_DOC AND F2.F2_SERIE = D2.D2_SERIE
cSql += " WHERE	F2.F2_CLIENTE	= '010064'                                                              
cSql += " AND		F2.F2_EMP		= '"+cEmpAnt+"'                                                         
cSql += " AND		F2.F2_EMISSAO 	= '"+ dToS(dDataBase) + " ' 
cSql += " AND NOT EXISTS
cSql += " (
cSql += " 	SELECT * 
cSql += " 	FROM SF1070 F1
cSql += " 	WHERE  F1_DOC	=	F2_DOC
cSql += " 	AND    F1_SERIE = F2_SERIE
cSql += " 	AND	   F1.D_E_L_E_T_   = ''	
cSql += " )
cSql += " ORDER BY 4,5,6,8,9

/*
cSql += " SELECT D2.D2_DOC, D2.D2_SERIE, D2.D2_NUMSEQ, D2.D2_EMISSAO, D2.D2_PEDIDO, D2.D2_CLIENTE, D2.D2_COD, D2.D2_LOTECTL, D2.D2_QUANT, D2.D2_YEMP, "
cSql += " 		C5.*,                                                                                       "
cSql += " 		LC5.C5_NUM, LC5.C5_CLIENTE, LC5.C5_YPEDORI, LC5.C5_YCLIORI,                                 "
cSql += " 		LD1.D1_FORNECE, LD1.D1_COD, LD1.D1_LOTECTL, LD1.D1_QUANT, LD1.D1_YEMPPED                    "
cSql += " FROM VW_SD2_EMP D2 WITH (NOLOCK)                                                                  "
cSql += " INNER JOIN                                                                                        "
cSql += " (                                                                                                 "
cSql += "  SELECT '01' C5_EMP,C5_NUM, C5_CLIENTE, C5_YPEDORI, C5_YCLIORI FROM SC5010 WHERE D_E_L_E_T_ = ''  "
cSql += "  UNION ALL                                                                                        "
cSql += "  SELECT '05' C5_EMP, C5_NUM, C5_CLIENTE, C5_YPEDORI, C5_YCLIORI FROM SC5050 WHERE D_E_L_E_T_ = '' "
cSql += "  UNION ALL                                                                                        "
cSql += "  SELECT '13' C5_EMP,C5_NUM, C5_CLIENTE, C5_YPEDORI, C5_YCLIORI FROM SC5130 WHERE D_E_L_E_T_ = ''  "
cSql += "  ) C5                                                                                             "
cSql += " ON  D2.D2_PEDIDO	= C5.C5_NUM                                                                 	"
cSql += " AND D2.D2_EMP		= C5.C5_EMP                                                                     "
cSql += " AND D2.D2_CLIENTE	= C5.C5_CLIENTE                                                                 "
cSql += " LEFT JOIN SC5070 LC5                                                                              "
cSql += " ON  LC5.C5_CLIENTE	= C5.C5_YCLIORI                                                             "
cSql += " AND LC5.C5_YPEDORI  	= C5.C5_NUM                                                                 "
cSql += " AND LC5.D_E_L_E_T_	= ''                                                                        "
cSql += " LEFT JOIN VW_SD1_EMP LD1 WITH(NOLOCK)                                                             "
cSql += " ON	LD1.D1_PEDIDO	= LC5.C5_NUM                                                                "
cSql += " AND LD1.D1_FORNECE	= LC5.C5_CLIENTE                                                            "
cSql += " AND LD1.D1_COD		= D2.D2_COD                                                                 "
cSql += " AND LD1.D1_LOTECTL  	= D2.D2_LOTECTL                                                             "
cSql += " AND LD1.D1_QUANT		= D2.D2_QUANT                                                               "
cSql += " AND LD1.D1_YEMPPED	= D2.D2_YEMP                                                                "
cSql += " WHERE		D2.D2_CLIENTE	= '010064'                                                              "
cSql += " AND		D2.D2_EMP		= '"+cEmpAnt+"'                                                         "
cSql += " AND		D2.D2_EMISSAO 	= '"+ dToS(dDataBase) + " ' 											"
cSql += " AND		D2.D2_YRESULT	= 'S'                                                                   "
cSql += " AND		LD1.D1_COD	IS NULL                                                                     "
cSql += " ORDER BY 4,5,6,8,9
*/
Return cSQL
