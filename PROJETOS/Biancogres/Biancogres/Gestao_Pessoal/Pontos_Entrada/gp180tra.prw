#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GP180TRA
@author Marcos Alberto Soprani
@since 24/08/16
@version 1.0
@description Ponto de Entrada executado logo após a atualização dos dados da tabela Cadastro de Funcionários (SRA). 
.            A tabela fica posicionada no funcionário que foi transferido, e as informações atualizadas ficam disponíveis e podem 
.            ser utilizadas em outros módulos do sistema ou rotinas específicas.
@obs OS: 3338-16 - FRANCINE DIAS DE ABREU ARAÚJO
@type function
/*/

User Function GP180TRA()

	Local cfgrArea := GetArea()

	U_BIAF043("0")

	RestArea(cfgrArea)

Return
