#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG047
@author Gabriel Rossi Mafioletti
@since 09/07/2018
@version 1.0
@description Fun��o para alertar que campos devem ser revisados ao alterar certos campos do cadastro de funcion�rio
@type function
/*/

User Function BIAFG047()

	Aviso( 'BIAFG047', 'Favor verificar os campos: %Acid.Trab e Ocorr�ncia!', {'Ok'} )

Return .T.