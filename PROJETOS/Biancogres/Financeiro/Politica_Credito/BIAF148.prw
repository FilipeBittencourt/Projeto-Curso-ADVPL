#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF148
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao para chamada da (Tela) Painel de Política de Crédito
@type class
/*/

User Function BIAF148()
Local aCores := {}
Private aRotina := {}
Private cCadastro := "Painel de Política de Crédito"
Private cAlias := "ZM0"

	aAdd(aCores, {"ZM0_STATUS == '1'", "BR_VERDE"})
	aAdd(aCores, {"ZM0_STATUS == '2'", "BR_AMARELO"})
	aAdd(aCores, {"ZM0_STATUS == '3'", "BR_VERMELHO"})
	aAdd(aCores, {"ZM0_STATUS == '4'", "BR_AZUL"})	

	aAdd(aRotina, {"Pesquisar" , "PesqBrw", 0, 1})
	aAdd(aRotina, {"Visualizar", "U_BIAF148A", 0, 2})
	aAdd(aRotina, {"Incluir", "U_BIAF148B", 0, 3})
	aAdd(aRotina, {"Atualizar", "U_BIAF148C", 0, 7})
	aAdd(aRotina, {"Legenda", "U_BIAF148D", 0, 7})	
	                                               
	DbSelectArea(cAlias)
	DbSetOrder(1)

	mBrowse(,,,,cAlias,,,,,,aCores)

Return()


User Function BIAF148A(cAlias, nRecno, nOpc)
Local oObj := Nil
	
	oObj := TWPainelPoliticaCredito():New()

	oObj:Activate()
	
	FreeObj(oObj)
													
Return()


User Function BIAF148B(cAlias, nRecno, nOpc)
Local aParam := {}

	aAdd(aParam,  {|| .T.})
	aAdd(aParam,  {|| fValidateInsert() })
	aAdd(aParam,  {|| .T.})
	aAdd(aParam,  {|| .T.})
					
	AxInclui(cAlias, nRecno, nOpc,,,,, .F.,,, aParam,,,.T.,,,,,)
														
Return()


Static Function fValidateInsert()
Local lRet := .T.
	
	If !U_BIAF149(M->ZM0_DATINI, M->ZM0_CLIENT, M->ZM0_LOJA, M->ZM0_GRUPO, M->ZM0_CNPJ, M->ZM0_ORIGEM, .F.)
	
		lRet := .F.
	
		MsgStop("Atenção, já existe uma solcititação de crédito em processamento para esse cliente ou grupo de clientes.")
	
	EndIf
	
Return(lRet)


User Function BIAF148C()
	
	U_BIAMsgRun("Atualizando status das solicitações de crédito...", "Aguarde!", {|| U_BIAF147A() })

Return()


User Function BIAF148D()
Local aLeg := {}

	aAdd(aLeg, {"BR_VERDE", "Em Aberto"})
	aAdd(aLeg, {"BR_AMARELO", "Em Análise"})	
	aAdd(aLeg, {"BR_VERMELHO", "Finalizado"})
	aAdd(aLeg, {"BR_AZUL", "Erro no Processamento"})	
	
	BrwLegenda(cCadastro, "Legenda", aLeg)

Return()