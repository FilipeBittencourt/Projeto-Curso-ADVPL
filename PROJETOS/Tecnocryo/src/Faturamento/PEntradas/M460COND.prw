#include 'protheus.ch'
#include 'parmtype.ch'

user function M460COND()

	Local dDataCnd := M->PARAMIXB[ 1 ]

	//Atribui data de entrega à data de início de desdobramento das parcelas
	dDataCnd := GetdataEntrega( dDataCnd )

return dDataCnd

//Pega data de entrega 
Static Function GetDataEntrega( dDataCnd )

	IF  ( SF2->F2_DOC + SF2->F2_SERIE ) <>  ( SD2->D2_DOC + SD2->D2_SERIE )
		POSICIONE( "SD2", 3, XFILIAL( 'SD2' ) +   ( SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ), 'FOUND()' )
	ENDIF

	IF POSICIONE( "SC6", 1, XFILIAL( 'SC6' ) +   ( SD2->D2_PEDIDO + SD2->D2_ITEMPV ), 'FOUND()' )
		dDataCnd := SC6->C6_ENTREG
	ENDIF

Return dDataCnd