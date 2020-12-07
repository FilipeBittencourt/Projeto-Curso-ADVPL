/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |WFRSP3     | Autor | Marcelo Sousa        | Data | 31.07.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |WORKFLOW UTILIZADO PARA INFORMAR AO FUNCIONARIO DA            |
|          |SEGURANÇA DO TRABALHO QUAIS CANDIDATOS IRÃO REALIZAR O ASO.   |
+----------+--------------------------------------------------------------+
|Uso       |RECRUTAMENTO E SELEÇÃO                                        |
+----------+-------------------------------------------------------------*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

User Function BIAFM005()

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/		
	Local cCabec := ""
	Local cCodProc := ""
	Local cCodEt := ""
	Local cPer := ""
	Local cHora := ""
	Local cEmPara := GetMv("MV_RSPASO")
	Local cCand := ""
	Local aTab := GetNextAlias()
	Local nl

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Definindo a query que trará os dados necessários.                       ±±
	±± para a montagem do e-mail. 											   ±±	
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	cQuery := ""
	cQuery += " SELECT QS_DESCRIC, "
	cQuery += " QD_DATA, "
	cQuery += " QD_HORA, "
	cQuery += " X5_DESCRI, "
	cQuery += " QG_NOME, "
	cQuery += " QG_DTNASC "
	cQuery += " FROM " + RetSqlName("SQD") + " SQD " 
	cQuery += " JOIN " + RetSqlName("SQG") + " SQG ON QD_CURRIC = QG_CURRIC "
	cQuery += " JOIN " + RetSqlName("SQS") + " SQS ON QD_VAGA = QS_VAGA "
	cQuery += " JOIN " + RetSqlName("SX5") + " SX5 ON X5_CHAVE = QD_TPPROCE "
	cQuery += " WHERE SQD.D_E_L_E_T_ = '' "
	cQuery += " AND SQS.D_E_L_E_T_ = '' "
	cQuery += " AND SQG.D_E_L_E_T_ = '' "
	cQuery += " AND X5_TABELA = 'R9' "
	cQuery += " AND QD_CURRIC + QD_VAGA + QD_DATA IN (SELECT QD_CURRIC+QD_VAGA+MIN(QD_DATA) FROM " + RetSqlName("SQD") + " SQD WHERE SQD.D_E_L_E_T_ = '' AND QD_SITPROC = 0 AND QD_TPPROCE = 06 GROUP BY QD_CURRIC,QD_VAGA) "


	TcQuery cQuery New Alias (aTab)

	aAux := {}

	While !(aTab)->(EOF())

		AAdd(aAux,{ ALLTRIM( (aTab)->QG_NOME ),CVALTOCHAR( STOD( (aTab)->QG_DTNASC ) ),ALLTRIM( (aTab)->QS_DESCRIC ),CVALTOCHAR( STOD( (aTab)->QD_DATA ) ),(aTab)->QD_HORA } )
		(aTab)->(DBskip())	

	ENDDO


	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Definindo os dados que vão ser enviados por e-mail                      ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	cCabec := "CANDIDATOS PARA ASO"

	cMens := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cMens += '   <html xmlns="http://www.w3.org/1999/xhtml">
	cMens += '      <head>
	cMens += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cMens += '         <title>cabtitpag</title>
	cMens += '         <style type="text/css">
	cMens += '			<!--
	cMens += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
	cMens += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
	cMens += '			.headTexto {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;}
	cMens += '			.headTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif}
	cMens += '			.style12  {background: #f6f6f6;	color: #747474;	font: 16px Arial, Helvetica, sans-serif}
	cMens += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
	cMens += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
	cMens += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
	cMens += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif }
	cMens += '			-->
	cMens += '         </style>
	cMens += '      </head>
	cMens += '      <body>
	cMens += '</br>'+CRLF
	cMens += '<div class = "headTexto1">Os candidatos abaixo estarão realizando ASO nas datas a seguir:</div>'+CRLF		
	cMens += '</br>'+CRLF

	FOR nl := 1 To Len(aAux)
		cMens += '<div class="style12">Candidato: </div>' + aAux[nl,1] +CRLF 
		cMens += '<div class="style12">Nascimento: </div>' + aAux[nl,2] +CRLF
		cMens += '<div class="style12">Vaga: </div>' + aAux[nl,3] +CRLF
		cMens += '<div class="style12">Data: </div>' + aAux[nl,4] +CRLF

		IF aAux[nl,5] <> "     "
			cMens += '<div class="style12">Hora: </div>' + aAux[nl,5] + 'Hs'+CRLF
		ENDIF

		cMens += '</br>'+CRLF
		cMens += '</br>'+CRLF
	Next nl

	cMens += '</br>'+CRLF
	cMens += '<class = "tottab">Caso haja dúvidas, favor encaminhar e-mail para recrutamento@biancogres.com.br.<P>'+CRLF
	cMens += '</br>'+CRLF
	cMens += '</br>'+CRLF
	cMens += '<br> <br><class = "tottab">Atenciosamente,</FONT></br>'+CRLF
	cMens += '</br>'+CRLF
	cMens += '<class = "tottab">Recrutamento Biancogres</FONT>'+CRLF
	cMens += '</body>'+CRLF
	cMens += '</html>'+CRLF

	U_BIAEnvMail(,cEmPara, cCabec, cMens)

	(aTab)->(DbCloseArea())	

Return .T.