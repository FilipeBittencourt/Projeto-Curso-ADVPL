#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA179
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 18/08/2013                      
# DESCRICAO..: Workflow para envio de Saida de Notas da Biancogres e Entrada na LM
#				CONFIGURADO JOB DIARIO
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function BIA179()  

	Local nPrazoPad := 180						//PRAZO PADRAO
	Local nI

	PRIVATE ENTER		:= CHR(13)+CHR(10)
	//PRIVATE	cEmail      := "fabio.sa@biancogres.com.br;fabiana.corona@biancogres.com.br"
	PRIVATE	cEmail     
	Private C_HTML  	:= ""
	Private lOK         := .F.
	PRIVATE aEmp := {'01','05','13'}        

	//SAIDA NAS EMPRESA SEM ENTRADA NA EMPRESA 07          
	For nI := 1 to Len(aEmp)  

		Prepare Environment Empresa aEmp[nI] Filial '01'

		CSQL := ""
		CSQL += " SELECT F2_DOC,F2_SERIE,F2_EMISSAO,F2_YPEDIDO,CAST('"+aEmp[nI]+"' AS CHAR(2)) EMPRESA  "  
		CSQL += " FROM SF2"+aEmp[nI]+"0 SF2 " + ENTER
		CSQL += " WHERE NOT EXISTS "
		CSQL += " (SELECT * FROM SF1070 SF1 WHERE SF2.F2_DOC = SF1.F1_DOC AND SF2.F2_SERIE = SF1.F1_SERIE AND SF1.D_E_L_E_T_='' ) AND "
		CSQL += " SF2.F2_CLIENTE = '010064' AND "
		CSQL += " SF2.F2_EMISSAO = '" +DtoS(dDatabase)+ "' AND SF2.D_E_L_E_T_= '' "
		CSQL += " ORDER BY F2_DOC,F2_EMISSAO "

		TCQUERY CSQL ALIAS "QRY" NEW         

		GeraHtml(1)        

		QRY->(DbCloseArea())
	Next nI                                                

	//ENTRADA NA EMPRESA 07 SEM SAIDA NAS OUTRAS EMPRESAS          
	For nI := 1 to Len(aEmp)  

		Prepare Environment Empresa aEmp[nI] Filial '01'

		CSQL := ""                                                                                                                               
		CSQL += " SELECT *,CAST('"+aEmp[nI]+"' AS CHAR(2)) EMPRESA FROM SF1070 SF1 "  
		CSQL += " WHERE NOT EXISTS "    + ENTER                                                                                               
		CSQL += " (SELECT * FROM SF2"+aEmp[nI]+"0 SF2 "
		CSQL += " WHERE SF2.F2_DOC = SF1.F1_DOC AND SF2.F2_SERIE = SF1.F1_SERIE AND SF2.D_E_L_E_T_='' ) AND " + ENTER

		DO CASE
			CASE aEmp[nI] = "01"
			CSQL += " SF1.F1_FORNECE = '000534' AND "      //BIANCOGRES
			CASE aEmp[nI] = "05"
			CSQL += " SF1.F1_FORNECE = '002912' AND "      //INCESA
			CASE aEmp[nI] = "13"
			CSQL += " SF1.F1_FORNECE = '004695' AND "      //MUNDI
		ENDCASE	

		CSQL += " SF1.F1_EMISSAO = '" +DtoS(dDatabase)+ "' AND SF1.D_E_L_E_T_= '' "
		CSQL += " ORDER BY F1_DOC,F1_EMISSAO "		

		TCQUERY CSQL ALIAS "QRY" NEW

		GeraHtml(2)        

		QRY->(DbCloseArea())
	Next nI

Return

//nOpc = 1 - SAIDA
//nOpc = 2 - ENTRADA
Static Function GeraHtml(nOpc) 
	Local nCount := 1

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

		If(nOpc == 1)     //SAIDA

			DO CASE
				CASE QRY->EMPRESA = "01"
				C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Notas Fiscais de Saída na BIANCOGRES sem Entrada na LM <BR>'
				CASE QRY->EMPRESA = "05"
				C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Notas Fiscais de Saída na INCESA sem Entrada na LM <BR>'
				CASE QRY->EMPRESA = "13"
				C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Notas Fiscais de Saída na MUNDI sem Entrada na LM <BR>'
			ENDCASE
		Else
			//ENTRADA
			DO CASE
				CASE QRY->EMPRESA = "01"
				C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Notas Fiscais de Entrada na LM e sem Saída na BIANCOGRES. <BR>'
				CASE QRY->EMPRESA = "05"
				C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Notas Fiscais de Entrada na LM e sem Saída na INCESA. <BR>'
				CASE QRY->EMPRESA = "13"
				C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Notas Fiscais de Entrada na LM e sem Saída na MUNDI. <BR>'
			ENDCASE
		EndIf	

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
		IF(nOpc == 1)
			C_HTML += '    <th width="30" scope="col"><span class="style21"> PEDIDO </span></th> ' 
		EndIf
		C_HTML += '  </tr> '

		WHILE !QRY->(EOF())
			// IMPRIMINDO OS ITENS		
			C_HTML += '  <tr>   
			C_HTML += '    <td class="style12">'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td> '
			C_HTML += '    <td class="style12">'+ IIF(nOpc == 1,QRY->F2_DOC,QRY->F1_DOC) +'</td> '  
			C_HTML += '    <td class="style12">'+ IIF(nOpc == 1,QRY->F2_SERIE,QRY->F1_SERIE) +'</td> '        
			C_HTML += '    <td class="style12">'+ IIF(nOpc == 1,SUBSTR(QRY->F2_EMISSAO,7,2)+"/"+SUBSTR(QRY->F2_EMISSAO,5,2)+"/"+SUBSTR(QRY->F2_EMISSAO,1,4),SUBSTR(QRY->F1_EMISSAO,7,2)+"/"+SUBSTR(QRY->F1_EMISSAO,5,2)+"/"+SUBSTR(QRY->F1_EMISSAO,1,4)) +'</td> '
			IF(nOpc == 1)
				C_HTML += '    <td class="style12">'+ QRY->F2_YPEDIDO+'</td> '          
			EndIf
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

	//QRY->(DbCloseArea())

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

	//EMAIL CONFIGURADO DE ACORDO COM A EMPRESA	
	cEmail := U_EmailWF('BIA179',cEmpAnt) 
	If (Empty(cEmail))
		cEmail := "wanisay.william@biancogres.com.br"
	EndIf                                            

	QRY->(DBGOTOP())

	DO CASE
		CASE QRY->EMPRESA = "01"
		cAssunto := "Notas Biancogres x LM" 					    // Assunto do Email
		CASE QRY->EMPRESA = "05"
		cAssunto := "Notas Incesa x LM" 	     				    // Assunto do Email
		CASE QRY->EMPRESA = "13"
		cAssunto := "Notas Mundi x LM"       					    // Assunto do Email
	ENDCASE 

	lOK := U_BIAEnvMail(,ALLTRIM(CEMAIL),cAssunto,C_HTML)

	IF !lOK
		CONOUT("ERRO AO ENVIAR EMAIL... WORKFLOW BIA179")
	ELSE
		CONOUT("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIA179")
	ENDIF

RETURN