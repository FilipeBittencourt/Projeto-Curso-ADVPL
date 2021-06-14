#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

//--------------------------------------------------------------------------------------------
//								*** WF DE PEDIDOS FATURADOS DO MARKETING - SHOWROOM ***
//--------------------------------------------------------------------------------------------
// Solcitante: Patelli
// Desenvolv.: Thiago Dantas
// Data: 02/12/2014 
//--------------------------------------------------------------------------------------------
// Listagem dos pedidos que foram faturados para o Showroom
//--------------------------------------------------------------------------------------------
User Function BIA228()
	Local lEnvia := .F.
	Private cMensagem := ''
	Private lOK := .F.
	Private lSexta := .F.
	Private lErro := .F.
	Private cERRO := ''
	Private cMensag := ''
	Private cMens := ''
	Private nItemPrd := 0
	Private cEmail := ''
	Private Enter := CHR(13)+CHR(10)
	Private C_HTML := ''
	Private lDebug := .F.	
	Private lShowroom := .F.
	Private lAmostra := .F.

	If lDebug

		RpcSetType(3)
		RpcSetEnv("01", "01")

		lDebug := .T.

		DbSelectArea("SF2")
		DbSetOrder(1)
		DbSeek(xFilial("SF2")+'000357951'+'1')

	EndIf

	DbSelectArea("SD2")
	DbSetOrder(3)
	If DbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)

		DbSelectArea("SC5")
		DbSetOrder(1)
		If DbSeek(xFilial("SC5") + SD2->D2_PEDIDO)						

			If AllTrim(SC5->C5_YSUBTP) == "A" .And. AllTrim(SC5->C5_YITEMCT) == "I0103"

				lShowroom := .T.

			ElseIf AllTrim(SC5->C5_YSUBTP) $ "A/M" .And. AllTrim(SC5->C5_YITEMCT) <> "I0103"

				lAmostra := .T.

			EndIf

			//Gera cabeçalho HTML
			GeraCab()

			GeraCabCls()

			//Verifica se os pedidos da NF são de SHOWROOM / AMOSTRA
			While !SD2->(Eof()) .And. SF2->F2_DOC == SD2->D2_DOC .And. SF2->F2_SERIE == SD2->D2_SERIE .And. SF2->F2_CLIENTE == SD2->D2_CLIENTE .And. SF2->F2_LOJA == SD2->D2_LOJA

				// Enviar p vendedor do pedido e filtrar pelos campos: C5_YSUBTP == 'A', 'M' .And. C5_YITEMCT <> 'I0103'

				// Se for de ShowRoom ou Amostra
				If lShowroom .Or. lAmostra 

					GeraItmTb()

					lEnvia := .T.

				EndIf

				SD2->(DbSkip())	

			EndDo

			SD2->(DbCloseArea())

			If lEnvia

				GeraFtrFim()

				Enviar()

			EndIf

		EndIf

	EndIf

	If lDebug

		RpcClearEnv()

	EndIf

Return()


Static Function Enviar()

	If lDebug

		cDest := "tiago@facilesistemas.com.br;"
		cDest += fRetMailVend(SC5->C5_CLIENTE, SC5->C5_VEND1)

	ElseIf lShowroom

		cDest := U_EmailWF('BIA228', cEmpAnt)

	ElseIf lAmostra

		cDest := fRetMailVend(SC5->C5_CLIENTE, SC5->C5_VEND1)

	EndIf

	Envioemail(cDest)

	cMensag := ''
	cMens := ''
	nItemPrd := 0

Return()


Static Function Envioemail(cEmail)
  					  		
	cRecebe := cEmail														 		
	cRecebeCC	:= ""  												 			
	cRecebeCO	:= ""			  								 					
	cAssunto := 'Relação de Pedidos Faturados ' + If (lShowroom, 'do Showroom', 'de Amostra')

	cMensag := ""
	cMensag += C_HTML	
	cArqAnexo := ""

	U_BIAEnvMail(, cRecebe, cAssunto, cMensag, "", cArqAnexo, , cRecebeCC)

Return()


Static Function GeraCab()

	C_HTML := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
	C_HTML += '   <html xmlns="http://www.w3.org/1999/xhtml">
	C_HTML += '      <head>
	C_HTML += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	C_HTML += '         <title>Producao</title>
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
	C_HTML += '         <table align="center" width="800" class = "headProd">
	C_HTML += '               <tr>
	C_HTML += '                  <div align="left">
	C_HTML += "                  <th width='694' scope='col'> NF FATURADA - " + If (lShowroom, "SHOWROOM", "AMOSTRA") + "</th>
	C_HTML += '					 </div>
	C_HTML += '               </tr>
	C_HTML += '         </table>
	C_HTML += '         <table align="center" width="800" class = "headProd">
	C_HTML += '               <th class = "cabtab" width="10" scope="col"> SERIE </span></th>
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> NF </span></th>
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> CLIENTE </span></th>
	C_HTML += '               <th class = "cabtab" width="100" scope="col"> NOME CLIENTE </span></th>
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> TRANSP. </span></th>
	C_HTML += '               <th class = "cabtab" width="100" scope="col"> DESC TRANSP. </span></th>

	C_HTML += '            </tr>
	C_HTML += '            <tr align=center>
	C_HTML += '               <th class = "style12" width="10" scope="col"> '+SF2->F2_SERIE+' </span></th>
	C_HTML += '               <th class = "style12" width="50" scope="col"> '+SF2->F2_DOC+' </span></th>
	C_HTML += '               <th class = "style12" width="50" scope="col"> '+SF2->F2_CLIENTE+' </span></th>

	If Empty(AllTrim(SC5->C5_YCLIORI))
	C_HTML += '				  <th class = "style12" width="100" scope="col"> '+Alltrim(POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")) +' </span></th>
	Else
	C_HTML += '				  <th class = "style12" width="100" scope="col"> '+Alltrim(POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_YCLIORI+SC5->C5_YLOJORI,"A1_NOME")) +' </span></th>
	EndIf

	C_HTML += '               <th class = "style12" width="50" scope="col"> '+SF2->F2_TRANSP+' </span></th>
	C_HTML += '				  <th class = "style12" width="100" scope="col"> '+Alltrim(POSICIONE("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME")) +' </span></th>

	C_HTML += '            </tr>
	C_HTML += '         </table>


	Return()


	Static Function GeraCabCls()
//ADICIONADO COLUNA ORDEM COMPRA CAMPO C5_YPC - TICKET 32584
	C_HTML += '         <table align="center" width="800" class = "headProd">
	C_HTML += '               <tr>
	C_HTML += '                  <div align="left">
	C_HTML += "                  <th width='694' scope='col'> PEDIDOS </th>
	C_HTML += '					 </div>
	C_HTML += '               </tr>
	C_HTML += '         </table>
	C_HTML += '         <table align="center" width="800" border="1" cellspacing="0" cellpadding="1">
	C_HTML += '            <tr align=center>
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> PEDIDO </span></th>
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> ORDEM COMPRA </span></th>
	C_HTML += '               <th class = "cabtab" width="10" scope="col"> ITEM </span></th>
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> PRODUTO </span></th>
	C_HTML += '               <th class = "cabtab" width="100" scope="col"> DESCRICAO </span></th>
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> QUANTIDADE </span></th>
	C_HTML += '            </tr>

	Return()


	Static Function GeraItmTb()

	C_HTML += " 			<tr align=center>
	C_HTML += "                   <td class='style12' width='50'scope='col'>"  +ALLTRIM(SD2->D2_PEDIDO)		+"</td>
	C_HTML += "                   <td class='style12' width='50'scope='col'>"  +ALLTRIM(SC5->C5_YPC)		+"</td>
	C_HTML += "                   <td class='style12' width='10'scope='col'>"  +ALLTRIM(SD2->D2_ITEM)		+"</td>
	C_HTML += "                   <td class='style12' width='50'scope='col'>"  +ALLTRIM(SD2->D2_COD)		+"</td>
	C_HTML += "                   <td class='style12' width='100'scope='col'>" +Alltrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")) +"</td>
	C_HTML += "                   <td class='style12' width='50'scope='col'>"  +Transform(SD2->D2_QUANT, "@E 999,999.99" )		+"</td>
	C_HTML += "            	</tr>

	Return()


	Static Function GeraFtrFim()

	C_HTML += "     </table>
	C_HTML += "		<table align='center' width='800' border='1' cellspacing='0' cellpadding='1'>
	C_HTML += "            <tr>
	C_HTML += "               <th class = 'tottab' width='600' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by BIA228).</th>
	C_HTML += "			</tr>  
	C_HTML += "		</table>
	C_HTML += "      </body>
	C_HTML += "   </html>

	Return()


	Static Function fRetMailVend(cCliente, cVendedor)
	Local cRet := ""
	Local cVend := ""
	Local cSQL := ""
	Local cQry := ""

	If cCliente == "010064"

	cSQL := " SELECT TOP 1 C5_VEND1 "
	cSQL += " FROM " + RetFullName("SC5", "07")
	cSQL += " WHERE C5_YPEDORI = " + ValToSQL(cNumero)
	cSQL += " AND C5_YEMPPED = " + ValToSQL(cEmpAnt)
	cSQL += " AND D_E_L_E_T_ = ''

	cQry := GetNextAlias()

	TcQuery cSQL New Alias (cQry)

	cVend := (cQry)->C5_VEND1

	(cQry)->(dbCloseArea())

	Else

	cVend := cVendedor

	EndIf

	If !Empty(cVend)

	cRet := AllTrim(Posicione("SA3", 1, xFilial("SA3") + cVend, "A3_EMAIL"))

	EndIf

	Return(cRet)
