#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TPorcelanatoBiancogresIncesa
@author Fernando Rocha
@since 16/07/2018
@version 1.0
@description Classe para controle dos processos do PBI - venda do mesmo Porcelanato nas Empresas Bianco e Incesa
@obs  Ticket
@type class
@version 2.0 Projeto Consolidação - o mesmo metodo ja verifica os estoques e traz os lotes e sugestão de quantidade em todas as empresas conforme prioridades
/*/


Class TPorcelanatoBiancogresIncesa From LongClassName

	Data EmpEst
	Data LocEst
	Data CodProduto
	Data Prioridade
	Data Lote
	Data Qtd_Solicit
	Data Saldo
	Data Qtd_Sug
	Data N_Pallets
	Data Qtd_Um_Pallet
	Data Qtd_Ponta
	Data Regra_Sug
	Data EscolheuSugestao
	

//parametros para a pesquisa de lote
	Data cCodPro
	Data nQtdDig
	Data cSegmento
	Data cCategoria
	Data cLotRes
	Data cIdTemp
	Data cItemPV
	Data nPercMax
	Data nPercMin
	Data lPalete
	Data cEmpAt		//Empresa que vai atender a quantidade solicitada (Branco para qualquer uma)
	Data nProxLote  //Parametro que define se a escolha vai ser do primeiro lote que nao gera ponta

//Lotes para considerar ou excluir - feito para atender Ticket 21667
	Data cLoteAdd
	Data cLoteExc
	
	Data cPrioSaldo
	Data nTolerancia
	Data ExibirTela
	Data lDFRA
	
	Data oWBrowse
	Data oDlg1
	Data oLayer
	Data oPanel1
	Data oBtnBar
	

	Method New() Constructor
	Method ChkEmpPro()
	Method TelaSugestao()
	Method LoadDados()
	Method GetLinha()

EndClass


Method New() Class TPorcelanatoBiancogresIncesa

	::EmpEst		:= ""
	::LocEst		:= ""
	::CodProduto	:= ""
	::Prioridade	:= 0
	::Lote			:= ""
	::Qtd_Solicit	:= 0
	::Saldo			:= 0
	::Qtd_Sug		:= 0
	::N_Pallets		:= 0
	::Qtd_Um_Pallet	:= 0
	::Qtd_Ponta		:= 0
	::Regra_Sug		:= ""
	::EscolheuSugestao	:= .F.
	::ExibirTela	:= .T.	
	::lDFRA			:= .F.
	
	//parametros para a pesquisa de lote
	::cCodPro		:= ""
	::nQtdDig		:= 0
	::cSegmento		:= ""
	::cCategoria	:= ""
	::cLotRes		:= ""
	::cIdTemp		:= ""
	::cItemPV		:= ""
	::nPercMax		:= 0
	::nPercMin		:= 0
	::cEmpAt		:= ""
	::nProxLote		:= 0
	::cLoteAdd		:= ""
	::cLoteExc		:= ""
	::cPrioSaldo	:= ""
	::nTolerancia	:= 0
	::oWBrowse		:= Nil

Return()

Method TelaSugestao() Class TPorcelanatoBiancogresIncesa
	
	Local oLayer		:= Nil
	Local aWBrowse		:= ::LoadDados() 
	
	Local nCol 			:= oMainWnd:nClientWidth
	Local nLin 			:= oMainWnd:nClientHeight

	Local nLinDlg 		:= nLin*.450
	Local nColDlg 		:= nCol*.500
	
	If (Len(aWBrowse) == 0)
		Return
	EndIf
	
	If (Len(aWBrowse) == 1)
		
		::EmpEst			:= aWBrowse[1][01]
		::LocEst			:= aWBrowse[1][02]
		::CodProduto		:= aWBrowse[1][03]
		::Prioridade		:= aWBrowse[1][04]
		::Lote				:= aWBrowse[1][05]
		::Qtd_Solicit		:= aWBrowse[1][06]
		::Saldo				:= aWBrowse[1][07]
		::Qtd_Sug			:= aWBrowse[1][08]
		::N_Pallets			:= aWBrowse[1][09]
		::Qtd_Um_Pallet		:= aWBrowse[1][10]
		::Qtd_Ponta			:= aWBrowse[1][11]
		::Regra_Sug			:= aWBrowse[1][12]
		::EscolheuSugestao	:= .T.
		
		If(::Qtd_Solicit == ::Saldo)
			Return
		EndIf
		
		If(::Qtd_Solicit == ::Qtd_Sug)
			Return
		EndIf
		
	EndIf
	
	If (!::ExibirTela)
		
		::EmpEst			:= ""
		::LocEst			:= ""
		::CodProduto		:= ""
		::Prioridade		:= 0
		::Lote				:= ""
		::Qtd_Solicit		:= 0
		::Saldo				:= 0
		::Qtd_Sug			:= 0
		::N_Pallets			:= 0
		::Qtd_Um_Pallet		:= 0
		::Qtd_Ponta			:= 0
		::Regra_Sug			:= ""
		::EscolheuSugestao	:= .F.
		
		
		If (Len(aWBrowse) > 0 .And. ::nProxLote == 1)
			::EmpEst			:= aWBrowse[1][01]
			::LocEst			:= aWBrowse[1][02]
			::CodProduto		:= aWBrowse[1][03]
			::Prioridade		:= aWBrowse[1][04]
			::Lote				:= aWBrowse[1][05]
			::Qtd_Solicit		:= aWBrowse[1][06]
			::Saldo				:= aWBrowse[1][07]
			::Qtd_Sug			:= aWBrowse[1][08]
			::N_Pallets			:= aWBrowse[1][09]
			::Qtd_Um_Pallet		:= aWBrowse[1][10]
			::Qtd_Ponta			:= aWBrowse[1][11]
			::Regra_Sug			:= aWBrowse[1][12]
			::EscolheuSugestao	:= .T.
		EndIf
		
		Return
		
	EndIf
	
	::oDlg1 			:= MsDialog():New(10, 10, nLinDlg, nColDlg, "Lotes Sugeridos",,,,DS_MODALFRAME,,,,,.T.)
	::oDlg1:lCentered 	:= .T.
	::oDlg1:bValid		:= {|| .F. }
	::oDlg1:lEscClose 	:= .F.

	::oLayer	:= FWLayer():New()
	::oLayer:Init(::oDlg1, .F., .T.)

	::oLayer:AddLine("LIN1", 80, .F.)
	::oLayer:AddCollumn("COL1", 100, .T., "LIN1")
	::oLayer:AddWindow("COL1", "WND1", "LotesSugeridos", 100, .F. ,.T.,, "LIN1", { || })
	::oPanel1 := ::oLayer:GetWinPanel("COL1", "WND1", "LIN1")
	
	::oWBrowse 			:= TCBrowse():New(000,000,000,000,,,,::oPanel1,,,,,,,,,,,,.F.,,.T.,,.F.)
	::oWBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
	::oWBrowse:lHScroll := .T.
	::oWBrowse:lVScroll := .T.
	
//	::oWBrowse:AddColumn(TcColumn():New("Empresa"		, {|| aWBrowse[::oWBrowse:nAt, 01]}, "@!"					,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
//	::oWBrowse:AddColumn(TcColumn():New("Local"			, {|| aWBrowse[::oWBrowse:nAt, 02]}, "@!"					,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	::oWBrowse:AddColumn(TcColumn():New("Produto"		, {|| aWBrowse[::oWBrowse:nAt, 03]}, "@!"					,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
//	::oWBrowse:AddColumn(TcColumn():New("Prioridade"	, {|| aWBrowse[::oWBrowse:nAt, 04]}, "@!"					,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	::oWBrowse:AddColumn(TcColumn():New("Lote"			, {|| aWBrowse[::oWBrowse:nAt, 05]}, "@!"					,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
//	::oWBrowse:AddColumn(TcColumn():New("Qtd"			, {|| aWBrowse[::oWBrowse:nAt, 06]}, "@E 999,999.99"		,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
//	::oWBrowse:AddColumn(TcColumn():New("Saldo"			, {|| aWBrowse[::oWBrowse:nAt, 07]}, "@E 999,999.99"		,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	::oWBrowse:AddColumn(TcColumn():New("Qtd. Sug"		, {|| aWBrowse[::oWBrowse:nAt, 08]}, "@E 999,999.99"		,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
//	::oWBrowse:AddColumn(TcColumn():New("Pallet"		, {|| aWBrowse[::oWBrowse:nAt, 09]}, "@E 999,999.99"		,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
//	::oWBrowse:AddColumn(TcColumn():New("Qtd. Um Pal."	, {|| aWBrowse[::oWBrowse:nAt, 10]}, "@E 999,999.99"		,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
//	::oWBrowse:AddColumn(TcColumn():New("Ponta"			, {|| aWBrowse[::oWBrowse:nAt, 11]}, "@E 999,999.99"		,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	::oWBrowse:AddColumn(TcColumn():New("Regra"			, {|| aWBrowse[::oWBrowse:nAt, 12]}, "@E 999,999.99"		,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	
	
	::oWBrowse:SetArray(aWBrowse)
	::oWBrowse:Refresh()
	
	//::oWBrowse:bLDblClick	:= {|| ::GetLinha(aWBrowse, ::oWBrowse:nAt, .T.) }
	//::oWBrowse:bSeekChange	:= {|| ::GetLinha(aWBrowse, ::oWBrowse:nAt, .T.) }
	
	::oBtnBar := FWButtonBar():New()
	::oBtnBar:Init(::oDlg1, 020, 020, CONTROL_ALIGN_BOTTOM, .T.)
	::oBtnBar:AddBtnText("SELECIONAR", "SELECIONAR", {|| ::GetLinha(aWBrowse, ::oWBrowse:nAt, .T.) },,,CONTROL_ALIGN_RIGHT, .T.)
	::oBtnBar:AddBtnText("CANCELAR", "CANCELAR", {||  ::GetLinha(aWBrowse, ::oWBrowse:nAt, .F.) },,,CONTROL_ALIGN_RIGHT, .T.)
	
	
	::oDlg1:Activate()
	
Return

Method LoadDados() Class TPorcelanatoBiancogresIncesa
	
	Local cAliasTmp := GetNextAlias()
	Local cExpEmp

	Local aBrwList	:= {}
	Local cLinha 	:= {}
	
	Local __cLoteAdd := "% default %"
	Local __cLoteExc := "% default %"
	
	//Aadd(aBrwList,{"", "", "", "", "", 0, 0, 0, 0, 0, 0, 0})
	
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+::cCodPro))

		If Empty(::cEmpAt )

			cExpEmp := "% default %"

		Else

			cExpEmp := ::cEmpAt

		EndIf

		//Regra de verificar todas as empresas que tem estoque disponivel
		cAliasTmp := GetNextAlias()

		IF ( GetNewPar("FA_PRCLF35","N") == "S" )

			BeginSql Alias cAliasTmp
			%NoParser%

			select * from  FNC_ROP_GET_ESTEMP(
			%Exp:AllTrim(CEMPANT)%,
			%Exp:self:cCodPro%,
			%Exp:self:nQtdDig%,
			%Exp:self:cSegmento%,
			%Exp:self:cCategoria%,
			%Exp:self:cLotRes%,
			%Exp:self:cIdTemp%,
			%Exp:self:cItemPV%,
			%Exp:self:nPercMax%,
			%Exp:self:nPercMin%,
			%Exp:IIF(self:lPalete,1,0)%,
			%Exp:cExpEmp%,
			%Exp:self:nProxLote%,
			%Exp:self:cLoteAdd%,
			%Exp:self:cLoteExc%,
			%Exp:self:cPrioSaldo%,
			%Exp:self:nTolerancia%,
			%Exp:IIF(self:lDFRA,1,0)%)
			
//cPrioSaldo
			order by PRI, SALDO

			EndSql

		ELSE

			BeginSql Alias cAliasTmp
			%NoParser%

			select * from  FNC_ROP_GET_ESTEMP(
			%Exp:AllTrim(CEMPANT)%,
			%Exp:self:cCodPro%,
			%Exp:self:nQtdDig%,
			%Exp:self:cSegmento%,
			%Exp:self:cCategoria%,
			%Exp:self:cLotRes%,
			%Exp:self:cIdTemp%,
			%Exp:self:cItemPV%,
			%Exp:self:nPercMax%,
			%Exp:self:nPercMin%,
			%Exp:IIF(self:lPalete,1,0)%,
			%Exp:cExpEmp%,
			%Exp:self:nProxLote%,
			%Exp:__cLoteAdd%,
			%Exp:__cLoteExc%,
			%Exp:self:cPrioSaldo%,
			%Exp:self:nTolerancia%,
			%Exp:IIF(self:lDFRA,1,0)%) 

			order by PRI, SALDO

			EndSql

		ENDIF

		(cAliasTmp)->(DbGoTop())
		
		conout("Query: "+GetLastQuery()[2])
		
		//Pega o primeiro lote retornado ja vem como prioridade
		While !(cAliasTmp)->(Eof())

			cLinha 		:= {}
			Aadd(cLinha, (cAliasTmp)->EMP)
			Aadd(cLinha, (cAliasTmp)->LOCEST)
			Aadd(cLinha, (cAliasTmp)->COD)
			Aadd(cLinha, (cAliasTmp)->PRI)
			Aadd(cLinha, (cAliasTmp)->LOTE)
			Aadd(cLinha, (cAliasTmp)->QTD)
			Aadd(cLinha, (cAliasTmp)->SALDO)
			Aadd(cLinha, (cAliasTmp)->QTD_SUG)
			Aadd(cLinha, (cAliasTmp)->N_PALLETS)
			Aadd(cLinha, (cAliasTmp)->QT_UM_PALLET)
			Aadd(cLinha, (cAliasTmp)->QT_PONTA)
			Aadd(cLinha, (cAliasTmp)->REGRA)
			
			Aadd(aBrwList, cLinha)
			
			(cAliasTmp)->(DbSkip())
			
		EndDo

		(cAliasTmp)->(DbCloseArea())

	EndIf
	
Return aBrwList

Method GetLinha(aBrwList, nBrwAT, lAceitar) Class TPorcelanatoBiancogresIncesa

	If nBrwAT <= 0
		Return
	EndIf
	
	::EmpEst			:= aBrwList[nBrwAT][01]
	::LocEst			:= aBrwList[nBrwAT][02]
	::CodProduto		:= aBrwList[nBrwAT][03]
	::Prioridade		:= aBrwList[nBrwAT][04]
	::Lote				:= aBrwList[nBrwAT][05]
	::Qtd_Solicit		:= aBrwList[nBrwAT][06]
	::Saldo				:= aBrwList[nBrwAT][07]
	::Qtd_Sug			:= aBrwList[nBrwAT][08]
	::N_Pallets			:= aBrwList[nBrwAT][09]
	::Qtd_Um_Pallet		:= aBrwList[nBrwAT][10]
	::Qtd_Ponta			:= aBrwList[nBrwAT][11]
	::Regra_Sug			:= aBrwList[nBrwAT][12]
	::EscolheuSugestao	:= lAceitar
	
	::oDlg1:End()
Return



Method ChkEmpPro() Class TPorcelanatoBiancogresIncesa

	Local cAliasTmp := GetNextAlias()
	Local cExpEmp
	
	Local __cLoteAdd := "% default %"
	Local __cLoteExc := "% default %"

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+::cCodPro))

		If Empty(::cEmpAt )

			cExpEmp := "% default %"

		Else

			cExpEmp := ::cEmpAt

		EndIf

		//Regra de verificar todas as empresas que tem estoque disponivel
		cAliasTmp := GetNextAlias()

		IF ( GetNewPar("FA_PRCLF35","N") == "S" )

			BeginSql Alias cAliasTmp
			%NoParser%

			select * from  FNC_ROP_GET_ESTEMP(
			%Exp:AllTrim(CEMPANT)%,
			%Exp:self:cCodPro%,
			%Exp:self:nQtdDig%,
			%Exp:self:cSegmento%,
			%Exp:self:cCategoria%,
			%Exp:self:cLotRes%,
			%Exp:self:cIdTemp%,
			%Exp:self:cItemPV%,
			%Exp:self:nPercMax%,
			%Exp:self:nPercMin%,
			%Exp:IIF(self:lPalete,1,0)%,
			%Exp:cExpEmp%,
			%Exp:self:nProxLote%,
			%Exp:self:cLoteAdd%,
			%Exp:self:cLoteExc%,
			%Exp:self:cPrioSaldo%,
			%Exp:self:nTolerancia%,
			%Exp:IIF(self:lDFRA,1,0)%) 

			order by PRI, SALDO

			EndSql

		ELSE

			BeginSql Alias cAliasTmp
			%NoParser%

			select * from  FNC_ROP_GET_ESTEMP(
			%Exp:AllTrim(CEMPANT)%,
			%Exp:self:cCodPro%,
			%Exp:self:nQtdDig%,
			%Exp:self:cSegmento%,
			%Exp:self:cCategoria%,
			%Exp:self:cLotRes%,
			%Exp:self:cIdTemp%,
			%Exp:self:cItemPV%,
			%Exp:self:nPercMax%,
			%Exp:self:nPercMin%,
			%Exp:IIF(self:lPalete,1,0)%,
			%Exp:cExpEmp%,
			%Exp:self:nProxLote%,
			%Exp:__cLoteAdd%,
			%Exp:__cLoteExc%,
			%Exp:self:cPrioSaldo%,
			%Exp:self:nTolerancia%,
			%Exp:IIF(self:lDFRA,1,0)%) 

			order by PRI, SALDO

			EndSql

		ENDIF

		(cAliasTmp)->(DbGoTop())
		
		conout("Query: "+GetLastQuery()[2])
		
		//Pega o primeiro lote retornado ja vem como prioridade
		IF	!(cAliasTmp)->(Eof())

			::EmpEst			:= (cAliasTmp)->EMP
			::LocEst			:= (cAliasTmp)->LOCEST
			::CodProduto		:= (cAliasTmp)->COD
			::Prioridade		:= (cAliasTmp)->PRI
			::Lote				:= (cAliasTmp)->LOTE
			::Qtd_Solicit		:= (cAliasTmp)->QTD
			::Saldo				:= (cAliasTmp)->SALDO
			::Qtd_Sug			:= (cAliasTmp)->QTD_SUG
			::N_Pallets			:= (cAliasTmp)->N_PALLETS
			::Qtd_Um_Pallet		:= (cAliasTmp)->QT_UM_PALLET
			::Qtd_Ponta			:= (cAliasTmp)->QT_PONTA
			::Regra_Sug			:= (cAliasTmp)->REGRA
			::EscolheuSugestao	:= .F.

		ENDIF

		(cAliasTmp)->(DbCloseArea())

	EndIf
	

Return()