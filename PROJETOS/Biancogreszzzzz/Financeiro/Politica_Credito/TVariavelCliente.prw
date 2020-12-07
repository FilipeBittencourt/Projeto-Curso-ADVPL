#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TVariavelCliente
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Classe para tratamento das Variavies do Cliente utilizadas na Politica de Credito
@type class
/*/

Class TVariavelCliente From LongClassName
	
	Data cCodPro
	Data dData
	Data cCliente
	Data cLoja
	Data cGrpVen
	Data cCnpj
	Data nLimCreSol
	Data nVlrObr
	Data oLst
	
	Method New() Constructor
	Method Add()
	Method Get(lWebService)
	Method Exist()
	Method NextCode()

EndClass


Method New() Class TVariavelCliente

	::cCodPro := ""
	::dData := dDataBase
	::cCliente := Space(6)
	::cLoja := Space(2)
	::cGrpVen := Space(6)
	::cCnpj := Space(14)
	::nLimCreSol := 0
	::nVlrObr := 0
	
	::oLst := ArrayList():New()
	
Return()


Method Add(cOrigem) Class TVariavelCliente
Local cSQL := ""
Local cQry := GetNextAlias()
Local cCodigo := ::NextCode()

	Default cOrigem := 'B'

	cSQL := " EXEC SP_POL_CRE_VARIAVEL_CLIENTE " + ValToSQL(::dData) + "," + ValToSQL(::cCliente) + "," + ValToSQL(::cLoja) + "," + ValToSQL(::cGrpVen) + "," + ValToSQL(::cCnpj) + "," + ValToSQL(::nLimCreSol) + "," + ValToSQL(::nVlrObr)
	 			
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())
		
		RecLock("ZM1", .T.)
		
			ZM1->ZM1_FILIAL := xFilial("ZM2")
			ZM1->ZM1_CODPRO := ::cCodPro
			ZM1->ZM1_CODIGO := cCodigo
			ZM1->ZM1_DATA := sToD((cQry)->_Data)
			ZM1->ZM1_CLIENT := (cQry)->_Cliente
			ZM1->ZM1_LOJA := (cQry)->_Loja
			ZM1->ZM1_TIPO := (cQry)->_Tipo
			ZM1->ZM1_SEGMEN := (cQry)->_Segmento
			ZM1->ZM1_GRUPO := (cQry)->_GrpVen
			ZM1->ZM1_PORTE := Space(1)
			ZM1->ZM1_CNPJ := (cQry)->_Cnpj
			ZM1->ZM1_DTPRCO := sToD((cQry)->_DatPriCom)
			ZM1->ZM1_LCATU := (cQry)->_LimCreAtu
			ZM1->ZM1_LCSOL := (cQry)->_LimCreSol
			ZM1->ZM1_VLROBR := (cQry)->_VlrObr
			ZM1->ZM1_QTVA07 := (cQry)->_Qtd_07
			ZM1->ZM1_VLVA08 := (cQry)->_Vlr_08
			ZM1->ZM1_QTVA09 := (cQry)->_Qtd_09
			ZM1->ZM1_VLVA10 := (cQry)->_Vlr_10
			ZM1->ZM1_QTVA11 := (cQry)->_Qtd_11
			ZM1->ZM1_VLVA12 := (cQry)->_Vlr_12
			ZM1->ZM1_QTVA13 := (cQry)->_Qtd_13
			ZM1->ZM1_VLVA14 := (cQry)->_Vlr_14
			ZM1->ZM1_QTVA15 := (cQry)->_Qtd_15
			ZM1->ZM1_VLVA16 := (cQry)->_Vlr_16
			ZM1->ZM1_QTVA17 := (cQry)->_Qtd_17
			ZM1->ZM1_VLVA18 := (cQry)->_Vlr_18
			ZM1->ZM1_VLVA19 := (cQry)->_Vlr_19
			ZM1->ZM1_QTVA20 := (cQry)->_Qtd_20
			ZM1->ZM1_VLVA21 := (cQry)->_Vlr_21
			ZM1->ZM1_QTVA22 := (cQry)->_Qtd_22
			ZM1->ZM1_VLVA23 := (cQry)->_Vlr_23
			ZM1->ZM1_VARC01 := (cQry)->_VlrC_01
			ZM1->ZM1_VARC02 := (cQry)->_VlrC_02
			ZM1->ZM1_VARC03 := (cQry)->_VlrC_03
			ZM1->ZM1_VARC04 := (cQry)->_VlrC_04
			ZM1->ZM1_VARC05 := (cQry)->_VlrC_05
			ZM1->ZM1_VARC06 := (cQry)->_VlrC_06
			ZM1->ZM1_VARC07 := (cQry)->_VlrC_07
			ZM1->ZM1_VARC08 := (cQry)->_VlrC_08
			ZM1->ZM1_VARC09 := (cQry)->_VlrC_09
			ZM1->ZM1_VARC10 := (cQry)->_VlrC_10
			ZM1->ZM1_VARC11 := (cQry)->_VlrC_11
			
			// Origem Rocket
			If cOrigem == 'R'
				
				ZM1->ZM1_TIPINT := '3'
			
			Else
				
				ZM1->ZM1_TIPINT := If (::cCliente == (cQry)->_Cliente .And. ::cLoja == (cQry)->_Loja, "1", "2")
				
			EndIf
					
		ZM1->(MsUnLock())
				
		(cQry)->(DbSkip())
								
	EndDo()
		
	(cQry)->(DbCloseArea())

Return()


Method Get(lWebService, cOrigem) Class TVariavelCliente
Local cSQL := ""
Local cQry := GetNextAlias()
Local oObj := Nil

	Default lWebService := .F.
	Default cOrigem	:= 'B'

	::oLst:Clear()

	cSQL := " SELECT * "
	cSQL += " FROM "+ RetSQLName("ZM1")
	cSQL += " WHERE ZM1_FILIAL = "+ ValToSQL(xFilial("ZM1"))
	cSQL += " AND ZM1_CODPRO = "+ ValToSQL(::cCodPro)
	
	If cOrigem == 'R'
		
		cSQL += " AND ZM1_TIPINT = '3' "
		
	Else
		
		cSQL += " AND ZM1_TIPINT = " + ValToSQL(If (lWebService, '2', '1'))
		
	EndIf
	
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())
	
		oObj := TIVariavelCliente():New()

		oObj:cCodPro := (cQry)->ZM1_CODPRO
		oObj:cCodigo := (cQry)->ZM1_CODIGO
		oObj:dData := sToD((cQry)->ZM1_DATA)
		oObj:cCliente := (cQry)->ZM1_CLIENT
		oObj:cLoja := (cQry)->ZM1_LOJA
		oObj:cTipo := (cQry)->ZM1_TIPO
		oObj:cSegmento := (cQry)->ZM1_SEGMEN
		oObj:cGrpVen := (cQry)->ZM1_GRUPO
		oObj:nOriGrp := 0
		oObj:cPorte := (cQry)->ZM1_PORTE
		oObj:cCnpj := (cQry)->ZM1_CNPJ
		oObj:dDatPriCom := sToD((cQry)->ZM1_DTPRCO)
		oObj:nLimCreAtu := (cQry)->ZM1_LCATU
		oObj:nLimCreSol := (cQry)->ZM1_LCSOL
		oObj:nVlrObr := (cQry)->ZM1_VLROBR
		oObj:nQtd_07 := (cQry)->ZM1_QTVA07
		oObj:nVlr_08 := (cQry)->ZM1_VLVA08
		oObj:nQtd_09 := (cQry)->ZM1_QTVA09
		oObj:nVlr_10 := (cQry)->ZM1_VLVA10
		oObj:nQtd_11 := (cQry)->ZM1_QTVA11
		oObj:nVlr_12 := (cQry)->ZM1_VLVA12
		oObj:nQtd_13 := (cQry)->ZM1_QTVA13
		oObj:nVlr_14 := (cQry)->ZM1_VLVA14
		oObj:nQtd_15 := (cQry)->ZM1_QTVA15
		oObj:nVlr_16 := (cQry)->ZM1_VLVA16
		oObj:nQtd_17 := (cQry)->ZM1_QTVA17
		oObj:nVlr_18 := (cQry)->ZM1_VLVA18
		oObj:nVlr_19 := (cQry)->ZM1_VLVA19
		oObj:nQtd_20 := (cQry)->ZM1_QTVA20
		oObj:nVlr_21 := (cQry)->ZM1_VLVA21
		oObj:nQtd_22 := (cQry)->ZM1_QTVA22
		oObj:nVlr_23 := (cQry)->ZM1_VLVA23
		oObj:nVlrC_01 := (cQry)->ZM1_VARC01
		oObj:nVlrC_02 := (cQry)->ZM1_VARC02
		oObj:nVlrC_03 := (cQry)->ZM1_VARC03
		oObj:nVlrC_04 := (cQry)->ZM1_VARC04
		oObj:nVlrC_05 := (cQry)->ZM1_VARC05
		oObj:nVlrC_06 := (cQry)->ZM1_VARC06
		oObj:nVlrC_07 := (cQry)->ZM1_VARC07
		oObj:nVlrC_08 := (cQry)->ZM1_VARC08
		oObj:nVlrC_09 := (cQry)->ZM1_VARC09
		oObj:nVlrC_10 := (cQry)->ZM1_VARC10
		oObj:nVlrC_11 := (cQry)->ZM1_VARC11
		
		::oLst:Add(oObj)

		(cQry)->(DbSkip())
								
	EndDo()

	(cQry)->(DbCloseArea())

Return(::oLst)


Method Exist() Class TVariavelCliente
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(ZM1_CODPRO) AS COUNT "
	cSQL += " FROM "+ RetSQLName("ZM1")
	cSQL += " WHERE ZM1_FILIAL = "+ ValToSQL(xFilial("ZM1"))
	cSQL += " AND ZM1_CODPRO = "+ ValToSQL(::cCodPro)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	lRet := (cQry)->COUNT > 0

	(cQry)->(DbCloseArea())

Return(lRet)


Method NextCode() Class TVariavelCliente
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(MAX(ZM1_CODIGO), '') AS ZM1_CODIGO "
	cSQL += " FROM "+ RetSQLName("ZM1")
	cSQL += " WHERE ZM1_FILIAL = "+ ValToSQL(xFilial("ZM1"))
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	cRet := Soma1((cQry)->ZM1_CODIGO)

	(cQry)->(DbCloseArea())

Return(cRet)
