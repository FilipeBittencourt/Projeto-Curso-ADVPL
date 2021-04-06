#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TCompensacaoReceber
@author Wlysses Cerqueira (Facile)
@since 26/03/2019
@project Automação Financeira
@version 1.0
@description Classe de compensação de titulos a receber com NCC  
@type class
/*/

#DEFINE NPOSPED	1 
#DEFINE NPOSTIT	2
#DEFINE NPOSPRF	3
#DEFINE NPOSPAR	4
#DEFINE NPOSTIP	5
#DEFINE NPOSCLI	6
#DEFINE NPOSLOJ	7
#DEFINE NPOSVLR	8
#DEFINE NPOSEMI	9
#DEFINE NPOSVNR	10
#DEFINE NPOSSAL	11
#DEFINE NPOSREC	12

#DEFINE NPOSSERIE	1
#DEFINE NPOSNOTA	2
						
Class TCompensacaoReceber From TAFAbstractClass
	
	Data lEnabled
	Data lInclui
	Data lClassifica
	Data lConfirma

	Data aNfDevol
	Data aTitCredito
	Data aTitReceber
	
	Data nTotTitCred
	Data nTotTitRec
		
	Method New() Constructor
	Method Compensar(aTitReceber, aTitCredito, nValorComp, nValorTit, lComisNCC, cMensagem, lWorkFlow) // Muita atencao no parametro lComisNCC, pois indica se gera comissao
	Method LoadDevolucao()
	Method Devolucao()
	
	Method LoadRecAnt()
	Method RecebAntecipado()
	
EndClass


Method New() Class TCompensacaoReceber
	
	_Super:New()
	
	::lEnabled := GetNewPar("MV_YCOMAUT", .T.)
	::lInclui := .F.
	::lClassifica := .F.
	::lConfirma := .F.
		
	::aNfDevol := {}
	::aTitCredito := {}
	::aTitReceber := {}
	
	::nTotTitCred := 0
	::nTotTitRec := 0
			
Return()

Method Compensar(aTitReceber, aTitCredito, nValorComp, nValorTit, lComisNCC, cMensagem, lWorkFlow) Class TCompensacaoReceber

	Local lRet := .F.
	Local lContabiliza := .F.
	Local lAglutina := .F.
	Local lDigita := .F.
			
	Default aTitReceber := {}
	Default aTitCredito := {}
	Default nValorComp := 0
	Default lComisNCC := .F.
	Default cMensagem := ""
	Default lWorkFlow := .T.
	
	Pergunte("AFI340", .F.)
		
	lContabiliza	:= MV_PAR09 == 1
	lAglutina		:= MV_PAR08 == 1
	lDigita			:= MV_PAR09 == 1
	
	Begin Transaction
	
		If MaIntBxCR(3,aTitReceber,,aTitCredito,,{lContabiliza,lAglutina,lDigita,.F.,.F.,lComisNCC},,,,,nValorComp)
		                                       
			lRet := .T.
		
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_TIT_INC"
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Baixa [" + cMensagem + "] por compensacao efetuada"
			::oLog:cEnvWF := If(lWorkFlow, "S", "N")
			::oLog:cTabela := RetSQLName("SE1")
			::oLog:nIDTab := aTitReceber[1]
		
			::oLog:Insert()
	
		Else
		
			lRet := .F.
		
		EndIf
		
		If !lRet
			
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_TIT_INC"
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Baixa por compensacao não efetuada [Saldo Credito (NCC/RA): " + AllTrim(Transform(nValorComp, "@e 999,999,999.99")) + "] [Saldo titulos: " + AllTrim(Transform(nValorTit, "@e 999,999,999.99")) + "]"
			::oLog:cEnvWF := "S"
			::oLog:cTabela := RetSQLName("SE1")
			::oLog:nIDTab := aTitReceber[1]
			
			::oLog:Insert()
					
		EndIf
	
	End Transaction
	
Return(lRet)

Method Devolucao() Class TCompensacaoReceber
	
	Local cBckFunc := FUNNAME()
	
	If ::lEnabled
	
		::lInclui := PARAMIXB[1] == 4
		::lClassifica := PARAMIXB[1] == 3
		::lConfirma := PARAMIXB[2] == 1
		
		If (::lInclui .Or. ::lClassifica) .And. ::lConfirma .And. SF1->F1_TIPO == "D"
			
			::oPro:Start()
			
			::LoadDevolucao()
		
			If ::nTotTitRec > 0 .And. ::nTotTitCred > 0 .And. ::nTotTitRec == ::nTotTitCred

				SETFUNNAME("MATA103")
				
				::Compensar(::aTitReceber, ::aTitCredito, ::nTotTitCred, ::nTotTitRec, .F., "DEVOLUCAO")
				
				SETFUNNAME(cBckFunc)
		  		
		  	ElseIf ::nTotTitRec > 0 .Or. ::nTotTitCred > 0
		  	
		  		::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_TIT_INC"
				::oLog:cHrFin := Time()
				::oLog:cRetMen := "Baixa por compensacao [DEVOLUCAO] não efetuada [Saldo Credito (NCC/RA): " + AllTrim(Transform(::nTotTitCred, "@e 999,999,999.99")) + "] [Saldo titulos: " + AllTrim(Transform(::nTotTitRec, "@e 999,999,999.99")) + "]"
				::oLog:cEnvWF := "S"
				::oLog:cTabela := RetSQLName("SE1")
				
				If ::nTotTitRec > 0
				
					::oLog:nIDTab := ::aTitReceber[1]
					
				ElseIf ::nTotTitCred > 0
				
					::oLog:nIDTab := ::aTitCredito[1]
				
				EndIf
				
				::oLog:Insert()
		  	
		  	EndIf
			
			::oPro:Finish()
			
		EndIf
	
	EndIf

Return()

Method LoadDevolucao() Class TCompensacaoReceber

	Local aArea  := SE1->(GetArea())
	Local nW := 0
	
	For nW := 1 To Len(aCols)

		If !GdDeleted(nW)
			
			If ! Empty(GdFieldGet("D1_NFORI", nW))
			
				nPos := aScan(::aNfDevol, {|x| x[1] + x[2] + cValToChar(x[3]) == GdFieldGet("D1_NFORI", nW) + GdFieldGet("D1_SERIORI", nW) + cValToChar(GdFieldGet("D1_QUANT", nW))})
				
				If nPos == 0
				
					aAdd(::aNfDevol, {GdFieldGet("D1_SERIORI", nW), GdFieldGet("D1_NFORI", nW), GdFieldGet("D1_QUANT", nW)})
				
				EndIf
			
			EndIf
		
		EndIf

	Next nW

	DBSelectArea("SE1")
	SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

	If SE1->(DBSeek(xFilial("SE1") + cA100For + cLoja + cSerie + cNfiscal))
		
		While !SE1->(EOF()) .And. SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM) == xFilial("SE1") + cA100For + cLoja + cSerie + cNfiscal
			
			__cID		:= SE1->(Recno())
			__oBlqCR	:= TBloqueioContaReceber():New()
			__lRet		:= __oBlqCR:CheckPorRecno(__cID)
			
			If(!__lRet)//não e FDIC
				
				If SE1->E1_SALDO > 0 .And. SE1->E1_TIPO == "NCC"
				
					::nTotTitCred += SE1->E1_SALDO
			
					aAdd(::aTitCredito, SE1->(Recno()))
				 
				EndIf
				
			EndIf
			
			SE1->(DbSkip())
			
		EndDo
			
	EndIf
		
	For nW := 1 To Len(::aNfDevol)
	
		If SE1->(DBSeek(xFilial("SE1") + cA100For + cLoja + ::aNfDevol[nW][NPOSSERIE] + ::aNfDevol[nW][NPOSNOTA]))
			
			While !SE1->(EOF()) .And. SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM) == xFilial("SE1") + cA100For + cLoja + ::aNfDevol[nW][NPOSSERIE] + ::aNfDevol[nW][NPOSNOTA]
				
				__cID		:= SE1->(Recno())
				__oBlqCR	:= TBloqueioContaReceber():New()
				__lRet		:= __oBlqCR:CheckPorRecno(__cID)
				
				If(!__lRet)//não e FDIC
			
					If SE1->E1_SALDO > 0
						
						::nTotTitRec += SE1->E1_SALDO
				
						aAdd(::aTitReceber, SE1->(Recno()))
					
					Endif
					
				EndIf
				
				SE1->(DbSkip())
			
			EndDo
		
		EndIf
		
	Next nW
	
	RestArea(aArea)

Return()

Method LoadRecAnt() Class TCompensacaoReceber

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local nPos := 0
	Local cPedidos := ""
	Local lRet := .F.
	
	cSQL := " SELECT E1_PEDIDO, E1_NUM, E1_PREFIXO, E1_PARCELA, E1_TIPO, "
	cSQL += " E1_CLIENTE, E1_LOJA, E1_SALDO, E1_EMISSAO, E1_VENCREA, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("SE1") + " A ( NOLOCK ) "
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1")) + " "
	cSQL += " AND E1_TIPO = 'RA' "
	cSQL += " AND E1_PEDIDO <> '' "
	cSQL += " AND E1_SALDO > 0 "
	cSQL += " AND A.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY E1_PEDIDO, E1_NUM, E1_PREFIXO, E1_PARCELA "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(EOF())
			
		aAdd(::aTitCredito, {(cQry)->E1_PEDIDO,; 
							(cQry)->E1_NUM,;
							(cQry)->E1_PREFIXO,;
							(cQry)->E1_PARCELA,;
							(cQry)->E1_TIPO,;
							(cQry)->E1_CLIENTE,;
							(cQry)->E1_LOJA,;
							(cQry)->E1_SALDO,;
							(cQry)->E1_EMISSAO,;
							(cQry)->E1_VENCREA,;
							(cQry)->E1_SALDO,;
							(cQry)->RECNO})
							
		If !((cQry)->E1_PEDIDO $ cPedidos)
		
			cPedidos += If(Empty(cPedidos), "", "/") + (cQry)->E1_PEDIDO
		
		EndIf
		
		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())
	
	If Len(::aTitCredito) > 0
	
		cQry := GetNextAlias()
	
		cSQL := " SELECT E1_PEDIDO, E1_NUM, E1_PREFIXO, E1_PARCELA, E1_TIPO, "
		cSQL += " E1_CLIENTE, E1_LOJA, E1_SALDO, E1_EMISSAO, E1_VENCREA, R_E_C_N_O_ AS RECNO "
		cSQL += " FROM " + RetSQLName("SE1") + " A ( NOLOCK ) "
		cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1")) + " "
		cSQL += " AND E1_TIPO <> 'RA' "
		cSQL += " AND EXISTS ( "
		cSQL += " 				SELECT NULL FROM " + RetSQLName("SF2") + " SF2  "
		cSQL += " 				WHERE F2_FILIAL  = E1_FILIAL AND "
		cSQL += " 					  F2_DOC 	 = E1_NUM AND "
		cSQL += " 					  F2_SERIE 	 = E1_PREFIXO AND "
		cSQL += " 					  F2_CLIENTE = E1_CLIENTE AND "
		cSQL += " 					  F2_LOJA 	 = E1_LOJA AND "
		cSQL += " 					  SF2.D_E_L_E_T_ = '' "
		cSQL += " 			) "
		cSQL += " AND E1_PEDIDO IN " + FormatIn(cPedidos, "/") + " "
		cSQL += " AND E1_SALDO > 0 "
		cSQL += " AND E1_NUMBOR = '' "
		cSQL += " AND A.D_E_L_E_T_ = '' "
		cSQL += " ORDER BY E1_PEDIDO, E1_NUM, E1_PREFIXO, E1_PARCELA "
	
		TcQuery cSQL New Alias (cQry)
	
		While !(cQry)->(EOF())

			If STOD((cQry)->E1_EMISSAO) < dDataBase //.And. Time() >= "09:00:00"
					
				aAdd(::aTitReceber, {(cQry)->E1_PEDIDO,; 
									(cQry)->E1_NUM,;
									(cQry)->E1_PREFIXO,;
									(cQry)->E1_PARCELA,;
									(cQry)->E1_TIPO,;
									(cQry)->E1_CLIENTE,;
									(cQry)->E1_LOJA,;
									(cQry)->E1_SALDO,;
									(cQry)->E1_EMISSAO,;
									(cQry)->E1_VENCREA,;
									(cQry)->E1_SALDO,;
									(cQry)->RECNO})
									
			EndIf
				
			(cQry)->(DbSkip())
	
		EndDo
	
		(cQry)->(DbCloseArea())
	
	EndIf
	
Return()

Method RecebAntecipado() Class TCompensacaoReceber

	Local nW := 0
	Local nX := 0
	Local nValor := 0
	Local lRet := .T.
	Local dDataBkp := dDataBase
	Local cBckFunc := FUNNAME()

	If ::lEnabled
		
		::oPro:Start()
		
		::LoadRecAnt()
		
		Begin Transaction
		
		For nW := 1 To Len(::aTitReceber)
			
			If !lRet
			
				Exit
			
			Endif
			
			For nX := 1 To Len(::aTitCredito)
				
				If ::aTitReceber[nW][NPOSPED] == ::aTitCredito[nX][NPOSPED] .And. ::aTitReceber[nW][NPOSCLI] == ::aTitCredito[nX][NPOSCLI] .And. ::aTitReceber[nW][NPOSLOJ] == ::aTitCredito[nX][NPOSLOJ]
					
					If ::aTitReceber[nW][NPOSSAL] > 0 .And. ::aTitCredito[nX][NPOSSAL] > 0
						
						nValor := If(::aTitCredito[nX][NPOSSAL] >= ::aTitReceber[nW][NPOSSAL], ::aTitReceber[nW][NPOSSAL], ::aTitCredito[nX][NPOSSAL])
					
						::aTitCredito[nX][NPOSSAL] -= nValor
						
						::aTitReceber[nW][NPOSSAL] -= nValor
						
						dDataBase := Max(STOD(::aTitReceber[nW][NPOSEMI]), STOD(::aTitCredito[nX][NPOSEMI]))
						
						SETFUNNAME("FINA330")

	  					lRet := ::Compensar({::aTitReceber[nW][NPOSREC]}, {::aTitCredito[nX][NPOSREC]}, nValor, ::aTitReceber[nW][NPOSVLR], .T., "RA", ::aTitReceber[nW][NPOSSAL] > 0)
	  					
						SETFUNNAME(cBckFunc)

	  					If !lRet
	  					
	  						DisarmTransaction()
	  						
	  						::oLog:cIDProc := ::oPro:cIDProc
							::oLog:cOperac := "R"
							::oLog:cMetodo := "CR_TIT_INC"
							::oLog:cHrFin := Time()
							::oLog:cRetMen := "DisarmTransaction - Baixa por compensacao [RA] não efetuada [Saldo Credito (NCC/RA): " + AllTrim(Transform(::aTitCredito[nX][NPOSVLR], "@e 999,999,999.99")) + "] [Saldo titulos: " + AllTrim(Transform(::aTitReceber[nW][NPOSVLR], "@e 999,999,999.99")) + "]"
							::oLog:cEnvWF := "S"
							::oLog:cTabela := RetSQLName("SE1")
							::oLog:nIDTab := ::aTitReceber[nW][NPOSREC]
							
							::oLog:Insert()
							
							Exit
	  					
	  					EndIf
	  					
	  				EndIf
	  			
	  			EndIf
	  		
	  		Next nX
	  	
	  	Next nW
	  	
	  	End Transaction
		
		::oPro:Finish()
	
	EndIf
	
	dDataBase := dDataBkp 
	
Return()