#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA175
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 13/08/2013                      
# DESCRICAO..: Workflow para envio de produtos tipo PA com saldo em estoque e sem Custo cadastrado. 
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/
User Function BIA175()  

	Local nI
	PRIVATE ENTER		:= CHR(13)+CHR(10)
	Private cEmail    	:= ""
	Private C_HTML  	:= ""
	Private lOK         := .F.
	PRIVATE aEmp        := {'01','05'}   

	For nI := 1 to Len(aEmp)  

		Prepare Environment Empresa aEmp[nI] Filial '01'

		CSQL := " SELECT B2_FILIAL, B2_COD, B2_LOCAL, B1_TIPO, B1_DESC, CP AS FN_CP, CH AS FN_CH, CAST('"+aEmp[nI]+"' AS CHAR(2)) EMPRESA " + ENTER
		CSQL += " FROM (SELECT *, (SELECT dbo.FN_CP('"+aEmp[nI]+"',B2_COD,'"+DTOS(DDATABASE)+"','"+DTOS(DDATABASE)+"')) AS CP "   //FUNCAO PADRAO DE CUSTO                                                                                              
		CSQL += " 				, (SELECT dbo.FN_CH('"+aEmp[nI]+"',B2_COD,'"+DTOS(DDATABASE)+"','"+DTOS(DDATABASE)+"')) AS CH "                           
		CSQL += " FROM SB2"+aEmp[nI]+"0 ) SB2 " + ENTER
		CSQL += " INNER JOIN SB1010 SB1 ON SB1.B1_COD = SB2.B2_COD AND "
		CSQL += " SB1.D_E_L_E_T_='' " + ENTER
		CSQL += " WHERE SB2.B2_QATU > 0 AND SB1.B1_TIPO = 'PA' AND SB1.B1_YCLASSE != '' AND SB1.B1_MSBLQL <> '1' "                 
		CSQL += " AND SB1.B1_YFORMAT <> 'AC' " //SOLICITAÇÃO 0993-14
		CSQL += " AND SB1.B1_YCLASSE <> '5' "                 	
		CSQL += " AND SB2.D_E_L_E_T_='' "
		CSQL += " AND (CP = 0 OR CH = 0) "
		CSQL += " ORDER BY B2_FILIAL, B2_COD "  

		TCQUERY CSQL ALIAS "QRY" NEW 

		//EMAIL CONFIGURADO DE ACORDO COM A EMPRESA	
		cEmail := U_EmailWF('BIA175',aEmp[nI]) 
		If (Empty(cEmail))
			cEmail := "wanisay.william@biancogres.com.br"
		EndIf

		GeraHtml()
		QRY->(DbCloseArea())
	Next nI
Return

Static Function GeraHtml()

	Local cCodAnt := '' 
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
		C_HTML += '    <th scope="col"><div align="left">Segue abaixo a rela&ccedil;&atilde;o de produtos com saldo em estoque e sem custo padrão e histórico <BR>'

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
		C_HTML += '    <th width="40" scope="col"><span class="style21"> ITEM </span></th> '
		C_HTML += '    <th width="30" scope="col"><span class="style21"> TIPO </span></th> '
		C_HTML += '    <th width="40" height="40" scope="col"><span class="style21"> CODIGO </span></th> '
		C_HTML += '    <th width="230" scope="col"><span class="style21"> DESCRI&Ccedil;&Atilde;O </span></th> '
		C_HTML += '    <th width="40" scope="col"><span class="style21"> CUSTO HISTORICO </span></th> '
		C_HTML += '    <th width="40" scope="col"><span class="style21"> CUSTO PADR&Atilde;O </span></th> '
		C_HTML += '  </tr> '

		WHILE !QRY->(EOF())
			// IMPRIMINDO OS ITENS
			cCodAnt := QRY->B2_COD		
			C_HTML += '  <tr>                                             
			C_HTML += '    <td class="style12">'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->B1_TIPO +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->B2_COD +'</td> '
			C_HTML += '    <td class="style12">'+ QRY->B1_DESC +'</td> '
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->FN_CH	,"@E 999,999,999.99") +'</td> '
			C_HTML += '    <td class="style12">'+ TRANSFORM(QRY->FN_CP	,"@E 999,999,999.99") +'</td> '			
			C_HTML += '  </tr>	  

			nCount ++		
			QRY->(DBSKIP())		   
			While (cCodAnt == QRY->B2_COD)  //IMPRIMIR SOMENTE UMA VEZ CADA PRODUTO
				QRY->(DBSKIP())		
			EndDo
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

	cAssunto	:= "Listagem de produtos sem custo cadastrado." 			// Assunto do Email   

	lOK := U_BIAEnvMail(,ALLTRIM(CEMAIL),cAssunto,C_HTML)

	IF !lOK
		CONOUT("ERRO AO ENVIAR EMAIL... WORKFLOW BIA175")
	ELSE
		CONOUT("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIA175")
	ENDIF

RETURN