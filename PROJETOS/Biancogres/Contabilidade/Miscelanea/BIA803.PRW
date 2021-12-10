#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA803
@author Marcos Alberto Soprani
@since 18/11/21
@version 1.0
@description Tela de Manutenção Aliquotas p/ FAROL GMT
@Obs Projeto A-59
@type function
/*/

User Function BIA803()

	Local aArea := ZND->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Aliquotas p/ FAROL GMT"
	Private msEnter   := CHR(13) + CHR(10)

	Private cTab	:= "ZND"
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
	oBrowse:SetAlias("ZND")

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
		lRet := bValPer(M->ZND_DATINI, M->ZND_DATFIN, nReg)
	EndIf

Return ( lRet )

Static Function bValPer(xDatIni, xDATFIN, xnReg)

	Local lRet := .T.

	cQry := GetNextAlias()

	cSql := " SELECT COUNT(*) CONTAD "
	cSql += " FROM " + RetSqlName("ZND") + " ZND(NOLOCK) "
	cSql += " WHERE ZND_FILIAL = '" + xFilial("ZND") + "' "
	cSql += "       AND ('" + dtos(xDatIni) + "' BETWEEN ZND_DATINI AND ZND_DATFIN "
	cSql += "            OR '" + dtos(xDATFIN) + "' BETWEEN ZND_DATINI AND ZND_DATFIN) "
	cSql += "       AND ZND.R_E_C_N_O_ <> " + Alltrim(Str(xnReg)) + " "
	cSql += "       AND ZND.D_E_L_E_T_ = ' ' "
	TcQuery cSQL New Alias (cQry)

	If !(cQry)->(Eof())

		If (cQry)->(CONTAD) > 0

			MsgStop("Já existe um registros na base de dados iguals ao que se pretende incluir. Utilize a opção Alterar!!!", "Atenção!!!" )
			lRet := .F.

		EndIf

	EndIf

	(cQry)->(DbCloseArea())

Return ( lRet )
