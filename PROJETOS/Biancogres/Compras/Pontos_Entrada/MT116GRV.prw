#Include 'Protheus.ch'

/*/{Protheus.doc} MT116GRV
Este ponto de entrada pertence a rotina de digitação de conhecimento de frete,
MATA116(). É executado na rotina de inclusão do conhecimento de frete, A116INCLUI(), 
quando a tela com o conhecimento e os itens são montados
@type function
@author Pontin
@since 26/10/2017
@version 1.0
/*/
User Function MT116GRV()
	
	//|Variaveis private da rotina MATA116 |
	cEspecie		:= PadR("CTE",TamSx3("F1_ESPECIE")[1])
	cTPCTE			:= "N - Normal"
	aNFEDanfe[18]	:= "N - Normal"
	
	//CONEXÃO NFE
	U_GTPE008()

Return

