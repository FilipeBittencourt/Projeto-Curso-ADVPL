#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA864
@author Ranisses A. Corona
@since 16/06/2014
@version 1.0
@description Cadastros Gerais to Business Intelligence	
@type function
/*/

User Function BIA864()

	Local oDlg
	Local oRadio
	Local nRadio
	Local nOpca := 1

	While nOpca == 1

		DEFINE MSDIALOG oDlg FROM  94,1 TO 650,293 TITLE "Cadastros Gerais to BI" PIXEL

		@ 05,17 Say "Cadastros Gerais to Business Intelligence:" SIZE 150,7 OF oDlg PIXEL

		@ 17,07 TO 250, 140 OF oDlg  PIXEL

		@ 25,10 Radio 	oRadio VAR nRadio;
		ITEMS 	"Empresa",;
		"Unidade Negócio",;
		"Marca",;
		"Tipo Segmento Cliente",;
		"Pacote Orçamento/GMCD 1.0",;
		"Classe Valor Gerencial",;
		"Parametros BI",;
		"Prazo Medio Fat. Contratado",;
		"Entidades p/ GMCD 2.0",;
		"Pacote p/ GMCD 2.0",;
		"Sub-Pacote p/ GMCD 2.0",;
		"Item Custo p/ RAC",;
		"Setor p/ GMCD 2.0",;
		"Linha de Fabricação",;
		"Critério Rateio CtaContábil",;
		"Critério Rateio CLVL",;
		"Base-Tipologia",;
		"Acabamento",;
		"Espessura",;
		"Tipo Versão Contábil",;
		"Versão Contábil";			
		SIZE 150,10 OF oDlg PIXEL

		DEFINE SBUTTON FROM 255,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
		DEFINE SBUTTON FROM 255,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)

		If nOpca == 1

			If nRadio == 1
				BIA864_1()					// Empresa

			ElseIf nRadio == 2
				BIA864_2()					// Unid. Negócio

			ElseIf nRadio == 3
				BIA864_3()					// Marca

			ElseIf nRadio == 4
				BIA864_4()					// Tipo Segmento Cliente

			ElseIf nRadio == 5
				BIA864_5()					// Pacote Orçamento/GMCD

			ElseIf nRadio == 6
				BIA864_6()					// Classe Valor Gerencial

			ElseIf nRadio == 7
				BIA864_7()					// Parametros BI

			ElseIf nRadio == 8
				BIA864_8()					// Prazao Medio Fat. Contratado

			ElseIf nRadio == 9
				BIA864_9()					// Entidades

			ElseIf nRadio == 10
				BIA864_10()					// Pacote p/ GMCD 2.0

			ElseIf nRadio == 11
				BIA864_11()					// Sub-Pacote p/ GMCD 2.0

			ElseIf nRadio == 12
				BIA864_12()					// Item Custo p/ RAC

			ElseIf nRadio == 13
				BIA864_13()					// Setor p/ GMCD 2.0

			ElseIf nRadio == 14
				BIA864_14()					// Linha de Fabricação

			ElseIf nRadio == 15
				BIA864_15()					// Critério Rateio CtaContábil

			ElseIf nRadio == 16
				BIA864_16()					// Critério Rateio CLVL

			ElseIf nRadio == 17
				BIA864_17()					// Base-Tipologia

			ElseIf nRadio == 18
				BIA864_18()					// Acabamento

			ElseIf nRadio == 19
				BIA864_19()					// Espessura

			ElseIf nRadio == 20
				BIA864_20()					// Tipo Versão Contábil

			ElseIf nRadio == 21
				BIA864_21()					// Versão Contábil

			EndIf

		EndIf

	EndDo

Return

//Cadastro de Empresa
Static FUNCTION BIA864_1()

	AXCADASTRO("Z35","Cadastro de Empresa")

Return

//Cadastro de Unidade de Negocio
Static FUNCTION BIA864_2()

	AXCADASTRO("Z36","Cadastro de Unidade Negócio")

Return

//Cadastro de Marca
Static FUNCTION BIA864_3()

	AXCADASTRO("Z37","Cadastro de Marca")

Return

//Cadastro de Tipo Segmento Cliente
Static FUNCTION BIA864_4()

	AXCADASTRO("Z41","Tipo Segmento Cliente")

Return

//Cadastro de Pacote do Orçamento/GMCD
Static FUNCTION BIA864_5()

	AXCADASTRO("Z38","Pacote Orçamento/GMCD")

Return

//Cadastro de Classe de Valor Gerencial
Static FUNCTION BIA864_6()

	AXCADASTRO("Z39","Classe de Valor Gerencial")

Return

//Cadastro de Parametros BI
Static FUNCTION BIA864_7()
	Local cVldAlt := "u_B864_7ALT()"

	dbSelectArea("Z40")
	dbSetOrder(1)

	AxCadastro("Z40", "Parametros BI", , cVldAlt)

Return

//Prazo Médio Fat. Contratado
Static Function BIA864_8()

	AXCADASTRO("Z77","Prazo Médio Fat. Contratado")

Return

//Entidades /p GMCD 2.0
Static Function BIA864_9()

	AXCADASTRO("ZCA","Entidades")

Return

//Pacote p/ GMCD 2.0
Static Function BIA864_10()

	AXCADASTRO("ZC8","Pacote p/ GMCD 2.0")

Return

//Sub-Pacote p/ GMCD 2.0
Static Function BIA864_11()

	AXCADASTRO("ZC9","Sub-Pacote p/ GMCD 2.0")

Return

//Item Custo p/ RAC
Static Function BIA864_12()

	AXCADASTRO("Z29","Item Custo p/ RAC")

Return

//Setor p/ GMCD 2.0
Static Function BIA864_13()

	AXCADASTRO("ZCB","Setor p/ GMCD 2.0")

Return

//Linha de Fabricação
Static Function BIA864_14()

	AXCADASTRO("ZCO","Linha de Fabricação")

Return

//Critério Rateio CtaContábil
Static Function BIA864_15()

	AXCADASTRO("ZF1","Critério Rateio CtaContábil")

Return

//Critério Rateio CLVL
Static Function BIA864_16()

	AXCADASTRO("ZF2","Critério Rateio CLVL")

Return

//Base-Tipologia
Static Function BIA864_17()

	AXCADASTRO("Z32","Base-Tipologia")

Return

//Base-Tipologia
Static Function BIA864_18()

	AXCADASTRO("Z33","Acabamento")

Return

Static Function BIA864_19()

	AXCADASTRO("Z34","Espessura")

Return

Static Function BIA864_20()

	AXCADASTRO("ZOX","Tipo Versão Contábil")

Return

Static Function BIA864_21()

	AXCADASTRO("ZOY","Versão Contábil")

Return

//Função para validar Inclusão/Alteração de registro na Tabela de Parametros - Z40
User Function B864_7ALT()

	Local lRet	:= .T.
	Local cSql	:= ""
	Local aArea	:= GetArea()	

	cSql := "SELECT COUNT(*) QUANT "
	cSql += "FROM "+RetSqlName("Z40")+" "
	cSql += "WHERE	Z40_FILIAL =  '"+xFilial("Z40")+"' AND " 
	cSql += "	(	"
	cSql += "	(Z40_DATDE  <= '"+Dtos(M->Z40_DATDE)+"' AND Z40_DATATE >= '"+Dtos(M->Z40_DATDE)+"') OR "
	cSql += "	(Z40_DATDE  <= '"+Dtos(M->Z40_DATATE)+"' AND Z40_DATATE >= '"+Dtos(M->Z40_DATATE)+"')  " 
	cSql += "	)	AND "
	cSql += "		Z40_MARCA  =  '"+M->Z40_MARCA+"'AND " 
	cSql += "		Z40_TIPO   =  '"+M->Z40_TIPO+"' AND "
	If Altera
		cSql += "		R_E_C_N_O_ <> '"+Alltrim(Str(Z40->(RECNO())))+"' AND "
	EndIf
	cSql += "		D_E_L_E_T_ =  '' "
	If chkfile("R01")
		DbSelectArea("R01")
		DbCloseArea()
	EndIf
	TcQuery cSql New Alias "R01"

	If R01->QUANT > 0
		lRet := .F.
		MsgStop("Atenção, já existe percentual cadastrado para os dados informados. Será necessário rever as informações antes de continuar.")
	EndIf

	//Fecha arquivo de trabalho
	R01->(DbCloseArea())

	RestArea(aArea)

Return(lRet)
