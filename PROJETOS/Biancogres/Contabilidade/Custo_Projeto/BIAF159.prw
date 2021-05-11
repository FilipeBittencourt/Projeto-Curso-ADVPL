#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF159
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Ferramenta para controlar os custos dos projetos - Tabela de cadastro de Subitem de Projeto 
@obs Projeto: D-01 - Custos dos Projetos
@type Function
/*/

User Function BIAF159()
Private aRotina := {}
Private cCadastro := "Subitem Projeto"
Private cAlias := "ZMA"

	aAdd(aRotina, {"Pesquisar" , "PesqBrw", 0, 1})
	aAdd(aRotina, {"Visualizar", "U_BIAF159A", 0, 2})
	aAdd(aRotina, {"Incluir", "U_BIAF159A", 0, 3})
	aAdd(aRotina, {"Alterar", "U_BIAF159A", 0, 4})
	aAdd(aRotina, {"Excluir", "U_BIAF159A", 0, 5})
	aAdd(aRotina, {"Subitem Padrão", "U_BIAF159B", 0, 2})		
	                                               
	DbSelectArea(cAlias)
	DbSetOrder(1)

	mBrowse(,,,,cAlias)

Return()


User Function BIAF159A(cAlias, nRecno, nOpc)
Local oObj := TWSubitemProjeto():New()
		
	If nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5 

		oObj:cCodigo := ZMA->ZMA_CODIGO
		oObj:cClvl := ZMA->ZMA_CLVL
		oObj:cItemCta := ZMA->ZMA_ITEMCT
			
	EndIf
	
	oObj:nFDOpc := nOpc
	
	oObj:Activate()
		
Return()


User Function BIAF159B()
Local oParam := TParBIAF159():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Importando Subitens...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)

	Begin Transaction	
	
		fItem(oParam:cClvlOri, oParam:cClvlDes)
		
	End Transaction

Return()


Static Function fItem(cClvlOri, cClvlDes)
Local cCodRef := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ZMA_CODIGO, ZMA_CLVL, ZMA_ITEMCT "
	cSQL += " FROM "+ RetSQLName("ZMA")
	cSQL += " WHERE ZMA_FILIAL = "+ ValToSQL(xFilial("ZMA")) 
	cSQL += " AND ZMA_CLVL = " + ValToSQL(cClvlOri)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY ZMA_CODIGO "
	
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		cCodRef := U_NumZMA()
		
		RecLock("ZMA", .T.)
			
			ZMA->ZMA_FILIAL := xFilial("ZMA")
			ZMA->ZMA_CODIGO := cCodRef
			ZMA->ZMA_CLVL := cClvlDes
			ZMA->ZMA_ITEMCT := (cQry)->ZMA_ITEMCT
			
		ZMA->(MsUnLock())
	
		fSubitem((cQry)->ZMA_CODIGO, cCodRef)
		
		(cQry)->(DbSkip())
		
	EndDo()
				
	(cQry)->(DbCloseArea())
			
Return()


Static Function fSubitem(cCodigo, cCodRef)
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ZMB_SUBITE, ZMB_DESC "
	cSQL += " FROM "+ RetSQLName("ZMB")
	cSQL += " WHERE ZMB_FILIAL = "+ ValToSQL(xFilial("ZMB")) 
	cSQL += " AND ZMB_CODREF = " + ValToSQL(cCodigo)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY ZMB_SUBITE "
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())		
		
		RecLock("ZMB", .T.)
		
			ZMB->ZMB_FILIAL := xFilial("ZMB")
			ZMB->ZMB_CODREF := cCodRef
			ZMB->ZMB_SUBITE := (cQry)->ZMB_SUBITE
			ZMB->ZMB_DESC := (cQry)->ZMB_DESC
	
		ZMB->(MsUnLock())

		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())	
	
Return()


User Function NumZMA()
Local cRet := ""
Local cCodRef := ""
	
	cCodRef := GetSxEnum('ZMA', 'ZMA_CODIGO')
	
	ConfirmSx8()
	
	DbSelectArea("ZMA")
	ZMA->(dbSetOrder(1))
	While (DbSeek(xFilial("ZMA") + cCodRef))
		
		cCodRef := GetSxEnum('ZMA', 'ZMA_CODIGO')
	
		ConfirmSx8()
				
	EndDo	
			
	cRet := cCodRef
	
Return(cRet)