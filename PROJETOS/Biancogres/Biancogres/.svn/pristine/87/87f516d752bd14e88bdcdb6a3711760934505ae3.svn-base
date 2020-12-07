#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} oParam
//Criar Listagem de contas a receber conforme filtro.
@author Pedro Henrique
@since 10/06/2019
@version 1.0
parametersSection
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/


User Function BAF040()

	Local aPergs		:= {}
	Local cRefPer	  	:= 'BAF040' + cEmpAnt
	Local cFileName    	:= __cUserID +"_"+ cRefPer
	Local aParRet		:= {}
	Local aParam		:= {}
	
	Local cPrefixoDe 	:= Space(TamSx3("E1_PREFIXO")[1])
	Local cPrefixoAte 	:= Replicate("Z", TamSx3("E1_PREFIXO")[1])
	Local cNumeroDe 	:= Space(TamSx3("E1_NUM")[1])
	Local cNumeroAte 	:= Replicate("Z", TamSx3("E1_NUM")[1])
	Local cCliDe 		:= Space(TamSx3("E1_CLIENTE")[1])
	Local cCliAte 		:= Replicate("Z", TamSx3("E1_CLIENTE")[1])
	Local dVenctoDe 	:= dDataBase
	Local dVenctoAte 	:= dDataBase
	Local dReferencia 	:= dDataBase
	
	
	aAdd(aPergs, {1, "Prefixo De", 		cPrefixoDe, 	"@!", ".T.",,".T.",,.F.})
	aAdd(aPergs, {1, "Prefixo Ate", 	cPrefixoAte, 	"@!", ".T.",,".T.",,.F.})
	aAdd(aPergs, {1, "Numero De", 		cNumeroDe, 		"@!", ".T.",,".T.",,.F.})
	aAdd(aPergs, {1, "Numero Ate", 		cNumeroAte, 	"@!", ".T.",,".T.",,.F.})
	aAdd(aPergs, {1, "Cliente De", 		cCliDe, 		"@!", ".T.","SA1",".T.",,.F.})
  	aAdd(aPergs, {1, "Cliente Ate", 	cCliAte, 		"@!", ".T.","SA1",".T.",,.F.})
	aAdd(aPergs, {1, "Dt. Vencto De", 	dVenctoDe, 		"@D", ".T.",,".T.",,.F.})
	aAdd(aPergs, {1, "Dt. Vencto Ate", 	dVenctoAte, 	"@D", ".T.",,".T.",,.F.})
	aAdd(aPergs, {1, "Dt. Referencia", 	dReferencia, 	"@D", ".T.",,".T.",,.F.})	
	

	If !ParamBox(aPergs, "Filtro", aParRet, ,,,,,, cFileName, .T., .T.)
		
		Return
			
	EndIf
			
	cPrefixoDe 	:= aParRet[1]
	cPrefixoAte := aParRet[2]
	cNumeroDe 	:= aParRet[3]
	cNumeroAte 	:= aParRet[4]
	cCliDe 		:= aParRet[5]
	cCliAte 	:= aParRet[6]
	dVenctoDe 	:= aParRet[7]
	dVenctoAte 	:= aParRet[8]
	dReferencia	:= aParRet[9]
	
	aParam := {;
			cPrefixoDe,;
			cPrefixoAte,;
			cNumeroDe,;
			cNumeroAte,;
			cCliDe,;
			cCliAte,;
			dVenctoDe,;
			dVenctoAte,;
			dReferencia,;
			cRepAtu;
			}	
	
	U_BIAMsgRun("Selecionando registros...", "Aguarde!", {|| fProcess(aParam) })
			
	
Return()


Static Function fProcess(aParam)
	Local oWObj := Nil
		
	oWObj := TWAFImprimirBoletoReceber():New(aParam)

	oWObj:Activate()

Return()