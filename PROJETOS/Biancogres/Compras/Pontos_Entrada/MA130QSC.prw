#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} MA130QSC
@author Barbara Luan Gomes Coelho
@since 10/07/2019
@version 1.0
@description Inclui códigos para quebra de solicitação de Compras
.            é executado no início da rotina de processamento da solicitação de compra 
.            que deve gerar cotação, permitindo incluir um bloco de código que 
.            realizará as quebras das solicitações de compras.
@type function
/*/

User Function MA130QSC()

Local cValid:={|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI + DTOS(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL +C1_YTAG}   
ConOut("MA130QSC - Quebra da SC:"+ cValid)

Return({|| cValid })