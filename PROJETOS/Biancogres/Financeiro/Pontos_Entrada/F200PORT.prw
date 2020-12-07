#include "protheus.ch"

/*/{Protheus.doc} F200PORT
@author Ranisses A. Corona
@since 30/04/15
@version 1.0
@description P.E. para validar portador do titulo no retorno de cobranca FINA200.
			.T. = Utiliza o portador do titulo, ignorando o banco do retorno CNAB 
			.F. = Utiliza o banco fornecido nos parametros da rotina			
@type function
/*/

User Function F200PORT()    
Local	lRet := .T.
Public __lBaixarPr := .F. // Variavel utilizado no P.E. F200AVL e na Classe TRecebimentoAntecipado   

Return(lRet)