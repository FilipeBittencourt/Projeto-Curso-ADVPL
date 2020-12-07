#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA178
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 18/08/2013                      
# DESCRICAO..: Workflow para envio de Produtos, Embalagens e Paletes que estao em sem retornar no prazo especificado
#			   CONFIGURADO JOB DIARIO
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/
User Function BIA178()  

	Local nCount := 1               
	Local nPrazoPad := 180									//PRAZO PADRAO
	Local dAntecedencia	:= ''
	Local nI

	PRIVATE ENTER		:= CHR(13)+CHR(10)
	Private cEmail    	:= ""
	Private C_HTML  	:= ""
	Private lOK         := .F.
	PRIVATE aEmp        := {'01','14'} 

	CSQL := ""
	For nI := 1 to Len(aEmp)                   

		Prepare Environment Empresa aEmp[nI] Filial '01'   
		dAntecedencia := DtoS(dDatabase - nPrazoPad + 30)	

		If (nI != 1)
			CSQL += " UNION ALL " + ENTER          	
		EndIf

		IF aEmp[nI] == "01"
			CSQL += " SELECT SB6.B6_CLIFOR,SB6.B6_LOJA,SB6.B6_PRODUTO,SB6.B6_DOC,SB6.B6_SERIE,SB6.B6_EMISSAO,SB6.B6_QUANT,SA2.A2_NREDUZ AS A2_NREDUZ, SB1.B1_DESC, "
			CSQL += "CAST('"+aEmp[nI]+"' AS CHAR(2)) EMPRESA  "
			CSQL += "FROM SB6"+aEmp[nI]+"0 SB6 "   
			CSQL += "INNER JOIN SA2010 SA2 ON SA2.A2_COD = SB6.B6_CLIFOR AND SB6.B6_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_='' "
			CSQL += "INNER JOIN SB1010 SB1 ON SB1.B1_COD = SB6.B6_PRODUTO AND SB1.D_E_L_E_T_='' "			
			CSQL += "WHERE SB6.B6_FILIAL = '01' AND SB6.B6_EMISSAO = '" +dAntecedencia+ "'AND "
			CSQL += "SB6.B6_SALDO > 0 AND SB6.B6_TIPO = 'E' AND SB6.B6_TPCF = 'F' AND SB6.B6_PODER3 = 'R' AND "
			CSQL += "SB6.D_E_L_E_T_= '' " + ENTER
		ELSE
			CSQL += " SELECT SB6.B6_CLIFOR,SB6.B6_LOJA,SB6.B6_PRODUTO,SB6.B6_DOC,SB6.B6_SERIE,SB6.B6_EMISSAO,SB6.B6_QUANT,SA1.A1_NREDUZ AS A2_NREDUZ, SB1.B1_DESC, "
			CSQL += "CAST('"+aEmp[nI]+"' AS CHAR(2)) EMPRESA  "
			CSQL += "FROM SB6"+aEmp[nI]+"0 SB6 "   
			CSQL += "INNER JOIN SA1010 SA1 ON SA1.A1_COD = SB6.B6_CLIFOR AND SB6.B6_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_='' "
			CSQL += "INNER JOIN SB1010 SB1 ON SB1.B1_COD = SB6.B6_PRODUTO AND SB1.D_E_L_E_T_='' "			
			CSQL += "WHERE SB6.B6_FILIAL = '01' AND SB6.B6_EMISSAO = '" +dAntecedencia+ "'AND "
			CSQL += "SB6.B6_SALDO > 0 AND SB6.B6_TIPO = 'D' AND SB6.B6_TPCF = 'C' AND SB6.B6_PODER3 = 'R' AND "
			CSQL += "SB6.D_E_L_E_T_= '' " + ENTER	
		ENDIF

	Next nI

	//cEmail := "joan.mareto@biancogres.com.br;bruno.zanette@biancogres.com.br;robert.luchi@biancogres.com.br;rosilene.souza@vitcer.com.br" 
	cEmail := "joan.mareto@biancogres.com.br;bruno.zanette@biancogres.com.br;fabio.sa@biancogres.com.br;rosilene.souza@vitcer.com.br" 

	TCQUERY CSQL ALIAS "QRY" NEW

	C_HTML  := ""
	IF !QRY->(EOF())

		//VERIFICA SE E PARA IMPRIMIR O CABECALHO
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

		C_HTML += '<table width="900" border="1"> '
		C_HTML += '  <tr> '
		C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Produtos Enviados para Terceiros que o prazo de retorno vencerá nos próximos 30 dias. <BR>'

		DO CASE
			CASE QRY->EMPRESA = "01"
			C_HTML += 'Empresa: BIANCOGRES CERÂMICA SA</div></th> '
			CASE QRY->EMPRESA = "05"
			C_HTML += 'Empresa: INCESA REVESTIMENTO CERÂMICO LTDA</div></th> '
			CASE QRY->EMPRESA = "13"
			C_HTML += 'Empresa: MUNDI COMERCIO EXTERIOR E LOGISTICA LTDA</div></th> '
			CASE QRY->EMPRESA = "14"
			C_HTML += 'Empresa: VITCER RETIFICA E COMPLEMENTOS CERAMICOS</div></th> '
		ENDCASE

		C_HTML += '  </tr> '
		C_HTML += '   '
		C_HTML += '  <tr> '
		C_HTML += '    <td>&nbsp;</td> '
		C_HTML += '  </tr> '
		C_HTML += '</table> '
		C_HTML += '<table width="900" border="1"> '
		C_HTML += '   '
		C_HTML += '  <tr bgcolor="#0066CC"> '  
		C_HTML += '    <th width="30" scope="col"><span class="style21"> ITEM </span></th> '
		C_HTML += '    <th width="20" scope="col"><span class="style21"> NOTA </span></th> '     
		C_HTML += '    <th width="20" scope="col"><span class="style21"> SERIE </span></th> '  
		C_HTML += '    <th width="30" scope="col"><span class="style21"> EMISSAO </span></th> '  
		C_HTML += '    <th width="30" scope="col"><span class="style21"> PRODUTO </span></th> '    
		C_HTML += '    <th width="230" scope="col"><span class="style21"> FORNECEDOR </span></th> '    
		C_HTML += '  </tr> '

		WHILE !QRY->(EOF())
			// IMPRIMINDO OS ITENS		
			C_HTML += '  <tr>   
			C_HTML += '    <td class="style12">'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->B6_DOC +'</td> '  
			C_HTML += '    <td class="style12">'+ QRY->B6_SERIE +'</td> '        
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->B6_EMISSAO,7,2)+"/"+SUBSTR(QRY->B6_EMISSAO,5,2)+"/"+SUBSTR(QRY->B6_EMISSAO,1,4) +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->B6_PRODUTO+ "-"+Alltrim(QRY->B1_DESC) +'</td> '          
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->A2_NREDUZ) +'</td> '
			C_HTML += '  </tr>			

			QRY->(DBSKIP()) 
			nCount ++                                      

		ENDDO 

		C_HTML += '</table> '   
		C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder.</b></u> '     
		C_HTML += '<p>&nbsp;	</p> '
		C_HTML += '</body> '
		C_HTML += '</html> '
	ENDIF  

	QRY->(DbCloseArea())

	IF C_HTML <> ""
		SENDMAIL()
	ENDIF

RETURN

/*
##############################################################################################################
# PROGRAMA...: SENDMAIL
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 18/08/2013                      
# DESCRICAO..: Rotina de Envio de Email
##############################################################################################################                                      
*/
STATIC FUNCTION SENDMAIL()               

	Local lOk

	cAssunto	:= "Material Vencendo Prazo de Retorno" 			// Assunto do Email   

	lOK := U_BIAEnvMail(,ALLTRIM(CEMAIL),cAssunto,C_HTML)

	IF !lOK
		CONOUT("ERRO AO ENVIAR EMAIL... WORKFLOW BIA178")
	ELSE
		CONOUT("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIA178")
	ENDIF

RETURN