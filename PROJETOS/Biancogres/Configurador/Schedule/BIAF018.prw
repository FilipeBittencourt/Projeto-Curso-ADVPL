#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

/*
|------------------------------------------------------------|
| Função:	| BIAF018																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 19/05/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Workflow de recebimento antecipado 							 |
| 				| informa os tiulos provisorios que deverao ser 	 |
| 				| excluidos do banco, referente ao pedido de venda |
| 				| deletado 																				 |
|------------------------------------------------------------|
| OS:			|	XXXX-XX - Usuário: Vagner Amaro   		 			 		 |
|------------------------------------------------------------|
*/

User Function BIAF018(cNumPed, cCliOri)
Local aArea := GetArea()
Private cMensag := ''
Private cEmail := ''
Private cQrySE1 := GetNextAlias()

	Default cNumPed := SC5->C5_NUM
	Default cCliOri := SC5->C5_YCLIORI
	
	GeraWF(cNumPed, cCliOri)
	
	RestArea(aArea)

Return()


//---------------------------------------(GeraWF)----------------------------------
Static Function GeraWF(cNumPed, cCliOri)
Private C_HTML := ''

	GeraHTML(cNumPed, cCliOri)

Return


//---------------------------------------(GeraHTML)----------------------------------
Static Function GeraHTML(cNumPed, cCliOri)
Local cEmpPed := cEmpAnt

	If GetData(cNumPed, cCliOri, @cEmpPed)
                                             
		GeraCab()
		GeraCabCls()
		GeraItmTb(cEmpPed)
		GeraFtrFim()
		Enviar()
		
		// Fecha query 
		(cQrySE1)->(DbCloseArea())
		
	EndIf

Return()


Static Function GetData(cNumPed, cCliOri, cEmpPed)
Local lRet := .F.
Local cSQL := ""
Local cQryLM := GetNextAlias()
Local cSC5 := If (!Empty(cCliOri), "SC5070", RetSQLName("SE1"))
Local cSE1 := If (!Empty(cCliOri), "SE1070", RetSQLName("SE1"))

	// Busca pedido de origem na LM
	If cEmpAnt $ '01_05_13_14' .And. !Empty(cCliOri)
	
		cSQL := " SELECT C5_NUM "
		cSQL += " FROM SC5070 "
		cSQL += " WHERE C5_YPEDORI = "+ ValToSQL(cNumPed)
		cSQL += " AND C5_YEMPPED = "+ ValToSQL(cEmpAnt)
		cSQL += " AND D_E_L_E_T_ = '' "
	
		TcQuery cSQL New Alias (cQryLM)
						
		If !Empty((cQryLM)->C5_NUM)
			cNumPed := (cQryLM)->C5_NUM
			cEmpPed := "07"
		EndIf
		
		(cQryLM)->(DbCloseArea())

	EndIf
	
	
	// Busca informações do titulo provisorio 
	cSQL := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCTO, E1_PEDIDO "
	cSQL += " FROM " + cSE1
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND SUBSTRING(E1_PREFIXO, 1, 2) IN ('PR', 'CT')	"
	cSQL += " AND SUBSTRING(E1_PREFIXO, 3, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9') "
	cSQL += " AND E1_TIPO = 'BOL' "
	cSQL += " AND E1_PEDIDO = " + ValToSQL(cNumPed)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQrySE1)
					
	lRet := !Empty((cQrySE1)->E1_PREFIXO)	

Return(lRet)


//---------------------------------------(Enviar)----------------------------------
Static Function Enviar()
	
	cDest := U_EmailWF('BIAF018', cEmpAnt)
	Envioemail(cDest)
	
Return()


//---------------------------------------(Envioemail)----------------------------------
Static Function Envioemail(cEmail)
	  					  		
	cRecebe := cEmail
	cRecebeCC	:= ""
	cRecebeCO	:= ""
	
	If SubStr((cQrySE1)->E1_PREFIXO, 1, 2) == "PR"
		cAssunto := 'Pedido de venda com recebimento antecipado - EXCLUÍDO'
	ElseIf SubStr((cQrySE1)->E1_PREFIXO, 1, 2) == "CT"
		cAssunto := 'Pedido de venda de contrato - EXCLUÍDO'
	Else
		cAssunto := 'NDA'
	EndIf
	
	cMensag += C_HTML
	cArqAnexo := ''
	
	U_BIAEnvMail(,cRecebe,cAssunto,cMensag,'',cArqAnexo,,cRecebeCC)       

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
	C_HTML += "                  <th width='1200' scope='col'> Título a Receber</th>
	C_HTML += '					 </div>
	C_HTML += '               </tr>
	C_HTML += '         </table>
	C_HTML += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">
	C_HTML += '            <tr align=center>
	C_HTML += '               <th class = "cabtab" width="200" scope="col"> Empresa </th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Prefixo </th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Número </th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Parcela </th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Tipo </th>
	C_HTML += '               <th class = "cabtab" width="200" scope="col"> Cliente </th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Dt. Emissão </th>
	C_HTML += '               <th class = "cabtab" width="80" scope="col"> Dt. Vencto </th>
	C_HTML += '               <th class = "cabtab" width="80" scope="col"> Pedido de Venda </th>
	C_HTML += '            </tr>
	
Return()


//---------------------------------------(GeraItmTb)----------------------------------
Static Function GeraItmTb(cEmpPed)
Local cEmpName := ""

	If cEmpPed = "01"	
		cEmpName := "BIANCOGRES CERÂMICA'	
	ElseIf cEmpPed $ "05"
		cEmpName := "INCESA CERAMICA LTDA"
	ElseIf cEmpPed $ "07"
		cEmpName := "LM COMÉRCIO"
	ElseIf cEmpPed = "05"
		cEmpName := "BELLACASA CERAMICA"
	ElseIf cEmpPed = "13"
		cEmpName := "MUNDI"
	ElseIf cEmpPed = "14"
		cEmpName := "VITCER"
	EndIf		

	C_HTML += " 			<tr align=center>
	C_HTML += "                   <td class='style12' width='200'scope='col'>"+ cEmpName +"</td>
	C_HTML += "                   <td class='style12' width='60'scope='col'>"+ AllTrim((cQrySE1)->E1_PREFIXO) +"</td>
	C_HTML += "                   <td class='style12' width='60'scope='col'>"+ AllTrim((cQrySE1)->E1_NUM) +"</td>
	C_HTML += "                   <td class='style12' width='60'scope='col'>"+ AllTrim((cQrySE1)->E1_PARCELA) +"</td>
	C_HTML += "                   <td class='style12' width='60'scope='col'>"+ AllTrim((cQrySE1)->E1_TIPO) +"</td>
	C_HTML += "                   <td class='style12' width='200'scope='col'>"+ AllTrim((cQrySE1)->E1_CLIENTE) +"-"+ (cQrySE1)->E1_LOJA +"-"+ AllTrim((cQrySE1)->E1_NOMCLI) +"</td>
	C_HTML += "                   <td class='style12' width='60'scope='col'>"+ dToC(sToD((cQrySE1)->E1_EMISSAO)) +"</td>
	C_HTML += "                   <td class='style12' width='80'scope='col'>"+ dToC(sToD((cQrySE1)->E1_VENCTO)) +"</td>
	C_HTML += "                   <td class='style12' width='80'scope='col'>"+ (cQrySE1)->E1_PEDIDO +"</td>
	C_HTML += "             </tr>
	C_HTML += '         </table>

Return()



//---------------------------------------(GeraFtrFim)----------------------------------
Static Function GeraFtrFim()

	C_HTML += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>
	C_HTML += "            <tr>
	C_HTML += "               <th class = 'tottab' width='600' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by BIAF018).</th>
	C_HTML += "			</tr>  
	C_HTML += "		</table>
	C_HTML += "      </body>
	C_HTML += "   </html>
	C_HTML += "   </html>

Return()