#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} M290QSD3
@author Gabriel Rossi Mafioletti
@since 05/06/2017
@version 1.0
@description Ponto de Entrada para incluir 
			customização na query do custo médio do mês
@type function
/*/

User Function M290QSD3()

Local _cQuery	:=	" AND SD3.D3_YPARADA <> 'S' "

return _cQuery