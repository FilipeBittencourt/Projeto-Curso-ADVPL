#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} BIA701
@author Wlysses Cerqueira (Facile)
@since 15/07/2020  
@project C-15
@version 1.0
@description 
@type function
/*/

User Function BIA701()

	Local aArea     := GetArea()
	Local aCores    := {}
	Local aIndDAK   := {}
	Local cCondicao := ""

	Private cCadastro   := "Integração Baixa por Quebra"
	Private aRotina 	:= {}
    Private aCores      := {}

    aAdd(aRotina, { "Pesquisa"      , "AxPesqui"	, 0, 1 })
	aAdd(aRotina, { "Visualizar"    , "AxVisual"	, 0, 2 })
	aAdd(aRotina, { "Incluir"       , "U_BIA701INC"	, 0, 3 })				
	aAdd(aRotina, { "Alterar"       , "U_BIA701ALT"	, 0, 5 })						
	aAdd(aRotina, { "Legenda"       , "U_BIA701LEG"	, 0, 8 })	
	aAdd(aRotina, { "Processar"     , "U_BIA701PRO"	, 0, 9 })							

	aAdd(aCores, { "ZL8_STATUS == 'A'" , 'BR_VERMELHO' 	})
	aAdd(aCores, { "ZL8_STATUS == 'P'" , 'BR_VERDE' 		})
	aAdd(aCores, { "ZL8_STATUS == 'B'" , 'BR_AMARELO' 	})
	aAdd(aCores, { "ZL8_STATUS == 'E'" , 'BR_PRETO' 	})

	DbSelectArea("ZL8")

	DbSetOrder(1)
	
	mBrowse(6, 1, 22, 75, "ZL8",,,,,, aCores)

Return()      

USer Function BIA701INC()

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local nOpcao	:= 0
	Local cAlias	:= "ZL8" 
	Private cMail	:= ""

	nOpcao := AxInclui(cAlias)

	If nOpcao == 1

		MsgInfo("Operacao realizada com sucesso!")

	Endif

	RestArea(aArea)

Return(lRet)


USer Function BIA701ALT()

	Local lRet		 := .T.
	Local aArea		 := GetArea()
	Local nOpcao	 := 0
	Private aCpos	 := {} //{"ZL8_DATAINI","ZL8_DATALIM","ZL8_OBS","ZL8_VALOR"}
	Private aButtons := {}

	//aAdd( aButtons, { "PEDIDO", {|| wVisual() }, "Pedido", "Visual. Pedido" } ) 
	If (ZL8->ZL8_STATUS <> 'P')
		aCpos := {"ZL8_STATUS"}
	EndIf
	
	nOpcao := AxAltera("ZL8",ZL8->(Recno()),4,,aCpos,,,,"",,aButtons,,,,.T.,,,,,)

	If nOpcao == 1

		MsgInfo("Operacao realizada com sucesso!")

	EndIf

	RestArea(aArea)

Return(lRet)

USer Function BIA701EXC()

	Local lRet  := .T.
	Local aArea := GetArea()

	AxDeleta("ZL8", ZL8->(Recno()), 5)

	RestArea(aArea)

Return(lRet)
                    
User Function BIA701LEG()     

    Local aLegenda := {}
    
    aAdd(aLegenda, { "BR_VERMELHO"  , "Aguard. Processamento"   })
	aAdd(aLegenda, { "BR_VERDE"		, "Processado"	  			})
	aAdd(aLegenda, { "BR_AMARELO"	, "Bloqueado"	 			})
	aAdd(aLegenda, { "BR_PRETO"	    , "Erro" 		  			})

	BRWLEGENDA( cCadastro, "Legenda", aLegenda )

Return(.T.)


User Function BIA701PRO()
	Local aArea := GetArea()
	
	If (ZL8->ZL8_STATUS <> 'P' )
		If (!Empty(ZL8->ZL8_CODEMP) .And. !Empty(ZL8->ZL8_CODFIL))
			Processa( {|| StartJob("U_PROCQBIT", GetEnvServer(), .T., ZL8->ZL8_CODEMP, ZL8->ZL8_CODFIL, ZL8->(Recno()))}, "Integração Baixa por Quebra", "Processando...", .T.)
		Else
			MsgInfo("Cod. Empresa e Cod. Filial não preenchido.")
		EndIf
	Else
		MsgInfo("Registro já processado.")
	EndIf
	
	RestArea(aArea)
Return 