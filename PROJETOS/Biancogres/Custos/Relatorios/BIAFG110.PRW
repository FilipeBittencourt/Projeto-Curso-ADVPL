#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG110
@author Gabriel Rossi Mafioletti
@since 02/09/2019
@version 1.0
@description Relatório Custo Unitário Orçamento 
@type function
/*/

User Function BIAFG110()

	If !ValidPerg()
		Return
	EndIf

	Processa({ || RptDetail() })

Return

Static Function RptDetail()

	Local _cAlias	:=	GetNextAlias()
	Local _cDataDe	:=	Dtos(MV_PAR04)
	Local _cDataAte	:=	Dtos(MV_PAR05)
	Local _aDados	:=	{}
	Local xCamp	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:Z46%
		WHERE Z46_FILIAl = %XFILIAL:Z46%
		AND Z46_VERSAO = %Exp:MV_PAR01%
		AND Z46_REVISA = %Exp:MV_PAR02%
		AND Z46_ANOREF = %Exp:MV_PAR03%
		AND Z46_COD BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
		AND Z46_DATARF BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		AND %NotDel%
		ORDER BY Z46_FILIAL, Z46_DATARF, Z46_COD, R_E_C_N_O_

	EndSql

	If (_cAlias)->(!EOF())

		AADD(xCamp,{ "DATA"       ,"D",8,0 } )
		AADD(xCamp,{ "PROPAI"     ,"C",15,0 } )
		AADD(xCamp,{ "DSCPAI"     ,"C",70,0 } )
		AADD(xCamp,{ "NIVEL"      ,"C",03,0 } )
		AADD(xCamp,{ "SG1COD"     ,"C",15,0 } )
		AADD(xCamp,{ "SGGDSC"     ,"C",70,0 } )
		AADD(xCamp,{ "COMP"       ,"C",15,0 } )
		AADD(xCamp,{ "DESCR"      ,"C",70,0 } )
		AADD(xCamp,{ "REVISA"     ,"C",03,0 } )
		AADD(xCamp,{ "UM"         ,"C",02,0 } )
		AADD(xCamp,{ "SEQUEN"     ,"C",03,0 } )
		AADD(xCamp,{ "QUANT"      ,"N",18,8 } )
		AADD(xCamp,{ "CUNIT"      ,"N",14,4 } )
		AADD(xCamp,{ "CTOTAL"     ,"N",14,4 } )
		AADD(xCamp,{ "RF"         ,"C",02,0 } )
		AADD(xCamp,{ "DTCTO"      ,"C",08,0 } )
		AADD(xCamp,{ "EMPR"       ,"C",02,0 } )
		AADD(xCamp,{ "PROJET"     ,"N",14,4 } )
		AADD(xCamp,{ "PERCT"      ,"N",08,2 } )
		AADD(xCamp,{ "UMIDAD"     ,"N",08,2 } )
		AADD(xCamp,{ "KEY"        ,"C",20,0 } )
		AADD(xCamp,{ "DESCRC"     ,"C",40,0 } )
		AADD(xCamp,{ "ITCUS"      ,"C",03,0 } )
		AADD(xCamp,{ "ITCUSDSC"   ,"C",45,0 } )

		While (_cAlias)->(!EOF())

			(_cAlias)->(aAdd(_aDados,{;	
			DTOC(STOD(Z46_DATARF)),;
			Z46_COD,;
			ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+Z46_COD,"B1_DESC")),;
			Z46_NIVEL,;
			Z46_SG1COD,;
			ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+Z46_SG1COD,"B1_DESC")),;
			Z46_COMP,;
			ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+Z46_COMP,"B1_DESC")),;
			Z46_REVATU,;
			POSICIONE("SB1",1,xFilial("SB1")+Z46_COMP,"B1_UM"),;
			Z46_TRT,;
			Transform(Z46_QUANT,"@E 999,999.99999999"),;
			Transform(Z46_CUNIT,"@E 9,999,999.9999"),;
			Transform(Z46_CTOTAL,"@E 9,999,999.9999"),;
			Z46_RF,;
			Z46_DTCSTO,;
			Z46_EMPR,;
			Transform(Z46_PROJET,"@E 99999.9999"),;
			Transform(Z46_PERCT,"@E 99999.99"),;
			Transform(Z46_UMIDAD,"@E 99999.99"),;
			Z46_CONTA,;
			Alltrim(POSICIONE("CT1", 1, xFilial("CT1") + Z46_CONTA, "CT1_DESC01")),;
			Z46_ITCUS,;
			Alltrim(POSICIONE("Z29", 1, xFilial("Z29") + Z46_ITCUS, "Z29_DESCR"));			
			}))

			(_cAlias)->(DbSkip())

		EndDo

		U_BIAxExcel(_aDados, xCamp, "BIAFG110"+strzero(seconds()%3500,5) )

		(_cAlias)->(DbCloseArea())

	Else

		MsgInfo("Não há Dados para exibição")

	EndIf

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG110" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := SPACE(TAMSX3("Z98_VERSAO")[1])
	MV_PAR02 := SPACE(TAMSX3("Z98_REVISA")[1])
	MV_PAR03 := SPACE(TAMSX3("Z98_ANOREF")[1])
	MV_PAR04 := Stod("")
	MV_PAR05 := Stod("")
	MV_PAR06 := SPACE(TAMSX3("B1_COD")[1])
	MV_PAR07 := SPACE(TAMSX3("B1_COD")[1])

	aAdd( aPergs ,{1,"Versão " 	   		,MV_PAR01 ,""  ,"",'ZB5'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Revisão " 	   	,MV_PAR02 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"AnoRef " 	   		,MV_PAR03 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Data De " 	   	,MV_PAR04 ,""  ,"",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data Ate " 	   	,MV_PAR05 ,""  ,"",''  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Produto De " 	   		,MV_PAR06 ,""  ,"",'SB1'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto Ate " 	   		,MV_PAR07 ,""  ,"",'SB1'  ,'.T.',50,.T.})	

	If ParamBox(aPergs ,"Relatório Custo Unitário Orçamento",,{||.T.},,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)
		MV_PAR07 := ParamLoad(cFileName,,7,MV_PAR07)

	EndIf

Return lRet
