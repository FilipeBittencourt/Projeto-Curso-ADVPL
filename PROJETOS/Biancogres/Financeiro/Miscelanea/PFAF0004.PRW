#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} PFAF0004
Rotina para desamarrar as informa��es do FIDC do t�tulo em caso de cancelamento da 
antecipa��o no portal (antes do pagamento total)
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 19/10/2021
/*/
User Function PFAF0004()
	
	Local aList       := {}
	Local aListFilial := {}
	Local nI          := 0
	Local aArea       := Nil
	
	SetFunName('RPC')
	
	// If Select("SX6") <= 0
	// 	RpcSetEnv("01", "01")
	// EndIf

	aArea	:= GetArea()
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
	
	Conout("PFAF0004 => Antecipa��o Fornecedor Cancelamento: ")
		
	For nI := 1 to Len(aList)
		
		Conout("PFAF0004 => Antecipa��o Fornecedor Cancelamento: Empresa: "+aList[nI, 1]+", Filial: "+aList[nI, 2])
		
		RpcSetEnv(aList[nI, 1], aList[nI, 2])

			Processa(aList[nI, 1], aList[nI, 2])
			
		RpcClearEnv()
		
	Next nI

Return

	
Static Function Processa(cEmp, cFil)	
	
	Local cAliasAnt  := Nil
	Local cAliasItem := Nil
	Local cQuery     := ""
	
	Local nId        := 0
	Local lOk        := .T.
	Local cRecno     := ""
	
	cQuery	+= " select ID=convert(int, [Antecipacao].ChaveUnica)																			"	
	cQuery	+= " from [BPORTAL_SA].[dbo].[Antecipacao]																						"
	cQuery	+= " inner join [BPORTAL_SA].[dbo].[EmpresaInterface] ON [Antecipacao].UnidadeID = [EmpresaInterface].UnidadeID					" 
	cQuery	+= " WHERE 																														" 
	cQuery	+= "  		[Antecipacao].Status					      = 9																			" 
	cQuery	+= "  and	[Antecipacao].StatusIntegracao			= 4																			" 
	cQuery	+= "  and	[EmpresaInterface].CodEmpresaERP		= '"+cEmp+"'																" 
	cQuery	+= "  and	[EmpresaInterface].CodUnidadeERP		= '"+cFil+"'																" 
	cQuery	+= "  and	[Antecipacao].Tipo					        = 1																	" 
	
	Conout("PFAF0004 => Antecipa��o Fornecedor Cancelamento: "+cQuery)
	
	cAliasAnt		:= GetNextAlias()
	TcQuery cQuery New Alias cAliasAnt	
		
	While !(cAliasAnt->(Eof()))
		
		nId					:= cValtoChar(cAliasAnt->ID)
		
		Conout("PFAF0004 => Antecipa��o Fornecedor Cancelamento: ID => "+nId)
		
		
		cQuery	:= " select Num=Convert(varchar(30), NumeroControleParticipante)		"
		// cQuery	+= "  [AntecipacaoItem].*												"
		cQuery	+= " from [BPORTAL_SA].[dbo].[AntecipacaoItem]							"
		cQuery	+= " where [AntecipacaoItem].AntecipacaoID	= "+nId+"					" 
		
		cAliasItem := GetNextAlias()
		TcQuery cQuery New Alias cAliasItem	
		
		Begin Transaction
		
			While !( cAliasItem->( EoF() ) )
				
				cRecno := Val(cAliasItem->Num)

				lOk    := CancelaBaixa(cRecno)

				If lOk

					dbSelectArea('SE2')
					SE2->( dbSetOrder(0) )
					SE2->( dbGoTo(cRecno) )

					RecLock("SE2", .F.)
						SE2->E2_YANTTX	:= 0
						SE2->E2_YANTDES	:= 0
						SE2->E2_VENCTO 	:= SE2->E2_VENCORI
						SE2->E2_VENCREA := DataValida(SE2->E2_VENCORI, .T.)
					SE2->(MsUnLock())
					
				Else

					DisarmTransaction()
					Exit

				EndIf
				
				cAliasItem->(DbSkip())
				
			EndDo
			
			cAliasItem->(DbCloseArea())
			
			If lOk
				TCSqlExec(" UPDATE [BPORTAL_SA].[dbo].[Antecipacao] SET StatusIntegracao = 5 WHERE ChaveUnica = '"+nId+"' ")
			EndIf
		
		End Transaction
		
		cAliasAnt->( dbSkip() )
				
	EndDo
	
	cAliasAnt->( dbCloseArea() )

Return()


Static Function CancelaBaixa(nId) 
	
	Local aArea            := GetArea()
	Local aParcBaixa       := {}
	Local lOk              := .F.
	Local cMsgLog          := ""
	Local nI               := 0
	Local dDataBkp				 := dDataBase
	
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	DbSelectArea('SE2')
	SE2->(DbSetOrder(0))
	SE2->(DbGoTo(nId))

	If !SE2->( EoF() ) .And. SE2->E2_SALDO > 0	//|N�o cancela quando tiver baixa total |

		dDataBase	:= SE2->E2_BAIXA

		AADD(aParcBaixa, {"E2_FILIAL"   , SE2->E2_FILIAL   						, Nil})
		AADD(aParcBaixa, {"E2_PREFIXO"  , SE2->E2_PREFIXO   					, Nil})
		AADD(aParcBaixa, {"E2_NUM"      , SE2->E2_NUM      						, Nil})
		AADD(aParcBaixa, {"E2_PARCELA"  , SE2->E2_PARCELA  						, Nil})
		AADD(aParcBaixa, {"E2_TIPO"     , SE2->E2_TIPO      					, Nil})
		AADD(aParcBaixa, {"E2_FORNECE"  , SE2->E2_FORNECE   					, Nil})
		AADD(aParcBaixa, {"E2_LOJA"     , SE2->E2_LOJA      					, Nil})

		MsExecAuto ({|x,y| FINA080(x,y)}, aParcBaixa, 6)

		If !lMsErroAuto
			lOk			:= .T.
		Else

			lOk			:= .F.
			aErroAuto	:= GetAutoGRLog()

			For nI := 1 To Len(aErroAuto)
				cMsgLog += StrTran(StrTran(aErroAuto[nI], "<", ""), "-", "") + " "
			Next nI

		EndIf

		dDataBase	:= dDataBkp

	EndIf
	
	RestArea(aArea)

Return lOk
