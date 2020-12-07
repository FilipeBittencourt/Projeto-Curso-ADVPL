#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA182
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 01/10/2013                      
# DESCRICAO..: Workflow para envio de Funcionarios / Cursos que precisam de avaliacao de Eficacia
#				JOB DIARIO				
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/
User Function BIA182()  

	Local nI                        
	PRIVATE ENTER		:= CHR(13)+CHR(10)
	Private cEmail    	:= ""
	Private cEmail_CC	:= ""
	Private C_HTML  	:= ""
	Private lOK        := .F.
	PRIVATE aEmp := {'01','05'}   

	//cEmail  	:= "rubinele.pimenta@biancogres.com.br"      

	For nI := 1 to Len(aEmp)  

		Prepare Environment Empresa aEmp[nI] Filial '01'
		//Prepare Environment Empresa '01' Filial '01'	

		CSQL := ""
		CSQL += " SELECT *,CAST('"+aEmp[nI]+"' AS CHAR(2)) EMPRESA, RA4.R_E_C_N_O_ AS CHAVE_RA4 FROM RA4"+aEmp[nI]+"0 RA4 "
		//CSQL += " SELECT *,CAST('"+aEmp[nI]+"' AS CHAR(2)) EMPRESA, RA4.R_E_C_N_O_ AS CHAVE_RA4 FROM " + RetSqlName("RA4")+" RA4 "
		CSQL += " INNER JOIN RA1010 RA1 ON " + ENTER  
		CSQL += " RA1.RA1_CURSO = RA4.RA4_CURSO " 
		CSQL += " AND RA1.RA1_YPRMAX != 0 " + ENTER          //SOMENTE CURSOS COM PRAZO MAXIMO DE AVALIACAO DE EFICACIA PREECHIDO
		CSQL += " INNER JOIN SRA"+aEmp[nI]+"0 SRA ON "   
		CSQL += " SRA.RA_MAT = RA4.RA4_MAT " + ENTER
		CSQL += " WHERE ('"+DTOS(dDatabase) +"' - RA1.RA1_YPRMAX >= RA4.RA4_DATAFI) AND "
		CSQL += " RA4.RA4_DATAFI != '' AND RA4.RA4_YEMAIL != 'S' AND "   + ENTER     //SOMENTE OS QUE NAO FORAM ENVIADOS AINDA O WORKFLOW
		CSQL += " RA4.D_E_L_E_T_='' AND "   
		CSQL += " RA1.D_E_L_E_T_='' AND SRA.D_E_L_E_T_='' ""
		//	CSQL += " ORDER BY PC_MAT "

		TCQUERY CSQL ALIAS "QRY" NEW

		GeraHtml()        

		QRY->(DbCloseArea())
	Next nI
Return                    

Static Function GeraHtml() 
	Local nCount := 1

	C_HTML  := ""
	IF !QRY->(EOF())

		cEmail_CC := ''

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

		DO CASE
			CASE QRY->EMPRESA = "01"
			C_HTML += '    <th scope="col"><div align="left">Segue abaixo a rela&ccedil;&atilde;o de funcionarios com Avaliação de Eficácia pendente - BIANCOGRES. </tr> '
			CASE QRY->EMPRESA = "05"
			C_HTML += '    <th scope="col"><div align="left">Segue abaixo a rela&ccedil;&atilde;o de funcionarios com Avaliação de Eficácia pendente - INCESA. </tr> '
			CASE QRY->EMPRESA = "13"
			C_HTML += '    <th scope="col"><div align="left">Segue abaixo a rela&ccedil;&atilde;o de funcionarios com Avaliação de Eficácia pendente - MUNDI. </tr> '
			OTHERWISE
			C_HTML += '    <th scope="col"><div align="left">Segue abaixo a rela&ccedil;&atilde;o de funcionarios com Avaliação de Eficácia pendente. </tr> '
		ENDCASE

		C_HTML += '  </tr> '
		C_HTML += '   '
		C_HTML += '</table> '
		C_HTML += '<table width="900" border="1"> '
		C_HTML += '   '
		C_HTML += '  <tr bgcolor="#0066CC"> '  
		C_HTML += '    <th width="30" scope="col"><span class="style21"> ITEM </span></th> '
		C_HTML += '    <th width="20" scope="col"><span class="style21"> COD. CURSO </span></th> '     
		C_HTML += '    <th width="20" scope="col"><span class="style21"> NOME DO CURSO </span></th> '     
		C_HTML += '    <th width="20" scope="col"><span class="style21"> MATRÍCULA </span></th> '  
		C_HTML += '    <th width="20" scope="col"><span class="style21"> NOME DO COLABORADOR </span></th> '  
		C_HTML += '    <th width="30" scope="col"><span class="style21"> CPF </span></th> '  
		C_HTML += '    <th width="30" scope="col"><span class="style21"> INÍCIO </span></th> ' 
		C_HTML += '    <th width="30" scope="col"><span class="style21"> FIM </span></th> ' 
		C_HTML += '  </tr> '

		WHILE !QRY->(EOF())
			// IMPRIMINDO OS ITENS		
			C_HTML += '  <tr>   
			C_HTML += '    <td class="style12">'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->RA1_CURSO +'</td> '  
			C_HTML += '    <td class="style12">'+ QRY->RA1_DESC +'</td> '       
			C_HTML += '    <td class="style12">'+ QRY->RA4_MAT +'</td> '                                 
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->RA_NOME) +'</td> '
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99")+'</td> '   
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->RA4_DATAIN,7,2)+"/"+SUBSTR(QRY->RA4_DATAIN,5,2)+"/"+SUBSTR(QRY->RA4_DATAIN,1,4) +'</td> '      
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->RA4_DATAFI,7,2)+"/"+SUBSTR(QRY->RA4_DATAFI,5,2)+"/"+SUBSTR(QRY->RA4_DATAFI,1,4) +'</td> ' 
			C_HTML += '  </tr>	 

			UpdFlag(QRY->CHAVE_RA4)		

			If !Empty(QRY->RA_YSEMAIL) .And.  !(Alltrim(QRY->RA_YSEMAIL) $ cEmail_CC)
				cEmail_CC 	+= Alltrim(QRY->RA_YSEMAIL) +";"
			EndIf
			QRY->(DBSKIP())                                       
			nCount ++
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
# PROGRAMA...: UpdFlag
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 01/10/2013                      
# DESCRICAO..: Atualizar Flag de Envio de Email
##############################################################################################################                                      
*/
STATIC FUNCTION UpdFlag(nReg)

	Local cUPD

	//cUPD := " UPDATE " +RETSQLNAME("RA4")+" "+ ENTER
	cUPD := " UPDATE RA4"+QRY->EMPRESA+"0
	cUPD += " SET RA4_YEMAIL = 'S' "
	cUPD += " WHERE R_E_C_N_O_ =  " +CVALTOCHAR(nReg)+ " " + ENTER

	TCSQLExec(cUPD)

Return


/*
##############################################################################################################
# PROGRAMA...: SENDMAIL
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 01/10/2013                      
# DESCRICAO..: Rotina de Envio de Email
##############################################################################################################                                      
*/
STATIC FUNCTION SENDMAIL() 

	Local cAssunto
	Local lOk

	cEmail := U_EmailWF('BIA182',cEmpAnt) 
	If (Empty(cEmail))
		cEmail := "wanisay.william@biancogres.com.br"
	EndIf           

	QRY->(DBGOTOP())

	DO CASE
		CASE QRY->EMPRESA = "01"
		cAssunto := "Cursos Pendentes de Avaliação de Eficacia - BIANCOGRES"    // Assunto do Email
		CASE QRY->EMPRESA = "05"
		cAssunto := "Cursos Pendentes de Avaliação de Eficacia - INCESA"	    // Assunto do Email
		CASE QRY->EMPRESA = "13"
		cAssunto := "Cursos Pendentes de Avaliação de Eficacia - MUNDI"    // Assunto do Email 
		OTHERWISE
		cAssunto := "Cursos Pendentes de Avaliação de Eficacia"    // Assunto do Email 
	ENDCASE  

	lOK := U_BIAEnvMail(,cEmail,cAssunto,C_HTML,,,,cEmail_CC)

	IF !lOK //.OR. lErro
		CONOUT("ERRO AO ENVIAR EMAIL... WORKFLOW BIA182")
	ELSE
		CONOUT("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIA182")
	ENDIF

RETURN   