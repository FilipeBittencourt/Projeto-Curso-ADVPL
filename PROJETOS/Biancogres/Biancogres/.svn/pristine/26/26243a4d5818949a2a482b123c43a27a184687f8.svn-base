#include "rwmake.ch"
#include "TOPCONN.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FA080TIT ³ Autor ³ Carlos Alberto        ³ Data ³ 10/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ponto de Entrada em FA080TIT                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FA080TIT()
LOCAL lRet	:= .T.
LOCAL cQUERY := ""

//Este programa tem a finalidade de Validar os titulos a serem baixados
//Analisa o campo E2_YSTATUS
//1- Nao permitir a baixa de titulos Bloqueados (E2_YSTATUS = B)
//2- Nao permitir a baixa de titulos com valor acima do previsto. buscar o codigo do processo
//no titulo para btrazer todas as despesas do processo (EET).
/*
If SE2->E2_YPROCEX <> ' '
NDOC := E2_YSTATUS
IF NDOC = 'B' // Se o titulo esta bloqueado, nao e possivel fazr a baixa
Alert("Nao e possível baixar este titulo, pois o mesmo não está liberado! ")
Return .F.
Else
//Return .T.
end if
End if
*/

	// Projeto Automacao Financeira - Desconsidera validacoes via execucao em JOB
	If !IsBlind()

		// ROTINA PARA  VALIDAR A DATA DA BAIXA COM O PARAMETRO MV_DATAFIM
		If DBAIXA <= GETMV("MV_DATAFIN")       
			MsgBox("Nao e permitida o cancelamento de baixa, com data anterior a "+Dtoc(GetMv("MV_DATAFIN"))+". ","DATA INVALIDA","INFO")
			lRet := .F.
			Return(lRet)
		EndIf
		
		If cEmpAnt == "02"
			Return(lRet)
		EndIf
		
		// Tiago Rossini Coradini - OS 2422-15 - Mikaely
		If dBaixa <> dDebito
			
			If !MsgYesNo("Atenção, a data de pagamento ("+ dToC(dBaixa) +") é diferente da data de débito ("+ dToC(dDebito) +")."+ Chr(13) + "Deseja confirmar a baixa?")
				lRet := .F.
				Return(lRet)
			EndIf
			
		EndIf	
	
	
		If SE2->E2_TIPO <> 'PA' .AND. SE2->E2_TIPO <> 'NDF' .AND. SE2->E2_YBLQ <> 'XX'
			
			// INFORMANDO QUANDO PA EM ABERTO
			Enter := chr(13) + Chr(10)
			cQUERY := "SELECT COUNT(E2_FORNECE) AS cCONT FROM "+RETSQLNAME("SE2")+" " + ENTER
			cQUERY += " WHERE 	E2_FORNECE = '"+SE2->E2_FORNECE+"' AND " + ENTER
			cQUERY += "			E2_LOJA		 = '"+SE2->E2_LOJA+"'	AND " + ENTER	
			cQUERY += "			E2_TIPO    IN('PA','NDF') AND " + ENTER
			cQUERY += "			E2_SALDO   <> 0 AND " + ENTER
			cQUERY += "			D_E_L_E_T_ = '' " + ENTER
			
			If chkfile("_QUANT")
				dbSelectArea("_QUANT")
				dbCloseArea()
			EndIf
			
			TCQUERY cQUERY ALIAS "_QUANT" NEW
			
			If _QUANT->cCONT <> 0 .AND. CEMPANT <> "02"
				
				//cMens := "O TITULO/FORNECEDOR DESCRITO ABAIXO POSSUI PA EM ABERTO!" +chr(13)
				cMens := "O Título descrito abaixo possui PA/NDF em aberto. Favor solicitar a liberação de um Diretor/Gerente para realizar esta baixa! " +chr(13)
				cMens += chr(13)
				cMens += "Número do Título: " + SE2->E2_NUM + chr(13)
				cMens += "Cod Fornecedor: " + SE2->E2_FORNECE + chr(13)
				cMens += "Nome Fornecedor: " + SE2->E2_NOMFOR + chr(13)
				cMens += chr(13)
				cMens += "ESTA BAIXA SERÁ REALIZADA APÓS LIBERAÇÃO!"
				
				If MsgYesNo(cMens,OemToAnsi('ATENCAO'))
					lRet := .F.
				Else
					lRet := .F.
				EndIf
				
				//ATUALIZANDO O CAMPO PARA BLOQUEAR O TITULO
				nRegSE2 := ALLTRIM(STR( SE2->(RecNo()) ))
				CSQL := " UPDATE "+RETSQLNAME("SE2")+" SET E2_YBLQ = '01' WHERE R_E_C_N_O_ = '"+nRegSE2+"' "
				TCSQLExec(CSQL)  
				
				GeraHtml()
				
			EndIf
			
		EndIf
			
		If SE2->E2_YBLQ <> 'XX' .And. Alltrim(SE2->E2_TIPO) <> 'PA' .And. SE2->E2_TIPO <> 'NDF' .And. U_BIAF076()	
			cRetorno := .F.
		EndIf
		
	EndIf

Return(lRet)


Static Function GeraHtml()        

// ENVIANCO EMAIL PARA OS RESPONSAVEIS PELO FINANCEIRO
C_TITULO 	:= "Titulo do Contas a Pagar Bloqueado"

//C_DESTI		:= "enelcio.araujo@biancogres.com.br;gardenia.stelzer@biancogres.com.br"
C_DESTI		:= "gardenia.stelzer@biancogres.com.br"
                                                                

C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
C_HTML += '<head> '
C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
C_HTML += '<title>Untitled Document</title> '
C_HTML += '<style type="text/css"> '
C_HTML += '<!-- '
C_HTML += '.style12 {font-size: 9px; } '
C_HTML += '.style21 {color: #FFFFFF; font-size: 9px; } '
C_HTML += '--> '
C_HTML += '</style> '
C_HTML += '</head> '
C_HTML += ' '
C_HTML += '<body> '
	 
//CABECALHO	
C_HTML += '<table width="900" border="0" bgcolor="black"> '
//C_HTML += '<table width="900" border="0" > '
C_HTML += '  <tr> '                                        
C_HTML += '<font color="white"> '
	
DO CASE
   CASE cEmpAnt = "01"
		C_HTML += '  <th scope="col"> TITULO À PAGAR BLOQUEADO NA EMPRESA BIANCOGRES <br>'			
 	CASE cEmpAnt = "05"   
 		C_HTML += '  <th scope="col"> TITULO À PAGAR BLOQUEADO NA EMPRESA INCESA <br>'			
       OTHERWISE
		C_HTML += '  <th scope="col"> TITULO À PAGAR BLOQUEADO <br>'			
ENDCASE                        

C_HTML += '</font>'            
C_HTML += '</tr> '             
C_HTML += '</table> ' 

//DADOS 
C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2" bgcolor="#7A67EE"> '
//C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2" bgcolor="#6495ED"> '
C_HTML += '<font color="white"> '                          
C_HTML += '<tr> '
C_HTML += '    <th width="900" scope="col"> DADOS DO TITULO:  </th> '
C_HTML += '  </tr> '
C_HTML += '</font>'        
C_HTML += '</table> '        

C_HTML += '<table width="900" border="1" cellspacing="0" cellpadding="2"> '
C_HTML += '<font color="black" size="2"> '              

C_HTML += '<tr> '
C_HTML += '    <td><div align="left"> NÚMERO DO TITULO: <b>'+SE2->E2_NUM+'</b></td> '
C_HTML += '  </tr> '  
C_HTML += '<tr> '
C_HTML += '    <td><div align="left"> CÓDIGO DO FORNECEDOR: <b>'+Alltrim(SE2->E2_FORNECE)+'</b></td> '
C_HTML += '  </tr> ' 
C_HTML += '<tr> '
C_HTML += '    <td><div align="left"> LOJA DO FORNECEDOR: <b>'+Alltrim(SE2->E2_LOJA)+'</b></td> '
C_HTML += '  </tr> ' 
C_HTML += '<tr> '
C_HTML += '    <td><div align="left"> NOME DO FORNECEDOR: <b>'+Alltrim(SE2->E2_NOMFOR)+'</b></td> '
C_HTML += '  </tr> '
C_HTML += '<tr> '
C_HTML += '    <td><div align="left"> VALOR DO TITULO: <b>'+Transform(SE2->E2_VALOR,"@E 999,999,999.99")+'</b></td> '
C_HTML += '  </tr> '
C_HTML += '<tr> '
C_HTML += '    <td><div align="left"> SALDO DO TITULO: <b>'+Transform(SE2->E2_SALDO,"@E 999,999,999.99")+'</b></td> '
C_HTML += '  </tr> '

C_HTML += '</font>'        
C_HTML += '</table> '   

C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder.</b></u> '     
C_HTML += '<p>&nbsp;	</p> '
C_HTML += '</body> '
C_HTML += '</html> '

U_BIAEnvMail(,C_DESTI,C_TITULO,C_HTML)

Return