#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFDepositoIdentificado
@author Tiago Rossini Coradini
@since 18/01/2019
@project Automação Financeira
@version 1.0
@description Classe para processamento de deposito identificado
@type class
/*/

Class TAFDepositoIdentificado From TAFAbstractClass
	
	Method New() Constructor
	Method Process()
	Method Analyze()
	Method CancProrrog()
	Method Get()
	Method SetItem(oObj)
	Method Validate()
	Method Exist(nPos)
	Method Update(nPos)
	Method Confirm()
	Method BankReceipt(nPos)
	Method GetErrorLog()
	Method SetConsoleLog(cError)
	
EndClass


Method New() Class TAFDepositoIdentificado
	
	_Super:New()

Return()


Method Process() Class TAFDepositoIdentificado
	
	::oPro:Start()
		
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_DEP_IDE"

	::oLog:Insert()
	
	::Analyze()

	::CancProrrog()

	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "F_DEP_IDE"

	::oLog:Insert()
		
	::oPro:Finish()
	
Return()


Method Analyze() Class TAFDepositoIdentificado

	::Get()
	
	If ::Validate()

		::Confirm()
				
	EndIf

Return()


Method Get() Class TAFDepositoIdentificado
Local cSQL := ""
Local cQry := GetNextAlias()

	::oLst:Clear()

	cSQL := " SELECT ZK8_NUMERO, ZK8_DATDPI, ZK8_BANCO, ZK8_AGENCI, ZK8_CONTA, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("ZK8")
	cSQL += " WHERE ZK8_FILIAL = " + ValToSQL(xFilial("ZK8"))
	cSQL += " AND ZK8_STATUS = 'A' "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY ZK8_NUMERO "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())			
		
		oObj := TIAFDepositoIdentificado():New()
		
		oObj:cNumero := (cQry)->ZK8_NUMERO
		oObj:dDtLanc := sToD((cQry)->ZK8_DATDPI)
		oObj:dDtCont := sToD((cQry)->ZK8_DATDPI)
		oObj:cBanco := (cQry)->ZK8_BANCO
		oObj:cAgencia := (cQry)->ZK8_AGENCI
		oObj:cConta := (cQry)->ZK8_CONTA
		oObj:nRecNo := (cQry)->RECNO
		
		::SetItem(oObj)
		
		::oLst:Add(oObj)
						
		(cQry)->(DbSkip())
			
	EndDo()

	(cQry)->(DbCloseArea())
			
Return()


Method SetItem(oObj) Class TAFDepositoIdentificado
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_SALDO, "
	cSQL += " ROUND( "
	cSQL += " 	CASE WHEN DATEDIFF(DAY, E1_VENCTO, ZK8_DATDPI) > 0 AND ZK8_CALCJR = 'S' AND ZK8_PERCJR > 0 THEN "
	cSQL += " 		(ZK8_PERCJR * (E1_SALDO / 100)) * DATEDIFF(DAY, E1_VENCTO, ZK8_DATDPI) "
	cSQL += "   ELSE "
	cSQL += " 		0 "
	cSQL += "   END, 2) AS E1_JUROS, SE1.R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("ZK8") + " ZK8 "
	cSQL += " INNER JOIN " + RetSQLName("SE1") + " SE1 "
	cSQL += " ON ZK8_NUMERO = E1_YNUMDPI "
	cSQL += " WHERE ZK8_FILIAL = " + ValToSQL(xFilial("ZK8"))
	cSQL += " AND ZK8_DATDPI = " + ValToSQL(oObj:dDtLanc)
	cSQL += " AND ZK8_STATUS = 'A' "
	cSQL += " AND ZK8_NUMERO = "	+ ValToSQL(oObj:cNumero)
	cSQL += " AND ZK8.D_E_L_E_T_ = '' "
	cSQL += " AND E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_SALDO > 0 "
	cSQL += " AND SE1.D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		oMF := TIAFMovimentoFinanceiro():New()
		 
		oMF:cTipo := "R"
		oMF:cPrefixo := (cQry)->E1_PREFIXO
		oMF:cNumero := (cQry)->E1_NUM
		oMF:cParcela := (cQry)->E1_PARCELA
		oMF:cTipo := (cQry)->E1_TIPO
		oMF:nSaldo := (cQry)->E1_SALDO
		oMF:nJuros := (cQry)->E1_JUROS
		oMF:nRecNo := (cQry)->RECNO
		
		// Acumula valores totais
		oObj:nValor += (cQry)->E1_SALDO
		oObj:nJuros += (cQry)->E1_JUROS
		
		oObj:oLst:Add(oMF)
		
		(cQry)->(DbSkip())
			
	EndDo()

	(cQry)->(DbCloseArea())

Return()


Method Validate() Class TAFDepositoIdentificado
Local lRet := .F.
Local nCount := 1

	If ::oLst:GetCount() > 0
	
		While nCount <= ::oLst:GetCount()
		
			::oLst:GetItem(nCount):lOK := ::Exist(nCount)
			
			nCount++
			
		EndDo()
		
		lRet := aScan(::oLst:ToArray(), {|x| x:lOK }) > 0
	
	EndIf
	
Return(lRet)


Method Exist(nPos) Class TAFDepositoIdentificado
Local lRet := .F.
Local cSQL := ""
Local nTotReg := 0
Local cQry := GetNextAlias()

	cSQL := " SELECT R_E_C_N_O_ AS RECNO, ZK4_DTLANC "
	cSQL += " FROM " + RetSQLName("ZK4")
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
	cSQL += " AND ZK4_EMP = " + ValToSQL(::oLst:GetItem(nPos):cEmp)
	cSQL += " AND ZK4_FIL = " + ValToSQL(::oLst:GetItem(nPos):cFil)
	cSQL += " AND ZK4_TIPO = 'C' "
	cSQL += " AND ZK4_STATUS = '1' "
	//cSQL += " AND ZK4_DTLANC BETWEEN ZK4_DTLANC AND " + ValToSQL(::oLst:GetItem(nPos):dDtCont + 5)
	cSQL += " AND SUBSTRING(ZK4_TPLANC, 1, 1) = 'C'	"
	cSQL += " AND ROUND(ZK4_VLTOT, 2) = " + ValToSQL(::oLst:GetItem(nPos):nValor + ::oLst:GetItem(nPos):nJuros)
	cSQL += " AND ZK4_BANCO = " + ValToSQL(::oLst:GetItem(nPos):cBanco)
	cSQL += " AND ZK4_AGENCI = " + ValToSQL(::oLst:GetItem(nPos):cAgencia)
	cSQL += " AND ZK4_CONTA = " + ValToSQL(::oLst:GetItem(nPos):cConta)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	Count To nTotReg

	(cQry)->(DBGoTop())

	If nTotReg == 0

		lRet := .F.

	ElseIf nTotReg == 1

		If STOD((cQry)->ZK4_DTLANC) == ::oLst:GetItem(nPos):dDtCont

			lRet := .T.

			::oLst:GetItem(nPos):nRecNoZK4 := (cQry)->RECNO
		
		ElseIf STOD((cQry)->ZK4_DTLANC) <= ::oLst:GetItem(nPos):dDtCont + 5 // Para casos de prorrogacao
			
			::oLst:GetItem(nPos):dDtCont := STOD((cQry)->ZK4_DTLANC)

			::oLst:GetItem(nPos):dDtLanc := STOD((cQry)->ZK4_DTLANC) 

			lRet := .T.

			::oLst:GetItem(nPos):nRecNoZK4 := (cQry)->RECNO

		EndIf

	Else // Se achou mais de um registro com mesmas caracteristicas
		
		While !(cQry)->(Eof())
		
			If STOD((cQry)->ZK4_DTLANC) == ::oLst:GetItem(nPos):dDtCont

				lRet := .T.

				::oLst:GetItem(nPos):nRecNoZK4 := (cQry)->RECNO

				Exit

			EndIf

			(cQry)->(DbSkip())
				
		EndDo

	EndIf
	
	(cQry)->(DbCloseArea())		
	
Return(lRet)


Method Update(nPos) Class TAFDepositoIdentificado

	DbSelectArea("ZK8")
	ZK8->(DbGoTo(::oLst:GetItem(nPos):nRecNo))
	
	RecLock("ZK8", .F.)
		
		ZK8->ZK8_STATUS := "B"
		
	ZK8->(MsUnLock())

	DbSelectArea("ZK4")
	ZK4->(DbGoTo(::oLst:GetItem(nPos):nRecNoZK4))
	
	RecLock("ZK4", .F.)
		
		ZK4->ZK4_STATUS := "2"
		
	ZK4->(MsUnLock())

Return()


Method Confirm() Class TAFDepositoIdentificado
Local nCount := 1
Local oObjDepId := TAFProrrogacaoBoletoReceber():New(.F.)

	While nCount <= ::oLst:GetCount()
		
		If ::oLst:GetItem(nCount):lOK					
				
			Begin Transaction
							
				If ::BankReceipt(nCount)
					
					oObjDepId:BaixaDepAntJR(.F.) 

					::Update(nCount)
					
					::oLog:SetProperty()
					
					::oLog:cIDProc := ::oPro:cIDProc
					::oLog:cTabela := RetSQLName("ZK8")
					::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
					::oLog:cHrFin := Time()
					::oLog:cRetMen := "DEPOSITO - [BAIXADO]"
					::oLog:cOperac := "R"
					::oLog:cMetodo := "CR_DEP_IDE"
					::oLog:cEnvWF := "S"
					
					::oLog:Insert()
					
				EndIf
											
			End Transaction		
		
		Else
		
			::oLog:SetProperty()
			
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK8")
			::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "DEPOSITO - [NÃO LOCALIZADO]"
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_DEP_IDE"
			::oLog:cEnvWF := "S"
	
			::oLog:Insert()
			
			::SetConsoleLog()
						
		EndIf
			
		nCount++
		
	EndDo()
	
Return()


Method BankReceipt(nPos) Class TAFDepositoIdentificado
Local aArea := GetArea()
Local dDtAux := dDataBase
Local aTit := {}
Local nCount := 1

Private lMsErroAuto 	:= .F.
Private lMsHelpAuto 	:= .T.
Private lAutoErrNoFile	:= .T.

	dDataBase := ::oLst:GetItem(nPos):dDtCont
	
	// Posiciona no banco da baixa para o identificacao no lancamento contabil
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	SA6->(DbSeek(xFilial("SA6") + ::oLst:GetItem(nPos):cBanco + ::oLst:GetItem(nPos):cAgencia + ::oLst:GetItem(nPos):cConta))	

	While nCount <= ::oLst:GetItem(nPos):oLst:GetCount()
		
		aTit := {}
		
		lMsErroAuto 	:= .F.
		lMsHelpAuto 	:= .T.
		lAutoErrNoFile	:= .T.

		DbSelectArea("SE1")
		SE1->(DbGoTo(::oLst:GetItem(nPos):oLst:GetItem(nCount):nRecNo))
		
		aAdd(aTit, {"E1_PREFIXO", ::oLst:GetItem(nPos):oLst:GetItem(nCount):cPrefixo, Nil})
		aAdd(aTit, {"E1_NUM", ::oLst:GetItem(nPos):oLst:GetItem(nCount):cNumero, Nil})
		aAdd(aTit, {"E1_PARCELA", ::oLst:GetItem(nPos):oLst:GetItem(nCount):cParcela, Nil})
		aAdd(aTit, {"E1_TIPO", ::oLst:GetItem(nPos):oLst:GetItem(nCount):cTipo, Nil})
		aAdd(aTit, {"AUTMOTBX", "NOR", Nil})
		aAdd(aTit, {"AUTBANCO", ::oLst:GetItem(nPos):cBanco, Nil})
		aAdd(aTit, {"AUTAGENCIA", ::oLst:GetItem(nPos):cAgencia, Nil})
		aAdd(aTit, {"AUTCONTA", ::oLst:GetItem(nPos):cConta, Nil})
		aAdd(aTit, {"AUTDTBAIXA", ::oLst:GetItem(nPos):dDtLanc, Nil})
		aAdd(aTit, {"AUTDTCREDITO", ::oLst:GetItem(nPos):dDtCont, Nil})
		aAdd(aTit, {"AUTJUROS", ::oLst:GetItem(nPos):oLst:GetItem(nCount):nJuros, Nil,.T.})
		aAdd(aTit, {"AUTVALREC", ::oLst:GetItem(nPos):oLst:GetItem(nCount):nSaldo, Nil})
	
		MsExecAuto({|x,y| FINA070(x,y)}, aTit, 3)
	
		If !lMsErroAuto
	
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("SE1")
			::oLog:nIDTab := ::oLst:GetItem(nPos):oLst:GetItem(nCount):nRecNo
			::oLog:dDtIni := dDtAux
			::oLog:dDtFin := dDtAux
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Baixa automatica - [OK]"
			::oLog:cOperac := "R"
			::oLog:cMetodo := "DEP_BAI_TIT"
			::oLog:cEnvWF := "N"

			::oLog:Insert()
			
			::SetConsoleLog()		
			
		Else

			varinfo( "", aTit )

			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("SE1")
			::oLog:nIDTab := ::oLst:GetItem(nPos):oLst:GetItem(nCount):nRecNo
			::oLog:dDtIni := dDtAux
			::oLog:dDtFin := dDtAux
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Baixa automatica - [ERRO] - " + Chr(13) + ::GetErrorLog()
			::oLog:cOperac := "R"
			::oLog:cMetodo := "DEP_BAI_TIT"
			::oLog:cEnvWF := "S"

			::oLog:Insert()
					
			::SetConsoleLog(::GetErrorLog())
					
		EndIf
		
		nCount++
		
	EndDo()
	
	dDataBase := dDtAux
	
	RestArea(aArea)

Return(!lMsErroAuto)

Method CancProrrog() Class TAFDepositoIdentificado

Local cSQL := ""
Local cQry := GetNextAlias()
Local oObjDepId := TAFProrrogacaoBoletoReceber():New(.F.)

	cSQL += " SELECT * "
	cSQL += " FROM " + RetSQLName("ZKC") + " A"
	cSQL += " WHERE A.ZKC_FILIAL = " + ValToSQL(xFilial("ZKC"))
	cSQL += " AND A.ZKC_PREFIX = 'JR' "
	cSQL += " AND CONVERT(VARCHAR(08), DATEADD(DAY, 5, CAST(A.ZKC_EMISSA AS DATE)), 112) < CONVERT(VARCHAR(08), GETDATE(), 112) "
	cSQL += " AND A.ZKC_STATUS <> 'C' "
	cSQL += " AND EXISTS ( "
	cSQL += " 				SELECT NULL "
	cSQL += " 				FROM   " + RetSQLName("SE1") + " B (NOLOCK) "
	cSQL += " 				WHERE  B.E1_FILIAL = A.ZKC_FILIAL "
	cSQL += " 				AND  B.E1_NUM     = A.ZKC_NUM "
	cSQL += " 				AND  B.E1_PREFIXO = A.ZKC_PREFIX "
	cSQL += " 				AND  B.E1_PARCELA = A.ZKC_PARCEL "
	cSQL += " 				AND  B.E1_CLIENTE = A.ZKC_CLIFOR "
	cSQL += " 				AND  B.E1_LOJA    = A.ZKC_LOJA "
	cSQL += " 				AND  B.E1_SALDO   = B.E1_VALOR "
	cSQL += " 				AND  B.D_E_L_E_T_ = '' "
	cSQL += " 			) "
	cSQL += " AND A.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY ZKC_NUMERO "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		oObjDepId:ExcDepAntJR((cQry)->ZKC_NUMERO, .T., ::oPro:cIDProc)
						
		(cQry)->(DbSkip())
			
	EndDo()

	(cQry)->(DbCloseArea())

Return()

Method GetErrorLog() Class TAFDepositoIdentificado
Local cRet := ""
Local nCount := 1
	
	aError := GetAutoGrLog()
	
	For nCount := 1 To Len(aError)
	
		cRet += aError[nCount] + CRLF
		
	Next
	
Return(cRet)


Method SetConsoleLog(cError) Class TAFDepositoIdentificado
Local cLog := ""
Local lError := .F.

	Default cError := ""
	
	lError := If (!Empty(cError), .T., .F.)

	cLog := Replicate("-", 120) + Chr(13)
	cLog += "[" + Dtoc(Date()) + Space(1) + Time() + "] -- Automacao Financeira -- Baixa Automatica - DEP -- [" + If (lError, "ERRO", "OK") + "]" + Chr(13)
	cLog += "[Thread: " + AllTrim(cValToChar(ThreadId())) + "]" + Chr(13)
	cLog += "[Empresa: " + cEmpAnt + "]" + Chr(13)
	cLog += "[Filial: " + cFilAnt + "]" + Chr(13)
	cLog += "[Processo: " + ::oPro:cIDProc + "]" + Chr(13)
	cLog += "[Prefixo: " + AllTrim(SE2->E2_PREFIXO) + "]" + Chr(13)
	cLog += "[Numero: " + AllTrim(SE2->E2_NUM) + "]" + Chr(13)
	cLog += "[Parcela: " + AllTrim(SE2->E2_PARCELA) + "]" + Chr(13)
	
	If lError
		
		cLog += "[Erro: " + AllTrim(cError) + "]" + Chr(13)
		
	EndIf

	cLog += Replicate("-", 120)
	
	ConOut(Chr(13) + cLog)

Return()
