#Include "RwMake.ch"
#include "TOPCONN.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ 	F090TIT     ³ Autor ³BRUNO MADALENO        ³ Data ³ 10/05/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ VERIFICA SE O TITULO NA BAIXA DO BORDERO TEM PA EM ABERTO       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION F090TIT()
LOCAL cQUERY	:= ""
LOCAL lRet	:= .T.

Enter := chr(13) + Chr(10)

IF ALLTRIM(SE2->E2_TIPO) <> 'PA'  .AND. SE2->E2_TIPO <> 'NDF' .AND. SE2->E2_YBLQ <> 'XX' .AND. ALLTRIM(SE2->E2_NUMBOR) = ""
	cQUERY := "SELECT	COUNT(E2_FORNECE) AS cCONT FROM "+RETSQLNAME("SE2")+" " + ENTER
	cQUERY += "WHERE	E2_FORNECE	= '"+SE2->E2_FORNECE+"' AND " + ENTER
	cQUERY += "			E2_LOJA		= '"+SE2->E2_LOJA+"'	AND " + ENTER
	cQUERY += "			E2_TIPO		IN('PA','NDF')	AND	" + ENTER
	cQUERY += "			E2_SALDO 	<> 0	AND	" + ENTER
	cQUERY += "			D_E_L_E_T_ 	= ''		" + ENTER
	If chkfile("_QUANT")
		dbSelectArea("_QUANT")
		dbCloseArea()
	EndIf
	TCQUERY cQUERY ALIAS "_QUANT" NEW
	
	IF _QUANT->cCONT <> 0 .AND. CEMPANT <> "02"
		//cMens := "O TITULO/FORNECEDOR DESCRITO ABAIXO POSSUI PA EM ABERTO!" +chr(13)
		cMens := "O Título descrito abaixo possui PA/NDF em aberto. Favor solicitar a liberação de um Diretor/Gerente para realizar esta baixa! " +chr(13)
		cMens += chr(13)
		cMens += "Número do Título: " + SE2->E2_NUM + chr(13)
		cMens += "Cod Fornecedor:	" + SE2->E2_FORNECE + chr(13)
		cMens += "Nome Fornecedor:	" + SE2->E2_NOMFOR + chr(13)
		cMens += chr(13)
		cMens += "ESTA BAIXA SERÁ REALIZADA APÓS LIBERAÇÃO!"
		If MsgYesNo(cMens,OemToAnsi('ATENCAO'))
			lRet := .F.
		ELSE
			lRet := .F.
		ENDIF
		
		//ATUALIZANDO O CAMPO PARA BLOQUEAR O TITULO
		nRegSE2 := ALLTRIM(STR( SE2->(RecNo()) ))
		CSQL := " UPDATE "+RETSQLNAME("SE2")+" SET E2_YBLQ = '01' WHERE R_E_C_N_O_ = '"+nRegSE2+"' "
		TCSQLExec(CSQL) 
		
		GeraHtml()
		
	ENDIF
ENDIF

IF !EMPTY(SE2->E2_NUMBOR)
	cQUERY := "SELECT	EA_NUMBOR, EA_DATABOR FROM "+RETSQLNAME("SEA")+" " + ENTER
	cQUERY += "WHERE	EA_PREFIXO 	= '"+SE2->E2_PREFIXO+"' AND " + ENTER
	cQUERY += "      	EA_NUM   	= '"+SE2->E2_NUM+"'     AND " + ENTER
	cQUERY += "      	EA_PARCELA 	= '"+SE2->E2_PARCELA+"' AND " + ENTER
	cQUERY += "      	EA_TIPO 	= '"+SE2->E2_TIPO+"'    AND " + ENTER
	cQUERY += "      	EA_FORNECE  = '"+SE2->E2_FORNECE+"' AND " + ENTER
	cQUERY += "      	EA_LOJA 	= '"+SE2->E2_LOJA+"'    AND " + ENTER
	cQUERY += "      	EA_CART 	= 'P'                   AND " + ENTER
	cQUERY += "			D_E_L_E_T_ 	= ''		" + ENTER
	If chkfile("_BORD")
		dbSelectArea("_BORD")
		dbCloseArea()
	EndIf
	TCQUERY cQUERY ALIAS "_BORD" NEW
	
	IF DTOS(DDATABASE) <> _BORD->EA_DATABOR
		lRet := .F.
	ENDIF
ENDIF
 	
	If Empty(SE2->E2_NUMBOR) .And. SE2->E2_YBLQ <> 'XX' .And. Alltrim(SE2->E2_TIPO) <> 'PA' .And. SE2->E2_TIPO <> 'NDF' .And. U_BIAF076()	
		lRet := .F.
	EndIf
	
	
	If lRet .And. Alltrim(SE2->E2_TIPO) == 'PA' .And. SE2->E2_SALDO == 0
		
		lRet := .F.
		
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