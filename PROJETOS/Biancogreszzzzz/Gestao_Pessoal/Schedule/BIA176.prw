#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA176
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 14/08/2013                      
# DESCRICAO..: Workflow para Projeto BEM INDICADO, informando os funcionarios que completaram 6 meses
# 			   Configurado via JOB (MENSAL - TODO DIA 1) 
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/

User Function BIA176()          


	Local dInicio := ""	//ARMAZENAR PRIMEIRO DIA DO MES
	Local dFim 	  := ""	//ARMAZENAR ULTIMO DIA DO MES
	Local nJ, nI
	Local cBemIndicado := ''   

	PRIVATE ENTER		:= CHR(13)+CHR(10)
	Private cEmail    	:= "" 
	Private C_HTML  	:= ""
	Private lOK        := .F.
	PRIVATE aEmp := {'01','05','13'}        

	For nI := 1 to Len(aEmp)

		Prepare Environment Empresa aEmp[nI] Filial '01'

		dInicio := DtoS(FirstDate(dDatabase - 200))
		//dFim 	:= DtoS(LastDate(dDatabase))
		dFim 	:= DtoS(LastDate(stod(dInicio)))

		CSQL := ""
		CSQL += " SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_CIC,SRA.RA_NOME,SRA.RA_ADMISSA,SRA.RA_YINDICA,CAST('"+aEmp[nI]+"' AS CHAR(2)) EMPRESA, "+ENTER
		CSQL += " SRA_I.RA_MAT AS RA_MAT_I,SRA_I.RA_CIC AS RA_CIC_I,SRA_I.RA_NOME AS RA_NOME_I, SRA_I.EMP_I  "
		CSQL += "FROM SRA"+aEmp[nI]+"0 SRA " +ENTER 
		CSQL += " LEFT JOIN " +ENTER
		CSQL += " ( " +ENTER
		//BUSCAR DADOS DO INDICADOR	
		For nJ := 1 to Len(aEmp)

			If (nJ != 1)   
				CSQL += " UNION ALL "  + ENTER
			EndIf                               

			CSQL += "SELECT RA_MAT,RA_CIC,RA_NOME,CAST('"+aEmp[nJ]+"' AS CHAR(2)) EMP_I "
			CSQL += "FROM SRA"+aEmp[nJ]+"0 " 
			CSQL += "WHERE RA_SITFOLH != 'D' AND D_E_L_E_T_= '' "      + ENTER	
		Next nJ

		CSQL += " ) SRA_I "
		CSQL += " ON SRA.RA_YINDICA = SRA_I.RA_CIC " +ENTER

		CSQL += " WHERE SRA.RA_ADMISSA BETWEEN '" +dInicio+ "' AND '" +dFim+ "' AND "
		CSQL += "SRA.RA_YINDICA != '' AND "        
		CSQL += "SRA.RA_SITFOLH != 'D' AND "
		CSQL += "SRA.D_E_L_E_T_= '' " + ENTER

		TCQUERY CSQL ALIAS "QRY" NEW   

		//EMAIL CONFIGURADO DE ACORDO COM A EMPRESA
		cEmail := U_EmailWF('BIA176',aEmp[nI]) 
		If (Empty(cEmail))
			cEmail := "wanisay.william@biancogres.com.br"
		EndIf	

		GeraHtml()
		QRY->(DbCloseArea())
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
		C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de funcionários do projeto BEM INDICADO <BR>'

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
		C_HTML += '    <th width="20" scope="col"><span class="style21"> Item </span></th> '
		C_HTML += '    <th width="30" scope="col"><span class="style21"> Matrícula </span></th> '
		C_HTML += '    <th width="50" scope="col"><span class="style21"> CPF </span></th> '      
		C_HTML += '    <th width="230" scope="col"><span class="style21"> Nome </span></th> '    
		C_HTML += '    <th width="50" scope="col"><span class="style21"> Admissão </span></th> '      
		C_HTML += '    <th width="30" scope="col"><span class="style21"> Mat. Indicador </span></th> '
		C_HTML += '    <th width="50" scope="col"><span class="style21"> CPF Indicador </span></th> '
		C_HTML += '    <th width="230" scope="col"><span class="style21"> Nome Indicador </span></th> '		
		C_HTML += '    <th width="40" scope="col"><span class="style21"> Empresa do Indicador </span></th> '		
		C_HTML += '  </tr> '

		WHILE !QRY->(EOF())
			// IMPRIMINDO OS ITENS		
			C_HTML += '  <tr>   
			C_HTML += '    <td class="style12">'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->RA_MAT +'</td> '          
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99")+'</td> '   
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->RA_NOME) +'</td> '
			C_HTML += '    <td class="style12">'+ SUBSTR(QRY->RA_ADMISSA,7,2)+"/"+SUBSTR(QRY->RA_ADMISSA,5,2)+"/"+SUBSTR(QRY->RA_ADMISSA,1,4) +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->RA_MAT_I +'</td> '
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->RA_CIC_I, "@R 999.999.999-99")+'</td> '   
			C_HTML += '    <td class="style12">'+ Alltrim(QRY->RA_NOME_I) +'</td> '        
			Do Case
				Case Alltrim(QRY->EMP_I) == '01'			
				C_HTML += '    <td class="style12"> BIANCOGRES</td> ' 
				Case Alltrim(QRY->EMP_I) == '05'			
				C_HTML += '    <td class="style12"> INCESA</td> ' 	
				Case Alltrim(QRY->EMP_I) == '07'			
				C_HTML += '    <td class="style12"> LM</td> ' 				
				Case Alltrim(QRY->EMP_I) == '13'			
				C_HTML += '    <td class="style12"> MUNDI</td> ' 
				Otherwise
				C_HTML += '    <td class="style12"> '+Alltrim(QRY->EMP_I)+'</td> ' 
			EndCase

			//cBemIndicado := ''
			//cBemIndicado += Indicador(QRY->RA_YINDICA) 
			//If !Empty(cBemIndicado)
			//	C_HTML += cBemIndicado
			//EndIf			
			C_HTML += '  </tr>			
			QRY->(DBSKIP())
			nCount ++		
		ENDDO 

		C_HTML += '</table> '   
		C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática (BIA176). Favor não responder.</b></u> '     
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
# DATA.......: 14/08/2013                      
# DESCRICAO..: Rotina de Envio de Email
##############################################################################################################                                      
*/
STATIC FUNCTION SENDMAIL()  

	Local lOk

	cAssunto	:= "Projeto BEM INDICADO" 			// Assunto do Email   

	lOK := U_BIAEnvMail(,ALLTRIM(CEMAIL),cAssunto,C_HTML)

	IF !lOK
		CONOUT("ERRO AO ENVIAR EMAIL... WORKFLOW BIA176")
	ELSE
		CONOUT("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIA176")
	ENDIF

RETURN



/*
##############################################################################################################
# PROGRAMA...: BIA176VALID
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 28/07/2014                      
# DESCRICAO..: VALIDACAO DO CPF DO INDICADOR NA TABELA SRA
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/

User Function BIA176VALID()          

	Local lRet := .F.
	Local aEmp := {'01','05','13'}
	Local cQuery := '' 
	Local ENTER		:= CHR(13)+CHR(10)  
	Local aArea :=GetArea()
	Local nJ

	If Empty(M->RA_YINDICA)  
		RestArea(aArea)            
		Return .T.
	EndIf
	For nJ := 1 to Len(aEmp)

		If (nJ != 1)   
			cQuery += " UNION ALL "  + ENTER
		EndIf                               

		cQuery += "SELECT RA_MAT,RA_CIC,RA_NOME "
		cQuery += "FROM SRA"+aEmp[nJ]+"0 " 
		cQuery += "WHERE RA_SITFOLH != 'D' AND RA_CIC = '"+M->RA_YINDICA+"' AND D_E_L_E_T_= '' "      + ENTER	
	Next nJ    

	If chkfile("QUERY")
		dbSelectArea("QUERY")
		dbCloseArea()
	EndIf

	TCQUERY cQuery ALIAS "QUERY" NEW  

	IF !QUERY->(EOF())
		lRet := .T.
	EndIf

	If !lRet
		MsgStop("CPF não Encontrado na Base de Dados ou Funcionário esta Demitido!") 
	EndIf

	QUERY->(DbCloseArea()) 

	RestArea(aArea)

Return lRet