#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

#DEFINE ATRASADOS 1
#DEFINE EMESPERA 2

User Function BIA568()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := Luana Marin Ribeiro
	Programa  := BIA568
	Empresa   := Biancogres Cerâmica S/A
	Data      := 29/09/2015
	Uso       := Entrega de Pedidos (Fornecedor - 1 vez ao dia)
	Aplicação := Prazo de entrega de pedidos realizados (Fornecedor - 1 vez ao dia)
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	Local nI
	Private ENTER		:= CHR(13)+CHR(10)
	Private cEmail    	:= ""
	Private C_HTML  	:= ""
	Private lOK        	:= .F.
	Private CSQL 		:= ""  
	Private lDebug 		:= .F.
	Private nOpc
	Private cForEmai	:= ''                  

	Private xViaSched 	:= (Select("SX6")== 0)
	Private xv_Emps 	:= {} 

	xv_Emps := U_BAGtEmpr("01_05_13")

	if lDebug
		xv_Emps := U_BAGtEmpr("13")
	EndIf


	For nI := 1 to Len(xv_Emps)
		If xViaSched
			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
		EndIf

		//atrasados
		//nOpc := ATRASADOS
		//MontaQry()
		//TCQUERY CSQL ALIAS "QRY" NEW 	
		//GeraHtml()        	
		//QRY->(DbCloseArea())

		//em espera
		nOpc := EMESPERA
		MontaQry()
		TCQUERY CSQL ALIAS "QRY" NEW 	
		GeraHtml()        	
		QRY->(DbCloseArea())

		If xViaSched	
			//Finaliza o ambiente criado
			RpcClearEnv()    
		EndIf       

	Next nI 

Return                

/*
##############################################################################################################
# PROGRAMA...: GeraHtml
# AUTOR......: LUANA MARIN RIBEIRO
# DATA.......: 29/09/2015
# DESCRICAO..: GERAR HTML PARA ENVIAR O EMAIL
##############################################################################################################
*/
Static Function GeraHtml()

	Local cCForAtu := ''
	Local cCForAnt := ''

	//Incio do email.
	//GeraCab()

	While !QRY->(EOF())
		//Incio do email.
		GeraCab()

		cCForAtu := QRY->COD_FORNEC

		cCForAnt := QRY->COD_FORNEC

		cForEmai := QRY->EMAIL_FORNEC

		//Cabeçalho para o Tipo de Empenho.
		GeraCabItm()

		//Prenche os Itens Empenhados.
		WHILE !QRY->(EOF()) .And. cCForAnt == cCForAtu

			cCForAnt := cCForAtu
			cForEmai := QRY->EMAIL_FORNEC

			If nOpc == ATRASADOS
				If lOK == .F.
					lOK := .T.
				EndIf   //DT_ENTREGA

				C_HTML += '<tr bgcolor="#9caeb8"> '		
				C_HTML += '    <td><div class="style12">' + QRY->PEDIDO + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + QRY->PRODUTO + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + QRY->DESCRICAO + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + QRY->UNID_MED + '</div></td> '		
				C_HTML += '    <td><div class="style12" align="right">' + TRANSFORM(QRY->QUANT_PED, "@E 99,999.99") + '</div></td> '		
				C_HTML += '    <td><div class="style12" align="right">' + TRANSFORM(QRY->QUANT_ENT, "@E 99,999.99") + '</div></td> '		
				C_HTML += '    <td><div class="style12" align="right">' + TRANSFORM(QRY->SALDO, "@E 99,999.99") + '</div></td> '		
				C_HTML += '    <td><div class="style12" align="right">' + TRANSFORM(QRY->PRECO, "@E 999,999,999.99") + '</div></td> '		
				C_HTML += '    <td><div class="style12" align="right">' + TRANSFORM(QRY->TOTAL, "@E 999,999,999.99") + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + UsrFullName(QRY->APROVADOR) + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + SUBSTR(QRY->DT_EMISSAO,7,2)+"/"+SUBSTR(QRY->DT_EMISSAO,5,2)+"/"+SUBSTR(QRY->DT_EMISSAO,1,4) + '</div></td> '		
				//C_HTML += '    <td><div class="style12">' + SUBSTR(QRY->DT_CHEGADA,7,2)+"/"+SUBSTR(QRY->DT_CHEGADA,5,2)+"/"+SUBSTR(QRY->DT_CHEGADA,1,4) + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + SUBSTR(QRY->DT_PREVISAO,7,2)+"/"+SUBSTR(QRY->DT_PREVISAO,5,2)+"/"+SUBSTR(QRY->DT_PREVISAO,1,4) + '</div></td> '
				//C_HTML += '    <td><div class="style12">' + SUBSTR(QRY->DT_ENTREGA,7,2)+"/"+SUBSTR(QRY->DT_ENTREGA,5,2)+"/"+SUBSTR(QRY->DT_ENTREGA,1,4) + '</div></td> '
				C_HTML += '    <td><div class="style12">' + Str(DateDiffDay(stod(QRY->DT_PREVISAO), dDataBase)) + ' dia(s) atrasado</div></td> '		
				C_HTML += '  </tr> '
			Else
				If lOK == .F.
					lOK := .T.
				EndIf

				C_HTML += '<tr bgcolor="#9caeb8"> '		
				C_HTML += '    <td><div class="style12">' + QRY->PEDIDO + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + QRY->PRODUTO + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + QRY->DESCRICAO + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + QRY->UNID_MED + '</div></td> '		
				C_HTML += '    <td><div class="style12" align="right">' + TRANSFORM(QRY->QUANT_PED, "@E 99,999.99") + '</div></td> '		
				C_HTML += '    <td><div class="style12" align="right">' + TRANSFORM(QRY->QUANT_ENT, "@E 99,999.99") + '</div></td> '		
				C_HTML += '    <td><div class="style12" align="right">' + TRANSFORM(QRY->SALDO, "@E 99,999.99") + '</div></td> '		
				C_HTML += '    <td><div class="style12" align="right">' + TRANSFORM(QRY->PRECO, "@E 999,999,999.99") + '</div></td> '		
				C_HTML += '    <td><div class="style12" align="right">' + TRANSFORM(QRY->TOTAL, "@E 999,999,999.99") + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + UsrFullName(QRY->APROVADOR) + '</td> '		
				C_HTML += '    <td><div class="style12">' + SUBSTR(QRY->DT_EMISSAO,7,2)+"/"+SUBSTR(QRY->DT_EMISSAO,5,2)+"/"+SUBSTR(QRY->DT_EMISSAO,1,4) + '</div></td> '		
				//C_HTML += '    <td><div class="style12">' + SUBSTR(QRY->DT_CHEGADA,7,2)+"/"+SUBSTR(QRY->DT_CHEGADA,5,2)+"/"+SUBSTR(QRY->DT_CHEGADA,1,4) + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + SUBSTR(QRY->DT_PREVISAO,7,2)+"/"+SUBSTR(QRY->DT_PREVISAO,5,2)+"/"+SUBSTR(QRY->DT_PREVISAO,1,4) + '</div></td> '		
				//C_HTML += '    <td><div class="style12">' + SUBSTR(QRY->DT_ENTREGA,7,2)+"/"+SUBSTR(QRY->DT_ENTREGA,5,2)+"/"+SUBSTR(QRY->DT_ENTREGA,1,4) + '</div></td> '		
				C_HTML += '    <td><div class="style12">' + Str(DateDiffDay(stod(QRY->DT_PREVISAO), dDataBase)) + ' dia(s)</div></td> '		
				C_HTML += '  </tr> '
			EndIf


			QRY->(DBSKIP())
			cCForAtu := QRY->COD_FORNEC

			dbSelectArea('QRY')
		End

		C_HTML += '</table> '

		dbSelectArea('QRY') 

		C_HTML += '<font face = "Arial"> <p>E-mail enviado automaticamente pelo sistema Protheus (by BIA568).</p> </font>    		
		C_HTML += '<p>&nbsp;	</p> '
		C_HTML += '</body> '
		C_HTML += '</html> '

		//SENDMAIL()
		If lOK == .T.
			EnvMailMult()
		EndIf
	End

RETURN   

/*
##############################################################################################################
# PROGRAMA...: GeraCab
# AUTOR......: LUANA MARIN RIBEIRO
# DATA.......: 29/09/2015
# DESCRICAO..: GERAR CABECALHO DE CADA EMAIL QUE VAI SER ENVIADO
##############################################################################################################
*/

Static Function GeraCab()
	lOK := .F.
	C_HTML := ''

	C_HTML += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	C_HTML += '<head> '
	C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	C_HTML += '<title>Untitled Document</title> '
	C_HTML += '<style type="text/css"> '
	C_HTML += '<!-- '
	C_HTML += '.style9 {font-family: Verdana; } '
	C_HTML += '.style10 {color: #FFFFFF; font-family: Verdana; } '
	C_HTML += '.style11 { '
	//a cor do título é diferente
	If nOpc == ATRASADOS
		C_HTML += '	color: #5f6a70; ' //cinza escuro
	Else                                           
		C_HTML += '	color: #87183d; ' //vinho
	EndIf
	C_HTML += '	font-family: Verdana; '
	C_HTML += '} '
	C_HTML += '.style12 {font-size: 14px} '
	C_HTML += '--> '
	C_HTML += '</style> '
	C_HTML += '</head> '
	C_HTML += '<body> '
	If nOpc == ATRASADOS
		C_HTML += '<h2 align="center" class="style11">PEDIDOS DE COMPRAS EM ATRASO</h2> '
	Else
		C_HTML += '<h2 align="center" class="style11">ATENÇÃO PARA OS PRAZOS DE ENTREGA ABAIXO</h2> '
	EndIf
	If CEmpAnt = "05"                                                                                                
		C_HTML += '<h4 class="style9">  EMPRESA: INCESA REVESTIMENTO CERÂMICO LTDA </h4> '
	ElseIf CEmpAnt = "13"
		C_HTML += '<h4 class="style9">  EMPRESA: MUNDIALLI </h4> '
	Else                                                                   
		C_HTML += '<h4 class="style9">  EMPRESA: BIANCOGRES CERÂMICA S/A </h4> '
	EndIf

	//C_FTML += '<table width=100% height="" border="0" cellpadding="0" > '
	//C_FTML += '  <tr> '
	//C_FTML += '    <th width=50% bgcolor="#5f6a70" scope="col"><div align="left" class="style9"> '
	//C_FTML += '    <strong class="style1">Cliente</strong><br/> '
	//C_FTML += '    <strong class="style2">' +  + '</strong></div></th> '
	//C_FTML += '    <th width=50% bgcolor="#5f6a70" scope="col"><div align="left" class="style9"> '
	//C_FTML += '    <strong class="style1">C.N.P.J.</strong><br/> '
	//C_FTML += '    <strong class="style2">' +  + '</strong></div></th> '	
	//C_FTML += '  </tr> '
	//C_FTML += '  <tr> '
	//C_FTML += '    <th width=50% bgcolor="#5f6a70" scope="col"><div align="left" class="style9"> '
	//C_FTML += '    <strong class="style1">E-mail</strong><br/> '
	//C_FTML += '    <strong class="style2">' +  + '</strong></div></th> '
	//C_FTML += '    <th width=50% bgcolor="#5f6a70" scope="col"><div align="left" class="style9"> '
	//C_FTML += '    <strong class="style1">Telefone</strong><br/> '
	//C_FTML += '    <strong class="style2">' +  + '</strong></div></th> '	
	//C_FTML += '  </tr> '
	//C_FTML += '</table><br/> '

Return

Static Function GeraCabItm()   

	//COD_FORNEC
	//FORNEC
	//CNPJ_FORNEC
	//CONT_FORNEC
	//EMAIL_FORNEC
	//TEL_FORNEC 

	sCnpj := ""

	If Len(QRY->CNPJ_FORNEC) == 14
		sCnpj := SubStr(QRY->CNPJ_FORNEC,1,2) + "." + SubStr(QRY->CNPJ_FORNEC,3,3) + "." + SubStr(QRY->CNPJ_FORNEC,6,3) + "/" + SubStr(QRY->CNPJ_FORNEC,9,4) + "-" + SubStr(QRY->CNPJ_FORNEC,13,2)
	ElseIf Len(QRY->CNPJ_FORNEC) == 11
		sCnpj := SubStr(QRY->CNPJ_FORNEC,1,3) + "." + SubStr(QRY->CNPJ_FORNEC,4,3) + "." + SubStr(QRY->CNPJ_FORNEC,7,3) + "-" + SubStr(QRY->CNPJ_FORNEC,10,2)
	Else
		sCnpj := QRY->CNPJ_FORNEC
	EndIf

	C_HTML += ' </br> '
	C_HTML += '<table width=100% height="" border="1" cellpadding="0" cellspacing="0" bordercolor="#5f6a70" > '
	C_HTML += '  <tr> '
	C_HTML += '    <th width=50% scope="col"><div align="left" class="style9"> '
	C_HTML += '    		<strong class="style12">Fornecedor</strong><br/> '
	C_HTML += '            <strong >' + QRY->FORNEC + '</strong></div></th> '
	C_HTML += '    <th width=50% scope="col"><div align="left" class="style9"> '
	C_HTML += '   		<strong class="style12">C.N.P.J.</strong><br/> '
	C_HTML += '            <strong >' + sCnpj + '</strong></div></th> '
	C_HTML += '  </tr> '
	C_HTML += '  <tr> '
	C_HTML += '    <th width=50% scope="col"><div align="left" class="style9"> '
	C_HTML += '   		<strong class="style12">Contato / E-mail</strong><br/> '
	C_HTML += '            <strong >' + QRY->CONT_FORNEC + ' / ' + QRY->EMAIL_FORNEC + '</strong></div></th> '
	C_HTML += '    <th width=50% scope="col"><div align="left" class="style9"> '
	C_HTML += '   		<strong class="style12">Telefone</strong><br/> '
	C_HTML += '            <strong >' + QRY->TEL_FORNEC + '</strong></div></th> '
	C_HTML += '  </tr> '
	C_HTML += '</table> '
	C_HTML += '<table width=100% border="0"> '
	C_HTML += '  <tr bgcolor="#5f6a70"> '
	C_HTML += '    <th width=4% scope="col"><strong class="style10 style12">Pedido</strong></th> '
	C_HTML += '    <th width=4% scope="col"><strong class="style10 style12">Produto</strong></th> '
	C_HTML += '    <th width=15% scope="col"><strong class="style10 style12">Descrição</strong></th> '
	C_HTML += '    <th width=2% scope="col"><strong class="style10 style12">UM</strong></th> '
	C_HTML += '    <th width=6% scope="col"><strong class="style10 style12">Qtd.Pedida</strong></th> '
	C_HTML += '    <th width=6% scope="col"><strong class="style10 style12">Entregue</strong></th> '
	C_HTML += '    <th width=6% scope="col"><strong class="style10 style12">Saldo</strong></th> '
	C_HTML += '    <th width=9% scope="col"><strong class="style10 style12">Preço</strong></th> '
	C_HTML += '    <th width=9% scope="col"><strong class="style10 style12">Total</strong></th> '
	C_HTML += '    <th width=10% scope="col"><strong class="style10 style12">Comprador</strong></th> '
	C_HTML += '    <th width=7% scope="col"><strong class="style10 style12">Data Emissão</strong></th> '
	//C_HTML += '    <th width=7% scope="col"><strong class="style10 style12">Data Chegada</strong></th> '
	C_HTML += '    <th width=7% scope="col"><strong class="style10 style12">Data Entrega</strong></th> '
	If nOpc == ATRASADOS
		C_HTML += '    <th width=15% scope="col"><strong class="style10 style12">Situação</strong></th> '
	Else
		C_HTML += '    <th width=15% scope="col"><strong class="style10 style12">Prazo</strong></th> '
	EndIf
	C_HTML += '  </tr> '

Return

Static Function EnvMailMult()
	//If AllTrim(__cUserID)=""
	//	lDebug := .T.
	//EndIf

	cRecebe     := cForEmai

	//cRecebe 	+=';'
	If AllTrim(cRecebe) == ''
		cRecebe := 'vagner.salles@biancogres.com.br'
	EndIf

	If nOpc == ATRASADOS
		cAssunto	:= "PEDIDO DE COMPRAS EM ATRASO"
	Else
		cAssunto	:= "ATENÇÃO PARA OS PRAZOS DE ENTREGA ABAIXO"
	EndIf
	cMensagem   := C_HTML

	//If lDebug
	//	cAssunto += " - " + cRecebe
	//	cRecebe  := "luana.ribeiro@biancogres.com.br"
	//EndIf

	U_BIAEnvMail(,cRecebe,cAssunto,cMensagem)

Return
//---------------------------------------------------------------------------------------------------

/*
##############################################################################################################
# PROGRAMA...: MontaQry
# AUTOR......: LUANA MARIN RIBEIRO
# DATA.......: 29/09/2015             
# DESCRICAO..: MONTAR QUERY
##############################################################################################################
*/
Static Function MontaQry()

	CSQL := ""                                                              

	CSQL +="SELECT SA2.A2_COD AS COD_FORNEC " +ENTER
	CSQL +="	, SA2.A2_NOME AS FORNEC " +ENTER
	CSQL +="	, SA2.A2_CGC AS CNPJ_FORNEC " +ENTER
	CSQL +="	, SA2.A2_CONTATO AS CONT_FORNEC " +ENTER
	CSQL +="	, SA2.A2_EMAIL AS EMAIL_FORNEC " +ENTER
	CSQL +="	, SA2.A2_TEL AS TEL_FORNEC " +ENTER
	CSQL +="	, SC7.C7_NUM AS PEDIDO " +ENTER
	CSQL +="	, SC7.C7_PRODUTO AS PRODUTO " +ENTER
	CSQL +="	, SC7.C7_DESCRI AS DESCRICAO " +ENTER
	CSQL +="	, SC7.C7_UM AS UNID_MED " +ENTER
	CSQL +="	, SC7.C7_QUANT AS QUANT_PED " +ENTER
	CSQL +="	, SC7.C7_QUJE AS QUANT_ENT " +ENTER
	CSQL +="	,(SC7.C7_QUANT - SC7.C7_QUJE) AS SALDO " +ENTER
	CSQL +="	, SC7.C7_PRECO AS PRECO " +ENTER
	CSQL +="	, SC7.C7_TOTAL AS TOTAL " +ENTER
	CSQL +="	, SC7.C7_USER AS APROVADOR " +ENTER
	CSQL +="	, SC7.C7_EMISSAO AS DT_EMISSAO " +ENTER
	CSQL +="	, SC7.C7_DATPRF AS DT_PREVISAO " +ENTER
	CSQL +="	, SC7.C7_YDATCHE AS DT_CHEGADA " +ENTER
	CSQL +="	, (CASE WHEN SC7.C7_YDATCHE<>'' THEN SC7.C7_YDATCHE ELSE SC7.C7_DATPRF END) AS DT_ENTREGA " +ENTER
	CSQL +="FROM " + RetSqlName("SC7") + " SC7 " +ENTER
	CSQL +="	INNER JOIN " + RetSqlName("SA2") + " SA2 " +ENTER
	CSQL +="		ON SC7.C7_FORNECE = SA2.A2_COD " +ENTER
	CSQL +="			AND SC7.C7_LOJA = SA2.A2_LOJA " +ENTER
	CSQL +="			AND SA2.A2_FILIAL='" + xFilial("SA2") + "' " +ENTER
	CSQL +="			AND SA2.D_E_L_E_T_=' ' " +ENTER
	CSQL +="WHERE SC7.C7_FILIAL='" + xFilial("SC7") + "' " +ENTER
	If nOpc == ATRASADOS
		CSQL +="	AND SC7.C7_DATPRF < CONVERT(VARCHAR,GETDATE(),112) " +ENTER
		csql +="	AND DATEDIFF(DAY, CONVERT(VARCHAR,GETDATE(),112), SC7.C7_DATPRF) < -6 " +ENTER
	Else
		CSQL +="	AND SC7.C7_DATPRF >= CONVERT(VARCHAR,GETDATE(),112) " +ENTER
		csql +="	AND DATEDIFF(DAY, CONVERT(VARCHAR,GETDATE(),112), SC7.C7_DATPRF) < 6 " +ENTER
	EndIf	
	//If nOpc == ATRASADOS
	//	CSQL +="	AND (CASE WHEN SC7.C7_YDATCHE<>'' THEN SC7.C7_YDATCHE ELSE SC7.C7_DATPRF END) < CONVERT(VARCHAR,GETDATE(),112) " +ENTER
	//	CSQL +="	AND DATEDIFF(DAY, CONVERT(VARCHAR,GETDATE(),112), (CASE WHEN SC7.C7_YDATCHE<>'' THEN SC7.C7_YDATCHE ELSE SC7.C7_DATPRF END)) < -6 " + ENTER
	//Else
	//	CSQL +="	AND (CASE WHEN SC7.C7_YDATCHE<>'' THEN SC7.C7_YDATCHE ELSE SC7.C7_DATPRF END) >= CONVERT(VARCHAR,GETDATE(),112) " +ENTER
	//	csql +="	AND DATEDIFF(DAY, CONVERT(VARCHAR,GETDATE(),112), (CASE WHEN SC7.C7_YDATCHE<>'' THEN SC7.C7_YDATCHE ELSE SC7.C7_DATPRF END)) < 6 " +ENTER
	//EndIf
	CSQL +="	AND SC7.C7_RESIDUO = '' " +ENTER
	CSQL +="	AND (SC7.C7_QUANT - SC7.C7_QUJE) > 0.0 " +ENTER
	CSQL +="	AND SC7.C7_CONAPRO='L' " +ENTER
	CSQL +="	AND SC7.C7_YEMAIL='S' " +ENTER
	CSQL +="	AND SC7.C7_PRODUTO NOT IN (SELECT SB1.B1_COD FROM SB1010 SB1 WHERE SUBSTRING(SB1.B1_GRUPO,1,3) IN ('101','102','103','104','105','107')) " +ENTER
	CSQL +="	AND SC7.D_E_L_E_T_ = ' ' " +ENTER
	CSQL +="ORDER BY SA2.A2_COD, PEDIDO, DT_PREVISAO "


Return