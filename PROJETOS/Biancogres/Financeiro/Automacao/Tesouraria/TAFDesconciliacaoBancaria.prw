#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFDesconciliacaoBancaria
@author Tiago Rossini Coradini
@since 01/07/2019
@project Automação Financeira
@version 1.0
@description Classe para desconciliacao de extrato e movimento bancario
@type class
/*/

Class TAFDesconciliacaoBancaria From LongClassName
	
	Data oParam // Parameter Object
	
	Method New(oParam) Constructor
	Method Process()
	Method BankStatement()
	Method BankMove()	

EndClass


Method New(oParam) Class TAFDesconciliacaoBancaria

	::oParam := oParam	
		
Return()


Method Process() Class TAFDesconciliacaoBancaria

	Begin Transaction

		::BankStatement()
		
		::BankMove()

	End Transaction

Return()


Method BankStatement() Class TAFDesconciliacaoBancaria
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("ZK4") + " ZK4 "
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
	cSQL += " AND ZK4_EMP = " + ValToSQL(cEmpAnt)
	cSQL += " AND ZK4_FIL = " + ValToSQL(cFilAnt)
	cSQL += " AND ZK4_TIPO = 'C' "
	cSQL += " AND ZK4_DTLANC BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte)
	cSQL += " AND ZK4_BANCO = " + ValToSQL(::oParam:cBanco)
	cSQL += " AND ZK4_AGENCI = " + ValToSQL(::oParam:cAgencia)
	cSQL += " AND ZK4_CONTA = " + ValToSQL(::oParam:cConta)
	cSQL += " AND ZK4_RECONC = 'S' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		DbSelectArea("ZK4")
		ZK4->(DbGoTo((cQry)->RECNO))
		
		RecLock("ZK4", .F.)
		
			ZK4->ZK4_RECONC := ""
		
		ZK4->(MsUnLock())

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return()


Method BankMove() Class TAFDesconciliacaoBancaria
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("SE5")
	cSQL += " WHERE E5_FILIAL = " + ValToSQL(cFilAnt)
	cSQL += " AND E5_DTDISPO BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte)
	cSQL += " AND E5_BANCO = " + ValToSQL(::oParam:cBanco)
	cSQL += " AND E5_AGENCIA = " + ValToSQL(::oParam:cAgencia)
	cSQL += " AND E5_CONTA = " + ValToSQL(::oParam:cConta)
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_RECONC = 'x' "
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
		
		DbSelectArea("SE5")
		SE5->(DbGoTo((cQry)->RECNO))
		
		RecLock("SE5", .F.)
		
			SE5->E5_RECONC := ""
		
		SE5->(MsUnLock())

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())
	
Return()