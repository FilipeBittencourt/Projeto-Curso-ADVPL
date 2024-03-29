#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TopConn.ch"

User Function PFAF0001()
	
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
	
	
	Conout("PFAF0001 => Antecipação Fornecedor: ")
		
	For nI := 1 to Len(aList)
		
		Conout("PFAF0001 => Antecipação Fornecedor: Empresa: "+aList[nI, 1]+", Filial: "+aList[nI, 2])
		
		RpcSetEnv(aList[nI, 1], aList[nI, 2])
			Processa(aList[nI, 1], aList[nI, 2])
		RpcClearEnv()
		
	Next nI

Return()
	
Static Function Processa(cEmp, cFil)	
	
	Local cAliasAnt			:= Nil
	Local cAliasItem		:= Nil
	Local cQuery			:= ""
	
	Local dDataRecebimento	:= ""
	Local nId				:= 0	
	Local cTipo				:= ""
	Local nTaxa				:= 0
	
	cQuery	+= " select ID=convert(int, [Antecipacao].ChaveUnica), EMPRESA=[EmpresaInterface].CodEmpresaERP, 								"	
	cQuery	+= " FILIAL=[EmpresaInterface].CodUnidadeERP,DATA=COnvert(Date, DataRecebimento), [Antecipacao].Tipo, [Antecipacao].Taxa		"				
	cQuery	+= " from [BPORTAL_SA].[dbo].[Antecipacao]																						"
	cQuery	+= " inner join [BPORTAL_SA].[dbo].[EmpresaInterface] ON [Antecipacao].UnidadeID = [EmpresaInterface].UnidadeID					" 
	cQuery	+= " WHERE 																														" 
	cQuery	+= "  		[Antecipacao].Status					= 2																			" 
	cQuery	+= "  and	[Antecipacao].StatusIntegracao			= 2																			" 
	cQuery	+= "  and	[EmpresaInterface].CodEmpresaERP		= '"+cEmp+"'																" 
	cQuery	+= "  and	[EmpresaInterface].CodUnidadeERP		= '"+cFil+"'																" 
	
	Conout("PFAF0001 => Antecipação Fornecedor: "+cQuery)
	
	cAliasAnt		:= GetNextAlias()
	TcQuery cQuery New Alias cAliasAnt	
		
	While !(cAliasAnt->(Eof()))
		
		oFatPagStruct 			:= TFaturaPagarStruct():New()
		
		nId					:= cValtoChar(cAliasAnt->ID)
		dDataRecebimento	:= (cAliasAnt->DATA) 
		nTaxa				:= cAliasAnt->Taxa
		cTipo				:= IIF(cAliasAnt->Tipo == 0, 'N', 'F')
		
		Conout("PFAF0001 => Antecipação Fornecedor: ID => "+nId)
		
		cAliasAnt->(DbSkip())
		
		cQuery	:= " select ValorAntecipado=ValorTituloAntecipado, Num=Convert(varchar(30), NumeroControleParticipante), ValorOriginal=ValorTitulo,	"
		cQuery	+= "  [AntecipacaoItem].*																											"
		cQuery	+= " from [BPORTAL_SA].[dbo].[AntecipacaoItem]																						"
		cQuery	+= " where [AntecipacaoItem].AntecipacaoID	= "+nId+"																				" 
		
		cAliasItem := GetNextAlias()
		TcQuery cQuery New Alias cAliasItem	
		
		While !(cAliasItem->(Eof()))
			
			oFatPagItemStruct 				:= TFaturaPagarItemStruct():New()
		 	oFatPagItemStruct:nId			:= Val(cAliasItem->Num)
		 	oFatPagItemStruct:nValorDesc	:= cAliasItem->ValorOriginal - cAliasItem->ValorAntecipado 
		 	oFatPagItemStruct:nTaxa			:= nTaxa
		 	
		 	oFatPagStruct:oFatPagItens:Add(oFatPagItemStruct)
			
			cAliasItem->(DbSkip())
			
		EndDo
		
		cAliasItem->(DbCloseArea())
		
		oFatPagStruct:cPrefixo 			:= "APF" 
		oFatPagStruct:cTipo				:= "FT" 
		oFatPagStruct:lLoadDados		:= .T.
		oFatPagStruct:dDataRecebimento	:= dDataRecebimento
		oFatPagStruct:cTipoAntecipacao	:= cTipo
		
		oFaturaPagar	:=  TFaturaPagar():New(oFatPagStruct)
		oResult 		:= oFaturaPagar:Incluir()
	
		Conout("PFAF0001 => Antecipação Fornecedor: Retorno ExecAuto => "+cValtoChar(oResult:Mensagem))
		
		If (oResult:Ok)
			TCSqlExec(" UPDATE [BPORTAL_SA].[dbo].[Antecipacao] SET StatusIntegracao = 4 WHERE ChaveUnica = '"+nId+"' ")
		EndIf
		
		
	EndDo
	
	cAliasAnt->(DbCloseArea())

Return()