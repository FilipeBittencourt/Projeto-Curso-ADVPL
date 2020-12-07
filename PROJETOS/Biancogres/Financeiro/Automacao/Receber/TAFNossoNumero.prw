#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFNossoNumero
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe com as regras para geração do nosso numero por banco
@type class
/*/

Class TAFNossoNumero From LongClassName

	Data cEmp
	Data cBanco
	Data cAgencia
	Data cConta
	Data cSubCta
	
	Method New() Constructor
	Method Get()
	Method Get001() // Retorna nosso numero do banco do brasil - 001 
	Method Get021() // Retorna nosso numero do banco banestes - 021
	Method Get237() // Retorna nosso numero do banco bradesco - 237

EndClass


Method New() Class TAFNossoNumero

	::cEmp := cEmpAnt
	::cBanco := ""
	::cAgencia := ""
	::cConta := ""

Return()


Method Get() Class TAFNossoNumero
Local cRet := ""

	If ::cBanco == "001"
	
		cRet := ::Get001()
	
	ElseIf ::cBanco == "021"
	
		cRet := ::Get021()
		
	ElseIf ::cBanco == "237"
	
		cRet := ::Get237()
		
	EndIf

Return(cRet)


Method Get001() Class TAFNossoNumero
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSeq := "" 

	cSQL := " SELECT RTRIM(EE_YCOVLID) AS EE_YCOVLID, RTRIM(EE_FAXATU) AS EE_FAXATU, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("SEE")    
	cSQL += " WHERE EE_FILIAL = "+ ValToSQL(xFilial("SEE"))
	cSQL += " AND EE_CODIGO	= "+ ValToSQL(::cBanco)
	cSQL += " AND	EE_AGENCIA = "+ ValToSQL(::cAgencia)
	cSQL += " AND	EE_CONTA	= "+ ValToSQL(::cConta)
	cSQL += " AND	EE_SUBCTA	= "+ ValToSQL(::cSubCta)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->EE_FAXATU)
			
		cRet := Alltrim((cQry)->EE_YCOVLID) + Substr(Soma1((cQry)->EE_FAXATU), 3, 10)
	
		DbSelectArea("SEE")
		SEE->(DbGoTo((cQry)->RECNO))
		
		RecLock("SEE", .F.)
		
			SEE->EE_FAXATU := Soma1((cQry)->EE_FAXATU)
		
		SEE->(MsUnLock())
		
	EndIf

	(cQry)->(DbCloseArea())

Return(cRet)


Method Get021() Class TAFNossoNumero

	Local cRet := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSeq := ""

	cSQL := " SELECT RTRIM(EE_YCOVLID) AS EE_YCOVLID, RTRIM(EE_FAXATU) AS EE_FAXATU, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("SEE")    
	cSQL += " WHERE EE_FILIAL = "+ ValToSQL(xFilial("SEE"))
	cSQL += " AND EE_CODIGO	= "+ ValToSQL(::cBanco)
	cSQL += " AND	EE_AGENCIA = "+ ValToSQL(::cAgencia)
	cSQL += " AND	EE_CONTA	= "+ ValToSQL(::cConta)
	cSQL += " AND	EE_SUBCTA	= "+ ValToSQL(::cSubCta)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->EE_FAXATU)
	
		cRet := Substr(Soma1((cQry)->EE_FAXATU), 5, 8)
		
		DbSelectArea("SEE")
		SEE->(DbGoTo((cQry)->RECNO))
		
		RecLock("SEE", .F.)
		
			SEE->EE_FAXATU := Soma1((cQry)->EE_FAXATU)
		
		SEE->(MsUnLock())
		
	EndIf

	(cQry)->(DbCloseArea())

Return(cRet)


Method Get237() Class TAFNossoNumero
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSeq := ""

	cSQL := " SELECT RTRIM(EE_YCOVLID) AS EE_YCOVLID, RTRIM(EE_FAXATU) AS EE_FAXATU, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("SEE")    
	cSQL += " WHERE EE_FILIAL = "+ ValToSQL(xFilial("SEE"))
	cSQL += " AND EE_CODIGO	= "+ ValToSQL(::cBanco)
	cSQL += " AND	EE_AGENCIA = "+ ValToSQL(::cAgencia)
	cSQL += " AND	EE_CONTA	= "+ ValToSQL(::cConta)
	cSQL += " AND	EE_SUBCTA	= "+ ValToSQL(::cSubCta)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->EE_FAXATU)
	
		cRet := Substr(Soma1((cQry)->EE_FAXATU), 2, 11)
		
		DbSelectArea("SEE")
		SEE->(DbGoTo((cQry)->RECNO))
		
		RecLock("SEE", .F.)
		
			SEE->EE_FAXATU := Soma1((cQry)->EE_FAXATU)
		
		SEE->(MsUnLock())
		
	EndIf

	(cQry)->(DbCloseArea())

Return(cRet)