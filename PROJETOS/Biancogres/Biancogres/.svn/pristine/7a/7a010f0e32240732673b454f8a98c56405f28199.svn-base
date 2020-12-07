#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA177
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 18/08/2013                      
# DESCRICAO..: Workflow para envio de vencimento de contratos de estagiario/menor aprendiz
#			   CONFIGURADO JOB DIARIO
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/

User Function BIA177()  

	Local dAntecedencia	
	Local nI

	PRIVATE ENTER		:= CHR(13)+CHR(10)
	Private cEmail    	:= ""
	Private C_HTML  	:= ""
	Private lOK        := .F.
	PRIVATE aEmp := {'01','05','13'}        
	PRIVATE cEmailSupervisores := ""

	For nI := 1 to Len(aEmp)                   

		Prepare Environment Empresa aEmp[nI] Filial '01' 

		dAntecedencia	:= DtoS(dDatabase - 20)

		CSQL := ""
		CSQL += " SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_CIC,SRA.RA_NOME,SRA.RA_VCTOEXP,SRA.RA_VCTEXP2,SRA.RA_YSUPERV,SRA.RA_YSEMAIL,"
		CSQL += "SRA.RA_CARGO,SRA.RA_CODFUNC,SRA.RA_ADMISSA,SRJ.RJ_DESC,CAST('"+aEmp[nI]+"' AS CHAR(2)) EMPRESA  "
		CSQL += "FROM SRA"+aEmp[nI]+"0 SRA " 
		CSQL += "INNER JOIN SRJ"+aEmp[nI]+"0 SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.D_E_L_E_T_=''	
		CSQL += "WHERE (SRA.RA_VCTOEXP = '" +dAntecedencia+ "' OR SRA.RA_VCTEXP2 = '" +dAntecedencia+ "') AND "
		CSQL += "SRA.RA_CATFUNC IN ('M','E') AND "   //MENOR APRENDIZ E ESTAGIARIO
		CSQL += "SRA.RA_CATEG = '07' AND "	
		CSQL += "SRA.D_E_L_E_T_= '' " + ENTER

		TCQUERY CSQL ALIAS "QRY" NEW

		//EMAIL CONFIGURADO DE ACORDO COM A EMPRESA	
		Do Case
			Case aEmp[nI] == '01' 
			cEmail := "francine.araujo@biancogres.com.br;jeane.carvalho@biancogres.com.br;"+Alltrim(QRY->RA_YSEMAIL)
			Case aEmp[nI] == '05'
			cEmail := "francine.araujo@biancogres.com.br;jeane.carvalho@biancogres.com.br;"+Alltrim(QRY->RA_YSEMAIL)
			Case aEmp[nI] == '13'
			cEmail := "francine.araujo@biancogres.com.br;jeane.carvalho@biancogres.com.br;"+Alltrim(QRY->RA_YSEMAIL)
			Otherwise       
			cEmail := "wanisay.william@biancogres.com.br"
		EndCase

		GeraHtml()
		QRY->(DbCloseArea())  

		//Finaliza o ambiente criado
		RpcClearEnv()
	Next nI

Return

Static Function GeraHtml()
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
		C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Funcionarios Prestes a vencer o contrato de experiência (primeiro e segundo vencimento) <BR>'

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
		C_HTML += '    <th width="20" scope="col"><span class="style21"> ITEM </span></th> '     
		C_HTML += '    <th width="30" scope="col"><span class="style21"> MATRICULA </span></th> '
		C_HTML += '    <th width="50" scope="col"><span class="style21"> CPF </span></th> '      
		C_HTML += '    <th width="230" scope="col"><span class="style21"> NOME </span></th> '    
		C_HTML += '    <th width="50" scope="col"><span class="style21"> ADMISS&Atilde;O </span></th> '      
		C_HTML += '    <th width="50" scope="col"><span class="style21"> VENCTO. EXPERIENCIA </span></th> '
		C_HTML += '    <th width="50" scope="col"><span class="style21"> VENCTO. 2ª EXPERIENCIA </span></th> '
		C_HTML += '    <th width="30" scope="col"><span class="style21"> FUNCAO </span></th> '
		C_HTML += '    <th width="230" scope="col"><span class="style21"> EMAIL SUPERVISOR </span></th> '
		C_HTML += '  </tr> ' 

		cEmailSupervisores := ""
		WHILE !QRY->(EOF())
			// IMPRIMINDO OS ITENS		
			C_HTML += '  <tr>   
			C_HTML += '    <td class="style12">'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->RA_MAT +'</td> '          
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99")+'</td> '   
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->RA_NOME) +'</td> '
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->RA_ADMISSA,7,2)+"/"+SUBSTR(QRY->RA_ADMISSA,5,2)+"/"+SUBSTR(QRY->RA_ADMISSA,1,4) +'</td> '
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->RA_VCTOEXP,7,2)+"/"+SUBSTR(QRY->RA_VCTOEXP,5,2)+"/"+SUBSTR(QRY->RA_VCTOEXP,1,4) +'</td> '
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->RA_VCTEXP2,7,2)+"/"+SUBSTR(QRY->RA_VCTEXP2,5,2)+"/"+SUBSTR(QRY->RA_VCTEXP2,1,4) +'</td> '
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->RJ_DESC) +'</td> '
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->RA_YSEMAIL) +'</td> '			
			C_HTML += '  </tr>			
			QRY->(DBSKIP())
			nCount ++	                                   

			//SUPERVISORES QUE RECEBERAO EMAIL COM COPIA 
			If !Empty(QRY->RA_YSEMAIL) 						
				If !(Alltrim(QRY->RA_YSEMAIL) $ cEmailSupervisores)
					cEmailSupervisores += Alltrim(QRY->RA_YSEMAIL)+"; "
				EndIf
			EndIf	
		ENDDO 

		C_HTML += '</table> ' 
		C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder.</b></u> '     
		C_HTML += '<p>&nbsp;	</p> '
		C_HTML += '</body> '
		C_HTML += '</html> '
	ENDIF  

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

	cAssunto	:= "Vencimento de Contratos" 			// Assunto do Email   

	lOK := U_BIAEnvMail(,ALLTRIM(CEMAIL),cAssunto,C_HTML,,,.T.,cEmailSupervisores)

	IF !lOK
		CONOUT("ERRO AO ENVIAR EMAIL... WORKFLOW BIA177")
	ELSE
		CONOUT("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIA177")
	ENDIF

RETURN