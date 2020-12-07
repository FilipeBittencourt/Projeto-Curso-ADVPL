#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TCalculoFrete
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Classe Calculo de frete
@obs Ticket: 17739
@type class
/*/

Class TCalculoFreteVinilico From TCalculoFrete

	Data cCliente
	Data cLoja
	Data nQuant
	Data nPeso
	Data nFrtTon
	Data nVlrProd
	Data nVlrSeg
	Data nFatSeg	

	Method New() Constructor
	Method SetProperty()
	Method SetSourceAddress()
	Method SetDestinationAddress()
	Method SetBrand()
	Method SetCategory()
	Method SetRule()
	Method Get()
	Method CalcFrete()
	Method CalcSeguro()
	Method CalcFatSeg()
	Method CalcVlrProd()
	

EndClass


Method New() Class TCalculoFreteVinilico
	
	_Super:New()
	
	::cCliente := ""
	::cLoja := ""
	::nQuant := 0
	::nPeso := 0
	::nFrtTon := 0
	::nVlrProd := 0
	::nSeguro := 0
	::nVlrSeg := 0
	::nFatSeg := 0
		
Return()


Method SetProperty() Class TCalculoFreteVinilico
	
	::SetSourceAddress()
	
	::SetDestinationAddress()
	
	::SetBrand()
	
	::SetCategory()
	
	::SetRule()
	
Return()


Method SetSourceAddress() Class TCalculoFreteVinilico

	::cUFOri := SM0->M0_ESTCOB
	::cMunOri := SubStr(SM0->M0_CODMUN, 3, 5)
	
Return()


Method SetDestinationAddress() Class TCalculoFreteVinilico
Local aArea := GetArea()
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	If SA1->(DbSeek(xFilial("SA1") + ::cCliente + ::cLoja))
	
		::cUFDes := SA1->A1_EST
		::cMunDes := SA1->A1_COD_MUN
	
	EndIf
	
	RestArea(aArea)
	
Return()


Method SetBrand() Class TCalculoFreteVinilico
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(ZZ7_EMP, '') AS ZZ7_EMP "
	cSQL += "	FROM "+ RetSQLName("ZZ7") +" ZZ7 "
	cSQL += "	INNER JOIN "+ RetSQLName("SB1") +" SB1 "
	cSQL += "	ON ZZ7_COD = B1_YLINHA "
	cSQL += "	AND ZZ7_LINSEQ = B1_YLINSEQ "
	cSQL += "	WHERE ZZ7_FILIAL = " + ValToSQL(xFilial("ZZ7"))
	cSQL += "	AND ZZ7.D_E_L_E_T_ = '' "
	cSQL += "	AND B1_FILIAL = " + ValToSQL(xFilial("SB1"))
	cSQL += "	AND B1_COD = " + ValToSQL(::cProduto)
	cSQL += "	AND SB1.D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)

	::cMarca := AllTrim((cQry)->ZZ7_EMP)
	
	(cQry)->(DbCloseArea())

Return()


Method SetCategory() Class TCalculoFreteVinilico
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT dbo.GET_CATEGORIA_CLIENTE("+ ValToSQL(::cMarca) +", "+ ValToSQL(::cCliente) +", "+ ValToSQL(::cLoja) +") AS CATCLI "
	
	TcQuery cSQL New Alias (cQry)

	::cCategoria := AllTrim((cQry)->CATCLI)
	
	(cQry)->(DbCloseArea())

Return()


Method SetRule() Class TCalculoFreteVinilico
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(ZKN_FRTVEN, 0) / 1000 AS ZKN_FRTTON, ISNULL(ZKN_SEGURO, 0) AS ZKN_SEGURO, "
	cSQL += "	( "
	cSQL += "		CASE WHEN ZKN_MUNDES = "+ ValToSQL(::cMunDes) +" THEN 3 ELSE 0 END + "
	cSQL += "		CASE WHEN ZKN_CAT = "+ ValToSQL(::cCategoria) +" THEN 2 ELSE 0 END + "
	cSQL += "		CASE WHEN ZKN_PRODUT = "+ ValToSQL(::cProduto) +" THEN 1 ELSE 0 END "
	cSQL += "	) AS RANK "	
	cSQL += "	FROM "+ RetSQLName("ZKN")
	cSQL += "	WHERE ZKN_FILIAL = " + ValToSQL(xFilial("ZKN"))
	cSQL += "	AND ZKN_UFORI = " + ValToSQL(::cUFOri)
	cSQL += "	AND ZKN_MUNORI = " + ValToSQL(::cMunOri)
	cSQL += "	AND ZKN_UFDES = " + ValToSQL(::cUFDes)
	cSQL += "	AND ZKN_MARCA = " + ValToSQL(::cMarca)
	cSQL += "	AND D_E_L_E_T_ = '' "
	cSQL += "	ORDER BY RANK DESC, ZKN_FRTVEN DESC "
	
	TcQuery cSQL New Alias (cQry)

	::nFrtTon := (cQry)->ZKN_FRTTON
	::nSeguro := (cQry)->ZKN_SEGURO
	
	(cQry)->(DbCloseArea())

Return()
	

Method CalcFrete() Class TCalculoFreteVinilico
	
	::SetProperty()
	
	IF ::nPeso > 0 .And. ::nQuant > 0 .And. ::nFrtTon > 0
	
		::nFrtVen := (::nPeso * ::nFrtTon) / ::nQuant
		
	EndIf
	
Return(::nFrtVen)


Method CalcVlrProd() Class TCalculoFreteVinilico
	
	::CalcFrete()
	
	::nVlrProd := ::nVlrProd + ::nFrtVen
	
	::CalcFatSeg()
	
	::nVlrProd :=  (::nVlrProd  /  IIF(::nFatSeg > 0, ::nFatSeg, 1))	
	
Return(::nVlrProd)


Method CalcFatSeg() Class TCalculoFreteVinilico
	
	If (::nSeguro > 0)
		::nFatSeg :=  (1 - (::nSeguro /100))
	EndIf
	
Return(::nFatSeg)

Method CalcSeguro() Class TCalculoFreteVinilico
	
	::CalcVlrProd()
	
	::nVlrSeg :=  (::nVlrProd  * (::nSeguro /100))

Return(::nVlrSeg)
