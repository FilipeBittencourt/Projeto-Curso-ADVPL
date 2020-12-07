#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MA131QSC
@author Gabriel Mafioletti
@version 1.0
@description Ponto de Entrada que manipula a quebra de itens para aglutinação de podutos na Cotação (FUNCIONA EM CONJUNTO COM O MA131KEY)
@type function
/*/


User Function MA131QSC()

	Local _bQuebra	:=	PARAMIXB[1]
	
	If MV_PAR15 == 1
		_bQuebra	:=	{|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO+C1_OP+C1_LOCAL}
	Else
		_bQuebra	:=	{|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO+C1_LOCAL}
	EndIf

Return _bQuebra 
