#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := FERNANDO ROCHA
Autor(rev):= Marcos Alberto Soprani
Programa  := BIAPNA01
Empresa   := Biancogres Cer‚mica S/A
Data      := 26/01/16
Uso       := Ponto EletrÙnico
AplicaÁ„o := Rotina - compensacao de banco de horas
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIAPNA01()

	Local aRet 		:= {"","","",CTOD(" "),0,0}

	Private cFilSel 	:= Space(2)
	Private cMatDe		:= Space(6)
	Private cMatAte		:= Space(6)
	Private dDataFim	:= CTOD(" ")
	Private nSaldo		:= "1"
	Private nFechamento := "1"

	Private nDiasLim 	:= GetNewPar("MV_YDIASBH", 90)
	Private xCtrlFch    := stod(Substr(GetNewPar("MV_PONMES", "20160211/20160310"),10,8))    // Por Marcos Alberto Soprani em 25/04/16...

	Aviso('BIAPNA01', 'ATEN«√O!!!'+CRLF+'Esta rotina faz o processamentos das compensaÁıes do ponto com banco de horas, executar SOMENTE apÛs todas as rotinas de acertos de pontos estarem finalizadas. Verifique!!!',{'Ok'})

	aPergs := {}
	aAdd( aPergs ,{1,"Filial: ",cFilSel,"@!",'',"SM0",'.T.',10,.T.})
	aAdd( aPergs ,{1,"Matricula De: ",cMatDe,"@!",'',"SRA",'.T.',20,.F.})
	aAdd( aPergs ,{1,"Matricula Ate: ",cMatAte,"@!",'',"SRA",'.T.',20,.T.})
	aAdd( aPergs ,{1,"Periodo Ate: ",dDataFim,"",'',"",'.T.',20,.T.})

	aAdd( aPergs ,{2,"Saldo: ","1",{"1=Ambos","2=Credor","3=Devedor"},60,'.T.',.T.})
	aAdd( aPergs ,{2,"Rescis„o: ","1",{"1=N„o","2=Sim","3=ZeraBanco"},40,'.T.',.T.})

	If !ParamBox(aPergs ,"CompensaÁ„o de Banco de Horas",aRet,,,,,,,,.F.,.F.)
		Return
	EndIf

	cFilSel 	:= aRet[1]
	cMatDe		:= aRet[2]
	cMatAte		:= aRet[3]
	dDataFim	:= aRet[4]
	nSaldo		:= aRet[5]
	nFechamento := aRet[6]

	//                                                                                           Regras geral para c·lculo
	//********************************************************************************************************************
	//   - NO fechamento mensal, depois de efetuados todos os ajutes de ponto e concluÌdo o c·lculo mensal, executar este
	//   com a data (PerÌodo atÈ) igual ‡ data FIM do perÌodo do ponto em aberto.
	//   - NA rescis„o, alÈm da matrÌcula "De" "AtÈ" serem iguais, a data de REFER NCIA tem que ser igual a DATA do DIA
	//   date()
	//********************************************************************************************************************

	//                            Se for rescisao considerar apenas o "Matricula De", deve ser feito para cada funcionario
	//********************************************************************************************************************
	If ( nFechamento == "2" )

		If ( cMatAte <> cMatDe )
			MsgAlert("Para a opÁ„o RESCIS√O somente È possÌvel executar a rotina para uma ˙nica matrÌcula!","ATEN«√O!!!")
			Return
		EndIf

		cMatAte := cMatDe
		dDataFim := Date()

	ElseIf ( nFechamento == "1" )

		If dDataFim <> xCtrlFch
			MsgAlert("A Data REFER NCIA para c·lculo tem que ser a mesma do ˙ltimo dia do perÌodo do ponto. Favor verificar!!!" , "ATEN«√O!!!")
			Return
		EndIf

	ElseIf ( nFechamento == "3" )

		If dDataFim <> xCtrlFch
			MsgAlert("A Data REFER NCIA para c·lculo tem que ser a mesma do ˙ltimo dia do perÌodo do ponto. Favor verificar!!!" , "ATEN«√O!!!")
			Return
		EndIf

	EndIf

	//                                                                                   Gravar campos customizados no SPI
	//********************************************************************************************************************
	U_BIAMsgRun("Aguarde... Gravando campos customizados: ",,{|| GravCampos() })

	//                                                                        Processar os SPI pendentes e compensar horas
	//********************************************************************************************************************
	U_BIAMsgRun("Aguarde... Processando Registros pendentes a compensar de Banco de Horas: ",,{|| ProcCompe() })

	//                                                                    Enviar para o SPB os SPI com data limite vencida
	//********************************************************************************************************************
	U_BIAMsgRun("Aguarde... Enviando Registro de Banco de Horas para Resultado: ",,{|| EncerrarBH() })

	MsgInfo("Processamento finalizado com sucesso!","CompensaÁ„o de Banco de Horas")

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Gravar os campo customizados em todos os SPI pendentes
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function GravCampos()

	Local _cAliasTmp

	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp
	%NOPARSER%

	select
	REC = SPI.R_E_C_N_O_
	from %TABLE:SPI% SPI
	where PI_FILIAL = %EXP:cFilSel%
	and PI_MAT between %EXP:cMatDe% and %EXP:cMatAte%
	and PI_DATA <= %EXP:DTOS(dDataFim)%
	and PI_YDTLIM = ''
	and PI_DTBAIX = ''
	and D_E_L_E_T_ = ''
	order by SPI.R_E_C_N_O_

	EndSql

	(_cAliasTmp)->(DbGoTop())
	While !(_cAliasTmp)->(Eof())

		SPI->(DbSetOrder(0))
		SPI->(DbGoTo((_cAliasTmp)->REC))

		If !SPI->(Eof())

			//inclusao - gravacao da data maxima de compensacao e valor original
			If ( SPI->PI_YHORIG == 0 )

				RecLock("SPI",.F.)

				SPI->PI_YHORIG := SPI->PI_QUANT
				SPI->PI_YDTLIM := SPI->PI_DATA + nDiasLim

				SPI->(MsUnlock())

			EndIf

		EndIf

		(_cAliasTmp)->(DbSkip())
	EndDo
	(_cAliasTmp)->(DbCloseArea())

Return


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Processar compensacao de todos os SPI pendentes
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function ProcCompe()

	Local _cAliasTmp
	Local _cWhereRct
	Local _cWhere047

	//Se for Rescisao deve considerar todos os apontamentos de banco pendentes independente da data limite
	If ( nFechamento == "2" )

		_cWhereRct := "% 1 = 1 %"
		_cWhere047 := "% RA_ACUMBH = 'S' %"

	ElseIf ( nFechamento == "1" )

		_cWhereRct := "% PI_YDTLIM >= '"+DTOS(dDataFim)+"' %"
		_cWhere047 := "% RA_ACUMBH = 'S' %"

	ElseIf ( nFechamento == "3" )

		_cWhereRct := "% 1 = 1 %"
		_cWhere047 := "% RA_ACUMBH <> 'S' %"

	EndIf

	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp
	%NOPARSER%

	select
	REC = SPI.R_E_C_N_O_
	from %TABLE:SPI% SPI
	join %TABLE:SRA% SRA ON RA_FILIAL = '01' AND RA_MAT = PI_MAT AND %EXP:_cWhere047% AND SRA.D_E_L_E_T_ = ' '
	where PI_FILIAL = %EXP:cFilSel%
	and PI_MAT between %EXP:cMatDe% and %EXP:cMatAte%
	and PI_DATA <= %EXP:DTOS(dDataFim)%

	and %EXP:_cWhereRct%

	and PI_QUANT > 0
	and PI_DTBAIX = ''
	and SPI.D_E_L_E_T_ = ''
	order by PI_FILIAL, PI_MAT, PI_DATA, PI_PD

	EndSql

	(_cAliasTmp)->(DbGoTop())
	While !(_cAliasTmp)->(Eof())

		SPI->(DbSetOrder(0))
		SPI->(DbGoTo((_cAliasTmp)->REC))

		If !SPI->(Eof())

			//Desconto ou Provento?
			SP9->(DbSetOrder(1))
			SRV->(DbSetOrder(1))
			If SP9->(DbSeek(XFilial("SP9")+SPI->PI_PD)) .And. SRV->(DbSeek(XFilial("SRV")+SP9->P9_CODFOL)) .And. SRV->RV_TIPOCOD == "2"
				_lCredito := .F.
			Else
				_lCredito := .T.
			EndIf

			//Compensacao
			If ( SPI->PI_QUANT > 0 )
				Compensar(_lCredito)
			EndIf

		EndIf

		(_cAliasTmp)->(DbSkip())
	EndDo
	(_cAliasTmp)->(DbCloseArea())

Return


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Procurar se exitem registros para compensar o SPI posicionado
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function Compensar(_lCredito)

	Local _cAliasTmp
	Local _cAliasHex
	Local _cWhere
	Local _cWhereRct
	Local _nQtdAComp := SPI->PI_QUANT
	Local aAreaSPI	 := SPI->(GetArea())
	Local cSql
	Local _cWhere047

	If ( _lCredito )
		_cWhere := "% RV_TIPOCOD = '2' %"
	Else
		_cWhere := "% RV_TIPOCOD <> '2' %"
	EndIf

	//Se for Rescisao deve considerar todos os apontamentos de banco pendentes independente da data limite
	If ( nFechamento == "2" )

		_cWhereRct := "% 1 = 1 %"
		_cWhere047 := "% RA_ACUMBH = 'S' %"

	ElseIf ( nFechamento == "1" )

		_cWhereRct := "% PI_YDTLIM >= '"+DTOS(SPI->PI_DATA)+"' %"
		_cWhere047 := "% RA_ACUMBH = 'S' %"

	ElseIf ( nFechamento == "3" )

		_cWhereRct := "% 1 = 1 %"
		_cWhere047 := "% RA_ACUMBH <> 'S' %"

	EndIf

	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp
	%NOPARSER%

	select REC = SPI.R_E_C_N_O_, SPI.*
	from %TABLE:SPI% SPI
	join %TABLE:SRA% SRA ON RA_FILIAL = '01' AND RA_MAT = PI_MAT AND %EXP:_cWhere047% AND SRA.D_E_L_E_T_ = ' '
	join %TABLE:SP9% SP9 on P9_FILIAL = '  ' and P9_CODIGO = PI_PD
	join %TABLE:SRV% SRV on RV_FILIAL = '  ' and RV_COD = P9_CODFOL
	where
	PI_FILIAL = %EXP:SPI->PI_FILIAL%
	and PI_MAT = %EXP:SPI->PI_MAT%
	and PI_DATA <= %EXP:SPI->PI_DATA%
	and PI_QUANT > 0
	and PI_DTBAIX = ''

	and %EXP:_cWhereRct%

	and SPI.R_E_C_N_O_ <> %EXP:SPI->(RecNo())%
	and %EXP:_cWhere%

	and SPI.D_E_L_E_T_ = ''
	and SP9.D_E_L_E_T_ = ''
	and SRV.D_E_L_E_T_ = ''
	order by PI_FILIAL, PI_MAT, PI_DATA, PI_PD

	EndSql

	(_cAliasTmp)->(DbGoTop())
	While !(_cAliasTmp)->(Eof())

		//enquanto houver horas para compensar
		If ( SPI->PI_QUANT > 0 )

			//Encontrou evento com capacidade para compensacao maior que o total
			//compensa as horas do evento encontrado
			//compensa totalmente o novo evento registrado
			If ( (_cAliasTmp)->PI_QUANT > SPI->PI_QUANT )

				//cSql := "update "+RetSQLName("SPI")+" set PI_QUANT = PI_QUANT - "+AllTrim(Str(SPI->PI_QUANT))+" where R_E_C_N_O_ = "+AllTrim(Str((_cAliasTmp)->REC))
				//Fernando/Facile em 22/04/16 - alterando para usar funcao SQL de calculo de horas hexagenal - comentado acima
				cSql := "update "+RetSQLName("SPI")+" set PI_QUANT = dbo.FN_HORAHEXDIFF(PI_QUANT, "+AllTrim(Str(SPI->PI_QUANT))+", 1) where R_E_C_N_O_ = "+AllTrim(Str((_cAliasTmp)->REC))

				TCSQLExec(cSql)

				RecLock("SPI",.F.)
				SPI->PI_QUANT := 0
				SPI->PI_YCOMPE := "S"
				SPI->PI_STATUS := "B"
				SPI->PI_YDTCOM := STOD((_cAliasTmp)->PI_DATA)
				SPI->PI_DTBAIX := STOD((_cAliasTmp)->PI_DATA)
				SPI->(MsUnlock())

			Else
				//Encontrou evento com qtde menor ou igual a compensacao
				//compensa totalmente o evento encontrado
				//compensa as hora o novo evento registrado e encerra se necessario

				cSql := "update "+RetSQLName("SPI")+" set PI_QUANT = 0, PI_YCOMPE = 'S', PI_STATUS = 'B', PI_YDTCOM = '"+DTOS(SPI->PI_DATA)+"', PI_DTBAIX = '"+DTOS(SPI->PI_DATA)+"' where R_E_C_N_O_ = "+AllTrim(Str((_cAliasTmp)->REC))
				TCSQLExec(cSql)

				_cAliasHex := GetNextAlias()
				BeginSql Alias _cAliasHex
				%NoParser%
				select CALC = dbo.FN_HORAHEXDIFF(%EXP:SPI->PI_QUANT%, %EXP:(_cAliasTmp)->PI_QUANT%, 1)
				EndSql

				RecLock("SPI",.F.)
				//SPI->PI_QUANT -= (_cAliasTmp)->PI_QUANT
				//Fernando/Facile em 22/04/16 - alterando para usar funcao SQL de calculo de horas hexagenal - comentado acima
				SPI->PI_QUANT := (_cAliasHex)->CALC

				(_cAliasHex)->(DbCloseArea())

				If ( SPI->PI_QUANT <= 0 )
					SPI->PI_YCOMPE := "S"
					SPI->PI_STATUS := "B"
					SPI->PI_YDTCOM := STOD((_cAliasTmp)->PI_DATA)
					SPI->PI_DTBAIX := STOD((_cAliasTmp)->PI_DATA)
				EndIf

				SPI->(MsUnlock())

			EndIf

		EndIf

		(_cAliasTmp)->(DbSkip())
	EndDo
	(_cAliasTmp)->(DbCloseArea())

	RestArea(aAreaSPI)

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Encerra os SPI com dt limite vencida
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function EncerrarBH()

	Local _cAliasTmp
	Local _cWhere
	Local _cWhereRct
	Local aAreaSPI	:= SPI->(GetArea())
	Local cSql
	Local _cChvGrp
	Local _nTotHR
	Local _cSRVCod
	Local _cWhere047

	If ( nSaldo == "3" )
		_cWhere := "% RV_TIPOCOD = '2' %"
	ElseIf ( nSaldo == "2" )
		_cWhere := "% RV_TIPOCOD <> '2' %"
	Else
		_cWhere := "% 1 = 1 %"
	EndIf

	//Se for Rescisao deve considerar todos os apontamentos de banco pendentes independente da data limite
	If ( nFechamento == "2" )

		_cWhereRct := "% 1 = 1 %"
		_cWhere047 := "% RA_ACUMBH = 'S' %"

	ElseIf ( nFechamento == "1" )

		_cWhereRct := "% PI_YDTLIM < '"+DTOS(dDataFim)+"' %"
		_cWhere047 := "% RA_ACUMBH = 'S' %"

	ElseIf ( nFechamento == "3" )

		_cWhereRct := "% 1 = 1 %"
		_cWhere047 := "% RA_ACUMBH <> 'S' %"

	EndIf

	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp
	%NOPARSER%

	select REC = SPI.R_E_C_N_O_, RV_COD
	from %TABLE:SPI% SPI
	join %TABLE:SRA% SRA ON RA_FILIAL = '01' AND RA_MAT = PI_MAT AND %EXP:_cWhere047% AND SRA.D_E_L_E_T_ = ' '
	join %TABLE:SP9% SP9 on P9_FILIAL = '  ' and P9_CODIGO = PI_PD
	join %TABLE:SRV% SRV on RV_FILIAL = '  ' and RV_COD = P9_CODFOL
	where
	PI_FILIAL = %EXP:cFilSel%
	and PI_MAT between %EXP:cMatDe% and %EXP:cMatAte%
	and PI_DATA <= %EXP:DTOS(dDataFim)%
	and PI_QUANT > 0
	and PI_YCOMPE <> 'S'
	and PI_DTBAIX = ''
	and %EXP:_cWhere%
	and %EXP:_cWhereRct%
	and SPI.D_E_L_E_T_ = ''
	and SP9.D_E_L_E_T_ = ''
	and SRV.D_E_L_E_T_ = ''
	order by PI_FILIAL, PI_MAT, PI_PD, PI_CC, PI_DATA

	EndSql

	(_cAliasTmp)->(DbGoTop())
	SPI->(DbSetOrder(0))
	SPI->(DbGoTo((_cAliasTmp)->REC))

	//Fernando/Facile em 22/04/2016 - modificacoes para agrupar o SPB pela verba e gravar as horas em base centesimal
	_nTotHR		:= 0
	_cChvGrp 	:= SPI->(PI_FILIAL+PI_MAT+PI_PD+PI_CC)

	While !(_cAliasTmp)->(Eof())

		//Acumula as horas em base centesimal
		_nTotHR += Round( int(SPI->PI_QUANT)  +  (( abs(SPI->PI_QUANT) - int(SPI->PI_QUANT) ) * 100)/60 , 2)
		// Por Marcos Alberto Soprani em 30/05/16, pois identifiquei um possÌvel problema de posicionamento
		hjpFil := SPI->PI_FILIAL
		hjpMat := SPI->PI_MAT
		hjpCC  := SPI->PI_CC

		//Atualiza campos na SPI
		RecLock("SPI",.F.)
		SPI->PI_STATUS := "B"
		SPI->PI_DTBAIX := dDataFim
		SPI->(MsUnlock())

		_cSRVCod := (_cAliasTmp)->RV_COD

		(_cAliasTmp)->(DbSkip())

		If !(_cAliasTmp)->(Eof())
			SPI->(DbSetOrder(0))
			SPI->(DbGoTo((_cAliasTmp)->REC))
		EndIf

		If ( SPI->(PI_FILIAL+PI_MAT+PI_PD+PI_CC) <> _cChvGrp ) .Or. (_cAliasTmp)->(Eof())

			//Gravando SPB
			RecLock("SPB",.T.)

			SPB->PB_FILIAL	:= hjpFil        //SPI->PI_FILIAL - Retirado em 30/05/16, por Marcos Alberto Soprani por indentificar um problema de posicionamento
			SPB->PB_MAT		:= hjpMat        //SPI->PI_MAT    - Retirado em 30/05/16, por Marcos Alberto Soprani por indentificar um problema de posicionamento
			SPB->PB_PD		:= _cSRVCod
			SPB->PB_TIPO1	:= "H"
			SPB->PB_HORAS	:= _nTotHR
			SPB->PB_VALOR	:= 0
			SPB->PB_DATA	:= xCtrlFch      //dDataFim // Retirado em 16/05/16 conforme alinhado com Claudia...
			SPB->PB_CC		:= hjpCC         //SPI->PI_CC     - Retirado em 30/05/16, por Marcos Alberto Soprani por indentificar um problema de posicionamento
			SPB->PB_PARCELA := 0
			SPB->PB_TIPO2	:= "G"
			SPB->PB_INTEGRA	:= "S"

			SPB->(MsUnlock())

			_nTotHR     := 0
			// Por Marcos Alberto Soprani em 30/05/16, pois identifiquei um possÌvel problema de posicionamento
			_cChvGrp 	:= SPI->(PI_FILIAL+PI_MAT+PI_PD+PI_CC)

		EndIf

	EndDo
	(_cAliasTmp)->(DbCloseArea())

	RestArea(aAreaSPI)

Return
