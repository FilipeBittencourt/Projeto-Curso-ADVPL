#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TBaixaDacaoReceber
@author Wlysses Cerqueira (Facile)
@since 01/04/2019
@project Automação Financeira
@version 1.0
@description Classe para baixa tipo dacao de titulos descontados em folha de pagamento. 
@type class
/*/

#DEFINE NPOSDOC 1
#DEFINE NPOSSER 2
#DEFINE NPOSMAT 3
#DEFINE NPOSVLR 4
#DEFINE NPOSSLD	5

Class TBaixaDacaoReceber From TAFAbstractClass
	
	Data lEnabled

	Data cRoteiro
	Data cDoc
	Data cSerie
	Data cCliente
	Data cLoja
	Data cTipo
	Data cParcela
	Data nVlrBaixa
	
	Method New() Constructor
	Method Processa()
	Method Baixar()
	
	Method Folha()
	Method Recisao()
	
	Method SetCliLoja(cMatricula)
	Method GetParcela(nParcela)
	Method GetErrorLog(aError)
	
	Method SetPergLC(cYesNo)
	
EndClass


Method New(cRoteiro) Class TBaixaDacaoReceber
	
	Local aAreaSX6 := SX6->(GetArea())
	
	Default cRoteiro := ""
	
	_Super:New()
	
	::lEnabled	:= GetNewPar("MV_YDACAUT", .T.)
	::cRoteiro	:= cRoteiro
	::cDoc 		:= ""
	::cSerie	:= ""
	::cCliente 	:= ""
	::cLoja		:= ""
	::cTipo 	:= ""
	::cParcela	:= ""
	::nVlrBaixa := 0
	
	RestArea(aAreaSX6)
			
Return()

Method Processa() Class TBaixaDacaoReceber
	
	If ::lEnabled
	
		::oPro:Start()
		
		If ::cRoteiro == "FOL" .And. RCH->RCH_ROTEIR == ::cRoteiro
			
			If ! Empty(SRK->RK_YNFISCA)
			
				::SetCliLoja(SRK->RK_MAT)
				
				::cDoc 		:= SRK->RK_YNFISCA
				::cSerie	:= SRK->RK_YSERNF
				::cTipo 	:= PADR("NF", TamSx3("E1_TIPO")[1])
				::cParcela	:= ::GetParcela(SRK->RK_PARCPAG)
				::nVlrBaixa := If(SRK->RK_PARCELA == SRK->RK_PARCPAG, SRK->RK_VALORPA + SRK->RK_VALORAR, SRK->RK_VALORPA)
				
				::Folha()
			
			EndIf
			
		ElseIf ::cRoteiro == "RES" .And. RCH->RCH_ROTEIR == ::cRoteiro
			
			::Recisao()
		
		EndIf
		
		::oPro:Finish()
	
	EndIf
	
Return()

Method Folha() Class TBaixaDacaoReceber
	
	Local aAreaSE1 := SE1->(GetArea())
	Local dAuxAux := dDataBase
	
	DBSelectArea("SE1")
	SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
	SE1->(DBGoTop())
			
	If SE1->(DBSeek(xFilial("SE1") + ::cCliente + ::cLoja + ::cSerie + ::cDoc + ::cParcela + ::cTipo))
					
		If SE1->E1_SALDO > 0 .And. SE1->E1_SALDO == ::nVlrBaixa
			
			//If Month(SE1->E1_VENCREA) == Month(RCH->RCH_DTFIM)
			
				//dDataBase := SE1->E1_VENCREA
				
			//Else
			
				dDataBase := DataValida(RCH->RCH_DTFIM, .F.)
			
			//EndIf
			
			::Baixar()
			
		Else
		
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_TIT_INC"
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Baixa DACAO [FOL] não efetuada [Saldo DP: " + AllTrim(Transform(::nVlrBaixa, "@e 999,999,999.99")) + "] [Saldo Financeiro: " + AllTrim(Transform(SE1->E1_SALDO, "@e 999,999,999.99")) + "]"
			::oLog:cEnvWF := "S"
			::oLog:cTabela := RetSQLName("SE1")
			::oLog:nIDTab := SE1->(Recno())
			
			::oLog:Insert()
					
		EndIf
					
	EndIf
	
	dDataBase := dAuxAux
	
	RestArea(aAreaSE1)
			
Return()

Method Recisao() Class TBaixaDacaoReceber
	
	Local aNota := {}
	Local nW	:= 0
	Local dAuxAux := dDataBase
	Local aAreaSE1 := SE1->(GetArea())
	Local aAreaSRR := SRR->(GetArea())
	Local aAreaSRK := SRK->(GetArea())
		
	DBSelectArea("SE1")
	SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SRR")
	SRR->(DBSetOrder(4)) // RR_FILIAL, RR_MAT, RR_PERIODO, RR_ROTEIR, RR_SEMANA, RR_PD, RR_CC, RR_SEQ, RR_DATA, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SRK")
	SRK->(DBSetOrder(2)) // RK_FILIAL, RK_MAT, RK_NUMID, R_E_C_N_O_, D_E_L_E_T_
						
	If SRR->(DBSeek(xFilial("SRR") + SRA->RA_MAT + RCH->RCH_PER + "RES"))
		
		While SRR->(! EOF()) .And. SRR->(RR_FILIAL + RR_MAT + RR_PERIODO + RR_ROTEIR) == xFilial("SRR") + SRA->RA_MAT + RCH->RCH_PER + "RES"
			
			If ! Empty(SRR->RR_NUMID)
						
				If SRK->(DBSeek(xFilial("SRK") + SRA->RA_MAT + SRR->RR_NUMID))
				
					If ! Empty(SRK->RK_YNFISCA)
				
						::SetCliLoja(SRA->RA_MAT)
				
						nPos := aScan(aNota, {|x| x[NPOSDOC] + x[NPOSSER] + x[NPOSMAT] == SRK->RK_YNFISCA + SRK->RK_YSERNF + SRA->RA_MAT})
							
						If nPos == 0
							
							aAdd(aNota, {SRK->RK_YNFISCA, SRK->RK_YSERNF, SRA->RA_MAT, SRR->RR_VALOR, 0})
								
						Else
							
							aNota[nPos][NPOSVLR] += SRR->RR_VALOR
							
						EndIf
						
					EndIf
						
				EndIf
			
			EndIf
					
			SRR->(DBSkip())
						
		EndDo
		
	EndIf

	For nW := 1 To Len(aNota)
						
		SE1->(DBGoTop())
				
		If SE1->(DBSeek(xFilial("SE1") + ::cCliente + ::cLoja + aNota[nW][NPOSSER] + aNota[nW][NPOSDOC]))

			While SE1->(! EOF()) .And. SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM) == xFilial("SE1") + ::cCliente + ::cLoja + aNota[nW][NPOSSER] + aNota[nW][NPOSDOC]
				
				aNota[nW][NPOSSLD] += SE1->E1_SALDO
						
				SE1->(DBSkip())
						
			EndDo
						
		EndIf
			
	Next nW

	For nW := 1 To Len(aNota)
					
		SE1->(DBGoTop())
				
		If SE1->(DBSeek(xFilial("SE1") + ::cCliente + ::cLoja + aNota[nW][NPOSSER] + aNota[nW][NPOSDOC]))

			If aNota[nW][NPOSVLR] == aNota[nW][NPOSSLD]

				While SE1->(! EOF()) .And. SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM) == xFilial("SE1") + ::cCliente + ::cLoja + aNota[nW][NPOSSER] + aNota[nW][NPOSDOC]
									
					If SE1->E1_SALDO > 0
						
						dDataBase := DataValida(RCH->RCH_DTFIM, .F.)
						
						::nVlrBaixa := SE1->E1_SALDO
									
						::Baixar()
									
					EndIf

					SE1->(DBSkip())

				EndDo
			
			Else
	
				::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_TIT_INC"
				::oLog:cHrFin := Time()
				::oLog:cRetMen := "Baixa DACAO [RES] não efetuada [Saldo DP: " + AllTrim(Transform(aNota[nW][NPOSVLR], "@e 999,999,999.99")) + "] [Saldo Financeiro: " + AllTrim(Transform(aNota[nW][NPOSSLD], "@e 999,999,999.99")) + "]"
				::oLog:cEnvWF := "S"
				::oLog:cTabela := RetSQLName("SE1")
				::oLog:nIDTab := SE1->(Recno())
				
				::oLog:Insert()

			EndIf

		EndIf

	Next nW
	
	dDataBase := dAuxAux
	
	RestArea(aAreaSE1)
	RestArea(aAreaSRR)
	RestArea(aAreaSRK)
				
Return()

Method GetParcela(nParcela) Class TBaixaDacaoReceber

	Local cRet := ""
	Local aParc := {}
	
	aAdd(aParc, "A")
	aAdd(aParc, "B")
	aAdd(aParc, "C")
	aAdd(aParc, "D")
	aAdd(aParc, "E")
	aAdd(aParc, "F")
	aAdd(aParc, "G")
	aAdd(aParc, "H")
	aAdd(aParc, "I")
	aAdd(aParc, "J")
	aAdd(aParc, "K")
	aAdd(aParc, "L")
	aAdd(aParc, "M")
	aAdd(aParc, "N")
	aAdd(aParc, "O")
	aAdd(aParc, "P")
	aAdd(aParc, "Q")
	aAdd(aParc, "R")
	aAdd(aParc, "S")
	aAdd(aParc, "T")
	aAdd(aParc, "U")
	aAdd(aParc, "V")
	aAdd(aParc, "W")
	aAdd(aParc, "X")
	aAdd(aParc, "Y")
	aAdd(aParc, "Z")
	
	cRet := PADR(aParc[nParcela], TamSx3("E1_PARCELA")[1])

Return(cRet)

Method SetCliLoja(cMatricula) Class TBaixaDacaoReceber
	
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaSRA := SRA->(GetArea())
	
	DBSelectArea("SRA")
	SRA->(DBSetOrder(1)) // RA_FILIAL, RA_MAT, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SA1")
	SA1->(DBSetOrder(3)) // A1_FILIAL, A1_CGC, R_E_C_N_O_, D_E_L_E_T_
		
	If SRA->(DBSeek(xFilial("SRA") + cMatricula))
	
		If SA1->(DBSeek(xFilial("SA1") + SRA->RA_CIC))
	
			::cCliente := SA1->A1_COD
			
			::cLoja := SA1->A1_LOJA
		
		EndIf
	
	EndIf
	
	RestArea(aAreaSA1)
	RestArea(aAreaSRA)

Return()

Method Baixar() Class TBaixaDacaoReceber

	Local aTit := {}
	Local aAutoErro := {}
	Local cLogTxt := ""
	Local cMotBx := "DAC"
	
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	
	::SetPergLC(2) // Ob.: Nesta versao do projeto nao existe contabilizacao de baixa por DACAO.
	
	aAdd(aTit, {"E1_PREFIXO"	, SE1->E1_PREFIXO	, Nil})
	aAdd(aTit, {"E1_NUM"		, SE1->E1_NUM		, Nil})
	aAdd(aTit, {"E1_PARCELA"	, SE1->E1_PARCELA	, Nil})
	aAdd(aTit, {"E1_TIPO"		, SE1->E1_TIPO		, Nil})
	aAdd(aTit, {"AUTMOTBX"		, cMotBx			, Nil})
	//aAdd(aTit, {"AUTBANCO"	, oObj:cBanco		, Nil})
	//aAdd(aTit, {"AUTAGENCIA"	, oObj:cAgencia		, Nil})
	//aAdd(aTit, {"AUTCONTA"	, oObj:cConta		, Nil})
	aAdd(aTit, {"AUTDTBAIXA"	, dDataBase			, Nil})
	aAdd(aTit, {"AUTDTCREDITO"	, dDataBase			, Nil})
	aAdd(aTit, {"AUTDESCONT"	, 0, Nil			, .T.})
	aAdd(aTit, {"AUTJUROS"		, 0, Nil			, .T.})
	aAdd(aTit, {"AUTMULTA"		, 0, Nil			, .T.})
	aAdd(aTit, {"AUTACRESC"		, 0, Nil				 })
	aAdd(aTit, {"AUTVALREC"		, ::nVlrBaixa		, Nil})

	MsExecAuto({|x,y| FINA070(x,y)}, aTit, 3)

	If lMsErroAuto
	
		aAutoErro := GETAUTOGRLOG()
		
		cLogTxt += ::GetErrorLog(aAutoErro)
		
		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_TIT_INC"
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Baixa DACAO: " + cLogTxt
		::oLog:cEnvWF := "N"
		::oLog:cTabela := RetSQLName("SE1")
		::oLog:nIDTab := SE1->(Recno())
		
		::oLog:Insert()

	Else
		
		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_TIT_INC"
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Baixa DACAO efetuada"
		::oLog:cEnvWF := "N"
		::oLog:cTabela := RetSQLName("SE1")
		::oLog:nIDTab := SE1->(Recno())
		
		::oLog:Insert()
		
	EndIf
	
	::SetPergLC(1)

Return(lMsErroAuto)

Method GetErrorLog(aError) Class TBaixaDacaoReceber

	Local cRet := ""
	Local nX := 1
	
	Default aError := {}
	
	For nX := 1 To Len(aError)
	
		cRet += aError[nX] + CRLF
		
	Next nX
	
Return(cRet)

Method SetPergLC(cYesNo) Class TBaixaDacaoReceber

	Local aPerg := {}

	Pergunte("FIN070", .F.,,,,, @aPerg)

	MV_PAR01 := cYesNo
	
	__SaveParam("FIN070", aPerg)

Return()