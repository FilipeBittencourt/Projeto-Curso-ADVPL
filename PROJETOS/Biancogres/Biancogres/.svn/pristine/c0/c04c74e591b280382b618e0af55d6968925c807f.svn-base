#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT241EXT
@author Gabriel Rossi Mafioletti
@since 10/08/2020
@version 1.0
@description Tela principal do projeto MRP
@type function
/*/

User Function MT241EXT()

	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()

	Local _cDoc	:=	SD3->D3_DOC

	BeginSql Alias _cAlias

		SELECT COUNT(*) QTD
		FROM %TABLE:SD3% SD3(NOLOCK)
		JOIN %TABLE:SZI% SZI(NOLOCK) ON SD3.D3_FILIAL = SZI.ZI_FILIAL
			AND SD3.D3_DOC = SZI.ZI_DOC
			AND SD3.D3_YMATRIC = SZI.ZI_MATRIC
			AND SD3.D3_LOCAL = SZI.ZI_YLOCAL
		WHERE D3_FILIAL = %XFILIAL:SD3%
			AND D3_DOC = %Exp:_cDoc%
			AND D3_LOCAL <> '07'
			AND ((SD3.D3_EMISSAO >= '20200811' AND D3_YOBS LIKE 'BX PREREQ%') OR (SD3.D3_EMISSAO < '20200811'))
			AND D3_CF NOT IN ('DE4','RE4')			
			AND SD3.%NotDel%
			AND SZI.%NotDel%
	
	EndSql

	If (_cAlias)->QTD > 0
		MsgSTOP("Impossível prosseguir, pois este movimento provém de uma pré-requisição!!!","MT241EXT")
		(_cAlias)->(DbCloseArea())
		RestArea(_aArea)
		Return .F.
	EndIf

Return .T.