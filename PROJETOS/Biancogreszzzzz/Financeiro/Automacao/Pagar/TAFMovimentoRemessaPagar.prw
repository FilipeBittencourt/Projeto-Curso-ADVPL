#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFMovimentoRemessaPagar
@author Wlysses Cerqueira (Facile)
@since 06/12/2018
@project Automação Financeira
@version 1.0
@description Classe para tratar os titulos a pagar que serao integrados com a API
@type class
/*/

Class TAFMovimentoRemessaPagar From TAFAbstractClass
	
	Data lScreen
	Data cNum
	Data cPrefixo
	Data cTipo
	Data cParcela
	Data lGnre
	
	Data dVencReDe // Data de vencimento inicial
	Data dVencReAte // Data de vencimento final
	
	Data nDia // Dias a considerar no vencimento

	Data cBorDe // Numero do Bordero De
	Data cBorAte // Numero do Bordero Ate
	
	Data cForneceDe // Fornecedor
	Data cLojaDe // Loja
	Data cForneceAte // Fornecedor
	Data cLojaAte // Loja
		
	Data cForExcec
	Data cIDProc // Identificar do processo
	Data oRcb // Objeto de regras de comunicacao bancaria
	Data oBor // Objeto de regras de bordero de recebimento
	Data oDesconto
	
	Method New() Constructor
	Method Get()
	Method SetSend(nRecno)
	Method FilterValid()
	
EndClass


Method New() Class TAFMovimentoRemessaPagar
		
	_Super:New()
	
	::lScreen := !IsBlind()
	
	::dVencReDe := dDataBase
	::dVencReAte := dDataBase

	::cNum := Space(TamSx3("E2_NUM")[1])
	::cPrefixo := Space(TamSx3("E2_PREFIXO")[1])
	::cTipo := Space(TamSx3("E2_TIPO")[1])
	::cParcela := Space(TamSx3("E2_PARCELA")[1])
	
	::lGnre := .F.
	::nDia := 0

	::cBorDe := ""
	::cBorAte := ""
	::cForneceDe := ""
	::cLojaDe := ""
	::cForneceAte := ""
	::cLojaAte := ""
		
	::cForExcec := GetNewPar("MV_YAPIFEX", "")
	::cIDProc := ""
	
	::oRcb := TAFRegraComunicacaoBancaria():New()
	::oBor := TAFBorderoPagar():New()
	::oDesconto := TAFDescontoPagar():New()
			
Return()


Method Get() Class TAFMovimentoRemessaPagar
Local cSQL := ""
Local cQry := GetNextAlias()
Local oObj := Nil
	
	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "I_SEL_TIT"
		
	::oLog:Insert()
	
	cSQL := " SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR, E2_SALDO, E2_DECRESC, E2_PORCJUR, E2_EMISSAO, E2_VENCTO, E2_VENCREA, "
	cSQL += " E2_NUMBOR, E2_NUMBCO, E2_CODBAR, E2_YLINDIG, E2_LINDIG, E2_IDCNAB, A2_BANCO, A2_AGENCIA, A2_NUMCON, E2_YCDGREG, SE2.R_E_C_N_O_ AS SE2_RECNO, "
	cSQL += " A2_YCDGREG "
	cSQL += " FROM "+ RetSQLName("SE2") + " SE2 "
	cSQL += " INNER JOIN "+ RetSQLName("SA2") + " SA2 "
	cSQL += " ON SA2.A2_FILIAL = "+ ValToSQL(xFilial("SA2"))
	cSQL += " AND SA2.A2_COD   = E2_FORNECE "
	cSQL += " AND SA2.A2_LOJA  = E2_LOJA "
	cSQL += " AND SA2.D_E_L_E_T_ = '' "
	cSQL += " WHERE E2_FILIAL = "+ ValToSQL(xFilial("SE2"))
	cSQL += " AND E2_TIPO NOT IN ('RES', 'FER', 'FOL', 'PENSAO', 'NDF', 'NCF', 'PR', '131', '132') "
	
	If ::lGnre
	
		cSQL += " AND SA2.A2_COD LIKE '%GNRE%' "
	
	EndIf
	
	If ::lScreen
	
		If Empty(::cBorDe) .And. Empty(::cBorAte) // BAF014 (Envio)
	
			cSQL += " AND SE2.E2_VENCREA = " + ValToSQL(::dVencReDe)
	
			cSQL += " AND E2_NUMBOR = '' "
			
		ElseIf ! Empty(::cBorDe) .Or. ! Empty(::cBorAte) // BAF015 (RE-Envio, bordero ja criado)
		
			cSQL += " AND E2_NUMBOR BETWEEN '" + ::cBorDe + "' AND '" + ::cBorAte + "' "
		
		EndIf
		
	Else
		
		If ::nDia > 0
		
			cSQL += " AND SE2.E2_VENCREA BETWEEN "
			cSQL += " CONVERT(VARCHAR(10), DATEADD(DAY, 1, " + ValToSQL(dDataBase) + "), 112) "
			cSQL += " AND "
			cSQL += " CONVERT(VARCHAR(10), DATEADD(DAY, " + cValToChar(::nDia) + ", " + ValToSQL(dDataBase) + "), 112) "
			cSQL += " AND E2_NUMBOR = '' "
		
		ElseIf ::nDia == 0
		
			cSQL += " AND SE2.E2_VENCREA BETWEEN " + ValToSQL(dDataBase) + " AND " + ValToSQL(dDataBase)
			cSQL += " AND E2_NUMBOR = '' "
			
		EndIf
		
	EndIf
	
	If ! Empty(::cForExcec)
	
		cSQL += " AND E2_FORNECE NOT IN " + FormatIn(::cForExcec, "|")
	
	EndIf
	
	If ! Empty(::cForneceAte) .And. ! Empty(::cLojaAte)
	
		cSQL += " AND E2_FORNECE BETWEEN '" + ::cForneceDe + "' AND '" + ::cForneceAte + "' "
		
		cSQL += " AND E2_LOJA BETWEEN '" + ::cLojaDe + "' AND '" + ::cLojaAte + "' "
	
	EndIf

	If ! Empty(::cNum)
	
		cSQL += " AND E2_NUM = '" + ::cNum + "'"
	
	EndIf

	If ! Empty(::cPrefixo)
	
		cSQL += " AND E2_PREFIXO = '" + ::cPrefixo + "'"
	
	EndIf
	
	If ! Empty(::cParcela)
	
		cSQL += " AND E2_PARCELA = '" + ::cParcela + "'"
	
	EndIf

	If ! Empty(::cTipo)
	
		cSQL += " AND E2_TIPO = '" + ::cTipo + "'"
	
	EndIf
		
	cSQL += " AND SE2.E2_YSITAPI <> '4' "
	cSQL += " AND SE2.E2_SALDO > 0 "
	cSQL += " AND SE2.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY E2_FORNECE, A2_YCDGREG "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
		
		oObj := TIAFMovimentoFinanceiro():New()
		 
		oObj:cPrefixo := (cQry)->E2_PREFIXO
		oObj:cNumero := (cQry)->E2_NUM
		oObj:cParcela := (cQry)->E2_PARCELA
		oObj:cTipo := (cQry)->E2_TIPO
		oObj:cCliFor := (cQry)->E2_FORNECE
		oObj:cLoja := (cQry)->E2_LOJA
		oObj:nValor := (cQry)->E2_VALOR
		oObj:nSaldo := (cQry)->E2_SALDO
		oObj:nAbat := SomaAbat((cQry)->E2_PREFIXO, (cQry)->E2_NUM, (cQry)->E2_PARCELA, "P", 1,, (cQry)->E2_FORNECE, (cQry)->E2_LOJA)
		oObj:nDesc := (cQry)->E2_DECRESC
		oObj:nPerJur := (cQry)->E2_PORCJUR
		oObj:dEmissao := sToD((cQry)->E2_EMISSAO)
		oObj:dVencto := If (sToD((cQry)->E2_VENCTO) < dDataBase, dDataBase, sToD((cQry)->E2_VENCTO))
		oObj:dVencRea := sToD((cQry)->E2_VENCREA)
		oObj:cNumBor := (cQry)->E2_NUMBOR
		oObj:cNumBco := (cQry)->E2_NUMBCO
		oObj:cIDCnab := (cQry)->E2_IDCNAB
		oObj:lRecAnt := If (oObj:cTipo == "BOL" .And. SubStr(oObj:cPrefixo, 1, 2) $ "PR/CT" .And. !Empty(oObj:cPedido), .T., .F.)
		oObj:nRecNo := (cQry)->SE2_RECNO
		oObj:cCodBar := (cQry)->E2_CODBAR
		oObj:cLinDig := If (Empty((cQry)->E2_LINDIG), (cQry)->E2_YLINDIG, (cQry)->E2_LINDIG)
		
		oObj:cBancoFor := (cQry)->A2_BANCO
		oObj:cAgenciaFor := (cQry)->A2_AGENCIA
		oObj:cContaFor := (cQry)->A2_NUMCON

		oObj:cSituacao := "1"
		oObj:cEspecie := ""
		
		oObj:cGRCB := (cQry)->A2_YCDGREG
		oObj:cRCB := (cQry)->E2_YCDGREG
		oObj:lMRCB := .F.
		
		::oLst:Add(oObj)
		
		ConOut("TAF => BAF001 - [Processa Remessa de titulos a pagar] " + cEmpAnt + cFilAnt + " - TAFMovimentoRemessaPagar - " + oObj:cPrefixo + "-" + oObj:cNumero + "-" + oObj:cParcela + "-" + oObj:cTipo + " - DATE: "+DTOC(Date())+" TIME: "+Time())
		
		::oLog:cIDProc := ::cIDProc
		::oLog:cOperac := "P"
		::oLog:cMetodo := "S_SEL_TIT"
		::oLog:cTabela := RetSQLName("SE2")
		::oLog:nIDTab := oObj:nRecNo
		::oLog:cHrFin := Time()
		
		::SetSend((cQry)->SE2_RECNO)
		
		::oLog:Insert()
		
		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

	If ::oLst:GetCount() > 0
		
		// Define regras de comunicacao bancaria
		::oRcb:cTipo := "P"
		::oRcb:cOpc := "E"
		::oRcb:oLst := ::oLst
		::oRcb:cIDProc := ::cIDProc
		
		::oRcb:Set()
	
	EndIf
	
	::FilterValid()
	
	If ::oLst:GetCount() > 0
			
		// Efetua desconto conforme regra
		::oDesconto:oLst := ::oLst
		::oDesconto:cIDProc := ::cIDProc
		
		::oDesconto:Set()
				
	EndIf
		
	::FilterValid()
	
	If ::oLst:GetCount() > 0
			
		// Cria borderos
		::oBor:oLst := ::oLst
		::oBor:cIDProc := ::cIDProc
		
		::oBor:Create()
	
	EndIf
	
	::FilterValid()
	
	If ::oLst:GetCount() == 0
	
		// Registra dia sem movimento bancario 
		::oLog:cIDProc := ::cIDProc
		::oLog:cOperac := "P"
		::oLog:cMetodo := "N_SEL_TIT"
		::oLog:cHrFin := Time()
		::oLog:cEnvWF := "S"
		
		::oLog:Insert()
				
	EndIf
	
	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "F_SEL_TIT"
	::oLog:cHrFin := Time()
	
	::oLog:Insert()
		
Return(::oLst)


Method FilterValid() Class TAFMovimentoRemessaPagar
Local oObj := ArrayList():New()
Local nW := 0

	For nW := 1 To ::oLst:GetCount()
		
		If ::oLst:GetItem(nW):lValid
		
			oObj:Add(::oLst:GetItem(nW))
		
		EndIf
		
	Next nW
	
	::oLst := oObj
	
Return(::oLst)

Method SetSend(nRecno) Class TAFMovimentoRemessaPagar
Local aArea := SE2->(GetArea())

	SE2->(DbSetOrder(0))
	SE2->(DbGoTo(nRecno))

	If !SE2->(Eof())
	
		RecLock("SE2", .F.)
		SE2->E2_YSITAPI := "1"	 //0=Pendente;1=Enviado;2=Retorno com Sucesso;3=Retorno com Erro
		SE2->(MSUnlock())
		
	EndIf

	RestArea(aArea)

Return()