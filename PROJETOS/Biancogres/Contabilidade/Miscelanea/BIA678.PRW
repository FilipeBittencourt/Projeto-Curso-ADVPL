#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA678
@author Marcos Alberto Soprani
@since 09/04/21
@version 1.0
@description Tela de Manutenção para Gestão Matricial de Tributos
@Obs Projeto A-59
@type function
/*/

User Function BIA678()

	Local aArea := ZN6->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Gestão Matricial de Tributos"
	Private msEnter   := CHR(13) + CHR(10)

	Private cTab	:= "ZN6"
	Private bOpcao3 := {|| fOpcoes(cTab,0,3)} 
	Private bOpcao4 := {|| fOpcoes(cTab,Recno(),4)} 
	Private bOpcao5 := {|| fOpcoes(cTab,Recno(),5)} 

	aRotina   := { {"Pesquisar"       ,"AxPesqui"                          ,0,1},;
	{               "Visualizar"      ,"AxVisual"                          ,0,2},;
	{               "Incluir"         ,"EVAL(bOpcao3)"				       ,0,3},;
	{               "Alterar"         ,"EVAL(bOpcao4)"					   ,0,4},;
	{               "Excluir"         ,"EVAL(bOpcao5)"					   ,0,5},;
	{               "Extrair"         ,"U_BIA694()"                        ,0,3} }

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZN6")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	oBrowse:SetFilterDefault( "ZN6_TIPO1 = 'M'" )

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)

Return

Static function fOpcoes(cAlias, nReg, nOpc)

	Private cAliasX	:= cAlias
	Private nRegX	:= nReg
	Private nOpcX	:= nOpc
	Private bTudoOK := {|| fTuudoOK(cAliasX, nRegX, nOpcX)} 

	Do Case

		Case nOpc == 3
		AxInclui(cAlias, nReg, nOpc, Nil, Nil, Nil, "EVAL(bTudoOK)")

		Case nOpc == 4
		If bValPer((cAlias)->ZN6_CODPLA, (cAlias)->ZN6_RUBVIS, (cAlias)->ZN6_DATREF)
			AxAltera(cAlias, nReg, nOpc, Nil, Nil, Nil, Nil, "EVAL(bTudoOK)")
		EndIf	

		Case nOpc == 5 
		If bValPer((cAlias)->ZN6_CODPLA, (cAlias)->ZN6_RUBVIS, (cAlias)->ZN6_DATREF)
			AxDeleta(cAlias, nReg, nOpc)
		EndIf

	EndCase

Return

Static Function fTuudoOK(cAlias, nReg, nOpc)

	Local lRet      := .T.

	If lRet
		lRet := bValPer(M->ZN6_CODPLA, M->ZN6_RUBVIS, M->ZN6_DATREF)
	EndIf

Return ( lRet )

Static Function bValPer(xCodPla, msRubVis, xDtRef)

	Local lRet := .T.

	CVF->(dbSetOrder(1))
	CVF->(dbSeek(xFilial("CVF") + xCodPla + msRubVis))
	msVetImp := Substr(CVF->CVF_YRFDRE, 4, 2)

	cQry := GetNextAlias()

	cSql := " SELECT ZNA.ZNA_CODIMP, "
	cSql += "        ZNA.ZNA_DESIMP, "
	cSql += "        ZNA.ZNA_ULTGMT "
	cSql += " FROM " + RetSqlName("ZNA") + " ZNA(NOLOCK) "
	cSql += " WHERE ZNA.ZNA_FILIAL = '" + xFilial("ZNA") + "' "
	cSql += "       AND ZNA.ZNA_CODPLA = '" + xCodPla + "' "
	cSql += "       AND ZNA.ZNA_CODIMP IN(" + msVetImp + ") "
	cSql += "       AND ZNA.ZNA_ULTGMT > '" + dtos(xDtRef) + "' "
	cSql += "       AND ZNA.D_E_L_E_T_ = ' ' "
	TcQuery cSQL New Alias (cQry)

	If !(cQry)->(Eof())

		MsgStop("Não é permitida movimentação anterior a " + dtoc(stod((cQry)->(ZNA_ULTGMT))) + " para o imposto selecionado!!!", "Atenção!!!" )
		lRet := .F.

	EndIf

	(cQry)->(DbCloseArea())

Return ( lRet )
