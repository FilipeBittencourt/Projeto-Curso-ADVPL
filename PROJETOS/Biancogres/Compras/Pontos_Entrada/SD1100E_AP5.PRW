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
	Local _oMd	:=	TBiaControleMD():New()
	//Fernando/Facile em 06/02/2015 - baixa de OP Vitcer
	U_FOPVCR03()

	If Alltrim(SF1->F1_TIPO) == 'N' .And. _oMd:CheckMD(SD1->D1_COD,SD1->D1_LOCAL) .AND. _oMd:MovimentaEstoque(SD1->D1_TES)
		_oMd:EstornaMovimentacao(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ITEM,SD1->D1_COD,SD1->D1_LOCAL,FunName(),"SD1",cUserName)
	EndIf	

Return
