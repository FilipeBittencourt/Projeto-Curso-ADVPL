#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA180
# AUTOR......: Wanisay William
# DATA.......: 08/10/2013
# DESCRICAO..: Workflow para envio de notas fiscais de entrada sem pedidos de compras
#				CONFIGURADO JOB SEMANAL
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function BIA180()

	Local nPrazoPad := 180						//PRAZO PADRAO
	Local nCount    := 1
	Local nI

	PRIVATE ENTER		:= CHR(13)+CHR(10)
	//PRIVATE	cEmail      := "enelcio.araujo@biancogres.com.br"
	PRIVATE	cEmail		:= ""
	Private C_HTML  	:= ""
	Private lOK         := .F.
	PRIVATE aEmp 		:= {'01','05','12','13'}

	For nI := 1 to Len(aEmp)

		Prepare Environment Empresa aEmp[nI] Filial '01'
		//Prepare Environment Empresa '01' Filial '01'
		nCount    := 1	

		CSQL := ""
		CSQL += " SELECT D1_CLVL, D1_CC, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, A2_NOME, D1_DTDIGIT, D1_EMISSAO, SUM(D1_TOTAL) AS D1_TOTAL "
		CSQL += " FROM ( SELECT D1_CLVL, D1_CC, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, A2_NOME, D1_DTDIGIT, D1_EMISSAO, (D1_TOTAL + D1_VALIPI - D1_VALDESC + D1_VALFRE) AS D1_TOTAL "
		CSQL += " FROM SD1"+aEmp[nI]+"0 SD1, SA2010 SA2 "
		CSQL += " WHERE D1_DTDIGIT BETWEEN '" +DtoS(dDatabase-7)+ "' AND '" +DtoS(dDatabase)+ "' "
		CSQL += " AND D1_PEDIDO   = '' "
		CSQL += " AND D1_TES   	  <> '' "	
		CSQL += " AND D1_FORNECE  = A2_COD "
		CSQL += " AND D1_LOJA     = A2_LOJA "

		If cEmpAnt == '01'
			CSQL += " AND SD1.D1_TES NOT IN ('','396', '397', '057', '089', '480', '484')
		ElseIf cEmpAnt == '05'
			CSQL += " AND SD1.D1_TES NOT IN ('','3J6', '3I7', '4I0', '4I4')
		ElseIf cEmpAnt == '12'
			CSQL += " AND SD1.D1_TES NOT IN ('480')
		ElseIf cEmpAnt == '13'
			CSQL += " AND SD1.D1_TES NOT IN ('4I0')	
		EndIf

		CSQL += " AND D1_TIPO = 'N' "
		CSQL += " AND SD1.D_E_L_E_T_ = '' "
		CSQL += " AND SA2.D_E_L_E_T_ = '') AS WWW "
		CSQL += " GROUP BY D1_CLVL, D1_CC, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, A2_NOME, D1_DTDIGIT, D1_EMISSAO "
		CSQL += " ORDER BY D1_DOC, D1_SERIE, D1_CLVL, D1_CC, D1_FORNECE, D1_LOJA, A2_NOME, D1_DTDIGIT, D1_EMISSAO "

		TCQUERY CSQL ALIAS "QRY" NEW

		If !QRY->(EOF())

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
				CASE aEmp[nI] = "01"
				C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Notas Fiscais de Entrada na BIANCOGRES sem Pedido de Compra <BR>'
				CASE aEmp[nI] = "05"
				C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Notas Fiscais de Entrada na INCESA sem Pedido de Compra <BR>'
				CASE aEmp[nI] = "12"
				C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Notas Fiscais de Entrada na ST-GESTÃO sem Pedido de Compra <BR>'
				CASE aEmp[nI] = "13"
				C_HTML += '    <th scope="col"><div align="left">Segue Abaixo a Rela&ccedil;&atilde;o de Notas Fiscais de Entrada na MUNDI sem Pedido de Compra <BR>'
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
			C_HTML += '    <th width="20" scope="col"><span class="style21"> Classe de Valor </span></th> '
			C_HTML += '    <th width="20" scope="col"><span class="style21"> Centro de Custo </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> Nota Fiscal </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> Serie </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> Fornecedor </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> Loja </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> Razão Social </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> Data de Digitação </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> Data de Emissão </span></th> '
			C_HTML += '    <th width="30" scope="col"><span class="style21"> Valor Total </span></th> '
			C_HTML += '  </tr> '

			WHILE !QRY->(EOF())

				C_HTML += '  <tr>
				C_HTML += '    <td class="style12">'+ TRANSFORM(nCount,"@E 999,999,999") +'</td> '
				C_HTML += '    <td class="style12">'+ QRY->D1_CLVL +'</td> '
				C_HTML += '    <td class="style12">'+ QRY->D1_CC +'</td> '
				C_HTML += '    <td class="style12">'+ QRY->D1_DOC +'</td> '
				C_HTML += '    <td class="style12">'+ QRY->D1_SERIE +'</td> '
				C_HTML += '    <td class="style12">'+ QRY->D1_FORNECE +'</td> '
				C_HTML += '    <td class="style12">'+ QRY->D1_LOJA +'</td> '
				C_HTML += '    <td class="style12">'+ QRY->A2_NOME +'</td> '
				C_HTML += '    <td class="style12">'+ SUBSTR(QRY->D1_DTDIGIT,7,2)+"/"+SUBSTR(QRY->D1_DTDIGIT,5,2)+"/"+SUBSTR(QRY->D1_DTDIGIT,1,4) +'</td> '
				C_HTML += '    <td class="style12">'+ SUBSTR(QRY->D1_EMISSAO,7,2)+"/"+SUBSTR(QRY->D1_EMISSAO,5,2)+"/"+SUBSTR(QRY->D1_EMISSAO,1,4) +'</td> '
				C_HTML += '    <td class="style12">'+ TRANSFORM(D1_TOTAL,"@E 9,999,999.99") +'</td> '
				C_HTML += '  </tr>

				QRY->(DBSKIP())
				nCount ++
			END

			//QRY->(DbCloseArea())

			IF C_HTML <> ""          

				C_HTML += '</table> '
				C_HTML += '<BR><BR>	<u><b>Esta é uma mensagem automática. Favor não responder.</b></u> '
				C_HTML += '<p>&nbsp;	</p> '
				C_HTML += '</body> '
				C_HTML += '</html> '

				SENDMAIL()
			ENDIF
		EndIf

		QRY->(DbCloseArea())

	Next nI

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
	Local lDebug := .F.         

	Local lOk
	If lDebug
		cEmail := "wanisay.william@biancogres.com.br"	
	Else	
		cEmail := U_EmailWF('BIA180',cEmpAnt) 
	EndIf

	If (Empty(cEmail))
		cEmail := "wanisay.william@biancogres.com.br"
	EndIf           
	cAssunto := "Notas de Entrada sem Pedidos de Compras"               // Assunto do Email

	lOK := U_BIAEnvMail(,cEmail,cAssunto,C_HTML)

	QRY->(DBGOTOP())

	IF !lOK //.OR. lErro
		CONOUT("ERRO AO ENVIAR EMAIL... WORKFLOW BIA180")
	ELSE
		CONOUT("EMAIL ENVIADO COM SUCESSO... WORKFLOW BIA180")
	ENDIF

RETURN