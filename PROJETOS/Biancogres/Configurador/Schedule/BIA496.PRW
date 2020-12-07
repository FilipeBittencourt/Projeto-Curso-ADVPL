#include "TOTVS.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} BIA496
@description Prepara envio de e-mail com estoque para representantes 
@author Wanisay William
@since 20.06.12
@version 1.0
@param AA_EMP, , descricao
@type function
@version V12 revisado por Fernando Rocha
@obs Ticket 801/3031 - revisado para usar a funcao CALC_SALDO_OP
/*/
User Function BIA496(AA_EMP, lEstAmo)

	Default lEstAmo := .F.
	
	If Type("DDATABASE") <> "D"
		DO CASE
			CASE AA_EMP == "01"
			RPCSETENV("01","01",,,"FAT")
			CASE AA_EMP == "05"
			RPCSETENV("05","01",,,"FAT")
			CASE AA_EMP == "07"
			RPCSETENV("07","05",,,"FAT")
			CASE AA_EMP == "13"
			RPCSETENV("13","01",,,"FAT")
		ENDCASE
	EndIf

	Private aLista     	:= {}
	Private nI         	:= 1
	Private cMensagem  	:= ''
	Private lOK        	:= .F.
	Private lSexta     	:= .F.
	Private lErro      	:= .F.
	Private cERRO      	:= ''
	Private nLastKey   	:= 0
	Private cItem 	   	:= 1
	Private cMensag    	:= ''
	Private cMens      	:= ''
	Private nItemPrd   	:= 0
	Private cEmail     	:= ''
	Private Enter      	:= CHR(13)+CHR(10)
	Private cEmpresa   	:= AA_EMP
	Private lAglutina 	:= .F.
	Private cArqHTML	:= ''
	Private cArqCSV		:= ''
	Private nHdl
	Private lPrimeiraVez:= .T.
	Private lDebug := .F.
	Private cInMarca := "('')"
	Private lAmostra := lEstAmo
	
	If (cEmpresa == '01')
		cInMarca  := "('0101','0199')"
	ElseIf (cEmpresa == '05') 
		cInMarca  := "('0501','0599')"
	ElseIf (cEmpresa == '13')
		cInMarca  := "('1302')"
	ElseIf (cEmpresa == '07')
		cInMarca  := "('1302')"
	EndIf

	
	If U_GETBIAPAR("REP_BLQREST",.F.)
		Conout("Consulta temporariamente indisponível","BIA496")
		Return
	EndIf

	//conout('bia496-INICIADO')

	Conout(dtoc(dDatabase) + " - " + Time() + " - BIA496 INICIADO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada de Funcoes                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTipo := '1'
	Processa({|| Calcula_EST()})

	//conout('bia496-ENCERRADO')
	Conout(dtoc(dDatabase) + " - " + Time() + " - BIA496 FINALIZADO")

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaArq   ³ Autor ³ Wanisay William       ³ Data ³ 08.02.08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Calcula_EST()

	Private nTotalProd 	:= 0
	Private nTotalEmp 	:= 0
	Private nTotalDisp 	:= 0
	Private nTotalCart 	:= 0

	Private cProdOld 	:= ''
	Private cDescOld 	:= ''
	Private cClasseOld 	:= ''
	Private cDesClsOld  := ''
	Private cArqCsv 	:= ''
	Private C_HTML		:= ''
	Private C_HTMLAnt	:= ''
	Private fCSV
	Private aStru		
	Private fHtml

	cQry := GeraSql()
	MemoWrite("\BIA496_QUERY.TXT", cQry)

	If chkfile("QRY")
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf
	TCQUERY cQry ALIAS "QRY" NEW

	DbSelectArea("QRY")
	DbGotop()
	//conout('bia496-2')
	Setprc(0,0)
	cEmailCC := ''
	cEmailCO := ''


	cArqHtml:= "\P10\workflow\Estoque.html"
	cArqCSV	:= "\P10\workflow\Estoque.csv"

	//Verifica se o arquivo existe
	If file(cArqHtml)
		FErase(cArqHtml)
	EndIf 

	If file(cArqCSV)
		FErase(cArqCSV)
	EndIf 

	fHtml := fCreate(cArqHtml)
	fCSV  := fCreate(cArqCSV)
	//nHdlCSV := MSFCREATE(cArqCSV,0)

	If fHtml != -1
		GeraArq()
	EndIf

	DbSelectArea("QRY")
	If eof()
		DbCloseArea()
	EndIf

Return

Static Function GeraArq()
	//caracter de salto de linha
	cCrLf := Chr(13) + Chr(10)

	GeraCab()

	nTotProdAc := 0
	nTotEmpAc  := 0
	nTotDispAc := 0

	While !EOF()

		nSaldoOp   := 0

		nTotalProd := 0
		nTotalEmp  := 0
		nTotalDisp := 0
		nTotalCart := 0

		cProdOld := QRY->PRODUTO
		cDescOld := QRY->DESCRICAO
		//nSaldoOp := QRY->SALDOOP

		If (cClasseOld != QRY->B1_YCLASSE) //.And. !Eof()
			cClasseOld := QRY->B1_YCLASSE
			cDesClsOld := QRY->DESC_CLASSE
			GeraCabCls()
		Else
			GeraCabItm()
		EndIf

		While (cProdOld == QRY->PRODUTO) //.And. !Eof()

			IncProc()
			nItemPrd := nItemPrd + 1

			nTotalProd += QRY->DISPONIVEL
			nTotalEmp  += QRY->PEDCART
			nTotalDisp := nTotalProd - nTotalEmp

			nSaldoOp += QRY->SALDOOP
			//Popula a tabela
			//If QRY->DISPONIVEL > 0
			GeraItmTb()
			//EndIf

			DbSelectArea("QRY")
			DbSkip()
		End
		If nTotalDisp != 0
			GeraTotItm()
		EndIf

		If (nSaldoOp > 0) .And. !(cClasseOld $ '2_3')
			GeraOps(cProdOld)
		EndIf

		nTotProdAc += nTotalProd
		nTotEmpAc  += nTotalEmp
		nTotDispAc += nTotalDisp

		if Eof()
			GeraFtrFim()
		EndIf

		FWrite(fHtml,C_HTML)
		C_HTML:=''

		DbSelectArea("QRY")
	END
	Enviar()
Return

Static Function Enviar()
	FWrite(fHtml,C_HTML)
	fClose(fHtml)
	fClose(fCSV)

	cSQL := ""
	cSQL += "SELECT A3_COD, A3_NOME, A3_YEMP, A3_EMAIL "  + Enter
	cSQL += "FROM " + RETSQLNAME("SA3") + " SA3 "  + Enter
	cSQL += "WHERE A3_MSBLQL <> '1' "  + Enter
	DO CASE
		CASE cEmpresa == "01"
		cSQL += "AND A3_YEMP LIKE '%0101%' "  + Enter
		CASE cEmpresa == "05"
		cSQL += "AND (A3_YEMP LIKE '%0501%' OR  A3_YEMP LIKE '%0599%') "  + Enter
		cSQL += "AND A3_COD NOT IN ('A00013')"
		CASE cEmpAnt == "07" .And. cFilAnt == '05'
			cSQL += "AND A3_YEMP = '1302' AND A3_EST = 'SP' "  + Enter
		CASE cEmpresa == "13"
		cSQL += "AND A3_YEMP LIKE '%13__%' "  + Enter
		OTHERWISE
	ENDCASE
	cSQL += "AND SA3.D_E_L_E_T_ = '' "  + Enter
	cSQL += "ORDER BY A3_COD 	  "  + Enter

	If chkfile("DEST")
		dbSelectArea("DEST")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "DEST" NEW

	DbSelectArea("DEST")
	DbGotop()

	if lDebug                                              
		Envioemail("tiago@facilesistemas.com.br")
	else
		//Enviar só para gerentes
		lSohGer := .F.

		//Envia para os gerentes...
		cEmail := U_EmailWF('BIA496',cEmpAnt)
		IF !EMPTY(cEmail)
			Envioemail(cEmail)
		ENDIF

		If !lSohGer
			WHILE !Eof()
				cEmailCC  := ''
				cEmailCO  := ''
				cEmail    := ''

				cEmail := ALLTRIM(DEST->A3_EMAIL)

				IF !EMPTY(cEmail)
					Envioemail(cEmail)
				ENDIF
				DbSelectArea("DEST")
				DbSkip()
			END
		EndIf
		
	EndIf

	FErase(cArqHtml)
	FErase(cArqCSV)

	cMensag  := ''
	cMens    := ''
	nItemPrd := 0
	//conout('bia496-10')

Return



Static Function Envioemail(cEmail)

	Local cNMarca := ""	
		  					  		// Email do Emissor
	cRecebe   	:= cEmail																// Email do(s) receptor(es)
	cRecebeCC	:= cEmailCC  												 			// Com Copia
	cRecebeCO	:= cEmailCO
	//cRecebe += ";luana.ribeiro@biancogres.com.br"
	//cRecebeCC := ""
	//cRecebeCO := ""
	
	If (cEmpAnt == '01')
		cNMarca := "BIANCOGRES"
	ElseIf (cEmpAnt == '05')
		cNMarca := "INCESA"
	ElseIf (cEmpAnt == '13')
		cNMarca := "MUNDI"
	ElseIf (cEmpAnt == '07' .or. cFilAnt == '05')
		cNMarca := "LM SP"
	EndIf
	
	If lAmostra
	
		cAssunto	:= 'Relação de estoque de AMOSTRA'// Assunto do Email
		cMensag := "Segue em anexo a relação de estoque de AMOSTRA disponível da marca "+ALLTRIM(cNMarca) +ENTER+ENTER
	
	Else

		cAssunto	:= 'Relação de estoque dos produtos acabados disponíveis para venda'// Assunto do Email
		cMensag := "Segue em anexo a relação de estoque de produtos disponível da marca "+ALLTRIM(cNMarca) +ENTER+ENTER
	
	EndIf

	cMensag += 'Atenciosamente,' +ENTER+ENTER
	cMensag += 'Qualquer dúvida entre em contato com o setor de TI. Este e-mail é automático.' +ENTER
	cMensag += 'Não Responda esta mensagem.'

	cArqAnexo := cArqHtml+";"+cArqCSV 
	
	//cRecebe := "gabriel@facilesistemas.com.br"
	//cRecebeCC := ""

	U_BIAEnvMail(,cRecebe,cAssunto,cMensag,'',cArqAnexo,,cRecebeCC)       

Return

// Sem CSS
Static Function GeraCab()
	C_HTML := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
	C_HTML += '   <html xmlns="http://www.w3.org/1999/xhtml">
	C_HTML += '      <head>
	C_HTML += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	C_HTML += '         <title>Estoque</title>
	C_HTML += '         <style type="text/css">
	C_HTML += '			<!--
	C_HTML += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
	C_HTML += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
	C_HTML += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
	C_HTML += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
	C_HTML += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
	C_HTML += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
	C_HTML += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif } 			
	C_HTML += '			--> 
	C_HTML += '         </style>
	C_HTML += '      </head>
	C_HTML += '      <body>

Return

//Gera cabeçalho a cada nova classe com CSS
Static Function GeraCabCls()
	C_HTML += '		<table align="center" class = "headClass"> '
	C_HTML += '            <tr align=center> '
	C_HTML += '                  <th width="587" scope="col"> '
	C_HTML += '                    <div align="left"> '
	C_HTML += "							<span> Classe de Produtos " + QRY->DESC_CLASSE + " </span> ' 
	C_HTML += '						</div> '
	C_HTML += '                  </th> '
	C_HTML += '               <td>&nbsp;</td> '
	C_HTML += '            </tr> '
	C_HTML += '         </table> '
	C_HTML += '         <table align="center" width="600" border="0" bgcolor="D3D3D3"> '
	C_HTML += '            <tr> <font face="Arial" color="white"> </font></tr> '
	C_HTML += '         </table> '
	C_HTML += '         <table align="center" class = "headProd"> '
	C_HTML += '               <tr> '
	C_HTML += '                  <div align="left"> '
	C_HTML += "                  <th width='594' scope='col'> Produto: " +ALLTRIM(QRY->PRODUTO)+" - "+ALLTRIM(QRY->DESCRICAO) + "</th> '
	C_HTML += '					 </div> '
	C_HTML += '               </tr> '
	C_HTML += '         </table> '
	C_HTML += '         <table align="center" width="600" border="1" cellspacing="0" cellpadding="1"> '
	C_HTML += '            <tr align=center> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Item </span></th> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Local </span></th> '
	C_HTML += '               <th class = "cabtab" width="50" scope="col" > Lote </span></th> '
	C_HTML += '               <th class = "cabtab" width="50" scope="col" > Dt Lote </span></th> '
	C_HTML += '               <th class = "cabtab" width="80" scope="col"> Estoque </span></th> '
	C_HTML += '            </tr> '

	fWrite(fCSV, " Codigo; "+PADR("Produto",50," ")+"; Classe; Local; Lote; Data Lote; Estoque;  ")
	fWrite(fCSV, cCrLf ) // Pula linha

Return

//Gera cabeçalho a cada novo item
Static Function GeraCabItm()

	C_HTML += '         <table align="center" class = "headProd"> '
	C_HTML += '               <tr> '
	C_HTML += '                  <th width="594" scope="col">Produto: ' +ALLTRIM(QRY->PRODUTO)+" - "+ALLTRIM(QRY->DESCRICAO) + ' </th> '
	C_HTML += '               </tr> '
	C_HTML += '         </table> '
	C_HTML += '         <table align="center" width="600" border="1" cellspacing="0" cellpadding="1"> '

Return

Static Function GeraItmTb()

	C_HTML += " 			<tr align=center> "
	C_HTML += "                   <td class='style12' width='60'scope='col'>" +STRZERO(nItemPrd,4)+ "</td> "
	C_HTML += "                   <td class='style12' width='60'scope='col'>"+ALLTRIM(QRY->EMP)+"</td> "
	C_HTML += " 				  <td class='style12' width='50'scope='col'>"+ALLTRIM(QRY->LOTE)+"</td> "
	C_HTML += " 				  <td class='style12' width='50'scope='col'>"+DTOC(STOD(QRY->DTPRILOTE))+"</td> "
	C_HTML += "                   <td class='style12' width='80'scope='col'>"+TRANSFORM(QRY->DISPONIVEL,"@E 9,999,999.99")+"</td> "
	C_HTML += "             </tr> "

	FWrite(fCSV, +ALLTRIM(QRY->PRODUTO)+";"+ALLTRIM(QRY->DESCRICAO)+";"+ALLTRIM(QRY->DESC_CLASSE)+";"+ ALLTRIM(QRY->EMP)+";"+ALLTRIM(QRY->LOTE)+";"+DTOC(STOD(QRY->DTPRILOTE))+";"+TRANSFORM(QRY->DISPONIVEL,"@E 9,999,999.99")+";")
	fWrite(fCSV, cCrLf ) // Pula linha

Return

Static Function GeraTotItm()

	C_HTML += "		</table> "
	C_HTML += "		<table align='center' width='600' border='1' cellspacing='0' cellpadding='1'> "
	C_HTML += "            <tr align=center> "
	C_HTML += "               <th class = 'tottab' width='205' scope='col'> Total </span></th> "
	C_HTML += "               <th class = 'tottab' width='70' scope='col'> "+ TRANSFORM(nTotalProd,"@E 9,999,999.99") +" </span></th> "
	C_HTML += "			</tr> "  
	C_HTML += "		</table> "

	FWrite(fCSV, " ; ; ; ;	Total ; ;"+ TRANSFORM(nTotalProd,"@E 9,999,999.99")+";")
	fWrite(fCSV, cCrLf ) // Pula linha

Return

Static Function GeraFtrFim()

	C_HTML += "		<table align='center' width='600' border='1' cellspacing='0' cellpadding='1'> "
	C_HTML += "            <tr align=center> "
	C_HTML += "               <th class = 'tottab' width='156' scope='col'> Total Acumulado </span></th> "
	C_HTML += "               <th class = 'tottab' width='70' scope='col'> "+ TRANSFORM(nTotProdAc,"@E 9,999,999.99") +" </span></th> "
	C_HTML += "			</tr> "  
	C_HTML += "		</table> "
	C_HTML += "		<table align='center' width='600' border='1' cellspacing='0' cellpadding='1'> "
	C_HTML += "            <tr> "
	C_HTML += "               <th class = 'tottab' width='600' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by BIA496).</th> "
	C_HTML += "			   <p>&nbsp;	</p> "
	C_HTML += "			</tr> "
	C_HTML += "		</table> "
	C_HTML += "      </body> "
	C_HTML += "   </html> "

	FWrite(fCSV, " ; ; ; ;	Total Acumulado; ;"+ TRANSFORM(nTotProdAc,"@E 9,999,999.99")+";")
	fWrite(fCSV, cCrLf ) // Pula linha

Return
//-----------------------------------------------------------------------------------------------------
Static Function GeraOps(pProduto)

	Local aArea			:= GetArea()
	Local cSqlOp 		:= SqlOp(pProduto)
	Private nSaldoTot 	:= 0

	If chkfile("OPS")
		dbSelectArea("OPS")
		dbCloseArea()
	EndIf
	TCQUERY cSqlOp ALIAS "OPS" NEW

	DbSelectArea("OPS")
	DbGotop()

	If !OPS->(Eof())

		GeraCabOP()

		While !OPS->(Eof())
			GeraItemOP()
			OPS->(dbSkip())
		End

		GeraTotOP()

	EndIf

	OPS->(dbCloseArea())

	RestArea(aArea)

Return
//-----------------------------------------------------------------------------------------------------
Static Function GeraCabOP()
	C_HTML += '         <table align="center" width="600" border="1" cellspacing="0" cellpadding="1"> '
	C_HTML += '            <tr align=center> '
	C_HTML += '               <th class = "cabtab" width="120" scope="col"> OP </span></th> '
	C_HTML += '               <th class = "cabtab" width="130" scope="col"> Disponibilidade </span></th> '
	C_HTML += '               <th class = "cabtab" width="160" scope="col"> Saldo </span></th> '
	C_HTML += '            </tr> '

	FWrite(fCSV, " ; OP ; Disponibilidade; Saldo; ; ")
	fWrite(fCSV, cCrLf ) // Pula linha

Return
//-----------------------------------------------------------------------------------------------------

Static Function GeraItemOP()

	nSaldoTot += OPS->SALDO 

	C_HTML += " 			<tr align=center> "
	C_HTML += "                   <td class='style12' width='120'scope='col'>"+ALLTRIM(OPS->OPNUM)+"</td> "
	C_HTML += " 				  <td class='style12' width='130'scope='col'>"+DToC(SToD(OPS->DATADISP))+"</td> "
	C_HTML += "                   <td class='style12' width='160'scope='col'>"+TRANSFORM(OPS->SALDO,"@E 9,999,999.99")+"</td> "
	C_HTML += "             </tr> "

	FWrite(fCSV, " ; "+ALLTRIM(OPS->OPNUM)+" ; "+DToC(SToD(OPS->DATADISP))+"; "+TRANSFORM(OPS->SALDO,"@E 9,999,999.99")+"; ; ")
	fWrite(fCSV, cCrLf ) // Pula linha

Return

/*
Static Function GeraItemOP()

	nSaldoTot += OPS->SALDO 

	C_HTML += " 			<tr align=center> "
	C_HTML += "                   <td class='style12' width='120'scope='col'>"+ALLTRIM(OPS->C2_NUM)+"</td> "
	C_HTML += " 				  <td class='style12' width='130'scope='col'>"+DToC(SToD(OPS->C2_YDTDISP))+"</td> "
	C_HTML += "                   <td class='style12' width='160'scope='col'>"+TRANSFORM(OPS->SALDO,"@E 9,999,999.99")+"</td> "
	C_HTML += "             </tr> "

	FWrite(fCSV, " ; "+ALLTRIM(OPS->C2_NUM)+" ; "+DToC(SToD(OPS->C2_YDTDISP))+"; "+TRANSFORM(OPS->SALDO,"@E 9,999,999.99")+"; ; ")
	fWrite(fCSV, cCrLf ) // Pula linha

Return

*/



//-----------------------------------------------------------------------------------------------------
Static Function GeraTotOP()
	C_HTML += '			</table> '
	C_HTML += "			<table align='center' width='600' border='1' cellspacing='0' cellpadding='1'> '
	C_HTML += '            <tr align=center> '
	C_HTML += '               <th class = "tottab" width="255" scope="col"> Total da Op </span></th> '
	C_HTML += '               <th class = "tottab" width="160" scope="col">'+TRANSFORM(nSaldoTot,"@E 9,999,999.99")+'</span></th> '
	C_HTML += '            </tr> '
	C_HTML += '			</table> '

	FWrite(fCSV, " ;  ; Total da Op;"+TRANSFORM(nSaldoTot,"@E 9,999,999.99")+" ; ; ")
	fWrite(fCSV, cCrLf ) // Pula linha

Return

Static Function GeraSql()

	cSQL := "	SELECT "+Enter
	cSQL += "	EST.*, DTPRILOTE FROM "+Enter
	cSQL += "	( "+Enter 
	cSQL += "	SELECT  "+Enter 
	cSQL += "		 "+Enter 
	cSQL += "		B1_COD,  " + Enter 
	cSQL += "		B1_COD AS PRODUTO,	 " + Enter 
	cSQL += "		MAX(CONV) AS CONV,  " + Enter 
	cSQL += "		MAX(DESCRICAO) AS DESCRICAO,  " + Enter 
	cSQL += "		LOTE,  " + Enter 
	cSQL += "		B1_LOCAL AS EMP,  " + Enter 
	cSQL += "		LOTE_ORI,  " + Enter 
	cSQL += "		MAX(RUA) AS RUA,  " + Enter 
	cSQL += "		SUM(QUANTIDADE) AS QUANTIDADE,  " + Enter 
	cSQL += "		SUM(EMPENHO) AS EMPENHO,  " + Enter 
	cSQL += "		ISNULL(SUM(QUANTIDADE) - SUM(EMPENHO),0) AS DISPONIVEL,  " + Enter 
	cSQL += "		MAX(CAIXA) AS CAIXA,  " + Enter 
	cSQL += "		B1_YCLASSE,  " + Enter 
	cSQL += "		ZZ8.ZZ8_DESC AS DESC_CLASSE,  " + Enter 
	cSQL += "		PEDCART = CASE WHEN (ROW_NUMBER() over (PARTITION BY B1_COD ORDER BY B1_COD DESC)) = 1 THEN (SELECT dbo.FN_SALDOPEDIDO(B1_LOCAL,B1_COD)) ELSE 0 END,   " + Enter 
	cSQL += "		GERAITEM = CASE WHEN SUM(PROD.QUANTIDADE - EMPENHO)> 0 THEN 'S' ELSE 'N' END,   " + Enter 
	cSQL += "		SALDOOP = CASE WHEN (ROW_NUMBER() over (PARTITION BY B1_COD ORDER BY B1_COD DESC)) = 1  " + Enter 

	//Fernando em 15/12/2017 - substituido o bloco de calculo de saldo de OP para usar a funcao SQL
	If cEmpresa $ "01_05"
		cSQL += "       THEN ISNULL((SELECT [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_01]('01',PROD.B1_COD ,'','',1)),0) ELSE 0 END "  + Enter
	ElseIf(cEmpresa $ "07")
		//saldo empresa 
		cSQL += "       THEN ISNULL((SELECT [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_13]('01',PROD.B1_COD ,'','',1)),0) ELSE 0 END "  + Enter
	Else
		cSQL += "       THEN ISNULL((SELECT [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_"+AllTrim(CEMPANT)+"]('01',PROD.B1_COD ,'','',1)),0) ELSE 0 END "  + Enter
	EndIf	

	cSQL += "	 " + Enter 
	cSQL += "	FROM  " + Enter 
	cSQL += "	( " + Enter 
	cSQL += "		SELECT  " + Enter 
	cSQL += "			B1_LOCAL,  " + Enter 
	cSQL += "			B1_COD, B1_CONV AS CONV,  " + Enter 
	cSQL += "			B1_DESC AS DESCRICAO,  " + Enter 
	cSQL += "			SUBSTRING(B1_COD,1,8) AS PRODUTO,  " + Enter 
	cSQL += "			LOTE = CASE WHEN ZZ9_RESTRI = '*' THEN RTRIM(BF_LOTECTL)+ZZ9_RESTRI ELSE RTRIM(BF_LOTECTL) END, " + Enter 
	cSQL += "			BF_LOTECTL AS LOTE_ORI,  " + Enter 
	cSQL += "			ISNULL(BF_LOCALIZ,'---') AS RUA,  " + Enter 
	cSQL += "			ISNULL(BF_QUANT,0) AS QUANTIDADE,  " + Enter 
	cSQL += "			ISNULL(BF_EMPENHO,0) AS EMPENHO,  " + Enter 
	cSQL += "			ZZ9.ZZ9_DIVPA AS CAIXA,  " + Enter 
	cSQL += "			B1_YFORMAT,  " + Enter 
	cSQL += "			B1_YFATOR,  " + Enter 
	cSQL += "			B1_YLINHA,  " + Enter 
	cSQL += "			B1_YCLASSE " + Enter 
	cSQL += "		 " + Enter 
	cSQL += "		FROM " + RETSQLNAME("SB1") + "  SB1  " + Enter 
	cSQL += "	 " + Enter 
	cSQL += "		INNER JOIN " + RETSQLNAME("ZZ7") +"  ZZ7 ON (SB1.B1_YLINHA		= ZZ7.ZZ7_COD AND SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ)  " + Enter 
	cSQL += "		INNER JOIN ( " + Enter 
	
	If lAmostra

		cSQL += "			SELECT '01' B1_LOCAL, * FROM SBF010 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND BF_LOCAL = '05' AND D_E_L_E_T_ = '' 	 " + Enter 
		cSQL += "			UNION ALL																																					 " + Enter 
		cSQL += "			SELECT '05' B1_LOCAL, * FROM SBF050 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND BF_LOCAL = '05' AND D_E_L_E_T_ = ''	 " + Enter 
		cSQL += "			UNION ALL																																					 " + Enter 
		cSQL += "			SELECT '13' B1_LOCAL, * FROM SBF130 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND BF_LOCAL = '05' AND D_E_L_E_T_ = '' 	 " + Enter 
		
	Else
		//estoque filial 05 empresa 07 vinilico
		If(cEmpresa $ "07")
			cSQL += "			SELECT '07' B1_LOCAL, * FROM SBF070 WITH (NOLOCK) WHERE BF_FILIAL = '05' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter 
		Else
			cSQL += "			SELECT '01' B1_LOCAL, * FROM SBF010 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter 
			cSQL += "			UNION ALL																																					 " + Enter 
			cSQL += "			SELECT '05' B1_LOCAL, * FROM SBF050 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = ''	 " + Enter 
			cSQL += "			UNION ALL																																					 " + Enter 
			cSQL += "			SELECT '13' B1_LOCAL, * FROM SBF130 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter 	
		EndIf
		
	EndIf
	cSQL += "		) SBF ON (SB1.B1_COD = SBF.BF_PRODUTO ) " + Enter 
	cSQL += "		INNER JOIN " + RETSQLNAME("ZZ9") +" ZZ9 ON (SBF.BF_PRODUTO  = ZZ9.ZZ9_PRODUT AND SBF.BF_LOTECTL  = ZZ9.ZZ9_LOTE)  " + Enter 
	cSQL += "	 " + Enter 
	cSQL += "		WHERE   " + Enter 
	cSQL += "		SB1.B1_FILIAL	= '  '		AND	 " + Enter 
	cSQL += "		ZZ9.ZZ9_FILIAL	= '  '		AND 														 " + Enter 
	cSQL += "		SB1.D_E_L_E_T_	= ''		AND															 " + Enter 
	cSQL += "		ZZ7.D_E_L_E_T_	= ''		AND " + Enter 
	cSQL += "		SB1.B1_YACESS	<> 'S'		AND  " + Enter 
	cSQL += "		ZZ7.ZZ7_EMP		IN "+cInMarca+"	AND " + Enter 

	If lAmostra

		cSQL += "		SBF.BF_LOTECTL = 'AMT'		AND  " + Enter 
	
	Else
	
		cSQL += "		SBF.BF_LOTECTL NOT IN ('AMT','IMP')		AND  " + Enter 
	
	EndIf
		
	cSQL += "		(SUBSTRING(SBF.BF_LOCALIZ,1,8)	<> 'P. DEVOL' AND SUBSTRING(SBF.BF_LOCALIZ,1,3)	NOT IN ('CLA','PAP'))  " + Enter 		
	
	cSQL += "	) " + Enter 
	cSQL += "	PROD " + Enter 
	cSQL += "	LEFT JOIN " + RETSQLNAME("ZZ8") +" ZZ8 ON PROD.B1_YCLASSE = ZZ8.ZZ8_COD 			 " + Enter 
	cSQL += "	GROUP BY B1_YCLASSE, ZZ8.ZZ8_DESC, DESCRICAO, B1_COD, B1_COD, B1_LOCAL, LOTE, LOTE_ORI  " + Enter 
	cSQL += "	 " + Enter 
	cSQL += "	 " + Enter 
	cSQL += "	UNION ALL " + Enter 
	cSQL += "	 " + Enter 
	cSQL += "	 " + Enter 
	cSQL += "	SELECT  " + Enter 
	cSQL += "		B1_COD,  " + Enter 
	cSQL += "		B1_COD AS PRODUTO,  " + Enter 
	cSQL += "		0 AS CONV,  " + Enter 
	cSQL += "		B1_DESC AS DESCRICAO,  " + Enter 
	cSQL += "		'' as LOTE,  " + Enter 
	cSQL += "		'' AS EMP,  " + Enter 
	cSQL += "		'' as LOTE_ORI,  " + Enter 
	cSQL += "		'' AS RUA,  " + Enter 
	cSQL += "		0 AS QUANTIDADE,  " + Enter 
	cSQL += "		0 AS EMPENHO,  " + Enter 
	cSQL += "		0 AS DISPONIVEL,  " + Enter 
	cSQL += "		0 AS CAIXA,  " + Enter 
	cSQL += "		B1_YCLASSE,  " + Enter 
	cSQL += "		ZZ8.ZZ8_DESC AS DESC_CLASSE,  " + Enter 
	cSQL += "	 	PEDCART = '', GERAITEM = 'N',                                                       " + Enter 
	
	If cEmpresa $ "01_05"
		cSQL += "    SALDOOP = ISNULL((select [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_01]('01',SB1.B1_COD ,'','',1)),0)  "+Enter
	ElseIf(cEmpresa $ "07")
		cSQL += "    SALDOOP = ISNULL((select [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_13]('01',SB1.B1_COD ,'','',1)),0)  "+Enter
	Else
		cSQL += "    SALDOOP = ISNULL((select [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_"+AllTrim(CEMPANT)+"]('01',SB1.B1_COD ,'','',1)),0)  "+Enter
	EndIf
	
	cSQL += "	FROM " + RETSQLNAME("SB1") +" SB1 WITH(NOLOCK)  " + Enter 
	cSQL += "	LEFT JOIN  " + RETSQLNAME("ZZ8") +" ZZ8 ON SB1.B1_YCLASSE = ZZ8.ZZ8_COD and ZZ8.D_E_L_E_T_= ''                                                     " + Enter 
	cSQL += "	INNER JOIN " + RETSQLNAME("ZZ6") +" ZZ6 WITH(NOLOCK) ON ZZ6.ZZ6_COD = SB1.B1_YFORMAT AND ZZ6.D_E_L_E_T_ = ''	 " + Enter 
	cSQL += "	INNER JOIN " + RETSQLNAME("ZZ7") +" ZZ7 ON (SB1.B1_YLINHA		= ZZ7.ZZ7_COD AND SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ)  " + Enter 
	cSQL += "			            			     " + Enter 
	cSQL += "	WHERE   " + Enter 
	cSQL += "	SB1.D_E_L_E_T_ = ''			AND " + Enter 
	cSQL += "	B1_YCLASSE  = '1'		     AND                                                                                                                   " + Enter 
	
	If cEmpresa $ "01_05"
		cSQL += "	ISNULL((SELECT [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_01]('01',SB1.B1_COD ,'','',1)),0) > 0	AND												 " + Enter 
	ElseIf(cEmpresa $ "07")
		cSQL += "	ISNULL((SELECT [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_13]('01',SB1.B1_COD ,'','',1)),0) > 0	AND												 " + Enter 
	Else
		cSQL += "	ISNULL((SELECT [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_"+AllTrim(CEMPANT)+"]('01',SB1.B1_COD ,'','',1)),0) > 0	AND												 " + Enter 
	EndIf
	
	cSQL += "	ISNULL(( " + Enter 
	cSQL += "		SELECT SUM(BF_QUANT - BF_EMPENHO)                                                                                                  " + Enter 
	cSQL += "	 		FROM SBF010	SBF                                                                                                          " + Enter 
	cSQL += "		WHERE  " + Enter 

	If lAmostra
	
		cSQL += "			BF_LOCAL = '05'					AND  " + Enter 
		
	Else
	
		cSQL += "			BF_LOCAL IN ('02','04')					AND  " + Enter 
	
	EndIf
	
	cSQL += "			BF_PRODUTO = SB1.B1_COD					AND                                                                                                             " + Enter 
	cSQL += "	 		BF_LOCALIZ IN ('ZZZZ','P. DEVOL')		AND                                                                                                        " + Enter 
	cSQL += "	 		SBF.D_E_L_E_T_ = ''                                                                                                                      " + Enter 
	cSQL += "		GROUP BY BF_PRODUTO),0) <= 0	 AND  " + Enter 
	
	If cEmpresa $ "05_13"
		cSQL += "	ISNULL(( " + Enter 
		cSQL += "		SELECT SUM(BF_QUANT - BF_EMPENHO)                                                                                                  " + Enter 
		cSQL += "	 		FROM  " + RETSQLNAME("SBF") +"	SBF                                                                                                          " + Enter 
		cSQL += "	 	WHERE  " + Enter 

		If lAmostra
		
			cSQL += "			BF_LOCAL = '05'					AND  " + Enter 
			
		Else
		
			cSQL += "			BF_LOCAL IN ('02','04')					AND  " + Enter 
		
		EndIf
				
		cSQL += "	 		BF_PRODUTO = SB1.B1_COD                 AND                                                                                                 " + Enter 
		cSQL += "	 		BF_LOCALIZ IN ('ZZZZ','P. DEVOL')       AND                                                                                                 " + Enter 
		cSQL += "	 		SBF.D_E_L_E_T_ = ''                                                                                                                      " + Enter 
		cSQL += "	 	GROUP BY BF_PRODUTO),0) <= 0	AND	  	 " + Enter 
	EndIf
	
	If cEmpresa != "07"
		cSQL += "	dbo.FN_SALDOPEDIDO('01' ,B1_COD) <= 0		AND          		 " + Enter 
	
		If cEmpresa $ "05_13"
			cSQL += "	dbo.FN_SALDOPEDIDO('"+AllTrim(CEMPANT)+"' ,B1_COD) <= 0       AND    		 " + Enter 
		EndIf
	
	Else
		cSQL += "	dbo.FN_SALDOPEDIDO('07' ,B1_COD) <= 0		AND          		 " + Enter 
	EndIf
	
	cSQL += "	ZZ7_EMP in "+cInMarca+" " + Enter 
	cSQL += "	GROUP BY B1_COD, B1_DESC, B1_YCLASSE, ZZ8_DESC                                                                                                 " + Enter 
	cSQL += "	) EST " + Enter 
	
	//(Thiago - 02/04/15) -> Trazer a data dos lotes
	cSQL += " LEFT JOIN
	If cEmpAnt $ "01_05"
		cSQL += " ((SELECT '01' EMP, B8_PRODUTO, B8_LOTECTL, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 					"  + Enter
		cSQL += "  FROM  SB8010 																										"  + Enter
		cSQL += " WHERE D_E_L_E_T_ = ''																									"  + Enter
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL	)																					"  + Enter
		cSQL += " UNION 																												"  + Enter
		cSQL += " (SELECT '05' EMP, B8_PRODUTO, B8_LOTECTL, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 					"  + Enter
		cSQL += "  FROM  SB8050   																										"  + Enter
		cSQL += " WHERE D_E_L_E_T_ = ''																									"  + Enter
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL	)																					"  + Enter
		cSQL += " UNION 																												"  + Enter
		cSQL += " (SELECT '13' EMP, B8_PRODUTO, B8_LOTECTL, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 					"  + Enter
		cSQL += "  FROM  SB8130   																										"  + Enter
		cSQL += " WHERE D_E_L_E_T_ = ''																									"  + Enter
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL	))SB8																				"  + Enter
	Else
		cSQL += " (SELECT '"+cEmpAnt+"' EMP, B8_PRODUTO, B8_LOTECTL, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 			"  + Enter
		cSQL += " FROM " +RETSQLNAME("SB8") + "																							"  + Enter
		cSQL += " WHERE D_E_L_E_T_ = '' 																								"  + Enter
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL	)SB8																				"  + Enter
	EndIf
	
	cSQL += " ON SB8.B8_PRODUTO  = EST.B1_COD	AND	 																					"  + Enter
	cSQL += " 	 SB8.B8_LOTECTL  = EST.LOTE_ORI 	AND																					"  + Enter
	cSQL += "	 SB8.EMP		 = EST.EMP																								"  + Enter
	
	cSQL += "	WHERE (SALDOOP > 0 OR ( QUANTIDADE - EMPENHO) > 0  OR  PEDCART > 0)  " + Enter 
	
	// Tiago Rossini Coradini - 17/10/16 - OS: 3364-16 - Raul Viana - Adicionado filtro de produtos com formato diferente de C1
	cSQL += " 	AND SUBSTRING(B1_COD, 1, 2) <> 'C1' "  + Enter
	
	If lDebug
		//cSQL += " AND PRODUTO = 'BD0296E1' "  + Enter
	EndIf
	
	cSQL += "	ORDER BY B1_YCLASSE, DESCRICAO, B1_COD, DISPONIVEL "

	
Return cSQL


Static Function SqlOp(pProduto)
	Local cSQL := ""

	If cEmpresa == "07"
		cSQL += "SELECT * FROM [FNC_ROP_PESQUISA_OP_EMP]('13','','','','', '"+pProduto+"','',0,'S','','','')"
	Else
		cSQL += "SELECT * FROM [FNC_ROP_PESQUISA_OP_EMP]('01','','','','', '"+pProduto+"','',0,'S','','','')"
	EndIf
	
	/*cSQL += " SELECT C2_NUM,C2_PRODUTO , C2_YDTDISP, SALDO = SUM(dbo.FNC_ROP_CALC_SALDO_OP_"+AllTrim(CEMPANT)+"(C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,'','',1)) "+ Enter
	cSQL += " FROM " + RETSQLNAME("SC2") + " SC2 WITH(NOLOCK)                                                                   "+ Enter
	cSQL += " WHERE C2_FILIAL	='"+xFilial("SC2")+"'  																			"+ Enter
	cSQL += " AND C2_PRODUTO 	= '"+pProduto+"'                                                                              	"+ Enter
	cSQL += " AND C2_DATRF 		= ''                                                                                            "+ Enter
	cSQL += " AND SC2.D_E_L_E_T_ 	= ''                                                                                        "+ Enter
	cSQL += " AND dbo.FNC_ROP_CALC_SALDO_OP_"+AllTrim(CEMPANT)+"(C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,'','',1) > 0				"+ Enter
	cSQL += " GROUP BY C2_NUM,C2_PRODUTO , C2_YDTDISP                                                                           "+ Enter 

	If cEmpresa $ "01_05"	

		cSQL += " UNION ALL "  + Enter	

		cSQL += " SELECT C2_NUM,C2_PRODUTO , C2_YDTDISP, SALDO = SUM(dbo.FNC_ROP_CALC_SALDO_OP_"+If (cEmpresa == "01", "05", "01")+"(C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,'','',1)) "+ Enter
		cSQL += " FROM SC2"+ If (cEmpresa == "01", "05", "01") +"0"+" SC2 WITH(NOLOCK)                                                                   "+ Enter
		cSQL += " WHERE C2_FILIAL	='"+xFilial("SC2")+"'  																			"+ Enter
		cSQL += " AND C2_PRODUTO 	= '"+pProduto+"'                                                                              	"+ Enter
		cSQL += " AND C2_DATRF 		= ''                                                                                            "+ Enter
		cSQL += " AND SC2.D_E_L_E_T_ 	= ''                                                                                        "+ Enter
		cSQL += " AND dbo.FNC_ROP_CALC_SALDO_OP_"+If (cEmpresa == "01", "05", "01")+"(C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,'','',1) > 0	"+ Enter
		cSQL += " GROUP BY C2_NUM,C2_PRODUTO , C2_YDTDISP                                                                           "+ Enter 

	EndIf
	*/
	
Return cSQL