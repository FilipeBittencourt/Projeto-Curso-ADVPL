#include "rwmake.ch" 
#include "topconn.ch"

/*/{Protheus.doc} SD1100E
@author Microsiga Vit¢ria
@since 22/03/16
@version 1.0
@description Ponto de Entrada na Exclusao da Nota Fiscal Entrada ...
.            utilizado para excluir o imposto de renda, ISS e INSS ...
.            dos fornecedores atuais.
.            Retiradas de uso todas as funcionalidades em 25/07/17 por Marcos Alberto Soprani.
.            Restando apenas a função do Fernando.
@type function
/*/

User Function SD1100E()

	//Fernando/Facile em 06/02/2015 - baixa de OP Vitcer
	U_FOPVCR03()

Return
