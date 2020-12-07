#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TVariavelCliente
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Classe de Interface para tratamento das Variavies do Cliente utilizadas na Politica de Credito
@type class
/*/

Class TIVariavelCliente From LongClassName

	Data cCodPro
	Data cCodigo
	Data dData
	Data cCliente
	Data cLoja
	Data cTipo
	Data cSegmento
	Data cGrpVen
	Data nOriGrp
	Data cPorte
	Data cCnpj
	Data dDatPriCom
	Data nLimCreAtu
	Data nLimCreSol
	Data nVlrObr
	Data nQtd_07
	Data nVlr_08
	Data nQtd_09
	Data nVlr_10
	Data nQtd_11
	Data nVlr_12
	Data nQtd_13
	Data nVlr_14
	Data nQtd_15
	Data nVlr_16
	Data nQtd_17
	Data nVlr_18
	Data nVlr_19
	Data nQtd_20
	Data nVlr_21
	Data nQtd_22
	Data nVlr_23
	Data nVlrC_01
	Data nVlrC_02
	Data nVlrC_03
	Data nVlrC_04
	Data nVlrC_05
	Data nVlrC_06
	Data nVlrC_07
	Data nVlrC_08
	Data nVlrC_09
	Data nVlrC_10
	Data nVlrC_11
	
	Method New() Constructor

EndClass


Method New() Class TIVariavelCliente
	
	::cCodPro := ""
	::cCodigo := ""
	::dData := dDataBase
	::cCliente := ""
	::cLoja := ""
	::cTipo := ""
	::cSegmento := ""
	::cGrpVen := ""
	::nOriGrp := 0
	::cPorte := ""
	::cCnpj := ""
	::dDatPriCom := dDataBase
	::nLimCreAtu := 0
	::nLimCreSol := 0
	::nVlrObr := 0	
	::nQtd_07 := 0
	::nVlr_08 := 0
	::nQtd_09 := 0
	::nVlr_10 := 0
	::nQtd_11 := 0
	::nVlr_12 := 0
	::nQtd_13 := 0
	::nVlr_14 := 0
	::nQtd_15 := 0
	::nVlr_16 := 0
	::nQtd_17 := 0
	::nVlr_18 := 0
	::nVlr_19 := 0
	::nQtd_20 := 0
	::nVlr_21 := 0
	::nQtd_22 := 0
	::nVlr_23 := 0
	::nVlrC_01 := 0
	::nVlrC_02 := 0
	::nVlrC_03 := 0
	::nVlrC_04 := 0
	::nVlrC_05 := 0
	::nVlrC_06 := 0
	::nVlrC_07 := 0
	::nVlrC_08 := 0
	::nVlrC_09 := 0
	::nVlrC_10 := 0
	::nVlrC_11 := 0
	
Return()