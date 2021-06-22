#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAV012
@author Marcus Vinicius Siqueira Nascimento
@since 22/06/2021
@version 1.0
@description Carga BI manual para Custos de Projeto. Key User: Amélia
@obs Projeto: D-07 - Custos dos Projetos
@type Function
/*/

User Function BIAV012()
Local aRet      := {}
	Local lParam    := .T.
	Local aOpSX3    := {}
	Local oJSTela   := JsonObject():New()
	Local aParamBox := {}

	Private cDash     := ""

	//Opções
	AADD(aOpSX3,"Mês atual") 
	AADD(aOpSX3,"Mês Anterior")    

	aAdd(aParamBox,{3,"Cargas de dados - Custos de Projeto",1,aOpSX3,50,"",.F.})

	while lParam == .T.

		If ParamBox(aParamBox,"Escolha a carga de dados que deseja executar",@aRet)


			oJSTela["NomeOpcao"]  := aParamBox[1,4,aRet[1]]
			oJSTela["CodigoSX3"]  := PadL(AllTrim(cValToChar(aRet[1])) , 2 , "0")

			IF aRet[1]  == 1
				U_EXEJBSQL("HERMES", "DW -> DDO Custos Proj Mes atual", "Sincronizando Dados com BI")
			ELSEIF aRet[1] == 2
				U_EXEJBSQL("HERMES", "DW -> DDO Custos Proj Mes passado", "Sincronizando Dados com BI")
			ENDIF

		Else

			lParam := .F.

		Endif

	endDo
	
Return()
