#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFConciliacaoBancaria
@author Tiago Rossini Coradini
@since 04/04/2019
@project Automação Financeira
@version 1.0
@description Classe para geracao movimentos bancarios automaticos via conciliacao bancaria
@type class
/*/

Class TAFConciliacaoBancaria From TAFAbstractClass

	Data cVwTypeExt // Tipo de visualização de extrato: E=Exclusivo; C=Compartilhado		
	Data cVwTypeMov // Tipo de visualização de movimentos bancarios: E=Exclusivo; C=Compartilhado
	
	Method New() Constructor
	Method Process()
	Method Analyze()
	Method Validate(oObj)
	Method Exist(oObj)
	Method ValidRules(oObj)
	Method Confirm(oObj)
	Method AddBankMove(oObj)
	Method GetHist(oObj)
	Method UpdStatus(nID, cStatus, cErro)
	Method GetErrorLog()

EndClass


Method New() Class TAFConciliacaoBancaria
	
	_Super:New()

	::cVwTypeExt := Upper(GetNewPar("MV_YVWTPEX", "C"))
	::cVwTypeMov := Upper(GetNewPar("MV_YVWTPMO", "C"))

Return()


Method Process(cIDProc) Class TAFConciliacaoBancaria
	
	::oPro:Start()
		
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "I_CON_BAN"

	::oLog:Insert()
	
	::Analyze()

	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "F_CON_BAN"

	::oLog:Insert()
		
	::oPro:Finish()
	
Return()


Method Analyze() Class TAFConciliacaoBancaria
Local cSQL := ""
Local cQry := GetNextAlias()
Local dDtIni := GetNewPar("MV_YULMES", FirstDate(dDatabase))

	cSQL := " SELECT ZK4_DATA, ZK4_TIPO, ZK4_BANCO, ZK4_AGENCI, ZK4_CONTA, CASE WHEN SUBSTRING(ZK4_TPLANC, 1, 1) = 'D' THEN 'P' ELSE 'R' END AS ZK4_TPLANC, "
	cSQL += " ZK4_DTLANC, ZK4_CDHIST, ZK4_VLTOT, ZK4_IDCNAB, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("ZK4")
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
	cSQL += " AND ZK4_EMP = " + ValToSQL(cEmpAnt)

	If ::cVwTypeExt == "E"
		
		cSQL += " AND ZK4_FIL = " + ValToSQL(cFilAnt)
		
	ElseIf ::cVwTypeExt == "C"
	
		cSQL += " AND ZK4_FIL BETWEEN " + ValToSQL(Space(Len(cFilAnt))) + " AND " + ValToSQL(Replicate("Z", Len(cFilAnt)))
			
	EndIf

	cSQL += " AND ZK4_TIPO = 'C' "
	cSQL += " AND ZK4_DTLANC BETWEEN " + ValToSQL(dDtIni) + " AND " + ValToSQL(dDatabase)
	cSQL += " AND ZK4_STATUS = '1' "
	cSQL += " AND ZK4_RECONC = '' "
	cSQL += " AND (
	cSQL += " 	ZK4_CDHIST IN  "
	cSQL += " 	( "
	cSQL += " 		SELECT ZKB_CODHIS "
	cSQL += " 		FROM " + RetSQLName("ZKB")
	cSQL += " 		WHERE ZKB_BANCO = ZK4_BANCO "
	cSQL += " 		AND D_E_L_E_T_ = '' "
	cSQL += " 		GROUP BY ZKB_CODHIS "
	cSQL += " 	) "
	cSQL += "		AND ZK4_DSHIST NOT LIKE '%CONTRATO%' "
	cSQL += "	) "
	cSQL += " AND D_E_L_E_T_ = ''	"
	cSQL += " ORDER BY ZK4_BANCO, ZK4_AGENCI, ZK4_CONTA, ZK4_DTLANC, ZK4_CDHIST, ZK4_VLTOT "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		oObj := TIAFRetornoBancario():New()
		
		oObj:dData := sToD((cQry)->ZK4_DATA)
		oObj:cTipo := (cQry)->ZK4_TIPO
		oObj:cBanco := (cQry)->ZK4_BANCO
		oObj:cAgencia := (cQry)->ZK4_AGENCI
		oObj:cConta := (cQry)->ZK4_CONTA
		oObj:cTpLanc := (cQry)->ZK4_TPLANC
		oObj:dDtLanc := sToD((cQry)->ZK4_DTLANC)
		oObj:cCdHist := (cQry)->ZK4_CDHIST
		oObj:nVlTot := (cQry)->ZK4_VLTOT
		oObj:cIdCnab := AllTrim((cQry)->ZK4_IDCNAB)		
		oObj:nID := (cQry)->RECNO

		If ::Validate(oObj)
	
			Begin Transaction
				
				::Confirm(oObj)
				
			End Transaction
					
		EndIf
		
		(cQry)->(DbSkip())
			
	EndDo()

	(cQry)->(DbCloseArea())
			
Return()


Method Validate(oObj) Class TAFConciliacaoBancaria
Local lRet := .F.
				
	lRet := !::Exist(oObj) .And. ::ValidRules(oObj)

Return(lRet)


Method Exist(oObj) Class TAFConciliacaoBancaria
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("SE5")

	If ::cVwTypeMov == "E"
		
		cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))
		
	ElseIf ::cVwTypeMov == "C"
	
		cSQL += " WHERE E5_FILIAL BETWEEN " + ValToSQL(Space(Len(cFilAnt))) + " AND " + ValToSQL(Replicate("Z", Len(cFilAnt)))
			
	EndIf

	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_BANCO = " + ValToSQL(oObj:cBanco)
	cSQL += " AND E5_AGENCIA = " + ValToSQL(oObj:cAgencia)
	cSQL += " AND E5_CONTA = " + ValToSQL(oObj:cConta)
	cSQL += " AND E5_RECPAG = " + ValToSQL(oObj:cTpLanc)
	cSQL += " AND E5_YIDAPIF = " + ValToSQL(oObj:nID)
	cSQL += " AND	D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If (lRet := (cQry)->RECNO > 0)

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Concilicao Bancaria via Extrato - [EXISTE]"
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_CON_BAN"
		::oLog:cEnvWF := "N"
		
		::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)
		
		::oLog:Insert()
			
	EndIf
			
	(cQry)->(DbCloseArea())
	
Return(lRet)


Method ValidRules(oObj) Class TAFConciliacaoBancaria
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ZKB_NATFIN, ZKB_MOVBAN "
	cSQL += " FROM " + RetSQLName("ZKB")
	cSQL += " WHERE ZKB_FILIAL = " + ValToSQL(xFilial("ZKB"))
	cSQL += " AND ZKB_BANCO = " + ValToSQL(oObj:cBanco)
	cSQL += " AND ZKB_CODHIS = " + ValToSQL(oObj:cCdHist)
	cSQL += " AND ((ZKB_TARIFA = 'S' AND "+ ValToSQL(oObj:nVlTot) +" % CONVERT(DECIMAL(8, 2), NULLIF(ZKB_VALOR, 0)) = 0) OR ZKB_TARIFA = 'N') "
	cSQL += " AND	D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->ZKB_NATFIN)
	
		If (cQry)->ZKB_MOVBAN == "S"
		
			lRet := .T.
			
			oObj:cNatFin := (cQry)->ZKB_NATFIN
			
		Else
			
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Concilicao Bancaria via Extrato - [NAO GERA]"
			::oLog:cOperac := "P"
			::oLog:cMetodo := "CP_CON_BAN"
			::oLog:cEnvWF := "N"						
			
			::oLog:Insert()
			
			::UpdStatus(oObj:nID, "2")
			
		EndIf
		
	Else

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Concilicao Bancaria via Extrato - [VALOR INVALIDO]"
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_CON_BAN"
		::oLog:cEnvWF := "N"
		
		::UpdStatus(oObj:nID, "4", ::oLog:cRetMen)
		
		::oLog:Insert()
				
	EndIf
	
	(cQry)->(DbCloseArea())
	
Return(lRet)


Method Confirm(oObj) Class TAFConciliacaoBancaria
	
	dAuxAux := dDataBase
	
	dDataBase := oObj:dDtLanc

	::AddBankMove(oObj)
	
	dDataBase := dAuxAux
	
Return()


Method AddBankMove(oObj) Class TAFConciliacaoBancaria
Local aArea := GetArea()
Local aMovBan := {}
Local cLogTxt := ""
Private lMsErroAuto := .F.

	aAdd(aMovBan, {"E5_FILIAL", xFilial("SE5"), Nil})
	aAdd(aMovBan, {"E5_DATA", oObj:dDtLanc, Nil})
	aAdd(aMovBan, {"E5_DTDIGIT", oObj:dDtLanc, Nil})
	aAdd(aMovBan, {"E5_DTDISPO", oObj:dDtLanc, Nil})
	aAdd(aMovBan, {"E5_VALOR", oObj:nVlTot, Nil})
	aAdd(aMovBan, {"E5_NATUREZ", oObj:cNatFin, Nil})
	aAdd(aMovBan, {"E5_HISTOR", ::GetHist(oObj), Nil})
	aAdd(aMovBan, {"E5_RECPAG", oObj:cTpLanc, Nil})
	aAdd(aMovBan, {"E5_BANCO", oObj:cBanco, Nil})
	aAdd(aMovBan, {"E5_AGENCIA", oObj:cAgencia, Nil})
	aAdd(aMovBan, {"E5_CONTA", oObj:cConta, Nil})	
	aAdd(aMovBan, {"E5_YIDAPIF", oObj:nID, Nil})	
	aAdd(aMovBan, {"E5_MOEDA", "M1", Nil})
	aAdd(aMovBan, {"E5_TXMOEDA", 0, Nil})
	aAdd(aMovBan, {"E5_CLVLDB", U_BIA478G("ZJ0_CLVLDB", oObj:cNatFin, "P"), Nil})
	aAdd(aMovBan, {"E5_CCD", "1000", Nil})	
	aAdd(aMovBan, {"E5_FILORIG", cFilAnt, Nil})

	aMovBan := FWVetByDic(aMovBan, "SE5", .F., 1)

	MsExecAuto({|x,y,z| FINA100(x,y,z)}, 0, aMovBan, 3)
	
	If !lMsErroAuto

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Movimento Bancario via Extrato - [OK]"
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_CON_BAN"
		::oLog:cEnvWF := "N"
		
		::oLog:Insert()
		
		::UpdStatus(oObj:nID, "2")
		
	Else
						
		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Movimento Bancario via Extrato - [ERRO]"
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_CON_BAN"
		::oLog:cEnvWF := "N"
		
		::oLog:Insert()
		
		::UpdStatus(oObj:nID, "1", ::GetErrorLog())
		
		DisarmTransaction()

	EndIf
	
	RestArea(aArea)

Return()


Method GetHist(oObj) Class TAFConciliacaoBancaria
Local cRet := ""
Local lFiname := oObj:cCdHist == "0177"
	
	DbSelectArea("SED")
	DbSetOrder(1)
	If SED->(DbSeek(xFilial("SED") + oObj:cNatFin))
	
		cRet := AllTrim(SED->ED_YHIST) + If (lFiname, Space(1) + "-" + Space(1) + AllTrim(oObj:cIdCnab), "")
	
	EndIf

Return(cRet)


Method UpdStatus(nID, cStatus, cErro) Class TAFConciliacaoBancaria

	Default cStatus := ""
	Default cErro := ""
		
	DbSelectArea("ZK4")
	ZK4->(DbGoTo(nID))

	RecLock("ZK4", .F.)

		ZK4->ZK4_STATUS := cStatus
		ZK4->ZK4_ERRO := cErro

	ZK4->(MsUnLock())

Return()


Method GetErrorLog() Class TAFConciliacaoBancaria
Local cRet := ""
Local nCount := 1
	
	aError := GetAutoGrLog()
	
	For nCount := 1 To Len(aError)
	
		cRet += aError[nCount] + CRLF
		
	Next
	
Return(cRet)