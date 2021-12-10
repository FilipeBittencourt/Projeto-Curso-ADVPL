#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAtualizaEmbalagem
@author Tiago Rossini Coradini
@since 18/11/2021
@version 1.0
@description Classe com Regras de Negocio para Atualizaçao dos Processos Embalagem
@obs Projeto: A-53 - Melhoria Processo Embalagem
@type Class
/*/

Class TAtualizaEmbalagem From LongClassName

	Data cProdA
	Data cProdN
	Data cEmp
	
	Method New() Constructor
	Method Update()
	Method UpdPrdN()
	
EndClass


Method New() Class TAtualizaEmbalagem
		
	::cProdA := ""
	::cProdN := ""
	::cEmp := cEmpAnt
	
Return()


Method Update() Class TAtualizaEmbalagem
Local cSQL := ""
Local cQry := GetNextAlias()
Local cTabEmp := ::cEmp + '0'
Local lInsert := .F.
		
	// Habilita produto novo
	cSQL := " UPDATE SB1010 "
	cSQL += " SET B1_YBLSCPC = '2' "
	cSQL += " WHERE B1_FILIAL = '' "
	cSQL += " AND B1_COD = " + ValToSQL(::cProdN)
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcSQLExec(cSQL)
	
	// Habilita indicador do produto novo
	cSQL := " UPDATE SBZ" + cTabEmp
	cSQL += " SET BZ_YBLSCPC = '2' "
	cSQL += " WHERE BZ_FILIAL = '' "
	cSQL += " AND BZ_COD = " + ValToSQL(::cProdN)
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcSQLExec(cSQL)
	
	// Tratamento de estoque de segurança (ZCN_ESTSEG) e lote economico (ZCN_LE)
	cSQL := " SELECT * "
	cSQL += " FROM ZCN" + cTabEmp
	cSQL += " WHERE ZCN_COD = " + ValToSQL(::cProdA)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		// Atualiza produto novo
		DbSelectArea("ZCN")
		ZCN->(DbSetOrder(1))
		If !ZCN->(DbSeek(xFilial("ZCN") + ::cProdN + (cQry)->ZCN_SEQUEN))
		
			lInsert := .T.
					
		EndIf
		
		Reclock("ZCN", lInsert)

			If lInsert

				ZCN->ZCN_FILIAL := xFilial("ZCN")
				ZCN->ZCN_COD :=	::cProdN
				ZCN->ZCN_SEQUEN := (cQry)->ZCN_SEQUEN
			
			EndIf
					
			ZCN->ZCN_LOCAL :=	(cQry)->ZCN_LOCAL
			ZCN->ZCN_ESTSEG	:= (cQry)->ZCN_ESTSEG
			ZCN->ZCN_PONPED	:= (cQry)->ZCN_PONPED
			ZCN->ZCN_LE	:= (cQry)->ZCN_LE
			ZCN->ZCN_LOCALI	:= (cQry)->ZCN_LOCALI
			ZCN->ZCN_PORTAR := (cQry)->ZCN_PORTAR
			ZCN->ZCN_POLIT := (cQry)->ZCN_POLIT
			ZCN->ZCN_MD := (cQry)->ZCN_MD
			ZCN->ZCN_COMUM := (cQry)->ZCN_COMUM
			ZCN->ZCN_OBSOLE := (cQry)->ZCN_OBSOLE
			ZCN->ZCN_SOLIC := (cQry)->ZCN_SOLIC
			ZCN->ZCN_ATIVO := "S"
			ZCN->ZCN_BLSCPC := "2"
			ZCN->ZCN_PE := (cQry)->ZCN_PE
			ZCN->ZCN_RELEV := (cQry)->ZCN_RELEV
			ZCN->ZCN_P8PE := (cQry)->ZCN_P8PE
			ZCN->ZCN_P8ESEG := (cQry)->ZCN_P8ESEG
			ZCN->ZCN_P8PPED := (cQry)->ZCN_P8PPED
			ZCN->ZCN_TAG := (cQry)->ZCN_TAG
			ZCN->ZCN_CLASSI := (cQry)->ZCN_CLASSI
			ZCN->ZCN_TPANL := (cQry)->ZCN_TPANL
			ZCN->ZCN_CERTIF := (cQry)->ZCN_CERTIF
		
		ZCN->(MsUnlock())
			
		// Atualiza produto antigo
		cSQL := " UPDATE ZCN" + cTabEmp
		cSQL += " SET ZCN_ESTSEG = 0, ZCN_LE = 0, ZCN_PONPED = 0, ZCN_BLSCPC = '1' "
		cSQL += " WHERE ZCN_COD = " + ValToSQL(::cProdA) 
		cSQL += " AND ZCN_SEQUEN = " + ValToSQL((cQry)->ZCN_SEQUEN)
		cSQL += " AND D_E_L_E_T_ = '' "
		
		TcSQLExec(cSQL)
		
		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return()