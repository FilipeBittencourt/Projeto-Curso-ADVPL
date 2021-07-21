#include "TOTVS.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"
#Include "FileIO.ch"

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
User Function BIA496(AA_EMP, lEstAmo, cMarcaJob,cNomFile)

	Local cLoad				:= ""
	Local cFileName			:= ""
	Local lWFlow			:= .F.

	Default lEstAmo 	:= .F.
	Default cMarcaJob := ""
	Default cNomFile := ""




	If Type("DDATABASE") <> "D"
		DO CASE
		CASE ( AA_EMP == "01" )
			RPCSETENV("01","01",,,"FAT")
		CASE ( AA_EMP == "05" )
			RPCSETENV("05","01",,,"FAT")
		CASE ( AA_EMP == "07" )
			RPCSETENV("07","05",,,"FAT")
		CASE ( AA_EMP == "13" )
			RPCSETENV("13","01",,,"FAT")
		ENDCASE
		CREPATU := ""
		lWFlow  := .T.
	Else
		AA_EMP  := cEmpAnt
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
	Private lDebug 		:= .F.
	Private cInMarca 	:= "('')"
	Private lAmostra 	:= lEstAmo
	Private lRepre 		:= !EMPTY(CREPATU)
	Private lShowFil	:= .F.
	Private lManual		:= .F.
	Private cPergunta	:= "BIA999"
	PRIVATE cMarcaJB  := ""
	PRIVATE cNoArqJB  :=  cNomFile



	cLoad				:= "BIA496" + cEmpAnt
	cFileName			:= RetCodUsr() +"_"+ cLoad
	// Validar utilização do relatório para representantes.
	If !Empty(cRepAtu) .And. U_GETBIAPAR("REP_BLQRDSPR",.F.)	// BLoQeuio Relatório DiSPonibilidade Representantes.
		MsgInfo("Consulta temporariamente indisponível","BIA496")
		Return
	EndIf

	// Utilização do relatório para usuários internos.
	If Empty(cRepAtu)
		If !lWFlow	// Executar via REMOTE (MANUAL).
			lManual	 := .T.
			aPergs 	 := {}
			MV_PAR01 := SPACE(1)
			aMarca	 := {'1=Biancogres', '2=Incesa', '3=Vinílico', '4=Todas'}

			aAdd(aPergs ,{2, "Marca", MV_PAR01, aMarca, 65, ".T.", .F.})
			If !ParamBox(aPergs, "Filtro",,,,,,,, cLoad, .T., .T.)
				Return()
			EndIf

			MV_PAR01 := Val(ParamLoad(cFileName,, 1, MV_PAR01))
			Do Case
			Case (MV_PAR01 == 1)	// BIANCOGRES
				cInMarca  := "('0101','0199')" 	//cEmpresa := '01'
			Case (MV_PAR01 == 2)	// INCESA
				cInMarca  := "('0501','0599')"	//cEmpresa := '05'
			Case (MV_PAR01 == 3)	// VINILICO
				cInMarca  := "('1302')"			//cEmpresa := '07'
				lShowFil  := .T.
			OtherWise
				cInMarca  := "('0101','0199','0501','0599','1302')"	//cEmpresa := '01'
				lShowFil  := .T.
			EndCase
			cEmpresa := '01' // A emissão MANUAL SEMPRE é via empresa 01.
		Else
			If (cEmpresa == '01')
				cInMarca  := "('0101','0199')"
			ElseIf (cEmpresa == '05')
				cInMarca  := "('0501','0599')"
			ElseIf (cEmpresa == '13')
				cInMarca  := "('1302')"
				lShowFil  := .T.
			ElseIf (cEmpresa == '07')
				cInMarca  := "('1302')"
				lShowFil  := .T.
			EndIf
		EndIf
	Else

		If IsBlind() //JOB
			cMarcaJB :=  AllTrim(cMarcaJob)
			cInMarca :=  "('" + AllTrim(cMarcaJob) + "')"
		Else
			cMarcaJB := "todas"
			cInMarca := "('" + AllTrim(SA3->A3_YEMP) + "')"
		EndIf
		cInMarca :=	 StrTran(  cInMarca, "/", "','")


		If ( '1302' $ cInMarca )
			lShowFil  := .T.
		EndIf
	EndIf

	//conout('bia496-INICIADO')
	ConOut(dtoc(dDatabase) + " - " + Time() + " - BIA496 INICIADO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada de Funcoes                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTipo := '1'
	Processa({|| Calcula_EST()})

	//conout('bia496-ENCERRADO')
	ConOut(dtoc(dDatabase) + " - " + Time() + " - BIA496 FINALIZADO")

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
	Local _nCount		:= 0
	Local cPath			:= ""
	Local cTime			:= Replace(Time(),":","_")

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

	IF !IsBlind()
		cPath	:= GetTempPath()
	EndIf

	//////////////////////////

	cTime := Replace(DTOC(Date()),"/","")
	If IsBlind()
		cArqHtml := "\P10\workflow\"+cNoArqJB+"_"+cMarcaJB+"_"+cTime+".html"
		cArqCSV	 := "\P10\workflow\"+cNoArqJB+"_"+cMarcaJB+"_"+cTime+".csv"
	Else
		cArqHtml := cPath + "Estoque_"+cTime+".html"
		cArqCSV	 := cPath + "Estoque_"+cTime+".csv"
	EndIf


	//Verifica se o arquivo existe
	If IsBlind() .AND. (file(cArqCSV) .OR. File(cArqHtml))

		Envioemail(AllTrim(SA3->A3_EMAIL), "2") // O solicitante pediu que não fosse criado parâmetro para troca do layout.

	Else

		cQry := GeraSql()
		MemoWrite("\BIA496_QUERY.TXT", cQry)

		If chkfile("QRY")
			dbSelectArea("QRY")
			dbCloseArea()
		EndIf
		TCQUERY cQry ALIAS "QRY" NEW
		QRY->(DbEval({|| _nCount++ }))
		QRY->(DbGoTop())

		if _nCount == 0 .AND. IsBlind()
			return .T.
		EndIF

		DbSelectArea("QRY")
		DbGotop()
		//conout('bia496-2')
		Setprc(0,0)
		cEmailCC := ''
		cEmailCO := ''

		fHtml := fCreate(cArqHtml)
		fCSV  := fCreate(cArqCSV)
		//nHdlCSV := MSFCREATE(cArqCSV,0)

		If ( fHtml != -1 ) .AnD. ( fCSV != -1 )
			GeraArq(_nCount)
		EndIf

		DbSelectArea("QRY")
		If EoF()
			DbCloseArea()
		EndIf

	EndIf





Return

Static Function GeraArq(nCount)
	Local cImpModel := "2"	// GetMV() - O solicitante pediu que não fosse criado parâmetro para troca do layout.
	Default nCount	:= 0
	//caracter de salto de linha
	cCrLf := Chr(13) + Chr(10)

	GeraCab()

	If ( cImpModel == "1" )

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
			If ( nTotalDisp >= 0 )	// Solicitande direcionou para nao exibir negativos; os zerados, são exibidos pois muitas das vezes possuem OP.
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
	Else
		// Formatar cabeçalhos para as saídas.
		fCabGeral()
		QRY->(DbGoTop())
		ProcRegua(nCount)
		//nSaldoOp := 0
		While !EoF() // (cProdOld == QRY->PRODUTO)
			IncProc()

			//nSaldoOp += QRY->SALDOOP
			//	Não devem ser exibidos registros com disponibilidade negativa.
			If ( QRY->DISPONIVEL >= 0 ) //.Or. ( QRY->DISPONIVEL >= 0 )
				fItmGeral(cImpModel)
			EndIf

			DbSelectArea("QRY")
			DbSkip()
		End
		fFimGeral()

		FWrite(fHtml,C_HTML)
		C_HTML := ''

		DbSelectArea("QRY")

	EndIf
	If !IsBlind() //Se nao estiver sendo executado via SCHEDULE
		Carregar(cImpModel)
	Else
		Enviar(cImpModel)
	EndIf

Return

Static Function Enviar(cImpModel)

	Default cImpModel := "1"

	FWrite(fHtml,C_HTML)
	fClose(fHtml)
	fClose(fCSV)


/*
	cSQL := ""
	cSQL += "SELECT A3_COD, A3_NOME, A3_YEMP, A3_EMAIL "  + Enter
	cSQL += "FROM " + RETSQLNAME("SA3") + " SA3 "  + Enter
	cSQL += "WHERE A3_MSBLQL <> '1' "  + Enter
	DO CASE
	CASE cEmpresa == "01"
		cSQL += "AND A3_YEMP LIKE '%0101%' "  + Enter

	CASE cEmpresa == "05"
		cSQL += "AND (A3_YEMP LIKE '%0501%' OR  A3_YEMP LIKE '%0599%') "  + Enter
		//cSQL += "AND A3_COD NOT IN ('A00013')"
	CASE cEmpAnt == "07" .And. cFilAnt == '05'
		cSQL += "AND A3_YEMP = '1302' AND A3_EST = 'SP' "  + Enter
	CASE cEmpresa == "13"
		cSQL += "AND A3_YEMP LIKE '%13__%' "  + Enter
	OTHERWISE
	ENDCASE
	cSQL += "AND SA3.A3_COD =  '"+CREPATU+"' "  + Enter
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
		Envioemail("tiago@facilesistemas.com.br", cImpModel)
	else
		//Enviar só para gerentes
		lSohGer := .F.

		//Envia para os gerentes...
		//cEmail := U_EmailWF('BIA496',cEmpAnt)

		IF !EMPTY(cEmail)
			Envioemail(cEmail, cImpModel)
		ENDIF


		If !lSohGer
			WHILE !Eof()
				cEmailCC  := ''
				cEmailCO  := ''
				cEmail    := ''

				cEmail := ALLTRIM(DEST->A3_EMAIL)

				IF !EMPTY(cEmail)
					Envioemail(cEmail, cImpModel)
				ENDIF
				DbSelectArea("DEST")
				DbSkip()
			END
		EndIf

	EndIf
*/

	Envioemail(AllTrim(SA3->A3_EMAIL), cImpModel)


	//	FErase(cArqHtml)
	//	FErase(cArqCSV)


	cMensag  := ''
	cMens    := ''
	nItemPrd := 0
	//conout('bia496-10')

Return

Static Function Envioemail(cEmail, cImpModel)

	Local cNMarca := ""

	Default cImpModel	:= "1"
	Default cEmailCC	:= ""
	Default cEmailCO	:= ""

	// Email do Emissor
	cRecebe   := cEmail																// Email do(s) receptor(es)
	cRecebeCC	:= cEmailCC  												 			// Com Copia
	cRecebeCO	:= cEmailCO


	If (cEmpAnt == '01')
		cNMarca := "BIANCOGRES"
	ElseIf (cEmpAnt == '05')
		cNMarca := "INCESA"
	ElseIf (cEmpAnt == '13')
		cNMarca := "VINILICO"	//"MUNDI"
	ElseIf (cEmpAnt == '07' .or. cFilAnt == '05')
		cNMarca := "VINILICO NA LM SP"
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

	If ( cImpModel == "1" )
		cArqAnexo := cArqHtml+";"+cArqCSV
	Else
		cArqAnexo := cArqCSV
	EndIf

	//cRecebe   := "filipe.bittencourt@facilesistemas.com.br"
	//cRecebeCC := "lohayne.moreira@biancogres.com.br"

	U_BIAEnvMail(,cRecebe,cAssunto+' - '+CREPATU,cMensag,'',cArqAnexo,,cRecebeCC)


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
Static Function GeraOps(pProduto,cImpModel)

	Local aArea			:= GetArea()
	Local cSqlOp 		:= SqlOp(pProduto)
	Local aRetOP 		:= {{'-','',0}}

	Private nSaldoTot 	:= 0

	Default cImpModel	:= "1"

	If chkfile("OPS")
		dbSelectArea("OPS")
		dbCloseArea()
	EndIf
	TCQUERY cSqlOp ALIAS "OPS" NEW

	DbSelectArea("OPS")
	DbGotop()

	If !OPS->(Eof())
		aRetOP	:= {}
		If ( cImpModel == '1' )	// Parametro para definir formatação da saída.
			GeraCabOP()
		EndIf
		// OP's.
		While !OPS->(Eof())
			If ( cImpModel == '1' )
				GeraItemOP()
			Else
				aAdd(aRetOP, { ALLTRIM(OPS->OPNUM), OPS->DATADISP, OPS->SALDO })
			EndIf
			OPS->(dbSkip())
		End

		If ( cImpModel == '1' )
			GeraTotOP()
		EndIf
	EndIf

	OPS->(dbCloseArea())

	RestArea(aArea)

Return(aRetOP)
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

	if lAmostra
		cSQL += "		SALDOOP = 0 ," + Enter
	Else
		cSQL += "		SALDOOP = CASE WHEN (ROW_NUMBER() over (PARTITION BY B1_COD ORDER BY B1_COD DESC)) = 1  " + Enter
		//Fernando em 15/12/2017 - substituido o bloco de calculo de saldo de OP para usar a funcao SQL
		If cEmpresa $ "01_05"
			cSQL += "       THEN ISNULL((SELECT [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_01]('01',PROD.B1_COD ,'','',1)),0) ELSE 0 END, "  + Enter
		ElseIf(cEmpresa $ "07")
			//saldo empresa
			cSQL += "       THEN ISNULL((SELECT [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_13]('01',PROD.B1_COD ,'','',1)),0) ELSE 0 END, "  + Enter
		Else
			cSQL += "       THEN ISNULL((SELECT [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_"+AllTrim(CEMPANT)+"]('01',PROD.B1_COD ,'','',1)),0) ELSE 0 END, "  + Enter
		EndIf

	EndIf



	cSQL += "		ZZ6.ZZ6_DESC AS FORMATO, " + Enter
	cSQL += "		ZZ6.ZZ6_FORNOP AS FORNO, " + Enter
	cSQL += "		PROD.ZZ7_EMP AS MARCA, " + Enter
	cSQL += "		PROD.REFLOCAL " + Enter

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
	cSQL += "			B1_YCLASSE, " + Enter
	cSQL += "			ZZ7_EMP, " + Enter
	cSQL += "			SBF.BF_FILIAL AS REFLOCAL " + Enter
	cSQL += "		 " + Enter
	cSQL += "		FROM " + RETSQLNAME("SB1") + "  SB1  " + Enter
	cSQL += "	 " + Enter
	cSQL += "		INNER JOIN " + RETSQLNAME("ZZ7") +"  ZZ7 with(nolock) ON (SB1.B1_YLINHA		= ZZ7.ZZ7_COD AND SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ)  " + Enter
	cSQL += "		INNER JOIN ( " + Enter

	If lAmostra

		cSQL += "			SELECT '01' B1_LOCAL, * FROM SBF010 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND BF_LOCAL = '05' AND D_E_L_E_T_ = '' 	 " + Enter
		cSQL += "			UNION ALL																											 " + Enter
		cSQL += "			SELECT '05' B1_LOCAL, * FROM SBF050 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND BF_LOCAL = '05' AND D_E_L_E_T_ = ''	 " + Enter
		cSQL += "			UNION ALL																											 " + Enter
		cSQL += "			SELECT '13' B1_LOCAL, * FROM SBF130 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND BF_LOCAL = '05' AND D_E_L_E_T_ = '' 	 " + Enter
		cSQL += "			UNION ALL																											 " + Enter
		cSQL += "			SELECT '14' B1_LOCAL, * FROM SBF140 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND BF_LOCAL = '05' AND D_E_L_E_T_ = '' 	 " + Enter

	Else
		//estoque filial 05 empresa 07 vinilico
		If ( lManual .AnD. ( '1302' $ cInMarca ) .AnD. Empty(cRepAtu) )
			cSQL += "			SELECT '01' B1_LOCAL, * FROM SBF010 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter
			cSQL += "			UNION ALL																																					 " + Enter
			cSQL += "			SELECT '05' B1_LOCAL, * FROM SBF050 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = ''	 " + Enter
			cSQL += "			UNION ALL																																					 " + Enter
			cSQL += "			SELECT '07' B1_LOCAL, * FROM SBF070 WITH (NOLOCK) WHERE BF_FILIAL = '05' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter
			cSQL += "			UNION ALL																																					 " + Enter
			cSQL += "			SELECT '13' B1_LOCAL, * FROM SBF130 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter
			cSQL += "			UNION ALL																																					 " + Enter
			cSQL += "			SELECT '14' B1_LOCAL, * FROM SBF140 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter
		Else
			If(cEmpresa $ "07")
				cSQL += "			SELECT '07' B1_LOCAL, * FROM SBF070 WITH (NOLOCK) WHERE BF_FILIAL = '05' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter
			Else
				cSQL += "			SELECT '01' B1_LOCAL, * FROM SBF010 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter
				cSQL += "			UNION ALL																																					 " + Enter
				cSQL += "			SELECT '05' B1_LOCAL, * FROM SBF050 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = ''	 " + Enter
				cSQL += "			UNION ALL																																					 " + Enter
				cSQL += "			SELECT '13' B1_LOCAL, * FROM SBF130 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter
				cSQL += "			UNION ALL																																					 " + Enter
				cSQL += "			SELECT '14' B1_LOCAL, * FROM SBF140 WITH (NOLOCK) WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) <> '0000' AND BF_LOCAL <> '05' AND D_E_L_E_T_ = '' 	 " + Enter
			EndIf
		EndIf

	EndIf
	cSQL += "		) SBF ON (SB1.B1_COD = SBF.BF_PRODUTO ) " + Enter
	cSQL += "		INNER JOIN " + RETSQLNAME("ZZ9") +" ZZ9 with(nolock) ON (SBF.BF_PRODUTO  = ZZ9.ZZ9_PRODUT AND SBF.BF_LOTECTL  = ZZ9.ZZ9_LOTE)  " + Enter
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
	cSQL += "	LEFT JOIN " + RETSQLNAME("ZZ8") +" ZZ8 with(nolock) ON PROD.B1_YCLASSE = ZZ8.ZZ8_COD 			 " + Enter
	cSQL += "	LEFT JOIN " + RETSQLNAME("ZZ6") +" ZZ6 with(nolock) ON PROD.B1_YFORMAT = ZZ6.ZZ6_COD AND ZZ6.D_E_L_E_T_ = ' ' " + Enter
	cSQL += "	GROUP BY B1_YCLASSE, ZZ8.ZZ8_DESC, DESCRICAO, B1_COD, B1_COD, B1_LOCAL, LOTE, LOTE_ORI, ZZ6.ZZ6_DESC, ZZ6.ZZ6_FORNOP, PROD.ZZ7_EMP, PROD.REFLOCAL " + Enter
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
	cSQL += "	 	PEDCART = '', GERAITEM = 'N', " + Enter

	if lAmostra
		cSQL += "    SALDOOP = 0 , " + Enter
	ElseIf cEmpresa $ "01_05"
		cSQL += "    SALDOOP = ISNULL((select [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_01]('01',SB1.B1_COD ,'','',1)),0),  "+Enter
	ElseIf(cEmpresa $ "07")
		cSQL += "    SALDOOP = ISNULL((select [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_13]('01',SB1.B1_COD ,'','',1)),0),  "+Enter
	Else
		cSQL += "    SALDOOP = ISNULL((select [dbo].[FNC_ROP_CALC_SALDO_OP_PRODUTO_"+AllTrim(CEMPANT)+"]('01',SB1.B1_COD ,'','',1)),0),  "+Enter
	EndIf

	cSQL += "		ZZ6.ZZ6_DESC AS FORMATO, " + Enter
	cSQL += "		ZZ6.ZZ6_FORNOP AS FORNO, " + Enter
	cSQL += "		ZZ7.ZZ7_EMP AS MARCA, " + Enter
	cSQL += "		'' AS REFLOCAL " + Enter
	cSQL += "	FROM " + RETSQLNAME("SB1") +" SB1 WITH(NOLOCK)  " + Enter
	cSQL += "	LEFT JOIN  " + RETSQLNAME("ZZ8") +" ZZ8 with(nolock) ON SB1.B1_YCLASSE = ZZ8.ZZ8_COD and ZZ8.D_E_L_E_T_= ''                                                     " + Enter
	cSQL += "	INNER JOIN " + RETSQLNAME("ZZ6") +" ZZ6 WITH(NOLOCK) ON ZZ6.ZZ6_COD = SB1.B1_YFORMAT AND ZZ6.D_E_L_E_T_ = ''	 " + Enter
	cSQL += "	INNER JOIN " + RETSQLNAME("ZZ7") +" ZZ7 with(nolock) ON (SB1.B1_YLINHA		= ZZ7.ZZ7_COD AND SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ)  " + Enter
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
	cSQL += "	 		FROM SBF010	SBF with(nolock)                                                                                                         " + Enter
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
		cSQL += "	 		FROM  " + RETSQLNAME("SBF") +"	SBF with(nolock)                                                                                                         " + Enter
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

	If ( lManual .AnD. ( '1302' $ cInMarca ) .AnD. Empty(cRepAtu) )
		cSQL += " NOT (ISNULL((select COUNT(*) from SBF010 with(nolock) where D_E_L_E_T_ = '' AND  BF_LOCAL IN ('02','04') AND BF_LOCALIZ IN ('ZZZZ','P. DEVOL') AND BF_PRODUTO = SB1.B1_COD), 0) > 0) AND " + Enter
		cSQL += " NOT (ISNULL((select COUNT(*) from SBF050 with(nolock) where D_E_L_E_T_ = '' AND  BF_LOCAL IN ('02','04') AND BF_LOCALIZ IN ('ZZZZ','P. DEVOL') AND BF_PRODUTO = SB1.B1_COD), 0) > 0) AND " + Enter
		cSQL += " NOT (ISNULL((select COUNT(*) from SBF070 with(nolock) where D_E_L_E_T_ = '' AND  BF_LOCAL IN ('02','04') AND BF_LOCALIZ IN ('ZZZZ','P. DEVOL') AND BF_PRODUTO = SB1.B1_COD), 0) > 0) AND " + Enter
		cSQL += " NOT (ISNULL((select COUNT(*) from SBF130 with(nolock) where D_E_L_E_T_ = '' AND  BF_LOCAL IN ('02','04') AND BF_LOCALIZ IN ('ZZZZ','P. DEVOL') AND BF_PRODUTO = SB1.B1_COD), 0) > 0) AND " + Enter
		cSQL += " NOT (ISNULL((select COUNT(*) from SBF140 with(nolock) where D_E_L_E_T_ = '' AND  BF_LOCAL IN ('02','04') AND BF_LOCALIZ IN ('ZZZZ','P. DEVOL') AND BF_PRODUTO = SB1.B1_COD), 0) > 0) AND " + Enter
	Else
		If ( cEmpresa != "07" )
			cSQL += " NOT (ISNULL((select COUNT(*) from SBF010 with(nolock) where D_E_L_E_T_ = '' AND  BF_LOCAL IN ('02','04') AND BF_LOCALIZ IN ('ZZZZ','P. DEVOL') AND BF_PRODUTO = SB1.B1_COD), 0) > 0) AND " + Enter
			cSQL += " NOT (ISNULL((select COUNT(*) from SBF050 with(nolock) where D_E_L_E_T_ = '' AND  BF_LOCAL IN ('02','04') AND BF_LOCALIZ IN ('ZZZZ','P. DEVOL') AND BF_PRODUTO = SB1.B1_COD), 0) > 0) AND " + Enter
			cSQL += " NOT (ISNULL((select COUNT(*) from SBF130 with(nolock) where D_E_L_E_T_ = '' AND  BF_LOCAL IN ('02','04') AND BF_LOCALIZ IN ('ZZZZ','P. DEVOL') AND BF_PRODUTO = SB1.B1_COD), 0) > 0) AND " + Enter
			cSQL += " NOT (ISNULL((select COUNT(*) from SBF140 with(nolock) where D_E_L_E_T_ = '' AND  BF_LOCAL IN ('02','04') AND BF_LOCALIZ IN ('ZZZZ','P. DEVOL') AND BF_PRODUTO = SB1.B1_COD), 0) > 0) AND " + Enter
		Else
			cSQL += " NOT (ISNULL((select COUNT(*) from SBF070 with(nolock) where D_E_L_E_T_ = '' AND  BF_LOCAL IN ('02','04') AND BF_LOCALIZ IN ('ZZZZ','P. DEVOL') AND BF_PRODUTO = SB1.B1_COD), 0) > 0) AND " + Enter
		EndIf
	EndIf

	cSQL += "	ZZ7_EMP in "+cInMarca+" " + Enter
	cSQL += "	GROUP BY B1_COD, B1_DESC, B1_YCLASSE, ZZ8_DESC, ZZ6.ZZ6_DESC, ZZ6.ZZ6_FORNOP, ZZ7_EMP" + Enter
	cSQL += "	) EST " + Enter

	//(Thiago - 02/04/15) -> Trazer a data dos lotes
	cSQL += " LEFT JOIN
	If cEmpAnt $ "01_05"
		cSQL += " ((SELECT '01' EMP, B8_PRODUTO, B8_LOTECTL, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 					"  + Enter
		cSQL += "  FROM  SB8010 with(nolock)																							"  + Enter
		cSQL += " WHERE D_E_L_E_T_ = ''																									"  + Enter
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL	)																					"  + Enter
		cSQL += " UNION 																												"  + Enter
		cSQL += " (SELECT '05' EMP, B8_PRODUTO, B8_LOTECTL, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 					"  + Enter
		cSQL += "  FROM  SB8050  with(nolock) 																							"  + Enter
		cSQL += " WHERE D_E_L_E_T_ = ''																									"  + Enter
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL	)																					"  + Enter
		cSQL += " UNION 																												"  + Enter
		cSQL += " (SELECT '13' EMP, B8_PRODUTO, B8_LOTECTL, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 					"  + Enter
		cSQL += "  FROM  SB8130  with(nolock) 																							"  + Enter
		cSQL += " WHERE D_E_L_E_T_ = ''																									"  + Enter
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL	)																					"  + Enter
		cSQL += " UNION 																												"  + Enter
		cSQL += " (SELECT '14' EMP, B8_PRODUTO, B8_LOTECTL, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 					"  + Enter
		cSQL += "  FROM  SB8140  with(nolock) 																							"  + Enter
		cSQL += " WHERE D_E_L_E_T_ = ''																									"  + Enter
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL	))SB8																				"  + Enter
	Else
		cSQL += " (SELECT '"+cEmpAnt+"' EMP, B8_PRODUTO, B8_LOTECTL, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 			"  + Enter
		cSQL += " FROM " +RETSQLNAME("SB8") + "	with(nolock)																			"  + Enter
		cSQL += " WHERE D_E_L_E_T_ = '' 																								"  + Enter
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL	)SB8																				"  + Enter
	EndIf

	cSQL += " ON SB8.B8_PRODUTO  = EST.B1_COD	AND	 																					"  + Enter
	cSQL += " 	 SB8.B8_LOTECTL  = EST.LOTE_ORI 	AND																					"  + Enter
	cSQL += "	 SB8.EMP		 = EST.EMP																								"  + Enter

	if lAmostra
		cSQL += "	WHERE (SALDOOP = 0)  " + Enter
	else
		cSQL += "	WHERE (SALDOOP > 0 OR ( QUANTIDADE - EMPENHO) > 0  OR  PEDCART > 0)  " + Enter
	EndIf

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
		cSQL += "SELECT * FROM [FNC_ROP_PESQUISA_OP_EMP]('13','','','','', '"+ pProduto +"','',0,'S','','','')"
	Else
		cSQL += "SELECT * FROM [FNC_ROP_PESQUISA_OP_EMP]('01','','','','', '"+ pProduto +"','',0,'S','','','')"
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

/*

Impressão dos dados em formatação como tabela corrida, excel, sem quebras.

*/
Static Function fCabGeral()

	// Formato, anexo, em HTML.
	C_HTML += '         <table align="center" width="600" border="1" cellspacing="0" cellpadding="1"> '
	C_HTML += '            <tr align=center> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Forno </span></th> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Marca </span></th> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Local </span></th> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Formato </span></th> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Codigo </span></th> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Descricao </span></th> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Classe </span></th> '
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> Lote </span></th> '
	C_HTML += '               <th class = "cabtab" width="80" scope="col"> Estoque </span></th> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Numero OP </span></th> '
	C_HTML += '               <th class = "cabtab" width="50" scope="col"> Disponibilidade </span></th> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Saldo OP </span></th> '
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> Filial</span></th> '
	C_HTML += '            </tr> '

	// Formato, anexo, em EXCEL.
	FWrite(fCSV, " Forno; Marca; Local; Formato; Codigo; Descricao; Classe; Lote; Estoque; Numero OP; Disponibilidade; Saldo OP; Filial; ")
	FWrite(fCSV, cCrLf ) // Pula linha

Return


Static Function fItmGeral(cImpModel)
	Local aRetOP 		:= {{'-','',0}}	//	C- Numero OP # C- Disponibilidade # N - Saldo OP
	Local nX	 		:= 0
	Local lUsaGesEmp 	:= iIf(FindFunction("FWFilialName") .AnD. FindFunction("FWSizeFilial") /*.AnD. FWSizeFilial() > 2*/, .T., .F.)
	Local xNomeFil		:= ""
	Local aAreaEmp		:= SM0->(GetArea())

	// Com a aglutinacao dos itens:
	//	O lote a ser impresso segue o default '-' por definicao do solicitante.
	//	Produtos com mais de uma OP serão demonstrados quanto a sua disponibilidade somente na primeira linha, nas demais segue o default '-'
	//	Impressão dos dados de OP. Estes não são aglutinados.
	If (QRY->SALDOOP > 0) .AnD. !(QRY->B1_YCLASSE $ '2_3')
		aRetOP := {}
		aRetOP := GeraOps(QRY->PRODUTO, cImpModel)
	EndIf

	// Formatar anexos, com disponibilidade, e/ou projeção de produção.
	// Apresentar de forma segmentada essas configurações.
	If ( QRY->DISPONIVEL > 0 )

		// Verificar a necessidade de criação de uma nova folder.
		If lShowFil

			If lUsaGesEmp
				xNomeFil := FWFilialName(QRY->EMP, QRY->REFLOCAL, 1)
			Else
				DbSelectArea("SM0")
				SM0->(DbSetOrder(1))
				If SM0->(DbSeek( AllTrim(QRY->EMP) + QRY->REFLOCAL))
					xNomeFil := AllTrim(SM0->M0_FILIAL)
				EndIf
			EndIf

			//Quando for selecionado 4=todas. E for 0101 e 0501 não devem aparece o nome da da empresa
			if ALLTRIM(QRY->MARCA) $ "0101#0501"
				xNomeFil := ""
			EndIf

		EndIf
		// Formato, anexo, em HTML.
		C_HTML += "            <tr align=center> "
		C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->FORNO) + "</td> "
		C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(Posicione("Z37", 1, xFilial("Z37") + ALLTRIM(QRY->MARCA), "Z37_DESCR")) + "</td> "
		C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->EMP) +"</td> "
		C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->FORMATO) + "</td> "
		C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->PRODUTO) + "</td> "
		C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->DESCRICAO) + "</td> "
		C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->DESC_CLASSE) +"</td> "
		C_HTML += "               <td class='style12' width='50'scope='col'>"+ ALLTRIM(QRY->LOTE) +"</td> "
		C_HTML += "               <td class='style12' width='80'scope='col'>"+ TRANSFORM(QRY->DISPONIVEL,"@E 9,999,999.99") +"</td> "
		C_HTML += "               <td class='style12' width='60'scope='col'>"+ '-' +"</td> "
		C_HTML += "               <td class='style12' width='50'scope='col'>"+ DTOC(STOD('')) +"</td> "
		C_HTML += "               <td class='style12' width='80'scope='col'>"+ TRANSFORM(0,"@E 9,999,999.99") +"</td> "
		If lShowFil
			C_HTML += "               <td class='style12' width='80'scope='col'>"+ ALLTRIM(xNomeFil) +"</td> "
		EndIf
		C_HTML += "            </tr> "

		// Formato, anexo, em EXCEL.
		If lShowFil
			FWrite(fCSV, +ALLTRIM(QRY->FORNO)+";"+ALLTRIM(Posicione("Z37", 1, xFilial("Z37") + ALLTRIM(QRY->MARCA), "Z37_DESCR"))+";"+ALLTRIM(QRY->EMP)+";"+ ALLTRIM(QRY->FORMATO)+";"+ALLTRIM(QRY->PRODUTO)+";"+ALLTRIM(QRY->DESCRICAO)+";"+ALLTRIM(QRY->DESC_CLASSE)+";"+iIf((QRY->DISPONIVEL > 0 ),ALLTRIM(QRY->LOTE), "-")+";"+TRANSFORM(QRY->DISPONIVEL,"@E 9,999,999.99")+";"+ALLTRIM('-')+";"+DTOC(STOD(''))+";"+TRANSFORM(0,"@E 9,999,999.99")+";"+ALLTRIM(xNomeFil)+";")
		Else
			FWrite(fCSV, +ALLTRIM(QRY->FORNO)+";"+ALLTRIM(Posicione("Z37", 1, xFilial("Z37") + ALLTRIM(QRY->MARCA), "Z37_DESCR"))+";"+ALLTRIM(QRY->EMP)+";"+ ALLTRIM(QRY->FORMATO)+";"+ALLTRIM(QRY->PRODUTO)+";"+ALLTRIM(QRY->DESCRICAO)+";"+ALLTRIM(QRY->DESC_CLASSE)+";"+iIf((QRY->DISPONIVEL > 0 ),ALLTRIM(QRY->LOTE), "-")+";"+TRANSFORM(QRY->DISPONIVEL,"@E 9,999,999.99")+";"+ALLTRIM('-')+";"+DTOC(STOD(''))+";"+TRANSFORM(0,"@E 9,999,999.99")+";")
		EndIf
		FWrite(fCSV, cCrLf ) // Pula linha
	EndIf
	// OP.
	If ( ( Len(aRetOP) >= 1 .AnD. aRetOP[1][3] > 0 ) )	// .AnD. ( QRY->DISPONIVEL >= 0 ) )
		For nX := 1 To Len(aRetOP)
			// Formato, anexo, em HTML.
			C_HTML += "            <tr align=center> "
			C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->FORNO) + "</td> "
			C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(Posicione("Z37", 1, xFilial("Z37") + ALLTRIM(QRY->MARCA), "Z37_DESCR")) + "</td> "
			C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->EMP) +"</td> "
			C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->FORMATO) + "</td> "
			C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->PRODUTO) + "</td> "
			C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->DESCRICAO) + "</td> "
			C_HTML += "               <td class='style12' width='60'scope='col'>"+ ALLTRIM(QRY->DESC_CLASSE) +"</td> "
			C_HTML += "               <td class='style12' width='50'scope='col'>"+ '-' +"</td> "
			C_HTML += "               <td class='style12' width='80'scope='col'>"+ TRANSFORM(0,"@E 9,999,999.99") +"</td> "
			C_HTML += "               <td class='style12' width='60'scope='col'>"+ AllTrim(aRetOP[nX][1]) +"</td> "
			C_HTML += "               <td class='style12' width='50'scope='col'>"+ DTOC(STOD(aRetOP[nX][2])) +"</td> "
			C_HTML += "               <td class='style12' width='80'scope='col'>"+ TRANSFORM(aRetOP[nX][3],"@E 9,999,999.99") +"</td> "
			If lShowFil
				C_HTML += "               <td class='style12' width='80'scope='col'>"+ ALLTRIM(xNomeFil) +"</td> "
			EndIf
			C_HTML += "            </tr> "

			// Formato, anexo, em EXCEL.
			If lShowFil
				FWrite(fCSV, +ALLTRIM(QRY->FORNO)+";"+ALLTRIM(Posicione("Z37", 1, xFilial("Z37") + ALLTRIM(QRY->MARCA), "Z37_DESCR"))+";"+ALLTRIM(QRY->EMP)+";"+ ALLTRIM(QRY->FORMATO)+";"+ALLTRIM(QRY->PRODUTO)+";"+ALLTRIM(QRY->DESCRICAO)+";"+ALLTRIM(QRY->DESC_CLASSE)+";"+"-"+";"+TRANSFORM(0,"@E 9,999,999.99")+";"+ALLTRIM(aRetOP[nX][1])+";"+DTOC(STOD(aRetOP[nX][2]))+";"+TRANSFORM(aRetOP[nX][3],"@E 9,999,999.99")+";"+' '+";")
			Else
				FWrite(fCSV, +ALLTRIM(QRY->FORNO)+";"+ALLTRIM(Posicione("Z37", 1, xFilial("Z37") + ALLTRIM(QRY->MARCA), "Z37_DESCR"))+";"+ALLTRIM(QRY->EMP)+";"+ ALLTRIM(QRY->FORMATO)+";"+ALLTRIM(QRY->PRODUTO)+";"+ALLTRIM(QRY->DESCRICAO)+";"+ALLTRIM(QRY->DESC_CLASSE)+";"+"-"+";"+TRANSFORM(0,"@E 9,999,999.99")+";"+ALLTRIM(aRetOP[nX][1])+";"+DTOC(STOD(aRetOP[nX][2]))+";"+TRANSFORM(aRetOP[nX][3],"@E 9,999,999.99")+";")
			EndIf
			FWrite(fCSV, cCrLf ) // Pula linha
		Next
	EndIf

	RestArea(aAreaEmp)
Return


Static Function fFimGeral()

	// Formato, anexo, em HTML.
	C_HTML += "		</table> "
	C_HTML += "      </body> "
	C_HTML += "   </html> "

	// Formato, anexo, em EXCEL.
	FWrite(fCSV, cCrLf ) // Pula linha

Return


Static Function Carregar(cImpModel)
	Local oExcel := Nil
	Local cPath	 := GetTempPath()
	Local cArq	 := ""
	Local CrLf

	Default cImpModel := "1"

	fClose(fCSV)

	If !Empty(cArqCSV)
		cArq := StrToKarr(cArqCSV, "\")
		cArq := cArq[Len(cArq)]
		If __CopyFile( cArqCSV, cPath + cArq )
			CrLf := Chr(13) + Chr(10)
			If ! ApOleClient( 'MsExcel' )
				MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+ cPath + cArq )
			Else
				oExcel := MsExcel():New()
				oExcel:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
				oExcel:SetVisible(.T.)
			EndIf
		Else
			MsgAlert("Não será possível a carga do arquivo, somente o envio por e-mail.")
		EndIf
		//FErase(cArqCSV)
		//DelClassINt(oExcel)
	EndIf

Return
