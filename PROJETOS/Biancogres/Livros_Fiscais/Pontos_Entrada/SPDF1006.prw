#include "totvs.ch"


/*/{Protheus.doc} SPDF1006
O ponto de entrada SPDF1006 permite o envio do nome do campo da tabela SE1 
utilizado para a seleção dos registros enviados e o campo que compõe o bloco F100.
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 03/05/2021
@return character, Nome do campo da SE1
/*/
User Function SPDF1006()

Local cNomeDt := "" //Nome do campo de data que deseja enviar no BLOCO F100 do SPED PIS COFINS.

cNomeDt := "E1_EMISSAO"

Return cNomeDt
