#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
|------------------------------------------------------------|
| Função:	| BIAF021																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 08/06/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Workflow para informar aos representantes os		 |
| 				| pedidos de venda com recebimento antecipado e 	 |
| 				| seus respectivos boletos 												 |
|------------------------------------------------------------|
| OS:			|	XXXX-XX - Usuário: Vagner amaro   		 			 		 |
|------------------------------------------------------------|
*/

User Function BIAF021(cNumPed, cDest, cNumBol)
Local aArea := SE1->(GetArea())
Private _cMensag := ''
Private cEmail := cDest
Private cBoleto := cNumBol
	
	// desliga envio do ambiente teste FAVARO
	cServerIP:=strTran(getServerIP(),".","")
	IF cServerIP=="1921682018"
		Return()
	EndIf

	GeraWF(cNumPed)
	
	RestArea(aArea)

Return()


//---------------------------------------(GeraWF)----------------------------------
Static Function GeraWF(cNumPed)
Private C_HTML := ''

	GeraHTML(cNumPed)

Return


//---------------------------------------(GeraHTML)----------------------------------
Static Function GeraHTML(cNumPed)

	If GetData(cNumPed)

		GeraCab()
		GeraCabCls()
		GeraItmTb()
		GeraFtrFim()
		Enviar()
		
	EndIf

Return()


Static Function GetData(cNumPed)
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSE1 := RetSQLName("SE1")

	cSQL := " SELECT R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + cSE1
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	//cSQL += " AND SUBSTRING(E1_PREFIXO, 1, 2) = 'PR' "
	cSQL += " AND E1_TIPO = 'BOL' "
	cSQL += " AND E1_PEDIDO = " + ValToSQL(cNumPed)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
					
	If lRet := (cQry)->(RECNO) > 0
		
		DbSelectArea("SE1")
		
		DbGoTo((cQry)->(RECNO))
		
	EndIf
	
	(cQry)->(DbCloseArea())

Return(lRet)


//---------------------------------------(Enviar)----------------------------------
Static Function Enviar()

	Envioemail()
	
Return()


//---------------------------------------(Envioemail)----------------------------------
Static Function Envioemail()

	_cRecebe := cEmail
	_cRecebeCC	:= ""
	_cRecebeCO	:= ""
	
	If SubStr(SE1->E1_PREFIXO, 1, 2) == "PR"
		_cAssunto := 'Pedido de venda com recebimento antecipado'
	ElseIf SubStr(SE1->E1_PREFIXO, 1, 2) == "CT"
		_cAssunto := 'Pedido de venda de contrato'
	EndIf
	
	_cMensag += C_HTML
	_cArqAnexo := cBoleto
	
	lok := U_BIAEnvMail(,_cRecebe,_cAssunto,_cMensag,'',_cArqAnexo,,_cRecebeCC)

Return()


//---------------------------------------(GeraCab)----------------------------------
Static Function GeraCab()

	C_HTML := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
	C_HTML += '   <html xmlns="http://www.w3.org/1999/xhtml">
	C_HTML += '      <head>
	C_HTML += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	C_HTML += '         <title>cabtitpag</title>
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

Return()


//---------------------------------------(GeraCabCls)----------------------------------
Static Function GeraCabCls()

	C_HTML += '         <table align="center" width="1200" class = "headProd">
	C_HTML += '               <tr>
	C_HTML += '                  <div align="left">
	C_HTML += "                  <th width='1200' scope='col'> Pedido de Venda </th>
	C_HTML += '					 </div>
	C_HTML += '               </tr>
	C_HTML += '         </table>
	C_HTML += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">
	C_HTML += '            <tr align=center>
	C_HTML += '               <th class = "cabtab" width="200" scope="col"> Empresa </th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Pedido de Venda </th>
	C_HTML += '               <th class = "cabtab" width="200" scope="col"> Cliente </th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Dt. Emissão </th>
	//C_HTML += '               <th class = "cabtab" width="60" scope="col"> Dt. Vencto </th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Valor </th>
	C_HTML += '            </tr>
	
Return()


//---------------------------------------(GeraItmTb)----------------------------------
Static Function GeraItmTb()

	C_HTML += " 			<tr align=center>
	C_HTML += "                   <td class='style12' width='200'scope='col'>"+ AllTrim(SM0->M0_NOMECOM) +"</td>
	C_HTML += "                   <td class='style12' width='80'scope='col'>"+ SE1->E1_PEDIDO +"</td>
	C_HTML += "                   <td class='style12' width='200'scope='col'>"+ AllTrim(SE1->E1_CLIENTE) +"-"+ SE1->E1_LOJA +"-"+ AllTrim(SE1->E1_NOMCLI) +"</td>
	C_HTML += "                   <td class='style12' width='60'scope='col'>"+ DToC(SE1->E1_EMISSAO) +"</td>
	//C_HTML += "                   <td class='style12' width='80'scope='col'>"+ DToC(SE1->E1_VENCTO) +"</td>
	C_HTML += "                   <td class='style12' width='80'scope='col'>"+ Transform(SE1->E1_VALOR, "@E 999,999,999.99") +"</td>
	C_HTML += "             </tr>
	C_HTML += '         </table>

Return()



//---------------------------------------(GeraFtrFim)----------------------------------
Static Function GeraFtrFim()

	C_HTML += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>
	C_HTML += "            <tr>
	C_HTML += "               <th class = 'tottab' width='300' scope='col'> Segue em anexo boleto(s) bancário(s).</th>
	C_HTML += "               <th class = 'tottab' width='300' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by BIAF021).</th>
	C_HTML += "			</tr>  
	C_HTML += "		</table>
	C_HTML += "      </body>
	C_HTML += "   </html>
	C_HTML += "   </html>

Return()
