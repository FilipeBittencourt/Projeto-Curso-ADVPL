#include "rwmake.ch" 

/*/{Protheus.doc} BIA025
@author MICROSIGA VITORIA
@since 11/06/99
@version 1.0
@description Obriga a digitacao do Classe de Valor Solicitacao/Pedido
@author Marcos Alberto Soprani
@since 16/03/17
@description Nesta data ajustado devido integração do projeto Buy Now 
/*/

User Function BIA025() 

	Local wProd 	:= ""
	Local wQuant	:= 0
	Local wCLVL		:= ""

	If Upper(Alltrim(FunName())) $ "MATA110/EICSI400/BIA773/BIAFG028"       

		wProd	:= Gdfieldget("C1_PRODUTO",n)
		wQuant	:= Gdfieldget("C1_QUANT",n)
		wCLVL	:= Gdfieldget("C1_CLVL",n)

	Else

		wQuant	:= Gdfieldget("C7_QUANT",n)
		wCLVL	:= Gdfieldget("C7_CLVL",n)

	EndIf

	If Len(Alltrim(wProd)) == 7	.and. Subs(wProd,4,4) == "0000" .and. Len(Alltrim(wCLVL)) == 0	

		Help(" ",1,"HCOMA001")
		wQuant := 0

	Endif

Return(wQuant)
