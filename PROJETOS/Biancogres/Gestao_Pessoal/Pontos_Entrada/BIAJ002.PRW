#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAJ002
@author Jussara F. Nóbrega
@since 24/04/2019
@version 1.0
@description Função para alertar que campos devem ser revisados ao alterar certos campos do cadastro de funcionário
@type function
/*/

User Function BIAJ002()

	IF SUBSTR(M->RA_MAT,1,3) == '100' .and. (M->RA_CATFUNC) = 'E' .and. !empty(M->RA_SINDICA) 
		
		MsgStop("Para estagiários o Sindicato não precisa ser preenchido") 
		return .f.
	ENDIF
	
	IF SUBSTR(M->RA_MAT,1,3) <> '100' .and. empty(M->RA_SINDICA)
		
		MsgStop("Favor preencher o Codigo do Sindicato")
		return .f.
	ENDIF
	

Return .T.