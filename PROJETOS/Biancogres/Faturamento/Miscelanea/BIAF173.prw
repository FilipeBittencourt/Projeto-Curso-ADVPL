#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF173
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Ferramenta para replicação de aprovadores e alçadas de liberação de pedidos de vendas 
@type Function
/*/

User Function BIAF173()
Local cMarOri := "0101" 
Local cMarDes := "1302"

	RpcSetType(3)
	RpcSetEnv("01", "01")
	
	  Begin Transaction
	  
	  	fReplicate(cMarOri, cMarDes)
	  	
	  End Transaction
		
	RpcClearEnv()
				
Return()


Static Function fReplicate(cMarOri, cMarDes)
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT * " 
	cSQL += " FROM " + RetSQLName("ZKI")
	cSQL += " WHERE D_E_L_E_T_ = '' "
	cSQL += " AND ZKI_MARCA = " + ValToSQL(cMarOri)
	cSQL += " ORDER BY ZKI_ORDEM "

	TcQuery cSQL New Alias (cQry)
	
	If !(cQry)->(Eof())
		
		fDelZKJ(cMarDes)
		
		fDelZKK(cMarDes)

		fAddZKJ(cMarOri, cMarDes)
		
		fAddZKK(cMarOri, cMarDes)
					
	EndIf
	
	(cQry)->(DbCloseArea())

Return()


Static Function fDelZKJ(cMarDes)
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT R_E_C_N_O_ AS RECNO " 
	cSQL += " FROM " + RetSQLName("ZKJ")
	cSQL += " WHERE D_E_L_E_T_ = '' " 
	cSQL += " AND ZKJ_CODZKI IN "
	cSQL += " ( "
	cSQL += " 	SELECT ZKI_CODIGO  " 
	cSQL += " 	FROM " + RetSQLName("ZKI")
	cSQL += " 	WHERE D_E_L_E_T_ = '' "
	cSQL += " 	AND ZKI_MARCA = " + ValToSQL(cMarDes)
	cSQL += " ) "
	cSQL += " ORDER BY ZKJ_CODIGO "	

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		DbSelectArea("ZKJ")
		ZKJ->(DbGoTo((cQry)->RECNO))
		
		ZKJ->(RecLock("ZKJ", .F.))
		
			ZKJ->(dbDelete())
			
		ZKJ->(MsUnLock())
		
	  (cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return()


Static Function fDelZKK(cMarDes)
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT R_E_C_N_O_ AS RECNO " 
	cSQL += " FROM " + RetSQLName("ZKK")
	cSQL += " WHERE D_E_L_E_T_ = '' " 
	cSQL += " AND ZKK_CODZKI IN "
	cSQL += " ( "
	cSQL += " 	SELECT ZKI_CODIGO  " 
	cSQL += " 	FROM " + RetSQLName("ZKI")
	cSQL += " 	WHERE D_E_L_E_T_ = '' "
	cSQL += " 	AND ZKI_MARCA = " + ValToSQL(cMarDes)
	cSQL += " ) "
	cSQL += " ORDER BY ZKK_CODIGO "	

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		DbSelectArea("ZKK")
		ZKK->(DbGoTo((cQry)->RECNO))
		
		ZKK->(RecLock("ZKK", .F.))
		
			ZKK->(dbDelete())
			
		ZKK->(MsUnLock())
		
	  (cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return()


Static Function fAddZKJ(cMarOri, cMarDes)
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT * " 
	cSQL += " FROM " + RetSQLName("ZKJ")
	cSQL += " WHERE D_E_L_E_T_ = '' " 
	cSQL += " AND ZKJ_CODZKI IN "
	cSQL += " ( "
	cSQL += " 	SELECT ZKI_CODIGO  " 
	cSQL += " 	FROM " + RetSQLName("ZKI")
	cSQL += " 	WHERE D_E_L_E_T_ = '' "
	cSQL += " 	AND ZKI_MARCA = " + ValToSQL(cMarOri)
	cSQL += " ) "
	cSQL += " ORDER BY ZKJ_CODIGO "	

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		ZKJ->(RecLock("ZKJ", .T.))

			ZKJ->ZKJ_FILIAL := xFilial("ZKK")
			ZKJ->ZKJ_CODIGO := fGetMaxZKJ()
			ZKJ->ZKJ_ORIAPR := (cQry)->ZKJ_ORIAPR
			ZKJ->ZKJ_APROV := (cQry)->ZKJ_APROV
			ZKJ->ZKJ_APROVT := (cQry)->ZKJ_APROVT
			ZKJ->ZKJ_ORDEM := (cQry)->ZKJ_ORDEM
			ZKJ->ZKJ_ENVEM := (cQry)->ZKJ_ENVEM
			ZKJ->ZKJ_CODZKI := fGetCodMar(cMarDes, (cQry)->ZKJ_CODZKI)
			ZKJ->ZKJ_CODZKK := (cQry)->ZKJ_CODZKK
			ZKJ->ZKJ_NIVEL := (cQry)->ZKJ_NIVEL
					
		ZKJ->(MsUnLock())
		
	  (cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return()


Static Function fAddZKK(cMarOri, cMarDes)
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT * " 
	cSQL += " FROM " + RetSQLName("ZKK")
	cSQL += " WHERE D_E_L_E_T_ = '' " 
	cSQL += " AND ZKK_CODZKI IN "
	cSQL += " ( "
	cSQL += " 	SELECT ZKI_CODIGO  " 
	cSQL += " 	FROM " + RetSQLName("ZKI")
	cSQL += " 	WHERE D_E_L_E_T_ = '' "
	cSQL += " 	AND ZKI_MARCA = " + ValToSQL(cMarOri)
	cSQL += " ) "
	cSQL += " ORDER BY ZKK_CODIGO "	

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		ZKK->(RecLock("ZKK", .T.))
		
			ZKK->ZKK_FILIAL := xFilial("ZKK")
			ZKK->ZKK_CODIGO := fGetMaxZKK()
			ZKK->ZKK_CODZKI := fGetCodMar(cMarDes, (cQry)->ZKK_CODZKI)
			ZKK->ZKK_VALIN := (cQry)->ZKK_VALIN 
			ZKK->ZKK_VALFI := (cQry)->ZKK_VALFI
			
		ZKK->(MsUnLock())
		
	  (cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return()


Static Function fGetCodMar(cMarDes, cCodMar)
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ZKI_CODIGO "
	cSQL += " FROM " + RetSQLName("ZKI")
	cSQL += " WHERE D_E_L_E_T_ = '' " 
	cSQL += " AND ZKI_MARCA = " + ValToSQL(cMarDes)
	cSQL += " AND ZKI_ORDEM IN " 
	cSQL += " ( "
	cSQL += " 	SELECT ZKI_ORDEM "
	cSQL += " 	FROM " + RetSQLName("ZKI")
	cSQL += " 	WHERE D_E_L_E_T_ = '' " 
	cSQL += " 	AND ZKI_CODIGO = " + ValToSQL(cCodMar)
	cSQL += " ) "

	TcQuery cSQL New Alias (cQry)

	cRet := (cQry)->ZKI_CODIGO

	(cQry)->(DbCloseArea())

Return(cRet)


Static Function fGetMaxZKJ()
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT MAX(ZKJ_CODIGO) AS ZKJ_CODIGO
	cSQL += " FROM " + RetSQLName("ZKJ")
	cSQL += " WHERE D_E_L_E_T_ = ''	
	
	TcQuery cSQL New Alias (cQry)
	
	cRet := Soma1((cQry)->ZKJ_CODIGO)
	
	(cQry)->(DbCloseArea())	

Return(cRet)


Static Function fGetMaxZKK()
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT MAX(ZKK_CODIGO) AS ZKK_CODIGO
	cSQL += " FROM " + RetSQLName("ZKK")
	cSQL += " WHERE D_E_L_E_T_ = ''	
	
	TcQuery cSQL New Alias (cQry)
	
	cRet := Soma1((cQry)->ZKK_CODIGO)
	
	(cQry)->(DbCloseArea())	

Return(cRet)
