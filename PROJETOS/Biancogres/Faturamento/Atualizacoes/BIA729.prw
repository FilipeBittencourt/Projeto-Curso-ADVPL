//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} BIA729
@description Tela para cadastro da tabela ZDL, Metas logistica
@author  Filipe - Facile
@since 07/06/2021
@version 1.0
@type function
/*/


User Function BIA729()

	Local aRet      := {}
	Local lParam    := .T.
	Local aOpSX3    := {}
	Local oJSTela   := JsonObject():New()
	Local aParamBox := {}

	Private cDash     := ""

	//MANTER A ORDEM
	AADD(aOpSX3,"Logistica") //01 - Logistica
	AADD(aOpSX3,"Vendas")    //02 - Vendas

	aAdd(aParamBox,{3,"TipoS de cadastro",1,aOpSX3,50,"",.F.})

	while lParam == .T.

		If ParamBox(aParamBox,"Escolha o tipo de Meta que deseja acessar",@aRet)


			oJSTela["NomeOpcao"]  := aParamBox[1,4,aRet[1]]
			oJSTela["CodigoSX3"]  := PadL(AllTrim(cValToChar(aRet[1])) , 2 , "0")

			IF aRet[1]  == 1
				cDash := "01"
				U_BIA729A(cDash,"LOGISTICA")
			ELSEIF aRet[1] == 2
				cDash := "02"
				U_BIA729B(cDash,"VENDAS")
			ENDIF

		Else

			lParam := .F.

		Endif

	endDo

Return Nil

// referencia: http://www.blacktdn.com.br/2011/10/protheus-advpl-otimizacao-de-filtro-na.html
// Fonte usado para filtro na consulta padrão ( DASH )  para as DASHBOARDAS  
USER Function BIA72900()

	Local cFilter := ""

	IF Type("cDash") == "C"

		cFilter := "@#"
		cFilter += "LEFT(X5_CHAVE,2) == '"+cDash+"'"
		cFilter += "@#"

	EndIf

Return cFilter

/*

USE [DADOSADV]
GO

INSERT INTO [dbo].[SX5010]
           ([X5_FILIAL]
           ,[X5_TABELA]
           ,[X5_CHAVE]
           ,[X5_DESCRI]
           ,[X5_DESCSPA]
           ,[X5_DESCENG]
           
           
           )
     VALUES
           (''
           ,'Z0'
           ,'01'
           ,'DASHBOARD LOGISTICA'
           ,'DASHBOARD LOGISTICA'
           ,'DASHBOARD LOGISTICA'           
           )           
GO




*/