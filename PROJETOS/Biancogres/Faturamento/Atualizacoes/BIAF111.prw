#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF111
@author Tiago Rossini Coradini
@since 26/06/2018
@version 1.0
@description Rotina para cadastro de Modelos de Veiculo por Marca 
@obs Ticket: 1292
@type Function
/*/

User Function BIAF111()
Private bDelete := {|| fDelete() }
Private cDelete := "Eval(bDelete)"
Private bSave := {|| fSave() }
Private cSave := "Eval(bSave)"
Private cString := "ZCG"

	dbSelectArea(cString)
	dbSetOrder(1)

	AxCadastro(cString, "Modelos de Veiculo por Marca", cDelete, cSave)	

Return()


Static Function fDelete()
Local aArea := GetArea()
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT DA3_COD "
	cSQL += " FROM " + RetSQLName("DA3")
	cSQL += " WHERE DA3_FILIAL = " + ValToSQL(xFilial("DA3"))
	cSQL += " AND DA3_YCODMO = " + ValToSQL(ZCG->ZCG_CODIGO)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	  			
	If !Empty((cQry)->DA3_COD)
		
		lRet := .F.
			
		MsgStop("Atenção, não será possível excluir o modelo, pois o mesmo está associado a veículo(s).")
				
	EndIf
	
	(cQry)->(dbCloseArea())

	RestArea(aArea)

Return(lRet)


Static Function fSave()
Local lRet := .T.	

Return(lRet)