#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TCalculoSaldoDiarioCliente
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Classe para calculo do saldo diario acumulado dos clientes
@type class
/*/

Class TCalculoSaldoDiarioCliente From LongClassName
	
	Data dDate
	Data dStartDate
	Data dEndDate
	Data lAuto
	
	Method New() Constructor
	Method Process()
	Method Calc(cCliente, cLoja, cGrpVen, cCnpj, cConta)
	Method Save(dData, cCliente, cLoja, cGrpVen, cCnpj, nSaldo)
	Method Exist(dData, cCliente, cLoja)
	Method GetSeq()
	Method SetDate()
	Method SetMonth()
	Method SetDay()
	Method GetBalanceDate(cConta)
	
EndClass


Method New() Class TCalculoSaldoDiarioCliente

	::dDate := dDataBase
	::dStartDate := dDataBase
	::dEndDate := dDataBase
	::lAuto := .F.
	
Return()


Method Process()Class TCalculoSaldoDiarioCliente
Local cSQL := ""
Local cQry := GetNextAlias()

	If ::lAuto
		
		::SetDate()
	
	EndIf

	cSQL := " SELECT A1_COD, A1_LOJA, A1_GRPVEN, A1_CGC, A1_CONTA "
	cSQL += " FROM "+ RetSQLName("SA1") + " SA1 "
	cSQL += " INNER JOIN "+ RetSQLName("CQ1") + " CQ1 "
	cSQL += " ON A1_CONTA = CQ1_CONTA "
	cSQL += " WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " AND A1_PESSOA = 'J' "
	cSQL += " AND SUBSTRING(A1_CGC,1,8) NOT IN ('', '02077546', '04917232', '04548187', '10524837', '13231737', '14086214', '08930868') "
	cSQL += " AND A1_CONTA <> '' "
	cSQL += " AND SA1.D_E_L_E_T_ = '' "
	cSQL += " AND CQ1_FILIAL = " + ValToSQL(xFilial("CQ1"))
	cSQL += " AND CQ1_DATA BETWEEN "+ ValToSQL(::dStartDate) +" AND " + ValToSQL(::dEndDate)
	cSQL += " AND CQ1.D_E_L_E_T_ = '' "
	cSQL += " GROUP BY  A1_COD, A1_LOJA, A1_GRPVEN, A1_CGC, A1_CONTA " 	
	cSQL += " ORDER BY A1_COD, A1_LOJA "
	
	TcQuery cSQL New Alias (cQry)
		
	While !(cQry)->(Eof())
			
		::Calc((cQry)->A1_COD, (cQry)->A1_LOJA, (cQry)->A1_GRPVEN, (cQry)->A1_CGC, (cQry)->A1_CONTA)
		
		(cQry)->(DbSkip())
									
	EndDo()
	
	(cQry)->(DbCloseArea())

Return()


Method Calc(cCliente, cLoja, cGrpVen, cCnpj, cConta) Class TCalculoSaldoDiarioCliente
Local nSaldo := 0
Local cMoeda := "01"
Local aDate := {}
Local nCount := 0
	
	aDate := ::GetBalanceDate(cConta)

	If Len(aDate) > 0
	
		For nCount := 1 To Len(aDate)
		
			nSaldo := 0
	
			nSaldo := SaldoConta(cConta, aDate[nCount], cMoeda)
			
			If nSaldo < 0
			
				::Save(aDate[nCount], cCliente, cLoja, cGrpVen, cCnpj, nSaldo)
				
			EndIf			
		
		Next
	
	EndIf

Return()


Method Save(dData, cCliente, cLoja, cGrpVen, cCnpj, nSaldo) Class TCalculoSaldoDiarioCliente
Local nRecNo := 0
	
	If (nRecNo := ::Exist(dData, cCliente, cLoja)) == 0 
	
		RecLock("ZM2", .T.)
		
			ZM2->ZM2_FILIAL := xFilial("ZM2")
			ZM2->ZM2_CODIGO := ::GetSeq()
			ZM2->ZM2_EMP := cEmpAnt
			ZM2->ZM2_DATA := dData
			ZM2->ZM2_CLIENT := cCliente
			ZM2->ZM2_LOJA := cLoja
			ZM2->ZM2_GRUPO := cGrpVen
			ZM2->ZM2_CNPJ := cCnpj
			ZM2->ZM2_SALDO := nSaldo
		
		ZM2->(MsUnLock())
		
	Else
	
		DbSelectArea("ZM2")
		
		ZM2->(DbGoTo(nRecNo))
		
		RecLock("ZM2", .F.)
		
			ZM2->ZM2_GRUPO := cGrpVen
			ZM2->ZM2_SALDO := nSaldo
		
		ZM2->(MsUnLock())
	
	EndIf
	
Return()


Method Exist(dData, cCliente, cLoja) Class TCalculoSaldoDiarioCliente
Local nRet := 0
Local cSQL := ""
Local cQry := GetNextAlias()

	DbSelectArea("ZM2")

	cSQL := " SELECT ISNULL(R_E_C_N_O_, 0) AS RECNO "
	cSQL += " FROM "+ RetSQLName("ZM2")
	cSQL += " WHERE ZM2_FILIAL = "+ ValToSQL(xFilial("ZM2"))
	cSQL += " AND ZM2_EMP = "+ ValToSQL(cEmpAnt)
	cSQL += " AND ZM2_DATA = "+ ValToSQL(dData)
	cSQL += " AND ZM2_CLIENT = "+ ValToSQL(cCliente)
	cSQL += " AND ZM2_LOJA = "+ ValToSQL(cLoja)	
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	nRet := (cQry)->RECNO

	(cQry)->(DbCloseArea())

Return(nRet)


Method GetSeq() Class TCalculoSaldoDiarioCliente
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(MAX(ZM2_CODIGO), '') AS ZM2_CODIGO "
	cSQL += " FROM "+ RetSQLName("ZM2")
	cSQL += " WHERE ZM2_FILIAL = "+ ValToSQL(xFilial("ZM2"))
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	cRet := Soma1((cQry)->ZM2_CODIGO)

	(cQry)->(DbCloseArea())

Return(cRet)


Method SetDate() Class TCalculoSaldoDiarioCliente
	
	If GetMV("MV_ULMES") == LastDate(MonthSub(::dDate, 1))
	
		::SetMonth()
	
	Else
	
		::SetDay()
		
	EndIf
	
Return()


Method SetMonth() Class TCalculoSaldoDiarioCliente

	::dStartDate := FirstDate(MonthSub(::dDate, 1))
	
	::dEndDate := LastDate(MonthSub(::dDate, 1))

Return()


Method SetDay() Class TCalculoSaldoDiarioCliente

	::dStartDate := MonthSub(::dDate, 1)
	
	::dEndDate := MonthSub(::dDate, 1)

Return()


Method GetBalanceDate(cConta) Class TCalculoSaldoDiarioCliente
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT CQ1_DATA "
	cSQL += " FROM "+ RetSQLName("CQ1")
	cSQL += " WHERE CQ1_FILIAL = "+ ValToSQL(xFilial("CQ1"))
	cSQL += " AND CQ1_CONTA = "+ ValToSQL(cConta)
	cSQL += " AND CQ1_DATA BETWEEN "+ ValToSQL(::dStartDate) +" AND " + ValToSQL(::dEndDate) 
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY CQ1_DATA "
	cSQL += " ORDER BY CQ1_DATA "
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
		
		aAdd(aRet, sToD((cQry)->CQ1_DATA))
		
		(cQry)->(DbSkip())
									
	EndDo()
	
	(cQry)->(DbCloseArea())

Return(aRet)