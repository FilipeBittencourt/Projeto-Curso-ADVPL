#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFP002
Apurar e gerar os dados do banco de horas para o eSocial, para demonstracao na folha de pagamento
@Author.....: Pontin
@Since......: 28/12/2018
@Version....: 1.0
@Return.....: Nil
/*/
User Function BIAFP002()

	Local nX			:= 0
	Local aSays 		:= {}
	Local aButtons		:= {}
	Local aCodFol		:= {}
	Local cMsg			:= ""
	Local cPerg			:= "PNM081R"
	Local cSvFilAnt		:= cFilAnt
	Local lContinua		:= .F.
	Local lBarG1ShowTm 	:= .F.
	Local lBarG2ShowTm 	:= .F.
	Local nOpcA			:= 0.00

	Private aPdBcoHor	:= {}
	Private lAbortPrint := .F.
	Private cCadastro   := OemToAnsi( "Apuracao do Banco de Horas para o e-Social" ) //"Apuracao do Banco de Horas para o e-Social"

	//Carrega verbas
	Fp_CodFol(@aCodFol, cFilAnt, .F., .F.)

	If Len(aCodFol) >= 1551
		lContinua := !Empty( aCodFol[1549,1] ) .And. !Empty( aCodFol[1550,1] ) .And. !Empty( aCodFol[1551,1] )
	EndIf

	If !lContinua
		cMsg := OemToAnsi( "Para executar essa rotina é obrigatório o cadastro das verbas (Tipo 3 - Base Provento) dos seguintes identificadores:" ) + CRLF + CRLF	//"Para executar essa rotina é obrigatório o cadastro das verbas (Tipo 3 - Base Provento) dos seguintes identificadores:"
		cMsg += OemToAnsi( "1549 - Saldo de banco de horas anterior ao esocial" ) + CRLF		//"1549 - Saldo de banco de horas anterior ao esocial"
		cMsg += OemToAnsi( "1550 - Horas debitadas em banco de horas no mes" ) + CRLF		//"1550 - Horas debitadas em banco de horas no mes"
		cMsg += OemToAnsi( "1551 - Horas creditadas em banco de horas no mes" ) 	//"1551 - Horas creditadas em banco de horas no mes"
		MsgInfo( cMsg )
		Return()
	Else
		aPdBcoHor := { {aCodFol[1549,1],""}, {aCodFol[1550,1],""}, {aCodFol[1551,1],""} }
		For nX := 1 To Len(aPdBcoHor)
			PosSrv( aPdBcoHor[nX,1], cFilAnt )
			aPdBcoHor[nX,2] := SRV->RV_TIPO
		Next nX
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ So Executa se os Modos de Acesso dos Arquivos Relacionados es³
	³ tiverm OK													   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF ValidArqPon()

		aAdd(aSays,OemToAnsi( "Este programa tem como objetivo gerar os Débitos e Créditos do banco de Horas no mês" )) 	//"Este programa tem como objetivo gerar os Débitos e Créditos do banco de Horas no mês"
		aAdd(aSays,OemToAnsi( "e também poderá gerar o Saldo do Banco de Horas anterior ao e-Social." ))	//"e também poderá gerar o Saldo do Banco de Horas anterior ao e-Social."

		aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
		aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA:=0 ) }} )
		aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

		FormBatch( cCadastro, aSays, aButtons )

		IF ( nOpcA == 1 )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Verifica se deve Mostrar Calculo de Tempo nas BarGauge			 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			lBarG1ShowTm := ( SuperGetMv("MV_PNSWTG1",NIL,"N") == "S" )
			lBarG2ShowTm := ( SuperGetMv("MV_PNSWTG2",NIL,"S") == "S" )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Executa o Processo de Fechamento do Banco de Horas				 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			Proc2BarGauge(  {|| PNM081Processa( cPerg ) }, OemToAnsi( "Apuracao do Banco de Horas para o e-Social" ), NIL , NIL , .T. , lBarG1ShowTm , lBarG2ShowTm )  //"Apuracao do Banco de Horas para o e-Social"
		EndIF

	EndIF

	cFilAnt := cSvFilAnt

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PONM080Processa ³ Autor ³ Aldo Marini jr ³ Data ³ 03/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa o Fechamento do Banco de Horas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso  	 ³ SIGAPON							             			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PNM081Processa( cPerg )

	Local nX			:= 0
	Local nAt			:= 0
	Local nReg			:= 0
	Local nValPd		:= 0
	Local nTFil			:= 0
	Local nTMat			:= 0
	Local nSaldoP     	:= 0.00
	Local nSaldoD     	:= 0.00
	Local nSaldoA     	:= 0.00
	Local cChave		:= ""
	Local cFilFun 		:= ""
	Local cMatFun 		:= ""
	Local cProcFun 		:= ""
	Local cDtIni    	:= ""
	Local cDtFim    	:= ""
	Local cDtIniMov    	:= ""
	Local cDtFimMov    	:= ""
	Local cDtIniSaldo  	:= ""
	Local cDtFimSaldo  	:= ""
	Local cTpCod		:= ""
	Local cWhereSRA		:= ""
	Local cWhereSPI		:= ""
	Local cSituacao		:= ""
	Local cCategoria	:= ""
	Local cSitQuery 	:= ""
	Local cCatQuery 	:= ""
	Local cAnoMes		:= ""
	Local cPdBh			:= ""
	Local cAliasSRA		:= "SRA"
	Local cAliasSPI		:= "SPI"
	Local aCodFol		:= {}
	Local lAddNew		:= .F.
	Local lGeraSaldo	:= .F.
	Local lGrv			:= .F.
	Local lFirst		:= .T.

	Private aLogDet		:= {}
	Private aLogTitle	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregando as Perguntas                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte( cPerg, .F. )

	cSituacao  			:= If( !Empty(mv_par05), mv_par05, ' ADFT' )
	cCategoria 			:= If( !Empty(mv_par06), mv_par06, 'CDHMST' )
	nTpEvento  			:= If( !Empty(mv_par08), mv_par08, 3 ) //-- 1=Autorizados 2=Nao Autorizados 3=Ambos
	dDtPagFol			:= mv_par13
	cAnoMes				:= AnoMes( dDtPagFol )

	MakeSqlExpr( cPerg )

	cSitQuery	:= ""
	For nReg :=1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSituacao)
			cSitQuery += ","
		Endif
	Next nReg

	cCatQuery	:= ""
	For nReg:=1 to Len(cCategoria)
		cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCategoria)
			cCatQuery += ","
		Endif
	Next nReg

	//Filial
	If !Empty(mv_par01)
		cWhereSRA += mv_par01
	EndIf

	//Centro de Custos
	If !Empty(mv_par02)
		cWhereSRA += Iif(!Empty(cWhereSRA)," AND ","")
		cWhereSRA += mv_par02
	EndIf

	//Turno
	If !Empty(mv_par03)
		cWhereSRA += Iif(!Empty(cWhereSRA)," AND ","")
		cWhereSRA	+= mv_par03
	EndIf

	//Matricula
	If !Empty(mv_par04)
		cWhereSRA += Iif(!Empty(cWhereSRA)," AND ","")
		cWhereSRA += mv_par04
	EndIf

	//Eventos
	If !Empty(mv_par07)
		nAt := At("P9_CODIGOS", mv_par07 )
		cWhereSPI := Stuff( mv_par07, nAt, 10, "PI_PD" )
	EndIf

	//Data inicial - Movimento Mes
	If !Empty(mv_par09)
		cDtIniMov := DTOS( mv_par09 )
	EndIf

	//Data Final - Movimento Mes
	If !Empty(mv_par10)
		cDtFimMov := DTOS( mv_par10 )
	EndIf

	//Data inicial - Saldo Anterior
	If !Empty(mv_par11)
		cDtIniSaldo := DTOS( mv_par11 )
	EndIf

	//Data Final - Saldo Anterior
	If !Empty(mv_par12)
		cDtFimSaldo := DTOS( mv_par12 )
	EndIf

	cSitQuery := "%" + cSitQuery + "%"
	cCatQuery := "%" + cCatQuery + "%"
	cWhereSRA := "%" + If( Empty(cWhereSRA), "", " AND " ) + cWhereSRA + "%"
	cWhereSPI := "%" + If( Empty(cWhereSPI), "", " AND " ) + cWhereSPI + "%"

	//Quando é para gerar saldo tem que levar na query o maior periodo possivel considerando os 4 perguntes
	If !Empty(mv_par11) .And. !Empty(mv_par11)
		aData := { cDtIniMov, cDtFimMov, cDtIniSaldo, cDtFimSaldo }
		aSort(aData)
		cDtIni := aData[1]
		cDtFim := aData[4]
		lGeraSaldo := .T.
	Else
		cDtIni := cDtIniMov
		cDtFim := cDtFimMov
	EndIf

	Begin Sequence

		If Select(cAliasSRA) > 0
			(cAliasSRA)->(dbcloseArea())
		Endif

		BeginSql alias cAliasSRA
			SELECT
			RA_FILIAL, RA_MAT, RA_NOME, RA_CC, RA_PROCES, RA_TNOTRAB, RA_SEQTURN, RA_REGRA, RA_ADMISSA, RA_CODFUNC,
			RA_DEMISSA, RA_CATFUNC, RA_SITFOLH, RA_SINDICA, RA_BHFOL, RA_POSTO, RA_DEPTO, RA_ITEM, RA_CLVL
			FROM
			%table:SRA% SRA
			WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
			SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			SRA.RA_BHFOL = 'S'
			%exp:cWhereSRA% AND SRA.%notDel%

			ORDER BY
			SRA.RA_FILIAL,SRA.RA_MAT
		EndSql
		dbSelectArea(cAliasSRA)

		While (cAliasSRA)->( !Eof() )

			cFilFun := (cAliasSRA)->RA_FILIAL
			cMatFun := (cAliasSRA)->RA_MAT
			cNomFun := SubStr((cAliasSRA)->RA_NOME,1,30)
			cProcFun:= (cAliasSRA)->RA_PROCES

			If lFirst
				nTFil  := 10 - Len(cFilFun)
				nTMat  := 15 - Len(cMatFun)
				lFirst := .F.
			EndIf
			nTNom := (35-Len(cNomFun))

			If Select(cAliasSPI) > 0
				(cAliasSPI)->(dbcloseArea())
			Endif

			BeginSql alias cAliasSPI
				SELECT PI_FILIAL, PI_MAT, PI_PD, PI_QUANT, PI_CC, PI_DATA, PI_STATUS
				FROM %table:SPI% SPI
				WHERE 	SPI.PI_FILIAL = %exp:cFilFun% AND
				SPI.PI_MAT = %exp:cMatFun% AND
				SPI.PI_DATA BETWEEN (%exp:cDtIni%) AND (%exp:cDtFim%)
				AND ( SPI.PI_STATUS <> 'B' OR ( SPI.PI_STATUS = 'B' AND SPI.PI_DTBAIX = (%exp:cDtFimMov%)) )
				%exp:cWhereSPI% AND SPI.%notDel%
				ORDER BY
				SPI.PI_FILIAL,SPI.PI_MAT,SPI.PI_DATA
			EndSql

			nSaldoA := 0.00
			nSaldoP := 0.00
			nSaldoD := 0.00
			cTpCod  := ""
			lGrv	:= .F.

			While (cAliasSPI)->( !Eof() )

				If nTpEvento <> 3
					If !fBscEven( (cAliasSPI)->PI_PD, 2, nTpEvento )
						(cAliasSPI)->( dbSkip() )
						Loop
					EndIF
				EndIf

				PosSP9( (cAliasSPI)->PI_PD, cFilFun)
				cTpCod := SP9->P9_TIPOCOD

				If lGeraSaldo
					//Gera o saldo Anterior
					If (cAliasSPI)->PI_DATA >= cDtIniSaldo .And. (cAliasSPI)->PI_DATA <= cDtFimSaldo
						nSaldoA := If( cTpCod $ "1*3", __TimeSum( nSaldoA, (cAliasSPI)->PI_QUANT ), __TimeSub( nSaldoA, (cAliasSPI)->PI_QUANT ) )
					EndIf
				EndIf

				//Gera os Creditos e Debitos do Banco de Horas - So avalia a data quando existe geracao de saldo anterior
				If !lGeraSaldo .Or. (cAliasSPI)->PI_DATA >= cDtIniMov .And. (cAliasSPI)->PI_DATA <= cDtFimMov
					If cTpCod $ "1*3"
						nSaldoP := __TimeSum( nSaldoP, (cAliasSPI)->PI_QUANT )
					Else
						nSaldoD := __TimeSum( nSaldoD, (cAliasSPI)->PI_QUANT )
					EndIf
				EndIf

				(cAliasSPI)->(DbSkip())
			End

			If nSaldoP > 0 .Or. nSaldoD > 0 .Or. nSaldoA > 0

				dbSelectArea("SRC")
				SRC->(dbSetOrder(1))

				For nX := 1 To Len( aPdBcoHor )

					Do Case
						Case nX == 1	//Saldo anterior ao eSocial
						nValPd := nSaldoA
						Case nX == 2	//Horas debitadas no mes
						nValPd := nSaldoD
						Case nX == 3	//Horas creditadas no mes
						nValPd := nSaldoP
					EndCase

					If !Empty( nValPd )

						cChave	:= cFilFun + cMatFun +  aPdBcoHor[nX,1] //RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ
						lAddNew := !SRC->( dbSeek( cChave ) )

						RecLock( "SRC", lAddNew )
						SRC->RC_FILIAL	:= cFilFun
						SRC->RC_MAT     := cMatFun
						SRC->RC_PD      := aPdBcoHor[nX,1]
						SRC->RC_TIPO1   := aPdBcoHor[nX,2]
						SRC->RC_HORAS   := 0.00
						SRC->RC_VALOR   := nValPd
						SRC->RC_DATA    := dDtPagFol
						SRC->RC_SEMANA  := "01"
						SRC->RC_CC      := (cAliasSRA)->RA_CC
						SRC->RC_PARCELA := 0
						SRC->RC_TIPO2   := "E"
						SRC->RC_QTDSEM  := 0
						SRC->RC_HORINFO := 0
						SRC->RC_VALINFO := 0
						SRC->RC_VNAOAPL := 0
						SRC->RC_DTREF   := dDtPagFol
						SRC->RC_PROCES  := cProcFun
						SRC->RC_PERIODO := cAnoMes
						SRC->RC_POSTO   := (cAliasSRA)->RA_POSTO
						SRC->RC_ROTEIR  := "FOL"
						SRC->RC_DEPTO   := (cAliasSRA)->RA_DEPTO
						SRC->RC_ITEM    := (cAliasSRA)->RA_ITEM
						SRC->RC_CLVL    := (cAliasSRA)->RA_CLVL
						SRC->( MsUnlock() )

						lGrv := .T.
					EndIf

				Next nX

				If lGrv
					cValA := Transform(nSaldoA,'@E 99999.99')
					cValD := Transform(nSaldoD,'@E 99999.99')
					cValP := Transform(nSaldoP,'@E 99999.99')
					aAdd( aLogDet, cFilFun + Space(nTFil) + cMatFun + Space(nTMat) + cNomFun + Space(nTNom) + cValA + Space(15-Len(cValA)) + cValD + Space(15-Len(cValD)) + cValP  )
				EndIf

			EndIf

			(cAliasSRA)->(DbSkip())
		End

	End Sequence
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Gera o Log de Processamento                                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !Empty( aLogDet )
		aAdd( aLogTitle, OemToAnsi("Filial    Matricula      Nome                               Saldo Ant.     Hr. Deb. Mes   Hr. Cred. Mes") ) //"Filial    Matricula      Nome                               Saldo Ant.     Hr. Deb. Mes   Hr. Cred. Mes" )
		fMakeLog( { aLogDet } , aLogTitle , cPerg )
	EndIF

Return( NIL )

