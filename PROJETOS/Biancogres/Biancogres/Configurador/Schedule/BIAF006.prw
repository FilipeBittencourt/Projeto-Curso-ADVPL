#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
|------------------------------------------------------------|
| Função:	| BIAF006																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 02/09/14																				 |
|------------------------------------------------------------|
| Desc.:	|	Workflow de estrutura de produtos  						   |
|------------------------------------------------------------|
| OS:			|	0672-14 - Usuário: Vinicius de Arruda  		 			 |
|------------------------------------------------------------|
*/

User Function BIAF006(nPar)
Local aArea := GetArea()
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
Private nOpc := nPar

	GeraWF()
	
	RestArea(aArea)

Return()


//---------------------------------------(GeraWF)----------------------------------
Static Function GeraWF()
Private C_HTML		:= ''

	GeraHTML()

Return


//---------------------------------------(GeraHTML)----------------------------------
Static Function GeraHTML()

	GeraCab()
	GeraCabCls()
	GeraItmTb()
	GeraFtrFim()
	Enviar()

Return()


//---------------------------------------(Enviar)----------------------------------
Static Function Enviar()
	
	cDest := U_EmailWF('BIAF006', cEmpAnt)
	Envioemail(cDest)
	
Return()


//---------------------------------------(Envioemail)----------------------------------
Static Function Envioemail(cEmail)
  					  		
	cRecebe := cEmail														 		
	cRecebeCC	:= ""  												 			
	cRecebeCO	:= ""			  								 					
	cAssunto := If (nOpc == 3, "Inclusão", If (nOpc == 4, "Alteração", "Exclusão"))+ " de estrutura de Produto"
		
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

	C_HTML += '         <table align="center" width="800" class = "headProd">
	C_HTML += '               <tr>
	C_HTML += '                  <div align="left">
	C_HTML += "                  <th width='800' scope='col'> Estrutura do Produto</th>
	C_HTML += '					 </div>
	C_HTML += '               </tr>
	C_HTML += '         </table>
	C_HTML += '         <table align="center" width="800" border="1" cellspacing="0" cellpadding="1">
	C_HTML += '            <tr align=center>
	C_HTML += '               <th class = "cabtab" width="200" scope="col"> Empresa </th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Código </th>
	C_HTML += '               <th class = "cabtab" width="200" scope="col"> Descrição </th>
	C_HTML += '               <th class = "cabtab" width="40" scope="col"> Unidade </th>
	C_HTML += '               <th class = "cabtab" width="40" scope="col"> Revisão </th>
	C_HTML += '            </tr>
	
Return()


//---------------------------------------(GeraItmTb)----------------------------------
Static Function GeraItmTb()
	
	C_HTML += " 			<tr align=center>
	C_HTML += "                   <td class='style12' width='200'scope='col'>"+ AllTrim(SM0->M0_NOMECOM) +"</td>
	C_HTML += "                   <td class='style12' width='60'scope='col'>"+ AllTrim(cProduto) +"</td>
	C_HTML += "                   <td class='style12' width='200'scope='col'>"+ AllTrim(Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_DESC")) +"</td>
	C_HTML += "                   <td class='style12' width='40'scope='col'>"+ AllTrim(cUm) +"</td>	
	C_HTML += "                   <td class='style12' width='40'scope='col'>"+ AllTrim(cRevisao) +"</td>
	C_HTML += "             </tr>
	C_HTML += '         </table>

Return()



//---------------------------------------(GeraFtrFim)----------------------------------
Static Function GeraFtrFim()

	C_HTML += "		<table align='center' width='800' border='1' cellspacing='0' cellpadding='1'>
	C_HTML += "            <tr>
	C_HTML += "               <th class = 'tottab' width='600' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by BIAF006).</th>
	C_HTML += "			</tr>  
	C_HTML += "		</table>
	C_HTML += "      </body>
	C_HTML += "   </html>
	C_HTML += "   </html>

Return()