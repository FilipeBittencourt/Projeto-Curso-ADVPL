#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA676
@author Marcos Alberto Soprani
@since 23/04/21
@version 1.0
@description Tela de Manutenção Aliquotas extraordinárias para cálculo de Rubricas - GMT
@Obs Projeto A-59
@type function
/*/

User Function BIA676()

	Local aArea := ZN7->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Aliquotas para Gestão Matricial de Tributos"
	Private msEnter   := CHR(13) + CHR(10)

	Private cTab	:= "ZN7"
	Private bOpcao3 := {|| fOpcoes(cTab,0,3)} 
	Private bOpcao4 := {|| fOpcoes(cTab,Recno(),4)} 
	Private bOpcao5 := {|| fOpcoes(cTab,Recno(),5)} 

	aRotina   := { {"Pesquisar"       ,"AxPesqui"	                        ,0,1},;
	{               "Visualizar"      ,"AxVisual"	                        ,0,2},;
	{               "Incluir"         ,"EVAL(bOpcao3)"				        ,0,3},;
	{               "Alterar"         ,"EVAL(bOpcao4)"					    ,0,4},;
	{               "Excluir"         ,"EVAL(bOpcao5)"					    ,0,5} }

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZN7")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	//oBrowse:SetFilterDefault( " informe o filtro aqui" )

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
		AxAltera(cAlias, nReg, nOpc, Nil, Nil, Nil, Nil, "EVAL(bTudoOK)")

		Case nOpc == 5 
		AxDeleta(cAlias, nReg, nOpc)

	EndCase

Return

Static Function fTuudoOK(cAlias, nReg, nOpc)

	Local lRet      := .T.

	If lRet
		lRet := bValPer(M->ZN7_CODPLA, M->ZN7_RUBVIS, M->ZN7_DTINI, M->ZN7_DTFIM, nReg)
	EndIf

Return ( lRet )

Static Function bValPer(xCodPla, msRubVis, xDtIni, xDtFim, xnReg)

	Local lRet := .T.

	cQry := GetNextAlias()

	cSql := " SELECT COUNT(*) CONTAD "
	cSql += " FROM " + RetSqlName("ZN7") + " ZN7(NOLOCK) "
	cSql += " WHERE ZN7_FILIAL = '" + xFilial("ZN7") + "' "
	cSql += "       AND ('" + dtos(xDtIni) + "' BETWEEN ZN7_DTINI AND ZN7_DTFIM "
	cSql += "            OR '" + dtos(xDtFim) + "' BETWEEN ZN7_DTINI AND ZN7_DTFIM) "
	cSql += "       AND ZN7_CODPLA = '" + xCodPla + "' "
	cSql += "       AND ZN7_RUBVIS = '" + msRubVis + "' "
	cSql += "       AND ZN7.R_E_C_N_O_ <> " + Alltrim(Str(xnReg)) + " "
	cSql += "       AND ZN7.D_E_L_E_T_ = ' ' "
	TcQuery cSQL New Alias (cQry)

	If !(cQry)->(Eof())

		If (cQry)->(CONTAD) > 0

			MsgStop("Já existe um registros na base de dados iguals ao que se pretende incluir. Utilize a opção Alterar!!!", "Atenção!!!" )
			lRet := .F.

		EndIf

	EndIf

	(cQry)->(DbCloseArea())

Return ( lRet )
