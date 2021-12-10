#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TTipoNegociacaoTaxaCambio
@author Tiago Rossini Coradini
@since 19/11/2021
@version 1.0
@description Classe para tratamento de Tipos de Negociacoes de Taxa de Cambio
@obs Projeto: A-69 - Taxa de Câmbio
@type class
/*/

Class TTipoNegociacaoTaxaCambio From LongClassName
	
	Data cCodigo
	Data cDesc
	Data cTpCalc
	Data cOpCalc
	Data nQtd
	Data nQtdRet
	Data nMoeda
	Data nCotacao
	
	Method New() Constructor
	Method Set()
	Method Process() 
	Method Fixed()
	Method Average()
	
EndClass


Method New() Class TTipoNegociacaoTaxaCambio

	::cCodigo := ""
	::cDesc := ""
	::cTpCalc := ""
	::cOpCalc := ""
	::nQtd := 0
	::nQtdRet := 0
	::nMoeda := 0
	::nCotacao := 0

Return()


Method Set() Class TTipoNegociacaoTaxaCambio
Local lRet := .F.

	DbSelectArea("ZKV")
	ZKV->(DbSetOrder(1))
	If ZKV->(DbSeek(xFilial("ZKV") + ::cCodigo))
	
		::cDesc := ZKV->ZKV_DESC
		::cTpCalc := ZKV->ZKV_TPCALC
		::cOpCalc := ZKV->ZKV_OPCALC
		::nQtd := ZKV->ZKV_QTD
		::nQtdRet := ZKV->ZKV_QTDRET
		
		lRet := .T.
			
	EndIf

Return(lRet)


Method Process() Class TTipoNegociacaoTaxaCambio
	
	::Set()
	
	If ::cTpCalc == 'F'
	
		::Fixed()
	
	ElseIf ::cTpCalc == 'M'
		
		::Average()
		
	EndIf

Return()


Method Fixed() Class TTipoNegociacaoTaxaCambio
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT TOP 1 M2_MOEDA2, M2_MOEDA5 "
	cSQL += " FROM " + RetSQLName("SM2")
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("SM2"))
		
	If ::cOpCalc == "D"
		
		cSQL += " AND M2_DATA <= " + ValToSQL(DaySub(If (::nQtdRet == 0, dDataBase, DaySub(dDataBase, ::nQtdRet)), ::nQtd))
	
	ElseIf ::cOpCalc == "M"
	
		cSQL += " AND M2_DATA <= " + ValToSQL(MonthSub(If (::nQtdRet == 0, dDataBase, MonthSub(dDataBase, ::nQtdRet)), ::nQtd))
		
	EndIf
	
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)

	If ::nMoeda == 2

		::nCotacao := (cQry)->M2_MOEDA2
		
	Else::nMoeda == 5
	
		::nCotacao := (cQry)->M2_MOEDA5
	
	EndIf
	
	(cQry)->(DbCloseArea())

Return()


Method Average() Class TTipoNegociacaoTaxaCambio
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT AVG(M2_MOEDA2) AS M2_MOEDA2, AVG(M2_MOEDA5) AS M2_MOEDA5 "
	cSQL += " FROM " + RetSQLName("SM2")
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("SM2"))
		
	If ::cOpCalc == "D"
		
		cSQL += " AND M2_DATA BETWEEN " + ValToSQL(DaySub(If (::nQtdRet == 0, dDataBase, DaySub(dDataBase, ::nQtdRet)), ::nQtd)) + " AND " + ValToSQL(dDataBase)
	
	ElseIf ::cOpCalc == "M"
		
		cSQL += " AND M2_DATA BETWEEN " + ValToSQL(FirstDate(MonthSub(If (::nQtdRet == 0, MonthSub(dDataBase, 1), MonthSub(MonthSub(dDataBase, 1), ::nQtdRet)), ::nQtd))) + " AND " + ValToSQL(LastDate(MonthSub(dDataBase, 1)))
		
	EndIf
	
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)

	If ::nMoeda == 2

		::nCotacao := (cQry)->M2_MOEDA2
		
	Else::nMoeda == 5
	
		::nCotacao := (cQry)->M2_MOEDA5
	
	EndIf
	
	(cQry)->(DbCloseArea())

Return()