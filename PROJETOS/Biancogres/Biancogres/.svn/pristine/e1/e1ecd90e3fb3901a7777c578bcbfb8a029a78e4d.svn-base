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

	Method New() Constructor
	Method ChkEmpPro()

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

Return()


Method ChkEmpPro() Class TPorcelanatoBiancogresIncesa

	Local cAliasTmp := GetNextAlias()
	Local cExpEmp

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
			%Exp:self:cLoteExc%) 

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
			%Exp:self:nProxLote%) 

			order by PRI, SALDO

			EndSql

		ENDIF

		(cAliasTmp)->(DbGoTop())

		//Pega o primeiro lote retornado ja vem como prioridade
		IF	!(cAliasTmp)->(Eof())

			::EmpEst		:= (cAliasTmp)->EMP
			::LocEst		:= (cAliasTmp)->LOCEST
			::CodProduto	:= (cAliasTmp)->COD
			::Prioridade	:= (cAliasTmp)->PRI
			::Lote			:= (cAliasTmp)->LOTE
			::Qtd_Solicit	:= (cAliasTmp)->QTD
			::Saldo			:= (cAliasTmp)->SALDO
			::Qtd_Sug		:= (cAliasTmp)->QTD_SUG
			::N_Pallets		:= (cAliasTmp)->N_PALLETS
			::Qtd_Um_Pallet	:= (cAliasTmp)->QT_UM_PALLET
			::Qtd_Ponta		:= (cAliasTmp)->QT_PONTA
			::Regra_Sug		:= (cAliasTmp)->REGRA

		ENDIF

		(cAliasTmp)->(DbCloseArea())

	EndIf

Return()