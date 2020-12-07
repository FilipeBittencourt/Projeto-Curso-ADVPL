#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} PDMLOEST
@description Importar Estrutura de Grupos do PDM de arquivo Excel
@author Fernando Rocha
@since 03/08/2018
@version 1.0
@type function
/*/
User Function PDMLOEST()

	Local oPDM := TPDMEstrutura():New()

	oPDM:ImpEstGrupos()

	oPDM := Nil

Return

/*/{Protheus.doc} PDMLOPDM
@description Importar Estrutura do PDM de arquivo Excel
@author Fernando Rocha
@since 06/08/2018
@version 1.0
@type function
/*/
User Function PDMLOPDM()

	Local oPDM := TPDMEstrutura():New()

	oPDM:ImpEstPDM()

	oPDM := Nil

Return

/*/{Protheus.doc} PDMLOPDM
@description Importar PRODUTOS de arquivo Excel
@author Fernando Rocha
@since 21/08/2018
@version 1.0
@type function
/*/
User Function PDMLOPRO()

	Local oPDM := TPDMEstrutura():New()

	oPDM:ImpProdutos()

	oPDM := Nil

Return

/*/{Protheus.doc} PDMGINI
@description Inicializador para campos
@author Fernando Rocha
@since 06/08/2018
@version 1.0
@type function
/*/
User Function PDMGINI(nOpc)

	Local cReturn := ""

	If !ZD0->(Eof())

		If nOpc == 1

			cReturn := POSICIONE("ZD3",1,XFILIAL("ZD3")+ZD0->ZD0_GRUPO,"ZD3_DESCR")

		ElseIf nOpc == 2

			cReturn := POSICIONE("ZD4",1,XFILIAL("ZD4")+ZD0->ZD0_GRUPO+ZD0->ZD0_SUBGRU,"ZD4_DESCR")    

		ElseIf nOpc == 3	

			cReturn := POSICIONE("ZD5",1,XFILIAL("ZD5")+ZD0->ZD0_GRUPO+ZD0->ZD0_SUBGRU+ZD0->ZD0_FAMILI,"ZD5_DESCR")

		EndIf
	EndIf

Return(cReturn)

/*/{Protheus.doc} PDMF3EST
@description Consulta F3 para a estrutura de Grupo
@author Fernando Rocha
@since 08/08/2018
@version 1.0
@type function
/*/
User Function PDMF3EST(nOpc)

	Local oTela

	If Type("__oTELA_PDM") <> "U"

		__oTELA_PDM:F3Estrut()

	ElseIf Type("__oW_CREATEPDM") <> "U"

		__oW_CREATEPDM:F3Estrut()

	EndIf

Return .T.


/*/{Protheus.doc} PDMTCPRD
@description Tela para parametros do PDM na inclusao de produto
@author Fernando Rocha
@since 13/08/2018
@version 1.0
@type function
/*/
User Function PDMTCPRD()

	__oW_CREATEPDM := TPDMCreateProduto():New()

	__oW_CREATEPDM:Show()

	Public _ObjCrePd_ := __oW_CREATEPDM

Return


/*/{Protheus.doc} PDMTPMAR
@description Tela para o cadastro de relacao de Marcas X Produtos
@author Fernando Rocha
@since 27/08/2018
@version 1.0
@type function
/*/
User Function PDMTPMAR(lAltera)

	__oW_MARCAS := TPDMWProdMarca():New()
	__oW_MARCAS:OpAltera := lAltera

	__oW_MARCAS:Show()

Return()


/*/{Protheus.doc} PDMPROD
@description Tela para visualizacao PDM x  Produtos
@author Wlysses Cerqueira (Facile)
@since 21/11/2018
@version 1.0
@type function
/*/
User Function PDMPROD()

	Local oObjPdmPrd := TPDMWPdmProduto():New()

	oObjPdmPrd:Show()

Return()


User Function PDMGRUPO()

	AxCadastro("ZD3", "Cadastro de Grupos PDM")

Return

User Function PDMSUBGR()

	AxCadastro("ZD4", "Cadastro de Subgrupos PDM")

Return

User Function PDMGETSG()

	Local cQTmp
	Local cNext := "0001"
	Local aArea := GetArea()

	cQTmp := GetNextAlias()
	BeginSql Alias cQTmp

		select MSUB = isnull(max(ZD4_SUBGRU),'0000') from %Table:ZD4% where ZD4_FILIAL = '  ' and ZD4_GRUPO = %Exp:M->ZD4_GRUPO%

	EndSql	

	If !(cQTmp)->(Eof())

		cNext := Soma1((cQTmp)->MSUB,4)

	EndIf
	(cQTmp)->(DbCloseArea())
	
	RestArea(aArea)

Return(cNext)

User Function PDMFAMIL()

	AxCadastro("ZD5", "Cadastro de Familias PDM")

Return

User Function PDMGETFA()

	Local cQTmp
	Local cNext := "0001"
	Local aArea := GetArea()

	cQTmp := GetNextAlias()
	BeginSql Alias cQTmp

		select MFAM = isnull(max(ZD5_FAMILI),'0000') from %Table:ZD5% where ZD5_FILIAL = '  ' and ZD5_GRUPO = %Exp:M->ZD5_GRUPO% and ZD5_SUBGRU = %Exp:M->ZD5_SUBGRU%

	EndSql	

	If !(cQTmp)->(Eof())

		cNext := Soma1((cQTmp)->MFAM,4)

	EndIf
	(cQTmp)->(DbCloseArea())
	
	RestArea(aArea)

Return(cNext)

User Function PDMMARCA()

	AxCadastro("ZD8", "Cadastro de Marcas PDM")

Return