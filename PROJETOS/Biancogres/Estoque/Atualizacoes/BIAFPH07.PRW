#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "tbiconn.ch"

User Function BIAFPH07()

	//select cast(ZLJ_RETINT as varchar(max)) ,* from ZLJ010
	Conout("BIAFPH07 Inicio ")
		ProcTransferencia()
		ProcRequisicao()
	Conout("BIAFPH07 Fim ")

	U_BIAFPH08()		
			
Return

Static Function ProcRequisicao()
	
	Local cAliasTrab	:= ""
	Local cQuery		:= ""
	
	Local cProd			:= ""
	Local nQuant		:= ""
	Local cClasseVr		:= ""
	Local cLocal		:= "" 
	Local cTipoMov		:= "502"
	Local nIdEco		:= 0 
	Local oItem			:= Nil
	Local cLocaliza		:= ""
	Local cOriMov		:= ""
	Local cTag			:= ""
	Local cAplica		:= "1"
	Local cMatric		:= ""
	Local cTempo		:=	Time()
	
	
	RpcSetEnv('01','01')

		cAliasTrab := GetNextAlias()
		
		cQuery	:=	"SELECT 	*																		"
		cQuery	+=	" FROM "+RetSQLName("ZLJ")+" ZLJ													"
		cQuery	+=	" WHERE D_E_L_E_T_	= ''					AND										"	
		cQuery	+=	" ZLJ_STATUS		= '0'					AND										"	
		cQuery	+=	" ZLJ_TIPO			IN ('R')														"	
		cQuery	+=	" ORDER BY	R_E_C_N_O_																"	
		
		TCQuery cQuery New Alias cAliasTrab
	
	BEGIN TRANSACTION
	
	While !cAliasTrab->(EoF())
		
		
		If (cAliasTrab->ZLJ_EMP <> cEmpAnt .Or. cAliasTrab->ZLJ_FIL <> cFilAnt)
			RpcClearEnv()
			RpcSetEnv(cAliasTrab->ZLJ_EMP, cAliasTrab->ZLJ_FIL)
		EndIf
		
		
			cProd 		:= cAliasTrab->ZLJ_PROD
			cLocal		:= GETNEWPAR("MV_YARDETC", "07")
			nQuant 		:= cAliasTrab->ZLJ_QUANT
			cClasseVr	:= cAliasTrab->ZLJ_CLVL
			cTag		:= cAliasTrab->ZLJ_TAG
			cMatric		:= cAliasTrab->ZLJ_MATRIC
			dDataEmis	:= Iif(cTempo >= '00:00:00' .And. cTempo <= '05:59:59',DaySub(dDatabase,1),dDataBase)
	
			
			oItem := TMovimentacaoInterna():New(3, cProd, cLocal, nQuant, cClasseVr, cTipoMov, dDataEmis, nIdEco, cLocaliza, cOriMov, cTag, cAplica, cMatric)
			oItem:Executar()
			
			DbSelectArea('ZLJ')
			ZLJ->(DbSetOrder(0))
			ZLJ->(DbGoTo(cAliasTrab->R_E_C_N_O_))

			If (!ZLJ->(Eof()))
				
				Reclock("ZLJ", .F.)
					ZLJ->ZLJ_STATUS 	:= IIF(oItem:lOk, '1', '2')
					ZLJ->ZLJ_RETINT 	:= oItem:cMensagem
					ZLJ->ZLJ_DTINT 		:= Date()
					ZLJ->ZLJ_HRINT 		:= SUBSTR(Time(), 1, 5)
				ZLJ->(MsUnlock())
				
			EndIf		
			
		
		cAliasTrab->(DbSkip())
	EndDo
	
	RpcSetEnv('01','01')
	
	cAliasTrab->(DbCloseArea())
	
	END TRANSACTION
	
	RpcClearEnv()
	
	
Return 

Static Function ProcTransferencia()

	Local cAliasTrab	:= ""
	Local cQuery		:= ""
	
	Local cProdOri		:= ""
	Local nQuantOri		:= ""
	Local cLocalOri		:= ""
	Local cProdDest		:= ""
	Local cLocalDes		:= ""
	Local cDocumento	:= ""	
	Local cItem			:= ""
	Local oItem			:= Nil
		
	RpcSetEnv('01','01')

		cAliasTrab := GetNextAlias()
		
		cQuery	:=	" SELECT 	*																		"
		cQuery	+=	" FROM "+RetSQLName("ZLJ")+" ZLJ													"
		cQuery	+=	" WHERE D_E_L_E_T_	= ''					AND										"	
		cQuery	+=	" ZLJ_STATUS		= '0'					AND										"	
		cQuery	+=	" ZLJ_TIPO			IN ('D', 'T')													"	
		cQuery	+=	" ORDER BY	R_E_C_N_O_																"	
	
		TCQuery cQuery New Alias cAliasTrab
	
	BEGIN TRANSACTION
	
	While !cAliasTrab->(EoF())
		
		If (cAliasTrab->ZLJ_EMP <> cEmpAnt .Or. cAliasTrab->ZLJ_FIL <> cFilAnt)
			RpcClearEnv()
			RpcSetEnv(cAliasTrab->ZLJ_EMP, cAliasTrab->ZLJ_FIL)
		EndIf
		
			
		If  cAliasTrab->ZLJ_TIPO == 'D'
			cLocalOri		:= GETNEWPAR("MV_YATDETC", "07")
			cLocalDes		:= GETNEWPAR("MV_YATORIC", "01")
		Else
			cLocalOri		:= GETNEWPAR("MV_YATORIC", "01")
			cLocalDes		:= GETNEWPAR("MV_YATDETC", "07")
		EndIf
		
		cProdOri 	:= cAliasTrab->ZLJ_PROD
		cProdDest 	:= cAliasTrab->ZLJ_PROD
		nQuantOri	:= cAliasTrab->ZLJ_QUANT
		
		oItem := TTransferenciaInterna():New(3, cDocumento, cItem, cProdOri, cLocalOri, nQuantOri, cProdDest, cLocalDes)
		oItem:Executar()
		
		DbSelectArea('ZLJ')
		ZLJ->(DbSetOrder(0))
		ZLJ->(DbGoTo(cAliasTrab->R_E_C_N_O_))

		If (!ZLJ->(Eof()))
			
			Reclock("ZLJ", .F.)
				ZLJ->ZLJ_STATUS 	:= IIF(oItem:lOk, '1', '2')
				ZLJ->ZLJ_RETINT 	:= oItem:cMensagem
				ZLJ->ZLJ_DTINT 		:= Date()
				ZLJ->ZLJ_HRINT 		:= SUBSTR(Time(), 1, 5)
			ZLJ->(MsUnlock())
			
		EndIf		
	
		cAliasTrab->(DbSkip())
	EndDo
	
	RpcSetEnv('01','01')
	
	cAliasTrab->(DbCloseArea())
	
	END TRANSACTION
	
	RpcClearEnv()

Return 