#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} F050MDVC
possibilita que o cliente calcule sua própria data de vencimento de ímpostos.
É chamado na rotina que calcula a data de vencimento dos impostos.
@type function
@author Pontin
@since 25/07/2017
@version 1.0
/*/
User function F050MDVC()

	Local dNextDay 	:= ParamIxb[1] //|data calculada pelo sistema |
	Local cIMposto 	:= ParamIxb[2]
	Local dEmissao 	:= ParamIxb[3]
	Local dEmis1 	:= ParamIxb[4]
	Local dVencRea 	:= ParamIxb[5]
	Local nNextMes 	:= Month(dVencRea)+1
	
	If cImposto $ "PIS,CSLL,COFINS"
		
		//|Calcula data 20 do próximo mes |
		dNextDay := CTOD("20/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+; 
					Substr(Str(Iif(nNextMes==13,Year(dVencRea)+1,Year(dVencRea))),2)) 
		
		//|Acho o ultimo dia util do periodo desejado |
		dNextday := DataValida(dNextday,.F.)
	
	EndIf 

Return dNextDay

