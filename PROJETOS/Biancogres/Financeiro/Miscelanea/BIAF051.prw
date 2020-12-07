#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF051
@author Tiago Rossini Coradini
@since 25/10/2016
@version 1.0
@description Rotina para visualizar Histórico de Tarifas do Contas a Receber.
@type function
/*/

User Function BIAF051(cEmpresa, cPrefixo, cNumero, cParcela, cTipo)
Local oDlg
Local oFont := TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)
Local oSay
Local oSButton
Local oWBrowse
Local aWBrowse := {}

	Default cEmpresa := cEmpAnt
	Default cPrefixo := SE1->E1_PREFIXO
	Default cNumero := SE1->E1_NUM
	Default cParcela := SE1->E1_PARCELA
	Default cTipo := SE1->E1_TIPO

  aWBrowse := fWBrowse(cEmpresa, cPrefixo, cNumero, cParcela, cTipo)
  
  If Len(aWBrowse) > 0
  
  	DEFINE MSDIALOG oDlg FROM 000, 000  TO 250, 700 COLORS 0, 16777215 PIXEL   
    
  		@ 006, 132 SAY oSay PROMPT "Histórico de Tarifas" SIZE 083, 009 OF oDlg FONT oFont COLORS 0, 16777215 PIXEL
  	
  		@ 019, 008 LISTBOX oWBrowse Fields HEADER "Data", "Valor", "Historico", "Banco ", "Agencia", "Conta" SIZE 332, 084 OF oDlg PIXEL ColSizes 50,50
		
  		oWBrowse:SetArray(aWBrowse)
		
  		oWBrowse:bLine := {|| {aWBrowse[oWBrowse:nAt,1], aWBrowse[oWBrowse:nAt,2], aWBrowse[oWBrowse:nAt,3], aWBrowse[oWBrowse:nAt,4],;
													 aWBrowse[oWBrowse:nAt,5], aWBrowse[oWBrowse:nAt,6]}}
	   
	    DEFINE SBUTTON oSButton FROM 108, 313 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()
	
	  ACTIVATE MSDIALOG oDlg CENTERED

	Else
		
		MsgAlert("Não existem tarifas para este título.")
		
		Return()
	
	EndIf

Return()


Static Function fWBrowse(cEmpresa, cPrefixo, cNumero, cParcela, cTipo)
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSE5 := "SE5" + cEmpresa + "0"

	cSQL := " SELECT E5_DATA, E5_VALOR,  E5_HISTOR, E5_BANCO, E5_AGENCIA, E5_CONTA "
	cSQL += " FROM "+ cSE5
	cSQL += " WHERE E5_FILIAL = "+ ValToSQL(xFilial("SE5"))
	cSQL += " AND E5_TIPODOC = 'DB' " 
	cSQL += " AND E5_PREFIXO = "+ ValToSQL(cPrefixo)
	cSQL += " AND E5_NUMERO = "+ ValToSQL(cNumero) 
	cSQL += " AND E5_PARCELA = "+ ValToSQL(cParcela)
	cSQL += " AND E5_TIPO = "+ ValToSQL(cTipo)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY E5_DATA "

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())
	
		Aadd(aRet, {CTOD(SUBSTR((cQry)->E5_DATA,7,2) +"/"+ SUBSTR((cQry)->E5_DATA,5,2) +"/"+ SUBSTR((cQry)->E5_DATA,1,4)),;
								TRANS((cQry)->E5_VALOR,"@E 999,999.99"), (cQry)->E5_HISTOR, (cQry)->E5_BANCO, (cQry)->E5_AGENCIA, (cQry)->E5_CONTA})
  
	  (cQry)->(DbSkip())
	
  EndDo()
		
  (cQry)->(DbCloseArea())	
		
Return(aRet)