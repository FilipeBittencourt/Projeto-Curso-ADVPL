#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFaturaReceberIntercompany
@author Wlysses Cerqueira (Facile)
@since 26/04/2019
@project Automação Financeira
@version 1.0
@description Classe responsavel pelo carregamento da fatura a pagar 
para replica da fatura na filial destino. 
@type class
/*/

// ARRAY aTitulos
#DEFINE TPOSEMP		1
#DEFINE TPOSFIL		2
#DEFINE TPOSPREF	3
#DEFINE TPOSNUM		4
#DEFINE TPOSPARC	5
#DEFINE TPOSVALOR	6
#DEFINE TPOSFATURA	7
#DEFINE TPOSFATPRF	8
#DEFINE TPOSFATPAR	9

// ARRAY aFatura
#DEFINE FPOSCLI		1
#DEFINE FPOSLOJ		2
#DEFINE FPOSFATURA	3
#DEFINE FPOSFATPAR	6
#DEFINE FPOSVLR		10
#DEFINE FPOSEMP		11
#DEFINE FPOSFIL		12
#DEFINE FPOSTAB		13
#DEFINE FPOSREC		14

Class TFaturaReceberIntercompany From LongClasName

	Data aTitulos
	Data aRecnoTit
	Data cNumFat
	Data aFatura
	Data oEmpresa
	Data oFatura
	Data oPro // Objeto Gestor de Processos
	Data oLog // Objeto de Log
	
	Method New() Constructor
	Method GetTitulos(cFornece, cLoja, cFatPref, cFatura)
	Method FaturaReceberDestino()
	Method Fatura(aTitulos, aFatura, cNumFat, cIDProc, dDataBase_)
	Method ExisteFaturaDestino(lRpc, cFatura)
	
EndClass

Method New() Class TFaturaReceberIntercompany

	::cNumFat := ""
	::aTitulos := {}
	::aRecnoTit  := {}
	::aFatura := {}
	
	::oFatura := TFaturaReceber():New()
	::oEmpresa := TLoadEmpresa():New()
	::oPro := TAFProcess():New()
	::oLog := TAFLog():New()

Return()

Method GetTitulos(cFornece, cLoja, cFatPref, cFatura) Class TFaturaReceberIntercompany
	
	Local aAreaSE2 := SE2->(GetArea())

	DbSelectArea("SE2")
	SE2->(DBSetOrder(9)) // E2_FILIAL, E2_FORNECE, E2_LOJA, E2_FATPREF, E2_FATURA, R_E_C_N_O_, D_E_L_E_T_
	SE2->(DBGoTop())
	
	::aTitulos := {}
	
	If SE2->(DBSeek(xFilial("SE2") + cFornece + cLoja + cFatPref + cFatura))
	
		While SE2->(E2_FILIAL + E2_FORNECE + E2_LOJA + E2_FATPREF + E2_FATURA) == xFilial("SE2") + cFornece + cLoja + cFatPref + cFatura
		
			aAdd(::aTitulos, {cEmpAnt, cFilAnt, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_VALOR, SE2->E2_FATURA, SE2->E2_FATPREF})

			SE2->(DBSkip())

		EndDo
		
	EndIf
	
	RestArea(aAreaSE2)
		
Return(::aTitulos)

Method FaturaReceberDestino(nSumDay) Class TFaturaReceberIntercompany
	
	Local xRet 		:= Nil
	Local nW_		:= 0
	Local aAreaSE2	:= SE2->(GetArea())
	Local cFornec_	:= If(MV_PAR01 == 1, cForn, cFornP)
	Local cLoja_	:= If(MV_PAR01 == 1, cLoja, cLojaP)
	Local cFat		:= ""

	Default nSumDay	:= If(IsInCallStack("U_BAF042") .Or. IsInCallStack("U_BAF042FD"), 0, 0)
	
	::oEmpresa := TLoadEmpresa():New()
	
	::oPro:Start()
	
	DbSelectArea("SE2")
	SE2->(DBSetOrder(1)) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
	SE2->(DBGoTop())
	
	If !Empty(SA2->A2_CGC) .And. ::oEmpresa:Seek(SA2->A2_CGC) // Esta posicionado
		
		For nW_ := 1 To Len(aCols)
		
			If !aCols[nW_, Len(aCols[1])]
				
				If SE2->(DBSeek(xFilial("SE2") + aCols[nW_][1] + cFatura + aCols[nW_][3] + aCols[nW_][4] + cFornec_ + cLoja_ ))
				
					aAdd(::aFatura, {"", "", SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_TIPO, SE2->E2_PARCELA, cCondicao, SE2->E2_VENCTO + nSumDay, SE2->E2_VENCREA + nSumDay, SE2->E2_VALOR, cEmpAnt, cFilAnt, RetSQLName("SE2"), SE2->(Recno())})

					cFat += SE2->E2_NUM + " "

				EndIf
				
			EndIf
		
		Next nW_
		
		::aTitulos := ::GetTitulos(SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_PREFIXO, SE2->E2_NUM)
		
		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_FAT_INTER"
		::oLog:cTabela := RetSQLName("SE2")
		::oLog:nIDTab := SE2->(Recno())
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Criacao de fatura receber"
		::oLog:cEnvWF := "S"
			
		If Len(::aTitulos) > 0
				
			If Empty(::cNumFat)
				
				::cNumFat := U_FROPCPRO(::oEmpresa:cCodEmp, ::oEmpresa:cCodFil, "U_FATRECNU")
				
			EndIf
			
			If ( ValType(::cNumFat) == "C" .And. UPPER(AllTrim(::cNumFat)) == "DEFAULTERRORPROC" ) .Or. ValType(::cNumFat) == "U"
				
				DisarmTransaction()
				
				MsgStop("Não foi possivel conectar na filial " + ::oEmpresa:cCodEmp + ::oEmpresa:cCodFil + " tente novamente!", "Intercompany")
			
			Else

				::oLog:cRetMen := "Criacao de fatura receber " + ::cNumFat + " referente fatura a pagar: " + cFat

				::oLog:Insert()

				xRet := U_FROPCPRO(::oEmpresa:cCodEmp, ::oEmpresa:cCodFil, "U_FATRECDE", ::aTitulos, ::aFatura, ::cNumFat, ::oPro:cIDProc, dDataBase) // _cEmpDes, _cFilDes, _cNomeProc, _uPar1, _uPar2 ... _uPar15

				If ( ValType(xRet) == "C" .And. UPPER(AllTrim(xRet)) == "DEFAULTERRORPROC" ) .Or. ValType(xRet) == "U"
					
					DisarmTransaction()	
					
					MsgStop("Não foi possivel conectar na filial " + ::oEmpresa:cCodEmp + ::oEmpresa:cCodFil + " tente novamente!", "Intercompany")
					
				ElseIf ValType(xRet) == "L" .And. !xRet // O retorno da classe TFaturaReceber foi false
					
					DisarmTransaction()	
					
					MsgStop("Não foi possivel incluir a fatura a receber na filial " + ::oEmpresa:cCodEmp + ::oEmpresa:cCodFil + " tente novamente!", "Intercompany")
				
				EndIf	
			
			EndIf
		
		EndIf
			
	EndIf
	
	::oPro:Finish()
	
	RestArea(aAreaSE2)
		
Return()

Method Fatura(aTitulos, aFatura, cNumFat, cIDProc, dDataBase_) Class TFaturaReceberIntercompany
	
	Local aAreaSE1	:= SE1->(GetArea())
	Local nW_ 		:= 0
	Local nX_		:= 0
	Local cPrefNDC 	:= PADL("NDC", TamSx3("E1_PREFIXO")[1], " ")
	Local cTipoNDC	:= PADL("NDC", TamSx3("E1_TIPO")[1], " ")
	Local nTotTit	:= 0
	Local nTotFat	:= 0
	Local xRet		:= Nil
	
	Default aTitulos := {}
	Default aFatura := {}
	Default cNumFat := ""
	Default dDataBase_ := dDataBase
	
	::oEmpresa := TLoadEmpresa():New()
	::aTitulos := aTitulos
	::aFatura := aFatura
	::cNumFat := @cNumFat
	::aRecnoTit := {}
	::oPro:cIDProc := cIDProc
	
	dDataBase  := dDataBase_
	
	DbSelectArea("SE1")
	SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
	SE1->(DBGoTop())
	
	Begin Transaction
	
		For nW_ := 1 To Len(::aTitulos)
		
			If !::oEmpresa:lCliente
			
				::oEmpresa:SeekForCli(::aTitulos[nW_][TPOSEMP], ::aTitulos[nW_][TPOSFIL])
				
				For nX_ := 1 To Len(::aFatura)
					
					::aFatura[nX_][FPOSCLI] := ::oEmpresa:cCodCli
					
					::aFatura[nX_][FPOSLOJ] := ::oEmpresa:cLojaCli
				
				Next nX_
				
			EndIf
			
			If ::oEmpresa:lCliente
	
				If SE1->(DBSeek(xFilial("SE1") + ::oEmpresa:cCodCli + ::oEmpresa:cLojaCli + ::aTitulos[nW_][TPOSPREF] + ::aTitulos[nW_][TPOSNUM] + ::aTitulos[nW_][TPOSPARC]))
			
					While SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA) == xFilial("SE1") + ::oEmpresa:cCodCli + ::oEmpresa:cLojaCli + ::aTitulos[nW_][TPOSPREF] + ::aTitulos[nW_][TPOSNUM] + ::aTitulos[nW_][TPOSPARC]
						
						If SE1->E1_SALDO > 0
						
							aAdd(::aRecnoTit, SE1->(Recno()))
						
							nTotTit	+= SE1->E1_SALDO
							
							::oLog:cIDProc := ::oPro:cIDProc
							::oLog:cOperac := "R"
							::oLog:cMetodo := "CR_FAT_INTER"
							::oLog:cTabela := RetSqlName("SE1")
							::oLog:nIDTab := SE1->(Recno())
							::oLog:cEmp := cEmpAnt
							::oLog:cFil := cFilAnt
							::oLog:cHrFin := Time()
							::oLog:cRetMen := "Encontrado saldo de " + AllTrim(Transform(SE1->E1_SALDO, "@E 999,999,999.99")) +  " para tentativa de gerar fatura " + ::cNumFat
							::oLog:cEnvWF := "N"
						
							::oLog:Insert()
										
						EndIf
						
						SE1->(DBSkip())
		
					EndDo
				
				Else
					
					SE1->(DBGoTop())
					
					If SE1->(DBSeek(xFilial("SE1") + ::oEmpresa:cCodCli + ::oEmpresa:cLojaCli + cPrefNDC + ::aTitulos[nW_][TPOSNUM] + ::aTitulos[nW_][TPOSPARC]))
			
						While SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA) == xFilial("SE1") + ::oEmpresa:cCodCli + ::oEmpresa:cLojaCli + cPrefNDC + ::aTitulos[nW_][TPOSNUM] + ::aTitulos[nW_][TPOSPARC]
							
							If SE1->E1_SALDO > 0
							
								aAdd(::aRecnoTit, SE1->(Recno()))
								
								nTotTit	+= SE1->E1_SALDO
								
								::oLog:cIDProc := ::oPro:cIDProc
								::oLog:cOperac := "R"
								::oLog:cMetodo := "CR_FAT_INTER"
								::oLog:cTabela := RetSqlName("SE1")
								::oLog:nIDTab := SE1->(Recno())
								::oLog:cEmp := cEmpAnt
								::oLog:cFil := cFilAnt
								::oLog:cHrFin := Time()
								::oLog:cRetMen := "Encontrado saldo de " + AllTrim(Transform(SE1->E1_SALDO, "@E 999,999,999.99")) +  " para tentativa de gerar fatura " + ::cNumFat
								::oLog:cEnvWF := "N"
							
								::oLog:Insert()
										
							EndIf
							
							SE1->(DBSkip())
			
						EndDo
					
					EndIf
					
				EndIf
			
			EndIf
			
		Next nW_
		
		For nW_ := 1 To Len(::aFatura)
		
			nTotFat += ::aFatura[nW_][FPOSVLR]
		
		Next nW_
		
		If nTotTit == nTotFat
		
			::oFatura:cNumFat := ::cNumFat
			::oFatura:cNatureza := "1121"
			::oFatura:lBaixaTit := .T.
			::oFatura:aFatura := ::aFatura
			::oFatura:aRecnoTit := ::aRecnoTit
			::oFatura:oPro:cIDProc := ::oPro:cIDProc
			
			xRet := ::oFatura:Create()
		
		Else
			
			For nW_ := 1 To Len(::aFatura)
		
				::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cOperac := "P"
				::oLog:cMetodo := "CP_FAT_INTER"
				::oLog:cTabela := ::aFatura[nW_][FPOSTAB]
				::oLog:nIDTab := ::aFatura[nW_][FPOSREC]
				::oLog:cEmp := ::aFatura[nW_][FPOSEMP]
				::oLog:cFil := ::aFatura[nW_][FPOSFIL]
				::oLog:cHrFin := Time()
				::oLog:cRetMen := "Criacao da fatura " + ::cNumFat + " valor: " + AllTrim(Transform(nTotTit, "@E 999,999,999.99")) + " parcela " + ::aFatura[nW_][FPOSFATPAR] + " na filial " + cEmpAnt + cFilAnt + " ref fatura " + ::aFatura[nW_][FPOSFATURA] + " valor: " + AllTrim(Transform(::aFatura[nW_][FPOSVLR], "@E 999,999,999.99")) + " da filial " + ::aFatura[nW_][FPOSEMP] + ::aFatura[nW_][FPOSFIL] + " valores diferentes!"
				::oLog:cEnvWF := "S"
			
				::oLog:Insert()
				
				xRet := .T.
			
			Next nW_
		
		EndIf
	
	End Transaction
	
	RestArea(aAreaSE1)

Return(xRet)

Method ExisteFaturaDestino(lRpc, cFatura) Class TFaturaReceberIntercompany
	
	Local xRet := Nil
	Local cSQL := ""
	Local cQry := ""
	Local oEmpresa := TLoadEmpresa():New()
	Local aAreaSA2 := SA2->(GetArea())
	Local aAreaSE2 := SE2->(GetArea())
	Local oMail	:= TAFMail():New()
	
	Default lRpc := .F.
	Default cFatura := ""
	
	If lRpc
	
		DBSelectArea("SA2")
		SA2->(DBSetorder(1)) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
		
		If SA2->(DBSeek(xFilial("SA2") + cFornCan + cLojaCan))
		
			If !Empty(SA2->A2_CGC) .And. ::oEmpresa:Seek(SA2->A2_CGC)
			
				xRet := U_FROPCPRO(::oEmpresa:cCodEmp, ::oEmpresa:cCodFil, "U_FATRECEX", cFatCan) // _cEmpDes, _cFilDes, _cNomeProc, _uPar1, _uPar2 ... _uPar15
				
				If ( ValType(xRet) == "C" .And. UPPER(AllTrim(xRet)) == "DEFAULTERRORPROC" ) .Or. ValType(xRet) == "U"
					
					DisarmTransaction()	
					
					MsgStop("Não foi possivel conectar na filial " + ::oEmpresa:cCodEmp + ::oEmpresa:cCodFil + " tente novamente!", "Intercompany")

					xRet := .F.
					
				ElseIf ValType(xRet) == "C" .And. ! Empty(xRet)
					
					DisarmTransaction()	
					
					MsgStop("Favor excluir a fatura a receber " + xRet + " da filial " + AllTrim(::oEmpresa:cCodEmp) + AllTrim(::oEmpresa:cCodFil) + " pois esta amarrada a fatura a pagar " + cFatCan + ".", "Intercompany")

					xRet := .F.
				
				Else
				
					xRet := .T.
					
				EndIf
			
			EndIf
		
		EndIf
	
	Else
		
		cQry := GetNextAlias()
		
		cSQL := "SELECT DISTINCT E1_FATURA "
		cSQL += "FROM " + RetSQLName("SE1") + " A ( NOLOCK ) "
		cSQL += "WHERE E1_YFATPAG = " + ValToSQL(cFatura)
		cSQL += "AND E1_FATURA <> '' "
		cSQL += "AND A.D_E_L_E_T_ = '' "
		
		TcQuery cSQL New Alias (cQry)
		
		xRet := ""
		
		While !(cQry)->(EOF())
			
			xRet += If(Empty(xRet), "", "/") + (cQry)->E1_FATURA
			
			(cQry)->(DbSkip())

		EndDo
		
		(cQry)->(DbCloseArea())
	
	EndIf
	
	RestArea(aAreaSA2)
	RestArea(aAreaSE2)

Return(xRet)

User Function FATRECEX(cFatura)

	Local oObj := Nil
	Local cFaturaDest := ""
	
	Default cFatura	 := ""
	
	oObj := TFaturaReceberIntercompany():New()
	
	cFaturaDest := oObj:ExisteFaturaDestino(.F., cFatura)
	
Return(cFaturaDest)

User Function FATRECNU()
	
	Local oObj := TFaturaReceber():New()
	Local cNumFat := ""
	
	cNumFat := oObj:GetNextNumFat()
	
Return(cNumFat)

User Function FATRECDE(aTitulos, aFatura, cNumFat, cIDProc, dDataBase_)

	Local oObj := Nil
	Local xRet := Nil
	
	Default aTitulos := {}
	Default aFatura	 := {}
	Default cNumFat	 := ""
	Default dDataBase_ := dDataBase
	
	oObj := TFaturaReceberIntercompany():New()
	
	xRet := oObj:Fatura(aTitulos, aFatura, cNumFat, cIDProc, dDataBase_)
	
Return(xRet)
