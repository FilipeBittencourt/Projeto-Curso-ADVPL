#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA187         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 04/12/2013                      
# DESCRICAO..: Workflow para Envio de Email das Faturas Geradas no Dia para os Clientes
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function BIA187()

	Local nI

	PRIVATE ENTER		:= CHR(13)+CHR(10)
	Private cEmail
	Private C_HTML  	:= ""
	Private lOK        := .F.     
	PRIVATE aEmp := {'01','05','07','13'}  

	Private cNumFat := ''
	Private cCodCLi := ''
	Private cCodLoja := ''

	For nI := 1 to Len(aEmp)   

		Prepare Environment Empresa aEmp[nI] Filial '01'                

		CSQL := ""
		CSQL += "SELECT *, " 
		CSQL += "CAST('"+aEmp[nI]+"' AS CHAR(2)) EMPRESA  "
		CSQL += "FROM SE1"+aEmp[nI]+"0 SE1 " +ENTER
		CSQL += "WHERE SE1.E1_FILIAL = '" +xFilial("SE1")+"' AND SE1.E1_EMISSAO = '"+DtoS(dDatabase)+"' AND "
		CSQL += "SE1.E1_FATURA = 'NOTFAT' AND " 
		CSQL += "SE1.D_E_L_E_T_= '' " +ENTER
		CSQL += " ORDER BY E1_FILIAL, E1_CLIENTE, E1_PREFIXO, E1_NUM, E1_PARCELA"

		TCQUERY CSQL ALIAS "QRY" NEW 

		GeraHtml()  

		QRY->(DbCloseArea())

		//Finaliza o ambiente criado
		RpcClearEnv()      
	Next nI

Return                


Static Function GeraHtml()

	C_HTML  := "" 
	cEmail  := ''

	IF !QRY->(EOF())

		CabFaturas(.T.)

		WHILE !QRY->(EOF())
			// IMPRIMINDO OS ITENS		
			C_HTML += '  <tr>   
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->E1_EMISSAO,7,2)+"/"+SUBSTR(QRY->E1_EMISSAO,5,2)+"/"+SUBSTR(QRY->E1_EMISSAO,1,4) +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->E1_NUM +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->E1_PARCELA +'</td> '
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->E1_SALDO	,"@E 999,999,999.99") +'</td> '
			//		C_HTML += '    <td class="style12">'+ SUBSTR(QRY->E1_VENCTO,7,2)+"/"+SUBSTR(QRY->E1_VENCTO,5,2)+"/"+SUBSTR(QRY->E1_VENCTO,1,4) +'</td> '			
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->E1_VENCREA,7,2)+"/"+SUBSTR(QRY->E1_VENCREA,5,2)+"/"+SUBSTR(QRY->E1_VENCREA,1,4) +'</td> '			
			C_HTML += '  </tr> 

			cNumFat := QRY->E1_NUM  
			cCodCLi := QRY->E1_CLIENTE 
			cCodLoja := QRY->E1_LOJA  

			cEmail 	:= Alltrim(Posicione("SA1",1,xFilial("SA1")+QRY->E1_CLIENTE+QRY->E1_LOJA,"A1_EMAIL"))

			QRY->(DBSKIP()) 
			//GERAR UM EMAIL PARA CADA FATURA
			If(cNumFat != QRY->E1_NUM)  

				CabTitulos()

				If(cCodCLi != QRY->E1_CLIENTE)

					C_HTML += '</table> ' 				
					C_HTML += '<BR><BR><BR><BR>	<u><b>Esta é uma Mensagem Automática. Favor Não Responder.</b></u> '     				
					C_HTML += '<p>&nbsp;	</p> '
					C_HTML += '</body> '
					C_HTML += '</html> ' 
					SENDMAIL()     
					//INICIAR OUTRO HTML
					CabFaturas(.T.)
				Else
					C_HTML += '<BR><BR><BR><BR> '
					C_HTML += '<table width="900" border="1"> '
					C_HTML += '   '
					C_HTML += '  <tr bgcolor="#0066CC"> '  
					C_HTML += '    <th width="50" scope="col"><span class="style21"> EMISS&Atilde;O </span></th> '
					C_HTML += '    <th width="60" scope="col"><span class="style21"> FATURA </span></th> '
					C_HTML += '    <th width="30" scope="col"><span class="style21"> PARCELA </span></th> '
					C_HTML += '    <th width="40" scope="col"><span class="style21"> VALOR </span></th> '
					//C_HTML += '    <th width="60" scope="col"><span class="style21"> VENCIMENTO </span></th> '
					C_HTML += '    <th width="60" scope="col"><span class="style21"> VENCTO REAL </span></th> '
					C_HTML += '  </tr> '
				EndIf
			EndIf             

		ENDDO

		C_HTML += '</table> ' 

		C_HTML += '<BR><BR><BR><BR>	<u><b>Esta é uma Mensagem Automática. Favor Não Responder.</b></u> '     	
		C_HTML += '<p>&nbsp;	</p> '
		C_HTML += '</body> '
		C_HTML += '</html> '

	ENDIF          

RETURN   


Static Function CabFaturas(lCab) 

	If lCab

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
		C_HTML += '    <th scope="col"><div align="left">SEGUE ABAIXO A RELA&Ccedil;&Atilde;O DE FATURA(S) EMITIDA(S) HOJE.'		
		C_HTML += '</div></th> ' 				
		C_HTML += '  </tr> '
		C_HTML += '   '
		C_HTML += '</table> '
	EndIf                  

	C_HTML += '<table width="900" border="1"> '
	C_HTML += '   '
	C_HTML += '  <tr bgcolor="#0066CC"> '  
	C_HTML += '    <th width="50" scope="col"><span class="style21"> EMISS&Atilde;O </span></th> '
	C_HTML += '    <th width="60" scope="col"><span class="style21"> FATURA </span></th> '
	C_HTML += '    <th width="30" scope="col"><span class="style21"> PARCELA </span></th> '
	C_HTML += '    <th width="40" scope="col"><span class="style21"> VALOR </span></th> '
	//	C_HTML += '    <th width="60" scope="col"><span class="style21"> VENCIMENTO </span></th> '
	C_HTML += '    <th width="60" scope="col"><span class="style21"> VENCTO REAL </span></th> '
	C_HTML += '  </tr> '

Return

Static Function CabTitulos(lCab) 

	C_HTML += '</table> '   	
	If lCab
		C_HTML += '<table width="900" border="1"> '
		C_HTML += '  <tr> '		
		C_HTML += '    <th scope="col"><div align="left">TITULOS QUE ORIGINARAM A(S) FATURA(S) ACIMA.'		
		C_HTML += '</div></th> ' 				
		C_HTML += '  </tr> '
		C_HTML += '</table> '
	EndIf       

	C_HTML += '<table width="900" border="1"> '
	C_HTML += '   '
	//	C_HTML += '  <tr bgcolor="#0066CC"> '  
	C_HTML += '  <tr bgcolor="#000000"> '  
	C_HTML += '    <th width="50" scope="col"><span class="style21"> EMISS&Atilde;O </span></th> '
	C_HTML += '    <th width="60" scope="col"><span class="style21"> TITULO </span></th> '
	C_HTML += '    <th width="30" scope="col"><span class="style21"> PARCELA </span></th> '
	C_HTML += '    <th width="40" scope="col"><span class="style21"> VALOR </span></th> '
	//	C_HTML += '    <th width="60" scope="col"><span class="style21"> VENCIMENTO </span></th> '
	C_HTML += '    <th width="60" scope="col"><span class="style21"> VENCTO REAL </span></th> '
	C_HTML += '  </tr> '   

	//IMPRESSAO DOS TITULOS VINCULADOS AS FATURAS						
	CSQL2 := ""
	CSQL2 += "SELECT * FROM SE1"+aEmp[nI]+"0 SE1 " +ENTER
	CSQL2 += "WHERE SE1.E1_FILIAL = '" +xFilial("SE1")+"' AND SE1.E1_FATURA = '"+cNumFat+"' AND "
	CSQL2 += "SE1.E1_CLIENTE = '"+cCodCLi+"' AND SE1.E1_LOJA = '"+cCodLoja+"' AND " 
	CSQL2 += "SE1.D_E_L_E_T_= '' " +ENTER
	CSQL2 += " ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA"

	TCQUERY CSQL2 ALIAS "QRY_TIT" NEW   

	While !QRY_TIT->(EOF())
		// IMPRIMINDO OS ITENS		
		C_HTML += '  <tr>   
		C_HTML += '    <td class="style12">'+ SUBSTR(QRY_TIT->E1_EMISSAO,7,2)+"/"+SUBSTR(QRY_TIT->E1_EMISSAO,5,2)+"/"+SUBSTR(QRY_TIT->E1_EMISSAO,1,4) +'</td> '
		C_HTML += '    <td class="style12">'+ QRY_TIT->E1_NUM +'</td> '
		C_HTML += '    <td class="style12">'+ QRY_TIT->E1_PARCELA +'</td> '
		C_HTML += '    <td class="style12">'+ TRANSFORM(QRY_TIT->E1_VALOR	,"@E 999,999,999.99") +'</td> '
		//		C_HTML += '    <td class="style12">'+ SUBSTR(QRY_TIT->E1_VENCTO,7,2)+"/"+SUBSTR(QRY_TIT->E1_VENCTO,5,2)+"/"+SUBSTR(QRY_TIT->E1_VENCTO,1,4) +'</td> '			
		C_HTML += '    <td class="style12">'+ SUBSTR(QRY_TIT->E1_VENCREA,7,2)+"/"+SUBSTR(QRY_TIT->E1_VENCREA,5,2)+"/"+SUBSTR(QRY_TIT->E1_VENCREA,1,4) +'</td> '			
		C_HTML += '  </tr>							

		QRY_TIT->(DBSKIP()) 
	EndDo

	C_HTML += '</table> '     

	QRY_TIT->(DbCloseArea())

Return


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

	cRecebe     := ALLTRIM(CEMAIL) 	// ;"+cEmail	// Email do(s) receptor(es)                  
	cRecebeCC	:= ""
	cRecebeCO	:= ""													// Copia Oculta
	cAssunto	:= "Listagem de Faturas Emitidas no Dia"			// Assunto do Email          

	If Empty(cRecebe)
		cRecebe	 := "wellison.toras@biancogres.com.br"                                           
		cAssunto := "Listagem de Faturas de Clientes Sem Email Cadastrado"			// Assunto do Email          
	EndIf  

	lOK := U_BIAEnvMail(,cRecebe,cAssunto,C_HTML)

	IF !lOK //.OR. lErro
		CONOUT("ERRO AO ENVIAR EMAIL... WORKFLOW BIA187")
	ELSE
		CONOUT("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIA187")
	ENDIF
RETURN