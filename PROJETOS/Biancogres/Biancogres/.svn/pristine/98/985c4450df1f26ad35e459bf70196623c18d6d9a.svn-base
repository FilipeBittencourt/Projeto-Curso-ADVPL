#DEFINE CALEND_POS_DATA       1
#DEFINE CALEND_POS_TIPO_MARC  4
#DEFINE CALEND_POS_ORDEM      1

#Include "TOPCONN.CH"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include "Ap5Mail.ch"
#Include "tbiconn.ch"
#Include 'FONT.CH'
#Include 'COLORS.CH'
#Include "FOLDER.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'MATA200.CH'
#INCLUDE 'DBTREE.CH'

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA284
Empresa   := Biancogres Cerâmica S/A
Data      := 27/02/12
Uso       := Ponto Eletrônico
Aplicação := Envio de e-mail contendo Ocorrências de Registro de Ponto
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA284()

	Local xt

	//Private xPrimeiro
	Private xPriPntHE
	Private	xPriPntOU

	//Private xEnviaM
	Private xEnvMailHE
	Private xEnvMailOU

	Private WF001
	Private zp_EpAtu
	Private cArqHtml := "\P10\workflow\Ponto.html"

	Private fHtml

	Private cHtml	:= ""
	Private cHtlmHE := ""
	Private cHtlmOU := ""

	Private aMailHex 	:= {}
	Private aMailOutros := {}

	Private lInicio := .F.

	cv_ViaWf := .F.
	If Select("SX6") == 0

		xv_Emps    := U_BAGtEmpr("01_05")
		For xt := 1 To Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)

			RPCSetEnv(xv_Emps[xt,1], xv_Emps[xt,2], "", "", "PON", "",{"SRA","SRX","SP4","SPC","SP9","SP8"})

			cv_ViaWf := .T.
			zp_EpAtu := xv_Emps[xt,1]
			MV_PAR01 := dDataBase - 1
			MV_PAR02 := dDataBase - 1
			MV_PAR03 := "      "
			MV_PAR04 := "ZZZZZZ"
			MV_PAR05 := ""
			MV_PAR06 := 2
			ConOut("HORA: "+TIME()+" - Iniciando Processo BIA284 " + xv_Emps[xt,1])

			Processa({||BGEvMlHr()})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIA284 " + xv_Emps[xt,1])

			RpcClearEnv()

		Next xt

	Else

		zp_EpAtu := cEmpAnt
		cHInicio := Time()
		fPerg := "BIA284"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		ValidPerg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		Processa({||BGEvMlHr()})

	EndIf

Return

//**********************************************************************************************
//**                                                                                          **
//**********************************************************************************************
Static Function BGEvMlHr()

	Local nMar
	Local nFor

	nTipHoras  := 3
	lImpMar    := .T.
	Li         := 0
	lCabec     := .F.
	lCabecCC   := .F.
	lCabecTT   := .F.
	lImpFol	   := .F.
	aTabPadrao := {}
	xSalMin    := 0

	wtTotHrHE    := 0
	wtToVlrHE    := 0

	wtTotHrOU    := 0
	wtToVlrOU    := 0

	lTemHE := .F.
	lTemOU := .F.

	A0001 := " SELECT CONVERT(NUMERIC, RX_TXT, 2) MINIMO
	A0001 += "   FROM " + RetSqlName("SRX")
	A0001 += "  WHERE RX_TIP = '11'
	A0001 += "    AND ( SUBSTRING(RX_COD,9,6) = '"+Substr(dtos(MV_PAR02),1,6)+"' OR SUBSTRING(RX_COD,9,6) = '      ')
	A0001 += "    AND D_E_L_E_T_ = ' '
	IF chkfile("A001")
		dbSelectArea("A001")
		dbCloseArea()
	ENDIF
	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	xSalMin    := A001->MINIMO
	A001->(dbCloseArea())

	DbSelectArea("SRA")

	If !fTabTurno(aTabPadrao)
		Return Nil
	EndIf

	A0007 := " SELECT RA_YSEMAIL, "
	A0007 += "        RA_NOME, "
	A0007 += "        R_E_C_N_O_ REGSRA "
	A0007 += "   FROM " + RetSqlName("SRA") + " "
	A0007 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"' "
	A0007 += "    AND RA_MAT BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	A0007 += "    AND RA_SITFOLH <> 'D' "
	A0007 += "    AND RA_YMOTBLQ <> 'D' "
	A0007 += "    AND RA_YSEMAIL <> ' ' "
	If !Empty(MV_PAR05)
		A0007 += "    AND RA_YSEMAIL = '"+Alltrim(MV_PAR05)+"' "
	EndIf
	A0007 += "    AND RA_REGRA IN('07','08','09') "
	A0007 += "    AND D_E_L_E_T_ = ' ' "
	A0007 += "  ORDER BY RA_YSEMAIL, RA_NOME "
	IF chkfile("A007")
		dbSelectArea("A007")
		dbCloseArea()
	ENDIF
	TCQUERY A0007 New Alias "A007"
	dbSelectArea("A007")
	dbGoTop()
	If !cv_ViaWf
		ProcRegua(RecCount())
	EndIf

	lInicio := .T.

	If file(cArqHtml)
		FErase(cArqHtml)
	EndIf

	fHtml := fCreate(cArqHtml)

	While !Eof()

		If lInicio
			cHtmlHE := ""
			cHtmlOU := ""
			cHtml := ""
			lInicio := .F.
		Else
		EndIF

		xEnvMailHE := .F.
		xEnvMailOU := .F.

		xEmailRf := A007->RA_YSEMAIL

		While !Eof() .and. A007->RA_YSEMAIL == xEmailRf

			dbSelectArea("SRA")
			dbSetOrder(1)
			dbGoTo(A007->REGSRA)

			If !cv_ViaWf
				IncProc()
			EndIf

			dDtMarc  := ctod("  /  /  ")
			cTnoAnt  := SRA->RA_TNOTRAB
			cSeqAnt  := SRA->RA_SEQTURN

			//-- Cria Calendario com o periodo completo com Trocas de Turno
			aTabCalend := {} ; aTurnos   := {} ; aMarcacoes := {}

			//-- Carrega as Marcacoes do Periodo
			If !GetMarcacoes( @aMarcacoes		,;	//Marcacoes dos Funcionarios
			@aTabCalend		                ,;	//Calendario de Marcacoes
			@aTabPadrao		                ,;	//Tabela Padrao
			@aTurnos			            ,;	//Turnos de Trabalho
			MV_PAR01                        ,;	//Periodo Inicial
			MV_PAR02 	                    ,;	//Periodo Final
			SRA->RA_FILIAL	                ,;	//Filial
			SRA->RA_MAT		                ,;	//Matricula
			SRA->RA_TNOTRAB	                ,;	//Turno
			SRA->RA_SEQTURN	                ,;	//Sequencia de Turno
			SRA->RA_CLVL	                ,;	//Centro de Custo
			"SP8"				            ,;	//Alias para Carga das Marcacoes
			.F.    			                ,;	//Se carrega Recno em aMarcacoes
			.T.      			            ,;	//Se considera Apenas Ordenadas
			.T.      			            ,;	//Se Verifica as Folgas Automaticas
			.F.      			            ;	//Se Grava Evento de Folga Automatica Periodo Anterior
			)
				SRA->(dbSkip())
				Loop
			EndIf

			//-- Obtem Qtde de Marcacoes
			nLenMarc := Len(aMarcacoes)

			aDet := {}

			// 1 - Data
			// 2 - Codigo do Evento
			// 3 - Descricao do Evento
			// 4 - Quantidade de horas Abonadas
			// 5 - Marcacoes

			dRef := ctod("  /  /  ")

			wtTotHrHE    := 0
			wtToVlrHE    := 0

			wtTotHrOU    := 0
			wtToVlrOU    := 0

			dbSelectArea("SPC")
			dbSetOrder(1)
			If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT )
				While !Eof() .and. SPC->PC_FILIAL+SPC->PC_MAT == SRA->RA_FILIAL+SRA->RA_MAT

					If !Empty(SPC->PC_ABONO)
						dbSelectArea("SPC")
						DbSkip()
						Loop
					EndIf

					// Exceção confirmada por Claudia em 23/04/12 por e-mail. Neste, ela exclui as verbas 209 e 358. Porém, a rotina está posicionada em tabelas do ponto e portanto, foi necessário
					// converter em ID de Evento.
					If SPC->PC_PD $ "115_133_142"
						dbSelectArea("SPC")
						DbSkip()
						Loop
					EndIf

					//-- Verifica o Periodo Solicitado
					If Empty(SPC->PC_DATA) .OR. SPC->PC_DATA < MV_PAR01 .OR. SPC->PC_DATA > MV_PAR02
						dbSkip()
						Loop
					Endif

					If dRef # SPC->PC_DATA
						dRef := SPC->PC_DATA
						aAutorizado := {}
						If Ascan(aTabCalend,{ |x| DtoS(x[1]) == DtoS(dRef) }) > 0
							If SP4->( dbSeek( ( cFilSP4 := If(Empty(xFilial('SP4')), xFilial('SP4'), SRA->RA_Filial) ) + ( cTno := SRA->RA_TnoTrab ) ) ) .Or. ;
							SP4->( dbSeek( ( cFilSP4 := If(Empty(xFilial('SP4')), xFilial('SP4'), SRA->RA_Filial) ) + ( cTno := Space(3)        ) ) )
								While !SP4->(Eof()) .And. cFilSP4 + cTno == SP4->P4_FILIAL + SP4->P4_TURNO
									Aadd(aAutorizado,{SP4->P4_CODAUT, If(SP9->(dbSeek(fFilFunc('SP9')+SP4->P4_CODAUT)),SP9->P9_DESC,Space(20)), (SP4->P4_PERCENT+100)/100 })
									Aadd(aAutorizado,{SP4->P4_CODNAUT, If(SP9->(DbSeek(fFilFunc('SP9')+SP4->P4_CODNAUT)),SP9->P9_DESC,Space(20)), (SP4->P4_PERCENT+100)/100 })
									SP4->(dbSkip())
								End
							Endif
							cCod029A := PosSP9("029A",SRA->RA_FILIAL,"P9_IDPON",2)
							If !Empty(cCod029A)
								Aadd(aAutorizado,{SP9->P9_CODIGO, SP9->P9_DESC, 1})
							Endif
							cCod025A := PosSP9("025A",SRA->RA_FILIAL,"P9_IDPON",2)
							If !Empty(cCod025A)
								Aadd(aAutorizado,{SP9->P9_CODIGO, SP9->P9_DESC, 1})
							Endif
							// Especifico para este relatório
							cCod008A := PosSP9("008A",SRA->RA_FILIAL,"P9_IDPON",2)
							If !Empty(cCod008A)
								Aadd(aAutorizado,{SP9->P9_CODIGO, SP9->P9_DESC, -1})
							Endif
							cCod010A := PosSP9("010A",SRA->RA_FILIAL,"P9_IDPON",2)
							If !Empty(cCod010A)
								Aadd(aAutorizado,{SP9->P9_CODIGO, SP9->P9_DESC, -1})
							Endif
							cCod012A := PosSP9("012A",SRA->RA_FILIAL,"P9_IDPON",2)
							If !Empty(cCod012A)
								Aadd(aAutorizado,{SP9->P9_CODIGO, SP9->P9_DESC, -1})
							Endif
							cCod014A := PosSP9("014A",SRA->RA_FILIAL,"P9_IDPON",2)
							If !Empty(cCod014A)
								Aadd(aAutorizado,{SP9->P9_CODIGO, SP9->P9_DESC, -1})
							Endif
							cCod020A := PosSP9("020A",SRA->RA_FILIAL,"P9_IDPON",2)
							If !Empty(cCod020A)
								Aadd(aAutorizado,{SP9->P9_CODIGO, SP9->P9_DESC, -1})
							Endif
						Endif
					Endif

					//-- Quando houver codigo informado, este sera utilizado
					//-- em substituicao ao codigo apontado
					cPD := If(Empty(SPC->PC_PDI),SPC->PC_PD, SPC->PC_PDI)

					//-- Verifica se eh um codigo contido na relacao de codigos
					//-- definidas segundo avariavel cCodigos
					nPos := Ascan(aAutorizado,{ |x| x[1] = cPD })

					//-- Se o Codigo do Evento apontado  eh Valido
					If nPos > 0

						//-- Obtem a quantidade do evento apontando
						xQuant := If(SPC->PC_QUANTI>0,SPC->PC_QUANTI,SPC->PC_QUANTC)
						//-- Posiciona na TabCalend para a Data Lida
						nTab := aScan(aTabCalend, {|x| x[CALEND_POS_DATA] == SPC->PC_DATA .And. x[CALEND_POS_TIPO_MARC] == '1E' })

						//-- Se existir calendario para o apontamento
						//-- Obs.: Se um apontamento for digitado pode ocorrer de nao ter
						//--       uma data correspondente na TabCalend ???
						If nTab>0

							//-- Obtem a Ordem para a Data Lida
							cOrdem    := aTabCalend[nTab,CALEND_POS_ORDEM] //-- Ordem
							aMarcFun:={}

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Obtem as Marcacoes Realizadas para a Ordem Lida³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lImpMar
								AY001 := " SELECT P8_TPMARCA, P8_HORA
								AY001 += "   FROM " + RetSqlName("SP8")
								AY001 += "  WHERE P8_FILIAL = '"+xFilial("SP8")+"'
								AY001 += "    AND P8_MAT = '"+SRA->RA_MAT+"'
								AY001 += "    AND P8_DATAAPO = '"+dtos(cOrdem)+"'
								AY001 += "    AND P8_TPMCREP = ' '
								AY001 += "    AND D_E_L_E_T_ = ' '
								AY001 += "  ORDER BY P8_TPMARCA

								IF chkfile("AY01")
									dbSelectArea("AY01")
									dbCloseArea()
								ENDIF
								TCQUERY AY001 New Alias "AY01"
								dbSelectArea("AY01")
								dbGoTop()
								ProcRegua(RecCount())
								While !Eof()
									Aadd(aMarcFun,StrTran(StrZero(AY01->P8_HORA,5,2),'.',':'))
									dbSelectArea("AY01")
									dbSkip()
								End
								AY01->(dbCloseArea())
							Endif

						Endif

						xVlrBas := SRA->RA_SALARIO + IIF(SRA->RA_PERICUL <> 0, SRA->RA_SALARIO*30/100, 0) + IIF(SRA->RA_INSMED <> 0, xSalMin*20/100, 0) + IIF(SRA->RA_INSMAX <> 0, xSalMin*40/100, 0)
						xVlrBas := xVlrBas/SRA->RA_HRSMES

						//aAdd(aDet,{ SPC->PC_DATA, aAutorizado[nPos,1], aAutorizado[nPos,2] , xQuant, aMarcFun , xQuant * aAutorizado[nPos,3] * xVlrBas })  // Retirado em 13/04/16 Por Marcos Alberto Soprani - OS 1308-16
						aAdd(aDet,{ SPC->PC_DATA, aAutorizado[nPos,1], aAutorizado[nPos,2] , xQuant, aMarcFun , ( INT(xQuant) + Round(( MOD(xQuant,1) / 60 * 100 ),2) ) * aAutorizado[nPos,3] * xVlrBas })
					Endif
					dbSelectArea("SPC")
					DbSkip()
				End

				If Len(aDet) > 0
					aSort(aDet,,,{|x,y| x[1] < y[1] })
					//xPrimeiro := .T.
					xPriPntHE := .T.
					xPriPntOU := .T.

					lTemHE := .F.
					lTemOU := .F.

					For nFor := 1 To Len(aDet)
						cDet  := ""
						cDet2 := ""	// Impressao da Continuacao das Marcacoes

						If lImpMar //.and. dDtMarc <> aDet[nFor,1] // Retirado em 10/03/16 por Marcos Alberto Soprani em atendimento a OS 0901-16
							aMarc   := aDet[nFor,5]
							dDtMarc := aDet[nFor,1]
							For nMar := 1 to Len(aMarc)
								If nMar > 8
									cDet2 += aMarc[nMar]+" "
								Else
									cDet += aMarc[nMar]+" "
								Endif
							Next
						Endif
						cDet  := Padr(cDet,49)
						cDet2 := Padr(cDet2,49)

						xQuant := StrZero(aDet[nFor,4],6,2)
						xQuant := STRTRAN(xQuant,".",":")
						cDet += SubStr(Dtos(aDet[nFor,1]),7,2) +"/"+ SubStr(Dtos(aDet[nFor,1]),5,2) + "  " + aDet[nFor,2] + " " + aDet[nFor,3] + " "+ xquant + " "

						//Envia um email separado quando for hora extra.
						If("H.EX" $ cDet) .OR. ("HORA EXTRA" $ cDet)
							lTemHE := .T.
							xEnvMailHE := .T.
							cHtmlHE += f284ImprL(cDet, aDet[nFor,6], .T.)

							If !Empty(cDet2)
								cHtmlHE += f284ImprL(cDet2, 0, .T.)
							Endif

							xPriPntHE := .F.
						Else
							lTemOU := .T.
							xEnvMailOU := .T.
							cHtmlOU += f284ImprL(cDet, aDet[nFor,6], .F.)

							If !Empty(cDet2)
								cHtmlOU += f284ImprL(cDet2, 0, .F.)
							Endif

							xPriPntOU := .F.
						EndIf
					Next nFor
				Endif

				If lTemHE
					cHtmlHE += Imp_FimFn(.T.)
					lTemHE 	:= .F.
				EndIf

				If lTemOU
					cHtmlOU += Imp_FimFn(.F.)
					lTemOU 	:= .F.
				EndIf
			Endif

			dbSelectArea("A007")
			dbSkip()
		End

		If xEnvMailHE
			cHtmlHE := Imp_Cabec(.T.) + cHtmlHE + Imp_Rodap()
			EnviarMail(.T.)
		EndIf

		If xEnvMailOU
			cHtmlOU := Imp_Cabec(.F.) + cHtmlOU + Imp_Rodap()
			EnviarMail(.F.)
		EndIf
	End
	A007->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------
Static Function EnviarMail(lpEhHEX)

	If MV_PAR06 == 1
		df_Dest := U_EmailWF('BIA284RH', zp_EpAtu, Alltrim(SRA->RA_CLVL))
	Else
		If (Select("SX6")== 0)
			DbSelectArea("SX6")
		EndIf
		df_Dest := U_EmailWF('BIA284', zp_EpAtu, Alltrim(SRA->RA_CLVL)) + ';' + Iif(!GETNEWPAR("MV_YWFPON",.T.),'', Alltrim(xEmailRf))
	EndIf
	df_Mens := ""

	If lpEhHEX
		df_Assu := "Ocorrências de Horas Extraordinárias - " + Alltrim(xEmailRf)
		df_Mens := cHtmlHE
	Else
		df_Assu := "Ocorrências de Registro de Ponto - " + Alltrim(xEmailRf)
		df_Mens := cHtmlOU
	EndIf
	df_Erro := "Ocorrências de Registro de Ponto não enviado. Favor verificar!!!"

	U_BIAEnvMail(, df_Dest, df_Assu, df_Mens, df_Erro)

	lInicio := .T.

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Imp_Cabec ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 27/02/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Cabeçalho de Horas Extras                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_Cabec(lpEhHEX)

	Local cRet := ''

	cRet := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	cRet += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	cRet += ' <head> '
	cRet += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	cRet += ' <title>Untitled Document</title> '
	cRet += ' <style type="text/css"> '
	cRet += ' <!-- '
	cRet += ' .style2 {color: #FFFFFF} '
	cRet += ' .style10 { '
	cRet += ' 	font-family: "Times New Roman", Times, serif; ' 
	cRet += ' 	font-size: 10px; '
	cRet += ' } '
	cRet += ' .style11 { '
	cRet += ' 	font-size: 16px; '
	cRet += ' 	font-weight: bold; '
	cRet += ' } '
	cRet += ' .style13 {font-family: "Times New Roman", Times, serif; font-size: 12px; font-weight: bold; } '
	cRet += ' .style14 {font-family: "Times New Roman", Times, serif; font-size: 12px; } '
	cRet += ' --> '
	cRet += ' </style> '
	cRet += ' </head> '
	cRet += ' <body> '
	cRet += ' <table width="775" border="0"> '
	cRet += '   <tr> '
	If(!lpEhHEX)
		cRet += '     <td width="775" height="45" class="style10"><div align="center" class="style11">Ocorrências de Registro de Ponto</div></td> '
	Else
		cRet += '     <td width="775" height="45" class="style10"><div align="center" class="style11">Ocorrências de Horas Extraordinárias</div></td> '
	EndIf
	cRet += '   </tr> '
	cRet += '   <tr> '
	cRet += '     <td width="775" height="50" class="style10"><div align="center" class="style11">'+Alltrim(SM0->M0_NOMECOM)+'</div></td> '
	cRet += '   </tr> '
	cRet += ' </table> '
	cRet += ' <p class="style10">&nbsp;</p> '
	If(!lpEhHEX)
		cRet += ' <p class="style14">Legenda(Situação):</p> '
		cRet += ' <p class="style14">  1 - Abonar;     2-Descontar;    3- Atestado médico/declaração médica;   4 - Banco de Horas.</p> '
	Else
		cRet += ' <p class="style14"> <font color="red"> Obs: Email apenas para visualização. Favor NÃO RESPONDER. </font></p> '
		cRet += ' <p class="style14"> <font color="red"> As horas excedentes (acima de 1 hora) deverão ser listadas no formulário AUTORIZAÇÃO PARA REALIZAÇÃO DE HORAS EXTRAORDINÁRIAS (UN-FO-SPE-015). </font></p> '
	EndIf

Return cRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ f284ImprL ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 27/02/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir detalhes de Horas Extras                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function f284ImprL(cString, nVlHrs, lpEhHEX)

	Local cRet := ""

	If (xPriPntHE .And. lpEhHEX) .Or. (xPriPntOU .And. !lpEhHEX)

		cRet += ' <table width="' +IIF(lpEhHEX, "725","775" ) +'" border="1" bordercolor="#000000"> '
		cRet += '   <tr> '
		cRet += '     <td width="215" class="style13">Matricula: '+SRA->RA_MAT+'</td> '
		cRet += '     <td width="545" class="style13">Classe de Valor: '+Alltrim(SRA->RA_CLVL)+'</td> '
		cRet += '   </tr> '
		cRet += '   <tr> '
		cRet += '     <td colspan="2" class="style13">Nome: '+Alltrim(SRA->RA_NOME) + Space(15) + '( ' + Alltrim(SRA->RA_PIS) + ' )' + '</td> '
		cRet += '   </tr> '
		cRet += ' </table> '
		cRet += ' <table width="' +IIF(lpEhHEX, "725","775" ) +'" border="1" bordercolor="#000000"> '
		cRet += '   <tr bordercolor="#000000" bgcolor="#0000FF"> '
		cRet += '     <td width="200" class="style10"><div align="left"><span class="style2">Marcações</span></div></td> '
		If !lpEhHEX
			cRet += '     <td width="168" class="style10"><div align="left"><span class="style2">Justificativa</span></div></td> '
		EndIf
		cRet += '     <td width="41" class="style10"><div align="center"><span class="style2">Data</span></div></td> '
		cRet += '     <td width="140" class="style10"><div align="left"><span class="style2">Descrição</span></div></td> '
		cRet += '     <td width="60" class="style10"><div align="center"><span class="style2">Horas</span></div></td> '
		cRet += '     <td width="70" class="style10"><div align="right"><span class="style2">Valor</span></div></td> '
		If !lpEhHEX
			cRet += '     <td width="50" class="style10"><div align="center" class="style2">Situação</div></td> '
		EndIf
		cRet += '   </tr> '
	EndIf

	cRet += '   <tr> '
	cRet += '     <td class="style10"><div align="left">'+Alltrim(Substr(cString,1,49))+'</div></td> ' 	//marcacao
	If !lpEhHEX
		cRet += '     <td class="style10"><div align="left" class="style2">.</div></td> '  				//justificativa
	EndIf
	cRet += '     <td class="style10"><div align="center">'+Alltrim(Substr(cString,50,6))+'</div></td> '//data
	cRet += '     <td width="' +IIF(lpEhHEX, "358","140" ) +'" class="style10"><div align="left">'+Alltrim(Substr(cString,61,20))+'</div></td>  '//descricao
	cRet += '     <td class="style10"><div align="center">'+Alltrim(Substr(cString,82,7))+'</div></td> '//horas
	cRet += '     <td "' +IIF(lpEhHEX, "120","70" ) +'" class="style10"><div align="right">'+Transform(nVlHrs, "@E 999,999.99")+'</div></td>'//valor
	If !lpEhHEX
		cRet += '     <td class="style10"><div align="center" class="style2">.</div></td> '//situacao
	EndIf
	cRet += '   </tr>

	If nVlHrs > 0
		if lpEhHEX
			wtTotHrHE    += Val(StrTran(Alltrim(Substr(cString,82,7)),':','.'))
			wtToVlrHE    += nVlHrs
		Else
			wtTotHrOU    += Val(StrTran(Alltrim(Substr(cString,82,7)),':','.'))
			wtToVlrOU    += nVlHrs
		EndIf
	EndIf

Return cRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Imp_FimFn ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 27/02/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Finalizição da Tabela dos dados do Funcionário    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_FimFn(lpEhHEX)

	Local cRet := ""

	If ((!xPriPntHE .And. lpEhHEX) .Or. (!xPriPntOU .And. !lpEhHEX))
		cRet += '   <tr> '
		cRet += '     <td colspan="' +IIF(lpEhHEX, "3","4" ) +'" class="style10"><div align="left">Totais</div></td> '
		cRet += '     <td class="style10"><div align="center">'+StrTran(StrZero(IIF(lpEhHEX, wtTotHrHE,wtTotHrOU ),5,2),'.',':')+'</div></td> '
		cRet += '     <td class="style10"><div align="right">'+Transform(IIF(lpEhHEX, wtToVlrHE,wtToVlrOU ), "@E 999,999.99")+'</div></td> '
		if !lpEhHEX
			cRet += '     <td class="style10"><div align="center" class="style2">.</div></td> '
		EndIf
		cRet += '   </tr> '
		cRet += ' </table> '
		cRet += ' <p class="style10">&nbsp;</p> '
	EndIf

Return cRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Imp_Rodap ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 27/02/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Rodapé de Horas Extras                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_Rodap()

	Local cRet := ""

	cRet += ' <p class="style10">&nbsp;</p> '
	cRet += ' <p class="style14">Informações geradas automaticamente a partir da importação dos dados do relógios de Ponto para o sistema Protheus.</p> '
	cRet += ' <p class="style14">Estas informações não foram tratadas e poderão sofrer algum tipo de tratamento durante o processo de fechamento do Ponto.</p> '
	cRet += ' <p class="style14">&nbsp;</p> '
	cRet += ' <p class="style14">Sem mais,</p> '
	cRet += ' <p class="style14">&nbsp;</p> '
	cRet += ' <p class="style14">Departamento Pessoal.</p> '
	cRet += ' <p class="style14">&nbsp;</p> '
	cRet += ' <p class="style14">E-mail enviado automaticamente pelo sistema Protheus - by BIA284.</p> '
	cRet += ' <p class="style14">&nbsp;</p> '
	cRet += ' </body> '
	cRet += ' </html> '

Return cRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs := {}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Matricula             ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"04","Ate Matricula            ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"05","Filtrar Email            ?","","","mv_ch5","C",50,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Só p/ Equipe de RH       ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
