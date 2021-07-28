#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"

User Function PFAF0004()
	
	Local aList			:= {}
	Local nI			:= 0
	Local aArea 		:= Nil
	Local aListFilial	:= {}
	
	SetFunName('RPC')
	
	RpcSetEnv("01", "01")
		aArea 		:= GetArea()
		If ( select("SM0") == 0 )
			OpenSM0()
		EndIf
		
		aListFilial	:=	FWLoadSM0()
		For nI := 1 to Len(aListFilial)
			If (aListFilial[nI, 1] $ "01_06_13_14")
				Aadd(aList, {aListFilial[nI, 1], aListFilial[nI, 2]})
			EndIf
		Next nI
		RestArea( aArea )
	RpcClearEnv()
	
	
	Conout("PFAF0004 => Antecipação Fornecedor Cancelamento: ")
		
	For nI := 1 to Len(aList)
		
		Conout("PFAF0004 => Antecipação Fornecedor Cancelamento: Empresa: "+aList[nI, 1]+", Filial: "+aList[nI, 2])
		
		RpcSetEnv(aList[nI, 1], aList[nI, 2])
			Processa(aList[nI, 1], aList[nI, 2])
		RpcClearEnv()
		
	Next nI

Return()
	
Static Function Processa(cEmp, cFil)	
	
	Local cAliasAnt			:= Nil
	Local cAliasItem		:= Nil
	Local cQuery			:= ""
	
	Local nId				:= 0	
	Local lOk				:= .T.
	Local cRecno			:= ""
	
	cQuery	+= " select ID=convert(int, [Antecipacao].ChaveUnica)																			"	
	cQuery	+= " from [BPORTAL_SA].[dbo].[Antecipacao]																						"
	cQuery	+= " inner join [BPORTAL_SA].[dbo].[EmpresaInterface] ON [Antecipacao].UnidadeID = [EmpresaInterface].UnidadeID					" 
	cQuery	+= " WHERE 																														" 
	cQuery	+= "  		[Antecipacao].Status					= 9																			" 
	cQuery	+= "  and	[Antecipacao].StatusIntegracao			= 2																			" 
	cQuery	+= "  and	[EmpresaInterface].CodEmpresaERP		= '"+cEmp+"'																" 
	cQuery	+= "  and	[EmpresaInterface].CodUnidadeERP		= '"+cFil+"'																" 
	cQuery	+= "  and	[EmpresaInterface].Tipo					= 'F'																		" 
	
	Conout("PFAF0004 => Antecipação Fornecedor Cancelamento: "+cQuery)
	
	cAliasAnt		:= GetNextAlias()
	TcQuery cQuery New Alias cAliasAnt	
		
	While !(cAliasAnt->(Eof()))
		
		nId					:= cValtoChar(cAliasAnt->ID)
		
		Conout("PFAF0004 => Antecipação Fornecedor Cancelamento: ID => "+nId)
		
		
		cQuery	:= " select Num=Convert(varchar(30), NumeroControleParticipante)		"
		cQuery	+= "  [AntecipacaoItem].*												"
		cQuery	+= " from [BPORTAL_SA].[dbo].[AntecipacaoItem]							"
		cQuery	+= " where [AntecipacaoItem].AntecipacaoID	= "+nId+"					" 
		
		cAliasItem := GetNextAlias()
		TcQuery cQuery New Alias cAliasItem	
		
		Begin Transaction
		
			While !(cAliasItem->(Eof()))
				
				cRecno	:= Val(cAliasItem->Num)
				lOk 	:= CancelaBaixa(cRecno) 
				If (lOk)
					DbSelectArea('SE2')
					SE2->(DbSetOrder(0))
					SE2->(DbGoTo(cRecno))
					RecLock("SE2", .F.)
						SE2->E2_YANTTX	:= 0
						SE2->E2_YANTDES	:= 0
						SE2->E2_VENCTO 	:= DataValida(SE2->E2_VENCORI, .T.)
						SE2->E2_VENCREA := DataValida(SE2->E2_VENCORI, .T.)
					SE2->(MsUnLock())
				Else
					DisarmTransaction()
					Exit
				EndIf
				
				cAliasItem->(DbSkip())
				
			EndDo
			
			cAliasItem->(DbCloseArea())
			
			If (lOk)
				TCSqlExec(" UPDATE [BPORTAL_SA].[dbo].[Antecipacao] SET StatusIntegracao = 4 WHERE ChaveUnica = '"+nId+"' ")
			EndIf
		
		End Transaction
		
		cAliasAnt->(DbSkip())
				
	EndDo
	
	cAliasAnt->(DbCloseArea())

Return()


Static Function CancelaBaixa(nId) 
	
	Local aArea				:= GetArea()
	Local aParcBaixa 		:= {}
	Local lOk				:= .F.
	Local cMsgLog			:= ""
	Local nI				:= 0
	
	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile	:= .T.

	DbSelectArea('SE2')
	SE2->(DbSetOrder(0))
	SE2->(DbGoTo(nId))

	If (!SE2->(Eof()))

		AADD(aParcBaixa, {"E2_FILIAL"   , SE2->E2_FILIAL   						, Nil})
		AADD(aParcBaixa, {"E2_PREFIXO"  , SE2->E2_PREFIXO   					, Nil})
		AADD(aParcBaixa, {"E2_NUM"      , SE2->E2_NUM      						, Nil})
		AADD(aParcBaixa, {"E2_PARCELA"  , SE2->E2_PARCELA  						, Nil})
		AADD(aParcBaixa, {"E2_TIPO"     , SE2->E2_TIPO      					, Nil})
		AADD(aParcBaixa, {"E2_FORNECE"  , SE2->E2_FORNECE   					, Nil})
		AADD(aParcBaixa, {"E2_LOJA"     , SE2->E2_LOJA      					, Nil})

		MsExecAuto ({|x,y| FINA080(x,y)}, aParcBaixa, 6)

		If (!lMsErroAuto)
			lOk			:= .T.
		Else

			lOk			:= .F.
			aErroAuto	:= GetAutoGRLog()

			For nI := 1 To Len(aErroAuto)
				cMsgLog += StrTran(StrTran(aErroAuto[nI], "<", ""), "-", "") + " "
			Next nI

		EndIf

		::_oResult:Add(lOk, cMsgLog)

	EndIf
	
	RestArea(aArea)

Return lOk